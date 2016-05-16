--������   
drop table attachment 
create table attachment(
uidFilename varchar(128) not null,	--UID�ļ���
billType	 smallint default(0)	not	null,	--Ʊ�����ͣ�0����֧����1��������
billID	varchar(13)	not	null,	--Ʊ�ݱ��
aFilename varchar(128) null,		--ԭʼ�ļ���
fileSize bigint null,				--�ļ��ߴ�
fileType varchar(10),				--�ļ�����
uploadTime smalldatetime default(getdate()),	--�ϴ�����
fileLog varchar(128) null,			--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG
--����
	 CONSTRAINT [PK_attachment] PRIMARY KEY CLUSTERED 
(
	uidFilename ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--��Ӹ���
drop PROCEDURE addAttachment
/*
	name:		addAttachment
	function:	1.��Ӹ���
				ע�⣺���洢���̲������༭��
	input: 
				@uidFilename varchar(128),	--UID�ļ���
				@billType	 smallint,		--Ʊ�����ͣ�0����֧����1��������
				@billID	varchar(13),		--Ʊ�ݱ��
				@aFilename varchar(128),	--ԭʼ�ļ���
				@fileSize bigint,			--�ļ��ߴ�
				@fileType varchar(10),		--�ļ�����
				@fileLog varchar(128),		--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG

				@createManID varchar(10),		--�����˹���

	output: 
				@Ret		int output,     --�ɹ���ʶ,0:�ɹ�,9:δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-5-13

*/

create PROCEDURE addAttachment			
				@uidFilename varchar(128),	--UID�ļ���
				@billType	 smallint,		--Ʊ�����ͣ�0����֧����1��������
				@billID	varchar(13),		--Ʊ�ݱ��
				@aFilename varchar(128),	--ԭʼ�ļ���
				@fileSize bigint,			--�ļ��ߴ�
				@fileType varchar(10),		--�ļ�����
				@fileLog varchar(128),		--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG

				@createManID varchar(10),		--�����˹���

				@Ret		int output,     --�ɹ���ʶ,0:�ɹ�,9:δ֪����
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()

	insert attachment(
				uidFilename,	--UID�ļ���
				billType	,	--Ʊ�����ͣ�0����֧����1��������
				billID,		--Ʊ�ݱ��
				aFilename,	--ԭʼ�ļ���
				fileSize,	--�ļ��ߴ�
				fileType,	--�ļ�����
				fileLog		--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG
							) 
	values (		
				@uidFilename,	--UID�ļ���
				@billType	,	--Ʊ�����ͣ�0����֧����1��������
				@billID,		--Ʊ�ݱ��
				@aFilename,	--ԭʼ�ļ���
				@fileSize,	--�ļ��ߴ�
				@fileType,	--�ļ�����
				@fileLog		--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��Ӹ���', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ������˸���[' + @uidFilename + ']��')		
GO


--ɾ������
drop PROCEDURE delAttachment
/*
	name:		delAttachment
	function:	1.ɾ������
				ע�⣺���洢���̲������༭��
	input: 
				@uidFilename varchar(128),		--UID�ļ���
				@lockManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		  --�ɹ���ʾ��0���ɹ���1���ø���������,9:δ֪����
				@createTime smalldatetime output
	author:		¬�γ�
	CreateDate:	2016-5-13
*/

create PROCEDURE delAttachment			
				@uidFilename varchar(128),		--UID�ļ���
				@lockManID varchar(10),		--�����˹���

				@Ret		int output,			--�ɹ���ʾ��0���ɹ���1���ø���������,9:δ֪����
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @createTime = getdate()
		
	--�ж�Ҫɾ���ĸ����Ƿ����
	declare @count as int
	set @count=(select count(*) from attachment where uidFilename= @uidFilename)	
	if (@count = 0)	--������
		begin
			set @Ret = 1
			return
		end
	--ɾ������
	delete FROM attachment where uidFilename= @uidFilename 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName, @createTime, 'ɾ������', 'ϵͳ�����û�' + @createManName + 
		'��Ҫ��ɾ���˸���[' + @uidFilename + ']��')		
GO
