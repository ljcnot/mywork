use fTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-��ͬ���۹���
	�����豸����ϵͳ����ı�
	author:		¬έ
	CreateDate:	2012-4-26
	UpdateDate: 
*/
--1.��ͬ�������һ����discussInfo����
select contractID, discussID, discussTitle, discussHTML, discussTime, authorID, authorName 
from discussInfo
order by discussID desc

drop TABLE discussInfo
CREATE TABLE discussInfo
(
	contractID varchar(12) not null,	--����������ţ���ͬ��ţ�
	discussID varchar(12) not null,		--���������������ţ�ʹ�õ� 2 �ź��뷢��������
	discussTitle nvarchar(100) null,	--���⣺��ʱδʹ��
	discussHTML nvarchar(4000) null,	--����

	discussTime datetime default(getdate()),--����ʱ��
	authorID varchar(10) null,			--������ID
	authorName varchar(30) null,		--����������:�������
CONSTRAINT [PK_discussInfo] PRIMARY KEY CLUSTERED 
(
	[discussID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[discussInfo] WITH CHECK ADD CONSTRAINT [FK_discussInfo_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussInfo] CHECK CONSTRAINT [FK_discussInfo_contractInfo] 
GO

CREATE NONCLUSTERED INDEX [IX_discussInfo] ON [dbo].[discussInfo] 
(
	[discussTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

--2.��������Ķ���¼
drop TABLE discussReadInfo
CREATE TABLE discussReadInfo
(
	contractID varchar(12) not null,	--����������ţ���ͬ��ţ�
	readerID varchar(10) not null,		--�Ķ���ID
	readerTime datetime null,			--�Ķ�ʱ��
CONSTRAINT [PK_discussReadInfo] PRIMARY KEY CLUSTERED 
(
	[contractID] ASC,
	[readerID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[discussReadInfo] WITH CHECK ADD CONSTRAINT [FK_discussReadInfo_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussReadInfo] CHECK CONSTRAINT [FK_discussReadInfo_contractInfo]
GO

select * from discussReadInfo


drop PROCEDURE addDiscussInfo
/*
	name:		addDiscussInfo
	function:	1.���ָ����ͬ���������
				ע�⣺�ô洢���̲���������
	input: 
				@contractID varchar(12),	--����������ţ���ͬ��ţ�
				@discussTitle nvarchar(100),--���⣺��ʱδʹ��
				@discussHTML nvarchar(4000),--����
				@authorID varchar(10),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
											0:�ɹ���9:δ֪����
				@discussID varchar(12) output--���������ţ�ʹ�õ� 2 �ź��뷢��������
	author:		¬έ
	CreateDate:	2012-4-26
	UpdateDate: 

*/
create PROCEDURE addDiscussInfo
	@contractID varchar(12),	--����������ţ���ͬ��ţ�
	@discussTitle nvarchar(100),--���⣺��ʱδʹ��
	@discussHTML nvarchar(4000),--����

	@authorID varchar(10),		--������ID

	@Ret int output,			--�����ɹ���ʶ
	@discussID varchar(12) output--���������ţ�ʹ�õ� 2 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 2, 1, @curNumber output
	set @discussID = @curNumber

	--ȡ�����˵�������
	declare @authorName varchar(30)
	set @authorName = isnull((select cName from sysUserInfo where userID = @authorID),'')

	declare @createTime smalldatetime --����ʱ��
	set @createTime = getdate()
	insert discussInfo(contractID, discussID, discussTitle, discussHTML, discussTime, authorID, authorName)
	values (@contractID, @discussID, @discussTitle, @discussHTML, @createTime, @authorID, @authorName)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	--����������Ϊ�Ѿ��Ķ���
	exec dbo.discussInfoReaded @contractID, @authorID,@Ret output
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@authorID, @authorName, @createTime, '���ۺ�ͬ', '�û�[' + @authorName + 
					']�Ժ�ͬ['+@contractID+']�����˱��Ϊ['+@discussID+']�������')
GO

select * from discussReadInfo

drop PROCEDURE delDiscussInfo
/*
	name:		delDiscussInfo
	function:	2.ɾ��ָ�����������
	input: 
				@discussID varchar(12),			--����������
				@delManID varchar(10),			--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1������������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-26
	UpdateDate:
*/
create PROCEDURE delDiscussInfo
	@discussID varchar(12),			--����������
	@delManID varchar(10),			--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ��������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussInfo where discussID = @discussID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	delete discussInfo where discussID = @discussID
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ�����������['+ @discussID +']��')

GO
--���ԣ�


drop PROCEDURE discussInfoReaded
/*
	name:		discussInfoReaded
	function:	3.�Ǽ�ָ����ͬ��������Ѿ��Ķ�
				ע�⣺���洢���̲��Ǽǹ�����־
	input: 
				@contractID varchar(12),	--�����ţ���ͬ��ţ�
				@readerID varchar(10),		--�Ķ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-9
	UpdateDate:
*/
create PROCEDURE discussInfoReaded
	@contractID varchar(12),	--�����ţ���ͬ��ţ�
	@readerID varchar(10),		--�Ķ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж��Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from discussReadInfo where contractID = @contractID and readerID = @readerID)	
	if (@count = 0)	--������
		insert discussReadInfo(contractID,readerID,readerTime)
		values(@contractID,@readerID,GETDATE())
	else
		update discussReadInfo
		set readerTime = GETDATE()
		where contractID = @contractID and readerID = @readerID

	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
GO

drop TABLE discussReadInfo
CREATE TABLE discussReadInfo
(
	contractID varchar(12) not null,	--����������ţ���ͬ��ţ�
	readerID varchar(10) not null,		--�Ķ���ID
	readerTime smalldatetime null,		--�Ķ�ʱ��
CONSTRAINT [PK_discussReadInfo] PRIMARY KEY CLUSTERED 
(
	[contractID] ASC,
	[readerID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

