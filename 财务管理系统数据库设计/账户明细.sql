--�˻���ϸ��
drop table accountDetailsList 
create table accountDetailsList(
AccountDetailsID varchar(14) not null,	--����ID
accountID varchar(10) not null,			--�˻�ID
account varchar(50) not null,			--�˻�����
detailDate smalldatetime not null		,--����
abstract	varchar(200),		--ժҪ
borrow numeric(15,2),		--��
loan	 numeric(15,2),		--��
balance numeric(15,2),		--���
departmentID	varchar(13),	--����ID
department varchar(30),	--����
projectID	 varchar(13),		--��ĿID
project varchar(50),		--��Ŀ
clerkID varchar(10),		--������ID
clerk varchar(30),			--������
remarks varchar(200),		--��ע
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
				@accountID 	varchar(10)	not null,	--�˻�ID
				@account		varchar(50)	not	null,	--�˻�����
				@detailDate	smalldatetime	not null,	--����
				@abstract	varchar(200),	--ժҪ
				@borrow		numeric(15,2),		--��
				@loan		numeric(15,2),		--��
				@balance		numeric(15,2),		--���
				@departmentID	varchar(13),	--����ID
				@department		varchar(30),	--����
				@projectID		varchar(13),	--��ĿID
				@project			varchar(50),	--��Ŀ
				@clerkID		varchar(10),		--������ID
				@clerk		varchar(30),		--������
				@remarks		varchar(200),		--��ע

				@createManID varchar(10),		--�����˹���
	output: 
				@AccountDetailsID	varchar(14) output,	--����ID��������ʹ��408�ź��뷢��������
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻��Ѵ��ڣ�9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-3-23
*/

create PROCEDURE addAccountDetails			
				@AccountDetailsID	varchar(14) output,	--����ID��������ʹ��408�ź��뷢��������
				@accountID 	varchar(10),	--�˻�ID
				@account		varchar(50),--�˻�����
				@detailDate	smalldatetime,	--����
				@abstract	varchar(200),	--ժҪ
				@borrow		numeric(15,2),			--��
				@loan		numeric(15,2),			--��
				@balance	numeric(15,2),			--���
				@departmentID	varchar(13),--����ID
				@department	varchar(30),	--����
				@projectID	varchar(13),	--��ĿID
				@project	varchar(50),	--��Ŀ
				@clerkID	varchar(10),	--������ID
				@clerk		varchar(30),	--������
				@remarks	varchar(200),	--��ע

				@createManID varchar(10),		--�����˹���

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
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	insert accountDetailsList(
				AccountDetailsID,	--����ID��������ʹ��408�ź��뷢��������
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
				@AccountDetailsID,	--����ID��������ʹ��408�ź��뷢��������
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
				@AccountDetailsID	varchar(14) output,	--����ID��������ʹ��408�ź��뷢��������
				@lockManID varchar(10),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻���ϸ�������û�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE delAccountDetails		
				@AccountDetailsID	varchar(14),	--����ID������
				@lockManID   varchar(10) output,		--������ID

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
	declare @thisLockMan varchar(10)
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
	set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
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
				@AccountDetailsID	varchar(14) output,	--����ID��������ʹ��408�ź��뷢��������
				@accountID 	varchar(10),	--�˻�ID
				@account		varchar(50),--�˻�����
				@detailDate	smalldatetime,	--����
				@abstract	varchar(200),	--ժҪ
				@borrow		numeric(15,2),			--��
				@loan		numeric(15,2),			--��
				@balance	numeric(15,2),			--���
				@departmentID	varchar(13),--����ID
				@department	varchar(30),	--����
				@projectID	varchar(13),	--��ĿID
				@project	varchar(50),	--��Ŀ
				@clerkID	varchar(10),	--������ID
				@clerk		varchar(30),	--������
				@remarks	varchar(200),	--��ע

				@lockManID varchar(10)output,		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻���ϸ�ѱ������û�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-3-23

*/


select count(*) from accountDetailsList where AccountDetailsID= 'ZHMX201605050002'
create PROCEDURE editAccountDetails				
				@AccountDetailsID	varchar(14) ,	--����ID������
				@accountID 	varchar(10),	--�˻�ID
				@account		varchar(50),--�˻�����
				@detailDate	smalldatetime,	--����
				@abstract	varchar(200),	--ժҪ
				@borrow		numeric(15,2),			--��
				@loan		numeric(15,2),			--��
				@balance	numeric(15,2),			--���
				@departmentID	varchar(13),--����ID
				@department	varchar(30),	--����
				@projectID	varchar(13),	--��ĿID
				@project	varchar(50),	--��Ŀ
				@clerkID	varchar(10),	--������ID
				@clerk		varchar(30),	--������
				@remarks	varchar(200),	--��ע

				@lockManID varchar(10) output,		--������ID

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
	declare @thisLockMan varchar(10)
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
	set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	update accountDetailsList set
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName, @createTime, '�༭������ϸ', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ��༭�˽�����ϸ[' + @AccountDetailsID + ']��')		
GO


drop PROCEDURE lockAccountDetailsEdit
/*
	name:		lockAccountDetailsEdit
	function: 	�����˻���ϸ�༭������༭��ͻ
	input: 
				@AccountDetailsID varchar(14),		--�˻�ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�������˻���ϸ�����ڣ�2:Ҫ�������˻���ϸ���ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountDetailsEdit
				@AccountDetailsID varchar(14),		--�˻�ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
	declare @thisLockMan varchar(10)
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
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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
				@AccountDetailsID varchar(14),		--����ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ��������˻���ϸ�����ڣ�2:Ҫ�ͷ��������˻���ϸ���ڱ����˱༭��8�����˻���ϸδ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockAccountDetailsEdit
				@AccountDetailsID varchar(14),			--����ID
				@lockManID varchar(10) output,	--������ID�������ǰ�˻����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
	declare @thisLockMan varchar(10)
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
				set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
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