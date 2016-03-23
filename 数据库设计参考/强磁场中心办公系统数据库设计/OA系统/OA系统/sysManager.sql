use hustOA
/*
	强磁场中心办公系统-单据号码发生器
	author:		卢苇
	CreateDate:	2010-5-21
	UpdateDate: 
*/
--原系统的号码发生器：
select * from epdbc.dbo.DBNumEng1
select * from epdbc.dbo.dbnumeng

select * from sysNumbers where numberClass = 6
update sysNumbers
set curNumber='20129000'
where numberClass = 6

delete sysNumbers where numberClass = 51
select * from sysNumbers where numberClass = 1
--0.号码发生器定义表：add by lw 2014-1-1
drop table [dbo].[sysEncoder]
CREATE TABLE [dbo].[sysEncoder]
(
	encoderID int not null,			--号码发生器的ID号
	encoderName nvarchar(30),		--号码发生器名称
	encoderPrefix varchar(8),		--前缀
	encoderDateType int,			--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
	encoderSerialNumLen int,		--流水码长度
	encoderSerialNumInc int default(1),	--流水码增量：计划扩展，暂时未用！
	encoderSuffix varchar(8),		--后缀
 CONSTRAINT [PK_sysEncoder] PRIMARY KEY CLUSTERED 
(
	[encoderID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SELECT * from sysEncoder e left join sysNumbers n on e.encoderID=n.numberClass

--1.号码发生器表(sysNumbers)
drop table [dbo].[sysNumbers]
CREATE TABLE [dbo].[sysNumbers]
(
	numberClass smallint not null,	--号码类别：等价于sysEncoder中的encoderID
	numberLength smallint not null, --号码长度
	classDesc nvarchar(50) null,	--类别说明：等价于sysEncoder中的encoderName
	curNumber varchar(30) null,		--当前号码
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
	function:	0.初始化指定类别的号码发生器
	input: 
				@numberType smallint,	--号码类别
	output: 
	author:		卢苇
	CreateDate:	2010-5-21
	UpdateDate: 采用定义的号码发生器重写 modi by lw 2014-1-1
*/
CREATE PROCEDURE  initNumberInstrument
	@numberType smallint	--号码类别
	WITH ENCRYPTION 
AS
	declare @count int
	set @count = (select count(*) from sysNumbers where numberClass = @numberType)
	if @count > 0
		return

	declare @encoderName nvarchar(30)	--号码发生器名称
	declare @encoderPrefix varchar(8)	--前缀
	declare @encoderDateType int		--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
	declare @encoderSerialNumLen int	--流水码长度
	declare @encoderSerialNumInc int	--流水码增量
	declare @encoderSuffix varchar(8)	--后缀
	select @encoderName = encoderName, @encoderPrefix = encoderPrefix, @encoderDateType = encoderDateType, 
			@encoderSerialNumLen = encoderSerialNumLen, @encoderSerialNumInc = encoderSerialNumInc, @encoderSuffix = encoderSuffix 
	from sysEncoder where encoderID = @numberType
	if (@encoderName is null)
		return

	--日期码：
	declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
	declare  @Str varchar(50), @CurDate datetime
	set  @CurDate =GetDate()

	set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
	set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
	set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)
	if (@encoderDateType=0)		--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
		set @Str=''
	else if (@encoderDateType=1)
		set @Str = @Year + @Month + @Day
	else if (@encoderDateType=2)
		set @Str = @Year + @Month
	else if (@encoderDateType=3)
		set @Str = @Year
	
	--生成初始号码：
	set @Str = 	@encoderPrefix + @Str + replace(SPACE(@encoderSerialNumLen - 1),' ','0')+'1'+ @encoderSuffix

	insert sysNumbers(numberClass, classDesc, numberLength, curNumber)
	values (@numberType, @encoderName, LEN(@Str), @Str)
go

--测试：
delete sysNumbers where numberClass = 51
exec dbo.initNumberInstrument 51
SELECT * FROM sysNumbers where numberClass = 51

DROP PROCEDURE increaseNumber
/*
	name:		increaseNumber
	function:	1.指定类别的号码++
	input: 
				@numberType smallint	--号码类别
	output: 
	author:		卢苇
	CreateDate:	2010-5-21
	UpdateDate: 采用定义的号码发生器重写 modi by lw 2014-1-1
*/
CREATE PROCEDURE increaseNumber
	@numberType smallint	--号码类别
	WITH ENCRYPTION 
AS
	declare @encoderName nvarchar(30)	--号码发生器名称
	declare @encoderPrefix varchar(8)	--前缀
	declare @encoderDateType int		--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
	declare @encoderSerialNumLen int	--流水码长度
	declare @encoderSerialNumInc int	--流水码增量
	declare @encoderSuffix varchar(8)	--后缀
	select @encoderName = encoderName, @encoderPrefix = encoderPrefix, @encoderDateType = encoderDateType, 
			@encoderSerialNumLen = encoderSerialNumLen, @encoderSerialNumInc = encoderSerialNumInc, @encoderSuffix = encoderSuffix 
	from sysEncoder where encoderID = @numberType
	if (@encoderName is null)
		return

	--日期码：
	declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
	declare  @strDate varchar(8), @CurDate datetime
	set  @CurDate =GetDate()

	set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
	set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
	set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)
	if (@encoderDateType=0)		--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
		set @strDate=''
	else if (@encoderDateType=1)
		set @strDate = @Year + @Month + @Day
	else if (@encoderDateType=2)
		set @strDate = @Year + @Month
	else if (@encoderDateType=3)
		set @strDate = @Year
	--比较日期码：
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
--测试：
select * from sysEncoder
exec dbo.increaseNumber 2
select * from sysNumbers where numberClass = 2

DROP PROCEDURE getClassNumber
/*
	name:		getClassNumber
	function:	2.根据用户申请号码的类别，通过号码发生器产生号码:
				格式：类别编码+日期码（8位）+流水号设计
	input: 
				@numberType smallint,		--号码类别（号码发生器的ID号）
				@isUsed smallint,			--是否使用：0->预读，1->占用
	output: 
				@thisNumber	varchar(30)	output	--成功返回号码
	author:		卢苇
	CreateDate:	2010-5-21
	UpdateDate: modi by lw 2011-10-1当日期与存在的号码日期不一致时重新生成单号！
				采用定义的号码发生器重写 modi by lw 2014-1-1
*/
CREATE PROCEDURE getClassNumber
	@numberType smallint,		--号码类别（号码发生器的ID号）
	@isUsed smallint,			--是否使用：0->预读，1->占用
	@thisNumber	varchar(30)	output	--成功返回号码
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
		declare @encoderName nvarchar(30)	--号码发生器名称
		declare @encoderPrefix varchar(8)	--前缀
		declare @encoderDateType int		--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
		declare @encoderSerialNumLen int	--流水码长度
		declare @encoderSerialNumInc int	--流水码增量
		declare @encoderSuffix varchar(8)	--后缀
		select @encoderName = encoderName, @encoderPrefix = encoderPrefix, @encoderDateType = encoderDateType, 
				@encoderSerialNumLen = encoderSerialNumLen, @encoderSerialNumInc = encoderSerialNumInc, @encoderSuffix = encoderSuffix 
		from sysEncoder where encoderID = @numberType
		if (@encoderName is null)
			return

		--日期码：
		declare  @Year varchar(4), @Month varchar(2), @Day varchar(2)
		declare  @strDate varchar(8), @CurDate datetime
		set  @CurDate =GetDate()

		set @Year = right('0000' + ltrim(convert(varchar(4), year(@CurDate))),4)
		set @Month  = right('0' + ltrim(convert(varchar(4), month(@CurDate))),2)
		set @Day = right('0' + ltrim(convert(varchar(4), day(@CurDate))),2)
		if (@encoderDateType=0)		--日期码格式：0->不使用日期码,1->4位年度+2位月份+2位日期,2->4位年度+2位月份,3->4位年度
			set @strDate=''
		else if (@encoderDateType=1)
			set @strDate = @Year + @Month + @Day
		else if (@encoderDateType=2)
			set @strDate = @Year + @Month
		else if (@encoderDateType=3)
			set @strDate = @Year

		if (substring(@thisNumber,LEN(@encoderPrefix)+1,LEN(@strDate)) <> @strDate)	--如果日期不一致
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
exec dbo.getClassNumber 20002, 1, @curNumber output
select @curNumber

SELECT * FROM sysNumbers where numberClass = 51
update sysNumbers 
set curNumber= 29
where numberClass = 70

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




--预定义的号码发生器：
insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(1, '验收申请单号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(2, '报废申请单号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(3, '调拨申请单号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(4, '设备清查单号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(5, '设备信息更正单号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(6, '设备编号','',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(7, '设备借用申请单编号','JY',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(50, '场地编号','CD',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(51, '场地申请单编号','CA',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(55, '试验站编号','SY',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(56, '试验站申请单编号','SA',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(60, '气体编号','QT',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(61, '气体申请单编号','QA',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(70, '装置编号','ZZ',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(71, '装置维修单号','WX',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(100, '论文编号','WX',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(101, '专著编号','ZZ',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(102, '专利编号','ZL',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(103, '获奖编号','HJ',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(104, '科研项目编号','XM',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(200, '学术报告编号','BG',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(251, '会议编号','HY',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(300, '请假条编号','QJ',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(301, '设备采购申请编号','CG',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(302, '论文发表申请编号','WF',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(303, '车间加工申请编号','JG',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(304, '其他申请编号','QT',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(901, '教学科研仪器设备表编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(902, '教学科研仪器设备增减变动情况表编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(903, '贵重仪器设备表编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(800, '财政部报表编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(10000, '统计表编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(10001, '用户意见反馈表编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(10010, '公告编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(10020, '短信编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(11000, '消息编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(11001, '消息模板编号','MB',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(11010, '任务编号','MB',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(11020, '勤务状态编号','QW',3,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(12000, '人员编号','G',3,5,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(20000, '讨论组编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(20001, '群编号','',1,4,1,'')

insert sysEncoder(encoderID, encoderName, encoderPrefix, encoderDateType, encoderSerialNumLen, encoderSerialNumInc, encoderSuffix)
values(20002, '群邀请（申请）单号','',1,4,1,'')

