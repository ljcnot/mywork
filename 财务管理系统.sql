drop table borrowSingle      --借支单表
create table borrowSingle(
	borrowSingleID varchar(15) not null,  --借支单号
	borrowManID varchar(13)	not null,	--借支人ID
	borrowMan varchar(20)	not null,		--借支人（姓名）
	position	varchar(10)	not null,	--职务
	departmentID	varchar(13)	not null,	--部门ID
	department	varchar(16)	not null,	--部门
	borrowDate	smalldatetime	not null,	--借支时间
	projectID	varchar(14),	--所在项目ID
	projectName	varchar(200),	--所在项目（名称）
	borrowReason	varchar(200),	--借支事由
	borrowSum	money,	--借支金额
	flowProgress smallint default(0),		--流转进度：0：待审核，1：审批中，2：已审结
	approvalOpinion	varchar(200),	--审批意见
	IssueSituation	smallint default(0),	--发放情况
	paymentMethodID	varchar(16),	---付款方式ID
	paymentMethod	varchar(14) ,	--付款方式
	paymentSum	money,	--付款金额
	draweeID varchar(13),	--付款人ID
	drawee varchar(14),		--付款人
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
 CONSTRAINT [PK_borrowSingle] PRIMARY KEY CLUSTERED 
(
	[borrowSingleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

----外键：
--ALTER TABLE [dbo].[eqpApplyDetail] WITH CHECK ADD CONSTRAINT [FK_eqpApplyDetail_eqpApplyInfo] FOREIGN KEY([eqpApplyID])
--REFERENCES [dbo].[eqpApplyInfo] ([eqpApplyID])
--ON UPDATE CASCADE
--ON DELETE CASCADE
GO



drop table ApprovalDetailsList      --审批详情表
create table ApprovalDetailsList(
	ApprovalDetailsID varchar(16)	not null,	--审批详情ID
	billID	varchar(17)	not null,	--单据ID
	approvalStatus int not	null,	--审批情况（同意/不同意）
	approvalOpinions	varchar(200),	--审批意见
	examinationPeoplePost varchar(50),	--审批人职务
	examinationPeopleID	varchar(20),	--审批人ID
	examinationPeopleName	varchar(20)	--审批人名称
	)
GO



drop PROCEDURE addborrowSingle
/*
	name:		addborrowSingle
	function:	1.添加借支单
				注意：本存储过程不锁定编辑！
	input: 
			@borrowSingleID varchar(15) ,  --借支单号,主键 由401号号码发生器生成
			@borrowManID varchar(13)	,	--借支人ID
			@borrowMan varchar(20)	,		--借支人（姓名）
			@position	varchar(10)	,	--职务
			@departmentID	varchar(13)	,	--部门ID
			@department	varchar(16)	,	--部门
			@borrowDate	smalldatetime	,	--借支时间
			@projectID	varchar(14),	--所在项目ID
			@projectName	varchar(200),	--所在项目（名称）
			@borrowReason	varchar(200),	--借支事由
			@borrowSum	money,	--借支金额
			@flowProgress varchar(10),		--流转进度：0：待审核，1：审批中，2：已审结

			@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/
create PROCEDURE addborrowSingle				
			@borrowManID varchar(13)	,	--借支人ID
			@borrowMan varchar(20)	,		--借支人（姓名）
			@position	varchar(10)	,	--职务
			@departmentID	varchar(13)	,	--部门ID
			@department	varchar(16)	,	--部门
			@borrowDate	smalldatetime	,	--借支时间
			@projectID	varchar(14),	--所在项目ID
			@projectName	varchar(200),	--所在项目（名称）
			@borrowReason	varchar(200),	--借支事由
			@borrowSum	Decimal(12),	--借支金额
			@flowProgress smallint,		--流转进度
			@createManID varchar(10),		--创建人工号

	@Ret		int output,
	@borrowSingleID varchar(15) output	--主键：借支单号，使用第 3 号号码发生器产生
	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 401, 1, @curNumber output
	set @borrowSingleID = @curNumber

	
	----取维护人的姓名：
	--declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @createTime smalldatetime, @createManName varchar(30)
	set @createManName = '卢嘉诚'
	set @createTime = getdate()
	insert borrowSingle(borrowSingleID,		--借支单ID
							borrowManID,	--借支人ID
							borrowMan,		--借支人姓名
							position,		--职务
							departmentID,	--部门ID
							department,		--部门名称
							borrowDate,		--借支时间
							projectID,		--所在项目ID
							projectName,	--所在项目(名称）
							borrowReason,	--借支事由
							borrowSum,		--借支金额
							flowProgress,	--流转进度
							createManID,	--创建人工号
							createManName,	--创建人姓名
							createTime		--创建时间
							) 
	values (@borrowSingleID, 
			@borrowManID,
			@borrowMan,
			@position, 
			@departmentID, 
			@department,
			@borrowDate, 
			@projectID, 
			@projectName, 
			@borrowReason,
			@borrowSum, 
			@flowProgress, 
			@createManID, 
			@createManName,
			@createTime) 
	set @Ret = 0
	--if @@ERROR <> 0 
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID,@createManName, @createTime, '添加借支单', '系统根据用户'+@createManName+'的要求添加了借支单[' + @borrowSingleID + ']。')
GO




drop table workNote      --工作日志表
create table workNote(
	workNoteID int primary key identity(1,1),	--工作日志ID
	userID	varchar(17)	not null,	--用户ID
	userName	varchar(17)	not	null,	--用户名字
	actionTime	varchar(200),	--修改时间
	actions varchar(50),	--操作说明
	actionObject	varchar(100),	--详细说明
	)
GO



drop PROCEDURE editborrowSingle
/*
	name:		addborrowSingle
	function:	1.添加报销单
				注意：本存储过程不锁定编辑！
	input: 
			@borrowSingleID varchar(15) ,  --借支单号
			@borrowManID varchar(13)	,	--借支人ID
			@borrowMan varchar(20)	,		--借支人（姓名）
			@position	varchar(10)	,	--职务
			@departmentID	varchar(13)	,	--部门ID
			@department	varchar(16)	,	--部门
			@borrowDate	smalldatetime	,	--借支时间
			@projectID	varchar(14),	--所在项目ID
			@projectName	varchar(200),	--所在项目（名称）
			@borrowReason	varchar(200),	--借支事由
			@borrowSum	money,	--借支金额
			@flowProgress smallint,		--流转进度

			@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该借支单已被锁定，2：该借支单为审核状态9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by 
*/
create PROCEDURE editborrowSingle				
			@borrowSingleID varchar(15), 	--主键：借支单号，使用第 3 号号码发生器产生
			@borrowManID varchar(13)	,	--借支人ID
			@borrowMan varchar(20)	,		--借支人（姓名）
			@position	varchar(10)	,	--职务
			@departmentID	varchar(13)	,	--部门ID
			@department	varchar(16)	,	--部门
			@borrowDate	smalldatetime	,	--借支时间
			@projectID	varchar(14),	--所在项目ID
			@projectName	varchar(200),	--所在项目（名称）
			@borrowReason	varchar(200),	--借支事由
			@borrowSum	Decimal(12),	--借支金额
			@flowProgress smallint,		--流转进度

			@modiManID varchar(10),		--维护人工号

		@Ret		int output		--操作表示，0：成功，1：该单据被其他人编辑占用，2：该单据为审核状态不允许编辑

	WITH ENCRYPTION 
AS
	set @Ret = 9
	--查询借支单是否为审核状态
	declare @thisflowProgress smallint
	set @thisflowProgress = (select flowProgress from borrowSingle where borrowSingleID = @borrowSingleID)
	if (@thisflowProgress<>0)
	begin
		set @Ret = 2
		return
	end

	--检查编辑的借支单是否有编辑锁或长事务锁：
	declare @count int
	set @count = (select COUNT(*) from borrowSingle
					where borrowSingleID = @borrowSingleID
					and	  ISNULL(lockManID,'')<>'')
						
	if (@count>0)
	begin
		set @Ret = 1
		return
	end

	
	--取维护人的姓名：
	--declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @modiTime smalldatetime,@modiManName varchar(30)
	set @modiManName = '卢嘉诚'
	set @modiTime = getdate()
	update borrowSingle set borrowManID = @borrowManID,	--借支人ID
							borrowMan = @borrowMan,		--借支人姓名
							position = @position,		--职务
							departmentID = @departmentID,	--部门
							borrowDate = @borrowDate,		--借支时间
							projectID = @projectID,		--所在项目ID
							projectName = @projectName,	--所在项目(名称）
							borrowReason = @borrowReason,	--借支事由
							borrowSum = @borrowSum,		--借支金额
							flowProgress = @flowProgress,	--流转进度
							modiManID = @modiManID,	--维护人工号
							modiManName	= @modiManName,	--维护人姓名
							modiTime	= @modiTime	--修改时间
							where borrowSingleID = @borrowSingleID--借支单ID
	set @Ret = 0
	--if @@ERROR <> 0 
	----插入明细表：
	--declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '编辑借支单单', '系统根据用户' + @modiManName + 
					'的要求修改了借支单[' + @borrowSingleID + ']。')
GO




drop PROCEDURE lockborrowSingleEdit
/*
	name:		borrowSingle
	function:	锁定借支单编辑，避免编辑冲突
	input: 
				@@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的借支单不存在，2:要锁定的借支单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockborrowSingleEdit
				@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的借支单是否存在
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = (select lockManID from borrowSingle
					where borrowSingleID = @borrowSingleID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update borrowSingle
	set lockManID = @lockManID 
	where borrowSingleID= @borrowSingleID

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
	values(@lockManID, @lockManName, getdate(), '锁定借支单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了借支单['+ @borrowSingleID +']为独占式编辑。')
GO


drop PROCEDURE unlockborrowSingleEdit
/*
	name:		borrowSingle
	function:	释放锁定借支单编辑，避免编辑冲突
	input: 
				@@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
												0:成功，1：该借支单不存在，2：锁定该单据的人不是自己，8:该单据未被锁定,9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockborrowSingleEdit
				@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的借支单是否存在
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = isnull((select lockManID from borrowSingle where borrowSingleID= @borrowSingleID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--释放借支单锁定
			update borrowSingle set lockManID = '' where borrowSingleID = @borrowSingleID
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
				values(@lockManID, @lockManName, getdate(), '释放借支单编辑', '系统根据用户' + @lockManName	+ '的要求释放了借支单['+ @borrowSingleID +']的编辑锁。')
		end
	else   --返回该借支单未被任何人锁定
		begin
			set @Ret = 8
			return
		end

GO



drop PROCEDURE delborrowSingle
/*
	name:		delborrowSingle
	function:	删除指定借支单
	input: 
				@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1：指定的借支单不存在，
							2:要删除的借支单正被别人锁定，
							3:该单据已经批复，不能删除，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE delborrowSingle
				@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要删除的借支单是否存在
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
	if (@count = 0)	--不存在
		begin
			set @Ret = 1
			return
		end

	--查询借支单是否为审核状态
	declare @thisflowProgress smallint
	set @thisflowProgress = (select flowProgress from borrowSingle where borrowSingleID = @borrowSingleID)
	if (@thisflowProgress<>0)
		begin
			set @Ret = 3
			return
		end

	--检查编辑锁：
	declare @thisLockMan varchar(14)
	set @thisLockMan = (select lockManID from borrowSingle
					where borrowSingleID = @borrowSingleID)
					
	if (@thisLockMan<>'')
		begin
			set @lockManID = @thisLockMan
			set @Ret = 2
			return
		end
	--删除指定借支单
	delete borrowSingle
	where borrowSingleID= @borrowSingleID
	--判断有无错误
	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
	
	set @Ret = 0


	----取维护人的姓名：
	declare @lockManName nvarchar(30)
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @lockManName = '卢嘉诚'
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '删除借支单', '系统根据用户' + @lockManName
												+ '删除了借支单['+ @borrowSingleID +']。')
GO

drop PROCEDURE examineborrowSingle
/*
	name:		borrowSingle
	function:	审核借支单
	input: 
				@borrowSingleID varchar(15),			--借支单ID
				@ApprovalDetailsID varchar(16)	ouput,	--审批详情ID，使用号码发生器生成
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的借支单不存在，2:要锁定的借支单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockborrowSingleEdit
				@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的借支单是否存在
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(14)
	set @count = (select COUNT(*) from borrowSingle
					where borrowSingleID = @borrowSingleID
					and	  ISNULL(lockManID,'')<>'')
	if (@count>0)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update borrowSingle
	set lockManID = @lockManID 
	where borrowSingleID= @borrowSingleID
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
	values(@lockManID, @lockManName, getdate(), '锁定借支单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了借支单['+ @borrowSingleID +']为独占式编辑。')
GO


-- 报销单
drop table ExpRemSingle 
create table ExpRemSingle(
	ExpRemSingleID varchar(15) not null,  --报销单编号
	departmentID varchar(13) not null,	--部门ID
	ExpRemDepartment varchar(20)	not null,	--报销部门
	ExpRemDate smalldatetime not null,	--报销日期
	projectID varchar(13) not null,	--项目ID
	projectName varchar(50) not null,	--项目名称
	ExpRemSingleNum int ,	--报销单据及附件
	note varchar(200),	--备注
	expRemSingleType smallint default(0) not null,	--报销单类型，0：费用报销单，1：差旅费报销单
	amount money not null,	--合计金额
	borrowSingleID varchar(15) ,	--原借支单ID
	originalloan money ,	--原借款
	replenishment money ,	--应补款
	shouldRefund money ,	--应退款
	ExpRemPersonID varchar(14) not null,	--报销人编号
	ExpRemPerson varchar(10)	not	null,	--报销人姓名
	businessPeopleID	varchar(14)  ,	--出差人编号
	businessPeople	varchar(10),	--出差人
	businessReason varchar(200),	--出差事由
	approvalProgress smallint default(0) not null,	--审批进度
	IssueSituation smallint default(0) ,	--发放情况
	paymentMethodID varchar(13)	,	--付款账户ID
	paymentMethod varchar(50),		--付款账户
	paymentSum money,	--付款金额
	draweeID varchar(13),	--付款人ID
	drawee	varchar(10),	--付款人
	
	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(13) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(13) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(13)				--当前正在锁定编辑的人工号
	 CONSTRAINT [PK_ExpRemSingle] PRIMARY KEY CLUSTERED 
(
	[ExpRemSingleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



--差旅费报销详情
drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsID varchar(18) not null,	--差旅费报销详情ID
ExpRemSingleID varchar(15) not null,	--报销单编号
StartDate smalldatetime	not null,	--起始时间
endDate smalldatetime not null,	--结束日期
startingPoint varchar(12) not null,	--起点
destination varchar(12) not null,	--终点
vehicle		varchar(12)	not null,	--交通工具
documentsNum	int	not null,	--单据张数
vehicleSum	money not null,	--交通费金额
financialAccountID	varchar(13)	not null,	--科目ID
financialAccount	varchar(20) not null,	--科目名称
peopleNum	int not null,	--人数
travelDays float ,	-- 出差天数
TravelAllowanceStandard	money,	--出差补贴标准
travelAllowancesum	money	not null,	--补贴金额
otherExpenses	varchar(20) null,	--其他费用
otherExpensesSum	money	null,	--其他费用金额
--外键
foreign key(ExpRemSingleID) references ExpRemSingle(ExpRemSingleID) on update cascade on delete cascade,
--主键
	 CONSTRAINT [PK_TravelExpensesDetails] PRIMARY KEY CLUSTERED 
(
	[TravelExpensesDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--报销详情表
drop table ExpenseReimbursementDetails 
create table ExpenseReimbursementDetails(
ExpRemDetailsID	varchar(17)	not null,	--报销详情ID
ExpRemSingleID	varchar(15)	not null,	--报销单ID
abstract	varchar(100)	not null,	--摘要
supplementaryExplanation	varchar(100)	not null,	--补充说明
financialAccountID	varchar(13)	not null,	--报销科目ID
financialAccount	varchar(200)	not null,	--报销科目
expSum	money	not null,	--金额
--外键
foreign key(ExpRemSingleID) references ExpRemSingle(ExpRemSingleID) on update cascade on delete cascade,
--主键
	 CONSTRAINT [PK_ExpRemDetails] PRIMARY KEY CLUSTERED 
(
	[ExpRemDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--添加费用报销单
drop PROCEDURE addExpRemSingle
/*
	name:		addExpRemSingle
	function:	1.添加费用报销单
				注意：本存储过程不锁定编辑！
	input: 
				@ExpRemSingleID varchar(15) not null,  --报销单编号
				@departmentID varchar(13) not null,	--部门ID
				@ExpRemDepartment varchar(20)	not null,	--报销部门
				@ExpRemDate smalldatetime not null,	--报销日期
				@projectID varchar(13) not null,	--项目ID
				@projectName varchar(50) not null,	--项目名称
				@ExpRemSingleNum int ,	--报销单据及附件
				@note varchar(200),	--备注
				@expRemSingleType smallint default,	--报销单类型，0：费用报销单，1：差旅费报销单
				@amount money not null,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan money not null,	--原借款
				@replenishment money not null,	--应补款
				@shouldRefund money not null,	--应退款
				@ExpRemPersonID varchar(14) not null,	--报销人编号
				@ExpRemPerson varchar(10)	not	null,	--报销人姓名
				@businessPeopleID	varchar(14) not null,	--出差人编号
				@businessPeople	varchar(10) not null,	--出差人
				@businessReason varchar(200)	not null,	--出差事由
				@approvalProgress smallint default(0) not null,	--审批进度

			@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addExpRemSingle			
				@departmentID varchar(13) ,	--部门ID
				@ExpRemDepartment varchar(20)	,	--报销部门
				@ExpRemDate smalldatetime ,	--报销日期
				@projectID varchar(13) ,	--项目ID
				@projectName varchar(50) ,	--项目名称
				@ExpRemSingleNum smallint ,	--报销单据及附件
				@note varchar(200),	--备注
				@expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				@amount money ,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan money ,	--原借款
				@replenishment money ,	--应补款
				@shouldRefund money ,	--应退款
				@ExpRemPersonID varchar(14) ,	--报销人编号
				@ExpRemPerson varchar(10),	--报销人姓名
				@businessPeopleID	varchar ,	--出差人编号
				@businessPeople	varchar(10) ,	--出差人
				@businessReason varchar(200)	,	--出差事由
				@approvalProgress smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

	@createManID varchar(13),		--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@ExpRemSingleID varchar(15) output	--主键：报销单编号，使用第 号号码发生器产生
	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 403, 1, @curNumber output
	set @ExpRemSingleID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()

	insert ExpRemSingle(ExpRemSingleID,		--报销单ID
							departmentID,	--部门ID
							ExpRemDepartment,		--报销部门
							ExpRemDate,		--报销日期
							projectID,	--项目ID
							projectName,	--项目名称
							ExpRemSingleNum,	--报销单据及附件
							note,			--备注
							expRemSingleType,	--报销单类型，0：费用报销单，1：差旅费报销单
							amount,			--合计金额
							borrowSingleID,	--原借支单ID
							originalloan,	--原借款
							replenishment,	--应补款
							shouldRefund,	--应退款
							ExpRemPersonID,	--报销人ID
							ExpRemPerson,	--报销人姓名
							businessPeopleID,	--出差人ID
							businessPeople,		--出差人
							businessReason,		--出差事由
							approvalProgress	--审批进度:0：新建，1：待审批，2：审批中,3:已审结
							) 
	values (	@ExpRemSingleID,
				@departmentID ,	
				@ExpRemDepartment,
				@ExpRemDate,
				@projectID,
				@projectName,
				@ExpRemSingleNum,
				@note,
				@expRemSingleType,
				@amount,
				@borrowSingleID,
				@originalloan,
				@replenishment,
				@shouldRefund ,
				@ExpRemPersonID,
				@ExpRemPerson ,
				@businessPeopleID,
				@businessPeople,
				@businessReason ,
				@approvalProgress ) 


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
	values(@createManID, @createManName, @createTime, '添加报销单', '系统根据用户' + @createManName + 
		'的要求添加了报销单[' + @ExpRemSingleID + ']。')		
GO



--添加费用报销单详情
drop PROCEDURE addExpenseReimbursementDetails
/*
	name:		addExpenseReimbursementDetails
	function:	1.添加费用报销单详情
				注意：本存储过程不锁定编辑！
	input: 
				ExpRemDetailsID	varchar(17)	not null,	--报销详情ID
				ExpRemSingleID	varchar(16)	not null,	--报销单ID
				abstract	varchar(100)	not null,	--摘要
				supplementaryExplanation	varchar(100)	not null,	--补充说明
				financialAccountID	varchar(13)	not null,	--报销科目ID
				financialAccount	varchar(200)	not null,	--报销科目
				expSum	float	not null,	--金额

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addExpenseReimbursementDetails			
				@ExpRemSingleID	varchar(15),	--报销单ID
				@abstract	varchar(100),	--摘要
				@supplementaryExplanation	varchar(100),	--补充说明
				@financialAccountID	varchar(13),	--报销科目ID
				@financialAccount	varchar(200),	--报销科目
				@expSum	money,	--金额

				@createManID varchar(13),		--创建人工号

				@Ret		int output,
				@createTime smalldatetime output,
				@ExpRemDetailsID varchar(17) output	--主键：报销详情ID，使用第404号号码发生器产生
	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 404, 1, @curNumber output
	set @ExpRemDetailsID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()

	insert ExpenseReimbursementDetails(
				ExpRemDetailsID,			--报销详情ID
				ExpRemSingleID,				--报销单ID
				abstract,					--摘要
				supplementaryExplanation,	--补充说明
				financialAccountID,			--报销科目ID
				financialAccount,			--报销科目
				expSum						--金额
							) 
	values (		
				@ExpRemDetailsID,			--报销详情ID
				@ExpRemSingleID,				--报销单ID
				@abstract,					--摘要
				@supplementaryExplanation,	--补充说明
				@financialAccountID,			--报销科目ID
				@financialAccount,			--报销科目
				@expSum						--金额 
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
	values(@createManID, @createManName, @createTime, '添加费用报销详情', '系统根据用户' + @createManName + 
		'的要求添加了费用报销详情[' + @ExpRemDetailsID + ']。')		
GO

--添加差旅费报销详情
drop PROCEDURE addTravelExpensesDetails
/*
	name:		addTravelExpensesDetails
	function:	1.添加差旅费报销详情
				注意：本存储过程不锁定编辑！
	input: 
				TravelExpensesDetailsID varchar(18) not null,	--差旅费报销详情ID
				ExpRemSingleID varchar(15) not null,	--报销单编号
				StartDate smalldatetime	not null,	--起始时间
				endDate smalldatetime not null,	--结束日期
				startingPoint varchar(12) not null,	--起点
				destination varchar(12) not null,	--终点
				vehicle		varchar(12)	not null,	--交通工具
				documentsNum	int	not null,	--单据张数
				vehicleSum	money not null,	--交通费金额
				financialAccountID	varchar(13)	not null,	--科目ID
				financialAccount	varchar(20) not null,	--科目名称
				peopleNum	int not null,	--人数
				travelDays float ,	-- 出差天数
				TravelAllowanceStandard	money,	--出差补贴标准
				travelAllowancesum	money	not null,	--补贴金额
				otherExpenses	varchar(20) null,	--其他费用
				otherExpensesSum	money	null,	--其他费用金额

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addTravelExpensesDetails			
				@ExpRemSingleID varchar(15),	--报销单编号
				@StartDate smalldatetime,	--起始时间
				@endDate smalldatetime,	--结束日期
				@startingPoint varchar(12),	--起点
				@destination varchar(12),	--终点
				@vehicle		varchar(12),	--交通工具
				@documentsNum	int,	--单据张数
				@vehicleSum	money,	--交通费金额
				@financialAccountID	varchar(13),	--科目ID
				@financialAccount	varchar(20),	--科目名称
				@peopleNum	int,	--人数
				@travelDays float,	-- 出差天数
				@TravelAllowanceStandard money,	--出差补贴标准
				@travelAllowancesum	money,	--补贴金额
				@otherExpenses	varchar(20),	--其他费用
				@otherExpensesSum	money,	--其他费用金额

				@createManID varchar(13),		--创建人工号

				@Ret		int output,
				@createTime smalldatetime output,
				@TravelExpensesDetailsID varchar(18) output	--主键：差旅费报销详情ID，使用第405号号码发生器产生
	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 405, 1, @curNumber output
	set @TravelExpensesDetailsID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()

	insert TravelExpensesDetails(
				TravelExpensesDetailsID,	--差旅费报销详情
				ExpRemSingleID,			--报销单编号
				StartDate,					--起始时间
				endDate,					--结束日期
				startingPoint,				--起点
				destination,				--终点
				vehicle,					--交通工具
				documentsNum,				--单据张数
				vehicleSum,				--交通费金额
				financialAccountID,		--科目ID
				financialAccount,			--科目名称
				peopleNum,					--人数
				travelDays,				--出差天数
				TravelAllowanceStandard,	--出差补贴标准
				travelAllowancesum,		--补贴金额
				otherExpenses,				--其他费用
				otherExpensesSum			--其他费用金额
							) 
	values (	
				@TravelExpensesDetailsID,	--差旅费报销详情
				@ExpRemSingleID,			--报销单编号
				@StartDate,					--起始时间
				@endDate,					--结束日期
				@startingPoint,				--起点
				@destination,				--终点
				@vehicle,					--交通工具
				@documentsNum,				--单据张数
				@vehicleSum,				--交通费金额
				@financialAccountID,		--科目ID
				@financialAccount,			--科目名称
				@peopleNum,					--人数
				@travelDays,				--出差天数
				@TravelAllowanceStandard,	--出差补贴标准
				@travelAllowancesum,		--补贴金额
				@otherExpenses,				--其他费用
				@otherExpensesSum			--其他费用金额
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
	values(@createManID, @createManName, @createTime, '添加差旅费报销详情', '系统根据用户' + @createManName + 
		'的要求添加了差旅费报销详情[' + @TravelExpensesDetailsID + ']。')		
GO


--删除报销单
drop PROCEDURE delExpRemSingle
/*
	name:		delExpRemSingle
	function:	删除报销单
	input: 
				@ExpRemSingleID varchar(15),			--报销单ID
				@lockManID varchar(13) output,	--锁定人，如果当前报销单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的借支单不存在，
							2:要删除的借支单正被别人锁定，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE delExpRemSingle
				@ExpRemSingleID varchar(15),			--报销单ID
				@lockManID varchar(13) output,	--锁定人，如果当前报销单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识，0：删除报销单成功，1：该报销单不存在，2：该报销单已被人锁定，无法删除，3：该报销单为审核状态无法删除
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要删除的报销单是否存在
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	--不存在
		begin
			set @Ret = 1
			return
		end
	--判断审核状态
	declare @thisProgress smallint
	set @thisProgress = (select approvalProgress from ExpRemSingle
					where ExpRemSingleID = @ExpRemSingleID)
	if (@thisProgress<>0)
		begin
			set @Ret = 3
			return
		end
	--检查编辑锁：
	declare @thisLockMan varchar(14)
	set @thisLockMan = (select lockManID from ExpRemSingle
					where ExpRemSingleID = @ExpRemSingleID)
					
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@lockManID)
				begin
					set @lockManID = @thisLockMan
					set @Ret = 2
					return
				end
				--删除指定报销单
			delete FROM ExpRemSingle where ExpRemSingleID= @ExpRemSingleID
			--判断有无错误
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				return
			end    
	
			set @Ret = 0
		end
	

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @lockManName = '卢嘉诚'
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '删除报销单', '系统根据用户' + @lockManName
												+ '删除了报销单['+ @ExpRemSingleID +']。')
GO



drop PROCEDURE lockExpRemSingleEdit
/*
	name:		lockExpRemSingleEdit
	function:	锁定报销单编辑，避免编辑冲突
	input: 
				@ExpRemSingleID varchar(15),			--报销单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的借支单不存在，2:要锁定的借支单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockExpRemSingleEdit
				@ExpRemSingleID varchar(15),			--报销单ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = (select lockManID from ExpRemSingle
					where ExpRemSingleID = @ExpRemSingleID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update ExpRemSingle
	set lockManID = @lockManID 
	where ExpRemSingleID= @ExpRemSingleID

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
	values(@lockManID, @lockManName, getdate(), '锁定报销单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了报销单['+ @ExpRemSingleID +']为独占式编辑。')
GO


drop PROCEDURE unlockExpRemSingleEdit
/*
	name:		unlockExpRemSingleEdit
	function:	释放锁定报销单编辑，避免编辑冲突
	input: 
				@ExpRemSingleID varchar(15),			--报销单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的借支单不存在，2:要锁定的借支单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockExpRemSingleEdit
				@ExpRemSingleID varchar(15),			--报销单ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = isnull((select lockManID from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--释放报销单锁定
			update ExpRemSingle set lockManID = '' where ExpRemSingleID = @ExpRemSingleID
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
				values(@lockManID, @lockManName, getdate(), '释放报销单编辑', '系统根据用户' + @lockManName	+ '的要求释放了报销单['+ @ExpRemSingleID +']的编辑锁。')
		end
	else   --返回该借支单未被任何人锁定
		begin
			set @Ret = 8
			return
		end

GO


drop PROCEDURE editExpRemSingle
/*
	name:		editExpRemSingle
	function:	1.编辑报销单
				注意：本存储过程不锁定编辑！
	input: 
				@ExpRemSingleID varchar(15),  --报销单ID			
				@departmentID varchar(13) ,	--部门ID
				@ExpRemDepartment varchar(20)	,	--报销部门
				@ExpRemDate smalldatetime ,	--报销日期
				@projectID varchar(13) ,	--项目ID
				@projectName varchar(50) ,	--项目名称
				@ExpRemSingleNum smallint ,	--报销单据及附件
				@note varchar(200),	--备注
				@expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				@amount money ,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan money ,	--原借款
				@replenishment money ,	--应补款
				@shouldRefund money ,	--应退款
				@ExpRemPersonID varchar(14) ,	--报销人编号
				@ExpRemPerson varchar(10),	--报销人姓名
				@businessPeopleID	varchar ,	--出差人编号
				@businessPeople	varchar(10) ,	--出差人
				@businessReason varchar(200)	,	--出差事由
				@approvalProgress smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

				@lockManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该借支单已被锁定，2：该借支单为审核状态9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by 
*/
create PROCEDURE editExpRemSingle	
				@ExpRemSingleID varchar(15),  --报销单ID			
				@departmentID varchar(13) ,	--部门ID
				@ExpRemDepartment varchar(20)	,	--报销部门
				@ExpRemDate smalldatetime ,	--报销日期
				@projectID varchar(13) ,	--项目ID
				@projectName varchar(50) ,	--项目名称
				@ExpRemSingleNum smallint ,	--报销单据及附件
				@note varchar(200),	--备注
				@expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				@amount money ,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan money ,	--原借款
				@replenishment money ,	--应补款
				@shouldRefund money ,	--应退款
				@ExpRemPersonID varchar(14) ,	--报销人编号
				@ExpRemPerson varchar(10),	--报销人姓名
				@businessPeopleID	varchar ,	--出差人编号
				@businessPeople	varchar(10) ,	--出差人
				@businessReason varchar(200)	,	--出差事由
				@approvalProgress smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

				@lockManID  varchar(13),		--锁定人ID
				@Ret		int output			--成功表示，0：成功，1：该单据已被其他用户锁定，2：该单据处于审核状态无法编辑，3：该单据不存在
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断要锁定的报销单是否存在
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	    --不存在
	begin
		set @Ret = 3
		return
	end
	--查询报销单是否为审核状态
	declare @thisflowProgress smallint
	set @thisflowProgress = (select approvalProgress from ExpRemSingle where ExpRemSingleID = @ExpRemSingleID)
	if (@thisflowProgress<>0)
		begin
			set @Ret = 2
			return
		end

	--检查编辑的报销单是否有编辑锁或长事务锁：
	declare @thislockMan varchar(13)
	set @thislockMan = (select lockManID from ExpRemSingle
					where ExpRemSingleID = @ExpRemSingleID)
						
	if (@thislockMan<>'')
		if(@thislockMan<>@lockManID)
		begin
			set @Ret = 1
			set @lockManID = @thislockMan
			return
		end
			
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	update ExpRemSingle set		
				departmentID = @departmentID,	--部门ID
				ExpRemDepartment = @ExpRemDepartment,	--报销部门
				ExpRemDate = @ExpRemDate,	--报销日期
				projectID = @projectID,	--项目ID
				projectName = @projectName,	--项目名称
				ExpRemSingleNum = @ExpRemSingleNum,	--报销单据及附件
				note = @note,	--备注
				expRemSingleType = @expRemSingleType,	--报销单类型，0：费用报销单，1：差旅费报销单
				amount = @amount,	--合计金额
				borrowSingleID = @borrowSingleID,	--原借支单ID
				originalloan = @originalloan,	--原借款
				replenishment = @replenishment,	--应补款
				shouldRefund = @shouldRefund,	--应退款
				ExpRemPersonID = @ExpRemPersonID,	--报销人编号
				ExpRemPerson = @ExpRemPerson,	--报销人姓名
				businessPeopleID = @businessPeopleID,	--出差人编号
				businessPeople = @businessPeople,	--出差人
				businessReason = @businessReason,	--出差事由
				approvalProgress = @approvalProgress	--审批进度:0：新建，1：待审批，2：审批中,3:已审结
				where ExpRemSingleID = @ExpRemSingleID--报销单ID
	set @Ret = 0
	if @@ERROR <> 0 
	----插入明细表：
	--declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName,  getdate(), '编辑报销单', '系统根据用户' + @createManName + 
					'的要求编辑了报销单单[' + @ExpRemSingleID + ']。')
GO




--附件表
drop table enclosure 
create table enclosure(
enclosureID	varchar(15)	not	null,	--附件编号
billType	 smallint default(0)	not	null,	--票据类型：0，借支单，1：报销单
billID	varchar(15)	not	null,	--票据编号
enclosureAddress	varchar(200)	not	null,	--附件地址
enclosureType	 smallint default(0)	not	null,	--附件类型
--主键
	 CONSTRAINT [PK_enclosure] PRIMARY KEY CLUSTERED 
(
	enclosureID ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--添加附件
drop PROCEDURE addEnclosure
/*
	name:		addEnclosure
	function:	1.添加附件
				注意：本存储过程不锁定编辑！
	input: 
				enclosureID	varchar(15)	not	null,	--主键：附件ID，使用第406号号码发生器产生
				billType	 smallint default(0)	not	null,	--票据类型：0，借支单，1：报销单
				billID	varchar(15)	not	null,	--票据编号
				enclosureAddress	varchar(200)	not	null,	--附件地址
				enclosureType	 smallint default(0)	not	null,	--附件类型

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addEnclosure			
				@enclosureID varchar(15) output,	--主键：附件ID，使用第406号号码发生器产生
				@billType	 smallint,	--票据类型：0，借支单，1：报销单
				@billID	varchar(15),	--票据编号
				@enclosureAddress	varchar(200),	--附件地址
				@enclosureType	 smallint,	--附件类型

				@createManID varchar(13),		--创建人工号

				@Ret		int output,
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 406, 1, @curNumber output
	set @enclosureID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()

	insert enclosure(
				enclosureID,		--主键：附件ID，使用第406号号码发生器产生
				billType,			--票据类型：0，借支单，1：报销单
				billID,				--票据编号
				enclosureAddress,	--附件地址
				enclosureType		--附件类型
							) 
	values (		
				@enclosureID,		--主键：附件ID，使用第406号号码发生器产生
				@billType,			--票据类型：0，借支单，1：报销单
				@billID,			--票据编号
				@enclosureAddress,	--附件地址
				@enclosureType		--附件类型
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
	values(@createManID, @createManName, @createTime, '添加附件', '系统根据用户' + @createManName + 
		'的要求添加了附件[' + @enclosureID + ']。')		
GO


--删除附件
drop PROCEDURE delEnclosure
/*
	name:		delEnclosure
	function:	1.删除附件
				注意：本存储过程不锁定编辑！
	input: 
				enclosureID	varchar(15)	not	null,	--主键：附件ID
				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		  --成功标示，0：成功，1：该附件不存在,9:未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE delEnclosure			
				@enclosureID varchar(15),	--主键：附件ID
				@createManID varchar(13),		--创建人工号

				@Ret		int output,			--成功标示，0：成功，1：该附件不存在,9:未知错误
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()
		
	--判断要删除的附件是否存在
	declare @count as int
	set @count=(select count(*) from enclosure where enclosureID= @enclosureID)	
	if (@count = 0)	--不存在
		begin
			set @Ret = 1
			return
		end
	--删除附件
	delete FROM enclosure where enclosureID= @enclosureID 


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
	values(@createManID, @createManName, @createTime, '删除附件', '系统根据用户' + @createManName + 
		'的要求删除了附件[' + @enclosureID + ']。')		
GO




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





--科目管理表
drop table subjectList 
create table subjectList(
FinancialSubjectID	varchar(13)	not	null,	--科目ID
classification	smallint default(0) not null,	--分类
superiorSubjectsID	varchar(13)	,	--上级科目ID
superiorSubjects varchar(50)	,	--上级科目名称
subjectName	varchar(50)	not null,	--科目名称
AccountNumber int not null,	--科目层数
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
				FinancialSubjectID	varchar(13)	not	null,	--科目ID
				classification	smallint default(0) not null,	--分类
				superiorSubjectsID	varchar(13)	,	--上级科目ID
				superiorSubjects varchar(50)	,	--上级科目名称
				subjectName	varchar(50)	not null,	--科目名称
				AccountNumber int not null,	--科目层数
				establishTime smalldatetime	not null,	--设立时间
				explain varchar(200)	null,	--说明

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addSubject			
				@FinancialSubjectID	varchar(13) output,	--科目ID,主键,使用407号号码发生器生成
				@classification	smallint,			--分类
				@superiorSubjectsID	varchar(13),	--上级科目ID
				@superiorSubjects varchar(50),		--上级科目名称
				@subjectName	varchar(50),		--科目名称
				@AccountNumber int ,				--科目层数
				@establishTime smalldatetime,		--设立时间
				@explain varchar(200),				--说明

				@createManID varchar(13),		--创建人工号

				@Ret		int output,
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 407, 1, @curNumber output
	set @FinancialSubjectID = @curNumber

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	set @createTime = getdate()

	insert subjectList(
				FinancialSubjectID,	--科目ID,主键,使用407号号码发生器生成
				classification,		--分类
				superiorSubjectsID,	--上级科目ID
				superiorSubjects,		--上级科目名称
				subjectName,			--科目名称
				AccountNumber,			--科目层数
				establishTime,			--设立时间
				explain,				--说明
				createManID,			--创建人工号
				createTime				--创建时间
							) 
	values (		
				@FinancialSubjectID,	--科目ID,主键,使用407号号码发生器生成
				@classification,		--分类
				@superiorSubjectsID,	--上级科目ID
				@superiorSubjects,		--上级科目名称
				@subjectName,			--科目名称
				@AccountNumber,			--科目层数
				@establishTime,			--设立时间
				@explain,				--说明
				@createManID,			--创建人工号
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
				FinancialSubjectID	varchar(13)	not	null,	--科目ID
				subjectName	varchar(50)	not null,			--科目名称
				explain varchar(200)	null,	--说明

				@lockManID varchar(10),		--锁定人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该科目已经被人锁定
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE editSubject			
				@FinancialSubjectID	varchar(13),	--科目ID
				@subjectName	varchar(50),		--科目名称
				@explain varchar(200),				--说明

				@lockManID varchar(13) output,				--锁定人工号

				@Ret		int output,
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
	declare @thislockMan varchar(13)
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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
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
				@FinancialSubjectID varchar(13),			--科目ID
				@lockManID varchar(13) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1：要锁定的科目不存在，
							2:要锁定的科目正在被别人编辑，
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockSubjectEdit
				@FinancialSubjectID varchar(13),			--科目ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
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
	set @lockManName = '卢嘉诚'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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
				@FinancialSubjectID varchar(13),			--科目ID
				@lockManID varchar(13) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1：要释放锁定的科目不存在，
							2:要释放锁定的科目正在被别人编辑，
							8：该科目未被任何人锁定
							9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockSubjectEdit
				@FinancialSubjectID varchar(13),			--科目ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
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
				--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				set @lockManName = '卢嘉诚'
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


--账户表
drop table accountList
create table accountList(
accountID 	varchar(13) not null,	--账户ID
accountName	varchar(50)	not null,	--账户名称
bankAccount	varchar(100) not null,	--开户行
accountCompany	varchar(100)	not null,	--开户名
accountOpening	varchar(50)	not	null,	--开户账号
bankAccountNum	varchar(50)	not null,	--开户行号
accountDate	smalldatetime	not	null,	--开户时间
administratorID	varchar(13)	,	--管理人ID
administrator	varchar(20)	,	--管理人(姓名）
branchAddress	varchar(100),	--支行地址
remarks	varchar(200),	--备注
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

--添加账户
drop PROCEDURE addAccountList
/*
	name:		addAccountList
	function:	1.添加账户
				注意：本存储过程不锁定编辑！
	input: 
				@accountID 	varchar(13) output,		--账户ID,主键,使用409号号码发生器生成
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(13),	--管理人ID
				@administrator	varchar(20),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该账户已存在，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE addAccountList			
				@accountID 	varchar(13) output,		--账户ID,主键,使用409号号码发生器生成
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(13),	--管理人ID
				@administrator	varchar(20),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注

				@createManID varchar(13),		--创建人工号

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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
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
				createTime		--创建时间
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
				@accountID 	varchar(13) output,		--账户ID,主键,使用409号号码发生器生成
				@lockManID varchar(13),		--锁定人ID
	output: 
				@Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该账户不存在，2：该账户被其他用户锁定，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE delAccountList			
				@accountID 	varchar(13) ,		--账户ID,主键
				@lockManID   varchar(13) output,		--锁定人ID

				@Ret		int output			--操作成功标示；0:成功，1：该账户不存在，2：该账户被其他用户锁定，9：未知错误

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

	--取维护人的姓名：
	declare @lockMan nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @lockMan = '卢嘉诚'
	declare @createTime smalldatetime
	set @createTime = getdate()

	delete from accountList where accountID = @accountID

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
	values(@lockManID, @lockMan, @createTime, '删除账户', '系统根据用户' + @lockMan + 
		'的要求删除了账户[' + @accountID + ']。')		
GO




--编辑账户
drop PROCEDURE editAccountList
/*
	name:		editAccountList
	function:	1.编辑账户
				注意：本存储过程锁定编辑！
	input: 
				@accountID 	varchar(13),		--账户ID,主键,使用409号号码发生器生成
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(13),	--管理人ID
				@administrator	varchar(20),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注

				@lockManID varchar(10)output,		--锁定人ID
	output: 
				@Ret		int output		--操作成功标示；0:成功，1：该账户不存在，2：该账户已被其他用户锁定，9：未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
*/

create PROCEDURE editAccountList			
				@accountID 	varchar(13),		--账户ID,主键,使用409号号码发生器生成
				@accountName	varchar(50),		--账户名称
				@bankAccount	varchar(100),		--开户行
				@accountCompany	varchar(100),	--开户名
				@accountOpening	varchar(50),	--开户账号
				@bankAccountNum	varchar(50),	--开户行号
				@accountDate	smalldatetime,	--开户时间
				@administratorID	varchar(13),	--管理人ID
				@administrator	varchar(20),	--管理人(姓名）
				@branchAddress	varchar(100),	--支行地址
				@remarks varchar(200),			--备注

				@lockManID varchar(13) output,		--锁定人ID

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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '卢嘉诚'
	declare @createTime smalldatetime
	set @createTime = getdate()

	update accountList set
				accountName = @accountName,			--账户名称
				bankAccount = @bankAccount,			--开户行
				accountCompany = accountCompany,	--开户名
				accountOpening = accountOpening,	--开户账号
				bankAccountNum = bankAccountNum,	--开户行号
				accountDate    = accountDate,		--开户时间
				administratorID = administratorID,	--管理人ID
				administrator  = administrator,		--管理人(姓名）
				branchAddress  = branchAddress,		--支行地址
				remarks = remarks,				--备注
				createManID = createManID,			--创建人工号
				createManName = createManName,		--创建人姓名
				createTime	= createTime			--创建时间
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
				@accountID varchar(13),		--账户ID
				@lockManID varchar(13) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要锁定的账户不存在，2:要锁定的账户正在被别人编辑，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountEdit
				@accountID varchar(13),		--账户ID
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
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
	declare @thisLockMan varchar(13)
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
	set @lockManName = '卢嘉诚'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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
				@accountID varchar(13),		--账户ID
				@lockManID varchar(13) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要释放锁定的账户不存在，2:要释放锁定的账户正在被别人编辑，8：该账户未被任何人锁定9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockAccountEdit
				@accountID varchar(13),			--账户ID
				@lockManID varchar(13) output,	--锁定人ID，如果当前账户正在被人占用编辑则返回该人的工号
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
	declare @thisLockMan varchar(13)
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
				--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				set @lockManName = '卢嘉诚'
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


--添加账户
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

--账户移交表
drop table accountTransferList
create table accountTransferList(
accountTransferID varchar(15)	not null,	--账户移交ID
handoverDate	smalldatetime	not null,	--移交日期
transferAccountID	varchar(13)	not	null,	--移交账户ID
transferAccount		varchar(30)	not null,	--移交账户
transferPersonID	varchar(13)	not null,	--移交人ID
transferPerson		varchar(20)	not null,	--移交人
handoverPersonID	varchar(13)	not	null,	--交接人ID
handoverPerson		varchar(20)	not	null,	--交接人
transferMatters		varchar(200),	--移交事项
remarks		varchar(200),	--备注
--外键
foreign key(transferAccountID) references accountList(accountID) on update cascade on delete cascade,
--主键
	 CONSTRAINT [PK_accountTransferID] PRIMARY KEY CLUSTERED 
(
	[accountTransferID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


drop PROCEDURE accountTransfer
/*
	name:		accountTransfer
	function: 	该存储过程锁定账户编辑，避免编辑冲突
	input: 
				@accountTransferID varchar(15) output,	--账户移交ID,主键，使用410号号码发生器生成
				@handoverDate	smalldatetime,	--移交日期
				@transferAccountID	varchar(13),	--移交账户ID
				@transferAccount	varchar(30),	--移交账户
				@transferPersonID	varchar(13),	--移交人ID
				@transferPerson	varchar(20),	--移交人
				@handoverPersonID	varchar(13),	--交接人ID
				@handoverPerson	varchar(20),	--交接人
				@transferMatters	varchar(200),	--移交事项
				@remarks		varchar(200),	--备注
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				
	output: 
				@Ret		int output		--操作成功标识0:成功，1：要移交的的账户不存在，2:要移交的的账户正在被别人锁定，9：未知错误
	author:		卢嘉诚
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE accountTransfer
				@accountTransferID varchar(15) output,	--账户移交ID,主键，使用410号号码发生器生成
				@handoverDate	smalldatetime,	--移交日期
				@transferAccountID	varchar(13),	--移交账户ID
				@transferAccount	varchar(30),	--移交账户
				@transferPersonID	varchar(13),	--移交人ID
				@transferPerson	varchar(20),	--移交人
				@handoverPersonID	varchar(13),	--交接人ID
				@handoverPerson	varchar(20),	--交接人
				@transferMatters	varchar(200),	--移交事项
				@remarks		varchar(200),	--备注
				@lockManID varchar(13) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
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
			--更改账户管理人
			update accountList set administratorID = @handoverPersonID,administrator =  @handoverPerson where accountID = @transferAccountID
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
									remarks			--备注
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
									@remarks			--备注
									)
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
				values(@lockManID, @lockManName, getdate(), '移交账户', '系统根据用户' + @lockManName	+ '的要求移交了账户，移交详情为['+ @accountTransferID +']。')
		end
	else
		begin
			set @Ret = 3
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