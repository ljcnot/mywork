--��Ŀ�����
drop table subjectList 
create table subjectList(
FinancialSubjectID	varchar(8)	not	null,	--��ĿID
superiorSubjectsID	varchar(8),	--�ϼ���ĿID
superiorSubjects varchar(30),	--�ϼ���Ŀ����
subjectName	varchar(30)	not null,	--��Ŀ����
AccountNumber int not null,	--��Ŀ����(�����ÿ�Ŀ�ڿ�Ŀ���Ĳ���)
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
				@FinancialSubjectID	varchar(8),	--��ĿID,����
				@superiorSubjectsID	varchar(8),	--�ϼ���ĿID
				@superiorSubjects varchar(30),		--�ϼ���Ŀ����
				@subjectName	varchar(30),			--��Ŀ����
				@AccountNumber int ,				--��Ŀ����
				@establishTime smalldatetime,		--����ʱ��
				@explain	varchar(200),				--˵��

				@createManID varchar(10),			--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23

*/

create PROCEDURE addSubject			
				@FinancialSubjectID	varchar(8),	--��ĿID,����
				@superiorSubjectsID	varchar(8),	--�ϼ���ĿID
				@superiorSubjects varchar(30),		--�ϼ���Ŀ����
				@subjectName	varchar(30),			--��Ŀ����
				@AccountNumber int ,				--��Ŀ����
				@establishTime smalldatetime,		--����ʱ��
				@explain	varchar(200),				--˵��

				@createManID varchar(10),			--�����˹���

				@Ret		int output,
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()

	insert subjectList(
				FinancialSubjectID,	--��ĿID,����
				superiorSubjectsID,	--�ϼ���ĿID
				superiorSubjects,		--�ϼ���Ŀ����
				subjectName,			--��Ŀ����
				AccountNumber,		--��Ŀ����
				establishTime,		--����ʱ��
				explain,				--˵��
				createManID,			--�����˹���
				createTime			--����ʱ��
							) 
	values (		
				@FinancialSubjectID,	--��ĿID,����
				@superiorSubjectsID,	--�ϼ���ĿID
				@superiorSubjects,		--�ϼ���Ŀ����
				@subjectName,			--��Ŀ����
				@AccountNumber,		--��Ŀ����
				@establishTime,		--����ʱ��
				@explain,				--˵��
				@createManID,			--�����˹���
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
				@FinancialSubjectID	varchar(8),	--��ĿID
				@subjectName	varchar(30),		--��Ŀ����
				@explain varchar(200),				--˵��


	output: 
				@lockManID varchar(10) output,		--�����˹���
				@Ret		int output,			--�����ɹ���ʶ,0:�ɹ���1���ÿ�Ŀ�ѱ��������û�������3���ÿ�Ŀ�����ڣ�9��δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-3-23

*/

create PROCEDURE editSubject			
				@FinancialSubjectID	varchar(8),	--��ĿID
				@subjectName	varchar(30),		--��Ŀ����
				@explain varchar(200),				--˵��

				@lockManID varchar(10) output,				--�����˹���
				@Ret		int output,			--�����ɹ���ʶ,0:�ɹ���1���ÿ�Ŀ�ѱ��������û�������3���ÿ�Ŀ�����ڣ�9��δ֪����
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
	declare @thislockMan varchar(10)
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
	set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
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
				@FinancialSubjectID varchar(8),			--��ĿID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				
	output: 
				@Ret int output					--�����ɹ���ʶ	0:�ɹ���1��Ҫ�����Ŀ�Ŀ�����ڣ�2:Ҫ�����Ŀ�Ŀ���ڱ����˱༭��9��δ֪����
							0:�ɹ���
							1��Ҫ�����Ŀ�Ŀ�����ڣ�
							2:Ҫ�����Ŀ�Ŀ���ڱ����˱༭��
							9��δ֪����
	author:		¬�γ�
	CreateDate:	2016-4-16

*/
create PROCEDURE lockSubjectEdit
				@FinancialSubjectID varchar(8),			--��ĿID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret int output					--�����ɹ���ʶ	0:�ɹ���1��Ҫ�����Ŀ�Ŀ�����ڣ�2:Ҫ�����Ŀ�Ŀ���ڱ����˱༭��9��δ֪����
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
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

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
				@FinancialSubjectID varchar(8),			--��ĿID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ������Ŀ�Ŀ�����ڣ�2:Ҫ�ͷ������Ŀ�Ŀ���ڱ����˱༭��8���ÿ�Ŀδ���κ���������9��δ֪����
							
	author:		¬�γ�
	CreateDate:	2016-4-16
	UpdateDate: 
*/
create PROCEDURE unlockSubjectEdit
				@FinancialSubjectID varchar(8),			--��ĿID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��֧�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
				@Ret		int output		--�����ɹ���ʶ0:�ɹ���1��Ҫ�ͷ������Ŀ�Ŀ�����ڣ�2:Ҫ�ͷ������Ŀ�Ŀ���ڱ����˱༭��8���ÿ�Ŀδ���κ���������9��δ֪����
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
				set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
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