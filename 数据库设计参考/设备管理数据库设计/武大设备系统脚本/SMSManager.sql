use epdc211
/*
	武大设备管理信息系统-短信管理表设计
	author:		卢苇
	CreateDate:	2012-8-18
	UpdateDate:
				
*/
select SMSInfoID, receiverID, receiver, mobile, convert(varchar(19),sendPlanTime,120) sendPlanTime, 
		convert(varchar(19),sendTime,120) sendTime, case SMSType when 1 then '系统定期推送' when 2 then '手工发送' end SMSType, 
		case SMSStatus when 0 then '' when 1 then '?' when 2 then '√' when -1 then '╳' end SMSStatus, SMSContent, senderID, sender
from SMSInfo
select * from SMSInfo
update SMSInfo set lockManID=''

alter TABLE SMSInfo add	feeTimes int default(1) null,		--计费次数：与OA系统一致化 by lw 2013-10-31
update SMSInfo
set feetimes=1

drop TABLE SMSInfo
CREATE TABLE SMSInfo
(
	SMSInfoID char(12) not null,		--主键：短信标识，使用第 10020 号号码发生器产生
	senderID varchar(10) not null,		--发信人工号
	sender nvarchar(30) not null,		--发信人
	receiverID varchar(110) not null,	--收信人工号：多个收信人使用“,”分隔
	receiver nvarchar(310) not null,	--收信人：多个收信人使用“,”分隔
	mobile varchar(300) not null,		--手机：多个手机使用“,”分隔
	sendPlanTime datetime null,			--计划发送时间:为null的时候为立刻发送
	sendTime datetime null,				--发送时间
	SMSType smallint default(2),		--短信类型：1->系统定期推送、2->手工发送
	SMSStatus smallint default(0),		--短信状态：0->新建（未定义发送）、1->请求发送、9->已发送、-1->发送失败
	SMSContent nvarchar(300) null,		--短信内容

	feeTimes int default(1) null,		--计费次数：与OA系统一致化 by lw 2013-10-31

	--创建人：
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_SMSInfo] PRIMARY KEY CLUSTERED 
(
	[SMSInfoID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_SMSInfo] ON [dbo].[SMSInfo] 
(
	[sender] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_1] ON [dbo].[SMSInfo] 
(
	[receiver] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_2] ON [dbo].[SMSInfo] 
(
	[sendTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_3] ON [dbo].[SMSInfo] 
(
	[SMSStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_4] ON [dbo].[SMSInfo] 
(
	[SMSType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.短信模板库：这个库暂时使用手工维护
drop table SMSTemplate
CREATE TABLE SMSTemplate(
	templateID varchar(12) not null,	--主键：消息模板编号,本系统使用第11001号号码发生器产生（8位日期代码+4位流水号）
	templateType nvarchar(30) null,		--消息模板类型
	templateBody nvarchar(4000) null,	--消息模板内容
 CONSTRAINT [PK_SMSTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--3.短信计费表：
select convert(varchar(10),a.accountTime,120) accountTime, a.summary, a.invoice, a.feeTimes, 
	a.income, a.outlay, a.overage
from SMSFeeAccount a
order by rowNum desc
select * from smsfeeaccount
drop TABLE SMSFeeAccount
CREATE TABLE SMSFeeAccount
(
	rowNum int IDENTITY(1,1) NOT NULL,	--主键：序号
	accountTime datetime null,			--记账时间
	summary nvarchar(30) null,			--摘要
	invoice varchar(30) null,			--票据号:收入的发票号，支出的短信号
	feeTimes int default(0),			--计费次数
	income numeric(12,2) default(0),	--收入
	outlay numeric(12,2) default(0),	--支出
	overage numeric(12,2) null,			--余额
 CONSTRAINT [PK_SMSFeeAccount] PRIMARY KEY CLUSTERED 
(
	[rowNum] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE addSMSInfo
/*
	name:		addSMSInfo
	function:	1.添加短信
				注意：该存储过程不锁定单据
	input: 
				@senderID varchar(10),		--发信人工号
				@receiverID varchar(110),	--收信人工号：多个收信人使用“,”分隔
				@mobile varchar(300),		--手机：多个手机使用“,”分隔
				@sendPlanTime varchar(19),	--计划发送时间
				@SMSType smallint,			--短信类型：1->系统定期推送、2->手工发送、9->系统管理类短信
				@SMSContent nvarchar(300),	--短信内容

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output	--创建时间
				@SMSInfoID char(12) output	--主键：短信标识，使用第 10020 号号码发生器产生
	author:		卢苇
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29修改收信人解析错误和增加收费次数统计
*/
create PROCEDURE addSMSInfo
	@senderID varchar(10),		--发信人工号
	@receiverID varchar(110),	--收信人工号：多个收信人使用“,”分隔
	@mobile varchar(300),		--手机：多个手机使用“,”分隔
	@sendPlanTime varchar(19),	--计划发送时间
	@SMSType smallint,			--短信类型：1->系统定期推送、2->手工发送
	@SMSContent nvarchar(300),	--短信内容

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,	--创建时间
	@SMSInfoID char(12) output	--主键：短信标识，使用第 10020 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生短信标识号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10020, 1, @curNumber output
	set @SMSInfoID = @curNumber

	--取发信人、收信人的姓名，统计收费次数：
	declare @id varchar(10), @sender nvarchar(30),@receiver nvarchar(310)
	declare @feeTimes int
	set @receiver = '';set @feeTimes = 0;
	declare tar cursor for
	SELECT convert(varchar(10),T.x.query('data(.)')) FROM 
	(SELECT CONVERT(XML,'<x>'+REPLACE(@receiverID,',','</x><x>')+'</x>',1) Col1) A
	OUTER APPLY A.Col1.nodes('/x') AS T(x)
	OPEN tar
	FETCH NEXT FROM tar INTO @id
	WHILE @@FETCH_STATUS = 0
	begin
		declare @name nvarchar(30)
		set @name = isnull((select cName from userInfo where jobNumber = @id),'')
		set @receiver = @receiver + @name
		set @feeTimes = @feeTimes + 1
		FETCH NEXT FROM tar INTO @id
	end
	CLOSE tar
	DEALLOCATE tar
	set @sender = isnull((select cName from userInfo where jobNumber = @senderID),'')

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--检查计划发送时间：
	declare @sPTime datetime
	if (@sendPlanTime='')
		set @sPTime = null
	else
		set @sPTime = CONVERT(datetime,@sendPlanTime,120)
	
	set @createTime = getdate()
	insert SMSInfo(SMSInfoID, senderID, sender, receiverID, receiver, mobile,
					sendPlanTime, SMSType, SMSContent, feeTimes,
					lockManID, modiManID, modiManName, modiTime,
					createManID, createManName, createTime)
	values (@SMSInfoID, @senderID, @sender, @receiverID, @receiver, @mobile,
					@sPTime, @SMSType, @SMSContent, @feeTimes,
					'', @createManID, @createManName, @createTime,
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加短信', '系统根据用户' + @createManName + 
					'的要求添加了短信[' + @SMSInfoID + ']。')
GO
--测试：
declare @Ret		int
declare @createTime smalldatetime 
declare @SMSInfoID char(12)
exec addSMSInfo '00200977','00200977','18602702392','',2,'Hello world!','00200977',@Ret output, @createTime output, @SMSInfoID output
select @Ret,@SMSInfoID

select * from SMSInfo

drop PROCEDURE querySMSInfoLocMan
/*
	name:		querySMSInfoLocMan
	function:	2.查询指定短信是否有人正在编辑
	input: 
				@SMSInfoID char(12),	--主键：短信标识，使用第 10020 号号码发生器产生
	output: 
				@Ret		int output	--操作成功标识
							0:成功，9：查询出错，可能是指定的短信不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE querySMSInfoLocMan
	@SMSInfoID char(12),	--主键：短信标识，使用第 10020 号号码发生器产生
	@Ret int output,		--操作成功标识
	@lockManID varchar(10) output		--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from SMSInfo where SMSInfoID = @SMSInfoID),'')
	set @Ret = 0
GO


drop PROCEDURE lockSMSInfo4Edit
/*
	name:		lockSMSInfo4Edit
	function:	3.锁定短信编辑，避免编辑冲突
	input: 
				@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前短信正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0：成功，1：要锁定的短信不存在，
							2：要锁定的短信正在被别人编辑，
							3：该短信已发送或正在发送
							9：未知错误
	author:		卢苇
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29 将“请求发送”状态列为不可编辑
*/
create PROCEDURE lockSMSInfo4Edit
	@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前短信正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的短信是否存在
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @SMSStatus int
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查短信状态:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end

	update SMSInfo 
	set lockManID = @lockManID 
	where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定短信编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了短信['+ @SMSInfoID +']为独占式编辑。')
GO

drop PROCEDURE unlockSMSInfoEditor
/*
	name:		unlockSMSInfoEditor
	function:	4.释放短信编辑锁
				注意：本过程不检查短信是否存在！
	input: 
				@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前短信正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE unlockSMSInfoEditor
	@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前短信正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from SMSInfo where SMSInfoID = @SMSInfoID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update SMSInfo set lockManID = '' where SMSInfoID = @SMSInfoID
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放短信编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了短信['+ @SMSInfoID +']的编辑锁。')
GO


drop PROCEDURE updateSMSInfo
/*
	name:		updateSMSInfo
	function:	5.更新短信
	input: 
				@SMSInfoID char(12),		--主键：短信标识，使用第 10020 号号码发生器产生
				@senderID varchar(10),		--发信人工号
				@receiverID varchar(110),	--收信人工号：多个收信人使用“,”分隔
				@mobile varchar(300),		--手机：多个手机使用“,”分隔
				@sendPlanTime varchar(19),	--计划发送时间
				@SMSType smallint,			--短信类型：1->系统定期推送、2->手工发送、9->系统管理类短信
				@SMSContent nvarchar(300),	--短信内容

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前短信正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的短信不存在，2：要更新的短信正被别人锁定，
							3：该短信已发送或正在发送，不允许修改，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29 将“请求发送”状态列为不可编辑
*/
create PROCEDURE updateSMSInfo
	@SMSInfoID char(12),		--主键：短信标识，使用第 10020 号号码发生器产生
	@senderID varchar(10),		--发信人工号
	@receiverID varchar(110),	--收信人工号：多个收信人使用“,”分隔
	@mobile varchar(300),		--手机：多个手机使用“,”分隔
	@sendPlanTime varchar(19),	--计划发送时间
	@SMSType smallint,			--短信类型：1->系统定期推送、2->手工发送
	@SMSContent nvarchar(300),	--短信内容

	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前短信正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @SMSStatus int
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查短信状态:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end
	
	--取发信人、收信人的姓名，统计收费次数：
	declare @id varchar(10), @sender nvarchar(30),@receiver nvarchar(310)
	declare @feeTimes int
	set @receiver = '';set @feeTimes = 0;
	declare tar cursor for
	SELECT convert(varchar(10),T.x.query('data(.)')) FROM 
	(SELECT CONVERT(XML,'<x>'+REPLACE(@receiverID,',','</x><x>')+'</x>',1) Col1) A
	OUTER APPLY A.Col1.nodes('/x') AS T(x)
	OPEN tar
	FETCH NEXT FROM tar INTO @id
	WHILE @@FETCH_STATUS = 0
	begin
		declare @name nvarchar(30)
		set @name = isnull((select cName from userInfo where jobNumber = @id),'')
		set @receiver = @receiver + @name
		set @feeTimes = @feeTimes + 1
		FETCH NEXT FROM tar INTO @id
	end
	CLOSE tar
	DEALLOCATE tar
	set @sender = isnull((select cName from userInfo where jobNumber = @senderID),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--检查计划发送时间：
	declare @sPTime datetime
	if (@sendPlanTime='')
		set @sPTime = null
	else
		set @sPTime = CONVERT(datetime,@sendPlanTime,120)

	set @updateTime = getdate()
	update SMSInfo 
	set SMSInfoID = @SMSInfoID, senderID = @senderID, sender = @sender, 
		receiverID = @receiverID, receiver = @receiver, mobile = @mobile,
		sendPlanTime = @sPTime, SMSType = @SMSType, SMSContent = @SMSContent,
		feeTimes = @feeTimes,
		SMSStatus = 0,	--将状态复位
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新短信', '用户' + @modiManName 
												+ '更新了短信['+ @SMSInfoID +']。')
GO

select * from SMSFeeAccount
drop PROCEDURE delSMSInfo
/*
	name:		delSMSInfo
	function:	6.删除指定的短信
	input: 
				@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
				@delManID varchar(10) output,	--删除人，如果当前短信正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的短信不存在，
							2：要删除的短信正被别人锁定，
							3：该短信已发送或正在发送，不允许删除，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29限制删除功能，发送的短信不允许删除！
*/
create PROCEDURE delSMSInfo
	@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
	@delManID varchar(10) output,	--删除人，如果当前短信正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的短信是否存在
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @SMSStatus int
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查短信状态:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end

	delete SMSInfo where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除短信', '用户' + @delManName
												+ '删除了短信['+ @SMSInfoID +']。')

GO

drop PROCEDURE clearSMSInfo
/*
	name:		clearSMSInfo
	function:	7.清除短信
				注意:该过程不检查短信状态，是高级管理人员使用的过程。该过程不能清除最近三个月的短信！
	input: 
				@startTime varchar(19),			--清除时间范围：开始时间
				@endTime varchar(19),			--清除时间范围：结束时间
				@clearManID varchar(10) output,	--清除人
	output: 
				@Ret		int output			--操作成功标识：0:成功，1:不能清除最近90天的数据，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-29
	UpdateDate: 

*/
create PROCEDURE clearSMSInfo
	@startTime varchar(19),			--清除时间范围：开始时间
	@endTime varchar(19),			--清除时间范围：结束时间
	@clearManID varchar(10) output,	--清除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--检查日期格式：
	declare @sTime smalldatetime, @eTime smalldatetime
	set @sTime = CONVERT(datetime,@startTime,120)
	set @eTime = CONVERT(datetime,@endTime,120)
	if (@sTime > @eTime)
	begin
		declare @temp smalldatetime
		set @temp = @sTime
		set @sTime = @eTime
		set @eTime = @temp
	end
	if (datediff(day,@eTime, GETDATE()) < 90)
	begin
		set @Ret = 1
		return
	end

	delete SMSInfo where modiTime>=@sTime and modiTime <= @eTime
	set @Ret = 0

	--取维护人的姓名：
	declare @clearManName nvarchar(30)
	set @clearManName = isnull((select userCName from activeUsers where userID = @clearManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@clearManID, @clearManName, getdate(), '清除短信', '用户' + @clearManName
			+ '清除了短信['+ convert(varchar(19),@sTime,120) + '至' + CONVERT(varchar(19),@eTime,120)  +']范围内的短信。')

GO
--测试：
declare @Ret int
exec dbo.clearSMSInfo '2012-09-1','2012-06-01','0000000000', @ret output
select @Ret
select * from SMSInfo
select * from workNote order by actionTime desc

drop PROCEDURE changeSMSStatus
drop PROCEDURE sendSMS
/*
	name:		sendSMS
	function:	8.发送短信
				注：该功能只将短信状态标定为请求发送状态，由调度程序自动调度发送！
	input: 
				@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
				@sendTime varchar(19),			--发送时间

				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前短信正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0：成功，1：指定的短信不存在，
							2：要发送的短信正被别人锁定，
							3：该短信已经发送或正在发送，
							4：账号余额不足，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE sendSMS
	@SMSInfoID char(12),			--主键：短信标识，使用第 10020 号号码发生器产生
	@sendTime varchar(19),			--发送时间

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前短信正在被人占用编辑则返回该人的工号
	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的短信是否存在
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @SMSStatus int, @oldSendPlanTime smalldatetime
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus, @oldSendPlanTime = sendPlanTime
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查短信状态:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--检查计划发送时间：
	declare @sTime datetime
	if (@sendTime='')
	begin
		if (@oldSendPlanTime is null)
			set @sTime = GETDATE()
		else 
			set @sTime = null
	end
	else
		set @sTime = CONVERT(datetime,@sendTime,120)
		
	--检查计费账号余额并记账：
	declare @feeTimes int		--本次短信发送计费次数
	declare @fee numeric(12,2)	--本次计费
	set @feeTimes = isnull((select feeTimes from SMSInfo where SMSInfoID = @SMSInfoID),1)
	declare @price numeric(12,2) --短信单价
	set @price = isnull(cast((select objDesc from codeDictionary where classCode=1 and objCode=6) as numeric(12,2)),0.1)
	set @fee = @feeTimes * @price
	
	declare @feeMode varchar(10)	--系统收费模式
	set @feeMode = isnull((select objDesc from codeDictionary where classCode=1 and objCode=5),2)
	declare @overage numeric(12,2)
	set @overage = isnull((select top 1 overage from SMSFeeAccount order by rowNum desc),0)
	if (@feeMode=2) --预付费模式
	begin
		if (@overage < @fee)
		begin
			set @Ret = 4
			return 
		end
	end
	
	set @updateTime = getdate()
	begin tran
		insert SMSFeeAccount(accountTime, summary, invoice, feeTimes, income, outlay, overage)
		values(@updateTime,'发送短信',@SMSInfoID,@feeTimes,0,@fee,@overage - @fee)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		update SMSInfo
		set SMSStatus = 1,	--短信状态：0->新建（未定义发送）、1->请求发送、9->已发送、-1->发送失败
			sendPlanTime = @sTime,
			--维护人：
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where SMSInfoID = @SMSInfoID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '发送短信', '用户' + @modiManName 
												+ '发送了短信['+ @SMSInfoID +']。')
GO
--测试:
declare	@updateTime smalldatetime --更新时间
declare	@Ret		int				--操作成功标识
exec dbo.sendSMS '201212300002', '2012-12-30 00:50:00', '00001', @updateTime output, @Ret output
select @Ret

update SMSInfo
set SMSStatus = 0

select * from SMSInfo
select * from SMSFeeAccount
select * from workNote

drop PROCEDURE sendingInfo
/*
	name:		sendingInfo
	function:	9.发送情况登记
				注：这是管理器登记的专有过程
	input: 
				@SMSInfoID char(12),		--短信标识
				@isSended smallint,			--是否发送成功：9->发送成功，-1->发送失败
	output: 
				@Ret		int output		--操作成功标识
							0：成功，1：指定的短信不存在，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE sendingInfo
	@SMSInfoID char(12),		--短信标识
	@isSended smallint,			--是否发送成功：9->发送成功，-1->发送失败
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的短信是否存在
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	begin tran	
		if (@isSended = -1)	--发送失败将费用倒计
		begin
			declare @overage numeric(12,2)
			set @overage = isnull((select top 1 overage from SMSFeeAccount order by rowNum desc),0)

			insert SMSFeeAccount(accountTime, summary, invoice, feeTimes, income, outlay, overage)
			select top 1 getdate(),'发送失败',@SMSInfoID,feeTimes,0,-outlay,@overage + outlay
			from SMSFeeAccount 
			where invoice = @SMSInfoID
			order by rowNum desc
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end

		update SMSInfo	
		set sendTime=GETDATE(),
			SMSStatus=@isSended
		where SMSInfoID = @SMSInfoID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran	
	set @Ret = 0
GO
--测试：
declare @Ret		int		--操作成功标识
exec dbo.sendingInfo '201212300002', -1, @Ret output
select @Ret
