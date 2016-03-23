use fTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-ͳ�Ʊ������
	author:		¬έ
	CreateDate:	2013-6-11
	UpdateDate: 
*/
--1.�¶�ͳ�Ʊ�
drop table monthlyReport
CREATE TABLE [dbo].[monthlyReport](
	reportNum varchar(12) not null,		--������������
	theMonth smalldatetime not null,	--������ͳ���¶�

	newContract int default(0),			--����������ͬ��
	newContractMoney money default(0),	--����������ͬ����Ԫ��
	completedContract int default(0),	--����ִ����ɺ�ͬ��
	completedContractMoney money default(0),--����ִ����ɺ�ͬ����Ԫ��
	totalContract int default(0),		--���ºϼƺ�ͬ��
	totalContractMoney money default(0),--���ºϼƺ�ͬ����Ԫ��
	yearTotalCompletedContract int default(0),		--�����ۼ���ɺ�ͬ��
	yearTotalCompletedContractMoney money default(0),--�����ۼ���ɺ�ͬ����Ԫ��
	

	makeDate smalldatetime null,		--�Ʊ�����
	makerID varchar(10) null,			--�Ʊ��˹���
	maker nvarchar(30) null,			--�Ʊ���
 CONSTRAINT [PK_monthlyReport] PRIMARY KEY CLUSTERED 
(
	[theMonth] ASC,
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


drop TABLE [dbo].[monthlyReportDetail]
CREATE TABLE [dbo].[monthlyReportDetail](
	theMonth smalldatetime not null,	--�����ͳ���¶�
	reportNum varchar(12) not null,		--����/�����������
	contractID varchar(12) not null,	--��������ͬ��ţ�ʹ�õ� 1 �ź��뷢��������

	startTime smalldatetime null,		--��ͬ����ʱ��
	completedTime smalldatetime null,	--��ͬ���ʱ�䣨�鵵ʱ�䣩
 CONSTRAINT [PK_monthlyReportDetail] PRIMARY KEY CLUSTERED 
(
	[theMonth] ASC,
	[reportNum] ASC,
	[contractID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[monthlyReportDetail]  WITH CHECK ADD  CONSTRAINT [FK_monthlyReportDetail_monthlyReport] FOREIGN KEY([theMonth],[reportNum])
REFERENCES [dbo].[monthlyReport] ([theMonth],[reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[monthlyReportDetail] CHECK CONSTRAINT [FK_monthlyReportDetail_monthlyReport]

--2.���ͳ�Ʊ�
drop table annualReport
CREATE TABLE [dbo].[annualReport](
	reportNum varchar(12) not null,		--������������
	theYear varchar(4) not null,		--������ͳ�����

	segment1Num int default(0),			--0.6�����£�������ͬ��
	segment1Money money default(0),		--0.6�����£�������ͬ���
	segment2Num int default(0),			--0.6�򣨲�����-1�򣨲�������ͬ��
	segment2Money money default(0),		--0.6�򣨲�����-1�򣨲�������ͬ���
	segment3Num int default(0),			--1�򣨺���-6�򣨲�������ͬ��
	segment3Money money default(0),		--1�򣨺���-6�򣨲�������ͬ���
	segment4Num int default(0),			--6�򣨺���-10�򣨲�������ͬ��
	segment4Money money default(0),		--6�򣨺���-10�򣨲�������ͬ���
	segment5Num int default(0),			--10�򣨺���-15�򣨲�������ͬ��
	segment5Money money default(0),		--10�򣨺���-15���ͬ���
	segment6Num int default(0),			--15�򣨺���-20�򣨲�������ͬ��
	segment6Money money default(0),		--15�򣨺���-20�򣨲�������ͬ���
	segment7Num int default(0),			--20�����ϣ�������ͬ��
	segment7Money money default(0),		--20�����ϣ�������ͬ���

	totalNum int default(0),			--�ϼƺ�ͬ��
	totalMoney money default(0),		--�ϼƺ�ͬ���

	payableFree money default(0),		--Ӧ��������
	realFree money default(0),			--ʵ��������

	makeDate smalldatetime null,		--�Ʊ�����
	makerID varchar(10) null,			--�Ʊ��˹���
	maker nvarchar(30) null,			--�Ʊ���
 CONSTRAINT [PK_annualReport] PRIMARY KEY CLUSTERED 
(
	[theYear] ASC,
	[reportNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


drop TABLE [dbo].[annualReportDetail]
CREATE TABLE [dbo].[annualReportDetail](
	theYear varchar(4) not null,		--�����ͳ�����
	reportNum varchar(12) not null,		--����/�����������

	traderID varchar(12) not null,		--��ó��˾���
	traderName nvarchar(30) null,		--��ó��˾���ƣ�������ƣ�������ʷ���� add by lw 2012-3-27
	abbTraderName nvarchar(6) null,		--��ó��˾���:������ƣ�add by lw 2012-4-27���ݿͻ�Ҫ������

	segment1Num int default(0),			--0.6�����£�������ͬ��
	segment1Money money default(0),		--0.6�����£�������ͬ���
	segment2Num int default(0),			--0.6�򣨲�����-1�򣨲�������ͬ��
	segment2Money money default(0),		--0.6�򣨲�����-1�򣨲�������ͬ���
	segment3Num int default(0),			--1�򣨺���-6�򣨲�������ͬ��
	segment3Money money default(0),		--1�򣨺���-6�򣨲�������ͬ���
	segment4Num int default(0),			--6�򣨺���-10�򣨲�������ͬ��
	segment4Money money default(0),		--6�򣨺���-10�򣨲�������ͬ���
	segment5Num int default(0),			--10�򣨺���-15�򣨲�������ͬ��
	segment5Money money default(0),		--10�򣨺���-15���ͬ���
	segment6Num int default(0),			--15�򣨺���-20�򣨲�������ͬ��
	segment6Money money default(0),		--15�򣨺���-20�򣨲�������ͬ���
	segment7Num int default(0),			--20�����ϣ�������ͬ��
	segment7Money money default(0),		--20�����ϣ�������ͬ���

	payableFree money default(0),		--Ӧ��������
	realFree money default(0),			--ʵ��������

 CONSTRAINT [PK_annualReportDetail] PRIMARY KEY CLUSTERED 
(
	[theYear] ASC,
	[reportNum] ASC,
	[traderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[annualReportDetail]  WITH CHECK ADD  CONSTRAINT [FK_annualReportDetail_annualReport] FOREIGN KEY([theYear],[reportNum])
REFERENCES [dbo].[annualReport] ([theYear],[reportNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[annualReportDetail] CHECK CONSTRAINT [FK_annualReportDetail_annualReport]



drop proc addMonthlyReport
/*
	name:		addMonthlyReport
	function:	1.���ָ���¶ȱ����Զ�����ͳ��ʱ����������
	input: 
				@theMonth varchar(7),			--ͳ���¶�
				@makerID varchar(10),			--�Ʊ��˹���
	output: 
				@Ret		int output,			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@reportNum varchar(12) output	--������:""��������ʱ����
	author:		¬έ
	CreateDate:	2013-06-11
	UpdateDate: 
*/
create PROCEDURE addMonthlyReport
	@theMonth varchar(7),			--ͳ���¶�
	@makerID varchar(10),			--�Ʊ��˹���
	@Ret int output,				--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	@reportNum varchar(12) output	--�����ţ�""��������ʱ����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 920, 1, @curNumber output
	set @reportNum = @curNumber
	--��ȡ�Ʊ���������
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--�Ʊ����ڣ�
	declare @makeDate smalldatetime		--�Ʊ�����
	set @makeDate = GETDATE()

	begin tran
		--��Ӹ�Ҫ��
		insert monthlyReport(reportNum, theMonth, makeDate, makerID, maker)
		values(@reportNum, @theMonth + '-01', @makeDate, @makerID, @maker)
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end

		--�����ϸ����Ŀ��
		insert monthlyReportDetail(theMonth, reportNum, contractID, startTime, completedTime)
		select @theMonth+'-01', @reportNum, contractID, startTime, completedTime
		from contractInfo
		where isnull(startTime,'')<>'' and isnull(convert(varchar(7),completedTime,120),@theMonth)=@theMonth
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end

		--���¸�Ҫ��ͳ�����֣�
		update monthlyReport
		set newContract = (select count(*) from monthlyReportDetail		--����������ͬ
							where reportNum=@reportNum and convert(varchar(7),startTime,120)=@theMonth),	
			newContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--����������ͬ����Ԫ��
							where contractID in (select contractID from monthlyReportDetail 
												 where reportNum=@reportNum and convert(varchar(7),startTime,120)=@theMonth)),0),
			completedContract = (select count(*) from monthlyReportDetail		--����ִ����ɺ�ͬ��
							where reportNum=@reportNum and convert(varchar(7),completedTime,120)=@theMonth),	
			completedContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--����ִ����ɺ�ͬ����Ԫ��
							where contractID in (select contractID from monthlyReportDetail 
												 where reportNum=@reportNum and convert(varchar(7),completedTime,120)=@theMonth)),0),
			totalContract = (select count(*) from monthlyReportDetail		--���ºϼƺ�ͬ��
							where reportNum=@reportNum 
							and (convert(varchar(7),startTime,120)=@theMonth or convert(varchar(7),completedTime,120)=@theMonth)),	
			totalContractMoney =isnull((select sum(isnull(dollar,0)) from contractInfo		--���ºϼƺ�ͬ����Ԫ��
							where contractID in (select contractID from monthlyReportDetail 
							where reportNum=@reportNum 
							and (convert(varchar(7),startTime,120)=@theMonth or convert(varchar(7),completedTime,120)=@theMonth))),0),	
			yearTotalCompletedContract = (select count(*) from monthlyReportDetail		--�����ۼ���ɺ�ͬ��
							where reportNum=@reportNum and convert(varchar(4),completedTime,120)=left(@theMonth,4)),	
			yearTotalCompletedContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--�����ۼ���ɺ�ͬ����Ԫ��
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
	--д������־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '�����¶�ͳ�Ʊ���', 'ϵͳ�����û�' + @maker + 
					'��Ҫ���������¶�ͳ�Ʊ���'+ +'[' + @reportNum + ']��')
GO
--���ԣ�
declare	@Ret int --�����ɹ���ʶ��0:�ɹ���9:δ֪����
declare @reportNum varchar(12) --�����ţ�""��������ʱ����
exec dbo.addMonthlyReport '2013-06','0000000000', @Ret output, @reportNum output
select @Ret, @reportNum

delete monthlyReport
select * from monthlyReport
select * from monthlyReportDetail


drop PROCEDURE delMonthlyReport
/*
	name:		delMonthlyReport
	function:	4.ɾ��ָ�����¶�ͳ�Ʊ���
	input: 
				@reportNum varchar(12),			--������
				@delManID varchar(10) output,	--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����¶�ͳ�Ʊ������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-11
	UpdateDate: 
*/
create PROCEDURE delMonthlyReport
	@reportNum varchar(12),			--������
	@delManID varchar(10) output,	--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı����Ƿ����
	declare @count as int
	set @count=(select count(*) from monthlyReport where reportNum = @reportNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end


	delete monthlyReport where reportNum = @reportNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���¶�ͳ�Ʊ���', '�û�' + @delManName
												+ 'ɾ�����¶�ͳ�Ʊ���['+ @reportNum +']��')

GO




drop proc addAnnualReport
/*
	name:		addAnnualReport
	function:	10.���ָ����ȱ����Զ�����ͳ��ʱ����������
	input: 
				@theYear varchar(4),			--ͳ�����
				@makerID varchar(10),			--�Ʊ��˹���
	output: 
				@Ret		int output,			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@reportNum varchar(12) output	--������:""��������ʱ����
	author:		¬έ
	CreateDate:	2013-06-12
	UpdateDate: 
*/
create PROCEDURE addAnnualReport
	@theYear varchar(4),			--ͳ�����
	@makerID varchar(10),			--�Ʊ��˹���
	@Ret int output,				--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	@reportNum varchar(12) output	--�����ţ�""��������ʱ����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 921, 1, @curNumber output
	set @reportNum = @curNumber
	--��ȡ�Ʊ���������
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--�Ʊ����ڣ�
	declare @makeDate smalldatetime		--�Ʊ�����
	set @makeDate = GETDATE()

	begin tran
		--��Ӹ�Ҫ��
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
		--���ɨ��������ó��˾�ĺ�ͬ���ͽ�
		declare @traderID varchar(12), @traderName nvarchar(30), @abbTraderName	nvarchar(6)		--��ó��˾
		declare tar cursor for
		select traderID, traderName, abbTraderName from traderInfo
		OPEN tar
		FETCH NEXT FROM tar INTO @traderID, @traderName, @abbTraderName
		WHILE @@FETCH_STATUS = 0
		begin
			--0.6�����£�����
			select @segment1Num = count(*), @segment1Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar <= 6000 and traderID = @traderID
			--0.6�򣨲�����-1�򣨲�����
			select @segment2Num = count(*), @segment2Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar > 6000 and dollar < 10000 and traderID = @traderID
			--1�򣨺���-6�򣨲�����
			select @segment3Num = count(*), @segment3Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 10000 and dollar < 60000 and traderID = @traderID
			--6�򣨺���-10�򣨲�����
			select @segment4Num = count(*), @segment4Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 60000 and dollar < 100000 and traderID = @traderID
			--10�򣨺���-15�򣨲�����
			select @segment5Num = count(*), @segment5Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 100000 and dollar < 150000 and traderID = @traderID
			--15�򣨺���-20�򣨲�����
			select @segment6Num = count(*), @segment6Money = SUM(dollar)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 150000 and dollar < 200000 and traderID = @traderID
			--20�����ϣ�����
			select @segment7Num = count(*), @segment7Money = SUM(dollar), @segmentg7Fee=SUM(payFee)
			from contractInfo
			where isnull(convert(varchar(4),startTime,120),'')=@theYear
					and dollar >= 200000 and traderID = @traderID
			declare @payableFree money	--Ӧ��������
			set @payableFree = (isnull(@segment1Money,0) + isnull(@segment2Money,0) + isnull(@segment3Money,0) + isnull(@segment4Money,0)
									+ isnull(@segment5Money,0) + isnull(@segment6Money,0) + isnull(@segment7Money,0)) * 0.25
			declare @realFree money		--ʵ��������
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

		--���¸�Ҫ��ͳ�����֣�
		select @segment1Num = sum(segment1Num), @segment1Money = sum(segment1Money), @segment2Num = sum(segment2Num), @segment2Money = sum(segment2Money),
							@segment3Num = sum(segment3Num), @segment3Money = sum(segment3Money), @segment4Num = sum(segment4Num), @segment4Money = sum(segment4Money),
							@segment5Num = sum(segment5Num), @segment5Money = sum(segment5Money), @segment6Num = sum(segment6Num), @segment6Money = sum(segment6Money),
							@segment7Num = sum(segment7Num), @segment7Money = sum(segment7Money),
							@payableFree = sum(payableFree), @realFree = sum(realFree)
		from annualReportDetail 
		where reportNum=@reportNum
		
		update annualReport
		set segment1Num = @segment1Num, segment1Money = @segment1Money ,		--0.6�����£�����
			segment2Num = @segment2Num, segment2Money = @segment2Money ,		--0.6�򣨲�����-1�򣨲�����
			segment3Num = @segment3Num, segment3Money = @segment3Money ,		--1�򣨺���-6�򣨲�����
			segment4Num = @segment4Num, segment4Money = @segment4Money ,		--6�򣨺���-10�򣨲�����
			segment5Num = @segment5Num, segment5Money = @segment5Money ,		--10�򣨺���-15��
			segment6Num = @segment6Num, segment6Money = @segment6Money ,		--15�򣨺���-20�򣨲�����
			segment7Num = @segment7Num, segment7Money = @segment7Money ,		--20�����ϣ�����
			totalNum = isnull(@segment1Num,0) + isnull(@segment2Num,0) + isnull(@segment3Num,0)
						+ isnull(@segment4Num,0) + isnull(@segment5Num,0) + isnull(@segment6Num,0) + isnull(@segment7Num,0),
			totalMoney = isnull(@segment1Money,0) + isnull(@segment2Money,0) + isnull(@segment3Money,0) 
						+ isnull(@segment4Money,0) + isnull(@segment5Money,0) + isnull(@segment6Money,0) + isnull(@segment7Money,0),
			payableFree = @payableFree,		--Ӧ��������
			realFree = @realFree			--ʵ��������
		where reportNum=@reportNum
		if (@@ERROR <> 0)
		begin
			rollback tran
			return
		end
	commit tran
	set @Ret = 0
	--д������־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '�������ͳ�Ʊ���', 'ϵͳ�����û�' + @maker + 
					'��Ҫ�����������ͳ�Ʊ���'+ +'[' + @reportNum + ']��')
GO
--���ԣ�
declare	@Ret int --�����ɹ���ʶ��0:�ɹ���9:δ֪����
declare @reportNum varchar(12) --�����ţ�""��������ʱ����
exec dbo.addannualReport '2012','0000000000', @Ret output, @reportNum output
select @Ret, @reportNum

delete annualReport
select * from annualReport
select * from annualReportDetail

select * from contractInfo

drop PROCEDURE delAnnualReport
/*
	name:		delAnnualReport
	function:	14.ɾ��ָ�������ͳ�Ʊ���
	input: 
				@reportNum varchar(12),			--������
				@delManID varchar(10) output,	--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������ͳ�Ʊ������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-12
	UpdateDate: 
*/
create PROCEDURE delAnnualReport
	@reportNum varchar(12),			--������
	@delManID varchar(10) output,	--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı����Ƿ����
	declare @count as int
	set @count=(select count(*) from annualReport where reportNum = @reportNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end


	delete annualReport where reportNum = @reportNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ�����ͳ�Ʊ���', '�û�' + @delManName
												+ 'ɾ�������ͳ�Ʊ���['+ @reportNum +']��')

GO


--�¶ȱ����б��ѯ��䣺
select reportNum, theMonth, newContract, newContractMoney, completedContract, 
	completedContractMoney, totalContract, totalContractMoney, 
	yearTotalCompletedContract, yearTotalCompletedContractMoney,
	makeDate, makerID, maker
from monthlyReport

--�¶ȱ�����ϸ��ѯ��䣨���������ͼ����
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




--��ȱ����ѯ��䣺
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


