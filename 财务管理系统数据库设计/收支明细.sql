--����һ����
drop table incomeList
create table incomeList(
incomeInformationID varchar(16)	not null,--�����¼��
projectID	 varchar(13)	not null,		--��ĿID
project varchar(50)	not null,		--��Ŀ����
customerID varchar(13)	not null,		--ί�е�λID���ɿͻ�����ϵͳά��
customerName varchar(30)	not null,	--�ͻ�����
abstract	varchar(200)	not null,		--ժҪ
incomeSum	numeric(15,2) not null,		--������
remarks	varchar(200),					--��ע
collectionModeID varchar(10) not null,	--�տʽID
collectionMode varchar(50)	not null,	--�տ��˺�
startDate	 smalldatetime	not null,	--�տ�����
paymentApplicantID varchar(10)not null,	--�տ�������ID
payee varchar(30)	not null,			--�տ���
ActualArrivalTime smalldatetime  ,		--ʵ�ʵ���ʱ��
confirmationDate smalldatetime	,		--ȷ������
confirmationPersonID	varchar(10),		--ȷ����ID
confirmationPerson		varchar(30),		--ȷ����
confirmationStatus	smallint default(0) not null, --ȷ��״̬��0��δȷ�ϣ�1����ȷ��
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
	function: 	�ô洢���̲������༭
	input: 

				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),		--��Ŀ����
				@customerID	varchar(13),			--�ͻ�ID
				@customerName	varchar(30),		--�ͻ�����
				@abstract	varchar(200),			--ժҪ
				@incomeSum	numeric(15,2),			--������
				@remarks	varchar(200),			--��ע
				@collectionModeID	varchar(10),	--�տʽID
				@collectionMode		varchar(50),	--�տ��˺�
				@startDate	smalldatetime,			--�տ�����
				@paymentApplicantID	varchar(10),	--�տ�������ID
				@payee	varchar(30),				--�տ���
				@createManID varchar(10),	--������

				
	output: 
				@incomeInformationID varchar(16)	output,	--�����¼�ţ�������ʹ��411�ź��뷢��������
				@Ret int output				--�����ɹ���ʶ0:�ɹ���9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	
*/
create PROCEDURE addIncome
				@incomeInformationID varchar(16) output,		--�����¼�ţ�������ʹ��411�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),		--��Ŀ����
				@customerID	varchar(13),			--�ͻ�ID
				@customerName	varchar(30),		--�ͻ�����
				@abstract		varchar(200),			--ժҪ
				@incomeSum	numeric(15,2),			--������
				@remarks		varchar(200),			--��ע
				@collectionModeID	varchar(10),	--�տʽID
				@collectionMode	varchar(50),	--�տ��˺�
				@startDate		smalldatetime,			--�տ�����
				@paymentApplicantID	varchar(10),	--�տ�������ID
				@payee			varchar(30),				--�տ���
				@createManID		varchar(10),	--������
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
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()
	insert incomeList (
						incomeInformationID,	--������ϢID��������ʹ��411�ź��뷢��������
						projectID,	--��ĿID
						project,	--��Ŀ����
						customerID,	--�ͻ�ID
						customerName,	--�ͻ�����
						abstract	,	--ժҪ
						incomeSum,	--������
						remarks,	--��ע
						collectionModeID,	--�տʽID
						collectionMode,	--�տ��˻�
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
						@remarks,	--��ע
						@collectionModeID,	--�տʽID
						@collectionMode,	--�տ��˻�
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
				values(@createManID, @createManName, getdate(), '��������¼', 'ϵͳ�����û�' + @createManName	+ '��Ҫ������������¼['+ @incomeInformationID +']��')
GO

--ȷ��ָ�������¼
drop PROCEDURE confirmIncome
/*				ȷ��ָ�������¼
	name:		confirmIncome
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 
				@incomeInformationID varchar(16)	,	--������ϢID������
				@ActualArrivalTime   smalldatetime  ,	--ʵ�ʵ���ʱ��
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(10),	--ȷ����ID
				@confirmationPerson		varchar(30),	--ȷ����

				
	output: 
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ������¼�����ڣ�2:Ҫȷ�ϵ������¼���ڱ�����������3:�������¼δ��������������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	
*/
create PROCEDURE confirmIncome
				@incomeInformationID varchar(16)	,	--������ϢID������
				@ActualArrivalTime   smalldatetime  ,	--ʵ�ʵ���ʱ��
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(10),	--ȷ����ID
				@confirmationPerson	varchar(30),	--ȷ����
				@lockManID varchar(10) output,		--�����ˣ������ǰ�������¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output					--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ������¼�����ڣ�2:Ҫȷ�ϵ������¼���ڱ�����������3:�������¼δ��������������9��δ֪����
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
	declare @thisLockMan varchar(10)
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
			set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @modiTime = getdate()
			--���ȷ����Ϣ
			update incomeList set ActualArrivalTime = @ActualArrivalTime,	--ʵ�ʵ���ʱ��
								confirmationDate = @confirmationDate,	--ȷ������
								confirmationPersonID =  @confirmationPersonID	,	--ȷ����ID
								confirmationPerson = @confirmationPerson,	--ȷ����
								confirmationStatus	 = '1',			--ȷ��״̬
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
				values(@lockManID, @lockManName, getdate(), 'ȷ�������¼', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ��ȷ���������¼['+ @incomeInformationID +']��')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO

--ɾ�������¼
drop PROCEDURE delIncome
/*
	name:		delIncome
	function:		1.ɾ�������¼
				ע�⣺���洢���������༭��
	input: 
				@incomeInformationID	varchar(16) output,	--������ϢID������
				@lockManID varchar(10),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1���������¼�����ڣ�2���������¼�������û�������3�����������������¼��ɾ�������ͻ��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-5-6
*/

create PROCEDURE delIncome		
				@incomeInformationID	varchar(16),	--������ϢID������
				@lockManID   varchar(10) output,		--������ID

				@Ret		int output			--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1���������¼�����ڣ�2���������¼�������û�������3�����������������¼��ɾ�������ͻ��9��δ֪����

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
	declare @thisLockMan varchar(10)
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
				set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
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
				values(@lockManID, @lockMan, @createTime, 'ɾ�������¼', 'ϵͳ�����û�' + @lockMan + 
					'��Ҫ��ɾ���������¼[' + @incomeInformationID + ']��')		
		end
	else
	set @Ret = 3
	return
	
GO


--�༭�����¼
drop PROCEDURE editIncome	
/*
	name:		editIncome
	function:	1.�༭�����¼
				ע�⣺���洢���������༭��
	input: 
				@incomeInformationID varchar(16),		--�����¼�ţ�����
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),		--��Ŀ����
				@customerID	varchar(13),			--�ͻ�ID
				@customerName	varchar(30),		--�ͻ�����
				@abstract		varchar(200),			--ժҪ
				@incomeSum	numeric(15,2),			--������
				@remarks		varchar(200),			--��ע
				@collectionModeID	varchar(10),	--�տʽID
				@collectionMode	varchar(50),	--�տ��˺�
				@startDate		smalldatetime,			--�տ�����
				@paymentApplicantID	varchar(10),	--�տ�������ID
				@payee			varchar(30),				--�տ���

				

	output: 
				@lockManID varchar(10) output,		--������ID
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻���ϸ�ѱ������û�������9��δ֪����

	author:		¬�γ�
	CreateDate:	2016-3-23

*/



create PROCEDURE editIncome			
				@incomeInformationID varchar(16),		--�����¼�ţ�����
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),		--��Ŀ����
				@customerID	varchar(13),			--�ͻ�ID
				@customerName	varchar(30),		--�ͻ�����
				@abstract		varchar(200),			--ժҪ
				@incomeSum	numeric(15,2),			--������
				@remarks		varchar(200),			--��ע
				@collectionModeID	varchar(10),	--�տʽID
				@collectionMode	varchar(50),	--�տ��˺�
				@startDate		smalldatetime,			--�տ�����
				@paymentApplicantID	varchar(10),	--�տ�������ID
				@payee			varchar(30),				--�տ���

				@lockManID varchar(10) output,		--������ID
				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻���ϸ�����ڣ�2�����˻��ѱ������û�������3:���������������¼����༭��ͻ4���������¼��ȷ���޷��༭9��δ֪����

	WITH ENCRYPTION 
AS
	--�ж�Ҫ�༭�������¼�Ƿ����
	declare @count as int
	set @count=(select count(*) from incomeList where incomeInformationID= @incomeInformationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������״̬
	declare @thisperson varchar(10)
	set @thisperson = (select confirmationPersonID from incomeList
					where incomeInformationID = @incomeInformationID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--���༭����
	declare @thisLockMan varchar(10)
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
			set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			declare @createTime smalldatetime
			set @createTime = getdate()

			update incomeList set
						projectID = @projectID,	--��ĿID
						project = @project,	--��Ŀ����
						customerID = @customerID,	--�ͻ�ID
						customerName = @customerName,	--�ͻ�����
						abstract	= @abstract,	--ժҪ
						incomeSum = @incomeSum,	--������
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
			values(@lockManID, @createManName, @createTime, '�༭�����¼', 'ϵͳ�����û�' + @createManName + 
				'��Ҫ��༭�������¼[' + @incomeInformationID + ']��')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockIncomeEdit
/*
	name:		lockAccountDetailsEdit
	function: 	���������¼�༭������༭��ͻ
	input: 
				@incomeInformationID varchar(16),		--������ϢID
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�����������¼�����ڣ�2:Ҫ�����������¼���ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockIncomeEdit
				@incomeInformationID varchar(16),		--������ϢID
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ�����������¼�����ڣ�2:Ҫ�����������¼���ڱ����˱༭��9��δ֪����
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
	declare @thisLockMan varchar(10)
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
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '���������¼�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������������¼['+ @incomeInformationID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockIncomeEdit
/*
	name:		unlockIncomeEdit
	function: 	�ͷ����������¼�༭������༭��ͻ
	input: 
				@incomeInformationID varchar(16),		--�����¼ID
				@lockManID varchar(10) output,			--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ������������¼�����ڣ�2:Ҫ�ͷ������������¼���ڱ����˱༭��8���������¼δ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockIncomeEdit
				@incomeInformationID varchar(16),			--�����¼ID
				@lockManID varchar(10) output,	--������ID�������ǰ�����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ������������¼�����ڣ�2:Ҫ�ͷ������������¼���ڱ����˱༭��8���������¼δ���κ�������9��δ֪����
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
	declare @thisLockMan varchar(10)
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
				set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				--�Ǽǹ�����־��
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '�ͷ������¼�༭����', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ��������¼['+ @incomeInformationID +']�ı༭����')
		end
	else   --���ظ������¼δ���κ�������
		begin
			set @Ret = 8
			return
		end
GO



--֧��һ����
drop table	expensesList
create table expensesList(
expensesID	varchar(16)	not null,	--֧����¼ID
projectID		varchar(13)	not null,	--��ĿID
project		varchar(50)	not null,	--��Ŀ����
customerID	varchar(13)	not null,	--�ͻ�ID
customerName	varchar(30)	not null,	--�ͻ�����
abstract	varchar(200)	not null,	--ժҪ
expensesSum	numeric(15,2)	not null,	--֧�����
remarks	varchar(200),	--��ע
collectionModeID	varchar(10) not null,	--�����˻�ID
collectionMode		varchar(50)	not null,	--�����˻�
startDate	smalldatetime	not null,	--��������
paymentApplicantID	varchar(10)	not null,	--����������ID
paymentApplicant	varchar(30)	not null,	--����������
confirmationStatus	smallint default(0) not null, --ȷ��״̬��0��δȷ�ϣ�1����ȷ��
paymentDate		smalldatetime,	--֧������
confirmationDate	smalldatetime	,	--ȷ������
confirmationPersonID	varchar(10),	--ȷ����ID
confirmationPerson		varchar(30),	--ȷ����
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



--ȷ��֧����¼
drop PROCEDURE confirmexpenses
/*
	name:		confirmexpenses
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 
				@expensesID varchar(16),			--֧����¼ID������
				@collectionModeID	varchar(10),	--�����˻�ID
				@collectionMode	varchar(50),	--�����˻�
				@paymentDate		smalldatetime,	--֧������
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(10),	--ȷ����ID
				@confirmationPerson	varchar(30),	--ȷ����
				
	output: 
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ�֧����¼�����ڣ�2:Ҫȷ�ϵ�֧����¼���ڱ�����������3:��֧����¼δ��������������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	
*/
create PROCEDURE confirmexpenses
				@expensesID varchar(16),			--֧����¼ID������
				@collectionModeID	varchar(10),	--�����˻�ID
				@collectionMode	varchar(50),	--�����˻�
				@paymentDate		smalldatetime,	--֧������
				@confirmationDate	smalldatetime	,	--ȷ������
				@confirmationPersonID	varchar(10),	--ȷ����ID
				@confirmationPerson	varchar(30),	--ȷ����
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫȷ�ϵ�֧����¼�����ڣ�2:Ҫȷ�ϵ�֧����¼���ڱ�����������3:��֧����¼δ��������������9��δ֪����
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
	declare @thisLockMan varchar(10)
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
			set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
			set @modiTime = getdate()
			--���ȷ����Ϣ
			update expensesList set @collectionModeID	= @collectionModeID,	--�����˻�ID
								collectionMode =	@collectionMode,			--�����˻�
								paymentDate = @paymentDate,					--֧������
								confirmationStatus = '1',					--ȷ��״̬��0��δȷ�ϣ�1����ȷ��
								confirmationDate = @confirmationDate,		--ȷ������
								confirmationPersonID =  @confirmationPersonID	,--ȷ����ID
								confirmationPerson = @confirmationPerson,	--ȷ����
								modiManID = @lockManID,					--ά��ID	
								modiManName = @lockManName,					--ά��������	
								modiTime = @modiTime						--ά��ʱ��
								where expensesID = @expensesID
			set @Ret = 0

			if @@ERROR <>0
			begin
				set @Ret = 9
				return
			end

				--�Ǽǹ�����־��
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), 'ȷ��֧����¼', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ��ȷ����֧����¼['+ @expensesID +']��')
		end
	else
		begin
			set @Ret = 3
			return
		end 
GO


--���֧����¼
drop PROCEDURE addExpenses
/*
	name:		addExpenses
	function:	1.���֧����¼
				ע�⣺���洢���̲������༭��
	input: 
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),		--ժҪ
				@expensesSum	numeric(15,2),--֧�����
				@remarks	varchar(200),		--��ע
				@startDate	smalldatetime,	--��������
				@paymentApplicantID	varchar(10),	--����������ID
				@paymentApplicant		varchar(30),	--����������

				@createManID varchar(10),		--�����˹���
	output: 
				@expensesID	varchar(16) output,	--֧����¼ID��������ʹ��412�ź��뷢��������
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
				
	author:		¬�γ�
	CreateDate:	2016-3-23

*/

create PROCEDURE addExpenses			
				@expensesID	varchar(16) output,	--֧����¼ID��������ʹ��412�ź��뷢��������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),		--ժҪ
				@expensesSum	numeric(15,2),--֧�����
				@remarks	varchar(200),		--��ע
				@startDate	smalldatetime,	--��������
				@paymentApplicantID	varchar(10),	--����������ID
				@paymentApplicant		varchar(30),	--����������

				@createManID varchar(10),		--�����˹���

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
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()

	insert expensesList(
				expensesID,			--֧����¼ID��������ʹ��412�ź��뷢��������
				projectID,			--��ĿID
				project,				--��Ŀ����
				customerID,			--�ͻ�ID
				customerName,			--�ͻ�����
				abstract	,			--ժҪ
				expensesSum,			--֧�����
				remarks,				--��ע
				startDate,			--��������
				paymentApplicantID,	--����������ID
				paymentApplicant,		--����������
				confirmationStatus,	--ȷ��״̬��0��δȷ�ϣ�1����ȷ��
				createManID,			--�����˹���
				createManName,		--������
				createTime			--����ʱ��
							) 
	values (		
				@expensesID,		--֧����¼ID��������ʹ��412�ź��뷢��������
				@projectID,		--��ĿID
				@project,			--��Ŀ����
				@customerID,		--�ͻ�ID
				@customerName,	--�ͻ�����
				@abstract	,		--ժҪ
				@expensesSum,		--֧�����
				@remarks,			--��ע
				@startDate,		--��������
				@paymentApplicantID,	--����������ID
				@paymentApplicant,		--����������
				'0',					--ȷ��״̬��0��δȷ�ϣ�1����ȷ��
				@createManID,			--�����˹���
				@createManName,		--������
				@createTime			--����ʱ��				
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
	values(@createManID, @createManName, @createTime, '���֧����¼', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ�������֧����¼[' + @expensesID + ']��')		
GO

--ɾ��֧����¼
drop PROCEDURE delExpenses
/*
	name:		delExpenses
	function:		1.ɾ��֧����¼
				ע�⣺���洢���������༭��
	input: 
				@expensesID	varchar(16) output,		--֧����¼ID������
				@lockManID varchar(10),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1����֧����¼�����ڣ�2����֧����¼�������û�������3������������֧����¼��ɾ�������ͻ��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-5-6
*/

create PROCEDURE delExpenses	
				@expensesID	varchar(16),		--֧����¼ID������
				@lockManID   varchar(10) output,		--������ID

				@Ret		int output			--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1����֧����¼�����ڣ�2����֧����¼�������û�������3������������֧����¼��ɾ�������ͻ��9��δ֪����

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
	declare @thisLockMan varchar(10)
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
				set @lockMan = isnull((select userCName from activeUsers where userID = @lockManID),'')
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
				values(@lockManID, @lockMan, @createTime, 'ɾ��֧����¼', 'ϵͳ�����û�' + @lockMan + 
					'��Ҫ��ɾ����֧����¼[' + @expensesID + ']��')		
		end
	else
	set @Ret = 3
	return
	
GO


--�༭֧����¼
drop PROCEDURE editExpenses	
/*
	name:		editExpenses
	function:	1.�༭֧����¼
				ע�⣺���洢���������༭��
	input: 
				@expensesID	varchar(16),	--֧����¼ID������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),		--ժҪ
				@expensesSum	numeric(15,2),--֧�����
				@remarks	varchar(200),		--��ע
				@startDate	smalldatetime,	--��������
				@paymentApplicantID	varchar(10),	--����������ID
				@paymentApplicant		varchar(30),	--����������

	output: 
				@lockManID varchar(10)output,		--������ID
				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1����֧����¼�����ڣ�2����֧����¼�ѱ������û�������3:����������֧����¼����༭��ͻ4����֧����¼��ȷ���޷��༭9��δ֪����

	author:		¬�γ�
	CreateDate:	2016-3-23

*/



create PROCEDURE editExpenses		
				@expensesID	varchar(16),	--֧����¼ID������
				@projectID	varchar(13),	--��ĿID
				@project		varchar(50),	--��Ŀ����
				@customerID	varchar(13),	--�ͻ�ID
				@customerName	varchar(30),	--�ͻ�����
				@abstract	varchar(200),		--ժҪ
				@expensesSum	numeric(15,2),--֧�����
				@remarks	varchar(200),		--��ע
				@startDate	smalldatetime,	--��������
				@paymentApplicantID	varchar(10),	--����������ID
				@paymentApplicant		varchar(30),	--����������

				@lockManID varchar(10) output,		--������ID
				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1����֧����¼�����ڣ�2����֧����¼�ѱ������û�������3:����������֧����¼����༭��ͻ4����֧����¼��ȷ���޷��༭9��δ֪����

	WITH ENCRYPTION 
AS
	--�ж�Ҫ�༭�������¼�Ƿ����
	declare @count as int
	set @count=(select count(*) from expensesList where expensesID= @expensesID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������״̬
	declare @thisperson varchar(10)
	set @thisperson = (select confirmationPersonID from expensesList
					where expensesID = @expensesID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>'')
	begin
		set @Ret = 4 
		return
	end
	--���༭����
	declare @thisLockMan varchar(10)
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
			set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			declare @createTime smalldatetime
			set @createTime = getdate()

			update expensesList set
						projectID = @projectID,		--��ĿID
						project = @project,			--��Ŀ����
						customerID = @customerID,		--�ͻ�ID
						customerName = @customerName,	--�ͻ�����
						abstract	= @abstract,			--ժҪ
						expensesSum = @expensesSum,		--������
						remarks = @remarks,			--��ע
						startDate = @startDate,		--�տ�����
						paymentApplicantID = @paymentApplicantID,--�տ�������ID
						paymentApplicant = @paymentApplicant,	--�տ���
						modiManID = @lockManID,		--ά����ID
						modiManName = @createManName,	--ά����
						modiTime = @createTime			--ά��ʱ��
						where	expensesID = @expensesID		--֧����¼ID������


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
			values(@lockManID, @createManName, @createTime, '�༭֧����¼', 'ϵͳ�����û�' + @createManName + 
				'��Ҫ��༭��֧����¼[' + @expensesID + ']��')		
		end
	else
	set @Ret = 3
	return

	
GO

drop PROCEDURE lockExpensesEdit
/*
	name:		lockAccountDetailsEdit
	function: 	����֧����¼�༭������༭��ͻ
	input: 
				@expensesID varchar(16),		--֧����¼ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ֧����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ������֧����¼�����ڣ�2:Ҫ������֧����¼���ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockExpensesEdit
				@expensesID varchar(16),		--֧����¼ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ֧����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output				--�����ɹ���ʶ0:�ɹ���1��Ҫ������֧����¼�����ڣ�2:Ҫ������֧����¼���ڱ����˱༭��9��δ֪����
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
	declare @thisLockMan varchar(10)
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
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����֧����¼�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������֧����¼['+ @expensesID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockExpensesEdit
/*
	name:		unlockExpensesEdit
	function: 	�ͷ�����֧����¼�༭������༭��ͻ
	input: 
				@expensesID varchar(16),		--֧����¼ID
				@lockManID varchar(10) output,			--�����ˣ������ǰ֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ�������֧����¼�����ڣ�2:Ҫ�ͷ�������֧����¼���ڱ����˱༭��8����֧����¼δ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockExpensesEdit
				@expensesID varchar(16),			--֧����¼ID
				@lockManID varchar(10) output,	--������ID�������ǰ֧����¼���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ�������֧����¼�����ڣ�2:Ҫ�ͷ�������֧����¼���ڱ����˱༭��8����֧����¼δ���κ�������9��δ֪����
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
	declare @thisLockMan varchar(10)
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
				set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				--�Ǽǹ�����־��
				insert workNote (userID, userName, actionTime, actions, actionObject)
				values(@lockManID, @lockManName, getdate(), '�ͷ�֧����¼�༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ���֧����¼['+ @expensesID +']�ı༭����')
		end
	else   --���ظ�֧����¼δ���κ�������
		begin
			set @Ret = 8
			return
		end
GO