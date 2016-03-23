use epdc211
/*
	����豸������Ϣϵͳ-���չ���
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: 
*/

--���յ���
update eqpAcceptInfo
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode

update eqpAcceptInfo 
set obtainMode = 1,purchaseMode=2

alter TABLE eqpAcceptInfo add	photoXml xml null					--�豸��Ƭ��add by lw 2012-10-25
update 	eqpAcceptInfo
set photoXml=N'<root></root>'

alter TABLE eqpAcceptInfo add eqpLocate nvarchar(100) null	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-10-27
alter TABLE eqpAcceptInfo add photoXml xml null					--�豸��Ƭ��add by lw 2012-10-25
alter TABLE eqpAcceptInfo add eqpLocate nvarchar(100) null		--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-10-27
select * from eqpAcceptInfo where acceptApplyID='201209290007'
drop TABLE eqpAcceptInfo
CREATE TABLE eqpAcceptInfo
(
	acceptApplyType smallint default(0),--���յ����ͣ�0->���豸���յ���1->�������յ� add by lw 2011-6-28�޸�Ϊ֧��
	acceptApplyID char(12) not null,	--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
	applyDate smalldatetime default(getdate()),	--�������� add by lw 2010-12-5
	acceptApplyStatus int default(0),	--���յ�״̬��0->���ڱ��ƣ�1->�ѷ���δ��ˣ�2->�����ͨ����δ���ͨ��ֱ�ӻָ�0״̬
	procurementPlanID char(12) null,	--��Ӧ�Ĳɹ��ƻ����ţ�����һ��������չ���ֶ�
	
	eTypeCode char(8) not null,			--�����ţ��̣�
	eTypeName nvarchar(30) not null,	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	aTypeCode varchar(7) not null,		--�����ţ��ƣ�
										--����GB/T 14885-2010�涨�������ӳ���7λmodi by lw 2012-2-23
	
	eName nvarchar(30) not null,		--�豸����
	eModel nvarchar(20) not null,		--�豸�ͺ�
	eFormat nvarchar(20) not null,		--�豸���
	unit nvarchar(10) null,				--������λ��add by lw 2012-10-5�õ�λ��GBT14885���л�ȡ
	cCode char(3) not null,				--���Ҵ���
	factory	nvarchar(20) not null,		--��������
	makeDate smalldatetime null,		--�������ڣ��ڽ���������
	serialNumber nvarchar(2100) null,	--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	buyDate smalldatetime not null,		--�������ڣ��������ֵ���������в����ǿ�ֵ�������Ҫ����ת������
	business nvarchar(20) not null,		--���۵�λ
	fCode char(2) not null,				--������Դ����
	aCode char(2) null,					--ʹ�÷�����룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������
	clgCode char(3) not null,			--ѧԺ����
	clgName nvarchar(30) null,			--ѧԺ����:������ƣ�������ʷ���� add by lw 2010-11-30
	uCode varchar(8) null,				--ʹ�õ�λ���룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) null,			--ʹ�õ�λ����:������ƣ�������ʷ���� add by lw 2010-11-30
	keeperID varchar(10) null,			--�����˹���,add by lw 2012-8-10
	keeper nvarchar(30) null,			--������
	eqpLocate nvarchar(100) null,		--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-10-27

	annexName nvarchar(20) null,		--��������
	--modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ���������ţ�UI���Ѿ�ɾ�������ݿ���ʱ����
	--annexCode nvarchar(2100) null,	--����������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	annexAmount	numeric(12,2) null,		--��������

	price numeric(12,2) null,			--���ۣ�>0
	totalAmount numeric(12,2) null,		--�ܼ�, >0������+�����۸�
	sumNumber int not null,				--����
	sumAmount numeric(15,2) not null,	--�ϼƽ��
	oprManID varchar(10) null,			--�����˹���,add by lw 2012-8-10
	oprMan nvarchar(30) null,			--������

	notes nvarchar(50) null,			--��ע
	startECode char(8) null,			--�豸��ʼ���,ʹ�ú��뷢�����������ֹ����룬����Ҫ�������
										--2λ��ݴ���+6λ��ˮ�ţ�����Ԥ�����ɣ�ÿ������һ���Ŷ�XXX
										--ʹ���ֹ�������룬�Զ��������Ƿ��غ�
	endECode char(8) null,				--�豸�������
	accountCode varchar(9) null,		--��ƿ�Ŀ���� --modi by lw 2011-4-4�޸�Ϊ��̬��չ�ַ���
	acceptDate smalldatetime null,		--��������
	acceptManID varchar(10) null,		--�����˹���
	acceptMan nvarchar(30) null,		--������
	photoXml xml null,					--�豸��Ƭ��add by lw 2012-10-25
	--�ƻ����ӵ��ֶΣ��ϴ�ͬ������ 2012-10-3
	obtainMode int default(1),			--ȡ�÷�ʽ���ɵ�11�Ŵ����ֵ䶨�壬add by lw 2012-10-1Ĭ�Ϸ�ʽ������
	purchaseMode int default(2),		--�ɹ���֯��ʽ���ɵ�18�Ŵ����ֵ䶨�壬add by lw 2012-10-1Ĭ��ֵ�����ż��вɹ�


	
	--�����ˣ�add by lw 2012-8-8Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_eqpAcceptInfo] PRIMARY KEY CLUSTERED 
(
	[acceptApplyID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_eqpAcceptInfo] ON [dbo].[eqpAcceptInfo] 
(
	[clgCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpAcceptInfo_1] ON [dbo].[eqpAcceptInfo] 
(
	[clgCode] ASC,
	[uCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



select * from accountTitle where accountCode ='14003040 '

drop FUNCTION getSerialNumber
/*
	name:		getSerialNumber
	function:	0.1.�����յ��ĳ������ת��Ϊ�м�
	input: 
				@acceptApplyID char(12)	--���յ���
	output: 
				return table
				(
					serialNumber varchar(20)
				)		--������ŵ��м�
	author:		¬έ
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION getSerialNumber
(  
	@acceptApplyID char(12)	--���յ���
)  
RETURNS @ret table
(
	serialNumber nvarchar(20)
)
WITH ENCRYPTION
AS      
begin
	DECLARE @String NVARCHAR(max);
	SET @String = isnull((select serialNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	insert @ret
	SELECT convert(nvarchar(20),T.x.query('data(.)')) FROM 
			(SELECT CONVERT(XML,'<x>'+REPLACE(@String,'|','</x><x>')+'</x>',1) Col1) A
			OUTER APPLY A.Col1.nodes('/x') AS T(x)
	return
end
--���ԣ�
select * from dbo.getSerialNumber('201208250001')

drop FUNCTION includedSerialNumber
/*
	name:		includedSerialNumber
	function:	0.2.������յ��ĳ�����ż����Ƿ����ָ���ĳ������
	input: 
				@acceptApplyID char(12),	--���յ���
				@serialNumber nvarchar(20)	--�������
	output: 
				return int,					--�Ƿ����ָ���ĳ�����ţ�0->��������1->����
	author:		¬έ
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION includedSerialNumber
(  
	@acceptApplyID char(12),	--���յ���
	@serialNumber nvarchar(20)	--�������
)  
RETURNS int
WITH ENCRYPTION
AS      
begin
	DECLARE @String NVARCHAR(max);
	SET @String = isnull((select serialNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	declare @ret int
	set @ret = 0
	if @serialNumber in (SELECT convert(nvarchar(20),T.x.query('data(.)')) FROM 
			(SELECT CONVERT(XML,'<x>'+REPLACE(@String,'|','</x><x>')+'</x>',1) Col1) A
			OUTER APPLY A.Col1.nodes('/x') AS T(x))
		set @ret = 1
	else
		set @ret = 0
	return @ret
end
--���ԣ�
select dbo.includedSerialNumber('201208250001','50')

drop FUNCTION includedSerialNumber2
/*
	name:		includedSerialNumber2
	function:	0.3.������յ��ĳ�����ż����Ƿ����ָ���ĳ�����ţ�ʹ���ַ���ƥ�䷽����
	input: 
				@acceptApplyID char(12),	--���յ���
				@serialNumber nvarchar(20)	--�������
	output: 
				return int,					--�Ƿ����ָ���ĳ�����ţ�0->��������1->����
	author:		¬έ
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION includedSerialNumber2
(  
	@acceptApplyID char(12),	--���յ���
	@serialNumber nvarchar(20)	--�������
)  
RETURNS int
WITH ENCRYPTION
AS      
begin
	DECLARE @String NVARCHAR(2100);
	SET @String = isnull((select serialNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	declare @ret int
	set @ret = CHARINDEX(@serialNumber, @String)
	
	if @ret > 0
	begin
		if @ret > 1
		begin
			if (substring(@String,@ret - 1,1)<>'|')
				return 0
		end
		declare @len int
		set @len = len(@serialNumber)
		if (@ret + @len <= len(@string))
		begin
			if (substring(@String,@ret + @len,1)<>'|')
				return 0
		end
		set @ret = 1
	end
	else
		set @ret = 0
	return @ret
end
--���ԣ�
select dbo.includedSerialNumber2('201208250001','50')

--�Ƚ������㷨���ٶȣ�
select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber(acceptApplyID,N'1') flag from eqpAcceptInfo) as tab
where tab.flag=1 

select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'49') flag from eqpAcceptInfo) as tab
where tab.flag=1 

select * from
(select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber(acceptApplyID,N'1') flag from eqpAcceptInfo) as tab
where tab.flag=1) as t1
right join
(select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'1') flag from eqpAcceptInfo) as tab
where tab.flag=1) as t2 on t1.acceptApplyID = t2.acceptApplyID
where t1.acceptApplyID is null

drop FUNCTION findIncludedSerialNumber
/*
	name:		findIncludedSerialNumber
	function:	0.4.������յ����еĳ�����ż������ذ���ָ���ĳ�����ţ�ʹ���ַ���ƥ�䷽��,������ſ���Ϊ�����ʹ�á�,���ָ������м�
	input: 
				@serialNumber nvarchar(max),	--������ţ�����������ʹ��","�ָ�
				@matchType int	--ƥ�䷽ʽ��0->����ƥ�䣬1->���ƥ��
	output: 
				return int,					--�Ƿ����ָ���ĳ�����ţ�0->��������1->����
	author:		¬έ
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION findIncludedSerialNumber
(  
	@serialNumber nvarchar(max),	--������ţ�����������ʹ��","�ָ�
	@matchType int	--ƥ�䷽ʽ��0->����ƥ�䣬1->���ƥ��
)  
RETURNS @retTab table
(
	acceptApplyID char(12) not null	--���յ���
)
WITH ENCRYPTION
AS      
begin
	--��Ҫƥ��ĳ�����ŷֽ���м���
	declare @m table
	(
		s nvarchar(20)
	)
	insert @m
	SELECT convert(nvarchar(20),T.x.query('data(.)')) FROM 
			(SELECT CONVERT(XML,'<x>'+REPLACE(@serialNumber,',','</x><x>')+'</x>',1) Col1) A
			OUTER APPLY A.Col1.nodes('/x') AS T(x)
	declare @s nvarchar(20)
	declare tar cursor Scroll for
	select s from @m
	For Read Only
	OPEN tar
	
	DECLARE @acceptApplyID char(12)	--���յ���
	DECLARE @String NVARCHAR(2100);
	declare tar1 cursor for
	select acceptApplyID, serialNumber from eqpAcceptInfo
	OPEN tar1
	FETCH NEXT FROM tar1 INTO @acceptApplyID, @String
	WHILE @@FETCH_STATUS = 0
	begin
		FETCH first FROM tar INTO @s
		WHILE @@FETCH_STATUS = 0
		begin
			declare @ret int
			set @ret = CHARINDEX(@s, @String)
			
			if @ret > 0
			begin
				if @ret > 1
				begin
					if (substring(@String,@ret - 1,1)<>'|')
						break
				end
				if (@matchType=0)	--����ƥ��
				begin
					declare @len int
					set @len = len(@s)
					if (@ret + @len <= len(@string))
					begin
						if (substring(@String,@ret + @len,1)<>'|')
							break
					end
				end
				insert @retTab
				values(@acceptApplyID)
			end
			FETCH NEXT FROM tar INTO @s
		end
		
		FETCH NEXT FROM tar1 INTO @acceptApplyID, @String
	end
	CLOSE tar1
	DEALLOCATE tar1

	CLOSE tar
	DEALLOCATE tar

	return
end
--���ԣ�
select acceptApplyID, serialNumber from eqpAcceptInfo where acceptApplyID in (select acceptApplyID from dbo.findIncludedSerialNumber('50,10',0))

select distinct acceptApplyID
from
((select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'49') flag from eqpAcceptInfo) as tab
where tab.flag=1) 
union all
(select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'99') flag from eqpAcceptInfo) as tab
where tab.flag=1)
) as t


drop PROCEDURE addAcceptApply
/*
	name:		addAcceptApply
	function:	1.����������뵥
				ע�⣺�ô洢�����Զ���������
	input: 
				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
				@aTypeCode varchar(7),		--�����ţ��ƣ�
				@eName nvarchar(30),		--�豸����
				@eModel nvarchar(20),		--�豸�ͺ�
				@eFormat nvarchar(20),		--�豸���
				@cCode char(3),				--���Ҵ���
				@factory nvarchar(20),		--��������
				@makeDate smalldatetime,	--�������ڣ��ڽ���������
				@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
				@buyDate smalldatetime,		--��������
				@business nvarchar(20),		--���۵�λ
				@fCode char(2),				--������Դ����
				@aCode char(2),				--ʹ�÷������
				@clgCode char(3),			--ѧԺ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@keeperID varchar(10),		--�����˹���,add by lw 2012-8-10
				@annexName nvarchar(20),	--��������
				--modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������
				--@annexCode nvarchar(2100),--����������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
				@annexAmount numeric(12,2),	--�������
				@price numeric(12,2),		--���ۣ�>0
				@sumNumber int,				--����
				@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10
				@notes nvarchar(50),		--��ע
				@photoXml xml,				--�豸��Ƭ��add by lw 2012-10-25
				@eqpLocate nvarchar(100),	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-12-19

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output	--���ʱ��
				@acceptApplyID char(12) output	--���ɵ����յ��ţ�ʹ�õ� 1 �ź��뷢��������
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������

				modi by lw 2012-2-23�����¹���GB/T 14885-2010�ӳ������������ų��ȣ�
				���ӽ������������Ƶı�ע�Ͳ���������ı�ע
				modi by lw 2012-8-8���Ӵ������ֶ�
				modi by lw 2012-8-9�����˺;�����ʹ�ù�������
				modi by lw 2012-10-5���Ӽ�����λ�ֶΣ����ݲ����������Զ�����GBT14885��ȡ��Ӧ�ļ�����λ�������޸�δ�޶��ӿ�
				modi by lw 2012-10-25�����豸��Ƭ����
				modi by lw 2012-10-27�޸����ڲ��ϼƽ��������Ȳ���������
				modi by lw 2012-12-19�����豸���ڵ��ֶ�
*/
create PROCEDURE addAcceptApply
	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	@aTypeCode varchar(7),		--�����ţ��ƣ�
	@eName nvarchar(30),		--�豸����
	@eModel nvarchar(20),		--�豸�ͺ�
	@eFormat nvarchar(20),		--�豸���
	@cCode char(3),				--���Ҵ���
	@factory nvarchar(20),		--��������
	@makeDate smalldatetime,	--�������ڣ��ڽ���������
	@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	@buyDate smalldatetime,		--��������
	@business nvarchar(20),		--���۵�λ
	@fCode char(2),				--������Դ����
	@aCode char(2),				--ʹ�÷������
	@clgCode char(3),			--ѧԺ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@keeperID varchar(10),		--�����˹���,add by lw 2012-8-10
	@annexName nvarchar(20),	--��������
	--modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������
	--@annexCode nvarchar(2100),--����������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	@annexAmount numeric(12,2),	--�������
	@price numeric(12,2),		--���ۣ�>0
	@sumNumber int,				--����
	@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10
	@notes nvarchar(50),		--��ע
	@photoXml xml,				--�豸��Ƭ��add by lw 2012-10-25
	@eqpLocate nvarchar(100),	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-12-19

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@acceptApplyID char(12) output	--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1, 1, @curNumber output
	set @acceptApplyID = @curNumber

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--ȡ������λ��
	declare @unit nvarchar(10)
	set @unit = ISNULL((select unit from GBT14885 where aTypeCode = @aTypeCode),'')
	
	--�����
	declare @totalAmount numeric(12,2)			--�ܼ�, >0������+�����۸�
	declare @sumAmount numeric(15,2)			--�ϼƽ��
	set @totalAmount = 	@annexAmount + @price
	set @sumAmount = @totalAmount * @sumNumber
	
	--��ȡԺ���ʹ�õ�λ�����ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)	--ѧԺ����/ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--ȡ�����ˡ������˵�������
	declare @keeper nvarchar(30),@oprMan nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')
	
	set @createTime = getdate()
	insert eqpAcceptInfo(acceptApplyID, eTypeCode, eTypeName, aTypeCode, eName,
							eModel, eFormat, unit, cCode, factory, makeDate, serialNumber, buyDate, business, fCode, aCode, 
							clgCode, clgName, uCode, uName, 
							keeperID, keeper, annexName, annexAmount, price, totalAmount, sumNumber, sumAmount,
							oprManID, oprMan, notes,photoXml, eqpLocate,
							lockManID, modiManID, modiManName, modiTime,
							createManID, createManName, createTime) 
	values (@acceptApplyID, @eTypeCode, @eTypeName, @aTypeCode, @eName,
							@eModel, @eFormat, @unit, @cCode, @factory, @makeDate, @serialNumber, @buyDate, @business, @fCode, @aCode, 
							@clgCode, @clgName, @uCode, @uName, 
							@keeperID, @keeper, @annexName, @annexAmount, @price, @totalAmount, @sumNumber, @sumAmount,
							@oprManID, @oprMan, @notes,@photoXml, @eqpLocate,
							@createManID, @createManID, @createManName, @createTime,
							@createManID, @createManName, @createTime) 
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '����������뵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��������������뵥[' + @acceptApplyID + ']��')
GO

drop PROCEDURE queryAcceptApplyLocMan
/*
	name:		queryAcceptApplyLocMan
	function:	2.��ѯָ���������뵥�Ƿ��������ڱ༭
	input: 
				@acceptApplyID char(12),	--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�������յ�������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE queryAcceptApplyLocMan
	@acceptApplyID char(12),	--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockAcceptInfo4Edit
/*
	name:		lockAcceptInfo4Edit
	function:	3.�������յ��༭������༭��ͻ
	input: 
				@acceptApplyID char(12),	--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���������յ������ڣ�2:Ҫ���������յ����ڱ����˱༭��3:�õ��������
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE lockAcceptInfo4Edit
	@acceptApplyID char(12),		--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ���������յ��Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @acceptApplyStatus int
	set @acceptApplyStatus = (select acceptApplyStatus from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

/*	���ݱϴ���Ҫ�󣬷ſ������޸�Ȩ�ޣ�����ɾ����del by lw 2010-11-22
	--ȡ���ά���˵�ID
	declare @modiManID int
	set @modiManID = (select modiManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	--���Ȩ�ޣ�
	if @lockManID <> @modiManID	--�豸����Աֻ�������Լ��ĵ���
	begin
		set @Ret = 3
		return
	end
*/
	update eqpAcceptInfo 
	set lockManID = @lockManID 
	where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������յ��༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�����������յ�['+ @acceptApplyID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockAcceptInfoEditor
/*
	name:		unlockAcceptInfoEditor
	function:	4.�ͷ����յ��༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@acceptApplyID char(12),		--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE unlockAcceptInfoEditor
	@acceptApplyID char(12),		--���������յ��ţ�ʹ�õ� 1 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpAcceptInfo set lockManID = '' where acceptApplyID = @acceptApplyID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ����յ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ������յ�['+ @acceptApplyID +']�ı༭����')
GO


drop PROCEDURE updateAcceptInfo
/*
	name:		updateAcceptInfo
	function:	5.�������յ�
	input: 
				@acceptApplyID char(12),	--���յ���
				@applyDate smalldatetime,	--��������
				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
				@aTypeCode varchar(7),		--�����ţ��ƣ�
				@eName nvarchar(30),		--�豸����
				@eModel nvarchar(20),		--�豸�ͺ�
				@eFormat nvarchar(20),		--�豸���
				@cCode char(3),				--���Ҵ���
				@factory nvarchar(20),		--��������
				@makeDate smalldatetime,	--�������ڣ��ڽ���������
				@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
				@buyDate smalldatetime,		--��������
				@business nvarchar(20),		--���۵�λ
				@fCode char(2),				--������Դ����
				@aCode char(2),				--ʹ�÷������
				@clgCode char(3),			--ѧԺ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@keeperID varchar(10),		--�����˹���,add by lw 2012-8-10
				@annexName nvarchar(20),	--��������
				--modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������
				--@annexCode nvarchar(2100),--����������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
				@annexAmount numeric(12,2),	--�������
				@price numeric(12,2),		--���ۣ�>0
				@sumNumber int,				--����
				@oprManID varchar(10),		--�������˹���,add by lw 2012-8-10
				@notes nvarchar(50),		--��ע
				@photoXml xml,				--�豸��Ƭ��add by lw 2012-10-25
				@eqpLocate nvarchar(100),	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-12-19

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ�����������뵥�����ڣ�2��Ҫ���µ����յ���������������3:�õ����Ѿ�ͨ����ˣ��������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: 2011-1-18�����������ڵ��޸�
				modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������
				modi by lw 2012-2-23�����¹���GB/T 14885-2010�ӳ������������ų��ȣ�
				���ӽ������������Ƶı�ע�Ͳ���������ı�ע
				modi by lw 2012-10-5���Ӽ�����λ�ֶΣ����ݲ����������Զ�����GBT14885��ȡ��Ӧ�ļ�����λ�������޸�δ�޶��ӿ�
				modi by lw 2012-10-25�����豸��Ƭ����
				modi by lw 2012-12-19�����豸���ڵ��ֶ�
*/
create PROCEDURE updateAcceptInfo
	@acceptApplyID char(12),	--���յ���
	@applyDate smalldatetime,	--��������
	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	@aTypeCode varchar(7),		--�����ţ��ƣ�
	@eName nvarchar(30),		--�豸����
	@eModel nvarchar(20),		--�豸�ͺ�
	@eFormat nvarchar(20),		--�豸���
	@cCode char(3),				--���Ҵ���
	@factory nvarchar(20),		--��������
	@makeDate smalldatetime,	--�������ڣ��ڽ���������
	@serialNumber nvarchar(2100),--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	@buyDate smalldatetime,		--��������
	@business nvarchar(20),		--���۵�λ
	@fCode char(2),				--������Դ����
	@aCode char(2),				--ʹ�÷������
	@clgCode char(3),			--ѧԺ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@keeperID varchar(10),		--�����˹���,add by lw 2012-8-10
	@annexName nvarchar(20),	--��������
	--modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������
	--@annexCode nvarchar(2100),--����������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	@annexAmount numeric(12,2),	--�������
	@price numeric(12,2),		--���ۣ�>0
	@sumNumber int,				--����
	@oprManID varchar(10),		--�����˹���,add by lw 2012-8-10
	@notes nvarchar(50),		--��ע
	@photoXml xml,				--�豸��Ƭ��add by lw 2012-10-25
	@eqpLocate nvarchar(100),	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-12-19

	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--�����
	declare @totalAmount numeric(12,2)			--�ܼ�, >0������+�����۸�
	declare @sumAmount numeric(15,2)			--�ϼƽ��
	set @totalAmount = 	@annexAmount + @price
	set @sumAmount = @totalAmount * @sumNumber
	
	--ȡ������λ��
	declare @unit nvarchar(10)
	set @unit = ISNULL((select unit from GBT14885 where aTypeCode = @aTypeCode),'')

	--��ȡԺ���ʹ�õ�λ�����ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)	--ѧԺ����/ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--ȡ�����ˡ�������������������
	declare @keeper nvarchar(30),@oprMan nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update eqpAcceptInfo 
	set applyDate = @applyDate, eTypeCode = @eTypeCode, eTypeName = @eTypeName, aTypeCode = @aTypeCode, eName = @eName,
		eModel = @eModel, eFormat = @eFormat, unit = @unit, cCode = @cCode, 
		factory = @factory, makeDate = @makeDate, serialNumber = @serialNumber, 
		buyDate = @buyDate, business = @business, fCode = @fCode, aCode = @aCode, 
		clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
		keeperID = @keeperID, keeper = @keeper, annexName = @annexName, annexAmount = @annexAmount, 
		price = @price, totalAmount = @totalAmount, sumNumber = @sumNumber, sumAmount = @sumAmount,
		oprManID = @oprManID, oprMan = @oprMan, notes = @notes,
		photoXml = @photoXml, eqpLocate = @eqpLocate,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�������յ�', '�û�' + @modiManName 
												+ '���������յ�['+ @acceptApplyID +']��')
GO


drop PROCEDURE delAcceptApply
/*
	name:		delAcceptApply
	function:	6.ɾ��ָ�����������뵥
	input: 
				@acceptApplyID char(12),	--�������뵥��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����������뵥�����ڣ�2��Ҫɾ�����������뵥��������������3�������������Ч������ɾ����9��δ֪����
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: 

*/
create PROCEDURE delAcceptApply
	@acceptApplyID char(12),	--���յ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	delete eqpAcceptInfo where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���������뵥', '�û�' + @delManName
												+ 'ɾ�����������뵥['+ @acceptApplyID +']��')

GO


drop PROCEDURE sendAcceptApply
/*
	name:		sendAcceptApply
	function:	7.�������յ�
				��ע���ô洢��������û��ʹ�ã���
	input: 
				@acceptApplyID char(12),	--���յ���

				--ά����:
				@sendManID varchar(10) output,	--�����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 

				@sendTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ�����������뵥�����ڣ�2��Ҫ���͵����յ���������������3�����������󣬲����ٴη��ͣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE sendAcceptApply
	@acceptApplyID char(12),	--���յ���

	--ά����:
	@sendManID varchar(10) output,	--�����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@sendTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @sendManID)
	begin
		set @sendManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @sendManID),'')
	
	set @sendTime = getdate()
	update eqpAcceptInfo
	set acceptApplyStatus = 1,	--���յ�״̬��0->���ڱ��ƣ�1->�ѷ���δ��ˣ�2->�����ͨ����δ���ͨ��ֱ�ӻָ�0״̬
		--ά���ˣ�
		modiManID = @sendManID, modiManName = @modiManName,	modiTime = @sendTime
	where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@sendManID, @modiManName, @sendTime, '�������յ�', '�û�' + @modiManName 
												+ '���������յ�['+ @acceptApplyID +']��')
GO

drop PROCEDURE verifyAcceptApply
/*
	name:		verifyAcceptApply
	function:	8.����������뵥���������豸�嵥
	input: 
				@acceptApplyID char(12),	--���յ���
				@eTypeCode char(8),			--�����ţ��̣�
				@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
				@aTypeCode varchar(7),		--�����ţ��ƣ�
				@startECode char(8),		--�豸��ʼ���
				@accountCode varchar(9),	--��ƿ�Ŀ����

				--ά����:
				@verifyManID varchar(10) output,	--����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@acceptDate smalldatetime output,	--��������
				@Ret		int output				--�����ɹ���ʶ
													0:�ɹ���1��ָ�����������뵥������,2��Ҫ��˵����յ���������������
													3�������յ��Ѿ���ˣ�4:����ĺ���α�ռ�ã�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-24
	UpdateDate: 2011-1-18�����豸����������Ϣ�Ǽ�
				modi by lw 2011-2-19�޸����������ô���
				modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������
				modi by lw 2011-4-4�ӳ���ƿ�Ŀ����
				modi by lw 2011-6-28�޸�δ�ǼǸ�����Ĵ������ӡ���Ӹ���������֧��
				modi by lw 2011-10-8�޸��豸�������δ�Ǽ��豸eTypeName�ֶε���ִ�в��ɹ�����͸����Ǽ����������
				modi by lw 2011-10-15�����豸�������ڱ��еı䶯���͡��䶯ƾ֤�Ǽǣ�
				modi by lw 2011-10-16Ӧ�ͻ�Ҫ��������˵�ʱ������޸��豸�����������ӵĽӿ�
				modi by lw 2012-2-23�����¹���GB/T 14885-2010�ӳ������������ų��ȣ�
				���ӽ������������Ƶı�ע�Ͳ���������ı�ע
				modi by lw 2012-8-9���ӱ����˺;����˹���
				modi by lw 2012-10-5���Ӽ�����λ\ȡ�÷�ʽ\�ɹ���֯��ʽ�ֶδ��ͣ������޸�δ�޶��ӿ�
				modi by lw 2012-10-6ɾ���˸����������ֶκ�ά���ֶ�
				modi by lw 2012-10-27�����豸��Ƭ�����豸��״��
				modi by lw 2012-12-19�����豸��ռ���ֶδ���
*/
create PROCEDURE verifyAcceptApply
	@acceptApplyID char(12),	--���յ���
	@eTypeCode char(8),			--�����ţ��̣�
	@eTypeName nvarchar(30),	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	@aTypeCode varchar(7),		--�����ţ��ƣ�
	@startECode char(8),		--�豸��ʼ���
	@accountCode varchar(9),	--��ƿ�Ŀ����

	--ά����:
	@verifyManID varchar(10) output,	--����ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@acceptDate smalldatetime output,	--��������
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	declare @clgCode char(3), @uCode char(5)
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus, @clgCode = clgCode, @uCode = uCode
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @verifyManID)
	begin
		set @verifyManID = @thisLockMan
		set @Ret = 2
		return
	end
	--�ٴμ�鵥��״̬:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	--��ȡԺ���ʹ�õ�λ�����ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)	--ѧԺ����/ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--���������ź͸�����ű�
	declare @serialNumber nvarchar(2100)--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	--modi by lw 2011-2-22 ӦС�ϵ�Ҫ�󣬲���Ҫ����������
	--declare @annexCode nvarchar(2100)	--����������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	select @serialNumber = serialNumber	--, @annexCode = annexCode
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	declare @xmlSerialNumber xml	--, @xmlAnnexCode xml
	set @xmlSerialNumber = '<s>'+REPLACE(@serialNumber,'|','</s><s>')+'</s>'
	--set @xmlAnnexCode = '<a>'+REPLACE(@annexCode,'|','</a><a>')+'</a>'

	--ȡά���˵�������
	declare @acceptMan nvarchar(30)
	set @acceptMan = isnull((select userCName from activeUsers where userID = @verifyManID),'')

	set @acceptDate = getdate()
	
	declare @length int
	set @length = (select sumNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	--�����豸�嵥��
	begin tran
		--��������豸����Ƿ�ռ��
		declare @execRet int
		exec dbo.checkEqpCodes @startECode, @length, @execRet output
		if (@execRet <> 0)
		begin 
			set @Ret = @execRet
			if (@Ret = -1)
				set @Ret = 4
			rollback tran
			return
		end
		--���ɽ�������
		declare @intEndNum int
		set @intEndNum = cast(right(@startECode,6) as int) + @length - 1
		declare @endCode as varchar(8)
		set @endCode = left(@startECode,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
		--ռ�øú���Σ�
		update eqpCodeList 
		set isUsed = 'Y'
		where eCode >= @startECode and eCode <= @endCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--��ȡ������Ϣ��
		declare @annexName nvarchar(20), @annexAmount numeric(12,2)	--��������,���������Ǹ������ۣ�
		select @annexName = annexName, @annexAmount = annexAmount
		from eqpAcceptInfo 
		where acceptApplyID = @acceptApplyID
				
		declare @rowID int --�кţ�����ȡ�豸������ź͸�����ŵ����к�
		set @rowID = 1
		
		--��������豸�嵥��
		declare @eCode char(8)
		declare tar cursor for
		select eCode from eqpCodeList 
		where eCode >= @startECode and eCode <= @endCode
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode
		WHILE @@FETCH_STATUS = 0
		begin
			declare @curSerialNumber nvarchar(20)	--��ǰ�豸�ĳ������
			--declare @curAnnexCode nvarchar(20)		--��ǰ�豸������������
			set @curSerialNumber = (select cast(@xmlSerialNumber.query('(/s)[sql:variable("@rowID")]/text()') as nvarchar(20)))
			--set @curAnnexCode = (select cast(@xmlAnnexCode.query('(/a)[sql:variable("@rowID")]/text()') as nvarchar(20)))
			--�����豸�嵥��
			insert equipmentList(eCode, acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, annexName, annexAmount, business,
				eTypeCode, eTypeName, aTypeCode, 
				fCode, aCode, makeDate, buyDate, price, totalAmount, clgCode, uCode, keeperID, keeper,eqpLocate, notes,
				acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus,
				serialNumber, annexCode, obtainMode, purchaseMode,
				--����ά�����:
				modiManID, modiManName, modiTime)
			select @eCode, @acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, annexName, annexAmount, business,
				--modi by lw 2011-10-16
				@eTypeCode,@eTypeName,@aTypeCode,
				fCode, aCode, makeDate, buyDate, price, totalAmount, clgCode, uCode, keeperID, keeper,eqpLocate, notes,
				@acceptDate, oprManID, oprMan, @verifyManID, @acceptMan, '1',
				@curSerialNumber, '', obtainMode, purchaseMode,
				--����ά�����:
				@verifyManID, @acceptMan, @acceptDate
			from eqpAcceptInfo 
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			
			--���ɸ����⣺add by lw 2011-6-28 modi by lw 2011-10-8�ж�������
			if rtrim(ltrim(isnull(@annexName,''))) not in('','��')
			begin
				insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat, cCode, fCode,
					business, buyDate, factory, makeDate, quantity, price, totalAmount, oprMan, acceptMan, acceptManID)

				select @acceptApplyID, @eCode, annexName, '*', cCode, fCode,
					business, buyDate, factory, makeDate, 1, annexAmount, annexAmount, oprMan, @acceptMan, @verifyManID


				from eqpAcceptInfo 
				where acceptApplyID = @acceptApplyID
				if @@ERROR <> 0 
				begin
					set @Ret = 9
					rollback tran
					return
				end    
			end
						
			--�Ǽ��豸���������ڣ�
			insert eqpLifeCycle(eCode,eName, eModel, eFormat,
				clgCode, clgName, uCode, uName, keeper,
				annexAmount, price, totalAmount,
				changeDate, changeDesc,changeType,changeInvoiceID) 
			select @eCode, eName, eModel, eFormat, 
				clgCode, @clgName, uCode, @uName, keeper,
				annexAmount, price, totalAmount,
				@acceptDate, '����ͨ���������˸��豸',
				'����',@acceptApplyID
			from eqpAcceptInfo
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
			
			--�����豸��״�⣺add by lw 2012-10-27
			--ֻ������Ϊ1�����յ����������豸��Ƭ������Ҫ��UI��������
			if (@length = 1)
			begin
				insert eqpStatusInfo(eCode, eName, sNumber, checkDate, keeperID, keeper, 
							eqpLocate, checkStatus,		--�豸״̬��
											--0��״̬���� --����״̬�Զ����Ϊ����
											--1��������
											--3�����ޣ�
											--4�������ϣ�
											--5���������
											--6���������--����״̬Ӧ���޷�ȷ����
											--9��������
							statusNotes, invoiceType, invoiceNum)
				select @eCode, eName, 1, acceptDate, keeperID, keeper, eqpLocate, 1,
					'�豸���״̬', '1', acceptApplyID 
				from eqpAcceptInfo
				where acceptApplyID = @acceptApplyID

				insert eqpStatusPhoto(eCode, eName, sNumber, photoDate, aFilename, notes)
				select @eCode, eName, 1, cast(T.photo.query('data(./@photoDate)') as varchar(10)), 
					cast(T.photo.query('data(./@aFileName)') as varchar(128)), 
					cast(T.photo.query('data(./@notes)') as nvarchar(100))
				from eqpAcceptInfo CROSS APPLY photoXml.nodes('/root/photo') as T(photo)
				where acceptApplyID = @acceptApplyID
			end
			set @rowID = @rowID + 1
			FETCH NEXT FROM tar INTO @eCode
		end
		CLOSE tar
		DEALLOCATE tar

		--�����豸�������뵥״̬��
		update eqpAcceptInfo
		set acceptApplyStatus = 2,	--���յ�״̬��0->���ڱ��ƣ�1->�ѷ���δ��ˣ�2->�����ͨ����δ���ͨ��ֱ�ӻָ�0״̬
			--add by lw 2011-10-16
			eTypeCode = @eTypeCode,	--�����ţ��̣�
			eTypeName = @eTypeName,	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶ�
			aTypeCode = @aTypeCode,	--�����ţ��ƣ�
			
			startECode = @startECode,
			endECode = @endCode,
			accountCode = @accountCode,
			acceptDate = @acceptDate,
			acceptManID = @verifyManID,
			acceptMan = @acceptMan,
			--ά���ˣ�
			modiManID = @verifyManID, modiManName = @acceptMan,	modiTime = @acceptDate
		where acceptApplyID = @acceptApplyID
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
	values(@verifyManID, @acceptMan, @acceptDate, '����', '�û�' + @acceptMan
												+ '���ͨ�������յ�['+ @acceptApplyID +'],ϵͳ��������Ӧ�豸�嵥��')
GO
--���ԣ�
select * from eqpAcceptInfo where acceptApplyID = '201210030001'
select * from equipmentList where acceptApplyID = '0000019968'
select * from workNote order by actionTime desc
select * from eqpCodeList
update eqpAcceptInfo
set acceptApplyStatus = 0
where acceptApplyID = '0000019968'
delete equipmentList where acceptApplyID = '0000019968'

select * from equipmentList where acceptApplyID = '201110080105'
select * from eqpAcceptInfo  where acceptApplyID = '201110080105'
update eqpAcceptInfo 
set acceptApplyStatus = 0
where acceptApplyID = '201110080105'

select * from eqpCodeList 

declare @acceptDate smalldatetime
declare @Ret int
exec dbo.verifyAcceptApply '201110080105', '11000010', '140030201', '00200977', @acceptDate output, @Ret output
select @acceptDate, @Ret

delete equipmentList where eCode = '10000016'
--Ret:0:�ɹ���1��Ҫ��˵����յ���������������2�������յ��Ѿ���ˣ�3:����ĺ���α�ռ�ã�9��δ֪����

drop PROCEDURE cancelVerifyAccept
/*
	name:		cancelVerifyAccept
	function:	9.ȡ�����յ���ˣ��������գ�
				ע�⣺�ô洢���̻����豸���������ڱ�������豸�е����򱨷ϲ�����ܾ�������
	input: 
				@acceptApplyID char(12),			--���յ���

				--ά����:
				@cancelManID varchar(10) output,	--ȡ���ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@cancelDate smalldatetime output,	--ȡ������
				@Ret		int output				--�����ɹ���ʶ
													0:�ɹ���1��ָ�������յ�������,2��Ҫȡ����˵����յ���������������
													3���õ��ݲ��������״̬��
													4�������յ���ָ�����豸�Ѿ��е����򱨷ϲ�����
													5�������յ����ɵ��豸�б༭����������
													9��δ֪����
	author:		¬έ
	CreateDate:	2011-10-9
	UpdateDate: modi by lw 2011-10-12�����ͷű༭��
				modi by lw 2011-10-30֧�ָ������յ��ĳ���
				modi by lw 2011-11-4֧�����豸����Ļ���
				modi by lw 2012-8-12���Ӽ���豸�Ƿ��б༭�������������
*/
create PROCEDURE cancelVerifyAccept
	@acceptApplyID char(12),			--���յ���
	@cancelManID varchar(10) output,	--ȡ���ˣ������ǰ���յ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@cancelDate smalldatetime output,	--ȡ������
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�������յ��Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @acceptApplyType smallint --���յ����ͣ�0->���豸���յ���1->�������յ� add by lw 2011-6-28�޸�Ϊ֧��
	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus, @acceptApplyType = acceptApplyType
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @cancelManID)
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@acceptApplyStatus <> 2)
	begin
		set @Ret = 3
		return
	end
	--���Ҫȡ�����յ��豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where  (acceptApplyID = @acceptApplyID 
							or eCode in (select eCode from equipmentAnnex where acceptApplyID = @acceptApplyID))
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--ȡά���˵�����\ʱ�䣺
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')
	set @cancelDate = getdate()

	declare @eCode char(8)
	if @acceptApplyType = 0
	begin
		--���ɨ�������ɵ��豸������Ƿ��е��������ϡ�ά�޵Ȳ���
		declare tar cursor for
		select eCode from equipmentList
		where acceptApplyID = @acceptApplyID
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode
		WHILE @@FETCH_STATUS = 0
		begin
			set @count=isnull((select count(*) from eqpLifeCycle where eCode = @eCode),0)
			if (@count > 1)	--����������
			begin
				CLOSE tar
				DEALLOCATE tar
				set @Ret = 4
				return
			end
			FETCH NEXT FROM tar INTO @eCode
		end
		CLOSE tar
		DEALLOCATE tar

		begin tran
			--�����豸��ţ�
			update eqpCodeList 
			set isUsed = 'N'
			where eCode in (select eCode from equipmentList where acceptApplyID = @acceptApplyID)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			--�������豸�ĺ������Ҫ�����ţ�
			insert eqpCodeList
			select eCode,'N' from equipmentList 
			where acceptApplyID = @acceptApplyID and eCode not in (select eCode from eqpCodeList)

			--ɾ�����������豸��
			delete equipmentList
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--�����豸�������뵥״̬��
			update eqpAcceptInfo
			set acceptApplyStatus = 0,	--���յ�״̬��0->���ڱ��ƣ�1->�ѷ���δ��ˣ�2->�����ͨ����δ���ͨ��ֱ�ӻָ�0״̬
				startECode = '',
				endECode = '',
				accountCode = '',
				acceptDate = null,
				acceptManID = null,
				acceptMan = null,
				lockManID = '',
				--ά���ˣ�
				modiManID = @cancelManID, modiManName = @cancelMan,	modiTime = @cancelDate
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran	
		--�Ǽǹ�����־��
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@cancelManID, @cancelMan, @cancelDate, 'ȡ���������', '�û�' + @cancelMan
													+ 'ȡ�������յ�['+ @acceptApplyID +']����ˡ�')
	end
	else	--�������յ��Ĵ���
	begin
		begin tran
			--ɾ���豸���������еļ�¼��
			delete eqpLifeCycle where changeInvoiceID= @acceptApplyID and changeType = '��Ӹ���'
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--�������豸�ĸ�����Ϣ���豸�ܼۣ�
			--declare @eCode char(8)			--���豸���
			declare @annexName nvarchar(20)	--��������
			declare @sumAmount numeric(12,2)		--�ϼƽ��
			select @annexName = annexName, @sumAmount = totalAmount, @eCode = eCode
			from equipmentAnnex
			where acceptApplyID = @acceptApplyID

			declare @curAnnexName nvarchar(20)
			set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
			if @curAnnexName = @annexName
				set @curAnnexName = ''
			update equipmentList
			set annexName = @curAnnexName,
				annexAmount	= isnull(annexAmount,0) - @sumAmount,
				totalAmount = isnull(totalAmount,0) - @sumAmount
			where eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--ɾ���������еļ�¼��
			delete equipmentAnnex
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--���¸������յ���
			update eqpAcceptInfo
			set acceptApplyStatus = 0,	--���յ�״̬��0->���ڱ��ƣ�1->�ѷ���δ��ˣ�2->�����ͨ����δ���ͨ��ֱ�ӻָ�0״̬
				acceptDate = null,
				lockManID = '',
				--ά���ˣ�
				modiManID = @cancelManID, modiManName = @cancelMan,	modiTime = @cancelDate
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran	

		--�Ǽǹ�����־��
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@cancelManID, @cancelMan, @cancelDate, 'ȡ�������������', '�û�' + @cancelMan
													+ 'ȡ���˸������յ�['+ @acceptApplyID +']����ˡ�')
	end	
	set @Ret = 0

GO
--���ԣ�
select * from eqpAcceptInfo 
where acceptApplyType = 1





--���������ͼ��
--���յ�
drop view acceptInfoPView
create view acceptInfoPView
AS
	select e.acceptApplyID, convert(varchar(10), e.applyDate, 120) applyDate, 
	e.acceptApplyStatus, e.procurementPlanID,
	e.eTypeCode, e.eTypeName, e.aTypeCode, t.aTypeName, e.eName, e.eModel, e.eFormat, e.unit, e.cCode, c.cName,
	e.factory, convert(varchar(10), e.makeDate, 120) makeDate,
	e.serialNumber, convert(varchar(10),e.buyDate,120) buyDate,e.business,e.fCode, f.fName,e.aCode, a.aName,
	e.clgCode, e.clgName,clg.manager,e.uCode, e.uName,e.keeperID,e.keeper, 
	e.annexName, isnull(e.annexAmount,0) annexAmount,
	isnull(e.price,0) price, isnull(e.totalAmount,0) totalAmount,e.sumNumber,isnull(e.sumAmount,0) sumAmount,e.oprManID,e.oprMan,
	e.notes, startECode, endECode, e.accountCode, act.accountName, convert(varchar(10), e.acceptDate, 120) acceptDate, e.acceptMan,
	dbo.cUCaseForMoneyWithUnit(e.sumAmount)as UCaseForMoney,
	e.createManID, e.createManName,obtainMode,purchaseMode,photoXml,e.eqpLocate
	from eqpAcceptInfo e left join country c on e.cCode = c.cCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
	left join accountTitle act on e.accountCode = act.accountCode
	left join typeCodes t on e.eTypeCode = t.eTypeCode and e.eTypeName = t.eTypeName and e.aTypeCode = t.aTypeCode
	left join college clg on e.clgCode = clg.clgCode

GO


select fCode,oprMan,oprManID,* from eqpAcceptInfo where acceptApplyID='201305300004'

