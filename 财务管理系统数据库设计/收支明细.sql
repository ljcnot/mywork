--收入一览表
drop table incomeList
create table incomeList(
incomeInformationID varchar(16)	not null,--收入记录号
projectID	 varchar(13)	not null,		--项目ID
project varchar(50)	not null,		--项目名称
customerID varchar(13)	not null,		--委托单位ID，由客户管理系统维护
customerName varchar(30)	not null,	--客户名称
abstract	varchar(200)	not null,		--摘要
incomeSum	numeric(15,2) not null,		--收入金额
remarks	varchar(200),					--备注
collectionModeID varchar(10) not null,	--收款方式ID
collectionMode varchar(50)	not null,	--收款账号
startDate	 smalldatetime	not null,	--收款日期
paymentApplicantID varchar(10)not null,	--收款申请人ID
payee varchar(30)	not null,			--收款人
ActualArrivalTime smalldatetime  ,		--实际到账时间
confirmationDate smalldatetime	,		--确认日期
confirmationPersonID	varchar(10),		--确认人ID
confirmationPerson		varchar(30),		--确认人
confirmationStatus	smallint default(0) not null, --确认状态，0：未确认，1：已确认
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
foreign key(collectionModeID) references accountList(accountID) on update cascade on delete cascade,
--主键
	 CONSTRAINT [PK_incomeInformationID] PRIMARY KEY CLUSTERED 
(
	[incomeInformationID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


drop PROCEDURE addIncome
/*
	name:		addIncome
	function: 	该存储过程不锁定编辑
	input: 

				@projectID	varchar(13),	--项目ID
				@project		varchar(50),		--项目名称
				@customerID	varchar(13),			--客户ID
				@customerName	varchar(30),		--客户名称
				@abstract	varchar(200),			--摘要
				@incomeSum	numeric(15,2),			--收入金额
				@remarks	varchar(200),			--备注
				@collectionModeID	varchar(10),	--收款方式ID
				@collectionMode		varchar(50),	--收款账号
				@startDate	smalldatetime,			--收款日期
				@paymentApplicantID	varchar(10),	--收款申请人ID
				@payee	varchar(30),				--收款人
				@createManID varchar(10),	--创建人

				
	output: 
				@incomeInformationID varchar(16)	output,	--收入记录号，主键，使用411号号码发生器生成
				@Ret int output				--操作成功标识0:成功，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	
*/
create PROCEDURE addIncome
				@incomeInformationID varchar(16) output,		--收入记录号，主键，使用411号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),		--项目名称
				@customerID	varchar(13),			--客户ID
				@customerName	varchar(30),		--客户名称
				@abstract		varchar(200),			--摘要
				@incomeSum	numeric(15,2),			--收入金额
				@remarks		varchar(200),			--备注
				@collectionModeID	varchar(10),	--收款方式ID
				@collectionMode	varchar(50),	--收款账号
				@startDate		smalldatetime,			--收款日期
				@paymentApplicantID	varchar(10),	--收款申请人ID
				@payee			varchar(30),				--收款人
				@createManID		varchar(10),	--创建人
				@Ret int output				--操作成功标识0:成功，9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 411, 1, @curNumber output
	set @incomeInformationID = @curNumber

	----取维护人的姓名：
	declare @createManName nvarchar(30),@createTime smalldatetime
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()
	insert incomeList (
						incomeInformationID,	--收入信息ID，主键，使用411号号码发生器生成
						projectID,	--项目ID
						project,	--项目名称
						customerID,	--客户ID
						customerName,	--客户名称
						abstract	,	--摘要
						incomeSum,	--收入金额
						remarks,	--备注
						collectionModeID,	--收款方式ID
						collectionMode,	--收款账户
						startDate,	--收款日期
						paymentApplicantID,	--收款申请人ID
						payee,	--收款人
						createManID,	--创建人ID
						createManName,	--创建人
						createTime		--创建时间
									)
						values     (
						@incomeInformationID,	--收入信息ID，主键，使用411号号码发生器生成
						@projectID,	--项目ID
						@project,	--项目名称
						@customerID,	--客户ID
						@customerName,	--客户名称
						@abstract	,	--摘要
						@incomeSum,	--收入金额
						@remarks,	--备注
						@collectionModeID,	--收款方式ID
						@collectionMode,	--收款账户
						@startDate,	--收款日期
						@paymentApplicantID,	--收款申请人ID
						@payee,	--收款人
						@createManID,	--创建人ID
						@createManName,	--创建人
						@createTime		--创建时间
									)
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--登记工作日志：
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@createManID, @createManName, getdate(), '添加收入记录', '系统根据用户' + @createManName	+ '的要求添加了收入记录['+ @incomeInformationID +']。')
GO

--确认指定收入记录
drop PROCEDURE confirmIncome
/*				确认指定收入记录
	name:		confirmIncome
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 
				@incomeInformationID varchar(16)	,	--收入信息ID，主键
				@ActualArrivalTime   smalldatetime  ,	--实际到账时间
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(10),	--确认人ID
				@confirmationPerson		varchar(30),	--确认人

				
	output: 
				@lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret		int output		--操作成功标识0:成功，1：要确认的收入记录不存在，2:要确认的收入记录正在被别人锁定，3:该收入记录未锁定，请先锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	
*/
create PROCEDURE confirmIncome
				@incomeInformationID varchar(16)	,	--收入信息ID，主键
				@ActualArrivalTime   smalldatetime  ,	--实际到账时间
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(10),	--确认人ID
				@confirmationPerson	varchar(30),	--确认人
				@lockManID varchar(10) output,		--锁定人，如果当前借收入记录正在被人占用编辑则返回该人的工号
				@Ret int output					--操作成功标识0:成功，1：要确认的收入记录不存在，2:要确认的收入记录正在被别人锁定，3:该收入记录未锁定，请先锁定9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户是否存在
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--取维护人的姓名：
			declare @lockManName nvarchar(30),@modiTime smalldatetime
			set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @modiTime = getdate()
			--添加确认信息
			update incomeList set ActualArrivalTime = @ActualArrivalTime,	--实际到账时间
								confirmationDate = @confirmationDate,	--确认日期
								confirmationPersonID =  @confirmationPersonID	,	--确认人ID
								confirmationPerson = @confirmationPerson,	--确认人
								confirmationStatus	 = '1',			--确认状态
								modiManID = @lockManID,			--维护ID	
								modiManName = @lockManName,			--维护人姓名	
								modiTime = @modiTime				--维护时间
								where incomeInformationID = @incomeInformationID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--登记工作日志：
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '确认收入记录', '系统根据用户' + @lockManName	+ '的要求确认了收入记录['+ @incomeInformationID +']。')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO

--删除收入记录
drop PROCEDURE delIncome
/*
	name:		delIncome
	function:		1.删除收入记录
				注意：本存储过程锁定编辑！
	input: 
				@incomeInformationID	varchar(16) output,	--收入信息ID，主键
				@lockManID varchar(10),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该收入记录不存在，2：该收入记录被其他用户锁定，3：请先锁定该收入记录再删除避免冲突，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-5-6
*/

create PROCEDURE delIncome		
				@incomeInformationID	varchar(16),	--收入信息ID，主键
				@lockManID   varchar(10) output,		--锁定人ID

				@Ret		int output			--操作成功标识;--操作成功标示；0:成功，1：该收入记录不存在，2：该收入记录被其他用户锁定，3：请先锁定该收入记录再删除避免冲突，9：未知错误

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--判断要删除的账户明细是否存在
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
				--取维护人的姓名：
				declare @lockMan nvarchar(30)
				set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
				declare @createTime smalldatetime
				set @createTime = getdate()

				delete from incomeList where incomeInformationID = @incomeInformationID

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
				values(@lockManID, @lockMan, @createTime, '删除收入记录', '系统根据用户' + @lockMan + 
					'的要求删除了收入记录[' + @incomeInformationID + ']。')		
		end
	else
	set @Ret = 3
	return
	
GO


--编辑收入记录
drop PROCEDURE editIncome	
/*
	name:		editIncome
	function:	1.编辑收入记录
				注意：本存储过程锁定编辑！
	input: 
				@incomeInformationID varchar(16),		--收入记录号，主键
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),		--项目名称
				@customerID	varchar(13),			--客户ID
				@customerName	varchar(30),		--客户名称
				@abstract		varchar(200),			--摘要
				@incomeSum	numeric(15,2),			--收入金额
				@remarks		varchar(200),			--备注
				@collectionModeID	varchar(10),	--收款方式ID
				@collectionMode	varchar(50),	--收款账号
				@startDate		smalldatetime,			--收款日期
				@paymentApplicantID	varchar(10),	--收款申请人ID
				@payee			varchar(30),				--收款人

				

	output: 
				@lockManID varchar(10) output,		--锁定人ID
				@Ret		int output		--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细已被其他用户锁定，9：未知错误

	author:		卢嘉诚
	CreateDate:	2016-3-23

*/



create PROCEDURE editIncome			
				@incomeInformationID varchar(16),		--收入记录号，主键
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),		--项目名称
				@customerID	varchar(13),			--客户ID
				@customerName	varchar(30),		--客户名称
				@abstract		varchar(200),			--摘要
				@incomeSum	numeric(15,2),			--收入金额
				@remarks		varchar(200),			--备注
				@collectionModeID	varchar(10),	--收款方式ID
				@collectionMode	varchar(50),	--收款账号
				@startDate		smalldatetime,			--收款日期
				@paymentApplicantID	varchar(10),	--收款申请人ID
				@payee			varchar(30),				--收款人

				@lockManID varchar(10) output,		--锁定人ID
				@Ret		int output			--操作成功标示；0:成功，1：该账户明细不存在，2：该账户已被其他用户锁定，3:请先锁定该收入记录避免编辑冲突4：该收入记录已确认无法编辑9：未知错误

	WITH ENCRYPTION 
AS
	--判断要编辑的收入记录是否存在
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查审核状态
	declare @thisperson varchar(10)
	set @thisperson = (select confirmationPersonID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@lockManID)
				begin
					set @lockManID = @thisLockMan
					set @Ret = 2
					return
				end
			set @Ret = 9
	
			--取维护人的姓名：
			declare @createManName nvarchar(30)
			set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			declare @createTime smalldatetime
			set @createTime = getdate()

			update incomeList set
						projectID = @projectID,	--项目ID
						project = @project,	--项目名称
						customerID = @customerID,	--客户ID
						customerName = @customerName,	--客户名称
						abstract	= @abstract,	--摘要
						incomeSum = @incomeSum,	--收入金额
						remarks = @remarks,	--备注
						collectionModeID = @collectionModeID,	--收款方式ID
						collectionMode = @collectionMode,	--收款方式
						startDate = @startDate,	--收款日期
						paymentApplicantID = @paymentApplicantID,	--收款申请人ID
						payee = @payee,	--收款人
						modiManID = @lockManID,	--维护人ID
						modiManName = @createManName,	--维护人
						modiTime = @createTime		--维护时间
						where	incomeInformationID = @incomeInformationID		--收入信息ID，主键


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
			values(@lockManID, @createManName, @createTime, '编辑收入记录', '系统根据用户' + @createManName + 
				'的要求编辑了收入记录[' + @incomeInformationID + ']。')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockIncomeEdit
/*
	name:		lockAccountDetailsEdit
	function: 	锁定收入记录编辑，避免编辑冲突
	input: 
				@incomeInformationID varchar(16),		--收入信息ID
				@lockManID varchar(10) output,	--锁定人，如果当前收入记录正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要锁定的收入记录不存在，2:要锁定的收入记录正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockIncomeEdit
				@incomeInformationID varchar(16),		--收入信息ID
				@lockManID varchar(10) output,	--锁定人，如果当前收入记录正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要锁定的收入记录不存在，2:要锁定的收入记录正在被别人编辑，9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户是否存在
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update incomeList
	set lockManID = @lockManID 
	where incomeInformationID= @incomeInformationID

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
	values(@lockManID, @lockManName, getdate(), '锁定收入记录编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了收入记录['+ @incomeInformationID +']为独占式编辑。')
GO


drop PROCEDURE unlockIncomeEdit
/*
	name:		unlockIncomeEdit
	function: 	释放锁定收入记录编辑，避免编辑冲突
	input: 
				@incomeInformationID varchar(16),		--收入记录ID
				@lockManID varchar(10) output,			--锁定人，如果当前收入正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的收入记录不存在，2:要释放锁定的收入记录正在被别人编辑，8：该收入记录未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockIncomeEdit
				@incomeInformationID varchar(16),			--收入记录ID
				@lockManID varchar(10) output,	--锁定人ID，如果当前收入记录正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识0:成功，1：要释放锁定的收入记录不存在，2:要释放锁定的收入记录正在被别人编辑，8：该收入记录未被任何人锁定9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from incomeList where incomeInformationID= @incomeInformationID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--释放报销单锁定
			update incomeList set lockManID = '' where incomeInformationID = @incomeInformationID
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
				values(@lockManID, @lockManName, getdate(), '释放收入记录编辑锁定', '系统根据用户' + @lockManName	+ '的要求释放了收入记录['+ @incomeInformationID +']的编辑锁。')
		end
	else   --返回该收入记录未被任何人锁定
		begin
			set @Ret = 8
			return
		end
GO



--支出一览表
drop table	expensesList
create table expensesList(
expensesID	varchar(16)	not null,	--支出记录ID
projectID		varchar(13)	not null,	--项目ID
project		varchar(50)	not null,	--项目名称
customerID	varchar(13)	not null,	--客户ID
customerName	varchar(30)	not null,	--客户名称
abstract	varchar(200)	not null,	--摘要
expensesSum	numeric(15,2)	not null,	--支出金额
remarks	varchar(200),	--备注
collectionModeID	varchar(10) not null,	--付款账户ID
collectionMode		varchar(50)	not null,	--付款账户
startDate	smalldatetime	not null,	--申请日期
paymentApplicantID	varchar(10)	not null,	--付款申请人ID
paymentApplicant	varchar(30)	not null,	--付款申请人
confirmationStatus	smallint default(0) not null, --确认状态，0：未确认，1：已确认
paymentDate		smalldatetime,	--支付日期
confirmationDate	smalldatetime	,	--确认日期
confirmationPersonID	varchar(10),	--确认人ID
confirmationPerson		varchar(30),	--确认人
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
foreign key(collectionModeID) references accountList(accountID) on update cascade on delete cascade,
--主键
	 CONSTRAINT [PK_expensesID] PRIMARY KEY CLUSTERED 
(
	[expensesID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



--确认支出记录
drop PROCEDURE confirmexpenses
/*
	name:		confirmexpenses
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 
				@expensesID varchar(16),			--支出记录ID，主键
				@collectionModeID	varchar(10),	--付款账户ID
				@collectionMode	varchar(50),	--付款账户
				@paymentDate		smalldatetime,	--支付日期
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(10),	--确认人ID
				@confirmationPerson	varchar(30),	--确认人
				
	output: 
				@lockManID varchar(10) output,	--锁定人，如果当前借支出记录正在被人占用编辑则返回该人的工号
				@Ret		int output		--操作成功标识0:成功，1：要确认的支出记录不存在，2:要确认的支出记录正在被别人锁定，3:该支出记录未锁定，请先锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	
*/
create PROCEDURE confirmexpenses
				@expensesID varchar(16),			--支出记录ID，主键
				@collectionModeID	varchar(10),	--付款账户ID
				@collectionMode	varchar(50),	--付款账户
				@paymentDate		smalldatetime,	--支付日期
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(10),	--确认人ID
				@confirmationPerson	varchar(30),	--确认人
				@lockManID varchar(10) output,	--锁定人，如果当前借支出记录正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要确认的支出记录不存在，2:要确认的支出记录正在被别人锁定，3:该支出记录未锁定，请先锁定9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户是否存在
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--取维护人的姓名：
			declare @lockManName nvarchar(30),@modiTime smalldatetime
			set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @modiTime = getdate()
			--添加确认信息
			update expensesList set @collectionModeID	= @collectionModeID,	--付款账户ID
								collectionMode =	@collectionMode,			--付款账户
								paymentDate = @paymentDate,					--支付如期
								confirmationStatus = '1',					--确认状态，0：未确认，1：已确认
								confirmationDate = @confirmationDate,		--确认日期
								confirmationPersonID =  @confirmationPersonID	,--确认人ID
								confirmationPerson = @confirmationPerson,	--确认人
								modiManID = @lockManID,					--维护ID	
								modiManName = @lockManName,					--维护人姓名	
								modiTime = @modiTime						--维护时间
								where expensesID = @expensesID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--登记工作日志：
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '确认支出记录', '系统根据用户' + @lockManName	+ '的要求确认了支出记录['+ @expensesID +']。')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO


--添加支出记录
drop PROCEDURE addExpenses
/*
	name:		addExpenses
	function:	1.添加支出记录
				注意：本存储过程不锁定编辑！
	input: 
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),		--摘要
				@expensesSum	numeric(15,2),--支出金额
				@remarks	varchar(200),		--备注
				@startDate	smalldatetime,	--申请日期
				@paymentApplicantID	varchar(10),	--付款申请人ID
				@paymentApplicant		varchar(30),	--付款申请人

				@createManID varchar(10),		--创建人工号
	output: 
				@expensesID	varchar(16) output,	--支出记录ID，主键，使用412号号码发生器生成
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
				
	author:		卢嘉诚
	CreateDate:	2016-3-23

*/

create PROCEDURE addExpenses			
				@expensesID	varchar(16) output,	--支出记录ID，主键，使用412号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),		--摘要
				@expensesSum	numeric(15,2),--支出金额
				@remarks	varchar(200),		--备注
				@startDate	smalldatetime,	--申请日期
				@paymentApplicantID	varchar(10),	--付款申请人ID
				@paymentApplicant		varchar(30),	--付款申请人

				@createManID varchar(10),		--创建人工号

				@Ret		int output

	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 412, 1, @curNumber output
	set @expensesID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30),@createTime smalldatetime
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()

	insert expensesList(
				expensesID,			--支出记录ID，主键，使用412号号码发生器生成
				projectID,			--项目ID
				project,				--项目名称
				customerID,			--客户ID
				customerName,			--客户名称
				abstract	,			--摘要
				expensesSum,			--支出金额
				remarks,				--备注
				startDate,			--申请日期
				paymentApplicantID,	--付款申请人ID
				paymentApplicant,		--付款申请人
				confirmationStatus,	--确认状态，0：未确认，1：已确认
				createManID,			--创建人工号
				createManName,		--创建人
				createTime			--创建时间
							) 
	values (		
				@expensesID,		--支出记录ID，主键，使用412号号码发生器生成
				@projectID,		--项目ID
				@project,			--项目名称
				@customerID,		--客户ID
				@customerName,	--客户名称
				@abstract	,		--摘要
				@expensesSum,		--支出金额
				@remarks,			--备注
				@startDate,		--申请日期
				@paymentApplicantID,	--付款申请人ID
				@paymentApplicant,		--付款申请人
				'0',					--确认状态，0：未确认，1：已确认
				@createManID,			--创建人工号
				@createManName,		--创建人
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
	values(@createManID, @createManName, @createTime, '添加支出记录', '系统根据用户' + @createManName + 
		'的要求添加了支出记录[' + @expensesID + ']。')		
GO

--删除支出记录
drop PROCEDURE delExpenses
/*
	name:		delExpenses
	function:		1.删除支出记录
				注意：本存储过程锁定编辑！
	input: 
				@expensesID	varchar(16) output,		--支出记录ID，主键
				@lockManID varchar(10),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该支出记录不存在，2：该支出记录被其他用户锁定，3：请先锁定该支出记录再删除避免冲突，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-5-6
*/

create PROCEDURE delExpenses	
				@expensesID	varchar(16),		--支出记录ID，主键
				@lockManID   varchar(10) output,		--锁定人ID

				@Ret		int output			--操作成功标识;--操作成功标示；0:成功，1：该支出记录不存在，2：该支出记录被其他用户锁定，3：请先锁定该支出记录再删除避免冲突，9：未知错误

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--判断要删除的账户明细是否存在
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
				--取维护人的姓名：
				declare @lockMan nvarchar(30)
				set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
				declare @createTime smalldatetime
				set @createTime = getdate()

				delete from expensesList where expensesID = @expensesID

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
				values(@lockManID, @lockMan, @createTime, '删除支出记录', '系统根据用户' + @lockMan + 
					'的要求删除了支出记录[' + @expensesID + ']。')		
		end
	else
	set @Ret = 3
	return
	
GO


--编辑支出记录
drop PROCEDURE editExpenses	
/*
	name:		editExpenses
	function:	1.编辑支出记录
				注意：本存储过程锁定编辑！
	input: 
				@expensesID	varchar(16),	--支出记录ID，主键
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),		--摘要
				@expensesSum	numeric(15,2),--支出金额
				@remarks	varchar(200),		--备注
				@startDate	smalldatetime,	--申请日期
				@paymentApplicantID	varchar(10),	--付款申请人ID
				@paymentApplicant		varchar(30),	--付款申请人

	output: 
				@lockManID varchar(10)output,		--锁定人ID
				@Ret		int output			--操作成功标示；0:成功，1：该支出记录不存在，2：该支出记录已被其他用户锁定，3:请先锁定该支出记录避免编辑冲突4：该支出记录已确认无法编辑9：未知错误

	author:		卢嘉诚
	CreateDate:	2016-3-23

*/



create PROCEDURE editExpenses		
				@expensesID	varchar(16),	--支出记录ID，主键
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),		--摘要
				@expensesSum	numeric(15,2),--支出金额
				@remarks	varchar(200),		--备注
				@startDate	smalldatetime,	--申请日期
				@paymentApplicantID	varchar(10),	--付款申请人ID
				@paymentApplicant		varchar(30),	--付款申请人

				@lockManID varchar(10) output,		--锁定人ID
				@Ret		int output			--操作成功标示；0:成功，1：该支出记录不存在，2：该支出记录已被其他用户锁定，3:请先锁定该支出记录避免编辑冲突4：该支出记录已确认无法编辑9：未知错误

	WITH ENCRYPTION 
AS
	--判断要编辑的收入记录是否存在
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查审核状态
	declare @thisperson varchar(10)
	set @thisperson = (select confirmationPersonID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@lockManID)
				begin
					set @lockManID = @thisLockMan
					set @Ret = 2
					return
				end
			set @Ret = 9
	
			--取维护人的姓名：
			declare @createManName nvarchar(30)
			set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			declare @createTime smalldatetime
			set @createTime = getdate()

			update expensesList set
						projectID = @projectID,		--项目ID
						project = @project,			--项目名称
						customerID = @customerID,		--客户ID
						customerName = @customerName,	--客户名称
						abstract	= @abstract,			--摘要
						expensesSum = @expensesSum,		--收入金额
						remarks = @remarks,			--备注
						startDate = @startDate,		--收款日期
						paymentApplicantID = @paymentApplicantID,--收款申请人ID
						paymentApplicant = @paymentApplicant,	--收款人
						modiManID = @lockManID,		--维护人ID
						modiManName = @createManName,	--维护人
						modiTime = @createTime			--维护时间
						where	expensesID = @expensesID		--支出记录ID，主键


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
			values(@lockManID, @createManName, @createTime, '编辑支出记录', '系统根据用户' + @createManName + 
				'的要求编辑了支出记录[' + @expensesID + ']。')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockExpensesEdit
/*
	name:		lockAccountDetailsEdit
	function: 	锁定支出记录编辑，避免编辑冲突
	input: 
				@expensesID varchar(16),		--支出记录ID
				@lockManID varchar(10) output,	--锁定人，如果当前支出记录正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要锁定的支出记录不存在，2:要锁定的支出记录正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockExpensesEdit
				@expensesID varchar(16),		--支出记录ID
				@lockManID varchar(10) output,	--锁定人，如果当前支出记录正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要锁定的支出记录不存在，2:要锁定的支出记录正在被别人编辑，9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的账户是否存在
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update expensesList
	set lockManID = @lockManID 
	where expensesID= @expensesID

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
	values(@lockManID, @lockManName, getdate(), '锁定支出记录编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了支出记录['+ @expensesID +']为独占式编辑。')
GO


drop PROCEDURE unlockExpensesEdit
/*
	name:		unlockExpensesEdit
	function: 	释放锁定支出记录编辑，避免编辑冲突
	input: 
				@expensesID varchar(16),		--支出记录ID
				@lockManID varchar(10) output,			--锁定人，如果当前支出正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的支出记录不存在，2:要释放锁定的支出记录正在被别人编辑，8：该支出记录未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockExpensesEdit
				@expensesID varchar(16),			--支出记录ID
				@lockManID varchar(10) output,	--锁定人ID，如果当前支出记录正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识0:成功，1：要释放锁定的支出记录不存在，2:要释放锁定的支出记录正在被别人编辑，8：该支出记录未被任何人锁定9：未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from expensesList where expensesID= @expensesID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--释放报销单锁定
			update expensesList set lockManID = '' where expensesID = @expensesID
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
				values(@lockManID, @lockManName, getdate(), '释放支出记录编辑', '系统根据用户' + @lockManName	+ '的要求释放了支出记录['+ @expensesID +']的编辑锁。')
		end
	else   --返回该支出记录未被任何人锁定
		begin
			set @Ret = 8
			return
		end
GO