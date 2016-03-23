use hustOA
/*
	ǿ�ų����İ칫ϵͳ-��Ϣ����
	�޸�˵������ԭ��Ϣ���б��޶�Ϊ������ʱͨ����Ϣ��ֻ������Ҫ��ϵͳ��Ϣ������顢ѧ���������������Ϣ��
	��Щ��Ϣ����Ҫϵͳ����Ӧ������������Ϣ��š�
	���ⴴ����ʱͨ����Ϣ��δ���ͼ�ʱ��Ϣ��������Ϣû����Ϣ��ţ�
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 
*/
--1.��������Ϣ���б�
drop table messageInfo
CREATE TABLE messageInfo(
	messageID varchar(12) not null,		--��������Ϣ���,��ϵͳʹ�õ�11000�ź��뷢����������8λ���ڴ���+4λ��ˮ�ţ�
	messageClass int not null,			--��Ϣ��𣺱�ʾ��Ϣ����Դ�������Ϣ
										/*	0	������ѯ����Ϣ
											1	ѯ�ʻش���Ϣ��ע�ᣩ 
											2	������֪ͨ�ͻ�����֤�����Ϣ
											3	����֪ͨ��Ϣ
											4	����ظ���Ϣ
											5	ѧ������֪ͨ��Ϣ
											6	ѧ������ظ���Ϣ
											7	�������Ա���û�������Ϣ
											8	�û�����������Ϣ
											9	Ⱥ�����û�����Ϣ
											10	�û���Ⱥ��Ϣ
											11	��Ϣ������������Ϣ
											99	��ʱͨ����Ϣ��������Ϣ���ڱ��б��У�
											100	�������㲥��Ϣ
										*/
	messageType nvarchar(30) null,		--��Ϣ����
	messageLevel smallint default(1),	--��Ҫ����1~9���ȼ�Խ��Խ��Ҫ����������
	senderID varchar(10) not null,		--�����˹���
	sender nvarchar(30) not null,		--������
	sendTime datetime DEFAULT(GETDATE()),--����ʱ��:���Ƿ����˽���Ϣ������Ϣ���е�ʱ��
	isSend smallint default(0),			--�Ƿ��ͣ�0->δ���ͣ�1->�ѷ���
	isRead smallint default(0),			--�Ƿ��Ķ���0->δ�Ķ���1->���Ķ�
	receiverType int not null,			--��������𣺱�ʾ��Ϣ�����˵����
										/*	0����������
											1���û���
											2�������飩
											3��Ⱥ��
											4�����飩
											5��ѧ�����棩
											9�������û���
											10����֯����-Ժ����
											11����֯����-���ţ�
										*/
	receiverID varchar(12) not null,	--�����˹��ţ�modi by lw 2013-4-13�޸��ֶγ���
	receiver nvarchar(30) not null,		--������
	messageBody nvarchar(4000) null,	--��Ϣ����
 CONSTRAINT [PK_messageInfo] PRIMARY KEY CLUSTERED 
(
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����ʱ��������
CREATE NONCLUSTERED INDEX [IX_meetingInfo] ON [dbo].[messageInfo] 
(
	[sendTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�Ƿ���������
CREATE NONCLUSTERED INDEX [IX_meetingInfo_1] ON [dbo].[messageInfo] 
(
	[isSend] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.��Ϣģ��⣺�������ʱʹ���ֹ�ά��
drop table messageTemplate
CREATE TABLE messageTemplate(
	templateID varchar(12) not null,	--��������Ϣģ����,��ϵͳʹ�õ�11001�ź��뷢����������8λ���ڴ���+4λ��ˮ�ţ�
	templateType nvarchar(30) null,		--��Ϣģ������
	templateBody nvarchar(4000) null,	--��Ϣģ������
 CONSTRAINT [PK_messageTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


select len(NEWID())

--3.��ʱͨѶ��Ϣ�����ʹ��
delete IMessageInfo
drop TABLE IMessageInfo
CREATE TABLE IMessageInfo(
	messageID varchar(36) default(''),	--ȫ��ΨһID�����Ǹ�Ⱥ�鷢�͵���Ϣ���Ƿ�����ֶ�Ҫ����ֵ��Ⱥ������Ϣֻ����һ������
	messageType nvarchar(30) null,		--��Ϣ����
	senderID varchar(10) not null,		--�����˹���
	sender nvarchar(30) not null,		--������
	sendTime datetime DEFAULT(GETDATE()),--����ʱ��
	receiverType int not null,			--��Ϣ��������𣺱�ʾ��Ϣ�����˵���𣬵���Ϣ��ת�����ֻ���ǣ�1���û���
	receiverID varchar(12) not null,	--�����˹��ţ�ע������Ҫ��������û���ID�����͸��������Ⱥ����Ϣ���Ҫת��Ϊ�������Ա
	receiver nvarchar(30) not null,		--������
	--��Ϣ��ԭʼ��Դ��
	srcReceiverType int not null,		--��Ϣ�������ʱ�Ľ��������
										/*	0����������
											1���û���
											2�������飩
											3��Ⱥ��
											4�����飩
											5��ѧ�����棩
											9�������û���
											10����֯����-Ժ����
											11����֯����-���ţ�
										*/
	srcReceiverID varchar(12) not null,	--�����˹���
	srcReceiver nvarchar(30) not null,	--������
	messageBody nvarchar(4000) null,	--��Ϣ����
 CONSTRAINT [PK_IMessageInfo] PRIMARY KEY CLUSTERED 
(
	[receiverType] ASC,
	[receiverID] ASC,
	[sendTime] ASC,
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--4.δ�ʹＴʱͨѶ��Ϣ��
drop TABLE undeliverableIMessageInfo
CREATE TABLE undeliverableIMessageInfo(
	messageID varchar(36) default(''),	--ȫ��ΨһID�����Ǹ�Ⱥ�鷢�͵���Ϣ���Ƿ�����ֶ�Ҫ����ֵ��Ⱥ������Ϣÿ���û�������һ������
	messageType nvarchar(30) null,		--��Ϣ����
	senderID varchar(10) not null,		--�����˹���
	sender nvarchar(30) not null,		--������
	sendTime datetime DEFAULT(GETDATE()),--����ʱ��:���Ƿ����˽���Ϣ������Ϣ���е�ʱ��
	receiverType int not null,			--��Ϣ��������𣺱�ʾ��Ϣ�����˵���𣬵���Ϣ��ת�����ֻ���ǣ�1���û���
	receiverID varchar(12) not null,	--�����˹��ţ�ע������Ҫ��������û���ID�����͸��������Ⱥ����Ϣ���Ҫת��Ϊ�������Ա
	receiver nvarchar(30) not null,		--������
	--��Ϣ��ԭʼ��Դ��
	srcReceiverType int not null,		--��Ϣ�������ʱ�Ľ��������
										/*	0����������
											1���û���
											2�������飩
											3��Ⱥ��
											4�����飩
											5��ѧ�����棩
											9�������û���
											10����֯����-Ժ����
											11����֯����-���ţ�
										*/
	srcReceiverID varchar(12) not null,	--�����˹���
	srcReceiver nvarchar(30) not null,	--������
	messageBody nvarchar(4000) null,	--��Ϣ����
 CONSTRAINT [PK_undeliverableIMessageInfo] PRIMARY KEY CLUSTERED 
(
	[receiverType] ASC,
	[receiverID] ASC,
	[sendTime] ASC,
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE isSend
/*
	name:		isSend
	function:	1.����Ϣ���ó��Ѿ�����(�����̼ƻ���ֹ,������Ϣ�ڻ�ȡ��ͬʱ���Ѿ��궨��!)
	input: 
				@messageID varchar(12),		--��Ϣ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE isSend
	@messageID varchar(12),		--��Ϣ���
	@Ret int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	update messageInfo
	set isSend = 1
	where messageID =  @messageID
	set @Ret = 0
GO

drop PROCEDURE isRead
/*
	name:		isRead
	function:	1.1.����Ϣ���ó��Ѿ��Ķ�(ͬʱҲ������״̬����Ϊ�ѷ���)
	input: 
				@messageID varchar(12),		--��Ϣ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-18
	UpdateDate: 
*/
create PROCEDURE isRead
	@messageID varchar(12),		--��Ϣ���
	@Ret int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	update messageInfo
	set isSend=1, isRead = 1
	where messageID =  @messageID
	set @Ret = 0
GO


drop PROCEDURE getActiveUserIP
/*
	name:		getActiveUserIP
	function:	2.��ȡ��û���IP
	input: 
				@userID varchar(10),		--�û�����
	output: 
				@userIP varchar(40) OUTPUT	--�Ự�ͻ���IP
	author:		¬έ
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE getActiveUserIP
	@userID varchar(10),		--�û�����
	@userIP varchar(40) OUTPUT	--�Ự�ͻ���IP
	WITH ENCRYPTION 
AS
	set @userIP = (select userIP from activeUsers where userID=@userID)
GO


drop PROCEDURE addMessageInfo
/*
	name:		addMessageInfo
	function:	4.�����Ϣ
	input: 
				@messageClass int,			--��Ϣ��𣺱�ʾ��Ϣ����Դ�������Ϣ
											0	������ѯ����Ϣ
											1	ѯ�ʻش���Ϣ��ע�ᣩ 
											2	������֪ͨ�ͻ�����֤�����Ϣ
											3	����֪ͨ��Ϣ
											4	����ظ���Ϣ
											5	ѧ������֪ͨ��Ϣ
											6	ѧ������ظ���Ϣ
											7	�������Ա���û�������Ϣ
											8	�û�����������Ϣ
											9	Ⱥ�����û�����Ϣ
											10	�û���Ⱥ��Ϣ
											11	��Ϣ������������Ϣ
											99	��ʱͨ����Ϣ��������Ϣ���ڱ��б��У�
											100	�������㲥��Ϣ
				@messageType nvarchar(30),	--��Ϣ����
				@messageLevel smallint,		--��Ҫ����1~9���ȼ�Խ��Խ��Ҫ����������
				@senderID varchar(12),		--�����˹���
				@receiverType int,			--��������𣺱�ʾ��Ϣ�����˵����
													/*	0����������
														1���û���
														2�������飩
														3��Ⱥ��
														4�����飩
														5��ѧ�����棩
														9�������û���
														10����֯����-Ժ����
														11����֯����-���ţ�
													*/
				@receiverID varchar(12),	--�����˹���
				@messageBody nvarchar(4000),--��Ϣ����
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@messageID varchar(12) output--��������Ϣ���,��ϵͳʹ�õ�11000�ź��뷢����������8λ���ڴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-1
	UpdateDate: modi by lw 2013-4-13������Ϣ���ͽ���������ֶ�
*/
create PROCEDURE addMessageInfo
	@messageClass int,			--��Ϣ��𣺱�ʾ��Ϣ����Դ�������Ϣ
	@messageType nvarchar(30),	--��Ϣ����
	@messageLevel smallint,		--��Ҫ����1~9���ȼ�Խ��Խ��Ҫ����������
	@senderID varchar(12),		--�����˹���
	@receiverType int,			--��������𣺱�ʾ��Ϣ�����˵����
	@receiverID varchar(12),	--�����˹���
	@messageBody nvarchar(4000),--��Ϣ����
	@Ret		int output,
	@messageID varchar(12) output--��������Ϣ���,��ϵͳʹ�õ�11000�ź��뷢����������8λ���ڴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢����������Ϣ��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 11000, 1, @curNumber output
	set @messageID = @curNumber

	--ȡ������/����������
	declare @sender nvarchar(30), @receiver nvarchar(30)		--������/������
	set @sender = isnull((select cName from userInfo where jobNumber=@senderID),'')
	set @receiver = isnull((select cName from userInfo where jobNumber=@receiverID),'')
	
	declare @sendTime smalldatetime
	set @sendTime = getdate()	--����ʱ��
	insert messageInfo(messageClass, messageID, messageType, messageLevel, senderID, sender, receiverType, receiverID, receiver, messageBody)
	values(@messageClass,@messageID, @messageType, @messageLevel, @senderID, @sender, @receiverType, @receiverID, @receiver, @messageBody)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO
--���ԣ�
declare	@Ret		int
declare	@messageID varchar(12)
declare @InviteForm nvarchar(2000)
set @InviteForm = 
N'<root>
	<groupID>201304130001</groupID>
	<groupName>����Ⱥ</groupName>
	<cmdType>Invite</cmdType>
	<applyID>201304130001</applyID> 
</root>'
exec addMessageInfo 9,'Ⱥ���뺯', 9, 'G201300007', 1, '0000000000', 
	@InviteForm,
	@Ret output, @messageID output
select @Ret, @messageID

select * from messageInfo
use hustOA
select * from userInfo
select * from activeUsers

--����ļ�����Ϣģ�壺
--1.����֪ͨ
--2.����ʱ����֪ͨ
--3.���鳡�ر��֪ͨ
--4.����ȡ��֪ͨ
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130001','����֪ͨ','<h3>����֪ͨ</h3><br /><p>������{meetingTime}�μӡ�{topic}�����顣'+
					'</p>���������:<a target="_blank" href=''http://www.oridway.com''>{meetingID}����</a>')
					
select * from messageTemplate
where templateID='MB20130001'

select * from messageInfo

update messageInfo
set isSend = 0




--��Ϣ����������ϲ�ѯ��䣺
select 1 iType, messageID id, messageType topic, sendTime theTime, isRead iStatus 
from messageInfo
where day(sendTime)=DAY(GETDATE())
union all
select 2, taskID, topic, taskStartTime, case isOver 
										when 1 then 9	--���������
										else case 
											 when DATEDIFF(s,getdate(), taskStartTime) > 0  then 0	--δ��ʱ����
											 else 1	--��ʱ����
											 end
										end 
from taskInfo
where day(taskStartTime) = DAY(getdate())
order by theTime



select * from taskInfo



use hustOA
select messageID, messageType, messageLevel, 
	senderID, sender, convert(varchar(19),sendTime,120) sendTime, 
	isSend, isRead, receiverID, receiver, messageBody
from messageInfo


--����ģ�壺
use hustOA
select * from messageTemplate
delete messageTemplate
--����֪ͨ:
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130001','����֪ͨ',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">����֪ͨ</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{InviteMan}��ʦ/ѧ����������{meetingTime}�μӡ�{meetingTopic}�����顣</p>
		<p style="text-indent:24px; line-height:30px;">���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a></p>
	</html>
</root>'
)

--������֪ͨ:
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130002','������֪ͨ',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">������֪ͨ</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{InviteMan}��ʦ/ѧ����ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}������</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">���б���������£�</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{changeInfo}</p>
		<p style="text-indent:24px; line-height:30px;">���������:<a target="_blank" href="{url}">{meetingTopic}����������</a></p>
	</html>
')

--����ȡ��֪ͨ:
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130003','����ȡ��֪ͨ',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">����ȡ��֪ͨ</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{InviteMan}��ʦ/ѧ����ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}����������ȡ����</p>
		<p style="text-indent:24px; line-height:30px;">���������:<a target="_blank" href="{url}">{meetingTopic}����ȡ������</a></p>
	</html>
')

select * from meetingInfo
select * from  messageInfo
use hustOA

delete messageInfo
delete meetingInfo


<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">������֪ͨ</h3>  <p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">��ӱ��ʦ/ѧ����ԭ����2013-01-30 12:00:00��B206�����ٿ��ġ����Ի���֪ͨ������</p>  <p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">���б���������£�</p>  <p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;"></p>  <p style="text-indent:24px; line-height:30px;">���������:<a target="_blank" href="http://localhost:19176/myWeb/meetingManager/meetingNotice/a7dc1a38-b8b0-46c7-9897-926f6f3480aa.html">���Ի���֪ͨ����������</a></p>

select * from SMSInfo

������֪ͨ\r\n  ¬έ��ʦ/ѧ����ԭ����2013-01-30 12:05:00��B206�����ٿ��ġ����Ի���֪ͨ������\r\n  ���б���������£�\r\n  ���������:<a target="_blank" href="http://localhost:19176/myWeb/meetingManager/meetingNotice/260522be-d975-4b36-8436-a32b9f2b4b19.html">���Ի���֪ͨ����������</a>



drop PROCEDURE saveIMessageInfo
/*
	name:		saveIMessageInfo
	function:	5.����ʱͨѶ��Ϣ���浽���ݿ��У����Ƿ�����ͨѶ������ר�ù��̣�
				ע�⣺����Ⱥ�����Ϣʱ��Ҫ����messageID��ϵͳ��ֻ����һ������
	input: 
				@messageID varchar(36),		--ȫ��ΨһID�����Ǹ�Ⱥ�鷢�͵���Ϣ���Ƿ�����ֶ�Ҫ����ֵ��Ⱥ������Ϣֻ����һ������
				@messageType nvarchar(30),	--��Ϣ����
				@senderID varchar(12),		--�����˹���
				@sendTime varchar(19),		--����ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ���
				@receiverType int,			--��Ϣ��������𣺱�ʾ��Ϣ�����˵���𣬵���Ϣ��ת�����ֻ���ǣ�1���û���
				@receiverID varchar(12),	--�����˹��ţ�ע������Ҫ��������û���ID�����͸��������Ⱥ����Ϣ���Ҫת��Ϊ�������Ա
				--��Ϣ��ԭʼ��Դ��
				@srcReceiverType int,		--��Ϣ�������ʱ�Ľ��������
													/*	0����������
														1���û���
														2�������飩
														3��Ⱥ��
														4�����飩
														5��ѧ�����棩
														9�������û���
														10����֯����-Ժ����
														11����֯����-���ţ�
													*/
				@srcReceiverID varchar(12),	--�����˹���
				@srcReceiver nvarchar(30),	--������
				@messageBody nvarchar(4000),--��Ϣ����
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE saveIMessageInfo
	@messageID varchar(36),		--ȫ��ΨһID�����Ǹ�Ⱥ�鷢�͵���Ϣ���Ƿ�����ֶ�Ҫ����ֵ��Ⱥ������Ϣֻ����һ������
	@messageType nvarchar(30),	--��Ϣ����
	@senderID varchar(12),		--�����˹���
	@sendTime varchar(19),		--����ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ���
	@receiverType int,			--��Ϣ��������𣺱�ʾ��Ϣ�����˵���𣬵���Ϣ��ת�����ֻ���ǣ�1���û���
	@receiverID varchar(12),	--�����˹��ţ�ע������Ҫ��������û���ID�����͸��������Ⱥ����Ϣ���Ҫת��Ϊ�������Ա
	--��Ϣ��ԭʼ��Դ��
	@srcReceiverType int,		--��Ϣ�������ʱ�Ľ��������
	@srcReceiverID varchar(12),	--�����˹���
	@srcReceiver nvarchar(30),	--������
	@messageBody nvarchar(4000),--��Ϣ����
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--��ΪȺ����Ϣʱ���messageID��ϵͳ��ֻ����һ��������
	if (@srcReceiverType<>1 and @messageID<>'')
	begin
		declare @count int
		set @count = (select count(*) from IMessageInfo where messageID=@messageID)
		if (@count>0)
		begin
			set @Ret =0
			return
		end
	end
	--ȡ������/����������
	declare @sender nvarchar(30), @receiver nvarchar(30)		--������/������
	set @sender = isnull((select cName from userInfo where jobNumber=@senderID),'')
	set @receiver = isnull((select cName from userInfo where jobNumber=@receiverID),'')
	
	insert IMessageInfo(messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
					srcReceiverType, srcReceiverID, srcReceiver, messageBody)
	values(@messageID, @messageType, @senderID, @sender, @sendTime, @receiverType, @receiverID, @receiver, 
					@srcReceiverType, @srcReceiverID, @srcReceiver, @messageBody)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO
declare @Ret		int 
exec dbo.saveIMessageInfo '123','����','G201300040','2013-04-17',2,'G201300040',2,'201304150009','������','����',@Ret output
select @Ret
select * from IMessageInfo

drop PROCEDURE saveUndeliverableIMessageInfo
/*
	name:		saveUndeliverableIMessageInfo
	function:	6.��δ�ʹＴʱͨѶ��Ϣ���浽���ݿ��У����Ƿ�����ͨѶ����������ҳ��������Ϣ��ר�ù��̣�
	input: 
				@messageID varchar(36),		--ȫ��ΨһID�����Ǹ�Ⱥ�鷢�͵���Ϣ���Ƿ�����ֶ�Ҫ����ֵ��Ⱥ������Ϣֻ����һ������
				@messageType nvarchar(30),	--��Ϣ����
				@senderID varchar(12),		--�����˹���
				@receiverType int,			--��Ϣ��������𣺱�ʾ��Ϣ�����˵���𣬵���Ϣ��ת�����ֻ���ǣ�1���û���
				@receiverID varchar(12),	--�����˹��ţ�ע������Ҫ��������û���ID�����͸��������Ⱥ����Ϣ���Ҫת��Ϊ�������Ա
				--��Ϣ��ԭʼ��Դ��
				@srcReceiverType int,		--��Ϣ�������ʱ�Ľ��������
													/*	0����������
														1���û���
														2�������飩
														3��Ⱥ��
														4�����飩
														5��ѧ�����棩
														9�������û���
														10����֯����-Ժ����
														11����֯����-���ţ�
													*/
				@srcReceiverID varchar(12),	--�����˹���
				@srcReceiver nvarchar(30),	--������
				@messageBody nvarchar(4000),--��Ϣ����
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE saveUndeliverableIMessageInfo
	@messageID varchar(36),		--ȫ��ΨһID�����Ǹ�Ⱥ�鷢�͵���Ϣ���Ƿ�����ֶ�Ҫ����ֵ��Ⱥ������Ϣֻ����һ������
	@messageType nvarchar(30),	--��Ϣ����
	@senderID varchar(12),		--�����˹���
	@receiverType int,			--��Ϣ��������𣺱�ʾ��Ϣ�����˵���𣬵���Ϣ��ת�����ֻ���ǣ�1���û���
	@receiverID varchar(12),	--�����˹��ţ�ע������Ҫ��������û���ID�����͸��������Ⱥ����Ϣ���Ҫת��Ϊ�������Ա
	--��Ϣ��ԭʼ��Դ��
	@srcReceiverType int,		--��Ϣ�������ʱ�Ľ��������
	@srcReceiverID varchar(12),	--�����˹���
	@srcReceiver nvarchar(30),	--������
	@messageBody nvarchar(4000),--��Ϣ����
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ������/����������
	declare @sender nvarchar(30), @receiver nvarchar(30)		--������/������
	set @sender = isnull((select cName from userInfo where jobNumber=@senderID),'')
	set @receiver = isnull((select cName from userInfo where jobNumber=@receiverID),'')
	
	insert undeliverableIMessageInfo(messageID, messageType, senderID, sender, receiverType, receiverID, receiver,
					srcReceiverType, srcReceiverID, srcReceiver, messageBody)
	values(@messageID, @messageType, @senderID, @sender, @receiverType, @receiverID, @receiver,
					@srcReceiverType, @srcReceiverID, @srcReceiver, @messageBody)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO
select * from IMessageInfo
--���ԣ�
declare @Ret		int 
exec dbo.saveUndeliverableIMessageInfo '123','����','G201300040',2,'G201300040',2,'201304150009','������','����',@Ret output
select @Ret
select * from undeliverableIMessageInfo

drop PROCEDURE getUndeliverableIMessageInfo
/*
	name:		getUndeliverableIMessageInfo
	function:	7.��ȡָ���û�����һ��ָ���û������顢Ⱥ����δ�ʹＴʱͨѶ��Ϣ������Ϣת�浽�ѷ����б���
				ע�⣺��������ֻ��δ�ʹ�ļ�ʱͨѶ��Ϣ����
	input: 
				@senderID varchar(12),			--�����˹���
				@userID varchar(10),			--��ѯ�˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE getUndeliverableIMessageInfo
	@senderID varchar(12),		--�����˹���
	@userID varchar(10),		--��ѯ�˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	select messageID, 99 messageClass, messageType, 9 messageLevel,
		senderID, sender, convert(varchar(19),sendTime,120) sendTime,
		receiverType, receiverID, receiver, 
		srcReceiverType, srcReceiverID, srcReceiver, messageBody
	from undeliverableIMessageInfo
	where (senderID = @senderID or (srcReceiverType in (2,3) and srcReceiverID=@senderID)) and receiverID = @userID
	order by sendTime
	
	begin tran
		insert IMessageInfo(messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
							srcReceiverType, srcReceiverID, srcReceiver, messageBody)
		select messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
				srcReceiverType, srcReceiverID, srcReceiver, messageBody
		from undeliverableIMessageInfo
		where (senderID = @senderID or (srcReceiverType in (2,3) and srcReceiverID=@senderID)) and receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		delete undeliverableIMessageInfo where (senderID = @senderID or (srcReceiverType in (2,3) and srcReceiverID=@senderID)) and receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0
GO
--���ԣ�
declare	@Ret		int
exec dbo.getUndeliverableIMessageInfo '201304150009','0000000000',@Ret output
select @Ret

select * from undeliverableIMessageInfo

drop PROCEDURE getAllUndeliverableIMessageInfo
/*
	name:		getAllUndeliverableIMessageInfo
	function:	7.1��ȡָ���û���δ�ʹＴʱͨѶ��Ϣ������Ϣת�浽�ѷ����б���
				ע�⣺��������ֻ��δ�ʹ�ļ�ʱͨѶ��Ϣ����(�������û���)��������Ϣ������ר�ù���
	input: 
				@userID varchar(10),			--��ѯ�˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE getAllUndeliverableIMessageInfo
	@userID varchar(10),		--��ѯ�˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	select messageID, 99 messageClass, messageType, 9 messageLevel,
		senderID, sender, convert(varchar(19),sendTime,120) sendTime,
		receiverType, receiverID, receiver, 
		srcReceiverType, srcReceiverID, srcReceiver, messageBody
	from undeliverableIMessageInfo
	where receiverID = @userID
	order by sendTime
	
	begin tran
		insert IMessageInfo(messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
							srcReceiverType, srcReceiverID, srcReceiver, messageBody)
		select messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
				srcReceiverType, srcReceiverID, srcReceiver, messageBody
		from undeliverableIMessageInfo
		where receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		delete undeliverableIMessageInfo where receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0
GO

--���ԣ�
declare @ret int
exec dbo.getAllUndeliverableIMessageInfo 'G201300040',@ret output
select @ret

select * from IMessageInfo



drop PROCEDURE clearIMessageInfo
/*
	name:		clearIMessageInfo
	function:	8.���ָ���û��ļ�ʱͨѶ��Ϣ
	input: 
				@userID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE clearIMessageInfo
	@userID varchar(10),		--�����˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete IMessageInfo where receiverID = @userID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	--ȡά���˵�������
	declare @userName nvarchar(30)
	set @userName = isnull((select userCName from activeUsers where userID = @userID),'')
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userName, GETDATE(), '�����ʱͨѶ��Ϣ', '�û�' + @userName
												+ '������Լ��ļ�ʱͨѶ��Ϣ��')
	set @Ret = 0
GO



--��ȡ��ʷ��Ϣ��
select '', 99, messageType, 9,
	senderID, sender, convert(varchar(19),sendTime,120) sendTime,
	receiverType, receiverID, receiver, srcReceiverType, srcReceiverID, srcReceiver, messageBody
from IMessageInfo
--where receiverID = @userID
order by sendTime


--��ȡδ����Ϣ֮�û��б�
select distinct senderID, sender from undeliverableIMessageInfo
where srcReceiverType = 1
union all
select distinct srcReceiverID, srcReceiver from undeliverableIMessageInfo
where srcReceiverType in (2,3)
order by senderID


delete systemInfo
select * from systemInfo
select * from userInfo
select * from undeliverableIMessageInfo
select * from IMessageInfo
delete IMessageInfo
delete undeliverableIMessageInfo

delete communityGroup
select * from messageInfo
delete messageInfo where messageID<'201304180399'

select * from discussGroup
select * from discussGroupMember where discussID='201304180001'
delete discussGroupMember where rowNum=261



select * from IMessageInfo i
where ((senderID = '201304150009' or (srcReceiverType in (2,3) and srcReceiverID='201304150009')) and receiverID = 'G201300238')
or ((receiverID = '201304150009' or (srcReceiverType in (2,3) and srcReceiverID='201304150009')) and senderID = 'G201300238')


select * from communityGroup
select * from communityGroupMember
select * from communityGroupApply
select * from messageInfo

select * from undeliverableIMessageInfo where srcReceiverID='201304150009' and receiver='���'


select * from messageInfo
select * from IMessageInfo order by sendTime desc
select * from IMessageInfo order by sendTime
select * from undeliverableIMessageInfo

delete messageInfo
delete IMessageInfo
delete systemInfo
delete activeUsers
delete undeliverableIMessageInfo

select * from undeliverableIMessageInfo
order by sendTime desc
select * from IMessageInfo 
order by sendTime desc
where sender='�︻��'
order by messageID


select * from undeliverableIMessageInfo

select * from systemInfo
select * from activeUsers
select * from userInfo

select * from workNote order by actionTime desc
delete workNote