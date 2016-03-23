use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�������
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 
*/
--1.��������
select * from meetingInfo where meetingID='HY20130341'
select * from eqpApplyDetail
select * from eqpBorrowApplyInfo where linkInvoice='HY20130341'

select * from placeApplyInfo

alter TABLE meetingInfo add	remindBefore int default(15)		--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15���� add by lw 2013-07-11
alter TABLE meetingInfo add	noticeTemplateUrl varchar(128) default('meetingTemplate.html')	--֪ͨ����ģ�� add by lw 2013-07-11
update meetingInfo
set remindBefore=15,noticeTemplateUrl='meetingTemplate.html'

exec sp_rename 'meetingInfo.reportPlaceID','placeID','column';
exec sp_rename 'meetingInfo.reportPlace','place','column';
select * from meetingInfo
drop table meetingInfo
CREATE TABLE meetingInfo(
	meetingID varchar(10) not null,		--������������,��ϵͳʹ�õ�251�ź��뷢����������'HY'+4λ��ݴ���+4λ��ˮ�ţ�
	topic  nvarchar(40) null,			--��������
	organizerID varchar(10) null,		--���鷢���˹���
	organizer nvarchar(30) null,		--���鷢�����������������
	meetingStartTime smalldatetime null,--���鿪ʼʱ��
	meetingEndTime smalldatetime null,	--����Ԥ�ƽ���ʱ��
	summary nvarchar(300) null,			--����ժҪ(�������)
	
	placeID varchar(10) null,		--����ص�ı�ʶ�ţ�����ID��
	place nvarchar(60) null,		--����ص�
	placeIsReady smallint default(0),	--������Ҫ�ĳ����Ƿ�׼���ã�0->δ׼���ã�1->׼������
	
	needEqpCodes varchar(80) null,		--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
	needEqpNames nvarchar(300) null,	--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�
	eqpIsReady smallint default(0),		--������Ҫ���豸�Ƿ�׼���ã�0->δ׼���ã�1->׼������

	needSMSInvitation smallint default(0),--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ add by lw 2013-1-3
	remindBefore int default(15),		--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15���� add by lw 2013-07-11
	needSMSRemind smallint default(0),	--�Ƿ���Ҫ�������ѣ�����ǰ1Сʱ���ѣ���0->����Ҫ��1->��Ҫ add by lw 2013-1-3
	
	noticeTemplateUrl varchar(128) defalut('meetingTemplate.html'),	--֪ͨ����ģ�� add by lw 2013-07-11
	meetingNoticeUrl varchar(128) null,	--��ǰ����֪ͨ��ҳ��·�� add by lw 2013-1-29
	isPublish smallint default(0),		--�Ƿ��Ѿ�����������֪ͨ����0->δ������1->�ѷ��� add by lw 2013-1-29
	
	--ͳ�����ݣ�
	InviteManNum int default(0),		--��������������
	replyManNum int default(0),			--�ظ�������
	replyOKManNum int default(0),		--�ظ��μ�����
	enterManNum int default(0),			--ʵ�ʲμ�����
	
	isOver smallint default(0),			--�Ƿ���������0->δ������1->�������
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_meetingInfo] PRIMARY KEY CLUSTERED 
(
	[meetingID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--���鿪ʼʱ��������
CREATE NONCLUSTERED INDEX [IX_meetingInfo] ON [dbo].[meetingInfo] 
(
	[meetingStartTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�����Ƿ����������
CREATE NONCLUSTERED INDEX [IX_meetingInfo_1] ON [dbo].[meetingInfo] 
(
	[isOver] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from meetingInfo
select * from AReportEnterMans

--2.����������Ա��
select * from meetingEnterMans where meetingID='HY20130166'
use hustOA
update meetingEnterMans
set isSendMsg = 1
alter TABLE meetingEnterMans add taskID varchar(10) null			--���������������� add by lw 2013-07-12 �������ֻ�ڴ洢�����ڲ�ά��

drop table meetingEnterMans
CREATE TABLE meetingEnterMans(
	rowNum int IDENTITY(1,1) NOT NULL,	--��ţ�����ʹ��
	meetingID varchar(10) not null,		--�����������
	--topic  nvarchar(40) null,			--���⣺�������del by lw 2013-1-3webservice�ӿ�δ��
	
	InviteManID varchar(10) not null,	--������Ա����
	InviteMan nvarchar(30) not null,	--������Ա�������������
	isSendMsg smallint default(0),		--֪ͨ�Ƿ��Ѿ����ͣ�0->δ���ͣ�1->�ѷ���
	sendTime smalldatetime null,		--����֪ͨ�ʹ�ʱ��
	isReadMsg smallint default(0),		--֪ͨ�Ƿ��Ѿ��Ķ���0->δ�Ķ���1->���Ķ�
	readTime smalldatetime null,		--����֪ͨ�Ķ�ʱ��
	
	replyTime smalldatetime null,		--�ظ�ʱ��
	isEnter smallint default(0),		--�Ƿ�μӣ�0->δ֪��1->�μӣ�-1->���μ�
	taskID varchar(10) null,			--���������������� add by lw 2013-07-12 �������ֻ�ڴ洢�����ڲ�ά��
	--replyOpinion nvarchar(300) null,	--�ظ����:del by lw 2013-1-3��Ϊ�ж�λظ������������Ƴ�һ�������ı�
	
	checkManID varchar(10) null,		--�����˹���
	checkMan nvarchar(30) null,			--����������
	arriveTime smalldatetime null,		--����ʱ��
	isLate smallint default(0),			--�Ƿ�ٵ���0->δ���1->�������-1->�ٵ�
 CONSTRAINT [PK_meetingEnterMans] PRIMARY KEY CLUSTERED 
(
	[meetingID] ASC,
	[InviteManID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[meetingEnterMans] WITH CHECK ADD CONSTRAINT [FK_meetingEnterMans_meetingInfo] FOREIGN KEY([meetingID])
REFERENCES [dbo].[meetingInfo] ([meetingID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[meetingEnterMans] CHECK CONSTRAINT [FK_meetingEnterMans_meetingInfo]
GO

--3.����ظ�������μӻ�����Ա���Զ�λظ���һ������Ҫ�����������޷�������ʷ���ݣ�
drop TABLE meetingManDiscussInfo
CREATE TABLE meetingManDiscussInfo(
	rowNum int IDENTITY(1,1) NOT NULL,	--��ţ�����ʹ��
	meetingID varchar(10) not null,		--������������
	replyTime smalldatetime null,		--�ظ�ʱ��
	
	InviteManID varchar(10) not null,	--�����������ˣ������ˣ�����
	InviteMan nvarchar(30) not null,	--�����ˣ������ˣ��������������
	isEnter smallint default(0),		--�Ƿ�μӣ�0->δ֪��1->�μӣ�-1->���μ�
	replyOpinion nvarchar(300) null,	--�ظ����
CONSTRAINT [PK_meetingManDiscussInfo] PRIMARY KEY CLUSTERED 
(
	[meetingID] ASC,
	[rowNum] ASC,
	[InviteManID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--4.���鷢��ģ���
drop TABLE meetingNoticeTemplate
CREATE TABLE meetingNoticeTemplate(
	rowNum int IDENTITY(1,1) NOT NULL,	--��ţ�����ʹ��
	templateName nvarchar(30) not null,	--ģ������
	url varchar(128) not null,			--ģ��ҳ���ļ�·��
CONSTRAINT [PK_meetingNoticeTemplate] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select templateName,url from meetingNoticeTemplate order by rowNum

--����ļ�����Ϣģ�壺
--1.����֪ͨ
--2.����ʱ����֪ͨ
--3.���鳡�ر��֪ͨ
--4.����ȡ��֪ͨ

delete messageTemplate
--����֪ͨģ�壺
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130001','����֪ͨ',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">����֪ͨ</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">�װ���{InviteMan}��������{meetingTime}�μӡ�{meetingTopic}�����顣</p>
		<p style="text-indent:24px; line-height:30px;">���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a></p>
	</html>
</root>')
--������֪ͨģ�壺
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130002','������֪ͨ',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">������֪ͨ</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">�װ���{InviteMan}��
		ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}������</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">���б���������£�</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{changeInfo}</p>
		<p style="text-indent:24px; line-height:30px;">���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a></p>
	</html>  
</root>')
--����ȡ��֪ͨģ�壺
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130003','����ȡ��֪ͨ',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">����ȡ��֪ͨ</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">�װ���{InviteMan}��
		ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}����������ȡ����</p>
		<p style="text-indent:24px; line-height:30px;">���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a></p>
	</html>
</root>')

select * from SMSTemplate
delete SMSTemplate
--����֪ͨģ��:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130001','����֪ͨ',
N'����֪ͨ'+ char(13)+char(10)+
'�װ���{InviteMan}��������{meetingTime}�μӡ�{meetingTopic}�����顣'+ char(13)+char(10)+
'���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a>')
--������֪ͨ:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130002','������֪ͨ',
N'������֪ͨ'+ char(13)+char(10)+
'�װ���{InviteMan}��ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}������'+ char(13)+char(10)+
'���б���������£�{changeInfo}'+ char(13)+char(10)+
'���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a>')

--����ȡ��֪ͨ:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130003','����ȡ��֪ͨ',
N'����ȡ��֪ͨ'+ char(13)+char(10)+
'�װ���{InviteMan}��ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}����������ȡ����'+ char(13)+char(10)+
'���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a>')

	
drop PROCEDURE querymeetingInfoLocMan
/*
	name:		querymeetingInfoLocMan
	function:	1.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@meetingID varchar(10),			--������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ļ��鲻����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 
*/
create PROCEDURE querymeetingInfoLocMan
	@meetingID varchar(10),			--������
	@Ret int output,				--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	set @Ret = 0
GO


drop PROCEDURE lockmeetingInfo4Edit
/*
	name:		lockmeetingInfo4Edit
	function:	2.��������༭������༭��ͻ
	input: 
				@meetingID varchar(10),			--������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ļ��鲻���ڣ�2:Ҫ�����Ļ������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 
*/
create PROCEDURE lockmeetingInfo4Edit
	@meetingID varchar(10),			--������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update meetingInfo
	set lockManID = @lockManID 
	where meetingID= @meetingID
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '��������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˻���['+ @meetingID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockmeetingInfoEditor
/*
	name:		unlockmeetingInfoEditor
	function:	3.�ͷŻ���༭��
				ע�⣺�����̲��������Ƿ���ڣ�
	input: 
				@meetingID varchar(10),			--������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 
*/
create PROCEDURE unlockmeetingInfoEditor
	@meetingID varchar(10),			--������
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update meetingInfo set lockManID = '' where meetingID= @meetingID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŻ���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˻���['+ @meetingID +']�ı༭����')
GO

drop PROCEDURE addMeetingInfo
/*
	name:		addMeetingInfo
	function:	4.��ӻ�����Ϣ
	input: 
				@topic  nvarchar(40),			--��������
				@organizerID varchar(10),		--���鷢���˹���
				@meetingStartTime varchar(19),	--���鿪ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@meetingEndTime varchar(19),	--����Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@summary nvarchar(300),			--����ժҪ(�������)
				
				@placeID varchar(10),		--����ص�ı�ʶ�ţ�����ID��
				@place nvarchar(60),		--����ص�
				
				@needEqpCodes varchar(80),		--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
				@needEqpNames nvarchar(300),	--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

				@noticeTemplateUrl varchar(128),--֪ͨ����ģ�� add by lw 2013-07-11
				@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
				@remindBefore int,				--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15���� add by lw 2013-07-11
				@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�����ǰ1Сʱ���ѣ���0->����Ҫ��1->��Ҫ

				@meetingEnterMans xml,			--��������μ���N'<root>
																--	<row id="1">
																--		<InviteManID>00001</InviteManID>
																--	</row>
																--	<row id="2">
																--		<InviteManID>00002</InviteManID>
																--	</row>
																--	...
																--</root>'
				--@meetingNoticeUrl varchar(128),	--��ǰ����֪ͨ��ҳ��·�� add by lw 2013-1-29 ���Ӧ���Ƿ�����ʱ��̬���ɣ�

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@meetingID varchar(10) output	--������:��ϵͳʹ�õ�251�ź��뷢����������'HY'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-3���Ӷ��Žӿ�
				modi by lw 2013-1-29���ӻ���֪ͨҳ��ӿڲ���
				modi by lw 2013-07-11���ӻ���ģ��֧�ֺ��趨��������ʱ��
*/
create PROCEDURE addMeetingInfo
	@topic  nvarchar(40),			--��������
	@organizerID varchar(10),		--���鷢���˹���
	@meetingStartTime varchar(19),	--���鿪ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@meetingEndTime varchar(19),	--����Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@summary nvarchar(300),			--����ժҪ(�������)
	
	@placeID varchar(10),		--����ص�ı�ʶ�ţ�����ID��
	@place nvarchar(60),		--����ص�
	
	@needEqpCodes varchar(80),		--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
	@needEqpNames nvarchar(300),	--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

	@noticeTemplateUrl varchar(128),--֪ͨ����ģ�� add by lw 2013-07-11
	@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
	@remindBefore int,				--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15���� add by lw 2013-07-11
	@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�����ǰ1Сʱ���ѣ���0->����Ҫ��1->��Ҫ

	@meetingEnterMans xml,			--��������μ���N'<root>
													--	<row id="1">
													--		<InviteManID>00001</InviteManID>
													--	</row>
													--	<row id="2">
													--		<InviteManID>00002</InviteManID>
													--	</row>
													--	...
													--</root>'
	--@meetingNoticeUrl varchar(128),	--��ǰ����֪ͨ��ҳ��·�� add by lw 2013-1-29 ���Ӧ���Ƿ�����ʱ��̬���ɣ�

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@meetingID varchar(10) output	--������:��ϵͳʹ�õ�251�ź��뷢����������'HY'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�������������ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 251, 1, @curNumber output
	set @meetingID = @curNumber

	--ȡ�����ˡ������˵�������
	declare @organizer nvarchar(30)		--���鷢�����������������
	set @organizer = isnull((select cName from userInfo where jobNumber = @organizerID),'')
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	begin tran
		insert meetingInfo(meetingID, topic, organizerID, organizer, 
							meetingStartTime, meetingEndTime, summary,
							placeID, place, 
							needEqpCodes, needEqpNames,
							noticeTemplateUrl,needSMSInvitation,
							remindBefore, needSMSRemind,
							--����ά�����:
							modiManID, modiManName, modiTime)
		values(@meetingID, @topic, @organizerID, @organizer, 
						@meetingStartTime, @meetingEndTime, @summary,
						@placeID, @place, 
						@needEqpCodes, @needEqpNames,
						@noticeTemplateUrl,@needSMSInvitation,
						@remindBefore, @needSMSRemind,
						--����ά�����:
						@createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--�Ǽǻ���μ��ˣ�
		insert meetingEnterMans(meetingID, InviteManID, InviteMan)
		select @meetingID, InviteManID, u.cName
		from (select cast(T.x.query('data(./InviteManID)') as varchar(10)) InviteManID 
			from(select @meetingEnterMans.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab left join userInfo u on tab.InviteManID = u.jobNumber
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	
		--����ͳ�����ݣ�
		declare @InviteManNum int
		set @InviteManNum = isnull((select count(*) from meetingEnterMans where meetingID = @meetingID),0)
		update meetingInfo
		set InviteManNum = @InviteManNum
		where meetingID = @meetingID
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
	values(@createManID, @createManName, @createTime, '�Ǽǻ���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ��˻��顰' + @topic + '['+@meetingID+']����')
GO
--����:
declare	@Ret		int
declare	@createTime smalldatetime
declare	@meetingID varchar(10)	--������:��ϵͳʹ�õ�251�ź��뷢����������'HY'+4λ��ݴ���+4λ��ˮ�ţ�
exec dbo.addmeetingInfo '�����������', '00001', '2012-12-29 14:00:00','2012-12-29 16:00:00','����ǿ�ų����İ칫ϵͳ����',
		'001','��˾������', '00000001','ͶӰ��',0,0,
			N'<root>
				<row id="1">
					<InviteManID>G201300001</InviteManID>
				</row>
				<row id="2">
					<InviteManID>G201300007</InviteManID>
				</row>
			</root>',
			'00002',
			@Ret output,
			@createTime output,
			@meetingID output
select @Ret
select * from meetingInfo
select * from meetingEnterMans
select * from userInfo

drop PROCEDURE updateMeetingInfo
/*
	name:		updateMeetingInfo
	function:	5.�޸Ļ�����Ϣ
	input: 
				@meetingID varchar(10),			--������
				@topic  nvarchar(40),			--��������
				@organizerID varchar(10),		--���鷢���˹���
				@meetingStartTime varchar(19),	--���鿪ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@meetingEndTime varchar(19),	--����Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@summary nvarchar(300),			--����ժҪ(�������)
				
				@placeID varchar(10),		--����ص�ı�ʶ�ţ�����ID��
				@place nvarchar(60),		--����ص�
				
				@needEqpCodes varchar(80),		--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
				@needEqpNames nvarchar(300),	--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

				@noticeTemplateUrl varchar(128),--֪ͨ����ģ�� add by lw 2013-07-11
				@meetingNoticeUrl varchar(128),	--��ǰ����֪ͨ��ҳ��·�� add by lw 2013-1-29 ��������Ѿ�������Ҫ����ò���
				@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
				@remindBefore int,				--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15���� add by lw 2013-07-11
				@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�����ǰ1Сʱ���ѣ���0->����Ҫ��1->��Ҫ
				@meetingEnterMans xml,			--��������μ���N'<root>
																--	<row id="1">
																--		<InviteManID>00001</InviteManID>
																--	</row>
																--	<row id="2">
																--		<InviteManID>00002</InviteManID>
																--	</row>
																--	...
																--</root>'

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵĻ��鲻���ڣ�
							2:Ҫ�޸ĵĻ����������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-3���Ӷ��Žӿ�
				modi by lw 2013-1-29���ӻ���֪ͨҳ��ӿڣ����ӻ���������
				modi by lw 2013-07-11���ӻ���ģ��֧�ֺ��趨��������ʱ��
*/
create PROCEDURE updateMeetingInfo
	@meetingID varchar(10),			--������
	@topic  nvarchar(40),			--��������
	@organizerID varchar(10),		--���鷢���˹���
	@meetingStartTime varchar(19),	--���鿪ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@meetingEndTime varchar(19),	--����Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@summary nvarchar(300),			--����ժҪ(�������)
	
	@placeID varchar(10),		--����ص�ı�ʶ�ţ�����ID��
	@place nvarchar(60),		--����ص�
	
	@needEqpCodes varchar(80),		--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
	@needEqpNames nvarchar(300),	--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

	@noticeTemplateUrl varchar(128),--֪ͨ����ģ�� add by lw 2013-07-11
	@meetingNoticeUrl varchar(128),	--��ǰ����֪ͨ��ҳ��·�� add by lw 2013-1-29 ��������Ѿ�������Ҫ����ò���
	@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
	@remindBefore int,				--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15���� add by lw 2013-07-11
	@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�����ǰ1Сʱ���ѣ���0->����Ҫ��1->��Ҫ
	@meetingEnterMans xml,			--��������μ���N'<root>
													--	<row id="1">
													--		<InviteManID>00001</InviteManID>
													--	</row>
													--	<row id="2">
													--		<InviteManID>00002</InviteManID>
													--	</row>
													--	...
													--</root>'

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @oldTopic nvarchar(40)				--��������
	declare @oldOrganizer nvarchar(30)			--���鷢��������
	declare @oldMeetingStartTime smalldatetime	--���鿪ʼʱ��
	declare @oldMeetingEndTime smalldatetime	--����Ԥ�ƽ���ʱ��
	declare @oldSummary nvarchar(300)			--����ժҪ(�������)
	declare @oldPlace nvarchar(60)		--����ص�
	declare @isPublish smallint					--�Ƿ��ѷ���֪ͨ
	select @thisLockMan = isnull(lockManID,''), @oldTopic = topic, @oldOrganizer = organizer,
			@oldMeetingStartTime = meetingStartTime, @oldMeetingEndTime = meetingEndTime,
			@oldSummary = summary, @oldPlace = place, @isPublish = isPublish
	from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡ�����˵�������
	declare @organizer nvarchar(30)
	set @organizer = isnull((select cName from userInfo where jobNumber = @organizerID),'')
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		update meetingInfo
		set topic = @topic, 
			organizerID = @organizerID, organizer = @organizer, 
			meetingStartTime = @meetingStartTime, meetingEndTime = @meetingEndTime, summary = @summary,
			placeID = @placeID, place = @place, 
			needEqpCodes = @needEqpCodes, needEqpNames = @needEqpNames,
			noticeTemplateUrl = @noticeTemplateUrl,	
			meetingNoticeUrl = @meetingNoticeUrl,
			needSMSInvitation = @needSMSInvitation,
			remindBefore = @remindBefore, needSMSRemind = @needSMSRemind,
			--����ά�����:
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
		where meetingID= @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--���»���μ��ˣ�
		delete meetingEnterMans where meetingID = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		insert meetingEnterMans(meetingID, InviteManID, InviteMan)
		select @meetingID, InviteManID, u.cName
		from (select cast(T.x.query('data(./InviteManID)') as varchar(10)) InviteManID 
			from(select @meetingEnterMans.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab left join userInfo u on tab.InviteManID = u.jobNumber
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	
		--����ͳ�����ݣ�
		declare @InviteManNum int
		set @InviteManNum = isnull((select count(*) from meetingEnterMans where meetingID = @meetingID),0)
		update meetingInfo
		set InviteManNum = @InviteManNum
		where meetingID = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran	
	--����Ѿ����͹�֪ͨ��Ҫ���ͱ��֪ͨ��
	if (@isPublish=1)
	begin
		declare @changeInfo nvarchar(300)
		set @changeInfo = ''
		if (@oldTopic <> @topic)
			set @changeInfo = @changeInfo + '���������ɡ�'+@oldTopic+'�����Ϊ��' + @oldTopic + '<br />'
		if (@oldOrganizer <> @organizer)
			set @changeInfo = @changeInfo + '���鷢�����ɡ�'+@oldOrganizer+'�����Ϊ��' + @organizer + '<br />'
		if (@oldMeetingStartTime <> @meetingStartTime)
			set @changeInfo = @changeInfo + '���鿪ʼʱ���ɡ�'+@oldMeetingStartTime+'�����Ϊ��' + @meetingStartTime + '<br />'
		if (@oldMeetingEndTime <> @meetingEndTime)
			set @changeInfo = @changeInfo + '����Ԥ�ƽ���ʱ���ɡ�'+@oldMeetingEndTime+'�����Ϊ��' + @meetingEndTime+ '<br />'
		if (@oldSummary <> @summary)
			set @changeInfo = @changeInfo + '�������ݣ���̣��ɡ�'+replace(replace(@oldSummary,'\r',''),'\n','<br />')
								+'��<br />���Ϊ��' + replace(replace(@summary,'\r',''),'\n','<br />'+ '<br />')
		if (@oldPlace <> @place)
			set @changeInfo = @changeInfo + '���鳡���ɡ�'+@oldPlace+'�����Ϊ��' + @place+ '<br />'

		exec dbo.makeInvitation @meetingID, 'MB20130002', @changeInfo, @Ret output	--����ֻ�л���֪ͨ�����������޸Ĺ������Զ������ˣ�
	end
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸Ļ���', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��˻��顰' + @topic + '['+@meetingID+']���ĵǼ���Ϣ��')
GO
--����:
declare	@Ret		int
declare	@modiTime smalldatetime
declare	@meetingID varchar(10)	--������:��ϵͳʹ�õ�251�ź��뷢����������'HY'+4λ��ݴ���+4λ��ˮ�ţ�
exec dbo.updatemeetingInfo 'HY20130097','�����������', 'G201300005', '2012-12-30 14:00:00','2012-12-30 16:00:00','����ǿ�ų����İ칫ϵͳ����',
		'001','��˾������', '00000001','ͶӰ��',0,0,
			N'<root>
				<row id="1">
					<InviteManID>G201300001</InviteManID>
				</row>
				<row id="2">
					<InviteManID>G201300007</InviteManID>
				</row>
			</root>',
			'00002',
			@Ret output,
			@modiTime output
select @Ret

select * from userInfo
select * from meetingInfo
select * from meetingEnterMans

drop PROCEDURE delMeetingLinkEqpApply
/*
	name:		delMeetingLinkEqpApply
	function:	5.1.ɾ��������ص��豸���뵥
	input: 
				@meetingID varchar(10),			--������
				@delManID varchar(10) output,	--ɾ���˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:ָ���Ļ��鲻���ڣ�
							2:ָ���Ļ����������������༭��
							9:δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-29���ӻ���֪ͨҳ��ӿڣ����ӻ���ȡ����Ϣ����
*/
create PROCEDURE delMeetingLinkEqpApply
	@meetingID varchar(10),			--������

	@delManID varchar(10) output,	--ɾ���˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete eqpBorrowApplyInfo where linkInvoiceType=2 and linkInvoice = @meetingID
	
	set @Ret = 0
GO

drop PROCEDURE delMeetingInfo
/*
	name:		delMeetingInfo
	function:	6.ɾ��ָ���Ļ���
	input: 
				@meetingID varchar(10),			--������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��Ҫɾ���Ļ�����������������
							3���û����Ѿ���ɣ�����ɾ����
							4���ڷ��ͻ���ȡ��֪ͨ��ʱ������������Ѿ�ɾ����
							5���û����Ѿ�����
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-29���ӻ���ȡ��֪ͨ��ɾ����������������豸����
				modi by lw 2013-07-12������ȡ����������
*/
create PROCEDURE delMeetingInfo
	@meetingID varchar(10),			--������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10),@isOver smallint
	declare @isPublish smallint					--�Ƿ��ѷ���֪ͨ
	select @thisLockMan = isnull(lockManID,''), @isPublish= isPublish, @isOver = isOver from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--������״̬��
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end
	--�����鷢��״̬��
	if (@isPublish=1)
	begin
		set @Ret = 5
		return
	end
	
	begin tran
		delete meetingInfo where meetingID= @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--ɾ����س�������
		delete eqpBorrowApplyInfo where linkInvoiceType=2 and linkInvoice = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--ɾ������豸����
		delete placeApplyInfo where linkInvoiceType=2 and linkInvoice = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName + 'ɾ���˻���['+@meetingID+']��')

GO
--���ԣ�
declare	@Ret		int 
exec dbo.delMeetingInfo 'HY20130565','0000000000',@Ret output
select @Ret

select * from meetingInfo
delete messageInfo
select * from messageInfo
select * from userInfo

drop PROCEDURE cancelPublishMeetingInfo
/*
	name:		cancelPublishMeetingInfo
	function:	6.1.ȡ��ָ���Ļ���
	input: 
				@meetingID varchar(10),			--������
				@modiManID varchar(10) output,	--ȡ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��Ҫȡ���Ļ�����������������
							3���û����Ѿ���ɣ�����ȡ����
							4���ڷ��ͻ���ȡ��֪ͨ��ʱ������������Ѿ�ȡ����
							5���û��黹û�з���֪ͨ
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-07-12
	UpdateDate: 
*/
create PROCEDURE cancelPublishMeetingInfo
	@meetingID varchar(10),			--������
	@modiManID varchar(10) output,	--ȡ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10),@isOver smallint
	declare @isPublish smallint					--�Ƿ��ѷ���֪ͨ
	select @thisLockMan = isnull(lockManID,''), @isPublish= isPublish, @isOver = isOver from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--������״̬��
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end
	--�������Ƿ񷢲���
	if (@isPublish<>1)
	begin
		set @Ret = 5
		return
	end
	
	declare @runRet int
	--���ͻ���ȡ��֪ͨ��
	exec dbo.makeInvitation @meetingID,'MB20130003','',@runRet output

	update meetingInfo 
	set isPublish = 0
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	--ɾ���μ���Ա�Ļ�����������
	delete taskInfo where taskID in(select taskID from meetingEnterMans where meetingID= @meetingID)


	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @remark nvarchar(500)
	if (@runRet<>0)
	begin
		set @remark='�û�' + @modiManName + 'ȡ���˻���['+@meetingID+'],���ڷ��ͻ���ȡ��֪ͨ��ʱ�����'
		set @Ret = 4
	end
	else 
	begin
		set @remark='�û�' + @modiManName + 'ȡ���˻���['+@meetingID+']��'
		set @Ret = 0
	end

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), 'ȡ������', @remark)

GO
--���ԣ�
declare	@Ret		int 
exec dbo.cancelPublishMeetingInfo 'HY20130565','0000000000',@Ret output
select @Ret

drop PROCEDURE placeIsReady4Meeting
/*
	name:		placeIsReady4Meeting
	function:	7.ָ֪ͨ���Ļ��鳡���Ѿ�׼����
	input: 
				@meetingID varchar(10),			--������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��ָ���Ļ�����������������3:�ڷ��ͻ���֪ͨ��ʱ�����9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-29�޸���Ϣ�Ͷ�Ϣ�ӿ�
				modi by lw 2013-07-11ȡ���������ͻ���֪ͨ

*/
create PROCEDURE placeIsReady4Meeting
	@meetingID varchar(10),			--������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update meetingInfo
	set placeIsReady = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
/*	--ʹ�û���ģ�壬�޷���֪֪ͨҳ�棬����ȡ���Զ��������� del by lw 2013-07-11
	--�ͻ�Ҫ�����豸������飬ֻҪ����׼�����˾����̷���֪ͨ add by lw 2013-1-29
	exec dbo.makeInvitation @meetingID, 'MB20130001', '', @Ret output	--����ֻ�л���֪ͨ�����������޸Ĺ������Զ������ˣ�
	--����Ƿ��豸Ҳ׼���ã����Ҳ׼�����˾Ϳ�ʼ����֪ͨ
	declare @eqpIsReady smallint
	set @eqpIsReady = (select eqpIsReady from meetingInfo where meetingID= @meetingID)
	if (@eqpIsReady=1)
	begin
		exec dbo.makeInvitation @meetingID, 'MB20130001', @Ret output	--����ֻ�л���֪ͨ�����������޸Ĺ������Զ������ˣ�
		if (@Ret<>0)
			set @Ret = 3
	end
*/
GO

drop PROCEDURE eqpIsReady4Meeting
/*
	name:		eqpIsReady4Meeting
	function:	8.ָ֪ͨ���Ļ����豸�Ѿ�׼����
	input: 
				@meetingID varchar(10),			--������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��ָ���Ļ�����������������9��δ֪����
							--3:�ڷ��ͻ���֪ͨ��ʱ�����del by lw 2013-3-24
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE eqpIsReady4Meeting
	@meetingID varchar(10),			--������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update meetingInfo
	set eqpIsReady = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
	--�ͻ�Ҫ�����豸������飬ֻҪ����׼�����˾����̷���֪ͨ add by lw 2013-1-29
/*	--����Ƿ񳡵�Ҳ׼���ã����Ҳ׼�����˾Ϳ�ʼ����֪ͨ
	declare @placeIsReady smallint
	set @placeIsReady = (select placeIsReady from meetingInfo where meetingID= @meetingID)
	if (@placeIsReady=1)
	begin
		exec dbo.makeInvitation @meetingID, 'MB20130001', @Ret output	--����ֻ�л���֪ͨ�����������޸Ĺ������Զ������ˣ�
		if (@Ret<>0)
			set @Ret = 3
	end
*/
GO

use hustOA
-----------------------------------------������Ϣ�ù��̣�-------------------------------
drop PROCEDURE makeInvitation
/*
	name:		makeInvitation
	function:	10.���ɻ���֪ͨ�����������Ϣ����
	input: 
				@meetingID varchar(10),			--������
				@templateID varchar(10),		--ʹ�õ�֪ͨģ�壺'MB20130001'Ϊ����֪ͨ��'MB20130002'Ϊ������֪ͨ, 'MB20130003'Ϊ����ȡ��֪ͨ
				@changeInfo nvarchar(300),		--���������֪ͨ��д��������''
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��ָ���Ļ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-1
	UpdateDate: modi by lw 2013-1-29���ӻ���������ӿڣ��������֪ͨģ�����ɵ�ҳ��

*/
create PROCEDURE makeInvitation
	@meetingID varchar(10),			--������
	@templateID varchar(10),		--ʹ�õ�֪ͨģ�壺'MB20130001'Ϊ����֪ͨ��'MB20130002'Ϊ������֪ͨ, 'MB20130003'Ϊ����ȡ��֪ͨ
	@changeInfo nvarchar(300),		--���������֪ͨ��д��������''
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	--��ȡ����Ļ�����Ϣ��
	declare @topic nvarchar(40), @organizerID varchar(10), @organizer nvarchar(30)	--��������/���鷢���˹���/���鷢�����������������
	declare @meetingStartTime smalldatetime, @meetingEndTime smalldatetime --���鿪ʼʱ��/����Ԥ�ƽ���ʱ��
	declare @place nvarchar(60)		--����ص�
	declare @summary nvarchar(300)			--����ժҪ(�������)
	declare @meetingNoticeUrl varchar(128)	--��ǰ����֪ͨ��ҳ��·�� add by lw 2013-1-29
	declare @needSMSInvitation smallint		--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ add by lw 2013-1-3
	select @topic = topic, @organizerID = organizerID, @organizer = organizer, 
		@meetingStartTime = meetingStartTime, @meetingEndTime = meetingEndTime,
		@place = place,@needSMSInvitation = needSMSInvitation,
		@summary = summary, @meetingNoticeUrl = isnull(meetingNoticeUrl,'')
	from meetingInfo
	where meetingID = @meetingID

	--��ȡ����ģ�壺
	declare @meetingInvitationTemplate Nvarchar(4000), @SMSTemplate nvarchar(500)
	set @meetingInvitationTemplate = (select templateBody from messageTemplate where templateID=@templateID)
	set @SMSTemplate = (select templateBody from SMSTemplate where templateID=@templateID)
	--������Ļ���֪ͨ�����url��
	set @meetingInvitationTemplate = replace(replace(replace(replace(replace(replace(@meetingInvitationTemplate,'{meetingTopic}',@topic),
										'{meetingTime}',convert(varchar(19),@meetingStartTime,120)),'{url}',@meetingNoticeUrl),
										'{meetingID}',@meetingID),'{meetingPlace}',@place),
										'{changeInfo}',@changeInfo)
	set @SMSTemplate = replace(replace(replace(replace(replace(replace(@SMSTemplate,'{meetingTopic}',@topic),
										'{meetingTime}',convert(varchar(19),@meetingStartTime,120)),'{url}',@meetingNoticeUrl),
										'{meetingID}',@meetingID),'{meetingPlace}',@place),
										'{changeInfo}',@changeInfo)
	--��ȡ֪ͨ���ͣ�
	declare @noticeType nvarchar(10)
	if (@templateID='MB20130001')
		set @noticeType = '����֪ͨ'
	else if (@templateID='MB20130002')
		set @noticeType = '������֪ͨ'
	else if (@templateID='MB20130003')
		set @noticeType = '����ȡ��֪ͨ'
		
	--�ֱ���֪ͨ������������Ա���ѷ���֪ͨ���˲���֪ͨ����֪ͨ������������޸��˳��ػ�ʱ��Ӧ�ý�����״̬�����
	if (@noticeType = '������֪ͨ' or @noticeType = '����ȡ��֪ͨ')
		update meetingEnterMans
		set isSendMsg = 0
		where meetingID = @meetingID
		
	declare @InviteManID varchar(10), @InviteMan nvarchar(30), @mobile varchar(20)	--������Ա����/������Ա����/�ֻ����롣
	declare mtar cursor for
	select m.InviteManID, m.InviteMan, isnull(u.mobile,'')
	from meetingEnterMans m left join userInfo u on m.InviteManID = u.jobNumber
	where m.meetingID = @meetingID and m.isSendMsg = 0
	order by m.rowNum
	
	declare @execRet int, @messageID varchar(12)
	declare @meetingInvitation nvarchar(4000), @SMS nvarchar(500)
	declare @errorMessage nvarchar(4000)
	OPEN mtar
	FETCH NEXT FROM mtar INTO @InviteManID, @InviteMan, @mobile
	WHILE @@FETCH_STATUS = 0
	begin
		set @meetingInvitation = replace(@meetingInvitationTemplate,'{InviteMan}',@InviteMan)
		exec dbo.addMessageInfo 3, @noticeType, 9, @organizerID, 1, @InviteManID, @meetingInvitation, @execRet output, @messageID output
		if (@execRet<>0)
		begin
			set @errorMessage = 'ϵͳ�ڷ��͸�['+ @InviteMan +']�Ļ���['+ @meetingID +']֪ͨʱ���ִ���'
			exec dbo.addMessageInfo 11,'֪ͨ���ʹ���', 9, '0000000000', 1, @organizerID, @errorMessage,@execRet output, @messageID output
		end
		
		--����֪ͨ��
		if (@needSMSInvitation=1 and @mobile<>'')
		begin
			declare @SMSInfoID char(12)	--���ű��
			declare @createTime smalldatetime 
			set @SMS = replace(@SMSTemplate,'{InviteMan}',@InviteMan)
			exec dbo.addSMSInfo @organizerID,@InviteManID,@mobile,'',9,@SMS,@organizerID, @execRet output, @createTime output, @SMSInfoID output
			--���Ͷ��ţ�
			declare @snderID varchar(10)
			set @snderID = '0000000000'
			exec dbo.sendSMS @SMSInfoID,'', @snderID output,@createTime output,@execRet output
			if (@execRet<>0)
			begin
				set @errorMessage = 'ϵͳ�ڷ����ֻ����Ÿ�['+ @InviteMan +']�Ļ���['+ @meetingID +']֪ͨʱ���ִ���'
				exec dbo.addMessageInfo 11,'֪ͨ���ʹ���', 9, '0000000000', 1, @organizerID, @errorMessage,@execRet output, @messageID output
			end
		end
		FETCH NEXT FROM mtar INTO @InviteManID, @InviteMan, @mobile
	end
	CLOSE mtar
	DEALLOCATE mtar
	--�궨����Ϊ�ѷ�����
	update meetingInfo 
	set isPublish = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	--�궨֪ͨ�ѷ�����
	update meetingEnterMans
	set isSendMsg = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
GO
--���ԣ�
declare @ret int
exec dbo.makeInvitation 'HY20130447','MB20130003','', @ret output
select @ret

select * from meetingInfo
select * from meetingEnterMans
select * from messageInfo
DELETE messageInfo

drop PROCEDURE isSendedInvitation
/*
	name:		isSendedInvitation
	function:	11.���μӻ�����Ա��֪ͨ���Ϊ�ѷ���״̬
				ע�⣺���ͻ���֪ͨʹ�ú�̨���ȳ����Զ����ͣ����ǵ��ȳ�����õĹ���
	input: 
				@meetingID varchar(10),			--������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��ָ���Ļ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE isSendedInvitation
	@meetingID varchar(10),			--������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end
	
	update meetingEnterMans
	set isSendMsg = 1, sendTime = GETDATE()
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
GO

drop PROCEDURE readInvitation
/*
	name:		readInvitation
	function:	12.֪ͨ��ִ������μӻ����˺��Ķ���(������֪���ˡ���ť��)�Զ����͵���Ϣ��
				ע�⣺���ͻ���֪ͨ�Ķ�ʹ����Ϣ���Զ����ͣ����ǵ��ȳ�����õĹ���
	input: 
				@meetingID varchar(10),			--������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��ָ���Ļ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE readInvitation
	@meetingID varchar(10),			--������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end
	
	update meetingEnterMans
	set isReadMsg = 1, readTime = GETDATE()
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
GO

select * from meetingEnterMans where meetingID='HY20130573'
select * from meetingInfo where meetingID='HY20130573'
drop PROCEDURE replyMeeting
/*
	name:		replyMeeting
	function:	13.�ظ�����֪ͨ
				ע�⣺���Զ�λظ�,����Ҳ�����༭��,Ҳ��������״̬(���������ɾ��ǻ����������)!
	input: 
				@meetingID varchar(10),			--������
				@replyManID varchar(10),		--�ظ��ˣ������ˣ�����
				@isEnter smallint,				--�Ƿ�μӣ�0->δ֪��1->�μӣ�-1->���μ�
				@replyOpinion nvarchar(300),	--�ظ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2.�ظ����Ѿ�����������Ա�б���,9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE replyMeeting
	@meetingID varchar(10),			--������
	@replyManID varchar(10),		--�ظ��ˣ������ˣ�����
	@isEnter smallint,				--�Ƿ�μӣ�0->δ֪��1->�μӣ�-1->���μ�
	@replyOpinion nvarchar(300),	--�ظ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�ظ��Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--�жϻظ����Ƿ���������Ա
	set @count=(select count(*) from meetingEnterMans where meetingID= @meetingID and InviteManID = @replyManID)	
	if (@count = 0)	--������
	begin
		set @Ret = 2
		return
	end

	--ȡ�ظ���������
	declare @replyMan nvarchar(30)
	set @replyMan = isnull((select userCName from activeUsers where userID = @replyManID),'')

	declare @replyTime smalldatetime	--����ʱ��
	set @replyTime = GETDATE()
	
	begin tran	
		update meetingEnterMans
		set replyTime = @replyTime, isEnter = @isEnter
		where meetingID= @meetingID and InviteManID = @replyManID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		--���»��������е�ͳ�����ݣ�
		declare @replyManNum int, @replyOKManNum int
		set @replyManNum=(select count(*) from meetingEnterMans where meetingID= @meetingID and isEnter<>0)		--�ظ�������
		set @replyOKManNum=(select count(*) from meetingEnterMans where meetingID= @meetingID and isEnter= 1)		--ͬ������
		update meetingInfo
		set replyManNum=@replyManNum, replyOKManNum = @replyOKManNum
		where meetingID= @meetingID
		set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		insert meetingManDiscussInfo(meetingID, InviteManID, InviteMan, isEnter, replyOpinion, replyTime)
		values(@meetingID, @replyManID, @replyMan, @isEnter, @replyOpinion, @replyTime)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0
	
	--��ȡ�������Ϣ��
	declare @topic  nvarchar(40)			--��������
	declare @meetingStartTime smalldatetime	--���鿪ʼʱ��
	declare @meetingEndTime smalldatetime	--����Ԥ�ƽ���ʱ��
	declare @summary nvarchar(300)			--����ժҪ(�������)
	declare @place nvarchar(60)		--����ص�
	declare @remindBefore int				--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15���� add by lw 2013-07-11
	declare @needSMSRemind smallint			--�Ƿ���Ҫ�������ѣ�����ǰ1Сʱ���ѣ���0->����Ҫ��1->��Ҫ add by lw 2013-1-3
	declare @meetingNoticeUrl varchar(128)	--��ǰ����֪ͨ��ҳ��·�� add by lw 2013-1-29

	select @topic = topic, @meetingStartTime = meetingStartTime, @meetingEndTime = meetingEndTime, @summary = summary,
	@place = place, @remindBefore = remindBefore, @needSMSRemind = needSMSRemind, @meetingNoticeUrl = meetingNoticeUrl
	from meetingInfo where meetingID= @meetingID

	declare @ExecRet int, @createTime smalldatetime, @taskID varchar(10)
	--ɾ�����ܴ��ڵ���ǰ�Ļ�����������
	set @taskID = isnull((select taskID from meetingEnterMans where meetingID= @meetingID and InviteManID = @replyManID),'')
	if (@taskID<>'')
	begin
		delete taskInfo where taskID= @taskID

		update meetingEnterMans
		set taskID=''
		where meetingID= @meetingID and InviteManID = @replyManID
	end
	--����ǲμӣ����һ�������������ѣ�
	if (@isEnter=1)
	begin
		set @summary = N'����ص㣺' + @place + char(13)+char(10) + N'������̣�' +char(13)+char(10) + @summary
		exec dbo.addTaskInfo @topic, @meetingStartTime, @meetingEndTime, @summary,
				0, @needSMSRemind, @remindBefore, @replyManID, @ExecRet output, @createTime output, @taskID output
		if (@ExecRet=0)
			update meetingEnterMans
			set taskID=@taskID
			where meetingID= @meetingID and InviteManID = @replyManID
	end
	--�Ǽǹ�����־��
	declare @desc nvarchar(20)
	if (@isEnter=-1)
		set @desc = '���μ�'
	else if(@isEnter=1)
		set @desc = '�μ�'
	else 
		set @desc = '�����ܾ����Ƿ�μ�'
	
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@replyManID, @replyMan, @replyTime, '�ظ�����', '�û�' + @replyMan
												+ '�ظ�'+@desc+'����['+@meetingID+']��')
GO
--���ԣ�
declare @Ret int
exec dbo.applyEnterAReport 'BG20120019','00001', @Ret output
select @Ret

select * from taskInfo
select * from AReportEnterMans
select * from meetingInfo
select * from userInfo




--------------------------------------�����ù��̣�-------------------------------------------------------
drop PROCEDURE checkEnterMeeting
/*
	name:		checkEnterMeeting
	function:	20.����ָ���Ļ��飨���ڣ�
	input: 
				@meetingID varchar(10),			--������
				@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
				@checkManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output,			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��Ҫ����μӵĻ�����������������9��δ֪����
				@isLate smallint output			--ϵͳ���صĵ���״̬��1:�������-1���ٵ�
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE checkEnterMeeting
	@meetingID varchar(10),			--������
	@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
	@checkManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output,			--�����ɹ���ʶ
	@isLate smallint output			--ϵͳ���صĵ���״̬��1:�������-1���ٵ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @isLate = 0

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡ�����˺Ϳ����˵�������
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--ȡ����ʱ��͵���ʱ�䣺
	declare @meetingTime smalldatetime, @arriveTime smalldatetime
	set @meetingTime = (select meetingStartTime from meetingInfo where meetingID=@meetingID)
	set @arriveTime = GETDATE()
	if (@meetingTime > @arriveTime)
		set @isLate = 1
	else
		set @isLate = -1
	
	--����Ƿ����ֱ���
	set @count =(select count(*) from meetingEnterMans where meetingID = @meetingID and InviteManID = @enterManID)
	if (@count = 0)	--δ����
	begin
		insert meetingEnterMans(meetingID, InviteManID, InviteMan, replyTime, checkManID, checkMan, arriveTime, isLate)
		select @meetingID, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from meetingInfo 
		where meetingID= @meetingID
	end
	else
	begin
		update meetingEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where meetingID= @meetingID and InviteManID = @enterManID
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, '�������', '�û�' + @checkMan
												+ '��['+@enterMan+']����Ϊ�������['+@meetingID+']��')
GO


drop PROCEDURE checkEnterMeetingByFlag
/*
	name:		checkEnterMeetingByFlag
	function:	21.ʹ�ñ�־״̬����
	input: 
				@meetingID varchar(10),			--������
				@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
				@isLate smallint,				--����״̬��1:������� -1:�ٵ�����
				@checkManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��Ҫ����μӵĻ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE checkEnterMeetingByFlag
	@meetingID varchar(10),			--������
	@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
	@isLate smallint,				--����״̬��1:������� -1:�ٵ�����
	@checkManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡ�����˺Ϳ����˵�������
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--ȡ����ʱ��
	declare @meetingTime smalldatetime, @arriveTime smalldatetime
	set @meetingTime = (select meetingStartTime from meetingInfo where meetingID=@meetingID)
	--���ݵ���״̬���õ���ʱ�䣺������������Ϊ���鿪ʼʱ�䣬�ٵ���������Ϊ���鿪ʼ��15����
	if (@isLate=1)
		set @arriveTime = @meetingTime
	else
		set @arriveTime = DATEADD(minute, 15, @meetingTime)
	
	--����Ƿ����ֱ���
	set @count =(select count(*) from meetingEnterMans where meetingID = @meetingID and InviteManID = @enterManID)
	if (@count = 0)	--δ����
	begin
		insert meetingEnterMans(meetingID, InviteManID, InviteMan, replyTime, checkManID, checkMan, arriveTime, isLate)
		select @meetingID, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from meetingInfo 
		where meetingID= @meetingID
	end
	else
	begin
		update meetingEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where meetingID= @meetingID and InviteManID = @enterManID
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, '�������', '�û�' + @checkMan
												+ '��['+@enterMan+']����Ϊ�������['+@meetingID+']��')
GO

drop PROCEDURE cancelCheckEnterMeeting
/*
	name:		cancelCheckEnterMeeting
	function:	22.ȡ�������������ȡ�����ܣ�
	input: 
				@meetingID varchar(10),			--������
				@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
				@checkManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��Ҫ����μӵĻ�����������������3:û�и������˻�δ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE cancelCheckEnterMeeting
	@meetingID varchar(10),			--������
	@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
	@checkManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--����������Ƿ���ڲ����
	set @count =(select count(*) from meetingEnterMans where meetingID = @meetingID and InviteManID = @enterManID and isLate<>0)
	if (@count=0)
	begin
		set @Ret =3
		return
	end

	--ȡ�����˺Ϳ����˵�������
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	update meetingEnterMans
	set checkManID = @checkManID, checkMan = @checkMan, arriveTime = null, isLate = 0
	where meetingID= @meetingID and InviteManID = @enterManID

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, GETDATE(), 'ȡ�����鵽��', '�û�' + @checkMan
												+ '��['+@enterMan+']����Ϊδ�������['+@meetingID+']��')
GO


drop PROCEDURE meetingIsOver
/*
	name:		meetingIsOver
	function:	25.��ָ���Ļ�������Ϊ���״̬
	input: 
				@meetingID varchar(10),			--������
				@overManID varchar(10) output,	--����趨�ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��鲻���ڣ�2��ָ���Ļ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE meetingIsOver
	@meetingID varchar(10),			--������
	@overManID varchar(10) output,	--����趨�ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ��ɵĻ����Ƿ����
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @overManID)
	begin
		set @overManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @overMan nvarchar(30)
	set @overMan = isnull((select userCName from activeUsers where userID = @overManID),'')

	declare @overTime smalldatetime
	set @overTime = GETDATE()
	update meetingInfo
	set isOver = 1,
		--����ά�����:
		modiManID = @overManID, modiManName = @overMan, modiTime = @overTime
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@overManID, @overMan, @overTime, '��ɷ�������', '�û�' + @overMan
												+ '������['+@meetingID+']����Ϊ���״̬��')

GO

use hustOA
--���߻����ѯ��䣺
select m.meetingID, m.topic, m.organizerID, m.organizer, 
	convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
	convert(varchar(19),m.meetingEndTime,120) meetingEndTime, 
	m.summary,
	m.placeID, m.place, m.placeIsReady, 
	m.needEqpCodes, m.needEqpNames, m.eqpIsReady,
	m.InviteManNum, m.replyManNum, m.replyOKManNum
from meetingInfo m
where isOver = 0

--��ʷ�����ѯ��䣺
select m.meetingID, m.topic, m.organizerID, m.organizer, 
	convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
	convert(varchar(19),m.meetingEndTime,120) meetingEndTime, 
	m.summary,
	m.placeID, m.place, m.placeIsReady, 
	m.needEqpCodes, m.needEqpNames, m.eqpIsReady,
	m.InviteManNum, m.replyManNum, m.replyOKManNum, enterManNum
from meetingInfo m
where isOver = 1

--��������μ���Ա��ѯ��䣺
select a.meetingID, m.topic, 
	convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
	convert(varchar(19),m.meetingEndTime,120) meetingEndTime, 
	a.InviteManID, a.InviteMan, a.isSendMsg, a.isReadMsg,
	convert(varchar(19),a.replyTime,120) replyTime, a.isEnter,
	a.checkManID, a.checkMan, convert(varchar(19),a.arriveTime,120) arriveTime, a.isLate
from meetingEnterMans a
left join meetingInfo m on m.meetingID = a.meetingID
order by rowNum

--��ѯ����ظ������䣺
select meetingID,convert(varchar(19),replyTime,120) replyTime, InviteManID, InviteMan, isEnter, replyOpinion
from meetingManDiscussInfo
order by replyTime desc



use hustOA
select m.meetingID, m.topic, m.organizerID, m.organizer,
convert(varchar(19),m.meetingStartTime,120) meetingStartTime,
convert(varchar(19),m.meetingEndTime,120) meetingEndTime,
m.summary,m.placeID, m.place, m.placeIsReady,
m.needEqpCodes, m.needEqpNames, m.eqpIsReady,m.InviteManNum, 
m.replyManNum, m.replyOKManNum, m.enterManNum, m.isOver 
from meetingInfo m where meetingID='243423';
select a.meetingID, m.topic,convert(varchar(19),m.meetingStartTime,120) meetingStartTime,
convert(varchar(19),m.meetingEndTime,120) meetingEndTime,a.InviteManID, a.InviteMan, 
a.isSendMsg, a.isReadMsg,convert(varchar(19),a.replyTime,120) replyTime, a.isEnter, a.replyOpinion,a.checkManID, a.checkMan, 
convert(varchar(19),a.arriveTime,120) arriveTime, a.isLate 
from meetingEnterMans a left join meetingInfo m on m.meetingID = a.meetingID 
where a.meetingID='243423' order by rowNum

use hustOA
select * from meetingInfo
update meetingInfo
set topic = '�����ܽ��'
where meetingID='HY20130012'

select * from messageInfo
delete messageInfo
select * from messageTemplate

use hustOA

select * from meetingInfo
select * from placeApplyInfo where linkInvoice='HY20130122'

select * from eqpBorrowApplyInfo



select *
from bulletinInfo



select * from userInfo

select m.isOver, m.meetingID, m.topic, case m.organizerID when 'G201300040' then 9 else em.isEnter end meetingType, 
m.isPublish, m.organizerID, m.organizer, convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
convert(varchar(19),m.meetingEndTime,120) meetingEndTime, m.summary,m.placeID, m.place, m.placeIsReady, 
m.needEqpCodes, m.needEqpNames, m.eqpIsReady,m.InviteManNum, m.replyManNum, m.replyOKManNum,m.needSMSInvitation, needSMSRemind
from meetingInfo m left join meetingEnterMans em on m.meetingID = em.meetingID and em.InviteManID='G201300040'
where m.isOver=0 and (m.meetingID in (select meetingID from meetingEnterMans where InviteManID='G201300040' and isSendMsg=1) or m.organizerID='G201300040')


select meetingID,* from meetingEnterMans where InviteManID='G201300040'
