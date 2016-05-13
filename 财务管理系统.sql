









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










--�˻���ϸ��
drop table accountDetailsList 
create table accountDetailsList(
AccountDetailsID	varchar(16)	not null,	--�˻���ϸID
accountID 	varchar(13)	not null,	--�˻�ID
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
--���
foreign key(accountID) references accountList(accountID) on update cascade on delete cascade,
--����
	 CONSTRAINT [PK_AccountDetailsID] PRIMARY KEY CLUSTERED 
(
	[AccountDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--����˻���ϸ
drop PROCEDURE addAccountDetails
/*
	name:		addAccountDetails
	function:	1.����˻���ϸ
				ע�⣺���洢���̲������༭��
	input: 
				@AccountDetailsID	varchar(16) output,	--�˻���ϸID��������ʹ��408�ź��뷢��������
				@accountID 	varchar(13),		--�˻�ID
				@account		varchar(30),		--�˻�����
				@detailDate	smalldatetime	,	--����
				@abstract	varchar(200),			--ժҪ
				@borrow		money,			--��
				@loan		money,			--��
				@balance		money,			--���
				@departmentID	varchar(13),		--����ID
				@department		varchar(30),	--����
				@projectID		varchar(13),	--��ĿID
				@project			varchar(100),	--��Ŀ
				@clerkID		varchar(13),		--������ID
				@clerk		varchar(20),		--������
				@remarks		varchar(200),		--��ע

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE addAccountDetails			
				@AccountDetailsID	varchar(16) output,	--�˻���ϸID��������ʹ��408�ź��뷢��������
				@accountID 	varchar(13),		--�˻�ID
				@account		varchar(30),		--�˻�����
				@detailDate	smalldatetime	,	--����
				@abstract		varchar(200),		--ժҪ
				@borrow		money,			--��
				@loan		money,			--��
				@balance		money,			--���
				@departmentID	varchar(13),		--����ID
				@department		varchar(30),	--����
				@projectID		varchar(13),	--��ĿID
				@project			varchar(100),	--��Ŀ
				@clerkID		varchar(13),		--������ID
				@clerk		varchar(20),		--������
				@remarks		varchar(200),		--��ע

				@createManID varchar(13),		--�����˹���

				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻��Ѵ��ڣ�9��δ֪����

	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 408, 1, @curNumber output
	set @AccountDetailsID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	declare @createTime smalldatetime
	set @createTime = getdate()

	insert accountDetailsList(
				AccountDetailsID,	--�˻���ϸID��������ʹ��408�ź��뷢��������
				accountID,		--�˻�ID
				account,			--�˻�����
				detailDate,		--����
				abstract,			--ժҪ
				borrow,			--��
				loan	,			--��
				balance,			--���
				departmentID,		--����ID
				department,		--����
				projectID,		--��ĿID
				project,			--��Ŀ
				clerkID,			--������ID
				clerk,			--������
				remarks,			--��ע
				createManID,		--�����˹���
				createManName,	--����������
				createTime		--����ʱ��
							) 
	values (		
				@AccountDetailsID,	--�˻���ϸID��������ʹ��408�ź��뷢��������
				@accountID,		--�˻�ID
				@account,			--�˻�����
				@detailDate,		--����
				@abstract,		--ժҪ
				@borrow,			--��
				@loan	,		--��
				@balance,			--���
				@departmentID,	--����ID
				@department,		--����
				@projectID,		--��ĿID
				@project,			--��Ŀ
				@clerkID,			--������ID
				@clerk,			--������
				@remarks,			--��ע
				@createManID,		--�����˹���
				@createManName,	--����������
				@createTime		--����ʱ��
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
	values(@createManID, @createManName, @createTime, '����˻���ϸ', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ��������˻���ϸ[' + @AccountDetailsID + ']��')		
GO



--ɾ���˻���ϸ
drop PROCEDURE delAccountDetails
/*
	name:		delAccountList
	function:		1.ɾ���˻���ϸ
				ע�⣺���洢���������༭��
	input: 
				@AccountDetailsID	varchar(16) output,	--�˻���ϸID��������ʹ��408�ź��뷢��������
				@lockManID varchar(13),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻���ϸ�������û�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE delAccountDetails		
				@AccountDetailsID	varchar(16),	--�˻���ϸID������
				@lockManID   varchar(13) output,		--������ID

				@Ret		int output			--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻���ϸ�������û�������9��δ֪����

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--�ж�Ҫɾ�����˻���ϸ�Ƿ����
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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

	--ȡά���˵�������
	declare @lockMan nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @lockMan = '¬�γ�'
	declare @createTime smalldatetime
	set @createTime = getdate()

	delete from accountDetailsList where AccountDetailsID = @AccountDetailsID

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
	values(@lockManID, @lockMan, @createTime, 'ɾ���˻���ϸ', 'ϵͳ�����û�' + @lockMan + 
		'��Ҫ��ɾ�����˻���ϸ[' + @AccountDetailsID + ']��')		
GO


--�༭�˻���ϸ
drop PROCEDURE editAccountDetails	
/*
	name:		editAccountDetails	
	function:	1.�༭�˻���ϸ
				ע�⣺���洢���������༭��
	input: 
				@AccountDetailsID	varchar(16) output,	--�˻���ϸID������
				@accountID 	varchar(13),		--�˻�ID
				@account		varchar(30),		--�˻�����
				@detailDate	smalldatetime	,	--����
				@abstract	varchar(200),			--ժҪ
				@borrow		money,			--��
				@loan		money,			--��
				@balance		money,			--���
				@departmentID	varchar(13),		--����ID
				@department		varchar(30),	--����
				@projectID		varchar(13),	--��ĿID
				@project			varchar(100),	--��Ŀ
				@clerkID		varchar(13),		--������ID
				@clerk		varchar(20),		--������
				@remarks		varchar(200),		--��ע

				@lockManID varchar(10)output,		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻���ϸ�ѱ������û�������9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/


select count(*) from accountDetailsList where AccountDetailsID= 'ZHMX201605050002'
create PROCEDURE editAccountDetails				
				@AccountDetailsID	varchar(16) ,	--�˻���ϸID������
				@accountID 	varchar(13),		--�˻�ID
				@account		varchar(30),		--�˻�����
				@detailDate	smalldatetime	,	--����
				@abstract	varchar(200),			--ժҪ
				@borrow		money,			--��
				@loan		money,			--��
				@balance		money,			--���
				@departmentID	varchar(13),		--����ID
				@department		varchar(30),	--����
				@projectID		varchar(13),	--��ĿID
				@project			varchar(100),	--��Ŀ
				@clerkID		varchar(13),		--������ID
				@clerk		varchar(20),		--������
				@remarks		varchar(200),		--��ע

				@lockManID varchar(13) output,		--������ID

				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻��ѱ������û�������9��δ֪����

	WITH ENCRYPTION 
AS
	--�ж�Ҫ�༭���˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	declare @createTime smalldatetime
	set @createTime = getdate()

	update accountDetailsList set
				AccountDetailsID = @AccountDetailsID,	--�˻���ϸID��������ʹ��408�ź��뷢��������
				accountID = @accountID,		--�˻�ID
				account = @account,			--�˻�����
				detailDate = @detailDate,		--����
				abstract = @abstract,			--ժҪ
				borrow = @borrow,			--��
				loan	 = @loan	,			--��
				balance = @balance,			--���
				departmentID = @departmentID,		--����ID
				department = @department,		--����
				projectID = @projectID,		--��ĿID
				project = @project,			--��Ŀ
				clerkID = @clerkID,			--������ID
				clerk = @clerk,			--������
				remarks = @remarks,			--��ע
				modiManID = @lockManID,		--�����˹���
				modiManName = @createManName,	--����������
				modiTime = @createTime	--����ʱ��
				where	AccountDetailsID = @AccountDetailsID		--�˻�ID,����


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
	values(@lockManID, @createManName, @createTime, '�༭�˻�', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ��༭���˻�[' + @accountID + ']��')		
GO


drop PROCEDURE lockAccountDetailsEdit
/*
	name:		lockAccountDetailsEdit
	function: 	�����˻���ϸ�༭������༭��ͻ
	input: 
				@AccountDetailsID varchar(16),		--�˻�ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�������˻���ϸ�����ڣ�2:Ҫ�������˻���ϸ���ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountDetailsEdit
				@AccountDetailsID varchar(16),		--�˻�ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ�������˻���ϸ�����ڣ�2:Ҫ�������˻���ϸ���ڱ����˱༭��9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	


	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = '¬�γ�'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����˻���ϸ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������˻���ϸ['+ @AccountDetailsID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockAccountDetailsEdit
/*
	name:		lockAccountDetailsEdit
	function: 	�ͷ������˻���ϸ�༭������༭��ͻ
	input: 
				@AccountDetailsID varchar(16),		--�˻�ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ��������˻���ϸ�����ڣ�2:Ҫ�ͷ��������˻���ϸ���ڱ����˱༭��8�����˻���ϸδ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockAccountDetailsEdit
				@AccountDetailsID varchar(16),			--�˻�ID
				@lockManID varchar(13) output,	--������ID�������ǰ�˻����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ��������˻���ϸ�����ڣ�2:Ҫ�ͷ��������˻���ϸ���ڱ����˱༭��8�����˻���ϸδ���κ�������9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from accountDetailsList where AccountDetailsID= @AccountDetailsID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
			--�ͷű���������
			update accountDetailsList set lockManID = '' where AccountDetailsID = @AccountDetailsID
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
				values(@lockManID, @lockManName, getdate(), '�ͷ��˻���ϸ�༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ����˻���ϸ['+ @AccountDetailsID +']�ı༭����')
		end
	else   --���ظ��˻���ϸδ���κ�������
		begin
			set @Ret = 8
			return
		end
GO





--����һ����
drop table incomeList
create table incomeList(
incomeInformationID varchar(16)	not null,	--������ϢID
projectID	varchar(13)	not null,	--��ĿID
project		varchar(50)	not null,	--��Ŀ����
customerID	varchar(13)	not null,	--�ͻ�ID
customerName	varchar(30)	not null,	--�ͻ�����
abstract	varchar(200)	not null,	--ժҪ
incomeSum	money not null,	--������
contractAmount money ,	--��ͬ���
receivedAmount	money,	--���ս��
remarks	varchar(200),	--��ע
collectionModeID	varchar(13) not null,	--�տʽID
collectionMode		varchar(50)	not null,	--�տʽ
startDate	smalldatetime	not null,	--�տ�����
paymentApplicantID	varchar(13)	not null,	--�տ�������ID
payee	varchar(10)	not null,	--�տ���
confirmationDate	smalldatetime	,	--ȷ������
confirmationPersonID	varchar(13),	--ȷ����ID
confirmationPerson		varchar(10),	--ȷ����
approvalOpinion			varchar(200),	--�������
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
--���
foreign key(collectionModeID) references accountList(accountID) on update cascade on delete cascade,
--����
	 CONSTRAINT [PK_incomeInformationID] PRIMARY KEY CLUSTERED 
(
	[incomeInformationID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


drop PROCEDURE addIncome
/*
	name:		addIncome
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 

				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),	--ժҪ
				@incomeSum	money,	--������
				@contractAmount money,	--��ͬ���
				@receivedAmount	money,	--���ս��
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13),	--�տʽID
				@collectionMode		varchar(50),	--�տʽ
				@startDate	smalldatetime	,	--�տ�����
				@paymentApplicantID	varchar(13),	--�տ�������ID
				@payee	varchar(10),	--�տ���
				@createManID varchar(13),	--������

				
	output: 
				@incomeInformationID varchar(16)	output,	--������ϢID��������ʹ��411�ź��뷢��������
				@Ret int output				--�����ɹ���ʶ0:�ɹ���9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE addIncome
				@incomeInformationID varchar(16)	output,	--������ϢID��������ʹ��411�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),	--ժҪ
				@incomeSum	money,	--������
				@contractAmount money,	--��ͬ���
				@receivedAmount	money,	--���ս��
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13),	--�տʽID
				@collectionMode		varchar(50),	--�տʽ
				@startDate	smalldatetime	,	--�տ�����
				@paymentApplicantID	varchar(13),	--�տ�������ID
				@payee	varchar(10),	--�տ���
				@createManID varchar(13),	--������
				@Ret int output				--�����ɹ���ʶ0:�ɹ���9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 411, 1, @curNumber output
	set @incomeInformationID = @curNumber

	----ȡά���˵�������
	declare @createManName nvarchar(30),@createTime smalldatetime
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()
	insert incomeList (
						incomeInformationID,	--������ϢID��������ʹ��411�ź��뷢��������
						projectID,	--��ĿID
						project,	--��Ŀ����
						customerID,	--�ͻ�ID
						customerName,	--�ͻ�����
						abstract	,	--ժҪ
						incomeSum,	--������
						contractAmount,	--��ͬ���
						receivedAmount,	--���ս��
						remarks,	--��ע
						collectionModeID,	--�տʽID
						collectionMode,	--�տʽ
						startDate,	--�տ�����
						paymentApplicantID,	--�տ�������ID
						payee,	--�տ���
						createManID,	--������ID
						createManName,	--������
						createTime		--����ʱ��
									)
						values     (
						@incomeInformationID,	--������ϢID��������ʹ��411�ź��뷢��������
						@projectID,	--��ĿID
						@project,	--��Ŀ����
						@customerID,	--�ͻ�ID
						@customerName,	--�ͻ�����
						@abstract	,	--ժҪ
						@incomeSum,	--������
						@contractAmount,	--��ͬ���
						@receivedAmount,	--���ս��
						@remarks,	--��ע
						@collectionModeID,	--�տʽID
						@collectionMode,	--�տʽ
						@startDate,	--�տ�����
						@paymentApplicantID,	--�տ�������ID
						@payee,	--�տ���
						@createManID,	--������ID
						@createManName,	--������
						@createTime		--����ʱ��
									)
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--�Ǽǹ�����־��
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@createManID, @createManName, getdate(), '�����������', 'ϵͳ�����û�' + @createManName	+ '��Ҫ���������������['+ @incomeInformationID +']��')
GO

--ȷ��ָ��������ϸ
drop PROCEDURE confirmIncome
/*				ȷ��ָ��������ϸ
	name:		confirmIncome
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 
				@incomeInformationID varchar(16)	,	--������ϢID������
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(13),	--ȷ����ID
				@confirmationPerson		varchar(10),	--ȷ����
				@approvalOpinion			varchar(200),	--�������

				
	output: 
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ�������ϸ�����ڣ�2:Ҫȷ�ϵ�������ϸ���ڱ�����������3:��������ϸδ��������������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE confirmIncome
				@incomeInformationID varchar(16)	,	--������ϢID������
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(13),	--ȷ����ID
				@confirmationPerson		varchar(10),	--ȷ����
				@approvalOpinion			varchar(200),	--�������
				@lockManID varchar(13) output,	--�����ˣ������ǰ��������ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ�������ϸ�����ڣ�2:Ҫȷ�ϵ�������ϸ���ڱ�����������3:��������ϸδ��������������9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
			--ȡά���˵�������
			declare @lockManName nvarchar(30),@modiTime smalldatetime
			--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @lockManName = '¬�γ�'
			set @modiTime = getdate()
			--���ȷ����Ϣ
			update incomeList set confirmationDate = @confirmationDate,	--ȷ������
								confirmationPersonID =  @confirmationPersonID	,	--ȷ����ID
								confirmationPerson = @confirmationPerson,	--ȷ����
								approvalOpinion = @approvalOpinion,		--�������
								modiManID = @lockManID,			--ά��ID	
								modiManName = @lockManName,			--ά��������	
								modiTime = @modiTime				--ά��ʱ��
								where incomeInformationID = @incomeInformationID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--�Ǽǹ�����־��
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), 'ȷ��������ϸ', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ��ȷ����������ϸ['+ @incomeInformationID +']��')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO

--ɾ��������ϸ
drop PROCEDURE delIncome
/*
	name:		delIncome
	function:		1.ɾ��������ϸ
				ע�⣺���洢���������༭��
	input: 
				@incomeInformationID	varchar(16) output,	--������ϢID������
				@lockManID varchar(13),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1����������ϸ�����ڣ�2����������ϸ�������û�������3������������������ϸ��ɾ�������ͻ��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-5-6
*/

create PROCEDURE delIncome		
				@incomeInformationID	varchar(16),	--������ϢID������
				@lockManID   varchar(13) output,		--������ID

				@Ret		int output			--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1����������ϸ�����ڣ�2����������ϸ�������û�������3������������������ϸ��ɾ�������ͻ��9��δ֪����

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--�ж�Ҫɾ�����˻���ϸ�Ƿ����
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
				--ȡά���˵�������
				declare @lockMan nvarchar(30)
				--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
				set @lockMan = '¬�γ�'
				declare @createTime smalldatetime
				set @createTime = getdate()

				delete from incomeList where incomeInformationID = @incomeInformationID

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
				values(@lockManID, @lockMan, @createTime, 'ɾ��������ϸ', 'ϵͳ�����û�' + @lockMan + 
					'��Ҫ��ɾ����������ϸ[' + @incomeInformationID + ']��')		
		end
	else
	set @Ret = 3
	return
	
GO


--�༭������ϸ
drop PROCEDURE editIncome	
/*
	name:		editIncome
	function:	1.�༭������ϸ
				ע�⣺���洢���������༭��
	input: 
				@incomeInformationID varchar(16)	output,	--������ϢID��������ʹ��411�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),	--ժҪ
				@incomeSum	money,	--������
				@contractAmount money,	--��ͬ���
				@receivedAmount	money,	--���ս��
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13),	--�տʽID
				@collectionMode		varchar(50),	--�տʽ
				@startDate	smalldatetime	,	--�տ�����
				@paymentApplicantID	varchar(13),	--�տ�������ID
				@payee	varchar(10),	--�տ���


	output: 
				@lockManID varchar(10)output,		--������ID
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻���ϸ�ѱ������û�������9��δ֪����

	author:		¬�γ�
	CreateDate:	2016-3-23

*/



create PROCEDURE editIncome			
				@incomeInformationID varchar(16)	output,	--������ϢID��������ʹ��411�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),	--ժҪ
				@incomeSum	money,	--������
				@contractAmount money,	--��ͬ���
				@receivedAmount	money,	--���ս��
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13),	--�տʽID
				@collectionMode		varchar(50),	--�տʽ
				@startDate	smalldatetime	,	--�տ�����
				@paymentApplicantID	varchar(13),	--�տ�������ID
				@payee	varchar(10),	--�տ���

				@lockManID varchar(13) output,		--������ID
				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻��ѱ������û�������3:����������������ϸ����༭��ͻ4����������ϸ��ȷ���޷��༭9��δ֪����

	WITH ENCRYPTION 
AS
	--�ж�Ҫ�༭��������ϸ�Ƿ����
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������״̬
	declare @thisperson varchar(13)
	set @thisperson = (select confirmationPersonID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--���༭����
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
	
			--ȡά���˵�������
			declare @createManName nvarchar(30)
			--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			set @createManName = '¬�γ�'
			declare @createTime smalldatetime
			set @createTime = getdate()

			update incomeList set
						projectID = @projectID,	--��ĿID
						project = @project,	--��Ŀ����
						customerID = @customerID,	--�ͻ�ID
						customerName = @customerName,	--�ͻ�����
						abstract	= @abstract,	--ժҪ
						incomeSum = @incomeSum,	--������
						contractAmount = @contractAmount,	--��ͬ���
						receivedAmount = @receivedAmount,	--���ս��
						remarks = @remarks,	--��ע
						collectionModeID = @collectionModeID,	--�տʽID
						collectionMode = @collectionMode,	--�տʽ
						startDate = @startDate,	--�տ�����
						paymentApplicantID = @paymentApplicantID,	--�տ�������ID
						payee = @payee,	--�տ���
						modiManID = @lockManID,	--ά����ID
						modiManName = @createManName,	--ά����
						modiTime = @createTime		--ά��ʱ��
						where	incomeInformationID = @incomeInformationID		--������ϢID������


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
			values(@lockManID, @createManName, @createTime, '�༭������ϸ', 'ϵͳ�����û�' + @createManName + 
				'��Ҫ��༭��������ϸ[' + @incomeInformationID + ']��')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockIncomeEdit
/*
	name:		lockAccountDetailsEdit
	function: 	����������ϸ�༭������༭��ͻ
	input: 
				@incomeInformationID varchar(16),		--������ϢID
				@lockManID varchar(13) output,	--�����ˣ������ǰ������ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ������������ϸ�����ڣ�2:Ҫ������������ϸ���ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockIncomeEdit
				@incomeInformationID varchar(16),		--������ϢID
				@lockManID varchar(13) output,	--�����ˣ������ǰ������ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ������������ϸ�����ڣ�2:Ҫ������������ϸ���ڱ����˱༭��9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	


	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = '¬�γ�'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����������ϸ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������������ϸ['+ @incomeInformationID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockIncomeEdit
/*
	name:		unlockIncomeEdit
	function: 	�ͷ�����������ϸ�༭������༭��ͻ
	input: 
				@incomeInformationID varchar(16),		--������ϸID
				@lockManID varchar(13) output,			--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ�������������ϸ�����ڣ�2:Ҫ�ͷ�������������ϸ���ڱ����˱༭��8����������ϸδ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockIncomeEdit
				@incomeInformationID varchar(16),			--������ϸID
				@lockManID varchar(13) output,	--������ID�������ǰ������ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ�������������ϸ�����ڣ�2:Ҫ�ͷ�������������ϸ���ڱ����˱༭��8����������ϸδ���κ�������9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
			--�ͷű���������
			update incomeList set lockManID = '' where incomeInformationID = @incomeInformationID
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
				values(@lockManID, @lockManName, getdate(), '�ͷ�������ϸ�༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ���������ϸ['+ @incomeInformationID +']�ı༭����')
		end
	else   --���ظ�������ϸδ���κ�������
		begin
			set @Ret = 8
			return
		end
GO



--֧��һ����
drop table	expensesList
create table expensesList(
expensesID	varchar(16)	not null,	--֧����ϢID
projectID	varchar(13)	not null,	--��ĿID
project		varchar(50)	not null,	--��Ŀ����
customerID	varchar(13)	not null,	--�ͻ�ID
customerName	varchar(30)	not null,	--�ͻ�����
abstract	varchar(200)	not null,	--ժҪ
expensesSum	money	not null,	--֧�����
contractAmount money ,	--��ͬ���
receivedAmount money,	--�Ѹ����
remarks	varchar(200),	--��ע
collectionModeID	varchar(13) not null,	--���ʽID
collectionMode		varchar(50)	not null,	--���ʽ
startDate	smalldatetime	not null,	--��������
paymentApplicantID	varchar(13)	not null,	--����������ID
paymentApplicant	varchar(10)	not null,	--����������
confirmationDate	smalldatetime	,	--ȷ������
confirmationPersonID	varchar(13),	--ȷ����ID
confirmationPerson		varchar(10),	--ȷ����
approvalOpinion			varchar(200),	--�������
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
--���
foreign key(collectionModeID) references accountList(accountID) on update cascade on delete cascade,
--����
	 CONSTRAINT [PK_expensesID] PRIMARY KEY CLUSTERED 
(
	[expensesID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




drop PROCEDURE confirmexpenses
/*
	name:		confirmexpenses
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 
				@expensesID varchar(16)	,	--֧����ϢID������
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(13),	--ȷ����ID
				@confirmationPerson		varchar(10),	--ȷ����
				@approvalOpinion			varchar(200),	--�������

				
	output: 
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ�֧����ϸ�����ڣ�2:Ҫȷ�ϵ�֧����ϸ���ڱ�����������3:��֧����ϸδ��������������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE confirmexpenses
				@expensesID varchar(16)	,	--֧����ϢID������
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(13),	--ȷ����ID
				@confirmationPerson	varchar(10),	--ȷ����
				@approvalOpinion		varchar(200),	--�������
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧����ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ�֧����ϸ�����ڣ�2:Ҫȷ�ϵ�֧����ϸ���ڱ�����������3:��֧����ϸδ��������������9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
			--ȡά���˵�������
			declare @lockManName nvarchar(30),@modiTime smalldatetime
			--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @lockManName = '¬�γ�'
			set @modiTime = getdate()
			--���ȷ����Ϣ
			update expensesList set confirmationDate = @confirmationDate,	--ȷ������
								confirmationPersonID =  @confirmationPersonID	,	--ȷ����ID
								confirmationPerson = @confirmationPerson,	--ȷ����
								approvalOpinion = @approvalOpinion,		--�������
								modiManID = @lockManID,			--ά��ID	
								modiManName = @lockManName,			--ά��������	
								modiTime = @modiTime				--ά��ʱ��
								where expensesID = @expensesID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--�Ǽǹ�����־��
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), 'ȷ��֧����ϸ', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ��ȷ����֧����ϸ['+ @expensesID +']��')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO


--���֧����ϸ
drop PROCEDURE addExpenses
/*
	name:		addExpenses
	function:	1.���֧����ϸ
				ע�⣺���洢���̲������༭��
	input: 

				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	     varchar(200),	--ժҪ
				@expensesSum	money,	--֧�����
				@contractAmount money,	--��ͬ���
				@receivedAmount money,	--�Ѹ����
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13) ,	--���ʽID
				@collectionMode		varchar(50),	--���ʽ
				@startDate	smalldatetime	,	--��������
				@paymentApplicantID	varchar(13),	--����������ID
				@paymentApplicant	varchar(10),	--����������

				@createManID varchar(13),		--�����˹���
	output: 
				@expensesID	varchar(16),	--֧����ϢID��������ʹ��412�ź��뷢��������
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE addExpenses			
				@expensesID	varchar(16) output,	--֧����ϢID��������ʹ��412�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),	--ժҪ
				@expensesSum	money,	--֧�����
				@contractAmount money,	--��ͬ���
				@receivedAmount money,	--�Ѹ����
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13) ,	--���ʽID
				@collectionMode		varchar(50),	--���ʽ
				@startDate	smalldatetime	,	--��������
				@paymentApplicantID	varchar(13),	--����������ID
				@paymentApplicant	varchar(10),	--����������

				@createManID varchar(13),		--�����˹���

				@Ret		int output

	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 412, 1, @curNumber output
	set @expensesID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30),@createTime smalldatetime
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	insert expensesList(
				expensesID,	--֧����ϢID��������ʹ��412�ź��뷢��������
				projectID,	--��ĿID
				project,	--��Ŀ����
				customerID,	--�ͻ�ID
				customerName,	--�ͻ�����
				abstract	,	--ժҪ
				expensesSum,	--֧�����
				contractAmount,	--��ͬ���
				receivedAmount,	--�Ѹ����
				remarks,	--��ע
				collectionModeID,	--���ʽID
				collectionMode,	--���ʽ
				startDate,	--��������
				paymentApplicantID,	--����������ID
				paymentApplicant,	--����������
				createManID,			--�����˹���
				createManName,	--������
				createTime				--����ʱ��
							) 
	values (		
				@expensesID,	--֧����ϢID��������ʹ��412�ź��뷢��������
				@projectID,	--��ĿID
				@project,	--��Ŀ����
				@customerID,	--�ͻ�ID
				@customerName,	--�ͻ�����
				@abstract	,	--ժҪ
				@expensesSum,	--֧�����
				@contractAmount,	--��ͬ���
				@receivedAmount,	--�Ѹ����
				@remarks,	--��ע
				@collectionModeID,	--���ʽID
				@collectionMode,	--���ʽ
				@startDate,	--��������
				@paymentApplicantID,	--����������ID
				@paymentApplicant,	--����������
				@createManID,			--�����˹���
				@createManName,	--������
				@createTime				--����ʱ��				
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
	values(@createManID, @createManName, @createTime, '���֧����ϸ', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ�������֧����ϸ[' + @expensesID + ']��')		
GO

--ɾ��֧����ϸ
drop PROCEDURE delExpenses
/*
	name:		delExpenses
	function:		1.ɾ��֧����ϸ
				ע�⣺���洢���������༭��
	input: 
				@expensesID	varchar(16) output,		--֧����ϢID������
				@lockManID varchar(13),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1����֧����ϸ�����ڣ�2����֧����ϸ�������û�������3������������֧����ϸ��ɾ�������ͻ��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-5-6
*/

create PROCEDURE delExpenses	
				@expensesID	varchar(16),		--֧����ϢID������
				@lockManID   varchar(13) output,		--������ID

				@Ret		int output			--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1����֧����ϸ�����ڣ�2����֧����ϸ�������û�������3������������֧����ϸ��ɾ�������ͻ��9��δ֪����

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--�ж�Ҫɾ�����˻���ϸ�Ƿ����
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
				--ȡά���˵�������
				declare @lockMan nvarchar(30)
				--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
				set @lockMan = '¬�γ�'
				declare @createTime smalldatetime
				set @createTime = getdate()

				delete from expensesList where expensesID = @expensesID

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
				values(@lockManID, @lockMan, @createTime, 'ɾ��֧����ϸ', 'ϵͳ�����û�' + @lockMan + 
					'��Ҫ��ɾ����֧����ϸ[' + @expensesID + ']��')		
		end
	else
	set @Ret = 3
	return
	
GO


--�༭֧����ϸ
drop PROCEDURE editExpenses	
/*
	name:		editExpenses
	function:	1.�༭֧����ϸ
				ע�⣺���洢���������༭��
	input: 
				@expensesID	varchar(16) output,	--֧����ϢID��������ʹ��412�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),	--ժҪ
				@expensesSum	money,	--֧�����
				@contractAmount money,	--��ͬ���
				@receivedAmount money,	--�Ѹ����
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13) ,	--���ʽID
				@collectionMode		varchar(50),	--���ʽ
				@startDate	smalldatetime	,	--��������
				@paymentApplicantID	varchar(13),	--����������ID
				@paymentApplicant	varchar(10),	--����������

	output: 
				@lockManID varchar(10)output,		--������ID
				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1����֧����ϸ�����ڣ�2����֧����ϸ�ѱ������û�������3:����������֧����ϸ����༭��ͻ4����֧����ϸ��ȷ���޷��༭9��δ֪����

	author:		¬�γ�
	CreateDate:	2016-3-23

*/



create PROCEDURE editExpenses		
				@expensesID	varchar(16) ,	--֧����ϢID��������ʹ��412�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),	--ժҪ
				@expensesSum	money,	--֧�����
				@contractAmount money,	--��ͬ���
				@receivedAmount money,	--�Ѹ����
				@remarks	varchar(200),	--��ע
				@collectionModeID	varchar(13) ,	--���ʽID
				@collectionMode		varchar(50),	--���ʽ
				@startDate	smalldatetime	,	--��������
				@paymentApplicantID	varchar(13),	--����������ID
				@paymentApplicant	varchar(10),	--����������

				@lockManID varchar(13) output,		--������ID
				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1����֧����ϸ�����ڣ�2����֧����ϸ�ѱ������û�������3:����������֧����ϸ����༭��ͻ4����֧����ϸ��ȷ���޷��༭9��δ֪����

	WITH ENCRYPTION 
AS
	--�ж�Ҫ�༭��������ϸ�Ƿ����
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������״̬
	declare @thisperson varchar(13)
	set @thisperson = (select confirmationPersonID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--���༭����
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
	
			--ȡά���˵�������
			declare @createManName nvarchar(30)
			--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			set @createManName = '¬�γ�'
			declare @createTime smalldatetime
			set @createTime = getdate()

			update expensesList set
						projectID = @projectID,	--��ĿID
						project = @project,	--��Ŀ����
						customerID = @customerID,	--�ͻ�ID
						customerName = @customerName,	--�ͻ�����
						abstract	= @abstract,	--ժҪ
						expensesSum = @expensesSum,	--������
						contractAmount = @contractAmount,	--��ͬ���
						receivedAmount = @receivedAmount,	--���ս��
						remarks = @remarks,	--��ע
						collectionModeID = @collectionModeID,	--�տʽID
						collectionMode = @collectionMode,	--�տʽ
						startDate = @startDate,	--�տ�����
						paymentApplicantID = @paymentApplicantID,	--�տ�������ID
						paymentApplicant = @paymentApplicant,	--�տ���
						modiManID = @lockManID,	--ά����ID
						modiManName = @createManName,	--ά����
						modiTime = @createTime		--ά��ʱ��
						where	expensesID = @expensesID		--֧����ϸID������


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
			values(@lockManID, @createManName, @createTime, '�༭֧����ϸ', 'ϵͳ�����û�' + @createManName + 
				'��Ҫ��༭��֧����ϸ[' + @expensesID + ']��')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockExpensesEdit
/*
	name:		lockAccountDetailsEdit
	function: 	����֧����ϸ�༭������༭��ͻ
	input: 
				@expensesID varchar(16),		--֧����ϢID
				@lockManID varchar(13) output,	--�����ˣ������ǰ֧����ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ������֧����ϸ�����ڣ�2:Ҫ������֧����ϸ���ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockExpensesEdit
				@expensesID varchar(16),		--֧����ϢID
				@lockManID varchar(13) output,	--�����ˣ������ǰ֧����ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ������֧����ϸ�����ڣ�2:Ҫ������֧����ϸ���ڱ����˱༭��9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	


	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = '¬�γ�'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����֧����ϸ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������֧����ϸ['+ @expensesID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockExpensesEdit
/*
	name:		unlockExpensesEdit
	function: 	�ͷ�����֧����ϸ�༭������༭��ͻ
	input: 
				@expensesID varchar(16),		--֧����ϸID
				@lockManID varchar(13) output,			--�����ˣ������ǰ֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ�������֧����ϸ�����ڣ�2:Ҫ�ͷ�������֧����ϸ���ڱ����˱༭��8����֧����ϸδ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockExpensesEdit
				@expensesID varchar(16),			--֧����ϸID
				@lockManID varchar(13) output,	--������ID�������ǰ֧����ϸ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ�������֧����ϸ�����ڣ�2:Ҫ�ͷ�������֧����ϸ���ڱ����˱༭��8����֧����ϸδ���κ�������9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
			--�ͷű���������
			update expensesList set lockManID = '' where expensesID = @expensesID
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
				values(@lockManID, @lockManName, getdate(), '�ͷ�֧����ϸ�༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ���֧����ϸ['+ @expensesID +']�ı༭����')
		end
	else   --���ظ�֧����ϸδ���κ�������
		begin
			set @Ret = 8
			return
		end
GO