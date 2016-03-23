use hustOA
/*
	强磁场中心办公系统-工作流管理设计
	author:		卢苇
	CreateDate:	2013-1-20
	UpdateDate: 
*/

--1.工作流模板表：
select w.templateID, w.templateName, w.formDBTable, w.formIDMaker,
	--创建人：
	isnull(w.createrID,'') createrID, isnull(w.creater,'') creater, convert(varchar(10),w.createTime,120) createTime,
	--最新维护情况:
	isnull(w.modiManID,'') modiManID, isnull(w.modiManName,'') modiManName, convert(varchar(10),w.modiTime,120) modiTime
from workFlowTemplate w

	--add by lw 2013-7-15
alter TABLE workFlowTemplate add	templateLogo varchar(128) null		--模板索引图片
alter TABLE workFlowTemplate add	templateIntroImage varchar(128) null--模板介绍图片

drop table workFlowTemplate
CREATE TABLE workFlowTemplate(
	templateID varchar(10) not null,	--主键：工作流模板编号,本系统使用第 号号码发生器产生（'WF'+4位年份代码+4位流水号）,暂时由手工维护
	templateName nvarchar(60) null,		--模板名称
	formDBTable varchar(30) null,		--表单数据库表名
	formIDMaker int null,				--文档号码发生器编号:废止，使用form定义中的号码发生器 del by lw 2014-1-1
	
	createFormID varchar(10) null,		--工作流模板使用的创建文档的表单ID
	completedFormID varchar(10) null,	--工作流模板使用的完成文档的提示表单ID
	stopFormID varchar(10) null,		--工作流模板使用的终止文档的提示表单ID
	showFormID varchar(10) null,		--工作流模板使用的通用的文档的显示表单ID	--add by lw 2013-2-26

	--工作模板使用人限制：add by lw 2013-2-20
	templateRole xml null,				--工作模板使用人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
	--add by lw 2013-7-15
	templateLogo varchar(128) null,		--模板索引图片
	templateIntroImage varchar(128) null,--模板介绍图片
	

	--创建人：
	createrID varchar(10) null,			--创建人工号
	creater nvarchar(30) null,			--创建人姓名
	createTime smalldatetime default(getdate()),--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_workFlowTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.工作流模板公文数据库字段定义表：add by lw 2013-07-15
drop table workFlowTemplateDBDesign
CREATE TABLE workFlowTemplateDBDesign(
	templateID varchar(10) not null,	--主键/外键：工作流模板编号
	fieldName varchar(30) not null,		--字段名称
	fieldDesc nvarchar(30) null,		--字段描述
	fieldDefine varchar(128) not null,	--数据库字段定义描述：采用"varchar(30) not null"格式描述
 CONSTRAINT [PK_workFlowTemplateDBDesign] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[workFlowTemplateDBDesign] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplate_workFlowTemplateDBDesign] FOREIGN KEY([templateID])
REFERENCES [dbo].[workFlowTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateDBDesign] CHECK CONSTRAINT [FK_workFlowTemplate_workFlowTemplateDBDesign] 
GO

select * from workFlowTemplateForms
--3.工作流模板表单定义表：一个工作流模板允许多个表单
drop table workFlowTemplateForms
CREATE TABLE workFlowTemplateForms(
	templateID varchar(10) not null,	--主键/外键：工作流模板编号
	formID varchar(10) not null,		--主键：工作流模板使用到的表单ID,本系统使用第 号号码发生器产生（'FM'+4位年份代码+4位流水号）
	formType smallint not null,			--节点使用表单类型：0->显示，1->编辑
	formName nvarchar(30) null,			--表单名称
	formPageFile varchar(128) not null,	--表单静态页面页面路径（这个设计为根据表单的布局数据库定义生成的静态页面）
	
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

--3.1.工作流模板表单布局定义表:add by lw 2013-07-15
drop table workFlowTemplateFormDesign
CREATE TABLE workFlowTemplateFormDesign(
	templateID varchar(10) not null,	--主键/外键：工作流模板编号
	formID varchar(10) not null,		--主键/外键：工作流模板使用到的表单ID
	controlType int not null,			--控件类型
	controlTypeName nvarchar(30) not null,--冗余设计：控件类型名称
	controlName nvarchar(30) not null,	--控件名称
	controlTop int not null,			--控件布局top坐标
	controlLeft int not null,			--控件布局Left坐标
	controlWidth int not null,			--控件布局宽度
	controlHeight int not null,			--控件布局高度
	controlZindex int not null,			--控件布局层高
	controlDBField varchar(60) null,	--控件对应的数据字段名
 CONSTRAINT [PK_workFlowTemplateFormDesign] PRIMARY KEY CLUSTERED 
(
	[formID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[workFlowTemplateFormDesign] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplateFormDesign] FOREIGN KEY([templateID],[formID])
REFERENCES [dbo].[workFlowTemplateForms] ([templateID],[formID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateFormDesign] CHECK CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplateFormDesign] 
GO

--3.2.表单控件登记表局定义表:add by lw 2013-07-15
drop table formCtrol
CREATE TABLE formCtrol(
	controlType int not null,			--控件类型
	controlTypeName nvarchar(30) not null,--冗余设计：控件类型名称
	defaultWidth int not null,			--控件布局宽度
	defaultHeight int not null,			--控件布局高度
 CONSTRAINT [PK_formCtrol] PRIMARY KEY CLUSTERED 
(
	[controlType] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--4.工作流角色定义表：这个要同系统的用户、角色关联，通过计算可以自动生成人员范围！这是对系统角色的补充！重点是强调人员之间的关系和行政级别
drop table workFlowRole
CREATE TABLE workFlowRole(
	roleID int not null,			--主键：角色ID
	roleName nvarchar(30) not null,	--角色名称
	roleDesc nvarchar(100) null,	--角色描述
 CONSTRAINT [PK_workFlowRole] PRIMARY KEY CLUSTERED 
(
	[roleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select * from workFlowRole
select * from workFlowTemplateFlow
delete workFlowTemplateFlow where templateID='WF20130002'
--5.工作流模板节点（模板活动）定义表
drop table workFlowTemplateFlow
CREATE TABLE workFlowTemplateFlow(
	templateID varchar(10) not null,	--主键/外键：工作流模板编号,本系统使用第 号号码发生器产生（'WF'+4位年份代码+4位流水号）
	flowID int not null,				--主键：流程节点编号
	flowType int not null,				--节点类型：1->创建节点（该节点类型暂未启用）modi by lw 2013-3-3将单一节点、与汇流、或汇流属性放入流入、流出条件中定义！
												--	2->中间节点
												--	9->结束节点
										--计划考类将中间节点与开始、结束节点分离，与汇流、或汇流作为节点的流入属性，分支、分发、单一对象作为节点的流出属性
	flowEditAttri int not null,			--节点编辑属性：0->处理（审批）类节点，不编辑公文；1->编辑类节点，本节点编辑公文，需要锁定编辑锁！ --add by lw 2013-2-21
	sectionName nvarchar(30) null,		--所在环节名称：主要是用来描述大的环节
	--表决方式：add by lw 2013-3-3
	voteType smallint default(0),		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult smallint default(0),		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName nvarchar(10) null,	--同意表决按钮名称
	vetoButtonName nvarchar(10) null,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole xml null,					--节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc smallint default(0),	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity nvarchar(100) not null,	--活动名称		
	activityType nvarchar(30) null,		--活动分类	计划删除：与节点所在环节有重复！
	activityDesc nvarchar(500) null,	--活动描述
	activityFormID varchar(10) null,	--处理活动使用的form表单ID
	activityFormType smallint null,		--处理活动使用的form表单类型：0->显示，1->编辑 计划删除：与节点编辑属性有重复！
	activityShowFormID varchar(10) null,--在本节点上查看信息使用的form表单ID
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib	varchar(128) null,	--当前活动使用的代码库（js文件名，或其他文件名）
	applicationCode	nvarchar(1000) null,--活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow xml null,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType smallint default(1),		--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition nvarchar(100) null,	--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess int default(0),		--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType int default(0),		--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode nvarchar(1000) null,--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow xml null,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode smallint default(0),	--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode smallint default(0),	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition nvarchar(100) null,	--转出启动条件：暂未使用！！
	userSelectReceiver smallint default(0),	--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver smallint default(0),	--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName nvarchar(10) null,--前进按钮名称
				--否决控制：
	negationEnable smallint default(1),	--是否允许否决:0->不允许，1->允许
	negationFlow xml null,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode smallint default(0),	--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode smallint default(0),	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver smallint default(0),	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver smallint default(0),	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName nvarchar(10) null,--否决按钮名称
			--撤销与退回控制：
	isCancelEnable smallint default(0),	--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable smallint default(1),	--是否允许后退:0->不允许，1->允许
	backwardButtonName nvarchar(10) null,--后退按钮名称
	postbackEnable smallint default(1),	--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable smallint default(0),		--是否允许终止流程:0->不允许，1->允许
	stopFlow xml null,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable smallint default(0),	--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID varchar(10) not null,	--子流程工作流模板编号
	subFlowBtnName varchar(10) not null,--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow smallint default(1),	--是否等待子流程处理:0->不等待，1->等待
	subFlowResult smallint default(0),	--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted smallint default(0),--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow xml null,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack smallint default(0),		--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc nvarchar(30) null,	--签署意见人称谓
	
	--时间控制：
	isExpire smallint null,				--是否超期控制:0->不控制，1->控制超期
	startTimeType varchar(30) default('lastNodeCompleted'),--起算时间类型:'startTime'从流程开始时间，
																		--'lastNodeCompleted'->上一节点完成日期，
																		--其他定义
	dayType smallint default(0),		--时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
	expireDay	int null				--节点允许天数
 CONSTRAINT [PK_workFlowTemplateFlow] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[flowID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[workFlowTemplateFlow] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateFlow_workFlowTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[workFlowTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateFlow] CHECK CONSTRAINT [FK_workFlowTemplateFlow_workFlowTemplate]
GO


select i.instanceID, i.instanceStatus, i.templateID, i.templateName, i.topic,
	--进度：
	i.curFlowID, i.sectionName, i.curActivity, i.curActivityType, i.curActivityDesc,
	i.extendedDay, i.isCompleted,
	--创建人：
	i.createrID, i.creater, CONVERT(varchar(10),i.createTime,120) createTime
from WorkflowInstance i

--10.工作流实例表
select * from workFlowInstance
delete workFlowInstance
drop table workFlowInstance
CREATE TABLE workFlowInstance(
	instanceID varchar(10) not null,	--主键：实例编号,使用模板中定义的号码发生器生成的编号
	buildDate smalldatetime default(getdate()),--实例创建时间
	instanceStatus int default(0),		--实例状态：0->创建，1->流转中，9->完成，-1->退回，-2：终止
	statusDesc nvarchar(500) null,		--状态说明
	isSubInstance smallint default(0),	--是否为子流程实例:0->不是,1->是 add by lw 2013-3-3
	parentInstanceID varchar(10) null,	--父实例编号,使用模板中定义的号码发生器生成的编号 add by lw 2013-3-3
	
	templateID varchar(10) not null,	--工作流模板编号
	templateName nvarchar(60) null,		--模板名称
	topic nvarchar(100) null,			--实例内容简述
	
	--最新活动情况:
	curFlowID int null,					--最新节点编号
	sectionName nvarchar(30) null,		--最新节点所在环节名称
	curActivity nvarchar(100) not null,	--最新活动名称		
	curActivityType nvarchar(30) null,	--最新活动分类
	curActivityDesc nvarchar(500) null,	--最新活动描述
	extendedDay int null,				--节点超期天数
	
	--完成情况：add by lw 2013-2-25
	completedStatus int default(0),		--完成结果状态：0->未知，1->同意，2->不同意
	completedInfo nvarchar(300) null,	--完成情况描述
	
	--创建人：
	createrID varchar(10) null,			--创建人工号
	creater nvarchar(30) null,			--创建人姓名
	createTime smalldatetime default(getdate()),--创建时间
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_workFlowInstance] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--模板编号索引：
CREATE NONCLUSTERED INDEX [IX_workFlowInstance] ON [dbo].[workFlowInstance] 
(
	[templateID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--创建人索引：
CREATE NONCLUSTERED INDEX [IX_workFlowInstance_1] ON [dbo].[workFlowInstance] 
(
	[createrID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--11.工作流实例活动表（公文环节送达人员表）
select activityID, instanceID, templateID, flowID, activity, sectionName,
	--活动主体：
	receiverID, receiver,
	--流向控制：
	prevFlowID2Status, nextFlowID,
	--时间控制：
	receiveDate, completedDate, activityStatus, isExpire, startTimeType, expireDay, usedDay
from workflowInstanceActivity
where instanceID='WF20130055'

drop table workflowInstanceActivity
CREATE TABLE workflowInstanceActivity(
	activityID bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--主键：当前活动的标识：每次启动活动都产生一个新的ID，
																	--多次进入同一个活动，会产生活动的多个副本。
	instanceID varchar(10) not null,	--外键：实例编号
	templateID varchar(10) not null,	--工作流模板编号：冗余设计
	flowID int not null,				--节点编号
	activity nvarchar(100) not null,	--活动名称		
	sectionName nvarchar(30) null,		--活动所在环节名称：冗余设计
	--活动主体：
	receiverID varchar(10) not null,	--送达人员工号
	receiver nvarchar(30) not null,		--送达人员姓名
	--流向说明：
	prevFlowID2Status xml null,			--流入实例活动与流入表决状态:
										--采用N'<root><flow id="2" aid="120" senderID="G201300001" sender="程远" status="1"></flow></root>'格式存放
	nextFlowID xml null,				--流出节点编号
	--子流程控制：
	startSubFlow smallint default(0),	--是否启动子流程：0->未启动，1->启动 add by lw 2013-3-3
	subInstanceID varchar(10) null,		--子实例编号,使用模板中定义的号码发生器生成的编号 add by lw 2013-3-3
	--时间控制：
	receiveDate smalldatetime null,		--送达日期
	completedDate smalldatetime null,	--活动完成日期
	activityStatus int default(0),		--活动状态：0->活动开始，但还未全部到达(等待前置节点完成)，
												--	1->前置节点活动全部完成，等待处理，
												--	2->正在处理中
												--	-1->撤销返回上一节点，-2->否决退回上一个节点，
												--	9->完成并转入下一个环节
												--	10->活动被终止
	isExpire smallint null,				--是否超期控制:0->不控制，1->控制超期
	startTimeType varchar(30) default('lastNodeCompleted'),--起算时间类型:'startTime'从流程开始时间，
																		--'lastNodeCompleted'->上一节点完成日期，
																		--其他定义
	expireDay int,						--活动允许天数
	usedDay int							--活动实际用时

 CONSTRAINT [PK_WorkflowInstanceActivity] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC,
	[activityID] ASC,
	[receiverID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[workflowInstanceActivity] WITH CHECK ADD CONSTRAINT [FK_WorkflowInstanceActivity_WorkflowInstance] FOREIGN KEY([instanceID])
REFERENCES [dbo].[WorkflowInstance] ([instanceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workflowInstanceActivity] CHECK CONSTRAINT [FK_WorkflowInstanceActivity_WorkflowInstance] 
GO

--索引：
--模板编号索引：
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceActivity] ON [dbo].[workflowInstanceActivity] 
(
	[templateID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from workflowInstanceFeedBack
--12.公文流转意见签署表
delete workflowInstanceFeedBack
alter table workflowInstanceFeedBack drop column attachment
alter table workflowInstanceFeedBack drop column attachmentFilename
drop table workflowInstanceFeedBack
CREATE TABLE workflowInstanceFeedBack(
	templateID varchar(10) not null,			--工作流模板编号：冗余设计
	instanceID varchar(10) not null,			--主键：实例编号
	activityID bigint,							--主键：当前活动的标识
	activity nvarchar(100) not null,			--活动名称：冗余设计
	flowID int not null,						--节点编号

	approveTime smalldatetime null,				--批准时间
	approveManID varchar(10) null,				--批准人工号
	approveMan nvarchar(30) null,				--批准人姓名：冗余设计
	approveStatus smallint null,				--批复意见类型：0->未知，1->批准，-1->不批准
	approveOpinion nvarchar(500) null,			--批复意见
	--attachment varchar(128) null,				--附件文件名 del by lw 2013-6-21
	--attachmentFilename varchar(128) null		--附件的原始文件名 add by lw 2013-2-26 del by lw 2013-6-21
 CONSTRAINT [PK_WorkflowInstanceFeedBack] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC,
	[activityID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[workflowInstanceFeedBack] WITH CHECK ADD CONSTRAINT [FK_WorkflowInstanceFeedBack_WorkflowInstance] FOREIGN KEY([instanceID])
REFERENCES [dbo].[WorkflowInstance] ([instanceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workflowInstanceFeedBack] CHECK CONSTRAINT [FK_WorkflowInstanceFeedBack_WorkflowInstance] 
GO

--索引：
--模板编号索引：
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceFeedBack] ON [dbo].[workflowInstanceFeedBack] 
(
	[templateID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--批准人索引：
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceFeedBack_1] ON [dbo].[workflowInstanceFeedBack] 
(
	[approveManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--模板节点索引：
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceFeedBack_2] ON [dbo].[workflowInstanceFeedBack] 
(
	[templateID] ASC,
	[flowID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--13.公文流转意见签署附件库：支持多个附件 add by lw 2013-6-21
select *, aFilename, uidFilename, fileSize, fileType, convert(varchar(19), uploadTime, 120) uploadTime
from feedBackAttachment
drop TABLE feedBackAttachment
CREATE TABLE feedBackAttachment(
	instanceID varchar(10) not null,			--主键/外键：实例编号
	activityID bigint,							--主键/外键：当前活动的标识
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,	--主键：行号
	
	aFilename varchar(128) null,					--原始文件名
	uidFilename varchar(128) not null,				--UID文件名
	fileSize bigint null,							--文件尺寸
	fileType varchar(10),							--文件类型
	uploadTime smalldatetime default(getdate()),	--上传日期
 CONSTRAINT [PK_feedBackAttachment] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC,
	[activityID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[feedBackAttachment] WITH CHECK ADD CONSTRAINT [FK_WorkflowInstanceFeedBack_feedBackAttachment] FOREIGN KEY([instanceID],[activityID])
REFERENCES [dbo].[WorkflowInstanceFeedBack] ([instanceID],[activityID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[feedBackAttachment] CHECK CONSTRAINT [FK_WorkflowInstanceFeedBack_feedBackAttachment]
GO

--索引：
--原始文件名索引：
CREATE NONCLUSTERED INDEX [IX_feedBackAttachment] ON [dbo].[feedBackAttachment]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--文件类型索引：
CREATE NONCLUSTERED INDEX [IX_feedBackAttachment_1] ON [dbo].[feedBackAttachment]
(
	[fileType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select templateID, flowID, flowType, sectionName, formID,
	--节点接收人限制：
	flowRole,					--节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, applicationLib, applicationCode,
	--流向控制：
	prevFlow, nextFlow, inCondition, outCondition, isFeedBack, feedBackManDesc,
	--时间控制：
	IsExpire, startTimeType, ExpireDay
from workFlowTemplateFlow
--获取指定工作流模板中的指定活动的角色限制：
SELECT flowRole.query('data(/root/role/@id)'), flowRole.query('data(/root/role/@desc)') from workFlowTemplateFlow

drop FUNCTION canUseThisWorkFlowTemplate
/*
	name:		canUseThisWorkFlowTemplate
	function:	0.判定指定的用户能否使用指定的工作流模板
	input: 
				@templateID varchar(10),	--工作流模板编号
				@userID varchar(10)			--用户工号
	output: 
				return char(1)	--能否使用：“Y”->能使用，“N”->不能使用
	author:		卢苇
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION canUseThisWorkFlowTemplate
(  
	@templateID varchar(10),	--工作流模板编号
	@userID varchar(10)			--用户工号
)  
RETURNS char(1)
WITH ENCRYPTION
AS      
begin
	--检查模板是否存在：
	declare @count int
	set @count = ISNULL((select count(*) from workFlowTemplate where templateID = @templateID),0)
	if (@count=0)
	begin
		return 'N'
	end
	
	--判断是否有角色限制：
	declare @templateRole xml			--工作模板使用人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
	select @templateRole = templateRole
	from workFlowTemplate
	where templateID = @templateID
	if (@templateRole is null)	--没有角色限制，返回全体人员
	begin
		return 'Y'
	end
	
	--获取指定工作流模板的角色限制：
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--是否全部为空
	set @isAllEmpty = 'Y'
	set @count=(select @templateRole.exist('/root/role'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'

		declare @roleID int, @roleDesc nvarchar(30)
		declare tar cursor for
		SELECT A.wfRole.value('./@id','int'), A.wfRole.value('./@desc','nvarchar(30)')
		from @templateRole.nodes('/root/role') as A(wfRole)
		OPEN tar
		FETCH NEXT FROM tar INTO @roleID, @roleDesc
		WHILE @@FETCH_STATUS = 0
		begin
			if (@roleID = 1)			--中心领导（正职）:中心最高领导，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from college where clgCode='001'
			end
			else if (@roleID = 2)		--中心领导（副职）:中心行政领导，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select deputyManID, deputyMan from college where clgCode='001'
			end
			else if (@roleID = 10)		--部长:各部门领导，泛指这个级别的所有人员
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
			end
			else if (@roleID = 20)		--教工:泛指全体教工
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1
			end
			else if (@roleID = 30)		--导师:泛指全体带研究生的导师
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and jobNumber in (select tutorID from userInfo where manType=9) 
			end
			else if (@roleID = 40)		--学生:泛指全体学生
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9
			end
			else if (@roleID = 100)		--全体人员
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo where isOff = 0
			end
			FETCH NEXT FROM tar INTO @roleID, @roleDesc
		end
		CLOSE tar
		DEALLOCATE tar
	end
	
	--添加系统角色定义的用户：
	set @count=(select @templateRole.exist('/root/sysRole'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		select u.jobNumber, u.cName 
		from userInfo u inner join sysUserRole s on u.jobNumber = s.jobNumber
		where s.sysRoleID in (SELECT A.sysRole.value('./@id','int')
								from @templateRole.nodes('/root/sysRole') as A(sysRole))
	end
	--添加直接定义的用户：
	set @count=(select @templateRole.exist('/root/user'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		SELECT cast(A.col1.query('data(./@userID)') as varchar(10)),cast(A.col1.query('data(./@userCName)') as nvarchar(30))
		from @templateRole.nodes('/root/user') as A(col1)
	end
	
	set @count = (select count(*) from @selectedMan)
	if (@count>0)
	begin
		--除外人员：
		delete	@selectedMan
		where userID in (SELECT A.col1.value('./@userID','varchar(10)') from @templateRole.nodes('/root/exceptUser') as A(col1))

		set @count = (select count(*) from @selectedMan where userID = @userID)
		if (@count>0)
			return 'Y'
	end
	else
	begin
		if (@isAllEmpty = 'Y')
		begin
			if (@userID not in (SELECT A.col1.value('./@userID','varchar(10)') from @templateRole.nodes('/root/exceptUser') as A(col1)))
				return 'Y'
		end
	end
	return 'N'
end
--测试：
select dbo.canUseThisWorkFlowTemplate('WF20130001','G201300004')
--查询指定用户能使用的模板：
select * from workFlowTemplate where dbo.canUseThisWorkFlowTemplate(templateID,'G201300006')='Y'

select * from workFlowTemplate
declare @templateRole xml
update workFlowTemplate
set templateRole = N'<root>'+
						--'<user userID="G201300001" userCName="程远" />'+
						--'<user userID="G201300003" userCName="杨斌" />'+
						'<role id="20" desc="教工" />'+
					'</root>'
where templateID='WF20130002'

select * from userInfo

drop PROCEDURE getWorkFlowTemplateEnableMan
/*
	name:		getWorkFlowTemplateEnableMan
	function:	1.查询工作流模板能够使用人员列表
				注意:工作流角色库中的角色不是全部能够加入定义的，人员之间的相对关系的角色不能加入模板使用人限制
	input: 
				@templateID varchar(10),	--工作流模板编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要查询的工作流模板不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-20
	UpdateDate: 
*/
create PROCEDURE getWorkFlowTemplateEnableMan
	@templateID varchar(10),	--工作流模板编号
	@Ret int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查模板是否存在：
	declare @count int
	set @count = ISNULL((select count(*) from workFlowTemplate where templateID = @templateID),0)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	
	--判断是否有角色限制：
	declare @templateRole xml			--工作模板使用人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
	select @templateRole = templateRole
	from workFlowTemplate
	where templateID = @templateID
	if (@templateRole is null)	--没有角色限制，返回全体人员
	begin
		set @Ret = 0
		select jobNumber, cName from userInfo where isOff = 0 order by cName
		return
	end
	
	--获取指定工作流模板的角色限制：
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--是否全部为空
	set @isAllEmpty = 'Y'
	set @count=(select @templateRole.exist('/root/role'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		
		declare @roleID int, @roleDesc nvarchar(30)
		declare tar cursor for
		SELECT A.wfRole.value('./@id','int'), A.wfRole.value('./@desc','nvarchar(30)')
		from @templateRole.nodes('/root/role') as A(wfRole)
		OPEN tar
		FETCH NEXT FROM tar INTO @roleID, @roleDesc
		WHILE @@FETCH_STATUS = 0
		begin
			if (@roleID = 1)			--中心领导（正职）:中心最高领导，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from college where clgCode='001'
			end
			else if (@roleID = 2)		--中心领导（副职）:中心行政领导，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select deputyManID, deputyMan from college where clgCode='001'
			end
			else if (@roleID = 10)		--部长:各部门领导，泛指这个级别的所有人员
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
			end
			else if (@roleID = 20)		--教工:泛指全体教工
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1
			end
			else if (@roleID = 30)		--导师:泛指全体带研究生的导师
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and jobNumber in (select tutorID from userInfo where manType=9) 
			end
			else if (@roleID = 40)		--学生:泛指全体学生
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9
			end
			else if (@roleID = 100)		--全体人员
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo where isOff = 0
			end
			FETCH NEXT FROM tar INTO @roleID, @roleDesc
		end
		CLOSE tar
		DEALLOCATE tar
	end
	
	--添加系统角色定义的用户：
	set @count=(select @templateRole.exist('/root/sysRole'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		select u.jobNumber, u.cName 
		from userInfo u inner join sysUserRole s on u.jobNumber = s.jobNumber
		where s.sysRoleID in (SELECT A.sysRole.value('./@id','int')
								from @templateRole.nodes('/root/sysRole') as A(sysRole))
	end

	--添加直接定义的用户：
	set @count=(select @templateRole.exist('/root/user'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		SELECT cast(A.col1.query('data(./@userID)') as varchar(10)),cast(A.col1.query('data(./@userCName)') as nvarchar(30))
		from @templateRole.nodes('/root/user') as A(col1)
	end

	--除外人员：
	set @count = (select count(*) from @selectedMan)
	if (@count>0)
	begin
		--除外人员：
		delete	@selectedMan
		where userID in (SELECT A.col1.value('./@userID','varchar(10)') from @templateRole.nodes('/root/exceptUser') as A(col1))
	end
	else
	begin
		if (@isAllEmpty = 'Y')
		begin
			insert @selectedMan(userID, userCName)
			select jobNumber, cName from userInfo 
			where isOff = 0 and jobNumber not in (SELECT A.col1.value('./@userID','varchar(10)') from @templateRole.nodes('/root/exceptUser') as A(col1))
		end
	end

	set @Ret = 0
	select distinct userID, userCName from @selectedMan 
	where isnull(userID,'')<>''
GO
--测试：
declare @Ret int	--操作成功标识
exec dbo.getWorkFlowTemplateEnableMan 'WF20130001',@Ret output


drop PROCEDURE getFlowInWorkFlowTemplateEnableMan
/*
	name:		getFlowInWorkFlowTemplateEnableMan
	function:	2.查询工作流节点能够使用人员列表
	input: 
				@templateID varchar(10),	--工作流模板编号
				@flowID int,				--流程节点编号
				@instanceID varchar(10),	--实例编号

				@prevManID varchar(10),		--上一个节点人员ID
				--del by lw 2013-2-23
				--@includePrevMan smallint,	--本节点计算人员是否可以包含上一个节点人员
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要查询的工作流模板不存在，2：要查询的节点不存在，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-20
	UpdateDate: modi by lw 2013-2-21增加系统角色和用户处理
				modi by lw 2013-2-23将排除人员计算放到高级语言中！
				modi by lw 2013-2-28增加公文的创建人角色支持
*/
create PROCEDURE getFlowInWorkFlowTemplateEnableMan
	@templateID varchar(10),	--工作流模板编号
	@flowID int,				--流程节点编号
	@instanceID varchar(10),	--实例编号
	
	@prevManID varchar(10),		--上一个节点人员ID
--	@includePrevMan smallint,	--本节点计算人员是否可以包含上一个节点人员
	@Ret int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查模板是否存在：
	declare @count int
	set @count = ISNULL((select count(*) from workFlowTemplate where templateID = @templateID),0)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	--检查节点是否存在：
	set @count = ISNULL((select count(*) from workFlowTemplateFlow where templateID = @templateID and flowID=@flowID),0)
	if (@count=0)
	begin
		set @Ret = 2
		return
	end
	
	--判断是否有角色限制：
	declare @templateRole xml			--节点可以使用人的角色：
										--采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
	select @templateRole = flowRole
	from workFlowTemplateFlow
	where templateID = @templateID and flowID = @flowID
	if (@templateRole is null)	--没有角色限制，返回全体人员
	begin
		set @Ret = 0
		select jobNumber userID, cName userCName from userInfo 
		where isOff = 0 and jobNumber <> @prevManID order by cName
		return
	end

	declare @managerID varchar(10), @manager nvarchar(30), @deputyManID varchar(10), @deputyMan nvarchar(30)	--中心领导
	--获取指定工作流模板中的指定活动的角色限制：
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--是否全部为空
	set @isAllEmpty = 'Y'
	set @count=(select @templateRole.exist('/root/role'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		
		declare @roleID int, @roleDesc nvarchar(30)
		declare tar cursor for
		SELECT A.wfRole.value('./@id','int'), A.wfRole.value('./@desc','nvarchar(30)')
		from @templateRole.nodes('/root/role') as A(wfRole)
		OPEN tar
		FETCH NEXT FROM tar INTO @roleID, @roleDesc
		WHILE @@FETCH_STATUS = 0
		begin
			if (@roleID = 0)			--公文创建人
			begin
				insert @selectedMan(userID, userCName)
				select createrID,creater from workFlowInstance where instanceID = @instanceID
			end
			else if (@roleID = 1)			--中心领导（正职）:中心最高领导，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from college where clgCode='001'
			end
			else if (@roleID = 2)		--中心领导（副职）:中心行政领导，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select deputyManID, deputyMan from college where clgCode='001'
			end
			else if (@roleID = 10)		--部长:各部门领导，泛指这个级别的所有人员
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
			end
			else if (@roleID = 11)		--直属部长:工作流节点处理人员所在部门的领导，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
				where uCode in (select uCode from userInfo where jobNumber=@prevManID)
			end
			else if (@roleID = 20)		--教工:泛指全体教工
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1
			end
			else if (@roleID = 21)		--部门同事:工作流节点处理人员所在部门的教工，泛指部门全体教工
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1 and uCode in (select uCode from userInfo where jobNumber=@prevManID) 
			end
			else if (@roleID = 30)		--导师:泛指全体带研究生的导师
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and jobNumber in (select tutorID from userInfo where manType=9) 
			end
			else if (@roleID = 31)		--直属导师:工作流节点处理学生的隶属导师，只能是单一人员
			begin
				insert @selectedMan(userID, userCName)
				select tutorID, tutorName from userInfo 
				where manType=9 and jobNumber=@prevManID 
			end
			else if (@roleID = 40)		--学生:泛指全体学生
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9
			end
			else if (@roleID = 41)		--部门同学:工作流节点处理学生所在部门的其他同学，泛指部门同学
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9 and uCode in (select uCode from userInfo where jobNumber=@prevManID)
			end
			else if (@roleID = 100)		--全体人员:工作流节点处理学生所在部门的其他同学，泛指部门同学
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo where isOff = 0
			end
			else if (@roleID = 101)		--直属领导:工作流节点处理人员的直属上级领导，比如学生的直属领导为其导师，教工的直属领导为部长，部长的直属领导为中心领导
			begin
				declare @manType smallint
				set @manType = ISNULL((select manType from userInfo where jobNumber=@prevManID),1)
				if (@manType=9)	--上一节点人为学生直接取导师
				begin
					insert @selectedMan(userID, userCName)
					select tutorID, tutorName from userInfo 
					where manType=9 and jobNumber=@prevManID 
				end
				else if (@manType=1)	--上一节点人为教工
				begin
					select @managerID = managerID, @manager = manager, @deputyManID = deputyManID, @deputyMan = deputyMan
					from college where clgCode='001'
					if (@prevManID <> @managerID)
					begin
						if (@prevManID = @deputyManID)
							insert @selectedMan(userID, userCName)
							values(@managerID,@manager)
						else
						begin
							set @count = isnull((select count(*) from useUnit where managerID = @prevManID),0)
							if (@count > 0)	--部长
							begin
								insert @selectedMan(userID, userCName)
								values(@managerID,@manager)
								insert @selectedMan(userID, userCName)
								values(@deputyManID,@deputyMan)
							end
							else
							begin
								insert @selectedMan(userID, userCName)
								select managerID, manager from useUnit
								where uCode in (select uCode from userInfo where jobNumber=@prevManID)
							end
						end
					end
				end		
			end
			else if (@roleID = 102)		--属下
			begin
				--判断该上一节点人员是否为中心领导
				set @count = isnull((select count(*) from college where clgCode='001' and (managerID=@prevManID or deputyManID=@prevManID)),0)
				if (@count > 0)	--中心领导
				begin
					select @managerID=managerID, @deputyManID=deputyManID from college where clgCode='001'
					insert @selectedMan(userID, userCName)
					select jobNumber, cName 
					from userInfo 
					where isOff = 0 and jobNumber not in (@managerID, @deputyManID)
				end
				else
				begin
					--判断该上一节点人员是否为部长
					set @count = isnull((select count(*) from useUnit where managerID = @prevManID),0)
					if (@count > 0)	--部长
					begin
						insert @selectedMan(userID, userCName)
						select jobNumber, cName 
						from userInfo 
						where isOff = 0 and uCode in (select uCode from useUnit where managerID = @prevManID)
					end
					else
					begin
						--判断该上一节点人员是否为教工：
						set @count = isnull((select count(*) from userInfo where manType=9 and jobNumber = @prevManID),0)
						if (@count > 0)	--部长
							insert @selectedMan(userID, userCName)
							select jobNumber, cName from userInfo where isOff = 0 and tutorID = @prevManID
					end
				end
			end
			else if (@roleID = 999)		--系统自动处理角色
			begin
				insert @selectedMan(userID, userCName)
				values('0000000000','系统用户')
			end
			
			FETCH NEXT FROM tar INTO @roleID, @roleDesc
		end
		CLOSE tar
		DEALLOCATE tar
	end
	
	--添加系统角色定义的用户：
	set @count=(select @templateRole.exist('/root/sysRole'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		select u.jobNumber, u.cName 
		from userInfo u inner join sysUserRole s on u.jobNumber = s.jobNumber
		where s.sysRoleID in (SELECT A.sysRole.value('./@id','int')
								from @templateRole.nodes('/root/sysRole') as A(sysRole))
	end
	
	--添加直接定义的用户：
	set @count=(select @templateRole.exist('/root/user'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		SELECT cast(A.col1.query('data(./@userID)') as varchar(10)),cast(A.col1.query('data(./@userCName)') as nvarchar(30))
		from @templateRole.nodes('/root/user') as A(col1)
	end

	--除外人员：
	set @count = (select count(*) from @selectedMan)
	if (@count>0)
	begin
		--除外人员：
		delete	@selectedMan
		where userID in (SELECT A.col1.value('./@userID','varchar(10)') from @templateRole.nodes('/root/exceptUser') as A(col1))
	end
	else
	begin
		if (@isAllEmpty = 'Y')
		begin
			insert @selectedMan(userID, userCName)
			select jobNumber, cName from userInfo 
			where isOff = 0 and jobNumber not in (SELECT A.col1.value('./@userID','varchar(10)') from @templateRole.nodes('/root/exceptUser') as A(col1))
		end
	end
	
	set @Ret = 0

	--排除前置节点人员本身：
	select distinct userID, userCName from @selectedMan 
	where userID <> @prevManID and isnull(userID,'')<>''
/*del by lw 2013-2-23
	if (@includePrevMan=1)
		select distinct userID, userCName from @selectedMan 
		where isnull(userID,'')<>''
	else
		select distinct userID, userCName from @selectedMan
		where userID <> @prevManID and isnull(userID,'')<>''
*/	
GO
--测试：
declare @Ret int 				--操作成功标识
exec dbo.getFlowInWorkFlowTemplateEnableMan 'WF20130002',2, 'CG20130382', 'G201300297', @Ret output
select uCode, uName, * from userInfo
where jobNumber='G201300297'
select managerID, manager from useUnit
where uCode in (select uCode from userInfo where jobNumber='G201300297')

select * from useUnit
declare @Ret int 				--操作成功标识
exec dbo.getFlowInWorkFlowTemplateEnableMan 'WF20130001',2,'G201300040', @Ret output
select * from workFlowInstance
select * from workflowInstanceActivity
select * from useUnit
update useUnit 
set managerID='G201300001'
where uCode='001001'
use hustOA
select * from workflowInstanceActivity

select * from workFlowInstance
delete workFlowInstance

select * from userInfo
select * from useUnit
select * from userInfo where jobNumber ='G201300035'
select * from useUnit where uCode='001003'
select * from userInfo where manType = 9

select * from useUnit

drop PROCEDURE addWorkFlowInstance
/*
	name:		addWorkFlowInstance
	function:	10.添加工作流实例并启动流程
	input: 
				@templateID varchar(10),		--工作流模板编号
				@topic nvarchar(100),			--实例内容简述

				@createrID varchar(10),			--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该模板不存在，2：该模板正被锁定编辑，不允许创建新实例，9:未知错误
				@createTime smalldatetime output,--创建时间
				@instanceID varchar(10) output	--实例编号,使用模板中定义的号码发生器生成的编号
	author:		卢苇
	CreateDate:	2013-1-20
	UpdateDate: 
*/
create PROCEDURE addWorkFlowInstance
	@templateID varchar(10),		--工作流模板编号
	@topic nvarchar(100),			--实例内容简述

	@createrID varchar(10),			--创建人工号
	@Ret	int output,				--操作成功标识
	@createTime smalldatetime output,--创建时间
	@instanceID varchar(10) output	--实例编号,使用模板中定义的号码发生器生成的编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--获取模板的基本信息：
	declare @templateName nvarchar(60)	--模板名称
	declare @formDBTable varchar(30)	--表单数据库表名
	declare @formIDMaker int			--文档号码发生器编号	
	declare @lockManID varchar(10)		--模板当前正在锁定编辑的人工号
	select @templateName = templateName, @formDBTable = formDBTable, @formIDMaker = formIDMaker, @lockManID = lockManID
	from workFlowTemplate
	where templateID = @templateID
	if (@templateName is null)	--模板不存在
	begin
		set @Ret = 1
		return
	end
	if (ISNULL(@lockManID,'')<>'')	--模板正被锁定编辑
	begin
		set @Ret = 2
		return
	end
	
	--使用号码发生器产生场地编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber @formIDMaker, 1, @curNumber output
	set @instanceID = @curNumber

	--创建人的姓名：
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @createrID),'')
	
	set @createTime = getdate()
	begin tran
		--登记实例：
		insert workFlowInstance(instanceID, buildDate, templateID, templateName, topic,
							--创建人/最新维护情况:
							createrID, creater, createTime,modiManID, modiManName, modiTime,
							--实例状态：
							instanceStatus, statusDesc,
							--进度：
							curFlowID, sectionName, 
							curActivity, curActivityType, curActivityDesc, extendedDay)

		select @instanceID, @createTime, @templateID, @templateName, @topic,
							--创建人/最新维护情况：
							@createrID, @creater, @createTime, @createrID, @creater, @createTime,
							--实例状态：
							1, activityDesc,
							--当前活动（进度）：
							1, sectionName, activity, activityType, activityDesc, 0
		from workFlowTemplateFlow
		where templateID = @templateID and flowID = 1
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--创建实例的活动库：
		insert workflowInstanceActivity(instanceID, templateID, flowID, 
				activity, sectionName,
				--活动主体：
				receiverID, receiver,
				--流向说明：
				prevFlowID2Status, nextFlowID,
				--时间控制：
				receiveDate, completedDate, activityStatus, 
				isExpire, startTimeType, expireDay, usedDay)
		select @instanceID, @templateID, flowID,
				activity, sectionName,
				@createrID, @creater,
				N'<root></root>',N'<root></root>',	--流入节点编号与状态/流出节点编号
				@createTime, null, 1, 
				--时间控制：
				isExpire, startTimeType,expireDay,0
		from workFlowTemplateFlow
		where templateID = @templateID and flowID = 1
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createrID, @creater, @createTime, '创建工作流实例', '系统根据用户' + @creater + 
					'的要求创建了工作流模板['+@templateName+']的实例['+@instanceID+']。')
GO
--测试：
declare @Ret	int		--操作成功标识
declare @createTime smalldatetime	--创建时间
declare @instanceID varchar(10)		--实例编号,使用模板中定义的号码发生器生成的编号
exec addWorkFlowInstance 'WF20130001','我的请假条','G201300001', @Ret output, @createTime output, @instanceID output
select @Ret,@instanceID

select * from workFlowInstance
select * from workflowInstanceActivity

drop PROCEDURE addWorkflowInstanceFeedBack
/*
	name:		addWorkflowInstanceFeedBack
	function:	11.添加工作流实例指定活动的会签意见
				注意：本过程添加前会自动清除上次添加的会签意见，这样就支持了处理过程中的临时保存，再次载入处理修改会签意见
	input: 
				@instanceID varchar(10),			--主键：实例编号
				@activityID bigint,					--主键：当前活动的标识

				@approveManID varchar(10),			--批准人工号
				@approveStatus smallint,			--批复意见类型：0->未知，1->批准，-1->不批准
				@approveOpinion nvarchar(500),		--批复意见
				@attachment xml,					--附件,采用如下xml格式存放：
													<root>
														<attachment aFilename="a.doc" uidFilename="XXXXXX" fileSize="123" fileType=".doc" />
													</root>
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的工作流实例不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-23
	UpdateDate: modi by lw 2013-2-23增加清除上次会签意见处理
				modi by lw 2013-2-26增加附件原始文件名支持
				modi by lw 2013-6-21支持多个附件

*/
create PROCEDURE addWorkflowInstanceFeedBack
	@instanceID varchar(10),			--主键：实例编号
	@activityID bigint,					--主键：当前活动的标识

	@approveManID varchar(10),			--批准人工号
	@approveStatus smallint,			--批复意见类型：0->未知，1->批准，-1->不批准
	@approveOpinion nvarchar(500),		--批复意见
	@attachment xml,					--附件,采用xml格式存放
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要添加会签意见的工作流实例和活动是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--删除可能的上次会签意见：
	delete workflowInstanceFeedBack where instanceID = @instanceID and activityID= @activityID
	
	--获取工作流实例的基本信息：	
	declare @templateID varchar(10)		--工作流模板编号
	declare @activity nvarchar(100)		--活动名称
	declare @flowID int					--节点编号
	select @templateID = templateID, @activity = activity, @flowID = flowID 
	from workflowInstanceActivity 
	where instanceID = @instanceID and activityID= @activityID

	--取批复人的姓名：
	declare @approveMan nvarchar(30)
	set @approveMan = isnull((select userCName from activeUsers where userID = @approveManID),'')

	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	begin tran
		insert workflowInstanceFeedBack(templateID, instanceID, activityID, activity, flowID,
					approveTime, approveManID, approveMan, approveStatus, approveOpinion)
		values(@templateID, @instanceID, @activityID, @activity, @flowID,
				@approveTime, @approveManID, @approveMan, @approveStatus, @approveOpinion)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--添加会签意见附件：
		set @count=(select @attachment.exist('/root/attachment'))
		if (@count>0)
		begin
			insert feedBackAttachment(instanceID, activityID, aFilename, uidFilename, fileSize, fileType)
			select @instanceID, @activityID, cast(T.x.query('data(./@aFilename)') as varchar(128)) aFilename,
							cast(T.x.query('data(./@uidFilename)') as varchar(128)) uidFilename,
							cast(cast(T.x.query('data(./@fileSize)') as varchar(12)) as bigint) fileSize,
							cast(T.x.query('data(./@fileType)') as varchar(10)) fileType
					from(select @attachment.query('/root/attachment') Col1) A
						OUTER APPLY A.Col1.nodes('/attachment') AS T(x)	
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '公文会签', '用户' + @approveMan
												+ '给公文['+@instanceID+']签署了一个意见。')

GO

select * from workFlowInstance
select * from workflowInstanceFeedBack
insert feedBackAttachment(instanceID, activityID, aFilename, uidFilename, fileSize, fileType)
values('CG20130354','5570','测试附件1','1XXXXX',123,'.doc')
insert feedBackAttachment(instanceID, activityID, aFilename, uidFilename, fileSize, fileType)
values('CG20130354','5570','测试附件2','2XXXXX',123,'.doc')


select * from taskInfo

drop PROCEDURE delWorkflowInstanceFeedBack
/*
	name:		delWorkflowInstanceFeedBack
	function:	12.删除工作流实例指定活动的会签意见
	input: 
				@instanceID varchar(10),		--主键：实例编号
				@activityID bigint,				--主键：当前活动的标识

				@delManID varchar(10),			--删除人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的工作流实例不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-23
	UpdateDate: 

*/
create PROCEDURE delWorkflowInstanceFeedBack
	@instanceID varchar(10),		--主键：实例编号
	@activityID bigint,				--主键：当前活动的标识

	@delManID varchar(10),			--删除人工号
	
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要添加会签意见的工作流实例和活动是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--删除会签意见：
	delete workflowInstanceFeedBack where instanceID = @instanceID and activityID= @activityID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除会签意见', '用户' + @delManName
												+ '删除了公文['+@instanceID+']活动['+STR(@activityID)+']的会签意见。')
GO

drop PROCEDURE registerFlowActivity
/*
	name:		registerFlowActivity
	function:	15.将实例的表决结果登记到指定的节点的一个活动中，如果该活动没有创建则创建
				注意：这里只创建一个活动，并且可以使前向或后向节点
	input: 
				@instanceID varchar(10),	--实例编号
				@activityID bigint,			--当前活动的标识
				@forwardFlowID int,			--推进到的活动的节点编号
				@receiverID varchar(10),	--接收人ID
				@declareStatus int,			--本活动的表决状态：0->未知，1->同意，2->不同意
	output: 
				@Ret		int output,		--操作成功标识
							0:成功，1：指定的工作流实例或活动不存在，2:本活动的前置节点还没有完全到达，3：本活动不是激活状态，9：未知错误
				@nextActivityID bigint output--登记的节点编号
	author:		卢苇
	CreateDate:	2013-1-23
	UpdateDate: modi by lw 2013-2-25在登记的节点中增加流入活动ID描述，增加登记节点编号的返回值，扩充支持前向或后向节点

*/
create PROCEDURE registerFlowActivity
	@instanceID varchar(10),	--实例编号
	@activityID bigint,			--当前活动的标识
	@forwardFlowID int,			--推进到的活动的节点编号
	@receiverID varchar(10),	--接收人ID
	@declareStatus int,			--本活动的表决状态：0->未知，1->同意，2->不同意
	@Ret		int output,		--操作成功标识
	@nextActivityID bigint output--登记的节点编号
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要推进的工作流实例和活动是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--获取工作流实例活动的基本信息：	
	declare @templateID varchar(10)		--工作流模板编号
	declare @activity nvarchar(100)		--活动名称
	declare @flowID int					--节点编号
	declare @activityStatus int			--活动状态：0->活动开始，但还未全部到达(等待前置节点完成)，
										--	1->前置节点活动全部完成，等待处理，
										--	2->正在处理中
										--	-1->撤销返回上一节点，-2->否决退回上一个节点，
										--	9->完成并转入下一个环节
	declare @senderID varchar(10)	--发送人员工号（指相对下一个节点）
	declare @sender nvarchar(30)	--发送人员姓名（指相对下一个节点）
	select @templateID = templateID, @activity = activity, @flowID = flowID, @activityStatus = activityStatus,
		@senderID = receiverID, @sender = receiver
	from workflowInstanceActivity 
	where instanceID = @instanceID and activityID= @activityID
	--判定活动状态：
	if (@activityStatus=0)
	begin
		set @Ret = 2
		return
	end
	else if (@activityStatus not in(1,2))
	begin
		set @Ret = 3
		return
	end
	
	--取接收人的姓名：
	declare @receiver nvarchar(30)
	set @receiver = isnull((select cName from userInfo where jobNumber = @receiverID),'')

	--检查后置活动是否生成，如果生成就设置状态，否则注入活动
	set @count = isnull((select count(*) from workflowInstanceActivity 
					where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus in (0,1) and receiverID=@receiverID),0)
	if (@count=0)
	begin
		--注入新的活动：
		insert workflowInstanceActivity(instanceID, templateID, flowID, activity, sectionName,
					--活动主体：
					receiverID, receiver,
					--流向说明：
					prevFlowID2Status, 
					nextFlowID,
					--时间控制：
					receiveDate, activityStatus, isExpire, startTimeType, expireDay, usedDay)
		select @instanceID, @templateID, @forwardFlowID, activity, sectionName,
					--活动主体：
					@receiverID, @receiver,
					--流向说明：
					N'<root><flow id="'+LTRIM(str(@flowID,8))+'" aID="'+ltrim(str(@activityID))
						+'" senderID="'+@senderID+'" sender="'+@sender+'" status="'+STR(@declareStatus,1)+'"></flow></root>', 
					forwardFlow,
					--时间控制：
					GETDATE(), 0, isExpire, startTimeType, expireDay, 0
		from workFlowTemplateFlow
		where templateID = @templateID and flowID = @forwardFlowID
	end
	else
	begin
		declare @flowDesc xml
		set @flowDesc = N'<flow id="'+ltrim(str(@flowID,8))+'" aID="'+ltrim(str(@activityID))
						+'" senderID="'+@senderID+'" sender="'+@sender+'" status="'+STR(@declareStatus,1)+'"></flow>'
		update workflowInstanceActivity
		set prevFlowID2Status.modify('
			insert sql:variable("@flowDesc")            
			into (/root[1])')
		where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus in (0,1) and receiverID=@receiverID
	end
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	--获取登记节点的编号：
	set @nextActivityID = (select activityID from workflowInstanceActivity
						   where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus in (0,1) and receiverID=@receiverID)

	--------------------------------以下预处理工作放在高级语言中处理:下面的写法不完整!---------------------------------------
	/*
	--取活动的标识：
	declare @nextActivityID bigint
	set @nextActivityID = (select activityID from workflowInstanceActivity 
							where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus in (0,1) and receiverID=@receiverID)
	
	--后置活动的预处理：
	declare @nextFlowType int	--节点类型：1->单一节点、2->分支节点、汇流节点（3->与汇流、4->或汇流）
	declare @isAutoProcess int	--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	declare @autoProcessCode nvarchar(1000)		--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态
	select @nextFlowType = flowType, @isAutoProcess = isAutoProcess, @autoProcessCode = autoProcessCode
	from workFlowTemplateFlow
	where templateID = @templateID and flowID = @forwardFlowID
	if (@nextFlowType=1) --单一节点
	begin
		update workflowInstanceActivity
		set activityStatus = 1
		where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus = 0 and receiverID=@receiverID
	end
	else if (@nextFlowType=3) --与汇流节点
	begin
		declare @prevFlowID2Status xml	--流入节点编号与状态
		set @prevFlowID2Status = (select prevFlowID2Status from workflowInstanceActivity where activityID = @nextActivityID)
		if (@isAutoProcess=1)
		begin
			if (@autoProcessCode<>'')
			begin
				declare @sql varchar(4000)
				set @sql = @autoProcessCode + ' ' + cast(@prevFlowID2Status as varchar(8000))
				exec @sql
			end
			else	--使用默认方式处理：如果前置节点都已经完成，则自动激活下一个节点
			begin
			end
		end
	end
	else if (@nextFlowType=4) --或汇流节点
	begin
	end
	*/
	--------------------------------------------------------------------------
	set @Ret = 0
GO
--测试：
declare @Ret int, @next bigint
exec dbo.registerFlowActivity 'WF20130220',5777,3,'0000000000',1,@Ret output, @next output
select @Ret, @next

select * from userInfo

select * from workflowInstanceActivity
where instanceID='CG20130025'

delete workflowInstanceActivity
where instanceID='CG20130025' and activityID=59

update workflowInstanceActivity
set activityStatus = 1
where instanceID='CG20130025' and activityID=22


select w.templateID, w.templateName, w.formDBTable, w.formIDMaker,
createFormID, completedFormID, stopFormID,isnull(w.createrID,'') createrID, isnull(w.creater,'') creater, 
convert(varchar(10),w.createTime,120) createTime,isnull(w.modiManID,'') modiManID, isnull(w.modiManName,'') modiManName, 
convert(varchar(10),w.modiTime,120) modiTime 
from workFlowTemplate w 
where w.templateID='WF20130001'



drop PROCEDURE setActivityStatus4Process
/*
	name:		setActivityStatus4Process
	function:	16.设置实例活动状态为“处理中”
	input: 
				@instanceID varchar(10),	--实例编号
				@activityID bigint,			--当前活动的标识
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的工作流实例或活动不存在，
							2：指定的实例活动还没有激活，3.指定的实例活动正在被处理，
							4：指定的实例活动已经停止，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-20
	UpdateDate: modi by lw 2013-2-24将“处理中”状态设定从setActivityStatus过程中分离

*/
create PROCEDURE setActivityStatus4Process
	@instanceID varchar(10),	--实例编号
	@activityID bigint,			--当前活动的标识
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要推进的工作流实例和活动是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--获取工作流实例活动的基本信息：	
	declare @templateID varchar(10)		--工作流模板编号
	declare @activity nvarchar(100)		--活动名称
	declare @flowID int					--节点编号
	declare @curActivityStatus int		--活动的当前状态：0->活动开始，但还未全部到达(等待前置节点完成)，
										--	1->前置节点活动全部完成，等待处理，
										--	2->正在处理中
										--	-1->撤销返回上一节点，-2->否决，
										--	9->完成并转入下一个环节
	select @templateID = templateID, @activity = activity, @flowID = flowID, @curActivityStatus = activityStatus
	from workflowInstanceActivity 
	where instanceID = @instanceID and activityID= @activityID
	--判定活动状态：
	if (@curActivityStatus = 0)
	begin
		set @Ret = 2
		return
	end
	else if (@curActivityStatus = 2)
	begin
		set @Ret = 3
		return
	end
	else if (@curActivityStatus in (-1,-2,9))
	begin
		set @Ret = 4
		return
	end

	update workflowInstanceActivity
	set activityStatus = 1
	where instanceID = @instanceID and activityID=@activityID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0
GO
--测试：
declare @Ret		int 		--操作成功标识
exec dbo.setActivityStatus4Process 'QJ20130083',1,@Ret output
select @Ret 

select * from workflowInstanceActivity

drop PROCEDURE setActivityStatus
/*
	name:		setActivityStatus
	function:	17.设置实例活动状态
	input: 
				@instanceID varchar(10),	--实例编号
				@activityID bigint,			--当前活动的标识
				
				@activityStatus int,		--活动状态：0->活动开始，但还未全部到达(等待前置节点完成)：这个状态不能由本过程设置
													  --1->前置节点活动全部完成，等待处理，
													  --2->正在处理中：这个状态不能由本过程设置
													-- -1->撤销返回上一节点，-2->否决退回上一个节点，
													  --9->完成并转入下一个环节
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的工作流实例或活动不存在，
							2：不能直接设定实例活动为处理状态
							9：未知错误
	author:		卢苇
	CreateDate:	2013-2-20
	UpdateDate: 

*/
create PROCEDURE setActivityStatus
	@instanceID varchar(10),	--实例编号
	@activityID bigint,			--当前活动的标识
	@activityStatus int,		--活动状态
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判定活动状态：
	if (@activityStatus = 2)
	begin
		set @Ret = 2
		return
	end

	--判断要推进的工作流实例和活动是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--获取工作流实例活动的基本信息：	
	declare @templateID varchar(10)		--工作流模板编号
	declare @activity nvarchar(100)		--活动名称
	declare @activityType nvarchar(30)	--活动分类
	declare @activityDesc nvarchar(500)	--活动描述
	declare @flowID int					--节点编号
	declare @sectionName nvarchar(30)	--最新节点所在环节名称
	declare @curActivityStatus int		--活动的当前状态：0->活动开始，但还未全部到达(等待前置节点完成)，
										--	1->前置节点活动全部完成，等待处理，
										--	2->正在处理中
										--	-1->撤销返回上一节点，-2->否决，
										--	9->完成并转入下一个环节
	select @templateID = ia.templateID, @activity = ia.activity, @activityType = wtf.activityType, @activityDesc = wtf.activityDesc,
			@flowID = ia.flowID, @sectionName= ia.sectionName, @curActivityStatus = ia.activityStatus
	from workflowInstanceActivity ia left join workFlowTemplateFlow wtf on ia.templateID = wtf.templateID and ia.flowID = wtf.flowID
	where ia.instanceID = @instanceID and ia.activityID= @activityID

	if (@activityStatus =1)
	begin
		update workflowInstanceActivity
		set activityStatus = @activityStatus 
		where instanceID = @instanceID and activityID=@activityID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end 
		if (@curActivityStatus=0)
		begin
			--维护实例状态：登记最新活动情况:
			update workFlowInstance
			set instanceStatus = 1,				--实例状态：0->创建，1->流转中，9->完成，-1->退回，-2：终止
				statusDesc ='流转中',			--状态说明
				curFlowID =@flowID,				--最新节点编号
				sectionName = @sectionName,		--最新节点所在环节名称
				curActivity =@activity,			--最新活动名称		
				curActivityType =@activityType,	--最新活动分类
				curActivityDesc =@activityDesc	--最新活动描述
			where instanceID = @instanceID 
		end
	end
	else 
		update workflowInstanceActivity
		set activityStatus = @activityStatus, completedDate=GETDATE()
		where instanceID = @instanceID and activityID=@activityID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	--应该还要提供日期计算！
	set @Ret = 0
GO


drop PROCEDURE queryInstanceLocMan
/*
	name:		queryInstanceLocMan
	function:	20.查询指定工作流实例是否有人正在编辑
				备注:公文如果是编辑状态需要锁定工作流实例编辑,公文中现在没有编辑锁!
	input: 
				@instanceID varchar(10),	--实例编号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，9：查询出错，可能是指定的工作流实例不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2003-2-21
	UpdateDate: 
*/
create PROCEDURE queryInstanceLocMan
	@instanceID varchar(10),	--实例编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from workFlowInstance where instanceID= @instanceID),'')
	set @Ret = 0
GO


drop PROCEDURE lockInstance4Edit
/*
	name:		lockInstance4Edit
	function:	21.锁定工作流实例编辑，避免编辑冲突
	input: 
				@instanceID varchar(10),		--实例编号
				@lockManID varchar(10) output,	--锁定人，如果当前工作流实例正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的工作流实例不存在，2:要锁定的工作流实例正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2003-2-21
	UpdateDate: 
*/
create PROCEDURE lockInstance4Edit
	@instanceID varchar(10),		--实例编号
	@lockManID varchar(10) output,	--锁定人，如果当前勤务状态正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的工作流实例是否存在
	declare @count as int
	set @count=(select count(*) from workFlowInstance where instanceID= @instanceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from workFlowInstance where instanceID= @instanceID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update workFlowInstance
	set lockManID = @lockManID 
	where instanceID= @instanceID
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
	values(@lockManID, @lockManName, getdate(), '锁定工作流实例编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了工作流实例['+@instanceID+']为独占式编辑。')
GO

drop PROCEDURE unlockInstanceEditor
/*
	name:		unlockInstanceEditor
	function:	22.释放工作流实例编辑锁
				注意：本过程不检查工作流实例是否存在！
	input: 
				@instanceID varchar(10),		--实例编号
				@lockManID varchar(10) output,	--锁定人，如果当前工作流实例正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2003-2-21
	UpdateDate: 
*/
create PROCEDURE unlockInstanceEditor
	@instanceID varchar(10),		--实例编号
	@lockManID varchar(10) output,	--锁定人，如果当前工作流实例正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from workFlowInstance where instanceID= @instanceID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update workFlowInstance set lockManID = '' where instanceID= @instanceID
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
	values(@lockManID, @lockManName, getdate(), '释放工作流实例编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了工作流实例['+ @instanceID +']的编辑锁。')
GO


drop PROCEDURE setInstanceStatus
/*
	name:		setInstanceStatus
	function:	25.设置实例状态
	input: 
				@instanceID varchar(10),	--实例编号
				
				@instanceStatus int,		--实例状态：0->创建，1->流转中，9->完成，-1->退回，-2：终止
	output: 
				@Ret		int output				--操作成功标识
							0:成功，1：指定的工作流实例不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-24
	UpdateDate: 

*/
create PROCEDURE setInstanceStatus
	@instanceID varchar(10),	--实例编号
	@instanceStatus int,		--实例状态：0->创建，1->流转中，9->完成，-1->退回，-2：终止
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要推进的工作流实例是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	update workflowInstance
	set instanceStatus = @instanceStatus
	where instanceID = @instanceID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0
GO

select * from workflowInstance where left(instanceID,2)='QJ'
DELETE workflowInstance where instanceID<>'QJ20130323'

drop PROCEDURE setInstanceCompletedInfo
/*
	name:		setInstanceCompletedInfo
	function:	26.设置实例的完成情况
	input: 
				@instanceID varchar(10),	--实例编号
				
				@completedStatus int,		--完成结果状态：0->未知，1->同意，2->不同意
				@completedInfo nvarchar(300),--完成情况描述
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的工作流实例不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-2-25
	UpdateDate: 

*/
create PROCEDURE setInstanceCompletedInfo
	@instanceID varchar(10),	--实例编号
	@completedStatus int,		--完成结果状态：0->未知，1->同意，2->不同意
	@completedInfo nvarchar(300),--完成情况描述
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要推进的工作流实例是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	update workflowInstance
	set instanceStatus = 9,
		statusDesc = '完成',	--状态说明
		completedStatus = @completedStatus,
		completedInfo = @completedInfo,
		--清除最新活动情况:
		curFlowID = null,		--最新节点编号
		sectionName = '',		--最新节点所在环节名称
		curActivity = '',		--最新活动名称		
		curActivityType = '',	--最新活动分类
		curActivityDesc = ''	--最新活动描述
	where instanceID = @instanceID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0
GO

drop PROCEDURE stopInstanceActivity
/*
	name:		stopInstanceActivity
	function:	27.终止指定的实例活动
	input: 
				@instanceID varchar(10),		--实例编号
				
				@stopManID varchar(10) output,	--终止人，如果当前工作流实例被锁定编辑则返回锁定人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的工作流实例不存在，
							2：指定的实例正被被人调度处理，
							3：指定的实例正被别人锁定编辑，
							4：指定的实例已经审批完成
							9：未知错误
	author:		卢苇
	CreateDate:	2013-3-2
	UpdateDate: 

*/
create PROCEDURE stopInstanceActivity
	@instanceID varchar(10),	--实例编号
	@stopManID varchar(10) output,	--终止人，如果当前工作流实例被锁定编辑则返回锁定人工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断实例是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查实例是否有正在调度处理的活动：
	set @count = (select count(*) from workflowInstanceActivity 
					where instanceID=@instanceID and activityStatus = 2 and receiverID<>@stopManID)
	if (@count > 0)	--存在
	begin
		set @Ret = 2
		return
	end
	
	--检查编辑锁和状态：
	declare @lockManID varchar(10)		--当前正在锁定编辑的人工号
	declare @instanceStatus smallint	--实例状态：0->创建，1->流转中，9->完成，-1->退回，-2：终止
	select @lockManID = lockManID, @instanceStatus = instanceStatus
	from workFlowInstance
	where instanceID = @instanceID
	--判断状态：
	if (@instanceStatus = 9)	
	begin
		set @Ret = 4
		return
	end
	else if (isnull(@lockManID,'')<>'' and @lockManID<>@stopManID)
	begin
		set @Ret = 3
		set @stopManID =@lockManID
		return
	end

	begin tran
		--设置实例所有的活动状态为“终止”
		update workflowInstanceActivity 
		set activityStatus = 10
		where instanceID = @instanceID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		
		update workflowInstance
		set instanceStatus = -2,
			statusDesc = '终止',	--状态说明
			completedStatus = 2,	--完成情况：完成结果状态
			completedInfo = '终止',	--完成情况：完成情况描述
			--清除最新活动情况:
			curFlowID = null,		--最新节点编号
			sectionName = '',		--最新节点所在环节名称
			curActivity = '',		--最新活动名称		
			curActivityType = '',	--最新活动分类
			curActivityDesc = ''	--最新活动描述
		where instanceID = @instanceID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	
	set @Ret = 0

	--取维护人的姓名：
	declare @stopMan nvarchar(30)
	set @stopMan = isnull((select userCName from activeUsers where userID = @stopManID),'')
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopMan, getdate(), '终止工作流实例', '用户' + @stopMan
												+ '终止了工作流实例['+@instanceID+']。')
GO

drop PROCEDURE stopInstance
/*
	name:		stopInstance
	function:	28.终止实例
	input: 
				@instanceID varchar(10),		--实例编号
				
				@stopManID varchar(10) output,	--终止人，如果当前工作流实例被锁定编辑则返回锁定人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的工作流实例不存在，
							2：指定的实例正被被人调度处理，
							3：指定的实例正被别人锁定编辑，
							4：指定的实例已经审批完成
							9：未知错误
	author:		卢苇
	CreateDate:	2013-3-2
	UpdateDate: 

*/
create PROCEDURE stopInstance
	@instanceID varchar(10),	--实例编号
	@stopManID varchar(10) output,	--终止人，如果当前工作流实例被锁定编辑则返回锁定人工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断实例是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查实例是否有正在调度处理的活动：
	set @count = (select count(*) from workflowInstanceActivity 
					where instanceID=@instanceID and activityStatus = 2 and receiverID<>@stopManID)
	if (@count > 0)	--存在
	begin
		set @Ret = 2
		return
	end
	
	--检查编辑锁和状态：
	declare @lockManID varchar(10)		--当前正在锁定编辑的人工号
	declare @instanceStatus smallint	--实例状态：0->创建，1->流转中，9->完成，-1->退回，-2：终止
	select @lockManID = lockManID, @instanceStatus = instanceStatus
	from workFlowInstance
	where instanceID = @instanceID
	--判断状态：
	if (@instanceStatus = 9)	
	begin
		set @Ret = 4
		return
	end
	else if (isnull(@lockManID,'')<>'' and @lockManID<>@stopManID)
	begin
		set @Ret = 3
		set @stopManID =@lockManID
		return
	end

	begin tran
		--设置实例所有的活动状态为“终止”
		update workflowInstanceActivity 
		set activityStatus = 10
		where instanceID = @instanceID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		
		update workflowInstance
		set instanceStatus = -2,
			statusDesc = '终止',	--状态说明
			completedStatus = 2,	--完成情况：完成结果状态
			completedInfo = '终止',	--完成情况：完成情况描述
			--清除最新活动情况:
			curFlowID = null,		--最新节点编号
			sectionName = '',		--最新节点所在环节名称
			curActivity = '',		--最新活动名称		
			curActivityType = '',	--最新活动分类
			curActivityDesc = ''	--最新活动描述
		where instanceID = @instanceID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	
	set @Ret = 0

	--取维护人的姓名：
	declare @stopMan nvarchar(30)
	set @stopMan = isnull((select userCName from activeUsers where userID = @stopManID),'')
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopMan, getdate(), '终止工作流实例', '用户' + @stopMan
												+ '终止了工作流实例['+@instanceID+']。')
GO

drop PROCEDURE delInstance
/*
	name:		delInstance
	function:	29.删除指定的实例
	input: 
				@instanceID varchar(10),		--实例编号
				@delManID varchar(10) output,	--删除人，如果当前工作流实例被锁定编辑则返回锁定人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的实例不存在，
							2：该实例正被锁定编辑，不能删除
							--3：该实例流转中，不能删除，
							3：该实例已经审批或审批中，不能删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-3-2
	UpdateDate: 

*/
create PROCEDURE delInstance
	@instanceID varchar(10),	--实例编号
	@delManID varchar(10) output,--删除人，如果当前工作流实例被锁定编辑则返回锁定人工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断实例是否存在
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁和状态：
	declare @lockManID varchar(10)		--当前正在锁定编辑的人工号
	declare @instanceStatus smallint	--实例状态：0->创建，1->流转中，9->完成，-1->退回，-2：终止
	declare @curFlowID int 				--最新节点编号
	select @lockManID = lockManID, @instanceStatus = instanceStatus, @curFlowID = curFlowID
	from workFlowInstance
	where instanceID= @instanceID
	--判断状态：
	--if (@instanceStatus not in (0,-1,-2))	--允许删除退回或终止的实例
	if (@instanceStatus =9 or (@instanceStatus=1 and @curFlowID>1))	--只允许删除未发送的实例
	begin
		set @Ret = 3
		return
	end
	else if (isnull(@lockManID,'')<>'' and @lockManID<>@delManID)
	begin
		set @Ret = 2
		set @delManID =@lockManID
		return
	end

	delete workFlowInstance where instanceID= @instanceID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除工作流实例', '用户' + @delManName
												+ '删除了工作流实例['+@instanceID+']。')

GO
--测试：
declare	@Ret		int --操作成功标识
exec dbo.delInstance 'QJ20130452','G201300001',@Ret output
select @Ret


select * from userInfo




use hustOA
select * from workflowInstance
where instanceID='QJ20130452'

select * from workflowInstanceActivity
where instanceID='QJ20130452'

select * from eqpApplyInfo
where eqpApplyID='CG20130215'

select * from workFlowInstance
select * from userInfo

select * from useUnit

delete workflowInstanceActivity
delete workFlowInstance

select templateID, instanceID, activityID, activity, flowID,
	approveTime, approveManID, approveMan, approveStatus, approveOpinion, attachment
from workflowInstanceFeedBack
	

select * from college