use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�����������
	author:		¬έ
	CreateDate:	2012-12-27
	UpdateDate: 
*/
--0.���ĸ����⣺���ĸ������ö�����ƣ�������֧�ֶ������ add by lw 2013-2-27
select * from docAttachment
drop TABLE docAttachment
CREATE TABLE docAttachment(
	applyID varchar(12) not null,					--���ı��
	rowNum bigint IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	
	aFilename varchar(128) null,					--ԭʼ�ļ���
	uidFilename varchar(128) not null,				--UID�ļ���
	fileSize bigint null,							--�ļ��ߴ�
	fileType varchar(10),							--�ļ�����
	uploadTime smalldatetime default(getdate()),	--�ϴ�����
 CONSTRAINT [PK_docAttachment] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--ԭʼ�ļ���������
CREATE NONCLUSTERED INDEX [IX_docAttachment] ON [dbo].[docAttachment]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�ļ�����������
CREATE NONCLUSTERED INDEX [IX_docAttachment_1] ON [dbo].[docAttachment]
(
	[fileType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--1.������ǼǱ�
select l.leaveRequestID, l.applyStatus, 
	convert(varchar(10),l.applyTime,120) applyTime, 
	l.applyManType, l.applyManID, l.applyMan, 
	convert(varchar(10),l.leaveStartTime,120) leaveStartTime, convert(varchar(10),l.leaveEndTime,120) leaveEndTime, 
	l.leaveReason
from leaveRequestInfo l
select l.leaveRequestID, l.applyStatus, convert(varchar(10),l.applyTime,120) applyTime, l.applyManType, l.applyManID, l.applyMan, convert(varchar(10),l.leaveStartTime,120) leaveStartTime, convert(varchar(10),l.leaveEndTime,120) leaveEndTime, l.leaveReason,convert(varchar(10),l.approveTime,120) approveTime,l.approveManID,l.approveMan,l.approveStatus from leaveRequestInfo l where l.leaveRequestID ='QJ20130110'

select * from leaveRequestInfo
update leaveRequestInfo
set applystatus = 0
delete leaveRequestInfo
drop table leaveRequestInfo
CREATE TABLE leaveRequestInfo(
	leaveRequestID varchar(10) not null,--��������������,��ϵͳʹ�õ�300�ź��뷢����������'QJ'+4λ��ݴ���+4λ��ˮ�ţ�,�ɹ����������ṩ����
	applyStatus smallint default(0),	--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	applyTime smalldatetime null,		--����ʱ��
	applyManType smallint null,			--��������1->�̹���9->ѧ��
	applyManID varchar(10) not null,	--����˹���
	applyMan nvarchar(30) not null,		--������������������
	
	leaveStartTime smalldatetime null,	--��ٿ�ʼʱ��
	leaveEndTime smalldatetime null,	--��ٽ���ʱ��
	leaveReason nvarchar(300) null,		--�������
	--attachment varchar(128) null,			--�����ļ���	del by lw2013-2-27�������ü�����ƣ�֧�ֶ������
	
	--����״̬�������������������Ĺ���������add by lw 2013-2-27
	approveTime smalldatetime null,		--��׼ʱ��
	approveManID varchar(10) null,		--��׼�˹���
	approveMan nvarchar(30) null,		--��׼���������������
	approveStatus smallint null,		--��׼״̬��0->δ֪��1->��׼��-1->����׼
 CONSTRAINT [PK_leaveRequestInfo] PRIMARY KEY CLUSTERED 
(
	[leaveRequestID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����˹���������
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo] ON [dbo].[leaveRequestInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--���������������
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo_1] ON [dbo].[leaveRequestInfo] 
(
	[applyMan] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��׼�˹���������
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo_2] ON [dbo].[leaveRequestInfo] 
(
	[approveManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��׼��������
CREATE NONCLUSTERED INDEX [IX_leaveRequestInfo_3] ON [dbo].[leaveRequestInfo] 
(
	[approveMan] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

delete eqpApplyInfo
--2.�豸�ɹ������
drop table eqpApplyInfo
CREATE TABLE eqpApplyInfo(
	eqpApplyID varchar(10) not null,	--�������豸�ɹ�������,��ϵͳʹ�õ�301�ź��뷢����������'CG'+4λ��ݴ���+4λ��ˮ�ţ�,�ɹ����������ṩ����
	applyStatus smallint default(0),	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵
	applyReason nvarchar(300) null,		--�ɹ�����/��;
	
	applyManID varchar(10) not null,	--�����˹���
	applyMan nvarchar(30) not null,		--�������������������
	applyTime smalldatetime null,		--��������
	
	preSumQuantity int default(0),		--Ԥ����̨����
	preSumMoney numeric(15,2) default(0),--Ԥ���ܽ��

	sumQuantity int default(0),			--��̨����
	sumMoney numeric(15,2) default(0),	--�ܽ��

	tSumQuantity int default(0),		--�б���̨����
	tSumMoney numeric(15,2) default(0),	--�б��ܽ��

	--�б������
	tenderInfo nvarchar(300) null,		--�б�������˵�� add by lw 2013-2-28
	
	departManagerID varchar(10) null,	--��������
	departManager nvarchar(30) null,	--�����������������
	dApproveTime smalldatetime null,	--��׼ʱ��
	departOpinion nvarchar(300) null,	--�������
	
	chiefEngineerID varchar(10) null,	--�ܹ�����
	chiefEngineer nvarchar(30) null,	--�ܹ��������������
	eApproveTime smalldatetime null,	--��׼ʱ��
	chiefEngineerOpinion nvarchar(300) null,	--�ܹ����
	
	chiefEconomistID varchar(10) null,	--�ܾ���ʦ����
	chiefEconomist nvarchar(30) null,	--�ܾ���ʦ�������������
	ecApproveTime smalldatetime null,	--��׼ʱ��
	chiefEconomistOpinion nvarchar(300) null,	--�ܾ���ʦ���
	
	generalManagerID varchar(10) null,	--�ܾ�����
	generalManager nvarchar(30) null,	--�ܾ�������
	gApproveTime smalldatetime null,	--��׼ʱ��
	generalManagerOpinion nvarchar(300) null,	--�ܾ������
	
	remark nvarchar(300) null,			--��ע

 CONSTRAINT [PK_eqpApplyInfo] PRIMARY KEY CLUSTERED 
(
	[eqpApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�����˹���������
CREATE NONCLUSTERED INDEX [IX_eqpApplyInfo] ON [dbo].[eqpApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.1�ɹ������豸��ϸ��
drop TABLE eqpApplyDetail
CREATE TABLE eqpApplyDetail(
	eqpApplyID varchar(10) not null,	--���/�������豸�ɹ�������
	rowNum int IDENTITY(1,1) NOT NULL,	--���������
	
	--���룺
	preEqpCode nvarchar(30) not null,	--�豸��ż�������ҳ��
	preEqpName nvarchar(60) not null,	--�豸���Ƽ��ͺ�
	prePrice numeric(12,2) null,		--Ԥ�Ƶ��ۣ�Ԫ��
	preQuantity int null,				--Ԥ������
	preTotalMoney numeric(15,2) default(0),--Ԥ���ܼۣ�Ԫ��
	
	--�б���ɣ�
	business nvarchar(20) null,			--���۵�λ
	eqpName nvarchar(60) null,			--�豸���Ƽ��ͺ�
	price numeric(12,2) null,			--���ۣ�Ԫ��
	quantity int null,					--����
	totalMoney numeric(15,2) default(0),--�ܼۣ�Ԫ��

 CONSTRAINT [PK_eqpApplyDetail] PRIMARY KEY CLUSTERED 
(
	[eqpApplyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpApplyDetail] WITH CHECK ADD CONSTRAINT [FK_eqpApplyDetail_eqpApplyInfo] FOREIGN KEY([eqpApplyID])
REFERENCES [dbo].[eqpApplyInfo] ([eqpApplyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpApplyDetail] CHECK CONSTRAINT [FK_eqpApplyDetail_eqpApplyInfo]
GO


--3.���ķ��������
select t.thesisPublishApplyID, t.applyManID, t.applyMan, convert(varchar(10),t.applyTime,120) applyTime,
	t.elseAuthor, t.thesisTitle, t.summary, t.keys, t.prePeriodicalName,
	t.elseAuthorNum, t.agreeNum
from thesisPublishApplyInfo t

drop table thesisPublishApplyInfo
CREATE TABLE thesisPublishApplyInfo(
	thesisPublishApplyID varchar(10) not null,	--���������ķ���������,��ϵͳʹ�õ�302�ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�,�ɹ����������ṩ����
	applyStatus smallint default(0),	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	applyManID varchar(10) not null,	--�����˹���
	applyMan nvarchar(30) not null,		--�������������������
	applyTime smalldatetime null,		--��������
	elseAuthor xml,						--�������ߣ�����N'<root><elseAuthor id="G201300001" name="��Զ"></elseAuthor></root>'��ʽ���
	thesisTitle nvarchar(40) null,		--������Ŀ
	summary nvarchar(300) null,			--���ݼ��
	keys nvarchar(30) null,				--�ؼ��֣�����ؼ���ʹ��","�ָ�

	prePeriodicalName nvarchar(40) not null,--��Ͷ��־����

	elseAuthorNum int null,				--������������
	agreeNum smallint default(0),		--ͬ��������0->δ֪��-1���з��ԣ�1~n��ͬ��Ʊ��
	isCanPublish smallint default(0),	--��������0->δ֪��1��ͬ�ⷢ��2����ͬ�ⷢ��
 CONSTRAINT [PK_thesisPublishApplyInfo] PRIMARY KEY CLUSTERED 
(
	[thesisPublishApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�����˹���������
CREATE NONCLUSTERED INDEX [IX_thesisPublishApplyInfo] ON [dbo].[thesisPublishApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--4.����ӹ������
drop table processApplyInfo
CREATE TABLE processApplyInfo(
	processApplyID varchar(10) not null,	--����������ӹ�������,��ϵͳʹ�õ�303�ź��뷢����������'JG'+4λ��ݴ���+4λ��ˮ�ţ�
	applyStatus smallint default(0),		--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	applyManID varchar(10) not null,		--�����˹���
	applyMan nvarchar(30) not null,			--�������������������
	applyTime smalldatetime null,			--��������
	
	preCompletedTime smalldatetime null,	--�������ʱ��
	applyReason nvarchar(300) null,			--��������
	--attachmentFile varchar(128) null,		--�����ļ�·��	del by lw 2013-3-2ͳһ��ƿ��Ǹ���

	processerID varchar(10) null,			--�ӹ��˹���
	processer nvarchar(30) null,			--�ӹ��ˡ��������
	appointTime smalldatetime null,			--ָ��ʱ��
	isCompleted smallint default(0),		--�ӹ�״̬��0->δ֪��1->���ڼӹ���9->���, 10->�޷����
	completedTime smalldatetime null,		--���ʱ��
	completeIntro nvarchar(300) null,		--������
 CONSTRAINT [PK_processApplyInfo] PRIMARY KEY CLUSTERED 
(
	[processApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�����˹���������
CREATE NONCLUSTERED INDEX [IX_processApplyInfo] ON [dbo].[processApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--5.���������
select * from otherApplyInfo
drop table otherApplyInfo
CREATE TABLE otherApplyInfo(
	otherApplyID varchar(10) not null,	--����������������,��ϵͳʹ�õ�304�ź��뷢����������'QT'+4λ��ݴ���+4λ��ˮ�ţ�
	applyStatus smallint default(0),	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	applyManID varchar(10) not null,	--�����˹���
	applyMan nvarchar(30) not null,		--�������������������
	applyTime smalldatetime null,		--��������
	
	title nvarchar(40) null,			--����
	summary nvarchar(300) null,			--����
	keys nvarchar(30) null,				--�ؼ��֣�����ؼ���ʹ��","�ָ�

 CONSTRAINT [PK_otherApplyInfo] PRIMARY KEY CLUSTERED 
(
	[otherApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�����˹���������
CREATE NONCLUSTERED INDEX [IX_otherApplyInfo] ON [dbo].[otherApplyInfo] 
(
	[applyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE addDocAttachment
/*
	name:		1.addDocAttachment
	function:	��ӹ��ĸ���
				@applyID varchar(12),		--���ı��
				@aFilename varchar(128),	--ԭʼ�ļ���
				@uidFilename varchar(128),	--UID�ļ���
				@fileSize bigint,			--�ļ��ߴ�
				@fileType varchar(10),		--�ļ�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
										0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-20
	UpdateDate: 
*/
create PROCEDURE addDocAttachment
	@applyID varchar(12),		--���ı��
	@aFilename varchar(128),	--ԭʼ�ļ���
	@uidFilename varchar(128),	--UID�ļ���
	@fileSize bigint,			--�ļ��ߴ�
	@fileType varchar(10),		--�ļ�����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	insert docAttachment(applyID, aFilename, uidFilename, fileSize, fileType)
	values(@applyID, @aFilename, @uidFilename, @fileSize, @fileType)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO

drop PROCEDURE delDocAttachment
/*
	name:		delDocAttachment
	function:	2.ɾ��ָ������ָ��UID�ĸ���
	input: 
				@applyID varchar(12),		--���ı��
				@uidFilename varchar(128),	--UID�ļ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĸ��������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-20
	UpdateDate: 
*/
create PROCEDURE delDocAttachment
	@applyID varchar(12),		--���ı��
	@uidFilename varchar(128),	--UID�ļ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�ָ���ĸ����Ƿ����
	declare @count as int
	set @count=(select count(*) from docAttachment where applyID = @applyID and uidFilename = @uidFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	delete docAttachment where applyID = @applyID and uidFilename = @uidFilename
	
	set @Ret = 0
GO


drop PROCEDURE addLeaveRequest
/*
	name:		addLeaveRequest
	function:	1.1.����������Ϣ
	input: 
				@leaveRequestID varchar(10),	--��������
				@leaveStartTime varchar(19),	--��ٿ�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@leaveEndTime varchar(19),		--��ٽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@leaveReason nvarchar(300),		--�������

				@createManID varchar(10),		--�����˹���

	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-27
	UpdateDate: modi by lw 2013-1-20 ���ù��������棬����������������������������Ӧ�޸Ľӿ�
*/
create PROCEDURE addLeaveRequest
	@leaveRequestID varchar(10),	--��������
	@leaveStartTime varchar(19),	--��ٿ�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@leaveEndTime varchar(19),		--��ٽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@leaveReason nvarchar(300),		--�������

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ�����˵����͡�������
	declare @applyManType smallint, @createManName nvarchar(30)
	select @createManName = cName, @applyManType = manType from userInfo where jobNumber = @createManID
	
	set @createTime = getdate()
	insert leaveRequestInfo(leaveRequestID, applyTime, applyManType, applyManID, applyMan,
					leaveStartTime, leaveEndTime, leaveReason)
	values(@leaveRequestID, @createTime, @applyManType, @createManID, @createManName,
					@leaveStartTime, @leaveEndTime, @leaveReason)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ������['+@leaveRequestID+']��')
GO

drop PROCEDURE updateLeaveRequest
/*
	name:		updateLeaveRequest
	function:	1.2.�޸��������Ϣ
	input: 
				@leaveRequestID varchar(10),	--��������
				@leaveStartTime varchar(19),	--��ٿ�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@leaveEndTime varchar(19),		--��ٽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@leaveReason nvarchar(300),		--�������

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�����������ڣ�
							3����������Ѿ����ͣ����ܱ༭��
							4����������Ѿ����������ܱ༭��
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2012-12-27
	UpdateDate: modi by lw 2013-2-27 ���ù��������棬�������������Ӧ�޸Ĵ���
*/
create PROCEDURE updateLeaveRequest
	@leaveRequestID varchar(10),	--��������
	@leaveStartTime varchar(19),	--��ٿ�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@leaveEndTime varchar(19),		--��ٽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@leaveReason nvarchar(300),		--�������

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�޸ĵ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	select @applyStatus = applyStatus
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--�ж�״̬��
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end
	else if (@applyStatus=9)
	begin
		set @Ret = 4
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update leaveRequestInfo
	set leaveStartTime = @leaveStartTime, leaveEndTime = @leaveEndTime, leaveReason = @leaveReason,
		applyStatus = 0		--״̬�ָ�����ʼ״̬
	where leaveRequestID= @leaveRequestID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸������', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��������['+@leaveRequestID+']��')
GO

drop PROCEDURE delLeaveRequest
/*
	name:		delLeaveRequest
	function:	1.3.ɾ��ָ���������
	input: 
				@leaveRequestID varchar(10),	--��������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ��������������ڣ�
							3����������Ѿ����ͣ�����ɾ����
							4����������Ѿ�����������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-27
	UpdateDate: modi by lw 2013-2-27 ���ù��������棬�������������Ӧ�޸Ĵ���

*/
create PROCEDURE delLeaveRequest
	@leaveRequestID varchar(10),	--��������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������������Ƿ����
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	select @applyStatus = applyStatus
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--�ж�״̬��
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end
	else if (@applyStatus=9)
	begin
		set @Ret = 4
		return
	end

	delete leaveRequestInfo where leaveRequestID= @leaveRequestID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ�������', '�û�' + @delManName
												+ 'ɾ���������['+@leaveRequestID+']��')

GO

drop PROCEDURE approvalLeaveRequest
/*
	name:		approvalLeaveRequest
	function:	1.4.���������
	input: 
				@leaveRequestID varchar(10),		--��������

				@approveManID varchar(10),			--��׼�˹���
				@approveStatus smallint,			--����������ͣ�0->δ֪��1->��׼��-1->����׼
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ��������������ڣ�2����������Ѿ�������9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-27
	UpdateDate: 
*/				
create PROCEDURE approvalLeaveRequest
	@leaveRequestID varchar(10),	--��������
	@approveManID varchar(10),		--��׼�˹���
	@approveStatus smallint,		--����������ͣ�0->δ֪��1->��׼��-1->����׼
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������������Ƿ����
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ���ݻ�����Ϣ����鵥��״̬��
	declare @applyManID varchar(10), @applyMan nvarchar(30)	--���������
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	declare @leaveStartTime smalldatetime	--��ٿ�ʼʱ��
	declare @leaveEndTime smalldatetime		--��ٽ���ʱ��
	declare @leaveReason nvarchar(300)		--�������
	select @applyManID = applyManID, @applyMan = applyMan, @applyStatus = applyStatus, @leaveStartTime = leaveStartTime,
			@leaveEndTime = leaveEndTime, @leaveReason = leaveReason
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--�ж�״̬��
	if (@applyStatus=9)
	begin
		set @Ret = 2
		return
	end

	--ȡ��׼��������
	declare @approveMan nvarchar(30)			--��׼������
	select @approveMan = cName from userInfo where jobNumber=@approveManID
	
	--��׼ʱ�䣺
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	begin tran	
		update leaveRequestInfo
		set applyStatus = 9,				--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
			--����״̬��
			approveTime = @approveTime,		--��׼ʱ��
			approveManID = @approveManID,	--��׼�˹���
			approveMan = @approveMan,		--��׼���������������
			approveStatus = @approveStatus	--��׼״̬��0->δ֪��1->��׼��-1->����׼
		where leaveRequestID = @leaveRequestID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		if (@approveStatus=1)
		begin
			--�Ǽ�����״̬��
			declare @runRet int
			declare @createTime smalldatetime	--���ʱ��
			declare @rowNum int		--�ڲ��к�

			exec dbo.addDutyStatusInfo @applyManID, 2, @leaveStartTime, @leaveEndTime, @leaveReason, @applyManID, 
					@runRet output, @createTime output, @rowNum output
			if @runRet = 9
			begin
				rollback tran
				set @Ret = 9
				return
			end  
		end  
	commit tran
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '���������', '�û�' + @applyMan
												+ '��׼��['+@applyMan+']�������['+@leaveRequestID+']��')

GO

drop PROCEDURE setLeaveRequestStatus
/*
	name:		setLeaveRequestStatus
	function:	1.5.���������״̬
				ע�⣺�������û�еǼǹ�����־
	input: 
				@leaveRequestID varchar(10),		--��������
				@applyStatus smallint,				--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ��������������ڣ�2����������Ѿ�������9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-27
	UpdateDate: 
*/				
create PROCEDURE setLeaveRequestStatus
	@leaveRequestID varchar(10),	--��������
	@applyStatus smallint,			--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������������Ƿ����
	declare @count as int
	set @count=(select count(*) from leaveRequestInfo where leaveRequestID= @leaveRequestID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ���ݻ�����Ϣ����鵥��״̬��
	declare @applyOldStatus smallint			--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	select @applyOldStatus = applyStatus
	from leaveRequestInfo 
	where leaveRequestID= @leaveRequestID
	--�ж�״̬��
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update leaveRequestInfo
	set applyStatus = @applyStatus				--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	where leaveRequestID = @leaveRequestID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE sendLeaveRequest
drop PROCEDURE cancelSendLeaveRequest
drop PROCEDURE approveLeaveRequest

--�������ѯ��䣺
select l.leaveRequestID, l.applyStatus, 
	convert(varchar(10),l.applyTime,120) applyTime, 
	l.applyManType, l.applyManID, l.applyMan, 
	convert(varchar(10),l.leaveStartTime,120) leaveStartTime, convert(varchar(10),l.leaveEndTime,120) leaveEndTime, 
	l.leaveReason
from leaveRequestInfo l



drop PROCEDURE addEqpApplyInfo
/*
	name:		addEqpApplyInfo
	function:	2.1.����豸�ɹ�����
	input: 
				@eqpApplyID varchar(10),	--�豸�ɹ�������,��ϵͳʹ�õ�301�ź��뷢����������'CG'+4λ��ݴ���+4λ��ˮ�ţ�,�й���������Ԥ����
				@applyReason nvarchar(300),	--�ɹ�����/��;
				@eqpApplyDetail xml,		--�ƻ��ɹ��豸��ϸ N'<root>
																--	<row id="1">
																--		<preEqpCode>10000014��������P1</preEqpCode>
																--		<preEqpName>�̵���5000W</preEqpName>
																--		<prePrice>10000.00</prePrice>
																--		<preQuantity>2</preQuantity>
																--	</row>
																--	<row id="2">
																--		<preEqpCode>10000015��������P2</preEqpCode>
																--		<preEqpName>�̵���3000W</preEqpName>
																--		<prePrice>8000.00</prePrice>
																--		<preQuantity>9</preQuantity>
																--	</row>
																--	...
																--</root>'
				
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--��������
				@remark nvarchar(300),		--��ע

				@createManID varchar(10),	--�����˹���

	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 ���ù��������棬����������������������������Ӧ�޸Ľӿ�
*/
create PROCEDURE addEqpApplyInfo
	@eqpApplyID varchar(10),	--�豸�ɹ�������,��ϵͳʹ�õ�301�ź��뷢����������'CG'+4λ��ݴ���+4λ��ˮ�ţ�,�й���������Ԥ����
	@applyReason nvarchar(300),	--�ɹ�����/��;
	@eqpApplyDetail xml,		--�ƻ��ɹ��豸��ϸ
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--��������
	@remark nvarchar(300),		--��ע

	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ�����ˡ������˵�������
	declare @applyMan nvarchar(30), @createManName nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	begin tran
		insert eqpApplyInfo(eqpApplyID, applyReason, applyManID, applyMan, applyTime, remark)
		values(@eqpApplyID, @applyReason, @applyManID, @applyMan, @applyTime, @remark)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--������ϸ�����ݣ�
		insert eqpApplyDetail(eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, preTotalMoney)
		select @eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, prePrice * preQuantity 
		from (select cast(T.x.query('data(./preEqpCode)') as nvarchar(30)) preEqpCode, 
				cast(T.x.query('data(./preEqpName)') as nvarchar(60)) preEqpName,
				cast(cast(T.x.query('data(./prePrice)') as varchar(13)) as numeric(12,2)) prePrice,
				cast(cast(T.x.query('data(./preQuantity)') as varchar(8)) as int) preQuantity
			from(select @eqpApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--�����ܼƣ�
		declare @preSumQuantity int, @preSumMoney numeric(15,2)
		set @preSumQuantity = isnull((select SUM(preQuantity) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		set @preSumMoney = isnull((select SUM(preTotalMoney) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		update eqpApplyInfo
		set preSumQuantity = @preSumQuantity, preSumMoney = @preSumMoney
		where eqpApplyID = @eqpApplyID
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
	values(@createManID, @createManName, @createTime, '�Ǽ��豸�ɹ�����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ��豸�ɹ�����['+@eqpApplyID+']��')
GO
--���ԣ�
declare @Ret		int
declare @createTime smalldatetime
declare @eqpApplyID varchar(10) 
declare @eqpApplyDetail xml		--�ƻ��ɹ��豸��ϸ 
set @eqpApplyDetail =N'<root>
						<row id="1">
							<preEqpCode>10000014��������P1</preEqpCode>
							<preEqpName>�̵���5000W</preEqpName>
							<prePrice>10000.00</prePrice>
							<preQuantity>2</preQuantity>
						</row>
						<row id="2">
							<preEqpCode>10000015��������P2</preEqpCode>
							<preEqpName>�̵���3000W</preEqpName>
							<prePrice>8000.00</prePrice>
							<preQuantity>9</preQuantity>
						</row>
						...
					</root>'
exec dbo.addEqpApplyInfo '����',@eqpApplyDetail, '00001', '2012-12-28', '��ע����','00001', @Ret output, @createTime output, @eqpApplyID output
select @Ret

select * from eqpApplyDetail
select * from eqpApplyInfo



drop PROCEDURE updateEqpApplyInfo
/*
	name:		updateEqpApplyInfo
	function:	2.2.�޸��豸�ɹ�������
	input: 
				@eqpApplyID varchar(10),	--�豸�ɹ�������
				@applyReason nvarchar(300),	--�ɹ�����/��;
				@eqpApplyDetail xml,		--�ƻ��ɹ��豸��ϸ
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--��������
				@remark nvarchar(300),		--��ע

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ��豸�ɹ����벻���ڣ�
							3:���豸�ɹ������Ѿ������������ڣ����ܱ༭��
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 ���ù��������棬�������������Ӧ�޸Ľӿ�
*/
create PROCEDURE updateEqpApplyInfo
	@eqpApplyID varchar(10),	--�豸�ɹ�������
	@applyReason nvarchar(300),	--�ɹ�����/��;
	@eqpApplyDetail xml,		--�ƻ��ɹ��豸��ϸ
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--��������
	@remark nvarchar(300),		--��ע

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�޸ĵ��豸�ɹ������Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鵥��״̬��
	declare @applyStatus smallint	----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵
	select @applyStatus = applyStatus
	from eqpApplyInfo 
	where eqpApplyID= @eqpApplyID
	--�ж�״̬��
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	--ȡ�����ˣ�
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		update eqpApplyInfo
		set applyReason = @applyReason, applyManID = @applyManID, applyMan = @applyMan, 
			applyTime = @applyTime, remark = @remark
		where eqpApplyID = @eqpApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--������ϸ�����ݣ�
		delete eqpApplyDetail where eqpApplyID = @eqpApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		insert eqpApplyDetail(eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, preTotalMoney)
		select @eqpApplyID, preEqpCode, preEqpName, prePrice, preQuantity, prePrice * preQuantity 
		from (select cast(T.x.query('data(./preEqpCode)') as nvarchar(30)) preEqpCode, 
				cast(T.x.query('data(./preEqpName)') as nvarchar(60)) preEqpName,
				cast(cast(T.x.query('data(./prePrice)') as varchar(13)) as numeric(12,2)) prePrice,
				cast(cast(T.x.query('data(./preQuantity)') as varchar(8)) as int) preQuantity
			from(select @eqpApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--�����ܼƣ�
		declare @preSumQuantity int, @preSumMoney numeric(15,2)
		set @preSumQuantity = isnull((select SUM(preQuantity) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		set @preSumMoney = isnull((select SUM(preTotalMoney) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		update eqpApplyInfo
		set preSumQuantity = @preSumQuantity, preSumMoney = @preSumMoney
		where eqpApplyID = @eqpApplyID
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
	values(@modiManID, @modiManName, @modiTime, '�޸��豸�ɹ�����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸����豸�ɹ�����['+@eqpApplyID+']��')
GO
declare @modiManID varchar(10)	--�����˹���
set @modiManID='00001'
declare @Ret		int
declare @modiTime smalldatetime
declare @eqpApplyDetail xml		--�ƻ��ɹ��豸��ϸ 
set @eqpApplyDetail =N'<root>
						<row id="1">
							<preEqpCode>10000014��������P12</preEqpCode>
							<preEqpName>�̵���5000W</preEqpName>
							<prePrice>10000.00</prePrice>
							<preQuantity>2</preQuantity>
						</row>
						<row id="2">
							<preEqpCode>10000015��������P23</preEqpCode>
							<preEqpName>�̵���3000W</preEqpName>
							<prePrice>8000.00</prePrice>
							<preQuantity>9</preQuantity>
						</row>
						...
					</root>'
exec dbo.updateEqpApplyInfo 'CG20120002', '�����޸�',@eqpApplyDetail, '00001', '2012-12-28', '��ע�����޸�',
	@modiManID output, @Ret output, @modiTime output
select @Ret

select * from eqpApplyDetail
select * from eqpApplyInfo

drop PROCEDURE delEqpApplyInfo
/*
	name:		delEqpApplyInfo
	function:	2.3.ɾ��ָ�����豸�ɹ�����
	input: 
				@eqpApplyID varchar(10),		--�豸�ɹ�������
				@delManID varchar(10),			--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����豸�ɹ����벻���ڣ�
							3:���豸�ɹ������Ѿ������������ڣ�����ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 ���ù��������棬�������������Ӧ�޸Ľӿ�

*/
create PROCEDURE delEqpApplyInfo
	@eqpApplyID varchar(10),		--�豸�ɹ�������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�豸�ɹ��������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ�����豸�ɹ������Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鵥��״̬��
	declare @applyStatus smallint	----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵
	select @applyStatus = applyStatus
	from eqpApplyInfo
	where eqpApplyID= @eqpApplyID
	--�ж�״̬��
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	delete eqpApplyInfo where eqpApplyID= @eqpApplyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���豸�ɹ�����', '�û�' + @delManName
												+ 'ɾ�����豸�ɹ�����['+@eqpApplyID+']��')

GO

drop PROCEDURE approvalEqpApplyInfo
/*
	name:		approvalEqpApplyInfo
	function:	1.4.���ֽڵ���д�������
	input: 
				@eqpApplyID varchar(10),		--�豸�ɹ����뵥��
				@flowID int,					--�ڵ���
				@approveManID varchar(10),		--��׼�˹���
				@approveStatus smallint,		--����������ͣ�0->δ֪��1->��׼��-1->����׼
				@approveOpinion nvarchar(300),	--�������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ��������������ڣ�2���������Ѿ���ɣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-28
	UpdateDate: 
*/				
create PROCEDURE approvalEqpApplyInfo
	@eqpApplyID varchar(10),		--�豸�ɹ����뵥��
	@flowID int,					--�ڵ���
	@approveManID varchar(10),		--��׼�˹���
	@approveStatus smallint,		--����������ͣ�0->δ֪��1->��׼��-1->����׼
	@approveOpinion nvarchar(300),	--�������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ���������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ���ݻ�����Ϣ����鵥��״̬��
	declare @applyStatus smallint	----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵
	select @applyStatus = applyStatus from eqpApplyInfo where eqpApplyID= @eqpApplyID
	--�ж�״̬��
	if (@applyStatus=9)
	begin
		set @Ret = 2
		return
	end

	--ȡ��׼��������
	declare @approveMan nvarchar(30)			--��׼������
	select @approveMan = cName from userInfo where jobNumber=@approveManID
	
	--��׼ʱ�䣺
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	
	if (@flowID=2)	--��������
	begin
		update eqpApplyInfo
		set departManagerID =@approveManID,	--��������
			departManager =@approveMan,	--�����������������
			dApproveTime =@approveTime,	--��׼ʱ��
			departOpinion =@approveOpinion	--�������
		where eqpApplyID= @eqpApplyID
	end
	else if (@flowID=3)
	begin
		update eqpApplyInfo
		set chiefEngineerID =@approveManID,	--�ܹ�����
			chiefEngineer =@approveMan,	--�ܹ��������������
			eApproveTime =@approveTime,	--��׼ʱ��
			chiefEngineerOpinion =@approveOpinion	--�ܹ����
		where eqpApplyID= @eqpApplyID
	end
	else if (@flowID=5)
	begin
		update eqpApplyInfo
		set chiefEconomistID=@approveManID,	--�ܾ���ʦ����
			chiefEconomist =@approveMan,	--�ܾ���ʦ�������������
			ecApproveTime =@approveTime,	--��׼ʱ��
			chiefEconomistOpinion =@approveOpinion	--�ܾ���ʦ���
		where eqpApplyID= @eqpApplyID
	end
	else if (@flowID=6)
	begin
		update eqpApplyInfo
		set generalManagerID=@approveManID,	--�ܾ�����
			generalManager=@approveMan,	--�ܾ�������
			gApproveTime=@approveTime,	--��׼ʱ��
			generalManagerOpinion=@approveOpinion	--�ܾ������
		where eqpApplyID= @eqpApplyID
	end
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '�����豸�ɹ����뵥', '�û�' + @approveMan
												+ '��׼���豸�ɹ����뵥['+@eqpApplyID+']��')

GO

drop PROCEDURE setEqpApplyStatus
/*
	name:		setEqpApplyStatus
	function:	2.5.�����豸�ɹ����뵥״̬
				ע�⣺�������û�еǼǹ�����־
	input: 
				@eqpApplyID varchar(10),		--�豸�ɹ����뵥��
				@applyStatus smallint,			----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����豸�ɹ����뵥�����ڣ�2�������뵥�Ѿ���ɣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-2-28
	UpdateDate: 
*/				
create PROCEDURE setEqpApplyStatus
	@eqpApplyID varchar(10),		--�豸�ɹ����뵥��
	@applyStatus smallint,			----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵

	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж����뵥�Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ���ݻ�����Ϣ����鵥��״̬��
	declare @applyOldStatus smallint			----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵
	select @applyOldStatus = applyStatus
	from eqpApplyInfo 
	where eqpApplyID= @eqpApplyID
	--�ж�״̬��
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update eqpApplyInfo 
	set applyStatus = @applyStatus				----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����˱༭������������������2->������׼���������ܹ�������
													--3->�ܹ���׼�����ط����˰����б�������
													--4->��������б���Ϣ���������ܾ���ʦ����
													--5->�ܾ���ʦ��׼���������ܾ�������
													--6->�ܾ�������
													--9->ִ����ɹ鵵
	where eqpApplyID= @eqpApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

drop PROCEDURE addTenderInfo
/*
	name:		addTenderInfo
	function:	2.6.����豸�ɹ��������б����˵��
				ע�⣺��������ͳһ����
	input: 
				@eqpApplyID varchar(10),	--�豸�ɹ�������
				@tenderInfo nvarchar(300) ,	--�б�������˵��
				@remark nvarchar(300),		--��ע
				@eqpTenderDetail xml,		--�ɹ��б��豸��ϸ

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ��豸�ɹ����벻���ڣ�
							3:���豸�ɹ����뻹û�е�������ڣ�
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-2-28 ���ù��������棬�������������Ӧ�޸Ľӿ�
*/
create PROCEDURE addTenderInfo
	@eqpApplyID varchar(10),	--�豸�ɹ�������
	@tenderInfo nvarchar(300) ,	--�б�������˵��
	@remark nvarchar(300),		--��ע
	@eqpTenderDetail xml,		--�ɹ��б��豸��ϸ
	
	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�޸ĵ��豸�ɹ������Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpApplyInfo where eqpApplyID= @eqpApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鵥��״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->���͵ȴ�������2->������׼�ȴ��ܹ���׼��3->�ܹ���׼�ȴ��б꣬
													--4->��б���Ϣ��ɵȴ��ܾ���ʦ��׼
													--5->�ܾ���ʦ��׼�ȴ��ܾ�����׼
													--6->�ܾ�����׼
													--9->ִ����ɹ鵵
	select @applyStatus = applyStatus
	from eqpApplyInfo 
	where eqpApplyID= @eqpApplyID
	--�ж�״̬��
	if (@applyStatus <> 4)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiMan nvarchar(30)
	set @modiMan = isnull((select cName from userInfo where jobNumber = @modiManID),'')
	
	set @modiTime = getdate()
	begin tran
		update eqpApplyInfo
		set tenderInfo = @tenderInfo, remark = @remark
		where eqpApplyID = @eqpApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--����б���ϸ�����ݣ�
		update eqpApplyDetail
		set eqpName = t.eqpName, business = t.business,
			price = t.price, quantity = t.quantity, totalMoney=t.price * t.quantity
		from eqpApplyDetail e left join (
					select cast((cast(T.x.query('data(./rowNum)') as nvarchar(12))) as int) rowNum,	--ԭ�����е��豸�к�
									cast(T.x.query('data(./eqpName)') as nvarchar(60)) eqpName,
									cast(T.x.query('data(./business)') as varchar(20)) business,
									cast(cast(T.x.query('data(./price)') as varchar(13)) as numeric(12,2)) price,
									cast(cast(T.x.query('data(./quantity)') as varchar(8)) as int) quantity
								from(select @eqpTenderDetail.query('/root/row') Col1) A
									OUTER APPLY A.Col1.nodes('/row') AS T(x)
					) t on e.eqpApplyID= @eqpApplyID and e.rowNum = t.rowNum
					
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		--�����ܼƣ�
		declare @tSumQuantity int, @tSumMoney numeric(15,2)
		set @tSumQuantity = isnull((select SUM(quantity) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		set @tSumMoney = isnull((select SUM(totalMoney) from eqpApplyDetail where eqpApplyID = @eqpApplyID),0)
		update eqpApplyInfo
		set tSumQuantity= @tSumQuantity, tSumMoney = @tSumMoney
		where eqpApplyID = @eqpApplyID
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
	values(@modiManID, @modiMan, @modiTime, '�޸��豸�ɹ�����', 'ϵͳ�����û�' + @modiMan + 
					'��Ҫ���޸����豸�ɹ�����['+@eqpApplyID+']��')
GO
declare @eqpTenderDetail xml		--�ƻ��ɹ��豸��ϸ 
set @eqpTenderDetail =N'<root>
						<row id="1">
							<rowNum>10000014</rowNum>
							<eqpName>�̵���5000W</eqpName>
							<business>��֮�ѵ�</business>
							<price>10000.00</price>
							<quantity>2</quantity>
						</row>
					</root>'
select T.rowNum
from
(
select cast((cast(T.x.query('data(./rowNum)') as nvarchar(12))) as int) rowNum,	--ԭ�����е��豸�к�
				cast(T.x.query('data(./eqpName)') as nvarchar(60)) eqpName,
				cast(T.x.query('data(./business)') as varchar(20)) business,
				cast(cast(T.x.query('data(./price)') as varchar(13)) as numeric(12,2)) price,
				cast(cast(T.x.query('data(./quantity)') as varchar(8)) as int) quantity
			from(select @eqpTenderDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
)as t

--�豸�ɹ������ѯ��䣺
select e.eqpApplyID, e.applyStatus, e.applyReason, 
	e.applyManID, e.applyMan, convert(varchar(10),e.applyTime,120) applyTime, 
	e.preSumQuantity, e.preSumMoney, e.sumQuantity, e.sumMoney
from eqpApplyInfo e


---------------------���ķ��������洢���̣�-------------------------------------------
drop PROCEDURE addThesisPublishApplyInfo
/*
	name:		addThesisPublishApplyInfo
	function:	3.1.������ķ������뵥
	input: 
				@thesisPublishApplyID varchar(10),	--���ķ���������,�ɹ������������ʹ�õ�302�ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
				@applyManID varchar(10),			--�����˹���
				@applyTime varchar(10),				--��������:���á�yyyy-MM-dd����ʽ����
				@elseAuthor xml,					--�������ߣ�����N'<root><elseAuthor id="G201300001" name="��Զ"></elseAuthor></root>'��ʽ���
				@thesisTitle nvarchar(40),			--������Ŀ
				@summary nvarchar(300),				--���ݼ��
				@keys nvarchar(30),					--�ؼ��֣�����ؼ���ʹ��","�ָ�
				@prePeriodicalName nvarchar(40),	--��Ͷ��־����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-1-24
	UpdateDate: 
*/
create PROCEDURE addThesisPublishApplyInfo
	@thesisPublishApplyID varchar(10),	--���ķ���������,�ɹ������������ʹ�õ�302�ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
	@applyManID varchar(10),			--�����˹���
	@applyTime varchar(10),				--��������:���á�yyyy-MM-dd����ʽ����
	@elseAuthor xml,					--�������ߣ�����N'<root><elseAuthor id="G201300001" name="��Զ"></elseAuthor></root>'��ʽ���
	@thesisTitle nvarchar(40),			--������Ŀ
	@summary nvarchar(300),				--���ݼ��
	@keys nvarchar(30),					--�ؼ��֣�����ؼ���ʹ��","�ָ�
	@prePeriodicalName nvarchar(40),	--��Ͷ��־����

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ�����˵�������
	declare @applyMan nvarchar(30)
	select @applyMan = cName from userInfo where jobNumber = @applyManID
	
	--ͳ����������������
	declare @count int
	set @count = (select @elseAuthor.value('count(/root/elseAuthor)','int'))
	
	insert thesisPublishApplyInfo(thesisPublishApplyID, applyManID, applyMan, applyTime, elseAuthor,
				thesisTitle, summary, keys, prePeriodicalName, elseAuthorNum)
	values(@thesisPublishApplyID, @applyManID, @applyMan, @applyTime, @elseAuthor,
		@thesisTitle, @summary, @keys, @prePeriodicalName, @count)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyMan, GETDATE(), '�Ǽ����ķ�����������', 'ϵͳ�����û�' + @applyMan + 
					'��Ҫ��Ǽ����ķ�����������['+@thesisPublishApplyID+']��')
GO

drop PROCEDURE updateThesisPublishApplyInfo
/*
	name:		updateThesisPublishApplyInfo
	function:	3.2.�޸����ķ�������
	input: 
				@thesisPublishApplyID varchar(10),	--���ķ���������,�ɹ������������ʹ�õ�302�ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
				@applyManID varchar(10),			--�����˹���
				@applyTime varchar(10),				--��������:���á�yyyy-MM-dd����ʽ����
				@elseAuthor xml,					--�������ߣ�����N'<root><elseAuthor id="G201300001" name="��Զ"></elseAuthor></root>'��ʽ���
				@thesisTitle nvarchar(40),			--������Ŀ
				@summary nvarchar(300),				--���ݼ��
				@keys nvarchar(30),					--�ؼ��֣�����ؼ���ʹ��","�ָ�
				@prePeriodicalName nvarchar(40),	--��Ͷ��־����
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ����뵥�����ڣ�
							3:Ҫ�޸ĵ����뵥�Ѿ����ͣ��������޸ģ�
							9:δ֪����
	author:		¬έ
	CreateDate:	2013-1-24
	UpdateDate: 
*/
create PROCEDURE updateThesisPublishApplyInfo
	@thesisPublishApplyID varchar(10),	--���ķ���������,�ɹ������������ʹ�õ�302�ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
	@applyManID varchar(10),			--�����˹���
	@applyTime varchar(10),				--��������:���á�yyyy-MM-dd����ʽ����
	@elseAuthor xml,					--�������ߣ�����N'<root><elseAuthor id="G201300001" name="��Զ"></elseAuthor></root>'��ʽ���
	@thesisTitle nvarchar(40),			--������Ŀ
	@summary nvarchar(300),				--���ݼ��
	@keys nvarchar(30),					--�ؼ��֣�����ؼ���ʹ��","�ָ�
	@prePeriodicalName nvarchar(40),	--��Ͷ��־����

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--��鵥���Ƿ����
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	--��鵥��״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->������
													--9->ִ����ɹ鵵
	select @applyStatus = applyStatus from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID
	if (@applyStatus not in(0,-1))
	begin
		set @Ret = 3
		return
	end

	--ȡ������/�����˵�������
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	--ͳ����������������
	set @count = (select @elseAuthor.value('count(/root/elseAuthor)','int'))
	
	update thesisPublishApplyInfo
	set applyManID = @applyManID, applyMan = @applyMan, applyTime = @applyTime, elseAuthor = @elseAuthor,
				thesisTitle = @thesisTitle, summary = @summary, keys = @keys, 
				prePeriodicalName = @prePeriodicalName, elseAuthorNum = @count
	where thesisPublishApplyID = @thesisPublishApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyMan, GETDATE(), '�޸����ķ�����������', 'ϵͳ�����û�' + @applyMan + 
					'��Ҫ���޸������ķ�����������['+@thesisPublishApplyID+']��')
GO

drop PROCEDURE delThesisPublishApplyInfo
/*
	name:		delThesisPublishApplyInfo
	function:	3.3.ɾ��ָ�������ķ�������
	input: 
				@thesisPublishApplyID varchar(10),	--���ķ���������,�ɹ������������ʹ�õ�302�ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
				@delManID varchar(10),			--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������벻���ڣ���
							3���������Ѿ����ͣ�������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-24
	UpdateDate: 

*/
create PROCEDURE delThesisPublishApplyInfo
	@thesisPublishApplyID varchar(10),	--���ķ���������,�ɹ������������ʹ�õ�302�ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
	@delManID varchar(10),			--ɾ����
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--��鵥���Ƿ����
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	--��鵥��״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->������
													--9->ִ����ɹ鵵
	select @applyStatus = applyStatus from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID
	if (@applyStatus not in(0,-1))
	begin
		set @Ret = 3
		return
	end

	delete thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ�����ķ�����������', '�û�' + @delManName
												+ 'ɾ�������ķ�����������['+@thesisPublishApplyID+']��')

	set @Ret = 0
GO
use hustOA
select * from thesisPublishApplyInfo
update thesisPublishApplyInfo
set applyStatus=1, agreeNum=0, isCanPublish=0
where thesisPublishApplyID='WF20130222'

drop PROCEDURE approvalThesisPublishApply
/*
	name:		approvalThesisPublishApply
	function:	3.4.�������ķ�������
	input: 
				@thesisPublishApplyID varchar(10),	--���ķ���������

				@approveManID varchar(10),			--��׼�˹���
				@approveStatus smallint,			--����������ͣ�0->δ֪��1->��׼��-1->����׼
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ�������ķ������벻���ڣ�2�������ķ��������Ѿ�������ɣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-3-25
	UpdateDate: 
*/				
create PROCEDURE approvalThesisPublishApply
	@thesisPublishApplyID varchar(10),	--���ķ���������
	@approveManID varchar(10),			--��׼�˹���
	@approveStatus smallint,			--����������ͣ�0->δ֪��1->��׼��-1->����׼
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ���������ķ��������Ƿ����
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ���ݻ�����Ϣ����鵥��״̬��
	declare @applyManID varchar(10), @applyMan nvarchar(30)	--������
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	declare @elseAuthorNum int		--������������
	declare @agreeNum smallint		--ͬ��������0->δ֪��-1���з��ԣ�1~n��ͬ��Ʊ��
	select @applyManID = applyManID, @applyMan = applyMan, @applyStatus = applyStatus, 
			@elseAuthorNum = isnull(elseAuthorNum,0), @agreeNum = isnull(agreeNum,0)
	from thesisPublishApplyInfo 
	where thesisPublishApplyID= @thesisPublishApplyID
	--�ж�״̬��
	if (@applyStatus=9)
	begin
		set @Ret = 2
		return
	end

	--ȡ��׼��������
	declare @approveMan nvarchar(30)			--��׼������
	select @approveMan = cName from userInfo where jobNumber=@approveManID
	
	--��׼ʱ�䣺
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	begin tran	
		if (@agreeNum>=0 and @approveStatus=1)--����������ͣ�0->δ֪��1->��׼��-1->����׼
		begin
			set @agreeNum = @agreeNum + 1
			update thesisPublishApplyInfo
			set agreeNum = @agreeNum
			where thesisPublishApplyID = @thesisPublishApplyID
		end
		else if (@approveStatus=-1)--����������ͣ�0->δ֪��1->��׼��-1->����׼
		begin
			update thesisPublishApplyInfo
			set agreeNum = -1,
				applyStatus = 9,
				isCanPublish =2			--��������0->δ֪��1��ͬ�ⷢ��2����ͬ�ⷢ��
			where thesisPublishApplyID = @thesisPublishApplyID
		end
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end 
		if (@elseAuthorNum=@agreeNum)
		begin   
			update thesisPublishApplyInfo
			set applyStatus = 9,
				isCanPublish =1			--��������0->δ֪��1��ͬ�ⷢ��2����ͬ�ⷢ��
			where thesisPublishApplyID = @thesisPublishApplyID
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end 
		end
	commit tran
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '�������ķ�������', '�û�' + @applyMan
												+ '��׼��['+@applyMan+']�����ķ�������['+@thesisPublishApplyID+']��')

GO


drop PROCEDURE setThesisPublishApplyStatus
/*
	name:		setThesisPublishApplyStatus
	function:	3.5.�������ķ������뵥״̬
				ע�⣺�������û�еǼǹ�����־
	input: 
				@thesisPublishApplyID varchar(10),	--���ķ���������
				@applyStatus smallint,				--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ�������ķ������벻���ڣ�2�������ķ��������Ѿ�������ɣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-3-25
	UpdateDate: 
*/				
create PROCEDURE setThesisPublishApplyStatus
	@thesisPublishApplyID varchar(10),	--���ķ���������
	@applyStatus smallint,				--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ���������ķ��������Ƿ����
	declare @count as int
	set @count=(select count(*) from thesisPublishApplyInfo where thesisPublishApplyID= @thesisPublishApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ���ݻ�����Ϣ����鵥��״̬��
	declare @applyOldStatus smallint			--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	select @applyOldStatus = applyStatus
	from thesisPublishApplyInfo 
	where thesisPublishApplyID= @thesisPublishApplyID
	--�ж�״̬��
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update thesisPublishApplyInfo
	set applyStatus = @applyStatus				--����״̬��0->�½�δ���ͣ�1->���͵ȴ�������9->������ɣ�-1->�˻أ�����׼״̬���룬��������״̬�ֶ�
	where thesisPublishApplyID= @thesisPublishApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO


----------------------------------------------------------------
drop PROCEDURE addProcessApply
/*
	name:		addProcessApply
	function:	4.1.��ӳ���ӹ�������Ϣ
	input: 
				@processApplyID varchar(10),	--����������ӹ�������,��ϵͳʹ�õ�303�ź��뷢����������'JG'+4λ��ݴ���+4λ��ˮ�ţ����ָ��ù�������������
				@applyManID varchar(10),		--�����˹���
				@applyTime varchar(10),			--��������:���á�yyyy-MM-dd����ʽ����
				
				@preCompletedTime varchar(19),	--�������ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@applyReason nvarchar(300),		--��������
				--@attachmentFile varchar(128),	--�����ļ�·�� del by lw 2013-3-2ͳһ��ƿ��Ǹ���

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: modi by lw 2013-3-1���ù������������ɵ��ţ�������������
*/
create PROCEDURE addProcessApply
	@processApplyID varchar(10),	--����������ӹ�������,��ϵͳʹ�õ�303�ź��뷢����������'JG'+4λ��ݴ���+4λ��ˮ�ţ����ָ��ù�������������
	@applyManID varchar(10),		--�����˹���
	@applyTime varchar(10),			--��������:���á�yyyy-MM-dd����ʽ����
	
	@preCompletedTime varchar(19),	--�������ʱ��
	@applyReason nvarchar(300),		--��������
	--@attachmentFile varchar(128),	--�����ļ�·�� del by lw 2013-3-2ͳһ��ƿ��Ǹ���

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ȡ������/�����˵�������
	declare @applyMan nvarchar(30), @createManName nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert processApplyInfo(processApplyID, applyManID, applyMan, applyTime, 
					preCompletedTime, applyReason)
	values(@processApplyID, @applyManID, @applyMan, @applyTime, 
					@preCompletedTime, @applyReason)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽǳ���ӹ�����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ��˳���ӹ�����['+@processApplyID+']��')
GO

drop PROCEDURE updateProcessApply
/*
	name:		updateProcessApply
	function:	4.2.�޸ĳ���ӹ�������Ϣ
	input: 
				@processApplyID varchar(10),	--����ӹ�������
				@applyManID varchar(10),		--�����˹���
				@applyTime varchar(10),			--��������:���á�yyyy-MM-dd����ʽ����
				
				@preCompletedTime varchar(19),	--�������ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@applyReason nvarchar(300),		--��������
				--@attachmentFile varchar(128),	--�����ļ�·��	del by lw 2013-3-2ͳһ��ƿ��Ǹ���

				@modiManID varchar(10),			--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ����뵥�����ڣ�
							3�������뵥�Ѿ����ͣ��������޸ģ�
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: modi by lw 2013-3-1���ù���������������
*/
create PROCEDURE updateProcessApply
	@processApplyID varchar(10),	--����ӹ�������
	@applyManID varchar(10),		--�����˹���
	@applyTime varchar(10),			--��������:���á�yyyy-MM-dd����ʽ����
	
	@preCompletedTime varchar(19),	--�������ʱ��
	@applyReason nvarchar(300),		--��������
	--@attachmentFile varchar(128),	--�����ļ�·��

	@modiManID varchar(10),			--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�޸ĵ����뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鵥��״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	select @applyStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	--ȡ������/�����˵�������
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update processApplyInfo
	set applyMan = @applyMan, applyTime = @applyTime, 
		preCompletedTime = @preCompletedTime, applyReason = @applyReason
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸ĳ���ӹ�����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��˳���ӹ�����['+@processApplyID+']�ĵǼ���Ϣ��')
GO

drop PROCEDURE delProcessApply
/*
	name:		delProcessApply
	function:	4.3.ɾ��ָ���ĳ���ӹ�����
	input: 
				@processApplyID varchar(10),	--����ӹ�������
				@delManID varchar(10),	--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������벻���ڣ�
							3���������Ѿ����ͣ�������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: modi by lw 2013-3-1���ù����������ṩ������

*/
create PROCEDURE delProcessApply
	@processApplyID varchar(10),	--����ӹ�������
	@delManID varchar(10),			--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ�������������Ƿ����
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鵥��״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	select @applyStatus = applyStatus 
	from processApplyInfo 
	where processApplyID= @processApplyID
	if (@applyStatus not in (0,-1))
	begin
		set @Ret = 3
		return
	end

	delete processApplyInfo where processApplyID= @processApplyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������ӹ�����', '�û�' + @delManName
												+ 'ɾ���˳���ӹ�����['+@processApplyID+']��')

GO

drop PROCEDURE appointProcesser
/*
	name:		appointProcesser
	function:	4.4.ָ�ɼӹ���Ա
	input: 
				@processApplyID varchar(10),	--����ӹ�������
				@processerID varchar(10),		--�ӹ��˹���

				@modiManID varchar(10),			--ָ���˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������벻���ڣ�2���õ����Ѿ���ɣ�9:δ֪����
	author:		¬έ
	CreateDate:	2013-3-2
	UpdateDate: 
*/
create PROCEDURE appointProcesser
	@processApplyID varchar(10),	--����ӹ�������
	@processerID varchar(10),		--�ӹ��˹���

	@modiManID varchar(10),			--ָ���˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж����뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鵥��״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	select @applyStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	if (@applyStatus =9)
	begin
		set @Ret = 2
		return
	end

	--ȡָ����/ָ����Ա��������
	declare @processer nvarchar(30)
	set @processer = isnull((select cName from userInfo where jobNumber = @processerID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update processApplyInfo
	set processerID = @processerID, processer = @processer,
		appointTime = @modiTime
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, 'ָ�ɼӹ���', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ�󽫳���ӹ�����['+@processApplyID+']ָ�ɸ�['+@processer+']�ӹ���')
GO

drop PROCEDURE setProcessStatus
/*
	name:		setProcessStatus
	function:	4.5.���üӹ�״̬
	input: 
				@processApplyID varchar(10),	--����ӹ�������
				@isCompleted smallint,			--�ӹ�״̬��0->δ֪��1->���ڼӹ���9->���, 10->�޷����
				@completedTime varchar(19),		--���ʱ��:����"yyyy-MM-dd hh:mm:ss"��ʽ���
				@completeIntro nvarchar(300),	--������

				@modiManID varchar(10),			--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������벻���ڣ�2���õ����Ѿ���ɣ�9:δ֪����
	author:		¬έ
	CreateDate:	2013-3-2
	UpdateDate: 
*/
create PROCEDURE setProcessStatus
	@processApplyID varchar(10),	--����ӹ�������
	@isCompleted smallint,			--�ӹ�״̬��0->δ֪��1->���ڼӹ���9->���
	@completedTime varchar(19),		--���ʱ��:����"yyyy-MM-dd hh:mm:ss"��ʽ���
	@completeIntro nvarchar(300),	--������

	@modiManID varchar(10),			--�����˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж����뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��鵥��״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	select @applyStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	if (@applyStatus =9)
	begin
		set @Ret = 2
		return
	end

	--ȡ�����˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update processApplyInfo
	set isCompleted = @isCompleted,			--�ӹ�״̬��0->δ֪��1->���ڼӹ���9->���
		completedTime = @completedTime,		--���ʱ��:����"yyyy-MM-dd hh:mm:ss"��ʽ���
		@completeIntro = @completeIntro		--������
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '��ӹ�״̬', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ����˳���ӹ�����['+@processApplyID+']�ļӹ������')
GO

drop PROCEDURE setProcessApplyStatus
/*
	name:		setProcessApplyStatus
	function:	4.6.���ó���ӹ����뵥״̬
				ע�⣺�������û�еǼǹ�����־
	input: 
				@processApplyID varchar(10),	--����ӹ�������
				@applyStatus smallint,			----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������벻���ڣ�2���õ����Ѿ���ɣ�9:δ֪����
	author:		¬έ
	CreateDate:	2013-3-2
	UpdateDate: 
*/				
create PROCEDURE setProcessApplyStatus
	@processApplyID varchar(10),	--����ӹ�������
	@applyStatus smallint,			----����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵

	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж����뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from processApplyInfo where processApplyID= @processApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ���ݻ�����Ϣ����鵥��״̬��
	declare @applyOldStatus smallint	--����״̬��0->�½�δ���ͣ�-1->���أ�1->�����У�9->ִ����ɹ鵵
	select @applyOldStatus = applyStatus from processApplyInfo where processApplyID= @processApplyID
	--�ж�״̬��
	if (@applyOldStatus=9)
	begin
		set @Ret = 2
		return
	end

	update processApplyInfo
	set applyStatus = @applyStatus
	where processApplyID= @processApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
GO

--����ӹ��б��ѯ��䣺
select p.processApplyID, p.applyStatus, p.applyManID, p.applyMan, 
	convert(varchar(10), p.applyTime,120) applyTime, p.applyReason, p.attachmentFile, 
	p.processerID, p.process, p.isCompleted, 
	convert(varchar(10), p.completedTime,120) completedTime, p.completeIntro
from processApplyInfo p

----------------------------------------------------------------

drop PROCEDURE addOtherApplyInfo
/*
	name:		addOtherApplyInfo
	function:	4.�������������Ϣ
				ע�⣺ֻ֧����ӱ��˵���������
	input: 
				@otherApplyID varchar(10),		--����������
				@applyTime smalldatetime,		--��������
				@title nvarchar(40),			--����
				@summary nvarchar(300),			--����
				@keys nvarchar(30),				--�ؼ��֣�����ؼ���ʹ��","�ָ�

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: modi by lw2013-3-25�������������׼���ӿ�
*/
create PROCEDURE addOtherApplyInfo
	@otherApplyID varchar(10),		--����������
	@applyTime varchar(10),			--��������:���á�yyyy-MM-dd����ʽ����
	@title nvarchar(40),			--����
	@summary nvarchar(300),			--����
	@keys nvarchar(30),				--�ؼ��֣�����ؼ���ʹ��","�ָ�

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
	insert otherApplyInfo(otherApplyID, applyManID, applyMan, applyTime, title, summary, keys)
	values(@otherApplyID, @createManID, @createManName, @applyTime, @title, @summary, @keys)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ���������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ����������롰' + @title + '['+@otherApplyID+']����')
GO

drop PROCEDURE updateOtherApplyInfo
/*
	name:		updateOtherApplyInfo
	function:	5.�޸�����������Ϣ
				ע�⣺ֻ֧���޸ı��˵���������
	input: 
				@otherApplyID varchar(10),		--����������
				@applyTime varchar(10),			--��������:���á�yyyy-MM-dd����ʽ����
				@title nvarchar(40),			--����
				@summary nvarchar(300),			--����
				@keys nvarchar(30),				--�ؼ��֣�����ؼ���ʹ��","�ָ�

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ��������벻���ڣ�
							3�������������Ѿ����ͣ��������޸ģ�
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: modi by lw 2013-3-25�������������׼���ӿ�
*/
create PROCEDURE updateOtherApplyInfo
	@otherApplyID varchar(10),		--����������
	@applyTime varchar(10),			--��������:���á�yyyy-MM-dd����ʽ����
	@title nvarchar(40),			--����
	@summary nvarchar(300),			--����
	@keys nvarchar(30),				--�ؼ��֣�����ؼ���ʹ��","�ָ�

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ���������������Ƿ����
	declare @count as int
	set @count=(select count(*) from otherApplyInfo where otherApplyID= @otherApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�1->����
	select @applyStatus = applyStatus from otherApplyInfo where otherApplyID= @otherApplyID
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update otherApplyInfo
	set applyTime = @applyTime, title = @title, summary = @summary, keys = @keys
	where otherApplyID= @otherApplyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸���������', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸����������롰' + @title + '['+@otherApplyID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delOtherApplyInfo
/*
	name:		delOtherApplyInfo
	function:	6.ɾ��ָ������������
	input: 
				@otherApplyID varchar(10),		--����������
				@delManID varchar(10) output,	--ɾ����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����������벻���ڣ�
							3�������������Ѿ����ͣ�������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 

*/
create PROCEDURE delOtherApplyInfo
	@otherApplyID varchar(10),		--����������
	@delManID varchar(10) output,	--ɾ����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ���������������Ƿ����
	declare @count as int
	set @count=(select count(*) from otherApplyInfo where otherApplyID= @otherApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���״̬��
	declare @applyStatus smallint	--����״̬��0->�½�δ���ͣ�1->����
	select @applyStatus = applyStatus 
	from otherApplyInfo 
	where otherApplyID= @otherApplyID
	if (@applyStatus=1)
	begin
		set @Ret = 3
		return
	end

	delete otherApplyInfo where otherApplyID= @otherApplyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����������', '�û�' + @delManName
												+ 'ɾ������������['+@otherApplyID+']��')

GO

/*
���뷢������
        LeaveRequestCode = 300, //��������
        EqpApplyCode = 301,     //�豸�ɹ�������
        ThesisPublishApplyCode = 302,   //���ķ���������
        ProcessApplyCode = 303, //����ӹ�������
        OtherApplyCode = 304,   //����������
*/


--���������б��ѯ��䣺
select t.otherApplyID, t.applyStatus, t.applyManID, t.applyMan, 
CONVERT(varchar(10), t.applyTime,120) applyTime, t.title, t.summary, t.keys
from otherApplyInfo t

select t.otherApplyID, t.applyStatus, t.applyManID, t.applyMan, 
CONVERT(varchar(10), t.applyTime,120) applyTime, t.title, t.summary, t.keys
 from otherApplyInfo t
 where t.otherApplyID ='" + otherApplyID + "'


select * from processApplyInfo
select * from workFlowInstance
where LEFT(instanceID,2)='JG'


select * from eqpApplyDetail
select * from eqpApplyInfo



select * from workFlowTemplateFlow
