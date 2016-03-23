use fTradeDB
/*
	武大外贸供货单位管理信息系统--供货单位管理
	author:		卢苇
	CreateDate:	2012-3-28
	UpdateDate: 
*/
--1.供货单位表：
select supplierID,supplierName,managerID,manager,managerMobile,tel,sAddress from supplierInfo
delete supplierInfo
drop TABLE supplierInfo
CREATE TABLE supplierInfo
(
	--供货单位：
	supplierID varchar(12) not null,	--主键：供货单位编号
	supplierName nvarchar(30) null,		--供货单位名称
	abbSupplierName nvarchar(6) null,	--供货单位简称
	inputCode varchar(5) null,			--名称输入码
	registeredCapital money default(0),	--注册资本
	legal nvarchar(30) null,			--法人
	managerID varchar(18) null,			--负责人ID
	manager nvarchar(30) null,			--负责人姓名：冗余设计
	managerMobile varchar(30) null,		--负责人联系手机：冗余设计
	e_mail varchar(30) null,			--E_mail地址：冗余设计
	tel varchar(30) null,				--公司联系电话
	sAddress nvarchar(100) null,		--公司地址
	
	--最新维护情况:
	buildDate smalldatetime default(getdate()),	--建档日期
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

 CONSTRAINT [PK_supplierInfo] PRIMARY KEY CLUSTERED 
(
	[supplierID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_supplierInfo] ON [dbo].[supplierInfo] 
(
	[supplierName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_supplierInfo_1] ON [dbo].[supplierInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--测试数据：
insert supplierInfo(supplierID, supplierName, inputCode, managerID, manager, managerMobile, tel, sAddress)
values('0001','Sony 全球','SONY','0001','卢苇','18602702392','0012345','美国加州')

--2.供货单位员工表(允许登录系统的人员)
drop TABLE supplierManInfo
CREATE TABLE supplierManInfo
(
	supplierID varchar(12) not null,	--外键：供货单位编号
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

 CONSTRAINT [PK_supplierManInfo] PRIMARY KEY CLUSTERED 
(
	[manID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[supplierManInfo] WITH CHECK ADD CONSTRAINT [FK_supplierManInfo_supplierInfo] FOREIGN KEY([supplierID])
REFERENCES [dbo].[supplierInfo] ([supplierID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[supplierManInfo] CHECK CONSTRAINT [FK_supplierManInfo_supplierInfo] 
GO

--索引：
CREATE NONCLUSTERED INDEX [IX_supplierManInfo] ON [dbo].[supplierManInfo] 
(
	[manName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_supplierManInfo_1] ON [dbo].[supplierManInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


insert supplierInfo(supplierID, supplierName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, sAddress,
	buildDate, modiManID, modiManName, modiTime)
select supplierID, supplierName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, sAddress,
	buildDate, modiManID, modiManName, modiTime 
from fTradeDB0.dbo.supplierInfo
select * from supplierInfo
	
insert supplierManInfo(supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime)
select supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime
from fTradeDB0.dbo.supplierManInfo

select * from supplierManInfo
delete supplierInfo

insert supplierManInfo(supplierID, manID, manName, inputCode, post, mobile, tel, hAddress)
values('0001','0001','卢苇','LW','总经理','18602702392','','')


drop PROCEDURE addSupplierInfo
/*
	name:		addSupplierInfo
	function:	1.添加供货单位
				注意：该存储过程自动锁定记录
	input: 
				@supplierName nvarchar(30),		--供货单位名称
				@inputCode varchar(5),			--名称输入码
				@registeredCapital money,		--注册资本
				@legal nvarchar(30),			--法人
				@manager nvarchar(30),			--负责人
				@managerMobile varchar(30),		--负责人联系手机：检查唯一性
				@e_mail varchar(30),			--E_mail地址
				@tel varchar(30),				--公司联系电话
				@sAddress nvarchar(100),		--公司地址

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1:该负责人的手机已经被别人登记过,9:未知错误
				@createTime smalldatetime output--添加时间
				@supplierID varchar(12) output	--主键：供货单位编号
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-4-19增加手机唯一性检查

*/
create PROCEDURE addSupplierInfo
	@supplierName nvarchar(30),		--供货单位名称
	@inputCode varchar(5),			--名称输入码
	@registeredCapital money,		--注册资本
	@legal nvarchar(30),			--法人
	@manager nvarchar(30),			--负责人
	@managerMobile varchar(30),		--负责人联系手机：检查唯一性
	@e_mail varchar(30),			--E_mail地址
	@tel varchar(30),				--公司联系电话
	@sAddress nvarchar(100),		--公司地址

	@createManID varchar(10),		--创建人工号

	@Ret		int output,			--操作成功标识
	@createTime smalldatetime output,--添加时间
	@supplierID varchar(12) output	--主键：供货单位编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生供货单位编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10, 1, @curNumber output
	set @supplierID = @curNumber
	--使用号码发生器产生员工编号：
	declare @managerID varchar(18)			--负责人ID
	exec dbo.getClassNumber 11, 1, @curNumber output
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
		insert supplierInfo(supplierID, supplierName, inputCode, registeredCapital, legal, managerID, manager, managerMobile, e_mail, tel, sAddress,
				lockManID, modiManID, modiManName, modiTime) 
		values (@supplierID, @supplierName, @inputCode, @registeredCapital, @legal, @managerID, @manager, @managerMobile, @e_mail, @tel, @sAddress,
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
		insert supplierManInfo(supplierID, manID, manName, inputCode, post, mobile, tel, e_mail, hAddress)
		values(@supplierID, @managerID, @manager, @managerInputCode, '总经理', @managerMobile, @tel, @e_mail, '')
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		--登记系统用户表：
		insert sysUserInfo(userType, userID, pID, mobile, cName, unitName, sysUserName)
		values(2, @managerID, '', @managerMobile, @manager, @supplierName, '')
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
	values(@createManID, @createManName, @createTime, '添加供货单位', '系统根据用户' + @createManName + 
					'的要求添加了供货单位[' + @supplierName + '('+@supplierID+')]。')
GO
--测试：
declare @Ret int, @createTime smalldatetime, @supplierID varchar(12)
exec dbo.addSupplierInfo '国际商用机器公司', 'GJSYS', 'luwei', '18602702392', 'lw_bk@163.com', '02781693105','美国加州'	,
	'00201314', @Ret output, @createTime output, @supplierID output
select @Ret, @createTime, @supplierID

select * from supplierInfo 
select * from supplierManInfo


drop PROCEDURE fastAddSupplierInfo
/*
	name:		fastAddSupplierInfo
	function:	1.1.快速添加供货单位（只添加名称）
				注意：该存储过程不锁定记录
	input: 
				@supplierName nvarchar(30),		--供货单位名称

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1:该名称的供货单位已经登记过了,9:未知错误
				@createTime smalldatetime output--添加时间
				@supplierID varchar(12) output	--主键：供货单位编号
	author:		卢苇
	CreateDate:	2012-4-27
	UpdateDate: modi by lw 2012-4-19增加手机唯一性检查

*/
create PROCEDURE fastAddSupplierInfo
	@supplierName nvarchar(30),		--供货单位名称

	@createManID varchar(10),		--创建人工号

	@Ret		int output,			--操作成功标识
	@createTime smalldatetime output,--添加时间
	@supplierID varchar(12) output	--主键：供货单位编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生供货单位编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10, 1, @curNumber output
	set @supplierID = @curNumber

	set @supplierName = RTRIM(LTRIM(@supplierName))
	--检查名称的唯一性：
	declare @iCount int
	set @iCount = (select count(*) from supplierInfo where supplierName = @supplierName)
	if (@iCount>0)
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert supplierInfo(supplierID, supplierName, inputCode, 
						lockManID, modiManID, modiManName, modiTime) 
	values (@supplierID, @supplierName, dbo.getChinaPYCode(@supplierName),
			'', @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end  
		  

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '速加供货单位', '系统根据用户' + @createManName + 
					'的要求快速添加了供货单位[' + @supplierName + '('+@supplierID+')]。')
GO


drop PROCEDURE querySupplierInfoLocMan
/*
	name:		querySupplierInfoLocMan
	function:	2.查询指定供货单位是否有人正在编辑
	input: 
				@supplierID varchar(12),	--供货单位编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的供货单位不存在
				@lockManID varchar(10) output--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE querySupplierInfoLocMan
	@supplierID varchar(12),	--供货单位编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from supplierInfo where supplierID = @supplierID),'')
	set @Ret = 0
GO


drop PROCEDURE lockSupplierInfo4Edit
/*
	name:		lockSupplierInfo4Edit
	function:	3.锁定供货单位编辑，避免编辑冲突
	input: 
				@supplierID varchar(12),	--供货单位编号
				@lockManID varchar(10) output,	--锁定人，如果当前供货单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的供货单位不存在，2:要锁定的供货单位正在被别人编辑
							9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE lockSupplierInfo4Edit
	@supplierID varchar(12),	--供货单位编号
	@lockManID varchar(10) output,	--锁定人，如果当前供货单位正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的供货单位是否存在
	declare @count as int
	set @count=(select count(*) from supplierInfo where supplierID = @supplierID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierInfo 
	where supplierID = @supplierID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update supplierInfo 
	set lockManID = @lockManID 
	where supplierID = @supplierID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定供货单位编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了供货单位['+ @supplierID +']为独占式编辑。')
GO

drop PROCEDURE unlockSupplierInfoEditor
/*
	name:		unlockSupplierInfoEditor
	function:	4.释放供货单位编辑锁
				注意：本过程不检查供货单位是否存在！
	input: 
				@supplierID varchar(12),	--供货单位编号
				@lockManID varchar(10) output,	--锁定人，如果当前供货单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE unlockSupplierInfoEditor
	@supplierID varchar(12),	--供货单位编号
	@lockManID varchar(10) output,	--锁定人，如果当前供货单位正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from supplierInfo where supplierID = @supplierID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update supplierInfo set lockManID = '' where supplierID = @supplierID
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
	values(@lockManID, @lockManName, getdate(), '释放供货单位编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了供货单位['+ @supplierID +']的编辑锁。')
GO

select * from supplierInfo
drop PROCEDURE updateSupplierInfo
/*
	name:		updateSupplierInfo
	function:	5.更新供货单位
	input: 
				@supplierID varchar(12),		--主键：供货单位编号
				@supplierName nvarchar(30),		--供货单位名称
				@inputCode varchar(5),			--名称输入码
				@registeredCapital money,		--注册资本
				@legal nvarchar(30),			--法人
				@tel varchar(30),				--公司联系电话
				@sAddress nvarchar(100),		--公司地址
				
				@modiManID varchar(10) output,	--维护人，如果当前供货单位正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output			--操作成功标识
							0:成功，1：指定的供货单位不存在，2：要更新的供货单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE updateSupplierInfo
	@supplierID varchar(12),		--主键：供货单位编号
	@supplierName nvarchar(30),		--供货单位名称
	@inputCode varchar(5),			--名称输入码
	@registeredCapital money,		--注册资本
	@legal nvarchar(30),			--法人
	@tel varchar(30),				--公司联系电话
	@sAddress nvarchar(100),		--公司地址
	
	@modiManID varchar(10) output,	--维护人，如果当前供货单位正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的供货单位是否存在
	declare @count as int
	set @count=(select count(*) from supplierInfo where supplierID = @supplierID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from supplierInfo
	where supplierID = @supplierID
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
	update supplierInfo
	set supplierName = @supplierName, 
		inputCode = @inputCode,
		registeredCapital = @registeredCapital,
		legal = @legal,
		tel = @tel,
		sAddress = @sAddress,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	where supplierID = @supplierID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新供货单位', '用户' + @modiManName 
												+ '更新了供货单位['+ @supplierID +']。')
GO

drop PROCEDURE updateSupplierManger
/*
	name:		updateSupplierManger
	function:	6.将指定员工设置为供货单位负责人
				注意:该负责人必须先在员工库中定义!
	input: 
				@managerID varchar(18),			--负责人ID
				
				@modiManID varchar(10) output,	--维护人，如果当前供货单位正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output			--操作成功标识
							0:成功，1：指定的供货单位不存在，2：要更新的供货单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-4-27简化接口
*/
create PROCEDURE updateSupplierManger
	@managerID varchar(18),			--负责人ID
	
	@modiManID varchar(10) output,	--维护人，如果当前供货单位正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @supplierID varchar(12)		--供货单位编号
	set @supplierID = (select supplierID from supplierManInfo where manID=@managerID)
	--判断指定的供货单位是否存在
	if (@supplierID is null)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from supplierInfo
	where supplierID = @supplierID
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
	update supplierInfo
	set managerID = @managerID,
		manager = m.manName,
		managerMobile = m.mobile,
		e_mail =  m.e_mail,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	from supplierInfo s inner join supplierManInfo m on s.supplierID = m.supplierID and m.manID = @managerID
	where s.supplierID = @supplierID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新供货单位负责人', '用户' + @modiManName 
												+ '更新了供货单位['+ @supplierID +']的负责人。')
GO
--测试：
select * from supplierInfo
select * from supplierManInfo
declare @updateTime smalldatetime	--更新时间
declare @Ret		int				--操作成功标识
exec dbo.updateSupplierManger '2012041906', '00201314', @updateTime output, @Ret output
select @updateTime, @Ret


drop PROCEDURE delSupplierInfo
/*
	name:		delSupplierInfo
	function:	7.删除指定的供货单位
	input: 
				@supplierID char(12),			--供货单位编号
				@delManID varchar(10) output,	--删除人，如果当前供货单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的供货单位不存在，2：要删除的供货单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-4-19 增加删除所有员工的登录信息

*/
create PROCEDURE delSupplierInfo
	@supplierID char(12),			--供货单位编号
	@delManID varchar(10) output,	--删除人，如果当前供货单位正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要指定的供货单位是否存在
	declare @count as int
	set @count=(select count(*) from supplierInfo where supplierID = @supplierID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierInfo 
	where supplierID = @supplierID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		--删除所有员工的登录信息：
		delete sysUserInfo where userID in (select manID from supplierManInfo where supplierID = @supplierID)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--删除供货单位及员工信息：员工级联删除：
		delete supplierInfo where supplierID = @supplierID
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
	values(@delManID, @delManName, getdate(), '删除供货单位', '用户' + @delManName
												+ '删除了供货单位['+ @supplierID +']。')

GO
--测试：
select * from supplierInfo
select * from supplierManInfo
declare @Ret		int				--操作成功标识
exec dbo.delSupplierInfo '201204190001', '00201314', @Ret output
select @Ret




drop PROCEDURE addSupplierManInfo
/*
	name:		addSupplierManInfo
	function:	10.添加供货单位员工基本信息
				注意：该存储过程自动锁定记录
	input: 
				@supplierID varchar(12),	--外键：供货单位编号
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
	CreateDate:	2012-4-18
	UpdateDate: 

*/
create PROCEDURE addSupplierManInfo
	@supplierID varchar(12),	--外键：供货单位编号
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
	exec dbo.getClassNumber 11, 1, @curNumber output
	set @manID = @curNumber

	--检查身份证的唯一性：身份证的正确性由前台验证！
	declare @iCount int
	if (@pID <> '')
	begin
		set @iCount = (select count(*) from supplierManInfo where pID = @pID)
		if (@iCount = 0)	--继续检查供货单位员工
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
	if (@mobile <> '')
	begin
		set @iCount = (select count(*) from supplierManInfo where mobile = @mobile)
		if (@iCount = 0)	--继续检查外贸公司员工
			set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
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
	insert supplierManInfo(supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
			lockManID, modiManID, modiManName, modiTime) 
		values(@supplierID, @manID, @pID, @manName, @inputCode, @post, @mobile, @tel, @e_mail, @hAddress,
				@createManID, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加供货单位员工', '系统根据用户' + @createManName + 
					'的要求添加了供货单位员工[' + @manName + '('+@manID+')]。')
GO

select * from supplierManInfo
--测试：
declare @manID varchar(10)	--主键：员工ID
declare @Ret int, @createTime smalldatetime
exec dbo.addSupplierManInfo '201204220012', '420111197009014113', '卢苇', 'LW', '总裁', '18602702381', '027-87889011', 'lw_bk@163.com','加拿大温哥华'	,
	'00201314', @Ret output, @createTime output, @manID output
select @Ret, @createTime, @manID

select * from supplierInfo 
select * from supplierManInfo

drop PROCEDURE fastAddSupplierManInfo
/*

	name:		fastAddSupplierManInfo
	function:	10.1.快速添加供货单位员工
				注意：该存储过程不锁定记录
	input: 
				@supplierID varchar(12),	--外键：供货单位编号
				@manName nvarchar(30),		--员工姓名

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1:该员工的姓名已经登记过，9:未知错误
				@createTime smalldatetime output--添加时间
				@manID varchar(10) output	--主键：员工ID
	author:		卢苇
	CreateDate:	2012-4-27
	UpdateDate: 

*/
create PROCEDURE fastAddSupplierManInfo
	@supplierID varchar(12),	--外键：供货单位编号
	@manName nvarchar(30),		--员工姓名

	@createManID varchar(10),	--创建人工号

	@Ret		int output,		--操作成功标识
	@createTime smalldatetime output,--添加时间
	@manID varchar(10) output	--主键：员工ID
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生员工编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 11, 1, @curNumber output
	set @manID = @curNumber

	--检查姓名的唯一性
	set @manName = LTRIM(RTRIM(@manName))
	declare @iCount int
	set @iCount =(select count(*) from supplierManInfo where manName = @manName and supplierID = @supplierID)
	if (@iCount > 0)
	begin
		set @Ret = 1
		return
	end
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	--登记员工表：
	insert supplierManInfo(supplierID, manID, manName, inputCode)
	values(@supplierID, @manID, @manName, dbo.getChinaPYCode(@manName))
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '速加供货单位员工', '系统根据用户' + @createManName + 
					'的要求快速添加了供货单位员工[' + @manName + '('+@manID+')]。')
GO
--测试：
declare @Ret		int		--操作成功标识
declare @createTime smalldatetime	--添加时间
declare @manID varchar(10)	--主键：员工ID
exec dbo.fastAddSupplierManInfo '201205150009','测试快速保存员工','00011275',@Ret output, @createTime output, @manID output
select @Ret, @createTime, @manID



drop PROCEDURE querySupplierManInfoLocMan
/*
	name:		querySupplierManInfoLocMan
	function:	12.查询指定供货单位员工是否有人正在编辑
	input: 
				@manID varchar(10),			--员工ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的员工不存在
				@lockManID varchar(10) output--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE querySupplierManInfoLocMan
	@manID varchar(10),			--员工ID
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from supplierManInfo where manID = @manID),'')
	set @Ret = 0
GO


drop PROCEDURE lockSupplierManInfo4Edit
/*
	name:		lockSupplierManInfo4Edit
	function:	13.锁定供货单位员工编辑，避免编辑冲突
	input: 
				@manID varchar(10),			--员工ID
				@lockManID varchar(10) output,	--锁定人，如果当前供货单位员工正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的员工不存在，2:要锁定的员工正在被别人编辑
							9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE lockSupplierManInfo4Edit
	@manID varchar(10),			--员工ID
	@lockManID varchar(10) output,	--锁定人，如果当前供货单位员工正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的供货单位员工是否存在
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update supplierManInfo 
	set lockManID = @lockManID 
	where manID = @manID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定员工编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了供货单位员工['+ @manID +']为独占式编辑。')
GO

drop PROCEDURE unlockSupplierManInfoEditor
/*
	name:		unlockSupplierManInfoEditor
	function:	14.释放供货单位员工编辑锁
				注意：本过程不检查供货单位员工是否存在！
	input: 
				@manID varchar(10),				--员工ID
				@lockManID varchar(10) output,	--锁定人，如果当前员工正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE unlockSupplierManInfoEditor
	@manID varchar(10),				--员工ID
	@lockManID varchar(10) output,	--锁定人，如果当前员工正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update supplierManInfo set lockManID = '' where manID = @manID
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
												+ '的要求释放了供货单位员工['+ @manID +']的编辑锁。')
GO

drop PROCEDURE updateSupplierManInfo
/*
	name:		updateSupplierManInfo
	function:	15.更新供货单位员工基本信息
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
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE updateSupplierManInfo
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
	--判断要锁定的供货单位员工是否存在
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
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
		set @iCount = (select count(*) from supplierManInfo where pID = @pID and manID <> @manID)
		if (@iCount = 0)	--继续检查外贸公司员工
			set @iCount = (select count(*) from traderManInfo where pID = @pID)
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
		set @iCount = (select count(*) from supplierManInfo where mobile = @mobile and manID <> @manID)
		if (@iCount = 0)	--继续检查外贸公司员工
			set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
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
		update supplierManInfo
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
												+ '更新了供货单位员工['+ @manID +']的基本信息。')
GO

drop PROCEDURE updateSupplierManMobile
/*
	name:		updateSupplierManMobile
	function:	15.1.更新供货单位员工手机号码
	input: 
				@manID varchar(10),			--员工ID
				@mobile varchar(30),		--联系手机：要做唯一性检查
				
				@modiManID varchar(10) output,	--维护人，如果当前员工正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output			--操作成功标识
							0:成功，1：指定的员工不存在，2：要更新的员工正被别人锁定，
							4:该员工的手机已经被别人登记过，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-27
	UpdateDate: 
*/
create PROCEDURE updateSupplierManMobile
	@manID varchar(10),			--员工ID
	@mobile varchar(30),		--联系手机：要做唯一性检查
	
	@modiManID varchar(10) output,	--维护人，如果当前员工正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的供货单位员工是否存在
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查手机的唯一性：
	declare @iCount int
	set @iCount = (select count(*) from supplierManInfo where mobile = @mobile and manID <> @manID)
	if (@iCount = 0)	--继续检查外贸公司员工
		set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
	if (@iCount = 0)	--继续检查学校员工
		set @iCount = (select count(*) from userInfo where mobileNum = @mobile)
	if (@iCount = 0)	--继续检查其他授权用户
		set @iCount = (select count(*) from sysUserInfo where mobile = @mobile and userID <> @manID)
	if (@iCount > 0)
	begin
		set @Ret = 4
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update supplierManInfo
	set mobile = @mobile,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	where manID = @manID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新员工手机', '用户' + @modiManName 
												+ '更新了供货单位员工['+ @manID +']的手机号码。')
GO


drop PROCEDURE delSupplierManInfo
/*
	name:		delSupplierManInfo
	function:	17.删除指定的供货单位员工
	input: 
				@manID varchar(10),				--员工ID
				@delManID varchar(10) output,	--删除人，如果当前员工正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的员工不存在，2：要删除的员工正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: 

*/
create PROCEDURE delSupplierManInfo
	@manID varchar(10),				--员工ID
	@delManID varchar(10) output,	--删除人，如果当前员工正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的供货单位员工是否存在
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete supplierManInfo where manID = @manID
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
												+ '删除了供货单位员工['+ @manID +']。')
GO
--测试：
select * from supplierInfo
select * from supplierManInfo
select * from sysUserInfo
declare @Ret		int				--操作成功标识
exec dbo.delSupplierManInfo 'G0000003', '00201314', @Ret output
select @Ret


delete supplierManInfo 
where manID='G0000035'; 
select supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress 
from supplierManInfo 
where manID='G0000029'; 
select userType, userID, pID, mobile, e_mail, cName, unitName, sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer, isOff, setOffDate 
from sysUserInfo 
where userID='G0000034';
select * from sysUserInfo


select UNICODE('帮')