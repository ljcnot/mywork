--�˻���
drop table accountList
create table accountList(
accountID 	varchar(10) not null,	--�˻�ID
accountName	varchar(50)	not null,	--�˻�����
bankAccount	varchar(100) not null,	--������
accountCompany	varchar(100)	not null,	--������
accountOpening	varchar(50)	not	null,	--�����˺�
bankAccountNum	varchar(50)	not null,	--�����к�
accountDate	smalldatetime	not	null,	--����ʱ��
administratorID	varchar(10)	,	--������ID
administrator	varchar(30)	,		--������(������
branchAddress	varchar(100),			--֧�е�ַ
remarks	varchar(200),	--��ע
Obsolete		smallint  default(0) not null,	--�Ƿ�����,0:���ã�1������
ObsoleteDate smalldatetime,		--��������
enabledeate	smalldatetime,	--��������

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
--����
	 CONSTRAINT [PK_accountList] PRIMARY KEY CLUSTERED 
(
	accountID ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--�˻��ƽ���
drop table accountTransferList
create table accountTransferList(
accountTransferID varchar(15)	not null,	--�˻��ƽ�ID
handoverDate	smalldatetime	not null,	--�ƽ�����
transferAccountID	varchar(10)	not	null,	--�ƽ��˻�ID
transferAccount		varchar(50)	not null,	--�ƽ��˻�
transferPersonID	varchar(10)	not null,	--�ƽ���ID
transferPerson	varchar(30)	not null,	--�ƽ���
handoverPersonID	varchar(10)	not	null,	--������ID
handoverPerson	varchar(30)	not	null,	--������
transferMatters	varchar(200),				--�ƽ�����
remarks		varchar(200),	--��ע
TransferConfirmation smallint default(0) not null,	--�ƽ�ȷ�ϣ�0��δȷ�ϣ�1��ȷ��

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
foreign key(transferAccountID) references accountList(accountID) on update cascade on delete cascade,
--����
	 CONSTRAINT [PK_accountTransferID] PRIMARY KEY CLUSTERED 
(
	[accountTransferID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--����˻�
drop PROCEDURE addAccountList
/*
	name:		addAccountList
	function:	1.����˻�
				ע�⣺���洢���̲������༭��
	input: 
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(10),	--������ID
				@administrator	varchar(30),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע
				@Obsolete		smallint ,		--�Ƿ�����,0:���ã�1������
				@enabledeate	smalldatetime,	--��������

				@createManID varchar(10),		--�����˹���
	output: 
				@accountID 	varchar(10) output,		--�˻�ID,����,ʹ��409�ź��뷢��������
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1�����˻��Ѵ��ڣ�9��δ֪����
				
	author:		¬�γ�
	CreateDate:	2016-3-23

*/

create PROCEDURE addAccountList			
				@accountID 	varchar(10) output,		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(10),	--������ID
				@administrator	varchar(30),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע
				@Obsolete		smallint ,		--�Ƿ�����,0:���ã�1������
				@enabledeate	smalldatetime,	--��������

				@createManID varchar(10),		--�����˹���

				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻��Ѵ��ڣ�9��δ֪����

	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 409, 1, @curNumber output
	set @accountID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	insert accountList(
				accountID,		--�˻�ID,����,ʹ��409�ź��뷢��������
				accountName,		--�˻�����
				bankAccount,		--������
				accountCompany,	--������
				accountOpening,	--�����˺�
				bankAccountNum,	--�����к�
				accountDate,		--����ʱ��
				administratorID,	--������ID
				administrator,	--������(������
				branchAddress,	--֧�е�ַ
				remarks,			--��ע
				createManID,		--�����˹���
				createManName,	--����������
				createTime,		--����ʱ��
				Obsolete,			--�Ƿ�����
				enabledeate		--��������
							) 
	values (		
				@accountID,		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName,		--�˻�����
				@bankAccount,		--������
				@accountCompany,	--������
				@accountOpening,	--�����˺�
				@bankAccountNum,	--�����к�
				@accountDate,		--����ʱ��
				@administratorID,	--������ID
				@administrator,	--������(������
				@branchAddress,	--֧�е�ַ
				@remarks,			--��ע
				@createManID,		--�����˹���
				@createManName,	--����������
				@createTime,		--����ʱ��
				@Obsolete,		--�Ƿ�����
				@enabledeate		--��������
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '����˻�', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ��������˻�[' + @accountID + ']��')		
GO


--ɾ���˻�
drop PROCEDURE delAccountList
/*
	name:		delAccountList
	function:		1.ɾ���˻�
				ע�⣺���洢���������༭��
	input: 
				@accountID 	varchar(10) output,		--�˻�ID,����,ʹ��409�ź��뷢��������
				@lockManID varchar(10),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻������ڣ�2�����˻��������û�������3:�����������˻���ɾ�������ͻ��9��δ֪����

	author:		¬�γ�
	CreateDate:	2016-5-13
*/

create PROCEDURE delAccountList			
				@accountID 	varchar(10) ,		--�˻�ID,����
				@lockManID   varchar(10) output,		--������ID

				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻������ڣ�2�����˻��������û�������3:�����������˻���ɾ�������ͻ��9��δ֪����

	WITH ENCRYPTION 
AS
	
	set @Ret = 9
	
	--�ж�Ҫɾ�����˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
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
		else
			begin
				--ȡά���˵�������
				declare @lockMan nvarchar(30)
				set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
				declare @createTime smalldatetime
				set @createTime = getdate()

				delete from accountList where accountID = @accountID

				if @@ERROR <> 0 
					begin
						set @Ret = 9
						return
					end
				set @Ret = 0
				--�Ǽǹ�����־��
				insert workNote(userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockMan, @createTime, 'ɾ���˻�', 'ϵͳ�����û�' + @lockMan + 
					'��Ҫ��ɾ�����˻�[' + @accountID + ']��')	
			end
	end
	else
		begin
			set @Ret = 3
			return
		end
GO




--�༭�˻�
drop PROCEDURE editAccountList
/*
	name:		editAccountList
	function:	1.�༭�˻�
				ע�⣺���洢���������༭��
	input: 
				@accountID 	varchar(10),		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(10),	--������ID
				@administrator	varchar(30),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע

	output: 
				@lockManID varchar(10)output,		--������ID
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻������ڣ�2�����˻��ѱ������û�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-3-23
	
*/

create PROCEDURE editAccountList			
				@accountID 	varchar(10),		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(10),	--������ID
				@administrator	varchar(30),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע

				@lockManID varchar(10) output,		--������ID
				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻������ڣ�2�����˻��ѱ������û�������9��δ֪����

	WITH ENCRYPTION 
AS
	--�ж�Ҫ�༭���˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()

	update accountList set
				accountName = @accountName,			--�˻�����
				bankAccount = @bankAccount,			--������
				accountCompany = @accountCompany,	--������
				accountOpening = @accountOpening,	--�����˺�
				bankAccountNum = @bankAccountNum,	--�����к�
				accountDate    = @accountDate,		--����ʱ��
				administratorID = @administratorID,	--������ID
				administrator  = @administrator,		--������(������
				branchAddress  = @branchAddress,		--֧�е�ַ
				remarks =	@remarks,				--��ע
				modiManID = @lockManID,			--�޸��˹���
				modiManName = @createManName,		--�޸�������
				modiTime	= @createTime				--�޸�ʱ��
				where	accountID = @accountID		--�˻�ID,����,ʹ��409�ź��뷢��������


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


drop PROCEDURE lockAccountEdit
/*
	name:		lockAccountEdit
	function: 	�����˻��༭������༭��ͻ
	input: 
				@accountID varchar(10),		--�˻�ID

	output: 
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�������˻������ڣ�2:Ҫ�������˻����ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountEdit
				@accountID varchar(10),		--�˻�ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ�������˻������ڣ�2:Ҫ�������˻����ڱ����˱༭��9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
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
	


	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����˻��༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������˻�['+ @accountID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockAccountEdit
/*
	name:		unlockAccountEdit
	function: 	�ͷ������˻��༭������༭��ͻ
	input: 
				@accountID varchar(10),			--�˻�ID
				
	output: 
				@lockManID varchar(10) output,	--������ID�������ǰ�˻����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ��������˻������ڣ�2:Ҫ�ͷ��������˻����ڱ����˱༭��8�����˻�δ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	
*/
create PROCEDURE unlockAccountEdit
				@accountID varchar(10),			--�˻�ID
				@lockManID varchar(10) output,	--������ID�������ǰ�˻����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ��������˻������ڣ�2:Ҫ�ͷ��������˻����ڱ����˱༭��8�����˻�δ���κ�������9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @accountID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountList where accountID= @accountID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--�ͷű���������
			update accountList set lockManID = '' where accountID = @accountID
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
				values(@lockManID, @lockManName, getdate(), '�ͷ��˻��༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ����˻�['+ @accountID +']�ı༭����')
		end
	else   --���ظý�֧��δ���κ�������
		begin
			set @Ret = 8
			return
		end
GO



drop PROCEDURE accountTransfer
/*
	name:		accountTransfer
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 

				@handoverDate	smalldatetime,	--�ƽ�����
				@transferAccountID	varchar(10),	--�ƽ��˻�ID
				@transferAccount	varchar(50),	--�ƽ��˻�
				@transferPersonID	varchar(10),	--�ƽ���ID
				@transferPerson	varchar(30),	--�ƽ���
				@handoverPersonID	varchar(10),	--������ID
				@handoverPerson	varchar(30),	--������
				@transferMatters	varchar(200),	--�ƽ�����
				@remarks		varchar(200),	--��ע
				@TransferConfirmation smallint ,	--�ƽ�ȷ�ϣ�0��δȷ�ϣ�1��ȷ��
				
	output: 
				@accountTransferID varchar(15) output,	--�˻��ƽ�ID,������ʹ��410�ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ�ƽ��ĵ��˻������ڣ�2:Ҫ�ƽ��ĵ��˻����ڱ�����������3:���˻�δ���������������˻�9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16

*/
create PROCEDURE accountTransfer
				@accountTransferID varchar(15) output,	--�˻��ƽ�ID,������ʹ��410�ź��뷢��������
				@handoverDate	smalldatetime,	--�ƽ�����
				@transferAccountID	varchar(10),	--�ƽ��˻�ID
				@transferAccount	varchar(50),	--�ƽ��˻�
				@transferPersonID	varchar(10),	--�ƽ���ID
				@transferPerson	varchar(30),	--�ƽ���
				@handoverPersonID	varchar(10),	--������ID
				@handoverPerson	varchar(30),	--������
				@transferMatters	varchar(200),	--�ƽ�����
				@remarks		varchar(200),	--��ע
				@TransferConfirmation smallint ,	--�ƽ�ȷ�ϣ�0��δȷ�ϣ�1��ȷ��

				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ�ƽ��ĵ��˻������ڣ�2:Ҫ�ƽ��ĵ��˻����ڱ�����������3:���˻�δ���������������˻�9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��Ƿ����
	declare @count as int
	set @count=(select count(*) from accountList where accountID= @transferAccountID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
				--ʹ�ú��뷢���������µĺ��룺
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 410, 1, @curNumber output
			set @accountTransferID = @curNumber
			insert accountTransferList (
									accountTransferID,	--�˻��ƽ�ID,������ʹ��410�ź��뷢��������
									handoverDate	,	--�ƽ�����
									transferAccountID,	--�ƽ��˻�ID
									transferAccount,	--�ƽ��˻�
									transferPersonID,	--�ƽ���ID
									transferPerson,	--�ƽ���
									handoverPersonID,	--������ID
									handoverPerson,	--������
									transferMatters,	--�ƽ�����
									remarks,			--��ע
									TransferConfirmation	--�ƽ�ȷ�ϣ�0��δȷ�ϣ�1��ȷ��
									)
						values     (
									@accountTransferID,	--�˻��ƽ�ID,������ʹ��410�ź��뷢��������
									@handoverDate	,	--�ƽ�����
									@transferAccountID,--�ƽ��˻�ID
									@transferAccount,	--�ƽ��˻�
									@transferPersonID,	--�ƽ���ID
									@transferPerson,	--�ƽ���
									@handoverPersonID,	--������ID
									@handoverPerson,	--������
									@transferMatters,	--�ƽ�����
									@remarks,			--��ע
									@TransferConfirmation
									)
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
				values(@lockManID, @lockManName, getdate(), '�ƽ��˻�', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ƽ����˻����ƽ�����Ϊ['+ @accountTransferID +']��')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO


--�˻��ƽ�ȷ��
drop PROCEDURE TransferAccountConfirmation
/*
	name:		TransferAccountConfirmation
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 
				@accountTransferID		--�˻��ƽ�ID

				
	output: 
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1���ô��˻��ƽ������ڣ�2:ȷ���˲��ǽ�����9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16

*/
create PROCEDURE TransferAccountConfirmation
				@accountTransferID varchar(15) ,	--�˻��ƽ�ID,������ʹ��410�ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1���ô��˻��ƽ������ڣ�2:ȷ���˲��ǽ�����9��δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������˻��ƽ��Ƿ����
	declare @count as int
	set @count=(select count(*) from accountTransferList where accountTransferID= @accountTransferID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	declare 		@transferAccountID	varchar(10),	--�ƽ��˻�ID
				@handoverPersonID	varchar(10),	--������ID
				@handoverPerson	varchar(30)	--������

	select @transferAccountID = transferAccountID,@handoverPersonID = handoverPersonID,@handoverPerson = handoverPerson 
							from accountTransferList
							where accountTransferID = @accountTransferID
	--���ȷ�����Ƿ����ƽ���
	if(@lockManID <> @handoverPersonID)
		begin
			set @Ret = 2
			return
		end
begin tran
	update accountList set administratorID = @handoverPersonID,
						administrator = @handoverPerson
						where accountID = @transferAccountID
	update accountTransferList set TransferConfirmation = '0' where accountTransferID = @accountTransferID
	set @Ret = 0

	if @@ERROR <>0
	begin
		rollback tran
		set @Ret = 9
		return
	end
commit tran
		----ȡά���˵�������
		declare @lockManName nvarchar(30)
		set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
		--�Ǽǹ�����־��
		insert workNote (userID, userName, actionTime, actions, actionObject)
		values(@lockManID, @lockManName, getdate(), 'ȷ�Ͻ����˻�', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ��ȷ�Ͻ������˻�['+ @transferAccountID +']��')

	
GO