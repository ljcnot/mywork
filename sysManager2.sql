use hustOA
/*
	ǿ�ų����İ칫ϵͳ-���ݺ��뷢����
	author:		¬έ
	CreateDate:	2010-5-21
	UpdateDate: 
*/
--ԭϵͳ�ĺ��뷢������
select * from epdbc.dbo.DBNumEng1
select * from epdbc.dbo.dbnumeng

select * from sysNumbers where numberClass = 6
update sysNumbers
set curNumber='20129000'
where numberClass = 6

delete sysNumbers where numberClass = 51
select * from sysNumbers where numberClass = 1
--0.���뷢���������add by lw 2014-1-1
drop table [dbo].[sysEncoder]
CREATE TABLE [dbo].[sysEncoder]
(
	encoderID int not null,			--���뷢������ID��
	encoderName nvarchar(30),		--���뷢��������
	encoderPrefix varchar(8),		--ǰ׺
	encoderDateType int,			--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
	encoderSerialNumLen int,		--��ˮ�볤��
	encoderSerialNumInc int default(1),	--��ˮ���������ƻ���չ����ʱδ�ã�
	encoderSuffix varchar(8),		--��׺
 CONSTRAINT [PK_sysEncoder] PRIMARY KEY CLUSTERED 
(
	[encoderID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SELECT * from sysEncoder e left join sysNumbers n on e.encoderID=n.numberClass

--1.���뷢������(sysNumbers)
drop table [dbo].[sysNumbers]
CREATE TABLE [dbo].[sysNumbers]
(
	numberClass smallint not null,	--������𣺵ȼ���sysEncoder�е�encoderID
	numberLength smallint not null, --���볤��
	classDesc nvarchar(50) null,	--���˵�����ȼ���sysEncoder�е�encoderName
	curNumber varchar(30) null,		--��ǰ����
 CONSTRAINT [PK_sysNumbers] PRIMARY KEY CLUSTERED 
(
	[numberClass] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

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
	UpdateDate: ���ö���ĺ��뷢������д modi by lw 2014-1-1
*/
CREATE PROCEDURE  initNumberInstrument
	@numberType smallint	--�������
	WITH ENCRYPTION 
AS
	declare @count int
	set @count = (select count(*) from sysNumbers where numberClass = @numberType)
	if @count > 0
		return

	declare @encoderName nvarchar(30)	--���뷢��������
	declare @encoderPrefix varchar(8)	--ǰ׺
	declare @encoderDateType int		--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
	declare @encoderSerialNumLen int	--��ˮ�볤��
	declare @encoderSerialNumInc int	--��ˮ������
	declare @encoderSuffix varchar(8)	--��׺
	select @encoderName = encoderName, @encoderPrefix = encoderPrefix, @encoderDateType = encoderDateType, 
			@encoderSerialNumLen = encoderSerialNumLen, @encoderSerialNumInc = encoderSerialNumInc, @encoderSuffix = encoderSuffix 
	from sysEncoder where encoderID = @numberType
	if (@encoderName is null)
		return

	--�����룺
	declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
	declare  @Str varchar(50), @CurDate datetime
	set  @CurDate =GetDate()

	set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
	set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
	set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)
	if (@encoderDateType=0)		--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
		set @Str=''
	else if (@encoderDateType=1)
		set @Str = @Year + @Month + @Day
	else if (@encoderDateType=2)
		set @Str = @Year + @Month
	else if (@encoderDateType=3)
		set @Str = @Year
	
	--���ɳ�ʼ���룺
	set @Str = 	@encoderPrefix + @Str + replace(SPACE(@encoderSerialNumLen - 1),' ','0')+'1'+ @encoderSuffix

	insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
	values (@numberType, @encoderName, LEN(@Str), @Str)
go

--���ԣ�
delete sysNumbers where numberClass = 2
exec dbo.initNumberInstrument 2
SELECT * FROM sysNumbers where numberClass = 2

DROP PROCEDURE increaseNumber
/*
	name:		increaseNumber
	function:	1.ָ�����ĺ���++
	input: 
				@numberType smallint	--�������
	output: 
	author:		¬έ
	CreateDate:	2010-5-21
	UpdateDate: ���ö���ĺ��뷢������д modi by lw 2014-1-1
*/
CREATE PROCEDURE increaseNumber
	@numberType smallint	--�������
	WITH ENCRYPTION 
AS
	declare @encoderName nvarchar(30)	--���뷢��������
	declare @encoderPrefix varchar(8)	--ǰ׺
	declare @encoderDateType int		--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
	declare @encoderSerialNumLen int	--��ˮ�볤��
	declare @encoderSerialNumInc int	--��ˮ������
	declare @encoderSuffix varchar(8)	--��׺
	select @encoderName = encoderName, @encoderPrefix = encoderPrefix, @encoderDateType = encoderDateType, 
			@encoderSerialNumLen = encoderSerialNumLen, @encoderSerialNumInc = encoderSerialNumInc, @encoderSuffix = encoderSuffix 
	from sysEncoder where encoderID = @numberType
	if (@encoderName is null)
		return

	--�����룺
	declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
	declare  @strDate varchar(8), @CurDate datetime
	set  @CurDate =GetDate()

	set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
	set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
	set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)
	if (@encoderDateType=0)		--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
		set @strDate=''
	else if (@encoderDateType=1)
		set @strDate = @Year + @Month + @Day
	else if (@encoderDateType=2)
		set @strDate = @Year + @Month
	else if (@encoderDateType=3)
		set @strDate = @Year
	--�Ƚ������룺
	declare @count int
	set @count = (select count(*) from sysNumbers where numberClass = @numberType)
	declare @curNumber bigint, @strCurNumber varchar(50)
	if (@count = 0)
	begin
		exec dbo.initNumberInstrument @numberType
	end
	else
	begin
		set @strCurNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		if (substring(@strCurNumber,LEN(@encoderPrefix)+1,LEN(@strDate)) = @strDate)
		begin
			set @strCurNumber = substring(@strCurNumber,LEN(@encoderPrefix) + LEN(@strDate)+1,@encoderSerialNumLen)
			set @curNumber = convert(bigint, @strCurNumber) + 1
		end
		else
			set @curNumber = 1

		set @strCurNumber = right(replace(SPACE(@encoderSerialNumLen - 1),' ','0') + ltrim(convert(varchar(10),@curNumber)), @encoderSerialNumLen)
		set @strCurNumber = @encoderPrefix + @strDate + @strCurNumber + @encoderSuffix

		update sysNumbers
		set curNumber = @strCurNumber
		where numberClass = @numberType
	end
go
--���ԣ�
select * from sysEncoder
exec dbo.increaseNumber 2
select * from sysNumbers where numberClass = 2

DROP PROCEDURE getClassNumber
/*
	name:		getClassNumber
	function:	2.�����û������������ͨ�����뷢������������:
				��ʽ��������+�����루8λ��+��ˮ�����
	input: 
				@numberType smallint,		--������𣨺��뷢������ID�ţ�
				@isUsed smallint,			--�Ƿ�ʹ�ã�0->Ԥ����1->ռ��
	output: 
				@thisNumber	varchar(30)	output	--�ɹ����غ���
	author:		¬έ
	CreateDate:	2010-5-21
	UpdateDate: modi by lw 2011-10-1����������ڵĺ������ڲ�һ��ʱ�������ɵ��ţ�
				���ö���ĺ��뷢������д modi by lw 2014-1-1
*/
CREATE PROCEDURE getClassNumber
	@numberType smallint,		--������𣨺��뷢������ID�ţ�
	@isUsed smallint,			--�Ƿ�ʹ�ã�0->Ԥ����1->ռ��
	@thisNumber	varchar(30)	output	--�ɹ����غ���
	WITH ENCRYPTION 
AS
	set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
	if ( isnull(@thisNumber , '') = '' ) 
	begin
		exec dbo.initNumberInstrument @numberType
		set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
	end
	else
	begin
		declare @encoderName nvarchar(30)	--���뷢��������
		declare @encoderPrefix varchar(8)	--ǰ׺
		declare @encoderDateType int		--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
		declare @encoderSerialNumLen int	--��ˮ�볤��
		declare @encoderSerialNumInc int	--��ˮ������
		declare @encoderSuffix varchar(8)	--��׺
		select @encoderName = encoderName, @encoderPrefix = encoderPrefix, @encoderDateType = encoderDateType, 
				@encoderSerialNumLen = encoderSerialNumLen, @encoderSerialNumInc = encoderSerialNumInc, @encoderSuffix = encoderSuffix 
		from sysEncoder where encoderID = @numberType
		if (@encoderName is null)
			return

		--�����룺
		declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
		declare  @strDate varchar(8), @CurDate datetime
		set  @CurDate =GetDate()

		set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
		set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
		set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)
		if (@encoderDateType=0)		--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
			set @strDate=''
		else if (@encoderDateType=1)
			set @strDate = @Year + @Month + @Day
		else if (@encoderDateType=2)
			set @strDate = @Year + @Month
		else if (@encoderDateType=3)
			set @strDate = @Year

		if (substring(@thisNumber,LEN(@encoderPrefix)+1,LEN(@strDate)) <> @strDate)	--������ڲ�һ��
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
exec dbo.getClassNumber 20002, 1, @curNumber output
select @curNumber

SELECT * FROM sysNumbers where numberClass = 51
update sysNumbers 
set curNumber= 29
where numberClass = 70

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




--Ԥ����ĺ��뷢������
insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(1, '�������뵥��','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(2, '�������뵥��','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(3, '�������뵥��','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(4, '�豸��鵥��','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(5, '�豸��Ϣ��������','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(6, '�豸���','',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(7, '�豸�������뵥���','JY',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(401, '��֧����','J',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(402, '���������','SPXQ',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(403, '��������','B',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(404, '���ñ��������','BXXQ',1,5,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(405, '���÷ѱ��������','CLFXQ',1,5,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(406, '�������','FJ',1,5,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(407, '��Ŀ��','KM',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(408, '�˻���ϸ��','ZHMX',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(409, '�˻���','Z',2,3,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(410, '�˻��ƽ���','ZHYJ',1,3,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(411, '���������','SRXX',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(412, '֧�������','ZCXX',1,4,1,'')