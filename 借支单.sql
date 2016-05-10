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

--��֧����������
drop table AuditBorrowList      
create table AuditBorrowList(
	ApprovalDetailsID varchar(16)	not null,	--��������ID
	billID	varchar(15)	not null,	--��֧��ID
	approvalStatus smallint default(0) not	null,	--���������ͬ��/��ͬ�⣩
	approvalOpinions	varchar(200),	--�������
	examinationPeoplePost varchar(50),	--������ְ��
	examinationPeopleID	varchar(20),	--������ID
	examinationPeopleName	varchar(20)	--����������
--���
foreign key(billID) references borrowSingle(borrowSingleID) on update cascade on delete cascade,
--����
 CONSTRAINT [PK_ AuditBorrow_ApprovalDetailsID] PRIMARY KEY CLUSTERED 
(
	[ApprovalDetailsID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--��˽�֧��
drop PROCEDURE AuditBorrowSingle
/*
	name:		AuditBorrowSingle
	function:	1.��˽�֧��
				ע�⣺���洢���̲������༭��
	input: 

			@billID	varchar(15),	--��֧��ID
			@approvalStatus smallint,	--���������0:ͬ��,1:��ͬ�⣩
			@approvalOpinions	varchar(200),	--�������
			@examinationPeoplePost varchar(50),	--������ְ��
			@examinationPeopleID	varchar(20),	--������ID
			@examinationPeopleName	varchar(20),	--����������



	output: 
			@ApprovalDetailsID varchar(16) output,	--��������ID��������ʹ��402�ź��뷢��������
			@Ret		int output           --�����ɹ���ʶ,0:�ɹ���1��Ҫ��˵Ľ�֧�������ڣ�2���ý�֧�����ڱ������û�������3���ý�֧��Ϊ�������״̬��9��δ֪����
			@createManID varchar(13) output,			--������ID
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-5-7

*/
create PROCEDURE AuditBorrowSingle				
			@ApprovalDetailsID varchar(16) output,	--��������ID��������ʹ��402�ź��뷢��������
			@billID	varchar(15),	--��֧��ID
			@approvalStatus smallint,	--���������0:ͬ��,1:��ͬ�⣩
			@approvalOpinions	varchar(200),	--�������
			@examinationPeoplePost varchar(50),	--������ְ��
			@examinationPeopleID	varchar(20),	--������ID
			@examinationPeopleName	varchar(20),	--����������

			@createManID varchar(13) output,			--������ID
			@Ret		int output           --�����ɹ���ʶ,0:�ɹ���1��Ҫ��˵Ľ�֧�������ڣ�2���ý�֧�����ڱ������û�������3���ý�֧��Ϊ�������״̬��4:���������ý�֧������˱����ͻ��9��δ֪����
	WITH ENCRYPTION 
AS

	--�ж�Ҫ��˵Ľ�֧���Ƿ����
	declare @count as int
	set @count=(select count(*) from borrowSingle where borrowSingleID= @billID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������״̬
	declare @thisperson varchar(13)
	set @thisperson = (select flowProgress from borrowSingle
					where borrowSingleID = @billID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson<>1)
	begin
		set @Ret = 3
		return
	end
	--���༭����
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
			insert AuditBorrowList(
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
			if @@ERROR <> 0 
			set @Ret = 9
			--�Ǽǹ�����־��
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@createManID,@createManName, @createTime, '��˵���', 'ϵͳ�����û�'+@createManName+'��Ҫ������˵��ݣ���������Ϊ[' + @ApprovalDetailsID + ']��')
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