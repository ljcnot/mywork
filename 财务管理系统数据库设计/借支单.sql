drop table borrowSingle      --��֧����
create table borrowSingle(
	borrowSingleID varchar(13) not null,  --��֧����
	borrowManID varchar(10)	not null,	--��֧��ID
	borrowMan varchar(30)	not null,		--��֧�ˣ�������
	position	varchar(20)	not null,	--ְ��
	departmentID	varchar(13)	not null,	--����ID
	department	varchar(30)	not null,	--����
	borrowDate	smalldatetime	not null,	--��֧ʱ��
	projectID	 varchar(13),					--������ĿID
	projectName	varchar(30),				--������Ŀ�����ƣ�
	borrowReason	varchar(200),				--��֧����
	borrowSum		numeric(15,2),			--��֧���
	flowProgress smallint default(0),		--��ת���ȣ�0���½���1:�����,2�������У�3�������
	IssueSituation	smallint default(0),	--���������0��δ���ţ�1���ѷ���
	paymentMethodID	varchar(13),	---�����˻�ID
	paymentMethod	varchar(50) ,	--�����˻�
	paymentSum	numeric(15,2),--������
	draweeID varchar(10),		--������ID
	drawee varchar(30),		--������
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
	ApprovalDetailsID int identity(1,1),	--��������ID
	billID	varchar(13)	Primary Key (ApprovalDetailsID, billID)not null,	--��֧��ID
	approvalStatus smallint default(0) not	null,	--���������0��ͬ��/1����ͬ�⣩
	approvalOpinions	varchar(200),		--�������
	examinationPeoplePost varchar(20),	--������ְ��
	examinationPeopleID	varchar(10),	--������ID
	examinationPeopleName	varchar(30),	--����������
--���
foreign key(billID) references borrowSingle(borrowSingleID) on update cascade on delete cascade
)

--��˽�֧��
drop PROCEDURE AuditBorrowSingle
/*
	name:		AuditBorrowSingle
	function:	1.��˽�֧��
				ע�⣺���洢���̲������༭��
	input: 
			@billID	varchar(13),				--��֧��ID
			@approvalStatus smallint,			--���������0��ͬ��/1����ͬ�⣩
			@approvalOpinions	varchar(200),		--�������
			@examinationPeoplePost varchar(20),	--������ְ��
			@examinationPeopleID	varchar(10),	--������ID
			@examinationPeopleName	varchar(30),	--����������

			@createManID varchar(10) output,			--������ID
	output: 
			@Ret		int output           --�����ɹ���ʶ,0:�ɹ���1��Ҫ��˵Ľ�֧�������ڣ�2���ý�֧�����ڱ������û�������3���ý�֧��Ϊ�������״̬��4:���������ý�֧������˱����ͻ��9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-5-7

*/
create PROCEDURE AuditBorrowSingle				
			@billID	varchar(13),				--��֧��ID
			@approvalStatus smallint,			--���������0��ͬ��/1����ͬ�⣩
			@approvalOpinions	varchar(200),		--�������
			@examinationPeoplePost varchar(20),	--������ְ��
			@examinationPeopleID	varchar(10),	--������ID
			@examinationPeopleName	varchar(30),	--����������

			@createManID varchar(10) output,			--������ID
			@Ret		int output           --�����ɹ���ʶ,0:�ɹ���1��Ҫ��˵Ľ�֧�������ڣ�2���ý�֧�����ڱ������û�������3���ý�֧��δ�������״̬��4:���������ý�֧������˱����ͻ��9��δ֪����
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
	declare @thisperson varchar(10)
	set @thisperson = (select flowProgress from borrowSingle
					where borrowSingleID = @billID
					and	  ISNULL(lockManID,'')<>'')
	if(@thisperson=0)
	begin
		set @Ret = 3
		return
	end

	if(@thisperson = 3)
	begin
		set @Ret = 3
		return
	end
	--���༭����
	declare @thisLockMan varchar(10)
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

	
			----ȡά���˵�������
			declare @createManName nvarchar(30)
			set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
			declare @createTime smalldatetime
			set @createTime = getdate()
			insert AuditBorrowList(
					billID,	--��֧��ID
					approvalStatus,	--���������ͬ��/��ͬ�⣩
					approvalOpinions,	--�������
					examinationPeoplePost,	--������ְ��
					examinationPeopleID,	--������ID
					examinationPeopleName	--����������
									) 
			values (			
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
			values(@createManID,@createManName, @createTime, '��˽�֧��', 'ϵͳ�����û�'+@createManName+'��Ҫ������˽�֧��['+@billID+']��')
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
			@borrowManID varchar(10),		--��֧��ID
			@borrowMan varchar(30),		--��֧�ˣ�������
			@position	varchar(20),			--ְ��
			@departmentID	varchar(13),		--����ID
			@department	varchar(30),		--����
			@borrowDate	smalldatetime,	--��֧ʱ��
			@projectID	 varchar(13),		--������ĿID
			@projectName	varchar(30),		--������Ŀ�����ƣ�
			@borrowReason	varchar(200),		--��֧����
			@borrowSum		numeric(15,2),--��֧���

			@createManID varchar(10),		--�����˹���
	output: 
				@borrowSingleID varchar(13),	--��֧����,���� ��401�ź��뷢��������
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-3-23
*/
create PROCEDURE addborrowSingle				
			@borrowSingleID varchar(13) output,	--��֧����,���� ��401�ź��뷢��������
			@borrowManID varchar(10),		--��֧��ID
			@borrowMan varchar(30),		--��֧�ˣ�������
			@position	varchar(20),			--ְ��
			@departmentID	varchar(13),		--����ID
			@department	varchar(30),		--����
			@borrowDate	smalldatetime,	--��֧ʱ��
			@projectID	 varchar(13),		--������ĿID
			@projectName	varchar(30),		--������Ŀ�����ƣ�
			@borrowReason	varchar(200),		--��֧����
			@borrowSum		numeric(15,2),--��֧���

			@createManID varchar(10),		--�����˹���

			@Ret		int output		--�����ɹ���ʶ,0:�ɹ���9��δ֪����
	WITH ENCRYPTION 
AS
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 401, 1, @curNumber output
	set @borrowSingleID = @curNumber

	
	----ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	declare @createTime smalldatetime
	set @createTime = getdate()
	insert borrowSingle(		borrowSingleID,	--��֧����,���� ��401�ź��뷢��������
							borrowManID,		--��֧��ID
							borrowMan,		--��֧�ˣ�������
							position	,			--ְ��
							departmentID,		--����ID
							department,		--����
							borrowDate,	--��֧ʱ��
							projectID,		--������ĿID
							projectName,		--������Ŀ�����ƣ�
							borrowReason,		--��֧����
							borrowSum,		--��֧���
							flowProgress,		--��ת���ȣ�0���½���1:�����,2�������У�3�������
							IssueSituation,	--���������0��δ���ţ�1���ѷ���
							createManID,	--�����˹���
							createManName,	--����������
							createTime		--����ʱ��
							) 
	values ( @borrowSingleID,	--��֧����,���� ��401�ź��뷢��������
			@borrowManID,		--��֧��ID
			@borrowMan,		--��֧�ˣ�������
			@position	,			--ְ��
			@departmentID,		--����ID
			@department,		--����
			@borrowDate,	--��֧ʱ��
			@projectID,		--������ĿID
			@projectName,		--������Ŀ�����ƣ�
			@borrowReason,		--��֧����
			@borrowSum,--��֧��� 
			'0',				--��ת���ȣ�0���½���1:�����,2�������У�3�������
			'0',				--���������0��δ���ţ�1���ѷ���
			@createManID, 
			@createManName,
			@createTime) 
	set @Ret = 0
	--if @@ERROR <> 0 
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID,@createManName, @createTime, '��ӽ�֧��', 'ϵͳ�����û�'+@createManName+'��Ҫ������˽�֧��[' + @borrowSingleID + ']��')
GO






drop PROCEDURE editborrowSingle
/*
	name:		editborrowSingle
	function:	1.�༭��֧��
				ע�⣺���洢���������༭��
	input: 
			@borrowSingleID varchar(13),	--��֧����,����
			@borrowManID varchar(10),		--��֧��ID
			@borrowMan varchar(30),		--��֧�ˣ�������
			@position	varchar(20),			--ְ��
			@departmentID	varchar(13),		--����ID
			@department	varchar(30),		--����
			@borrowDate	smalldatetime,	--��֧ʱ��
			@projectID	 varchar(13),		--������ĿID
			@projectName	varchar(30),		--������Ŀ�����ƣ�
			@borrowReason	varchar(200),		--��֧����
			@borrowSum		numeric(15,2),--��֧���

	output: 
				@lockManID varchar(10) output,		--�����˹���
				@Ret		int output		--������ʾ��0���ɹ���1���ý�֧�������ڣ�2���õ���Ϊ���״̬������༭��3���õ��ݱ������˱༭ռ��,4:���������õ����ٱ༭,�����ͻ

	author:		¬�γ�
	CreateDate:	2016-3-23
*/
create PROCEDURE editborrowSingle				
			@borrowSingleID varchar(13),	--��֧����,����
			@borrowManID varchar(10),		--��֧��ID
			@borrowMan varchar(30),		--��֧�ˣ�������
			@position	varchar(20),			--ְ��
			@departmentID	varchar(13),		--����ID
			@department	varchar(30),		--����
			@borrowDate	smalldatetime,	--��֧ʱ��
			@projectID	 varchar(13),		--������ĿID
			@projectName	varchar(30),		--������Ŀ�����ƣ�
			@borrowReason	varchar(200),		--��֧����
			@borrowSum		numeric(15,2),--��֧���

			@lockManID varchar(10) output,		--�����˹���

			@Ret		int output		--������ʾ��0���ɹ���1���ý�֧�������ڣ�2���õ���Ϊ���״̬������༭��3���õ��ݱ������˱༭ռ��,4:���������õ����ٱ༭,�����ͻ

	WITH ENCRYPTION 
AS
	set @Ret = 9

		--�ж�Ҫ��˵Ľ�֧���Ƿ����
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
		set @Ret = 2
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from borrowSingle
					where borrowManID = @borrowManID
					and	  ISNULL(lockManID,'')<>'')
	if (@thisLockMan<>'')
		begin
			if(@thisLockMan<>@lockManID)
				begin
					set @lockManID = @thisLockMan
					set @Ret = 3
					return
				end
			else
				begin
									--ȡά���˵�������
					declare @modiManName nvarchar(30)
					set @modiManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
					declare @modiTime smalldatetime
					set @modiTime = getdate()
					update borrowSingle set 
											borrowMan = @borrowMan,		--��֧������
											position = @position,			--ְ��
											departmentID = @departmentID,	--����
											borrowDate = @borrowDate,		--��֧ʱ��
											projectID = @projectID,		--������ĿID
											projectName = @projectName,	--������Ŀ(���ƣ�
											borrowReason = @borrowReason,	--��֧����
											borrowSum = @borrowSum,		--��֧���
											modiManID = @lockManID,		--ά���˹���
											modiManName	= @modiManName,	--ά��������
											modiTime	= @modiTime			--�޸�ʱ��
											where borrowSingleID = @borrowSingleID--��֧��ID
					set @Ret = 0
					if @@ERROR <> 0
					begin
						set @Ret = 9
						return
					end 
					--�Ǽǹ�����־��
					insert workNote(userID, userName, actionTime, actions, actionObject)
					values(@lockManID, @modiManName, @modiTime, '�༭��֧����', 'ϵͳ�����û�' + @modiManName + 
									'��Ҫ���޸��˽�֧��[' + @borrowSingleID + ']��')
				end
		end
	else
	begin
		set @Ret = 4
		return
	end

GO




drop PROCEDURE lockborrowSingleEdit
/*
	name:		borrowSingle
	function:	������֧���༭������༭��ͻ
	input: 
				@@borrowSingleID varchar(13),			--��֧��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
				@borrowSingleID varchar(13),			--��֧��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
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
	declare @thisLockMan varchar(10)
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
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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
				@@borrowSingleID varchar(13),			--��֧��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
												0:�ɹ���1���ý�֧�������ڣ�2�������õ��ݵ��˲����Լ���8:�õ���δ������,9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockborrowSingleEdit
				@borrowSingleID varchar(13),			--��֧��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ,0:�ɹ���1���ý�֧�������ڣ�2�������õ��ݵ��˲����Լ���8:�õ���δ������,9��δ֪����
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
	declare @thisLockMan varchar(10)
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
				set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
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
				@borrowSingleID varchar(13),			--��֧��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��ָ���Ľ�֧�������ڣ�
							2:Ҫɾ���Ľ�֧����������������
							3:�õ����Ѿ�����������ɾ����
							4:���������ý�֧������ɾ���������ͻ
							9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16

*/
create PROCEDURE delborrowSingle
				@borrowSingleID varchar(13),			--��֧��ID
				@lockManID varchar(10) output,		--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���.

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
	declare @thisLockMan varchar(10)
	set @thisLockMan = (select lockManID from borrowSingle
					where borrowSingleID = @borrowSingleID)
					
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
					set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
					--�Ǽǹ�����־��
					insert workNote(userID, userName, actionTime, actions, actionObject)
					values(@lockManID, @lockManName, getdate(), 'ɾ����֧��', 'ϵͳ�����û�' + @lockManName
																+ 'ɾ���˽�֧��['+ @borrowSingleID +']��')
				end
		end
	else
		begin
			set @Ret = 4
			return
		end
GO
