use fTradeDB2
/*
	武大外贸合同管理信息系统-统计报表管理
	author:		卢苇
	CreateDate:	2013-6-11
	UpdateDate: 
*/
--1.月度统计表：
drop table monthlyReport
CREATE TABLE [dbo].[monthlyReport](
	reportNum varchar(12) not null,		--主键：报表编号
	theMonth smalldatetime not null,	--主键：统计月度

	newContract int default(0),			--本月新增合同数
	newContractMoney money default(0),	--本月新增合同金额（美元）
	completedContract int default(0),	--本月执行完成合同数
	completedContractMoney money default(0),--本月执行完成合同金额（美元）
	totalContract int default(0),		--本月合计合同数
	totalContractMoney money default(0),--本月合计合同金额（美元）
	yearTotalCompletedContract int default(0),		--本年累计完成合同数
	yearTotalCompletedContractMoney money default(0),--本年累计完成合同金额（美元）
	

	makeDate smalldatetime null,		--制表日期
	makerID varchar(10) null,			--制表人工号
	maker nvarchar(30) null,			--制表人
 CONSTRAINT [PK_monthlyReport] PRIMARY KEY CLUSTERED 
(
	[theMonth] ASC,
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


drop TABLE [dbo].[monthlyReportDetail]
CREATE TABLE [dbo].[monthlyReportDetail](
	theMonth smalldatetime not null,	--外键：统计月度
	reportNum varchar(12) not null,		--主键/外键：报表编号
	contractID varchar(12) not null,	--主键：合同编号，使用第 1 号号码发生器产生

	startTime smalldatetime null,		--合同启动时间
	completedTime smalldatetime null,	--合同完成时间（归档时间）
 CONSTRAINT [PK_monthlyReportDetail] PRIMARY KEY CLUSTERED 
(
	[theMonth] ASC,
	[reportNum] ASC,
	[contractID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[monthlyReportDetail]  WITH CHECK ADD  CONSTRAINT [FK_monthlyReportDetail_monthlyReport] FOREIGN KEY([theMonth],[reportNum])
REFERENCES [dbo].[monthlyReport] ([theMonth],[reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[monthlyReportDetail] CHECK CONSTRAINT [FK_monthlyReportDetail_monthlyReport]

--2.年度统计表：
drop table annualReport
CREATE TABLE [dbo].[annualReport](
	reportNum varchar(12) not null,		--主键：报表编号
	theYear varchar(4) not null,		--主键：统计年度

	segment1Num int default(0),			--0.6万以下（含）合同数
	segment1Money money default(0),		--0.6万以下（含）合同金额
	segment2Num int default(0),			--0.6万（不含）-1万（不含）合同数
	segment2Money money default(0),		--0.6万（不含）-1万（不含）合同金额
	segment3Num int default(0),			--1万（含）-6万（不含）合同数
	segment3Money money default(0),		--1万（含）-6万（不含）合同金额
	segment4Num int default(0),			--6万（含）-10万（不含）合同数
	segment4Money money default(0),		--6万（含）-10万（不含）合同金额
	segment5Num int default(0),			--10万（含）-15万（不含）合同数
	segment5Money money default(0),		--10万（含）-15万合同金额
	segment6Num int default(0),			--15万（含）-20万（不含）合同数
	segment6Money money default(0),		--15万（含）-20万（不含）合同金额
	segment7Num int default(0),			--20万以上（含）合同数
	segment7Money money default(0),		--20万以上（含）合同金额

	totalNum int default(0),			--合计合同数
	totalMoney money default(0),		--合计合同金额

	payableFree money default(0),		--应付手续费
	realFree money default(0),			--实付手续费

	makeDate smalldatetime null,		--制表日期
	makerID varchar(10) null,			--制表人工号
	maker nvarchar(30) null,			--制表人
 CONSTRAINT [PK_annualReport] PRIMARY KEY CLUSTERED 
(
	[theYear] ASC,
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


drop TABLE [dbo].[annualReportDetail]
CREATE TABLE [dbo].[annualReportDetail](
	theYear varchar(4) not null,		--外键：统计年度
	reportNum varchar(12) not null,		--主键/外键：报表编号

	traderID varchar(12) not null,		--外贸公司编号
	traderName nvarchar(30) null,		--外贸公司名称：冗余设计，保存历史数据 add by lw 2012-3-27
	abbTraderName nvarchar(6) null,		--外贸公司简称:冗余设计，add by lw 2012-4-27根据客户要求增加

	segment1Num int default(0),			--0.6万以下（含）合同数
	segment1Money money default(0),		--0.6万以下（含）合同金额
	segment2Num int default(0),			--0.6万（不含）-1万（不含）合同数
	segment2Money money default(0),		--0.6万（不含）-1万（不含）合同金额
	segment3Num int default(0),			--1万（含）-6万（不含）合同数
	segment3Money money default(0),		--1万（含）-6万（不含）合同金额
	segment4Num int default(0),			--6万（含）-10万（不含）合同数
	segment4Money money default(0),		--6万（含）-10万（不含）合同金额
	segment5Num int default(0),			--10万（含）-15万（不含）合同数
	segment5Money money default(0),		--10万（含）-15万合同金额
	segment6Num int default(0),			--15万（含）-20万（不含）合同数
	segment6Money money default(0),		--15万（含）-20万（不含）合同金额
	segment7Num int default(0),			--20万以上（含）合同数
	segment7Money money default(0),		--20万以上（含）合同金额

	payableFree money default(0),		--应付手续费
	realFree money default(0),			--实付手续费

 CONSTRAINT [PK_annualReportDetail] PRIMARY KEY CLUSTERED 
(
	[theYear] ASC,
	[reportNum] ASC,
	[traderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[annualReportDetail]  WITH CHECK ADD  CONSTRAINT [FK_annualReportDetail_annualReport] FOREIGN KEY([theYear],[reportNum])
REFERENCES [dbo].[annualReport] ([theYear],[reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[annualReportDetail] CHECK CONSTRAINT [FK_annualReportDetail_annualReport]



drop proc addMonthlyReport
/*
	name:		addMonthlyReport
	function:	1.添加指定月度报表：自动根据统计时间生成数据
	input: 
				@theMonth varchar(7),			--统计月度
				@makerID varchar(10),			--制表人工号
	output: 
				@Ret		int output,			--操作成功标识：0:成功，9:未知错误
				@reportNum varchar(12) output	--报表编号:""创建报表时出错！
	author:		卢苇
	CreateDate:	2013-06-11
	UpdateDate: 
*/
create PROCEDURE addMonthlyReport
	@theMonth varchar(7),			--统计月度
	@makerID varchar(10),			--制表人工号
	@Ret int output,				--操作成功标识：0:成功，9:未知错误
	@reportNum varchar(12) output	--报表编号：""创建报表时出错！
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 920, 1, @curNumber output
	set @reportNum = @curNumber
	--获取制表人姓名：
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--制表日期：
	declare @makeDate smalldatetime		--制表日期
	set @makeDate = GETDATE()

	begin tran
		--添加概要表：
		insert monthlyReport(reportNum, theMonth, makeDate, makerID, maker)
		values(@reportNum, @theMonth + '-01', @makeDate, @makerID, @maker)
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end

		--添加明细表条目：
		insert monthlyReportDetail(theMonth, reportNum, contractID, startTime, completedTime)
		select @theMonth+'-01', @reportNum, contractID, startTime, completedTime
		from contractInfo
		where isnull(startTime,'')<>'' and isnull(convert(varchar(7),completedTime,120),@theMonth)=@theMonth
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end

		--更新概要表统计数字：
		update monthlyReport
		set newContract = (select count(*) from monthlyReportDetail		--本月新增合同
							where reportNum=@reportNum and convert(varchar(7),startTime,120)=@theMonth),	
			newContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--本月新增合同金额（美元）
							where contractID in (select contractID from monthlyReportDetail 
												 where reportNum=@reportNum and convert(varchar(7),startTime,120)=@theMonth)),0),
			completedContract = (select count(*) from monthlyReportDetail		--本月执行完成合同数
							where reportNum=@reportNum and convert(varchar(7),completedTime,120)=@theMonth),	
			completedContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--本月执行完成合同金额（美元）
							where contractID in (select contractID from monthlyReportDetail 
												 where reportNum=@reportNum and convert(varchar(7),completedTime,120)=@theMonth)),0),
			totalContract = (select count(*) from monthlyReportDetail		--本月合计合同数
							where reportNum=@reportNum 
							and (convert(varchar(7),startTime,120)=@theMonth or convert(varchar(7),completedTime,120)=@theMonth)),	
			totalContractMoney =isnull((select sum(isnull(dollar,0)) from contractInfo		--本月合计合同金额（美元）
							where contractID in (select contractID from monthlyReportDetail 
							where reportNum=@reportNum 
							and (convert(varchar(7),startTime,120)=@theMonth or convert(varchar(7),completedTime,120)=@theMonth))),0),	
			yearTotalCompletedContract = (select count(*) from monthlyReportDetail		--本年累计完成合同数
							where reportNum=@reportNum and convert(varchar(4),completedTime,120)=left(@theMonth,4)),	
			yearTotalCompletedContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--本年累计完成合同金额（美元）
							where contractID in (select contractID from monthlyReportDetail 
												 where reportNum=@reportNum and convert(varchar(4),completedTime,120)=left(@theMonth,4))),0)
		where reportNum = @reportNum
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end
	commit tran
	set @Ret = 0
	--写工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '生成月度统计报表', '系统根据用户' + @maker + 
					'的要求生成了月度统计报表'+ +'[' + @reportNum + ']。')
GO
--测试：
declare	@Ret int --操作成功标识：0:成功，9:未知错误
declare @reportNum varchar(12) --报表编号：""创建报表时出错！
exec dbo.addMonthlyReport '2013-06','0000000000', @Ret output, @reportNum output
select @Ret, @reportNum

delete monthlyReport
select * from monthlyReport
select * from monthlyReportDetail


drop PROCEDURE delMonthlyReport
/*
	name:		delMonthlyReport
	function:	4.删除指定的月度统计报表
	input: 
				@reportNum varchar(12),			--报表编号
				@delManID varchar(10) output,	--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的月度统计报表不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-11
	UpdateDate: 
*/
create PROCEDURE delMonthlyReport
	@reportNum varchar(12),			--报表编号
	@delManID varchar(10) output,	--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报表是否存在
	declare @count as int
	set @count=(select count(*) from monthlyReport where reportNum = @reportNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end


	delete monthlyReport where reportNum = @reportNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除月度统计报表', '用户' + @delManName
												+ '删除了月度统计报表['+ @reportNum +']。')

GO




drop proc addAnnualReport
/*
	name:		addAnnualReport
	function:	10.添加指定年度报表：自动根据统计时间生成数据
	input: 
				@theYear varchar(4),			--统计年度
				@makerID varchar(10),			--制表人工号
	output: 
				@Ret		int output,			--操作成功标识：0:成功，9:未知错误
				@reportNum varchar(12) output	--报表编号:""创建报表时出错！
	author:		卢苇
	CreateDate:	2013-06-12
	UpdateDate: 
*/
create PROCEDURE addAnnualReport
	@theYear varchar(4),			--统计年度
	@makerID varchar(10),			--制表人工号
	@Ret int output,				--操作成功标识：0:成功，9:未知错误
	@reportNum varchar(12) output	--报表编号：""创建报表时出错！
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 921, 1, @curNumber output
	set @reportNum = @curNumber
	--获取制表人姓名：
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--制表日期：
	declare @makeDate smalldatetime		--制表日期
	set @makeDate = GETDATE()

	begin tran
		--添加概要表：
		insert annualReport(reportNum, theYear,	makeDate, makerID, maker)
		values(@reportNum, @theYear, @makeDate, @makerID, @maker)
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end

		declare @segment1Num int, @segment1Money money
		declare @segment2Num int, @segment2Money money
		declare @segment3Num int, @segment3Money money
		declare @segment4Num int, @segment4Money money
		declare @segment5Num int, @segment5Money money
		declare @segment6Num int, @segment6Money money
		declare @segment7Num int, @segment7Money money, @segmentg7Fee money
		--逐个扫描计算各外贸公司的合同数和金额：
		declare @traderID varchar(12), @traderName nvarchar(30), @abbTraderName	nvarchar(6)		--外贸公司
		declare tar cursor for
		select traderID, traderName, abbTraderName from traderInfo
		OPEN tar
		FETCH NEXT FROM tar INTO @traderID, @traderName, @abbTraderName
		WHILE @@FETCH_STATUS = 0
		begin
			--0.6万以下（含）
			select @segment1Num = count(*), @segment1Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar <= 6000 and traderID = @traderID
			--0.6万（不含）-1万（不含）
			select @segment2Num = count(*), @segment2Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar > 6000 and dollar < 10000 and traderID = @traderID
			--1万（含）-6万（不含）
			select @segment3Num = count(*), @segment3Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 10000 and dollar < 60000 and traderID = @traderID
			--6万（含）-10万（不含）
			select @segment4Num = count(*), @segment4Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 60000 and dollar < 100000 and traderID = @traderID
			--10万（含）-15万（不含）
			select @segment5Num = count(*), @segment5Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 100000 and dollar < 150000 and traderID = @traderID
			--15万（含）-20万（不含）
			select @segment6Num = count(*), @segment6Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 150000 and dollar < 200000 and traderID = @traderID
			--20万以上（含）
			select @segment7Num = count(*), @segment7Money = SUM(dollar), @segmentg7Fee=SUM(payFee)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 200000 and traderID = @traderID
			declare @payableFree money	--应付手续费
			set @payableFree = (isnull(@segment1Money,0) + isnull(@segment2Money,0) + isnull(@segment3Money,0) + isnull(@segment4Money,0)
									+ isnull(@segment5Money,0) + isnull(@segment6Money,0) + isnull(@segment7Money,0)) * 0.25
			declare @realFree money		--实付手续费
			set @realFree = isnull(@segment1Num,0) * 1200 + isnull(@segment2Money,0) * 0.2 + isnull(@segment3Money,0) * 0.13 
							+ isnull(@segment4Money,0) * 0.12 + isnull(@segment5Money,0) * 0.1 + isnull(@segment6Money,0) * 0.9 + isnull(@segmentg7Fee,0)

			insert annualReportDetail(theYear, reportNum, traderID, traderName, abbTraderName,
										segment1Num, segment1Money, segment2Num, segment2Money,
										segment3Num, segment3Money, segment4Num, segment4Money, segment5Num, 
										segment5Money, segment6Num, segment6Money, segment7Num, segment7Money,
										payableFree, realFree)
			values (@theYear, @reportNum, @traderID, @traderName, @abbTraderName,
							@segment1Num, @segment1Money, @segment2Num, @segment2Money,
							@segment3Num, @segment3Money, @segment4Num, @segment4Money, 
							@segment5Num, @segment5Money, @segment6Num, @segment6Money, @segment7Num, @segment7Money,
							@payableFree, @realFree)	
			if (@@ERROR <> 0)
			begin
				CLOSE tar
				DEALLOCATE tar
				rollback tran
				return
			end
					
			FETCH NEXT FROM tar INTO @traderID, @traderName, @abbTraderName
		end
		CLOSE tar
		DEALLOCATE tar

		--更新概要表统计数字：
		select @segment1Num = sum(segment1Num), @segment1Money = sum(segment1Money), @segment2Num = sum(segment2Num), @segment2Money = sum(segment2Money),
							@segment3Num = sum(segment3Num), @segment3Money = sum(segment3Money), @segment4Num = sum(segment4Num), @segment4Money = sum(segment4Money),
							@segment5Num = sum(segment5Num), @segment5Money = sum(segment5Money), @segment6Num = sum(segment6Num), @segment6Money = sum(segment6Money),
							@segment7Num = sum(segment7Num), @segment7Money = sum(segment7Money),
							@payableFree = sum(payableFree), @realFree = sum(realFree)
		from annualReportDetail 
		where reportNum=@reportNum
		
		update annualReport
		set segment1Num = @segment1Num, segment1Money = @segment1Money ,		--0.6万以下（含）
			segment2Num = @segment2Num, segment2Money = @segment2Money ,		--0.6万（不含）-1万（不含）
			segment3Num = @segment3Num, segment3Money = @segment3Money ,		--1万（含）-6万（不含）
			segment4Num = @segment4Num, segment4Money = @segment4Money ,		--6万（含）-10万（不含）
			segment5Num = @segment5Num, segment5Money = @segment5Money ,		--10万（含）-15万
			segment6Num = @segment6Num, segment6Money = @segment6Money ,		--15万（含）-20万（不含）
			segment7Num = @segment7Num, segment7Money = @segment7Money ,		--20万以上（含）
			totalNum = isnull(@segment1Num,0) + isnull(@segment2Num,0) + isnull(@segment3Num,0)
						+ isnull(@segment4Num,0) + isnull(@segment5Num,0) + isnull(@segment6Num,0) + isnull(@segment7Num,0),
			totalMoney = isnull(@segment1Money,0) + isnull(@segment2Money,0) + isnull(@segment3Money,0) 
						+ isnull(@segment4Money,0) + isnull(@segment5Money,0) + isnull(@segment6Money,0) + isnull(@segment7Money,0),
			payableFree = @payableFree,		--应付手续费
			realFree = @realFree			--实付手续费
		where reportNum=@reportNum
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end
	commit tran
	set @Ret = 0
	--写工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '生成年度统计报表', '系统根据用户' + @maker + 
					'的要求生成了年度统计报表'+ +'[' + @reportNum + ']。')
GO
--测试：
declare	@Ret int --操作成功标识：0:成功，9:未知错误
declare @reportNum varchar(12) --报表编号：""创建报表时出错！
exec dbo.addannualReport '2012','0000000000', @Ret output, @reportNum output
select @Ret, @reportNum

delete annualReport
select * from annualReport
select * from annualReportDetail

select * from contractInfo

drop PROCEDURE delAnnualReport
/*
	name:		delAnnualReport
	function:	14.删除指定的年度统计报表
	input: 
				@reportNum varchar(12),			--报表编号
				@delManID varchar(10) output,	--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的年度统计报表不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-12
	UpdateDate: 
*/
create PROCEDURE delAnnualReport
	@reportNum varchar(12),			--报表编号
	@delManID varchar(10) output,	--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的报表是否存在
	declare @count as int
	set @count=(select count(*) from annualReport where reportNum = @reportNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end


	delete annualReport where reportNum = @reportNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除年度统计报表', '用户' + @delManName
												+ '删除了年度统计报表['+ @reportNum +']。')

GO


--月度报表列表查询语句：
select reportNum, theMonth, newContract, newContractMoney, completedContract, 
	completedContractMoney, totalContract, totalContractMoney, 
	yearTotalCompletedContract, yearTotalCompletedContractMoney,
	makeDate, makerID, maker
from monthlyReport

--月度报表明细查询语句（报表设计视图）：
drop view monthlyReportDetailView
create view monthlyReportDetailView
as
	select m.theMonth, m.reportNum, m.contractID, convert(varchar(10),m.startTime,120) startTime,
		e.rowNum, e.clgCode, e.clgName, e.ordererID, e.orderer,
		e.eName, e.eFormat, e.quantity, e.price, c.currency, cd.objDesc currencyName,
		case convert(varchar(7),m.startTime,120) when convert(varchar(7),m.theMonth,120) then convert(varchar(10),m.startTime,120) else '' end addTime,
		convert(varchar(10),m.completedTime,120) completedTime
	from monthlyReportDetail m left join contractInfo c on m.contractID = c.contractID
	left join contractEqp e on m.contractID = e.contractID
	left join codedictionary cd on cd.classCode = 3 and c.currency = cd.objCode
go

select * from monthlyReportDetailView
order by addTime desc, completedTime desc, contractID




--年度报表查询语句：
select reportNum, theYear, segment1Num, segment1Money, segment2Num, segment2Money,
	segment3Num, segment3Money, segment4Num, segment4Money, segment5Num, segment5Money, 
	segment6Num, segment6Money, segment7Num, segment7Money
	totalNum, totalMoney,
	payableFree, realFree,
	convert(varchar(10),a.makeDate,120), makerID, maker
from annualReport a

select theYear, reportNum, traderID, traderName, abbTraderName,
	segment1Num, segment1Money, segment2Num, segment2Money, segment3Num, segment3Money, segment4Num, segment4Money,
	segment5Num, segment5Money, segment6Num, segment6Money, segment7Num, segment7Money,
	payableFree, realFree
from annualReportDetail
order by traderID


