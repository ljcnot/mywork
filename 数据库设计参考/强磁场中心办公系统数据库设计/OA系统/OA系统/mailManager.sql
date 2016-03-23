use hustOA
/*
	ǿ�ų�OAϵͳ-�ʼ���������
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate:
				
*/
--1.�������б�
select * from mailBindOption
drop TABLE mailBindOption
CREATE TABLE mailBindOption(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	mailerID varchar(10) not null,			--�������ʼ������˹���
	mailServer varchar(128) not null default('imap.163.com'),	--���������
	mailServerPort int default(143),		--������������˿�:163���䲻ʹ��SSL���ܵĶ˿ں���143��ʹ��SSL���ܵĶ˿ں���993.
	mailAddr varchar(60) not null,			--�����������ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	loginPSW varchar(128) null,				--��¼���룺ʹ��AES128λ�����㷨����
	usedSSL smallint default(0),			--�Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
	SMTPServer varchar(128) null,			--smtp�����ʼ�����������
	SMTPUsedSSL smallint default(0),		--smtp�������Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
	isDefaultSMTP smallint default(0),		--�Ƿ�ΪĬ�ϵ�SMTP���䣨�����佫���������ʼ�����0->�ǣ�1->��
	--������IMAPЭ���Ӧ�ķ������ļ��У�
	inBoxFolder nvarchar(30) null,			--�ռ����ļ�������
	outBoxFolder nvarchar(30) null,			--�������ļ�������
	sketchBoxFolder nvarchar(30) null,		--�ݸ����ļ�������
	trashBoxFolder nvarchar(30) null,		--�����ʼ�����ļ���
	deletedBoxFolder nvarchar(30) null,		--��ɾ���ʼ�����ļ���
	adBoxFolder nvarchar(30) null,			--����ʼ�����ļ���
	subscribeBoxFolder nvarchar(30) null,	--�����ʼ�����ļ���

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_mailBindOption] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[mailAddr] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--���±�Ĺ���û���������ʹ���������ֹ������ʹ��mailBindOption����������
--2.�ʼ��б�
drop TABLE mailList
CREATE TABLE mailList(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	mailerID varchar(10) not null,		--�ʼ������˹���
	mailAddr varchar(60) not null,		--��������Դ���䣬����"lw_bk@163.com"��ʽ
	folder nvarchar(128) not null,		--����Ŀ¼
	--����Ϊ�ʼ��ĸ�Ҫ��Ϣ��
	messageNum int not null,			--��ָ���������ʼ��ļ����ڵ��ʼ����:Ҫʼ�ձ�֤�Ǵ�1:*
	messageID varchar(128) not null,	--��������ָ���������ʼ���Ψһ��ʶ(UID)
	/*�����ӱ�������del by lw 2013-3-30
	mailFrom xml null,					--�ʼ���Դ�������ж����ַ������<root><from>��ַ1</from><from>��ַ2</from>...</root>��ʽ���
	mailTo xml null,					--���͵��������ж����ַ������<root><to>��ַ1</to><to>��ַ2</to>...</root>��ʽ���
	*/
	mailSubject nvarchar(300) null,		--�ʼ�����
	mailReceivedTime datetime null,		--�ʼ����յ�ʱ�䣺ָ���������ʱ��
	mailSize int null,					--�ʼ���С
	--�ʼ���ǣ�add by lw 2013-2-15
    isSeen smallint default(0),			--�Ƿ��Ķ���0->δ�Ķ���1->���Ķ�
	isAnswered smallint default(0),		--�Ƿ�ظ���0->δ�ظ���1->�ѻظ�
	isFlagged smallint default(0),		--�Ƿ��ǣ�0->δ��ǣ�1->�ѱ��
	isRecent smallint default(0),		--�Ƿ�������0->��1->��
	haveAttach smallint default(0),		--�Ƿ��и�����0->�ޣ�1->��
	isDeleted smallint default(0),		--�Ƿ�ɾ����0->δɾ����1->��ɾ��
	isDraft smallint default(0),		--�Ƿ�ݸ壺0->��ʽ�ʼ���1->�ݸ�
	
 CONSTRAINT [PK_mailList] PRIMARY KEY CLUSTERED
(
	[mailAddr] ASC,
	[folder] ASC,
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����������
CREATE NONCLUSTERED INDEX [IX_mailList] ON [dbo].[mailList]
(
	[mailReceivedTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--Ŀ¼������
CREATE NONCLUSTERED INDEX [IX_mailList_1] ON [dbo].[mailList]
(
	[mailerID] ASC,
	[mailAddr] ASC,
	[folder] ASC,
	[messageID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
select * from mailList 
where mailAddr+folder+messageID in (
	select mailAddr+folder+messageID from mailAddrList where name like '%¬έ%' and fromCCOrTo = 1
)
select * from mailAddrList
--2.1�ʼ���ַ�б������д洢�����ʼ���Դ���͵��ĵ�ַ��Ϣ
--add by lw 2013-3-30
drop TABLE mailAddrList
CREATE TABLE mailAddrList(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	mailAddr varchar(60) not null,		--����/�������Դ���䣬����"lw_bk@163.com"��ʽ
	folder nvarchar(128) not null,		--����Ŀ¼
	messageID varchar(128) not null,	--����/�������ָ���������ʼ���Ψһ��ʶ(UID)
	name nvarchar(30) null,				--�ʼ���ַ����
	eMailAddr varchar(128) not null,	--����:�ʼ���ַ
	fromCCOrTo smallint default(0),		--�����ʼ��ŷ�ṹ���ֶΣ�0->������1->From��2->To��3->CC
 CONSTRAINT [PK_mailAddrList] PRIMARY KEY CLUSTERED 
(
	[mailAddr] ASC,
	[folder] ASC,
	[messageID] ASC,
	[rowNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[mailAddrList] WITH CHECK ADD CONSTRAINT [FK_mailAddrList_mailList] FOREIGN KEY([mailAddr],[folder],[messageID])
REFERENCES [dbo].[mailList] ([mailAddr],[folder],[messageID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[mailAddrList] CHECK CONSTRAINT [FK_mailAddrList_mailList]
GO

--����������
CREATE NONCLUSTERED INDEX [IX_mailAddrList] ON [dbo].[mailAddrList]
(
	[name] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--3.�ݸ��䣨�����ʼ����������Ϊ�ʼ�ֻ�б��˲��ܱ༭������û���ṩ�༭����
--add by lw 2013-3-31
select * from mailInfo where mailerID='G201300040'
drop TABLE mailInfo
CREATE TABLE mailInfo(
	messageID int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	mailerID varchar(10) not null,		--�ʼ���д�˹���
	mFrom xml,							--�������䣺����Ϊ���Ժ���չ����ƵĿɱ���������
										/*�����ж����ַ������<root>
																	<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																	<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																	...
																</root>��ʽ���
										*/
	mTo xml null,						--������
										/*�����ж����ַ������<root>
																	<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																	<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																	...
																</root>��ʽ���
										*/
	mSubject nvarchar(1000) null,		--�ʼ�����
	mBody nvarchar(max) null,			--�ʼ�����
	AttachFiles nvarchar(1000) null,	--�ʼ����������л�����ַ�����
	mCC xml null,						--����
										/*�����ж����ַ������<root>
																	<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																	<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																	...
																</root>��ʽ���
										*/
	saveTime smalldatetime default(getdate())	--����ʱ��
 CONSTRAINT [PK_mailInfo] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[messageID] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select messageID, mailerID, mFrom, mTo, mSubject, mBody, AttachFiles, mCC, convert(varchar(19),saveTime,120) saveTime
from mailInfo


--4.���Ի�ǩ����Ϣ��
drop TABLE signInfo
CREATE TABLE signInfo(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	mailerID varchar(10) not null,		--�ʼ������˹���
	signName nvarchar(20) not null,		--ǩ��������
	signBody nvarchar(4000) null,		--ǩ����Ƶ�HTML

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_signInfo] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[signName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--5.������ϵ�˷����
drop TABLE contactsGroup
CREATE TABLE contactsGroup(
	groupID int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,	--�����������
	mailerID varchar(10) not null,		--����:�ʼ������˹���
	groupName nvarchar(30) null,	--��������
	notes nvarchar(300) null,		--��ע
	createTime smalldatetime default(getdate())	--����ʱ��
 CONSTRAINT [PK_contactsGroup] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[groupID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--5.1.������ϵ�˱�
drop TABLE mailContacts
CREATE TABLE mailContacts(
	groupID int default(0),				--����ţ�����û��ǿ�����ӵ������������ϵ�˲���Ԥ����ķ�����.0��ʾû�з���
	groupName nvarchar(30) null,		--������ƣ���������
	mailerID varchar(10) not null,		--����:�ʼ������˹���
	eMailAddr varchar(128) not null,	--����:�ʼ���ַ
	mailerName nvarchar(30) null,		--�ʼ���ַ����
	isShared smallint default(0),		--�Ƿ����0->������1->����
	createrID varchar(10) null,			--�����˹���
	creater nvarchar(30) null,			--������
	createTime smalldatetime default(getdate())	--����ʱ��
 CONSTRAINT [PK_mailContacts] PRIMARY KEY CLUSTERED 
(
	[mailerID] ASC,
	[eMailAddr] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--����������
CREATE NONCLUSTERED INDEX [IX_mailContacts] ON [dbo].[mailContacts]
(
	[groupName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�Ƿ����������
CREATE NONCLUSTERED INDEX [IX_mailContacts_1] ON [dbo].[mailContacts]
(
	[isShared] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE checkMailAddr
/*
	name:		checkMailAddr
	function:	0.���ָ���������ַ�Ƿ��Ѿ�����
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@mailAddr varchar(60),	--�����ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkMailAddr
	@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@mailAddr varchar(60),	--�����ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	set @count = (select count(*) from mailBindOption where mailAddr = @mailAddr and rowNum <> @rowNum)
	set @Ret = @count
GO

drop PROCEDURE queryMailBindOptionLocMan
/*
	name:		queryMailBindOptionLocMan
	function:	1.��ѯָ���������Ƿ��������ڱ༭
	input: 
				@mailAddr varchar(60),			--�����ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�������䲻����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE queryMailBindOptionLocMan
	@mailAddr varchar(60),			--�����ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	@Ret int output,				--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from mailBindOption where mailAddr = @mailAddr),'')
	set @Ret = 0
GO


drop PROCEDURE lockMailBindOption4Edit
/*
	name:		lockMailBindOption4Edit
	function:	2.��������༭������༭��ͻ
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���������䲻���ڣ�2:Ҫ�������������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE lockMailBindOption4Edit
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from mailBindOption where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update mailBindOption 
	set lockManID = @lockManID 
	where rowNum = @rowNum

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '��������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˵�['+str(@rowNum)+']������Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockMailBindOptionEditor
/*
	name:		unlockMailBindOptionEditor
	function:	3.�ͷ�����༭��
				ע�⣺���Ǹ��༭������ʹ�õĹ��̣������̲������������Ƿ���ڣ�
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE unlockMailBindOptionEditor
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update mailBindOption  set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�����༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˵�['+str(@rowNum)+']������ı༭����')
GO

drop PROCEDURE addMailBindOption
/*
	name:		addMailBindOption
	function:	4.��Ӱ�����
	input: 
				@mailerID varchar(10),			--�������ʼ������˹���
				@mailServer varchar(128),		--�����������������
				@mailServerPort int,			--������������˿�:163���䲻ʹ��SSL���ܵĶ˿ں���143��ʹ��SSL���ܵĶ˿ں���993.
				@mailAddr varchar(60),			--�����������ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
				@loginPSW varchar(128),			--��¼���룺ʹ��AES128λ�����㷨����
				@usedSSL smallint,				--�Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
				@SMTPServer varchar(128),		--smtp�����ʼ�����������
				@SMTPUsedSSL smallint,			--smtp�������Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
				--������IMAPЭ���Ӧ�ķ������ļ��У�
				@inBoxFolder nvarchar(128),		--�ռ����ļ�������
				@outBoxFolder nvarchar(128),	--�������ļ�������
				@sketchBoxFolder nvarchar(128),	--�ݸ����ļ�������
				@trashBoxFolder nvarchar(128),	--�����ʼ�����ļ���
				@deletedBoxFolder nvarchar(128),--��ɾ���ʼ�����ļ���
				@adBoxFolder nvarchar(128),		--����ʼ�����ļ���
				@subscribeBoxFolder nvarchar(128),	--�����ʼ�����ļ���

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: modi by lw 2013-1-27����SMTP����������
*/
create PROCEDURE addMailBindOption
	@mailerID varchar(10),			--�������ʼ������˹���
	@mailServer varchar(128),		--�����������������
	@mailServerPort int,			--������������˿�:163���䲻ʹ��SSL���ܵĶ˿ں���143��ʹ��SSL���ܵĶ˿ں���993.
	@mailAddr varchar(60),			--�����������ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	@loginPSW varchar(128),			--��¼���룺ʹ��AES128λ�����㷨����
	@usedSSL smallint,				--�Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
	@SMTPServer varchar(128),		--smtp�����ʼ�����������
	@SMTPUsedSSL smallint,			--smtp�������Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
	--������IMAPЭ���Ӧ�ķ������ļ��У�
	@inBoxFolder nvarchar(128),		--�ռ����ļ�������
	@outBoxFolder nvarchar(128),	--�������ļ�������
	@sketchBoxFolder nvarchar(128),	--�ݸ����ļ�������
	@trashBoxFolder nvarchar(128),	--�����ʼ�����ļ���
	@deletedBoxFolder nvarchar(128),--��ɾ���ʼ�����ļ���
	@adBoxFolder nvarchar(128),		--����ʼ�����ļ���
	@subscribeBoxFolder nvarchar(128),	--�����ʼ�����ļ���

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert mailBindOption(mailerID, mailServer, mailServerPort, mailAddr, loginPSW, usedSSL,
							SMTPServer, SMTPUsedSSL,
							--������IMAPЭ���Ӧ�ķ������ļ��У�
							inBoxFolder, outBoxFolder, sketchBoxFolder, trashBoxFolder,
							deletedBoxFolder, adBoxFolder, subscribeBoxFolder,
							--����ά�����:
							modiManID, modiManName, modiTime)
	values(@mailerID, @mailServer, @mailServerPort, @mailAddr, @loginPSW, @usedSSL,
					@SMTPServer, @SMTPUsedSSL,
					--������IMAPЭ���Ӧ�ķ������ļ��У�
					@inBoxFolder, @outBoxFolder, @sketchBoxFolder, @trashBoxFolder,
					@deletedBoxFolder, @adBoxFolder, @subscribeBoxFolder,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ���������['+@mailAddr+']��')
GO
--����:
declare	@Ret		int
declare	@createTime smalldatetime
select * from userInfo

drop PROCEDURE setDefaultSMTP
/*
	name:		setDefaultSMTP
	function:	4.1.��ָ������������ΪSMTPĬ�ϵķ�����
	input: 
				@mailAddr varchar(60),		--�����������ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ

				@modiManID varchar(10) output,	--�޸��˹��ţ������ǰ���������˱༭�������򷵻������˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���
											1:Ҫ�޸ĵ����䲻���ڣ�
											2:Ҫ�޸ĵ������������������༭��
											9:δ֪����
	author:		¬έ
	CreateDate:	2013-1-27
	UpdateDate: 
*/
create PROCEDURE setDefaultSMTP
	@mailAddr varchar(60),		--�����ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ

	@modiManID varchar(10) output,	--�޸��˹��ţ������ǰ���������˱༭�������򷵻������˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from mailBindOption where mailAddr = @mailAddr)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where mailAddr = @mailAddr),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��ȡ�����Ӧ���ʼ��˹��ţ�
	declare @mailerID varchar(10)
	set @mailerID = (select top 1 mailerID from mailBindOption where mailAddr = @mailAddr)

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran 
		update mailBindOption
		set isDefaultSMTP = 0
		where mailerID = @mailerID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update mailBindOption
		set isDefaultSMTP = 1,
			--����ά�����:
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
		where mailAddr = @mailAddr
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
	values(@modiManID, @modiManName, @modiTime, '����Ĭ�Ϸ�����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ��['+@mailerID+']��['+@mailAddr+']��������ΪĬ�ϵķ����䡣')
GO

drop PROCEDURE updateMailBindOption
/*
	name:		updateMailBindOption
	function:	5.�޸��������
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@mailerID varchar(10),			--�������ʼ������˹���
				@mailServer varchar(128),		--�����������������
				@mailServerPort int,			--������������˿�:163���䲻ʹ��SSL���ܵĶ˿ں���143��ʹ��SSL���ܵĶ˿ں���993.
				@mailAddr varchar(60),			--�����������ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
				@loginPSW varchar(128),			--��¼���룺ʹ��AES128λ�����㷨����
				@usedSSL smallint,				--�Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
				@SMTPServer varchar(128),		--smtp�����ʼ�����������
				@SMTPUsedSSL smallint,			--smtp�������Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
				--������IMAPЭ���Ӧ�ķ������ļ��У�
				@inBoxFolder nvarchar(128),		--�ռ����ļ�������
				@outBoxFolder nvarchar(128),	--�������ļ�������
				@sketchBoxFolder nvarchar(128),	--�ݸ����ļ�������
				@trashBoxFolder nvarchar(128),	--�����ʼ�����ļ���
				@deletedBoxFolder nvarchar(128),--��ɾ���ʼ�����ļ���
				@adBoxFolder nvarchar(128),		--����ʼ�����ļ���
				@subscribeBoxFolder nvarchar(128),	--�����ʼ�����ļ���

				@modiManID varchar(10) output,	--�޸��˹��ţ������ǰ���������˱༭�������򷵻������˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ����䲻���ڣ�
							2:Ҫ�޸ĵ������������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE updateMailBindOption
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@mailerID varchar(10),			--�������ʼ������˹���
	@mailServer varchar(128),		--�����������������
	@mailServerPort int,			--������������˿�:163���䲻ʹ��SSL���ܵĶ˿ں���143��ʹ��SSL���ܵĶ˿ں���993.
	@mailAddr varchar(60),			--�����������ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	@loginPSW varchar(128),			--��¼���룺ʹ��AES128λ�����㷨����
	@usedSSL smallint,				--�Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
	@SMTPServer varchar(128),		--smtp�����ʼ�����������
	@SMTPUsedSSL smallint,			--smtp�������Ƿ�ʹ��SSL����:0->��ʹ�ã�1->ʹ��
	--������IMAPЭ���Ӧ�ķ������ļ��У�
	@inBoxFolder nvarchar(128),		--�ռ����ļ�������
	@outBoxFolder nvarchar(128),	--�������ļ�������
	@sketchBoxFolder nvarchar(128),	--�ݸ����ļ�������
	@trashBoxFolder nvarchar(128),	--�����ʼ�����ļ���
	@deletedBoxFolder nvarchar(128),--��ɾ���ʼ�����ļ���
	@adBoxFolder nvarchar(128),		--����ʼ�����ļ���
	@subscribeBoxFolder nvarchar(128),	--�����ʼ�����ļ���

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from mailBindOption where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from mailBindOption where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update mailBindOption
	set mailerID = @mailerID, mailServer = @mailServer, mailServerPort = @mailServerPort, mailAddr = @mailAddr,
		loginPSW = @loginPSW, usedSSL = @usedSSL,
		SMTPServer = @SMTPServer, SMTPUsedSSL = @SMTPUsedSSL,
		--������IMAPЭ���Ӧ�ķ������ļ��У�
		inBoxFolder = @inBoxFolder, outBoxFolder = @outBoxFolder, 
		sketchBoxFolder = @sketchBoxFolder, trashBoxFolder = @trashBoxFolder,
		deletedBoxFolder = @deletedBoxFolder, adBoxFolder = @adBoxFolder, subscribeBoxFolder = @subscribeBoxFolder,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where rowNum = @rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸��������', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸���['+@mailerID+']�ĵ�['+str(@rowNum)+']������Ĳ���]����')
GO
--����:
declare	@Ret		int
declare	@modiTime smalldatetime
exec dbo.updateMailBindOption 10,'00006745','imap.163.com',143,'wyfttp@163.com','13507236429',0,
	'�ݸ���','�ݸ���','�ѷ���','�ѷ���','�ѷ���','�ѷ���','�ѷ���','00006745',@Ret output,@modiTime output
	
select @Ret

select * from mailBindOption

drop PROCEDURE delMailBindOption
/*
	name:		delMailBindOption
	function:	6.ɾ��ָ��������
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������䲻���ڣ�2��Ҫɾ����������������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 

*/
create PROCEDURE delMailBindOption
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from mailBindOption where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @mailAddr varchar(60)			--�����������ַ��������ĵ�¼�˺ţ�������"lw_bk@163.com"��ʽ
	select @thisLockMan = isnull(lockManID,''), @mailAddr = mailAddr from mailBindOption where rowNum = @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete mailBindOption where mailAddr = @mailAddr
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ��������['+@mailAddr+']��')

GO

drop PROCEDURE addMailInfo
/*
	name:		addMailInfo
	function:	7.����ʼ���Ҫ��Ϣ
	input: 
				@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
				@folder nvarchar(30),		--�ʼ��ļ���
				--����Ϊ�ʼ��ĸ�Ҫ��Ϣ��
				@messageNum int,			--��ָ���������ʼ��ļ����ڵ��ʼ����:Ҫʼ�ձ�֤�Ǵ�1:*,�ò�����Ҫ�������ͬ����������ʱδ����
				@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)
				@mailFrom xml,				--�ʼ���Դ�������ж����ַ������<root>
																				<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																				<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																				...
																			</root>��ʽ���
				@mailTo xml,				--���͵��������ж����ַ������<root>
																				<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																				<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																				...
																			</root>��ʽ���
				@mailSubject nvarchar(300),	--�ʼ�����
				@mailReceivedTime varchar(19),--�ʼ����յ�ʱ�䣺ָ���������ʱ��
				@mailSize int,				--�ʼ���С
				@isSeen smallint,			--�Ƿ��Ķ���0->δ�Ķ���1->���Ķ�
				@isAnswered smallint,		--�Ƿ�ظ���0->δ�ظ���1->�ѻظ�
				@isFlagged smallint,		--�Ƿ��ǣ�0->δ��ǣ�1->�ѱ��
				@isRecent smallint,			--�Ƿ�������0->��1->��
				@haveAttach smallint,		--�Ƿ��и�����0->�ޣ�1->��
				@isDeleted smallint,		--�Ƿ�ɾ����0->δɾ����1->��ɾ��
				@isDraft smallint,			--�Ƿ�ݸ壺0->��ʽ�ʼ���1->�ݸ�
	output: 
				@Ret		int output			--�����ɹ���ʶ0:�ɹ���1:���ʼ��Ѵ��ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: modi by lw 2013-1-27�򻯽ӿ�
				modi by lw 2013-2-18�����ʼ����
				modi by lw 2013-3-30�޸��ռ��˺ͷ�����Ϊ�ӱ�ṹ��
*/
create PROCEDURE addMailInfo
	@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
	@folder nvarchar(30),		--�ʼ��ļ���
	--����Ϊ�ʼ��ĸ�Ҫ��Ϣ��
	@messageNum int,			--��ָ���������ʼ��ļ����ڵ��ʼ����:Ҫʼ�ձ�֤�Ǵ�1:*
	@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)
	@mailFrom xml,				/*�ʼ���Դ�������ж����ַ������<root>
																	<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																	<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																	...
																</root>��ʽ���*/
	@mailTo xml,				/*���͵��������ж����ַ������<root>
																	<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																	<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																	...
																</root>��ʽ���*/
	@mailSubject nvarchar(300),	--�ʼ�����
	@mailReceivedTime  varchar(19),--�ʼ����յ�ʱ�䣺ָ���������ʱ��
	@mailSize int,				--�ʼ���С
	@isSeen smallint,			--�Ƿ��Ķ���0->δ�Ķ���1->���Ķ�
	@isAnswered smallint,		--�Ƿ�ظ���0->δ�ظ���1->�ѻظ�
	@isFlagged smallint,		--�Ƿ��ǣ�0->δ��ǣ�1->�ѱ��
	@isRecent smallint,			--�Ƿ�������0->��1->��
	@haveAttach smallint,		--�Ƿ��и�����0->�ޣ�1->��
	@isDeleted smallint,		--�Ƿ�ɾ����0->δɾ����1->��ɾ��
	@isDraft smallint,			--�Ƿ�ݸ壺0->��ʽ�ʼ���1->�ݸ�

	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--��ȡ�ʼ������˹��ţ�
	declare @mailerID varchar(10)
	set @mailerID = (select mailerID from mailBindOption where mailAddr = @mailAddr)
	
	declare @count int
	set @count = (select count(*) from mailList where mailAddr = @mailAddr and folder = @folder and messageID = @messageID)
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	begin tran
		insert mailList(mailerID, mailAddr, folder, messageNum, messageID, 
						mailSubject, mailReceivedTime, mailSize,
						isSeen, isAnswered, isFlagged, isRecent, haveAttach, isDeleted, isDraft)
		values(@mailerID, @mailAddr, @folder, @messageNum, @messageID, 
				@mailSubject, @mailReceivedTime, @mailSize,
				@isSeen, @isAnswered, @isFlagged, @isRecent, @haveAttach, @isDeleted, @isDraft)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		print '1'
		--�����ʼ���Դ�б�--fromCCOrTo�����ʼ��ŷ�ṹ���ֶΣ�0->������1->From��2->To��3->CC
		insert mailAddrList(mailAddr, folder, messageID, name, eMailAddr, fromCCOrTo) 
		select @mailAddr, @folder, @messageID, cast(T.x.query('data(./name)') as nvarchar(30)) name, 
				cast(T.x.query('data(./eMailAddr)') as varchar(128)) eMailAddr,1
		from(select @mailFrom.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		print '2'
		--�����ʼ����͵��б�--fromCCOrTo�����ʼ��ŷ�ṹ���ֶΣ�0->������1->From��2->To��3->CC
		insert mailAddrList(mailAddr, folder, messageID, name, eMailAddr, fromCCOrTo) 
		select @mailAddr, @folder, @messageID, cast(T.x.query('data(./name)') as nvarchar(30)) name, 
				cast(T.x.query('data(./eMailAddr)') as varchar(128)) eMailAddr,2
		from(select @mailTo.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
print @@ERROR		
			rollback tran
			set @Ret = 9
			return
		end
		print '3'
	commit tran
	set @Ret = 0

GO
declare @mailFrom xml
set @mailFrom = N'<root><row><name></name><eMailAddr>lw_bk@163.com</eMailAddr></row></root>'
		select cast(T.x.query('data(./name)') as nvarchar(30)) name, 
				cast(T.x.query('data(./eMailAddr)') as varchar(128)) eMailAddr
		from(select @mailFrom.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)

select * from mailList
select * from mailAddrList
delete mailList

declare	@Ret		int --�����ɹ���ʶ
exec dbo.addMailInfo 'lw_bk@163.com','INBOX',2159,'1320997306',
'<root><row><name>s</name><eMailAddr>lw_bk@163.com</eMailAddr></row></root>',
'<root><row><name>¬έ</name><eMailAddr>lw_bk@162.com</eMailAddr></row></root>',
'Hello','2013-03-31 01:00:00',888,0,0,0,1,1,0,0,@Ret output
select @Ret
select * from mailAddrList where messageID=''

select * from mailBindOption 
insert mailList(mailerID, mailAddr, folder, messageNum, messageID, 
				mailSubject, mailReceivedTime, mailSize,
				isSeen, isAnswered, isFlagged, isRecent, haveAttach, isDeleted, isDraft)
values('G201300040','lw_bk@163.com','INBOX',2159,'1320997305',
'Hello','2013-03-31 01:00:00',888,0,0,0,1,1,0,0)

select * from mailList where messageID='1320997249'
select mailerID from mailBindOption where mailAddr='lw_bk@163.com'


drop PROCEDURE delMailInfo
/*
	name:		delMailInfo
	function:	8.ɾ���ʼ���Ҫ��Ϣ
				ע���ù���Ӧ��ά��messageNum�ֶΣ���ָ���������ʼ��ļ����ڵ��ʼ����:Ҫʼ�ձ�֤�Ǵ�1:*,�ò�����Ҫ�������ͬ����������δά������
	input: 
				@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
				@folder nvarchar(30),		--�ʼ��ļ���
				@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)
	output: 
				@Ret		int output			--�����ɹ���ʶ0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: modi by lw 2013-1-27�򻯽ӿ�

*/
create PROCEDURE delMailInfo
	@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
	@folder nvarchar(30),		--�ʼ��ļ���
	@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)

	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	delete mailList where mailAddr = @mailAddr and folder = @folder and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO


drop PROCEDURE setMailInfoSeen
/*
	name:		setMailInfoSeen
	function:	10.���ʼ�����Ϊ�Ѷ�
	input: 
				@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
				@folder nvarchar(30),		--�ʼ��ļ���
				@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)
	output: 
				@Ret		int output			--�����ɹ���ʶ0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-18
	UpdateDate: 

*/
create PROCEDURE setMailInfoSeen
	@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
	@folder nvarchar(30),		--�ʼ��ļ���
	@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)

	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	update mailList
	set isSeen = 1
	where mailAddr = @mailAddr and folder = @folder and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE setMailInfoAnswered
/*
	name:		setMailInfoAnswered
	function:	11.���ʼ�����Ϊ�ѻظ�
	input: 
				@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
				@folder nvarchar(30),		--�ʼ��ļ���
				@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)
	output: 
				@Ret		int output			--�����ɹ���ʶ0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-18
	UpdateDate: 

*/
create PROCEDURE setMailInfoAnswered
	@mailAddr varchar(60),		--��������Դ���䣬����"lw_bk@163.com"��ʽ
	@folder nvarchar(30),		--�ʼ��ļ���
	@messageID varchar(128),	--��������ָ���������ʼ���Ψһ��ʶ(UID)

	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	update mailList
	set isAnswered = 1
	where mailAddr = @mailAddr and folder = @folder and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop FUNCTION getEMailAddrInfo
/*
	name:		getEMailAddrInfo
	function:	12.��ȡָ���ż�ָ���ֶε��ʼ���ַ�б�
	input: 
				@mailAddr varchar(60),		--��Դ���䣬����"lw_bk@163.com"��ʽ
				@messageID varchar(128),	--��ָ���������ʼ���Ψһ��ʶ(UID)
				@fromCCOrTo smallint 		--�����ʼ��ŷ�ṹ���ֶΣ�1->From��2->To��3->CC
	output: 
				return xml					--���ؿ����ж����ַ������<root>
																		<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																		<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																		...
																	</root>��ʽ���
	author:		¬έ
	CreateDate:	2013-3-30
	UpdateDate: 
*/
create FUNCTION getEMailAddrInfo
(  
	@mailAddr varchar(60),		--��Դ���䣬����"lw_bk@163.com"��ʽ
	@messageID varchar(128),	--��ָ���������ʼ���Ψһ��ʶ(UID)
	@fromCCOrTo smallint 		--�����ʼ��ŷ�ṹ���ֶΣ�1->From��2->To��3->CC
)  
RETURNS xml	
WITH ENCRYPTION
AS      
begin
	DECLARE @list xml;
	
	set @list = (select name, eMailAddr from mailAddrList
						where mailAddr = @mailAddr and messageID=@messageID and fromCCOrTo=@fromCCOrTo
						FOR XML RAW)
	return N'<root>' + cast(@list as nvarchar(max)) + N'</root>'
end

select * from mailAddrList
order by mailAddr,messageID,fromCCOrTo

DECLARE @statusRemark xml;
set @statusRemark = (select name, eMailAddr 
from mailAddrList
where mailAddr = '1356054110@qq.com' and messageID='14' and fromCCOrTo =1
FOR XML RAW)
select @statusRemark

--����
select dbo.getEMailAddrInfo('1356054110@qq.com','14',1)
-------------------------------------------�����ʼ��Ĵ洢����------------------------------------------
drop PROCEDURE addLocalMailInfo
/*
	name:		addLocalMailInfo
	function:	15.����ʼ�����������
	input: 
				@mailerID varchar(10),		--�ʼ���д�˹���
				@mFrom xml,					--�ʼ���Դ���������䣩������Ϊ���Ժ���չ����ƵĿɱ���������
											/*�����ж����ַ������<root>
																		<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																		<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																		...
																	</root>��ʽ���
											*/
				@mTo xml,					--������
											/*�����ж����ַ������<root>
																		<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																		<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																		...
																	</root>��ʽ���
											*/
				@mSubject nvarchar(1000),	--�ʼ�����
				@mBody nvarchar(max),		--�ʼ�����
				@AttachFiles nvarchar(1000),--�ʼ����������л�����ַ�����
				@mCC xml,					--����
											/*�����ж����ַ������<root>
																		<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																		<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																		...
																	</root>��ʽ���
											*/
	output: 
				@Ret		int output			--�����ɹ���ʶ0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-2
	UpdateDate: 
*/
create PROCEDURE addLocalMailInfo
	@mailerID varchar(10),		--�ʼ���д�˹���
	@mFrom xml,					--�ʼ���Դ���������䣩������Ϊ���Ժ���չ����ƵĿɱ���������
	@mTo xml,					--������
	@mSubject nvarchar(1000),	--�ʼ�����
	@mBody nvarchar(max),		--�ʼ�����
	@AttachFiles nvarchar(1000),--�ʼ����������л�����ַ�����
	@mCC xml,					--����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	insert mailInfo(mailerID, mFrom, mTo, mSubject, mBody, AttachFiles, mCC)
	values(@mailerID, @mFrom, @mTo, @mSubject, @mBody, @AttachFiles, @mCC)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

GO


drop PROCEDURE updateLocalMailInfo
/*
	name:		updateLocalMailInfo
	function:	16.�޸ı����ʼ�
	input: 
				@messageID int,				--�ʼ���ʶID				
				@mailerID varchar(10),		--�ʼ���д�˹���
				@mFrom xml,					--�ʼ���Դ���������䣩������Ϊ���Ժ���չ����ƵĿɱ���������
											/*�����ж����ַ������<root>
																		<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																		<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																		...
																	</root>��ʽ���
											*/
				@mTo xml,					--������
											/*�����ж����ַ������<root>
																		<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																		<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																		...
																	</root>��ʽ���
											*/
				@mSubject nvarchar(1000),	--�ʼ�����
				@mBody nvarchar(max),		--�ʼ�����
				@AttachFiles nvarchar(1000),--�ʼ����������л�����ַ�����
				@mCC xml,					--����
											/*�����ж����ַ������<root>
																		<row><name>����</name><eMailAddr>��ַ1</eMailAddr></row>
																		<row><name>����</name><eMailAddr>��ַ2</eMailAddr></row>
																		...
																	</root>��ʽ���
											*/
	output: 
				@Ret		int output			--�����ɹ���ʶ0:�ɹ���1:���ʼ������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-2
	UpdateDate: 
*/
create PROCEDURE updateLocalMailInfo
	@messageID int,				--�ʼ���ʶID				
	@mailerID varchar(10),		--�ʼ���д�˹���
	@mFrom xml,					--�ʼ���Դ���������䣩������Ϊ���Ժ���չ����ƵĿɱ���������
	@mTo xml,					--������
	@mSubject nvarchar(1000),	--�ʼ�����
	@mBody nvarchar(max),		--�ʼ�����
	@AttachFiles nvarchar(1000),--�ʼ����������л�����ַ�����
	@mCC xml,					--����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	declare @count int
	set @count=isnull((select count(*) from mailInfo where messageID=@messageID),0)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	
	update mailInfo
	set mailerID = @mailerID, mFrom = @mFrom, mTo = @mTo, 
	mSubject = @mSubject, mBody = @mBody, AttachFiles = @AttachFiles, mCC = @mCC,
	saveTime = getdate()
	where messageID=@messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

GO

drop PROCEDURE delLocalMailInfo
/*
	name:		delLocalMailInfo
	function:	17.ɾ��ָ���ı����ʼ�
	input: 
				@messageID int,
				@mailerID varchar(10),		--ɾ���ˣ��ʼ���д�ˣ�����
	output: 
				@Ret		int output			--�����ɹ���ʶ0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-2
	UpdateDate: 

*/
create PROCEDURE delLocalMailInfo
	@messageID int,
	@mailerID varchar(10),		--ɾ���ˣ��ʼ���д�ˣ�����

	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	delete mailInfo where messageID = @messageID and messageID = @messageID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

-------------------------------------------ǩ���Ĵ洢����------------------------------------------
drop PROCEDURE checkSignName
/*
	name:		checkSignName
	function:	20.���ָ����Ա��ǩ���Ƿ��Ѿ�����
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@mailerID varchar(10),		--�ʼ������˹���
				@signName nvarchar(20),		--ǩ��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkSignName
	@rowNum int,				--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@mailerID varchar(10),		--�ʼ������˹���
	@signName nvarchar(20),		--ǩ��������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	set @count = (select count(*) from signInfo where mailerID = @mailerID and signName = @signName and rowNum <> @rowNum)
	set @Ret = @count
GO


drop PROCEDURE querySignNameLocMan
/*
	name:		querySignNameLocMan
	function:	21.��ѯָ������Ա��ǩ���Ƿ��������ڱ༭
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@signName nvarchar(20),		--ǩ��������
	output: 
				@Ret		int output,			--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ǩ��������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE querySignNameLocMan
	@mailerID varchar(10),		--�ʼ������˹���
	@signName nvarchar(20),		--ǩ��������
	
	@Ret		int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from signInfo where mailerID = @mailerID and signName = @signName),'')
	set @Ret = 0
GO


drop PROCEDURE lockSignInfo4Edit
/*
	name:		lockSignInfo4Edit
	function:	22.����ָ����Ա��ǩ���༭������༭��ͻ
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@lockManID varchar(10) output,	--�����ˣ������ǰǩ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ǩ�������ڣ�2:Ҫ������ǩ�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE lockSignInfo4Edit
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@lockManID varchar(10) output,	--�����ˣ������ǰǩ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ǩ���Ƿ����
	declare @count as int
	set @count=(select count(*) from signInfo where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from signInfo where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update signInfo
	set lockManID = @lockManID 
	where rowNum = @rowNum

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ǩ���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������ǩ��['+ str(@rowNum) +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockSignInfoEditor
/*
	name:		unlockSignInfoEditor
	function:	23.�ͷ�ǩ���༭��
				ע�⣺�����̲����ǩ���Ƿ���ڣ�
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@lockManID varchar(10) output,	--�����ˣ������ǰǩ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE unlockSignInfoEditor
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@lockManID varchar(10) output,	--�����ˣ������ǰǩ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from signInfo where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update signInfo set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�ǩ���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���ǩ��['+ str(@rowNum)+']�ı༭����')
GO


drop PROCEDURE addSignInfo
/*
	name:		addSignInfo
	function:	24.���ǩ��
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@signName nvarchar(20),		--ǩ��������
				@signBody nvarchar(4000),	--ǩ����Ƶ�HTML

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE addSignInfo
	@mailerID varchar(10),		--�ʼ������˹���
	@signName nvarchar(20),		--ǩ��������
	@signBody nvarchar(4000),	--ǩ����Ƶ�HTML

	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert signInfo(mailerID, signName, signBody,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@mailerID, @signName, @signBody,
			--����ά�����:
			@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '���ǩ��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������ǩ��['+@signName+']��')
GO
--����:
declare	@Ret		int
declare	@createTime smalldatetime


drop PROCEDURE updateSignInfo
/*
	name:		updateSignInfo
	function:	25.�޸�ǩ��
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@mailerID varchar(10),			--�ʼ������˹���
				@signName nvarchar(20),			--ǩ��������
				@signBody nvarchar(4000),		--ǩ����Ƶ�HTML

				@modiManID varchar(10) output,	--�޸��˹��ţ������ǰǩ�������˱༭�������򷵻������˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�ǩ�������ڣ�
							2:Ҫ�޸ĵ�ǩ���������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 
*/
create PROCEDURE updateSignInfo
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@mailerID varchar(10),			--�ʼ������˹���
	@signName nvarchar(20),			--ǩ��������
	@signBody nvarchar(4000),		--ǩ����Ƶ�HTML

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�޸ĵ�ǩ���Ƿ����
	declare @count as int
	set @count=(select count(*) from signInfo where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from signInfo where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update signInfo
	set mailerID = @mailerID, signName = @signName, signBody = @signBody,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where rowNum = @rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�ǩ��', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸���ǩ��['+str(@rowNum)+']��')
GO
--����:
declare	@Ret		int
declare	@modiTime smalldatetime

drop PROCEDURE delSignInfo
/*
	name:		delSignInfo
	function:	26.ɾ��ָ����ǩ��
	input: 
				@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
				@delManID varchar(10) output,	--ɾ���ˣ������ǰǩ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ǩ�������ڣ�2��Ҫɾ����ǩ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-30
	UpdateDate: 

*/
create PROCEDURE delSignInfo
	@rowNum int,					--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�к�
	@delManID varchar(10) output,	--ɾ���ˣ������ǰǩ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�޸ĵ�ǩ���Ƿ����
	declare @count as int
	set @count=(select count(*) from signInfo where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @mailerID varchar(10)		--�ʼ������˹���
	declare @signName nvarchar(20)		--ǩ��������
	select @thisLockMan = isnull(lockManID,''), @mailerID=mailerID, @signName = signName 
	from signInfo where rowNum = @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete signInfo where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ǩ��', '�û�' + @delManName
												+ 'ɾ����['+@mailerID+']��ǩ��['+@signName+']��')

GO





select rowNum, mailerID, mailServer, mailServerPort, mailAddr, loginPSW, usedSSL,
	SMTPServer, SMTPUsedSSL, isDefaultSMTP,
	--������IMAPЭ���Ӧ�ķ������ļ��У�
	inBoxFolder, outBoxFolder, sketchBoxFolder, trashBoxFolder, deletedBoxFolder, adBoxFolder, subscribeBoxFolder
from mailBindOption
where isnull(inBoxFolder,'') <>''




select rowNum, mailerID, mailServer, mailServerPort, mailAddr, loginPSW, usedSSL, 
SMTPServer, SMTPUsedSSL, isDefaultSMTP,outBoxFolder folder 
from mailBindOption where mailerID='G201300040' and isnull(outBoxFolder,'') <>'' 
order by rowNum
use hustOA
delete mailList
select * from mailList where messageID='1320997305' order by messageID desc
select * from mailAddrList

select * from mailBindOption


-------------------------------------------������ϵ�˵Ĵ洢����------------------------------------------


drop PROCEDURE checkContactsGroupName
/*
	name:		checkContactsGroupName
	function:	30.���ָ���ķ������Ƿ��Ѿ�����
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@groupName nvarchar(30),	--��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE checkContactsGroupName
	@mailerID varchar(10),		--�ʼ������˹���
	@groupName nvarchar(30),	--��������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count int
	set @count = (select count(*) from contactsGroup where groupName = @groupName and mailerID = @mailerID)
	set @Ret = @count
GO

drop PROCEDURE addContactsGroup
/*
	name:		addContactsGroup
	function:	31.�����ϵ�˷���
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@groupName nvarchar(30),	--��������
				@notes nvarchar(300),		--��ע
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���1���÷��������Ѿ����ڣ�9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE addContactsGroup
	@mailerID varchar(10),		--�ʼ������˹���
	@groupName nvarchar(30),	--��������
	@notes nvarchar(300),		--��ע

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�����������Ƿ�Ψһ��
	declare @count int
	set @count = ISNULL((select count(*) from contactsGroup where groupName = @groupName and mailerID=@mailerID),0)
	if (@count >0)
	begin
		set @Ret = 1
		return
	end
	
	--ȡ�����˵�������
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @mailerID),'')
	
	insert contactsGroup(mailerID, groupName, notes)
	values(@mailerID, @groupName, @notes)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @creater, GETDATE(), '�����ϵ�˷���', 'ϵͳ�����û�' + @creater + 
					'��Ҫ���������ϵ�˷���['+@groupName+']��')
GO
--���ԣ�
declare	@Ret		int 
exec dbo.addContactsGroup 'G201300004','�ҵ�ͬѧ','�����ҵ�ͬѧ�ķ���', @Ret output
exec dbo.addContactsGroup 'G201300004','�ҵļ���','�����ҵ�����', @Ret output
exec dbo.addContactsGroup 'G201300004','�ҵ���ѧͬѧ','�����ҵ�ͬѧ�ķ���', @Ret output

select * from contactsGroup
select * from userInfo where sysUserName='zml'


drop PROCEDURE addContacter
/*
	name:		addContacter
	function:	32.��ӳ�����ϵ��
	input: 
				@mailerID varchar(10),		--����:�ʼ������˹���
				@groupID int,				--����ţ�����û��ǿ�����ӵ������������ϵ�˲���Ԥ����ķ�����.0��ʾû�з���
				@mailerName nvarchar(30),	--�ʼ���ַ����
				@eMailAddr varchar(128),	--����:�ʼ���ַ
				@isShared smallint,			--�Ƿ����0->������1->����
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���1������ϵ���Ѿ����ڣ�9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE addContacter
	@mailerID varchar(10),		--����:�ʼ������˹���
	@groupID int,				--����ţ�����û��ǿ�����ӵ������������ϵ�˲���Ԥ����ķ�����.0��ʾû�з���
	@mailerName nvarchar(30),	--�ʼ���ַ����
	@eMailAddr varchar(128),	--����:�ʼ���ַ
	@isShared smallint,			--�Ƿ����0->������1->����

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count >0)
	begin
		set @Ret = 1
		return
	end

	--��ȡ��������
	declare @groupName nvarchar(30)	--��������
	set @groupName = ISNULL((select groupName from contactsGroup where groupID=@groupID),'')
	if (@groupName='')
		set @groupID = 0
	
	--ȡ�����˵�������
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @mailerID),'')
	
	insert mailContacts(mailerID, groupID, groupName, mailerName, eMailAddr, isShared, createrID, creater)
	values(@mailerID, @groupID, @groupName, @mailerName, @eMailAddr, @isShared, @mailerID, @creater)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @creater, GETDATE(), '��ӳ�����ϵ��', 'ϵͳ�����û�' + @creater + 
					'��Ҫ������˳�����ϵ��['+@mailerName+']��')
GO
--���ԣ�
declare	@Ret		int 
exec dbo.addContacter 'G201300004',1,'¬έ','lw_bk@163.com',0,@Ret output
exec dbo.addContacter 'G201300004',2,'������','zxh@163.com',0,@Ret output
declare	@Ret		int 
exec dbo.addContacter 'G201300004',0,'��XX','zxx@163.com',0,@Ret output
declare	@Ret		int 
exec dbo.addContacter 'G201300004',0,'�Ź���','zgx@163.com',0,@Ret output

select * from mailContacts


drop PROCEDURE updateContactsGroup
/*
	name:		updateContactsGroup
	function:	33.�޸���ϵ�˷���ķ������뱸ע
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@groupID int,				--�����
				@groupName nvarchar(30),	--��������
				@notes nvarchar(300),		--��ע
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���1���÷��鲻���ڣ�9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE updateContactsGroup
	@mailerID varchar(10),		--�ʼ������˹���
	@groupID int,				--�����
	@groupName nvarchar(30),	--��������
	@notes nvarchar(300),		--��ע

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�������Ƿ���ڣ�
	declare @oldGroupName nvarchar(30)	--��������
	set @oldGroupName = ISNULL((select groupName from contactsGroup where mailerID = @mailerID and groupID = @groupID),'')
	if (@oldGroupName = '')
	begin
		set @Ret = 1
		return
	end
	
	--ȡ�޸��˵�������
	declare @updater nvarchar(30)
	set @updater = isnull((select userCName from activeUsers where userID = @mailerID),'')
	
	update contactsGroup
	set groupName = @groupName, notes = @notes
	where mailerID = @mailerID and groupID = @groupID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @updater, GETDATE(), '�޸���ϵ�˷�����Ϣ', 'ϵͳ�����û�' + @updater + 
					'��Ҫ���޸�����ϵ�˷���['+@oldGroupName+']����Ϣ��')
GO

drop PROCEDURE moveContacterToGroup
/*
	name:		moveContacterToGroup
	function:	34.�޸���ϵ�����ڷ��飨�����ӹ�����������ƶ���˽�˵������У�
	input: 
				@mailerID varchar(10),		--����:�ʼ������˹���
				@eMailAddr varchar(128),	--����:�ʼ���ַ
				@groupID int,				--�����

				@moverID varchar(10),		--�ƶ��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���1������ϵ�˲����ڣ�9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE moveContacterToGroup
	@mailerID varchar(10),		--����:�ʼ������˹���
	@eMailAddr varchar(128),	--����:�ʼ���ַ
	@groupID int,				--�����

	@moverID varchar(10),		--�ƶ��˹���

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count =0)
	begin
		set @Ret = 1
		return
	end

	--��ȡ��������
	declare @groupName nvarchar(30)	--��������
	set @groupName = ISNULL((select groupName from contactsGroup where groupID=@groupID),'')
	if (@groupName='')
		set @groupID = 0
	
	if (@mailerID <> @moverID)	--�ӹ����������ƶ���˽�˵�������
	begin
		insert mailContacts(mailerID, groupID, groupName, mailerName, eMailAddr, isShared, createrID, creater)
		select @moverID, @groupID, @groupName, mailerName, @eMailAddr, 0, createrID, creater
		from mailContacts
		where mailerID = @mailerID and eMailAddr = @eMailAddr
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
	end
	else
	begin
		update mailContacts
		set groupID = @groupID, groupName = @groupName
		where mailerID = @mailerID and eMailAddr = @eMailAddr
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
	end
	
	set @Ret = 0

	--ȡ�ƶ��˵�������
	declare @mover nvarchar(30)
	set @mover = isnull((select userCName from activeUsers where userID = @moverID),'')
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@moverID, @mover, GETDATE(), '�ƶ���ϵ�˷���', 'ϵͳ�����û�' + @mover + 
					'��Ҫ����ϵ���ƶ�������['+@groupName+']�С�')
GO

drop PROCEDURE delContactsGroup
/*
	name:		delContactsGroup
	function:	35.ɾ��ָ���ķ��飨���洢���̱�֤����ɾ�����������ϵ�ˣ�
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@groupID int,				--�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ķ��鲻���ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 

*/
create PROCEDURE delContactsGroup
	@mailerID varchar(10),		--�ʼ������˹���
	@groupID int,				--�����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--��ȡ��������
	declare @groupName nvarchar(30)	--��������
	set @groupName = ISNULL((select groupName from contactsGroup where mailerID = @mailerID and groupID = @groupID),'')

	--�ж�Ҫɾ���ķ����Ƿ����
	if (@groupName = '')	--������
	begin
		set @Ret = 1
		return
	end

	begin tran
		delete mailContacts where mailerID = @mailerID and groupID = @groupID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		delete contactsGroup where mailerID = @mailerID and groupID = @groupID
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
	set @delManName = isnull((select userCName from activeUsers where userID = @mailerID),'')


	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @delManName, getdate(), 'ɾ����ϵ�˷���', '�û�' + @delManName
												+ 'ɾ������ϵ�˷���['+@groupName+']��')

GO

drop PROCEDURE delContacter
/*
	name:		delContacter
	function:	36.ɾ��ָ������ϵ��
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@eMailAddr varchar(128),	--��ϵ�ˣ��ʼ���ַ��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ������ϵ�˲����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE delContacter
	@mailerID varchar(10),		--�ʼ������˹���
	@eMailAddr varchar(128),	--��ϵ�ˣ��ʼ���ַ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ������ϵ���Ƿ����
	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	delete mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end    

	set @Ret = 0

	
	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @mailerID),'')


	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@mailerID, @delManName, getdate(), 'ɾ����ϵ��', '�û�' + @delManName
												+ 'ɾ������ϵ��['+@eMailAddr+']��')

GO

drop PROCEDURE shareContacter
/*
	name:		shareContacter
	function:	37.����ȡ������ָ������ϵ��
	input: 
				@mailerID varchar(10),		--�ʼ������˹���
				@eMailAddr varchar(128),	--��ϵ�ˣ��ʼ���ַ��
				@isShared smallint,			--�Ƿ����0->������1->����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ������ϵ�˲����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-02
	UpdateDate: 
*/
create PROCEDURE shareContacter
	@mailerID varchar(10),		--�ʼ������˹���
	@eMailAddr varchar(128),	--��ϵ�ˣ��ʼ���ַ��
	@isShared smallint,			--�Ƿ����0->������1->����

	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ������ϵ���Ƿ����
	declare @count int
	set @count = ISNULL((select count(*) from mailContacts where mailerID = @mailerID and eMailAddr = @eMailAddr),0)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	update mailContacts 
	set isShared = @isShared
	where mailerID = @mailerID and eMailAddr = @eMailAddr
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end    

	set @Ret = 0

	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @mailerID),'')

	--�Ǽǹ�����־��
	if (@isShared=0)
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@mailerID, @modiManName, getdate(), 'ֹͣ������ϵ��', '�û�' + @modiManName + 'ֹͣ�˷�����ϵ��['+@eMailAddr+']��')
	else
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@mailerID, @modiManName, getdate(), '������ϵ��', '�û�' + @modiManName + '��������ϵ��['+@eMailAddr+']��')

GO
--���ԣ�
declare	@Ret		int 
exec dbo.shareContacter 'G201300004','zgx@163.com',1,@Ret output


select * from mailContacts

--������ϵ���б�
select 1 orderID, clgName className, uName groupName, '' mailerID, cName mailerName, e_mail eMailAddr
from userInfo
where isnull(e_mail,'')<>''
union all
select 2, '������ϵ��', g.groupName, m.mailerID, m.mailerName, m.eMailAddr 
from contactsGroup g left join mailContacts m on g.groupID=m.groupID
union all
select 3, '������ϵ��', '', mailerID, mailerName, eMailAddr 
from mailContacts
where isShared=1
union all
select 4, 'δ����', '', mailerID, mailerName, eMailAddr 
from mailContacts
where isnull(groupName,'')=''
order by orderID, className, groupName, cName


select * from contactsGroup


update userInfo
set clgCode='001',clgName='����ǿ�ų���ѧ����'

select * from userInfo



select 1 orderID, clgName className, uName groupName, '' mailerID, cName mailerName, e_mail eMailAddr 
from userInfo 
where isnull(e_mail,'')<>'' 
union all 
select 2, '������ϵ��', g.groupName, m.mailerID, m.mailerName, m.eMailAddr 
from contactsGroup g left join mailContacts m on g.groupID=m.groupID 
where g.mailerID='G201300040' union all select 3, '������ϵ��', '', mailerID, mailerName, eMailAddr from mailContacts where isShared=1 union all select 4, 'δ����', '', mailerID, mailerName, eMailAddr from mailContacts where mailerID='G201300040' and isnull(groupName,'')='' order by orderID, className, groupName, cName



--���ݸ����������������ʼ���ѯ��䣺
select m.mailerID, m.mailAddr, m.folder, m.isSeen, m.isAnswered, m.isFlagged, m.isRecent, m.haveAttach,
m.messageNum, m.messageID, dbo.getEMailAddrInfo(m.mailAddr,m.messageID,1) mailFrom, dbo.getEMailAddrInfo(m.mailAddr,m.messageID,2) mailTo, m.mailSubject,
convert(varchar(19),m.mailReceivedTime,120) mailReceivedTime, m.mailSize
from mailList m
where mailAddr='lw_bk@163.com' and folder='INBOX' 
and messageID in (select messageID from mailAddrList 
				  where fromCCOrTo=1 and eMailAddr='scwang@east-dawn.com.cn' 
					and mailAddr='lw_bk@163.com' and folder='INBOX')

--�ݸ���Ĳ�ѯ��䣺
select * from mailInfo where cast(mTo as varchar(max)) like '%<eMailAddr>huying_52000@sina.com</eMailAddr>%'

