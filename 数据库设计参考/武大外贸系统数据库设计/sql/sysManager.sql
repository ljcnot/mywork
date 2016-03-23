use fTradeDB2
/*
	武大外贸合同管理信息系统-单据号码发生器
	根据设备管理系统修改
	author:		卢苇
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

--1.号码发生器表(sysNumbers)
drop table [dbo].[sysNumbers]
CREATE TABLE [dbo].[sysNumbers]
(
	numberClass smallint not null,	--号码类别
	numberLength smallint not null, --号码长度
	classDesc nvarchar(50) null,	--类别说明
	curNumber varchar(30) null,		--当前号码
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
	function:	0.初始化指定类别的号码发生器
	input: 
				@numberType smallint,	--号码类别
	output: 
	author:		卢苇
	CreateDate:	2010-5-21
	UpdateDate: 
*/
CREATE PROCEDURE  initNumberInstrument
	@numberType smallint	--号码类别
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
		values (1, '合同编号', 8, @Str)
	end
	else if @numberType = 2
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (2, '合同讨论意见编号', 12, @Str)
	end
	else if @numberType = 3
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (3, '合同变更申请单号', 12, @Str)
	end
	else if @numberType = 10
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10, '供货单位编号', 12, @Str)
	end
	else if @numberType = 11
	begin
		set @Str = 'G0000001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (11, '供货单位员工统一编号', 8, @Str)
	end
	else if @numberType = 12
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (12, '外贸公司编号', 12, @Str)
	end
	else if @numberType = 13
	begin
		set @Str = 'W0000001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (13, '外贸公司员工统一编号', 8, @Str)
	end
	else if @numberType = 14
	begin
		set @Str = 'T0000001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (14, '其他授权用户统一编号', 8, @Str)
	end
	else if @numberType = 920
	begin
		set @Str = 'R' + SUBSTRING(@Str,1,8) + '001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (920, '月度报表编号', 12, @Str)
	end
	else if @numberType = 921
	begin
		set @Str = 'R' + SUBSTRING(@Str,1,8) + '001'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (921, '年度报表编号', 12, @Str)
	end
	else if @numberType = 10000
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10000, '用户意见反馈表编号', 12, @Str)
	end
	else if @numberType = 10010
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10010, '公告编号', 12, @Str)
	end
	else if @numberType = 10020
	begin
		set @Str = left(@Str, 11) + '1'
		insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
		values (10020, '短信编号', 12, @Str)
	end
go
--测试：
exec dbo.initNumberInstrument 920
SELECT * FROM sysNumbers where numberClass = 920
delete sysNumbers where numberClass in(920,921)

DROP PROCEDURE increaseNumber
/*
	name:		increaseNumber
	function:	1.指定类别的号码++
	input: 
				@numberType smallint	--号码类别
	output: 
	author:		卢苇
	CreateDate:	2010-5-21
	UpdateDate: 
*/
CREATE PROCEDURE increaseNumber
	@numberType smallint	--号码类别
	WITH ENCRYPTION 
AS
	--生成日期码：
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
	else if (@numberType in (1))	--合同编号
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
	else if (@numberType in (2, 3))	--合同讨论意见编号/合同申请变更单号
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
	else if (@numberType in (10,12))	--供货单位编号/外贸公司编号
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
	else if (@numberType in (11,13,14))	--外部单位（供货单位、外贸公司）员工及其他授权用户的统一编号
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
	else if (@numberType in (920,921))	--月度报表编号、年度报表编号
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
	else if (@numberType in (10000,10010,10020))	--用户意见反馈表编号/公告编号/短信编号
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
--测试：
exec dbo.increaseNumber 920
select * from sysNumbers where numberClass in (920,921)

DROP PROCEDURE getClassNumber
/*
	name:		getClassNumber
	function:	2.根据用户申请号码的类别，通过号码发生器产生号码:
				格式：类别编码+日期码（8位）+流水号设计
	input: 
				@numberType smallint,		--号码类别:
												1->合同编号
												2->合同讨论意见编号
												3->合同申请变更单号
												10->供货单位编号
												11->供货单位员工统一编号
												12->外贸公司编号
												13->外贸公司员工统一编号
												14->其他授权用户统一编号
												920->月度统计报表编号
												921->年度统计报表编号
												10000->用户意见反馈表编号
												10010->公告编号
												10020->短信编号
												
				@isUsed smallint,			--是否使用：0->预读，1->占用
	output: 
				@thisNumber	varchar(30)	output	--成功返回号码
	author:		卢苇
	CreateDate:	2010-5-21
	UpdateDate: modi by lw 2011-10-1当日期与存在的号码日期不一致时重新生成单号！
*/
CREATE PROCEDURE getClassNumber
	@numberType smallint,		--号码类别
	@isUsed smallint,			--是否使用：0->预读，1->占用
	@thisNumber	varchar(30)	output	--成功返回号码
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
	else if @numberType = 1	--合同编号的日期码只有年份，要特殊处理！
	begin
		if (substring(@thisNumber,1,4) <> @Year)	--如果年份不一致
		begin
			exec dbo.increaseNumber @numberType
			set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		end
	end
	else if @numberType in (920,921)
	begin
		if (substring(@thisNumber,2,8) <> @strDate)	--如果日期不一致
		begin
			exec dbo.increaseNumber @numberType
			set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		end
	end
	else if @numberType not in (11,13,14)
	begin
		if (substring(@thisNumber,1,8) <> @strDate)	--如果日期不一致
		begin
			exec dbo.increaseNumber @numberType
			set @thisNumber = (select curNumber from sysNumbers where numberClass = @numberType)
		end
	end
	--号码被领用：
	if ( @isUsed = 1 )
	begin
		exec dbo.increaseNumber @numberType
	end
GO
--测试：
declare @curNumber varchar(50)
exec dbo.getClassNumber 921, 1, @curNumber output
select @curNumber

SELECT * FROM sysNumbers where numberClass = 920


drop PROCEDURE  getServerDatetime
/*
	name:		getServerDatetime
	function:	10.获取服务器当前时间
	input: 
	output: 
				@curDatetime varchar(19)
	author:		卢苇
	CreateDate:	2011-1-12
	UpdateDate: 
*/
CREATE PROCEDURE  getServerDatetime
	@curDatetime varchar(19) OUTPUT
	WITH ENCRYPTION 
AS
	set @curDatetime = convert(char(19), getdate(),120)
go
