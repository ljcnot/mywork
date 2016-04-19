drop table borrowSingle      --��֧����
create table borrwSingle(
	borrowSingleID varchar(15) not null,  --��֧����
	borrowManID varchar(13)	not null,	--��֧��ID
	borrowMan varchar(20)	not null,		--��֧�ˣ�������
	position	varchar(10)	not null,	--ְ��
	departmentID	varchar(13)	not null,	--����ID
	department	varchar(16)	not null,	--����
	borrowDate	smalldatetime	not null,	--��֧ʱ��
	projectID	varchar(14),	--������ĿID
	projectName	varchar(200),	--������Ŀ�����ƣ�
	borrowReason	varchar(200),	--��֧����
	borrowSum	money,	--��֧���
	flowProgress smallint default(0),		--��ת���ȣ�0������ˣ�1�������У�2�������
	approvalOpinion	varchar(200)	not null,	--�������
	IssueSituation	smallint default(0) not null,	--�������
	paymentMethodID	varchar(16),	---���ʽID
	paymentMethod	varchar(14) ,	--���ʽ
	paymentSum	money,	--������
	draweeID varchar(13),	--������ID
	drawee varchar(14),		--������
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10)				--��ǰ���������༭���˹���
 CONSTRAINT [PK_borrwSingle] PRIMARY KEY CLUSTERED 
(
	[borrowSingleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpApplyDetail] WITH CHECK ADD CONSTRAINT [FK_eqpApplyDetail_eqpApplyInfo] FOREIGN KEY([eqpApplyID])
REFERENCES [dbo].[eqpApplyInfo] ([eqpApplyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO



drop table ApprovalDetailsList      --���������
create table ApprovalDetailsList(
	ApprovalDetailsID varchar(16)	not null,	--��������ID
	billID	varchar(17)	not null,	--����ID
	approvalStatus int not	null,	--���������ͬ��/��ͬ�⣩
	approvalOpinions	varchar(200),	--�������
	examinationPeoplePost varchar(50),	--������ְ��
	examinationPeopleID	varchar(20),	--������ID
	examinationPeopleName	varchar(20)	--����������
	)
GO


drop PROCEDURE addborrowSingle
/*
	name:		addborrowSingle
	function:	1.��ӱ�����
				ע�⣺���洢���̲������༭��
	input: 
			@borrowSingleID varchar(15) ,  --��֧����
			@borrowManID varchar(13)	,	--��֧��ID
			@borrowMan varchar(20)	,		--��֧�ˣ�������
			@position	varchar(10)	,	--ְ��
			@departmentID	varchar(13)	,	--����ID
			@department	varchar(16)	,	--����
			@borrowDate	smalldatetime	,	--��֧ʱ��
			@projectID	varchar(14),	--������ĿID
			@projectName	varchar(200),	--������Ŀ�����ƣ�
			@borrowReason	varchar(200),	--��֧����
			@borrowSum	money,	--��֧���
			@flowProgress varchar(10),		--��ת���ȣ�0������ˣ�1�������У�2�������

			@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE addborrowSingle				
			@borrowManID varchar(13)	,	--��֧��ID
			@borrowMan varchar(20)	,		--��֧�ˣ�������
			@position	varchar(10)	,	--ְ��
			@departmentID	varchar(13)	,	--����ID
			@department	varchar(16)	,	--����
			@borrowDate	smalldatetime	,	--��֧ʱ��
			@projectID	varchar(14),	--������ĿID
			@projectName	varchar(200),	--������Ŀ�����ƣ�
			@borrowReason	varchar(200),	--��֧����
			@borrowSum	money,	--��֧���
			@flowProgress smallint,		--��ת����

	@createManID varchar(10),		--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@borrowSingleID varchar(15) output	--��������֧���ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @borrowSingleID = @curNumber

	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert borrowSingle(borrowSingleID,		--��֧��ID
							borrowManID,	--��֧��ID
							borrowMan,		--��֧������
							position,		--ְ��
							departmentID,	--����
							borrowDate,		--��֧ʱ��
							projectID,		--������ĿID
							projectName,	--������Ŀ(���ƣ�
							borrowReason,	--��֧����
							borrowSum,		--��֧���
							flowProgress,	--��ת����
							createManID,	--�����˹���
							createManName,	--����������
							createTime		--����ʱ��
							) 
	values (@borrowSingleID, 
			@borrowManID,
			@borrowMan,
			@position, 
			@departmentID, 
			@borrowDate, 
			@projectID, 
			@projectName, 
			@borrowReason,
			@borrowSum, 
			@flowProgress, 
			@createManID, 
			@createManName, 
			@createTime) 
	if @@ERROR <> 0 
	--������ϸ��
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӽ�֧��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˽�֧��[' + @borrowSingleID + ']��')
GO



drop PROCEDURE editBorrowSingle
/*
	name:		addborrowSingle
	function:	1.��ӱ�����
				ע�⣺���洢���̲������༭��
	input: 
			@borrowSingleID varchar(15) ,  --��֧����
			@borrowManID varchar(13)	,	--��֧��ID
			@borrowMan varchar(20)	,		--��֧�ˣ�������
			@position	varchar(10)	,	--ְ��
			@departmentID	varchar(13)	,	--����ID
			@department	varchar(16)	,	--����
			@borrowDate	smalldatetime	,	--��֧ʱ��
			@projectID	varchar(14),	--������ĿID
			@projectName	varchar(200),	--������Ŀ�����ƣ�
			@borrowReason	varchar(200),	--��֧����
			@borrowSum	money,	--��֧���
			@flowProgress smallint,		--��ת����

			@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ý�֧���ѱ�������2���ý�֧��Ϊ���״̬9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by 
*/
create PROCEDURE editBorrowSingle				
			@borrowManID varchar(13)	,	--��֧��ID
			@borrowMan varchar(20)	,		--��֧�ˣ�������
			@position	varchar(10)	,	--ְ��
			@departmentID	varchar(13)	,	--����ID
			@department	varchar(16)	,	--����
			@borrowDate	smalldatetime	,	--��֧ʱ��
			@projectID	varchar(14),	--������ĿID
			@projectName	varchar(200),	--������Ŀ�����ƣ�
			@borrowReason	varchar(200),	--��֧����
			@borrowSum	money,	--��֧���
			@flowProgress smallint,		--��ת����

	@createManID varchar(10),		--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@borrowSingleID varchar(15) output	--��������֧���ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��ѯ��֧���Ƿ�Ϊ���״̬
	declare @thisflowProgress smallint
	set @thisflowProgress = (select flowProgress from borrowSingle where borrowSingleID = @borrowSingleID)
	if (@thisflowProgress<>0)
	begin
		set @Ret = 2
		return
	end

	--���༭�Ľ�֧���Ƿ��б༭������������
	declare @count int
	set @count = (select COUNT(*) from borrowSingle
					where borrowSingleID = @borrowSingleID
					and	  ISNULL(lockManID,'')<>'')
						
	if (@count>0)
	begin
		set @Ret = 1
		return
	end

	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @borrowSingleID = @curNumber

	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	update borrowSingle set borrowManID = @borrowManID,	--��֧��ID
							borrowMan = @borrowMan,		--��֧������
							position = @position,		--ְ��
							departmentID = @departmentID,	--����
							borrowDate = @borrowDate,		--��֧ʱ��
							projectID = @projectID,		--������ĿID
							projectName = @projectName,	--������Ŀ(���ƣ�
							borrowReason = @borrowReason,	--��֧����
							borrowSum = @borrowSum,		--��֧���
							flowProgress = @flowProgress,	--��ת����
							createManID = @createManID,	--�����˹���
							createManName = @createManName,	--����������
							createTime	= @createTime	--����ʱ��
							where borrowSingleID = @borrowSingleID--��֧��ID
	if @@ERROR <> 0 
	--������ϸ��
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӵ������뵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˽�֧��[' + @borrowSingleID + ']��')
GO



drop PROCEDURE lockBorrowSingleEdit
/*
	name:		BorrowSingle
	function:	������֧���༭������༭��ͻ
	input: 
				@borrwSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ľ�֧�������ڣ�2:Ҫ�����Ľ�֧�����ڱ����˱༭��
							3:�õ����Ѿ����������ܱ༭������
							9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockBorrowSingleEdit
				@borrwSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrwSingle where borrwSingleID= @borrwSingleID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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

	update borrwSingle
	set lockManID = @lockManID 
	where borrwSingleID= @borrwSingleID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������֧���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˽�֧��['+ @borrwSingleID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockBorrowSingleEdit
/*
	name:		BorrowSingle
	function:	�ͷ�������֧���༭������༭��ͻ
	input: 
				@borrwSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���8:�õ���δ����,9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockBorrowSingleEdit
				@borrwSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrwSingle where borrwSingleID= @borrwSingleID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(14)
	set @thisLockMan = isnull((select lockManID from borrowSingle where borrowSingleID= @borrowSingleID),'')
	if (@thisLockMan<>'')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		else		--�ͷŽ�֧������
		update borrowSingle set @lockManID = '' where borrowSingleID = @borrowSingleID
		if @@ERROR <>0
		begin
			set @Ret = 9
			return
	end
	else   --���ظý�֧��δ���κ�������
	begin
		set @Ret = 8
		return
	end
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷŽ�֧���༭', 'ϵͳ�����û�' + @lockManName												+ '��Ҫ���ͷ��˽�֧��['+ @borrwSingleID +']�ı༭����')
GO


drop PROCEDURE delBorrowSingle
/*
	name:		delBorrowSingle
	function:	ɾ��ָ����֧��
	input: 
				@borrwSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ľ�֧�������ڣ�
							2:Ҫɾ���Ľ�֧����������������
							3:�õ����Ѿ����������ܱ༭������
							9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE delBorrowSingle
				@borrwSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫɾ���Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrwSingle where borrwSingleID= @borrwSingleID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	--ɾ��ָ����֧��
	delete borrwSingle
	where borrwSingleID= @borrwSingleID
	--�ж����޴���
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), 'ɾ����֧��', 'ϵͳ�����û�' + @lockManName
												+ 'ɾ���˽�֧��['+ @borrwSingleID +']��')
GO

-- ���ñ�����
drop table ExpRemSingle 
create table ExpRemSingle(
	ExpRemSingleID varchar(15) not null,  --���������
	departmentID varchar(13) not null,	--����ID
	ExpRemDepartment varchar(20)	not null,	--��������
	ExpRemDate smalldatetime not null,	--��������
	projectID varchar(13) not null,	--��ĿID
	projectName varchar(50) not null,	--��Ŀ����
	ExpRemSingleNum int ,	--�������ݼ�����
	note varchar(200),	--��ע
	expRemSingleType smallint default(0) not null,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
	amount money not null,	--�ϼƽ��
	borrowSingleID varchar(15) ,	--ԭ��֧��ID
	originalloan money not null,	--ԭ���
	replenishment money not null,	--Ӧ����
	shouldRefund money not null,	--Ӧ�˿�
	ExpRemPersonID varchar(14) not null,	--�����˱��
	ExpRemPerson varchar(10)	not	null,	--����������
	businessPeopleID	varchar(14) not null,	--�����˱��
	businessPeople	varchar(10) not null,	--������
	businessReason varchar(200)	not null,	--��������
	approvalProgress smallint default(0) not null,	--��������
	IssueSituation smallint default(0) not null,	--�������
	paymentMethodID varchar(13)	,	--�����˻�ID
	paymentMethod varchar(50),		--�����˻�
	paymentSum money,	--������
	draweeID varchar(13),	--������ID
	drawee	varchar(10),	--������
	
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10)				--��ǰ���������༭���˹���
	 CONSTRAINT [PK_ExpRemSingle] PRIMARY KEY CLUSTERED 
(
	[ExpRemSingleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--���÷ѱ�������
drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsID varchar(18) not null,	--���÷ѱ�������ID
ExpRemSingleID varchar(15) not null,	--���������
StartDate smalldatetime	not null,	--��ʼʱ��
endDate smalldatetime not null,	--��������
startingPoint varchar(12) not null,	--���
destination varchar(12) not null,	--�յ�
vehicle		varchar(12)	not null,	--��ͨ����
documentsNum	int	not null,	--��������
vehicleSum	money not null,	--��ͨ�ѽ��
financialAccountID	varchar(13)	not null,	--��ĿID
financialAccount	varchar(20) not null,	--��Ŀ����
peopleNum	int not null,	--����
travelDays float ,	-- ��������
TravelAllowanceStandard	money,	--�������׼
travelAllowancesum	money	not null,	--�������
otherExpenses	varchar(20) null,	--��������
otherExpensesSum	money	null,	--�������ý��
	 CONSTRAINT [PK_TravelExpensesDetails] PRIMARY KEY CLUSTERED 
(
	[TravelExpensesDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--���������
drop table ExpenseReimbursementDetails 
create table ExpenseReimbursementDetails(
ExpRemDetailsID	varchar(17)	not null,	--��������ID
ExpRemSingleID	varchar(16)	not null,	--������ID
abstract	varchar(100)	not null,	--ժҪ
supplementaryExplanation	varchar(100)	not null,	--����˵��
financialAccountID	varchar(13)	not null,	--������ĿID
financialAccount	varchar(200)	not null,	--������Ŀ
expSum	float	not null,	--���
)

GO

-- ��Ʊ�����	
drop table VATinvoice 
create table VATinvoice(
CustomerID	varchar(14)	not null,	--�ͻ����
customerUnit	varchar(20)	not null,	--�ͻ���λ
projectName varchar(20)	not null,	--��Ŀ����
projectID	varchar(14)	not	null,	--��Ŀ���
billingDate	smalldatetime	not null,	--��Ʊ����
billingAmount	float	not null,	--��Ʊ���
invoiceType	int	not	null,	--��Ʊ����
WhetherCancel	int not null,	--�Ƿ�����
invoiceID	varchar(14)	not	null,	--��Ʊ���
applyDate	smalldatetime	not	null,	--��������
applicantDept	varchar(20)	not	null,	--���벿��
applyDrawer	varchar(10)	not null,	--���뿪Ʊ��
drawer	varchar(10)	not	null,	--��Ʊ��
paymentMode	varchar(10)	not	null,	--�ؿʽ
paymentDate	smalldatetime	not	null,	--�ؿ�����
paymentAmount	float	not	null,	--�ؿ���
accountsReceivable	float	not	null,	--Ӧ���˿�
taxAmount	float	not	null,	--Ӧ��˰��
paidTaxAmount	float not	null,	--ʵ��˰��
payableVAT	float	null,	--Ӧ����ֵ����˰
paidAddTax	float	null,	--ʵ�ɸ���˰
--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
createManID varchar(10) null,		--�����˹���
createManName varchar(30) null,		--����������
createTime smalldatetime null,		--����ʱ��

--����ά�����:
modiManID varchar(10) null,			--ά���˹���
modiManName nvarchar(30) null,		--ά��������
modiTime smalldatetime null,		--���ά��ʱ��

--�༭�����ˣ�
lockManID varchar(10)				--��ǰ���������༭���˹���
)



--������
drop table enclosure 
create table enclosure(
enclosureID	varchar(15)	not	null,	--�������
billType	 smallint default(0)	not	null,	--Ʊ�����ͣ�0����֧����1��������
billID	varchar(15)	not	null,	--Ʊ�ݱ��
enclosureAddress	varchar(200)	not	null,	--������ַ
enclosureType	 smallint default(0)	not	null,	--��������
)


--��Ŀ�����
drop table subjectList 
create table subjectList(
FinancialSubjectID	varchar(13)	not	null,	--��ĿID
classification	smallint default(0) not null,	--����
superiorSubjectsID	varchar(13)	,	--�ϼ���ĿID
superiorSubjects varchar(50)	,	--�ϼ���Ŀ����
subjectName	varchar(50)	not null,	--��Ŀ����
AccountNumber int not null,	--��Ŀ����
establishTime smalldatetime	not null,	--����ʱ��
explain varchar(200)	null,	--˵��

--�����ˣ�Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
createManID varchar(10) null,		--�����˹���
createManName varchar(30) null,		--����������
createTime smalldatetime null,		--����ʱ��

--����ά�����:
modiManID varchar(10) null,			--ά���˹���
modiManName nvarchar(30) null,		--ά��������
modiTime smalldatetime null,		--���ά��ʱ��

--�༭�����ˣ�
lockManID varchar(10)				--��ǰ���������༭���˹���
	 CONSTRAINT [PK_subjectList] PRIMARY KEY CLUSTERED 
(
	[FinancialSubjectID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--�˻���ϸ��
drop table accountDetailsList 
create table accountList(
AccountDetailsID	varchar(16)	not null,	--�˻���ϸID
accountID	varchar(13)	not null,	--�˻�ID
account		varchar(30)	not	null,	--�˻�����
detailDate	smalldatetime	not null,	--����
abstract	varchar(200),	--ժҪ
borrow		money,		--��
loan		money,		--��
balance		money,		--���
departmentID	varchar(13),	--����ID
department		varchar(30),	--����
projectID		varchar(13),	--��ĿID
project			varchar(100),	--��Ŀ
clerkID		varchar(13),		--������ID
clerk		varchar(20),		--������
remarks		varchar(200),		--��ע
--�����ˣ�Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
createManID varchar(10) null,		--�����˹���
createManName varchar(30) null,		--����������
createTime smalldatetime null,		--����ʱ��

--����ά�����:
modiManID varchar(10) null,			--ά���˹���
modiManName nvarchar(30) null,		--ά��������
modiTime smalldatetime null,		--���ά��ʱ��

--�༭�����ˣ�
lockManID varchar(10)				--��ǰ���������༭���˹���
)


--�˻���
drop table accountList
create table accountList(
accountID	varchar(13) not null,	--�˻�ID
accountName	varchar(50)	not null,	--�˻�����
bankAccount	varchar(100) not null,	--������
accountCompany	varchar(100)	not null,	--������
accountOpening	varchar(50)	not	null,	--�����˺�
bankAccountNum	varchar(50)	not null,	--�����к�
accountDate	smalldatetime	not	null,	--����ʱ��
administratorID	varchar(13)	,	--������ID
administartor	varchar(20)	,	--������(������
branchAddress	varchar(100),	--֧�е�ַ
remarks	varchar(200),	--��ע
--�����ˣ�Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
createManID varchar(10) null,		--�����˹���
createManName varchar(30) null,		--����������
createTime smalldatetime null,		--����ʱ��

--����ά�����:
modiManID varchar(10) null,			--ά���˹���
modiManName nvarchar(30) null,		--ά��������
modiTime smalldatetime null,		--���ά��ʱ��

--�༭�����ˣ�
lockManID varchar(10)				--��ǰ���������༭���˹���
)


--�˻��ƽ���
drop table accountTransferList
create table accountTransferList(
accountTransferID varchar(15)	not null,	--�˻��ƽ�ID
handoverDate	smalldatetime	not null,	--�ƽ�����
transferAccountID	varchar(13)	not	null,	--�ƽ��˻�ID
transferAccount		varchar(30)	not null,	--�ƽ��˻�
transferPersonID	varchar(13)	not null,	--�ƽ���ID
transferPerson		varchar(20)	not null,	--�ƽ���
handoverPersonID	varchar(13)	not	null,	--������ID
handoverPerson		varchar(20)	not	null,	--������
transferMatters		varchar(200),	--�ƽ�����
remarks		varchar(200),	--��ע