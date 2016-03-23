use newfTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-���Ź�������
	author:		¬έ
	CreateDate:	2012-8-18
	UpdateDate:
				
*/
select SMSInfoID, receiverID, receiver, mobile, convert(varchar(19),sendPlanTime,120) sendPlanTime, 
		convert(varchar(19),sendTime,120) sendTime, case SMSType when 1 then 'ϵͳ��������' when 2 then '�ֹ�����' end SMSType, 
		case SMSStatus when 0 then '' when 1 then '?' when 2 then '��' when -1 then '�w' end SMSStatus, SMSContent, senderID, sender
from SMSInfo

alter TABLE SMSInfo	add feeTimes int default(1) null		--�ƷѴ�������������˼�Ϊ��� add by lw 2012-12-29
update SMSInfo	
set feeTimes=1

drop TABLE SMSInfo
CREATE TABLE SMSInfo
(
	SMSInfoID char(12) not null,	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	senderID varchar(10) not null,	--�����˹���
	sender nvarchar(30) not null,	--������
	receiverID varchar(110) not null,--�����˹��ţ����������ʹ�á�,���ָ�
	receiver nvarchar(310) not null,	--�����ˣ����������ʹ�á�,���ָ�
	mobile varchar(300) not null,	--�ֻ�������ֻ�ʹ�á�,���ָ�
	sendPlanTime datetime null,		--�ƻ�����ʱ��:Ϊnull��ʱ��Ϊ���̷���
	sendTime datetime null,			--����ʱ��
	SMSType smallint default(2),	--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
	SMSStatus smallint default(0),	--����״̬��0->�½���δ���巢�ͣ���1->�����͡�9->�ѷ��͡�-1->����ʧ��
	SMSContent nvarchar(300) null,	--��������

	feeTimes int default(1) null,		--�ƷѴ�������������˼�Ϊ��� add by lw 2012-12-29

	--�����ˣ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_SMSInfo] PRIMARY KEY CLUSTERED 
(
	[SMSInfoID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_SMSInfo] ON [dbo].[SMSInfo] 
(
	[sender] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_1] ON [dbo].[SMSInfo] 
(
	[receiver] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_2] ON [dbo].[SMSInfo] 
(
	[sendTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_3] ON [dbo].[SMSInfo] 
(
	[SMSStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_4] ON [dbo].[SMSInfo] 
(
	[SMSType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.����ģ��⣺�������ʱʹ���ֹ�ά��
drop table SMSTemplate
CREATE TABLE SMSTemplate(
	templateID varchar(12) not null,	--��������Ϣģ����,��ϵͳʹ�õ�11001�ź��뷢����������8λ���ڴ���+4λ��ˮ�ţ�
	templateType nvarchar(30) null,		--��Ϣģ������
	templateBody nvarchar(4000) null,	--��Ϣģ������
 CONSTRAINT [PK_SMSTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--����֪ͨģ��:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130001','����֪ͨ',
N'����֪ͨ\r\n
{InviteMan}��ʦ/ѧ����������{meetingTime}�μӡ�{meetingTopic}�����顣\r\n
���������:<a target="_blank" href="{url}">{meetingTopic}���鹫��</a>')
--������֪ͨ:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130002','������֪ͨ',
N'������֪ͨ\r\n
{InviteMan}��ʦ/ѧ����ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}������\r\n
���б���������£�{changeInfo}\r\n
���������:<a target="_blank" href="{url}">{meetingTopic}����������</a>')

--����ȡ��֪ͨ:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130003','����ȡ��֪ͨ',
N'����ȡ��֪ͨ\r\n
{InviteMan}��ʦ/ѧ����ԭ����{meetingTime}��{meetingPlace}�����ٿ��ġ�{meetingTopic}����������ȡ����\r\n
���������:<a target="_blank" href="{url}">{meetingTopic}����ȡ������</a>')


--3.���żƷѱ�
select convert(varchar(10),a.accountTime,120) accountTime, a.summary, a.invoice, a.feeTimes, 
	a.income, a.outlay, a.overage
from SMSFeeAccount a
order by rowNum desc
select * from smsfeeaccount
drop TABLE SMSFeeAccount
CREATE TABLE SMSFeeAccount
(
	rowNum int IDENTITY(1,1) NOT NULL,	--���������
	accountTime datetime null,			--����ʱ��
	summary nvarchar(30) null,			--ժҪ
	invoice varchar(30) null,			--Ʊ�ݺ�:����ķ�Ʊ�ţ�֧���Ķ��ź�
	feeTimes int default(0),			--�ƷѴ���
	income numeric(12,2) default(0),	--����
	outlay numeric(12,2) default(0),	--֧��
	overage numeric(12,2) null,			--���
 CONSTRAINT [PK_SMSFeeAccount] PRIMARY KEY CLUSTERED 
(
	[rowNum] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE addSMSInfo
/*
	name:		addSMSInfo
	function:	1.��Ӷ���
				ע�⣺�ô洢�����Զ���������
	input: 
				@senderID varchar(10),		--�����˹���
				@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
				@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
				@sendPlanTime varchar(19),	--�ƻ�����ʱ��
				@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
				@SMSContent nvarchar(300),	--��������

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output	--����ʱ��
				@SMSInfoID char(12) output	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE addSMSInfo
	@senderID varchar(10),		--�����˹���
	@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
	@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
	@sendPlanTime varchar(19),	--�ƻ�����ʱ��
	@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
	@SMSContent nvarchar(300),	--��������

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,	--����ʱ��
	@SMSInfoID char(12) output	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�����������ű�ʶ���룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10020, 1, @curNumber output
	set @SMSInfoID = @curNumber

	--ȡ�����ˡ������˵�������
	declare @id varchar(10), @sender nvarchar(310),@receiver nvarchar(30)
	set @sender = ''
	declare tar cursor for
	SELECT convert(varchar(10),T.x.query('data(.)')) FROM 
	(SELECT CONVERT(XML,'<x>'+REPLACE(@receiverID,',','</x><x>')+'</x>',1) Col1) A
	OUTER APPLY A.Col1.nodes('/x') AS T(x)
	OPEN tar
	FETCH NEXT FROM tar INTO @id
	WHILE @@FETCH_STATUS = 0
	begin
		declare @name nvarchar(30)
		set @name = isnull((select cName from userInfo where jobNumber = @id),'')
		set @sender = @sender + @name
		FETCH NEXT FROM tar INTO @id
	end
	CLOSE tar
	DEALLOCATE tar
	set @receiver = isnull((select cName from userInfo where jobNumber = @receiverID),'')

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--���ƻ�����ʱ�䣺
	declare @sPTime datetime
	if (@sendPlanTime='')
		set @sPTime = null
	else
		set @sPTime = CONVERT(datetime,@sendPlanTime,120)
	
	set @createTime = getdate()
	insert SMSInfo(SMSInfoID, senderID, sender, receiverID, receiver, mobile,
					sendPlanTime, SMSType, SMSContent,
					lockManID, modiManID, modiManName, modiTime,
					createManID, createManName, createTime) 
	values (@SMSInfoID, @senderID, @sender, @receiverID, @receiver, @mobile,
					@sPTime, @SMSType, @SMSContent,
					@createManID, @createManID, @createManName, @createTime,
					@createManID, @createManName, @createTime) 
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��Ӷ���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˶���[' + @SMSInfoID + ']��')
GO
--���ԣ�
declare @Ret		int
declare @createTime smalldatetime 
declare @SMSInfoID char(12)
exec addSMSInfo '00200977','00200977','18602702392','',2,'Hello world!','00200977',@Ret output, @createTime output, @SMSInfoID output
select @Ret,@SMSInfoID

select * from SMSInfo

drop PROCEDURE querySMSInfoLocMan
/*
	name:		querySMSInfoLocMan
	function:	2.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@SMSInfoID char(12),	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ķ��Ų�����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE querySMSInfoLocMan
	@SMSInfoID char(12),	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@Ret int output,		--�����ɹ���ʶ
	@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from SMSInfo where SMSInfoID = @SMSInfoID),'')
	set @Ret = 0
GO


drop PROCEDURE lockSMSInfo4Edit
/*
	name:		lockSMSInfo4Edit
	function:	3.�������ű༭������༭��ͻ
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1��Ҫ�����Ķ��Ų����ڣ�
							2��Ҫ�����Ķ������ڱ����˱༭��
							3���ö����ѷ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE lockSMSInfo4Edit
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from SMSInfo where SMSInfoID = @SMSInfoID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--������״̬:
	declare @acceptApplyStatus int
	set @acceptApplyStatus = (select SMSStatus from SMSInfo where SMSInfoID = @SMSInfoID)
	if (@acceptApplyStatus = 9)
	begin
		set @Ret = 3
		return
	end

	update SMSInfo 
	set lockManID = @lockManID 
	where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������ű༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˶���['+ @SMSInfoID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockSMSInfoEditor
/*
	name:		unlockSMSInfoEditor
	function:	4.�ͷŶ��ű༭��
				ע�⣺�����̲��������Ƿ���ڣ�
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE unlockSMSInfoEditor
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from SMSInfo where SMSInfoID = @SMSInfoID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update SMSInfo set lockManID = '' where SMSInfoID = @SMSInfoID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŶ��ű༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˶���['+ @SMSInfoID +']�ı༭����')
GO


drop PROCEDURE updateSMSInfo
/*
	name:		updateSMSInfo
	function:	5.���¶���
	input: 
				@SMSInfoID char(12),		--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@senderID varchar(10),		--�����˹���
				@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
				@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
				@sendPlanTime varchar(19),	--�ƻ�����ʱ��
				@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
				@SMSContent nvarchar(300),	--��������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ķ��Ų����ڣ�2��Ҫ���µĶ�����������������
							3���ö����Ѿ����ͣ��������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE updateSMSInfo
	@SMSInfoID char(12),		--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@senderID varchar(10),		--�����˹���
	@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
	@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
	@sendPlanTime varchar(19),	--�ƻ�����ʱ��
	@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
	@SMSContent nvarchar(300),	--��������

	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @SMSStatus int
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	if (@SMSStatus = 9)
	begin
		set @Ret = 3
		return
	end
	
	--ȡ�����ˡ������˵�������
	declare @id varchar(10), @sender nvarchar(310),@receiver nvarchar(30)
	set @sender = ''
	declare tar cursor for
	SELECT convert(varchar(10),T.x.query('data(.)')) FROM 
	(SELECT CONVERT(XML,'<x>'+REPLACE(@receiverID,',','</x><x>')+'</x>',1) Col1) A
	OUTER APPLY A.Col1.nodes('/x') AS T(x)
	OPEN tar
	FETCH NEXT FROM tar INTO @id
	WHILE @@FETCH_STATUS = 0
	begin
		declare @name nvarchar(30)
		set @name = isnull((select cName from userInfo where jobNumber = @id),'')
		set @sender = @sender + @name
		FETCH NEXT FROM tar INTO @id
	end
	CLOSE tar
	DEALLOCATE tar
	set @receiver = isnull((select cName from userInfo where jobNumber = @receiverID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--���ƻ�����ʱ�䣺
	declare @sPTime datetime
	if (@sendPlanTime='')
		set @sPTime = null
	else
		set @sPTime = CONVERT(datetime,@sendPlanTime,120)

	set @updateTime = getdate()
	update SMSInfo 
	set SMSInfoID = @SMSInfoID, senderID = @senderID, sender = @sender, 
		receiverID = @receiverID, receiver = @receiver, mobile = @mobile,
		sendPlanTime = @sPTime, SMSType = @SMSType, SMSContent = @SMSContent,
		SMSStatus = 0,	--��״̬��λ
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���¶���', '�û�' + @modiManName 
												+ '�����˶���['+ @SMSInfoID +']��')
GO

drop PROCEDURE delSMSInfo
/*
	name:		delSMSInfo
	function:	6.ɾ��ָ���Ķ���
				ע��:�ù��̲�������״̬
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ķ��Ų����ڣ�
							2��Ҫɾ���Ķ�����������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 

*/
create PROCEDURE delSMSInfo
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete SMSInfo where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ���˶���['+ @SMSInfoID +']��')

GO


drop PROCEDURE changeSMSStatus
/*
	name:		changeSMSStatus
	function:	7.�ı����״̬
				ע�����ŷ��͵�ʱ����Ҫ���ø߼����Գ�����,����ֻ��״̬���
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@SMSStatus smallint,			--����״̬��0->�½���δ���巢�ͣ���1->�����͡�9->�ѷ��͡�-1->����ʧ��
				@sendTime varchar(19),			--����ʱ��

				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1��ָ���Ķ��Ų����ڣ�2��Ҫ�༭�Ķ�����������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE changeSMSStatus
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@SMSStatus smallint,			--����״̬��0->�½���δ���巢�ͣ���1->�����͡�9->�ѷ��͡�-1->����ʧ��
	@sendTime varchar(19),			--����ʱ��

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @oldStatus int
	select @thisLockMan = isnull(lockManID,''), @oldStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ƻ�����ʱ�䣺
	declare @sTime datetime
	if (@sendTime='')
	begin
		if (@SMSStatus=9)
			set @sTime = GETDATE()
		else
			set @sTime = null
	end
	else
		set @sTime = CONVERT(datetime,@sendTime,120)

	set @updateTime = getdate()
	update SMSInfo
	set SMSStatus = @SMSStatus,	--����״̬��0->�½���δ���巢�ͣ���1->�����͡�9->�ѷ��͡�-1->����ʧ��
		sendTime = @sTime,
		--ά���ˣ�
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�������״̬', '�û�' + @modiManName 
												+ '�޸��˶���['+ @SMSInfoID +']��״̬��')
GO

select * from sysDataOpr

select * from sysRoleDataOpr