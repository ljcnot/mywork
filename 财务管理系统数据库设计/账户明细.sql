--账户明细表
drop table accountDetailsList 
create table accountDetailsList(
AccountDetailsID varchar(14) not null,	--交易ID
accountID varchar(10) not null,			--账户ID
account varchar(50) not null,			--账户名称
detailDate smalldatetime not null		,--日期
abstract	varchar(200),		--摘要
borrow numeric(15,2),		--借
loan	 numeric(15,2),		--贷
balance numeric(15,2),		--余额
departmentID	varchar(13),	--部门ID
department varchar(30),	--部门
projectID	 varchar(13),		--项目ID
project varchar(50),		--项目
clerkID varchar(10),		--经手人ID
clerk varchar(30),			--经手人
remarks varchar(200),		--备注
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
--外键
foreign key(accountID) references accountList(accountID) on update cascade on delete cascade,
--主键
	 CONSTRAINT [PK_AccountDetailsID] PRIMARY KEY CLUSTERED 
(
	[AccountDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--添加账户明细
drop PROCEDURE addAccountDetails
/*
	name:		addAccountDetails
	function:	1.添加账户明细
				注意：本存储过程不锁定编辑！
	input: 
				@accountID 	varchar(10)	not null,	--账户ID
				@account		varchar(50)	not	null,	--账户名称
				@detailDate	smalldatetime	not null,	--日期
				@abstract	varchar(200),	--摘要
				@borrow		numeric(15,2),		--借
				@loan		numeric(15,2),		--贷
				@balance		numeric(15,2),		--余额
				@departmentID	varchar(13),	--部门ID
				@department		varchar(30),	--部门
				@projectID		varchar(13),	--项目ID
				@project			varchar(50),	--项目
				@clerkID		varchar(10),		--经手人ID
				@clerk		varchar(30),		--经手人
				@remarks		varchar(200),		--备注

				@createManID varchar(10),		--创建人工号
	output: 
				@AccountDetailsID	varchar(14) output,	--交易ID，主键，使用408号号码发生器生成
				@Ret		int output		--操作成功标示；0:成功，1：该账户已存在，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-3-23
*/

create PROCEDURE addAccountDetails			
				@AccountDetailsID	varchar(14) output,	--交易ID，主键，使用408号号码发生器生成
				@accountID 	varchar(10),	--账户ID
				@account		varchar(50),--账户名称
				@detailDate	smalldatetime,	--日期
				@abstract	varchar(200),	--摘要
				@borrow		numeric(15,2),			--借
				@loan		numeric(15,2),			--贷
				@balance	numeric(15,2),			--余额
				@departmentID	varchar(13),--部门ID
				@department	varchar(30),	--部门
				@projectID	varchar(13),	--项目ID
				@project	varchar(50),	--项目
				@clerkID	varchar(10),	--经手人ID
				@clerk		varchar(30),	--经手人
				@remarks	varchar(200),	--备注

				@createManID varchar(10),		--创建人工号

				@Ret		int output			--操作成功标示；0:成功，1：该账户已存在，9：未知错误

	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 408, 1, @curNumber output
	set @AccountDetailsID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	insert accountDetailsList(
				AccountDetailsID,	--交易ID，主键，使用408号号码发生器生成
				accountID,		--账户ID
				account,			--账户名称
				detailDate,		--日期
				abstract,			--摘要
				borrow,			--借
				loan	,			--贷
				balance,			--余额
				departmentID,		--部门ID
				department,		--部门
				projectID,		--项目ID
				project,			--项目
				clerkID,			--经手人ID
				clerk,			--经手人
				remarks,			--备注
				createManID,		--创建人工号
				createManName,	--创建人姓名
				createTime		--创建时间
							) 
	values (		
				@AccountDetailsID,	--交易ID，主键，使用408号号码发生器生成
				@accountID,		--账户ID
				@account,			--账户名称
				@detailDate,		--日期
				@abstract,		--摘要
				@borrow,			--借
				@loan	,		--贷
				@balance,			--余额
				@departmentID,	--部门ID
				@department,		--部门
				@projectID,		--项目ID
				@project,			--项目
				@clerkID,			--经手人ID
				@clerk,			--经手人
				@remarks,			--备注
				@createManID,		--创建人工号
				@createManName,	--创建人姓名
				@createTime		--创建时间
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加账户明细', '系统根据用户' + @createManName + 
		'的要求添加了账户明细[' + @AccountDetailsID + ']。')		
GO



--删除账户明细
drop PROCEDURE delAccountDetails
/*
	name:		delAccountList
	function:		1.删除账户明细
				注意：本存储过程锁定编辑！
	input: 
				@AccountDetailsID	varchar(14) output,	--交易ID，主键，使用408号号码发生器生成
				@lockManID varchar(10),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细被其他用户锁定，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE delAccountDetails		
				@AccountDetailsID	varchar(14),	--交易ID，主键
				@lockManID   varchar(10) output,		--锁定人ID

				@Ret		int output			--操作成功标识;--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细被其他用户锁定，9：未知错误

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--判断要删除的账户明细是否存在
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from accountDetailsList
					where AccountDetailsID = @AccountDetailsID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		if(@thisLockMan<>@lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 2
			return
		end
	end

	--取维护人的姓名：
	declare @lockMan nvarchar(30)
	set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	delete from accountDetailsList where AccountDetailsID = @AccountDetailsID

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
	values(@lockManID, @lockMan, @createTime, '删除账户明细', '系统根据用户' + @lockMan + 
		'的要求删除了账户明细[' + @AccountDetailsID + ']。')		
GO


--编辑账户明细
drop PROCEDURE editAccountDetails	
/*
	name:		editAccountDetails	
	function:	1.编辑账户明细
				注意：本存储过程锁定编辑！
	input: 
				@AccountDetailsID	varchar(14) output,	--交易ID，主键，使用408号号码发生器生成
				@accountID 	varchar(10),	--账户ID
				@account		varchar(50),--账户名称
				@detailDate	smalldatetime,	--日期
				@abstract	varchar(200),	--摘要
				@borrow		numeric(15,2),			--借
				@loan		numeric(15,2),			--贷
				@balance	numeric(15,2),			--余额
				@departmentID	varchar(13),--部门ID
				@department	varchar(30),	--部门
				@projectID	varchar(13),	--项目ID
				@project	varchar(50),	--项目
				@clerkID	varchar(10),	--经手人ID
				@clerk		varchar(30),	--经手人
				@remarks	varchar(200),	--备注

				@lockManID varchar(10)output,		--锁定人ID
	output: 
				@Ret		int output		--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细已被其他用户锁定，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-3-23

*/


select count(*) from accountDetailsList where AccountDetailsID= 'ZHMX201605050002'
create PROCEDURE editAccountDetails				
				@AccountDetailsID	varchar(14) ,	--交易ID，主键
				@accountID 	varchar(10),	--账户ID
				@account		varchar(50),--账户名称
				@detailDate	smalldatetime,	--日期
				@abstract	varchar(200),	--摘要
				@borrow		numeric(15,2),			--借
				@loan		numeric(15,2),			--贷
				@balance	numeric(15,2),			--余额
				@departmentID	varchar(13),--部门ID
				@department	varchar(30),	--部门
				@projectID	varchar(13),	--项目ID
				@project	varchar(50),	--项目
				@clerkID	varchar(10),	--经手人ID
				@clerk		varchar(30),	--经手人
				@remarks	varchar(200),	--备注

				@lockManID varchar(10) output,		--锁定人ID

				@Ret		int output			--操作成功标示；0:成功，1：该账户明细不存在，2：该账户已被其他用户锁定，9：未知错误

	WITH ENCRYPTION 
AS
	--判断要编辑的账户是否存在
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from accountDetailsList
					where AccountDetailsID = @AccountDetailsID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		if(@thisLockMan<>@lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 2
			return
		end
	end


	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	update accountDetailsList set
				accountID = @accountID,		--账户ID
				account = @account,			--账户名称
				detailDate = @detailDate,		--日期
				abstract = @abstract,			--摘要
				borrow = @borrow,			--借
				loan	 = @loan	,			--贷
				balance = @balance,			--余额
				departmentID = @departmentID,		--部门ID
				department = @department,		--部门
				projectID = @projectID,		--项目ID
				project = @project,			--项目
				clerkID = @clerkID,			--经手人ID
				clerk = @clerk,			--经手人
				remarks = @remarks,			--备注
				modiManID = @lockManID,		--创建人工号
				modiManName = @createManName,	--创建人姓名
				modiTime = @createTime	--创建时间
				where	AccountDetailsID = @AccountDetailsID		--账户ID,主键


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName, @createTime, '编辑交易明细', '系统根据用户' + @createManName + 
		'的要求编辑了交易明细[' + @AccountDetailsID + ']。')		
GO


drop PROCEDURE lockAccountDetailsEdit
/*
	name:		lockAccountDetailsEdit
	function: 	锁定账户明细编辑，避免编辑冲突
	input: 
				@AccountDetailsID varchar(14),		--账户ID
				@lockManID varchar(10) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要锁定的账户明细不存在，2:要锁定的账户明细正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountDetailsEdit
				@AccountDetailsID varchar(14),		--账户ID
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要锁定的账户明细不存在，2:要锁定的账户明细正在被别人编辑，9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户是否存在
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from accountDetailsList
					where AccountDetailsID = @AccountDetailsID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update accountDetailsList
	set lockManID = @lockManID 
	where AccountDetailsID= @AccountDetailsID

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
	values(@lockManID, @lockManName, getdate(), '锁定账户明细编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了账户明细['+ @AccountDetailsID +']为独占式编辑。')
GO


drop PROCEDURE unlockAccountDetailsEdit
/*
	name:		lockAccountDetailsEdit
	function: 	释放锁定账户明细编辑，避免编辑冲突
	input: 
				@AccountDetailsID varchar(14),		--交易ID
				@lockManID varchar(10) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的账户明细不存在，2:要释放锁定的账户明细正在被别人编辑，8：该账户明细未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockAccountDetailsEdit
				@AccountDetailsID varchar(14),			--交易ID
				@lockManID varchar(10) output,	--锁定人ID，如果当前账户正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识0:成功，1：要释放锁定的账户明细不存在，2:要释放锁定的账户明细正在被别人编辑，8：该账户明细未被任何人锁定9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountDetailsList where AccountDetailsID= @AccountDetailsID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--释放报销单锁定
			update accountDetailsList set lockManID = '' where AccountDetailsID = @AccountDetailsID
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
				values(@lockManID, @lockManName, getdate(), '释放账户明细编辑', '系统根据用户' + @lockManName	+ '的要求释放了账户明细['+ @AccountDetailsID +']的编辑锁。')
		end
	else   --返回该账户明细未被任何人锁定
		begin
			set @Ret = 8
			return
		end
GO