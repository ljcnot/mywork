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

--借支单审批详情
drop table AuditBorrowList      
create table AuditBorrowList(
	ApprovalDetailsID varchar(16)	not null,	--审批详情ID
	billID	varchar(15)	not null,	--借支单ID
	approvalStatus smallint default(0) not	null,	--审批情况（同意/不同意）
	approvalOpinions	varchar(200),	--审批意见
	examinationPeoplePost varchar(50),	--审批人职务
	examinationPeopleID	varchar(20),	--审批人ID
	examinationPeopleName	varchar(20)	--审批人名称
--外键
foreign key(billID) references borrowSingle(borrowSingleID) on update cascade on delete cascade,
--主键
 CONSTRAINT [PK_ AuditBorrow_ApprovalDetailsID] PRIMARY KEY CLUSTERED 
(
	[ApprovalDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--审核借支单
drop PROCEDURE AuditBorrowSingle
/*
	name:		AuditBorrowSingle
	function:	1.审核借支单
				注意：本存储过程不锁定编辑！
	input: 

			@billID	varchar(15),	--借支单ID
			@approvalStatus smallint,	--审批情况（0:同意,1:不同意）
			@approvalOpinions	varchar(200),	--审批意见
			@examinationPeoplePost varchar(50),	--审批人职务
			@examinationPeopleID	varchar(20),	--审批人ID
			@examinationPeopleName	varchar(20),	--审批人名称



	output: 
			@ApprovalDetailsID varchar(16) output,	--审批详情ID，主键，使用402号号码发生器生成
			@Ret		int output           --操作成功标识,0:成功，1：要审核的借支单不存在，2：该借支单正在被其他用户锁定，3：该借支单为处于审核状态，9：未知错误
			@createManID varchar(13) output,			--创建人ID
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-5-7

*/
create PROCEDURE AuditBorrowSingle				
			@ApprovalDetailsID varchar(16) output,	--审批详情ID，主键，使用402号号码发生器生成
			@billID	varchar(15),	--借支单ID
			@approvalStatus smallint,	--审批情况（0:同意,1:不同意）
			@approvalOpinions	varchar(200),	--审批意见
			@examinationPeoplePost varchar(50),	--审批人职务
			@examinationPeopleID	varchar(20),	--审批人ID
			@examinationPeopleName	varchar(20),	--审批人名称

			@createManID varchar(13) output,			--创建人ID
			@Ret		int output           --操作成功标识,0:成功，1：要审核的借支单不存在，2：该借支单正在被其他用户锁定，3：该借支单为处于审核状态，4:请先锁定该借支单再审核避免冲突，9：未知错误
	WITH ENCRYPTION 
AS

	--判断要审核的借支单是否存在
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @billID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查审核状态
	declare @thisperson varchar(13)
	set @thisperson = (select flowProgress from borrowSingle
					where borrowSingleID = @billID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>1)
	begin
		set @Ret = 3
		return
	end
	--检查编辑锁：
	declare @thisLockMan varchar(13)
	set @thisLockMan = (select lockManID from borrowSingle
					where borrowSingleID = @billID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@createManID)
				begin
					set @createManID = @thisLockMan
					set @Ret = 2
					return
				end
			


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
			insert AuditBorrowList(
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
			if @@ERROR <> 0 
			set @Ret = 9
			--登记工作日志：
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@createManID,@createManName, @createTime, '审核单据', '系统根据用户'+@createManName+'的要求审核了单据，审批详情为[' + @ApprovalDetailsID + ']。')
		end
	else
		begin
		set @Ret = 4
		return
		end
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