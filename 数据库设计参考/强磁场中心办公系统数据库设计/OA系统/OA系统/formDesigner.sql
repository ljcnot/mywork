use hustOA
/*
	强磁场中心办公系统-工作流Form设计器
	author:		卢苇
	CreateDate:	2014-1-1
	UpdateDate: 
*/
--3.工作流模板表单定义表：一个工作流模板允许多个表单
drop table workFlowTemplateForms
CREATE TABLE workFlowTemplateForms(
	templateID varchar(10) not null,	--主键/外键：工作流模板编号
	formID varchar(10) not null,		--主键：工作流模板使用到的表单ID,本系统使用第 号号码发生器产生（'FM'+4位年份代码+4位流水号）
	formType smallint not null,			--节点使用表单类型：0->显示，1->编辑
	formName nvarchar(30) null,			--表单名称

	formPageFile varchar(128) not null,	--表单静态页面页面路径（这个设计为根据表单的布局数据库定义生成的静态页面）
	--当formHtmlFile为null时，使用数据库存储的表单控件：
	formTab varchar(60) null,			--表单对应的数据库表名（主表）
	paperWidth int not null,			--纸张宽度，以mm为单位
	paperHeight int not null,			--纸张高度，以mm为单位
	paddingLeft int default(0),			--左留空，以mm为单位
	paddingRight int default(0),		--右留空，以mm为单位
	paddingTop int default(0),			--上留空，以mm为单位
	paddingBottom int default(0),		--下留空，以mm为单位
	
	--文档的号码发生器：
	DocEncoderID int default(0),		--号码发生器的ID号：0->不使用
	DocEncoderPrefix varchar(8),		--前缀
	DocEncoderDateType int,				--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
	DocEncoderSerialNumLen int,			--流水码长度
	DocEncoderSerialNumInc int,			--流水码增量
	DocEncoderSuffix varchar(8),		--后缀
	
	haveAttach int default(0),			--是否允许上传附件：0->不允许，1->允许
	/*
		扩展定义应该包括页面上使用的控件类型，布局方式，长度限制，对应的数据库字段，验证用的正则表达式等
	*/
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_workFlowTemplateForms] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[workFlowTemplateForms] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[workFlowTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateForms] CHECK CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplate] 
GO

--3.1.工作流模板表单控件一览表
drop table formCtrolList
CREATE TABLE formCtrolList(
	templateID varchar(10) not null,	--主键/外键：工作流模板编号
	formID varchar(10) not null,		--主键/外键：工作流模板使用到的表单ID
	
	ctrolType int not null,			--控件类型
	ctrolTypeName nvarchar(30) not null,--冗余设计：控件类型名称
	ctrolName varchar(30) not null,	--主键：控件名称
	ctrolCName nvarchar(30) not null,	--控件中文名称
	
	styleDesc varchar(1024) null,		--控件的样式描述：包括位置、字体、字号、颜色、字间距、行高、底色、边框、上下留空、左右留空、左右对齐方式、超出隐藏方式、是否转行
 CONSTRAINT [PK_formCtrolList] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[formCtrolList] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateForms_formCtrolList] FOREIGN KEY([templateID],[formID])
REFERENCES [dbo].[workFlowTemplateForms] ([templateID],[formID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[formCtrolList] CHECK CONSTRAINT [FK_workFlowTemplateForms_formCtrolList] 
GO
--具体控件描述表：
--3.2.标签描述表：
drop table ctrolLabel
CREATE TABLE ctrolLabel(
	templateID varchar(10) not null,--主键/外键：工作流模板编号
	formID varchar(10) not null,	--主键/外键：工作流模板使用到的表单ID
	ctrolName varchar(30) not null,	--主键/外键：控件名称

	labelText nvarchar(256),		--文本属性
CONSTRAINT [PK_ctrolLabel] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[ctrolLabel] WITH CHECK ADD CONSTRAINT [FK_formCtrolList_ctrolLabel] FOREIGN KEY([templateID],[formID],[ctrolName])
REFERENCES [dbo].[formCtrolList] ([templateID],[formID],[ctrolName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ctrolLabel] CHECK CONSTRAINT [FK_formCtrolList_ctrolLabel] 
GO


--3.3.单行文本输入框描述表：
drop table ctrolTextbox
CREATE TABLE ctrolTextbox(
	templateID varchar(10) not null,--主键/外键：工作流模板编号
	formID varchar(10) not null,	--主键/外键：工作流模板使用到的表单ID
	ctrolName varchar(30) not null,	--主键/外键：控件名称

	fieldName varchar(30) null,		--对应的字段名
	defaultText nvarchar(256),		--默认文本
	mask varchar(30),				--掩膜码
	maxLen int default(256),		--最大长度
	reg varchar(1024),				--验证正则表达式
	validatorFun varchar(32),		--验证用函数名，注意reg优先！
CONSTRAINT [PK_ctrolTextbox] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[ctrolTextbox] WITH CHECK ADD CONSTRAINT [FK_formCtrolList_ctrolTextbox] FOREIGN KEY([templateID],[formID],[ctrolName])
REFERENCES [dbo].[formCtrolList] ([templateID],[formID],[ctrolName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ctrolTextbox] CHECK CONSTRAINT [FK_formCtrolList_ctrolTextbox] 
GO

--3.4.多行文本输入框描述表：
drop table ctrolTextArea
CREATE TABLE ctrolTextArea(
	templateID varchar(10) not null,--主键/外键：工作流模板编号
	formID varchar(10) not null,	--主键/外键：工作流模板使用到的表单ID
	ctrolName varchar(30) not null,	--主键/外键：控件名称

	fieldName varchar(30) null,		--对应的字段名
	defaultText nvarchar(256),		--默认文本
	maxLen int default(256),		--最大长度
	reg varchar(1024),				--验证正则表达式
	validatorFun varchar(32),		--验证用函数名，注意reg优先！
CONSTRAINT [PK_ctrolTextArea] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[ctrolTextArea] WITH CHECK ADD CONSTRAINT [FK_formCtrolList_ctrolTextArea] FOREIGN KEY([templateID],[formID],[ctrolName])
REFERENCES [dbo].[formCtrolList] ([templateID],[formID],[ctrolName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ctrolTextArea] CHECK CONSTRAINT [FK_formCtrolList_ctrolTextArea] 
GO


drop PROCEDURE queryWorkFlowTemplateLocMan
/*
	name:		queryWorkFlowTemplateLocMan
	function:	1.查询指定的工作流模板是否有人正在编辑
	input: 
				@templateID varchar(10),--工作流模板编号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，9：查询出错，可能是指定的工作流模板不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2014-1-1
	UpdateDate: 
*/
create PROCEDURE queryWorkFlowTemplateLocMan
	@templateID varchar(10),	--工作流模板编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from workFlowTemplate where templateID= @templateID),'')
	set @Ret = 0
GO


drop PROCEDURE lockWorkFlowTemplate4Edit
/*
	name:		lockWorkFlowTemplate4Edit
	function:	2.锁定工作流模板编辑，避免编辑冲突
	input: 
				@templateID varchar(10),		--工作流模板编号
				@lockManID varchar(10) output,	--锁定人，如果当前工作流模板正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要锁定的工作流模板不存在，2:要锁定的工作流模板正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2014-1-1
	UpdateDate: 
*/
create PROCEDURE lockWorkFlowTemplate4Edit
	@templateID varchar(10),	--工作流模板编号
	@lockManID varchar(10) output,	--锁定人，如果当前工作流模板正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的工作流模板是否存在
	declare @count as int
	set @count=(select count(*) from workFlowTemplate where templateID= @templateID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from workFlowTemplate where templateID= @templateID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update workFlowTemplate 
	set lockManID = @lockManID 
	where templateID= @templateID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定工作流模板编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了工作流模板['+ @templateID +']为独占式编辑。')
GO

drop PROCEDURE unlockWorkFlowTemplateEditor
/*
	name:		unlockWorkFlowTemplateEditor
	function:	3.释放工作流模板编辑锁
				注意：本过程不检查工作流模板是否存在！
	input: 
				@templateID varchar(10),		--工作流模板编号
				@lockManID varchar(10) output,	--锁定人，如果当前工作流模板正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2014-1-1
	UpdateDate: 
*/
create PROCEDURE unlockWorkFlowTemplateEditor
	@templateID varchar(10),		--工作流模板编号
	@lockManID varchar(10) output,	--锁定人，如果当前工作流模板正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from workFlowTemplate where templateID= @templateID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update workFlowTemplate set lockManID = '' where templateID= @templateID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
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
	values(@lockManID, @lockManName, getdate(), '释放工作流模板编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了工作流模板['+ @templateID +']的编辑锁。')
GO

drop PROCEDURE addWorkFlowTemplate
/*
	name:		addWorkFlowTemplate
	function:	4.添加工作流模板
	input: 
				@templateName nvarchar(60),		--模板名称
				@formDBTable varchar(30),		--表单数据库表名
				@createFormID varchar(10),		--工作流模板使用的创建文档的表单ID
				@completedFormID varchar(10),	--工作流模板使用的完成文档的提示表单ID
				@stopFormID varchar(10),		--工作流模板使用的终止文档的提示表单ID
				@showFormID varchar(10),		--工作流模板使用的通用的文档的显示表单ID

				--工作模板使用人限制：add by lw 2013-2-20
				@templateRole xml,				--工作模板使用人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
												--role为工作流角色定义表中的角色
												--sysRole为系统角色表中的角色
												--user为系统中的用户
												--exceptUser为除外人员
				@templateLogo varchar(128),		--模板索引图片
				@templateIntroImage varchar(128),--模板介绍图片
				
				@createrID varchar(10),			--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@templateID varchar(10) output	--主键：工作流模板编号,本系统使用第 号号码发生器产生（'WF'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2014-1-1
*/
create PROCEDURE addWorkFlowTemplate
	@templateName nvarchar(60),		--模板名称
	@formDBTable varchar(30),		--表单数据库表名
	@createFormID varchar(10),		--工作流模板使用的创建文档的表单ID
	@completedFormID varchar(10),	--工作流模板使用的完成文档的提示表单ID
	@stopFormID varchar(10),		--工作流模板使用的终止文档的提示表单ID
	@showFormID varchar(10),		--工作流模板使用的通用的文档的显示表单ID

	--工作模板使用人限制：add by lw 2013-2-20
	@templateRole xml,				--工作模板使用人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
									--role为工作流角色定义表中的角色
									--sysRole为系统角色表中的角色
									--user为系统中的用户
									--exceptUser为除外人员
	@templateLogo varchar(128),		--模板索引图片
	@templateIntroImage varchar(128),--模板介绍图片
	
	@createrID varchar(10),			--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@templateID varchar(10) output	--主键：工作流模板编号,本系统使用第 号号码发生器产生（'WF'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生气体编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 60, 1, @curNumber output
	set @gasID = @curNumber

	--取保管人/创建人的姓名：
	declare @keeper nvarchar(30), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert gasInfo(gasID, gasName, gasUnit, buildDate, keeperID, keeper,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@gasID, @gasName, @gasUnit, @buildDate, @keeperID, @keeper,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记气体', '系统根据用户' + @createManName + 
					'的要求登记了气体“' + @gasName + '['+@gasID+']”。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime
declare	@gasID varchar(10)
exec dbo.addGasInfo 'He气', '2013-1-13','G201300001','00002', @Ret output, @createTime output, @gasID output
select @Ret, @gasID

select * from gasInfo

drop PROCEDURE updateGasInfo
/*
	name:		updateGasInfo
	function:	5.修改气体信息
	input: 
				@gasID varchar(10),			--气体编号
				@gasName nvarchar(30),		--气体名称
				@gasUnit nvarchar(4),		--计量单位
				@buildDate varchar(10),		--气体建立日期:采用“yyyy-MM-dd”格式传送
				@keeperID varchar(10),		--保管人工号

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的气体不存在，
							2:要修改的气体正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: modi by lw 2013-4-23增加计量单位
*/
create PROCEDURE updateGasInfo
	@templateID varchar(10) output	--主键：工作流模板编号,本系统使用第 号号码发生器产生（'WF'+4位年份代码+4位流水号）,暂时由手工维护
	@templateName nvarchar(60),		--模板名称
	@formDBTable varchar(30),		--表单数据库表名
	@createFormID varchar(10),		--工作流模板使用的创建文档的表单ID
	@completedFormID varchar(10),	--工作流模板使用的完成文档的提示表单ID
	@stopFormID varchar(10),		--工作流模板使用的终止文档的提示表单ID
	@showFormID varchar(10),		--工作流模板使用的通用的文档的显示表单ID

	--工作模板使用人限制：add by lw 2013-2-20
	@templateRole xml,				--工作模板使用人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
									--role为工作流角色定义表中的角色
									--sysRole为系统角色表中的角色
									--user为系统中的用户
									--exceptUser为除外人员
	@templateLogo varchar(128),		--模板索引图片
	@templateIntroImage varchar(128),--模板介绍图片
	
	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的气体是否存在
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取保管人/维护人的姓名：
	declare @keeper nvarchar(30), @modiManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update gasInfo
	set gasName = @gasName, gasUnit = @gasUnit,
		buildDate=@buildDate, keeperID = @keeperID, keeper = @keeper,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where gasID= @gasID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改气体', '系统根据用户' + @modiManName + 
					'的要求修改了气体“' + @gasName + '['+@gasID+']”的登记信息。')
GO

drop PROCEDURE delGasInfo
/*
	name:		delGasInfo
	function:	6.删除指定的气体
	input: 
				@gasID varchar(10),			--气体编号
				@delManID varchar(10) output,	--删除人，如果当前气体正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的气体不存在，2：要删除的气体正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE delGasInfo
	@gasID varchar(10),			--气体编号
	@delManID varchar(10) output,	--删除人，如果当前气体正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的气体是否存在
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete gasInfo where gasID= @gasID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除气体', '用户' + @delManName
												+ '删除了气体['+@gasID+']。')

GO


--3.工作流模板表单定义：一个工作流模板允许多个表单
select * from workFlowTemplateForms
delete workFlowTemplateForms
--请假条创建表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130001', 'FM20130001',1,'新建请假条','../workFlowDoc/addLeave.html')
--请假条显示页面：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130001', 'FM20130002',0,'显示请假条','../workFlowDoc/leaveDetail.html')
--请假条编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130001', 'FM20130003',1,'编辑请假条','../workFlowDoc/editLeave.html')

--设备采购申请表单创建表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130010',1,'新建设备采购申请单','../workFlowDoc/addEqpApply.html')
--设备采购申请表单编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130011',1,'编辑设备采购申请单', '../workFlowDoc/editEqpApply.html')
--设备采购申请表招标结果信息创建、编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130012',1,'填报设备招标信息', '../workFlowDoc/editEqpApply2.html')
--设备采购申请表显示页面：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130013',0,'显示设备采购申请单','../workFlowDoc/eqpApplyDetail.html')

--论文发表申请表创建表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130020',1,'新建论文发表申请','../workFlowDoc/addThesisApply.html')
--论文发表申请表编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130021',1,'编辑论文发表申请', '../workFlowDoc/editThesisApply.html')
--论文发表申请表显示页面：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130022',0,'显示论文发表申请','../workFlowDoc/thesisApplyDetail.html')


--车间加工申请表创建表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130030',1,'创建车间加工申请','../workFlowDoc/addWorkshopApply.html')
--车间加工申请表编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130031',1,'编辑车间加工申请','../workFlowDoc/editWorkshopApply.html')
--车间加工申请表加工状态填报表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130032',1,'填报车间加工申请表加工状态','../workFlowDoc/addWorkshopStatus.html')
--车间加工申请表显示页面：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130033',0,'显示车间加工申请','../workFlowDoc/workshopApplyDetail.html')

--其他申请表创建表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130040',1,'创建其他申请','../workFlowDoc/addOhterApply.html')
--其他申请表编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130041',1,'编辑其他申请','../workFlowDoc/editOhterApply.html')
--其他申请表显示页面：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130042',0,'显示其他申请','../workFlowDoc/otherApplyDetail.html')

--设备采购申请2表单创建表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130010',1,'新建设备采购申请单','../workFlowDoc/addEqpApply.html')
--设备采购申请表单编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130011',1,'编辑设备采购申请单', '../workFlowDoc/editEqpApply.html')
--设备采购申请表招标结果信息创建、编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130012',1,'填报设备招标信息', '../workFlowDoc/editEqpApply2.html')
--设备采购申请表显示页面：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130013',0,'显示设备采购申请单','../workFlowDoc/eqpApplyDetail.html')

