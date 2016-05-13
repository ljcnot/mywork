









-- 发票申请表	
drop table VATinvoice 
create table VATinvoice(
CustomerID	varchar(14)	not null,	--客户编号
customerUnit	varchar(20)	not null,	--客户单位
projectName varchar(20)	not null,	--项目名称
projectID	varchar(14)	not	null,	--项目编号
billingDate	smalldatetime	not null,	--开票日期
billingAmount	float	not null,	--开票金额
invoiceType	int	not	null,	--发票类型
WhetherCancel	int not null,	--是否作废
invoiceID	varchar(14)	not	null,	--发票编号
applyDate	smalldatetime	not	null,	--申请日期
applicantDept	varchar(20)	not	null,	--申请部门
applyDrawer	varchar(10)	not null,	--申请开票人
drawer	varchar(10)	not	null,	--开票人
paymentMode	varchar(10)	not	null,	--回款方式
paymentDate	smalldatetime	not	null,	--回款日期
paymentAmount	float	not	null,	--回款金额
accountsReceivable	float	not	null,	--应收账款
taxAmount	float	not	null,	--应交税金
paidTaxAmount	float not	null,	--实缴税金
payableVAT	float	null,	--应交增值附加税
paidAddTax	float	null,	--实缴附加税
--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
createManID varchar(10) null,		--创建人工号
createManName varchar(30) null,		--创建人姓名
createTime smalldatetime null,		--创建时间

--最新维护情况:
modiManID varchar(10) null,			--维护人工号
modiManName nvarchar(30) null,		--维护人姓名
modiTime smalldatetime null,		--最后维护时间

--编辑锁定人：
lockManID varchar(10)				--当前正在锁定编辑的人工号
)










--账户明细表
drop table accountDetailsList 
create table accountDetailsList(
AccountDetailsID	varchar(16)	not null,	--账户明细ID
accountID 	varchar(13)	not null,	--账户ID
account		varchar(30)	not	null,	--账户名称
detailDate	smalldatetime	not null,	--日期
abstract	varchar(200),	--摘要
borrow		money,		--借
loan		money,		--贷
balance		money,		--余额
departmentID	varchar(13),	--部门ID
department		varchar(30),	--部门
projectID		varchar(13),	--项目ID
project			varchar(100),	--项目
clerkID		varchar(13),		--经手人ID
clerk		varchar(20),		--经手人
remarks		varchar(200),		--备注
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
				@AccountDetailsID	varchar(16) output,	--账户明细ID，主键，使用408号号码发生器生成
				@accountID 	varchar(13),		--账户ID
				@account		varchar(30),		--账户名称
				@detailDate	smalldatetime	,	--日期
				@abstract	varchar(200),			--摘要
				@borrow		money,			--借
				@loan		money,			--贷
				@balance		money,			--余额
				@departmentID	varchar(13),		--部门ID
				@department		varchar(30),	--部门
				@projectID		varchar(13),	--项目ID
				@project			varchar(100),	--项目
				@clerkID		varchar(13),		--经手人ID
				@clerk		varchar(20),		--经手人
				@remarks		varchar(200),		--备注

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addAccountDetails			
				@AccountDetailsID	varchar(16) output,	--账户明细ID，主键，使用408号号码发生器生成
				@accountID 	varchar(13),		--账户ID
				@account		varchar(30),		--账户名称
				@detailDate	smalldatetime	,	--日期
				@abstract		varchar(200),		--摘要
				@borrow		money,			--借
				@loan		money,			--贷
				@balance		money,			--余额
				@departmentID	varchar(13),		--部门ID
				@department		varchar(30),	--部门
				@projectID		varchar(13),	--项目ID
				@project			varchar(100),	--项目
				@clerkID		varchar(13),		--经手人ID
				@clerk		varchar(20),		--经手人
				@remarks		varchar(200),		--备注

				@createManID varchar(13),		--创建人工号

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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	declare @createTime smalldatetime
	set @createTime = getdate()

	insert accountDetailsList(
				AccountDetailsID,	--账户明细ID，主键，使用408号号码发生器生成
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
				@AccountDetailsID,	--账户明细ID，主键，使用408号号码发生器生成
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
	--插入明细表：
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
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
				@AccountDetailsID	varchar(16) output,	--账户明细ID，主键，使用408号号码发生器生成
				@lockManID varchar(13),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细被其他用户锁定，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE delAccountDetails		
				@AccountDetailsID	varchar(16),	--账户明细ID，主键
				@lockManID   varchar(13) output,		--锁定人ID

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
	declare @thisLockMan varchar(13)
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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @lockMan = '卢嘉诚'
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
				@AccountDetailsID	varchar(16) output,	--账户明细ID，主键
				@accountID 	varchar(13),		--账户ID
				@account		varchar(30),		--账户名称
				@detailDate	smalldatetime	,	--日期
				@abstract	varchar(200),			--摘要
				@borrow		money,			--借
				@loan		money,			--贷
				@balance		money,			--余额
				@departmentID	varchar(13),		--部门ID
				@department		varchar(30),	--部门
				@projectID		varchar(13),	--项目ID
				@project			varchar(100),	--项目
				@clerkID		varchar(13),		--经手人ID
				@clerk		varchar(20),		--经手人
				@remarks		varchar(200),		--备注

				@lockManID varchar(10)output,		--锁定人ID
	output: 
				@Ret		int output		--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细已被其他用户锁定，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/


select count(*) from accountDetailsList where AccountDetailsID= 'ZHMX201605050002'
create PROCEDURE editAccountDetails				
				@AccountDetailsID	varchar(16) ,	--账户明细ID，主键
				@accountID 	varchar(13),		--账户ID
				@account		varchar(30),		--账户名称
				@detailDate	smalldatetime	,	--日期
				@abstract	varchar(200),			--摘要
				@borrow		money,			--借
				@loan		money,			--贷
				@balance		money,			--余额
				@departmentID	varchar(13),		--部门ID
				@department		varchar(30),	--部门
				@projectID		varchar(13),	--项目ID
				@project			varchar(100),	--项目
				@clerkID		varchar(13),		--经手人ID
				@clerk		varchar(20),		--经手人
				@remarks		varchar(200),		--备注

				@lockManID varchar(13) output,		--锁定人ID

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
	declare @thisLockMan varchar(13)
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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	declare @createTime smalldatetime
	set @createTime = getdate()

	update accountDetailsList set
				AccountDetailsID = @AccountDetailsID,	--账户明细ID，主键，使用408号号码发生器生成
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
	--插入明细表：
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName, @createTime, '编辑账户', '系统根据用户' + @createManName + 
		'的要求编辑了账户[' + @accountID + ']。')		
GO


drop PROCEDURE lockAccountDetailsEdit
/*
	name:		lockAccountDetailsEdit
	function: 	锁定账户明细编辑，避免编辑冲突
	input: 
				@AccountDetailsID varchar(16),		--账户ID
				@lockManID varchar(13) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要锁定的账户明细不存在，2:要锁定的账户明细正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountDetailsEdit
				@AccountDetailsID varchar(16),		--账户ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
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
	declare @thisLockMan varchar(13)
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
	set @lockManName = '卢嘉诚'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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
				@AccountDetailsID varchar(16),		--账户ID
				@lockManID varchar(13) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的账户明细不存在，2:要释放锁定的账户明细正在被别人编辑，8：该账户明细未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockAccountDetailsEdit
				@AccountDetailsID varchar(16),			--账户ID
				@lockManID varchar(13) output,	--锁定人ID，如果当前账户正在被人占用编辑则返回该人的工号
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
	declare @thisLockMan varchar(13)
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
				--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				set @lockManName = '卢嘉诚'
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





--收入一览表
drop table incomeList
create table incomeList(
incomeInformationID varchar(16)	not null,	--收入信息ID
projectID	varchar(13)	not null,	--项目ID
project		varchar(50)	not null,	--项目名称
customerID	varchar(13)	not null,	--客户ID
customerName	varchar(30)	not null,	--客户名称
abstract	varchar(200)	not null,	--摘要
incomeSum	money not null,	--收入金额
contractAmount money ,	--合同金额
receivedAmount	money,	--已收金额
remarks	varchar(200),	--备注
collectionModeID	varchar(13) not null,	--收款方式ID
collectionMode		varchar(50)	not null,	--收款方式
startDate	smalldatetime	not null,	--收款日期
paymentApplicantID	varchar(13)	not null,	--收款申请人ID
payee	varchar(10)	not null,	--收款人
confirmationDate	smalldatetime	,	--确认日期
confirmationPersonID	varchar(13),	--确认人ID
confirmationPerson		varchar(10),	--确认人
approvalOpinion			varchar(200),	--审批意见
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
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 

				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),	--摘要
				@incomeSum	money,	--收入金额
				@contractAmount money,	--合同金额
				@receivedAmount	money,	--已收金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13),	--收款方式ID
				@collectionMode		varchar(50),	--收款方式
				@startDate	smalldatetime	,	--收款日期
				@paymentApplicantID	varchar(13),	--收款申请人ID
				@payee	varchar(10),	--收款人
				@createManID varchar(13),	--创建人

				
	output: 
				@incomeInformationID varchar(16)	output,	--收入信息ID，主键，使用411号号码发生器生成
				@Ret int output				--操作成功标识0:成功，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE addIncome
				@incomeInformationID varchar(16)	output,	--收入信息ID，主键，使用411号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),	--摘要
				@incomeSum	money,	--收入金额
				@contractAmount money,	--合同金额
				@receivedAmount	money,	--已收金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13),	--收款方式ID
				@collectionMode		varchar(50),	--收款方式
				@startDate	smalldatetime	,	--收款日期
				@paymentApplicantID	varchar(13),	--收款申请人ID
				@payee	varchar(10),	--收款人
				@createManID varchar(13),	--创建人
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
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()
	insert incomeList (
						incomeInformationID,	--收入信息ID，主键，使用411号号码发生器生成
						projectID,	--项目ID
						project,	--项目名称
						customerID,	--客户ID
						customerName,	--客户名称
						abstract	,	--摘要
						incomeSum,	--收入金额
						contractAmount,	--合同金额
						receivedAmount,	--已收金额
						remarks,	--备注
						collectionModeID,	--收款方式ID
						collectionMode,	--收款方式
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
						@contractAmount,	--合同金额
						@receivedAmount,	--已收金额
						@remarks,	--备注
						@collectionModeID,	--收款方式ID
						@collectionMode,	--收款方式
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
				values(@createManID, @createManName, getdate(), '添加收入详情', '系统根据用户' + @createManName	+ '的要求添加了收入详情['+ @incomeInformationID +']。')
GO

--确认指定收入明细
drop PROCEDURE confirmIncome
/*				确认指定收入明细
	name:		confirmIncome
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 
				@incomeInformationID varchar(16)	,	--收入信息ID，主键
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(13),	--确认人ID
				@confirmationPerson		varchar(10),	--确认人
				@approvalOpinion			varchar(200),	--审批意见

				
	output: 
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret		int output		--操作成功标识0:成功，1：要确认的收入明细不存在，2:要确认的收入明细正在被别人锁定，3:该收入明细未锁定，请先锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE confirmIncome
				@incomeInformationID varchar(16)	,	--收入信息ID，主键
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(13),	--确认人ID
				@confirmationPerson		varchar(10),	--确认人
				@approvalOpinion			varchar(200),	--审批意见
				@lockManID varchar(13) output,	--锁定人，如果当前借收入明细正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要确认的收入明细不存在，2:要确认的收入明细正在被别人锁定，3:该收入明细未锁定，请先锁定9：未知错误
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
	declare @thisLockMan varchar(13)
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
			--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @lockManName = '卢嘉诚'
			set @modiTime = getdate()
			--添加确认信息
			update incomeList set confirmationDate = @confirmationDate,	--确认日期
								confirmationPersonID =  @confirmationPersonID	,	--确认人ID
								confirmationPerson = @confirmationPerson,	--确认人
								approvalOpinion = @approvalOpinion,		--审批意见
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
				values(@lockManID, @lockManName, getdate(), '确认收入明细', '系统根据用户' + @lockManName	+ '的要求确认了收入明细['+ @incomeInformationID +']。')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO

--删除收入明细
drop PROCEDURE delIncome
/*
	name:		delIncome
	function:		1.删除收入明细
				注意：本存储过程锁定编辑！
	input: 
				@incomeInformationID	varchar(16) output,	--收入信息ID，主键
				@lockManID varchar(13),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该收入明细不存在，2：该收入明细被其他用户锁定，3：请先锁定该收入明细再删除避免冲突，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-5-6
*/

create PROCEDURE delIncome		
				@incomeInformationID	varchar(16),	--收入信息ID，主键
				@lockManID   varchar(13) output,		--锁定人ID

				@Ret		int output			--操作成功标识;--操作成功标示；0:成功，1：该收入明细不存在，2：该收入明细被其他用户锁定，3：请先锁定该收入明细再删除避免冲突，9：未知错误

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
	declare @thisLockMan varchar(13)
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
				--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
				set @lockMan = '卢嘉诚'
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
				values(@lockManID, @lockMan, @createTime, '删除收入明细', '系统根据用户' + @lockMan + 
					'的要求删除了收入明细[' + @incomeInformationID + ']。')		
		end
	else
	set @Ret = 3
	return
	
GO


--编辑收入明细
drop PROCEDURE editIncome	
/*
	name:		editIncome
	function:	1.编辑收入明细
				注意：本存储过程锁定编辑！
	input: 
				@incomeInformationID varchar(16)	output,	--收入信息ID，主键，使用411号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),	--摘要
				@incomeSum	money,	--收入金额
				@contractAmount money,	--合同金额
				@receivedAmount	money,	--已收金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13),	--收款方式ID
				@collectionMode		varchar(50),	--收款方式
				@startDate	smalldatetime	,	--收款日期
				@paymentApplicantID	varchar(13),	--收款申请人ID
				@payee	varchar(10),	--收款人


	output: 
				@lockManID varchar(10)output,		--锁定人ID
				@Ret		int output		--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细已被其他用户锁定，9：未知错误

	author:		卢嘉诚
	CreateDate:	2016-3-23

*/



create PROCEDURE editIncome			
				@incomeInformationID varchar(16)	output,	--收入信息ID，主键，使用411号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),	--摘要
				@incomeSum	money,	--收入金额
				@contractAmount money,	--合同金额
				@receivedAmount	money,	--已收金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13),	--收款方式ID
				@collectionMode		varchar(50),	--收款方式
				@startDate	smalldatetime	,	--收款日期
				@paymentApplicantID	varchar(13),	--收款申请人ID
				@payee	varchar(10),	--收款人

				@lockManID varchar(13) output,		--锁定人ID
				@Ret		int output			--操作成功标示；0:成功，1：该账户明细不存在，2：该账户已被其他用户锁定，3:请先锁定该收入明细避免编辑冲突4：该收入明细已确认无法编辑9：未知错误

	WITH ENCRYPTION 
AS
	--判断要编辑的收入明细是否存在
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查审核状态
	declare @thisperson varchar(13)
	set @thisperson = (select confirmationPersonID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--检查编辑锁：
	declare @thisLockMan varchar(13)
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
			--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			set @createManName = '卢嘉诚'
			declare @createTime smalldatetime
			set @createTime = getdate()

			update incomeList set
						projectID = @projectID,	--项目ID
						project = @project,	--项目名称
						customerID = @customerID,	--客户ID
						customerName = @customerName,	--客户名称
						abstract	= @abstract,	--摘要
						incomeSum = @incomeSum,	--收入金额
						contractAmount = @contractAmount,	--合同金额
						receivedAmount = @receivedAmount,	--已收金额
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
			values(@lockManID, @createManName, @createTime, '编辑收入明细', '系统根据用户' + @createManName + 
				'的要求编辑了收入明细[' + @incomeInformationID + ']。')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockIncomeEdit
/*
	name:		lockAccountDetailsEdit
	function: 	锁定收入明细编辑，避免编辑冲突
	input: 
				@incomeInformationID varchar(16),		--收入信息ID
				@lockManID varchar(13) output,	--锁定人，如果当前收入明细正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要锁定的收入明细不存在，2:要锁定的收入明细正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockIncomeEdit
				@incomeInformationID varchar(16),		--收入信息ID
				@lockManID varchar(13) output,	--锁定人，如果当前收入明细正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要锁定的收入明细不存在，2:要锁定的收入明细正在被别人编辑，9：未知错误
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
	declare @thisLockMan varchar(13)
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
	set @lockManName = '卢嘉诚'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定收入明细编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了收入明细['+ @incomeInformationID +']为独占式编辑。')
GO


drop PROCEDURE unlockIncomeEdit
/*
	name:		unlockIncomeEdit
	function: 	释放锁定收入明细编辑，避免编辑冲突
	input: 
				@incomeInformationID varchar(16),		--收入明细ID
				@lockManID varchar(13) output,			--锁定人，如果当前收入正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的收入明细不存在，2:要释放锁定的收入明细正在被别人编辑，8：该收入明细未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockIncomeEdit
				@incomeInformationID varchar(16),			--收入明细ID
				@lockManID varchar(13) output,	--锁定人ID，如果当前收入明细正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识0:成功，1：要释放锁定的收入明细不存在，2:要释放锁定的收入明细正在被别人编辑，8：该收入明细未被任何人锁定9：未知错误
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
	declare @thisLockMan varchar(13)
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
				--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				set @lockManName = '卢嘉诚'
				--登记工作日志：
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '释放收入明细编辑', '系统根据用户' + @lockManName	+ '的要求释放了收入明细['+ @incomeInformationID +']的编辑锁。')
		end
	else   --返回该收入明细未被任何人锁定
		begin
			set @Ret = 8
			return
		end
GO



--支出一览表
drop table	expensesList
create table expensesList(
expensesID	varchar(16)	not null,	--支出信息ID
projectID	varchar(13)	not null,	--项目ID
project		varchar(50)	not null,	--项目名称
customerID	varchar(13)	not null,	--客户ID
customerName	varchar(30)	not null,	--客户名称
abstract	varchar(200)	not null,	--摘要
expensesSum	money	not null,	--支出金额
contractAmount money ,	--合同金额
receivedAmount money,	--已付金额
remarks	varchar(200),	--备注
collectionModeID	varchar(13) not null,	--付款方式ID
collectionMode		varchar(50)	not null,	--付款方式
startDate	smalldatetime	not null,	--付款日期
paymentApplicantID	varchar(13)	not null,	--付款申请人ID
paymentApplicant	varchar(10)	not null,	--付款申请人
confirmationDate	smalldatetime	,	--确认日期
confirmationPersonID	varchar(13),	--确认人ID
confirmationPerson		varchar(10),	--确认人
approvalOpinion			varchar(200),	--审批意见
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




drop PROCEDURE confirmexpenses
/*
	name:		confirmexpenses
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 
				@expensesID varchar(16)	,	--支出信息ID，主键
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(13),	--确认人ID
				@confirmationPerson		varchar(10),	--确认人
				@approvalOpinion			varchar(200),	--审批意见

				
	output: 
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				@Ret		int output		--操作成功标识0:成功，1：要确认的支出明细不存在，2:要确认的支出明细正在被别人锁定，3:该支出明细未锁定，请先锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE confirmexpenses
				@expensesID varchar(16)	,	--支出信息ID，主键
				@confirmationDate	smalldatetime	,	--确认日期
				@confirmationPersonID	varchar(13),	--确认人ID
				@confirmationPerson	varchar(10),	--确认人
				@approvalOpinion		varchar(200),	--审批意见
				@lockManID varchar(13) output,	--锁定人，如果当前借支出明细正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要确认的支出明细不存在，2:要确认的支出明细正在被别人锁定，3:该支出明细未锁定，请先锁定9：未知错误
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
	declare @thisLockMan varchar(13)
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
			--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @lockManName = '卢嘉诚'
			set @modiTime = getdate()
			--添加确认信息
			update expensesList set confirmationDate = @confirmationDate,	--确认日期
								confirmationPersonID =  @confirmationPersonID	,	--确认人ID
								confirmationPerson = @confirmationPerson,	--确认人
								approvalOpinion = @approvalOpinion,		--审批意见
								modiManID = @lockManID,			--维护ID	
								modiManName = @lockManName,			--维护人姓名	
								modiTime = @modiTime				--维护时间
								where expensesID = @expensesID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--登记工作日志：
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '确认支出明细', '系统根据用户' + @lockManName	+ '的要求确认了支出明细['+ @expensesID +']。')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO


--添加支出明细
drop PROCEDURE addExpenses
/*
	name:		addExpenses
	function:	1.添加支出明细
				注意：本存储过程不锁定编辑！
	input: 

				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	     varchar(200),	--摘要
				@expensesSum	money,	--支出金额
				@contractAmount money,	--合同金额
				@receivedAmount money,	--已付金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13) ,	--付款方式ID
				@collectionMode		varchar(50),	--付款方式
				@startDate	smalldatetime	,	--付款日期
				@paymentApplicantID	varchar(13),	--付款申请人ID
				@paymentApplicant	varchar(10),	--付款申请人

				@createManID varchar(13),		--创建人工号
	output: 
				@expensesID	varchar(16),	--支出信息ID，主键，使用412号号码发生器生成
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addExpenses			
				@expensesID	varchar(16) output,	--支出信息ID，主键，使用412号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),	--摘要
				@expensesSum	money,	--支出金额
				@contractAmount money,	--合同金额
				@receivedAmount money,	--已付金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13) ,	--付款方式ID
				@collectionMode		varchar(50),	--付款方式
				@startDate	smalldatetime	,	--付款日期
				@paymentApplicantID	varchar(13),	--付款申请人ID
				@paymentApplicant	varchar(10),	--付款申请人

				@createManID varchar(13),		--创建人工号

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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()

	insert expensesList(
				expensesID,	--支出信息ID，主键，使用412号号码发生器生成
				projectID,	--项目ID
				project,	--项目名称
				customerID,	--客户ID
				customerName,	--客户名称
				abstract	,	--摘要
				expensesSum,	--支出金额
				contractAmount,	--合同金额
				receivedAmount,	--已付金额
				remarks,	--备注
				collectionModeID,	--付款方式ID
				collectionMode,	--付款方式
				startDate,	--付款日期
				paymentApplicantID,	--付款申请人ID
				paymentApplicant,	--付款申请人
				createManID,			--创建人工号
				createManName,	--创建人
				createTime				--创建时间
							) 
	values (		
				@expensesID,	--支出信息ID，主键，使用412号号码发生器生成
				@projectID,	--项目ID
				@project,	--项目名称
				@customerID,	--客户ID
				@customerName,	--客户名称
				@abstract	,	--摘要
				@expensesSum,	--支出金额
				@contractAmount,	--合同金额
				@receivedAmount,	--已付金额
				@remarks,	--备注
				@collectionModeID,	--付款方式ID
				@collectionMode,	--付款方式
				@startDate,	--付款日期
				@paymentApplicantID,	--付款申请人ID
				@paymentApplicant,	--付款申请人
				@createManID,			--创建人工号
				@createManName,	--创建人
				@createTime				--创建时间				
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
	values(@createManID, @createManName, @createTime, '添加支出明细', '系统根据用户' + @createManName + 
		'的要求添加了支出明细[' + @expensesID + ']。')		
GO

--删除支出明细
drop PROCEDURE delExpenses
/*
	name:		delExpenses
	function:		1.删除支出明细
				注意：本存储过程锁定编辑！
	input: 
				@expensesID	varchar(16) output,		--支出信息ID，主键
				@lockManID varchar(13),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该支出明细不存在，2：该支出明细被其他用户锁定，3：请先锁定该支出明细再删除避免冲突，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-5-6
*/

create PROCEDURE delExpenses	
				@expensesID	varchar(16),		--支出信息ID，主键
				@lockManID   varchar(13) output,		--锁定人ID

				@Ret		int output			--操作成功标识;--操作成功标示；0:成功，1：该支出明细不存在，2：该支出明细被其他用户锁定，3：请先锁定该支出明细再删除避免冲突，9：未知错误

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
	declare @thisLockMan varchar(13)
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
				--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
				set @lockMan = '卢嘉诚'
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
				values(@lockManID, @lockMan, @createTime, '删除支出明细', '系统根据用户' + @lockMan + 
					'的要求删除了支出明细[' + @expensesID + ']。')		
		end
	else
	set @Ret = 3
	return
	
GO


--编辑支出明细
drop PROCEDURE editExpenses	
/*
	name:		editExpenses
	function:	1.编辑支出明细
				注意：本存储过程锁定编辑！
	input: 
				@expensesID	varchar(16) output,	--支出信息ID，主键，使用412号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),	--摘要
				@expensesSum	money,	--支出金额
				@contractAmount money,	--合同金额
				@receivedAmount money,	--已付金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13) ,	--付款方式ID
				@collectionMode		varchar(50),	--付款方式
				@startDate	smalldatetime	,	--付款日期
				@paymentApplicantID	varchar(13),	--付款申请人ID
				@paymentApplicant	varchar(10),	--付款申请人

	output: 
				@lockManID varchar(10)output,		--锁定人ID
				@Ret		int output			--操作成功标示；0:成功，1：该支出明细不存在，2：该支出明细已被其他用户锁定，3:请先锁定该支出明细避免编辑冲突4：该支出明细已确认无法编辑9：未知错误

	author:		卢嘉诚
	CreateDate:	2016-3-23

*/



create PROCEDURE editExpenses		
				@expensesID	varchar(16) ,	--支出信息ID，主键，使用412号号码发生器生成
				@projectID	varchar(13),	--项目ID
				@project		varchar(50),	--项目名称
				@customerID	varchar(13),	--客户ID
				@customerName	varchar(30),	--客户名称
				@abstract	varchar(200),	--摘要
				@expensesSum	money,	--支出金额
				@contractAmount money,	--合同金额
				@receivedAmount money,	--已付金额
				@remarks	varchar(200),	--备注
				@collectionModeID	varchar(13) ,	--付款方式ID
				@collectionMode		varchar(50),	--付款方式
				@startDate	smalldatetime	,	--付款日期
				@paymentApplicantID	varchar(13),	--付款申请人ID
				@paymentApplicant	varchar(10),	--付款申请人

				@lockManID varchar(13) output,		--锁定人ID
				@Ret		int output			--操作成功标示；0:成功，1：该支出明细不存在，2：该支出明细已被其他用户锁定，3:请先锁定该支出明细避免编辑冲突4：该支出明细已确认无法编辑9：未知错误

	WITH ENCRYPTION 
AS
	--判断要编辑的收入明细是否存在
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查审核状态
	declare @thisperson varchar(13)
	set @thisperson = (select confirmationPersonID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--检查编辑锁：
	declare @thisLockMan varchar(13)
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
			--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			set @createManName = '卢嘉诚'
			declare @createTime smalldatetime
			set @createTime = getdate()

			update expensesList set
						projectID = @projectID,	--项目ID
						project = @project,	--项目名称
						customerID = @customerID,	--客户ID
						customerName = @customerName,	--客户名称
						abstract	= @abstract,	--摘要
						expensesSum = @expensesSum,	--收入金额
						contractAmount = @contractAmount,	--合同金额
						receivedAmount = @receivedAmount,	--已收金额
						remarks = @remarks,	--备注
						collectionModeID = @collectionModeID,	--收款方式ID
						collectionMode = @collectionMode,	--收款方式
						startDate = @startDate,	--收款日期
						paymentApplicantID = @paymentApplicantID,	--收款申请人ID
						paymentApplicant = @paymentApplicant,	--收款人
						modiManID = @lockManID,	--维护人ID
						modiManName = @createManName,	--维护人
						modiTime = @createTime		--维护时间
						where	expensesID = @expensesID		--支出明细ID，主键


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
			values(@lockManID, @createManName, @createTime, '编辑支出明细', '系统根据用户' + @createManName + 
				'的要求编辑了支出明细[' + @expensesID + ']。')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockExpensesEdit
/*
	name:		lockAccountDetailsEdit
	function: 	锁定支出明细编辑，避免编辑冲突
	input: 
				@expensesID varchar(16),		--支出信息ID
				@lockManID varchar(13) output,	--锁定人，如果当前支出明细正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要锁定的支出明细不存在，2:要锁定的支出明细正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockExpensesEdit
				@expensesID varchar(16),		--支出信息ID
				@lockManID varchar(13) output,	--锁定人，如果当前支出明细正在被人占用编辑则返回该人的工号
				@Ret int output				--操作成功标识0:成功，1：要锁定的支出明细不存在，2:要锁定的支出明细正在被别人编辑，9：未知错误
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
	declare @thisLockMan varchar(13)
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
	set @lockManName = '卢嘉诚'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定支出明细编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了支出明细['+ @expensesID +']为独占式编辑。')
GO


drop PROCEDURE unlockExpensesEdit
/*
	name:		unlockExpensesEdit
	function: 	释放锁定支出明细编辑，避免编辑冲突
	input: 
				@expensesID varchar(16),		--支出明细ID
				@lockManID varchar(13) output,			--锁定人，如果当前支出正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的支出明细不存在，2:要释放锁定的支出明细正在被别人编辑，8：该支出明细未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockExpensesEdit
				@expensesID varchar(16),			--支出明细ID
				@lockManID varchar(13) output,	--锁定人ID，如果当前支出明细正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识0:成功，1：要释放锁定的支出明细不存在，2:要释放锁定的支出明细正在被别人编辑，8：该支出明细未被任何人锁定9：未知错误
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
	declare @thisLockMan varchar(13)
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
				--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				set @lockManName = '卢嘉诚'
				--登记工作日志：
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '释放支出明细编辑', '系统根据用户' + @lockManName	+ '的要求释放了支出明细['+ @expensesID +']的编辑锁。')
		end
	else   --返回该支出明细未被任何人锁定
		begin
			set @Ret = 8
			return
		end
GO