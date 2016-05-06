drop table borrowSingle      --��֧����
create table borrowSingle(
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
	approvalOpinion	varchar(200),	--�������
	IssueSituation	smallint default(0),	--�������
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
 CONSTRAINT [PK_borrowSingle] PRIMARY KEY CLUSTERED 
(
	[borrowSingleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

----�����
--ALTER TABLE [dbo].[eqpApplyDetail] WITH CHECK ADD CONSTRAINT [FK_eqpApplyDetail_eqpApplyInfo] FOREIGN KEY([eqpApplyID])
--REFERENCES [dbo].[eqpApplyInfo] ([eqpApplyID])
--ON UPDATE CASCADE
--ON DELETE CASCADE
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
	function:	1.��ӽ�֧��
				ע�⣺���洢���̲������༭��
	input: 
			@borrowSingleID varchar(15) ,  --��֧����,���� ��401�ź��뷢��������
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
			@borrowSum	Decimal(12),	--��֧���
			@flowProgress smallint,		--��ת����
			@createManID varchar(10),		--�����˹���

	@Ret		int output,
	@borrowSingleID varchar(15) output	--��������֧���ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 401, 1, @curNumber output
	set @borrowSingleID = @curNumber

	
	----ȡά���˵�������
	--declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @createTime smalldatetime, @createManName varchar(30)
	set @createManName = '¬�γ�'
	set @createTime = getdate()
	insert borrowSingle(borrowSingleID,		--��֧��ID
							borrowManID,	--��֧��ID
							borrowMan,		--��֧������
							position,		--ְ��
							departmentID,	--����ID
							department,		--��������
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID,@createManName, @createTime, '��ӽ�֧��', 'ϵͳ�����û�'+@createManName+'��Ҫ������˽�֧��[' + @borrowSingleID + ']��')
GO




drop table workNote      --������־��
create table workNote(
	workNoteID int primary key identity(1,1),	--������־ID
	userID	varchar(17)	not null,	--�û�ID
	userName	varchar(17)	not	null,	--�û�����
	actionTime	varchar(200),	--�޸�ʱ��
	actions varchar(50),	--����˵��
	actionObject	varchar(100),	--��ϸ˵��
	)
GO



drop PROCEDURE editborrowSingle
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
create PROCEDURE editborrowSingle				
			@borrowSingleID varchar(15), 	--��������֧���ţ�ʹ�õ� 3 �ź��뷢��������
			@borrowManID varchar(13)	,	--��֧��ID
			@borrowMan varchar(20)	,		--��֧�ˣ�������
			@position	varchar(10)	,	--ְ��
			@departmentID	varchar(13)	,	--����ID
			@department	varchar(16)	,	--����
			@borrowDate	smalldatetime	,	--��֧ʱ��
			@projectID	varchar(14),	--������ĿID
			@projectName	varchar(200),	--������Ŀ�����ƣ�
			@borrowReason	varchar(200),	--��֧����
			@borrowSum	Decimal(12),	--��֧���
			@flowProgress smallint,		--��ת����

			@modiManID varchar(10),		--ά���˹���

		@Ret		int output		--������ʾ��0���ɹ���1���õ��ݱ������˱༭ռ�ã�2���õ���Ϊ���״̬������༭

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

	
	--ȡά���˵�������
	--declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @modiTime smalldatetime,@modiManName varchar(30)
	set @modiManName = '¬�γ�'
	set @modiTime = getdate()
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
							modiManID = @modiManID,	--ά���˹���
							modiManName	= @modiManName,	--ά��������
							modiTime	= @modiTime	--�޸�ʱ��
							where borrowSingleID = @borrowSingleID--��֧��ID
	set @Ret = 0
	--if @@ERROR <> 0 
	----������ϸ��
	--declare @runRet int 
	--exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�༭��֧����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��˽�֧��[' + @borrowSingleID + ']��')
GO




drop PROCEDURE lockborrowSingleEdit
/*
	name:		borrowSingle
	function:	������֧���༭������༭��ͻ
	input: 
				@@borrowSingleID varchar(15),			--��֧��ID
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
create PROCEDURE lockborrowSingleEdit
				@borrowSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	


	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = '¬�γ�'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������֧���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˽�֧��['+ @borrowSingleID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockborrowSingleEdit
/*
	name:		borrowSingle
	function:	�ͷ�������֧���༭������༭��ͻ
	input: 
				@@borrowSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
												0:�ɹ���1���ý�֧�������ڣ�2�������õ��ݵ��˲����Լ���8:�õ���δ������,9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockborrowSingleEdit
				@borrowSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
			--�ͷŽ�֧������
			update borrowSingle set lockManID = '' where borrowSingleID = @borrowSingleID
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
				values(@lockManID, @lockManName, getdate(), '�ͷŽ�֧���༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ��˽�֧��['+ @borrowSingleID +']�ı༭����')
		end
	else   --���ظý�֧��δ���κ�������
		begin
			set @Ret = 8
			return
		end

GO



drop PROCEDURE delborrowSingle
/*
	name:		delborrowSingle
	function:	ɾ��ָ����֧��
	input: 
				@borrowSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��ָ���Ľ�֧�������ڣ�
							2:Ҫɾ���Ľ�֧����������������
							3:�õ����Ѿ�����������ɾ����
							9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE delborrowSingle
				@borrowSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫɾ���Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
	if (@count = 0)	--������
		begin
			set @Ret = 1
			return
		end

	--��ѯ��֧���Ƿ�Ϊ���״̬
	declare @thisflowProgress smallint
	set @thisflowProgress = (select flowProgress from borrowSingle where borrowSingleID = @borrowSingleID)
	if (@thisflowProgress<>0)
		begin
			set @Ret = 3
			return
		end

	--���༭����
	declare @thisLockMan varchar(14)
	set @thisLockMan = (select lockManID from borrowSingle
					where borrowSingleID = @borrowSingleID)
					
	if (@thisLockMan<>'')
		begin
			set @lockManID = @thisLockMan
			set @Ret = 2
			return
		end
	--ɾ��ָ����֧��
	delete borrowSingle
	where borrowSingleID= @borrowSingleID
	--�ж����޴���
	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
	
	set @Ret = 0


	----ȡά���˵�������
	declare @lockManName nvarchar(30)
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @lockManName = '¬�γ�'
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), 'ɾ����֧��', 'ϵͳ�����û�' + @lockManName
												+ 'ɾ���˽�֧��['+ @borrowSingleID +']��')
GO

drop PROCEDURE examineborrowSingle
/*
	name:		borrowSingle
	function:	��˽�֧��
	input: 
				@borrowSingleID varchar(15),			--��֧��ID
				@ApprovalDetailsID varchar(16)	ouput,	--��������ID��ʹ�ú��뷢��������
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
create PROCEDURE lockborrowSingleEdit
				@borrowSingleID varchar(15),			--��֧��ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @borrowSingleID)	
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

	update borrowSingle
	set lockManID = @lockManID 
	where borrowSingleID= @borrowSingleID
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
												+ '��Ҫ�������˽�֧��['+ @borrowSingleID +']Ϊ��ռʽ�༭��')
GO


-- ������
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
	originalloan money ,	--ԭ���
	replenishment money ,	--Ӧ����
	shouldRefund money ,	--Ӧ�˿�
	ExpRemPersonID varchar(14) not null,	--�����˱��
	ExpRemPerson varchar(10)	not	null,	--����������
	businessPeopleID	varchar(14)  ,	--�����˱��
	businessPeople	varchar(10),	--������
	businessReason varchar(200),	--��������
	approvalProgress smallint default(0) not null,	--��������
	IssueSituation smallint default(0) ,	--�������
	paymentMethodID varchar(13)	,	--�����˻�ID
	paymentMethod varchar(50),		--�����˻�
	paymentSum money,	--������
	draweeID varchar(13),	--������ID
	drawee	varchar(10),	--������
	
	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(13) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(13) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(13)				--��ǰ���������༭���˹���
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
expSum	money	not null,	--���
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
				@amount money not null,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan money not null,	--ԭ���
				@replenishment money not null,	--Ӧ����
				@shouldRefund money not null,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) not null,	--�����˱��
				@ExpRemPerson varchar(10)	not	null,	--����������
				@businessPeopleID	varchar(14) not null,	--�����˱��
				@businessPeople	varchar(10) not null,	--������
				@businessReason varchar(200)	not null,	--��������
				@approvalProgress smallint default(0) not null,	--��������

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
				@amount money ,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan money ,	--ԭ���
				@replenishment money ,	--Ӧ����
				@shouldRefund money ,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) ,	--�����˱��
				@ExpRemPerson varchar(10),	--����������
				@businessPeopleID	varchar ,	--�����˱��
				@businessPeople	varchar(10) ,	--������
				@businessReason varchar(200)	,	--��������
				@approvalProgress smallint ,	--��������:0���½���1����������2��������,3:�����

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
							approvalProgress	--��������:0���½���1����������2��������,3:�����
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
				@expSum	money,	--���

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
				vehicleSum	money not null,	--��ͨ�ѽ��
				financialAccountID	varchar(13)	not null,	--��ĿID
				financialAccount	varchar(20) not null,	--��Ŀ����
				peopleNum	int not null,	--����
				travelDays float ,	-- ��������
				TravelAllowanceStandard	money,	--�������׼
				travelAllowancesum	money	not null,	--�������
				otherExpenses	varchar(20) null,	--��������
				otherExpensesSum	money	null,	--�������ý��

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
				@vehicleSum	money,	--��ͨ�ѽ��
				@financialAccountID	varchar(13),	--��ĿID
				@financialAccount	varchar(20),	--��Ŀ����
				@peopleNum	int,	--����
				@travelDays float,	-- ��������
				@TravelAllowanceStandard money,	--�������׼
				@travelAllowancesum	money,	--�������
				@otherExpenses	varchar(20),	--��������
				@otherExpensesSum	money,	--�������ý��

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
	set @thisProgress = (select approvalProgress from ExpRemSingle
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
				@amount money ,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan money ,	--ԭ���
				@replenishment money ,	--Ӧ����
				@shouldRefund money ,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) ,	--�����˱��
				@ExpRemPerson varchar(10),	--����������
				@businessPeopleID	varchar ,	--�����˱��
				@businessPeople	varchar(10) ,	--������
				@businessReason varchar(200)	,	--��������
				@approvalProgress smallint ,	--��������:0���½���1����������2��������,3:�����

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
				@amount money ,	--�ϼƽ��
				@borrowSingleID varchar(15) ,	--ԭ��֧��ID
				@originalloan money ,	--ԭ���
				@replenishment money ,	--Ӧ����
				@shouldRefund money ,	--Ӧ�˿�
				@ExpRemPersonID varchar(14) ,	--�����˱��
				@ExpRemPerson varchar(10),	--����������
				@businessPeopleID	varchar ,	--�����˱��
				@businessPeople	varchar(10) ,	--������
				@businessReason varchar(200)	,	--��������
				@approvalProgress smallint ,	--��������:0���½���1����������2��������,3:�����

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
	set @thisflowProgress = (select approvalProgress from ExpRemSingle where ExpRemSingleID = @ExpRemSingleID)
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
				approvalProgress = @approvalProgress	--��������:0���½���1����������2��������,3:�����
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




--������
drop table enclosure 
create table enclosure(
enclosureID	varchar(15)	not	null,	--�������
billType	 smallint default(0)	not	null,	--Ʊ�����ͣ�0����֧����1��������
billID	varchar(15)	not	null,	--Ʊ�ݱ��
enclosureAddress	varchar(200)	not	null,	--������ַ
enclosureType	 smallint default(0)	not	null,	--��������
--����
	 CONSTRAINT [PK_enclosure] PRIMARY KEY CLUSTERED 
(
	enclosureID ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--��Ӹ���
drop PROCEDURE addEnclosure
/*
	name:		addEnclosure
	function:	1.��Ӹ���
				ע�⣺���洢���̲������༭��
	input: 
				enclosureID	varchar(15)	not	null,	--����������ID��ʹ�õ�406�ź��뷢��������
				billType	 smallint default(0)	not	null,	--Ʊ�����ͣ�0����֧����1��������
				billID	varchar(15)	not	null,	--Ʊ�ݱ��
				enclosureAddress	varchar(200)	not	null,	--������ַ
				enclosureType	 smallint default(0)	not	null,	--��������

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE addEnclosure			
				@enclosureID varchar(15) output,	--����������ID��ʹ�õ�406�ź��뷢��������
				@billType	 smallint,	--Ʊ�����ͣ�0����֧����1��������
				@billID	varchar(15),	--Ʊ�ݱ��
				@enclosureAddress	varchar(200),	--������ַ
				@enclosureType	 smallint,	--��������

				@createManID varchar(13),		--�����˹���

				@Ret		int output,
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 406, 1, @curNumber output
	set @enclosureID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	insert enclosure(
				enclosureID,		--����������ID��ʹ�õ�406�ź��뷢��������
				billType,			--Ʊ�����ͣ�0����֧����1��������
				billID,				--Ʊ�ݱ��
				enclosureAddress,	--������ַ
				enclosureType		--��������
							) 
	values (		
				@enclosureID,		--����������ID��ʹ�õ�406�ź��뷢��������
				@billType,			--Ʊ�����ͣ�0����֧����1��������
				@billID,			--Ʊ�ݱ��
				@enclosureAddress,	--������ַ
				@enclosureType		--��������
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
	values(@createManID, @createManName, @createTime, '��Ӹ���', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ������˸���[' + @enclosureID + ']��')		
GO


--ɾ������
drop PROCEDURE delEnclosure
/*
	name:		delEnclosure
	function:	1.ɾ������
				ע�⣺���洢���̲������༭��
	input: 
				enclosureID	varchar(15)	not	null,	--����������ID
				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		  --�ɹ���ʾ��0���ɹ���1���ø���������,9:δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE delEnclosure			
				@enclosureID varchar(15),	--����������ID
				@createManID varchar(13),		--�����˹���

				@Ret		int output,			--�ɹ���ʾ��0���ɹ���1���ø���������,9:δ֪����
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()
		
	--�ж�Ҫɾ���ĸ����Ƿ����
	declare @count as int
	set @count=(select count(*) from enclosure where enclosureID= @enclosureID)	
	if (@count = 0)	--������
		begin
			set @Ret = 1
			return
		end
	--ɾ������
	delete FROM enclosure where enclosureID= @enclosureID 


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
	values(@createManID, @createManName, @createTime, 'ɾ������', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ��ɾ���˸���[' + @enclosureID + ']��')		
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



--��ӿ�Ŀ
drop PROCEDURE addSubject
/*
	name:		addSubject
	function:	1.��ӿ�Ŀ
				ע�⣺���洢���̲������༭��
	input: 
				FinancialSubjectID	varchar(13)	not	null,	--��ĿID
				classification	smallint default(0) not null,	--����
				superiorSubjectsID	varchar(13)	,	--�ϼ���ĿID
				superiorSubjects varchar(50)	,	--�ϼ���Ŀ����
				subjectName	varchar(50)	not null,	--��Ŀ����
				AccountNumber int not null,	--��Ŀ����
				establishTime smalldatetime	not null,	--����ʱ��
				explain varchar(200)	null,	--˵��

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE addSubject			
				@FinancialSubjectID	varchar(13) output,	--��ĿID,����,ʹ��407�ź��뷢��������
				@classification	smallint,			--����
				@superiorSubjectsID	varchar(13),	--�ϼ���ĿID
				@superiorSubjects varchar(50),		--�ϼ���Ŀ����
				@subjectName	varchar(50),		--��Ŀ����
				@AccountNumber int ,				--��Ŀ����
				@establishTime smalldatetime,		--����ʱ��
				@explain varchar(200),				--˵��

				@createManID varchar(13),		--�����˹���

				@Ret		int output,
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 407, 1, @curNumber output
	set @FinancialSubjectID = @curNumber

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	insert subjectList(
				FinancialSubjectID,	--��ĿID,����,ʹ��407�ź��뷢��������
				classification,		--����
				superiorSubjectsID,	--�ϼ���ĿID
				superiorSubjects,		--�ϼ���Ŀ����
				subjectName,			--��Ŀ����
				AccountNumber,			--��Ŀ����
				establishTime,			--����ʱ��
				explain,				--˵��
				createManID,			--�����˹���
				createTime				--����ʱ��
							) 
	values (		
				@FinancialSubjectID,	--��ĿID,����,ʹ��407�ź��뷢��������
				@classification,		--����
				@superiorSubjectsID,	--�ϼ���ĿID
				@superiorSubjects,		--�ϼ���Ŀ����
				@subjectName,			--��Ŀ����
				@AccountNumber,			--��Ŀ����
				@establishTime,			--����ʱ��
				@explain,				--˵��
				@createManID,			--�����˹���
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
	values(@createManID, @createManName, @createTime, '��ӿ�Ŀ', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ������˿�Ŀ[' + @FinancialSubjectID + ']��')		
GO


--�༭��Ŀ
drop PROCEDURE editSubject
/*
	name:		editSubject
	function:	1.�༭��Ŀ
				ע�⣺���洢���������༭��
	input: 
				FinancialSubjectID	varchar(13)	not	null,	--��ĿID
				subjectName	varchar(50)	not null,			--��Ŀ����
				explain varchar(200)	null,	--˵��

				@lockManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ÿ�Ŀ�Ѿ���������
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE editSubject			
				@FinancialSubjectID	varchar(13),	--��ĿID
				@subjectName	varchar(50),		--��Ŀ����
				@explain varchar(200),				--˵��

				@lockManID varchar(13) output,				--�����˹���

				@Ret		int output,
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS
	--�ж�Ҫ�����Ŀ�Ŀ�Ƿ�����Ƿ����
	declare @count as int
	set @count=(select count(*) from subjectList where FinancialSubjectID = @FinancialSubjectID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 3
		return
	end

	--���༭�Ŀ�Ŀ�Ƿ��б༭������������
	declare @thislockMan varchar(13)
	set @thislockMan = (select lockManID from subjectList
					where FinancialSubjectID = @FinancialSubjectID)
						
	if (@thislockMan<>'')
		if(@thislockMan<>@lockManID)
		begin
			set @Ret = 1
			set @lockManID = @thislockMan
			return
		end
			

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	set @createTime = getdate()

	update subjectList set 
				subjectName = @subjectName,			--��Ŀ����
				explain = @explain				--˵��
				 where FinancialSubjectID = @FinancialSubjectID


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
	values(@lockManID, @createManName, @createTime, '�༭��Ŀ', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ��༭�˿�Ŀ[' + @FinancialSubjectID + ']��')		
GO


drop PROCEDURE lockSubjectEdit
/*
	name:		lockSubjectEdit
	function:	������Ŀ�༭������༭��ͻ
	input: 
				@FinancialSubjectID varchar(13),			--��ĿID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��Ҫ�����Ŀ�Ŀ�����ڣ�
							2:Ҫ�����Ŀ�Ŀ���ڱ����˱༭��
							9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockSubjectEdit
				@FinancialSubjectID varchar(13),			--��ĿID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ŀ�Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from subjectList where FinancialSubjectID= @FinancialSubjectID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(13)
	set @thisLockMan = (select lockManID from subjectList
					where FinancialSubjectID = @FinancialSubjectID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update subjectList
	set lockManID = @lockManID 
	where FinancialSubjectID= @FinancialSubjectID

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
	values(@lockManID, @lockManName, getdate(), '������Ŀ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˿�Ŀ['+ @FinancialSubjectID +']Ϊ��ռʽ�༭��')
GO


drop PROCEDURE unlockSubjectEdit
/*
	name:		unlockSubjectEdit
	function:	�ͷſ�Ŀ�༭����������༭��ͻ
	input: 
				@FinancialSubjectID varchar(13),			--��ĿID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��Ҫ�ͷ������Ŀ�Ŀ�����ڣ�
							2:Ҫ�ͷ������Ŀ�Ŀ���ڱ����˱༭��
							8���ÿ�Ŀδ���κ�������
							9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockSubjectEdit
				@FinancialSubjectID varchar(13),			--��ĿID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı������Ƿ����
	declare @count as int
	set @count=(select count(*) from subjectList where FinancialSubjectID= @FinancialSubjectID)	
	if (@count = 0)	    --������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(13)
	set @thisLockMan = isnull((select lockManID from subjectList where FinancialSubjectID= @FinancialSubjectID),'')
	if (@thisLockMan<>'')
		begin
			if (@thisLockMan <> @lockManID)
			begin
				set @lockManID = @thisLockMan
				set @Ret = 2
				return
			end
			--�ͷű���������
			update subjectList set lockManID = '' where FinancialSubjectID = @FinancialSubjectID
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
				values(@lockManID, @lockManName, getdate(), '�ͷſ�Ŀ�༭', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ͷ��˿�Ŀ['+ @FinancialSubjectID +']�ı༭����')
		end
	else   --���ظý�֧��δ���κ�������
		begin
			set @Ret = 8
			return
		end

GO


--�˻���
drop table accountList
create table accountList(
accountID 	varchar(13) not null,	--�˻�ID
accountName	varchar(50)	not null,	--�˻�����
bankAccount	varchar(100) not null,	--������
accountCompany	varchar(100)	not null,	--������
accountOpening	varchar(50)	not	null,	--�����˺�
bankAccountNum	varchar(50)	not null,	--�����к�
accountDate	smalldatetime	not	null,	--����ʱ��
administratorID	varchar(13)	,	--������ID
administrator	varchar(20)	,	--������(������
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
--����
	 CONSTRAINT [PK_accountList] PRIMARY KEY CLUSTERED 
(
	accountID ASC
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
				@accountID 	varchar(13) output,		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(13),	--������ID
				@administrator	varchar(20),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1�����˻��Ѵ��ڣ�9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE addAccountList			
				@accountID 	varchar(13) output,		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(13),	--������ID
				@administrator	varchar(20),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע

				@createManID varchar(13),		--�����˹���

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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
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
				createTime		--����ʱ��
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
				@accountID 	varchar(13) output,		--�˻�ID,����,ʹ��409�ź��뷢��������
				@lockManID varchar(13),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ;--�����ɹ���ʾ��0:�ɹ���1�����˻������ڣ�2�����˻��������û�������9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE delAccountList			
				@accountID 	varchar(13) ,		--�˻�ID,����
				@lockManID   varchar(13) output,		--������ID

				@Ret		int output			--�����ɹ���ʾ��0:�ɹ���1�����˻������ڣ�2�����˻��������û�������9��δ֪����

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

	--ȡά���˵�������
	declare @lockMan nvarchar(30)
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @lockMan = '¬�γ�'
	declare @createTime smalldatetime
	set @createTime = getdate()

	delete from accountList where accountID = @accountID

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
	values(@lockManID, @lockMan, @createTime, 'ɾ���˻�', 'ϵͳ�����û�' + @lockMan + 
		'��Ҫ��ɾ�����˻�[' + @accountID + ']��')		
GO




--�༭�˻�
drop PROCEDURE editAccountList
/*
	name:		editAccountList
	function:	1.�༭�˻�
				ע�⣺���洢���������༭��
	input: 
				@accountID 	varchar(13),		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(13),	--������ID
				@administrator	varchar(20),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע

				@lockManID varchar(10)output,		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʾ��0:�ɹ���1�����˻������ڣ�2�����˻��ѱ������û�������9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23
	UpdateDate: 2016-3-23 by lw ���ݱ༭Ҫ������rowNum���ز���
*/

create PROCEDURE editAccountList			
				@accountID 	varchar(13),		--�˻�ID,����,ʹ��409�ź��뷢��������
				@accountName	varchar(50),		--�˻�����
				@bankAccount	varchar(100),		--������
				@accountCompany	varchar(100),	--������
				@accountOpening	varchar(50),	--�����˺�
				@bankAccountNum	varchar(50),	--�����к�
				@accountDate	smalldatetime,	--����ʱ��
				@administratorID	varchar(13),	--������ID
				@administrator	varchar(20),	--������(������
				@branchAddress	varchar(100),	--֧�е�ַ
				@remarks varchar(200),			--��ע

				@lockManID varchar(13) output,		--������ID

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
	--set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createManName = '¬�γ�'
	declare @createTime smalldatetime
	set @createTime = getdate()

	update accountList set
				accountName = @accountName,			--�˻�����
				bankAccount = @bankAccount,			--������
				accountCompany = accountCompany,	--������
				accountOpening = accountOpening,	--�����˺�
				bankAccountNum = bankAccountNum,	--�����к�
				accountDate    = accountDate,		--����ʱ��
				administratorID = administratorID,	--������ID
				administrator  = administrator,		--������(������
				branchAddress  = branchAddress,		--֧�е�ַ
				remarks = remarks,				--��ע
				createManID = createManID,			--�����˹���
				createManName = createManName,		--����������
				createTime	= createTime			--����ʱ��
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
				@accountID varchar(13),		--�˻�ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�������˻������ڣ�2:Ҫ�������˻����ڱ����˱༭��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE lockAccountEdit
				@accountID varchar(13),		--�˻�ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
	declare @thisLockMan varchar(13)
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
	set @lockManName = '¬�γ�'
	--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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
				@accountID varchar(13),		--�˻�ID
				@lockManID varchar(13) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ��������˻������ڣ�2:Ҫ�ͷ��������˻����ڱ����˱༭��8�����˻�δ���κ�������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockAccountEdit
				@accountID varchar(13),			--�˻�ID
				@lockManID varchar(13) output,	--������ID�������ǰ�˻����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
	declare @thisLockMan varchar(13)
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
				--set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
				set @lockManName = '¬�γ�'
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


--����˻�
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
--���
foreign key(transferAccountID) references accountList(accountID) on update cascade on delete cascade,
--����
	 CONSTRAINT [PK_accountTransferID] PRIMARY KEY CLUSTERED 
(
	[accountTransferID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


drop PROCEDURE accountTransfer
/*
	name:		accountTransfer
	function: 	�ô洢���������˻��༭������༭��ͻ
	input: 
				@accountTransferID varchar(15) output,	--�˻��ƽ�ID,������ʹ��410�ź��뷢��������
				@handoverDate	smalldatetime,	--�ƽ�����
				@transferAccountID	varchar(13),	--�ƽ��˻�ID
				@transferAccount	varchar(30),	--�ƽ��˻�
				@transferPersonID	varchar(13),	--�ƽ���ID
				@transferPerson	varchar(20),	--�ƽ���
				@handoverPersonID	varchar(13),	--������ID
				@handoverPerson	varchar(20),	--������
				@transferMatters	varchar(200),	--�ƽ�����
				@remarks		varchar(200),	--��ע
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ƽ��ĵ��˻������ڣ�2:Ҫ�ƽ��ĵ��˻����ڱ�����������9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE accountTransfer
				@accountTransferID varchar(15) output,	--�˻��ƽ�ID,������ʹ��410�ź��뷢��������
				@handoverDate	smalldatetime,	--�ƽ�����
				@transferAccountID	varchar(13),	--�ƽ��˻�ID
				@transferAccount	varchar(30),	--�ƽ��˻�
				@transferPersonID	varchar(13),	--�ƽ���ID
				@transferPerson	varchar(20),	--�ƽ���
				@handoverPersonID	varchar(13),	--������ID
				@handoverPerson	varchar(20),	--������
				@transferMatters	varchar(200),	--�ƽ�����
				@remarks		varchar(200),	--��ע
				@lockManID varchar(13) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
			--�����˻�������
			update accountList set administratorID = @handoverPersonID,administrator =  @handoverPerson where accountID = @transferAccountID
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
									remarks			--��ע
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
									@remarks			--��ע
									)
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
				values(@lockManID, @lockManName, getdate(), '�ƽ��˻�', 'ϵͳ�����û�' + @lockManName	+ '��Ҫ���ƽ����˻����ƽ�����Ϊ['+ @accountTransferID +']��')
		end
	else
		begin
			set @Ret = 3
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