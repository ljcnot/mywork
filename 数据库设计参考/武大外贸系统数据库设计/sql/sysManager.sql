use fTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-���ݺ��뷢����
	�����豸����ϵͳ�޸�
	author:		¬έ
	CreateDate:	2010-5-21
	UpdateDate: 
*/
select * from traderManInfo order by manID
select * from traderInfo order by traderID
update sysNumbers set curNumber='W0000012' where numberClass=13

select * from supplierManInfo order by manID
update sysNumbers set curNumber='G0000100' where numberClass=11

select * from sysNumbers where numberClass in (11,13)
delete sysNumbers where numberClass = 1
delete sysNumbers where numberClass = 2
select * from sysNumbers where numberClass = 1
select * from supplierManInfo order by manID desc

select * from sysUserInfo where userID like 'G%'

--1.���뷢������(sysNumbers)
drop table [dbo].[sysNumbers]
CREATE TABLE [dbo].[sysNumbers]
(
	numberClass smallint not null,	--�������
	numberLength smallint not null, --���볤��
	classDesc nvarchar(50) null,	--���˵��
	curNumber varchar(30) null,		--��ǰ����
 CONSTRAINT [PK_sysNumbers] PRIMARY KEY CLUSTERED 
(
	[numberClass] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

insert sysNumbers
select * from fTradeDB1.dbo.sysNumbers
select * from sysNumbers
delete sysNumbers where numberClass = 1


drop PROCEDURE  initNumberInstrument
/*
	name:		initNumberInstrument
	function:	0.��ʼ��ָ�����ĺ��뷢����
	input: 
				@numberType smallint,	--�������
	output: 
	author:		¬έ
	CreateDate:	2010-5-21
	UpdateDate: 
*/
CREATE PROCEDURE  initNumberInstrument
	@numberType smallint	--�������
	WITH ENCRYPTION 
AS
	declare @count int
	set @count = (select count(*) from sysNumbers where numberClass = @numberType)
	if @count > 0
		return

	declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
	declare  @Str varchar(50), @CurDate datetime
	set  @CurDate =GetDate()

	set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
	set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
	set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)

	set @Str = @Year + @Month + @Day + '0000000000000000000000'

	if @numberType = 1	
	begin
		set @Str = @Year + '0000'
		set @Str = left(@Str, 7) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (1, '��ͬ���', 8, @Str)
	end
	else if @numberType = 2
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (2, '��ͬ����������', 12, @Str)
	end
	else if @numberType = 3
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (3, '��ͬ������뵥��', 12, @Str)
	end
	else if @numberType = 10
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10, '������λ���', 12, @Str)
	end
	else if @numberType = 11
	begin
		set @Str = 'G0000001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (11, '������λԱ��ͳһ���', 8, @Str)
	end
	else if @numberType = 12
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (12, '��ó��˾���', 12, @Str)
	end
	else if @numberType = 13
	begin
		set @Str = 'W0000001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (13, '��ó��˾Ա��ͳһ���', 8, @Str)
	end
	else if @numberType = 14
	begin
		set @Str = 'T0000001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (14, '������Ȩ�û�ͳһ���', 8, @Str)
	end
	else if @numberType = 920
	begin
		set @Str = 'R' + SUBSTRING(@Str,1,8) + '001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (920, '�¶ȱ�����', 12, @Str)
	end
	else if @numberType = 921
	begin
		set @Str = 'R' + SUBSTRING(@Str,1,8) + '001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (921, '��ȱ�����', 12, @Str)
	end
	else if @numberType = 10000
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10000, '�û������������', 12, @Str)
	end
	else if @numberType = 10010
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10010, '������', 12, @Str)
	end
	else if @numberType = 10020
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10020, '���ű��', 12, @Str)
	end
go
--���ԣ�
exec dbo.initNumberInstrument 920
SELECT * FROM sysNumbers where numberClass = 920
delete sysNumbers where numberClass in(920,921)

DROP PROCEDURE increaseNumber
/*
	name:		increaseNumber
	function:	1.ָ�����ĺ���++
	input: 
				@numberType smallint	--�������
	output: 
	author:		¬έ
	CreateDate:	2010-5-21
	UpdateDate: 
*/
CREATE PROCEDURE increaseNumber
	@numberType smallint	--�������
	WITH ENCRYPTION 
AS
	--���������룺
	declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
	declare  @strDate varchar(8), @CurDate datetime
	set  @CurDate =GetDate()
	set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
	set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
	set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)
	set @strDate = @Year + @Month + @Day

	declare @count int
	set @count = (select count(*) from sysNumbers where numberClass = @numberType)
	declare @curNumber bigint, @strCurNumber varchar(50)
	if (@count = 0)
	begin
		exec dbo.initNumberInstrument @numberType
	end
	else if (@numberType in (1))	--��ͬ���
	begin
		set @strCurNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		if (substring(@strCurNumber,1,4) = @Year)
		begin
			set @strCurNumber = right(@strCurNumber , 4)
			set @curNumber = convert(bigint, @strCurNumber) + 1
		end
		else
			set @curNumber = 1
		set @strCurNumber = ltrim(convert(varchar(4),@curNumber))
		set @strCurNumber = left(@Year + '0000', 8 - len(@strCurNumber)) + @strCurNumber
		update sysNumbers
		set curNumber = @strCurNumber
		where numberClass = @numberType
	end
	else if (@numberType in (2, 3))	--��ͬ����������/��ͬ����������
	begin
		set @strCurNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		if (substring(@strCurNumber,1,8) = @strDate)
		begin
			set @strCurNumber = right(@strCurNumber , 4)
			set @curNumber = convert(bigint, @strCurNumber) + 1
		end
		else
			set @curNumber = 1
		set @strCurNumber = ltrim(convert(varchar(4),@curNumber))
		set @strCurNumber = left(@strDate + '0000', 12 - len(@strCurNumber)) + @strCurNumber
		update sysNumbers
		set curNumber = @strCurNumber
		where numberClass = @numberType
	end
	else if (@numberType in (10,12))	--������λ���/��ó��˾���
	begin
		set @strCurNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		if (substring(@strCurNumber,1,8) = @strDate)
		begin
			set @strCurNumber = right(@strCurNumber , 4)
			set @curNumber = convert(bigint, @strCurNumber) + 1
		end
		else
			set @curNumber = 1
		set @strCurNumber = ltrim(convert(varchar(4),@curNumber))
		set @strCurNumber = left(@strDate + '0000', 12 - len(@strCurNumber)) + @strCurNumber
		update sysNumbers
		set curNumber = @strCurNumber
		where numberClass = @numberType
	end
	else if (@numberType in (11,13,14))	--�ⲿ��λ��������λ����ó��˾��Ա����������Ȩ�û���ͳһ���
	begin
		declare @sCurNumber varchar(50)
		set @strCurNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		set @sCurNumber = right(@strCurNumber , 7)
		set @curNumber = convert(bigint, @sCurNumber) + 1
		set @sCurNumber = ltrim(convert(varchar(7),@curNumber))
		set @strCurNumber = left(left(@strCurNumber,1) + '000000', 8 - len(@sCurNumber)) + @sCurNumber
		update sysNumbers
		set curNumber = @strCurNumber
		where numberClass = @numberType
	end
	else if (@numberType in (920,921))	--�¶ȱ����š���ȱ�����
	begin
		set @strCurNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		if (substring(@strCurNumber,2,8) = @strDate)
		begin
			set @strCurNumber = right(@strCurNumber , 3)
			set @curNumber = convert(bigint, @strCurNumber) + 1
		end
		else
			set @curNumber = 1
		set @strCurNumber = ltrim(convert(varchar(3),@curNumber))
		set @strCurNumber = 'R'+left(@strDate + '000', 11 - len(@strCurNumber)) + @strCurNumber
		update sysNumbers
		set curNumber = @strCurNumber
		where numberClass = @numberType
	end
	else if (@numberType in (10000,10010,10020))	--�û������������/������/���ű��
	begin
		set @strCurNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		if (substring(@strCurNumber,1,8) = @strDate)
		begin
			set @strCurNumber = right(@strCurNumber , 4)
			set @curNumber = convert(bigint, @strCurNumber) + 1
		end
		else
			set @curNumber = 1
		set @strCurNumber = ltrim(convert(varchar(4),@curNumber))
		set @strCurNumber = left(@strDate + '0000', 12 - len(@strCurNumber)) + @strCurNumber
		update sysNumbers
		set curNumber = @strCurNumber
		where numberClass = @numberType
	end
go
--���ԣ�
exec dbo.increaseNumber 920
select * from sysNumbers where numberClass in (920,921)

DROP PROCEDURE getClassNumber
/*
	name:		getClassNumber
	function:	2.�����û������������ͨ�����뷢������������:
				��ʽ��������+�����루8λ��+��ˮ�����
	input: 
				@numberType smallint,		--�������:
												1->��ͬ���
												2->��ͬ����������
												3->��ͬ����������
												10->������λ���
												11->������λԱ��ͳһ���
												12->��ó��˾���
												13->��ó��˾Ա��ͳһ���
												14->������Ȩ�û�ͳһ���
												920->�¶�ͳ�Ʊ�����
												921->���ͳ�Ʊ�����
												10000->�û������������
												10010->������
												10020->���ű��
												
				@isUsed smallint,			--�Ƿ�ʹ�ã�0->Ԥ����1->ռ��
	output: 
				@thisNumber	varchar(30)	output	--�ɹ����غ���
	author:		¬έ
	CreateDate:	2010-5-21
	UpdateDate: modi by lw 2011-10-1����������ڵĺ������ڲ�һ��ʱ�������ɵ��ţ�
*/
CREATE PROCEDURE getClassNumber
	@numberType smallint,		--�������
	@isUsed smallint,			--�Ƿ�ʹ�ã�0->Ԥ����1->ռ��
	@thisNumber	varchar(30)	output	--�ɹ����غ���
	WITH ENCRYPTION 
AS
	declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
	declare  @StrDate varchar(8), @CurDate datetime
	set  @CurDate =GetDate()

	set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
	set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
	set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)

	set  @StrDate = @Year + @Month + @Day
	--print @StrDate

	set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
	if ( isnull(@thisNumber , '') = '' ) 
	begin
		exec dbo.initNumberInstrument @numberType
		set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
	end
	else if @numberType = 1	--��ͬ��ŵ�������ֻ����ݣ�Ҫ���⴦��
	begin
		if (substring(@thisNumber,1,4) <> @Year)	--�����ݲ�һ��
		begin
			exec dbo.increaseNumber @numberType
			set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		end
	end
	else if @numberType in (920,921)
	begin
		if (substring(@thisNumber,2,8) <> @strDate)	--������ڲ�һ��
		begin
			exec dbo.increaseNumber @numberType
			set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		end
	end
	else if @numberType not in (11,13,14)
	begin
		if (substring(@thisNumber,1,8) <> @strDate)	--������ڲ�һ��
		begin
			exec dbo.increaseNumber @numberType
			set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		end
	end
	--���뱻���ã�
	if ( @isUsed = 1 )
	begin
		exec dbo.increaseNumber @numberType
	end
GO
--���ԣ�
declare @curNumber varchar(50)
exec dbo.getClassNumber 921, 1, @curNumber output
select @curNumber

SELECT * FROM sysNumbers where numberClass = 920


drop PROCEDURE  getServerDatetime
/*
	name:		getServerDatetime
	function:	10.��ȡ��������ǰʱ��
	input: 
	output: 
				@curDatetime varchar(19)
	author:		¬έ
	CreateDate:	2011-1-12
	UpdateDate: 
*/
CREATE PROCEDURE  getServerDatetime
	@curDatetime varchar(19) OUTPUT
	WITH ENCRYPTION 
AS
	set @curDatetime = convert(char(19), getdate(),120)
go
