--账户表
drop table accountList
create table accountList(
accountID 	varchar(10) not null,	--账户ID
accountName	varchar(50)	not null,	--账户名称
bankAccount	varchar(100) not null,	--开户行
accountCompany	varchar(100)	not null,	--开户名
accountOpening	varchar(50)	not	null,	--开户账号
bankAccountNum	varchar(50)	not null,	--开户行号
accountDate	smalldatetime	not	null,	--开户时间
administratorID	varchar(10)	,	--管理人ID
administrator	varchar(30)	,		--管理人(姓名）
branchAddress	varchar(100),			--支行地址
remarks	varchar(200),	--备注
Obsolete		smallint  default(0) not null,	--是否作废,0:在用，1：作废
ObsoleteDate smalldatetime,		--作废日期
enabledeate	smalldatetime,	--启用日期

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
--主键
	 CONSTRAINT [PK_accountList] PRIMARY KEY CLUSTERED 
(
	accountID ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--账户移交表
drop table accountTransferList
create table accountTransferList(
accountTransferID varchar(15)	not null,	--账户移交ID
handoverDate	smalldatetime	not null,	--移交日期
transferAccountID	varchar(10)	not	null,	--移交账户ID
transferAccount		varchar(50)	not null,	--移交账户
transferPersonID	varchar(10)	not null,	--移交人ID
transferPerson	varchar(30)	not null,	--移交人
handoverPersonID	varchar(10)	not	null,	--交接人ID
handoverPerson	varchar(30)	not	null,	--交接人
transferMatters	varchar(200),				--移交事项
remarks		varchar(200),	--备注
TransferConfirmation smallint default(0) not null,	--移交确认，0：未确认，1：确认

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
foreign key(transferAccountID) references accountList(accountID) on update cascade on delete cascade,
--主键
	 CONSTRAINT [PK_accountTransferID] PRIMARY KEY CLUSTERED 
(
	[accountTransferID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--添加账户
drop PROCEDURE addAccountList
/*
	name:		addAccountList
	function:	1.添加账户
				注意：本存储过程不锁定编辑！
	input: 
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(10),	--管理人ID
				@administrator	varchar(30),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注
				@Obsolete		smallint ,		--是否作废,0:在用，1：作废
				@enabledeate	smalldatetime,	--启用日期

				@createManID varchar(10),		--创建人工号
	output: 
				@accountID 	varchar(10) output,		--账户ID,主键,使用409号号码发生器生成
				@Ret		int output		--操作成功标识
							0:成功，1：该账户已存在，9：未知错误
				
	author:		卢嘉诚
	CreateDate:	2016-3-23

*/

create PROCEDURE addAccountList			
				@accountID 	varchar(10) output,		--账户ID,主键,使用409号号码发生器生成
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(10),	--管理人ID
				@administrator	varchar(30),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注
				@Obsolete		smallint ,		--是否作废,0:在用，1：作废
				@enabledeate	smalldatetime,	--启用日期

				@createManID varchar(10),		--创建人工号

				@Ret		int output			--操作成功标示；0:成功，1：该账户已存在，9：未知错误

	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 409, 1, @curNumber output
	set @accountID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	insert accountList(
				accountID,		--账户ID,主键,使用409号号码发生器生成
				accountName,		--账户名称
				bankAccount,		--开户行
				accountCompany,	--开户名
				accountOpening,	--开户账号
				bankAccountNum,	--开户行号
				accountDate,		--开户时间
				administratorID,	--管理人ID
				administrator,	--管理人(姓名）
				branchAddress,	--支行地址
				remarks,			--备注
				createManID,		--创建人工号
				createManName,	--创建人姓名
				createTime,		--创建时间
				Obsolete,			--是否作废
				enabledeate		--启用日期
							) 
	values (		
				@accountID,		--账户ID,主键,使用409号号码发生器生成
				@accountName,		--账户名称
				@bankAccount,		--开户行
				@accountCompany,	--开户名
				@accountOpening,	--开户账号
				@bankAccountNum,	--开户行号
				@accountDate,		--开户时间
				@administratorID,	--管理人ID
				@administrator,	--管理人(姓名）
				@branchAddress,	--支行地址
				@remarks,			--备注
				@createManID,		--创建人工号
				@createManName,	--创建人姓名
				@createTime,		--创建时间
				@Obsolete,		--是否作废
				@enabledeate		--启用日期
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加账户', '系统根据用户' + @createManName + 
		'的要求添加了账户[' + @accountID + ']。')		
GO


--删除账户
drop PROCEDURE delAccountList
/*
	name:		delAccountList
	function:		1.删除账户
				注意：本存储过程锁定编辑！
	input: 
				@accountID 	varchar(10) output,		--账户ID,主键,使用409号号码发生器生成
				@lockManID varchar(10),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标示；0:成功，1：该账户不存在，2：该账户被其他用户锁定，3:请先锁定该账户在删除避免冲突，9：未知错误

	author:		卢嘉诚
	CreateDate:	2016-5-13
*/

create PROCEDURE delAccountList			
				@accountID 	varchar(10) ,		--账户ID,主键
				@lockManID   varchar(10) output,		--锁定人ID

				@Ret		int output			--操作成功标示；0:成功，1：该账户不存在，2：该账户被其他用户锁定，3:请先锁定该账户在删除避免冲突，9：未知错误

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--判断要删除的账户是否存在
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from accountList
					where accountID = @accountID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		if(@thisLockMan<>@lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
		else
			begin
				--取维护人的姓名：
				declare @lockMan nvarchar(30)
				set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
				declare @createTime smalldatetime
				set @createTime = getdate()

				delete from accountList where accountID = @accountID

				if @@ERROR <> 0 
					begin
						set @Ret = 9
						return
					end
				set @Ret = 0
				--登记工作日志：
				insert workNote(userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockMan, @createTime, '删除账户', '系统根据用户' + @lockMan + 
					'的要求删除了账户[' + @accountID + ']。')	
			end
	end
	else
		begin
			set @Ret = 3
			return
		end
GO




--编辑账户
drop PROCEDURE editAccountList
/*
	name:		editAccountList
	function:	1.编辑账户
				注意：本存储过程锁定编辑！
	input: 
				@accountID 	varchar(10),		--账户ID,主键,使用409号号码发生器生成
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(10),	--管理人ID
				@administrator	varchar(30),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注

	output: 
				@lockManID varchar(10)output,		--锁定人ID
				@Ret		int output		--操作成功标示；0:成功，1：该账户不存在，2：该账户已被其他用户锁定，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-3-23
	
*/

create PROCEDURE editAccountList			
				@accountID 	varchar(10),		--账户ID,主键,使用409号号码发生器生成
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(10),	--管理人ID
				@administrator	varchar(30),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注

				@lockManID varchar(10) output,		--锁定人ID
				@Ret		int output			--操作成功标示；0:成功，1：该账户不存在，2：该账户已被其他用户锁定，9：未知错误

	WITH ENCRYPTION 
AS
	--判断要编辑的账户是否存在
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = (select lockManID from accountList
					where accountID = @accountID
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

	update accountList set
				accountName = @accountName,			--账户名称
				bankAccount = @bankAccount,			--开户行
				accountCompany = @accountCompany,	--开户名
				accountOpening = @accountOpening,	--开户账号
				bankAccountNum = @bankAccountNum,	--开户行号
				accountDate    = @accountDate,		--开户时间
				administratorID = @administratorID,	--管理人ID
				administrator  = @administrator,		--管理人(姓名）
				branchAddress  = @branchAddress,		--支行地址
				remarks =	@remarks,				--备注
				modiManID = @lockManID,			--修改人工号
				modiManName = @createManName,		--修改人姓名
				modiTime	= @createTime				--修改时间
				where	accountID = @accountID		--账户ID,主键,使用409号号码发生器生成


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
	values(@lockManID, @createManName, @createTime, '编辑账户', '系统根据用户' + @createManName + 
		'的要求编辑了账户[' + @accountID + ']。')		
GO


drop PROCEDURE lockAccountEdit
/*
	name:		lockAccountEdit
	function: 	锁定账户编辑，避免编辑冲突
	input: 
				@accountID varchar(10),		--账户ID

	output: 
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret		int output		--操作成功标识0:成功，1：要锁定的账户不存在，2:要锁定的账户正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountEdit
				@accountID varchar(10),		--账户ID
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要锁定的账户不存在，2:要锁定的账户正在被别人编辑，9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户是否存在
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from accountList
					where accountID = @accountID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update accountList
	set lockManID = @lockManID 
	where accountID= @accountID

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
	values(@lockManID, @lockManName, getdate(), '锁定账户编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了账户['+ @accountID +']为独占式编辑。')
GO


drop PROCEDURE unlockAccountEdit
/*
	name:		unlockAccountEdit
	function: 	释放锁定账户编辑，避免编辑冲突
	input: 
				@accountID varchar(10),			--账户ID
				
	output: 
				@lockManID varchar(10) output,	--锁定人ID，如果当前账户正在被人占用编辑则返回该人的工号
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的账户不存在，2:要释放锁定的账户正在被别人编辑，8：该账户未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	
*/
create PROCEDURE unlockAccountEdit
				@accountID varchar(10),			--账户ID
				@lockManID varchar(10) output,	--锁定人ID，如果当前账户正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识0:成功，1：要释放锁定的账户不存在，2:要释放锁定的账户正在被别人编辑，8：该账户未被任何人锁定9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountList where accountID= @accountID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--释放报销单锁定
			update accountList set lockManID = '' where accountID = @accountID
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
				values(@lockManID, @lockManName, getdate(), '释放账户编辑', '系统根据用户' + @lockManName	+ '的要求释放了账户['+ @accountID +']的编辑锁。')
		end
	else   --返回该借支单未被任何人锁定
		begin
			set @Ret = 8
			return
		end
GO



drop PROCEDURE accountTransfer
/*
	name:		accountTransfer
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 

				@handoverDate	smalldatetime,	--移交日期
				@transferAccountID	varchar(10),	--移交账户ID
				@transferAccount	varchar(50),	--移交账户
				@transferPersonID	varchar(10),	--移交人ID
				@transferPerson	varchar(30),	--移交人
				@handoverPersonID	varchar(10),	--交接人ID
				@handoverPerson	varchar(30),	--交接人
				@transferMatters	varchar(200),	--移交事项
				@remarks		varchar(200),	--备注
				@TransferConfirmation smallint ,	--移交确认，0：未确认，1：确认
				
	output: 
				@accountTransferID varchar(15) output,	--账户移交ID,主键，使用410号号码发生器生成
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要移交的的账户不存在，2:要移交的的账户正在被别人锁定，3:该账户未锁定，请先锁定账户9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16

*/
create PROCEDURE accountTransfer
				@accountTransferID varchar(15) output,	--账户移交ID,主键，使用410号号码发生器生成
				@handoverDate	smalldatetime,	--移交日期
				@transferAccountID	varchar(10),	--移交账户ID
				@transferAccount	varchar(50),	--移交账户
				@transferPersonID	varchar(10),	--移交人ID
				@transferPerson	varchar(30),	--移交人
				@handoverPersonID	varchar(10),	--交接人ID
				@handoverPerson	varchar(30),	--交接人
				@transferMatters	varchar(200),	--移交事项
				@remarks		varchar(200),	--备注
				@TransferConfirmation smallint ,	--移交确认，0：未确认，1：确认

				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要移交的的账户不存在，2:要移交的的账户正在被别人锁定，3:该账户未锁定，请先锁定账户9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户是否存在
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @transferAccountID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = (select lockManID from accountList
					where accountID = @transferAccountID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
				--使用号码发生器产生新的号码：
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 410, 1, @curNumber output
			set @accountTransferID = @curNumber
			insert accountTransferList (
									accountTransferID,	--账户移交ID,主键，使用410号号码发生器生成
									handoverDate	,	--移交日期
									transferAccountID,	--移交账户ID
									transferAccount,	--移交账户
									transferPersonID,	--移交人ID
									transferPerson,	--移交人
									handoverPersonID,	--交接人ID
									handoverPerson,	--交接人
									transferMatters,	--移交事项
									remarks,			--备注
									TransferConfirmation	--移交确认，0：未确认，1：确认
									)
						values     (
									@accountTransferID,	--账户移交ID,主键，使用410号号码发生器生成
									@handoverDate	,	--移交日期
									@transferAccountID,--移交账户ID
									@transferAccount,	--移交账户
									@transferPersonID,	--移交人ID
									@transferPerson,	--移交人
									@handoverPersonID,	--交接人ID
									@handoverPerson,	--交接人
									@transferMatters,	--移交事项
									@remarks,			--备注
									@TransferConfirmation
									)
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
				values(@lockManID, @lockManName, getdate(), '移交账户', '系统根据用户' + @lockManName	+ '的要求移交了账户，移交详情为['+ @accountTransferID +']。')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO


--账户移交确认
drop PROCEDURE TransferAccountConfirmation
/*
	name:		TransferAccountConfirmation
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 
				@accountTransferID		--账户移交ID

				
	output: 
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：该次账户移交不存在，2:确认人并非交接人9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16

*/
create PROCEDURE TransferAccountConfirmation
				@accountTransferID varchar(15) ,	--账户移交ID,主键，使用410号号码发生器生成
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：该次账户移交不存在，2:确认人并非交接人9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户移交是否存在
	declare @count as int
	set @count=(select count(*) from accountTransferList where accountTransferID= @accountTransferID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	declare 		@transferAccountID	varchar(10),	--移交账户ID
				@handoverPersonID	varchar(10),	--交接人ID
				@handoverPerson	varchar(30)	--交接人

	select @transferAccountID = transferAccountID,@handoverPersonID = handoverPersonID,@handoverPerson = handoverPerson 
							from accountTransferList
							where accountTransferID = @accountTransferID
	--检查确认人是否是移交人
	if(@lockManID <> @handoverPersonID)
		begin
			set @Ret = 2
			return
		end
begin tran
	update accountList set administratorID = @handoverPersonID,
						administrator = @handoverPerson
						where accountID = @transferAccountID
	update accountTransferList set TransferConfirmation = '0' where accountTransferID = @accountTransferID
	set @Ret = 0

	if @@ERROR <>0
	begin
		rollback tran
		set @Ret = 9
		return
	end
commit tran
		----取维护人的姓名：
		declare @lockManName nvarchar(30)
		set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
		--登记工作日志：
		insert workNote (userID, userName, actionTime, actions, actionObject)
		values(@lockManID, @lockManName, getdate(), '确认交接账户', '系统根据用户' + @lockManName	+ '的要求确认交接了账户['+ @transferAccountID +']。')

	
GO