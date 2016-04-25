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

select * from borrowSingle where borrowSingleID = 'JZD201604250001'


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

select lockManID from borrowSingle
					where borrowSingleID = 'JZD201604250002'
					and	  ISNULL(lockManID,'')<>''

select COUNT(*) from borrowSingle
					where borrowSingleID = 'JZD201604250002'
					and	  ISNULL(lockManID,'')<>''


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


select count(*) from borrowSingle where borrowSingleID= 'JZD201604250002'

drop PROCEDURE delborrowSingle
/*
	name:		delborrowSingle
	function:	删除指定借支单
	input: 
				@borrowSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
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

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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


-- 费用报销单
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
	originalloan money not null,	--原借款
	replenishment money not null,	--应补款
	shouldRefund money not null,	--应退款
	ExpRemPersonID varchar(14) not null,	--报销人编号
	ExpRemPerson varchar(10)	not	null,	--报销人姓名
	businessPeopleID	varchar(14) not null,	--出差人编号
	businessPeople	varchar(10) not null,	--出差人
	businessReason varchar(200)	not null,	--出差事由
	approvalProgress smallint default(0) not null,	--审批进度
	IssueSituation smallint default(0) not null,	--发放情况
	paymentMethodID varchar(13)	,	--付款账户ID
	paymentMethod varchar(50),		--付款账户
	paymentSum money,	--付款金额
	draweeID varchar(13),	--付款人ID
	drawee	varchar(10),	--付款人
	
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
				@IssueSituation smallint default(0) not null,	--发放情况

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
				@ExpRemSingleNum int ,	--报销单据及附件
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

	@createManID varchar(10),		--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@ExpRemSingleID varchar(15) output	--主键：报销单编号，使用第 号号码发生器产生
	WITH ENCRYPTION 
AS
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @borrowSingleID = @curNumber

	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

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
	--插入明细表：
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加报销单', '系统根据用户' + @createManName + 
		'的要求添加了报销单[' + @ExpRemSingleID + ']。')
			
GO


drop PROCEDURE delExpRemSingle
/*
	name:		delExpRemSingle
	function:	删除报销单
	input: 
				@ExpRemSingleID varchar(15),			--报销单ID
				@expRemSingleType smallint,				--报销单类型，0：费用报销单，1：差旅费报销单
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
				@expRemSingleType smallint,				--报销单类型，0：费用报销单，1：差旅费报销单
				@lockManID varchar(13) output,	--锁定人，如果当前报销单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
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

	--检查编辑锁：
	declare @thisLockMan varchar(14)
	set @count = (select COUNT(*) from ExpRemSingle
					where ExpRemSingleID = @ExpRemSingleID
					and	  ISNULL(lockManID,'')<>'')
	if (@count>0)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--删除报销单详情
	if(@expRemSingleType=0)
		begin
			delete	from ExpenseReimbursementDetails where ExpRemSingleID= @ExpRemSingleID
		end
	else
		begin
			delete	from TravelExpensesDetails where ExpRemSingleID= @ExpRemSingleID	
	--删除指定报销单
	delete FROM ExpRemSingle where ExpRemSingleID= @ExpRemSingleID
	--判断有无错误
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
	values(@lockManID, @lockManName, getdate(), '删除报销单', '系统根据用户' + @lockManName
												+ '删除了报销单['+ @ExpRemSingleID +']。')
GO


drop PROCEDURE editExpRemSingle
/*
	name:		editExpRemSingle
	function:	1.编辑报销单
				注意：本存储过程不锁定编辑！
	input: 
				@ExpRemSingleID varchar(15) output	--主键：报销单编号，使用第 号号码发生器产生
				@departmentID varchar(13) ,	--部门ID
				@ExpRemDepartment varchar(20)	,	--报销部门
				@ExpRemDate smalldatetime ,	--报销日期
				@projectID varchar(13) ,	--项目ID
				@projectName varchar(50) ,	--项目名称
				@ExpRemSingleNum int ,	--报销单据及附件
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
create PROCEDURE editExpRemSingle				
				@departmentID varchar(13) ,	--部门ID
				@ExpRemDepartment varchar(20)	,	--报销部门
				@ExpRemDate smalldatetime ,	--报销日期
				@projectID varchar(13) ,	--项目ID
				@projectName varchar(50) ,	--项目名称
				@ExpRemSingleNum int ,	--报销单据及附件
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

	@createManID varchar(10),		--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@ExpRemSingleID varchar(15) output	--主键：报销单编号，使用第 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--查询报销单是否为审核状态
	declare @thisflowProgress smallint
	set @thisflowProgress = (select approvalProgress from ExpRemSingle where ExpRemSingleID = @ExpRemSingleID)
	if (@thisflowProgress<>0)
	begin
		set @Ret = 2
		return
	end

	--检查编辑的报销单是否有编辑锁或长事务锁：
	declare @count int
	set @count = (select COUNT(*) from ExpRemSingle
					where ExpRemSingleID = @ExpRemSingleID
					and	  ISNULL(lockManID,'')<>'')
						
	if (@count>0)
	begin
		set @Ret = 1
		return
	end


	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	update borrowSingle set
							departmentID = @departmentID,		--部门ID
							ExpRemDepartment = @ExpRemDepartment,		--报销部门
							ExpRemDate = @ExpRemDate,	--报销日期
							projectID = @projectID,		--项目ID
							projectName = @projectName,		--项目名称
							ExpRemSingleNum = @ExpRemSingleNum,	--报销单据及附件）
							note = @note,	--备注
							expRemSingleType = @expRemSingleType,		--报销单类型
							amount = @amount,	--合计金额
							borrowSingleID = @borrowSingleID,	--原借支单ID
							originalloan = @originalloan,	--原借款
							replenishment	= @replenishment,	--应补款
							shouldRefund	= @shouldRefund	,	--应退款
							ExpRemPersonID	=	@ExpRemPersonID,	--报销人ID
							ExpRemPerson	=	@ExpRemPerson,	--报销人姓名
							businessPeopleID	=	@businessPeopleID,	--出差人ID
							businessPeople	=	@businessPeople,	--出差人姓名
							businessReason	=	@businessReason	--出差事由
							where ExpRemSingleID = @ExpRemSingleID--报销单ID
	if @@ERROR <> 0 
	--插入明细表：
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '编辑报销单', '系统根据用户' + @createManName + 
					'的要求编辑了报销单单[' + @ExpRemSingleID + ']。')
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
ExpRemSingleID	varchar(16)	not null,	--报销单ID
abstract	varchar(100)	not null,	--摘要
supplementaryExplanation	varchar(100)	not null,	--补充说明
financialAccountID	varchar(13)	not null,	--报销科目ID
financialAccount	varchar(200)	not null,	--报销科目
expSum	float	not null,	--金额
)

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



--附件表
drop table enclosure 
create table enclosure(
enclosureID	varchar(15)	not	null,	--附件编号
billType	 smallint default(0)	not	null,	--票据类型：0，借支单，1：报销单
billID	varchar(15)	not	null,	--票据编号
enclosureAddress	varchar(200)	not	null,	--附件地址
enclosureType	 smallint default(0)	not	null,	--附件类型
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


--账户明细表
drop table accountDetailsList 
create table accountList(
AccountDetailsID	varchar(16)	not null,	--账户明细ID
accountID	varchar(13)	not null,	--账户ID
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
)
GO

--账户表
drop table accountList
create table accountList(
accountID	varchar(13) not null,	--账户ID
accountName	varchar(50)	not null,	--账户名称
bankAccount	varchar(100) not null,	--开户行
accountCompany	varchar(100)	not null,	--开户名
accountOpening	varchar(50)	not	null,	--开户账号
bankAccountNum	varchar(50)	not null,	--开户行号
accountDate	smalldatetime	not	null,	--开户时间
administratorID	varchar(13)	,	--管理人ID
administartor	varchar(20)	,	--管理人(姓名）
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
)
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
)

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
)

go

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
)

GO