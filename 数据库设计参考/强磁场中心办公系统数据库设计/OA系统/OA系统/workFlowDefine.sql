use hustOA
/*
	ǿ�ų����İ칫ϵͳ-������������
	author:		¬έ
	CreateDate:	2013-2-21
	UpdateDate: 
*/

--1.������ģ�嶨�壺
--���Ҫ����ʹ��ģ�����Ա�������ã�templateRole xml null ����'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
select * from workFlowTemplate
insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130001','�����','leaveRequestInfo','300','FM20130001','','','FM20130002',null)

insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130002','�豸�ɹ������','eqpApplyInfo','301','FM20130010','','','FM20130013',
		N'<root>'+
			'<role id="20" desc="�̹�" />'+
		'</root>')
	--�豸�ɹ������ֻ����̹�ʹ��
insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130003','���ķ��������','thesisPublishApplyInfo','302','FM20130020','','','FM20130022',null)

insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130004','����ӹ������','processApplyInfo','303','FM20130030','','','FM20130033',null)

insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130005','���������','otherApplyInfo','304','FM20130040','','','FM20130042',null)

--�޶�Ϊȫ���̹�ʹ�ã������̲����������ڿ���ѡ�񲿳���
delete workFlowTemplate where templateID='WF20130006'
insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130006','�豸�ɹ������2','eqpApplyInfo','301','FM20130010','','','FM20130013',
			N'<root>'+
				'<role id="20" desc="�̹�" />'+
			'</root>')
	--�豸�ɹ������2ֻ����̹�ʹ��
			
select * from userInfo
select * from sysRole
select * from workFlowRole

--2.��������ɫ���壺���Ҫͬϵͳ���û�����ɫ������ͨ����������Զ�������Ա��Χ�����Ƕ�ϵͳ��ɫ�Ĳ��䣡�ص���ǿ����Ա֮��Ĺ�ϵ����������
insert workFlowRole(roleID,roleName,roleDesc)
values(0,'���ķ�����','���Ĵ�����')
insert workFlowRole(roleID,roleName,roleDesc)
values(1,'�����쵼����ְ��','��������쵼��ֻ���ǵ�һ��Ա')--�����������Ϊϵͳ�Ľ�ɫ��
insert workFlowRole(roleID,roleName,roleDesc)
values(2,'�����쵼����ְ��','���������쵼��ֻ���ǵ�һ��Ա')--�����������Ϊϵͳ�Ľ�ɫ��
insert workFlowRole(roleID,roleName,roleDesc)
values(10,'����','�������쵼����ָ��������������Ա')	--�����������Ϊϵͳ�Ľ�ɫ��
insert workFlowRole(roleID,roleName,roleDesc)
values(11,'ֱ������','�������ڵ㴦����Ա���ڲ��ŵ��쵼��ֻ���ǵ�һ��Ա')
insert workFlowRole(roleID,roleName,roleDesc)
values(20,'�̹�','��ָȫ��̹�')--�����������Ϊϵͳ�Ľ�ɫ��
insert workFlowRole(roleID,roleName,roleDesc)
values(21,'����ͬ��','�������ڵ㴦����Ա���ڲ��ŵĽ̹�����ָ����ȫ��̹�')
insert workFlowRole(roleID,roleName,roleDesc)
values(30,'��ʦ','��ָȫ����о����ĵ�ʦ')--�����������Ϊϵͳ�Ľ�ɫ��
insert workFlowRole(roleID,roleName,roleDesc)
values(31,'ֱ����ʦ','�������ڵ㴦��ѧ����������ʦ��ֻ���ǵ�һ��Ա')
insert workFlowRole(roleID,roleName,roleDesc)
values(40,'ѧ��','��ָȫ��ѧ��')--�����������Ϊϵͳ�Ľ�ɫ��
insert workFlowRole(roleID,roleName,roleDesc)
values(41,'����ͬѧ','�������ڵ㴦��ѧ�����ڲ��ŵ�����ͬѧ����ָ����ͬѧ')
insert workFlowRole(roleID,roleName,roleDesc)
values(100,'ȫ����Ա','ȫ����Ա������ѧ������ʦ')--�����������Ϊϵͳ�Ľ�ɫ��
insert workFlowRole(roleID,roleName,roleDesc)
values(101,'ֱ���쵼','�������ڵ㴦����Ա��ֱ���ϼ��쵼������ѧ����ֱ���쵼Ϊ�䵼ʦ���̹���ֱ���쵼Ϊ������������ֱ���쵼Ϊ�����쵼')
insert workFlowRole(roleID,roleName,roleDesc)
values(102,'����','�������ڵ㴦����Ա�����£����粿��������Ϊ���ŵ���ʦ')
insert workFlowRole(roleID,roleName,roleDesc)
values(999,'ϵͳ','ϵͳ�Զ������ɫ')

--3.������ģ������壺һ��������ģ����������
select * from workFlowTemplateForms
delete workFlowTemplateForms
--�������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile,paperWidth,paperHeight)
values('WF20130001', 'FM20130001',1,'�½������','../workFlowDoc/addLeave.html',210,160)
--�������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile,paperWidth,paperHeight)
values('WF20130001', 'FM20130002',0,'��ʾ�����','../workFlowDoc/leaveDetail.html',210,160)
--������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile,paperWidth,paperHeight)
values('WF20130001', 'FM20130003',1,'�༭�����','../workFlowDoc/editLeave.html',210,160)

--�豸�ɹ��������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130010',1,'�½��豸�ɹ����뵥','../workFlowDoc/addEqpApply.html')
--�豸�ɹ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130011',1,'�༭�豸�ɹ����뵥', '../workFlowDoc/editEqpApply.html')
--�豸�ɹ�������б�����Ϣ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130012',1,'��豸�б���Ϣ', '../workFlowDoc/editEqpApply2.html')
--�豸�ɹ��������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130013',0,'��ʾ�豸�ɹ����뵥','../workFlowDoc/eqpApplyDetail.html')

--���ķ��������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130020',1,'�½����ķ�������','../workFlowDoc/addThesisApply.html')
--���ķ��������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130021',1,'�༭���ķ�������', '../workFlowDoc/editThesisApply.html')
--���ķ����������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130022',0,'��ʾ���ķ�������','../workFlowDoc/thesisApplyDetail.html')


--����ӹ������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130030',1,'��������ӹ�����','../workFlowDoc/addWorkshopApply.html')
--����ӹ������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130031',1,'�༭����ӹ�����','../workFlowDoc/editWorkshopApply.html')
--����ӹ������ӹ�״̬�����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130032',1,'�����ӹ������ӹ�״̬','../workFlowDoc/addWorkshopStatus.html')
--����ӹ��������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130033',0,'��ʾ����ӹ�����','../workFlowDoc/workshopApplyDetail.html')

--���������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130040',1,'������������','../workFlowDoc/addOhterApply.html')
--���������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130041',1,'�༭��������','../workFlowDoc/editOhterApply.html')
--�����������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130042',0,'��ʾ��������','../workFlowDoc/otherApplyDetail.html')

--�豸�ɹ�����2����������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130010',1,'�½��豸�ɹ����뵥','../workFlowDoc/addEqpApply.html')
--�豸�ɹ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130011',1,'�༭�豸�ɹ����뵥', '../workFlowDoc/editEqpApply.html')
--�豸�ɹ�������б�����Ϣ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130012',1,'��豸�б���Ϣ', '../workFlowDoc/editEqpApply2.html')
--�豸�ɹ��������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130013',0,'��ʾ�豸�ɹ����뵥','../workFlowDoc/eqpApplyDetail.html')

--4.������ģ�����̣�ģ�������壺
--�������̣�
select * from workFlowTemplate
select * from workFlowTemplateForms
select * from  workFlowInstance
select * from workflowInstanceActivity
update workflowInstanceActivity
set activityStatus = 0
select * from workFlowTemplateFlow
delete workFlowTemplateFlow

delete workFlowTemplateFlow where templateID='WF20130001' 
--������������̣�
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130001',1,1,1,'����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="100" desc="ȫ����Ա"></role></root>',0,
	--����壺
	'��д�����','�༭','�����˱༭�������','FM20130003',1,'FM20130002',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>2</flowID></root>',0,0,1,0,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	0,'',
	--ʱ����ƣ�
	0,'',0,0)

insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130001',2,9,0,'����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="101" desc="ֱ���쵼"></role></root>',0,
	--����壺
	'���������','����','ֱ���쵼�鿴������������ɣ������Ƿ���׼��١�������������ֹ','FM20130002',0, 'FM20130002',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'��ʦ',
	--ʱ����ƣ�
	0,'',0,0)


--�����豸�ɹ����̣�
--1.����
select * from workFlowTemplateFlow where templateID='WF20130002'
delete workFlowTemplateFlow where templateID='WF20130002'
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130002',1,1,1,'����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="20" desc="�̹�" /></root>',0,
	--����壺
	'��д�豸�ɹ����뵥','����','����������д�豸�ɹ����뵥���������豸�ɹ������������̡�','FM20130011',1,'FM20130013',
	'','',
	--������ƣ�
	N'<root></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>2</flowID></root>',0,0,0,0,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	0,'',
	--ʱ����ƣ�
	0,'',0,0)


--2.����������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130002',2,2,0,'��������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="11" desc="ֱ������"></role></root>',0,
	--����壺
	'�����豸�ɹ�����','����','ֱ�������鿴�����˲ɹ����ɣ������Ƿ���׼��Ȼ��ת�����ĸ����Ρ�','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>3</flowID></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>1</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'����',
	--ʱ����ƣ�
	0,'',0,0)

select * from workFlowTemplateFlow where templateID='WF20130002'
--3.����������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130002',3,2,0,'��������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="1" desc="����"></role></root>',0,
	--����壺
	'�����豸�ɹ�����','����','���β鿴�����˲ɹ����ɺͲ�������������������Ƿ���׼��Ȼ�󷢻�������ʵʩ�ɹ��бꡣ','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>2</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>4</flowID></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>2</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'����',
	--ʱ����ƣ�
	0,'',0,0)
	
--4.��ɹ��б������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130002',4,2,1,'��ɹ��б����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="0" desc="���ķ�����"></role></root>',0,
	--����壺
	'��ɹ��б����','�ɹ��б�','�ɷ��������豸�������豸�ɹ����룬�б���ɺ���б������','FM20130012',1, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>3</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>5</flowID></root>',0,0,0,0,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	0,'',
	--ʱ����ƣ�
	0,'',0,0)

--5.�ܾ���ʦ������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130002',5,2,0,'�ܾ���ʦ����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="2" desc="�ܾ���ʦ"></role></root>',0,
	--����壺
	'�ܾ���ʦ����','����','�ܾ���ʦ����б�����Ƿ��������Ҫ�󣬾����Ƿ�ʵʩ�ɹ���Ȼ��ת���ܾ���������','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>4</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>6</flowID></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>4</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'�ܾ���ʦ',
	--ʱ����ƣ�
	0,'',0,0)

--6.�ܾ���������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130002',6,9,0,'�ܾ�������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="1" desc="�ܾ���"></role></root>',0,
	--����壺
	'�ܾ�������','����','�ܾ�������б�����Ƿ��������Ҫ�󣬾����Ƿ�ʵʩ�ɹ���','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>5</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>5</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'�ܾ���',
	--ʱ����ƣ�
	0,'',0,0)
	


--�������ķ����������̣�
delete workFlowTemplateFlow where templateID='WF20130003'
--1.�����˱༭��
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130003',1,0,1,'����',
	--�����ʽ��
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="100" desc="ȫ����Ա"></role></root>',0,
	--����壺
	'��д���ķ������뵥','����','����������д���ķ������뵥�����������ķ��������������̡�','FM20130021',1,'FM20130022',
	'','',
	--������ƣ�
			--������ƣ�
	'',1,
				--������Զ�����
	0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>2</flowID></root>',0,0,0,0,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ������
	1,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,N'<root></root>',
			--�Ƿ������ǩ
	0,'',
	--ʱ����ƣ�
	0,'',0,0)
	
--2.��������������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130003',2,2,0,'����',
	--�����ʽ��add by lw 2013-3-3
	2,1,'ͬ��','��ͬ��',
	--�ڵ���������ƣ�
	N'<root><role id="100" desc="ȫ����Ա"></role></root>',1,
	--����壺
	'�������ķ�������','����','�������߲鿴���ķ�������������Ƿ���׼��','FM20130022',0, 'FM20130022',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>3</flowID></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>3</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'��ʦ',
	--ʱ����ƣ�
	0,'',0,0)

	
--3.�����������������������Զ����������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130003',3,9,0,'����������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="999" desc="ϵͳ"></role></root>',0,
	--����壺
	'������������������ķ�������Ľ��','����','�������������������������Ƿ���׼��','FM20130022',0, 'FM20130022',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>2</flowID></root>',2,1,1,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root></root>',0,0,0,0,'',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
	0,'',
	--ʱ����ƣ�
	0,'',0,0)


--���峵��ӹ��������̣�
--1.����
select * from workFlowTemplateFlow where templateID='WF20130004'
delete workFlowTemplateFlow where templateID='WF20130004'
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130004',1,1,1,'����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="100" desc="ȫ����Ա"></role></root>',0,
	--����壺
	'��д����ӹ����뵥','����','����������д����ӹ����뵥�������𳵼�ӹ������������̡�','FM20130031',1,'FM20130033',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>2</flowID></root>',0,0,0,0,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
	0,'',
	--ʱ����ƣ�
	0,'',0,0)



--2.����(���Ӧ���Ǳ��ϲ���������ʱʹ�ø�����)������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130004',2,2,0,'��������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="11" desc="ֱ������"></role></root>',0,
	--����壺
	'��������ӹ����룬ָ�ɼӹ���Ա','����','ֱ�������鿴�����˼ӹ����ɣ������Ƿ���׼��Ȼ��ָ�ɼӹ���Ա��','FM20130033',0, 'FM20130033',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>3</flowID></root>',0,0,1,0,'ָ��',
				--������ƣ�
	1,N'<root>1</root>',0,0,0,0,'�˻�',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'����',
	--ʱ����ƣ�
	0,'',0,0)

--3.�ӹ���Ա��ӹ�״̬��
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130004',3,9,1,'�ӹ�',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="102" desc="����"></role></root>',0,
	--����壺
	'�ӹ��������ӹ�״̬','�ӹ�','����������ԱҪ��Ͳ���ָʾ�ӹ���������������','FM20130032',1, 'FM20130033',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>2</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root></root>',0,0,0,0,'���',
				--������ƣ�
	1,N'<root>1</root>',0,0,0,0,'�޷����',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'�̹�',
	--ʱ����ƣ�
	0,'',0,0)

select * from workFlowTemplateFlow
delete workFlowTemplateFlow




--���������������̣�
delete workFlowTemplateFlow where templateID='WF20130005'
--1.�����˱༭��
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130005',1,1,1,'����',
	--�����ʽ��
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="100" desc="ȫ����Ա"></role></root>',0,
	--����壺
	'��д�������뵥','����','����������д�������뵥��������������ת���̡�','FM20130041',1,'FM20130042',
	'','',
	--������ƣ�
			--������ƣ�
	'',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>2</flowID></root>',0,0,1,1,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ������
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,N'<root></root>',
			--�Ƿ������ǩ
	0,'',
	--ʱ����ƣ�
	0,'',0,0)
	
--2.�����������ģ�
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130005',2,2,0,'����',
	--�����ʽ��
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="100" desc="ȫ����Ա"></role></root>',0,
	--����壺
	'�����������뵥','����','�����������뵥����ת����','FM20130042',0,'FM20130042',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>2</flowID></root>',0,0,1,1,'ת��',
				--������ƣ�
	1,N'<root></root>',0,0,0,0,'��֪����',
			--�������˻ؿ��ƣ�
	0,0,'',1,
			--��ֹʵ�����ƣ�
	1,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'��ʦ',
	--ʱ����ƣ�
	0,'',0,0)



--�����豸�ɹ�2���̣�
--1.����
select * from workFlowTemplateFlow where templateID='WF20130006'
delete workFlowTemplateFlow where templateID='WF20130006'
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130006',1,1,1,'����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="20" desc="�̹�" /></root>',0,
	--����壺
	'��д�豸�ɹ����뵥','����','����������д�豸�ɹ����뵥���������豸�ɹ������������̡�','FM20130011',1,'FM20130013',
	'','',
	--������ƣ�
	N'<root></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>2</flowID></root>',0,0,1,0,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	0,'',
	--ʱ����ƣ�
	0,'',0,0)


--2.����������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130006',2,2,0,'��������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="10" desc="����"></role></root>',0,
	--����壺
	'�����豸�ɹ�����','����','ֱ�������鿴�����˲ɹ����ɣ������Ƿ���׼��Ȼ��ת�����ĸ����Ρ�','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>3</flowID></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>1</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'����',
	--ʱ����ƣ�
	0,'',0,0)

--3.����������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130006',3,2,0,'��������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="1" desc="����"></role></root>',0,
	--����壺
	'�����豸�ɹ�����','����','���β鿴�����˲ɹ����ɺͲ�������������������Ƿ���׼��Ȼ�󷢻�������ʵʩ�ɹ��бꡣ','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>2</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>4</flowID></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>2</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'����',
	--ʱ����ƣ�
	0,'',0,0)
	
--4.��ɹ��б������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130006',4,2,1,'��ɹ��б����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="0" desc="���ķ�����"></role></root>',0,
	--����壺
	'��ɹ��б����','�ɹ��б�','�ɷ��������豸�������豸�ɹ����룬�б���ɺ���б������','FM20130012',1, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>3</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>5</flowID></root>',0,0,0,0,'����',
				--������ƣ�
	0,N'<root></root>',0,0,0,0,'',
			--�������˻ؿ��ƣ�
	0,0,'',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	0,'',
	--ʱ����ƣ�
	0,'',0,0)

--5.�ܾ���ʦ������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130006',5,2,0,'�ܾ���ʦ����',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="2" desc="�ܾ���ʦ"></role></root>',0,
	--����壺
	'�ܾ���ʦ����','����','�ܾ���ʦ����б�����Ƿ��������Ҫ�󣬾����Ƿ�ʵʩ�ɹ���Ȼ��ת���ܾ���������','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>4</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root><flowID>6</flowID></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>4</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'�ܾ���ʦ',
	--ʱ����ƣ�
	0,'',0,0)

--6.�ܾ���������
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--�����ʽ��add by lw 2013-3-3
	voteType,		--�ڵ�����ʽ��0->û�б����1->ֻ��ͬ�⣬2->��ͬ�⡱�򡰲�ͬ�⡱��3->ֻ�ܲ�ͬ��
	voteResult,		--�ڵ������Ĭ��ֵ��0->δ�����1->ͬ�⣬2->��ͬ�� add by lw 2013-3-3
	assentButtonName,	--ͬ������ť����
	vetoButtonName,	--��ͬ������ť����
	--�ڵ���������ƣ�
	flowRole, --�ڵ�����˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
										--roleΪ��������ɫ������еĽ�ɫ
										--sysRoleΪϵͳ��ɫ���еĽ�ɫ
										--userΪϵͳ�е��û�
										--exceptUserΪ������Ա
										--flowInUserΪ�ڵ�������Ա��0->��ʹ�ýڵ�������Ա��1->ʹ�ýڵ�������Ա������������ڵ��ת������ж��ڸ߼�����������add by lw 2013-3-3
	limitUserByDoc,	--�Ƿ�ʹ�ù��ĵ�����Լ��������Ա��0->��ʹ�ã�1->ʹ�� add by lw 2013-3-1
	--����壺
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--��������������Ϊ��չʹ�ã���ʱû��ʹ�ã�
	applicationLib, applicationCode,	--��ǰ�ʹ�õĴ���⣨js�ļ������������ļ��������ʹ�õĴ���
	--������ƣ�
			--������ƣ�
	prevFlow,					--����ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	flowInType,					--ת������������1->��һ���룬2->�������3->����� add by lw 2013-3-3
	--inCondition,				--ת�������������ƻ�����ɣ���һ���룬������������
			--������Զ�����
	isAutoProcess,				--�Ƿ�Ϊ�Զ�����ڵ㣨�Զ�����ڵ㲻��Ҫ���棬�ڻ�����߱�ʱ�Զ���������0->���Զ�����ڵ㣬1->�Զ�����ڵ�
	autoProcessType,			--�Զ��������ͣ�add by lw 2013-2-25
													--	0->������
													--	1->ȫ��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬��,�з�����Զ���������һ���ڵ㣨���״̬����
													--	3->ȫ��������Զ���������һ���ڵ㣨���״̬��,��ͬ�����Զ���������һ���ڵ㣨ͬ��״̬����
													--	5->ȫ���������ͶƱ�����������һ���ڵ㣨ͬ�����״̬����Ҫ����Ʊ�����壩��
													--�����Ͻ���������㣬����Ҫ�˹��ж�
	autoProcessCode,			--�Զ�������룺���SQL�洢������䣬����������ڵ��š���Ա��״̬���ò�����δ����
			--�������ƣ�	
				--ͬ����ƣ�
	forwardFlow,				--ǰ���ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectForwardNode,		--�û��Ƿ����ѡ�������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectForwardNode,	--�û��Ƿ���Զ�ѡ�����ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	--outCondition,				--ת��������������δʹ�ã���
	userSelectReceiver,			--�û��Ƿ����ѡ������ˣ�0->����ѡ��1->����ѡ��
	canMultiSelectReceiver,		--�û��Ƿ���Զ�ѡ�����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	forwardButtonName,			--ǰ����ť����
				--������ƣ�
	negationEnable,				--�Ƿ�������:0->������1->����
	negationFlow,				--����ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
	userSelectNegationNode,		--�û��Ƿ����ѡ��������ڵ㣺0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationNode,	--�û��Ƿ���Զ�ѡ�������ڵ㡣��ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	userSelectNegationReceiver,	--�û��Ƿ����ѡ��񶨽����ˣ�0->����ѡ��1->����ѡ�� add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--�û��Ƿ���Զ�ѡ�񶨽����ˡ���ǰһ������Ϊ��ʱ��������ѡ��0->���ܶ�ѡ��1->���Զ�ѡ add by lw 2013-3-3
	negationButtonName,			--�����ť����
			--�������˻ؿ��ƣ�
	isCancelEnable,				--�Ƿ�����ǰ�ýڵ㳷����0->������1->����
	backwardEnable,				--�Ƿ��������:0->������1->����
	backwardButtonName,			--���˰�ť����
	postbackEnable,				--�Ƿ������ת:0->������1->������ת��ָ�����˽�����������ͻؽ����ˣ��������ڵ�����ѭ����ʱ������һ����Ҫ���ж�������
			--��ֹʵ�����ƣ�
	stopEnable,					--�Ƿ�������ֹ����:0->������1->����
	stopFlow,					--��ֹ��ת�ڵ���:����'<root><flowID><flowID></root>'��ʽ���
			--�����̿��ƣ�add by lw 2013-3-1
	subFlowEnable,				--�Ƿ�������������:0->������1->����
	subFlowTemplateID,			--�����̹�����ģ����
	subFlowBtnName,				--���������̵İ�ť���� add by lw2013-3-3
	waitSubFlow,				--�Ƿ�ȴ������̴���:0->���ȴ���1->�ȴ�
	subFlowResult,				--�����̽����0->δ֪��1->ͬ�⣬2->��ͬ��
	subFlowCompleted,			--�������Ƿ�����ɣ�0->δ��ɣ�9->���
	subFlowJumpFlow,			--�����������ת�ڵ�:����'<root><flowID><flowID></root>'��ʽ��š����û�нڵ��������̱��������뱾�ڵ�
			--�Ƿ������ǩ
	isFeedBack,					--�Ƿ������ǩ���:0->������1->����
	feedBackManDesc,			--ǩ������˳�ν
	--ʱ����ƣ�
	isExpire, startTimeType, dayType,expireDay) --ʱ�䵥λ���壺0->��Ȼ�գ�1->������ add by lw 2013-3-1
values('WF20130006',6,9,0,'�ܾ�������',
	--�����ʽ��add by lw 2013-3-3
	0,0,'','',
	--�ڵ���������ƣ�
	N'<root><role id="1" desc="�ܾ���"></role></root>',0,
	--����壺
	'�ܾ�������','����','�ܾ�������б�����Ƿ��������Ҫ�󣬾����Ƿ�ʵʩ�ɹ���','FM20130013',0, 'FM20130013',
	'','',
	--������ƣ�
			--������ƣ�
	N'<root><flowID>5</flowID></root>',1,0,0,'',
			--�������ƣ�	
				--ͬ����ƣ�
	N'<root></root>',0,0,0,0,'ͬ��',
				--������ƣ�
	1,N'<root><flowID>5</flowID></root>',0,0,0,0,'��ͬ��',
			--�������˻ؿ��ƣ�
	0,1,'�˻�',0,
			--��ֹʵ�����ƣ�
	0,N'<root></root>',
			--�����̿��ƣ�add by lw 2013-3-1
	0,'','',0,0,0,'',
			--�Ƿ������ǩ
	1,'�ܾ���',
	--ʱ����ƣ�
	0,'',0,0)




--��ȡʵ����б�
select a.activityID, a.instanceID, a.templateID, i.templateName, i.topic, a.flowID, a.activity, a.sectionName,
	a.receiverID, a.receiver, a.prevFlowID2Status, a.nextFlowID, 
	convert(varchar(10),a.receiveDate,120) receiveDate, 
	--a.completedDate, 
	a.activityStatus, 
--	a.isExpire, a.startTimeType, a.expireDay, a.usedDay
from workflowInstanceActivity a left join workFlowInstance i on a.instanceID = i.instanceID






select a.activityID, a.instanceID, a.templateID, a.flowID, a.activity, a.sectionName,
a.receiverID, a.receiver,a.prevFlowID2Status, a.nextFlowID,
convert(varchar(10),a.receiveDate,120) receiveDate, 
convert(varchar(10),a.completedDate,120) completedDate,a.activityStatus, a.isExpire, a.startTimeType, a.expireDay, a.usedDay 
from WorkflowInstanceActivity a where a.instanceID='QJ20130057' and a.activityID='1'

use hustOA
delete workFlowInstance
select * from workFlowTemplate
select * from eqpApplyInfo

select * from workflowInstanceActivity where templateID='WF20130002' and activityID=282 order by activityID 
update workflowInstanceActivity
set activityStatus=1
where templateID='WF20130002' and activityID=282 

select * from workflowInstanceActivity where instanceID='QJ20130407'
select * from workFlowInstance where instanceID='WF20130226'
select * from thesisPublishApplyInfo where thesisPublishApplyID='WF20130226'



select * from workFlowTemplate where templateID='WF20130002'
select * from workFlowTemplateFlow where templateID='WF20130002'


delete workFlowInstance


