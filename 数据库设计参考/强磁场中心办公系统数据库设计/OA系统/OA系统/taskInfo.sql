use hustOA
/*
	强磁场中心办公系统-任务管理
	author:		卢苇
	CreateDate:	2013-1-5
	UpdateDate: 
*/

select * from taskInfo
--1.任务管理表：
alter table taskInfo add closeRemind smallint default(0)	--是否关闭提醒：0->不关闭，1->关闭 add by lw 2013-6-18
update taskInfo
set closeRemind = 0
alter table taskInfo add taskRemindTime smalldatetime null	--任务提醒时间：该字段为计算时间 add by lw 2013-6-19

update taskInfo
set taskRemindTime = DATEADD(MINUTE,-taskRemindBefore,taskStartTime)
where taskStartTime > '2013'
select * from taskInfo
where taskID='RW20131253'

drop table taskInfo
CREATE TABLE taskInfo(
	taskID varchar(10) not null,		--主键：任务编号,本系统使用第11010号号码发生器产生（'RW'+4位年份代码+4位流水号）
	topic  nvarchar(300) null,			--任务描述
	taskManID varchar(10) not null,		--任务所有人工号
	taskMan nvarchar(30) not null,		--任务所有人姓名
	taskStartTime smalldatetime null,	--任务开始时间
	taskEndTime smalldatetime null,		--任务结束时间
	summary nvarchar(300) null,			--任务内容描述

	needSMSInvitation smallint default(0),--是否需要短信通知：0->需要, 1->不需要(暂时不启用，将来为定义别人的任务使用)
	needSMSRemind smallint default(0),	--是否需要短信提醒：0->不需要，1->需要
	taskRemindBefore int default(15),	--任务提醒提前时间：单位为分钟，默认为15分钟
	taskRemindTime smalldatetime null,	--任务提醒时间：该字段为计算时间 add by lw 2013-6-19
	closeRemind smallint default(0),	--是否关闭提醒：0->不关闭，1->关闭 add by lw 2013-6-18
	isOver smallint default(0),			--任务是否结束：0->未结束，1->结束
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_taskInfo] PRIMARY KEY CLUSTERED 
(
	[isOver] DESC,
	[taskID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--任务开始时间索引：
CREATE NONCLUSTERED INDEX [IX_taskInfo] ON [dbo].[taskInfo] 
(
	[taskStartTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE queryTaskInfoLocMan
/*
	name:		queryTaskInfoLocMan
	function:	1.查询指定任务是否有人正在编辑
	input: 
				@taskID varchar(10),		--任务编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的任务不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-1-5
	UpdateDate: 
*/
create PROCEDURE queryTaskInfoLocMan
	@taskID varchar(10),		--任务编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from taskInfo where taskID= @taskID),'')
	set @Ret = 0
GO


drop PROCEDURE lockTaskInfo4Edit
/*
	name:		lockTaskInfo4Edit
	function:	2.锁定任务编辑，避免编辑冲突
	input: 
				@taskID varchar(10),			--任务编号
				@lockManID varchar(10) output,	--锁定人，如果当前任务正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的任务不存在，2:要锁定的任务正在被别人编辑，
							3：该任务已结束，不允许编辑锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-1-5
	UpdateDate: 
*/
create PROCEDURE lockTaskInfo4Edit
	@taskID varchar(10),		--任务编号
	@lockManID varchar(10) output,	--锁定人，如果当前任务正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的任务是否存在
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isOver smallint
	select @thisLockMan = isnull(lockManID,''), @isOver = isOver from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查状态：
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end

	update taskInfo
	set lockManID = @lockManID 
	where taskID= @taskID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定任务编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了任务['+ @taskID +']为独占式编辑。')
GO

drop PROCEDURE unlockTaskInfoEditor
/*
	name:		unlockTaskInfoEditor
	function:	3.释放任务编辑锁
				注意：本过程不检查任务是否存在！
	input: 
				@taskID varchar(10),			--任务编号
				@lockManID varchar(10) output,	--锁定人，如果当前任务正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-5
	UpdateDate: 
*/
create PROCEDURE unlockTaskInfoEditor
	@taskID varchar(10),			--任务编号
	@lockManID varchar(10) output,	--锁定人，如果当前任务呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from taskInfo where taskID= @taskID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update taskInfo set lockManID = '' where taskID= @taskID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
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
	values(@lockManID, @lockManName, getdate(), '释放任务编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了任务['+ @taskID +']的编辑锁。')
GO

drop PROCEDURE addTaskInfo
/*
	name:		addTaskInfo
	function:	4.添加任务信息
				注意：目前只支持添加本人的任务
	input: 
				@topic  nvarchar(300),			--任务描述
				@taskStartTime varchar(19),		--任务开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@taskEndTime varchar(19),		--任务结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@summary nvarchar(300),			--任务内容描述

				@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
				@needSMSRemind smallint,		--是否需要短信提醒：0->不需要，1->需要
				@taskRemindBefore int,			--任务提醒提前时间：单位为分钟，默认为15分钟

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@taskID varchar(10) output		--任务编号
	author:		卢苇
	CreateDate:	2013-1-5
	UpdateDate: modi by lw 2013-6-19将提醒时间作为单独字段计算
*/
create PROCEDURE addTaskInfo
	@topic  nvarchar(300),			--任务描述
	@taskStartTime varchar(19),		--任务开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@taskEndTime varchar(19),		--任务结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@summary nvarchar(300),			--任务内容描述

	@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
	@needSMSRemind smallint,		--是否需要短信提醒：0->不需要，1->需要
	@taskRemindBefore int,			--任务提醒提前时间：单位为分钟，默认为15分钟

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@taskID varchar(10) output		--任务编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生任务编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 11010, 1, @curNumber output
	set @taskID = @curNumber

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	declare @taskRemindTime smalldatetime --任务提醒时间
	set @taskRemindTime = DATEADD(MINUTE,-@taskRemindBefore,@taskStartTime)
	insert taskInfo(taskID, topic, taskManID, taskMan, taskStartTime, taskEndTime, summary,
					needSMSInvitation, needSMSRemind, taskRemindBefore, taskRemindTime,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@taskID, @topic, @createManID, @createManName, @taskStartTime, @taskEndTime, @summary,
					@needSMSInvitation, @needSMSRemind, @taskRemindBefore, @taskRemindTime,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记任务', '系统根据用户' + @createManName + 
					'的要求登记了任务“' + @topic + '['+@taskID+']”。')
GO

drop PROCEDURE updateTaskInfo
/*
	name:		updateTaskInfo
	function:	5.修改任务信息
				注意：目前只支持修改本人的任务
	input: 
				@taskID varchar(10),		--任务编号
				@topic  nvarchar(300),			--任务描述
				@taskStartTime varchar(19),		--任务开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@taskEndTime varchar(19),		--任务结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
				@summary nvarchar(300),			--任务内容描述

				@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
				@needSMSRemind smallint,		--是否需要短信提醒：0->不需要，1->需要
				@taskRemindBefore int,			--任务提醒提前时间：单位为分钟，默认为15分钟

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的任务不存在，
							2:要修改的任务正被别人锁定编辑，
							3：该任务已经结束，不允许修改，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2013-1-5
	UpdateDate: modi by lw 2013-6-19将提醒时间作为单独字段计算
*/
create PROCEDURE updateTaskInfo
	@taskID varchar(10),		--任务编号
	@topic  nvarchar(300),			--任务描述
	@taskStartTime varchar(19),		--任务开始时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@taskEndTime varchar(19),		--任务结束时间：采用"yyyy-MM-dd hh:MM:ss"格式存放
	@summary nvarchar(300),			--任务内容描述

	@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
	@needSMSRemind smallint,		--是否需要短信提醒：0->不需要，1->需要
	@taskRemindBefore int,			--任务提醒提前时间：单位为分钟，默认为15分钟

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的任务是否存在
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @isOver smallint
	select @thisLockMan = isnull(lockManID,''), @isOver = isOver from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查状态：
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	declare @taskRemindTime smalldatetime --任务提醒时间
	set @taskRemindTime = DATEADD(MINUTE,-@taskRemindBefore,@taskStartTime)
	update taskInfo
	set topic = @topic, taskManID = @modiManID, taskMan = @modiManName, 
		taskStartTime = @taskStartTime, taskEndTime = @taskEndTime, summary = @summary,
		needSMSInvitation = @needSMSInvitation, needSMSRemind = @needSMSRemind, taskRemindBefore = @taskRemindBefore,
		taskRemindTime = @taskRemindTime,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where taskID= @taskID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改任务', '系统根据用户' + @modiManName + 
					'的要求修改了任务“' + @topic + '['+@taskID+']”的登记信息。')
GO

drop PROCEDURE delTaskInfo
/*
	name:		delTaskInfo
	function:	6.删除指定的任务
				注意：该存储过程不检测任务的状态，可以删除已经完成的任务。
	input: 
				@taskID varchar(10),			--任务编号
				@delManID varchar(10) output,	--删除人，如果当前任务正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的任务不存在，2：要删除的任务正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-5
	UpdateDate: 

*/
create PROCEDURE delTaskInfo
	@taskID varchar(10),			--任务编号
	@delManID varchar(10) output,	--删除人，如果当前任务正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的任务是否存在
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete taskInfo where taskID= @taskID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除任务', '用户' + @delManName
												+ '删除了任务['+@taskID+']。')

GO


drop PROCEDURE closeTaskRemind
/*
	name:		closeTaskRemind
	function:	7.关闭指定任务的提醒
	input: 
				@taskID varchar(10),			--任务编号
				@closeManID varchar(10) output,	--关闭人，如果当前任务正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的任务不存在，2：要关闭的任务正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-19
	UpdateDate: 

*/
create PROCEDURE closeTaskRemind
	@taskID varchar(10),			--任务编号
	@closeManID varchar(10) output,	--关闭人，如果当前任务正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的任务是否存在
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @closeManID)
	begin
		set @closeManID = @thisLockMan
		set @Ret = 2
		return
	end

	update taskInfo 
	set closeRemind = 1
	where taskID= @taskID
	set @Ret = 0

	--取维护人的姓名：
	declare @closeManName nvarchar(30)
	set @closeManName = isnull((select userCName from activeUsers where userID = @closeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@closeManID, @closeManName, getdate(), '关闭任务提醒', '用户' + @closeManName
												+ '关闭了任务['+@taskID+']的提醒。')

GO

drop PROCEDURE delayTaskRemindTime
/*
	name:		delayTaskRemindTime
	function:	8.推迟指定任务的提醒时间
	input: 
				@taskID varchar(10),			--任务编号
				@delayTimes int,				--推迟时间：单位为分钟
				@needSMSRemind smallint,		--是否需要短信提醒：0->不需要，1->需要
				@delayer varchar(10) output,	--推迟人，如果当前任务正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的任务不存在，2：要推迟的任务正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-19
	UpdateDate: modi by lw 2013-07-13增加是否需要再次短信提醒接口！

*/
create PROCEDURE delayTaskRemindTime
	@taskID varchar(10),			--任务编号
	@delayTimes int,				--推迟时间：单位为分钟
	@needSMSRemind smallint,		--是否需要短信提醒：0->不需要，1->需要
	@delayer varchar(10) output,	--推迟人，如果当前任务正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的任务是否存在
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @delayer)
	begin
		set @delayer = @thisLockMan
		set @Ret = 2
		return
	end

	update taskInfo 
	set taskRemindTime = DATEADD(MINUTE, @delayTimes, GETDATE()), needSMSRemind = @needSMSRemind
	where taskID= @taskID
	set @Ret = 0

	--取维护人的姓名：
	declare @delayerName nvarchar(30)
	set @delayerName = isnull((select userCName from activeUsers where userID = @delayer),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delayer, @delayerName, getdate(), '推迟任务提醒', '用户' + @delayerName
												+ '推迟了任务['+@taskID+']的提醒。')

GO

drop PROCEDURE scanTaskSMSRemind
/*
	name:		scanTaskSMSRemind
	function:	9.自动扫描需要发送提醒短信的任务，并发送
				注意：该存储过程不登记工作日志
	input: 
	output: 
				@Ret		int output			--发送短信条数
	author:		卢苇
	CreateDate:	2013-07-12
	UpdateDate: 

*/
create PROCEDURE scanTaskSMSRemind
	@Ret		int output			--发送短信条数
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @taskID varchar(10), @topic nvarchar(300), @taskStartTime varchar(19)
	declare @userID varchar(10), @userCName nvarchar(30), @mobile varchar(20)
	declare @execRet int, @messageID varchar(12)
	set @Ret = 0
	
	declare mtar cursor for
	select t.taskID, t.topic, convert(varchar(19),t.taskStartTime,120), t.taskManID, isnull(u.cName,''), isnull(u.mobile,'')
	from taskInfo t left join userInfo u on t.taskManID = u.jobNumber
	where isOver = 0 and closeRemind=0 and taskRemindTime< getdate() and needSMSRemind=1
	OPEN mtar
	FETCH NEXT FROM mtar INTO @taskID, @topic, @taskStartTime, @userID, @userCName, @mobile
	WHILE @@FETCH_STATUS = 0
	begin
		if (@mobile<>'')
		begin
			declare @SMSInfoID char(12)			--短信编号
			declare @createTime smalldatetime 
			declare @SMSContent nvarchar(300)	--短信内容
			set @SMSContent = '亲爱的' + @userCName + ':您计划的任务['+@topic+']即将于['+@taskStartTime+']到期。'
			exec dbo.addSMSInfo '0000000000', @userID, @mobile, '', 9, @SMSContent, '0000000000', @execRet output, @createTime output, @SMSInfoID output
			--发送短信：
			declare @snderID varchar(10)
			set @snderID = '0000000000'
			exec dbo.sendSMS @SMSInfoID,'', @snderID output,@createTime output,@execRet output
			if (@execRet=0)
			begin
				--将短信提醒清除：
				update taskInfo set needSMSRemind=0 where taskID = @taskID
				set @Ret = @Ret+1
			end
		end
		FETCH NEXT FROM mtar INTO @taskID, @topic, @taskStartTime, @userID, @userCName, @mobile
	end
	CLOSE mtar
	DEALLOCATE mtar
GO
--测试：
declare @Ret		int
exec dbo.scanTaskSMSRemind @Ret output
select @Ret

select * from taskInfo


--任务的查询语句：
select t.taskID, t.topic, t.taskManID, t.taskMan, 
convert(varchar(19),t.taskStartTime,120) taskStartTime, CONVERT(varchar(19),t.taskEndTime,120) taskEndTime, 
t.needSMSInvitation, t.needSMSRemind, t.taskRemindBefore, t.isOver 
from taskInfo t
order by t.taskStartTime desc



--消息、任务、勤务状态联合查询：
declare @myDate varchar(10), @userID varchar(10)
set @myDate = '2013-01-21'
set @userID = 'G201300001'
select 1 iType, messageID id, messageType topic, sendTime theTime, isRead iStatus
from messageInfo
where convert(varchar(10),sendTime,120)=@myDate  and receiverID=@userID 
union all
select 2, taskID, topic, taskStartTime, case isOver 
    										when 1 then 9 --已完成任务
    									else case 
    											 when DATEDIFF(s,getdate(), taskStartTime) > 0  then 2    --未超时任务
    										 else 3   --超时任务
    											 end
    										end 
from taskInfo
where convert(varchar(10),taskStartTime,120)=@myDate and taskManID=@userID
union all
select 3, cast(rowNum as varchar(10)), dutyStatusDesc, startTime, 100
from dutyStatusInfo
where convert(varchar(10),startTime,120)=@myDate and userID=@userID
order by theTime

/*
iStatus定义的值：
0->消息未阅读，1->消息已阅读
2->未超时任务，3->超时任务，9->任务已完成
100->无状态
*/



select 1 iType, messageID id, messageType topic, sendTime theTime, isRead iStatus 
from messageInfo 
where convert(varchar(10),sendTime,120)='2013-01-22' and receiverID='0000000000' 
union all 
select 2, taskID, topic, taskStartTime, case isOver when 1 then 9 else case when DATEDIFF(s,getdate(), taskStartTime) > 0  then 2 else 3 end end  
from taskInfo 
where convert(varchar(10),taskStartTime,120)='2013-01-22' and taskManID='0000000000' 
union all 
select 3, cast(rowNum as varchar(10)), dutyStatusDesc, startTime, 100 
from dutyStatusInfo 
where convert(varchar(10),startTime,120)='2013-01-22' and userID='0000000000' order by theTime


SELECT * from taskInfo 



--获取提醒任务和到期未完成任务列表：
select taskID, topic, taskManID, taskMan, taskStartTime, taskEndTime, summary, needSMSInvitation, needSMSRemind, taskRemindBefore, isOver
from taskInfo
where isOver = 0 and taskRemindTime< getdate() and closeRemind=0

select dateadd(minute,-15, getdate())
