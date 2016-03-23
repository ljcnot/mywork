use newfTradeDB2
/*
	武大外贸合同管理信息系统-学校用户表设计
	根据警用地理信息系统、设备管理系统改编，将用户表改成学校员工登记表，将其与系统登录用户表分离！系统登录用户表独立到sysUserInfo表中。
	author:		卢苇
	客户要求：
	用户分级问题：
	1.用户分三级：校级、院级、科室级，可以调阅的权限分别为：全校、全院、全科室的设备.使用角色分级和数据对象的操作范围约束实现!
	2.支持游客，只能查询，不能生成报表
	CreateDate:	2010-11-22
	UpdateDate: by lw 2011-9-12 修改用户表，支持多重角色，去除用户权限表，将用户权限改为动态计算。
				
*/
select * from userInfo
--1.学校用户信息表 （userInfo）：
select u.jobNumber,u.cName,u.pID,u.mobileNum,u.telNum,u.e_mail,u.homeAddress,u.clgCode,u.clgName,u.uCode,u.uName,
	s.sysUserName,s.sysUserDesc,
    case s.isOff when '0' then '√' else '' end isOff,
    case s.isOff when '0' then '' else convert(char(10), setOffDate, 120) end offDate,
    u.modiManID,u.modiManName,u.modiTime,u.lockManID
from userInfo u left join sysUserInfo s on u.jobNumber= s.userID and s.userType = 1

	--改造userInfo表：
alter TABLE userInfo drop column sysUserName
alter TABLE userInfo drop column sysUserDesc
alter TABLE userInfo drop column sysPassword
alter TABLE userInfo drop column pswProtectQuestion
alter TABLE userInfo drop column psqProtectAnswer
alter TABLE userInfo drop column isOff
alter TABLE userInfo drop column setOffDate
	--从设备管理系统导入数据：
insert userInfo(jobNumber, cName, pID, mobileNum, telNum, e_mail, homeAddress, clgCode, clgName, uCode, uName)
select jobNumber, cName, pID, mobileNum, telNum, e_mail, homeAddress, clgCode, clgName, uCode, uName
from epdc211.dbo.userInfo

alter TABLE userInfo add	inputCode varchar(5) null			--姓名输入码 add by lw 2012-4-24
update userInfo
set inputCode = upper(dbo.getChinaPYCode(cName))

select * from userInfo where cName like '%谢晓芬%'
drop TABLE userInfo
CREATE TABLE userInfo
(
	jobNumber varchar(10) not null,		--工号：主键
	
	--个人信息：
	cName nvarchar(30) not null,		--姓名
	inputCode varchar(5) null,			--姓名输入码 add by lw 2012-4-24
	pID varchar(18) null,				--身份证号
	mobileNum varchar(20) null,			--手机号码
	telNum varchar(30) null,			--电话号码
	e_mail varchar(30) null,			--E_mail地址
	homeAddress nvarchar(100) null,		--住址
	
	--隶属信息:
	clgCode char(3) not null,			--所属学院代码
	clgName nvarchar(30) not null,		--所属学院名称:冗余设计
	uCode varchar(8) null,				--所属使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) null,			--所属使用单位名称:冗余设计

	--最新维护情况:
	modiManID varchar(10) null,		--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10) null,			--当前正在锁定编辑人工号
CONSTRAINT [PK_userInfo] PRIMARY KEY CLUSTERED 
(
	[jobNumber] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


select * from userInfo

drop PROCEDURE checkJobNumber
/*
	name:		checkJobNumber
	function:	0.1.检查工号是否唯一
	input: 
				@jobNumber varchar(10),		--工号
	output: 
				@Ret		int output
							0:唯一，>1：不唯一，-1：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE checkJobNumber
	@jobNumber varchar(10),		--工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from userInfo where jobNumber = @jobNumber)
GO

drop PROCEDURE addUser
/*
	name:		addUser
	function:	1.添加用户
				注意：这个存储过程检查工号和系统登陆名的唯一性！
	input: 
				@jobNumber varchar(10),		--工号：主键
				--个人信息：
				@cName nvarchar(30),		--姓名
				@pID varchar(18),			--身份证号
				@mobileNum varchar(20),		--手机号码
				@telNum varchar(30),		--电话号码
				@e_mail varchar(30),		--E_mail地址
				@homeAddress nvarchar(100),	--住址
				
				--隶属信息：
				@clgCode char(3),			--所属学院代码
				@uCode varchar(8),			--所属使用单位代码
				
				--最新维护情况:
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output,
							0:成功，1:该工号已经登记过，2:该用户名已经被注册过了，9:未知错误
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2011-9-4去除角色中文名，增加角色分级类型处理
				modi by lw 2011-9-12修改用户表，支持多重角色，去除用户权限表，将用户权限改为动态计算。
				modi by lw 2012-4-18根据系统登录用户表分离设计要求删除相应的登录信息
*/
create PROCEDURE addUser
	@jobNumber varchar(10),		--工号：主键
	--个人信息：
	@cName nvarchar(30),		--姓名
	@pID varchar(18),			--身份证号
	@mobileNum varchar(20),		--手机号码
	@telNum varchar(30),		--电话号码
	@e_mail varchar(30),		--E_mail地址
	@homeAddress nvarchar(100),	--住址
	
	--隶属信息：
	@clgCode char(3),			--所属学院代码
	@uCode varchar(8),			--所属使用单位代码
	
	--最新维护情况:
	@createManID varchar(10),	--创建人工号

	@Ret int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查工号是否唯一：
	declare @count as int
	set @count = (select count(*) from userInfo where jobNumber = @jobNumber)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--取院部名称和使用单位名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)		--所属学院名称、所属使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
		 
	--取添加人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert userInfo (jobNumber,
				--个人信息：
				cName, pID, mobileNum, telNum, e_mail, homeAddress,
				--隶属信息：
				clgCode, clgName, uCode, uName,
				--最新维护情况:
				modiManID, modiManName, modiTime)
	values(@jobNumber,
				--个人信息：
				@cName, @pID, @mobileNum, @telNum, @e_mail, @homeAddress,
				--隶属信息：
				@clgCode, @clgName, @uCode, @uName,
				--最新维护情况:
				@createManID, @createManName, @createTime)

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'注册用户','系统根据' + @createManName + 
								'的要求登记了学校员工[' + @cName + '('+ @jobNumber +')]的信息。')
GO


--1.2对象的LOGO图片文件名登记表 （logoFileInfo）：
drop TABLE logoFileInfo
CREATE TABLE logoFileInfo
(
	myID varchar(10) NOT NULL,			--LOGO图片对应的对象ID
	logoID int NOT NULL,				--logo的ID
	logoGUID36 varchar(36) NULL,		--logo对应的36位全球唯一编码文件名
	logoExtFileName varchar(4) NULL,	--logo的扩展名
CONSTRAINT [PK_logoFileInfo] PRIMARY KEY CLUSTERED 
(
	[myID] ASC,
	[logoID]
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE addLogo
/*
	name:		addLogo
	function:	向当前图片的左侧或右侧插入新的图片
				注意：这需要图片的编号是连续的，所以删除需要特殊处理！
	input: 
				@myID varchar(10),			--LOGO图片对应的对象ID
				@curLogo int,				--当前图片的编号
				@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
				@logoExtFileName varchar(4),--插入的Logo文件扩展名
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，1：出错

				@logoGUID36 varchar(36) output,--系统分配的唯一文件名
				@thisLogoID int output		--插入的Logo编号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE addLogo
	@myID varchar(10),			--LOGO图片对应的对象ID
	@curLogo int,				--当前图片的编号
	@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
	@logoExtFileName varchar(4),--插入的Logo文件扩展名

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--系统分配的唯一文件名
	@thisLogoID int output		--插入的Logo编号
	WITH ENCRYPTION 
AS
	set @Ret = 1

	--判断当前编号的图片是否存在，根据方向生成要插入的图片的编号
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @myID and logoID = @curLogo)	
	begin tran
		if (@count > 0)	--该图片存在，计算插入图片的编号
		begin
			if (@insertDir = 1)	--在右侧插入
			begin
				update logoFileInfo
				set logoID = logoID + 1 
				where myID = @myID and logoID > @curLogo
				set @thisLogoID = @curlogo + 1
			end
			else	--在左侧插入
			begin
				update logoFileInfo
				set logoID = logoID + 1 
				where myID = @myID and logoID >= @curLogo
				set @thisLogoID = @curlogo 
			end
		end
		else 	--第1次插入图片
		begin
			set @thisLogoID = 0
		end

		--生成唯一的文件名：
		set @logoGUID36 = (select newid())

		--登记图片信息：
		insert dbo.logoFileInfo(myID, logoID, logoGUID36, logoExtFileName)
		values(@myID, @thisLogoID, @logoGUID36, @logoExtFileName)
	commit tran
	set @Ret = 0
GO

drop PROCEDURE delLogo
/*
	name:		delLogo
	function:	删除指定对象的当前图片
				注意：这需要对象图片的编号是连续的，所以删除需要特殊处理！
	input: 
				@myID varchar(10),			--LOGO图片对应的对象ID
				@curLogo int,				--当前图片的编号
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，1：要删除的图片不存在，2：出错
				@logoGUID36 varchar(36) output,--当前图片的文件名
				@thisLogoID int output		--删除后当前的图片的编号
	author:		卢苇
	CreateDate:	2010-5-28
	UpdateDate: 
*/
create PROCEDURE delLogo
	@myID varchar(10),			--LOGO图片对应的对象ID
	@curLogo int,				--当前图片的编号

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--当前图片的文件名
	@thisLogoID int output		--删除后当前的图片的编号
	WITH ENCRYPTION 
AS
	set @Ret = 2
	set @thisLogoID = @curLogo

	--判断当前编号的图片是否存在
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @myID and logoID = @curLogo)	
	if (@count = 0)	--该图片不存在
	begin
		set @Ret = 1
		return
	end
	
	begin tran
	--获取要删除的当前图片的文件名：
	declare @GUID36 varchar(36), @extFileName varchar(4)
	select @GUID36 = logoGUID36, @extFileName = logoExtFileName
	from logoFileInfo
	where myID = @myID and logoID = @curLogo
	set @logoGUID36 = @GUID36 + @extFileName 

	delete logoFileInfo where myID = @myID and logoID = @curLogo
	update logoFileInfo set logoID = logoID - 1 where myID = @myID and logoID > @curLogo

	--判断是否删除的是最后一张图片，如果是修正当前图片索引号
	set @count=isnull((select max(logoID) from logoFileInfo where myID = @myID),0)
	if (@count < @curLogo)
	begin
		set @curLogo = @curLogo - 1
	end
	set @thisLogoID = @curLogo

	commit tran
	set @Ret = 0
GO


drop PROCEDURE addUserLogo
/*
	name:		addUserLogo
	function:	3.添加用户的Logo
	input: 
				@jobNumber varchar(10),		--工号
				@curLogo int,				--当前图片的编号
				@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
				@logoExtFileName varchar(4),--插入的Logo文件扩展名

				@addManID varchar(10) output,	--添加人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output,			--操作成功标识
							0:成功，1:不存在该用户，2:该用户信息正被别人锁定，9:未知错误
				@logoGUID36 varchar(36) output,--系统分配的唯一文件名
				@thisLogoID int output		--插入的Logo编号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE addUserLogo
	@jobNumber varchar(10),		--工号
	@curLogo int,				--当前图片的编号
	@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
	@logoExtFileName varchar(4),--插入的Logo文件扩展名

	@addManID varchar(10) output,		--添加人，如果当前用户正在被人占用编辑则返回该人的工号

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--系统分配的唯一文件名
	@thisLogoID int output		--插入的Logo编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查用户是否存在
	declare @count as int
	set @count = (select count(*) from userInfo where jobNumber = @jobNumber)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @addManID)
	begin
		set @addManID = @thisLockMan
		set @Ret = 2
		return
	end

	exec dbo.addLogo @jobNumber, @curLogo, @insertDir, @logoExtFileName, 
			@Ret output, @logoGUID36 output, @thisLogoID output
	if @Ret = 1
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	declare @addTime as smalldatetime
	set @addTime = getdate()

	--取添加人的姓名：
	declare @addManName nvarchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')

	--登记维护信息：
	update userInfo
	set modiManID = @addManID, modiManName = @addManName, modiTime = @addTime
	where jobNumber = @jobNumber

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @addTime, '添加用户Logo', @addManName
												+ '添加了用户['+ @jobNumber +']的一个Logo。')
GO

drop PROCEDURE delUserLogo
/*
	name:		delUserLogo
	function:	4.删除指定用户的当前图片
				注意：这需要用户图片的编号是连续的，所以删除需要特殊处理！
	input: 
				@jobNumber varchar(10),		--工号
				@curLogo int,				--当前图片的编号

				@delManID varchar(10) output,--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，1：要删除的图片不存在，2:该用户信息正被别人锁定，9:未知错误
				@logoGUID36 varchar(36) output,--当前图片的文件名
				@thisLogoID int output		--删除后当前的图片的编号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE delUserLogo
	@jobNumber varchar(10),		--工号
	@curLogo int,				--当前图片的编号

	@delManID varchar(10) output,--删除人，如果当前用户正在被人占用编辑则返回该人的工号

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--当前图片的文件名
	@thisLogoID int output		--删除后当前的图片的编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @thisLogoID = @curLogo

	--判断当前图片是否存在
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	exec dbo.delLogo @jobNumber, @curLogo, @Ret output, @logoGUID36 output, @thisLogoID output
	if @Ret = 2
	begin
		set @Ret = 9
		return
	end

	declare @delTime as smalldatetime
	set @delTime = getdate()

	--取删除人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记维护信息：
	update userInfo
	set modiManID = @delManID, modiManName = @delManName, modiTime = @delTime
	where jobNumber = @jobNumber

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '删除用户Logo', @delManName
												+ '删除了用户['+ @jobNumber +']的一个Logo。')
GO


drop PROCEDURE queryUserLockMan
/*
	name:		queryUserLockMan
	function:	5.查询指定用户是否有人正在编辑
	input: 
				@jobNumber varchar(10),		--工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：查询出错，可能是该工号的用户不存在
				@lockManID varchar(10) output		--当前正在编辑的人工号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE queryUserLockMan
	@jobNumber varchar(10),		--工号
	@Ret		int output,		--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人工号
	WITH ENCRYPTION 
AS
	set @Ret = 1
	set @lockManID = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	set @Ret = 0
GO

drop PROCEDURE lockUser4Edit
/*
	name:		lockUser4Edit
	function:	6.锁定用户编辑，避免编辑冲突
	input: 
				@jobNumber varchar(10),		--工号
				@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的用户不存在，2:要锁定的用户正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE lockUser4Edit
	@jobNumber varchar(10),		--工号
	@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output	--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会员是否存在
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update userInfo 
	set lockManID = @lockManID 
	where jobNumber = @jobNumber
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定用户编辑', '系统根据' + @lockManName
												+ '的要求锁定了用户['+ @jobNumber +']为独占式编辑。')
GO

drop PROCEDURE unlockUserEditor
/*
	name:		unlockUserEditor
	function:	7.释放用户编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@jobNumber varchar(10),		--工号
				@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE unlockUserEditor
	@jobNumber varchar(10),		--工号
	@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin 
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update userInfo set lockManID = '' where jobNumber = @jobNumber
	end
	else
	begin
		set @Ret = 0
		return
	end
	
	set @Ret = 0
	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放用户编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了用户['+ @jobNumber +']的编辑锁。')
GO

drop PROCEDURE updateUserInfo
/*
	name:		updateUserInfo
	function:	8.更新指定的用户信息
	input: 
				@jobNumber varchar(10),		--工号：主键
				--个人信息：
				@cName nvarchar(30),		--姓名
				@pID varchar(18),			--身份证号
				@mobileNum varchar(20),		--手机号码
				@telNum varchar(30),		--电话号码
				@e_mail varchar(30),		--E_mail地址
				@homeAddress nvarchar(100),	--住址
				
				--隶属信息：
				@clgCode char(3),			--所属学院代码
				@uCode varchar(8),			--所属使用单位代码

				--维护情况:
				@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的用户信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-20
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2011-9-4去除角色中文名，增加角色分级类型处理
				modi by lw 2011-9-12修改用户表，支持多重角色，去除用户权限表，将用户权限改为动态计算。
				modi by lw 2011-9-24修改用户信息的时候不允许修改密码。
*/
create PROCEDURE updateUserInfo
	@jobNumber varchar(10),		--工号：主键
	--个人信息：
	@cName nvarchar(30),		--姓名
	@pID varchar(18),			--身份证号
	@mobileNum varchar(20),		--手机号码
	@telNum varchar(30),		--电话号码
	@e_mail varchar(30),		--E_mail地址
	@homeAddress nvarchar(100),	--住址
	
	--隶属信息：
	@clgCode char(3),			--所属学院代码
	@uCode varchar(8),			--所属使用单位代码
	
	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取院部名称和使用单位名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)		--所属学院名称、所属使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update userInfo 
	set cName = @cName, pID = @pID, mobileNum = @mobileNum, telNum = @telNum, e_mail = @e_mail, homeAddress = @homeAddress,
		--隶属信息：
		clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新用户信息', '用户' + @modiManName 
												+ '更新了用户['+ @jobNumber +']的信息。')
GO

drop PROCEDURE delUserInfo
/*
	name:		delUserInfo
	function:	10.删除指定的用户
	input: 
				@jobNumber varchar(10),			--工号
				@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该用户不存在，2:要删除的用户信息正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-6-7发现该存储过程没有执行删除命令
*/
create PROCEDURE delUserInfo
	@jobNumber varchar(10),			--工号
	@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete sysUserInfo where userID = @jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end

		delete userInfo where jobNumber = @jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除用户', '用户' + @delManName
												+ '删除了用户['+ @jobNumber +']的信息。')

GO
--测试：
declare @delManID varchar(10), @Ret int
set @delManID = '2010112301'
exec dbo.delUserInfo '1234561234', @delManID output, @Ret output
select @Ret

select * from userInfo
delete userInfo where jobNumber=''
update userInfo
set lockManID = null

