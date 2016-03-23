drop table borrowSingle 
create table borrwSingle(
	borrowSingleID varchar(13) not null,  --借支单号
	borrowDate smalldatetime	not null,	--借支时间
	employeeID varchar(11)	not null,		--员工编号
	position	varchar(10)	not null,	--职务
	borrowReason	varchar(200)	not null,	--借支事由
	borrowSum	float	not null,	--金额
	approved	varchar(16),	--核准
	accounting	varchar(16),	--会计
	cashier	varchar(16),	--出纳
	borrowMan	varchar(16),	--借支人
	department	varchar(16)	not null,	--部门
	documentTemplate	int default(0) not null,	---公文模板
	flowProgress	int default(0) not null,	--流转进度
	IssueSituation	int default(0) not null,	--发放情况
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
GO


drop PROCEDURE addborrowSingle
/*
	name:		addborrowSingle
	function:	1.添加报销单
				注意：本存储过程不锁定编辑！
	input: 
			@borrowDate varchar(10),		--借支时间								
			@employeeID varchar(11),		--员工编号
			@borrowName varchar(16),		--借支人姓名
			@position varchar(10),			--职务
			@borrowReason varchar(200),		--借支事由
			@borrowSum float,				--金额
			@borrowMan varchar(16),			--借支人
			@department nvarchar(16),		--部门
			@documentTemplate varchar(10),	--公文模板
			@flowProgress int,				--流转进度

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
	@borrowDate varchar(10),		--借支时间								
	@employeeID varchar(11),		--员工编号
	@borrowName varchar(16),		--借支人姓名
	@position varchar(10),			--职务
	@borrowReason varchar(200),		--借支事由
	@borrowSum float,				--金额
	@borrowMan varchar(16),			--借支人
	@department nvarchar(16),		--部门
	@documentTemplate varchar(10),	--公文模板
	@flowProgress int,				--流转进度

	@createManID varchar(10),		--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@borrowSingleID varchar(15) output	--主键：借支单号，使用第 3 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查调拨的设备是否有编辑锁或长事务锁：
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @alcApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end

	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @borrowSingleID = @curNumber

	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert borrowSingle(borrowSingleID,		--借支单号
							borrowDate,		--借支时间
							employeeID,		--员工编号
							borrowName,		--借支人姓名
							position,		--职务
							borrowReason,	--借支事由
							borrowSum,		--金额
							borrowMan,		--借支人
							department,		--部门
							documentTemplate,	--公文模板
							flowProgress,	--流转进度
							createManID,	--创建人工号
							createManName,	--创建人姓名
							createTime		--创建时间
							) 
	values (@borrowSingleID, 
			@borrowDate,
			@employeeID,
			@borrowName, 
			@position, 
			@borrowReason, 
			@borrowSum, 
			@borrowMan, 
			@department,
			@documentTemplate, 
			@flowProgress, 
			@createManID, 
			@createManName, 
			@createTime) 
	if @@ERROR <> 0 
	--插入明细表：
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加调拨申请单', '系统根据用户' + @createManName + 
					'的要求添加了借支单[' + @borrowSingleID + ']。')
GO



drop table ExpRemSingle 
create table ExpRemSingle(
	borrowSingleID varchar(15) not null,  --报销单编号
	expRemSingleID varchar(13) not null,	--部门编号
	projectID varchar(14) not null,	--项目编号
	projectName varchar(50) not null,	--项目名称
	ExpRemDate smalldatetime	not null,	--报销日期
	ExpRemSingleNum int ,	--报销单据及附件
	expRemSingleType int not null,	--报销单类型
	amount float not null,	--合计金额
	originalloan float not null,	--原借款
	replenishment float not null,	--应补款
	shouldRefund float not null,	--应退款
	expRemPerson varchar(10) not null,	--报销人
	expRemPersonID varchar(14) not null,	--报销人编号
	businessPeople	varchar(10) not null,	--出差人
	businessPeopleID	varchar(14) not null,	--出差人编号
	leadershipApproval varchar(10) not null,	--领导审批
	leadershipApprovalID varchar(14) not null,	--员工编号(领导)
	AccountingSupervisor varchar(10)	not null,	--会计主管
	AccountingSupervisorID varchar(14) not null,	--员工编号(会计主管)
	doubleChec varchar(10) not null,	--复核
	doubleChecID varchar (14),	--员工编号(复核)
	cashier varchar (10),	--出纳
	cashierID varchar(14),	--员工编号（出纳）
	businessReason varchar(200)	not null,	--出差事由
	approvalProgress int not null,	--审批进度
	IssueSituation int not null,	--发放情况
	note varchar(200),	--备注
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
GO


drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsIDd varchar(17) not null,	--差旅费报销详情
ExpRemSingleID varchar(15) not null,	--报销单编号
StartDate smalldatetime	not null,	--起始时间
endDate smalldatetime not null,	--结束日期
startingPoint varchar(20) not null,	--起点
destination varchar(20) not null,	--终点
vehicle		varchar(10)	not null,	--交通工具
documentsNum	int	not null,	--单据张数
projectID	varchar(14)	not null,	--项目编号
projectName	varchar(20)	not null,	--项目名称
expSum	float	not null,	--金额
peopleNum	int not null,	--人数
expDays	float	not null,	--天数
travelAllowanceStandard	float	not null,	--出差补贴标准
subsidyAmount	float	not null,	--补贴金额
otherExpenses	varchar(20) null,	--其他费用
otherExpensesSum	float	null,	--其他费用金额
)
GO


drop table ExpenseReimbursementDetails 
create table ExpenseReimbursementDetails(
ExpRemSingleID	varchar(15)	not null,	--报销单编号
ExpRemDetailsID	varchar(17)	not null,	--报销详情编号
projectID	varchar(14)	not null,	--报销项目
expRemProject	varchar(50)	not null,	--报销项目
abstract	varchar(100)	not null,	--摘要
expSum	float	not null,	--金额
)

GO

	
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

drop table VATinvoice 
create table VATinvoice(
enclosureID	varchar(14)	not	null,	--附件编号
billType	int	not	null,	--票据类型
billID	varchar(14)	not	null,	--票据编号
enclosureAddress	varchar(200)	not	null,	--附件地址
enclosureType	int	not	null,	--附件类型
)

drop table CashJournal 
create table CashJournal(
CashJournalDate	smalldatetime	not	null,	--日期
abstract	varchar(30)	not	null,	--摘要
debit	float	not	null,	--借记
credit	float	not	null,	--贷记
balance	float	not	null,	--余额
voucherNum	varchar(13),	--凭证号
paymentMethod	int	not	null,--支付方式
cashJournalID	varchar(13),	--现金日记编号
department	varchar(20),	--部门
project	varchar(50),	--项目
brokerage	varchar(16),	--经手人
remarks	varchar(200),	--备注
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


drop table VATinvoiceDetails 
create table VATinvoiceDetails(
VATinvoiceID	varchar(17)	not	null,	--增值税发票编号
goodsName	varchar(20)	not	null,	--货物或应税劳务、服务名称
SpecificationModel	int	not	null,	--规格型号
company	varchar(20)	not	null,	--单位
)