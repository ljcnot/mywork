









-- ��Ʊ�����	
drop table VATinvoice 
create table VATinvoice(
CustomerID	varchar(14)	not null,	--�ͻ����
customerUnit	varchar(20)	not null,	--�ͻ���λ
projectName varchar(20)	not null,	--��Ŀ����
projectID	varchar(14)	not	null,	--��Ŀ���
billingDate	smalldatetime	not null,	--��Ʊ����
billingAmount	float	not null,	--��Ʊ���
invoiceType	int	not	null,	--��Ʊ����
WhetherCancel	int not null,	--�Ƿ�����
invoiceID	varchar(14)	not	null,	--��Ʊ���
applyDate	smalldatetime	not	null,	--��������
applicantDept	varchar(20)	not	null,	--���벿��
applyDrawer	varchar(10)	not null,	--���뿪Ʊ��
drawer	varchar(10)	not	null,	--��Ʊ��
paymentMode	varchar(10)	not	null,	--�ؿʽ
paymentDate	smalldatetime	not	null,	--�ؿ�����
paymentAmount	float	not	null,	--�ؿ���
accountsReceivable	float	not	null,	--Ӧ���˿�
taxAmount	float	not	null,	--Ӧ��˰��
paidTaxAmount	float not	null,	--ʵ��˰��
payableVAT	float	null,	--Ӧ����ֵ����˰
paidAddTax	float	null,	--ʵ�ɸ���˰
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
















