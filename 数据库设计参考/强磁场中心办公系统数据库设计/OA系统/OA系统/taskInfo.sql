use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�������
	author:		¬έ
	CreateDate:	2013-1-5
	UpdateDate: 
*/

select * from taskInfo
--1.��������
alter table taskInfo add closeRemind smallint default(0)	--�Ƿ�ر����ѣ�0->���رգ�1->�ر� add by lw 2013-6-18
update taskInfo
set closeRemind = 0
alter table taskInfo add taskRemindTime smalldatetime null	--��������ʱ�䣺���ֶ�Ϊ����ʱ�� add by lw 2013-6-19

update taskInfo
set taskRemindTime = DATEADD(MINUTE,-taskRemindBefore,taskStartTime)
where taskStartTime > '2013'
select * from taskInfo
where taskID='RW20131253'

drop table taskInfo
CREATE TABLE taskInfo(
	taskID varchar(10) not null,		--������������,��ϵͳʹ�õ�11010�ź��뷢����������'RW'+4λ��ݴ���+4λ��ˮ�ţ�
	topic  nvarchar(300) null,			--��������
	taskManID varchar(10) not null,		--���������˹���
	taskMan nvarchar(30) not null,		--��������������
	taskStartTime smalldatetime null,	--����ʼʱ��
	taskEndTime smalldatetime null,		--�������ʱ��
	summary nvarchar(300) null,			--������������

	needSMSInvitation smallint default(0),--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ(��ʱ�����ã�����Ϊ������˵�����ʹ��)
	needSMSRemind smallint default(0),	--�Ƿ���Ҫ�������ѣ�0->����Ҫ��1->��Ҫ
	taskRemindBefore int default(15),	--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15����
	taskRemindTime smalldatetime null,	--��������ʱ�䣺���ֶ�Ϊ����ʱ�� add by lw 2013-6-19
	closeRemind smallint default(0),	--�Ƿ�ر����ѣ�0->���رգ�1->�ر� add by lw 2013-6-18
	isOver smallint default(0),			--�����Ƿ������0->δ������1->����
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_taskInfo] PRIMARY KEY CLUSTERED 
(
	[isOver] DESC,
	[taskID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����ʼʱ��������
CREATE NONCLUSTERED INDEX [IX_taskInfo] ON [dbo].[taskInfo] 
(
	[taskStartTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE queryTaskInfoLocMan
/*
	name:		queryTaskInfoLocMan
	function:	1.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@taskID varchar(10),		--������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�������񲻴���
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-5
	UpdateDate: 
*/
create PROCEDURE queryTaskInfoLocMan
	@taskID varchar(10),		--������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from taskInfo where taskID= @taskID),'')
	set @Ret = 0
GO


drop PROCEDURE lockTaskInfo4Edit
/*
	name:		lockTaskInfo4Edit
	function:	2.��������༭������༭��ͻ
	input: 
				@taskID varchar(10),			--������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���������񲻴��ڣ�2:Ҫ�������������ڱ����˱༭��
							3���������ѽ�����������༭������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-5
	UpdateDate: 
*/
create PROCEDURE lockTaskInfo4Edit
	@taskID varchar(10),		--������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isOver smallint
	select @thisLockMan = isnull(lockManID,''), @isOver = isOver from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end

	update taskInfo
	set lockManID = @lockManID 
	where taskID= @taskID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '��������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ������������['+ @taskID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockTaskInfoEditor
/*
	name:		unlockTaskInfoEditor
	function:	3.�ͷ�����༭��
				ע�⣺�����̲���������Ƿ���ڣ�
	input: 
				@taskID varchar(10),			--������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-5
	UpdateDate: 
*/
create PROCEDURE unlockTaskInfoEditor
	@taskID varchar(10),			--������
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from taskInfo where taskID= @taskID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update taskInfo set lockManID = '' where taskID= @taskID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
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
												+ '��Ҫ���ͷ�������['+ @taskID +']�ı༭����')
GO

drop PROCEDURE addTaskInfo
/*
	name:		addTaskInfo
	function:	4.���������Ϣ
				ע�⣺Ŀǰֻ֧����ӱ��˵�����
	input: 
				@topic  nvarchar(300),			--��������
				@taskStartTime varchar(19),		--����ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@taskEndTime varchar(19),		--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@summary nvarchar(300),			--������������

				@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
				@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�0->����Ҫ��1->��Ҫ
				@taskRemindBefore int,			--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15����

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@taskID varchar(10) output		--������
	author:		¬έ
	CreateDate:	2013-1-5
	UpdateDate: modi by lw 2013-6-19������ʱ����Ϊ�����ֶμ���
*/
create PROCEDURE addTaskInfo
	@topic  nvarchar(300),			--��������
	@taskStartTime varchar(19),		--����ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@taskEndTime varchar(19),		--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@summary nvarchar(300),			--������������

	@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
	@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�0->����Ҫ��1->��Ҫ
	@taskRemindBefore int,			--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15����

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@taskID varchar(10) output		--������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�������������ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 11010, 1, @curNumber output
	set @taskID = @curNumber

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	declare @taskRemindTime smalldatetime --��������ʱ��
	set @taskRemindTime = DATEADD(MINUTE,-@taskRemindBefore,@taskStartTime)
	insert taskInfo(taskID, topic, taskManID, taskMan, taskStartTime, taskEndTime, summary,
					needSMSInvitation, needSMSRemind, taskRemindBefore, taskRemindTime,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@taskID, @topic, @createManID, @createManName, @taskStartTime, @taskEndTime, @summary,
					@needSMSInvitation, @needSMSRemind, @taskRemindBefore, @taskRemindTime,
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
	values(@createManID, @createManName, @createTime, '�Ǽ�����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ�������' + @topic + '['+@taskID+']����')
GO

drop PROCEDURE updateTaskInfo
/*
	name:		updateTaskInfo
	function:	5.�޸�������Ϣ
				ע�⣺Ŀǰֻ֧���޸ı��˵�����
	input: 
				@taskID varchar(10),		--������
				@topic  nvarchar(300),			--��������
				@taskStartTime varchar(19),		--����ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@taskEndTime varchar(19),		--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@summary nvarchar(300),			--������������

				@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
				@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�0->����Ҫ��1->��Ҫ
				@taskRemindBefore int,			--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15����

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ����񲻴��ڣ�
							2:Ҫ�޸ĵ������������������༭��
							3���������Ѿ��������������޸ģ�
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2013-1-5
	UpdateDate: modi by lw 2013-6-19������ʱ����Ϊ�����ֶμ���
*/
create PROCEDURE updateTaskInfo
	@taskID varchar(10),		--������
	@topic  nvarchar(300),			--��������
	@taskStartTime varchar(19),		--����ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@taskEndTime varchar(19),		--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@summary nvarchar(300),			--������������

	@needSMSInvitation smallint,	--�Ƿ���Ҫ����֪ͨ��0->��Ҫ, 1->����Ҫ
	@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�0->����Ҫ��1->��Ҫ
	@taskRemindBefore int,			--����������ǰʱ�䣺��λΪ���ӣ�Ĭ��Ϊ15����

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isOver smallint
	select @thisLockMan = isnull(lockManID,''), @isOver = isOver from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	declare @taskRemindTime smalldatetime --��������ʱ��
	set @taskRemindTime = DATEADD(MINUTE,-@taskRemindBefore,@taskStartTime)
	update taskInfo
	set topic = @topic, taskManID = @modiManID, taskMan = @modiManName, 
		taskStartTime = @taskStartTime, taskEndTime = @taskEndTime, summary = @summary,
		needSMSInvitation = @needSMSInvitation, needSMSRemind = @needSMSRemind, taskRemindBefore = @taskRemindBefore,
		taskRemindTime = @taskRemindTime,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where taskID= @taskID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸�������' + @topic + '['+@taskID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delTaskInfo
/*
	name:		delTaskInfo
	function:	6.ɾ��ָ��������
				ע�⣺�ô洢���̲���������״̬������ɾ���Ѿ���ɵ�����
	input: 
				@taskID varchar(10),			--������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������񲻴��ڣ�2��Ҫɾ����������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-5
	UpdateDate: 

*/
create PROCEDURE delTaskInfo
	@taskID varchar(10),			--������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete taskInfo where taskID= @taskID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ��������['+@taskID+']��')

GO


drop PROCEDURE closeTaskRemind
/*
	name:		closeTaskRemind
	function:	7.�ر�ָ�����������
	input: 
				@taskID varchar(10),			--������
				@closeManID varchar(10) output,	--�ر��ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������񲻴��ڣ�2��Ҫ�رյ�������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-19
	UpdateDate: 

*/
create PROCEDURE closeTaskRemind
	@taskID varchar(10),			--������
	@closeManID varchar(10) output,	--�ر��ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @closeManID)
	begin
		set @closeManID = @thisLockMan
		set @Ret = 2
		return
	end

	update taskInfo 
	set closeRemind = 1
	where taskID= @taskID
	set @Ret = 0

	--ȡά���˵�������
	declare @closeManName nvarchar(30)
	set @closeManName = isnull((select userCName from activeUsers where userID = @closeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@closeManID, @closeManName, getdate(), '�ر���������', '�û�' + @closeManName
												+ '�ر�������['+@taskID+']�����ѡ�')

GO

drop PROCEDURE delayTaskRemindTime
/*
	name:		delayTaskRemindTime
	function:	8.�Ƴ�ָ�����������ʱ��
	input: 
				@taskID varchar(10),			--������
				@delayTimes int,				--�Ƴ�ʱ�䣺��λΪ����
				@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�0->����Ҫ��1->��Ҫ
				@delayer varchar(10) output,	--�Ƴ��ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������񲻴��ڣ�2��Ҫ�Ƴٵ�������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-19
	UpdateDate: modi by lw 2013-07-13�����Ƿ���Ҫ�ٴζ������ѽӿڣ�

*/
create PROCEDURE delayTaskRemindTime
	@taskID varchar(10),			--������
	@delayTimes int,				--�Ƴ�ʱ�䣺��λΪ����
	@needSMSRemind smallint,		--�Ƿ���Ҫ�������ѣ�0->����Ҫ��1->��Ҫ
	@delayer varchar(10) output,	--�Ƴ��ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from taskInfo where taskID= @taskID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from taskInfo where taskID= @taskID
	if (@thisLockMan <> '' and @thisLockMan <> @delayer)
	begin
		set @delayer = @thisLockMan
		set @Ret = 2
		return
	end

	update taskInfo 
	set taskRemindTime = DATEADD(MINUTE, @delayTimes, GETDATE()), needSMSRemind = @needSMSRemind
	where taskID= @taskID
	set @Ret = 0

	--ȡά���˵�������
	declare @delayerName nvarchar(30)
	set @delayerName = isnull((select userCName from activeUsers where userID = @delayer),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delayer, @delayerName, getdate(), '�Ƴ���������', '�û�' + @delayerName
												+ '�Ƴ�������['+@taskID+']�����ѡ�')

GO

drop PROCEDURE scanTaskSMSRemind
/*
	name:		scanTaskSMSRemind
	function:	9.�Զ�ɨ����Ҫ�������Ѷ��ŵ����񣬲�����
				ע�⣺�ô洢���̲��Ǽǹ�����־
	input: 
	output: 
				@Ret		int output			--���Ͷ�������
	author:		¬έ
	CreateDate:	2013-07-12
	UpdateDate: 

*/
create PROCEDURE scanTaskSMSRemind
	@Ret		int output			--���Ͷ�������
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @taskID varchar(10), @topic nvarchar(300), @taskStartTime varchar(19)
	declare @userID varchar(10), @userCName nvarchar(30), @mobile varchar(20)
	declare @execRet int, @messageID varchar(12)
	set @Ret = 0
	
	declare mtar cursor for
	select t.taskID, t.topic, convert(varchar(19),t.taskStartTime,120), t.taskManID, isnull(u.cName,''), isnull(u.mobile,'')
	from taskInfo t left join userInfo u on t.taskManID = u.jobNumber
	where isOver = 0 and closeRemind=0 and taskRemindTime< getdate() and needSMSRemind=1
	OPEN mtar
	FETCH NEXT FROM mtar INTO @taskID, @topic, @taskStartTime, @userID, @userCName, @mobile
	WHILE @@FETCH_STATUS = 0
	begin
		if (@mobile<>'')
		begin
			declare @SMSInfoID char(12)			--���ű��
			declare @createTime smalldatetime 
			declare @SMSContent nvarchar(300)	--��������
			set @SMSContent = '�װ���' + @userCName + ':���ƻ�������['+@topic+']������['+@taskStartTime+']���ڡ�'
			exec dbo.addSMSInfo '0000000000', @userID, @mobile, '', 9, @SMSContent, '0000000000', @execRet output, @createTime output, @SMSInfoID output
			--���Ͷ��ţ�
			declare @snderID varchar(10)
			set @snderID = '0000000000'
			exec dbo.sendSMS @SMSInfoID,'', @snderID output,@createTime output,@execRet output
			if (@execRet=0)
			begin
				--���������������
				update taskInfo set needSMSRemind=0 where taskID = @taskID
				set @Ret = @Ret+1
			end
		end
		FETCH NEXT FROM mtar INTO @taskID, @topic, @taskStartTime, @userID, @userCName, @mobile
	end
	CLOSE mtar
	DEALLOCATE mtar
GO
--���ԣ�
declare @Ret		int
exec dbo.scanTaskSMSRemind @Ret output
select @Ret

select * from taskInfo


--����Ĳ�ѯ��䣺
select t.taskID, t.topic, t.taskManID, t.taskMan, 
convert(varchar(19),t.taskStartTime,120) taskStartTime, CONVERT(varchar(19),t.taskEndTime,120) taskEndTime, 
t.needSMSInvitation, t.needSMSRemind, t.taskRemindBefore, t.isOver 
from taskInfo t
order by t.taskStartTime desc



--��Ϣ����������״̬���ϲ�ѯ��
declare @myDate varchar(10), @userID varchar(10)
set @myDate = '2013-01-21'
set @userID = 'G201300001'
select 1 iType, messageID id, messageType topic, sendTime theTime, isRead iStatus
from messageInfo
where convert(varchar(10),sendTime,120)=@myDate  and receiverID=@userID 
union all
select 2, taskID, topic, taskStartTime, case isOver 
    										when 1 then 9 --���������
    									else case 
    											 when DATEDIFF(s,getdate(), taskStartTime) > 0  then 2    --δ��ʱ����
    										 else 3   --��ʱ����
    											 end
    										end 
from taskInfo
where convert(varchar(10),taskStartTime,120)=@myDate and taskManID=@userID
union all
select 3, cast(rowNum as varchar(10)), dutyStatusDesc, startTime, 100
from dutyStatusInfo
where convert(varchar(10),startTime,120)=@myDate and userID=@userID
order by theTime

/*
iStatus�����ֵ��
0->��Ϣδ�Ķ���1->��Ϣ���Ķ�
2->δ��ʱ����3->��ʱ����9->���������
100->��״̬
*/



select 1 iType, messageID id, messageType topic, sendTime theTime, isRead iStatus 
from messageInfo 
where convert(varchar(10),sendTime,120)='2013-01-22' and receiverID='0000000000' 
union all 
select 2, taskID, topic, taskStartTime, case isOver when 1 then 9 else case when DATEDIFF(s,getdate(), taskStartTime) > 0  then 2 else 3 end end  
from taskInfo 
where convert(varchar(10),taskStartTime,120)='2013-01-22' and taskManID='0000000000' 
union all 
select 3, cast(rowNum as varchar(10)), dutyStatusDesc, startTime, 100 
from dutyStatusInfo 
where convert(varchar(10),startTime,120)='2013-01-22' and userID='0000000000' order by theTime


SELECT * from taskInfo 



--��ȡ��������͵���δ��������б�
select taskID, topic, taskManID, taskMan, taskStartTime, taskEndTime, summary, needSMSInvitation, needSMSRemind, taskRemindBefore, isOver
from taskInfo
where isOver = 0 and taskRemindTime< getdate() and closeRemind=0

select dateadd(minute,-15, getdate())
