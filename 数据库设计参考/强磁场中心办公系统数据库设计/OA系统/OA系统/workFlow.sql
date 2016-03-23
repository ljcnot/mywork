use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�������������
	author:		¬έ
	CreateDate:	2013-1-20
	UpdateDate: 
*/

--1.������ģ���
select w.templateID, w.templateName, w.formDBTable, w.formIDMaker,
	--�����ˣ�
	isnull(w.createrID,'') createrID, isnull(w.creater,'') creater, convert(varchar(10),w.createTime,120) createTime,
	--����ά�����:
	isnull(w.modiManID,'') modiManID, isnull(w.modiManName,'') modiManName, convert(varchar(10),w.modiTime,120) modiTime
from workFlowTemplate w

	--add by lw 2013-7-15
alter TABLE workFlowTemplate add	templateLogo varchar(128) null		--ģ������ͼƬ
alter TABLE workFlowTemplate add	templateIntroImage varchar(128) null--ģ�����ͼƬ

drop table workFlowTemplate
CREATE TABLE workFlowTemplate(
	templateID varchar(10) not null,	--������������ģ����,��ϵͳʹ�õ� �ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�,��ʱ���ֹ�ά��
	templateName nvarchar(60) null,		--ģ������
	formDBTable varchar(30) null,		--�����ݿ����
	formIDMaker int null,				--�ĵ����뷢�������:��ֹ��ʹ��form�����еĺ��뷢���� del by lw 2014-1-1
	
	createFormID varchar(10) null,		--������ģ��ʹ�õĴ����ĵ��ı�ID
	completedFormID varchar(10) null,	--������ģ��ʹ�õ�����ĵ�����ʾ��ID
	stopFormID varchar(10) null,		--������ģ��ʹ�õ���ֹ�ĵ�����ʾ��ID
	showFormID varchar(10) null,		--������ģ��ʹ�õ�ͨ�õ��ĵ�����ʾ��ID	--add by lw 2013-2-26

	--����ģ��ʹ�������ƣ�add by lw 2013-2-20
	templateRole xml null,				--����ģ��ʹ���˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
	--add by lw 2013-7-15
	templateLogo varchar(128) null,		--ģ������ͼƬ
	templateIntroImage varchar(128) null,--ģ�����ͼƬ
	

	--�����ˣ�
	createrID varchar(10) null,			--�����˹���
	creater nvarchar(30) null,			--����������
	createTime smalldatetime default(getdate()),--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_workFlowTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.������ģ�幫�����ݿ��ֶζ����add by lw 2013-07-15
drop table workFlowTemplateDBDesign
CREATE TABLE workFlowTemplateDBDesign(
	templateID varchar(10) not null,	--����/�����������ģ����
	fieldName varchar(30) not null,		--�ֶ�����
	fieldDesc nvarchar(30) null,		--�ֶ�����
	fieldDefine varchar(128) not null,	--���ݿ��ֶζ�������������"varchar(30) not null"��ʽ����
 CONSTRAINT [PK_workFlowTemplateDBDesign] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[workFlowTemplateDBDesign] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplate_workFlowTemplateDBDesign] FOREIGN KEY([templateID])
REFERENCES [dbo].[workFlowTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateDBDesign] CHECK CONSTRAINT [FK_workFlowTemplate_workFlowTemplateDBDesign] 
GO

select * from workFlowTemplateForms
--3.������ģ��������һ��������ģ����������
drop table workFlowTemplateForms
CREATE TABLE workFlowTemplateForms(
	templateID varchar(10) not null,	--����/�����������ģ����
	formID varchar(10) not null,		--������������ģ��ʹ�õ��ı�ID,��ϵͳʹ�õ� �ź��뷢����������'FM'+4λ��ݴ���+4λ��ˮ�ţ�
	formType smallint not null,			--�ڵ�ʹ�ñ����ͣ�0->��ʾ��1->�༭
	formName nvarchar(30) null,			--������
	formPageFile varchar(128) not null,	--����̬ҳ��ҳ��·����������Ϊ���ݱ��Ĳ������ݿⶨ�����ɵľ�̬ҳ�棩
	
	/*
		��չ����Ӧ�ð���ҳ����ʹ�õĿؼ����ͣ����ַ�ʽ���������ƣ���Ӧ�����ݿ��ֶΣ���֤�õ�������ʽ��
	*/
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_workFlowTemplateForms] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[workFlowTemplateForms] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[workFlowTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateForms] CHECK CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplate] 
GO

--3.1.������ģ������ֶ����:add by lw 2013-07-15
drop table workFlowTemplateFormDesign
CREATE TABLE workFlowTemplateFormDesign(
	templateID varchar(10) not null,	--����/�����������ģ����
	formID varchar(10) not null,		--����/�����������ģ��ʹ�õ��ı�ID
	controlType int not null,			--�ؼ�����
	controlTypeName nvarchar(30) not null,--������ƣ��ؼ���������
	controlName nvarchar(30) not null,	--�ؼ�����
	controlTop int not null,			--�ؼ�����top����
	controlLeft int not null,			--�ؼ�����Left����
	controlWidth int not null,			--�ؼ����ֿ��
	controlHeight int not null,			--�ؼ����ָ߶�
	controlZindex int not null,			--�ؼ����ֲ��
	controlDBField varchar(60) null,	--�ؼ���Ӧ�������ֶ���
 CONSTRAINT [PK_workFlowTemplateFormDesign] PRIMARY KEY CLUSTERED 
(
	[formID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[workFlowTemplateFormDesign] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplateFormDesign] FOREIGN KEY([templateID],[formID])
REFERENCES [dbo].[workFlowTemplateForms] ([templateID],[formID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateFormDesign] CHECK CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplateFormDesign] 
GO

--3.2.���ؼ��ǼǱ�ֶ����:add by lw 2013-07-15
drop table formCtrol
CREATE TABLE formCtrol(
	controlType int not null,			--�ؼ�����
	controlTypeName nvarchar(30) not null,--������ƣ��ؼ���������
	defaultWidth int not null,			--�ؼ����ֿ��
	defaultHeight int not null,			--�ؼ����ָ߶�
 CONSTRAINT [PK_formCtrol] PRIMARY KEY CLUSTERED 
(
	[controlType] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--4.��������ɫ��������Ҫͬϵͳ���û�����ɫ������ͨ����������Զ�������Ա��Χ�����Ƕ�ϵͳ��ɫ�Ĳ��䣡�ص���ǿ����Ա֮��Ĺ�ϵ����������
drop table workFlowRole
CREATE TABLE workFlowRole(
	roleID int not null,			--��������ɫID
	roleName nvarchar(30) not null,	--��ɫ����
	roleDesc nvarchar(100) null,	--��ɫ����
 CONSTRAINT [PK_workFlowRole] PRIMARY KEY CLUSTERED 
(
	[roleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select * from workFlowRole
select * from workFlowTemplateFlow
delete workFlowTemplateFlow where templateID='WF20130002'
--5.������ģ��ڵ㣨ģ���������
drop table workFlowTemplateFlow
CREATE TABLE workFlowTemplateFlow(
	templateID varchar(10) not null,	--����/�����������ģ����,��ϵͳʹ�õ� �ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
	flowID int not null,				--���������̽ڵ���
	flowType int not null,				--�ڵ����ͣ�1->�����ڵ㣨�ýڵ�������δ���ã�modi by lw 2013-3-3����һ�ڵ㡢���������������Է������롢���������ж��壡
												--	2->�м�ڵ�
												--	9->�����ڵ�
										--�ƻ����ཫ�м�ڵ��뿪ʼ�������ڵ���룬��������������Ϊ�ڵ���������ԣ���֧���ַ�����һ������Ϊ�ڵ����������
	flowEditAttri int not null,			--�ڵ�༭���ԣ�0->������������ڵ㣬���༭���ģ�1->�༭��ڵ㣬���ڵ�༭���ģ���Ҫ�����༭���� --add by lw 2013-2-21
	sectionName nvarchar(30) null,		--���ڻ������ƣ���Ҫ������������Ļ���
	--�����ʽ��add by lw 2013-3-3
	voteType smallint default(0),		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult smallint default(0),		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName nvarchar(10) null,	--ͬ������ť����
	vetoButtonName nvarchar(10) null,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole xml null,					--�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc smallint default(0),	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity nvarchar(100) not null,	--�����		
	activityType nvarchar(30) null,		--�����	�ƻ�ɾ������ڵ����ڻ������ظ���
	activityDesc nvarchar(500) null,	--�����
	activityFormID varchar(10) null,	--����ʹ�õ�form��ID
	activityFormType smallint null,		--����ʹ�õ�form�����ͣ�0->��ʾ��1->�༭ �ƻ�ɾ������ڵ�༭�������ظ���
	activityShowFormID varchar(10) null,--�ڱ��ڵ��ϲ鿴��Ϣʹ�õ�form��ID
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib	varchar(128) null,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ�����
	applicationCode	nvarchar(1000) null,--�ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow xml null,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType smallint default(1),		--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition nvarchar(100) null,	--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess int default(0),		--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType int default(0),		--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode nvarchar(1000) null,--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow xml null,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode smallint default(0),	--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode smallint default(0),	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition nvarchar(100) null,	--ת��������������δʹ�ã���
	userSelectReceiver smallint default(0),	--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver smallint default(0),	--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName nvarchar(10) null,--ǰ����ť����
				--������ƣ�
	negationEnable smallint default(1),	--�Ƿ�������:0->������1->����
	negationFlow xml null,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode smallint default(0),	--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode smallint default(0),	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver smallint default(0),	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver smallint default(0),	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName nvarchar(10) null,--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable smallint default(0),	--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable smallint default(1),	--�Ƿ��������:0->������1->����
	backwardButtonName nvarchar(10) null,--���˰�ť����
	postbackEnable smallint default(1),	--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable smallint default(0),		--�Ƿ�������ֹ����:0->������1->����
	stopFlow xml null,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable smallint default(0),	--�Ƿ�������������:0->������1->����
	subFlowTemplateID varchar(10) not null,	--�����̹�����ģ����
	subFlowBtnName varchar(10) not null,--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow smallint default(1),	--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult smallint default(0),	--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted smallint default(0),--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow xml null,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack smallint default(0),		--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc nvarchar(30) null,	--ǩ������˳�ν
	
	--ʱ����ƣ�
	isExpire smallint null,				--�Ƿ��ڿ���:0->�����ƣ�1->���Ƴ���
	startTimeType varchar(30) default('lastNodeCompleted'),--����ʱ������:'startTime'�����̿�ʼʱ�䣬
																		--'lastNodeCompleted'->��һ�ڵ�������ڣ�
																		--��������
	dayType smallint default(0),		--ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
	expireDay	int null				--�ڵ���������
 CONSTRAINT [PK_workFlowTemplateFlow] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[flowID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[workFlowTemplateFlow] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateFlow_workFlowTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[workFlowTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateFlow] CHECK CONSTRAINT [FK_workFlowTemplateFlow_workFlowTemplate]
GO


select i.instanceID, i.instanceStatus, i.templateID, i.templateName, i.topic,
	--���ȣ�
	i.curFlowID, i.sectionName, i.curActivity, i.curActivityType, i.curActivityDesc,
	i.extendedDay, i.isCompleted,
	--�����ˣ�
	i.createrID, i.creater, CONVERT(varchar(10),i.createTime,120) createTime
from WorkflowInstance i

--10.������ʵ����
select * from workFlowInstance
delete workFlowInstance
drop table workFlowInstance
CREATE TABLE workFlowInstance(
	instanceID varchar(10) not null,	--������ʵ�����,ʹ��ģ���ж���ĺ��뷢�������ɵı��
	buildDate smalldatetime default(getdate()),--ʵ������ʱ��
	instanceStatus int default(0),		--ʵ��״̬��0->������1->��ת�У�9->��ɣ�-1->�˻أ�-2����ֹ
	statusDesc nvarchar(500) null,		--״̬˵��
	isSubInstance smallint default(0),	--�Ƿ�Ϊ������ʵ��:0->����,1->�� add by lw 2013-3-3
	parentInstanceID varchar(10) null,	--��ʵ�����,ʹ��ģ���ж���ĺ��뷢�������ɵı�� add by lw 2013-3-3
	
	templateID varchar(10) not null,	--������ģ����
	templateName nvarchar(60) null,		--ģ������
	topic nvarchar(100) null,			--ʵ�����ݼ���
	
	--���»���:
	curFlowID int null,					--���½ڵ���
	sectionName nvarchar(30) null,		--���½ڵ����ڻ�������
	curActivity nvarchar(100) not null,	--���»����		
	curActivityType nvarchar(30) null,	--���»����
	curActivityDesc nvarchar(500) null,	--���»����
	extendedDay int null,				--�ڵ㳬������
	
	--��������add by lw 2013-2-25
	completedStatus int default(0),		--��ɽ��״̬��0->δ֪��1->ͬ�⣬2->��ͬ��
	completedInfo nvarchar(300) null,	--����������
	
	--�����ˣ�
	createrID varchar(10) null,			--�����˹���
	creater nvarchar(30) null,			--����������
	createTime smalldatetime default(getdate()),--����ʱ��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_workFlowInstance] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--ģ����������
CREATE NONCLUSTERED INDEX [IX_workFlowInstance] ON [dbo].[workFlowInstance] 
(
	[templateID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--������������
CREATE NONCLUSTERED INDEX [IX_workFlowInstance_1] ON [dbo].[workFlowInstance] 
(
	[createrID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--11.������ʵ��������Ļ����ʹ���Ա��
select activityID, instanceID, templateID, flowID, activity, sectionName,
	--����壺
	receiverID, receiver,
	--������ƣ�
	prevFlowID2Status, nextFlowID,
	--ʱ����ƣ�
	receiveDate, completedDate, activityStatus, isExpire, startTimeType, expireDay, usedDay
from workflowInstanceActivity
where instanceID='WF20130055'

drop table workflowInstanceActivity
CREATE TABLE workflowInstanceActivity(
	activityID bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--��������ǰ��ı�ʶ��ÿ�������������һ���µ�ID��
																	--��ν���ͬһ������������Ķ��������
	instanceID varchar(10) not null,	--�����ʵ�����
	templateID varchar(10) not null,	--������ģ���ţ��������
	flowID int not null,				--�ڵ���
	activity nvarchar(100) not null,	--�����		
	sectionName nvarchar(30) null,		--����ڻ������ƣ��������
	--����壺
	receiverID varchar(10) not null,	--�ʹ���Ա����
	receiver nvarchar(30) not null,		--�ʹ���Ա����
	--����˵����
	prevFlowID2Status xml null,			--����ʵ�����������״̬:
										--����N'<root><flow id="2" aid="120" senderID="G201300001" sender="��Զ" status="1"></flow></root>'��ʽ���
	nextFlowID xml null,				--�����ڵ���
	--�����̿��ƣ�
	startSubFlow smallint default(0),	--�Ƿ����������̣�0->δ������1->���� add by lw 2013-3-3
	subInstanceID varchar(10) null,		--��ʵ�����,ʹ��ģ���ж���ĺ��뷢�������ɵı�� add by lw 2013-3-3
	--ʱ����ƣ�
	receiveDate smalldatetime null,		--�ʹ�����
	completedDate smalldatetime null,	--��������
	activityStatus int default(0),		--�״̬��0->���ʼ������δȫ������(�ȴ�ǰ�ýڵ����)��
												--	1->ǰ�ýڵ�ȫ����ɣ��ȴ�����
												--	2->���ڴ�����
												--	-1->����������һ�ڵ㣬-2->����˻���һ���ڵ㣬
												--	9->��ɲ�ת����һ������
												--	10->�����ֹ
	isExpire smallint null,				--�Ƿ��ڿ���:0->�����ƣ�1->���Ƴ���
	startTimeType varchar(30) default('lastNodeCompleted'),--����ʱ������:'startTime'�����̿�ʼʱ�䣬
																		--'lastNodeCompleted'->��һ�ڵ�������ڣ�
																		--��������
	expireDay int,						--���������
	usedDay int							--�ʵ����ʱ

 CONSTRAINT [PK_WorkflowInstanceActivity] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC,
	[activityID] ASC,
	[receiverID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[workflowInstanceActivity] WITH CHECK ADD CONSTRAINT [FK_WorkflowInstanceActivity_WorkflowInstance] FOREIGN KEY([instanceID])
REFERENCES [dbo].[WorkflowInstance] ([instanceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workflowInstanceActivity] CHECK CONSTRAINT [FK_WorkflowInstanceActivity_WorkflowInstance] 
GO

--������
--ģ����������
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceActivity] ON [dbo].[workflowInstanceActivity] 
(
	[templateID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from workflowInstanceFeedBack
--12.������ת���ǩ���
delete workflowInstanceFeedBack
alter table workflowInstanceFeedBack drop column attachment
alter table workflowInstanceFeedBack drop column attachmentFilename
drop table workflowInstanceFeedBack
CREATE TABLE workflowInstanceFeedBack(
	templateID varchar(10) not null,			--������ģ���ţ��������
	instanceID varchar(10) not null,			--������ʵ�����
	activityID bigint,							--��������ǰ��ı�ʶ
	activity nvarchar(100) not null,			--����ƣ��������
	flowID int not null,						--�ڵ���

	approveTime smalldatetime null,				--��׼ʱ��
	approveManID varchar(10) null,				--��׼�˹���
	approveMan nvarchar(30) null,				--��׼���������������
	approveStatus smallint null,				--����������ͣ�0->δ֪��1->��׼��-1->����׼
	approveOpinion nvarchar(500) null,			--�������
	--attachment varchar(128) null,				--�����ļ��� del by lw 2013-6-21
	--attachmentFilename varchar(128) null		--������ԭʼ�ļ��� add by lw 2013-2-26 del by lw 2013-6-21
 CONSTRAINT [PK_WorkflowInstanceFeedBack] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC,
	[activityID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[workflowInstanceFeedBack] WITH CHECK ADD CONSTRAINT [FK_WorkflowInstanceFeedBack_WorkflowInstance] FOREIGN KEY([instanceID])
REFERENCES [dbo].[WorkflowInstance] ([instanceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workflowInstanceFeedBack] CHECK CONSTRAINT [FK_WorkflowInstanceFeedBack_WorkflowInstance] 
GO

--������
--ģ����������
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceFeedBack] ON [dbo].[workflowInstanceFeedBack] 
(
	[templateID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��׼��������
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceFeedBack_1] ON [dbo].[workflowInstanceFeedBack] 
(
	[approveManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--ģ��ڵ�������
CREATE NONCLUSTERED INDEX [IX_WorkflowInstanceFeedBack_2] ON [dbo].[workflowInstanceFeedBack] 
(
	[templateID] ASC,
	[flowID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--13.������ת���ǩ�𸽼��⣺֧�ֶ������ add by lw 2013-6-21
select *, aFilename, uidFilename, fileSize, fileType, convert(varchar(19), uploadTime, 120) uploadTime
from feedBackAttachment
drop TABLE feedBackAttachment
CREATE TABLE feedBackAttachment(
	instanceID varchar(10) not null,			--����/�����ʵ�����
	activityID bigint,							--����/�������ǰ��ı�ʶ
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,	--�������к�
	
	aFilename varchar(128) null,					--ԭʼ�ļ���
	uidFilename varchar(128) not null,				--UID�ļ���
	fileSize bigint null,							--�ļ��ߴ�
	fileType varchar(10),							--�ļ�����
	uploadTime smalldatetime default(getdate()),	--�ϴ�����
 CONSTRAINT [PK_feedBackAttachment] PRIMARY KEY CLUSTERED 
(
	[instanceID] ASC,
	[activityID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[feedBackAttachment] WITH CHECK ADD CONSTRAINT [FK_WorkflowInstanceFeedBack_feedBackAttachment] FOREIGN KEY([instanceID],[activityID])
REFERENCES [dbo].[WorkflowInstanceFeedBack] ([instanceID],[activityID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[feedBackAttachment] CHECK CONSTRAINT [FK_WorkflowInstanceFeedBack_feedBackAttachment]
GO

--������
--ԭʼ�ļ���������
CREATE NONCLUSTERED INDEX [IX_feedBackAttachment] ON [dbo].[feedBackAttachment]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�ļ�����������
CREATE NONCLUSTERED INDEX [IX_feedBackAttachment_1] ON [dbo].[feedBackAttachment]
(
	[fileType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select templateID, flowID, flowType, sectionName, formID,
	--�ڵ���������ƣ�
	flowRole,					--�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, applicationLib, applicationCode,
	--������ƣ�
	prevFlow, nextFlow, inCondition, outCondition, isFeedBack, feedBackManDesc,
	--ʱ����ƣ�
	IsExpire, startTimeType, ExpireDay
from workFlowTemplateFlow
--��ȡָ��������ģ���е�ָ����Ľ�ɫ���ƣ�
SELECT flowRole.query('data(/root/role/@id)'), flowRole.query('data(/root/role/@desc)') from workFlowTemplateFlow

drop FUNCTION canUseThisWorkFlowTemplate
/*
	name:		canUseThisWorkFlowTemplate
	function:	0.�ж�ָ�����û��ܷ�ʹ��ָ���Ĺ�����ģ��
	input: 
				@templateID varchar(10),	--������ģ����
				@userID varchar(10)			--�û�����
	output: 
				return char(1)	--�ܷ�ʹ�ã���Y��->��ʹ�ã���N��->����ʹ��
	author:		¬έ
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION canUseThisWorkFlowTemplate
(  
	@templateID varchar(10),	--������ģ����
	@userID varchar(10)			--�û�����
)  
RETURNS char(1)
WITH ENCRYPTION
AS      
begin
	--���ģ���Ƿ���ڣ�
	declare @count int
	set @count = ISNULL((select count(*) from workFlowTemplate where templateID = @templateID),0)
	if (@count=0)
	begin
		return 'N'
	end
	
	--�ж��Ƿ��н�ɫ���ƣ�
	declare @templateRole xml			--����ģ��ʹ���˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
	select @templateRole = templateRole
	from workFlowTemplate
	where templateID = @templateID
	if (@templateRole is null)	--û�н�ɫ���ƣ�����ȫ����Ա
	begin
		return 'Y'
	end
	
	--��ȡָ��������ģ��Ľ�ɫ���ƣ�
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--�Ƿ�ȫ��Ϊ��
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
			if (@roleID = 1)			--�����쵼����ְ��:��������쵼��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from college where clgCode='001'
			end
			else if (@roleID = 2)		--�����쵼����ְ��:���������쵼��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select deputyManID, deputyMan from college where clgCode='001'
			end
			else if (@roleID = 10)		--����:�������쵼����ָ��������������Ա
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
			end
			else if (@roleID = 20)		--�̹�:��ָȫ��̹�
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1
			end
			else if (@roleID = 30)		--��ʦ:��ָȫ����о����ĵ�ʦ
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and jobNumber in (select tutorID from userInfo where manType=9) 
			end
			else if (@roleID = 40)		--ѧ��:��ָȫ��ѧ��
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9
			end
			else if (@roleID = 100)		--ȫ����Ա
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo where isOff = 0
			end
			FETCH NEXT FROM tar INTO @roleID, @roleDesc
		end
		CLOSE tar
		DEALLOCATE tar
	end
	
	--���ϵͳ��ɫ������û���
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
	--���ֱ�Ӷ�����û���
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
		--������Ա��
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
--���ԣ�
select dbo.canUseThisWorkFlowTemplate('WF20130001','G201300004')
--��ѯָ���û���ʹ�õ�ģ�壺
select * from workFlowTemplate where dbo.canUseThisWorkFlowTemplate(templateID,'G201300006')='Y'

select * from workFlowTemplate
declare @templateRole xml
update workFlowTemplate
set templateRole = N'<root>'+
						--'<user userID="G201300001" userCName="��Զ" />'+
						--'<user userID="G201300003" userCName="���" />'+
						'<role id="20" desc="�̹�" />'+
					'</root>'
where templateID='WF20130002'

select * from userInfo

drop PROCEDURE getWorkFlowTemplateEnableMan
/*
	name:		getWorkFlowTemplateEnableMan
	function:	1.��ѯ������ģ���ܹ�ʹ����Ա�б�
				ע��:��������ɫ���еĽ�ɫ����ȫ���ܹ����붨��ģ���Ա֮�����Թ�ϵ�Ľ�ɫ���ܼ���ģ��ʹ��������
	input: 
				@templateID varchar(10),	--������ģ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ��ѯ�Ĺ�����ģ�岻���ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-20
	UpdateDate: 
*/
create PROCEDURE getWorkFlowTemplateEnableMan
	@templateID varchar(10),	--������ģ����
	@Ret int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ģ���Ƿ���ڣ�
	declare @count int
	set @count = ISNULL((select count(*) from workFlowTemplate where templateID = @templateID),0)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	
	--�ж��Ƿ��н�ɫ���ƣ�
	declare @templateRole xml			--����ģ��ʹ���˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
	select @templateRole = templateRole
	from workFlowTemplate
	where templateID = @templateID
	if (@templateRole is null)	--û�н�ɫ���ƣ�����ȫ����Ա
	begin
		set @Ret = 0
		select jobNumber, cName from userInfo where isOff = 0 order by cName
		return
	end
	
	--��ȡָ��������ģ��Ľ�ɫ���ƣ�
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--�Ƿ�ȫ��Ϊ��
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
			if (@roleID = 1)			--�����쵼����ְ��:��������쵼��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from college where clgCode='001'
			end
			else if (@roleID = 2)		--�����쵼����ְ��:���������쵼��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select deputyManID, deputyMan from college where clgCode='001'
			end
			else if (@roleID = 10)		--����:�������쵼����ָ��������������Ա
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
			end
			else if (@roleID = 20)		--�̹�:��ָȫ��̹�
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1
			end
			else if (@roleID = 30)		--��ʦ:��ָȫ����о����ĵ�ʦ
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and jobNumber in (select tutorID from userInfo where manType=9) 
			end
			else if (@roleID = 40)		--ѧ��:��ָȫ��ѧ��
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9
			end
			else if (@roleID = 100)		--ȫ����Ա
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo where isOff = 0
			end
			FETCH NEXT FROM tar INTO @roleID, @roleDesc
		end
		CLOSE tar
		DEALLOCATE tar
	end
	
	--���ϵͳ��ɫ������û���
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

	--���ֱ�Ӷ�����û���
	set @count=(select @templateRole.exist('/root/user'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		SELECT cast(A.col1.query('data(./@userID)') as varchar(10)),cast(A.col1.query('data(./@userCName)') as nvarchar(30))
		from @templateRole.nodes('/root/user') as A(col1)
	end

	--������Ա��
	set @count = (select count(*) from @selectedMan)
	if (@count>0)
	begin
		--������Ա��
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
--���ԣ�
declare @Ret int	--�����ɹ���ʶ
exec dbo.getWorkFlowTemplateEnableMan 'WF20130001',@Ret output


drop PROCEDURE getFlowInWorkFlowTemplateEnableMan
/*
	name:		getFlowInWorkFlowTemplateEnableMan
	function:	2.��ѯ�������ڵ��ܹ�ʹ����Ա�б�
	input: 
				@templateID varchar(10),	--������ģ����
				@flowID int,				--���̽ڵ���
				@instanceID varchar(10),	--ʵ�����

				@prevManID varchar(10),		--��һ���ڵ���ԱID
				--del by lw 2013-2-23
				--@includePrevMan smallint,	--���ڵ������Ա�Ƿ���԰�����һ���ڵ���Ա
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ��ѯ�Ĺ�����ģ�岻���ڣ�2��Ҫ��ѯ�Ľڵ㲻���ڣ�
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-20
	UpdateDate: modi by lw 2013-2-21����ϵͳ��ɫ���û�����
				modi by lw 2013-2-23���ų���Ա����ŵ��߼������У�
				modi by lw 2013-2-28���ӹ��ĵĴ����˽�ɫ֧��
*/
create PROCEDURE getFlowInWorkFlowTemplateEnableMan
	@templateID varchar(10),	--������ģ����
	@flowID int,				--���̽ڵ���
	@instanceID varchar(10),	--ʵ�����
	
	@prevManID varchar(10),		--��һ���ڵ���ԱID
--	@includePrevMan smallint,	--���ڵ������Ա�Ƿ���԰�����һ���ڵ���Ա
	@Ret int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ģ���Ƿ���ڣ�
	declare @count int
	set @count = ISNULL((select count(*) from workFlowTemplate where templateID = @templateID),0)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	--���ڵ��Ƿ���ڣ�
	set @count = ISNULL((select count(*) from workFlowTemplateFlow where templateID = @templateID and flowID=@flowID),0)
	if (@count=0)
	begin
		set @Ret = 2
		return
	end
	
	--�ж��Ƿ��н�ɫ���ƣ�
	declare @templateRole xml			--�ڵ����ʹ���˵Ľ�ɫ��
										--����'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
	select @templateRole = flowRole
	from workFlowTemplateFlow
	where templateID = @templateID and flowID = @flowID
	if (@templateRole is null)	--û�н�ɫ���ƣ�����ȫ����Ա
	begin
		set @Ret = 0
		select jobNumber userID, cName userCName from userInfo 
		where isOff = 0 and jobNumber <> @prevManID order by cName
		return
	end

	declare @managerID varchar(10), @manager nvarchar(30), @deputyManID varchar(10), @deputyMan nvarchar(30)	--�����쵼
	--��ȡָ��������ģ���е�ָ����Ľ�ɫ���ƣ�
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--�Ƿ�ȫ��Ϊ��
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
			if (@roleID = 0)			--���Ĵ�����
			begin
				insert @selectedMan(userID, userCName)
				select createrID,creater from workFlowInstance where instanceID = @instanceID
			end
			else if (@roleID = 1)			--�����쵼����ְ��:��������쵼��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from college where clgCode='001'
			end
			else if (@roleID = 2)		--�����쵼����ְ��:���������쵼��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select deputyManID, deputyMan from college where clgCode='001'
			end
			else if (@roleID = 10)		--����:�������쵼����ָ��������������Ա
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
			end
			else if (@roleID = 11)		--ֱ������:�������ڵ㴦����Ա���ڲ��ŵ��쵼��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select managerID, manager from useUnit
				where uCode in (select uCode from userInfo where jobNumber=@prevManID)
			end
			else if (@roleID = 20)		--�̹�:��ָȫ��̹�
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1
			end
			else if (@roleID = 21)		--����ͬ��:�������ڵ㴦����Ա���ڲ��ŵĽ̹�����ָ����ȫ��̹�
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 1 and uCode in (select uCode from userInfo where jobNumber=@prevManID) 
			end
			else if (@roleID = 30)		--��ʦ:��ָȫ����о����ĵ�ʦ
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and jobNumber in (select tutorID from userInfo where manType=9) 
			end
			else if (@roleID = 31)		--ֱ����ʦ:�������ڵ㴦��ѧ����������ʦ��ֻ���ǵ�һ��Ա
			begin
				insert @selectedMan(userID, userCName)
				select tutorID, tutorName from userInfo 
				where manType=9 and jobNumber=@prevManID 
			end
			else if (@roleID = 40)		--ѧ��:��ָȫ��ѧ��
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9
			end
			else if (@roleID = 41)		--����ͬѧ:�������ڵ㴦��ѧ�����ڲ��ŵ�����ͬѧ����ָ����ͬѧ
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo
				where isOff = 0 and manType = 9 and uCode in (select uCode from userInfo where jobNumber=@prevManID)
			end
			else if (@roleID = 100)		--ȫ����Ա:�������ڵ㴦��ѧ�����ڲ��ŵ�����ͬѧ����ָ����ͬѧ
			begin
				insert @selectedMan(userID, userCName)
				select jobNumber, cName from userInfo where isOff = 0
			end
			else if (@roleID = 101)		--ֱ���쵼:�������ڵ㴦����Ա��ֱ���ϼ��쵼������ѧ����ֱ���쵼Ϊ�䵼ʦ���̹���ֱ���쵼Ϊ������������ֱ���쵼Ϊ�����쵼
			begin
				declare @manType smallint
				set @manType = ISNULL((select manType from userInfo where jobNumber=@prevManID),1)
				if (@manType=9)	--��һ�ڵ���Ϊѧ��ֱ��ȡ��ʦ
				begin
					insert @selectedMan(userID, userCName)
					select tutorID, tutorName from userInfo 
					where manType=9 and jobNumber=@prevManID 
				end
				else if (@manType=1)	--��һ�ڵ���Ϊ�̹�
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
							if (@count > 0)	--����
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
			else if (@roleID = 102)		--����
			begin
				--�жϸ���һ�ڵ���Ա�Ƿ�Ϊ�����쵼
				set @count = isnull((select count(*) from college where clgCode='001' and (managerID=@prevManID or deputyManID=@prevManID)),0)
				if (@count > 0)	--�����쵼
				begin
					select @managerID=managerID, @deputyManID=deputyManID from college where clgCode='001'
					insert @selectedMan(userID, userCName)
					select jobNumber, cName 
					from userInfo 
					where isOff = 0 and jobNumber not in (@managerID, @deputyManID)
				end
				else
				begin
					--�жϸ���һ�ڵ���Ա�Ƿ�Ϊ����
					set @count = isnull((select count(*) from useUnit where managerID = @prevManID),0)
					if (@count > 0)	--����
					begin
						insert @selectedMan(userID, userCName)
						select jobNumber, cName 
						from userInfo 
						where isOff = 0 and uCode in (select uCode from useUnit where managerID = @prevManID)
					end
					else
					begin
						--�жϸ���һ�ڵ���Ա�Ƿ�Ϊ�̹���
						set @count = isnull((select count(*) from userInfo where manType=9 and jobNumber = @prevManID),0)
						if (@count > 0)	--����
							insert @selectedMan(userID, userCName)
							select jobNumber, cName from userInfo where isOff = 0 and tutorID = @prevManID
					end
				end
			end
			else if (@roleID = 999)		--ϵͳ�Զ������ɫ
			begin
				insert @selectedMan(userID, userCName)
				values('0000000000','ϵͳ�û�')
			end
			
			FETCH NEXT FROM tar INTO @roleID, @roleDesc
		end
		CLOSE tar
		DEALLOCATE tar
	end
	
	--���ϵͳ��ɫ������û���
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
	
	--���ֱ�Ӷ�����û���
	set @count=(select @templateRole.exist('/root/user'))
	if (@count>0)
	begin
		set @isAllEmpty = 'N'
		insert @selectedMan(userID, userCName)
		SELECT cast(A.col1.query('data(./@userID)') as varchar(10)),cast(A.col1.query('data(./@userCName)') as nvarchar(30))
		from @templateRole.nodes('/root/user') as A(col1)
	end

	--������Ա��
	set @count = (select count(*) from @selectedMan)
	if (@count>0)
	begin
		--������Ա��
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

	--�ų�ǰ�ýڵ���Ա����
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
--���ԣ�
declare @Ret int 				--�����ɹ���ʶ
exec dbo.getFlowInWorkFlowTemplateEnableMan 'WF20130002',2, 'CG20130382', 'G201300297', @Ret output
select uCode, uName, * from userInfo
where jobNumber='G201300297'
select managerID, manager from useUnit
where uCode in (select uCode from userInfo where jobNumber='G201300297')

select * from useUnit
declare @Ret int 				--�����ɹ���ʶ
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
	function:	10.��ӹ�����ʵ������������
	input: 
				@templateID varchar(10),		--������ģ����
				@topic nvarchar(100),			--ʵ�����ݼ���

				@createrID varchar(10),			--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1����ģ�岻���ڣ�2����ģ�����������༭������������ʵ����9:δ֪����
				@createTime smalldatetime output,--����ʱ��
				@instanceID varchar(10) output	--ʵ�����,ʹ��ģ���ж���ĺ��뷢�������ɵı��
	author:		¬έ
	CreateDate:	2013-1-20
	UpdateDate: 
*/
create PROCEDURE addWorkFlowInstance
	@templateID varchar(10),		--������ģ����
	@topic nvarchar(100),			--ʵ�����ݼ���

	@createrID varchar(10),			--�����˹���
	@Ret	int output,				--�����ɹ���ʶ
	@createTime smalldatetime output,--����ʱ��
	@instanceID varchar(10) output	--ʵ�����,ʹ��ģ���ж���ĺ��뷢�������ɵı��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��ȡģ��Ļ�����Ϣ��
	declare @templateName nvarchar(60)	--ģ������
	declare @formDBTable varchar(30)	--�����ݿ����
	declare @formIDMaker int			--�ĵ����뷢�������	
	declare @lockManID varchar(10)		--ģ�嵱ǰ���������༭���˹���
	select @templateName = templateName, @formDBTable = formDBTable, @formIDMaker = formIDMaker, @lockManID = lockManID
	from workFlowTemplate
	where templateID = @templateID
	if (@templateName is null)	--ģ�岻����
	begin
		set @Ret = 1
		return
	end
	if (ISNULL(@lockManID,'')<>'')	--ģ�����������༭
	begin
		set @Ret = 2
		return
	end
	
	--ʹ�ú��뷢�����������ر�ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber @formIDMaker, 1, @curNumber output
	set @instanceID = @curNumber

	--�����˵�������
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @createrID),'')
	
	set @createTime = getdate()
	begin tran
		--�Ǽ�ʵ����
		insert workFlowInstance(instanceID, buildDate, templateID, templateName, topic,
							--������/����ά�����:
							createrID, creater, createTime,modiManID, modiManName, modiTime,
							--ʵ��״̬��
							instanceStatus, statusDesc,
							--���ȣ�
							curFlowID, sectionName, 
							curActivity, curActivityType, curActivityDesc, extendedDay)

		select @instanceID, @createTime, @templateID, @templateName, @topic,
							--������/����ά�������
							@createrID, @creater, @createTime, @createrID, @creater, @createTime,
							--ʵ��״̬��
							1, activityDesc,
							--��ǰ������ȣ���
							1, sectionName, activity, activityType, activityDesc, 0
		from workFlowTemplateFlow
		where templateID = @templateID and flowID = 1
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--����ʵ���Ļ�⣺
		insert workflowInstanceActivity(instanceID, templateID, flowID, 
				activity, sectionName,
				--����壺
				receiverID, receiver,
				--����˵����
				prevFlowID2Status, nextFlowID,
				--ʱ����ƣ�
				receiveDate, completedDate, activityStatus, 
				isExpire, startTimeType, expireDay, usedDay)
		select @instanceID, @templateID, flowID,
				activity, sectionName,
				@createrID, @creater,
				N'<root></root>',N'<root></root>',	--����ڵ�����״̬/�����ڵ���
				@createTime, null, 1, 
				--ʱ����ƣ�
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

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createrID, @creater, @createTime, '����������ʵ��', 'ϵͳ�����û�' + @creater + 
					'��Ҫ�󴴽��˹�����ģ��['+@templateName+']��ʵ��['+@instanceID+']��')
GO
--���ԣ�
declare @Ret	int		--�����ɹ���ʶ
declare @createTime smalldatetime	--����ʱ��
declare @instanceID varchar(10)		--ʵ�����,ʹ��ģ���ж���ĺ��뷢�������ɵı��
exec addWorkFlowInstance 'WF20130001','�ҵ������','G201300001', @Ret output, @createTime output, @instanceID output
select @Ret,@instanceID

select * from workFlowInstance
select * from workflowInstanceActivity

drop PROCEDURE addWorkflowInstanceFeedBack
/*
	name:		addWorkflowInstanceFeedBack
	function:	11.��ӹ�����ʵ��ָ����Ļ�ǩ���
				ע�⣺���������ǰ���Զ�����ϴ���ӵĻ�ǩ�����������֧���˴�������е���ʱ���棬�ٴ����봦���޸Ļ�ǩ���
	input: 
				@instanceID varchar(10),			--������ʵ�����
				@activityID bigint,					--��������ǰ��ı�ʶ

				@approveManID varchar(10),			--��׼�˹���
				@approveStatus smallint,			--����������ͣ�0->δ֪��1->��׼��-1->����׼
				@approveOpinion nvarchar(500),		--�������
				@attachment xml,					--����,��������xml��ʽ��ţ�
													<root>
														<attachment aFilename="a.doc" uidFilename="XXXXXX" fileSize="123" fileType=".doc" />
													</root>
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ�������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-23
	UpdateDate: modi by lw 2013-2-23��������ϴλ�ǩ�������
				modi by lw 2013-2-26���Ӹ���ԭʼ�ļ���֧��
				modi by lw 2013-6-21֧�ֶ������

*/
create PROCEDURE addWorkflowInstanceFeedBack
	@instanceID varchar(10),			--������ʵ�����
	@activityID bigint,					--��������ǰ��ı�ʶ

	@approveManID varchar(10),			--��׼�˹���
	@approveStatus smallint,			--����������ͣ�0->δ֪��1->��׼��-1->����׼
	@approveOpinion nvarchar(500),		--�������
	@attachment xml,					--����,����xml��ʽ���
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ��ӻ�ǩ����Ĺ�����ʵ���ͻ�Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ɾ�����ܵ��ϴλ�ǩ�����
	delete workflowInstanceFeedBack where instanceID = @instanceID and activityID= @activityID
	
	--��ȡ������ʵ���Ļ�����Ϣ��	
	declare @templateID varchar(10)		--������ģ����
	declare @activity nvarchar(100)		--�����
	declare @flowID int					--�ڵ���
	select @templateID = templateID, @activity = activity, @flowID = flowID 
	from workflowInstanceActivity 
	where instanceID = @instanceID and activityID= @activityID

	--ȡ�����˵�������
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
		--��ӻ�ǩ���������
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

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '���Ļ�ǩ', '�û�' + @approveMan
												+ '������['+@instanceID+']ǩ����һ�������')

GO

select * from workFlowInstance
select * from workflowInstanceFeedBack
insert feedBackAttachment(instanceID, activityID, aFilename, uidFilename, fileSize, fileType)
values('CG20130354','5570','���Ը���1','1XXXXX',123,'.doc')
insert feedBackAttachment(instanceID, activityID, aFilename, uidFilename, fileSize, fileType)
values('CG20130354','5570','���Ը���2','2XXXXX',123,'.doc')


select * from taskInfo

drop PROCEDURE delWorkflowInstanceFeedBack
/*
	name:		delWorkflowInstanceFeedBack
	function:	12.ɾ��������ʵ��ָ����Ļ�ǩ���
	input: 
				@instanceID varchar(10),		--������ʵ�����
				@activityID bigint,				--��������ǰ��ı�ʶ

				@delManID varchar(10),			--ɾ���˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ�������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-23
	UpdateDate: 

*/
create PROCEDURE delWorkflowInstanceFeedBack
	@instanceID varchar(10),		--������ʵ�����
	@activityID bigint,				--��������ǰ��ı�ʶ

	@delManID varchar(10),			--ɾ���˹���
	
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ��ӻ�ǩ����Ĺ�����ʵ���ͻ�Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ɾ����ǩ�����
	delete workflowInstanceFeedBack where instanceID = @instanceID and activityID= @activityID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����ǩ���', '�û�' + @delManName
												+ 'ɾ���˹���['+@instanceID+']�['+STR(@activityID)+']�Ļ�ǩ�����')
GO

drop PROCEDURE registerFlowActivity
/*
	name:		registerFlowActivity
	function:	15.��ʵ���ı������Ǽǵ�ָ���Ľڵ��һ����У�����ûû�д����򴴽�
				ע�⣺����ֻ����һ��������ҿ���ʹǰ������ڵ�
	input: 
				@instanceID varchar(10),	--ʵ�����
				@activityID bigint,			--��ǰ��ı�ʶ
				@forwardFlowID int,			--�ƽ����Ļ�Ľڵ���
				@receiverID varchar(10),	--������ID
				@declareStatus int,			--����ı��״̬��0->δ֪��1->ͬ�⣬2->��ͬ��
	output: 
				@Ret		int output,		--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ���������ڣ�2:�����ǰ�ýڵ㻹û����ȫ���3��������Ǽ���״̬��9��δ֪����
				@nextActivityID bigint output--�ǼǵĽڵ���
	author:		¬έ
	CreateDate:	2013-1-23
	UpdateDate: modi by lw 2013-2-25�ڵǼǵĽڵ�����������ID���������ӵǼǽڵ��ŵķ���ֵ������֧��ǰ������ڵ�

*/
create PROCEDURE registerFlowActivity
	@instanceID varchar(10),	--ʵ�����
	@activityID bigint,			--��ǰ��ı�ʶ
	@forwardFlowID int,			--�ƽ����Ļ�Ľڵ���
	@receiverID varchar(10),	--������ID
	@declareStatus int,			--����ı��״̬��0->δ֪��1->ͬ�⣬2->��ͬ��
	@Ret		int output,		--�����ɹ���ʶ
	@nextActivityID bigint output--�ǼǵĽڵ���
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�ƽ��Ĺ�����ʵ���ͻ�Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--��ȡ������ʵ����Ļ�����Ϣ��	
	declare @templateID varchar(10)		--������ģ����
	declare @activity nvarchar(100)		--�����
	declare @flowID int					--�ڵ���
	declare @activityStatus int			--�״̬��0->���ʼ������δȫ������(�ȴ�ǰ�ýڵ����)��
										--	1->ǰ�ýڵ�ȫ����ɣ��ȴ�����
										--	2->���ڴ�����
										--	-1->����������һ�ڵ㣬-2->����˻���һ���ڵ㣬
										--	9->��ɲ�ת����һ������
	declare @senderID varchar(10)	--������Ա���ţ�ָ�����һ���ڵ㣩
	declare @sender nvarchar(30)	--������Ա������ָ�����һ���ڵ㣩
	select @templateID = templateID, @activity = activity, @flowID = flowID, @activityStatus = activityStatus,
		@senderID = receiverID, @sender = receiver
	from workflowInstanceActivity 
	where instanceID = @instanceID and activityID= @activityID
	--�ж��״̬��
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
	
	--ȡ�����˵�������
	declare @receiver nvarchar(30)
	set @receiver = isnull((select cName from userInfo where jobNumber = @receiverID),'')

	--�����û�Ƿ����ɣ�������ɾ�����״̬������ע��
	set @count = isnull((select count(*) from workflowInstanceActivity 
					where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus in (0,1) and receiverID=@receiverID),0)
	if (@count=0)
	begin
		--ע���µĻ��
		insert workflowInstanceActivity(instanceID, templateID, flowID, activity, sectionName,
					--����壺
					receiverID, receiver,
					--����˵����
					prevFlowID2Status, 
					nextFlowID,
					--ʱ����ƣ�
					receiveDate, activityStatus, isExpire, startTimeType, expireDay, usedDay)
		select @instanceID, @templateID, @forwardFlowID, activity, sectionName,
					--����壺
					@receiverID, @receiver,
					--����˵����
					N'<root><flow id="'+LTRIM(str(@flowID,8))+'" aID="'+ltrim(str(@activityID))
						+'" senderID="'+@senderID+'" sender="'+@sender+'" status="'+STR(@declareStatus,1)+'"></flow></root>', 
					forwardFlow,
					--ʱ����ƣ�
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
	--��ȡ�Ǽǽڵ�ı�ţ�
	set @nextActivityID = (select activityID from workflowInstanceActivity
						   where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus in (0,1) and receiverID=@receiverID)

	--------------------------------����Ԥ���������ڸ߼������д���:�����д��������!---------------------------------------
	/*
	--ȡ��ı�ʶ��
	declare @nextActivityID bigint
	set @nextActivityID = (select activityID from workflowInstanceActivity 
							where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus in (0,1) and receiverID=@receiverID)
	
	--���û��Ԥ����
	declare @nextFlowType int	--�ڵ����ͣ�1->��һ�ڵ㡢2->��֧�ڵ㡢�����ڵ㣨3->�������4->�������
	declare @isAutoProcess int	--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	declare @autoProcessCode nvarchar(1000)		--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬
	select @nextFlowType = flowType, @isAutoProcess = isAutoProcess, @autoProcessCode = autoProcessCode
	from workFlowTemplateFlow
	where templateID = @templateID and flowID = @forwardFlowID
	if (@nextFlowType=1) --��һ�ڵ�
	begin
		update workflowInstanceActivity
		set activityStatus = 1
		where instanceID = @instanceID and flowID=@forwardFlowID and activityStatus = 0 and receiverID=@receiverID
	end
	else if (@nextFlowType=3) --������ڵ�
	begin
		declare @prevFlowID2Status xml	--����ڵ�����״̬
		set @prevFlowID2Status = (select prevFlowID2Status from workflowInstanceActivity where activityID = @nextActivityID)
		if (@isAutoProcess=1)
		begin
			if (@autoProcessCode<>'')
			begin
				declare @sql varchar(4000)
				set @sql = @autoProcessCode + ' ' + cast(@prevFlowID2Status as varchar(8000))
				exec @sql
			end
			else	--ʹ��Ĭ�Ϸ�ʽ�������ǰ�ýڵ㶼�Ѿ���ɣ����Զ�������һ���ڵ�
			begin
			end
		end
	end
	else if (@nextFlowType=4) --������ڵ�
	begin
	end
	*/
	--------------------------------------------------------------------------
	set @Ret = 0
GO
--���ԣ�
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
	function:	16.����ʵ���״̬Ϊ�������С�
	input: 
				@instanceID varchar(10),	--ʵ�����
				@activityID bigint,			--��ǰ��ı�ʶ
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ���������ڣ�
							2��ָ����ʵ�����û�м��3.ָ����ʵ������ڱ�����
							4��ָ����ʵ����Ѿ�ֹͣ��9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-20
	UpdateDate: modi by lw 2013-2-24���������С�״̬�趨��setActivityStatus�����з���

*/
create PROCEDURE setActivityStatus4Process
	@instanceID varchar(10),	--ʵ�����
	@activityID bigint,			--��ǰ��ı�ʶ
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�ƽ��Ĺ�����ʵ���ͻ�Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--��ȡ������ʵ����Ļ�����Ϣ��	
	declare @templateID varchar(10)		--������ģ����
	declare @activity nvarchar(100)		--�����
	declare @flowID int					--�ڵ���
	declare @curActivityStatus int		--��ĵ�ǰ״̬��0->���ʼ������δȫ������(�ȴ�ǰ�ýڵ����)��
										--	1->ǰ�ýڵ�ȫ����ɣ��ȴ�����
										--	2->���ڴ�����
										--	-1->����������һ�ڵ㣬-2->�����
										--	9->��ɲ�ת����һ������
	select @templateID = templateID, @activity = activity, @flowID = flowID, @curActivityStatus = activityStatus
	from workflowInstanceActivity 
	where instanceID = @instanceID and activityID= @activityID
	--�ж��״̬��
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
--���ԣ�
declare @Ret		int 		--�����ɹ���ʶ
exec dbo.setActivityStatus4Process 'QJ20130083',1,@Ret output
select @Ret 

select * from workflowInstanceActivity

drop PROCEDURE setActivityStatus
/*
	name:		setActivityStatus
	function:	17.����ʵ���״̬
	input: 
				@instanceID varchar(10),	--ʵ�����
				@activityID bigint,			--��ǰ��ı�ʶ
				
				@activityStatus int,		--�״̬��0->���ʼ������δȫ������(�ȴ�ǰ�ýڵ����)�����״̬�����ɱ���������
													  --1->ǰ�ýڵ�ȫ����ɣ��ȴ�����
													  --2->���ڴ����У����״̬�����ɱ���������
													-- -1->����������һ�ڵ㣬-2->����˻���һ���ڵ㣬
													  --9->��ɲ�ת����һ������
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ���������ڣ�
							2������ֱ���趨ʵ���Ϊ����״̬
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-20
	UpdateDate: 

*/
create PROCEDURE setActivityStatus
	@instanceID varchar(10),	--ʵ�����
	@activityID bigint,			--��ǰ��ı�ʶ
	@activityStatus int,		--�״̬
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж��״̬��
	if (@activityStatus = 2)
	begin
		set @Ret = 2
		return
	end

	--�ж�Ҫ�ƽ��Ĺ�����ʵ���ͻ�Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstanceActivity where instanceID = @instanceID and activityID= @activityID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--��ȡ������ʵ����Ļ�����Ϣ��	
	declare @templateID varchar(10)		--������ģ����
	declare @activity nvarchar(100)		--�����
	declare @activityType nvarchar(30)	--�����
	declare @activityDesc nvarchar(500)	--�����
	declare @flowID int					--�ڵ���
	declare @sectionName nvarchar(30)	--���½ڵ����ڻ�������
	declare @curActivityStatus int		--��ĵ�ǰ״̬��0->���ʼ������δȫ������(�ȴ�ǰ�ýڵ����)��
										--	1->ǰ�ýڵ�ȫ����ɣ��ȴ�����
										--	2->���ڴ�����
										--	-1->����������һ�ڵ㣬-2->�����
										--	9->��ɲ�ת����һ������
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
			--ά��ʵ��״̬���Ǽ����»���:
			update workFlowInstance
			set instanceStatus = 1,				--ʵ��״̬��0->������1->��ת�У�9->��ɣ�-1->�˻أ�-2����ֹ
				statusDesc ='��ת��',			--״̬˵��
				curFlowID =@flowID,				--���½ڵ���
				sectionName = @sectionName,		--���½ڵ����ڻ�������
				curActivity =@activity,			--���»����		
				curActivityType =@activityType,	--���»����
				curActivityDesc =@activityDesc	--���»����
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
	--Ӧ�û�Ҫ�ṩ���ڼ��㣡
	set @Ret = 0
GO


drop PROCEDURE queryInstanceLocMan
/*
	name:		queryInstanceLocMan
	function:	20.��ѯָ��������ʵ���Ƿ��������ڱ༭
				��ע:��������Ǳ༭״̬��Ҫ����������ʵ���༭,����������û�б༭��!
	input: 
				@instanceID varchar(10),	--ʵ�����
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ĺ�����ʵ��������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2003-2-21
	UpdateDate: 
*/
create PROCEDURE queryInstanceLocMan
	@instanceID varchar(10),	--ʵ�����
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from workFlowInstance where instanceID= @instanceID),'')
	set @Ret = 0
GO


drop PROCEDURE lockInstance4Edit
/*
	name:		lockInstance4Edit
	function:	21.����������ʵ���༭������༭��ͻ
	input: 
				@instanceID varchar(10),		--ʵ�����
				@lockManID varchar(10) output,	--�����ˣ������ǰ������ʵ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ�����ʵ�������ڣ�2:Ҫ�����Ĺ�����ʵ�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2003-2-21
	UpdateDate: 
*/
create PROCEDURE lockInstance4Edit
	@instanceID varchar(10),		--ʵ�����
	@lockManID varchar(10) output,	--�����ˣ������ǰ����״̬���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ�����ʵ���Ƿ����
	declare @count as int
	set @count=(select count(*) from workFlowInstance where instanceID= @instanceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����������ʵ���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˹�����ʵ��['+@instanceID+']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockInstanceEditor
/*
	name:		unlockInstanceEditor
	function:	22.�ͷŹ�����ʵ���༭��
				ע�⣺�����̲���鹤����ʵ���Ƿ���ڣ�
	input: 
				@instanceID varchar(10),		--ʵ�����
				@lockManID varchar(10) output,	--�����ˣ������ǰ������ʵ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2003-2-21
	UpdateDate: 
*/
create PROCEDURE unlockInstanceEditor
	@instanceID varchar(10),		--ʵ�����
	@lockManID varchar(10) output,	--�����ˣ������ǰ������ʵ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷŹ�����ʵ���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˹�����ʵ��['+ @instanceID +']�ı༭����')
GO


drop PROCEDURE setInstanceStatus
/*
	name:		setInstanceStatus
	function:	25.����ʵ��״̬
	input: 
				@instanceID varchar(10),	--ʵ�����
				
				@instanceStatus int,		--ʵ��״̬��0->������1->��ת�У�9->��ɣ�-1->�˻أ�-2����ֹ
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ�������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-24
	UpdateDate: 

*/
create PROCEDURE setInstanceStatus
	@instanceID varchar(10),	--ʵ�����
	@instanceStatus int,		--ʵ��״̬��0->������1->��ת�У�9->��ɣ�-1->�˻أ�-2����ֹ
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�ƽ��Ĺ�����ʵ���Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--������
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
	function:	26.����ʵ����������
	input: 
				@instanceID varchar(10),	--ʵ�����
				
				@completedStatus int,		--��ɽ��״̬��0->δ֪��1->ͬ�⣬2->��ͬ��
				@completedInfo nvarchar(300),--����������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ�������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-25
	UpdateDate: 

*/
create PROCEDURE setInstanceCompletedInfo
	@instanceID varchar(10),	--ʵ�����
	@completedStatus int,		--��ɽ��״̬��0->δ֪��1->ͬ�⣬2->��ͬ��
	@completedInfo nvarchar(300),--����������
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�ƽ��Ĺ�����ʵ���Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	update workflowInstance
	set instanceStatus = 9,
		statusDesc = '���',	--״̬˵��
		completedStatus = @completedStatus,
		completedInfo = @completedInfo,
		--������»���:
		curFlowID = null,		--���½ڵ���
		sectionName = '',		--���½ڵ����ڻ�������
		curActivity = '',		--���»����		
		curActivityType = '',	--���»����
		curActivityDesc = ''	--���»����
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
	function:	27.��ָֹ����ʵ���
	input: 
				@instanceID varchar(10),		--ʵ�����
				
				@stopManID varchar(10) output,	--��ֹ�ˣ������ǰ������ʵ���������༭�򷵻������˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ�������ڣ�
							2��ָ����ʵ���������˵��ȴ���
							3��ָ����ʵ���������������༭��
							4��ָ����ʵ���Ѿ��������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-3-2
	UpdateDate: 

*/
create PROCEDURE stopInstanceActivity
	@instanceID varchar(10),	--ʵ�����
	@stopManID varchar(10) output,	--��ֹ�ˣ������ǰ������ʵ���������༭�򷵻������˹���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ʵ���Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���ʵ���Ƿ������ڵ��ȴ���Ļ��
	set @count = (select count(*) from workflowInstanceActivity 
					where instanceID=@instanceID and activityStatus = 2 and receiverID<>@stopManID)
	if (@count > 0)	--����
	begin
		set @Ret = 2
		return
	end
	
	--���༭����״̬��
	declare @lockManID varchar(10)		--��ǰ���������༭���˹���
	declare @instanceStatus smallint	--ʵ��״̬��0->������1->��ת�У�9->��ɣ�-1->�˻أ�-2����ֹ
	select @lockManID = lockManID, @instanceStatus = instanceStatus
	from workFlowInstance
	where instanceID = @instanceID
	--�ж�״̬��
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
		--����ʵ�����еĻ״̬Ϊ����ֹ��
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
			statusDesc = '��ֹ',	--״̬˵��
			completedStatus = 2,	--����������ɽ��״̬
			completedInfo = '��ֹ',	--������������������
			--������»���:
			curFlowID = null,		--���½ڵ���
			sectionName = '',		--���½ڵ����ڻ�������
			curActivity = '',		--���»����		
			curActivityType = '',	--���»����
			curActivityDesc = ''	--���»����
		where instanceID = @instanceID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	
	set @Ret = 0

	--ȡά���˵�������
	declare @stopMan nvarchar(30)
	set @stopMan = isnull((select userCName from activeUsers where userID = @stopManID),'')
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopMan, getdate(), '��ֹ������ʵ��', '�û�' + @stopMan
												+ '��ֹ�˹�����ʵ��['+@instanceID+']��')
GO

drop PROCEDURE stopInstance
/*
	name:		stopInstance
	function:	28.��ֹʵ��
	input: 
				@instanceID varchar(10),		--ʵ�����
				
				@stopManID varchar(10) output,	--��ֹ�ˣ������ǰ������ʵ���������༭�򷵻������˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����ʵ�������ڣ�
							2��ָ����ʵ���������˵��ȴ���
							3��ָ����ʵ���������������༭��
							4��ָ����ʵ���Ѿ��������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-3-2
	UpdateDate: 

*/
create PROCEDURE stopInstance
	@instanceID varchar(10),	--ʵ�����
	@stopManID varchar(10) output,	--��ֹ�ˣ������ǰ������ʵ���������༭�򷵻������˹���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ʵ���Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���ʵ���Ƿ������ڵ��ȴ���Ļ��
	set @count = (select count(*) from workflowInstanceActivity 
					where instanceID=@instanceID and activityStatus = 2 and receiverID<>@stopManID)
	if (@count > 0)	--����
	begin
		set @Ret = 2
		return
	end
	
	--���༭����״̬��
	declare @lockManID varchar(10)		--��ǰ���������༭���˹���
	declare @instanceStatus smallint	--ʵ��״̬��0->������1->��ת�У�9->��ɣ�-1->�˻أ�-2����ֹ
	select @lockManID = lockManID, @instanceStatus = instanceStatus
	from workFlowInstance
	where instanceID = @instanceID
	--�ж�״̬��
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
		--����ʵ�����еĻ״̬Ϊ����ֹ��
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
			statusDesc = '��ֹ',	--״̬˵��
			completedStatus = 2,	--����������ɽ��״̬
			completedInfo = '��ֹ',	--������������������
			--������»���:
			curFlowID = null,		--���½ڵ���
			sectionName = '',		--���½ڵ����ڻ�������
			curActivity = '',		--���»����		
			curActivityType = '',	--���»����
			curActivityDesc = ''	--���»����
		where instanceID = @instanceID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	
	set @Ret = 0

	--ȡά���˵�������
	declare @stopMan nvarchar(30)
	set @stopMan = isnull((select userCName from activeUsers where userID = @stopManID),'')
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopMan, getdate(), '��ֹ������ʵ��', '�û�' + @stopMan
												+ '��ֹ�˹�����ʵ��['+@instanceID+']��')
GO

drop PROCEDURE delInstance
/*
	name:		delInstance
	function:	29.ɾ��ָ����ʵ��
	input: 
				@instanceID varchar(10),		--ʵ�����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ������ʵ���������༭�򷵻������˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ʵ�������ڣ�
							2����ʵ�����������༭������ɾ��
							--3����ʵ����ת�У�����ɾ����
							3����ʵ���Ѿ������������У�����ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-3-2
	UpdateDate: 

*/
create PROCEDURE delInstance
	@instanceID varchar(10),	--ʵ�����
	@delManID varchar(10) output,--ɾ���ˣ������ǰ������ʵ���������༭�򷵻������˹���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ʵ���Ƿ����
	declare @count as int
	set @count=(select count(*) from workflowInstance where instanceID = @instanceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����״̬��
	declare @lockManID varchar(10)		--��ǰ���������༭���˹���
	declare @instanceStatus smallint	--ʵ��״̬��0->������1->��ת�У�9->��ɣ�-1->�˻أ�-2����ֹ
	declare @curFlowID int 				--���½ڵ���
	select @lockManID = lockManID, @instanceStatus = instanceStatus, @curFlowID = curFlowID
	from workFlowInstance
	where instanceID= @instanceID
	--�ж�״̬��
	--if (@instanceStatus not in (0,-1,-2))	--����ɾ���˻ػ���ֹ��ʵ��
	if (@instanceStatus =9 or (@instanceStatus=1 and @curFlowID>1))	--ֻ����ɾ��δ���͵�ʵ��
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

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��������ʵ��', '�û�' + @delManName
												+ 'ɾ���˹�����ʵ��['+@instanceID+']��')

GO
--���ԣ�
declare	@Ret		int --�����ɹ���ʶ
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