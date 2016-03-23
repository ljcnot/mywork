create table ProjectRegistration(
projectID	varchar(13)	not	null,	--项目编号
projectName	varchar(40)	not	null,	--项目名称
projectLocation	varchar(50)	not	null,	--项目所在地
UndertakingDepartment	varchar(30)	not	null,	--承接部门
customerID	varchar(16)	not	null,	--委托单位
customerName	varchar(30)	not	null,	--委托单位
customerAddress	varchar(30)	not	null,	--委托单位办公地点
SuperiorUnitName	varchar(30)	not	null,	--上级单位名称
contractAmount	numeric(12,2)	not	null,	--合同金额
amountType	smallint	not	null,	--合同金额类型
netAmount	money	not	null,	--净合同金额
signID	varchar(13)	not	null,	--合同编号
signDate	smalldatetime	not	null,--	合同签订日期
signerID	varchar(14)	not	null,	--签订人ID
signer	varchar(10)	not	null,	--签订人
startDate	smalldatetime	null,	--开工日期
expectedDuration	int	null,	--预算工期
completeDate	smalldatetime	null,	--实际完工日期
managerID	varchar(14)	null,	--负责人ID
manager	varchar(30)	null,	--负责人
Audit	varchar(30)	null,	--审核人
progress	numeric(6,2)	null,	--进度
statusThat	varchar(10)	null,	--状态说明
collectedAmount	money	not	null,	--已收款
uncollectedAmount	money	not	null,	--尾款
remarks	varchar(120)	not	null,
collectedDetail	xml	null,	--回款情况
projectDesc	nvarchar(1000)	null,	--项目简述
approvedValue	money	not	null,	--总重核定值
Approveder	varchar(30)	not	null,	--核定人
approvedDate	smalldatetime	not	null,	--核定日期
ProjectItems	varchar(200)	not	null,	--项目事项纪录
leaderComment	varchar(100)	not	null,	--领导批注
	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10)				--当前正在锁定编辑的人工号
)

drop table ProjectPersonnel 
create table ProjectPersonnel(
ProjectPerID	varchar(16)	not	null,	--项目人员ID
projectName	varchar(200)	not	null,	--项目名称
projectID	varchar(16)	not	null,	--项目编号
employeesID	varchar(14)	not	null,	--员工ID
employeeName	varchar(20)	not	null,	--员工姓名
ProjectJob	varchar(20)	not	null,	--项目岗位
	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10)				--当前正在锁定编辑的人工号
)


drop table ProjectRevenueCost
create	table ProjectRevenueCost(
ProjectRevenueCostID	varchar(18)	not null,	--项目收入成本编号
projectID	varchar(14)	not	null,	--项目编号
costName	varchar(100)	not	null,	--费用名称
spending	money	not	null,	--支出
income	money	not	null,	--收入
note	navarchar(60)	not	null,	--备注
	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10)				--当前正在锁定编辑的人工号
)


drop table ProjectQualityInspection
create	table ProjectQualityInspection(
qualityCheckID	varchar(16)	not	null,	--质量检查ID
projectID	varchar(14)	not	null,	--项目编号
projectName	varchar(50)	not	null,	--项目名称
QCID	varchar(14)	not	null,	--质检人员ID
QC	varchar(20)	not	null,	--质检人员
checkoPinion	varchar(500)	not	null,	--检查意见
note	varchar(500)	not	null,	--备注
checkdate	datetime	not	null,	--检查时间
projectManager	varchar(13)	not	null,	--项目负责人
appointor	varchar(10)	not	null,	--项目任命人
projectManagerPreliminaryAssessment	varchar(10)	not	null,	--项目负责人初评
projectManagerExamine varchar(10)	not	null,	--项目负责人审核
projectManagerDate	datetime	null,	--项目负责人审核日期
EngineerExamine	varchar(10)	null,	--主任工程师审核
EngineerPreliminaryAssessment	varchar(10)	null,	--主任工程师初评
EngineerExamineDate	varchar(10)	null,	--主任工程师审核日期
chiefEngineerExamine	varchar(10)	null,	--总工程师审核
chiefEngineerPreliminaryAssessment	varchar(10)	null,	--总工程师初评
chiefEngineerExamineDate	datetime	null,	--总工程师审核日期
DeputyChiefEngineerExamine	varchar(10)	null,	--副总工程师审核
	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10)				--当前正在锁定编辑的人工号
)


drop table ChiefEngineerAudit
create table ChiefEngineerAudit(
qualityCheckID	varchar(16)	not	null,	--质量检查ID
ReviewProject	varchar(100)	not	null,	--审核项目
ReviewProject	varchar(500)	not	null,	--审核问题记载
auditConclusion	varchar(100)	not	null,	--审核结论
)

drop table projectManager
create table projectManager(
qualityCheckID	varchar(16)	not	null,	--质量检查ID
number	int	not	null,	--序号
datatype	int	not null,	--资料类型
SelfCheckingProblem	varchar(200)	not	null,	--自检问题记录
Result	varchar(200)	not	null,	--处理结果
changed	varchar(200)	not	null,	--是否已改

)

drop table projectManager
create table projectManager(
qualityCheckID	varchar(16)	not	null,	--质量检查ID
qualityCheck_detailsID	varchar(16)	not	null,	--项目审核ID

)