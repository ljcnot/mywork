use hustOA
/*
	强磁场中心办公系统-工作流管理定义
	author:		卢苇
	CreateDate:	2013-2-21
	UpdateDate: 
*/

--1.工作流模板定义：
--如果要限制使用模板的人员，请设置：templateRole xml null 采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
select * from workFlowTemplate
insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130001','请假条','leaveRequestInfo','300','FM20130001','','','FM20130002',null)

insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130002','设备采购申请表','eqpApplyInfo','301','FM20130010','','','FM20130013',
		N'<root>'+
			'<role id="20" desc="教工" />'+
		'</root>')
	--设备采购申请表只允许教工使用
insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130003','论文发表申请表','thesisPublishApplyInfo','302','FM20130020','','','FM20130022',null)

insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130004','车间加工申请表','processApplyInfo','303','FM20130030','','','FM20130033',null)

insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130005','其他申请表','otherApplyInfo','304','FM20130040','','','FM20130042',null)

--限定为全部教工使用：该流程部长审批环节可以选择部长！
delete workFlowTemplate where templateID='WF20130006'
insert workFlowTemplate(templateID, templateName,formDBTable,formIDMaker,createFormID, completedFormID, stopFormID,showFormID,templateRole)
values('WF20130006','设备采购申请表2','eqpApplyInfo','301','FM20130010','','','FM20130013',
			N'<root>'+
				'<role id="20" desc="教工" />'+
			'</root>')
	--设备采购申请表2只允许教工使用
			
select * from userInfo
select * from sysRole
select * from workFlowRole

--2.工作流角色定义：这个要同系统的用户、角色关联，通过计算可以自动生成人员范围！这是对系统角色的补充！重点是强调人员之间的关系和行政级别
insert workFlowRole(roleID,roleName,roleDesc)
values(0,'公文发起人','公文创建人')
insert workFlowRole(roleID,roleName,roleDesc)
values(1,'中心领导（正职）','中心最高领导，只能是单一人员')--这个可以设置为系统的角色！
insert workFlowRole(roleID,roleName,roleDesc)
values(2,'中心领导（副职）','中心行政领导，只能是单一人员')--这个可以设置为系统的角色！
insert workFlowRole(roleID,roleName,roleDesc)
values(10,'部长','各部门领导，泛指这个级别的所有人员')	--这个可以设置为系统的角色！
insert workFlowRole(roleID,roleName,roleDesc)
values(11,'直属部长','工作流节点处理人员所在部门的领导，只能是单一人员')
insert workFlowRole(roleID,roleName,roleDesc)
values(20,'教工','泛指全体教工')--这个可以设置为系统的角色！
insert workFlowRole(roleID,roleName,roleDesc)
values(21,'部门同事','工作流节点处理人员所在部门的教工，泛指部门全体教工')
insert workFlowRole(roleID,roleName,roleDesc)
values(30,'导师','泛指全体带研究生的导师')--这个可以设置为系统的角色！
insert workFlowRole(roleID,roleName,roleDesc)
values(31,'直属导师','工作流节点处理学生的隶属导师，只能是单一人员')
insert workFlowRole(roleID,roleName,roleDesc)
values(40,'学生','泛指全体学生')--这个可以设置为系统的角色！
insert workFlowRole(roleID,roleName,roleDesc)
values(41,'部门同学','工作流节点处理学生所在部门的其他同学，泛指部门同学')
insert workFlowRole(roleID,roleName,roleDesc)
values(100,'全体人员','全部人员，包括学生和老师')--这个可以设置为系统的角色！
insert workFlowRole(roleID,roleName,roleDesc)
values(101,'直属领导','工作流节点处理人员的直属上级领导，比如学生的直属领导为其导师，教工的直属领导为部长，部长的直属领导为中心领导')
insert workFlowRole(roleID,roleName,roleDesc)
values(102,'属下','工作流节点处理人员的属下，比如部长的属下为部门的老师')
insert workFlowRole(roleID,roleName,roleDesc)
values(999,'系统','系统自动处理角色')

--3.工作流模板表单定义：一个工作流模板允许多个表单
select * from workFlowTemplateForms
delete workFlowTemplateForms
--请假条创建表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile,paperWidth,paperHeight)
values('WF20130001', 'FM20130001',1,'新建请假条','../workFlowDoc/addLeave.html',210,160)
--请假条显示页面：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile,paperWidth,paperHeight)
values('WF20130001', 'FM20130002',0,'显示请假条','../workFlowDoc/leaveDetail.html',210,160)
--请假条编辑表单：
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile,paperWidth,paperHeight)
values('WF20130001', 'FM20130003',1,'编辑请假条','../workFlowDoc/editLeave.html',210,160)

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

--4.工作流模板流程（模板活动）定义：
--定义流程：
select * from workFlowTemplate
select * from workFlowTemplateForms
select * from  workFlowInstance
select * from workflowInstanceActivity
update workflowInstanceActivity
set activityStatus = 0
select * from workFlowTemplateFlow
delete workFlowTemplateFlow

delete workFlowTemplateFlow where templateID='WF20130001' 
--定义请假条流程：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130001',1,1,1,'申请',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="100" desc="全体人员"></role></root>',0,
	--活动定义：
	'填写请假条','编辑','申请人编辑请假条。','FM20130003',1,'FM20130002',
	'','',
	--流向控制：
			--流入控制：
	N'<root></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>2</flowID></root>',0,0,1,0,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	0,'',
	--时间控制：
	0,'',0,0)

insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130001',2,9,0,'审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="101" desc="直属领导"></role></root>',0,
	--活动定义：
	'审批请假条','审批','直属领导查看申请人请假理由，决定是否批准请假。批复后流程终止','FM20130002',0, 'FM20130002',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'老师',
	--时间控制：
	0,'',0,0)


--定义设备采购流程：
--1.发起：
select * from workFlowTemplateFlow where templateID='WF20130002'
delete workFlowTemplateFlow where templateID='WF20130002'
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130002',1,1,1,'申请',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="20" desc="教工" /></root>',0,
	--活动定义：
	'填写设备采购申请单','创建','由申请人填写设备采购申请单，并发起设备采购申请审批流程。','FM20130011',1,'FM20130013',
	'','',
	--流向控制：
	N'<root></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>2</flowID></root>',0,0,0,0,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	0,'',
	--时间控制：
	0,'',0,0)


--2.部长审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130002',2,2,0,'部长审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="11" desc="直属部长"></role></root>',0,
	--活动定义：
	'审批设备采购申请','审批','直属部长查看申请人采购理由，决定是否批准，然后转呈中心副主任。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>3</flowID></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>1</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'部长',
	--时间控制：
	0,'',0,0)

select * from workFlowTemplateFlow where templateID='WF20130002'
--3.主任审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130002',3,2,0,'主任审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="1" desc="主任"></role></root>',0,
	--活动定义：
	'审批设备采购申请','审批','主任查看申请人采购理由和部长的审批意见，决定是否批准，然后发回申请人实施采购招标。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>2</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>4</flowID></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>2</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'主任',
	--时间控制：
	0,'',0,0)
	
--4.填报采购招标情况：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130002',4,2,1,'填报采购招标情况',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="0" desc="公文发起人"></role></root>',0,
	--活动定义：
	'填报采购招标情况','采购招标','由发起人向设备处发出设备采购申请，招标完成后填报招标情况。','FM20130012',1, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>3</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>5</flowID></root>',0,0,0,0,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	0,'',
	--时间控制：
	0,'',0,0)

--5.总经济师审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130002',5,2,0,'总经济师审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="2" desc="总经济师"></role></root>',0,
	--活动定义：
	'总经济师审批','审批','总经济师审核招标情况是否符合申请要求，决定是否实施采购，然后转呈总经理审批。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>4</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>6</flowID></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>4</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'总经济师',
	--时间控制：
	0,'',0,0)

--6.总经理审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130002',6,9,0,'总经理审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="1" desc="总经理"></role></root>',0,
	--活动定义：
	'总经理审批','审批','总经理审核招标情况是否符合申请要求，决定是否实施采购。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>5</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>5</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'总经理',
	--时间控制：
	0,'',0,0)
	


--定义论文发表申请流程：
delete workFlowTemplateFlow where templateID='WF20130003'
--1.发起人编辑：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130003',1,0,1,'申请',
	--表决方式：
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="100" desc="全体人员"></role></root>',0,
	--活动定义：
	'填写论文发表申请单','创建','由申请人填写论文发表申请单，并发起论文发表申请审批流程。','FM20130021',1,'FM20130022',
	'','',
	--流向控制：
			--流入控制：
	'',1,
				--流入后自动处理：
	0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>2</flowID></root>',0,0,0,0,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制
	1,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,N'<root></root>',
			--是否允许会签
	0,'',
	--时间控制：
	0,'',0,0)
	
--2.其他作者审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130003',2,2,0,'审批',
	--表决方式：add by lw 2013-3-3
	2,1,'同意','不同意',
	--节点接收人限制：
	N'<root><role id="100" desc="全体人员"></role></root>',1,
	--活动定义：
	'审批论文发表申请','审批','其他作者查看论文发表情况，决定是否批准。','FM20130022',0, 'FM20130022',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>3</flowID></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>3</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'老师',
	--时间控制：
	0,'',0,0)

	
--3.汇聚其他作者审批意见，并自动决定结果：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130003',3,9,0,'汇聚审批意见',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="999" desc="系统"></role></root>',0,
	--活动定义：
	'汇聚其他作者审批论文发表申请的结果','汇总','汇聚其他作者审批结果，决定是否批准。','FM20130022',0, 'FM20130022',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>2</flowID></root>',2,1,1,'',
			--流出控制：	
				--同意控制：
	N'<root></root>',0,0,0,0,'',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
	0,'',
	--时间控制：
	0,'',0,0)


--定义车间加工申请流程：
--1.发起：
select * from workFlowTemplateFlow where templateID='WF20130004'
delete workFlowTemplateFlow where templateID='WF20130004'
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130004',1,1,1,'申请',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="100" desc="全体人员"></role></root>',0,
	--活动定义：
	'填写车间加工申请单','创建','由申请人填写车间加工申请单，并发起车间加工申请审批流程。','FM20130031',1,'FM20130033',
	'','',
	--流向控制：
			--流入控制：
	N'<root></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>2</flowID></root>',0,0,0,0,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
	0,'',
	--时间控制：
	0,'',0,0)



--2.部长(这个应该是保障部部长，暂时使用各部长)审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130004',2,2,0,'部长审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="11" desc="直属部长"></role></root>',0,
	--活动定义：
	'审批车间加工申请，指派加工人员','审批','直属部长查看申请人加工理由，决定是否批准，然后指派加工人员。','FM20130033',0, 'FM20130033',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>3</flowID></root>',0,0,1,0,'指派',
				--否决控制：
	1,N'<root>1</root>',0,0,0,0,'退回',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'部长',
	--时间控制：
	0,'',0,0)

--3.加工人员填报加工状态：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130004',3,9,1,'加工',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="102" desc="属下"></role></root>',0,
	--活动定义：
	'加工零件，填报加工状态','加工','根据申请人员要求和部长指示加工零件，填报完成情况。','FM20130032',1, 'FM20130033',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>2</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root></root>',0,0,0,0,'完成',
				--否决控制：
	1,N'<root>1</root>',0,0,0,0,'无法完成',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'教工',
	--时间控制：
	0,'',0,0)

select * from workFlowTemplateFlow
delete workFlowTemplateFlow




--定义其他申请流程：
delete workFlowTemplateFlow where templateID='WF20130005'
--1.发起人编辑：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130005',1,1,1,'申请',
	--表决方式：
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="100" desc="全体人员"></role></root>',0,
	--活动定义：
	'填写其他申请单','创建','由申请人填写其他申请单，并发起申请流转流程。','FM20130041',1,'FM20130042',
	'','',
	--流向控制：
			--流入控制：
	'',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>2</flowID></root>',0,0,1,1,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,N'<root></root>',
			--是否允许会签
	0,'',
	--时间控制：
	0,'',0,0)
	
--2.其他作者批阅：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130005',2,2,0,'批阅',
	--表决方式：
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="100" desc="全体人员"></role></root>',0,
	--活动定义：
	'批阅其他申请单','批阅','批阅其他申请单，并转发。','FM20130042',0,'FM20130042',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>2</flowID></root>',0,0,1,1,'转发',
				--否决控制：
	1,N'<root></root>',0,0,0,0,'我知道了',
			--撤销与退回控制：
	0,0,'',1,
			--终止实例控制：
	1,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
	1,'老师',
	--时间控制：
	0,'',0,0)



--定义设备采购2流程：
--1.发起：
select * from workFlowTemplateFlow where templateID='WF20130006'
delete workFlowTemplateFlow where templateID='WF20130006'
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130006',1,1,1,'申请',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="20" desc="教工" /></root>',0,
	--活动定义：
	'填写设备采购申请单','创建','由申请人填写设备采购申请单，并发起设备采购申请审批流程。','FM20130011',1,'FM20130013',
	'','',
	--流向控制：
	N'<root></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>2</flowID></root>',0,0,1,0,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	0,'',
	--时间控制：
	0,'',0,0)


--2.部长审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130006',2,2,0,'部长审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="10" desc="部长"></role></root>',0,
	--活动定义：
	'审批设备采购申请','审批','直属部长查看申请人采购理由，决定是否批准，然后转呈中心副主任。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>1</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>3</flowID></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>1</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'部长',
	--时间控制：
	0,'',0,0)

--3.主任审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130006',3,2,0,'主任审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="1" desc="主任"></role></root>',0,
	--活动定义：
	'审批设备采购申请','审批','主任查看申请人采购理由和部长的审批意见，决定是否批准，然后发回申请人实施采购招标。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>2</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>4</flowID></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>2</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'主任',
	--时间控制：
	0,'',0,0)
	
--4.填报采购招标情况：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130006',4,2,1,'填报采购招标情况',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="0" desc="公文发起人"></role></root>',0,
	--活动定义：
	'填报采购招标情况','采购招标','由发起人向设备处发出设备采购申请，招标完成后填报招标情况。','FM20130012',1, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>3</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>5</flowID></root>',0,0,0,0,'发送',
				--否决控制：
	0,N'<root></root>',0,0,0,0,'',
			--撤销与退回控制：
	0,0,'',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	0,'',
	--时间控制：
	0,'',0,0)

--5.总经济师审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130006',5,2,0,'总经济师审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="2" desc="总经济师"></role></root>',0,
	--活动定义：
	'总经济师审批','审批','总经济师审核招标情况是否符合申请要求，决定是否实施采购，然后转呈总经理审批。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>4</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root><flowID>6</flowID></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>4</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'总经济师',
	--时间控制：
	0,'',0,0)

--6.总经理审批：
insert workFlowTemplateFlow(templateID, flowID, flowType, flowEditAttri, sectionName, 
	--表决方式：add by lw 2013-3-3
	voteType,		--节点表决方式：0->没有表决，1->只能同意，2->“同意”或“不同意”，3->只能不同意
	voteResult,		--节点表决结果默认值：0->未表决，1->同意，2->不同意 add by lw 2013-3-3
	assentButtonName,	--同意表决按钮名称
	vetoButtonName,	--不同意表决按钮名称
	--节点接收人限制：
	flowRole, --节点接收人的角色：采用'<root><role id="100" desc="全体人员"></roleID></root>'格式存放
										--role为工作流角色定义表中的角色
										--sysRole为系统角色表中的角色
										--user为系统中的用户
										--exceptUser为除外人员
										--flowInUser为节点流入人员：0->不使用节点流入人员，1->使用节点流入人员；这样就允许节点回转，这个判定在高级语言中做！add by lw 2013-3-3
	limitUserByDoc,	--是否使用公文的条件约束流出人员：0->不使用，1->使用 add by lw 2013-3-1
	--活动定义：
	activity, activityType, activityDesc, activityFormID, activityFormType, activityShowFormID,
			--以下两个属性作为扩展使用，暂时没有使用！
	applicationLib, applicationCode,	--当前活动使用的代码库（js文件名，或其他文件名），活动使用的代码
	--流向控制：
			--流入控制：
	prevFlow,					--流入节点编号:采用'<root><flowID><flowID></root>'格式存放
	flowInType,					--转入启动条件：1->单一流入，2->与汇流，3->或汇流 add by lw 2013-3-3
	--inCondition,				--转入启动条件：计划改造成：单一流入，与汇流，或汇流
			--流入后自动处理：
	isAutoProcess,				--是否为自动处理节点（自动处理节点不需要界面，在活动条件具备时自动触发）：0->非自动处理节点，1->自动处理节点
	autoProcessType,			--自动处理类型：add by lw 2013-2-25
													--	0->不处理；
													--	1->全部同意则自动流出到下一个节点（同意状态）,有否决则自动流出到下一个节点（否决状态）；
													--	3->全部否决则自动流出到下一个节点（否决状态）,有同意则自动流出到下一个节点（同意状态）；
													--	5->全部到达根据投票结果流出到下一个节点（同意或否决状态，需要根据票数定义）；
													--当以上结果不能满足，则需要人工判断
	autoProcessCode,			--自动处理代码：存放SQL存储过程语句，参数是流入节点编号、人员、状态。该参数暂未启用
			--流出控制：	
				--同意控制：
	forwardFlow,				--前进节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectForwardNode,		--用户是否可以选择流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectForwardNode,	--用户是否可以多选流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	--outCondition,				--转出启动条件：暂未使用！！
	userSelectReceiver,			--用户是否可以选择接收人：0->不能选择，1->可以选择
	canMultiSelectReceiver,		--用户是否可以多选接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	forwardButtonName,			--前进按钮名称
				--否决控制：
	negationEnable,				--是否允许否决:0->不允许，1->允许
	negationFlow,				--否定跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
	userSelectNegationNode,		--用户是否可以选择否定流出节点：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationNode,	--用户是否可以多选否定流出节点。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	userSelectNegationReceiver,	--用户是否可以选择否定接收人：0->不能选择，1->可以选择 add by lw 2013-3-3
	canMultiSelectNegationReceiver,	--用户是否可以多选否定接收人。当前一个条件为真时本条件可选：0->不能多选，1->可以多选 add by lw 2013-3-3
	negationButtonName,			--否决按钮名称
			--撤销与退回控制：
	isCancelEnable,				--是否允许前置节点撤销：0->不允许，1->允许
	backwardEnable,				--是否允许后退:0->不允许，1->允许
	backwardButtonName,			--后退按钮名称
	postbackEnable,				--是否允许回转:0->不允许，1->允许，回转是指接收人将处理意见发送回接收人，当两个节点中有循环的时候这是一个重要的判断条件！
			--终止实例控制：
	stopEnable,					--是否允许终止流程:0->不允许，1->允许
	stopFlow,					--终止跳转节点编号:采用'<root><flowID><flowID></root>'格式存放
			--子流程控制：add by lw 2013-3-1
	subFlowEnable,				--是否允许发起子流程:0->不允许，1->允许
	subFlowTemplateID,			--子流程工作流模板编号
	subFlowBtnName,				--启动子流程的按钮名称 add by lw2013-3-3
	waitSubFlow,				--是否等待子流程处理:0->不等待，1->等待
	subFlowResult,				--子流程结果：0->未知，1->同意，2->不同意
	subFlowCompleted,			--子流程是否处理完成：0->未完成，9->完成
	subFlowJumpFlow,			--子流程完成跳转节点:采用'<root><flowID><flowID></root>'格式存放。如果没有节点则将子流程表决结果送入本节点
			--是否允许会签
	isFeedBack,					--是否允许会签意见:0->不允许，1->允许
	feedBackManDesc,			--签署意见人称谓
	--时间控制：
	isExpire, startTimeType, dayType,expireDay) --时间单位定义：0->自然日，1->工作日 add by lw 2013-3-1
values('WF20130006',6,9,0,'总经理审批',
	--表决方式：add by lw 2013-3-3
	0,0,'','',
	--节点接收人限制：
	N'<root><role id="1" desc="总经理"></role></root>',0,
	--活动定义：
	'总经理审批','审批','总经理审核招标情况是否符合申请要求，决定是否实施采购。','FM20130013',0, 'FM20130013',
	'','',
	--流向控制：
			--流入控制：
	N'<root><flowID>5</flowID></root>',1,0,0,'',
			--流出控制：	
				--同意控制：
	N'<root></root>',0,0,0,0,'同意',
				--否决控制：
	1,N'<root><flowID>5</flowID></root>',0,0,0,0,'不同意',
			--撤销与退回控制：
	0,1,'退回',0,
			--终止实例控制：
	0,N'<root></root>',
			--子流程控制：add by lw 2013-3-1
	0,'','',0,0,0,'',
			--是否允许会签
	1,'总经理',
	--时间控制：
	0,'',0,0)




--获取实例活动列表：
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


