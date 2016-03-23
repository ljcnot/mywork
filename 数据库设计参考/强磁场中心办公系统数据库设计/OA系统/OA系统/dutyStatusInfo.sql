use hustOA
/*
	强磁场中心办公系统-勤务状态管理
	author:		卢苇
	CreateDate:	2013-1-21
	UpdateDate: 
*/

--1.勤务状态登记表：
select * from dutyStatusInfo
select * from codeDictionary where classCode=200
delete dutyStatusInfo
drop table dutyStatusInfo
CREATE TABLE dutyStatusInfo(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL, --内部行号
	userID varchar(10) not null,		--工号
	userCName nvarchar(30) null,		--姓名:冗余设计
	
	dutyStatus int not null,			--勤务状态代码：使用第200号代码字典设定
	dutyStatusDesc nvarchar(60) null,	--勤务状态描述：冗余设计
	
	startTime smalldatetime not null,	--开始时间
	endTime smalldatetime null,			--结束时间
	
	remark nvarchar(300) null,			--事由说明
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_dutyStatusInfo] PRIMARY KEY CLUSTERED 
(
	[userID] ASC,
	[startTime] desc,
	[rowNum] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--勤务状态码索引：
CREATE NONCLUSTERED INDEX [IX_dutyStatusInfo] ON [dbo].[dutyStatusInfo] 
(
	[dutyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop FUNCTION getUserDutyStatus
/*
	name:		getUserDutyStatus
	function:	0.根据用户工号和时间获取用户最近的勤务状态
	input: 
				@userID varchar(10),		--用户工号
				@startTime varchar(19)		--查询开始时间:当天时间请使用到秒时间，其他时间使用到天时间
	output: 
				return xml					--状态秒速：
	author:		卢苇
	CreateDate:	2013-1-21
	UpdateDate: 
*/
create FUNCTION getUserDutyStatus
(  
	@userID varchar(10),		--用户工号
	@queryTime varchar(19)		--查询开始时间:当天时间请使用到秒时间，其他时间使用到天时间
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @theTime smalldatetime, @theNextDayTime smalldatetime
	set @theTime = convert(smalldatetime, @queryTime,120)
	set @theNextDayTime = dateadd(day,1,@theTime)
	
	declare @dutyStatusDesc nvarchar(60), @startTime smalldatetime, @endTime smalldatetime
	declare @remark nvarchar(300)
	select top 1 @dutyStatusDesc = dutyStatusDesc, @startTime = startTime,
		@endTime = endTime, @remark = remark
	from dutyStatusInfo 
	where userID = @userID and ((endTime between @theTime and @theNextDayTime) 
			or (startTime between @theTime and @theNextDayTime)
			or (@theTime between startTime and endTime))
	order by startTime
	
	declare @result xml
	if (@dutyStatusDesc is null)
	begin
		set @result = N'<root><dutyStatusDesc>在岗</dutyStatusDesc></root>'
	end
	else
	begin
		set @result = N'<root>'+
							'<dutyStatusDesc>'+@dutyStatusDesc+'</dutyStatusDesc>'+
							'<startTime>'+convert(varchar(19),@startTime,120)+'</startTime>'+
							'<endTime>'+convert(varchar(19),@endTime,120)+'</endTime>'+
							'<remark>'+@remark+'</remark>'+
						'</root>'
	end
	return @result
end
--测试：
select dbo.getUserDutyStatus('G201300040','2013-03-08 12:00:00')

drop PROCEDURE queryDutyStatusInfoLocMan
/*
	name:		queryDutyStatusInfoLocMan
	function:	1.查询指定勤务状态是否有人正在编辑
	input: 
				@rowNum int,			--内部行号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，9：查询出错，可能是指定的勤务状态不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE queryDutyStatusInfoLocMan
	@rowNum int,					--内部行号
	@Ret int output,				--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from dutyStatusInfo where rowNum= @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockDutyStatusInfo4Edit
/*
	name:		lockDutyStatusInfo4Edit
	function:	2.锁定勤务状态编辑，避免编辑冲突
	input: 
				@rowNum int,					--内部行号
				@lockManID varchar(10) output,	--锁定人，如果当前勤务状态正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的勤务状态不存在，2:要锁定的勤务状态正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE lockDutyStatusInfo4Edit
	@rowNum int,					--内部行号
	@lockManID varchar(10) output,	--锁定人，如果当前勤务状态正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的勤务状态是否存在
	declare @count as int
	set @count=(select count(*) from dutyStatusInfo where rowNum= @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from dutyStatusInfo where rowNum= @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update dutyStatusInfo
	set lockManID = @lockManID 
	where rowNum= @rowNum
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
	values(@lockManID, @lockManName, getdate(), '锁定勤务状态编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了勤务状态['+str(@rowNum,8) +']为独占式编辑。')
GO

drop PROCEDURE unlockDutyStatusInfoEditor
/*
	name:		unlockDutyStatusInfoEditor
	function:	3.释放勤务状态编辑锁
				注意：本过程不检查勤务状态是否存在！
	input: 
				@rowNum int,					--内部行号
				@lockManID varchar(10) output,	--锁定人，如果当前勤务状态正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE unlockDutyStatusInfoEditor
	@rowNum int,					--内部行号
	@lockManID varchar(10) output,	--锁定人，如果当前勤务状态呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from dutyStatusInfo where rowNum= @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update dutyStatusInfo set lockManID = '' where rowNum= @rowNum
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
	values(@lockManID, @lockManName, getdate(), '释放勤务状态编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了勤务状态['+ str(@rowNum,8) +']的编辑锁。')
GO
select *  from dutyStatusInfo
select * from codeDictionary where classCode=200
drop PROCEDURE addDutyStatusInfo
/*
	name:		addDutyStatusInfo
	function:	4.添加勤务状态信息
	input: 
				@userID varchar(10),		--填报状态用户工号
				@dutyStatus int,			--勤务状态代码：使用第200号代码字典设定
				@startTime varchar(19),		--开始时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
				@endTime varchar(19),		--结束时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
				@remark nvarchar(300),		--事由说明

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@rowNum int output			--内部行号
	author:		卢苇
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE addDutyStatusInfo
	@userID varchar(10),		--工号
	@dutyStatus int,			--勤务状态代码：使用第200号代码字典设定
	@startTime varchar(19),		--开始时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
	@endTime varchar(19),		--结束时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
	@remark nvarchar(300),		--事由说明

	@createManID varchar(10),	--创建人工号
	@Ret		int output,		--操作成功标识
	@createTime smalldatetime output,
	@rowNum int output			--内部行号
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取状态人/创建人的姓名：
	declare @userCName nvarchar(30), @createManName nvarchar(30)
	set @userCName = isnull((select cName from userInfo where jobNumber = @userID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	--取勤务状态描述：
	declare @dutyStatusDesc nvarchar(60)	--勤务状态描述：冗余设计
	set @dutyStatusDesc = isnull((select objDesc from codeDictionary where classCode =200 and objCode=@dutyStatus),'')
	
	set @createTime = getdate()
	insert dutyStatusInfo(userID, userCName, dutyStatus, dutyStatusDesc,
					startTime, endTime, remark,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@userID, @userCName, @dutyStatus, @dutyStatusDesc,
					@startTime, @endTime, @remark,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @rowNum = (select rowNum from dutyStatusInfo where userID=@userID and dutyStatus=@dutyStatus and convert(varchar(19),startTime,120)=@startTime)
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记勤务状态', '系统根据用户' + @createManName + 
					'的要求登记了勤务状态['+@dutyStatusDesc+']。')
GO
--测试:
declare	@Ret		int --操作成功标识
declare	@createTime smalldatetime 
declare	@rowNum int --内部行号
exec dbo.addDutyStatusInfo 'G20130001',2,'2013-01-23 12:00:00','2013-01-25 12:00:00','到上海参加展示会', '0000000000', 
	@Ret output, @createTime output, @rowNum output
select @Ret, @rowNum

select * from dutyStatusInfo

drop PROCEDURE updateDutyStatusInfo
/*
	name:		updateDutyStatusInfo
	function:	5.修改勤务状态信息
	input: 
				@rowNum int,				--内部行号
				@userID varchar(10),		--工号
				@dutyStatus int,			--勤务状态代码：使用第200号代码字典设定
				@startTime varchar(19),		--开始时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
				@endTime varchar(19),		--结束时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
				@remark nvarchar(300),		--事由说明

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的勤务状态不存在，
							2:要修改的勤务状态正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE updateDutyStatusInfo
	@rowNum int,				--内部行号
	@userID varchar(10),		--工号
	@dutyStatus int,			--勤务状态代码：使用第200号代码字典设定
	@startTime varchar(19),		--开始时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
	@endTime varchar(19),		--结束时间:采用“yyyy-MM-dd hh:mm:ss”格式传递
	@remark nvarchar(300),		--事由说明

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的勤务状态是否存在
	declare @count as int
	set @count=(select count(*) from dutyStatusInfo where rowNum= @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from dutyStatusInfo where rowNum= @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取状态人/创建人的姓名：
	declare @userCName nvarchar(30), @modiManName nvarchar(30)
	set @userCName = isnull((select cName from userInfo where jobNumber = @userID),'')
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	--取勤务状态描述：
	declare @dutyStatusDesc nvarchar(60)	--勤务状态描述：冗余设计
	set @dutyStatusDesc = isnull((select objDesc from codeDictionary where classCode =200 and objCode=@dutyStatus),'')

	set @modiTime = getdate()
	update dutyStatusInfo
	set userID = @userID, userCName = @userCName, dutyStatus = @dutyStatus, dutyStatusDesc = @dutyStatusDesc,
		startTime = @startTime, endTime = @endTime, remark = @remark,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where rowNum= @rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改勤务状态', '系统根据用户' + @modiManName + 
					'的要求修改了勤务状态行号为['+str(@rowNum,8)+']的勤务状态的登记信息。')
GO

drop PROCEDURE delDutyStatusInfo
/*
	name:		delDutyStatusInfo
	function:	6.删除指定的勤务状态
	input: 
				@rowNum int,					--内部行号
				@delManID varchar(10) output,	--删除人，如果当前勤务状态正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的勤务状态不存在，2：要删除的勤务状态正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2003-1-21
	UpdateDate: 

*/
create PROCEDURE delDutyStatusInfo
	@rowNum int,					--内部行号
	@delManID varchar(10) output,	--删除人，如果当前勤务状态正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要删除的勤务状态是否存在
	declare @count as int
	set @count=(select count(*) from dutyStatusInfo where rowNum= @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from dutyStatusInfo where rowNum= @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete dutyStatusInfo where rowNum= @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除勤务状态', '用户' + @delManName
												+ '删除了行号为['+str(@rowNum,8)+']的勤务状态。')

GO



--查询个人勤务状态：
select d.rowNum, d.userID, d.userCName, d.dutyStatus, d.dutyStatusDesc,
convert(varchar(19),d.startTime,120) startTime, convert(varchar(19),d.endTime,120) endTime, d.remark
from dutyStatusInfo d
where convert(varchar(19),d.startTime,120) >= '2013-01-21'

use hustOA
--查询团队勤务状态：
declare @theDay varchar(19)
set @theDay = '2013-01-22 14:27:26'
select jobNumber, cName, ucode, uName, workPos, dbo.getUserDutyStatus(jobNumber,@theDay) dutyStatus
from userInfo
