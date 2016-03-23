create table ProjectRegistration(
projectID	varchar(13)	not	null,	--��Ŀ���
projectName	varchar(40)	not	null,	--��Ŀ����
projectLocation	varchar(50)	not	null,	--��Ŀ���ڵ�
UndertakingDepartment	varchar(30)	not	null,	--�нӲ���
customerID	varchar(16)	not	null,	--ί�е�λ
customerName	varchar(30)	not	null,	--ί�е�λ
customerAddress	varchar(30)	not	null,	--ί�е�λ�칫�ص�
SuperiorUnitName	varchar(30)	not	null,	--�ϼ���λ����
contractAmount	numeric(12,2)	not	null,	--��ͬ���
amountType	smallint	not	null,	--��ͬ�������
netAmount	money	not	null,	--����ͬ���
signID	varchar(13)	not	null,	--��ͬ���
signDate	smalldatetime	not	null,--	��ͬǩ������
signerID	varchar(14)	not	null,	--ǩ����ID
signer	varchar(10)	not	null,	--ǩ����
startDate	smalldatetime	null,	--��������
expectedDuration	int	null,	--Ԥ�㹤��
completeDate	smalldatetime	null,	--ʵ���깤����
managerID	varchar(14)	null,	--������ID
manager	varchar(30)	null,	--������
Audit	varchar(30)	null,	--�����
progress	numeric(6,2)	null,	--����
statusThat	varchar(10)	null,	--״̬˵��
collectedAmount	money	not	null,	--���տ�
uncollectedAmount	money	not	null,	--β��
remarks	varchar(120)	not	null,
collectedDetail	xml	null,	--�ؿ����
projectDesc	nvarchar(1000)	null,	--��Ŀ����
approvedValue	money	not	null,	--���غ˶�ֵ
Approveder	varchar(30)	not	null,	--�˶���
approvedDate	smalldatetime	not	null,	--�˶�����
ProjectItems	varchar(200)	not	null,	--��Ŀ�����¼
leaderComment	varchar(100)	not	null,	--�쵼��ע
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10)				--��ǰ���������༭���˹���
)

drop table ProjectPersonnel 
create table ProjectPersonnel(
ProjectPerID	varchar(16)	not	null,	--��Ŀ��ԱID
projectName	varchar(200)	not	null,	--��Ŀ����
projectID	varchar(16)	not	null,	--��Ŀ���
employeesID	varchar(14)	not	null,	--Ա��ID
employeeName	varchar(20)	not	null,	--Ա������
ProjectJob	varchar(20)	not	null,	--��Ŀ��λ
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10)				--��ǰ���������༭���˹���
)


drop table ProjectRevenueCost
create	table ProjectRevenueCost(
ProjectRevenueCostID	varchar(18)	not null,	--��Ŀ����ɱ����
projectID	varchar(14)	not	null,	--��Ŀ���
costName	varchar(100)	not	null,	--��������
spending	money	not	null,	--֧��
income	money	not	null,	--����
note	navarchar(60)	not	null,	--��ע
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10)				--��ǰ���������༭���˹���
)


drop table ProjectQualityInspection
create	table ProjectQualityInspection(
qualityCheckID	varchar(16)	not	null,	--�������ID
projectID	varchar(14)	not	null,	--��Ŀ���
projectName	varchar(50)	not	null,	--��Ŀ����
QCID	varchar(14)	not	null,	--�ʼ���ԱID
QC	varchar(20)	not	null,	--�ʼ���Ա
checkoPinion	varchar(500)	not	null,	--������
note	varchar(500)	not	null,	--��ע
checkdate	datetime	not	null,	--���ʱ��
projectManager	varchar(13)	not	null,	--��Ŀ������
appointor	varchar(10)	not	null,	--��Ŀ������
projectManagerPreliminaryAssessment	varchar(10)	not	null,	--��Ŀ�����˳���
projectManagerExamine varchar(10)	not	null,	--��Ŀ���������
projectManagerDate	datetime	null,	--��Ŀ�������������
EngineerExamine	varchar(10)	null,	--���ι���ʦ���
EngineerPreliminaryAssessment	varchar(10)	null,	--���ι���ʦ����
EngineerExamineDate	varchar(10)	null,	--���ι���ʦ�������
chiefEngineerExamine	varchar(10)	null,	--�ܹ���ʦ���
chiefEngineerPreliminaryAssessment	varchar(10)	null,	--�ܹ���ʦ����
chiefEngineerExamineDate	datetime	null,	--�ܹ���ʦ�������
DeputyChiefEngineerExamine	varchar(10)	null,	--���ܹ���ʦ���
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10)				--��ǰ���������༭���˹���
)


drop table ChiefEngineerAudit
create table ChiefEngineerAudit(
qualityCheckID	varchar(16)	not	null,	--�������ID
ReviewProject	varchar(100)	not	null,	--�����Ŀ
ReviewProject	varchar(500)	not	null,	--����������
auditConclusion	varchar(100)	not	null,	--��˽���
)

drop table projectManager
create table projectManager(
qualityCheckID	varchar(16)	not	null,	--�������ID
number	int	not	null,	--���
datatype	int	not null,	--��������
SelfCheckingProblem	varchar(200)	not	null,	--�Լ������¼
Result	varchar(200)	not	null,	--������
changed	varchar(200)	not	null,	--�Ƿ��Ѹ�

)

drop table projectManager
create table projectManager(
qualityCheckID	varchar(16)	not	null,	--�������ID
qualityCheck_detailsID	varchar(16)	not	null,	--��Ŀ���ID

)