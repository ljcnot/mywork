drop table borrowSingle 
create table borrwSingle(
	borrowSingleID varchar(13) not null,  --��֧����
	borrowDate smalldatetime	not null,	--��֧ʱ��
	employeeID varchar(11)	not null,		--Ա�����
	borrowName varchar(16)	not null,		--��֧������
	position	varchar(10)	not null,	--ְ��
	borrowReason	varchar(200)	not null,	--��֧����
	borrowSum	float	not null,	--���
	approved	varchar(16),	--��׼
	accounting	varchar(16),	--���
	cashier	varchar(16),	--����
	borrowMan	varchar(16),	--��֧��
	department	varchar(16)	not null,	--����
	documentTemplate	int default(0) not null,	---����ģ��
	flowProgress	int default(0) not null,	--��ת����
	IssueSituation	int default(0) not null,	--�������
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

















	





