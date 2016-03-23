use hustOA
/*
	ǿ�ų����İ칫ϵͳ-����״̬����
	author:		¬έ
	CreateDate:	2013-1-21
	UpdateDate: 
*/

--1.����״̬�ǼǱ�
select * from dutyStatusInfo
select * from codeDictionary where classCode=200
delete dutyStatusInfo
drop table dutyStatusInfo
CREATE TABLE dutyStatusInfo(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL, --�ڲ��к�
	userID varchar(10) not null,		--����
	userCName nvarchar(30) null,		--����:�������
	
	dutyStatus int not null,			--����״̬���룺ʹ�õ�200�Ŵ����ֵ��趨
	dutyStatusDesc nvarchar(60) null,	--����״̬�������������
	
	startTime smalldatetime not null,	--��ʼʱ��
	endTime smalldatetime null,			--����ʱ��
	
	remark nvarchar(300) null,			--����˵��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_dutyStatusInfo] PRIMARY KEY CLUSTERED 
(
	[userID] ASC,
	[startTime] desc,
	[rowNum] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����״̬��������
CREATE NONCLUSTERED INDEX [IX_dutyStatusInfo] ON [dbo].[dutyStatusInfo] 
(
	[dutyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop FUNCTION getUserDutyStatus
/*
	name:		getUserDutyStatus
	function:	0.�����û����ź�ʱ���ȡ�û����������״̬
	input: 
				@userID varchar(10),		--�û�����
				@startTime varchar(19)		--��ѯ��ʼʱ��:����ʱ����ʹ�õ���ʱ�䣬����ʱ��ʹ�õ���ʱ��
	output: 
				return xml					--״̬���٣�
	author:		¬έ
	CreateDate:	2013-1-21
	UpdateDate: 
*/
create FUNCTION getUserDutyStatus
(  
	@userID varchar(10),		--�û�����
	@queryTime varchar(19)		--��ѯ��ʼʱ��:����ʱ����ʹ�õ���ʱ�䣬����ʱ��ʹ�õ���ʱ��
)  
RETURNS xml
WITH ENCRYPTION
AS      
begin
	declare @theTime smalldatetime, @theNextDayTime smalldatetime
	set @theTime = convert(smalldatetime, @queryTime,120)
	set @theNextDayTime = dateadd(day,1,@theTime)
	
	declare @dutyStatusDesc nvarchar(60), @startTime smalldatetime, @endTime smalldatetime
	declare @remark nvarchar(300)
	select top 1 @dutyStatusDesc = dutyStatusDesc, @startTime = startTime,
		@endTime = endTime, @remark = remark
	from dutyStatusInfo 
	where userID = @userID and ((endTime between @theTime and @theNextDayTime) 
			or (startTime between @theTime and @theNextDayTime)
			or (@theTime between startTime and endTime))
	order by startTime
	
	declare @result xml
	if (@dutyStatusDesc is null)
	begin
		set @result = N'<root><dutyStatusDesc>�ڸ�</dutyStatusDesc></root>'
	end
	else
	begin
		set @result = N'<root>'+
							'<dutyStatusDesc>'+@dutyStatusDesc+'</dutyStatusDesc>'+
							'<startTime>'+convert(varchar(19),@startTime,120)+'</startTime>'+
							'<endTime>'+convert(varchar(19),@endTime,120)+'</endTime>'+
							'<remark>'+@remark+'</remark>'+
						'</root>'
	end
	return @result
end
--���ԣ�
select dbo.getUserDutyStatus('G201300040','2013-03-08 12:00:00')

drop PROCEDURE queryDutyStatusInfoLocMan
/*
	name:		queryDutyStatusInfoLocMan
	function:	1.��ѯָ������״̬�Ƿ��������ڱ༭
	input: 
				@rowNum int,			--�ڲ��к�
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ��������״̬������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE queryDutyStatusInfoLocMan
	@rowNum int,					--�ڲ��к�
	@Ret int output,				--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from dutyStatusInfo where rowNum= @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockDutyStatusInfo4Edit
/*
	name:		lockDutyStatusInfo4Edit
	function:	2.��������״̬�༭������༭��ͻ
	input: 
				@rowNum int,					--�ڲ��к�
				@lockManID varchar(10) output,	--�����ˣ������ǰ����״̬���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ����������״̬�����ڣ�2:Ҫ����������״̬���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE lockDutyStatusInfo4Edit
	@rowNum int,					--�ڲ��к�
	@lockManID varchar(10) output,	--�����ˣ������ǰ����״̬���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ����������״̬�Ƿ����
	declare @count as int
	set @count=(select count(*) from dutyStatusInfo where rowNum= @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from dutyStatusInfo where rowNum= @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update dutyStatusInfo
	set lockManID = @lockManID 
	where rowNum= @rowNum
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
	values(@lockManID, @lockManName, getdate(), '��������״̬�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ������������״̬['+str(@rowNum,8) +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockDutyStatusInfoEditor
/*
	name:		unlockDutyStatusInfoEditor
	function:	3.�ͷ�����״̬�༭��
				ע�⣺�����̲��������״̬�Ƿ���ڣ�
	input: 
				@rowNum int,					--�ڲ��к�
				@lockManID varchar(10) output,	--�����ˣ������ǰ����״̬���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE unlockDutyStatusInfoEditor
	@rowNum int,					--�ڲ��к�
	@lockManID varchar(10) output,	--�����ˣ������ǰ����״̬�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from dutyStatusInfo where rowNum= @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update dutyStatusInfo set lockManID = '' where rowNum= @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�����״̬�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�������״̬['+ str(@rowNum,8) +']�ı༭����')
GO
select *  from dutyStatusInfo
select * from codeDictionary where classCode=200
drop PROCEDURE addDutyStatusInfo
/*
	name:		addDutyStatusInfo
	function:	4.�������״̬��Ϣ
	input: 
				@userID varchar(10),		--�״̬�û�����
				@dutyStatus int,			--����״̬���룺ʹ�õ�200�Ŵ����ֵ��趨
				@startTime varchar(19),		--��ʼʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@endTime varchar(19),		--����ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@remark nvarchar(300),		--����˵��

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@rowNum int output			--�ڲ��к�
	author:		¬έ
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE addDutyStatusInfo
	@userID varchar(10),		--����
	@dutyStatus int,			--����״̬���룺ʹ�õ�200�Ŵ����ֵ��趨
	@startTime varchar(19),		--��ʼʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@endTime varchar(19),		--����ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@remark nvarchar(300),		--����˵��

	@createManID varchar(10),	--�����˹���
	@Ret		int output,		--�����ɹ���ʶ
	@createTime smalldatetime output,
	@rowNum int output			--�ڲ��к�
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ״̬��/�����˵�������
	declare @userCName nvarchar(30), @createManName nvarchar(30)
	set @userCName = isnull((select cName from userInfo where jobNumber = @userID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	--ȡ����״̬������
	declare @dutyStatusDesc nvarchar(60)	--����״̬�������������
	set @dutyStatusDesc = isnull((select objDesc from codeDictionary where classCode =200 and objCode=@dutyStatus),'')
	
	set @createTime = getdate()
	insert dutyStatusInfo(userID, userCName, dutyStatus, dutyStatusDesc,
					startTime, endTime, remark,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@userID, @userCName, @dutyStatus, @dutyStatusDesc,
					@startTime, @endTime, @remark,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @rowNum = (select rowNum from dutyStatusInfo where userID=@userID and dutyStatus=@dutyStatus and convert(varchar(19),startTime,120)=@startTime)
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ�����״̬', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ�������״̬['+@dutyStatusDesc+']��')
GO
--����:
declare	@Ret		int --�����ɹ���ʶ
declare	@createTime smalldatetime 
declare	@rowNum int --�ڲ��к�
exec dbo.addDutyStatusInfo 'G20130001',2,'2013-01-23 12:00:00','2013-01-25 12:00:00','���Ϻ��μ�չʾ��', '0000000000', 
	@Ret output, @createTime output, @rowNum output
select @Ret, @rowNum

select * from dutyStatusInfo

drop PROCEDURE updateDutyStatusInfo
/*
	name:		updateDutyStatusInfo
	function:	5.�޸�����״̬��Ϣ
	input: 
				@rowNum int,				--�ڲ��к�
				@userID varchar(10),		--����
				@dutyStatus int,			--����״̬���룺ʹ�õ�200�Ŵ����ֵ��趨
				@startTime varchar(19),		--��ʼʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@endTime varchar(19),		--����ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@remark nvarchar(300),		--����˵��

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�����״̬�����ڣ�
							2:Ҫ�޸ĵ�����״̬�������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2003-1-21
	UpdateDate: 
*/
create PROCEDURE updateDutyStatusInfo
	@rowNum int,				--�ڲ��к�
	@userID varchar(10),		--����
	@dutyStatus int,			--����״̬���룺ʹ�õ�200�Ŵ����ֵ��趨
	@startTime varchar(19),		--��ʼʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@endTime varchar(19),		--����ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@remark nvarchar(300),		--����˵��

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ����������״̬�Ƿ����
	declare @count as int
	set @count=(select count(*) from dutyStatusInfo where rowNum= @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from dutyStatusInfo where rowNum= @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡ״̬��/�����˵�������
	declare @userCName nvarchar(30), @modiManName nvarchar(30)
	set @userCName = isnull((select cName from userInfo where jobNumber = @userID),'')
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	--ȡ����״̬������
	declare @dutyStatusDesc nvarchar(60)	--����״̬�������������
	set @dutyStatusDesc = isnull((select objDesc from codeDictionary where classCode =200 and objCode=@dutyStatus),'')

	set @modiTime = getdate()
	update dutyStatusInfo
	set userID = @userID, userCName = @userCName, dutyStatus = @dutyStatus, dutyStatusDesc = @dutyStatusDesc,
		startTime = @startTime, endTime = @endTime, remark = @remark,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where rowNum= @rowNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�����״̬', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸�������״̬�к�Ϊ['+str(@rowNum,8)+']������״̬�ĵǼ���Ϣ��')
GO

drop PROCEDURE delDutyStatusInfo
/*
	name:		delDutyStatusInfo
	function:	6.ɾ��ָ��������״̬
	input: 
				@rowNum int,					--�ڲ��к�
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ����״̬���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ��������״̬�����ڣ�2��Ҫɾ��������״̬��������������9��δ֪����
	author:		¬έ
	CreateDate:	2003-1-21
	UpdateDate: 

*/
create PROCEDURE delDutyStatusInfo
	@rowNum int,					--�ڲ��к�
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ����״̬���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ��������״̬�Ƿ����
	declare @count as int
	set @count=(select count(*) from dutyStatusInfo where rowNum= @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from dutyStatusInfo where rowNum= @rowNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete dutyStatusInfo where rowNum= @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������״̬', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ['+str(@rowNum,8)+']������״̬��')

GO



--��ѯ��������״̬��
select d.rowNum, d.userID, d.userCName, d.dutyStatus, d.dutyStatusDesc,
convert(varchar(19),d.startTime,120) startTime, convert(varchar(19),d.endTime,120) endTime, d.remark
from dutyStatusInfo d
where convert(varchar(19),d.startTime,120) >= '2013-01-21'

use hustOA
--��ѯ�Ŷ�����״̬��
declare @theDay varchar(19)
set @theDay = '2013-01-22 14:27:26'
select jobNumber, cName, ucode, uName, workPos, dbo.getUserDutyStatus(jobNumber,@theDay) dutyStatus
from userInfo
