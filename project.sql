use PM100
/*
	项目管理系统--项目登记
	author:		卢苇
	CreateDate:	2015-10-20
	UpdateDate: 
*/
--1.项目登记表：
drop TABLE project
CREATE TABLE project
(
	projectID varchar(13) not null,		--主键：项目编号，采用1100号号码发生器发生,格式：P+8位日期码+4位流水码
	projectName	nvarchar(30) not null,	--项目名称
	inputCode varchar(5) null,			--输入码
	customerID varchar(13) not null,	--委托单位ID，由客户管理系统维护
	customerName nvarchar(30) not null,	--委托单位名称：冗余设计
	contractAmount numeric(12,2) null,	--合同金额
	amountType smallint default(1),		--合同金额类型:0->估算金额，1->正式合同金额
	netAmount numeric(12,2) null,		--净合同金额
	signDate smalldatetime null,		--合同签订日期
	signerID varchar(10) null,			--签订人ID，由人事管理系统维护
	signer nvarchar(30) null,			--签订人：冗余设计
	startDate smalldatetime null,		--开工日期：有进度管理系统传递过来
	expectedDuration int null,			--预算工期，单位：天
	completeDate smalldatetime null,	--实际完工日期
	managerID varchar(10) null,			--负责人ID，由人事管理系统维护
	manager nvarchar(30) null,			--负责人：冗余设计
	progress numeric(6,2) default(0),	--进度：有进度管理系统汇总过来
	pStatus	nvarchar(10) null,			--状态说明:由第2000号代码字典定义,但可以手工输入，所以保存状态名称
	collectedAmount numeric(12,2) default(0),	--已收款：由财务收款系统汇总过来
	--uncollectedAmount numeric(12,2),	--尾款：计算字段
	remarks	nvarchar(60) null,			--备注
	--collectedDetail xml,				--回款情况
	projectDesc	nvarchar(1000) null,	--项目简述

	--最新维护情况:
	createDate smalldatetime default(getdate()),	--创建日期
	createrID varchar(10) null,			--创建人ID
	creater nvarchar(30) null,			--创建人姓名
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

 CONSTRAINT [PK_project] PRIMARY KEY CLUSTERED 
(
	[projectID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_project] ON [dbo].[project] 
(
	[projectName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_project_1] ON [dbo].[project] 
(
	[customerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_project_2] ON [dbo].[project] 
(
	[signerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_project_3] ON [dbo].[project] 
(
	[managerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from project
select case amountType when 0 then '估算' when 1 then '' end from project
drop PROCEDURE addProject
/*
	name:		addProject
	function:	1.添加项目
	input: 
				@projectName nvarchar(30),		--项目名称
				@customerID varchar(13),		--委托单位ID，由客户管理系统维护
				@contractAmount numeric(12,2),	--合同金额
				@amountType smallint,			--合同金额类型:0->估算金额，1->正式合同金额
				@netAmount numeric(12,2),		--净合同金额：为空或'0'表示等于同合同金额
				@strSignDate varchar(19),		--合同签订日期:采用YYYY-MM-DD hh:mm:ss格式输入
				@signerID varchar(10),			--签订人ID，由人事管理系统维护
				@managerID varchar(10),			--负责人ID，由人事管理系统维护
				@pStatus nvarchar(10),			--状态说明:由第2000号代码字典定义,但可以手工输入，所以保存状态名称
				@remarks nvarchar(60),			--备注
				@projectDesc nvarchar(1000),	--项目简述

				--最新维护情况:
				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output,			--成功标识
												0:成功，1:该项目已经被注册过了，2:没有输入委托单位，3:该委托单位不存在，9:未知错误
				@projectID varchar(13) output	--项目编号，采用1100号号码发生器发生
	author:		卢苇
	CreateDate:	2015-10-21
	UpdateDate:
*/
create PROCEDURE addProject
	@projectName nvarchar(30),		--项目名称
	@customerID varchar(13),		--委托单位ID，由客户管理系统维护
	@contractAmount numeric(12,2),	--合同金额
	@amountType smallint,			--合同金额类型:0->估算金额，1->正式合同金额
	@netAmount numeric(12,2),		--净合同金额：为空或'0'表示等于同合同金额
	@strSignDate varchar(19),		--合同签订日期:采用YYYY-MM-DD hh:mm:ss格式输入
	@signerID varchar(10),			--签订人ID，由人事管理系统维护
	@managerID varchar(10),			--负责人ID，由人事管理系统维护
	@pStatus nvarchar(10),			--状态说明:由第2000号代码字典定义,但可以手工输入，所以保存状态名称
	@remarks nvarchar(60),			--备注
	@projectDesc nvarchar(1000),	--项目简述

	--最新维护情况:
	@createManID varchar(10),		--创建人工号
	@Ret int output,				--成功标识
	@projectID varchar(13) output	--项目编号，采用1100号号码发生器发生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查重名：
	declare @count as int
	set @count = (select count(*) from project where projectName = @projectName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--获取输入码：
	declare @inputCode varchar(5)	--名称输入码
	set @inputCode = dbo.getChinaPYCode(@projectName)
	--获取委托单位名称：
	if (@customerID is null or @customerID='')
	begin
		set @Ret = 2
		return
	end
	declare @customerName nvarchar(30)
	set @customerName = isnull((select customerName from customerInfo where customerID = @customerID),'')
	if (@customerName is null)
	begin
		set @Ret = 3
		return
	end
	
	--使用号码发生器产生项目编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1100, 1, @curNumber output
	set @projectID = @curNumber

	--格式化签订人：
	if (@signerID is null or @signerID='')
		set @signerID = @createManID
	--取人员的姓名：
	declare @signer nvarchar(30),@manager nvarchar(30),@createManName nvarchar(30)	--签订人/负责人/创建人
	set @signer = isnull((select cName from userInfo where userID = @signerID),'')
	set @manager = isnull((select cName from userInfo where userID = @managerID),'')
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')

	--格式化状态说明：
	if (@pStatus is null or @pStatus='')
		set @pStatus = (select objDesc from codeDictionary where classCode=2000 and objCode=1)
	declare @createTime smalldatetime
	set @createTime = getdate()
	--格式化签订日期：
	declare @signDate smalldatetime
	if (@strSignDate is null or @strSignDate='')
		set @signDate = @createTime
	else
		set @signDate = convert(smalldatetime, @strSignDate, 120)
	--格式化合同净值：
	if (@netAmount is null or @netAmount=0)
		set @netAmount = @contractAmount
	insert project(projectID, projectName, inputCode, customerID, customerName,
			contractAmount, amountType, netAmount,
			signDate, signerID, signer,
			managerID, manager,
			pStatus, remarks, projectDesc,
			--最新维护情况:
			createDate, createrID, creater, modiManID, modiManName, modiTime)
	values(@projectID, @projectName, @inputCode, @customerID, @customerName,
			@contractAmount, @amountType, @netAmount,
			@signDate, @signerID, @signer,
			@managerID, @manager,
			@pStatus, @remarks, @projectDesc,
			--最新维护情况:
			@createTime, @createManID, @createManName, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'添加项目','系统根据' + @createManName + 
								'的要求添加了项目[' + @projectName + ']的信息。')
GO
--测试：
declare	@Ret int, @projectID varchar(13)
exec dbo.addProject '琼海地理国情普查项目','C201510200005',400,0,0,'','','','计划中','','','U201510003',@Ret output, @projectID output
select @Ret, @projectID


drop PROCEDURE checkProjectName
/*
	name:		checkProjectName
	function:	2.检查指定的项目是否已经登记
	input: 
				@projectName nvarchar(30),		--项目名称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE checkProjectName
	@projectName nvarchar(30),		--项目名称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该项目名称是否存在：
	declare @count int
	set @count = (select count(*) from project where projectName = @projectName)
	set @Ret = @count
GO
--测试：
declare	@Ret int
exec dbo.checkProjectName '琼海地理国情普查项目',@Ret output
select @Ret

drop PROCEDURE queryProjectLocMan
/*
	name:		queryProjectLocMan
	function:	3.查询指定项目是否有人正在编辑
	input: 
				@projectID varchar(13),		--项目编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的项目不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE queryProjectLocMan
	@projectID varchar(13),		--项目编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from project where projectID = @projectID),'')
	set @Ret = 0
GO


drop PROCEDURE lockProject4Edit
/*
	name:		lockProject4Edit
	function:	4.锁定项目编辑，避免编辑冲突
	input: 
				@projectID varchar(13),			--项目编号
				@lockManID varchar(10) output,	--锁定人，如果当前项目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：要锁定的项目不存在，2:要锁定的项目正在被别人编辑，
												9：未知错误
	author:		卢苇
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE lockProject4Edit
	@projectID varchar(13),			--项目编号
	@lockManID varchar(10) output,	--锁定人，如果当前项目正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的项目是否存在
	declare @count as int
	set @count=(select count(*) from project where projectID = @projectID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update project
	set lockManID = @lockManID 
	where projectID = @projectID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定项目编辑', '系统根据用户' + @lockManName
												+ '的要求锁定编号为：[' + @projectID + ']的项目为独占式编辑。')
GO

drop PROCEDURE unlockProjectEditor
/*
	name:		unlockProjectEditor
	function:	5.释放项目编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@projectID varchar(13),			--项目编号
				@lockManID varchar(10) output,	--锁定人，如果当前项目正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE unlockProjectEditor
	@projectID varchar(13),			--项目编号
	@lockManID varchar(10) output,	--锁定人，如果当前项目正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update project set lockManID = '' where projectID = @projectID
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
	values(@lockManID, @lockManName, getdate(), '释放项目编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了编号为：[' + @projectID + ']的项目的编辑锁。')
GO

drop PROCEDURE delProject
/*
	name:		delProject
	function:	6.删除指定的项目
	input: 
				@projectID varchar(13),			--项目编号
				@delManID varchar(10) output,	--删除人，如果当前项目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：指定的项目不存在，2：要删除的项目正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2015-10-22
	UpdateDate: 

*/
create PROCEDURE delProject
	@projectID varchar(13),			--项目编号
	@delManID varchar(10) output,	--删除人，如果当前项目正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的项目是否存在
	declare @count as int
	set @count=(select count(*) from project where projectID = @projectID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete project where projectID = @projectID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除项目', '用户' + @delManName
												+ '删除了编号为：[' + @projectID + ']的项目。')
GO



--------------------------因为工作流的要求，每一个更新都需要审核，更新操作碎片化---------------------------
drop PROCEDURE updateProjectName
/*
	name:		updateProjectName
	function:	7.更新项目名称
	input: 
				@projectID varchar(13),			--项目编号
				@projectName nvarchar(30),		--项目名称

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前项目正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的项目正被别人锁定，2:新的名称被占用，9：未知错误
	author:		卢苇
	CreateDate:	2015-10-23
	UpdateDate: 
*/
create PROCEDURE updateProjectName
	@projectID varchar(13),			--项目编号
	@projectName nvarchar(30),		--项目名称

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前项目正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from project where projectName = @projectName)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update project
	set projectName = @projectName,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where projectID = @projectID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新项目名称', '用户' + @modiManName 
												+ '更新了编号为：[' + @projectID + ']的项目的名称。')
GO




select projectID, projectName, inputCode, customerID, customerName, isnull(contractAmount,0) contractAmount,
amountType, case amountType when 0 then '估算' when 1 then '' end amountTypeDesc, isnull(netAmount,0) netAmount,
isnull(convert(varchar(19),signDate,120),'') signDate, signerID, signer,
isnull(convert(varchar(19),startDate,120),'') startDate, isnull(expectedDuration,0) expectedDuration,
isnull(convert(varchar(19),completeDate,120),'') completeDate,
isnull(managerID,'') managerID, isnull(manager,'') manager, isnull(progress,0) progress, pStatus,
collectedAmount, isnull(contractAmount,0) - isnull(collectedAmount,0) uncollectedAmount,
isnull(remarks,'') remarks, isnull(projectDesc,'') projectDesc
from project

select * from project

select projectID, projectName, inputCode, customerID, customerName, contractAmount, amountType,
	convert(varchar(19),signDate,120) signDate, signerID, signer,
	convert(varchar(19),startDate,120) startDate, expectedDuration,
	convert(varchar(19),completeDate,120) completeDate,
	managerID, manager, isnull(progress,0), pStatus,
	collectedAmount, contractAmount - collectedAmount uncollectedAmount,
	remarks, projectDesc
from project

select * from customerInfo
select * from userInfo