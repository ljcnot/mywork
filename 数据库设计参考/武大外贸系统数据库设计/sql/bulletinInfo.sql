use newfTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-��������
	�����豸����ϵͳ�ı�
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: 2013-10-06��OAϵͳһ�»�
*/
--1.վ�ڹ���һ����bulletinInfo����
drop TABLE bulletinInfo
CREATE TABLE bulletinInfo
(
	bulletinID char(12) not null,			--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
	bulletinTime datetime null,				--����ʱ��
	bulletinTitle nvarchar(100) null,		--�������
	bulletinHTML nvarchar(max) null,		--��������

	onTop int default(0),					--�Ƿ��ö���ʾ��0->���ö���1->�ö���ʾ add by lw 2013-9-8
	isActive int default(0),				--�Ƿ񷢲���0->δ������1->�ѷ���
	activeDate smalldatetime null,			--��������
	isClosed int default(0),				--�Ƿ�رգ���ʷ���棩��0->δ�رգ�1->�ѹر� add by lw 2013-9-8
	closedTime smalldatetime null,			--�ر����� add by lw 2013-9-8
	orderNum smallint default(-1),			--��ʾ�����
	autoCloseDate smalldatetime null,		--�Զ��ر�����

	--ͶƱ��
	enableVote smallint default(0),			--�Ƿ�����ͶƱ��0->����1->������
	voteOption xml null,					--ͶƱѡ�� add by lw 2013-07-12
												--N'<root>'+
												--	'<item ID="1" itemDesc="ͬ��" />'+
												--	'<item ID="2" itemDesc="��ͬ��" />'+
												--	'<item ID="3" itemDesc="��Ȩ" />'+
												--'</root>'	
	--��������
	publishTo xml null,						--���������Ķ�Ȩ�ޣ�����������xml��ʽ���
												--N'<root>'+
												--	'<user userID="G201300001" userCName="��Զ" />'+	--�������û�
												--	'<unit uCode="001001" uName="�칫��" />'+			--�����Ĳ���
												--	'<sysRole id="3" desc="���ع���Ա" />'+				--�����Ľ�ɫ
												--	'<exceptUser userID="G201300003" userCName="���" />'+			--������Ա
												--'</root>'	
	--�����ˣ�
	createrID varchar(10) null,			--�����˹���
	creater varchar(30) null,			--������
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
CONSTRAINT [PK_bulletinInfo] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_bulletinInfo] ON [dbo].[bulletinInfo] 
(
	[bulletinTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_bulletinInfo_0] ON [dbo].[bulletinInfo] 
(
	[isActive] ASC,
	[orderNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

--1.1.1����ͶƱһ����
DROP TABLE bulletinVote
CREATE TABLE bulletinVote
(
	bulletinID char(12) not null,			--����/�����������
	voterID varchar(10) not null,			--������ͶƱ��ID
	voter nvarchar(30) null,				--������ƣ�ͶƱ��
	voteTime datetime default(getdate()),	--ͶƱʱ��
	voteResult smallint default(0),			--����������ӦͶƱѡ���ID
CONSTRAINT [PK_bulletinVote] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC,
	[voterID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[bulletinVote] WITH CHECK ADD CONSTRAINT [FK_bulletinVote_bulletinInfo] FOREIGN KEY([bulletinID])
REFERENCES [dbo].[bulletinInfo] ([bulletinID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bulletinVote] CHECK CONSTRAINT [FK_bulletinVote_bulletinInfo]
GO

select bulletinID, voterID, voter, convert(varchar(19),voteTime,120) voteTime, voteResult
from bulletinVote

--1.1.2��������һ����
drop TABLE bulletinDiscuss
CREATE TABLE bulletinDiscuss
(
	bulletinID char(12) not null,		--����/�����������
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL, --�ڲ��к�
	discussTitle nvarchar(100) null,	--���⣺��ʱδʹ��
	discussHTML nvarchar(4000) null,	--����

	discussTime datetime default(getdate()),--����ʱ��
	discusserID varchar(10) null,		--������ID
	discusser varchar(30) null,			--����������:�������
CONSTRAINT [PK_bulletinDiscuss] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[bulletinDiscuss] WITH CHECK ADD CONSTRAINT [FK_bulletinDiscuss_bulletinInfo] FOREIGN KEY([bulletinID])
REFERENCES [dbo].[bulletinInfo] ([bulletinID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bulletinDiscuss] CHECK CONSTRAINT [FK_bulletinDiscuss_bulletinInfo] 
GO

select bulletinID, rowNum, discussTitle, discussHTML, convert(varchar(19),d.discussTime,120) discussTime, discusserID, discusser
from bulletinDiscuss d
where bulletinID = '201307130008'
order by d.discussTime

--1.2������ý����Դ�����
--��ý���ļ�����bulletin\media��
drop TABLE bulletinResouce
CREATE TABLE bulletinResouce(
	resouceName nvarchar(30) not null,	--��Դ����
	resouceType smallint not null,		--��Դ���ͣ�1->ͼƬ��2->Ӱ���ļ�
	fileGUID36 varchar(36) not NULL,	--��Դ�ļ���Ӧ��36λȫ��Ψһ�����ļ���
	oldFilename varchar(128) not null,	--��Դ�ļ�ԭʼ�ļ���
	extFileName varchar(8) not NULL,	--��Դ�ļ��ļ���չ��
	notes nvarchar(100) null,			--˵��
	ownerID varchar(10) null,			--�����˹���
	ownerName varchar(30) null,			--����������
	isShare char(1) default('N')		--�Ƿ���
 CONSTRAINT [PK_bulletinResouce] PRIMARY KEY CLUSTERED 
(
	[resouceType] ASC,
	[fileGUID36] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--��Դ��������
CREATE NONCLUSTERED INDEX [IX_bulletinResouce] ON [dbo].[bulletinResouce]
(
	[resouceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--1.3.���渽���⣺add by lw 2013-9-8
select * from bulletinAttachment where bulletinID='201310020001'
drop TABLE bulletinAttachment
CREATE TABLE bulletinAttachment(
	bulletinID char(12) not null,					--���/������������
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--�������к�
	
	aFilename varchar(128) null,					--ԭʼ�ļ���
	uidFilename varchar(128) not null,				--UID�ļ���
	fileSize bigint null,							--�ļ��ߴ�
	fileType varchar(10),							--�ļ�����
	uploadTime smalldatetime default(getdate()),	--�ϴ�����
 CONSTRAINT [PK_bulletinAttachment] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[bulletinAttachment] WITH CHECK ADD CONSTRAINT [FK_bulletinAttachment_bulletinInfo] FOREIGN KEY([bulletinID])
REFERENCES [dbo].[bulletinInfo] ([bulletinID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bulletinAttachment] CHECK CONSTRAINT [FK_bulletinAttachment_bulletinInfo] 
GO
--������
--ԭʼ�ļ���������
CREATE NONCLUSTERED INDEX [IX_bulletinAttachment] ON [dbo].[bulletinAttachment]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�ļ�����������
CREATE NONCLUSTERED INDEX [IX_bulletinAttachment_1] ON [dbo].[bulletinAttachment]
(
	[fileType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop FUNCTION canSeeBulletinInfo
/*
	name:		canSeeBulletinInfo
	function:	0.�ж�ָ�����û��ܷ����ָ���Ĺ���
				ע�⣺�ô洢������OAϵͳ��һ��������û�в��ţ�ֻ��Ժ����
	input: 
				@bulletinID char(12),			--������
				@userID varchar(10)			--�û�����
	output: 
				return char(1)	--�ܷ�ʹ�ã���Y��->��ʹ�ã���N��->����ʹ��
	author:		¬έ
	CreateDate:	2013-6-23
	UpdateDate: 
*/
create FUNCTION canSeeBulletinInfo
(  
	@bulletinID char(12),		--������
	@userID varchar(10)			--�û�����
)  
RETURNS char(1)
WITH ENCRYPTION
AS      
begin
	--��鹫���Ƿ���ڣ�
	declare @count int
	set @count = ISNULL((select count(*) from bulletinInfo where bulletinID = @bulletinID),0)
	if (@count=0)
	begin
		return 'N'
	end
	
	--�ж��Ƿ��з�������
	declare @publishTo xml			--���������Ķ�Ȩ�ޣ�����������xml��ʽ���
												--N'<root>'+
												--	'<user userID="G201300001" userCName="���Ҳ�" />'+	--�������û�
												--	'<college clgCode="001001" clgName="ʵ�������豸��" />'+			--������Ժ��
												--	'<sysRole id="3" desc="�豸����Ա" />'+				--�����Ľ�ɫ
												--	'<exceptUser userID="G201300003" userCName="���" />'+			--������Ա
												--'</root>'	
	select @publishTo = publishTo
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@publishTo is null)	--û�н�ɫ���ƣ�����ȫ����Ա
	begin
		return 'Y'
	end
	
	--��ȡָ������ķ�������
	declare @selectedMan as table(
		userID varchar(10),
		userCName nvarchar(30)
	)
	declare @isAllEmpty char(1)	--�Ƿ�ȫ��Ϊ��
	set @isAllEmpty = 'Y'
	--���ϵͳ��ɫ������û���
	set @count=(select @publishTo.exist('/root/sysRole'))
	if (@count>0)
	begin
		insert @selectedMan(userID, userCName)
		select u.userID, u.cName 
		from sysUserInfo u inner join sysUserRole s on u.userID = s.userID
		where s.sysRoleID in (SELECT A.sysRole.value('./@id','int') from @publishTo.nodes('/root/sysRole') as A(sysRole))
		set @isAllEmpty = 'N'
	end
	--���ֱ�Ӷ�����û���
	set @count=(select @publishTo.exist('/root/user'))
	if (@count>0)
	begin
		insert @selectedMan(userID, userCName)
		SELECT cast(A.col1.query('data(./@userID)') as varchar(10)),
			cast(A.col1.query('data(./@userCName)') as nvarchar(30))
		from @publishTo.nodes('/root/user') as A(col1)
		set @isAllEmpty = 'N'
	end
	--��Ӳ����û���
	set @count=(select @publishTo.exist('/root/college'))
	if (@count>0)
	begin
		insert @selectedMan(userID, userCName)
		select u.jobNumber, u.cName 
		from userInfo u 
		where u.uCode in (SELECT A.unit.value('./@clgCode','varchar(8)') from @publishTo.nodes('/root/college') as A(unit))
		set @isAllEmpty = 'N'
	end
		
	set @count = (select count(*) from @selectedMan)
	if (@count>0)
	begin
		--������Ա��
		delete	@selectedMan
		where userID in (SELECT A.col1.value('./@userID','varchar(10)') from @publishTo.nodes('/root/exceptUser') as A(col1))

		set @count = (select count(*) from @selectedMan where userID = @userID)
		if (@count>0)
			return 'Y'
	end
	else
	begin
		if (@isAllEmpty = 'Y')
		begin
			if (@userID not in (SELECT A.col1.value('./@userID','varchar(10)') from @publishTo.nodes('/root/exceptUser') as A(col1)))
				return 'Y'
		end
	end
	return 'N'
end
--���ԣ�
update bulletinInfo
set publishTo=N'<root>'+
					'<user userID="00011275" userCName="���Ҳ�" />'+	--�������û�
					'<college clgCode="000" clgName="ʵ�������豸��" />'+			--�����Ĳ���
					--'<sysRole id="3" desc="�豸����Ա" />'+				--�����Ľ�ɫ
					--'<exceptUser userID="G201300003" userCName="���" />'+			--������Ա
				'</root>'
where bulletinID='201306270005'

select * from bulletinInfo
select * from useUnit

select * from useUnit
select * from sysRole
select * from userInfo

select dbo.canSeeBulletinInfo('201311010003','00011275')
select dbo.canSeeBulletinInfo('201306270005','G201300001')
select dbo.canSeeBulletinInfo('201304170001','G201300003')

select * from bulletinInfo where publishTo is not null

declare @publishTo xml			--���������Ķ�Ȩ�ޣ�����������xml��ʽ���
set @publishTo=N'<root>
  <sysRole id="1" desc="�����û�" />
  <sysRole id="2" desc="һ���û�" />
  <sysRole id="3" desc="����" />
  <sysRole id="4" desc="��ɫ1" />
</root>'
SELECT A.sysRole.value('./@id','int') from @publishTo.nodes('/root/sysRole') as A(sysRole)

--��ѯָ���û�������Ĺ��棺
select * from bulletinInfo where dbo.canSeeBulletinInfo(bulletinID,'G201300040')='Y'

select publishTo, * from bulletinInfo where publishTo is not null
update bulletinInfo 
set publishTo=null
where bulletinID in ('201306220010','201306220007')


drop PROCEDURE addBulletinInfo
/*
	name:		addBulletinInfo
	function:	1.��ӹ�����Ϣ
				ע�⣺�ô洢�����Զ���������
	input: 
				@bulletinTitle nvarchar(100),	--�������
				@bulletinTime varchar(10),		--��������
				@autoCloseDate varchar(10),		--�����Զ��ر�����
				@bulletinHTML nvarchar(max),	--��������
				@enableVote smallint,			--�Ƿ�����ͶƱ��0->����1->������
				@voteOption xml,				--ͶƱѡ��
												--N'<root>'+
												--	'<item ID="1" itemDesc="ͬ��" />'+
												--	'<item ID="2" itemDesc="��ͬ��" />'+
												--	'<item ID="3" itemDesc="��Ȩ" />'+
												--'</root>'	

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,
				@bulletinID char(12) output		--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2011-12-4���ӹ������ں��Զ��ر����ڲ���
				modi by lw 2013-6-21�����Ƿ�����ͶƱ
				modi by lw 2013-07-12����ͶƱѡ���趨

*/
create PROCEDURE addBulletinInfo
	@bulletinTitle nvarchar(100),		--�������
	@bulletinTime varchar(10),			--��������
	@autoCloseDate varchar(10),			--�����Զ��ر�����
	@bulletinHTML nvarchar(max),		--��������
	@enableVote smallint,				--�Ƿ�����ͶƱ��0->����1->������
	@voteOption xml,					--ͶƱѡ��

	@createManID varchar(10),			--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@bulletinID char(12) output			--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10010, 1, @curNumber output
	set @bulletinID = @curNumber

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	
	set @createTime = getdate()
	if (@bulletinTime='')
		set @bulletinTime = CONVERT(varchar(10), @createTime, 120)
		
	--�����Զ��ر����ڣ�
	declare @closeDate smalldatetime
	if (@autoCloseDate='')
		set @closeDate=null
	else
		set @closeDate=convert(smalldatetime,@autoCloseDate,120)

	insert bulletinInfo(bulletinID, bulletinTime, autoCloseDate, bulletinTitle, bulletinHTML,
						enableVote, voteOption,
						publishTo, lockManID, modiManID, modiManName, modiTime,	createrID, creater) 
	values (@bulletinID, @bulletinTime, @closeDate, @bulletinTitle, @bulletinHTML,
			@enableVote, @voteOption, N'<root />',@createManID, @createManID, @createManName, @createTime, @createManID, @createManName)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӹ���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˹���[' + @bulletinID + ']��')
GO

DROP PROCEDURE cloneBulletinInfo
/*
	name:		cloneBulletinInfo
	function:	1.0.��¡ָ���Ĺ���
	input: 
				@bulletinID char(12),			--������
				--ά�����:
				@modiManID varchar(10) output,	--ά����
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output,			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ��¡�Ĺ��治���ڣ�9��δ֪����
				@newBulletinID char(12) output	--��������¡�Ĺ����ţ�ʹ�õ� 10010 �ź��뷢��������
	author:		¬έ
	CreateDate:	2013-09-08
	UpdateDate: 
*/
create PROCEDURE cloneBulletinInfo
	@bulletinID char(12),			--������
	--ά�����:
	@modiManID varchar(10) output,	--ά����

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output,			--�����ɹ���ʶ
	@newBulletinID char(12) output	--��������¡�Ĺ����ţ�ʹ�õ� 10010 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ��¡�Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10010, 1, @curNumber output
	set @newBulletinID = @curNumber

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	begin tran
		insert bulletinInfo(bulletinID, bulletinTime, bulletinTitle, bulletinHTML,
							enableVote, voteOption,
							publishTo, modiManID, modiManName, modiTime,	createrID, creater)
		select @newBulletinID, bulletinTime, bulletinTitle, bulletinHTML,
							enableVote, voteOption,
							publishTo, @modiManID, @modiManName, @updateTime, @modiManID, @modiManName
		from bulletinInfo
		where bulletinID = @bulletinID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		
		insert bulletinAttachment(bulletinID, aFilename, uidFilename, fileSize, fileType, uploadTime)
		select @newBulletinID, aFilename, uidFilename, fileSize, fileType, uploadTime
		from bulletinAttachment
		where bulletinID = @bulletinID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
	commit tran
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '��¡����', '�û�' + @modiManName 
												+ '��¡����['+ @bulletinID +']Ϊ['+@newBulletinID+']��')
GO
--����:
declare @updateTime smalldatetime--����ʱ��
declare @Ret		int		--�����ɹ���ʶ
declare @newBulletinID char(12)--��������¡�Ĺ����ţ�ʹ�õ� 10010 �ź��뷢��������
exec dbo.cloneBulletinInfo '201307180001','G201300040', @updateTime output, @Ret output, @newBulletinID output
select @updateTime, @Ret, @newBulletinID

select * from bulletinInfo

drop PROCEDURE addBulletinAttachment
/*
	name:		1.1.addBulletinAttachment
	function:	��ӹ��渽��
				@bulletinID char(12),		--������
				@aFilename varchar(128),	--ԭʼ�ļ���
				@uidFilename varchar(128),	--UID�ļ���
				@fileSize bigint,			--�ļ��ߴ�
				@fileType varchar(10),		--�ļ�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
										0:�ɹ���1:ָ���Ĺ��治����,9��δ֪����
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE addBulletinAttachment
	@bulletinID char(12),		--������
	@aFilename varchar(128),	--ԭʼ�ļ���
	@uidFilename varchar(128),	--UID�ļ���
	@fileSize bigint,			--�ļ��ߴ�
	@fileType varchar(10),		--�ļ�����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	insert bulletinAttachment(bulletinID, aFilename, uidFilename, fileSize, fileType)
	values(@bulletinID, @aFilename, @uidFilename, @fileSize, @fileType)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE delBulletinAttachment
/*
	name:		delBulletinAttachment
	function:	1.2.ɾ��ָ������ָ��UID�ĸ���
	input: 
				@bulletinID char(12),		--������
				@uidFilename varchar(128),	--UID�ļ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:ָ���Ĺ��治����,2��ָ���ĸ��������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE delBulletinAttachment
	@bulletinID char(12),		--������
	@uidFilename varchar(128),	--UID�ļ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	--�ж�ָ���ĸ����Ƿ����
	set @count=(select count(*) from bulletinAttachment where bulletinID = @bulletinID and uidFilename = @uidFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 2
		return
	end

	delete bulletinAttachment where bulletinID = @bulletinID  and uidFilename = @uidFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE delBulletinAllAttachment
/*
	name:		delBulletinAllAttachment
	function:	1.3.ɾ��ָ�������ȫ������
	input: 
				@bulletinID char(12),		--������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:ָ���Ĺ��治����,9��δ֪����
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE delBulletinAllAttachment
	@bulletinID char(12),		--������
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--Ҫ�ų������������õĸ�����������Ҫ�ǿ��ǿ�¡����������
	delete bulletinAttachment where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE bulletinAttachmentIsExist
/*
	name:		bulletinAttachmentIsExist
	function:	1.4.���ָ��UID�ĸ������������ô���
				������Ҫ�ǿ��ǿ�¡�����и����ļ����ܱ�����������ã������ݿ�ɾ�����ٴμ�飬���δ��������ɾ���ϴ��ļ�
	input: 
				@uidFilename varchar(128),	--UID�ļ���
	output: 
				@Ret		int output		--�����õĴ�����0:δ���ã�>1:������
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE bulletinAttachmentIsExist
	@uidFilename varchar(128),	--UID�ļ���
	@Ret		int output		--�����õĴ�����0:δ���ã�>1:������
	WITH ENCRYPTION 
AS
	set @Ret=(select count(*) from bulletinAttachment where uidFilename = @uidFilename)	
GO


DROP PROCEDURE activeBulletinInfo
/*
	name:		activeBulletinInfo
	function:	2.����ָ���Ĺ��棬���Զ����������
	input: 
				@bulletinID char(12),			--������
				@autoCloseDate varchar(10),		--�Զ��ر�����
				@publishTo xml,					--���������Ķ�Ȩ�ޣ�����������xml��ʽ���
												--N'<root>'+
												--	'<user userID="G201300001" userCName="��Զ" />'+	--�������û�
												--	'<unit uCode="001001" uName="�칫��" />'+			--�����Ĳ���
												--	'<sysRole id="3" desc="���ع���Ա" />'+				--�����Ľ�ɫ
												--	'<exceptUser userID="G201300003" userCName="���" />'+			--������Ա
												--'</root>'	
				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ��治���ڣ�2:Ҫ�����Ĺ������ڱ����˱༭��3��Ҫ�����Ĺ����Ѿ��رգ�4:Ҫ�����Ĺ����Ѿ��Ƿ���״̬��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2013-6-21����ָ����������ӿ�
				modi by lw 2013-9-8���ӷ���״̬�͹ر�״̬�ж�
*/
create PROCEDURE activeBulletinInfo
	@bulletinID char(12),			--������
	@autoCloseDate varchar(10),		--�Զ��ر�����
	@publishTo xml,					--���������Ķ�Ȩ�ޣ�

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	declare @isClosed int	--�Ƿ�رգ�0->δ�رգ�1->�ѹر�
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���ر�״̬��
	if (@isClosed=1)
	begin
		set @Ret = 3
		return
	end
	--��鷢��״̬��
	if (@isActive=1)
	begin
		set @Ret = 4
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���Ĭ�Ϲر�ʱ�䣺���ݿͻ�Ҫ��ȥ���Զ��رչ���modi by lw 2013-09-08
	if (@autoCloseDate ='')
		set @autoCloseDate=null
		--set @autoCloseDate = convert(varchar(10), dateadd(day, 7, getdate()), 120)
	
	set @updateTime = getdate()
	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from bulletinInfo where isActive = 1),0) + 1
	update bulletinInfo
	set isActive = 1, activeDate = @updateTime,
		autoCloseDate = @autoCloseDate, publishTo = @publishTo,
		orderNum = @curMaxOrderNum,
		isClosed=0, closedTime=null,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

/*	--���ù����ö���
	declare @execRet int
	exec dbo.setBulletinToTop @bulletinID, @modiManID output, @execRet output
*/
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '��������', '�û�' + @modiManName 
												+ '�����˹���['+ @bulletinID +']��')
GO

update bulletinInfo
set onTop=0
select * from bulletinInfo where isActive=1

DROP PROCEDURE setOffBulletinInfo
/*
	name:		setOffBulletinInfo
	function:	3.����ָ���Ĺ���
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ��治���ڣ�2:Ҫ�����Ĺ������ڱ����˱༭��3��Ҫ�����Ĺ����Ѿ��رգ�4:Ҫ�����Ĺ����Ѿ���δ����״̬��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2013-9-8���ӷ���״̬�͹ر�״̬�ж�
*/
create PROCEDURE setOffBulletinInfo
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	declare @isClosed int	--�Ƿ�رգ�0->δ�رգ�1->�ѹر�
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���ر�״̬��
	if (@isClosed=1)
	begin
		set @Ret = 3
		return
	end
	--��鷢��״̬��
	if (@isActive=0)
	begin
		set @Ret = 4
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = -1, onTop=0,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '��������', '�û�' + @modiManName 
												+ '�����˹���['+ @bulletinID +']��')
GO

DROP PROCEDURE closeBulletinInfo
/*
	name:		closeBulletinInfo
	function:	3.1.�ر�ָ���Ĺ���
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�رյĹ��治���ڣ�2:Ҫ�رյĹ������ڱ����˱༭��3:Ҫ�رյĹ����Ѿ��ǹر�״̬��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE closeBulletinInfo
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	declare @isClosed int	--�Ƿ�رգ�0->δ�رգ�1->�ѹر�
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���ر�״̬��
	if (@isClosed=1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update bulletinInfo
	set isActive = 0, orderNum = -1,
		isClosed=1, closedTime=@updateTime, onTop=0,

		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�رչ���', '�û�' + @modiManName 
												+ '�ر��˹���['+ @bulletinID +']��')
GO

DROP PROCEDURE recallBulletinInfo
/*
	name:		recallBulletinInfo
	function:	3.2.��������ָ���Ĺ���
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�������õĹ��治���ڣ�2:Ҫ�������õĹ������ڱ����˱༭��3:Ҫ�������õĹ����Ѿ�������״̬��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE recallBulletinInfo
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	declare @isClosed int	--�Ƿ�رգ�0->δ�رգ�1->�ѹر�
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���ر�״̬��
	if (@isClosed=0)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = -1,
		isClosed=0, closedTime=null,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�������ù���', '�û�' + @modiManName 
												+ '���������˹���['+ @bulletinID +']��')
GO

drop PROCEDURE delBulletinInfo
/*
	name:		delBulletinInfo
	function:	4.ɾ��ָ���Ĺ���
	input: 
				@bulletinID char(12),			--������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1���ù��治���ڣ�2:Ҫɾ���Ĺ�����Ϣ��������������3:�ù����Ѿ�����,
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-24
	UpdateDate: modi by lw 2013-9-8���ӷ���״̬�ж�
*/
create PROCEDURE delBulletinInfo
	@bulletinID char(12),			--������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	declare @isClosed int	--�Ƿ�رգ�0->δ�رգ�1->�ѹر�
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鷢��״̬:
	if (@isActive <> 0)
	begin
		set @Ret = 3
		return
	end
	
	delete bulletinInfo where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ���˹���['+ @bulletinID +']��')

GO
--���ԣ�


DROP PROCEDURE updateBulletinInfo
/*
	name:		updateBulletinInfo
	function:	5.����ָ���Ĺ������ݻ����
	input: 
				@bulletinID char(12),			--������
				@bulletinTitle nvarchar(100),	--�������
				@bulletinTime varchar(10),		--��������
				@autoCloseDate varchar(10),		--�����Զ��ر�����
				@bulletinHTML nvarchar(max),	--��������
				@enableVote smallint,			--�Ƿ�����ͶƱ��0->����1->������
				@voteOption xml,				--ͶƱѡ��
												--N'<root>'+
												--	'<item ID="1" itemDesc="ͬ��" />'+
												--	'<item ID="2" itemDesc="��ͬ��" />'+
												--	'<item ID="3" itemDesc="��Ȩ" />'+
												--'</root>'	

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�޸ĵĹ��治���ڣ�2:Ҫ�޸ĵĹ������ڱ����˱༭��3:�ù����ѷ�����4:�ù����Ѿ��رգ�
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-24
	UpdateDate: modi by lw 2011-12-4���ӹ������ں��Զ��ر����ڲ���
				modi by lw 2013-6-21�����Ƿ�����ͶƱ�ӿ�
				modi by lw 2013-07-12����ͶƱѡ���趨
				modi by lw 2013-9-8���ӷ���״̬�͹ر�״̬�ж�
*/
create PROCEDURE updateBulletinInfo
	@bulletinID char(12),			--������
	@bulletinTitle nvarchar(100),	--�������
	@bulletinTime varchar(10),		--��������
	@autoCloseDate varchar(10),		--�����Զ��ر�����
	@bulletinHTML nvarchar(max),	--��������
	@enableVote smallint,			--�Ƿ�����ͶƱ��0->����1->������
	@voteOption xml,				--ͶƱѡ��

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	declare @isClosed int	--�Ƿ�رգ�0->δ�رգ�1->�ѹر�
	select @thisLockMan=isnull(lockManID,''), @isActive=isActive, @isClosed=isClosed 
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���ر�״̬��
	if (@isClosed=1)
	begin
		set @Ret = 4
		return
	end
	--��鷢��״̬:
	if (@isActive <> 0)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	if (@bulletinTime='')
		set @bulletinTime=CONVERT(varchar(10),@updateTime, 120)

	update bulletinInfo
	set bulletinTitle = @bulletinTitle, bulletinHTML = @bulletinHTML,
		bulletinTime = @bulletinTime, autoCloseDate = @autoCloseDate,
		enableVote = @enableVote, voteOption = @voteOption,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�޸Ĺ���', '�û�' + @modiManName 
												+ '�޸��˹���['+ @bulletinID +']��')
GO

select * from bulletinInfo where bulletinID='201310240004'
DROP PROCEDURE voteBulletin
/*
	name:		voteBulletin
	function:	6.ͶƱָ���Ĺ���
				ע�⣺�����̲����༭�������Ǽǹ�����־��ÿ����ֻ����ͶƱһ�Σ������ͶƱ�������ǰ���
	input: 
				@bulletinID char(12),			--������
				@voteResult smallint,			--��������ͶƱѡ��ID
				@voterID varchar(10),			--ͶƱ��ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ��治���ڣ�2:ָ���Ĺ��治�Ƿ���״̬
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-21
	UpdateDate: ���ӹ��淢��״̬��� modi by lw 2013-9-8
*/
create PROCEDURE voteBulletin
	@bulletinID char(12),			--������
	@voteResult smallint,			--��������0->��Ȩ��1->ͬ�⣬2->��ͬ��
	@voterID varchar(10),			--ͶƱ��ID
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�жϹ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鷢��״̬:
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	select @isActive=isActive
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@isActive <> 1)
	begin
		set @Ret = 2
		return
	end

	--ȡͶƱ�˵�������
	declare @voter nvarchar(30)	--ͶƱ��
	set @voter = isnull((select userCName from activeUsers where userID = @voterID),'')
	
	--ɾ�����ܴ��ڵ���ʷͶƱ�����
	begin tran
		delete bulletinVote where bulletinID = @bulletinID and voterID = @voterID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		insert bulletinVote(bulletinID, voterID, voter, voteResult)
		values(@bulletinID, @voterID, @voter, @voteResult)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0
GO


drop PROCEDURE addBulletinDiscuss
/*
	name:		addBulletinDiscuss
	function:	7.���ָ�����������
				ע�⣺�ô洢���̼��༭��
	input: 
				@bulletinID char(12),			--������
				@discussTitle nvarchar(100),	--���⣺��ʱδʹ��
				@discussHTML nvarchar(4000),	--����
				@discusserID varchar(10),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ��治���ڣ�2:ָ���Ĺ��治�Ƿ���״̬
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-21
	UpdateDate: ���ӹ��淢��״̬��� modi by lw 2013-9-8
*/
create PROCEDURE addBulletinDiscuss
	@bulletinID char(12),			--������
	@discussTitle nvarchar(100),	--���⣺��ʱδʹ��
	@discussHTML nvarchar(4000),	--����
	@discusserID varchar(10),		--������ID

	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�жϹ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	--��鷢��״̬:
	declare @isActive int	--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	select @isActive=isActive
	from bulletinInfo 
	where bulletinID = @bulletinID
	if (@isActive <> 0)
	begin
		set @Ret = 2
		return
	end

	--ȡ�����˵�������
	declare @discusser varchar(30)
	set @discusser = isnull((select userCName from activeUsers where userID = @discusserID),'')

	insert bulletinDiscuss(bulletinID, discussTitle, discussHTML, discusserID, discusser)
	values (@bulletinID, @discussTitle, @discussHTML, @discusserID, @discusser)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@discusserID, @discusser, GETDATE(), '��������', '�û�[' + @discusser + 
					']�Թ���['+@bulletinID+']������һ�����ۡ�')
GO
select * from bulletinDiscuss

drop PROCEDURE delBulletinDiscuss
/*
	name:		delBulletinDiscuss
	function:	8.ɾ��ָ���Ĺ�������
				ע�⣺�����̲����༭��
	input: 
				@bulletinID char(12),			--������
				@rowNum bigint,					--�ڲ��к�
				@delManID varchar(10),			--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1���ù������۲����ڣ�
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-21
	UpdateDate:
*/
create PROCEDURE delBulletinDiscuss
	@bulletinID char(12),			--������
	@rowNum bigint,					--�ڲ��к�
	@delManID varchar(10),			--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinDiscuss where bulletinID = @bulletinID and rowNum=@rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	delete bulletinDiscuss where bulletinID = @bulletinID and rowNum=@rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����������', '�û�' + @delManName
												+ 'ɾ���˹���['+ @bulletinID +']��һ�����ۡ�')

GO

drop PROCEDURE closeDieingBulletinInfo
/*
	name:		closeDieingBulletinInfo
	function:	9.�Զ��رյ��ڵĹ��棨��������Ǹ�ά���ƻ������ã��û����ð�װ��
	input: 
	output: 
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate:
*/
create PROCEDURE closeDieingBulletinInfo
	WITH ENCRYPTION 
AS
	declare @count as int
	set @count=(select count(*) from bulletinInfo 
		where isActive =1 and autoCloseDate is not null and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120))	
	if (@count = 0)	--������
	begin
		return
	end

	declare @updateTime smalldatetime
	set @updateTime=GETDATE()
	update bulletinInfo
	set isActive = 0, orderNum = -1,
		isClosed=1, closedTime=@updateTime, onTop=0
	where isActive =1 and autoCloseDate is not null and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120)

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('', 'System', @updateTime, '�Զ��رյ��ڹ���', 'ϵͳִ�����Զ��رյ��ڹ���ļƻ��ر���'+cast(@count as varchar(10))+'�����ڵĹ��档')
GO
--���ԣ�
exec dbo.closeDieingBulletinInfo
select * from bulletinInfo where isActive =1
update bulletinInfo
set autoCloseDate = getdate()
where bulletinID='201111260001'


DROP PROCEDURE setBulletinToTop
/*
	name:		setBulletinToTop
	function:	10.��ָ���Ĺ����ö�
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ö��Ĺ��治���ڣ�2:Ҫ�ö��Ĺ������ڱ����˱༭��3.�ù���δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE setBulletinToTop
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��鹫��״̬:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ѷ����Ĺ�����������
	declare @tab table
					(
						bulletinID char(12) not null,			--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
						orderNum smallint default(-1)			--��ʾ�����
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and bulletinID <> @bulletinID
	order by orderNum
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--��ָ���Ĺ����ö���	
		update bulletinInfo
		set orderNum = 0,onTop=1
		where bulletinID = @bulletinID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '�����ö�', '�û�' + @modiManName 
												+ '������['+ @bulletinID +']�ö���')
GO
--���ԣ�
select * from bulletinInfo
declare @Ret int 
exec dbo.setBulletinToTop '201111260001', '00200977', @Ret output

DROP PROCEDURE closeBulletinOnTop
/*
	name:		closeBulletinOnTop
	function:	10.1.����ָ��������ö�
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ö��Ĺ��治���ڣ�2:Ҫ�����ö��Ĺ������ڱ����˱༭��3.�ù���δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-9-8
	UpdateDate: 
*/
create PROCEDURE closeBulletinOnTop
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��鹫��״̬:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	update bulletinInfo
	set onTop=0
	where bulletinID = @bulletinID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '���������ö�', '�û�' + @modiManName 
												+ '�����˹���['+ @bulletinID +']�ö���')
GO
--���ԣ�
select * from bulletinInfo
declare @Ret int 
exec dbo.closeBulletinOnTop '201111260001', '00200977', @Ret output

DROP PROCEDURE setBulletinToFirst
/*
	name:		setBulletinToFirst
	function:	10.2.��ָ���Ĺ�������Ϊ������ʾ���������ö����棩
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���õĹ��治���ڣ�2:Ҫ���õĹ������ڱ����˱༭��3.�ù���δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: ���ö���������ʾ���ܷ���������� modi by lw 2013-9-8
*/
create PROCEDURE setBulletinToFirst
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��鹫��״̬:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ѷ����Ĺ�����������
	declare @tab table
					(
						bulletinID char(12) not null,			--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
						orderNum smallint default(-1)			--��ʾ�����
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and bulletinID <> @bulletinID
	order by orderNum
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--��ָ���Ĺ����ö���	
		update bulletinInfo
		set orderNum = 0
		where bulletinID = @bulletinID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '�����ƶ�������', '�û�' + @modiManName 
												+ '������['+ @bulletinID +']�ƶ������С�')
GO
--���ԣ�
select * from bulletinInfo
declare @Ret int 
exec dbo.setBulletinToFirst '201111260001', '00200977', @Ret output

DROP PROCEDURE setBulletinToLast
/*
	name:		setBulletinToLast
	function:	11.��ָ���Ŀ���ʾ��������һ��
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ��Ĺ��治���ڣ�2:Ҫ�ƶ��Ĺ������ڱ����˱༭��3.�ù���δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE setBulletinToLast
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int
	declare @myOrderNum smallint --������������
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive, @myOrderNum = orderNum from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��鹫��״̬:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ѷ�����λ���ڱ�����ǰ��Ĺ�����������
	declare @tab table
					(
						bulletinID char(12) not null,			--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
						orderNum smallint default(-1)			--��ʾ�����
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and orderNum < @myOrderNum
	order by orderNum
	
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--��ָ���Ĺ�������һ�У�	
		update bulletinInfo
		set orderNum = @i
		where bulletinID = @bID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update bulletinInfo
		set orderNum = @i - 1
		where bulletinID = @bulletinID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '��������һ��', '�û�' + @modiManName 
												+ '������['+ @bulletinID +']������һ�С�')
GO
--���ԣ�
select * from bulletinInfo 
where isActive =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToLast '201111270001', '00200977', @Ret output

DROP PROCEDURE setBulletinToNext
/*
	name:		setBulletinToNext
	function:	12.��ָ���Ŀ���ʾ��������һ��
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ��Ĺ��治���ڣ�2:Ҫ�ƶ��Ĺ������ڱ����˱༭��3.�ù���δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE setBulletinToNext
	@bulletinID char(12),			--������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isActive int
	declare @myOrderNum smallint --������������
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive, @myOrderNum = orderNum from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��鹫��״̬:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--������������һ�����潻��λ�ã�
	declare @nextBulletinID char(12), @nextOrderNum smallint
	select top 1 @nextBulletinID = bulletinID, @nextOrderNum = orderNum 
	from bulletinInfo 
	where isActive =1 and orderNum > @myOrderNum
	order by orderNum
	
	if (@nextBulletinID is not null)
	begin
		begin tran
			update bulletinInfo 
			set orderNum = @nextOrderNum
			where bulletinID = @bulletinID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update bulletinInfo 
			set orderNum = @myOrderNum
			where bulletinID = @nextBulletinID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran
	end
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '��������һ��', '�û�' + @modiManName 
												+ '������['+ @bulletinID +']������һ�С�')
GO
--���ԣ�
select * from bulletinInfo 
where isActive =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToNext '201111270001', '00200977', @Ret output

drop PROCEDURE queryBulletinLocMan
/*
	name:		queryBulletinLocMan
	function:	13.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@bulletinID char(12),			--�����,ʹ��10010�ź��뷢��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ĺ��治����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE queryBulletinLocMan
	@bulletinID char(12),			--�����,ʹ��10010�ź��뷢��������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	set @Ret = 0
GO


drop PROCEDURE lockBulletin4Edit
/*
	name:		lockBulletin4Edit
	function:	14.�������濪ʼ�༭������༭��ͻ
	input: 
				@bulletinID char(12),			--�����,ʹ��10010�ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ��治���ڣ�2:Ҫ�����Ĺ������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE lockBulletin4Edit
	@bulletinID char(12),			--�����,ʹ��10010�ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	update bulletinInfo
	set lockManID = @lockManID 
	where bulletinID = @bulletinID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '��������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˹���['+ @bulletinID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockBulletinEditor
/*
	name:		unlockBulletinEditor
	function:	15.�ͷŹ���༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@bulletinID char(12),			--�����,ʹ��10010�ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE unlockBulletinEditor
	@bulletinID char(12),			--�����,ʹ��10010�ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update bulletinInfo set lockManID = '' where bulletinID = @bulletinID
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷŹ���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˹���['+ @bulletinID +']�ı༭����')
GO

drop PROCEDURE addResource
/*
	name:		20.addResource
	function:	�����Դ�ļ�
				ע�⣺�ô洢���̲��Ǽǹ�����־
	input: 
				@resouceName nvarchar(30),	--��Դ����
				@resouceType smallint,		--��Դ���ͣ�1->ͼƬ��2->Ӱ���ļ�
				@oldFilename varchar(128),	--��Դ�ļ�ԭʼ�ļ���
				@extFileName varchar(8),	--��Դ�ļ��ļ���չ��
				@notes nvarchar(100),		--˵��
				@ownerID varchar(10),		--�����˹���
				@isShare char(1),			--�Ƿ���
	output: 
				@Ret		int output,	--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
				@fileGUID36 varchar(36) output	--ϵͳ�������Դ�ļ�36λȫ��Ψһ�����ļ���
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE addResource
	@resouceName nvarchar(30),	--��Դ����
	@resouceType smallint,		--��Դ���ͣ�1->ͼƬ��2->Ӱ���ļ�
	@oldFilename varchar(128),	--��Դ�ļ�ԭʼ�ļ���
	@extFileName varchar(8),	--��Դ�ļ��ļ���չ��
	@notes nvarchar(100),		--˵��
	@ownerID varchar(10),		--�����˹���
	@isShare char(1),			--�Ƿ���

	@Ret int output,			--�����ɹ���ʶ
	@fileGUID36 varchar(36) output	--ϵͳ�������Դ�ļ�36λȫ��Ψһ�����ļ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--ȡ������������
	declare @ownerName varchar(30)		--����������
	set @ownerName = isnull((select userCName from activeUsers where userID = @ownerID),'')

	--����Ψһ���ļ�����
	set @fileGUID36 = (select newid())

	--�Ǽ���Դ��Ϣ��
	insert bulletinResouce(resouceName, resouceType, fileGUID36, oldFilename, extFileName,
							notes, ownerID, ownerName, isShare)
	values(@resouceName, @resouceType, @fileGUID36, @oldFilename, @extFileName,
							@notes, @ownerID, @ownerName, @isShare)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0
GO


drop PROCEDURE delResource
/*
	name:		delResource
	function:	21.ɾ��ָ������Դ�ļ�
				ע�⣺�ô洢���̲��Ǽǹ�����־��Ҳ��ɾ���ļ���
	input: 
				@fileGUID36 varchar(36),	--��Դ�ļ�����
				@delManID varchar(10),		--ɾ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-27
	UpdateDate: 

*/
create PROCEDURE delResource
	@fileGUID36 varchar(36),	--��Դ�ļ�����
	@delManID varchar(10),		--ɾ����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete bulletinResouce where fileGUID36 = @fileGUID36
	set @Ret = 0
GO

