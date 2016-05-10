use PM100
/*
	项目管理系统--组织机构管理
	author:		卢苇
	CreateDate:	2015-10-20
	UpdateDate: 
*/
--1.组织机构表：
alter TABLE organization add	orgType smallint default(9)		--使用单位类型：由第10号代码字典定义。教育类：1：教学，2：科研，3：行政，4：后勤，9：其他
drop TABLE organization
CREATE TABLE organization
(
	orgID varchar(13) not null,			--主键：机构代码，采用1000号号码发生器发生，格式：O+8位日期码+4位流水码
	orgType smallint default(9),		--使用单位类型：由第10号代码字典定义。教育类：1：教学，2：科研，3：行政，4：后勤，9：其他
	orgName nvarchar(30) null,			--机构名称
	abbOrgName nvarchar(6) null,		--机构简称
	inputCode varchar(5) null,			--名称输入码
	superiorOrgID varchar(13) default(''),--上级机构代码：如果没有上级机构置''
	orgLevel smallint default(0),		--机构在整个组织中所处的层级

	managerID varchar(10) null,			--管理人工号
	managerName nvarchar(30) null,		--管理人姓名

	e_mail varchar(30) null,			--E_mail地址
	tel varchar(30) null,				--联系电话
	tAddress nvarchar(100) null,		--地址
	web varchar(36) null,				--网址
	
	isOff int default(0),				--是否注销：0->未注销，1->已注销
	setOffDate smalldatetime,			--注销日期

	--最新维护情况:
	createDate smalldatetime default(getdate()),	--创建日期
	createrID varchar(10) null,			--创建人ID
	creater nvarchar(30) null,			--创建人姓名
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

 CONSTRAINT [PK_organization] PRIMARY KEY CLUSTERED 
(
	[orgID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_organization] ON [dbo].[organization] 
(
	[orgName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_1] ON [dbo].[organization] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_2] ON [dbo].[organization] 
(
	[superiorOrgID] ASC,
	[orgID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_3] ON [dbo].[organization] 
(
	[superiorOrgID] ASC,
	[orgName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_4] ON [dbo].[organization] 
(
	[orgLevel] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from organization



drop PROCEDURE fastAddOrganization
/*
	name:		fastAddOrganization
	function:	1.快速添加机构简要信息
	input: 
				@orgName nvarchar(30),		--机构名称
				--隶属信息：
				@superiorOrgID varchar(13),	--上级机构代码：如果没有上级机构置''
				--最新维护情况:
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output,		--操作成功标识：
							0:成功，1:同级机构中有重名，2:上级机构不存在，9:未知错误
				@orgID varchar(13)output	--机构代码，采用1000号号码发生器发生
	author:		卢苇
	CreateDate:	2015-10-21
	UpdateDate:
*/
create PROCEDURE fastAddOrganization
	@orgName nvarchar(30),		--机构名称
	--隶属信息：
	@superiorOrgID varchar(13),	--上级机构代码：如果没有上级机构置''
	--最新维护情况:
	@createManID varchar(10),	--创建人工号
	@Ret int output,			--操作成功标识
	@orgID varchar(13)output	--机构代码，采用1000号号码发生器发生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查重名：
	declare @count as int
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgName = @orgName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--获取输入码：
	declare @inputCode varchar(5)	--名称输入码
	set @inputCode = dbo.getChinaPYCode(@orgName)
	--获取机构的层级：
	declare @orgLevel smallint		--机构在整个组织中所处的层级
	if (@superiorOrgID='')
		set @orgLevel = 0
	else
	begin
		set @orgLevel = (select orgLevel from organization where orgID = @superiorOrgID)
		if (@orgLevel is null)
		begin 
			set @Ret = 2
			return
		end
		set @orgLevel = @orgLevel + 1
	end
	--使用号码发生器产生机构代码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1000, 1, @curNumber output
	set @orgID = @curNumber

	--取添加人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')

	declare @createTime smalldatetime
	set @createTime = getdate()
	insert organization (orgID, orgName,inputCode,
				--隶属信息：
				superiorOrgID, orgLevel,
				--最新维护情况:
				createDate, createrID, creater,modiManID, modiManName, modiTime)
	values(@orgID, @orgName, @inputCode,
				--隶属信息：
				@superiorOrgID, @orgLevel,
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
								'简要注册机构','系统根据' + @createManName + 
								'的要求添加了机构[' + @orgName + ']的简要信息。')
GO
--测试：
declare	@Ret int, @orgID varchar(13)
exec dbo.fastAddOrganization '软件工程部','O201510001', 'U201510003',@Ret output, @orgID output
select @Ret, @orgID
select * from organization
select * from workNote

drop PROCEDURE addOrganization
/*
	name:		addOrganization
	function:	1.1添加机构基本信息
	input: 
				--隶属信息：
				@superiorOrgID varchar(13),	--上级机构代码：如果没有上级机构置''

				@orgType smallint,			--机构类型：由第10号代码字典定义。教育类：1：教学，2：科研，3：行政，4：后勤，9：其他
				@orgName nvarchar(30),		--机构名称
				@abbOrgName nvarchar(6),	--机构简称
				@inputCode varchar(5),		--名称输入码，为''则自动定义。自动定义原则：简称不为空，则取简称的拼音码；否则取名称的拼音码
				@e_mail varchar(30),		--E_mail地址
				@tel varchar(30),			--联系电话
				@tAddress nvarchar(100),	--地址
				@web varchar(36),			--网址

				--维护人:
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output,		--操作成功标识：
											0:成功，1:同级机构中有重名，2:上级机构不存在，9:未知错误
				@orgID varchar(13)output	--机构代码，采用1000号号码发生器发生
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE addOrganization
	--隶属信息：
	@superiorOrgID varchar(13),	--上级机构代码：如果没有上级机构置''
	
	@orgType smallint,			--使用单位类型：由第10号代码字典定义。教育类：1：教学，2：科研，3：行政，4：后勤，9：其他
	@orgName nvarchar(30),		--机构名称
	@abbOrgName nvarchar(6),	--机构简称
	@inputCode varchar(5),		--名称输入码，为''则自动定义。自动定义原则：简称不为空，则取简称的拼音码；否则取名称的拼音码
	@e_mail varchar(30),		--E_mail地址
	@tel varchar(30),			--联系电话
	@tAddress nvarchar(100),	--地址
	@web varchar(36),			--网址

	--维护人:
	@createManID varchar(10),	--创建人工号
	@Ret		int output,		--操作成功标识
	@orgID varchar(13)output	--机构代码，采用1000号号码发生器发生
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查在同级机构内是否有重名：
	declare @count int
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgName = @orgName and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--获取机构的层级：
	declare @orgLevel smallint		--机构在整个组织中所处的层级
	if (@superiorOrgID='')
		set @orgLevel = 0
	else
	begin
		set @orgLevel = (select orgLevel from organization where orgID = @superiorOrgID)
		if (@orgLevel is null)
		begin 
			set @Ret = 2
			return
		end
		set @orgLevel = @orgLevel + 1
	end

	--如果输入码为空，则定义输入码
	if (@inputCode is null or @inputCode='')
	begin
		if (@abbOrgName is not null and @abbOrgName<>'')
			set @inputCode = dbo.getChinaPYCode(@abbOrgName)
		else
			set @inputCode = dbo.getChinaPYCode(@orgName)
	end
	
	--使用号码发生器产生机构代码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1000, 1, @curNumber output
	set @orgID = @curNumber

	--取添加人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')

	declare @createTime smalldatetime
	set @createTime = getdate()
	insert organization (orgID, orgType, orgName, abbOrgName, inputCode,
				--隶属信息：
				superiorOrgID, orgLevel,
				--联系方式：
				e_mail, tel, tAddress, web,
				--最新维护情况:
				createDate, createrID, creater,modiManID, modiManName, modiTime)
	values(@orgID, @orgType, @orgName, @abbOrgName, @inputCode,
				--隶属信息：
				@superiorOrgID, @orgLevel,
				--联系方式：
				@e_mail, @tel, @tAddress, @web,
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
								'注册机构','系统根据' + @createManName + 
								'的要求添加了机构[' + @orgName + ']的基本信息。')
GO

drop PROCEDURE queryOrganizationLocMan
/*
	name:		queryOrganizationLocMan
	function:	2.查询指定机构是否有人正在编辑
	input: 
				@orgID varchar(13),			--机构代码
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的机构不存在
				@lockManID varchar(10) output--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE queryOrganizationLocMan
	@orgID varchar(13),			--机构代码
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from Organization where orgID = @orgID),'')
	set @Ret = 0
GO


drop PROCEDURE lockOrganization4Edit
/*
	name:		lockOrganization4Edit
	function:	3.锁定机构编辑，避免编辑冲突
	input: 
				@orgID varchar(13),				--机构代码
				@lockManID varchar(10) output,	--锁定人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：要锁定的机构不存在，2:要锁定的机构正在被别人编辑，
												9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE lockOrganization4Edit
	@orgID varchar(13),				--机构代码
	@lockManID varchar(10) output,	--锁定人，如果当前机构正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的机构是否存在
	declare @count as int
	set @count=(select count(*) from Organization where orgID = @orgID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from Organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update Organization
	set lockManID = @lockManID 
	where orgID = @orgID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定机构编辑', '系统根据用户' + @lockManName
												+ '的要求锁定编号为：[' + @orgID + ']的机构为独占式编辑。')
GO

drop PROCEDURE unlockOrganizationEditor
/*
	name:		unlockOrganizationEditor
	function:	4.释放机构编辑锁
				注意：本过程不检查机构是否存在！
	input: 
				@orgID varchar(13),				--机构代码
				@lockManID varchar(10) output,	--锁定人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE unlockOrganizationEditor
	@orgID varchar(13),				--机构代码
	@lockManID varchar(10) output,	--锁定人，如果当前机构正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from Organization where orgID = @orgID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update Organization set lockManID = '' where orgID = @orgID
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
	values(@lockManID, @lockManName, getdate(), '释放机构编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了编号为：[' + @orgID + ']的机构的编辑锁。')
GO


drop PROCEDURE checkOrgCode
/*
	name:		checkOrgCode
	function:	5.检查指定的机构代码是否已经存在
				说明：这是一个特殊的接口，应用在需要自行定义代码的机构
	input: 
				@superiorOrgID varchar(13),	--上级机构代码，为空串则为顶级机构
				@orgID varchar(13),			--机构代码
	output: 
				@Ret		int output		--操作成功标识
											0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE checkOrgCode
	@superiorOrgID varchar(13),	--上级机构代码
	@orgID varchar(13),			--机构代码
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查在同级机构内是否有重复代码：
	declare @count int
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgID = @orgID)
	set @Ret = @count
GO

drop PROCEDURE checkOrgName
/*
	name:		checkOrgName
	function:	6.检查指定的机构名称是否已经存在
	input: 
				@superiorOrgID varchar(13),	--上级机构代码，为空串则为顶级机构
				@orgName nvarchar(30),		--机构名称	
				@excludedOrgID varchar(13),	--除外的机构代码，''表示没有除外的机构
	output: 
				@Ret		int output		--操作成功标识
											0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE checkOrgName
	@superiorOrgID varchar(13),	--上级机构代码，为空串则为顶级机构
	@orgName nvarchar(30),		--机构名称	
	@excludedOrgID varchar(13),	--除外的机构代码，''表示没有除外的机构
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该名称是否存在：
	declare @count int
	set @count = (select count(*) from Organization 
					where superiorOrgID = @superiorOrgID and orgName = @orgName and orgID<>@excludedOrgID)
	set @Ret = @count
GO

drop PROCEDURE checkOrgAbbName
/*
	name:		checkOrgAbbName
	function:	7.检查指定的机构简称是否已经存在
	input: 
				@superiorOrgID varchar(13),	--上级机构代码，为空串则为顶级机构
				@abbOrgName nvarchar(6),	--机构简称
				@excludedOrgID varchar(13),	--除外的机构代码，''表示没有除外的机构
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE checkOrgAbbName
	@superiorOrgID varchar(13),	--上级机构代码，为空串则为顶级机构
	@abbOrgName nvarchar(6),	--机构简称
	@excludedOrgID varchar(13),	--除外的机构代码，''表示没有除外的机构
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该名称是否存在：
	declare @count int
	set @count = (select count(*) from organization 
						where superiorOrgID = @superiorOrgID and abbOrgName = @abbOrgName and orgID<>@excludedOrgID)
	set @Ret = @count
GO

drop PROCEDURE delOrganization
/*
	name:		delOrganization
	function:	8.删除指定的机构
	input: 
				@orgID varchar(13),				--机构代码
				@delManID varchar(10) output,	--删除人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
												0:成功，1：指定的机构不存在，2：要删除的机构正被别人锁定，
												3：还有下级机构，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 

*/
create PROCEDURE delOrganization
	@orgID varchar(13),				--机构代码
	@delManID varchar(10) output,	--删除人，如果当前使用单位正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的机构是否存在
	declare @count as int
	set @count=(select count(*) from organization where orgID = @orgID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查是否还有下级机构：
	set @count=(select count(*) from organization where superiorOrgID = @orgID)
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	
	delete organization where orgID = @orgID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除机构', '用户' + @delManName
												+ '删除了代码为：[' + @orgID + ']的机构。')
GO
--测试：
select * from organization

declare	@Ret int, @orgID varchar(13)
exec dbo.fastAddOrganization '测试用机构','O201511004', 'U201510003',@Ret output, @orgID output
select @Ret, @orgID

declare	@Ret int, @delManID varchar(10)
set @delManID ='U201510003'
exec dbo.delOrganization 'O201511005',@delManID output, @Ret output
select @Ret, @delManID

select * from organization
select * from workNote
	
drop PROCEDURE updateOrganization
/*
	name:		updateOrganization
	function:	9.更新机构基本信息
	input: 
				@orgID varchar(13),			--机构代码（定位字段，非更新字段）
				@orgType smallint,			--使用单位类型：由第10号代码字典定义。教育类：1：教学，2：科研，3：行政，4：后勤，9：其他
				@orgName nvarchar(30),		--机构名称
				@abbOrgName nvarchar(6),	--机构简称
				@inputCode varchar(5),		--名称输入码，为''则自动定义。自动定义原则：简称不为空，则取简称的拼音码；否则取名称的拼音码
				@e_mail varchar(30),		--E_mail地址
				@tel varchar(30),			--联系电话
				@tAddress nvarchar(100),	--地址
				@web varchar(36),			--网址

				--维护人:
				@modiManID varchar(10) output,--维护人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
											0:成功，1：要更新的机构正被别人锁定，
											2:在同级机构中有重复的名称，
											3:在同级机构中有重复的简称，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE updateOrganization
	@orgID varchar(13),			--机构代码（定位字段，非更新字段）
	@orgType smallint,			--使用单位类型：由第10号代码字典定义。教育类：1：教学，2：科研，3：行政，4：后勤，9：其他
	@orgName nvarchar(30),		--机构名称
	@abbOrgName nvarchar(6),	--机构简称
	@inputCode varchar(5),		--名称输入码，为''则自动定义。自动定义原则：简称不为空，则取简称的拼音码；否则取名称的拼音码
	@e_mail varchar(30),		--E_mail地址
	@tel varchar(30),			--联系电话
	@tAddress nvarchar(100),	--地址
	@web varchar(36),			--网址

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前机构正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查在同级机构内是否有重名：
	declare @count int, @superiorOrgID varchar(13) --上级机构代码
	set @superiorOrgID =(select superiorOrgID from organization where orgID = @orgID)
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgName = @orgName and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--检查在同级机构内是否有重复的简称：
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and abbOrgName = @abbOrgName and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 3
		return
	end

	--如果输入码为空，则定义输入码
	if (@inputCode is null or @inputCode='')
	begin
		if (@abbOrgName is not null and @abbOrgName<>'')
			set @inputCode = dbo.getChinaPYCode(@abbOrgName)
		else
			set @inputCode = dbo.getChinaPYCode(@orgName)
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update organization
	set orgType = @orgType,orgName =@orgName ,abbOrgName = @abbOrgName,inputCode = @inputCode,
		e_mail = @e_mail,tel = @tel,tAddress = @tAddress,@web = @web,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where orgID = @orgID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新机构基本信息', '用户' + @modiManName 
												+ '更新了代码为：[' + @orgID + ']的机构的基本信息。')
GO


drop PROCEDURE updateOrgID
/*
	name:		updateOrgID
	function:	10.更新机构代码
				说明：这是一个特殊的接口，应用在需要自行定义代码的机构
	input: 
				@orgID varchar(13),			--机构代码（定位字段，非更新字段）
				@newOrgID varchar(13),		--新的机构代码

				--维护人:
				@modiManID varchar(10) output,--维护人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
											0:成功，1：要更新的机构正被别人锁定，
											2:在同级机构中有重复的代码，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE updateOrgID
	@orgID varchar(13),			--机构代码（定位字段，非更新字段）
	@newOrgID varchar(13),		--新的机构代码

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前机构正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查在同级机构内是否有重复代码：
	declare @count int, @superiorOrgID varchar(13) --上级机构代码
	set @superiorOrgID =(select superiorOrgID from organization where orgID = @orgID)
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgID = @newOrgID and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update organization
	set orgID = @newOrgID,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where orgID = @orgID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更改机构代码', '用户' + @modiManName 
												+ '更改了代码为：[' + @orgID + ']的机构代码，改成了['+@newOrgID+']。')
GO


drop PROCEDURE updateOrgManager
/*
	name:		updateOrgManager
	function:	11.更新机构负责人
	input: 
				@orgID varchar(13),			--机构代码（定位字段，非更新字段）
				@managerID varchar(10),		--管理人工号

				--维护人:
				@modiManID varchar(10) output,--维护人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
											0:成功，1：要更新的机构正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE updateOrgManager
	@orgID varchar(13),			--机构代码（定位字段，非更新字段）
	@managerID varchar(10),		--管理人工号

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前机构正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取管理人、维护人的姓名：
	declare @managerName nvarchar(30),@modiManName nvarchar(30)
	set @managerName = isnull((select cName from userInfo where userID = @managerID),'')
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update organization
	set managerID = @managerID, managerName = @managerName,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where orgID = @orgID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更改机构负责人', '用户' + @modiManName 
					+ '更改了代码为：[' + @orgID + ']的机构负责人，新负责人为['+@managerName+'（'+@managerID+'）]。')
GO

drop PROCEDURE setOrganizationOff
/*
	name:		setOrganizationOff
	function:	12.停用指定的机构
	input: 
				@orgID varchar(13),				--机构代码
				@stopManID varchar(10) output,	--停用人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的机构不存在，2：要停用的机构正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 

*/
create PROCEDURE setOrganizationOff
	@orgID varchar(13),				--机构代码
	@stopManID varchar(10) output,	--停用人，如果当前机构正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的机构是否存在
	declare @count as int
	set @count=(select count(*) from organization where orgID = @orgID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update organization
	set isOff = '1', setOffDate = @stopTime
	where orgID = @orgID
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用机构', '用户' + @stopManName
												+ '停用了代码为：[' + @orgID + ']的单位。')
GO

drop PROCEDURE setOrganizationActive
/*
	name:		setOrganizationActive
	function:	13.启用指定的机构
	input: 
				@orgID varchar(13),				--机构代码
				@activeManID varchar(10) output,--启用人，如果当前机构正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
											0:成功，1：指定的机构不存在，2：要启用的机构正被别人锁定，
											3：该机构本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2015-11-22
	UpdateDate: 

*/
create PROCEDURE setOrganizationActive
	@orgID varchar(13),				--机构代码
	@activeManID varchar(10) output,--启用人，如果当前使用单位正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的机构是否存在
	declare @count as int
	set @count=(select count(*) from organization where orgID = @orgID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10),@status int
	select @thisLockMan = isnull(lockManID,''), @status = isOff  
	from organization 
	where orgID = @orgID
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
	if (@status = 0)
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update organization
	set isOff = '0', setOffDate = null
	where orgID = @orgID
	set @Ret = 0

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用机构', '用户' + @activeManName
												+ '重新启用了代码为：[' + @orgID + ']的机构。')
GO
