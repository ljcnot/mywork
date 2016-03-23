use epdc211
/*
	����豸������Ϣϵͳ-�ɹ��ƻ������洢����
	author:		¬έ
	�����ݿ�ӳ��γ��������־־��õ�����Ϣϵͳ-�������������ֲ
	author:		¬έ
	CreateDate:	2010-03-26
	UpdateDate: 2011-2-9����Ա�����֤���޸�Ϊ���ţ�
*/


--�������������Ĺ����
select * from reportCenter
delete reportCenter
drop table reportCenter
CREATE TABLE [dbo].[reportCenter](
	reportNum varchar(12) not null,	--������������
	reportType int not null,		--��������������:���õ�900��901�Ŵ����ֵ�
											--����������
											--901->��ѧ���������豸��
											--902->��ѧ���������豸�����䶯�����
											--903->���������豸��
	theTitle nvarchar(100) null,		--�������
	theYear varchar(4) null,			--ͳ�����
	totalStartDate smalldatetime null,	--ͳ�ƿ�ʼ����
	totalEndDate smalldatetime null,	--ͳ�ƽ�������

	makeUnit nvarchar(50) null,			--�Ʊ�λ
	makeDate smalldatetime null,		--�Ʊ�����
	makerID varchar(10) null,			--�Ʊ��˹���
	maker nvarchar(30) null,			--�Ʊ���
 CONSTRAINT [PK_reportCenter] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[reportType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

select * from useUnit where uCode='12217'

select * from eDepartCode
--����������λ����ת����
drop TABLE [dbo].[eDepartCode]
CREATE TABLE [dbo].[eDepartCode](
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к�
	clgCode char(3) not null,			--Ժ������
	clgName nvarchar(30) not null,		--Ժ������	
	uCode varchar(8) not null,			--ʹ�õ�λ����
	uName nvarchar(30) null,			--ʹ�õ�λ����
	isUsed char(1) default('N'),		--�Ƿ�ʹ�ã����Ϊ��ʹ�ã��򲻲������������ļ���
	
	--����Ϊ��Ӧ�Ľ���������ʹ�õĴ�������ƣ�
	eUCode varchar(8) null,				--ӳ���ʹ�õ�λ����
	eUName nvarchar(30) null,			--ӳ���ʹ�õ�λ����
	switchUName xml null,				--��ʹ�÷��������������ӳ�䣺������������Ҫ�󣡾���һЩ��λ����ѧ���͡����С�����ʲ��ֱ���ڲ�ͬ�ĵ�λ������
	remark nvarchar(25) null,			--��ע

	--�����ˣ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
PRIMARY KEY NONCLUSTERED 
(
	[clgCode] ASC,
	[uCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

select * from e
update eDepartCode
set eUCode = e.eUCode, eUName = e.eUName, switchUName = e.switchUName, remark = e.remark
from eDepartCode d left join e on d.uCode = e.uCode

update eDepartCode
set isUsed = 'Y'
where eUCode is not null

select * from eDepartCode
insert eDepartCode(clgCode, clgName, uCode, uName, isUsed, eUName, switchUName, remark, 
				createManID, createManName, createTime)
select clgCode, clgName, uCode, uName, isUsed, eUName, switchUName, remark, 
				createManID, createManName, createTime
from WHGXYepdc211.dbo.eDepartCode

--901������һ ��ѧ���������豸������ֻͳ��ʹ�÷���Ϊ����ѧ����У�������ѧ��������ʵ�ʹ�õ�λ���豸����
--�����е������豸��ָ��ѧ�����е�λ�У������������800Ԫ���������ϣ�ʹ�÷���Ϊ��ѧ����е������豸��
--���ߵ�ѧУ�̶��ʲ����༰���롷�е�01�ࣨ���ݼ��������02�ࣨ���ؼ�ֲ���11�ࣨͼ�飩��13�ࣨ�Ҿߣ���15�ࣨ����װ�ߣ���16�ࣨ���󣩲�����
--�ϱ���Χ������������Ϊ�����豸�ĸ����ϱ�������Ϊ��̨���ϱ���
--�ϴ���2012-10-3���������ڸ�ʽֻȡ����-�¡���Ժ�����Ʋ���Ҫ
--
--������Դ��
select * from fundSrc
select * from equipmentList where fCode='1'
drop TABLE [dbo].[rptBase1]
CREATE TABLE [dbo].[rptBase1](
	reportNum varchar(12) not null,			--�����������
	reportType int not null default(1),		--�������������:�����õ�900�Ŵ����ֵ�
											--����������
											--901->��ѧ���������豸��


	universityCode char(5) not null,		--ѧУ���룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ5��
												--���������涨�ĸߵ�ѧУ5λ����������������ɷ����й�����ͳ����վ��http://www.stats.edu.cn/��
	universityName nvarchar(60) not null,	--ѧУ����:�ϱ�������Ҫ���ֶΣ�


	eCode char(8) not null,					--�������(�豸���)�����ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ѧУ�ڲ�ʹ�õ������豸��ţ��ڱ�У�ھ���Ψһ�ԡ�
	eTypeCode char(8) not null,				--3.����ţ������������ţ������ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ָ�������豸����ͳһ����ı��룬
												--���������߽�˾�䷢�ġ��ߵ�ѧУ�̶��ʲ����༰���롷��д�������������ӣ�
												--���޶�Ӧ���룬����һ�����룬����ĩλ�00������8λ��
	eName nvarchar(30) not null,			--�������ƣ���������������/�豸���ƣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ30���ú��ֱ�ʾ������Ϊ�գ��롶�ߵ�ѧУ�̶��ʲ����༰���롷�еķ��������Ӧ������һ�£�
												--���޶�Ӧ����,����д�����豸���Ƶĺ������ƻ�淶�����ķ������ơ�
	eModel nvarchar(20) not null,			--�ͺţ����ݸ�ʽΪ�ַ��ͣ�����Ϊ20���������豸���ƻ�˵�����ʾ��д���ͺŲ���������豸����ѧУ�����ź�ʵ���*���������ֶγ���Ӧ��ȡ��Ҫ������д��
	eFormat nvarchar(30) not null,			--��񣺹�����ݸ�ʽΪ�ַ��ͣ�����Ϊ30��ָ�����豸�Ĺ�����Ҫ����ָ�ꡣ�����������豸����ѧУ�����ź�ʵ���*���������ֶγ���Ӧ��ȡ��Ҫ������д��
	fCode char(1) not null,					--������Դ�����ݸ�ʽΪ�ַ��ͣ�����Ϊ1����������д��1�����ã�2��������ָ��Ȼ�ˡ����˻���������֯��Ը�޳���ѧУ�����������豸��
																							-- 3�����ƣ���Ҫ������������ơ��ӹ�������������豸��
																							-- 4��У����룺��ǰ�������������Դ��
	cCode char(3) not null,					--�����룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ3��ָ�����豸���������Ҵ��룬�Բ�Ʒ���Ʊ�ʾ�Ĳ���Ϊ׼��������������͵������ƴ��롷��GB/T 2659-2000����д�������벻����000����
	totalAmount numeric(12,2) null,			--���ۣ��豸�ܼۣ������ݸ�ʽΪ��ֵ�ͣ�����Ϊ12��ָ�����豸�����������ڵ��ܼ۸���ԪΪ��λ��������λС����
	acceptDate char(6) null,				--�������ڣ��������ڣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ6��ָ�����豸��У�������ڡ�ǰ��λ��ʾ�꣬����λ��ʾ�¡�
	curEqpStatus char(1) not null,			--��״�룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ1
											--1�����ã�ָ����ʹ�õ������豸��
											--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
											--3�����ޣ�ָ���޻���������������豸��
											--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
											--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
											--9����������״����������豸��
	aCode char(1) not null,					--ʹ�÷������ݸ�ʽΪ�ַ��ͣ�����Ϊ1��ָ�����豸��ʹ�����ʣ���������д��1����ѧΪ����2������Ϊ������ĳ̨�����豸��ѧ�����ʹ�û�ʱ��ռһ�룬����롰2����
	
	eUCode varchar(10) not null,			--��λ��ţ�Ϊ��λӳ����е��µ�λ���룩�����ݸ�ʽΪ�ַ��ͣ�����Ϊ10��
											--ָѧУ�Ա�������豸���ڵ�λ��ţ�У�ھ���Ψһ�ԡ�
	eUName nvarchar(50) not null,			--��λ���ƣ�Ϊ��λӳ����е��µ�λ���ƣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ50��
											--ָ�����豸���ڵ�λ���ơ�
 CONSTRAINT [PK_rptBase1] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[eCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[rptBase1]  WITH CHECK ADD  CONSTRAINT [FK_rptBase1_reportCenter] FOREIGN KEY([reportNum], [reportType])
REFERENCES [dbo].[reportCenter] ([reportNum], [reportType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[rptBase1] CHECK CONSTRAINT [FK_rptBase1_reportCenter]


--����һ�ļ�鱨�棺
drop TABLE [dbo].[rptBase1CheckDetail]
CREATE TABLE [dbo].[rptBase1CheckDetail](
	checkManID varchar(10) not null,		--����˹���
	checkManName varchar(30) not null,		--���������
	checkTime smalldatetime default(getdate()),--���ʱ��
	errorType nvarchar(10) not null,		--�������
	errorDesc nvarchar(50) null,			--��������
	
	reportNum varchar(12) not null,			--������
	reportType int not null default(901),	--��������:�����õ�900�Ŵ����ֵ�
											--����������--901->��ѧ���������豸��

	universityCode char(5) not null,		--ѧУ���룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ5��
											--���������涨�ĸߵ�ѧУ5λ����������������ɷ����й�����ͳ����վ��http://www.stats.edu.cn/��
	universityName nvarchar(60) not null,	--ѧУ����:�ϱ�������Ҫ���ֶΣ�


	eCode char(8) not null,					--�������(�豸���)�����ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ѧУ�ڲ�ʹ�õ������豸��ţ��ڱ�У�ھ���Ψһ�ԡ�
	eTypeCode char(8) not null,				--3.����ţ������������ţ������ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ָ�������豸����ͳһ����ı��룬
												--���������߽�˾�䷢�ġ��ߵ�ѧУ�̶��ʲ����༰���롷��д�������������ӣ�
												--���޶�Ӧ���룬����һ�����룬����ĩλ�00������8λ��
	eName nvarchar(30) not null,			--�������ƣ���������������/�豸���ƣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ30���ú��ֱ�ʾ������Ϊ�գ��롶�ߵ�ѧУ�̶��ʲ����༰���롷�еķ��������Ӧ������һ�£�
												--���޶�Ӧ����,����д�����豸���Ƶĺ������ƻ�淶�����ķ������ơ�
	eModel nvarchar(20) not null,			--�ͺţ����ݸ�ʽΪ�ַ��ͣ�����Ϊ20���������豸���ƻ�˵�����ʾ��д���ͺŲ���������豸����ѧУ�����ź�ʵ���*���������ֶγ���Ӧ��ȡ��Ҫ������д��
	eFormat nvarchar(30) not null,			--��񣺹�����ݸ�ʽΪ�ַ��ͣ�����Ϊ30��ָ�����豸�Ĺ�����Ҫ����ָ�ꡣ�����������豸����ѧУ�����ź�ʵ���*���������ֶγ���Ӧ��ȡ��Ҫ������д��
	fCode char(1) not null,					--������Դ�����ݸ�ʽΪ�ַ��ͣ�����Ϊ1����������д��1�����ã�2��������ָ��Ȼ�ˡ����˻���������֯��Ը�޳���ѧУ�����������豸��
																							-- 3�����ƣ���Ҫ������������ơ��ӹ�������������豸��
																							-- 4��У����룺��ǰ�������������Դ��
	cCode char(3) not null,					--�����룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ3��ָ�����豸���������Ҵ��룬�Բ�Ʒ���Ʊ�ʾ�Ĳ���Ϊ׼��������������͵������ƴ��롷��GB/T 2659-2000����д�������벻����000����
	totalAmount numeric(12,2) null,			--���ۣ��豸�ܼۣ������ݸ�ʽΪ��ֵ�ͣ�����Ϊ12��ָ�����豸�����������ڵ��ܼ۸���ԪΪ��λ��������λС����
	acceptDate char(6) null,				--�������ڣ��������ڣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ6��ָ�����豸��У�������ڡ�ǰ��λ��ʾ�꣬����λ��ʾ�¡�
	curEqpStatus char(1) not null,			--��״�룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ1
											--1�����ã�ָ����ʹ�õ������豸��
											--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
											--3�����ޣ�ָ���޻���������������豸��
											--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
											--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
											--9����������״����������豸��
	aCode char(1) not null,					--ʹ�÷������ݸ�ʽΪ�ַ��ͣ�����Ϊ1��ָ�����豸��ʹ�����ʣ���������д��1����ѧΪ����2������Ϊ������ĳ̨�����豸��ѧ�����ʹ�û�ʱ��ռһ�룬����롰2����
	
	eUCode varchar(10) not null,			--��λ��ţ�Ϊ��λӳ����е��µ�λ���룩�����ݸ�ʽΪ�ַ��ͣ�����Ϊ10��
											--ָѧУ�Ա�������豸���ڵ�λ��ţ�У�ھ���Ψһ�ԡ�
	eUName nvarchar(50) not null,			--��λ���ƣ�Ϊ��λӳ����е��µ�λ���ƣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ50��
											--ָ�����豸���ڵ�λ���ơ�
 CONSTRAINT [PK_rptBase1CheckDetail] PRIMARY KEY CLUSTERED 
(
	[checkManID] ASC,
	[reportNum] Asc,
	[errorType] ASC,
	[eCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--902������� ��ѧ���������豸�����䶯���������ֻͳ��ʹ�÷���Ϊ����ѧ����У�������ѧ��������ʵ�ʹ�õ�λ���豸����
--�����е������豸��ָ��ѧ�����е�λ�У������������800Ԫ���������ϣ�ʹ�÷���Ϊ��ѧ����е������豸��
--���ߵ�ѧУ�̶��ʲ����༰���롷�е�01�ࣨ���ݼ��������02�ࣨ���ؼ�ֲ���11�ࣨͼ�飩��13�ࣨ�Ҿߣ���15�ࣨ����װ�ߣ���16�ࣨ���󣩲�����
--�ϱ���Χ:����������Ϊ�����豸�ĸ����ϱ�������Ϊ��̨���ϱ����������ԪΪ��λ��������λС����
drop TABLE [dbo].[rptBase2]
CREATE TABLE [dbo].[rptBase2](
	reportNum varchar(12) not null,			--�����������
	reportType int not null default(1),		--�������������:�����õ�900�Ŵ����ֵ�
											--����������
											--901->��ѧ���������豸��

	universityCode char(5) not null,		--ѧУ����
	universityName nvarchar(60) not null,	--ѧУ����
	
	--��ѧ��ĩʵ������
	eSumNumLastYear int not null,				--̨���ϼ�
	eSumAmountLastYear numeric(18,2) not null,	--���ϼ�
	bESumNumLastYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bESumAmountLastYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�
	
	--��ѧ����������
	eIncNumCurYear int not null,				--̨���ϼ�
	eIncAmountCurYear numeric(18,2) not null,	--���ϼ�
	bEIncNumCurYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bEIncAmountCurYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�
--Ҫ���Ǵ�������λ����ѧ���е�λ�ĵ������⣡

	--��ѧ���������
	eDecNumCurYear int not null,				--̨���ϼ�
	eDecAmountCurYear numeric(18,2) not null,	--���ϼ�
	bEDecNumCurYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bEDecAmountCurYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�

	--��ѧ��ĩʵ������
	eSumNumCurYear int not null,				--̨���ϼ�
	eSumAmountCurYear numeric(18,2) not null,	--���ϼ�
	bESumNumCurYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bESumAmountCurYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�
 CONSTRAINT [PK_rptBase2] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[rptBase2]  WITH CHECK ADD  CONSTRAINT [FK_rptBase2_reportCenter] FOREIGN KEY([reportNum], [reportType])
REFERENCES [dbo].[reportCenter] ([reportNum], [reportType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[rptBase2] CHECK CONSTRAINT [FK_rptBase2_reportCenter]

--add by lw 2013-4-3
--����� ��ʹ�õ�λ����Ľ�ѧ���������豸�����䶯���������ֻͳ��ʹ�÷���Ϊ����ѧ����У�������ѧ��������ʵ�ʹ�õ�λ���豸����
--�����е������豸��ָ��ѧ�����е�λ�У������������800Ԫ���������ϣ�ʹ�÷���Ϊ��ѧ����е������豸��
--���ߵ�ѧУ�̶��ʲ����༰���롷�е�01�ࣨ���ݼ��������02�ࣨ���ؼ�ֲ���11�ࣨͼ�飩��13�ࣨ�Ҿߣ���15�ࣨ����װ�ߣ���16�ࣨ���󣩲�����
--�ϱ���Χ:����������Ϊ�����豸�ĸ����ϱ�������Ϊ��̨���ϱ����������ԪΪ��λ��������λС����
drop TABLE [dbo].[rptBase2Exp]
CREATE TABLE [dbo].[rptBase2Exp](
	reportNum varchar(12) not null,			--�����������
	reportType int not null default(1),		--�������������:�����õ�900�Ŵ����ֵ�
											--����������
											--901->��ѧ���������豸��

	universityCode char(5) not null,		--ѧУ����
	universityName nvarchar(60) not null,	--ѧУ����
	eUCode varchar(8) not null,					--ӳ���ʹ�õ�λ����
	eUName nvarchar(30) not null,				--ӳ���ʹ�õ�λ����
	
	--��ѧ��ĩʵ������
	eSumNumLastYear int not null,				--̨���ϼ�
	eSumAmountLastYear numeric(18,2) not null,	--���ϼ�
	bESumNumLastYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bESumAmountLastYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�
	
	--��ѧ����������
	eIncNumCurYear int not null,				--̨���ϼ�
	eIncAmountCurYear numeric(18,2) not null,	--���ϼ�
	bEIncNumCurYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bEIncAmountCurYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�
--Ҫ���Ǵ�������λ����ѧ���е�λ�ĵ������⣡

	--��ѧ���������
	eDecNumCurYear int not null,				--̨���ϼ�
	eDecAmountCurYear numeric(18,2) not null,	--���ϼ�
	bEDecNumCurYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bEDecAmountCurYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�

	--��ѧ��ĩʵ������
	eSumNumCurYear int not null,				--̨���ϼ�
	eSumAmountCurYear numeric(18,2) not null,	--���ϼ�
	bESumNumCurYear int not null,				--10��Ԫ�����������豸̨���ϼ�
	bESumAmountCurYear numeric(18,2) not null,	--10��Ԫ�����������豸���ϼ�
 CONSTRAINT [PK_rptBase2Exp] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[eUCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--903�������� ���������豸������ֻͳ��ʹ�÷���Ϊ����ѧ����У�������ѧ��������ʵ�ʹ�õ�λ���豸����
--���������豸��ָ���ߵ�ѧУ�̶��ʲ����༰���롷��03�ࣨ�����Ǳ��е����������40��Ԫ���������ϡ�ʹ�÷���Ϊ��ѧ����е������豸��
--����������Ϊ�����豸�ĸ����ϱ�������Ϊ��̨���ϱ���
--������ԴӦ���ǻ���һ��03���40��Ԫ���ϵ��豸
drop TABLE [dbo].[rptBase3]
CREATE TABLE [dbo].[rptBase3](
	reportNum varchar(12) not null,			--�����������
	reportType int not null default(1),		--�������������:�����õ�900�Ŵ����ֵ�
											--����������
											--901->��ѧ���������豸��


	universityCode char(5) not null,		--ѧУ����
	universityName nvarchar(60) not null,	--ѧУ����:���ϱ��ֶ�

	eCode char(8) not null,					--�������(�豸���)�����ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ѧУ�ڲ�ʹ�õ������豸��ţ��ڱ�У�ھ���Ψһ�ԡ�
	eTypeCode char(8) not null,				--3.����ţ������������ţ������ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ָ�������豸����ͳһ����ı��룬
												--���������߽�˾�䷢�ġ��ߵ�ѧУ�̶��ʲ����༰���롷��д�������������ӣ�
												--���޶�Ӧ���룬����һ�����룬����ĩλ�00������8λ��
	eName nvarchar(30) not null,			--�������ƣ���������������/�豸���ƣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ30���ú��ֱ�ʾ������Ϊ�գ��롶�ߵ�ѧУ�̶��ʲ����༰���롷�еķ��������Ӧ������һ�£�
												--���޶�Ӧ����,����д�����豸���Ƶĺ������ƻ�淶�����ķ������ơ�
	totalAmount numeric(12,2) null,			--���ۣ��豸�ܼۣ������ݸ�ʽΪ��ֵ�ͣ�����Ϊ12��ָ�����豸�����������ڵ��ܼ۸���ԪΪ��λ��������λС����
	eModel nvarchar(20) not null,			--�ͺţ����ݸ�ʽΪ�ַ��ͣ�����Ϊ20���������豸���ƻ�˵�����ʾ��д���ͺŲ���������豸����ѧУ�����ź�ʵ���*���������ֶγ���Ӧ��ȡ��Ҫ������д��
	eFormat nvarchar(200) not null,			--��񣺹�����ݸ�ʽΪ�ַ��ͣ�����Ϊ30��ָ�����豸�Ĺ�����Ҫ����ָ�ꡣ�����������豸����ѧУ�����ź�ʵ���*���������ֶγ���Ӧ��ȡ��Ҫ������д��

	--�����ֶηǱ�ϵͳ�ṩ��Ӧ�ɴ����豸����ϵͳ��ʵ���ҹ���ϵͳ�ṩ��
	useHour4Education int default(0),		--ʹ�û�ʱ����ѧ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڽ�ѧ������ʹ�û�ʱ�������������豸ʹ�ü�¼����ѧ����ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
											--ʹ�û�ʱ����Ҫ�Ŀ���׼��ʱ��+����ʱ��+����ĺ���ʱ�䡣
	useHour4Research int default(0),		--ʹ�û�ʱ�����У������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڿ��й�����ʹ�û�ʱ�������������豸ʹ�ü�¼�����з���ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Service int default(0),			--ʹ�û�ʱ�������񣩣����ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�����������ʹ�û�ʱ�������������豸ʹ�ü�¼����������ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Open int default(0),			--ʹ�û�ʱ�����п���ʹ�û�ʱ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�������û�����ʹ�ã��û������ϻ����ԡ��۲���Ʒ���Ļ�ʱ����
	samplesNum int default(0),				--�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ6��
											--��ѧ���ڱ������豸�ϲ��ԡ���������Ʒ����������ԭʼ��¼ͳ�����
											--ͬһ��Ʒ��һ̨�����ϲ��ԣ�ͳ�Ʋ�����Ϊ1������Է����ʹ����޹ء�
	trainStudents int default(0),			--��ѵ��Ա����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������ѧ������������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainTeachers int default(0),			--��ѵ��Ա������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ����������Ľ�ʦ����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainOthers int default(0),				--��ѵ��Ա���������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������������Ա����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	experimentItems int default(0),			--��ѧʵ����Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸����������ѧ�ƻ���ʵ����Ŀ����
	researchItems int default(0),			--������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸��ɵĸ��ֿ�����Ŀ�������Ŀ����
	serviceItems int default(0),			--��������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ�����ñ������豸��ɵ�ΪУ��е�����������Ŀ����
	awardsFromCountry int default(0),		--����������Ҽ��������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸�ڱ�ѧ���õĹ��Ҽ����������
	awardsFromProvince int default(0),		--�������ʡ�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸��ѧ���õ�ʡ�������������
	patentsFromTeacher int default(0),		--����ר������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	patentsFromStudent int default(0),		--����ר����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	thesisNum1 int default(0),				--�����������������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ�귢������������������ָ��SCI��EI ��ISTP��
	thesisNum2 int default(0),				--������������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ������ڿ��������������

	keeper nvarchar(30) null,				--����������(������):���ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ָ�������豸�����ĸ�����������û�и����˵���ޡ�


	--�����ֶ���������չ�ģ�
	fCode char(1) not null,					--������Դ�����ݸ�ʽΪ�ַ��ͣ�����Ϊ1����������д��1�����ã�2��������ָ��Ȼ�ˡ����˻���������֯��Ը�޳���ѧУ�����������豸��
																							-- 3�����ƣ���Ҫ������������ơ��ӹ�������������豸��
																							-- 4��У����룺��ǰ�������������Դ��
	cCode char(3) not null,					--�����룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ3��ָ�����豸���������Ҵ��룬�Բ�Ʒ���Ʊ�ʾ�Ĳ���Ϊ׼��������������͵������ƴ��롷��GB/T 2659-2000����д�������벻����000����
	acceptDate char(6) null,				--�������ڣ��������ڣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ6��ָ�����豸��У�������ڡ�ǰ��λ��ʾ�꣬����λ��ʾ�¡�

	curEqpStatus char(1) not null,			--��״�룺���ݸ�ʽΪ�ַ��ͣ�����Ϊ1
											--1�����ã�ָ����ʹ�õ������豸��
											--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
											--3�����ޣ�ָ���޻���������������豸��
											--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
											--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
											--9����������״����������豸��
	aCode char(1) not null,					--ʹ�÷������ݸ�ʽΪ�ַ��ͣ�����Ϊ1��ָ�����豸��ʹ�����ʣ���������д��1����ѧΪ����2������Ϊ������ĳ̨�����豸��ѧ�����ʹ�û�ʱ��ռһ�룬����롰2����
	
	eUCode varchar(10) not null,			--��λ��ţ�Ϊ��λӳ����е��µ�λ���룩�����ݸ�ʽΪ�ַ��ͣ�����Ϊ10��
											--ָѧУ�Ա�������豸���ڵ�λ��ţ�У�ھ���Ψһ�ԡ�
	eUName nvarchar(50) not null,			--��λ���ƣ�Ϊ��λӳ����е��µ�λ���ƣ������ݸ�ʽΪ�ַ��ͣ�����Ϊ50��
											--ָ�����豸���ڵ�λ���ơ�
 CONSTRAINT [PK_rptBase3] PRIMARY KEY CLUSTERED 
(
	[reportNum] ASC,
	[eCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[rptBase3]  WITH CHECK ADD  CONSTRAINT [FK_rptBase3_reportCenter] FOREIGN KEY([reportNum], [reportType])
REFERENCES [dbo].[reportCenter] ([reportNum], [reportType])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[rptBase3] CHECK CONSTRAINT [FK_rptBase3_reportCenter]

drop proc addReport
/*
	name:		addReport
	function:	1.���ָ�����͵ı����Զ�����ͳ����ֹʱ����������
	input: 
				@reportType int,		--��������:���õ�900��901�Ŵ����ֵ�
											--����������
											--901->��ѧ���������豸��
											--902->��ѧ���������豸�����䶯�����
											--903->���������豸��
				@theTitle nvarchar(100),		--�������
				@theYear varchar(4),			--ͳ�����
				@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
				@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ

				@makeUnit nvarchar(50),			--�Ʊ�λ
				@makerID varchar(10),			--�Ʊ��˹���
	output: 
				@Ret		int output,			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@reportNum varchar(12) output	--������:""��������ʱ����
	author:		¬έ
	CreateDate:	2010-3-26
	UpdateDate: �򻯲��� by lw 2012-10-2
*/
create PROCEDURE addReport
	@reportType int,		--��������:���õ�900��901�Ŵ����ֵ�
								--����������
								--901->��ѧ���������豸��
								--902->��ѧ���������豸�����䶯�����
								--903->���������豸��
	@theTitle nvarchar(100),		--�������
	@theYear varchar(4),			--ͳ�����
	@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
	@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ

	@makeUnit nvarchar(50),			--�Ʊ�λ
	@makerID varchar(10),			--�Ʊ��˹���
	@Ret int output,				--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	@reportNum varchar(12) output	--�����ţ�""��������ʱ����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber @reportType, 1, @curNumber output
	set @reportNum = @curNumber
	--��ȡ�Ʊ���������
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--�Ʊ����ڣ�
	declare @makeDate smalldatetime		--�Ʊ�����
	set @makeDate = GETDATE()

	begin tran
		--���������Ŀ��
		insert reportCenter(reportNum, reportType, theTitle, theYear, totalStartDate, totalEndDate,
								makeUnit, makeDate, makerID, maker) 
		values (@reportNum, @reportType, @theTitle, @theYear, @totalStartDate, @totalEndDate,
								@makeUnit, getdate(), @makerID, @maker)
		--���ݱ������ͣ����챨��
		--����������
		if @reportType = 901	--��ѧ���������豸��
			EXEC dbo.makeRptBase1 @reportNum, @totalStartDate, @totalEndDate, @Ret output
		else if @reportType = 902	--��ѧ���������豸�����䶯�����
			EXEC dbo.makeRptBase2 @reportNum, @totalStartDate, @totalEndDate, @Ret output
		else if @reportType = 903	--���������豸��
			EXEC dbo.makeRptBase3 @reportNum, @totalStartDate, @totalEndDate, @Ret output
		if (@@ERROR <> 0 or @Ret <> 0)
		begin
			rollback tran
			return
		end
	commit tran
	set @Ret = 0
	declare @reportName nvarchar(60)
	set @reportName = (case @reportType when 901 then '��ѧ���������豸��' 
										when 902 then '��ѧ���������豸�����䶯�����'
										when 903 then '���������豸��' end)
	--д������־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '���ɽ���������', 'ϵͳ�����û�' + @maker + 
					'��Ҫ�������˽���������-'+ +'[' + @reportNum + ']��')
GO
--���ԣ�
declare @Ret int, @reportNum as varchar(12)
exec dbo.addReport 903, '������', '2012', '2011-09-01', '2012-08-31', 
'�人��ѧ', '00000008', @Ret output, @reportNum output
select @Ret, @reportNum

select * from rptBase2 where reportNum='201210110002'
select COUNT(*),SUM(totalAmount) from rptBase1 where reportNum='201210110005'

select * from [rptBase1] where reportNum='201210110005' and eUCode='6080100'

select * from equipmentList
where eCode='00J00947'

use epdc211
select * from reportCenter
select count(*), SUM(totalAmount) from [rptBase1] where reportNum='201210080012'
select * from [rptBase1] where reportNum='201210110004' and eCode not in (select eCode from [rptBase1] where reportNum='201210080007')
select * from equipmentList where eCode='11000045'
select * from [rptBase3] where reportNum='201210140002' and eCode='11000045'
select * from [rptBase2]
select count(*),SUM(totalAmount) from rptBase1 where reportNum='201210090003'

select * from [rptBase1] where reportNum='201210080013' and left(eucode,1)='L'

select * from [rptBase3] where reportNum='201210150001' and eCode not in (select left(eCode,8) from r3 uu)
select CHAR(39)+uu.eCode, CHAR(39)+e.eCode, CHAR(39)+uu.eTypeCode, CHAR(39)+e.eTypeCode, uu.eName, e.eName, e.totalAmount, c.clgName, u.uName  
from r3 uu left join equipmentList e on uu.eCode = e.eCode left join college c on e.clgCode=c.clgCode left join useUnit u on e.uCode=u.uCode
where uu.eCode not in (select eCode from [rptBase3] where reportNum='201210150001')

select * from r3 where eCode is null
delete r3 where eCode is null


select r.eCode, uu.eCode, r.eName, uu.eName, * from [rptBase3] r inner join uu on r.reportNum='201210120005' and r.eCode=uu.eCode

select eCode, count(*) from uu group by eCode having count(*) > 1

select * from uu where eCode is null
select distinct rtrim(eCode) from [rptBase3] where reportNum='201210140001'
select distinct RTRIM(eCode) from uu
select * from uu where ecode ='03030900'

select eCode, LEN(eCode) from uu where LEN(eCode)<>8
select * from equipmentList where eName like '%����%'

delete uu where eCode is null
select * from [rptBase3] where reportNum='201210120005' and ecode ='11000045'

drop table uu

DROP PROCEDURE makeRptBase1
/*
	name:		makeRptBase1
	function:	2.����ͳ���������ɡ���ѧ���������豸��
	input: 
				@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
				@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2011-1-26
	UpdateDate: 
*/
create PROCEDURE makeRptBase1
	@reportNum varchar(12),			--������
	@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
	@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
	@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--��ȡѧУ�����ѧУ���ƣ�
	declare @universityCode char(5), @universityName nvarchar(60)		--ѧУ���롢ѧУ����
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)
--	select @universityCode, @universityName

	insert rptBase1(reportNum, reportType, universityCode, universityName,
					eCode, eTypeCode, 
					eName, eModel, eFormat,
					fCode, cCode, 
					totalAmount, acceptDate, curEqpStatus,
					aCode, 
					eUCode, eUName)
	select @reportNum, 901, @universityCode, @universityName,	
					e.eCode, e.eTypeCode, 
					case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, e.eModel, e.eFormat,
					case e.obtainMode when 4 then '2' when 7 then '3' when 3 then '3' when 1 then '1' else '4' end, 
					isnull(e.cCode,'000'), 
					e.totalAmount, 
					cast(year(e.acceptDate) as CHAR(4)) + right('0'+cast(MONTH(e.acceptDate) as varchar(2)),2), 
					case e.curEqpStatus when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
										when '5' then '9' when '7' then '9'
										  else e.curEqpStatus end, --ע�⣺Ŀǰֻ�����˱��ϵ������
					case rtrim(cast(e.aCode as varchar(2))) when '1' then '1' when '2' then '2' else '1' end, 
					u.eUCode, isnull(u.eUName,'')
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	if @@ERROR <> 0 
	begin
		return
	end    

	--����ʹ�÷�����ʱ�����������λ�ı����޸�һ�£�������������Ҫ��
	--�����ⵥλ��ʹ�÷���Ϊ����ѧ��ת��Ϊ����ע���ֶεĵ�2��ӳ���룺
	update rptBase1 
	set eUCode = cast(e.switchUName.query('data(root/code[1])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[1])') as nvarchar(50))
	from rptBase1 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '1'
	if @@ERROR <> 0 
	begin
		return
	end    
	--�����ⵥλ��ʹ�÷���Ϊ�����С�ת��Ϊ����ע���ֶεĵ�1��ӳ���룺
	update rptBase1 
	set eUCode = cast(e.switchUName.query('data(root/code[2])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[2])') as nvarchar(50))
	from rptBase1 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '2'
	if @@ERROR <> 0 
	begin
		return
	end    
	
	set @Ret = 0
go

DROP PROCEDURE makeRptBase2
/*
	name:		makeRptBase2
	function:	2.����ͳ���������ɡ���ѧ���������豸�����䶯�����
	input: 
				@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
				@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2011-1-26
	UpdateDate: 
*/
create PROCEDURE makeRptBase2
	@reportNum varchar(12),			--������
	@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
	@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
	@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--��ȡѧУ�����ѧУ���ƣ�
	declare @universityCode char(5), @universityName nvarchar(60)		--ѧУ���롢ѧУ����
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)

	--������ѧ��ĩʵ������
	declare @eSumNumLastYear int		--̨���ϼ�
	declare @eSumAmountLastYear money	--���ϼ�
	declare @bESumNumLastYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bESumAmountLastYear money	--10��Ԫ�����������豸���ϼ�

	select @eSumNumLastYear = isnull(count(*),0), @eSumAmountLastYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
		and convert(varchar(10),acceptDate,120) < @totalStartDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

	select @bESumNumLastYear = isnull(count(*),0), @bESumAmountLastYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
		and convert(varchar(10),acceptDate,120) < @totalStartDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

	--���㱾ѧ����������
	declare @eIncNumCurYear int			--̨���ϼ�
	declare @eIncAmountCurYear money	--���ϼ�
	declare @bEIncNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bEIncAmountCurYear money	--10��Ԫ�����������豸���ϼ�

	select @eIncNumCurYear = isnull(count(*),0), @eIncAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
		and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate
		
	select @bEIncNumCurYear = isnull(count(*),0), @bEIncAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
		and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate

	--��ѧ����������������ʹ�õ��ƣ�
/*	
	declare @eDecNumCurYear int			--̨���ϼ�
	declare @eDecAmountCurYear money	--���ϼ�
	declare @bEDecNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bEDecAmountCurYear money	--10��Ԫ�����������豸���ϼ�

	select @eDecNumCurYear = isnull(count(*),0), @eDecAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
		and (e.curEqpStatus in ('5','6','7') 
		and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --����ֻ�����˱������

	select @bEDecNumCurYear = isnull(count(*),0), @bEDecAmountCurYear = isnull(sum(totalAmount),0)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
		and (e.curEqpStatus in ('5','6','7') 
		and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --����ֻ�����˱������
*/

	--���㱾ѧ��ĩʵ������
	declare @eSumNumCurYear int		--̨���ϼ�
	declare @eSumAmountCurYear money	--���ϼ�
	declare @bESumNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bESumAmountCurYear money	--10��Ԫ�����������豸���ϼ�

	select @eSumNumCurYear = count(*), @eSumAmountCurYear = sum(totalAmount)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)

	select @bESumNumCurYear = count(*), @bESumAmountCurYear = sum(totalAmount)
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	

	--���㱾ѧ���������
	declare @eDecNumCurYear int			--̨���ϼ�
	declare @eDecAmountCurYear money	--���ϼ�
	declare @bEDecNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bEDecAmountCurYear money	--10��Ԫ�����������豸���ϼ�
	set @eDecNumCurYear = @eSumNumLastYear + @eIncNumCurYear - @eSumNumCurYear
	set @eDecAmountCurYear =  @eSumAmountLastYear + @eIncAmountCurYear - @eSumAmountCurYear
	set @bEDecNumCurYear = @bESumNumLastYear + @bEIncNumCurYear - @bESumNumCurYear
	set @bEDecAmountCurYear = @bESumAmountLastYear + @bEIncAmountCurYear - @bESumAmountCurYear

	--���汨��
	insert rptBase2(reportNum, reportType, universityCode, universityName,
					eSumNumLastYear, eSumAmountLastYear, bESumNumLastYear, bESumAmountLastYear,
					eIncNumCurYear, eIncAmountCurYear, bEIncNumCurYear, bEIncAmountCurYear,
					eDecNumCurYear, eDecAmountCurYear, bEDecNumCurYear, bEDecAmountCurYear,
					eSumNumCurYear, eSumAmountCurYear, bESumNumCurYear, bESumAmountCurYear)
	values(@reportNum, 902, @universityCode, @universityName,
					@eSumNumLastYear, @eSumAmountLastYear, @bESumNumLastYear, @bESumAmountLastYear,
					@eIncNumCurYear, @eIncAmountCurYear, @bEIncNumCurYear, @bEIncAmountCurYear,
					@eDecNumCurYear, @eDecAmountCurYear, @bEDecNumCurYear, @bEDecAmountCurYear,
					@eSumNumCurYear, @eSumAmountCurYear, @bESumNumCurYear, @bESumAmountCurYear)
	if @@ERROR <> 0 
	begin
		return
	end    

	set @Ret = 0
go

DROP PROCEDURE makeRptBase2Exp
/*
	name:		makeRptBase2Exp
	function:	2.1.����ͳ���������ɡ���ѧ���������豸�����䶯�����(��Ժ������ͳ��)��
	input: 
				@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
				@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
				@eUCode varchar(8),				--ӳ���ʹ�õ�λ����
				@eUName nvarchar(30),			--ӳ���ʹ�õ�λ����
				@aCode varchar(30),					--ʹ��ʹ�÷���Լ����''->��Լ����'2'->Լ���������࣬'1,3,4,5,6,7,8'->Լ������ѧ��
				@realEUCode varchar(8),			--���п��ص�λ����ʱʹ�õ�ӳ���ʹ�õ�λ����
				@realEUName nvarchar(30),		--���п��ص�λ����ʱʹ�õ�ӳ���ʹ�õ�λ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-4-3
	UpdateDate: 
*/
create PROCEDURE makeRptBase2Exp
	@reportNum varchar(12),			--������
	@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
	@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
	@eUCode varchar(8),				--ӳ���ʹ�õ�λ����
	@eUName nvarchar(30),			--ӳ���ʹ�õ�λ����
	@aCode varchar(30),					--ʹ��ʹ�÷���Լ����''->��Լ����'2'->Լ���������࣬'1,3,4,5,6,7,8'->Լ������ѧ��
	@realEUCode varchar(8),			--���п��ص�λ����ʱʹ�õ�ӳ���ʹ�õ�λ����
	@realEUName nvarchar(30),		--���п��ص�λ����ʱʹ�õ�ӳ���ʹ�õ�λ����
	@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--��ȡѧУ�����ѧУ���ƣ�
	declare @universityCode char(5), @universityName nvarchar(60)		--ѧУ���롢ѧУ����
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)

	--������ѧ��ĩʵ������
	declare @eSumNumLastYear int		--̨���ϼ�
	declare @eSumAmountLastYear money	--���ϼ�
	declare @bESumNumLastYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bESumAmountLastYear money	--10��Ԫ�����������豸���ϼ�

	--���㱾ѧ����������
	declare @eIncNumCurYear int			--̨���ϼ�
	declare @eIncAmountCurYear money	--���ϼ�
	declare @bEIncNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bEIncAmountCurYear money	--10��Ԫ�����������豸���ϼ�

	--���㱾ѧ��ĩʵ������
	declare @eSumNumCurYear int		--̨���ϼ�
	declare @eSumAmountCurYear money	--���ϼ�
	declare @bESumNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bESumAmountCurYear money	--10��Ԫ�����������豸���ϼ�
	if (@aCode='')	--��ʹ��ʹ�÷���Լ��
	begin
		select @eSumNumLastYear = isnull(count(*),0), @eSumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		select @bESumNumLastYear = isnull(count(*),0), @bESumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		--���㱾ѧ����������
		select @eIncNumCurYear = isnull(count(*),0), @eIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate
			
		select @bEIncNumCurYear = isnull(count(*),0), @bEIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate

		--��ѧ����������������ʹ�õ��ƣ�
	/*	
		declare @eDecNumCurYear int			--̨���ϼ�
		declare @eDecAmountCurYear money	--���ϼ�
		declare @bEDecNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
		declare @bEDecAmountCurYear money	--10��Ԫ�����������豸���ϼ�

		select @eDecNumCurYear = isnull(count(*),0), @eDecAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
			and (e.curEqpStatus in ('5','6','7') 
			and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --����ֻ�����˱������

		select @bEDecNumCurYear = isnull(count(*),0), @bEDecAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
			and (e.curEqpStatus in ('5','6','7') 
			and convert(varchar(10),scrapDate,120) >= @totalStartDate and scrapDate <= @totalEndDate) --����ֻ�����˱������
	*/

		--���㱾ѧ��ĩʵ������
		select @eSumNumCurYear = count(*), @eSumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)

		select @bESumNumCurYear = count(*), @bESumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	end	
	else	--ʹ��ʹ�÷���Լ��
	begin
		select @eSumNumLastYear = isnull(count(*),0), @eSumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.aCode in (--Լ�����ض���ʹ�÷���
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		select @bESumNumLastYear = isnull(count(*),0), @bESumAmountLastYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.aCode in (--Լ�����ض���ʹ�÷���
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
			and convert(varchar(10),acceptDate,120) < @totalStartDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) >= @totalStartDate)

		--���㱾ѧ����������
		select @eIncNumCurYear = isnull(count(*),0), @eIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.aCode in (--Լ�����ض���ʹ�÷���
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate
			
		select @bEIncNumCurYear = isnull(count(*),0), @bEIncAmountCurYear = isnull(sum(totalAmount),0)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.aCode in (--Լ�����ض���ʹ�÷���
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
			and convert(varchar(10),acceptDate,120) >= @totalStartDate and acceptDate <= @totalEndDate

		--��ѧ����������������ʹ�õ��ƣ�

		--���㱾ѧ��ĩʵ������
		select @eSumNumCurYear = count(*), @eSumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.aCode in (--Լ�����ض���ʹ�÷���
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 800	--����800Ԫ���������ϵ��豸
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)

		select @bESumNumCurYear = count(*), @bESumAmountCurYear = sum(totalAmount)
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
			left join eDepartCode u on e.uCode = u.uCode
		where left(e.eTypeCode,2) not in ('01','02','11','13','15','16')
			and e.uCode in (select uCode from eDepartCode where eUCode=@eUCode)	--Լ������ѧ���������ʹ�õ�λ
			and e.aCode in (--Լ�����ض���ʹ�÷���
				SELECT cast(T.x.query('data(.)') as CHAR(1)) FROM 
				(SELECT CONVERT(XML,'<x>'+REPLACE(@aCode,',','</x><x>')+'</x>',1) Col1) A
				OUTER APPLY A.Col1.nodes('/x') AS T(x)
				)
			and e.totalAmount >= 100000	--�ܼ�10��Ԫ����
			and convert(varchar(10),acceptDate,120) <= @totalEndDate
			and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
		set @eUCode = @realEUCode; set @eUName = @realEUName;
	end	

	--���㱾ѧ���������
	declare @eDecNumCurYear int			--̨���ϼ�
	declare @eDecAmountCurYear money	--���ϼ�
	declare @bEDecNumCurYear int		--10��Ԫ�����������豸̨���ϼ�
	declare @bEDecAmountCurYear money	--10��Ԫ�����������豸���ϼ�
	set @eDecNumCurYear = @eSumNumLastYear + @eIncNumCurYear - @eSumNumCurYear
	set @eDecAmountCurYear =  @eSumAmountLastYear + @eIncAmountCurYear - @eSumAmountCurYear
	set @bEDecNumCurYear = @bESumNumLastYear + @bEIncNumCurYear - @bESumNumCurYear
	set @bEDecAmountCurYear = @bESumAmountLastYear + @bEIncAmountCurYear - @bESumAmountCurYear

	--���汨��
	insert rptBase2Exp(reportNum, reportType, universityCode, universityName,
					eUCode, eUName,
					eSumNumLastYear, eSumAmountLastYear, bESumNumLastYear, bESumAmountLastYear,
					eIncNumCurYear, eIncAmountCurYear, bEIncNumCurYear, bEIncAmountCurYear,
					eDecNumCurYear, eDecAmountCurYear, bEDecNumCurYear, bEDecAmountCurYear,
					eSumNumCurYear, eSumAmountCurYear, bESumNumCurYear, bESumAmountCurYear)
	values(@reportNum, 902, @universityCode, @universityName,
					@eUCode, @eUName,
					isnull(@eSumNumLastYear,0), isnull(@eSumAmountLastYear,0), isnull(@bESumNumLastYear,0), isnull(@bESumAmountLastYear,0),
					isnull(@eIncNumCurYear,0), isnull(@eIncAmountCurYear,0), isnull(@bEIncNumCurYear,0), isnull(@bEIncAmountCurYear,0),
					isnull(@eDecNumCurYear,0), isnull(@eDecAmountCurYear,0), isnull(@bEDecNumCurYear,0), isnull(@bEDecAmountCurYear,0),
					isnull(@eSumNumCurYear,0), isnull(@eSumAmountCurYear,0), isnull(@bESumNumCurYear,0), isnull(@bESumAmountCurYear,0))
	if @@ERROR <> 0 
	begin
		return
	end    

	set @Ret = 0
go

delete rptBase2Exp
--������ϸ��
declare @eUCode varchar(8)	--ӳ���ʹ�õ�λ����
declare @eUName nvarchar(30)--ӳ���ʹ�õ�λ����
declare @Ret	int --�����ɹ���ʶ��0:�ɹ���9:δ֪����
declare tar cursor for
select distinct eUCode,eUName from eDepartCode where isUsed='Y'	--Լ������ѧ���������ʹ�õ�λ
OPEN tar
FETCH NEXT FROM tar INTO @eUCode,@eUName
WHILE @@FETCH_STATUS = 0
begin
	print '���ڴ���' + @eUcode + '-' + @eUName
	if left(@eUCode,1)='L'
	begin
		declare @switchUName xml	--��ʹ�÷��������������ӳ�䣺������������Ҫ�󣡾���һЩ��λ����ѧ���͡����С�����ʲ��ֱ���ڲ�ͬ�ĵ�λ������
		set @switchUName=(select top 1 switchUName from eDepartCode where eUCode = @eUCode)

		declare @realEUCode varchar(8)	--ӳ���ʹ�õ�λ����:aCode = '1'
		declare @realEUName nvarchar(30)--ӳ���ʹ�õ�λ����
		declare @realEUCode2 varchar(8)	--ӳ���ʹ�õ�λ����:aCode = '2'
		declare @realEUName2 nvarchar(30)--ӳ���ʹ�õ�λ����
		select @realEUCode = cast(@switchUName.query('data(root/code[1])') as varchar(8)), 
			   @realEUName = cast(@switchUName.query('data(root/name[1])') as nvarchar(50)),
			   @realEUCode2 = cast(@switchUName.query('data(root/code[2])') as varchar(8)), 
			   @realEUName2 = cast(@switchUName.query('data(root/name[2])') as nvarchar(50))
		--������ԣ����ǿ�������ʲ�ȫ�������ѧ���ʲ���
		exec dbo.makeRptBase2Exp '201304010001','2011-09-01','2012-08-31',@eUCode,@eUName,'1,3,4,5,6,7,8',@realEUCode,@realEUName,@Ret output
		if (@Ret<>0)
			break;	
		exec dbo.makeRptBase2Exp '201304010001','2011-09-01','2012-08-31',@eUCode,@eUName,'2',@realEUCode2,@realEUName2,@Ret output
	end
	else
		exec dbo.makeRptBase2Exp '201304010001','2011-09-01','2012-08-31',@eUCode,@eUName,'','','',@Ret output

	if (@Ret<>0)
		break;	
	FETCH NEXT FROM tar INTO @eUCode,@eUName
end
CLOSE tar
DEALLOCATE tar

select * from rptBase2Exp
--�ԱȽ����
select * from rptBase2
select reportNum, reportType, universityCode, universityName,
					sum(eSumNumLastYear), sum(eSumAmountLastYear), sum(bESumNumLastYear), sum(bESumAmountLastYear),
					sum(eIncNumCurYear), sum(eIncAmountCurYear), sum(bEIncNumCurYear), sum(bEIncAmountCurYear),
					sum(eDecNumCurYear), sum(eDecAmountCurYear), sum(bEDecNumCurYear), sum(bEDecAmountCurYear),
					sum(eSumNumCurYear), sum(eSumAmountCurYear), sum(bESumNumCurYear), sum(bESumAmountCurYear)
from rptBase2Exp
group by reportNum, reportType, universityCode, universityName


select * from appDir

SELECT * FROM eDepartCode WHERE isUsed = 'Y'
select * from rptBase1 where eUCode = '6020100'
select * from eDepartCode where isused ='Y'
select * from rptBase2


select * from codeDictionary where classCode = 1
DROP PROCEDURE makeRptBase3
/*
	name:		makeRptBase3
	function:	3.����ͳ���������ɡ����������豸��
	input: 
				@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
				@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2011-1-28
	UpdateDate: 
*/
create PROCEDURE makeRptBase3
	@reportNum varchar(12),			--������
	@totalStartDate varchar(10),	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
	@totalEndDate varchar(10),		--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
	@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--��ȡѧУ�����ѧУ���ƣ�
	declare @universityCode char(5), @universityName nvarchar(60)		--ѧУ���롢ѧУ����
	set @universityCode = (select objDesc from codeDictionary where classCode = 1 and objCode = 1)
	set @universityName = (select objDesc from codeDictionary where classCode = 1 and objCode = 2)
--	select @universityCode, @universityName

	insert rptBase3(reportNum, reportType, universityCode, universityName,
					eCode, eTypeCode, 
					eName, totalAmount, eModel, eFormat, keeper,
					fCode, cCode, 
					acceptDate, curEqpStatus,
					aCode, 
					eUCode, eUName)
	select @reportNum, 903, @universityCode, @universityName,	
					e.eCode, e.eTypeCode, 
					case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
					e.totalAmount, e.eModel, e.eFormat, e.keeper,
					case e.obtainMode when 4 then '2' when 7 then '3' when 3 then '3' when 1 then '1' else '4' end, 
					isnull(e.cCode,'000'), 
					cast(year(e.acceptDate) as CHAR(4)) + right('0'+cast(MONTH(e.acceptDate) as varchar(2)),2), 
					case e.curEqpStatus when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
										when '5' then '9' when '7' then '9'
										  else e.curEqpStatus end, --ע�⣺Ŀǰֻ�����˱��ϵ������
					case rtrim(cast(e.aCode as varchar(2))) when '1' then '1' when '2' then '2' else '1' end, 
					u.eUCode, isnull(u.eUName,'')
	from equipmentList e left join college clg on e.clgCode = clg.clgCode
		left join eDepartCode u on e.uCode = u.uCode
	where left(e.eTypeCode,2) = '03'
		and e.uCode in (select uCode from eDepartCode where isUsed='Y')	--Լ������ѧ���������ʹ�õ�λ
		and e.totalAmount >= 400000	--����40��Ԫ���������ϵ��豸
		and convert(varchar(10),acceptDate,120) <= @totalEndDate
		and (e.curEqpStatus in ('1','2','3','4','8','9') or convert(varchar(10),scrapDate,120) > @totalEndDate)
	if @@ERROR <> 0 
	begin
		return
	end    

	--����ʹ�÷�����ʱ�����������λ�ı����޸�һ�£�������������Ҫ��
	--�����ⵥλ��ʹ�÷���Ϊ����ѧ��ת��Ϊ����ע���ֶεĵ�2��ӳ���룺
	update rptBase3 
	set eUCode = cast(e.switchUName.query('data(root/code[1])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[1])') as nvarchar(50))
	from rptBase3 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '1'
	if @@ERROR <> 0 
	begin
		return
	end    
	--�����ⵥλ��ʹ�÷���Ϊ�����С�ת��Ϊ����ע���ֶεĵ�1��ӳ���룺
	update rptBase3
	set eUCode = cast(e.switchUName.query('data(root/code[2])') as varchar(8)), 
		eUName = cast(e.switchUName.query('data(root/name[2])') as nvarchar(50))
	from rptBase3 r left join eDepartCode e on r.eUCode = e.eUCode
	where reportNum=@reportNum and left(r.eUCode,1)='L' and aCode = '2'
	if @@ERROR <> 0 
	begin
		return
	end    
	set @Ret = 0

go


drop PROCEDURE delReport
/*
	name:		delReport
	function:	4.ɾ��ָ���Ľ���������
	input: 
				@reportNum varchar(12),			--������
				@delManID varchar(10) output,	--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ı������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-2
	UpdateDate: 

*/
create PROCEDURE delReport
	@reportNum varchar(12),			--������
	@delManID varchar(10) output,	--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı����Ƿ����
	declare @count as int
	set @count=(select count(*) from reportCenter where reportNum = @reportNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end


	delete reportCenter where reportNum = @reportNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������������', '�û�' + @delManName
												+ 'ɾ���˽���������['+ @reportNum +']��')

GO

--�������������ݸ�ʽ���Ĵ洢���̣�
drop PROCEDURE checkReportDataModel
/*
	name:		checkReportDataModel
	function:	5.1���ָ���Ľ������������ݵĸ�ʽ�����ͺ�
	input: 
				@reportNum varchar(12),			--������
				@checkManID varchar(10),		--�����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���-1��ָ���ı������ڣ�>0 :�����ͺŴ��������
	author:		¬έ
	CreateDate:	2012-10-12
	UpdateDate: 

*/
create PROCEDURE checkReportDataModel
	@reportNum varchar(12),			--������
	@checkManID varchar(10),		--�����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	--�ж�ָ���ı����Ƿ����
	declare @count as int
	set @count=(select count(*) from reportCenter where reportNum = @reportNum)	
	if (@count = 0)	--������
	begin
		set @Ret = -1
		return
	end


	set @Ret = (select count(*) from rptBase1 where reportNum = @reportNum and isnull(eModel,'')='')

	--д��鱨�棺
	--ȡ����˵�������
	declare @checkManName nvarchar(30)
	set @checkManName = isnull((select userCName from activeUsers where userID = @checkManID),'')

	insert rptBase1CheckDetail(checkManID, checkManName, errorType, errorDesc, 
		reportNum, reportType, universityCode, universityName, 
		eCode, eTypeCode, eName, eModel, eFormat, 
		fCode, cCode, totalAmount, acceptDate, curEqpStatus, aCode,
		eUCode, eUName)
	select @checkManID, @checkManName, '�����ͺŴ���', '�����ͺŲ���Ϊ�գ��ͺŲ���������豸����ѧУ�����ź�ʵ���*��', 
		reportNum, reportType, universityCode, universityName, 
		eCode, eTypeCode, eName, eModel, eFormat, 
		fCode, cCode, totalAmount, acceptDate, curEqpStatus, aCode,
		eUCode, eUName
	from rptBase1
	where reportNum = @reportNum and isnull(eModel,'')=''
	
GO

select count(*), SUM(totalAmount) from equipmentList
------------------------------�����ϱ��ļ���ʽ��--------------------------
use epdc211
select * from reportCenter

select COUNT(*),SUM(totalAmount) from rptBase1 where reportNum='201210110005'
--��������Ƿ���ϸ�ʽҪ��
	--1.����ͺţ�
select * from rptBase1 where isnull(eModel,'')=''
update rptBase1
set eModel='*'
where isnull(eModel,'')=''

update equipmentList
set eModel='*'
where isnull(eModel,'')=''
	--2.�����
select * from rptBase1 where isnull(eFormat,'')=''
update rptBase1
set eFormat='*'
where isnull(eFormat,'')=''

update equipmentList
set eFormat='*'
where isnull(eFormat,'')=''

	--3.������
select * from rptBase1 where ISNULL(cCode,'') not in (select cCode from country)
select * from equipmentList where eCode='12006806'
select * from country where cName like '�й�'
update rptBase1
set cCode='156'
where ISNULL(cCode,'') not in (select cCode from country)

update equipmentList
set cCode='156'
where ISNULL(cCode,'') not in (select cCode from country)

	--4.����������
	--����һ������ķ��ࣺ
select * from equipmentList where eCode='11013208'
select * from equipmentList where eCode='11T13208'

update rptBase1
set eTypeCode='04400109'
where eCode in ('11013208','11T13208')

update equipmentList
set eTypeCode='04400109'
where eCode in ('11013208','11T13208')

select * from rptBase1 where eCode='00012388'
select * from collegeCode where dCode='7006000'
	
select top 10 * from rptBase1

--����һ������
update equipmentList
set eTypeCode='03250213', eTypeName='��������¼��', aTypeCode='767200'
where eCode = '11000005'

update rptBase1
set eTypeCode='03250213'
where eCode = '11000005'

update rptBase3
set eTypeCode='03250213'
where eCode = '11000005'

select * from typeCodes where eTypeCode='03250213'


--�����ֹ�¼�뿼�����ݣ�
select * from r3
update rptBase3
set useHour4Education = F8,		--ʹ�û�ʱ����ѧ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڽ�ѧ������ʹ�û�ʱ�������������豸ʹ�ü�¼����ѧ����ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
											--ʹ�û�ʱ����Ҫ�Ŀ���׼��ʱ��+����ʱ��+����ĺ���ʱ�䡣
	useHour4Research = F9,		--ʹ�û�ʱ�����У������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڿ��й�����ʹ�û�ʱ�������������豸ʹ�ü�¼�����з���ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Service =F10,			--ʹ�û�ʱ�������񣩣����ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�����������ʹ�û�ʱ�������������豸ʹ�ü�¼����������ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Open =F11,			--ʹ�û�ʱ�����п���ʹ�û�ʱ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�������û�����ʹ�ã��û������ϻ����ԡ��۲���Ʒ���Ļ�ʱ����
	samplesNum =F12,				--�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ6��
											--��ѧ���ڱ������豸�ϲ��ԡ���������Ʒ����������ԭʼ��¼ͳ�����
											--ͬһ��Ʒ��һ̨�����ϲ��ԣ�ͳ�Ʋ�����Ϊ1������Է����ʹ����޹ء�
	trainStudents =F13,			--��ѵ��Ա����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������ѧ������������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainTeachers =F14,			--��ѵ��Ա������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ����������Ľ�ʦ����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainOthers =F15,				--��ѵ��Ա���������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������������Ա����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	experimentItems =F16,			--��ѧʵ����Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸����������ѧ�ƻ���ʵ����Ŀ����
	researchItems =F17,			--������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸��ɵĸ��ֿ�����Ŀ�������Ŀ����
	serviceItems =F18,			--��������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ�����ñ������豸��ɵ�ΪУ��е�����������Ŀ����
	awardsFromCountry =F19,		--����������Ҽ��������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸�ڱ�ѧ���õĹ��Ҽ����������
	awardsFromProvince =F20,		--�������ʡ�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸��ѧ���õ�ʡ�������������
	patentsFromTeacher =F21,		--����ר������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	patentsFromStudent =F22,		--����ר����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	thesisNum1 =F23,				--�����������������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ�귢������������������ָ��SCI��EI ��ISTP��
	thesisNum2 =F24,				--������������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ������ڿ��������������

	keeper =F25				--����������(������):���ݸ�ʽΪ�ַ��ͣ�����Ϊ8��ָ�������豸�����ĸ�����������û�и����˵���ޡ�
from rptBase3 b left join r3 on b.eCode=r3.eCode

--���⴦����̨�豸��
select * from rptBase3 where eCode in( 'Q0198002','10000043')

update rptBase3
set useHour4Education = 24*360		--ʹ�û�ʱ����ѧ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڽ�ѧ������ʹ�û�ʱ�������������豸ʹ�ü�¼����ѧ����ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
											--ʹ�û�ʱ����Ҫ�Ŀ���׼��ʱ��+����ʱ��+����ĺ���ʱ�䡣
where eCode = 'Q0198002'

update rptBase3
set	useHour4Research = 24*360		--ʹ�û�ʱ�����У������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
where eCode = '10000043'

--��Null����Ϊ0
select * from rptBase3 where useHour4Education is null
update rptBase3
set useHour4Education = isnull(useHour4Education,0),		--ʹ�û�ʱ����ѧ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڽ�ѧ������ʹ�û�ʱ�������������豸ʹ�ü�¼����ѧ����ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
											--ʹ�û�ʱ����Ҫ�Ŀ���׼��ʱ��+����ʱ��+����ĺ���ʱ�䡣
	useHour4Research = isnull(useHour4Research,0),		--ʹ�û�ʱ�����У������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڿ��й�����ʹ�û�ʱ�������������豸ʹ�ü�¼�����з���ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Service =isnull(useHour4Service,0),			--ʹ�û�ʱ�������񣩣����ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�����������ʹ�û�ʱ�������������豸ʹ�ü�¼����������ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Open =isnull(useHour4Open,0),			--ʹ�û�ʱ�����п���ʹ�û�ʱ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�������û�����ʹ�ã��û������ϻ����ԡ��۲���Ʒ���Ļ�ʱ����
	samplesNum =isnull(samplesNum,0),				--�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ6��
											--��ѧ���ڱ������豸�ϲ��ԡ���������Ʒ����������ԭʼ��¼ͳ�����
											--ͬһ��Ʒ��һ̨�����ϲ��ԣ�ͳ�Ʋ�����Ϊ1������Է����ʹ����޹ء�
	trainStudents =isnull(trainStudents,0) ,			--��ѵ��Ա����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������ѧ������������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainTeachers =isnull(trainTeachers,0),			--��ѵ��Ա������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ����������Ľ�ʦ����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainOthers =isnull(trainOthers,0),				--��ѵ��Ա���������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������������Ա����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	experimentItems =isnull(experimentItems,0),			--��ѧʵ����Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸����������ѧ�ƻ���ʵ����Ŀ����
	researchItems =isnull(researchItems,0),			--������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸��ɵĸ��ֿ�����Ŀ�������Ŀ����
	serviceItems =isnull(serviceItems,0),			--��������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ�����ñ������豸��ɵ�ΪУ��е�����������Ŀ����
	awardsFromCountry =isnull(awardsFromCountry,0),		--����������Ҽ��������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸�ڱ�ѧ���õĹ��Ҽ����������
	awardsFromProvince =isnull(awardsFromProvince,0),		--�������ʡ�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸��ѧ���õ�ʡ�������������
	patentsFromTeacher =isnull(patentsFromTeacher,0),		--����ר������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	patentsFromStudent =isnull(patentsFromStudent,0),		--����ר����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	thesisNum1 =isnull(thesisNum1,0),				--�����������������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ�귢������������������ָ��SCI��EI ��ISTP��
	thesisNum2 =isnull(thesisNum2,0)				--������������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ������ڿ��������������

from rptBase3 

--11000004��11000005�Ŀ�������Ϊ������Ȩ�������:
select * from rptBase3 where eCode in ('11000004','11000005')
update rptBase3 set eName ='�ർ�����¼��' where eCode in ('11000004','11000005')

update rptBase3
set useHour4Education = 100,		--ʹ�û�ʱ����ѧ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڽ�ѧ������ʹ�û�ʱ�������������豸ʹ�ü�¼����ѧ����ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
											--ʹ�û�ʱ����Ҫ�Ŀ���׼��ʱ��+����ʱ��+����ĺ���ʱ�䡣
	useHour4Research = 2150,		--ʹ�û�ʱ�����У������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڿ��й�����ʹ�û�ʱ�������������豸ʹ�ü�¼�����з���ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Service =0,			--ʹ�û�ʱ�������񣩣����ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�����������ʹ�û�ʱ�������������豸ʹ�ü�¼����������ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Open =0,			--ʹ�û�ʱ�����п���ʹ�û�ʱ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�������û�����ʹ�ã��û������ϻ����ԡ��۲���Ʒ���Ļ�ʱ����
	samplesNum =256,				--�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ6��
											--��ѧ���ڱ������豸�ϲ��ԡ���������Ʒ����������ԭʼ��¼ͳ�����
											--ͬһ��Ʒ��һ̨�����ϲ��ԣ�ͳ�Ʋ�����Ϊ1������Է����ʹ����޹ء�
	trainStudents =78,			--��ѵ��Ա����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������ѧ������������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainTeachers =65,			--��ѵ��Ա������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ����������Ľ�ʦ����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainOthers =0,				--��ѵ��Ա���������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������������Ա����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	experimentItems =17,			--��ѧʵ����Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸����������ѧ�ƻ���ʵ����Ŀ����
	researchItems =6,			--������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸��ɵĸ��ֿ�����Ŀ�������Ŀ����
	serviceItems =121,			--��������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ�����ñ������豸��ɵ�ΪУ��е�����������Ŀ����
	awardsFromCountry =0,		--����������Ҽ��������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸�ڱ�ѧ���õĹ��Ҽ����������
	awardsFromProvince =0,		--�������ʡ�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸��ѧ���õ�ʡ�������������
	patentsFromTeacher =0,		--����ר������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	patentsFromStudent =0,		--����ר����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	thesisNum1 =7,				--�����������������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ�귢������������������ָ��SCI��EI ��ISTP��
	thesisNum2 =3				--������������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ������ڿ��������������

from rptBase3 
where eCode='11000004'

update rptBase3
set useHour4Education = 200,		--ʹ�û�ʱ����ѧ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڽ�ѧ������ʹ�û�ʱ�������������豸ʹ�ü�¼����ѧ����ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
											--ʹ�û�ʱ����Ҫ�Ŀ���׼��ʱ��+����ʱ��+����ĺ���ʱ�䡣
	useHour4Research = 1780,		--ʹ�û�ʱ�����У������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--���ڿ��й�����ʹ�û�ʱ�������������豸ʹ�ü�¼�����з���ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Service =0,			--ʹ�û�ʱ�������񣩣����ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�����������ʹ�û�ʱ�������������豸ʹ�ü�¼����������ͳ�ƻ�ʱ��������ʹ�û�ʱ���0�������ܿ��
	useHour4Open =0,			--ʹ�û�ʱ�����п���ʹ�û�ʱ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--�������û�����ʹ�ã��û������ϻ����ԡ��۲���Ʒ���Ļ�ʱ����
	samplesNum =418,				--�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ6��
											--��ѧ���ڱ������豸�ϲ��ԡ���������Ʒ����������ԭʼ��¼ͳ�����
											--ͬһ��Ʒ��һ̨�����ϲ��ԣ�ͳ�Ʋ�����Ϊ1������Է����ʹ����޹ء�
	trainStudents =76,			--��ѵ��Ա����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������ѧ������������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainTeachers =88,			--��ѵ��Ա������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ����������Ľ�ʦ����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	trainOthers =0,				--��ѵ��Ա���������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ���ڱ���������ѵ���ܹ�����������������Ա����������������ʽ�Ĳι�����������ԭʼ��¼ͳ�����
	experimentItems =21,			--��ѧʵ����Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸����������ѧ�ƻ���ʵ����Ŀ����
	researchItems =8,			--������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--��ѧ�����ñ������豸��ɵĸ��ֿ�����Ŀ�������Ŀ����
	serviceItems =128,			--��������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ4��
											--��ѧ�����ñ������豸��ɵ�ΪУ��е�����������Ŀ����
	awardsFromCountry =0,		--����������Ҽ��������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸�ڱ�ѧ���õĹ��Ҽ����������
	awardsFromProvince =0,		--�������ʡ�����������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2�����ñ������豸��ѧ���õ�ʡ�������������
	patentsFromTeacher =0,		--����ר������ʦ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	patentsFromStudent =0,		--����ר����ѧ���������ݸ�ʽΪ��ֵ�ͣ�����Ϊ2��
											--���ñ������豸�ڱ�ѧ���õ�����Ȩ����ר����������ʵ�����ͺ������ơ�
	thesisNum1 =5,				--�����������������������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ�귢������������������ָ��SCI��EI ��ISTP��
	thesisNum2 =4				--������������Ŀ�������ݸ�ʽΪ��ֵ�ͣ�����Ϊ3��
											--���ñ������豸�ڱ�ѧ������ڿ��������������

from rptBase3 
where eCode='11000005'

--�����豸�ı����ˣ�
update rptBase3
set keeper='������'
where reportNum='201210150001'
and eCode='11000005'

update rptBase3
set keeper='������'
where reportNum='201210150001'
and eCode='11000004'

update rptBase3
set keeper='���꿡'
where reportNum='201210150001'
and eCode='Q0198002'

update rptBase3
set keeper='�ƽ���'
where reportNum='201210150001'
and eCode='10000043'

update rptBase3
set keeper='����'
where reportNum='201210150001'
and eCode='12000162'

--����Ҫ���豸����ʹ��ϵͳ�е��豸���ƣ�
update rptBase1
set eName = e.eName
from rptBase1 r inner join equipmentList e on r.eCode= e.eCode

update rptBase3
set eName = e.eName
from rptBase3 r inner join equipmentList e on r.eCode= e.eCode

--����һ���ϱ���ʽ��
select universityCode+cast(eCode as char(8))+cast(eTypeCode as char(8)) 
	+ cast(eName as CHAR(30))+cast(eModel as CHAR(20))+cast(eFormat as CHAR(30))
	+cast(fCode as CHAR(1)) +cast(cCode as CHAR(3)) +right(SPACE(12)+cast(totalAmount as varchar(12)),12)
	+acceptDate+isnull(curEqpStatus,' ') + ISNULL(aCode,' ')+cast(eUCode as CHAR(10))+cast(eUName as CHAR(50))
from rptBase1
where reportNum='201210150001'
order by eCode desc


--��������ϱ���ʽ��
select universityCode
		+right(SPACE(8)+cast(eSumNumLastYear as varchar(8)),8)
		+right(SPACE(11)+str(eSumAmountLastYear/10000,11,2),11)
		+right(SPACE(6)+cast(bESumNumLastYear as varchar(6)),6)
		+right(SPACE(9)+str(bESumAmountLastYear/10000,9,2),9)
		+right(SPACE(6)+cast(eIncNumCurYear as varchar(6)),6)
		+right(SPACE(9)+str(eIncAmountCurYear/10000,9,2),9)
		+right(SPACE(6)+cast(eDecNumCurYear as varchar(6)),6)
		+right(SPACE(9)+str(eDecAmountCurYear/10000,9,2),9)
		+right(SPACE(8)+cast(eSumNumCurYear as varchar(8)),8)
		+right(SPACE(11)+str(eSumAmountCurYear/10000,11,2),11)
		+right(SPACE(6)+cast(bESumNumCurYear as varchar(6)),6)
		+right(SPACE(9)+str(bESumAmountCurYear/10000,9,2),9)
from rptBase2
where reportNum='201210150001'

select * from rptBase2

--���������ϱ���ʽ��
select universityCode+cast(eCode as char(8))+cast(eTypeCode as char(8))+cast(eName as char(30))
	+right(space(12)+cast(totalAmount as varchar(12)),12)
	+cast(eModel as CHAR(20))+cast(eFormat as CHAR(200))
	--�����ֶηǱ�ϵͳ�ṩ��Ӧ�ɴ����豸����ϵͳ��ʵ���ҹ���ϵͳ�ṩ��
	+right(space(4)+cast(useHour4Education as varchar(4)),4)
	+right(space(4)+cast(useHour4Research as varchar(4)),4) 
	+right(space(4)+cast(useHour4Service as varchar(4)),4) 
	+right(space(4)+cast(useHour4Open as varchar(4)),4) 
	+right(space(6)+cast(samplesNum as varchar(6)),6) 
	+right(space(4)+cast(trainStudents as varchar(4)),4) 
	+right(space(4)+cast(trainTeachers as varchar(4)),4) 
	+right(space(4)+cast(trainOthers as varchar(4)),4) 
	+right(space(3)+cast(experimentItems as varchar(3)),3) 
	+right(space(3)+cast(researchItems as varchar(3)),3) 
	+right(space(4)+cast(serviceItems as varchar(4)),4) 
	+right(space(2)+cast(awardsFromCountry as varchar(2)),2) 
	+right(space(2)+cast(awardsFromProvince as varchar(2)),2) 
	+right(space(2)+cast(patentsFromTeacher as varchar(2)),2) 
	+right(space(2)+cast(patentsFromStudent as varchar(2)),2) 
	+right(space(3)+cast(thesisNum1 as varchar(3)),3) 
	+right(space(3)+cast(thesisNum2 as varchar(3)),3) 
	+right(space(8)+cast(keeper as varchar(8)),8) 
from rptBase3
where reportNum='201210150001'

--�������豸�ı����ˣ�



--------------------------------------------��λ����ӳ���༭��洢����-------------------
drop PROCEDURE importDepart
/*
	name:		importDepart
	function:	5.ע����ϵͳ�еĵ�λ�б�ӳ�����
	input: 
				@modiManID varchar(10) output,	--ά����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-8
	UpdateDate: 

*/
create PROCEDURE importDepart
	@modiManID varchar(10) output,	--ά����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	insert eDepartCode(clgCode,clgName,uCode,uName)
	select clg.clgCode, clg.clgName, u.uCode, u.uName 
	from college clg left join useUnit u on clg.clgCode = u.clgCode
	where uCode not in (select uCode from eDepartCode)
	if @@ERROR <> 0 
	begin
		return
	end    

	set @Ret = 0

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '���½�������λӳ���', '�û�' + @modiManName
												+ '�����˽�������λӳ���')

GO
--���ԣ�
declare @ret int
exec dbo.importDepart '00000000000', @ret output
select @ret

truncate table eDepartCode
select * from eDepartCode

drop PROCEDURE queryEDepartCodeLocMan
/*
	name:		queryEDepartCodeLocMan
	function:	4.��ѯָ����������λӳ����е�λ�Ƿ��������ڱ༭
	input: 
				@uCode varchar(8),				--ʹ�õ�λ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ĵ�λ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-10-12
	UpdateDate: 
*/
create PROCEDURE queryEDepartCodeLocMan
	@uCode varchar(8),				--ʹ�õ�λ����
	@Ret int output,				--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eDepartCode where uCode = @uCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockEDepartCode4Edit
/*
	name:		lockEDepartCode4Edit
	function:	5.������������λӳ����е�λ�༭������༭��ͻ
	input: 
				@uCode varchar(8),				--ʹ�õ�λ����
				@lockManID varchar(10) output,	--�����ˣ������ǰ��λӳ��������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ĵ�λ�����ڣ�2:Ҫ�����ĵ�λ���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-12
	UpdateDate: 
*/
create PROCEDURE lockEDepartCode4Edit
	@uCode varchar(8),				--ʹ�õ�λ����
	@lockManID varchar(10) output,	--�����ˣ������ǰ��λӳ��������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĵ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eDepartCode where uCode = @uCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	update eDepartCode
	set lockManID = @lockManID 
	where uCode = @uCode
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ӳ�䵥λ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˽�������λӳ����е�λ['+ @uCode +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockEDepartCodeEditor
/*
	name:		unlockEDepartCodeEditor
	function:	6.�ͷŽ�������λӳ����е�λ�༭��
				ע�⣺�����̲���鵥λ�Ƿ���ڣ�
	input: 
				@uCode varchar(8),				--ʹ�õ�λ����
				@lockManID varchar(10) output,	--�����ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-12
	UpdateDate: 
*/
create PROCEDURE unlockEDepartCodeEditor
	@uCode varchar(8),				--ʹ�õ�λ����
	@lockManID varchar(10) output,	--�����ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eDepartCode where uCode = @uCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eDepartCode set lockManID = '' where uCode = @uCode
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
	values(@lockManID, @lockManName, getdate(), '�ͷŵ�λӳ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˽�������λӳ����е�λ['+ @uCode +']�ı༭����')
GO

drop PROCEDURE updateEDepartCodeMap
/*
	name:		updateEDepartCodeMap
	function:	7.���µ�λӳ��
	input: 
				@uCode varchar(8),		--ʹ�õ�λ����
				@isUsed char(1),		--�Ƿ�ʹ�ã����Ϊ��ʹ�ã��򲻲������������ļ���
				@eUCode varchar(8),		--ӳ���ʹ�õ�λ����
				@eUName nvarchar(30),	--ӳ���ʹ�õ�λ����
				@switchUName xml,		--��ʹ�÷��������������ӳ�䣺������������Ҫ�󣡾���һЩ��λ����ѧ���͡����С�����ʲ��ֱ���ڲ�ͬ�ĵ�λ������
				@remark nvarchar(25),	--��ע

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ�λ�����ڣ�
							2��Ҫ���µĵ�λ��������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-10
	UpdateDate: modi by lw 2013-4-6�Զ���������ӳ��ı���
*/
create PROCEDURE updateEDepartCodeMap
	@uCode varchar(8),		--ʹ�õ�λ����
	@isUsed char(1),		--�Ƿ�ʹ�ã����Ϊ��ʹ�ã��򲻲������������ļ���
	@eUCode varchar(8),		--ӳ���ʹ�õ�λ����
	@eUName nvarchar(30),	--ӳ���ʹ�õ�λ����
	@switchUName xml,		--��ʹ�÷��������������ӳ�䣺������������Ҫ�󣡾���һЩ��λ����ѧ���͡����С�����ʲ��ֱ���ڲ�ͬ�ĵ�λ������
	@remark nvarchar(25),	--��ע
	
	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���Ľ�������λӳ����е�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from eDepartCode
	where uCode = @uCode
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--����ӳ�䣬����eUCode��eUName��
	if (cast(@switchUName as varchar(max))<>'')
	begin
		declare @clgName nvarchar(30)
		set @clgName =(select clgName from eDepartCode where uCode = @uCode)
		set @eUCode = null
		select top 1 @eUCode = eUCode, @eUName = eUName from eDepartCode where eUName = @clgName and isnull(eUCode,'') <> ''
		if (@eUCode is null)
		begin
			select top 1 @eUCode=eUCode from eDepartCode where left(eUCode,1) ='L' order by eUCode desc
			if (@eUCode is null)
				set @eUCode = 'L000001'
			else
				set @eUCode = 'L' + right('00000'+ltrim(str(cast(right(@eUCode,6) as int) +1)),7)
			set @eUName = @clgName
		end
	end

	set @updateTime = getdate()
	update eDepartCode
	set isUsed = @isUsed, eUCode = @eUCode, eUName = @eUName, switchUName = @switchUName, remark = @remark,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where uCode = @uCode
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���µ�λӳ��', '�û�' + @modiManName 
												+ '�����˽�������λӳ����е�λ['+ @uCode +']��ӳ�䡣')
GO
--���ԣ�
declare	@modiManID varchar(10)	--ά���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
declare	@updateTime smalldatetime--����ʱ��
declare	@Ret		int	--�����ɹ���ʶ
set @modiManID = '0000000000'
exec updateEDepartCodeMap '00000', 'Y','1234567','����ӳ�䵥λ',
N'<root>
  <code>6080100</code>
  <name>ҩѧʵ���ѧ����</name>
  <code>6080200</code>
  <name>ҩ���о���</name>
</root>','����',
@modiManID output, @updateTime output, @Ret output
select @Ret

select * from eDepartCode

update eDepartCode
set isUsed='N', eUCode=null,eUName=null,switchUName=N''
where uCode='00000'

drop PROCEDURE delEDepartCode
/*
	name:		delEDepartCode
	function:	8.ɾ��ָ���ĵ�λ
	input: 
				@uCode varchar(8),				--ʹ�õ�λ����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ�λ�����ڣ�2��Ҫɾ���ĵ�λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-12
	UpdateDate: 

*/
create PROCEDURE delEDepartCode
	@uCode varchar(8),				--ʹ�õ�λ����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ĵ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from eDepartCode
	where uCode = @uCode
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete eDepartCode where uCode = @uCode
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ӳ�䵥λ', '�û�' + @delManName
												+ 'ɾ���˽�������λӳ����е�λ['+ @uCode +']��')

GO

drop PROCEDURE clearEDepartCode
/*
	name:		clearEDepartCode
	function:	9.���ָ����λ�Ľ�����ӳ�䵥λ
	input: 
				@uCode varchar(8),				--ʹ�õ�λ����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ�λ�����ڣ�2��Ҫ���ӳ��ĵ�λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-10-12
	UpdateDate: 

*/
create PROCEDURE clearEDepartCode
	@uCode varchar(8),				--ʹ�õ�λ����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������λӳ����е�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ĵ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from eDepartCode where uCode = @uCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from eDepartCode
	where uCode = @uCode
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	update eDepartCode 
	set isUsed = 'N', eUCode = '', eUName = '', switchUName = N'', remark = ''
	where uCode = @uCode
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '�����λӳ��', '�û�' + @delManName
												+ '����˽�������λӳ����е�λ['+ @uCode+']��ӳ�䡣')

GO


--ʹ�õ��뷽ʽ�ֹ�������������λӳ���

select e.clgCode, e.clgName, e.uCode, e.uName, c.eUCode, c.eUName, c.switchUName, c.remark 
from eDepartCode e left join c on e.clgCode=c.clgCode and e.uCode=c.uCode

update eDepartCode
set eUCode = c.eUCode, eUName=c.eUName, switchUName= convert(xml, c.switchUName,0), remark=c.remark
from eDepartCode e inner join c on e.clgCode=c.clgCode and e.uCode=c.uCode

update eDepartCode
set isUsed='Y'
where eUCode is not null

update eDepartCode
set eUName=''
where eUCode is not null and eUName is null

select * from eDepartCode
where eUCode is not null

select c.*, e.*
from eDepartCode e right join c on e.clgCode=c.clgCode and e.uCode=c.uCode
where e.clgCode is null or rtrim(e.clgCode)=''

select * from c where clgCode not in (select clgCode from college)
select * from c where uCode not in (select uCode from useUnit)
select clgCode, uCode, count(*)
from c
group by clgCode,uCode

select * from useUnit where uCode = '03301'

select * from college where clgCode='033'
select * from useUnit where clgCode='033'
select * from college where clgCode='123'
select * from useUnit where clgCode='123'
select * from useUnit where uCode='12302'

select * from c where uCode='03301'
update c
set clgCode='033'
where uCode='03301'


--���ɱ���
declare @Ret int, @reportNum as varchar(12)
exec dbo.addReport 903, '������', '2012', '2011-09-01', '2012-08-31', 
'�人��ѧ', '00200977', @Ret output, @reportNum output
select @Ret, @reportNum

select * from userInfo where cName like '��%'
select * from rptBase2 where reportNum='201210150001'

select eCode,* from l where eCode not in (select eCode from rptBase3 where reportNum='201210120005')
select eCode, * from rptBase3 where reportNum='201210120005'  and eCode not in (select eCode from l)

use epdc211
select * from rptBase2 where reportNum='201210150001'
select COUNT(*),SUM(totalAmount) from rptBase1 where reportNum='201210150001'

select * from [rptBase3] where reportNum='201210150001'

select * from equipmentList
where eCode='00J00947'


select * from reportCenter
select count(*), SUM(totalAmount) from [rptBase1] where reportNum='201210080012'
select * from [rptBase1] where reportNum='201210110004' and eCode not in (select eCode from [rptBase1] where reportNum='201210080007')
select * from equipmentList where eCode='11018354'
select * from [rptBase2] where reportNum='201210080004' 

select * from [rptBase2]
select count(*),SUM(totalAmount) from rptBase1 where reportNum='201210090003'

select * from [rptBase1] where reportNum='201210080013' and left(eucode,1)='L'



--��������¼�����ݣ�

select * from r3





--����豸ͳ��
use epdc211
--��Ȳɹ��豸�嵥��
declare	@totalStartDate varchar(10)	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
declare	@totalEndDate varchar(10)	--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
set @totalStartDate='2014-01-01'
set @totalEndDate='2014-12-31'
select e.eCode, convert(varchar(10),e.acceptDate,120), 
--״̬��(����ǰ״̬)
case (case e.curEqpStatus 
		when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
		when '5' then '9' 
		when '7' then '9'
		else e.curEqpStatus 
	  end)
when '1' then '����'
when '2' then '����'
when '3' then '����'
when '4' then '������'
when '9' then '����'
when '8' then '����'
else '����'
end, 
--��״
case e.curEqpStatus 
when '1' then '����'
when '2' then '����'
when '3' then '����'
when '4' then '������'
when '5' then '��ʧ'
when '6' then '����'
when '7' then '����'
when '8' then '����'
when '9' then '����'
else '����'
end, 
e.eName, e.eModel, e.eFormat,
isnull(e.cCode,'000'), c.cName, 
isnull(factory,'����'),	isnull(business,'����'),
annexAmount, 
dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --��ͳ�������޶���ĸ������
e.eTypeCode,  case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
e.aTypeCode, g.aTypeName,
f.fName, a.aName,
price, e.totalAmount, 
e.price + dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --��ͳ�������޶�����ܽ��
e.clgCode, clg.clgName,
isnull(e.uCode,''), isnull(u.uName,''),
keeper
from equipmentList e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
	left join country c on e.cCode = c.cCode
	left join GBT14885 g on e.aTypeCode = g.aTypeCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
where convert(varchar(10),acceptDate,120) > @totalStartDate and convert(varchar(10),acceptDate,120) <= @totalEndDate
order by e.acceptDate


--����ڿ��豸�嵥��
declare	@totalStartDate varchar(10)	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
declare	@totalEndDate varchar(10)	--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
set @totalStartDate='2014-01-01'
set @totalEndDate='2014-12-31'
select e.eCode, convert(varchar(10),e.acceptDate,120), 
--״̬��(����ǰ״̬)
case (case e.curEqpStatus 
		when '6' then dbo.getEqpStatusBeforeScrap(e.eCode)
		when '5' then '9' 
		when '7' then '9'
		else e.curEqpStatus 
	  end)
when '1' then '����'
when '2' then '����'
when '3' then '����'
when '4' then '������'
when '9' then '����'
when '8' then '����'
else '����'
end, 
--��״
case e.curEqpStatus 
when '1' then '����'
when '2' then '����'
when '3' then '����'
when '4' then '������'
when '5' then '��ʧ'
when '6' then '����'
when '7' then '����'
when '8' then '����'
when '9' then '����'
else '����'
end, 
e.eName, e.eModel, e.eFormat,
isnull(e.cCode,'000'), c.cName, 
isnull(factory,'����'),	isnull(business,'����'),
annexAmount, 
dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --��ͳ�������޶���ĸ������
e.eTypeCode,  case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
e.aTypeCode, g.aTypeName,
f.fName, a.aName,
e.price, e.totalAmount, 
e.price + dbo.getEqpAnnexAmount(e.eCode,@totalEndDate), --��ͳ�������޶�����ܽ��
e.clgCode, clg.clgName,
isnull(u.uCode,''), isnull(u.uName,''),
keeper
from equipmentList e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
	left join country c on e.cCode = c.cCode
	left join GBT14885 g on e.aTypeCode = g.aTypeCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
where convert(varchar(10),acceptDate,120) <= @totalEndDate 
and (e.curEqpStatus <> '6' or (e.curEqpStatus = '6' and convert(varchar(10),scrapDate,120) > @totalEndDate))
order by e.acceptDate



--�����豸һ����
declare	@totalStartDate varchar(10)	--ͳ�ƿ�ʼ����:"yyyy-MM-dd"��ʽ
declare	@totalEndDate varchar(10)	--ͳ�ƽ�������:"yyyy-MM-dd"��ʽ
set @totalStartDate='2014-01-01'
set @totalEndDate='2014-12-31'
select convert(varchar(10),scrapDate,120),e.eCode, convert(varchar(10),e.acceptDate,120), 
e.eName, e.eModel, e.eFormat,
isnull(e.cCode,'000'), c.cName, 
isnull(factory,'����'),	isnull(business,'����'),
annexAmount, 
e.eTypeCode,  case isnull(e.eTypeName,'') when '' then e.eName else e.eTypeName end, 
e.aTypeCode, g.aTypeName,
f.fName, a.aName,
price, e.totalAmount, 
e.clgCode, clg.clgName,
isnull(u.uCode,''), isnull(u.uName,''),
keeper
from equipmentList e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
	left join country c on e.cCode = c.cCode
	left join GBT14885 g on e.aTypeCode = g.aTypeCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
where convert(varchar(10),scrapDate,120) > @totalStartDate and convert(varchar(10),scrapDate,120) <= @totalEndDate
order by e.scrapDate


--��ȡָ������ǰ�ĸ�����
drop FUNCTION getEqpAnnexAmount
/*
	name:		getEqpAnnexAmount
	function:	1.��ȡ�豸��ָ������ǰ�ĸ������
	input: 
				@eCode char(8),	--�豸���
				@totalEndDate varchar(10) --ͳ�ƽ�ֹ����
	output: 
				return char(1)	--�豸����ǰ��״̬
	author:		¬έ
	CreateDate:	2015-5-30
	UpdateDate: 
*/
create FUNCTION getEqpAnnexAmount
(  
	@eCode char(8),	--�豸���
	@totalEndDate varchar(10) --ͳ�ƽ�ֹ����
)  
RETURNS numeric(12, 2)
WITH ENCRYPTION
AS      
begin
	--�����豸�е� �������-������ֹ���ڵĸ������ӽ�� ���㣬������֤�������ݣ�����ʱ�������ͬʱ���գ�ԭ����ϵͳû�и����嵥����⣩����ȷ��ʾ��
	DECLARE @total numeric(12, 2), @overTotal numeric(12, 2)--�������ȫֵ/������ֹ���ڵĸ������ӽ��
	select @total = isnull(annexAmount,0)
	from equipmentList
	where eCode =@eCode
	select @overTotal = isnull(sum(an.totalAmount),0) 
	from equipmentAnnex an left join eqpAcceptInfo a on an.acceptApplyID = a.acceptApplyID
	where an.eCode =@eCode and convert(varchar(10),a.acceptDate,120) > @totalEndDate
	return @total - @overTotal
end
--���ԣ�
select dbo.getEqpAnnexAmount('15007011','2015-12-31')


select sum(an.totalAmount)
from equipmentAnnex an left join eqpAcceptInfo a on an.acceptApplyID = a.acceptApplyID
where an.eCode ='V0780003' and convert(varchar(10),a.acceptDate,120) > '2014-12-31'

