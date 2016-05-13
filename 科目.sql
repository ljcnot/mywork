--科目管理表
drop table subjectList 
create table subjectList(
FinancialSubjectID	varchar(8)	not	null,	--科目ID
superiorSubjectsID	varchar(8),	--上级科目ID
superiorSubjects varchar(30),	--上级科目名称
subjectName	varchar(30)	not null,	--科目名称
AccountNumber int not null,	--科目层数(表明该科目在科目树的层数)
establishTime smalldatetime	not null,	--设立时间
explain varchar(200)	null,	--说明

--创建人：为了保持操作的范围——个人的一致性增加的字段
createManID varchar(10) null,		--创建人工号
createManName varchar(30) null,		--创建人姓名
createTime smalldatetime null,		--创建时间

--最新维护情况:
modiManID varchar(10) null,			--维护人工号
modiManName nvarchar(30) null,		--维护人姓名
modiTime smalldatetime null,		--最后维护时间

--编辑锁定人：
lockManID varchar(10)				--当前正在锁定编辑的人工号
	 CONSTRAINT [PK_subjectList] PRIMARY KEY CLUSTERED 
(
	[FinancialSubjectID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



--添加科目
drop PROCEDURE addSubject
/*
	name:		addSubject
	function:	1.添加科目
				注意：本存储过程不锁定编辑！
	input: 
				@FinancialSubjectID	varchar(8),	--科目ID,主键
				@superiorSubjectsID	varchar(8),	--上级科目ID
				@superiorSubjects varchar(30),		--上级科目名称
				@subjectName	varchar(30),			--科目名称
				@AccountNumber int ,				--科目层数
				@establishTime smalldatetime,		--设立时间
				@explain	varchar(200),				--说明

				@createManID varchar(10),			--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23

*/

create PROCEDURE addSubject			
				@FinancialSubjectID	varchar(8),	--科目ID,主键
				@superiorSubjectsID	varchar(8),	--上级科目ID
				@superiorSubjects varchar(30),		--上级科目名称
				@subjectName	varchar(30),			--科目名称
				@AccountNumber int ,				--科目层数
				@establishTime smalldatetime,		--设立时间
				@explain	varchar(200),				--说明

				@createManID varchar(10),			--创建人工号

				@Ret		int output,
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()

	insert subjectList(
				FinancialSubjectID,	--科目ID,主键
				superiorSubjectsID,	--上级科目ID
				superiorSubjects,		--上级科目名称
				subjectName,			--科目名称
				AccountNumber,		--科目层数
				establishTime,		--设立时间
				explain,				--说明
				createManID,			--创建人工号
				createTime			--创建时间
							) 
	values (		
				@FinancialSubjectID,	--科目ID,主键
				@superiorSubjectsID,	--上级科目ID
				@superiorSubjects,		--上级科目名称
				@subjectName,			--科目名称
				@AccountNumber,		--科目层数
				@establishTime,		--设立时间
				@explain,				--说明
				@createManID,			--创建人工号
				@createTime			--创建时间
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--插入明细表：
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加科目', '系统根据用户' + @createManName + 
		'的要求添加了科目[' + @FinancialSubjectID + ']。')		
GO


--编辑科目
drop PROCEDURE editSubject
/*
	name:		editSubject
	function:	1.编辑科目
				注意：本存储过程锁定编辑！
	input: 
				@FinancialSubjectID	varchar(8),	--科目ID
				@subjectName	varchar(30),		--科目名称
				@explain varchar(200),				--说明


	output: 
				@lockManID varchar(10) output,		--锁定人工号
				@Ret		int output,			--操作成功标识,0:成功，1：该科目已被其他人用户锁定，3：该科目不存在，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23

*/

create PROCEDURE editSubject			
				@FinancialSubjectID	varchar(8),	--科目ID
				@subjectName	varchar(30),		--科目名称
				@explain varchar(200),				--说明

				@lockManID varchar(10) output,				--锁定人工号
				@Ret		int output,			--操作成功标识,0:成功，1：该科目已被其他人用户锁定，3：该科目不存在，9：未知错误
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS
	--判断要锁定的科目是否存在是否存在
	declare @count as int
	set @count=(select count(*) from subjectList where FinancialSubjectID = @FinancialSubjectID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 3
		return
	end

	--检查编辑的科目是否有编辑锁或长事务锁：
	declare @thislockMan varchar(10)
	set @thislockMan = (select lockManID from subjectList
					where FinancialSubjectID = @FinancialSubjectID)
						
	if (@thislockMan<>'')
		if(@thislockMan<>@lockManID)
		begin
			set @Ret = 1
			set @lockManID = @thislockMan
			return
		end
			

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @createTime = getdate()

	update subjectList set 
				subjectName = @subjectName,			--科目名称
				explain = @explain				--说明
				 where FinancialSubjectID = @FinancialSubjectID


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--插入明细表：
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName, @createTime, '编辑科目', '系统根据用户' + @createManName + 
		'的要求编辑了科目[' + @FinancialSubjectID + ']。')		
GO


drop PROCEDURE lockSubjectEdit
/*
	name:		lockSubjectEdit
	function:	锁定科目编辑，避免编辑冲突
	input: 
				@FinancialSubjectID varchar(8),			--科目ID
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				
	output: 
				@Ret int output					--操作成功标识	0:成功，1：要锁定的科目不存在，2:要锁定的科目正在被别人编辑，9：未知错误
							0:成功，
							1：要锁定的科目不存在，
							2:要锁定的科目正在被别人编辑，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16

*/
create PROCEDURE lockSubjectEdit
				@FinancialSubjectID varchar(8),			--科目ID
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret int output					--操作成功标识	0:成功，1：要锁定的科目不存在，2:要锁定的科目正在被别人编辑，9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的科目是否存在
	declare @count as int
	set @count=(select count(*) from subjectList where FinancialSubjectID= @FinancialSubjectID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = (select lockManID from subjectList
					where FinancialSubjectID = @FinancialSubjectID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update subjectList
	set lockManID = @lockManID 
	where FinancialSubjectID= @FinancialSubjectID

	set @Ret = 0

	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	


	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定科目编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了科目['+ @FinancialSubjectID +']为独占式编辑。')
GO


drop PROCEDURE unlockSubjectEdit
/*
	name:		unlockSubjectEdit
	function:	释放科目编辑锁定，避免编辑冲突
	input: 
				@FinancialSubjectID varchar(8),			--科目ID
				@lockManID varchar(10) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的科目不存在，2:要释放锁定的科目正在被别人编辑，8：该科目未被任何人锁定，9：未知错误
							
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockSubjectEdit
				@FinancialSubjectID varchar(8),			--科目ID
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的科目不存在，2:要释放锁定的科目正在被别人编辑，8：该科目未被任何人锁定，9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from subjectList where FinancialSubjectID= @FinancialSubjectID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = isnull((select lockManID from subjectList where FinancialSubjectID= @FinancialSubjectID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--释放报销单锁定
			update subjectList set lockManID = '' where FinancialSubjectID = @FinancialSubjectID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end
				----取维护人的姓名：
				declare @lockManName nvarchar(30)
				set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				--登记工作日志：
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '释放科目编辑', '系统根据用户' + @lockManName	+ '的要求释放了科目['+ @FinancialSubjectID +']的编辑锁。')
		end
	else   --返回该借支单未被任何人锁定
		begin
			set @Ret = 8
			return
		end

GO