-- ������
drop table ExpRemSingle 
create table ExpRemSingle(
	ExpRemSingleID varchar(13) not null,  --���������
	departmentID varchar(13) not null,	--����ID
	ExpRemDepartment varchar(30)	not null,	--��������
	ExpRemDate smalldatetime not null,	--��������
	projectID varchar(13) not null,	--��ĿID
	projectName varchar(50) not null,	--��Ŀ����
	ExpRemSingleNum varchar(13) ,	--��������(����)
	note varchar(200),	--��ע
	expRemSingleType smallint default(0) not null,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
	amount numeric(15,2) not null,	--�ϼƽ��
	borrowSingleID varchar(15) ,	--ԭ��֧��ID
	originalloan numeric(15,2) ,	--ԭ���
	replenishment numeric(15,2) ,	--Ӧ����
	shouldRefund numeric(15,2) ,	--Ӧ�˿�
	ExpRemPersonID varchar(10) not null,	--�����˱��
	ExpRemPerson varchar(30)	not	null,	--����������
	businessPeopleID	varchar(10)  ,	--�����˱��
	businessPeople	varchar(30),	--������
	businessReason varchar(200),	--��������
	approvalStatus smallint default(0) not null,	--����״̬��0��δ����1������У�2���������
	IssueSituation smallint default(0) ,	--���������0��δ���ţ�1���Է���
	paymentMethodID varchar(13)	,	--�����˻�ID
	paymentMethod varchar(50),		--�����˻�
	paymentSum numeric(15,2),	--������
	draweeID varchar(10),	--������ID
	drawee	varchar(30),	--������
	
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


--��������������
drop table AuditExpRemList      
create table AuditExpRemList(
	ApprovalDetailsID varchar(16)	not null,	--��������ID
	billID	varchar(13)	not null,	--������ID
	approvalStatus smallint default(0) not	null,	--���������ͬ��/��ͬ�⣩
	approvalOpinions	varchar(200),	--�������
	examinationPeoplePost varchar(50),	--������ְ��
	examinationPeopleID	varchar(10),	--������ID
	examinationPeopleName	varchar(30)	--����������
--���
foreign key(billID) references ExpRemSingle(ExpRemSingleID) on update cascade on delete cascade,
--����
 CONSTRAINT [PK_ExpRemSingleID_ApprovalDetailsID] PRIMARY KEY CLUSTERED 
(
	[ApprovalDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE AudiExpRemSingle
/*
	name:		AudiExpRemSingle
	function:	1.��˱�����
				ע�⣺���洢���̲������༭��
	input: 

			@billID	varchar(13),	--������ID
			@approvalStatus int,	--���������ͬ��/��ͬ�⣩
			@approvalOpinions	varchar(200),	--�������
			@examinationPeoplePost varchar(50),	--������ְ��
			@examinationPeopleID	varchar(10),	--������ID
			@examinationPeopleName	varchar(30),	--����������



	output: 
			@ApprovalDetailsID varchar(16) output,	--��������ID��������ʹ��402�ź��뷢��������
			@Ret		int output           --�����ɹ���ʶ,0:�ɹ���1��Ҫ��˵ı����������ڣ�2���ñ��������ڱ������û�������3���ñ�����Ϊ�������״̬��9��δ֪����
			@createManID varchar(13) output,			--������ID
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-5-7

*/
create PROCEDURE AudiExpRemSingle				
			@ApprovalDetailsID varchar(16) output,	--��������ID��������ʹ��402�ź��뷢��������
			@billID	varchar(13),	--������ID
			@approvalStatus smallint,	--���������ͬ��/��ͬ�⣩
			@approvalOpinions	varchar(200),	--�������
			@examinationPeoplePost varchar(50),	--������ְ��
			@examinationPeopleID	varchar(10),	--������ID
			@examinationPeopleName	varchar(30),	--����������

			@createManID varchar(10) output,			--������ID
			@Ret		int output           --�����ɹ���ʶ,0:�ɹ���1��Ҫ��˵ı����������ڣ�2���ñ��������ڱ������û�������3���ñ�����Ϊ�������״̬��4��������������������˱����ͻ9��δ֪����
	WITH ENCRYPTION 
AS

	--�ж�Ҫ��˵ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @billID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������״̬
	declare @thisperson smallint
	set @thisperson = (select approvalStatus from ExpRemSingle
					where ExpRemSingleID = @billID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>1)
	begin
		set @Ret = 3
		return
	end
	--���༭����
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


			--ʹ��402���뷢���������µĺ��룺
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 402, 1, @curNumber output
			set @ApprovalDetailsID = @curNumber

	
			----ȡά���˵�������
			--declare @createManName nvarchar(30)
			--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			declare @createTime smalldatetime, @createManName varchar(30)
			set @createManName = '¬�γ�'
			set @createTime = getdate()
			insert AuditExpRemList(
					ApprovalDetailsID,	--��������ID��������ʹ��402�ź��뷢��������
					billID,	--��֧��ID
					approvalStatus,	--���������ͬ��/��ͬ�⣩
					approvalOpinions,	--�������
					examinationPeoplePost,	--������ְ��
					examinationPeopleID,	--������ID
					examinationPeopleName	--����������
									) 
			values (			
					@ApprovalDetailsID,	--��������ID��������ʹ��402�ź��뷢��������
					@billID,	--����ID
					@approvalStatus,	--���������ͬ��/��ͬ�⣩
					@approvalOpinions,	--�������
					@examinationPeoplePost,	--������ְ��
					@examinationPeopleID,	--������ID
					@examinationPeopleName	--����������
					) 
			set @Ret = 0
			--if @@ERROR <> 0 
			--�Ǽǹ�����־��
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@createManID,@createManName, @createTime, '��˱�����', 'ϵͳ�����û�'+@createManName+'��Ҫ������˱���������������Ϊ[' + @ApprovalDetailsID + ']��')
		end
	else
		begin
		set @Ret = 4
		return
	end
GO

--���÷ѱ�������
drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsID varchar(18) not null,	--���÷ѱ�������ID
ExpRemSingleID varchar(13) not null,	--���������
StartDate smalldatetime	not null,	--��ʼʱ��
endDate smalldatetime not null,	--��������
startingPoint varchar(20) not null,	--���
destination varchar(20) not null,	--�յ�
vehicle		varchar(12)	not null,	--��ͨ����
documentsNum	int	not null,	--��������
vehicleSum	numeric(15,2) not null,	--��ͨ�ѽ��
financialAccountID	varchar(13)	not null,	--��ĿID
financialAccount	varchar(20) not null,	--��Ŀ����
peopleNum	int not null,	--����
travelDays float ,	-- ��������
TravelAllowanceStandard	numeric(15,2),	--�������׼
travelAllowancesum	numeric(15,2)	not null,	--�������
otherExpenses	varchar(20) null,	--��������
otherExpensesSum	numeric(15,2)	null,	--�������ý��
--���
foreign key(ExpRemSingleID) references ExpRemSingle(ExpRemSingleID) on update cascade on delete cascade,
--����
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
ExpRemSingleID	varchar(15)	not null,	--������ID
abstract	varchar(100)	not null,	--ժҪ
supplementaryExplanation	varchar(100)	not null,	--����˵��
financialAccountID	varchar(13)	not null,	--������ĿID
financialAccount	varchar(200)	not null,	--������Ŀ
expSum	numeric(15,2)	not null,	--���
--���
foreign key(ExpRemSingleID) references ExpRemSingle(ExpRemSingleID) on update cascade on delete cascade,
--����
	 CONSTRAINT [PK_ExpRemDetails] PRIMARY KEY CLUSTERED 
(
	[ExpRemDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
--��ӷ��ñ�����
drop PROCEDURE addExpRemSingle
/*
	name:		addExpRemSingle
	function:	1.��ӷ��ñ�����
				ע�⣺���洢���̲������༭��
	input: 
				@ExpRemSingleID varchar(15) not null,  --���������
				@departmentID varchar(13) not null,	--����ID
				@ExpRemDepartment varchar(20)	not null,	--��������
				@ExpRemDate smalldatetime not null,	--��������
				@projectID varchar(13) not null,	--��ĿID
				@projectName varchar(50) not null,	--��Ŀ����
				@ExpRemSingleNum int ,	--�������ݼ�����
				@note varchar(200),	--��ע
				@expRemSingleType smallint default,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
				@amount numeric(15,2) not null,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan numeric(15,2) not null,	--ԭ���
				@replenishment numeric(15,2) not null,	--Ӧ����
				@shouldRefund numeric(15,2) not null,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) not null,	--�����˱��
				@ExpRemPerson varchar(10)	not	null,	--����������
				@businessPeopleID	varchar(14) not null,	--�����˱��
				@businessPeople	varchar(10) not null,	--������
				@businessReason varchar(200)	not null,	--��������
				@approvalStatus smallint default(0) not null,	--��������

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

create PROCEDURE addExpRemSingle			
				@departmentID varchar(13) ,	--����ID
				@ExpRemDepartment varchar(20)	,	--��������
				@ExpRemDate smalldatetime ,	--��������
				@projectID varchar(13) ,	--��ĿID
				@projectName varchar(50) ,	--��Ŀ����
				@ExpRemSingleNum smallint ,	--�������ݼ�����
				@note varchar(200),	--��ע
				@expRemSingleType smallint ,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
				@amount numeric(15,2) ,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan numeric(15,2) ,	--ԭ���
				@replenishment numeric(15,2) ,	--Ӧ����
				@shouldRefund numeric(15,2) ,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) ,	--�����˱��
				@ExpRemPerson varchar(10),	--����������
				@businessPeopleID	varchar ,	--�����˱��
				@businessPeople	varchar(10) ,	--������
				@businessReason varchar(200)	,	--��������
				@approvalStatus smallint ,	--��������:0���½���1����������2��������,3:�����

	@createManID varchar(13),		--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@ExpRemSingleID varchar(15) output	--��������������ţ�ʹ�õ� �ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 403, 1, @curNumber output
	set @ExpRemSingleID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	insert ExpRemSingle(ExpRemSingleID,		--������ID
							departmentID,	--����ID
							ExpRemDepartment,		--��������
							ExpRemDate,		--��������
							projectID,	--��ĿID
							projectName,	--��Ŀ����
							ExpRemSingleNum,	--�������ݼ�����
							note,			--��ע
							expRemSingleType,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
							amount,			--�ϼƽ��
							borrowSingleID,	--ԭ��֧��ID
							originalloan,	--ԭ���
							replenishment,	--Ӧ����
							shouldRefund,	--Ӧ�˿�
							ExpRemPersonID,	--������ID
							ExpRemPerson,	--����������
							businessPeopleID,	--������ID
							businessPeople,		--������
							businessReason,		--��������
							approvalStatus	--��������:0���½���1����������2��������,3:�����
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
	--������ϸ��
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӱ�����', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ������˱�����[' + @ExpRemSingleID + ']��')		
GO

--��ӷ��ñ�����(XML)
drop PROCEDURE addExpRemSingleForXML
/*
	name:		addExpRemSingleForXML
	function:	1.��ӷ��ñ�����
				ע�⣺���洢���̲������༭��
	input: 
				@ExpRemSingleID varchar(15) not null,  --���������
				@departmentID varchar(13) not null,	--����ID
				@ExpRemDepartment varchar(20)	not null,	--��������
				@ExpRemDate smalldatetime not null,	--��������
				@projectID varchar(13) not null,	--��ĿID
				@projectName varchar(50) not null,	--��Ŀ����
				@ExpRemSingleNum int ,	--�������ݼ�����
				@note varchar(200),	--��ע
				@expRemSingleType smallint default,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
				@amount numeric(15,2) not null,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan numeric(15,2) not null,	--ԭ���
				@replenishment numeric(15,2) not null,	--Ӧ����
				@shouldRefund numeric(15,2) not null,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) not null,	--�����˱��
				@ExpRemPerson varchar(10)	not	null,	--����������
				@businessPeopleID	varchar(14) not null,	--�����˱��
				@businessPeople	varchar(10) not null,	--������
				@businessReason varchar(200)	not null,	--��������
				@approvalStatus smallint default(0) not null,	--��������
				@xVar XML,					--XML��ʽ������

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

create PROCEDURE addExpRemSingleForXML			
				@departmentID varchar(13) ,	--����ID
				@ExpRemDepartment varchar(20)	,	--��������
				@ExpRemDate smalldatetime ,	--��������
				@projectID varchar(13) ,	--��ĿID
				@projectName varchar(50) ,	--��Ŀ����
				@ExpRemSingleNum smallint ,	--�������ݼ�����
				@note varchar(200),	--��ע
				@expRemSingleType smallint ,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
				@amount numeric(15,2) ,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan numeric(15,2) ,	--ԭ���
				@replenishment numeric(15,2) ,	--Ӧ����
				@shouldRefund numeric(15,2) ,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) ,	--�����˱��
				@ExpRemPerson varchar(10),	--����������
				@businessPeopleID	varchar ,	--�����˱��
				@businessPeople	varchar(10) ,	--������
				@businessReason varchar(200)	,	--��������
				@approvalStatus smallint ,	--��������:0���½���1����������2��������,3:�����
				@xVar XML,					--XML��ʽ������

	@createManID varchar(13),		--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@ExpRemSingleID varchar(15) output	--��������������ţ�ʹ�õ� �ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 403, 1, @curNumber output
	set @ExpRemSingleID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	insert ExpRemSingle(ExpRemSingleID,		--������ID
							departmentID,	--����ID
							ExpRemDepartment,		--��������
							ExpRemDate,		--��������
							projectID,	--��ĿID
							projectName,	--��Ŀ����
							ExpRemSingleNum,	--�������ݼ�����
							note,			--��ע
							expRemSingleType,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
							amount,			--�ϼƽ��
							borrowSingleID,	--ԭ��֧��ID
							originalloan,	--ԭ���
							replenishment,	--Ӧ����
							shouldRefund,	--Ӧ�˿�
							ExpRemPersonID,	--������ID
							ExpRemPerson,	--����������
							businessPeopleID,	--������ID
							businessPeople,		--������
							businessReason,		--��������
							approvalStatus	--��������:0���½���1����������2��������,3:�����
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
			ExpRemDetailsID	varchar(17),	--��������ID
			ExpRemSingleID	varchar(15),	--������ID
			abstract	varchar(100),	--ժҪ
			supplementaryExplanation	varchar(100),	--����˵��
			financialAccountID	varchar(13),	--������ĿID
			financialAccount	varchar(200),	--������Ŀ
			expSum	numeric(15,2)				--���
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
					--���ɱ�������ID
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
	--������ϸ��
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӱ�����', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ������˱�����[' + @ExpRemSingleID + ']��')		
GO



--��ӷ��ñ���������
drop PROCEDURE addExpenseReimbursementDetails
/*
	name:		addExpenseReimbursementDetails
	function:	1.��ӷ��ñ���������
				ע�⣺���洢���̲������༭��
	input: 
				ExpRemDetailsID	varchar(17)	not null,	--��������ID
				ExpRemSingleID	varchar(16)	not null,	--������ID
				abstract	varchar(100)	not null,	--ժҪ
				supplementaryExplanation	varchar(100)	not null,	--����˵��
				financialAccountID	varchar(13)	not null,	--������ĿID
				financialAccount	varchar(200)	not null,	--������Ŀ
				expSum	float	not null,	--���

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

create PROCEDURE addExpenseReimbursementDetails			
				@ExpRemSingleID	varchar(15),	--������ID
				@abstract	varchar(100),	--ժҪ
				@supplementaryExplanation	varchar(100),	--����˵��
				@financialAccountID	varchar(13),	--������ĿID
				@financialAccount	varchar(200),	--������Ŀ
				@expSum	numeric(15,2),	--���

				@createManID varchar(13),		--�����˹���

				@Ret		int output,
				@createTime smalldatetime output,
				@ExpRemDetailsID varchar(17) output	--��������������ID��ʹ�õ�404�ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 404, 1, @curNumber output
	set @ExpRemDetailsID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	insert ExpenseReimbursementDetails(
				ExpRemDetailsID,			--��������ID
				ExpRemSingleID,				--������ID
				abstract,					--ժҪ
				supplementaryExplanation,	--����˵��
				financialAccountID,			--������ĿID
				financialAccount,			--������Ŀ
				expSum						--���
							) 
	values (		
				@ExpRemDetailsID,			--��������ID
				@ExpRemSingleID,				--������ID
				@abstract,					--ժҪ
				@supplementaryExplanation,	--����˵��
				@financialAccountID,			--������ĿID
				@financialAccount,			--������Ŀ
				@expSum						--��� 
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--������ϸ��
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӷ��ñ�������', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ������˷��ñ�������[' + @ExpRemDetailsID + ']��')		
GO

--��Ӳ��÷ѱ�������
drop PROCEDURE addTravelExpensesDetails
/*
	name:		addTravelExpensesDetails
	function:	1.��Ӳ��÷ѱ�������
				ע�⣺���洢���̲������༭��
	input: 
				TravelExpensesDetailsID varchar(18) not null,	--���÷ѱ�������ID
				ExpRemSingleID varchar(15) not null,	--���������
				StartDate smalldatetime	not null,	--��ʼʱ��
				endDate smalldatetime not null,	--��������
				startingPoint varchar(12) not null,	--���
				destination varchar(12) not null,	--�յ�
				vehicle		varchar(12)	not null,	--��ͨ����
				documentsNum	int	not null,	--��������
				vehicleSum	numeric(15,2) not null,	--��ͨ�ѽ��
				financialAccountID	varchar(13)	not null,	--��ĿID
				financialAccount	varchar(20) not null,	--��Ŀ����
				peopleNum	int not null,	--����
				travelDays float ,	-- ��������
				TravelAllowanceStandard	numeric(15,2),	--�������׼
				travelAllowancesum	numeric(15,2)	not null,	--�������
				otherExpenses	varchar(20) null,	--��������
				otherExpensesSum	numeric(15,2)	null,	--�������ý��

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

create PROCEDURE addTravelExpensesDetails			
				@ExpRemSingleID varchar(15),	--���������
				@StartDate smalldatetime,	--��ʼʱ��
				@endDate smalldatetime,	--��������
				@startingPoint varchar(12),	--���
				@destination varchar(12),	--�յ�
				@vehicle		varchar(12),	--��ͨ����
				@documentsNum	int,	--��������
				@vehicleSum	numeric(15,2),	--��ͨ�ѽ��
				@financialAccountID	varchar(13),	--��ĿID
				@financialAccount	varchar(20),	--��Ŀ����
				@peopleNum	int,	--����
				@travelDays float,	-- ��������
				@TravelAllowanceStandard numeric(15,2),	--�������׼
				@travelAllowancesum	numeric(15,2),	--�������
				@otherExpenses	varchar(20),	--��������
				@otherExpensesSum	numeric(15,2),	--�������ý��

				@createManID varchar(13),		--�����˹���

				@Ret		int output,
				@createTime smalldatetime output,
				@TravelExpensesDetailsID varchar(18) output	--���������÷ѱ�������ID��ʹ�õ�405�ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 405, 1, @curNumber output
	set @TravelExpensesDetailsID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	insert TravelExpensesDetails(
				TravelExpensesDetailsID,	--���÷ѱ�������
				ExpRemSingleID,			--���������
				StartDate,					--��ʼʱ��
				endDate,					--��������
				startingPoint,				--���
				destination,				--�յ�
				vehicle,					--��ͨ����
				documentsNum,				--��������
				vehicleSum,				--��ͨ�ѽ��
				financialAccountID,		--��ĿID
				financialAccount,			--��Ŀ����
				peopleNum,					--����
				travelDays,				--��������
				TravelAllowanceStandard,	--�������׼
				travelAllowancesum,		--�������
				otherExpenses,				--��������
				otherExpensesSum			--�������ý��
							) 
	values (	
				@TravelExpensesDetailsID,	--���÷ѱ�������
				@ExpRemSingleID,			--���������
				@StartDate,					--��ʼʱ��
				@endDate,					--��������
				@startingPoint,				--���
				@destination,				--�յ�
				@vehicle,					--��ͨ����
				@documentsNum,				--��������
				@vehicleSum,				--��ͨ�ѽ��
				@financialAccountID,		--��ĿID
				@financialAccount,			--��Ŀ����
				@peopleNum,					--����
				@travelDays,				--��������
				@TravelAllowanceStandard,	--�������׼
				@travelAllowancesum,		--�������
				@otherExpenses,				--��������
				@otherExpensesSum			--�������ý��
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--������ϸ��
	declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��Ӳ��÷ѱ�������', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ������˲��÷ѱ�������[' + @TravelExpensesDetailsID + ']��')		
GO


--ɾ��������
drop PROCEDURE delExpRemSingle
/*
	name:		delExpRemSingle
	function:	ɾ��������
	input: 
				@ExpRemSingleID varchar(15),			--������ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
create PROCEDURE delExpRemSingle
				@ExpRemSingleID varchar(15),			--������ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ��0��ɾ���������ɹ���1���ñ����������ڣ�2���ñ������ѱ����������޷�ɾ����3���ñ�����Ϊ���״̬�޷�ɾ��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫɾ���ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	--������
		begin
			set @Ret = 1
			return
		end
	--�ж����״̬
	declare @thisProgress smallint
	set @thisProgress = (select approvalStatus from ExpRemSingle
					where ExpRemSingleID = @ExpRemSingleID)
	if (@thisProgress<>0)
		begin
			set @Ret = 3
			return
		end
	--���༭����
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
				--ɾ��ָ��������
			delete FROM ExpRemSingle where ExpRemSingleID= @ExpRemSingleID
			--�ж����޴���
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				return
			end    
	
			set @Ret = 0
		end
	

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @lockManName = '¬�γ�'
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), 'ɾ��������', 'ϵͳ�����û�' + @lockManName
												+ 'ɾ���˱�����['+ @ExpRemSingleID +']��')
GO



drop PROCEDURE lockExpRemSingleEdit
/*
	name:		lockExpRemSingleEdit
	function:	�����������༭������༭��ͻ
	input: 
				@ExpRemSingleID varchar(15),			--������ID
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
create PROCEDURE lockExpRemSingleEdit
				@ExpRemSingleID varchar(15),			--������ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	


	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = '¬�γ�'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˱�����['+ @ExpRemSingleID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockExpRemSingleEdit
/*
	name:		unlockExpRemSingleEdit
	function:	�ͷ������������༭������༭��ͻ
	input: 
				@ExpRemSingleID varchar(15),			--������ID
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
create PROCEDURE unlockExpRemSingleEdit
				@ExpRemSingleID varchar(15),			--������ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
			--�ͷű���������
			update ExpRemSingle set lockManID = '' where ExpRemSingleID = @ExpRemSingleID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end
				----ȡά���˵�������
				declare @lockManName nvarchar(30)
				--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				set @lockManName = '¬�γ�'
				--�Ǽǹ�����־��
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '�ͷű������༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ��˱�����['+ @ExpRemSingleID +']�ı༭����')
		end
	else   --���ظý�֧��δ���κ�������
		begin
			set @Ret = 8
			return
		end

GO


drop PROCEDURE editExpRemSingle
/*
	name:		editExpRemSingle
	function:	1.�༭������
				ע�⣺���洢���̲������༭��
	input: 
				@ExpRemSingleID varchar(15),  --������ID			
				@departmentID varchar(13) ,	--����ID
				@ExpRemDepartment varchar(20)	,	--��������
				@ExpRemDate smalldatetime ,	--��������
				@projectID varchar(13) ,	--��ĿID
				@projectName varchar(50) ,	--��Ŀ����
				@ExpRemSingleNum smallint ,	--�������ݼ�����
				@note varchar(200),	--��ע
				@expRemSingleType smallint ,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
				@amount numeric(15,2) ,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan numeric(15,2) ,	--ԭ���
				@replenishment numeric(15,2) ,	--Ӧ����
				@shouldRefund numeric(15,2) ,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) ,	--�����˱��
				@ExpRemPerson varchar(10),	--����������
				@businessPeopleID	varchar ,	--�����˱��
				@businessPeople	varchar(10) ,	--������
				@businessReason varchar(200)	,	--��������
				@approvalStatus smallint ,	--��������:0���½���1����������2��������,3:�����

				@lockManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ý�֧���ѱ�������2���ý�֧��Ϊ���״̬9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by 
*/
create PROCEDURE editExpRemSingle	
				@ExpRemSingleID varchar(15),  --������ID			
				@departmentID varchar(13) ,	--����ID
				@ExpRemDepartment varchar(20)	,	--��������
				@ExpRemDate smalldatetime ,	--��������
				@projectID varchar(13) ,	--��ĿID
				@projectName varchar(50) ,	--��Ŀ����
				@ExpRemSingleNum smallint ,	--�������ݼ�����
				@note varchar(200),	--��ע
				@expRemSingleType smallint ,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
				@amount numeric(15,2) ,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan numeric(15,2) ,	--ԭ���
				@replenishment numeric(15,2) ,	--Ӧ����
				@shouldRefund numeric(15,2) ,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) ,	--�����˱��
				@ExpRemPerson varchar(10),	--����������
				@businessPeopleID	varchar ,	--�����˱��
				@businessPeople	varchar(10) ,	--������
				@businessReason varchar(200)	,	--��������
				@approvalStatus smallint ,	--��������:0���½���1����������2��������,3:�����

				@lockManID  varchar(13),		--������ID
				@Ret		int output			--�ɹ���ʾ��0���ɹ���1���õ����ѱ������û�������2���õ��ݴ������״̬�޷��༭��3���õ��ݲ�����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from ExpRemSingle where ExpRemSingleID= @ExpRemSingleID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 3
		return
	end
	--��ѯ�������Ƿ�Ϊ���״̬
	declare @thisflowProgress smallint
	set @thisflowProgress = (select approvalStatus from ExpRemSingle where ExpRemSingleID = @ExpRemSingleID)
	if (@thisflowProgress<>0)
		begin
			set @Ret = 2
			return
		end

	--���༭�ı������Ƿ��б༭������������
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
			
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	update ExpRemSingle set		
				departmentID = @departmentID,	--����ID
				ExpRemDepartment = @ExpRemDepartment,	--��������
				ExpRemDate = @ExpRemDate,	--��������
				projectID = @projectID,	--��ĿID
				projectName = @projectName,	--��Ŀ����
				ExpRemSingleNum = @ExpRemSingleNum,	--�������ݼ�����
				note = @note,	--��ע
				expRemSingleType = @expRemSingleType,	--���������ͣ�0�����ñ�������1�����÷ѱ�����
				amount = @amount,	--�ϼƽ��
				borrowSingleID = @borrowSingleID,	--ԭ��֧��ID
				originalloan = @originalloan,	--ԭ���
				replenishment = @replenishment,	--Ӧ����
				shouldRefund = @shouldRefund,	--Ӧ�˿�
				ExpRemPersonID = @ExpRemPersonID,	--�����˱��
				ExpRemPerson = @ExpRemPerson,	--����������
				businessPeopleID = @businessPeopleID,	--�����˱��
				businessPeople = @businessPeople,	--������
				businessReason = @businessReason,	--��������
				approvalStatus = @approvalStatus	--��������:0���½���1����������2��������,3:�����
				where ExpRemSingleID = @ExpRemSingleID--������ID
	set @Ret = 0
	if @@ERROR <> 0 
	----������ϸ��
	--declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName,  getdate(), '�༭������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��༭�˱�������[' + @ExpRemSingleID + ']��')
GO