-- 报销单
drop table ExpRemSingle 
create table ExpRemSingle(
	ExpRemSingleID varchar(13) not null,  --报销单编号
	departmentID varchar(13) not null,	--部门ID
	ExpRemDepartment varchar(30)	not null,	--报销部门
	ExpRemDate smalldatetime not null,	--报销日期
	projectID varchar(13) not null,	--项目ID
	projectName varchar(50) not null,	--项目名称
	ExpRemSingleNum varchar(13) ,	--报销单据(附件)
	note varchar(200),	--备注
	expRemSingleType smallint default(0) not null,	--报销单类型，0：费用报销单，1：差旅费报销单
	amount numeric(15,2) not null,	--合计金额
	borrowSingleID varchar(15) ,	--原借支单ID
	originalloan numeric(15,2) ,	--原借款
	replenishment numeric(15,2) ,	--应补款
	shouldRefund numeric(15,2) ,	--应退款
	ExpRemPersonID varchar(10) not null,	--报销人编号
	ExpRemPerson varchar(30)	not	null,	--报销人姓名
	businessPeopleID	varchar(10)  ,	--出差人编号
	businessPeople	varchar(30),	--出差人
	businessReason varchar(200),	--出差事由
	approvalStatus smallint default(0) not null,	--审批状态，0：未发起，1：审核中，2：审批完成
	IssueSituation smallint default(0) ,	--发放情况，0：未发放，1：以发放
	paymentMethodID varchar(13)	,	--付款账户ID
	paymentMethod varchar(50),		--付款账户
	paymentSum numeric(15,2),	--付款金额
	draweeID varchar(10),	--付款人ID
	drawee	varchar(30),	--付款人
	
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
	 CONSTRAINT [PK_ExpRemSingle] PRIMARY KEY CLUSTERED 
(
	[ExpRemSingleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--报销单审批详情
drop table AuditExpRemList      
create table AuditExpRemList(
	ApprovalDetailsID varchar(16)	not null,	--审批详情ID
	billID	varchar(13)	not null,	--报销单ID
	approvalStatus smallint default(0) not	null,	--审批情况（同意/不同意）
	approvalOpinions	varchar(200),	--审批意见
	examinationPeoplePost varchar(50),	--审批人职务
	examinationPeopleID	varchar(10),	--审批人ID
	examinationPeopleName	varchar(30)	--审批人名称
--外键
foreign key(billID) references ExpRemSingle(ExpRemSingleID) on update cascade on delete cascade,
--主键
 CONSTRAINT [PK_ExpRemSingleID_ApprovalDetailsID] PRIMARY KEY CLUSTERED 
(
	[ApprovalDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE AudiExpRemSingle
/*
	name:		AudiExpRemSingle
	function:	1.审核报销单
				注意：本存储过程不锁定编辑！
	input: 

			@billID	varchar(13),	--报销单ID
			@approvalStatus int,	--审批情况（同意/不同意）
			@approvalOpinions	varchar(200),	--审批意见
			@examinationPeoplePost varchar(50),	--审批人职务
			@examinationPeopleID	varchar(10),	--审批人ID
			@examinationPeopleName	varchar(30),	--审批人名称



	output: 
			@ApprovalDetailsID varchar(16) output,	--审批详情ID，主键，使用402号号码发生器生成
			@Ret		int output           --操作成功标识,0:成功，1：要审核的报销单不存在，2：该报销单正在被其他用户锁定，3：该报销单为处于审核状态，9：未知错误
			@createManID varchar(13) output,			--创建人ID
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-5-7

*/
create PROCEDURE AudiExpRemSingle				
			@ApprovalDetailsID varchar(16) output,	--审批详情ID，主键，使用402号号码发生器生成
			@billID	varchar(13),	--报销单ID
			@approvalStatus smallint,	--审批情况（同意/不同意）
			@approvalOpinions	varchar(200),	--审批意见
			@examinationPeoplePost varchar(50),	--审批人职务
			@examinationPeopleID	varchar(10),	--审批人ID
			@examinationPeopleName	varchar(30),	--审批人名称

			@createManID varchar(10) output,			--创建人ID
			@Ret		int output           --操作成功标识,0:成功，1：要审核的报销单不存在，2：该报销单正在被其他用户锁定，3：该报销单为处于审核状态，4：请先锁定报销单再审核避免冲突9：未知错误
	WITH ENCRYPTION 
AS

	--判断要审核的报销单是否存在
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @billID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查审核状态
	declare @thisperson smallint
	set @thisperson = (select approvalStatus from ExpRemSingle
					where ExpRemSingleID = @billID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>1)
	begin
		set @Ret = 3
		return
	end
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from ExpRemSingle
					where ExpRemSingleID = @billID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@createManID)
				begin
					set @createManID = @thisLockMan
					set @Ret = 2
					return
				end
			set @Ret = 9


			--使用402号码发生器产生新的号码：
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 402, 1, @curNumber output
			set @ApprovalDetailsID = @curNumber

	
			----取维护人的姓名：
			--declare @createManName nvarchar(30)
			--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			declare @createTime smalldatetime, @createManName varchar(30)
			set @createManName = '卢嘉诚'
			set @createTime = getdate()
			insert AuditExpRemList(
					ApprovalDetailsID,	--审批详情ID，主键，使用402号号码发生器生成
					billID,	--借支单ID
					approvalStatus,	--审批情况（同意/不同意）
					approvalOpinions,	--审批意见
					examinationPeoplePost,	--审批人职务
					examinationPeopleID,	--审批人ID
					examinationPeopleName	--审批人名称
									) 
			values (			
					@ApprovalDetailsID,	--审批详情ID，主键，使用402号号码发生器生成
					@billID,	--单据ID
					@approvalStatus,	--审批情况（同意/不同意）
					@approvalOpinions,	--审批意见
					@examinationPeoplePost,	--审批人职务
					@examinationPeopleID,	--审批人ID
					@examinationPeopleName	--审批人名称
					) 
			set @Ret = 0
			--if @@ERROR <> 0 
			--登记工作日志：
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@createManID,@createManName, @createTime, '审核报销单', '系统根据用户'+@createManName+'的要求审核了报销单，审批详情为[' + @ApprovalDetailsID + ']。')
		end
	else
		begin
		set @Ret = 4
		return
	end
GO

--差旅费报销详情
drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsID varchar(18) not null,	--差旅费报销详情ID
ExpRemSingleID varchar(13) not null,	--报销单编号
StartDate smalldatetime	not null,	--起始时间
endDate smalldatetime not null,	--结束日期
startingPoint varchar(20) not null,	--起点
destination varchar(20) not null,	--终点
vehicle		varchar(12)	not null,	--交通工具
documentsNum	int	not null,	--单据张数
vehicleSum	numeric(15,2) not null,	--交通费金额
financialAccountID	varchar(13)	not null,	--科目ID
financialAccount	varchar(20) not null,	--科目名称
peopleNum	int not null,	--人数
travelDays float ,	-- 出差天数
TravelAllowanceStandard	numeric(15,2),	--出差补贴标准
travelAllowancesum	numeric(15,2)	not null,	--补贴金额
otherExpenses	varchar(20) null,	--其他费用
otherExpensesSum	numeric(15,2)	null,	--其他费用金额
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
expSum	numeric(15,2)	not null,	--金额
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
				@amount numeric(15,2) not null,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan numeric(15,2) not null,	--原借款
				@replenishment numeric(15,2) not null,	--应补款
				@shouldRefund numeric(15,2) not null,	--应退款
				@ExpRemPersonID varchar(14) not null,	--报销人编号
				@ExpRemPerson varchar(10)	not	null,	--报销人姓名
				@businessPeopleID	varchar(14) not null,	--出差人编号
				@businessPeople	varchar(10) not null,	--出差人
				@businessReason varchar(200)	not null,	--出差事由
				@approvalStatus smallint default(0) not null,	--审批进度

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
				@amount numeric(15,2) ,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan numeric(15,2) ,	--原借款
				@replenishment numeric(15,2) ,	--应补款
				@shouldRefund numeric(15,2) ,	--应退款
				@ExpRemPersonID varchar(14) ,	--报销人编号
				@ExpRemPerson varchar(10),	--报销人姓名
				@businessPeopleID	varchar ,	--出差人编号
				@businessPeople	varchar(10) ,	--出差人
				@businessReason varchar(200)	,	--出差事由
				@approvalStatus smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

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
							approvalStatus	--审批进度:0：新建，1：待审批，2：审批中,3:已审结
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
				@approvalStatus ) 



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

--添加费用报销单(XML)
drop PROCEDURE addExpRemSingleForXML
/*
	name:		addExpRemSingleForXML
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
				@amount numeric(15,2) not null,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan numeric(15,2) not null,	--原借款
				@replenishment numeric(15,2) not null,	--应补款
				@shouldRefund numeric(15,2) not null,	--应退款
				@ExpRemPersonID varchar(14) not null,	--报销人编号
				@ExpRemPerson varchar(10)	not	null,	--报销人姓名
				@businessPeopleID	varchar(14) not null,	--出差人编号
				@businessPeople	varchar(10) not null,	--出差人
				@businessReason varchar(200)	not null,	--出差事由
				@approvalStatus smallint default(0) not null,	--审批进度
				@xVar XML,					--XML格式的详情

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

create PROCEDURE addExpRemSingleForXML			
				@departmentID varchar(13) ,	--部门ID
				@ExpRemDepartment varchar(20)	,	--报销部门
				@ExpRemDate smalldatetime ,	--报销日期
				@projectID varchar(13) ,	--项目ID
				@projectName varchar(50) ,	--项目名称
				@ExpRemSingleNum smallint ,	--报销单据及附件
				@note varchar(200),	--备注
				@expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				@amount numeric(15,2) ,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan numeric(15,2) ,	--原借款
				@replenishment numeric(15,2) ,	--应补款
				@shouldRefund numeric(15,2) ,	--应退款
				@ExpRemPersonID varchar(14) ,	--报销人编号
				@ExpRemPerson varchar(10),	--报销人姓名
				@businessPeopleID	varchar ,	--出差人编号
				@businessPeople	varchar(10) ,	--出差人
				@businessReason varchar(200)	,	--出差事由
				@approvalStatus smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结
				@xVar XML,					--XML格式的详情

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
							approvalStatus	--审批进度:0：新建，1：待审批，2：审批中,3:已审结
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
				@approvalStatus ) 
	if(@expRemSingleType =0)
		begin
			declare @temporaryDetails table(
			ExpRemDetailsID	varchar(17),	--报销详情ID
			ExpRemSingleID	varchar(15),	--报销单ID
			abstract	varchar(100),	--摘要
			supplementaryExplanation	varchar(100),	--补充说明
			financialAccountID	varchar(13),	--报销科目ID
			financialAccount	varchar(200),	--报销科目
			expSum	numeric(15,2)				--金额
			)
			insert @temporaryDetails
			select t.r.value('(@ExpRemSingleID)', 'varchar(15)') ExpRemSingleID,t.r.value('(@abstract)', 'varchar(100)') abstract,
			t.r.value('(@supplementaryExplanation)', 'varchar(100)') supplementaryExplanation,t.r.value('(@financialAccountID)', 'varchar(13)') financialAccountID,
			t.r.value('(@financialAccount)', 'varchar(200)') financialAccount,t.r.value('(@expSum)', 'numeric(15,2)') expSum
			from @xVar.nodes('root/row') as t(r)
			declare @ExpRemDetailsID varchar(17)
			declare tar cursor for select ExpRemDetailsID from @temporaryDetails
			open tar
			fetch next from tar into @ExpRemDetailsID
			while @@fetch_status = 0
				begin
					--生成报销详情ID
					exec dbo.getClassNumber 404, 1, @curNumber output
					set @ExpRemDetailsID = @curNumber
					Update @temporaryDetails Set ExpRemDetailsID=@ExpRemDetailsID Where Current of  tar
				end
			close tar
			deallocate tar
			insert ExpenseReimbursementDetails select * from @temporaryDetails
		end
	



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
				@expSum	numeric(15,2),	--金额

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
				vehicleSum	numeric(15,2) not null,	--交通费金额
				financialAccountID	varchar(13)	not null,	--科目ID
				financialAccount	varchar(20) not null,	--科目名称
				peopleNum	int not null,	--人数
				travelDays float ,	-- 出差天数
				TravelAllowanceStandard	numeric(15,2),	--出差补贴标准
				travelAllowancesum	numeric(15,2)	not null,	--补贴金额
				otherExpenses	varchar(20) null,	--其他费用
				otherExpensesSum	numeric(15,2)	null,	--其他费用金额

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
				@vehicleSum	numeric(15,2),	--交通费金额
				@financialAccountID	varchar(13),	--科目ID
				@financialAccount	varchar(20),	--科目名称
				@peopleNum	int,	--人数
				@travelDays float,	-- 出差天数
				@TravelAllowanceStandard numeric(15,2),	--出差补贴标准
				@travelAllowancesum	numeric(15,2),	--补贴金额
				@otherExpenses	varchar(20),	--其他费用
				@otherExpensesSum	numeric(15,2),	--其他费用金额

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
	set @thisProgress = (select approvalStatus from ExpRemSingle
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
				@amount numeric(15,2) ,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan numeric(15,2) ,	--原借款
				@replenishment numeric(15,2) ,	--应补款
				@shouldRefund numeric(15,2) ,	--应退款
				@ExpRemPersonID varchar(14) ,	--报销人编号
				@ExpRemPerson varchar(10),	--报销人姓名
				@businessPeopleID	varchar ,	--出差人编号
				@businessPeople	varchar(10) ,	--出差人
				@businessReason varchar(200)	,	--出差事由
				@approvalStatus smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

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
				@amount numeric(15,2) ,	--合计金额
				@borrowSingleID varchar(15) ,	--原借支单ID
				@originalloan numeric(15,2) ,	--原借款
				@replenishment numeric(15,2) ,	--应补款
				@shouldRefund numeric(15,2) ,	--应退款
				@ExpRemPersonID varchar(14) ,	--报销人编号
				@ExpRemPerson varchar(10),	--报销人姓名
				@businessPeopleID	varchar ,	--出差人编号
				@businessPeople	varchar(10) ,	--出差人
				@businessReason varchar(200)	,	--出差事由
				@approvalStatus smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

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
	set @thisflowProgress = (select approvalStatus from ExpRemSingle where ExpRemSingleID = @ExpRemSingleID)
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
				approvalStatus = @approvalStatus	--审批进度:0：新建，1：待审批，2：审批中,3:已审结
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