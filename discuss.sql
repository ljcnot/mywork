use PM100
/*
	������ϵͳ--��̳����
	��ע����ֲ�Թ�˾��վ--��̳����
	author:	¬�γ�
	CreateDate:	2013-8-25
	UpdateDate: 
*/
--1.��̳����
select * from discussSection

drop table discussSection
create table discussSection
(
	sectionID varchar(12) not null,		--����������ţ��ɵ�20�ź��뷢����
	sectionType int default(1),			--������1->������̳��2->��Ʒ��̳
	sectionName nvarchar(30) not null,	--������ƣ���Ʒ���ƣ�
	sectionDesc  nvarchar(300) null,	--�����ܣ���Ʒ��飩
	sectionLogo varchar(128) null,		--���logo
	sectionManagerID varchar(12) null,	--����ID
	sectionManager nvarchar(30) not null,--��������
	isClosed smallint default(1),		--�Ƿ�رգ�0->������1->�ر�
	closeDate smalldatetime default(getdate()),		--�ر�����

	--����ά�����:
	createDate smalldatetime default(getdate()),	--��������
	createrID varchar(10) null,			--������ID
	creater nvarchar(30) null,			--����������
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10)				--��ǰ���������༭���˹���
 CONSTRAINT [PK_discussSection] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select 	sectionID, sectionType, sectionName, sectionDesc, isnull(sectionLogo,''),
	sectionManagerID, sectionManager,convert(varchar(19),createTime,120) createTime,
	isClosed, convert(varchar(19),isnull(closeDate,''),120) closeDate,
	--����ά�����:
	convert(varchar(19),createDate,120) createDate,createrID,creater,
	modiManID, modiManName, convert(varchar(19),isnull(modiTime,''),120) modiTime,
	--�༭�����ˣ�
	isnull(lockManID,'')
from discussSection

--2.��̳��������ӣ���
drop table discussTopic
create table discussTopic
(
	sectionID varchar(12) not null,		--���/�����������
	topicID varchar(13) not null,		--�����������ţ��ɵ�21�ź��뷢��������
	title nvarchar(100)not null,		--����
	topicDesc nvarchar(4000) null,		--��������
	authorID varchar(12) null,			--����ID
	author nvarchar(30) null,			--����
	createDate smalldatetime default(getdate()),	--��������
	viewNum int null,					--�鿴����
	isBoutique int null,				--�Ƿ񾫻��� 0-->����  1-->��
	sequence int null,                  --����
	isTop int default(0),				--�Ƿ��ö���0->���ö���1->�ö�
	isRecommend int default(0),			--�Ƿ��Ƽ���0->��ͨ��1->�Ƽ�
	
 CONSTRAINT [PK_discussTopic] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC,
	[topicID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[discussTopic] WITH CHECK ADD CONSTRAINT [FK_discussTopic_discussSection] FOREIGN KEY([sectionID])
REFERENCES [dbo].[discussSection] ([sectionID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussTopic] CHECK CONSTRAINT [FK_discussTopic_discussSection]
GO
--������
CREATE NONCLUSTERED INDEX [IX_discussTopic] ON [dbo].[discussTopic]
(
	[sequence] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_discussTopic_1] ON [dbo].[discussTopic] 
(
	[authorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from discussTopic
select sectionID, topicID, rowNum, replyContent, replyTime, authorID, authorName
from discussReply


select * from discussReply
--3.��̳�������������ظ�����
drop table discussReply
create table discussReply
(
	sectionID varchar(12) not null,		--���/�����������
	topicID varchar(13) not null,		--���/������������
	replyID varchar(16) not null,		--�������ظ����
	replyContent nvarchar(4000) null,	--����
	replyTime datetime default(getdate()),--����ʱ��
	authorID varchar(10) null,			--������ID
	authorName varchar(30) null,		--����������
CONSTRAINT [PK_discussReply] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC,
	[topicID] ASC,
	[replyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[discussReply] WITH CHECK ADD CONSTRAINT [FK_discussReply_discussTopic] FOREIGN KEY([sectionID],[topicID])
REFERENCES [dbo].[discussTopic] ([sectionID],[topicID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussReply] CHECK CONSTRAINT [FK_discussReply_discussTopic]
GO


--4.��̳��顢���⣨���ӣ����������ظ���������
drop table discussAttach
create table discussAttach
(
	sectionID varchar(12) not null,		--���/�����������
	topicID varchar(13) default(''),	--���/������������
	replyID varchar(16) default(''),	--���/�������ظ����
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--����:�к�
	aFilename varchar(128) null,		--ԭʼ�ļ���
	uidFilename varchar(128) not null,	--UID�ļ���
	title nvarchar(32) null,			--����
	fileSize bigint null,				--�ļ��ߴ�
	fileType varchar(10),				--�ļ�����
	uploadTime smalldatetime default(getdate()),	--�ϴ�����
	fileLog varchar(128) null,			--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG
 CONSTRAINT [PK_discussAttach] PRIMARY KEY CLUSTERED 
(
	[sectionID] ASC,
	[topicID] ASC,
	[replyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[discussAttach]  WITH CHECK ADD  CONSTRAINT [FK_discussAttach_discussSection] FOREIGN KEY([sectionID])
REFERENCES [dbo].[discussSection] ([sectionID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussAttach] CHECK CONSTRAINT [FK_discussAttach_discussSection]
GO



select * from discussAttach
--5.������Ҫ�Ĳ�ѯ��ͼ��
--��̳���ſ���ͼ(�����Ϣ+���⣨���ӣ���+�ظ���+���·���+���շ���)��
drop view discussOverview
create view discussOverview
as
	select ds.isClosed, isnull(convert(varchar(19),ds.closeDate,120),'') closeDate, ds.sectionID, ds.sectionName,ds.sectionType, ds.sectionDesc, 
		ds.sectionLogo, ds.sectionManagerID,ds.sectionManager, 
		convert(varchar(19),ds.createDate,120) createDate, 
		--ͳ�ƣ����⣨���ӣ��������ظ�����
		isnull(t.topics,0) topics, isnull(r.replys,0) replys,
		--���»ظ���
		isnull(dr.topicID,'') topicID, isnull(dr.replyID,'') replyID,isnull(dr.replyContent,'') replyContent, 
		isnull(convert(varchar(19),dr.replyTime,120),'') replyTime, isnull(dr.authorID,'') authorID, isnull(dr.authorName,'') authorName, 
		--���ջظ�������
		isnull(dc.dCount,0) dCount,
		--������
		dbo.getDiscussAttach(ds.sectionID,'','') attachMent
	from discussSection ds left join (select sectionID, count(*) topics from discussTopic group by sectionID) t on ds.sectionID= t.sectionID
	left join (select sectionID, count(*) replys from discussReply group by sectionID) r on ds.sectionID= r.sectionID
	left join (select d.sectionID, d.topicID, d.replyID, d.replyContent, d.replyTime, d.authorID, d.authorName
				from discussReply d right join 
					(select sectionID, max(replyID) rowNum
					 from discussReply
					 group by sectionID) m on d.replyID=m.rowNum) dr on ds.sectionID = dr.sectionID
	left join (select sectionID, count(*) dCount from discussReply
				where convert(varchar(10),replyTime,120)=CONVERT(varchar(10),getdate(),120)
				group by sectionID) dc on ds.sectionID = dc.sectionID
go

select * from discussOverview

--��̳�������ſ������⣨���ӣ���Ϣ+���»ظ�+���ջ�����+��������ͼ��
drop view discussTopicOverview
create view discussTopicOverview
as
	select dt.sectionID, ds.sectionName,ds.sectionManager,dt.topicID, dt.title, dt.topicDesc, 
			convert(varchar(10),dt.createDate,120) createDate,dt.authorID, dt.author,
			dt.viewNum,isnull(r.replyNum,0) replyNum, dt.isBoutique, dt.sequence,
			dt.isTop, dt.isRecommend,
			--���»ظ���
			isnull(dr.replyID,'') replyID, isnull(dr.replyContent,'') replyContent, 
			isnull(convert(varchar(19),dr.replyTime,120),'') replyTime, 
			isnull(dr.authorID,'') replyAuthorID, isnull(dr.authorName,'') replyAuthorName,
			--���ջظ�������
			isnull(dc.dCount,0) dCount,
			--������
			dbo.getDiscussAttach(dt.sectionID,dt.topicID,'') attachMent
	from discussTopic dt
	left join (select d.sectionID, d.topicID, d.replyID, d.replyContent, d.replyTime, d.authorID, d.authorName
				from discussReply d right join 
					(select sectionID, topicID, max(replyID) rowNum
					from discussReply
					group by sectionID, topicID) m on d.replyID=m.rowNum) dr on dt.sectionID = dr.sectionID and dt.topicID=dr.topicID
	left join (select sectionID,sectionName,sectionManager from discussSection) ds on dt.sectionID=ds.sectionID
	left join (select topicID, count(*) replyNum from discussReply group by topicID) r on dt.topicID= r.topicID
	left join (select topicID, count(*) dCount from discussReply
				where convert(varchar(10),replyTime,120)=CONVERT(varchar(10),getdate(),120)
				group by topicID) dc on dt.topicID= dc.topicID
go

select * from discussTopicOverview

drop procedure addDiscussSection
/*
	name:		addDiscussSection
	function:	1.�����̳���
				ע�⣺�ô洢���̲�������̳
	input: 
				@sectionType int,			--������1->������̳��2->��Ʒ��̳
				@sectionName nvarchar(30),	--������ƣ���Ʒ���ƣ�
				@sectionDesc nvarchar(300),	--�����ܣ���Ʒ��飩
				@sectionLogo varchar(128),	--���logo
				@sectionManagerID varchar(12),	--����ID

				--����ά�����:
				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output,			--�����ɹ���ʶ
												0:�ɹ���9:δ֪����
				@sectionID varchar(12) output,	--�����
	author:		¬έ
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create procedure addDiscussSection
	@sectionType int,			--������1->������̳��2->��Ʒ��̳
	@sectionName nvarchar(30),	--�������
	@sectionDesc nvarchar(300),	--������
	@sectionLogo varchar(128),	--���logo
	@sectionManagerID varchar(12),	--����ID

	--����ά�����:
	@createManID varchar(10),		--�����˹���
	
	@Ret		int output,			--�����ɹ���ʶ
	@sectionID varchar(12) output	--�����
as
begin
	set @Ret = 9
	--��20�ź��뷢������ȡsectionID
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 20, 1, @curNumber output
	set @sectionID = @curNumber

	--ȡ����\������������
	declare @sectionManager nvarchar(30),@createManName nvarchar(30)
	set @sectionManager = isnull((select cName from userInfo where userID = @sectionManagerID),'')
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')
		
	declare @createTime smalldatetime
	set @createTime = getdate()
	insert into discussSection(sectionID, sectionType, sectionName, sectionDesc, sectionLogo, 
				sectionManagerID, sectionManager, 
				--����ά�����:
				createDate, createrID, creater, modiManID, modiManName, modiTime)
	values(@sectionID, @sectionType, @sectionName, @sectionDesc, @sectionLogo, 
			@sectionManagerID, @sectionManager, 
			--����ά�����:
			@createTime, @createManID, @createManName, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'�����̳���','ϵͳ����' + @createManName + 
								'��Ҫ���������̳���[' + @sectionName + ']����Ϣ��')
end
--���ԣ�
declare @Ret int, @sectionID varchar(12)
exec dbo.addDiscussSection 1,'�ѵ��칫ϵͳ��������ƽ̨-�������',
'�ѵ��칫ϵͳ��������ƽ̨ �����ҹ�˾�����ġ��豸����ϵͳ��������ó��ͬ����ϵͳ������ʵ����OA�칫ϵͳ���Ȱ칫ϵͳ������ͳһ�ӿڣ����¹滮�����֯���������û�������ǿ �ͻ���ϵ�������¹������������������������Ȱ�ϵͳ��һ���װ칫ϵͳ���õķ��񼯡����ṩ�����Ŀ����ӿ��ֲ��һ��һ����Step By Step���̡̳�
������ƽ̨��ľʽ�Ķѵ���������󽵵���web�칫ϵͳ�Ŀ����Ѷȣ������˿���ʱ�䣬��Լ�˿������á�
����������Ǹ�ƽ̨�����ƻ��е����˼·����������ӭ����ڴ����۱��ƻ������˼·��',
'images/productdeveloping_new.gif','U201510004','U201510004', @Ret output, @sectionID output
select @Ret, @sectionID

select * from discussSection
update discussSection
set sectionName='�ѵ��칫ϵͳ��������ƽ̨-�������'
where sectionid='S20151105005'

declare @Ret int, @sectionID varchar(12)
exec dbo.addDiscussSection 1,'�ѵ��칫ϵͳ��������ƽ̨-���ȼල',
'�ѵ��칫ϵͳ��������ƽ̨ �����ҹ�˾�����ġ��豸����ϵͳ��������ó��ͬ����ϵͳ������ʵ����OA�칫ϵͳ���Ȱ칫ϵͳ������ͳһ�ӿڣ����¹滮�����֯���������û�������ǿ �ͻ���ϵ�������¹������������������������Ȱ�ϵͳ��һ���װ칫ϵͳ���õķ��񼯡����ṩ�����Ŀ����ӿ��ֲ��һ��һ����Step By Step���̡̳�
������ƽ̨��ľʽ�Ķѵ���������󽵵���web�칫ϵͳ�Ŀ����Ѷȣ������˿���ʱ�䣬��Լ�˿������á�
����������Ǹ�ƽ̨�����ƻ��еĽ��ȼල����������ӭ����ڴ����۱��ƻ���ʵʩ���⡣',
'images/bbsbig.jpg','U201510004','U201510004', @Ret output, @sectionID output
select @Ret, @sectionID

declare @Ret int, @sectionID varchar(12)
exec dbo.addDiscussSection 1,'�ѵ��칫ϵͳ��������ƽ̨-ǰ̨������������',
'�ѵ��칫ϵͳ��������ƽ̨ �����ҹ�˾�����ġ��豸����ϵͳ��������ó��ͬ����ϵͳ������ʵ����OA�칫ϵͳ���Ȱ칫ϵͳ������ͳһ�ӿڣ����¹滮�����֯���������û�������ǿ �ͻ���ϵ�������¹������������������������Ȱ�ϵͳ��һ���װ칫ϵͳ���õķ��񼯡����ṩ�����Ŀ����ӿ��ֲ��һ��һ����Step By Step���̡̳�
������ƽ̨��ľʽ�Ķѵ���������󽵵���web�칫ϵͳ�Ŀ����Ѷȣ������˿���ʱ�䣬��Լ�˿������á�
����������Ǹ�ƽ̨��ǰ̨������������������ӭ����ڴ����۱�ƽ̨ǰ̨�������⡣',
'images/webDeveloping.jpg','U201510004','U201510004', @Ret output, @sectionID output
select @Ret, @sectionID

select * from userInfo

delete discussSection
select * from discussSection
select * from workNote
  
 
drop PROCEDURE queryDiscussSectionLocMan
/*
	name:		queryDiscussSectionLocMan
	function:	2.��ѯָ������Ƿ��������ڱ༭
	input: 
				@sectionID varchar(12),		--�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���İ�鲻����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2015-11-1
	UpdateDate: 
*/
create PROCEDURE queryDiscussSectionLocMan
	@sectionID varchar(12),		--�����
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	set @Ret = 0
GO


drop PROCEDURE lockDiscussSection4Edit
/*
	name:		lockDiscussSection4Edit
	function:	3.�������༭������༭��ͻ
	input: 
				@sectionID varchar(12),			--�����
				@lockManID varchar(10) output,	--�����ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�����İ�鲻���ڣ�2:Ҫ�����İ�����ڱ����˱༭��
												9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-1
	UpdateDate: 
*/
create PROCEDURE lockDiscussSection4Edit
	@sectionID varchar(12),			--�����
	@lockManID varchar(10) output,	--�����ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����İ���Ƿ����
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update discussSection
	set lockManID = @lockManID 
	where sectionID = @sectionID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������Ϊ��[' + @sectionID + ']�İ��Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockDiscussSectionEditor
/*
	name:		unlockDiscussSectionEditor
	function:	4.�ͷŰ��༭��
				ע�⣺�����̲�������Ƿ���ڣ�
	input: 
				@sectionID varchar(12),			--�����
				@lockManID varchar(10) output,	--�����ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-1
	UpdateDate: 
*/
create PROCEDURE unlockDiscussSectionEditor
	@sectionID varchar(12),			--�����
	@lockManID varchar(10) output,	--�����ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update discussSection set lockManID = '' where sectionID = @sectionID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŰ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˱��Ϊ��[' + @sectionID + ']�İ��ı༭����')
GO

drop PROCEDURE delDiscussSection
/*
	name:		delDiscussSection
	function:	5.ɾ��ָ������̳���
	input: 
				@sectionID varchar(12),			--�����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��ָ���İ�鲻���ڣ�2��Ҫɾ���İ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create PROCEDURE delDiscussSection
	@sectionID varchar(12),			--�����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���İ���Ƿ����
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete discussSection where sectionID = @sectionID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ�����', '�û�' + @delManName
												+ 'ɾ���˱��Ϊ��[' + @sectionID + ']�İ�顣')
GO

drop procedure updateDiscussSection
/*
	name:		updateDiscussSection
	function:	6.������̳���
	input: 
				@sectionID varchar(12),		--�����
				@sectionType int,			--������1->������̳��2->��Ʒ��̳
				@sectionName nvarchar(30),	--������ƣ���Ʒ���ƣ�
				@sectionDesc nvarchar(300),	--�����ܣ���Ʒ��飩
				@sectionLogo varchar(128),	--���logo
				@sectionManagerID varchar(12),	--����ID

				--����ά�����:
				@modiManID varchar(10) output,	--ά���˹��ţ�����ɱ���ռ�ã��򷵻�ռ���˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1:�ð�鲻���ڣ�2���ð���������������༭��9:δ֪����
	author:		¬έ
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create procedure updateDiscussSection
	@sectionID varchar(12),		--�����
	@sectionType int,			--������1->������̳��2->��Ʒ��̳
	@sectionName nvarchar(30),	--�������
	@sectionDesc nvarchar(300),	--������
	@sectionLogo varchar(128),	--���logo
	@sectionManagerID varchar(12),	--����ID

	--����ά�����:
	@modiManID varchar(10) output,	--ά���˹���
	@Ret		int output			--�����ɹ���ʶ
as
begin
	set @Ret = 9

	--�ж�ָ���İ���Ƿ����
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡ����\ά����������
	declare @sectionManager nvarchar(30),@modiManName nvarchar(30)
	set @sectionManager = isnull((select cName from userInfo where userID = @sectionManagerID),'')
	set @modiManName = isnull((select cName from userInfo where userID = modiManID),'')
		
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update discussSection
	set sectionType = @sectionType, 
		sectionName = @sectionName, 
		sectionDesc = @sectionDesc, 
		sectionLogo = @sectionLogo, 
		sectionManagerID = @sectionManagerID, 
		sectionManager = @sectionManager, 
		--����ά�����:
		modiManID = @modiManID, 
		modiManName = @modiManName, 
		modiTime = @updateTime
	where sectionID= @sectionID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 
								'�޸���̳���','ϵͳ����' + @modiManName + 
								'��Ҫ���޸�����̳���[' + @sectionID + ']����Ϣ��')
end
--���ԣ�

drop procedure changeDiscussSectionManager
/*
	name:		changeDiscussSectionManager
	function:	6.1.��������
	input: 
				@sectionID varchar(12),		--�����
				@sectionManagerID varchar(12),	--����ID

				--����ά�����:
				@modiManID varchar(10) output,	--ά���˹��ţ�����ɱ���ռ�ã��򷵻�ռ���˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1:�ð�鲻���ڣ�2���ð���������������༭��9:δ֪����
	author:		¬έ
	CreateDate:	2015-11-1
	UpdateDate: 

*/
create procedure changeDiscussSectionManager
	@sectionID varchar(12),		--�����
	@sectionManagerID varchar(12),	--����ID

	--����ά�����:
	@modiManID varchar(10) output,	--ά���˹���
	@Ret		int output			--�����ɹ���ʶ
as
begin
	set @Ret = 9

	--�ж�ָ���İ���Ƿ����
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡ����\ά����������
	declare @sectionManager nvarchar(30),@modiManName nvarchar(30)
	set @sectionManager = isnull((select cName from userInfo where userID = @sectionManagerID),'')
	set @modiManName = isnull((select cName from userInfo where userID = modiManID),'')
		
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update discussSection
	set sectionManagerID = @sectionManagerID, 
		sectionManager = @sectionManager, 
		--����ά�����:
		modiManID = @modiManID, 
		modiManName = @modiManName, 
		modiTime = @updateTime
	where sectionID= @sectionID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 
								'��������','ϵͳ����' + @modiManName + 
								'��Ҫ������˰��[' + @sectionID + ']�İ�����')
end

drop procedure changeDiscussSectionLogo
/*
	name:		changeDiscussSectionLogo
	function:	6.2.�������ͼ��
	input: 
				@sectionID varchar(12),		--�����
				@sectionLogo varchar(128),	--���logo

				--����ά�����:
				@modiManID varchar(10) output,	--ά���˹��ţ�����ɱ���ռ�ã��򷵻�ռ���˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1:�ð�鲻���ڣ�2���ð���������������༭��9:δ֪����
	author:		¬έ
	CreateDate:	2015-11-14
	UpdateDate: 

*/
create procedure changeDiscussSectionLogo
	@sectionID varchar(12),		--�����
	@sectionLogo varchar(128),	--���logo

	--����ά�����:
	@modiManID varchar(10) output,	--ά���˹���
	@Ret		int output			--�����ɹ���ʶ
as
begin
	set @Ret = 9

	--�ж�ָ���İ���Ƿ����
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡ����\ά����������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select cName from userInfo where userID = modiManID),'')
		
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update discussSection
	set sectionLogo = @sectionLogo,
		--����ά�����:
		modiManID = @modiManID, 
		modiManName = @modiManName, 
		modiTime = @updateTime
	where sectionID= @sectionID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 
								'�������ͼ��','ϵͳ����' + @modiManName + 
								'��Ҫ������˰��[' + @sectionID + ']��ͼ�ꡣ')
end

drop PROCEDURE closeDiscussSection
/*
	name:		closeDiscussSection
	function:	7.�ر�ָ������̳���
	input: 
				@sectionID varchar(12),			--�����
				@closeManID varchar(10) output,	--�ر��ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��ָ���İ�鲻���ڣ�2��Ҫ�رյİ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-4
	UpdateDate: 

*/
create PROCEDURE closeDiscussSection
	@sectionID varchar(12),			--�����
	@closeManID varchar(10) output,	--�ر��ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���İ���Ƿ����
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @closeManID)
	begin
		set @closeManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @closeManName nvarchar(30)
	set @closeManName = isnull((select userCName from activeUsers where userID = @closeManID),'')

	declare @closeDate smalldatetime
	set @closeDate = getdate()
	update discussSection 
	set isClosed = 1, closeDate = @closeDate,
		--����ά�����:
		modiManID = @closeManID, 
		modiManName = @closeManName, 
		modiTime = @closeDate
	where sectionID = @sectionID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@closeManID, @closeManName, @closeDate, '�رհ��', '�û�' + @closeManName
												+ '�ر��˱��Ϊ��[' + @sectionID + ']�İ�顣')
GO

drop PROCEDURE openDiscussSection
/*
	name:		openDiscussSection
	function:	7.����ָ������̳���
	input: 
				@sectionID varchar(12),			--�����
				@openManID varchar(10) output,	--�����ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��ָ���İ�鲻���ڣ�2��Ҫ���ŵİ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-4
	UpdateDate: 

*/
create PROCEDURE openDiscussSection
	@sectionID varchar(12),			--�����
	@openManID varchar(10) output,	--�����ˣ������ǰ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���İ���Ƿ����
	declare @count as int
	set @count=(select count(*) from discussSection where sectionID = @sectionID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @openManID)
	begin
		set @openManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @openManName nvarchar(30)
	set @openManName = isnull((select userCName from activeUsers where userID = @openManID),'')

	declare @openDate smalldatetime
	set @openDate = getdate()
	update discussSection 
	set isClosed = 0, closeDate = null,
		--����ά�����:
		modiManID = @openManID, 
		modiManName = @openManName, 
		modiTime = @openDate
	where sectionID = @sectionID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@openManID, @openManName, @openDate, '���Ű��', '�û�' + @openManName
												+ '�����˱��Ϊ��[' + @sectionID + ']�İ�顣')
GO

drop PROCEDURE addDiscussAttachment
/*
	name:		8.addDiscussAttachment
	function:	��Ӹ���
				@sectionID varchar(12),		--�����
				@topicID varchar(13),		--������
				@replyID varchar(16),		--�����к�
				@aFilename varchar(128),	--ԭʼ�ļ���
				@uidFilename varchar(128),	--UID�ļ���
				@title nvarchar(32),		--����
				@fileSize bigint,			--�ļ��ߴ�
				@fileType varchar(10),		--�ļ�����
				@fileLog varchar(128),		--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG
	output: 
				@Ret		int output		--�����ɹ���ʶ
										0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-5
	UpdateDate: 
*/
create PROCEDURE addDiscussAttachment
	@sectionID varchar(12),		--�����
	@topicID varchar(13),		--������
	@replyID varchar(16),		--�����к�
	@aFilename varchar(128),	--ԭʼ�ļ���
	@uidFilename varchar(128),	--UID�ļ���
	@title nvarchar(32),		--����
	@fileSize bigint,			--�ļ��ߴ�
	@fileType varchar(10),		--�ļ�����
	@fileLog varchar(128),		--�ļ�log�����û��û�ж��壬��ʹ��Ĭ�ϵ��ļ�����LOG
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	insert into discussAttach(sectionID, topicID, replyID,
			aFilename, uidFilename, title, fileSize, fileType, uploadTime, fileLog)
	values(@sectionID, @topicID, @replyID,
			@aFilename, @uidFilename, @title, @fileSize, @fileType, getdate(), @fileLog)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE delDiscussAttachment
/*
	name:		delDiscussAttachment
	function:	9.ɾ��ָ��UID�ĸ���
	input: 
				@uidFilename varchar(128),	--UID�ļ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĸ��������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-5
	UpdateDate: 
*/
create PROCEDURE delDiscussAttachment
	@uidFilename varchar(128),	--UID�ļ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�ָ���ĸ����Ƿ����
	declare @count as int
	set @count=(select count(*) from discussAttach where uidFilename = @uidFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	delete discussAttach where uidFilename = @uidFilename
	
	set @Ret = 0
GO

drop PROCEDURE clearDiscussAttachment
/*
	name:		clearDiscussAttachment
	function:	10.���ָ����顢���⡢�ظ���ȫ������
				ע�⣺������������Ƿ��и���
	input: 
				@sectionID varchar(12),		--�����
				@topicID varchar(13),		--������
				@replyID varchar(16),		--�����к�
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-5
	UpdateDate: 
*/
create PROCEDURE clearDiscussAttachment
	@sectionID varchar(12),		--�����
	@topicID varchar(13),		--������
	@replyID varchar(16),		--�����к�
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	delete discussAttach where sectionID= @sectionID and isnull(topicID,'') = @topicID and isnull(replyID,'') = @replyID

	set @Ret = 0
GO

select * from discussAttach
------------------------------------------------------------------------------------------


drop procedure addDiscussTopic
/*
	name:		addDiscussTopic
	function:	11.�����������
				ע�⣺����洢���̲���д������־
	input: 
				@sectionID varchar(12),			--�����
				@title varchar(100),			--����
				@topicDesc nvarchar(4000),		--��������
				@authorID varchar(12),			--����ID
	output: 
				@Ret		int output,			--�����ɹ���ʶ
												0:�ɹ���9:δ֪����
				@topicID varchar(13) output		--������
	author:		¬�γ�
	CreateDate:	2013-8-25
	UpdateDate: 

*/
create procedure addDiscussTopic
	@sectionID varchar(12),			--�����
	@title varchar(100),			--����
	@topicDesc nvarchar(4000),		--��������
	@authorID varchar(12),			--����ID
	@Ret int output,				--�����ɹ���ʶ
	@topicID varchar(13) output		--������
as
begin
	set @Ret = 9
	--��21�ź��뷢������ȡtopicID
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 21, 1, @curNumber output
	set @topicID = @curNumber

	--ȡ�����˵�������
	declare @authorName varchar(30)
	if (@authorID is not null and @authorID!='')
		set @authorName = isnull((select cName from userInfo where userID = @authorID),'')
	if (@authorID is null or @authorID='' or @authorName is null or @authorName='')
		set @authorName = '����'
		
	insert into discussTopic(sectionID,topicID,title,topicDesc,authorID,author,viewNum ,isBoutique,sequence,createDate) 
	values(@sectionID,@topicID,@title,@topicDesc,@authorID,@authorName,0,0,9,GETDATE())
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	set @Ret = 0
end

drop procedure updateTopicViewNum
/*
	name:		updateTopicViewNum
	function:	12.�������������+1
	input: 
				@topicID varchar(13)	--������
	output: 
	author:		¬�γ�
	CreateDate:	2013-8-25
	UpdateDate: 

*/
create procedure updateTopicViewNum
	@topicID varchar(13)
as
begin
	declare @oldNum int,@newNum int
	set @oldNum=(select viewNum from discussTopic where topicID=@topicID)
	set @newNum=@oldNum+1;
	update discussTopic set viewNum=@newNum where topicID=@topicID
end


select * from discussTopicOverview
go


drop PROCEDURE topicDetail
/*
	name:		topicDetail
	function:	13.��ҳ��ȡ�����������ϸ��Ϣ
	input: 
				@topicID varchar(13),	--������
				@pageSize int,			--��ҳ�ߴ�
				@pageIndex int,			--��ҳ��
	output: 
				@title varchar(100) output,			--����
				@topicDesc varchar(4000) output,	--��������
				@attachMent varchar(8000) output,	--���⸽��
				@viewNum int output,			--�������
				@replyNum int output,			--������
				@authorID varchar(12) output,	--����ID
				@author nvarchar(30) output,	--����
				@createTime varchar(16) output,	--����ʱ��
				@creatorTopicNum int output,	--���ⴴ����������
				@creatorBoutiqueNum int output,	--���ⴴ�������Ӿ�����
				@nextTopicID varchar(12) output,--��һ����ID
				@nextTitle nvarchar(100) output,--��һ����
				@lastTopicID varchar(12) output,--��һ����ID
				@lastTitle nvarchar(100) output	--��һ����
	author:		¬�γ�
	CreateDate:	2013-8-25
	UpdateDate: 

*/
CREATE PROCEDURE topicDetail
	@topicID varchar(13),	--������
	@pageSize int,			--��ҳ�ߴ�
	@pageIndex int,			--��ҳ��
	@title varchar(100) output,			--����
	@topicDesc varchar(4000) output,	--��������
	@attachMent varchar(8000) output,	--���⸽��
	@viewNum int output,			--�������
	@replyNum int output,			--������
	@authorID varchar(12) output,	--����ID
	@author nvarchar(30) output,	--����
	@createDate varchar(19) output,	--����ʱ��
	@creatorTopicNum int output,	--���ⴴ����������
	@creatorBoutiqueNum int output,	--���ⴴ�������Ӿ�����
	@nextTopicID varchar(12) output,--��һ����ID
	@nextTitle nvarchar(100) output,--��һ����
	@lastTopicID varchar(12) output,--��һ����ID
	@lastTitle nvarchar(100) output	--��һ����
	WITH ENCRYPTION
AS
BEGIN
	declare @sectionID varchar(12)
	select @sectionID = sectionID, @title=title,@topicDesc=topicDesc,@viewNum=viewNum,@authorID=authorID,@author=author,
			@createDate =convert(varchar(19),createDate,120) 
	from discussTopic 
	where topicID=@topicID--ID�����⣬�鿴����������ID�������ˣ�����ʱ��
	
	select @replyNum=isnull(COUNT(replyID),0) from discussReply where topicID=@topicID--�ظ���
	
	select @creatorTopicNum=COUNT(topicID) 
	from discussTopic 
	where authorID in(select authorID from discussTopic where topicID=@topicID)--���ⴴ����������
	select @creatorBoutiqueNum=COUNT(topicID) 
	from discussTopic 
	where authorID = @authorID and isBoutique=1--���ⴴ�������Ӿ�����

	select @nextTopicID=topicID,@nextTitle=title 
	from discussTopic 
	where topicID in(select top 1 topicID from discussTopic where topicID>@topicID 
						and sectionID = @sectionID order by topicID asc)--��һ��
	
	select @lastTopicID=topicID,@lastTitle=title 
	from discussTopic 
	where topicID in(select top 1 topicID from discussTopic where topicID<@topicID 
						and sectionID = @sectionID order by topicID desc)--��һ��
	--������
	set @attachMent = dbo.getDiscussAttach(@sectionID,@topicID,'') 
	
	--�ظ�����Ϣ���ظ����ݣ�ʱ�䣬�ظ��˾������������ظ����������������ظ���ID���ظ�������
	SELECT * FROM 
		(SELECT top 100 percent ROW_NUMBER() OVER(ORDER BY replyTime asc) AS rowNum,
		topicID,replyID,replyContent,convert(varchar(19),replyTime,120) replyTime, 
		isnull(b.boutiqueNum,0) as replyBoutiqueNum,ISNULL(c.replyTopicNum,0) as replyTopicNum,
		d.authorID as replyManID,authorName as replyManName,
		dbo.getDiscussAttach(d.sectionID,d.topicID,d.replyID) attachMent
		FROM discussReply d left join 
			(select authorID, COUNT(topicID) as boutiqueNum 
			from discussTopic 
			where authorID in(select authorID from discussReply where topicID=@topicID) and isBoutique=1
			group by authorID) b on d.authorID = b.authorID 
		left join
			(select authorID,COUNT(topicID) as replyTopicNum 
			from discussTopic 
			where authorID in(select authorID from discussReply where topicID=@topicID)
								group by authorID) c on d.authorID=c.authorID
		where topicID=@topicID order by replyTime asc)AS D
	WHERE rowNum BETWEEN (@pageIndex-1)*@pageSize+1 AND @pageIndex*@pageSize
	ORDER BY replyTime asc
	
END
GO 


drop PROCEDURE delDiscussTopic
/*
	name:		delDiscussTopic
	function:	14.ɾ��ָ������̳���⣨���ӣ�
	input: 
				@topicID varchar(13),			--������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��ָ�������ⲻ���ڣ�2��Ҫɾ�����������ڰ���������������༭��9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-07
	UpdateDate: 

*/
create PROCEDURE delDiscussTopic
	@topicID varchar(13),			--������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussTopic where topicID = @topicID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @sectionID varchar(12)
	set @sectionID=(select sectionID from discussTopic where topicID = @topicID)
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	begin tran
		delete discussTopic where topicID = @topicID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--ɾ�������������µĻظ���������
		delete discussAttach where topicID = @topicID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ���˱��Ϊ��[' + @topicID + ']�����⡣')
GO

------------------------------------------------------------------

drop procedure addDiscussReply
/*
	name:		addDiscussReply
	function:	20.�������ظ�
				ע�⣺����洢���̲���д������־
	input: 
				@sectionID varchar(12),			--�����
				@topicID varchar(13),			--������
				@replyContent nvarchar(4000),	--����
				@authorID varchar(12),			--����ID
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���9:δ֪����
				@replyID varchar(16) output		--�ظ����
	author:		¬έ
	CreateDate:	2015-11-5
	UpdateDate: 

*/
create procedure addDiscussReply
	@sectionID varchar(12),			--�����
	@topicID varchar(13),			--������
	@replyContent nvarchar(4000),	--����
	@authorID varchar(12),			--����ID
	@Ret int output,				--�����ɹ���ʶ
	@replyID varchar(16) output		--�ظ����
as
begin
	set @Ret = 9

	--��22�ź��뷢������ȡreplyID
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 22, 1, @curNumber output
	set @replyID = @curNumber

	--ȡ�����˵�������
	declare @authorName varchar(30)
	if (@authorID is not null and @authorID!='')
		set @authorName = isnull((select cName from userInfo where userID = @authorID),'')
	if (@authorID is null or @authorID='' or @authorName is null or @authorName='')
		set @authorName = '����'
		
	insert into discussReply(sectionID,topicID, replyID, replyContent,replyTime,authorID,authorName) 
	values(@sectionID,@topicID, @replyID, @replyContent,getdate(),@authorID,@authorName)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	set @Ret = 0
end

drop PROCEDURE delDiscussReply
/*
	name:		delDiscussReply
	function:	21.ɾ��ָ������̳����Ļ���
	input: 
				@replyID varchar(16),			--�ظ����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��ָ���Ļ��������ڣ�2��Ҫɾ���Ļ������ڰ���������������༭��9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-07
	UpdateDate: 

*/
create PROCEDURE delDiscussReply
	@replyID varchar(16),			--�ظ����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from discussReply where replyID = @replyID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @sectionID varchar(12)
	set @sectionID=(select sectionID from discussReply where replyID = @replyID)
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussSection where sectionID = @sectionID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete discussReply where replyID = @replyID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--ɾ�������������µĻظ���������
		delete discussAttach where replyID = @replyID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ���˱��Ϊ��[' + @replyID + ']�Ļ�����')
GO


drop FUNCTION getDiscussAttach
/*
	name:		getDiscussAttach
	function:	100.��ȡ����������json��ʽ���
	input: 
				@sectionID varchar(12),	--�����
				@topicID varchar(13),	--�����ţ�����Ϊ""
				@replyID varchar(16)	--�ظ���ţ�����Ϊ""
	output: 
				return varchar(max),	--������Json����
	author:		¬έ
	CreateDate:	2015-11-6
	UpdateDate: 
*/
create FUNCTION getDiscussAttach(@sectionID varchar(12),@topicID varchar(13),@replyID varchar(16))
RETURNS varchar(max)
WITH ENCRYPTION
AS      
begin
	declare @result varchar(max)
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where sectionID = @sectionID and topicID = @topicID and replyID = @replyID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'

	return @result
end
--���ԣ�
select dbo.getDiscussAttach('S20151107001','D201511070001','R201511070000001')
select * from discussAttach
delete discussAttach

select substring('S20151105005',1,3)
S2
--�������xml
select * from discussAttach FOR XML RAW,TYPE,ELEMENTS


drop FUNCTION attachToJson
/*
	name:		attachToJson
	function:	100.1.������ת��ΪJson
	input: 
				@sectionID varchar(12),	--�����
				@topicID varchar(13),	--�����ţ�����Ϊ""
				@replyID varchar(16)	--�ظ���ţ�����Ϊ""
	output: 
				return varchar(max),	--������Json����
	author:		¬έ
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create FUNCTION attachToJson(@rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128))
RETURNS varchar(max)
WITH ENCRYPTION
AS      
begin
	declare @result varchar(max)
	set @result = '{' + '"rowNum":' + '"' + cast(@rowNum as varchar(10)) + '",' 
					   + '"filename":' + '"' + @aFilename + '",'
					   + '"uid":' + '"' + @uidFilename + '",'
					   + '"title":' + '"' + @title + '",'
					   + '"size":' + '"' + cast(@fileSize as varchar(18)) + '",'
					   + '"type":' + '"' + @fileType + '",'
					   + '"uploadTime":' + '"' + @uploadTime + '",'
					   + '"fileLog":' + '"' + @fileLog + '"},'
	return @result
end


drop PROCEDURE getAllAttachInSection
/*
	name:		getAllAttachInSection
	function:	101.��ȡ����ȫ���������������µ�����ͻظ��ĸ�����������json��ʽ���
	input: 
				@sectionID varchar(12),	--�����
	output: 
				@result varchar(8000) output	--����Json�����ִ�
	author:		¬έ
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create PROCEDURE getAllAttachInSection
	@sectionID varchar(12),			--�����
	@result varchar(8000) output	--����Json�����ִ�
	WITH ENCRYPTION 
AS
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where sectionID = @sectionID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'
go
--���ԣ�
declare @result varchar(8000)
exec dbo.getAllAttachInSection 'S20151107001', @result output
select @result

drop PROCEDURE getAllAttachInTopic
/*
	name:		getAllAttachInTopic
	function:	102.��ȡ�����ȫ���������������µĻظ��ĸ�����������json��ʽ���
	input: 
				@topicID varchar(13),	--������
	output: 
				@result varchar(8000) output	--����Json�����ִ�
	author:		¬έ
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create PROCEDURE getAllAttachInTopic
	@topicID varchar(13),			--������
	@result varchar(8000) output	--����Json�����ִ�
	WITH ENCRYPTION 
AS
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where topicID = @topicID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'
go
--���ԣ�
declare @result varchar(8000)
exec dbo.getAllAttachInTopic 'D201511070001', @result output
select @result

drop PROCEDURE getAllAttachInReply
/*
	name:		getAllAttachInReply
	function:	102.��ȡ�ظ���ȫ������������json��ʽ���
	input: 
				@replyID varchar(16),			--�ظ����
	output: 
				@result varchar(8000) output	--����Json�����ִ�
	author:		¬έ
	CreateDate:	2015-11-8
	UpdateDate: 
*/
create PROCEDURE getAllAttachInReply
	@replyID varchar(16),			--�ظ����
	@result varchar(8000) output	--����Json�����ִ�
	WITH ENCRYPTION 
AS
	set @result = ''
	declare @rowNum bigint, @aFilename varchar(128), @uidFilename varchar(128), 
			@title nvarchar(32), @fileSize bigint, @fileType varchar(10),
			@uploadTime varchar(19), @fileLog varchar(128)

	declare tar cursor for
	select rowNum, aFileName, uidFilename,isnull(title,'') title, fileSize, fileType, convert(varchar(19),uploadTime,120), isnull(fileLog,'')
	from discussAttach 
	where replyID = @replyID
	order by rowNum
	OPEN tar
	FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	WHILE @@FETCH_STATUS = 0
	begin
		declare @row varchar(1000)
		set @row = dbo.attachToJson(@rowNum, @aFilename, @uidFilename, 
									@title, @fileSize, @fileType,@uploadTime, @fileLog)
		set @result += @row
		FETCH NEXT FROM tar INTO @rowNum, @aFilename, @uidFilename, @title, @fileSize, @fileType, @uploadTime, @fileLog
	end
	CLOSE tar
	DEALLOCATE tar
	if @result <> ''
		set @result = '[' + substring(@result,1, len(@result)-1) + ']'
	else
		set @result = '[]'
go
--���ԣ�
declare @result varchar(8000)
exec dbo.getAllAttachInReply 'R201511070000001', @result output
select @result
 
update discussAttach
set topicid='',replyID=''
where sectionID='S20151107001' and topicID='D201511080046'


select * from discussTopic where topicID='S20151107001'

select * from discussAttach 

delete discussAttach 