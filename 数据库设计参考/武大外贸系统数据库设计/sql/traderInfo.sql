use fTradeDB
/*
	武大外贸合同管理信息系统--外贸公司管理
	author:		卢苇
	CreateDate:	2012-3-28
	UpdateDate: 
*/
--1.外贸公司表：
alter TABLE traderInfo add abbTraderName nvarchar(6) null		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
select SUBSTRING(traderName,3,2),* from traderInfo
update traderInfo set abbTraderName = SUBSTRING(traderName,3,2)
delete traderInfo
select * from traderInfo
drop TABLE traderInfo
CREATE TABLE traderInfo
(
	traderID varchar(12) not null,		--主键：外贸公司编号
	traderName nvarchar(30) null,		--外贸公司名称
	abbTraderName nvarchar(6) null,		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
	inputCode varchar(5) null,			--名称输入码
	registeredCapital money null,		--注册资本
	legal nvarchar(30) null,			--法人
	managerID varchar(18) null,			--负责人ID
	manager nvarchar(30) null,			--负责人姓名：冗余设计
	managerMobile varchar(30) null,		--负责人联系手机：冗余设计
	e_mail varchar(30) null,			--E_mail地址：冗余设计
	tel varchar(30) null,				--公司联系电话
	tAddress nvarchar(100) null,		--公司地址
	
	--最新维护情况:
	buildDate smalldatetime default(getdate()),	--建档日期
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

 CONSTRAINT [PK_traderInfo] PRIMARY KEY CLUSTERED 
(
	[traderID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_traderInfo] ON [dbo].[traderInfo] 
(
	[traderName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_traderInfo_1] ON [dbo].[traderInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.外贸公司员工表(允许登录系统的人员)
delete traderManInfo
drop TABLE traderManInfo
CREATE TABLE traderManInfo
(
	traderID varchar(12) not null,		--外键：外贸公司编号
	manID varchar(10) not null,			--主键：员工ID
	pID varchar(18) null,				--身份证号：要做唯一性检查
	manName nvarchar(30) not null,		--员工姓名
	inputCode varchar(5) null,			--名称输入码
	post nvarchar(30) null,				--职务
	mobile varchar(30) null,			--联系手机
	tel varchar(30) null,				--其他电话
	e_mail varchar(30) null,			--E_mail地址
	hAddress nvarchar(100) null,		--家庭地址
	
	--最新维护情况:
	buildDate smalldatetime default(getdate()),	--建档日期
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

 CONSTRAINT [PK_traderManInfo] PRIMARY KEY CLUSTERED 
(
	[manID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[traderManInfo] WITH CHECK ADD CONSTRAINT [FK_traderManInfo_traderInfo] FOREIGN KEY([traderID])
REFERENCES [dbo].[traderInfo] ([traderID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[traderManInfo] CHECK CONSTRAINT [FK_traderManInfo_traderInfo]
GO

--索引：
CREATE NONCLUSTERED INDEX [IX_traderManInfo] ON [dbo].[traderManInfo] 
(
	[manName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_traderManInfo_1] ON [dbo].[traderManInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

	
insert traderInfo(traderID, traderName, abbTraderName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, tAddress,
	buildDate, modiManID, modiManName, modiTime)
select traderID, traderName, abbTraderName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, tAddress,
	buildDate, modiManID, modiManName, modiTime 
from fTradeDB0.dbo.traderInfo
select * from traderInfo
	
insert traderManInfo(traderID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime)
select traderID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime
from fTradeDB0.dbo.traderManInfo

select * from traderManInfo


drop PROCEDURE addTraderInfo
/*
	name:		addTraderInfo
	function:	1.添加外贸公司
				注意：该存储过程自动锁定记录
	input: 
				@traderName nvarchar(30),		--外贸公司名称
				@abbTraderName nvarchar(6),		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
				@inputCode varchar(5),			--名称输入码
				@registeredCapital money,		--注册资本
				@legal nvarchar(30),			--法人
				@manager nvarchar(30),			--负责人
				@managerMobile varchar(30),		--负责人联系手机：检查唯一性
				@e_mail varchar(30),			--E_mail地址
				@tel varchar(30),				--公司联系电话
				@tAddress nvarchar(100),		--公司地址

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1:该负责人的手机已经被别人登记过,9:未知错误
				@createTime smalldatetime output--添加时间
				@traderID varchar(12) output	--主键：外贸公司编号
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: modi by lw 2012-4-27增加简称

*/
create PROCEDURE addTraderInfo
	@traderName nvarchar(30),		--外贸公司名称
	@abbTraderName nvarchar(6),		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
	@inputCode varchar(5),			--名称输入码
	@registeredCapital money,		--注册资本
	@legal nvarchar(30),			--法人
	@manager nvarchar(30),			--负责人
	@managerMobile varchar(30),		--负责人联系手机：检查唯一性
	@e_mail varchar(30),			--E_mail地址
	@tel varchar(30),				--公司联系电话
	@tAddress nvarchar(100),		--公司地址

	@createManID varchar(10),		--创建人工号

	@Ret		int output,			--操作成功标识
	@createTime smalldatetime output,--添加时间
	@traderID varchar(12) output	--主键：外贸公司编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生外贸公司编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 12, 1, @curNumber output
	set @traderID = @curNumber
	--使用号码发生器产生员工编号：
	declare @managerID varchar(18)			--负责人ID
	exec dbo.getClassNumber 13, 1, @curNumber output
	set @managerID = @curNumber

	--检查手机的唯一性：
	declare @iCount int
	if (@managerMobile<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where mobile = @managerMobile)
		if (@iCount = 0)	--继续检查外贸公司员工
			set @iCount = (select count(*) from traderManInfo where mobile = @managerMobile)
		if (@iCount = 0)	--继续检查学校员工
			set @iCount = (select count(*) from userInfo where mobileNum = @managerMobile)
		if (@iCount = 0)	--继续检查其他授权用户
			set @iCount = (select count(*) from sysUserInfo where mobile = @managerMobile)
		if (@iCount > 0)
		begin
			set @Ret = 1
			return
		end
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	begin tran
		insert traderInfo(traderID, traderName, abbTraderName, inputCode, registeredCapital, legal, managerID, manager, managerMobile, e_mail, tel, tAddress,
				lockManID, modiManID, modiManName, modiTime) 
		values (@traderID, @traderName, @abbTraderName, @inputCode, @registeredCapital, @legal, @managerID, @manager, @managerMobile, @e_mail, @tel, @tAddress,
				@createManID, @createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		  
		--登记员工表：
		declare @managerInputCode varchar(5)
		set @managerInputCode = (select dbo.getChinaPYCode(@manager))
		insert traderManInfo(traderID, manID, manName, inputCode, post, mobile, tel, e_mail, hAddress)
		values(@traderID, @managerID, @manager, @managerInputCode, '总经理', @managerMobile, @tel, @e_mail, '')
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		--登记系统用户表：
		insert sysUserInfo(userType, userID, pID, mobile, cName, unitName, sysUserName)
		values(3, @managerID, '', @managerMobile, @manager, @traderName, '')
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
	commit tran

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加外贸公司', '系统根据用户' + @createManName + 
					'的要求添加了外贸公司[' + @traderName + '('+@traderID+')]。')
GO
--测试：
declare @Ret int, @createTime smalldatetime, @traderID varchar(12)
exec dbo.addTraderInfo ' 武汉黑马贸易公司', 'WHJMS', 100000, 'wt', '吴涛', '18702702392', 'lw_bk@163.com', '02781693105','中国武汉'	,
	'00201314', @Ret output, @createTime output, @traderID output
select @Ret, @createTime, @traderID

select * from traderInfo 
select * from traderManInfo
update traderInfo set lockManID=''

drop PROCEDURE queryTraderInfoLocMan
/*
	name:		queryTraderInfoLocMan
	function:	2.查询指定外贸公司是否有人正在编辑
	input: 
				@traderID varchar(12),	--外贸公司编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的外贸公司不存在
				@lockManID varchar(10) output--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE queryTraderInfoLocMan
	@traderID varchar(12),	--外贸公司编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from traderInfo where traderID = @traderID),'')
	set @Ret = 0
GO


drop PROCEDURE lockTraderInfo4Edit
/*
	name:		lockTraderInfo4Edit
	function:	3.锁定外贸公司编辑，避免编辑冲突
	input: 
				@traderID varchar(12),	--外贸公司编号
				@lockManID varchar(10) output,	--锁定人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的外贸公司不存在，2:要锁定的外贸公司正在被别人编辑
							9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE lockTraderInfo4Edit
	@traderID varchar(12),	--外贸公司编号
	@lockManID varchar(10) output,	--锁定人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的外贸公司是否存在
	declare @count as int
	set @count=(select count(*) from traderInfo where traderID = @traderID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderInfo 
	where traderID = @traderID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update traderInfo 
	set lockManID = @lockManID 
	where traderID = @traderID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定外贸公司编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了外贸公司['+ @traderID +']为独占式编辑。')
GO

drop PROCEDURE unlockTraderInfoEditor
/*
	name:		unlockTraderInfoEditor
	function:	4.释放外贸公司编辑锁
				注意：本过程不检查外贸公司是否存在！
	input: 
				@traderID varchar(12),	--外贸公司编号
				@lockManID varchar(10) output,	--锁定人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE unlockTraderInfoEditor
	@traderID varchar(12),	--外贸公司编号
	@lockManID varchar(10) output,	--锁定人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from traderInfo where traderID = @traderID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update traderInfo set lockManID = '' where traderID = @traderID
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
	values(@lockManID, @lockManName, getdate(), '释放外贸公司编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了外贸公司['+ @traderID +']的编辑锁。')
GO

drop PROCEDURE updateTraderInfo
/*
	name:		updateTraderInfo
	function:	5.更新外贸公司
	input: 
				@traderID varchar(12),		--主键：外贸公司编号
				@traderName nvarchar(30),		--外贸公司名称
				@abbTraderName nvarchar(6),		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
				@inputCode varchar(5),			--名称输入码
				@registeredCapital money,		--注册资本
				@legal nvarchar(30),			--法人
				@tel varchar(30),				--公司联系电话
				@tAddress nvarchar(100),		--公司地址
				
				@modiManID varchar(10) output,	--维护人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output			--操作成功标识
							0:成功，1：指定的外贸公司不存在，2：要更新的外贸公司正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: modi by lw 2012-4-27增加简称
*/
create PROCEDURE updateTraderInfo
	@traderID varchar(12),		--主键：外贸公司编号
	@traderName nvarchar(30),		--外贸公司名称
	@abbTraderName nvarchar(6),		--外贸公司简称	add by lw 2012-4-27根据客户要求增加
	@inputCode varchar(5),			--名称输入码
	@registeredCapital money,		--注册资本
	@legal nvarchar(30),			--法人
	@tel varchar(30),				--公司联系电话
	@tAddress nvarchar(100),		--公司地址
	
	@modiManID varchar(10) output,	--维护人，如果当前外贸公司正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的外贸公司是否存在
	declare @count as int
	set @count=(select count(*) from traderInfo where traderID = @traderID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from traderInfo
	where traderID = @traderID
	--检查编辑锁：
	if (@thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update traderInfo
	set traderName = @traderName, abbTraderName = @abbTraderName,
		inputCode = @inputCode,
		registeredCapital = @registeredCapital,
		legal = @legal,
		tel = @tel,
		tAddress = @tAddress,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	where traderID = @traderID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新外贸公司', '用户' + @modiManName 
												+ '更新了外贸公司['+ @traderID +']。')
GO

drop PROCEDURE updateTraderManger
/*
	name:		updateTraderManger
	function:	6.将指定员工设置为外贸公司负责人
				注意:该负责人必须先在员工库中定义!
	input: 
				@managerID varchar(18),			--负责人ID
				
				@modiManID varchar(10) output,	--维护人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output			--操作成功标识
							0:成功，1：指定的外贸公司不存在，2：要更新的外贸公司正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: modi by lw 2012-4-27简化接口
*/
create PROCEDURE updateTraderManger
	@managerID varchar(18),			--负责人ID
	
	@modiManID varchar(10) output,	--维护人，如果当前外贸公司正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @traderID varchar(12)	--外贸公司编号
	set @traderID = (select traderID from traderManInfo where manID=@managerID)
	--判断指定的外贸公司是否存在
	if (@traderID is null)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from traderInfo
	where traderID = @traderID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update traderInfo
	set managerID = @managerID,
		manager = m.manName,
		managerMobile = m.mobile,
		e_mail =  m.e_mail,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	from traderInfo s inner join traderManInfo m on s.traderID = m.traderID and m.manID = @managerID
	where s.traderID = @traderID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新外贸公司负责人', '用户' + @modiManName 
												+ '更新了外贸公司['+ @traderID +']的负责人。')
GO
--测试：
select * from traderInfo
select * from traderManInfo
declare @updateTime smalldatetime	--更新时间
declare @Ret		int				--操作成功标识
exec dbo.updateTraderManger '201204190002', '2012041906', '00201314', @updateTime output, @Ret output
select @updateTime, @Ret


drop PROCEDURE delTraderInfo
/*
	name:		delTraderInfo
	function:	7.删除指定的外贸公司
	input: 
				@traderID char(12),			--外贸公司编号
				@delManID varchar(10) output,	--删除人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的外贸公司不存在，2：要删除的外贸公司正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 

*/
create PROCEDURE delTraderInfo
	@traderID char(12),			--外贸公司编号
	@delManID varchar(10) output,	--删除人，如果当前外贸公司正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要指定的外贸公司是否存在
	declare @count as int
	set @count=(select count(*) from traderInfo where traderID = @traderID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderInfo 
	where traderID = @traderID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		--删除所有员工的登录信息：
		delete sysUserInfo where userID in (select manID from traderManInfo where traderID = @traderID)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--删除外贸公司及员工信息：员工级联删除：
		delete traderInfo where traderID = @traderID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除外贸公司', '用户' + @delManName
												+ '删除了外贸公司['+ @traderID +']。')

GO
--测试：
select * from traderInfo
select * from traderManInfo
declare @Ret		int				--操作成功标识
exec dbo.delTraderInfo '201204190003', '00201314', @Ret output
select @Ret




drop PROCEDURE addTraderManInfo
/*
	name:		addTraderManInfo
	function:	10.添加外贸公司员工基本信息
				注意：该存储过程自动锁定记录
	input: 
				@traderID varchar(12),		--外键：外贸公司编号
				@pID varchar(18),			--身份证号：要做唯一性检查
				@manName nvarchar(30),		--员工姓名
				@inputCode varchar(5),		--名称输入码
				@post nvarchar(30),			--职务
				@mobile varchar(30),		--联系手机：要做唯一性检查
				@tel varchar(30),			--其他电话
				@e_mail varchar(30),		--E_mail地址
				@hAddress nvarchar(100),	--家庭地址

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1:该员工的身份证号已经被别人登记过， 2:该员工的手机已经被别人登记过，9:未知错误
				@createTime smalldatetime output--添加时间
				@manID varchar(10) output	--主键：员工ID
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 

*/
create PROCEDURE addTraderManInfo
	@traderID varchar(12),	--外键：外贸公司编号
	@pID varchar(18),			--身份证号：要做唯一性检查
	@manName nvarchar(30),		--员工姓名
	@inputCode varchar(5),		--名称输入码
	@post nvarchar(30),			--职务
	@mobile varchar(30),		--联系手机
	@tel varchar(30),			--其他电话
	@e_mail varchar(30),		--E_mail地址
	@hAddress nvarchar(100),	--家庭地址

	@createManID varchar(10),	--创建人工号

	@Ret		int output,		--操作成功标识
	@createTime smalldatetime output,--添加时间
	@manID varchar(10) output	--主键：员工ID
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生员工编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 13, 1, @curNumber output
	set @manID = @curNumber

	--检查身份证的唯一性：身份证的正确性由前台验证！
	declare @iCount int
	if (@pID<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where pID = @pID)
		if (@iCount = 0)	--继续检查外贸公司员工
			set @iCount = (select count(*) from traderManInfo where pID = @pID)
		if (@iCount = 0)	--继续检查学校员工
			set @iCount = (select count(*) from userInfo where pID = @pID)
		if (@iCount = 0)	--继续检查其他授权用户
			set @iCount = (select count(*) from sysUserInfo where pID = @pID)
		if (@iCount > 0)
		begin
			set @Ret = 1
			return
		end
	end
	
	--检查手机的唯一性：
	if (@mobile<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
		if (@iCount = 0)	--继续检查外贸公司员工
			set @iCount = (select count(*) from supplierManInfo where mobile = @mobile)
		if (@iCount = 0)	--继续检查学校员工
			set @iCount = (select count(*) from userInfo where mobileNum = @mobile)
		if (@iCount = 0)	--继续检查其他授权用户
			set @iCount = (select count(*) from sysUserInfo where mobile = @mobile)
		if (@iCount > 0)
		begin
			set @Ret = 2
			return
		end
	end
		
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	--登记员工表：
	insert traderManInfo(traderID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress)
	values(@traderID, @manID, @pID, @manName, @inputCode, @post, @mobile, @tel, @e_mail, @hAddress)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加外贸公司员工', '系统根据用户' + @createManName + 
					'的要求添加了外贸公司员工[' + @manName + '('+@manID+')]。')
GO

--测试：
declare @manID varchar(10)	--主键：员工ID
declare @Ret int, @createTime smalldatetime
exec dbo.addTraderManInfo '201204190001', '420111197009014113', '卢苇', 'LW', '总裁', '18602702392', '027-87889011', 'lw_bk@163.com','加拿大温哥华'	,
	'00201314', @Ret output, @createTime output, @manID output
select @Ret, @createTime, @manID

select * from traderInfo 
select * from traderManInfo

drop PROCEDURE queryTraderManInfoLocMan
/*
	name:		queryTraderManInfoLocMan
	function:	12.查询指定外贸公司员工是否有人正在编辑
	input: 
				@manID varchar(10),			--员工ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的员工不存在
				@lockManID varchar(10) output--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE queryTraderManInfoLocMan
	@manID varchar(10),			--员工ID
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from traderManInfo where manID = @manID),'')
	set @Ret = 0
GO


drop PROCEDURE lockTraderManInfo4Edit
/*
	name:		lockTraderManInfo4Edit
	function:	13.锁定外贸公司员工编辑，避免编辑冲突
	input: 
				@manID varchar(10),			--员工ID
				@lockManID varchar(10) output,	--锁定人，如果当前外贸公司员工正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的员工不存在，2:要锁定的员工正在被别人编辑
							9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE lockTraderManInfo4Edit
	@manID varchar(10),			--员工ID
	@lockManID varchar(10) output,	--锁定人，如果当前外贸公司员工正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的外贸公司员工是否存在
	declare @count as int
	set @count=(select count(*) from traderManInfo where manID = @manID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update traderManInfo 
	set lockManID = @lockManID 
	where manID = @manID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定员工编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了外贸公司员工['+ @manID +']为独占式编辑。')
GO

drop PROCEDURE unlockTraderManInfoEditor
/*
	name:		unlockTraderManInfoEditor
	function:	14.释放外贸公司员工编辑锁
				注意：本过程不检查外贸公司员工是否存在！
	input: 
				@manID varchar(10),				--员工ID
				@lockManID varchar(10) output,	--锁定人，如果当前员工正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE unlockTraderManInfoEditor
	@manID varchar(10),				--员工ID
	@lockManID varchar(10) output,	--锁定人，如果当前员工正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update traderManInfo set lockManID = '' where manID = @manID
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
	values(@lockManID, @lockManName, getdate(), '释放员工编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了外贸公司员工['+ @manID +']的编辑锁。')
GO

drop PROCEDURE updateTraderManInfo
/*
	name:		updateTraderManInfo
	function:	15.更新外贸公司员工基本信息
	input: 
				@manID varchar(10),			--员工ID
				@pID varchar(18),			--身份证号：要做唯一性检查
				@manName nvarchar(30),		--员工姓名
				@inputCode varchar(5),		--名称输入码
				@post nvarchar(30),			--职务
				@mobile varchar(30),		--联系手机：要做唯一性检查
				@tel varchar(30),			--其他电话
				@e_mail varchar(30),		--E_mail地址
				@hAddress nvarchar(100),	--家庭地址
				
				@modiManID varchar(10) output,	--维护人，如果当前员工正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output			--操作成功标识
							0:成功，1：指定的员工不存在，2：要更新的员工正被别人锁定，
							3:该员工的身份证号已经被别人登记过， 4:该员工的手机已经被别人登记过，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE updateTraderManInfo
	@manID varchar(10),			--员工ID
	@pID varchar(18),			--身份证号：要做唯一性检查
	@manName nvarchar(30),		--员工姓名
	@inputCode varchar(5),		--名称输入码
	@post nvarchar(30),			--职务
	@mobile varchar(30),		--联系手机：要做唯一性检查
	@tel varchar(30),			--其他电话
	@e_mail varchar(30),		--E_mail地址
	@hAddress nvarchar(100),	--家庭地址
	
	@modiManID varchar(10) output,	--维护人，如果当前员工正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的外贸公司员工是否存在
	declare @count as int
	set @count=(select count(*) from traderManInfo where manID = @manID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查身份证的唯一性：身份证的正确性由前台验证！
	declare @iCount int
	if (@pID<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where pID = @pID and manID <> @manID)
		if (@iCount = 0)	--继续检查供货单位员工
			set @iCount = (select count(*) from supplierManInfo where pID = @pID)
		if (@iCount = 0)	--继续检查学校员工
			set @iCount = (select count(*) from userInfo where pID = @pID)
		if (@iCount = 0)	--继续检查其他授权用户
			set @iCount = (select count(*) from sysUserInfo where pID = @pID and userID <> @manID)
		if (@iCount > 0)
		begin
			set @Ret = 3
			return
		end
	end

	--检查手机的唯一性：
	if (@mobile<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where mobile = @mobile and manID <> @manID)
		if (@iCount = 0)	--继续检查供货单位员工
			set @iCount = (select count(*) from supplierManInfo where mobile = @mobile)
		if (@iCount = 0)	--继续检查学校员工
			set @iCount = (select count(*) from userInfo where mobileNum = @mobile)
		if (@iCount = 0)	--继续检查其他授权用户
			set @iCount = (select count(*) from sysUserInfo where mobile = @mobile and userID <> @manID)
		if (@iCount > 0)
		begin
			set @Ret = 4
			return
		end
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		update traderManInfo
		set pID = @pID,
			manName = @manName,
			inputCode = @inputCode,
			post = @post,
			mobile = @mobile,
			tel = @tel,
			e_mail = @e_mail,
			hAddress = @hAddress,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where manID = @manID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		--检查该员工是否已经登记登录信息，如果登记则做相应修改：
		set @count = (select count(*) from sysUserInfo where userID = @manID)
		if (@count > 0)
		begin
			update sysUserInfo
			set pID = @pID,
				mobile = @mobile,
				cName = @manName
			where userID = @manID
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end  
		end
	commit tran
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新员工基本信息', '用户' + @modiManName 
												+ '更新了外贸公司员工['+ @manID +']的基本信息。')
GO

drop PROCEDURE delTraderManInfo
/*
	name:		delTraderManInfo
	function:	17.删除指定的外贸公司员工
	input: 
				@manID varchar(10),				--员工ID
				@delManID varchar(10) output,	--删除人，如果当前员工正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的员工不存在，2：要删除的员工正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-19
	UpdateDate: 

*/
create PROCEDURE delTraderManInfo
	@manID varchar(10),				--员工ID
	@delManID varchar(10) output,	--删除人，如果当前员工正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的外贸公司员工是否存在
	declare @count as int
	set @count=(select count(*) from traderManInfo where manID = @manID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete traderManInfo where manID = @manID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		
		--删除登录信息：级联删除用户角色
		delete sysUserInfo where userID = @manID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
	commit tran
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除员工', '用户' + @delManName
												+ '删除了外贸公司员工['+ @manID +']。')
GO
--测试：
select * from traderInfo
select * from traderManInfo
select * from sysUserInfo
declare @Ret		int				--操作成功标识
exec dbo.delTraderManInfo 'W0000003', '00201314', @Ret output
select @Ret


select * from traderInfo


select * from sysUserInfo where userID = 'W0000009'