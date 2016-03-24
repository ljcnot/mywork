drop table borrowSingle 
create table borrwSingle(
	borrowSingleID varchar(13) not null,  --��֧����
	borrowDate smalldatetime	not null,	--��֧ʱ��
	employeeID varchar(11)	not null,		--Ա�����
	position	varchar(10)	not null,	--ְ��
	borrowReason	varchar(200)	not null,	--��֧����
	borrowSum	float	not null,	--���
	approved	varchar(16),	--��׼
	accounting	varchar(16),	--���
	cashier	varchar(16),	--����
	borrowMan	varchar(16),	--��֧��
	department	varchar(16)	not null,	--����
	documentTemplate	int default(0) not null,	---����ģ��
	flowProgress	int default(0) not null,	--��ת����
	IssueSituation	int default(0) not null,	--�������
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
GO


drop PROCEDURE addborrowSingle
/*
	name:		addborrowSingle
	function:	1.��ӽ�֧��
				ע�⣺���洢���̲������༭��
	input: 
			@borrowDate varchar(10),		--��֧ʱ��								
			@employeeID varchar(11),		--Ա�����
			@borrowName varchar(16),		--��֧������
			@position varchar(10),			--ְ��
			@borrowReason varchar(200),		--��֧����
			@borrowSum float,				--���
			@borrowMan varchar(16),			--��֧��
			@department nvarchar(16),		--����
			@documentTemplate varchar(10),	--����ģ��
			@flowProgress int,				--��ת����

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
	@borrowDate varchar(10),		--��֧ʱ��								
	@employeeID varchar(11),		--Ա�����
	@borrowName varchar(16),		--��֧������
	@position varchar(10),			--ְ��
	@borrowReason varchar(200),		--��֧����
	@borrowSum float,				--���
	@borrowMan varchar(16),			--��֧��
	@department nvarchar(16),		--����
	@documentTemplate varchar(10),	--����ģ��
	@flowProgress int,				--��ת����

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
	insert borrowSingle(borrowSingleID,		--��֧����
							borrowDate,		--��֧ʱ��
							employeeID,		--Ա�����
							borrowName,		--��֧������
							position,		--ְ��
							borrowReason,	--��֧����
							borrowSum,		--���
							borrowMan,		--��֧��
							department,		--����
							documentTemplate,	--����ģ��
							flowProgress,	--��ת����
							createManID,	--�����˹���
							createManName,	--����������
							createTime		--����ʱ��
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
	--������ϸ��
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӵ������뵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˽�֧��[' + @borrowSingleID + ']��')
GO




drop PROCEDURE editBorrowSingle
/*
	name:		editBorrowSingle
	function:	1.�޸Ľ�֧��
				ע�⣺���洢���������༭��
	input: 
			@borrowDate varchar(10),		--��֧ʱ��								
			@employeeID varchar(11),		--Ա�����
			@borrowName varchar(16),		--��֧������
			@position varchar(10),			--ְ��
			@borrowReason varchar(200),		--��֧����
			@borrowSum float,				--���
			@borrowMan varchar(16),			--��֧��
			@department nvarchar(16),		--����
			@documentTemplate varchar(10),	--����ģ��
			@flowProgress int,				--��ת����

			@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ý�֧�����Ѵ��ڻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE editBorrowSingle
	@borrowDate varchar(10),		--��֧ʱ��								
	@employeeID varchar(11),		--Ա�����
	@borrowName varchar(16),		--��֧������
	@position varchar(10),			--ְ��
	@borrowReason varchar(200),		--��֧����
	@borrowSum float,				--���
	@borrowMan varchar(16),			--��֧��
	@department nvarchar(16),		--����
	@documentTemplate varchar(10),	--����ģ��
	@flowProgress int,				--��ת����

	@createManID varchar(10),		--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@borrowSingleID varchar(15) 	--��������֧���ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	--�������������豸�Ƿ��б༭��������Ҫ��ſ������������������豸���ڣ�modi by lw 2013-5-27
	declare @count int
	set @count = (select COUNT(*) from borrowSingle
					where borrowSingleID = @borrowSingleID and  isnull(lockManID,'')<>'')
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	update borrowSingle set borrowDate = @borrowDate,	--��֧ʱ��
							employeeID = @employeeID,		--Ա�����
							borrowName = @borrowName,		--��֧������
							position = @position,		--ְ��
							borrowReason = @borrowReason,	--��֧����
							borrowSum = @borrowSum,		--���
							borrowMan = @borrowMan,		--��֧��
							department = @department,		--����
							documentTemplate = @documentTemplate,	--����ģ��
							flowProgress = @flowProgress,	--��ת����
							createManID = @createManID,	--�����˹���
							createManName = @createManName,	--����������
							createTime	= @createTime	--����ʱ��
	where 	borrowSingleID = @borrowSingleID		 

	if @@ERROR <> 0 
	update borrowborrowSingle set lockManID = null where borrowSingleID = @borrowSingleID  --�����ɹ�,�ͷű༭��
	--������ϸ��
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�޸ĵ������뵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˽�֧��[' + @borrowSingleID + ']��')
GO



drop PROCEDURE delteBorrowSingle
/*
	name:		delteBorrowSingle
	function:	1.ɾ����֧��
				ע�⣺���洢���������༭��
	input: 
				@borrowSingleID varchar(15) 	--��������֧����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ý�֧�����Ѵ��ڻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE delteBorrowSingle
	@Operator varchar(14),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@borrowSingleID varchar(15) 	--��������֧���ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	--�������������豸�Ƿ��б༭��������Ҫ��ſ������������������豸���ڣ�modi by lw 2013-5-27
	declare @count int
	set @count = (select COUNT(*) from borrowSingle
					where borrowSingleID = @borrowSingleID and  isnull(lockManID,'')<>'')
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	delete borrowSingle 
	where borrowSingleID = @borrowSingleID		 

	if @@ERROR <> 0 
	update borrowborrowSingle set lockManID = null where borrowSingleID = @borrowSingleID  --�����ɹ�,�ͷű༭��
	--������ϸ��
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 'ɾ���������뵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��ɾ���˽�֧��[' + @borrowSingleID + ']��')
GO



drop table ExpRemSingle 
create table ExpRemSingle(
	borrowSingleID varchar(15) not null,  --���������
	expRemSingleID varchar(13) not null,	--���ű��
	expRemDepartment	varchar(20),	--��������
	projectID varchar(14) not null,	--��Ŀ���
	projectName varchar(50) not null,	--��Ŀ����
	expRemProject varchar(50),	--������Ŀ
	ExpRemDate smalldatetime	not null,	--��������
	ExpRemSingleNum int ,	--�������ݼ�����
	expRemSingleType int not null,	--����������
	amount float not null,	--�ϼƽ��
	originalloan float not null,	--ԭ���
	replenishment float not null,	--Ӧ����
	shouldRefund float not null,	--Ӧ�˿�
	expRemPerson varchar(10) not null,	--������
	expRemPersonID varchar(14) not null,	--�����˱��
	businessPeople	varchar(10) not null,	--������
	businessPeopleID	varchar(14) not null,	--�����˱��
	leadershipApproval varchar(10) not null,	--�쵼����
	leadershipApprovalID varchar(14) not null,	--Ա�����(�쵼)
	AccountingSupervisor varchar(10)	not null,	--�������
	AccountingSupervisorID varchar(14) not null,	--Ա�����(�������)
	doubleChec varchar(10) not null,	--����
	doubleChecID varchar (14),	--Ա�����(����)
	cashier varchar (10),	--����
	cashierID varchar(14),	--Ա����ţ����ɣ�
	businessReason varchar(200)	not null,	--��������
	approvalProgress int not null,	--��������
	IssueSituation int not null,	--�������
	note varchar(200),	--��ע
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
GO


drop PROCEDURE addExpRemSingle
/*
	name:		addborrowSingle
	function:	1.��ӽ�֧��
				ע�⣺���洢���̲������༭��
	input: 
			borrowSingleID varchar(15) not null,  --���������
			expRemSingleID varchar(13) not null,	--���ű��
			projectID varchar(14) not null,	--��Ŀ���
			projectName varchar(50) not null,	--��Ŀ����
			expRemProject varchar(50),	--������Ŀ
			ExpRemDate smalldatetime	not null,	--��������
			ExpRemSingleNum int ,	--�������ݼ�����
			expRemSingleType int not null,	--����������
			amount float not null,	--�ϼƽ��
			originalloan float not null,	--ԭ���
			replenishment float not null,	--Ӧ����
			shouldRefund float not null,	--Ӧ�˿�
			expRemPerson varchar(10) not null,	--������
			expRemPersonID varchar(14) not null,	--�����˱��
			businessPeople	varchar(10) not null,	--������
			businessPeopleID	varchar(14) not null,	--�����˱��
			leadershipApproval varchar(10) not null,	--�쵼����
			leadershipApprovalID varchar(14) not null,	--Ա�����(�쵼)
			AccountingSupervisor varchar(10)	not null,	--�������
			AccountingSupervisorID varchar(14) not null,	--Ա�����(�������)
			doubleChec varchar(10) not null,	--����
			doubleChecID varchar (14),	--Ա�����(����)
			cashier varchar (10),	--����
			cashierID varchar(14),	--Ա����ţ����ɣ�
			businessReason varchar(200)	not null,	--��������
			approvalProgress int not null,	--��������
			IssueSituation int not null,	--�������
			note varchar(200),	--��ע
			--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
			createManID varchar(10) null,		--�����˹���
			createManName varchar(30) null,		--����������
			createTime smalldatetime null,		--����ʱ��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE addExpRemSingle
			@departmentID varchar(13),		--���ű��
			@projectID varchar(14),		--��Ŀ���
			@projectName varchar(50) ,	--��Ŀ����
			@expRemProject varchar(50),	--������Ŀ
			@ExpRemDate smalldatetime	,	--��������
			@ExpRemSingleNum int ,	--�������ݼ�����
			@expRemSingleType int ,	--����������
			@amount float ,	--�ϼƽ��
			@originalloan float ,	--ԭ���
			@replenishment float ,	--Ӧ����
			@shouldRefund float ,	--Ӧ�˿�
			@expRemPerson varchar(10) ,	--������
			@expRemPersonID varchar(14) ,	--�����˱��
			@businessPeople	varchar(10) ,	--������
			@businessPeopleID	varchar(14) ,	--�����˱��
			@leadershipApproval varchar(10) ,	--�쵼����
			@leadershipApprovalID varchar(14) ,	--Ա�����(�쵼)
			@AccountingSupervisor varchar(10)	,	--�������
			@AccountingSupervisorID		varchar(14) ,	--Ա�����(�������)
			@doubleChec varchar(10) ,	--����
			@doubleChecID varchar (14),	--Ա�����(����)
			@cashier varchar (10),	--����
			@cashierID varchar(14),	--Ա����ţ����ɣ�
			@businessReason varchar(200)	,	--��������
			@approvalProgress int ,	--��������
			@IssueSituation int ,	--�������
			@note varchar(200),	--��ע
			
			--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
			@createManID varchar(10) ,		--�����˹���
			@createManName varchar(30) ,		--����������
			@createTime smalldatetime ,		--����ʱ��

	@Ret		int output,
	@createTime smalldatetime output,
	@expRemSingleID varchar(15) output	--��������������ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @expRemSingleID = @curNumber

	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	begin tran
		insert borrowSingle(	
				expRemSingleID, --���������
				departmentID,	--���ű��		
				projectID,	--��Ŀ���
				projectName,	--��Ŀ����
				ExpRemDate,	--��������
				ExpRemSingleNum,	--�������ݼ�����
				expRemSingleType,	--����������
				amount,	--�ϼƽ��
				originalloan,	--ԭ���
				replenishment,	--Ӧ����
				shouldRefund,	--Ӧ�˿�
				expRemPerson,	--������
				expRemPersonID,	--�����˱��
				businessPeople,	--������
				businessPeopleID,	--�����˱��
				leadershipApproval,	--�쵼����
				leadershipApprovalID,	--Ա�����(�쵼)
				AccountingSupervisor ,	--�������
				AccountingSupervisorID,	--Ա�����(�������)
				doubleChec,	--����
				doubleChecID,	--Ա�����(����)
				cashier,	--����
				cashierID,	--Ա����ţ����ɣ�
				businessReason,	--��������
				approvalProgress,	--��������
				IssueSituation)	--�������
							 
		values (
				@expRemSingleID,--���������	
				@departmentID,	--���ű��
				@projectID,	--��Ŀ���
				@projectName,	--��Ŀ����
				@ExpRemDate,	--��������
				@ExpRemSingleNum,	--�������ݼ�����
				@expRemSingleType,	--����������
				@amount,	--�ϼƽ��
				@originalloan,	--ԭ���
				@replenishment,	--Ӧ����
				@shouldRefund,	--Ӧ�˿�
				@expRemPerson,	--������
				@expRemPersonID,	--�����˱��
				@businessPeople,	--������
				@businessPeopleID,	--�����˱��
				@leadershipApproval,	--�쵼����
				@leadershipApprovalID,	--Ա�����(�쵼)
				@AccountingSupervisor ,	--�������
				@AccountingSupervisorID,	--Ա�����(�������)
				@doubleChec,	--����
				@doubleChecID,	--Ա�����(����)
				@cashier,	--����
				@cashierID,	--Ա����ţ����ɣ�
				@businessReason,	--��������
				@approvalProgress,	--��������
				@IssueSituation	--�������) 

		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		insert	ExpenseReimbursementDetails(
				ExpRemSingleID,	--���������
				ExpRemDetailsID,	--����������
				ExpRemContent,	--��������
				abstract,		--ժҪ
				expRemsum)		--���
		values (
				@ExpRemSingleID,	--���������
				@ExpRemDetailsID,	--����������
				@ExpRemContent,	--��������
				@abstract,		--ժҪ
				@expRemsum)		--���
	commit tran
	set @Ret = 0
	--������ϸ��
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӷ��ñ�����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˷��ñ�����[' + @borrowSingleID + ']��')
GO

drop PROCEDURE addExpRemSingle

create PROCEDURE addExpRemDetails
	--���������
			@ExpRemDetailsID varchar(16),	--��������ID
			@ExpRemContent	varchar(200),	--��������
			@abstract	varchar(100),		--ժҪ
			@expRemsum	money,					--���

			@ExpRemDetailsID varchar(15) output	--��������������ţ�ʹ�õ� 3 �ź��뷢��������

	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @expRemSingleID = @curNumber

GO



drop PROCEDURE editExpRemSingle
/*
	name:		editExpRemSingle
	function:	1.�༭���ñ�����
				ע�⣺���洢���̲������༭��
	input: 
			borrowSingleID varchar(15) not null,  --���������
			expRemSingleID varchar(13) not null,	--���ű��
			projectID varchar(14) not null,	--��Ŀ���
			projectName varchar(50) not null,	--��Ŀ����
			expRemProject varchar(50),	--������Ŀ
			ExpRemDate smalldatetime	not null,	--��������
			ExpRemSingleNum int ,	--�������ݼ�����
			expRemSingleType int not null,	--����������
			amount float not null,	--�ϼƽ��
			originalloan float not null,	--ԭ���
			replenishment float not null,	--Ӧ����
			shouldRefund float not null,	--Ӧ�˿�
			expRemPerson varchar(10) not null,	--������
			expRemPersonID varchar(14) not null,	--�����˱��
			businessPeople	varchar(10) not null,	--������
			businessPeopleID	varchar(14) not null,	--�����˱��
			leadershipApproval varchar(10) not null,	--�쵼����
			leadershipApprovalID varchar(14) not null,	--Ա�����(�쵼)
			AccountingSupervisor varchar(10)	not null,	--�������
			AccountingSupervisorID varchar(14) not null,	--Ա�����(�������)
			doubleChec varchar(10) not null,	--����
			doubleChecID varchar (14),	--Ա�����(����)
			cashier varchar (10),	--����
			cashierID varchar(14),	--Ա����ţ����ɣ�
			businessReason varchar(200)	not null,	--��������
			approvalProgress int not null,	--��������
			IssueSituation int not null,	--�������
			note varchar(200),	--��ע
			--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
			createManID varchar(10) null,		--�����˹���
			createManName varchar(30) null,		--����������
			createTime smalldatetime null,		--����ʱ��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE editExpRemSingle
			@departmentID varchar(13),		--���ű��
			@projectID varchar(14),		--��Ŀ���
			@projectName varchar(50) ,	--��Ŀ����
			@expRemProject varchar(50),	--������Ŀ
			@ExpRemDate smalldatetime	,	--��������
			@ExpRemSingleNum int ,	--�������ݼ�����
			@expRemSingleType int ,	--����������
			@amount float ,	--�ϼƽ��
			@originalloan float ,	--ԭ���
			@replenishment float ,	--Ӧ����
			@shouldRefund float ,	--Ӧ�˿�
			@expRemPerson varchar(10) ,	--������
			@expRemPersonID varchar(14) ,	--�����˱��
			@businessPeople	varchar(10) ,	--������
			@businessPeopleID	varchar(14) ,	--������ID
			@leadershipApproval varchar(10) ,	--�쵼����
			@leadershipApprovalID varchar(14) ,	--Ա�����(�쵼)
			@AccountingSupervisor varchar(10)	,	--�������
			@AccountingSupervisorID		varchar(14) ,	--Ա�����(�������)
			@doubleChec varchar(10) ,	--����
			@doubleChecID varchar (14),	--Ա�����(����)
			@cashier varchar (10),	--����
			@cashierID varchar(14),	--Ա����ţ����ɣ�
			@businessReason varchar(200)	,	--��������
			@approvalProgress int ,	--��������
			@IssueSituation int ,	--�������
			@note varchar(200),	--��ע
			
			--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
			@createManID varchar(10) ,		--�����˹���
			@createManName varchar(30) ,		--����������
			@createTime smalldatetime ,		--����ʱ��

	@Ret		int output,
	@createTime smalldatetime output,
	@expRemSingleID varchar(15) output	--��������������ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @expRemSingleID = @curNumber

	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	begin tran
			update borrowSingle set departmentID = @departmentID,	--��֧ʱ��
							projectID = @projectID,					--��Ŀ���
							projectName = @projectName,		--��Ŀ����
							expRemProject = @expRemProject,		--������Ŀ
							ExpRemDate = @ExpRemDate,	--��������
							ExpRemSingleNum = @ExpRemSingleNum,		--�������ݼ�����
							expRemSingleType = @expRemSingleType,	--����������
							amount = @amount,		--�ϼƽ��
							originalloan = @originalloan,	--ԭ���
							replenishment = @replenishment,	--Ӧ����
							shouldRefund = @shouldRefund,	--Ӧ�˿�
							expRemPerson = @expRemPerson,	--������
							expRemPersonID	= @expRemPersonID,	--������ID
							businessPeople = @businessPeople, --������
							businessPeopleID = @businessPeopleID,	--������ID
							leadershipApproval = @leadershipApproval,	--�쵼����
							leadershipApprovalID = @leadershipApprovalID,	--Ա�����(�쵼)
							AccountingSupervisor = @AccountingSupervisor,	--�������
							AccountingSupervisorID = @AccountingSupervisorID,	--Ա�����(�������)
							doubleChec = @doubleChec,		--����
							doubleChecID = @doubleChecID,		--Ա�����(����)
							cashier = @cashier,	--
							cashierID = @cashierID, --Ա�����(����)
							businessReason = @businessReason,	--��������
							approvalProgress = @approvalProgress,	--��������
							IssueSituation = @IssueSituation,	--�������
							note = @note,	--��ע


	where 	borrowSingleID = @borrowSingleID		 

		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		insert	ExpenseReimbursementDetails(
				ExpRemSingleID,	--���������
				ExpRemDetailsID,	--����������
				ExpRemContent,	--��������
				abstract,		--ժҪ
				expRemsum)		--���
		values (
				@ExpRemSingleID,	--���������
				@ExpRemDetailsID,	--����������
				@ExpRemContent,	--��������
				@abstract,		--ժҪ
				@expRemsum)		--���
	commit tran
	set @Ret = 0
	--������ϸ��
	declare @runRet int 
	exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӷ��ñ�����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˷��ñ�����[' + @borrowSingleID + ']��')
GO

drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsIDd varchar(17) not null,	--���÷ѱ�������
ExpRemSingleID varchar(15) not null,	--���������
StartDate smalldatetime	not null,	--��ʼʱ��
endDate smalldatetime not null,	--��������
startingPoint varchar(20) not null,	--���
destination varchar(20) not null,	--�յ�
vehicle		varchar(10)	not null,	--��ͨ����
documentsNum	int	not null,	--��������
projectID	varchar(14)	not null,	--��Ŀ���
projectName	varchar(20)	not null,	--��Ŀ����
expSum	float	not null,	--���
peopleNum	int not null,	--����
expDays	float	not null,	--����
travelAllowanceStandard	float	not null,	--�������׼
subsidyAmount	float	not null,	--�������
otherExpenses	varchar(20) null,	--��������
otherExpensesSum	float	null,	--�������ý��
)
GO


drop table ExpenseReimbursementDetails 
create table ExpenseReimbursementDetails(
ExpRemSingleID	varchar(15)	not null,	--���������
ExpRemDetailsID	varchar(17)	not null,	--����������
projectID	varchar(14)	not null,	--������Ŀ
expRemProject	varchar(50)	not null,	--������Ŀ
abstract	varchar(100)	not null,	--ժҪ
expSum	float	not null,	--���
)

GO

	
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

drop table VATinvoice 
create table VATinvoice(
enclosureID	varchar(14)	not	null,	--�������
billType	int	not	null,	--Ʊ������
billID	varchar(14)	not	null,	--Ʊ�ݱ��
enclosureAddress	varchar(200)	not	null,	--������ַ
enclosureType	int	not	null,	--��������
)

drop table CashJournal 
create table CashJournal(
CashJournalDate	smalldatetime	not	null,	--����
abstract	varchar(30)	not	null,	--ժҪ
debit	float	not	null,	--���
credit	float	not	null,	--����
balance	float	not	null,	--���
voucherNum	varchar(13),	--ƾ֤��
paymentMethod	int	not	null,--֧����ʽ
cashJournalID	varchar(13),	--�ֽ��ռǱ��
department	varchar(20),	--����
project	varchar(50),	--��Ŀ
brokerage	varchar(16),	--������
remarks	varchar(200),	--��ע
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


drop table VATinvoiceDetails 
create table VATinvoiceDetails(
VATinvoiceID	varchar(17)	not	null,	--��ֵ˰��Ʊ���
goodsName	varchar(20)	not	null,	--�����Ӧ˰���񡢷�������
SpecificationModel	int	not	null,	--����ͺ�
company	varchar(20)	not	null,	--��λ
)