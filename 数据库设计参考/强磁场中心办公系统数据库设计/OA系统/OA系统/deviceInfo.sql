/*
	ǿ�ų����İ칫ϵͳ-װ�ù���
	author:		¬έ
	CreateDate:	2013-1-8
	UpdateDate: 
*/
use hustOA
select * from deviceInfo
--1.װ��һ����
drop table deviceInfo
CREATE TABLE deviceInfo(
	deviceID varchar(10) not null,		--������װ�ñ��,��ϵͳʹ�õ�70�ź��뷢����������'ZZ'+4λ��ݴ���+4λ��ˮ�ţ�
	deviceName nvarchar(30) null,		--װ������
	devicePhotoFile varchar(128) null,	--װ������ͼ�ļ�·��
	buildDate smalldatetime null,		--װ�ý�������
	scrappedDate smalldatetime null,	--��������
	keeperID varchar(10) null,			--�����˹���
	keeper nvarchar(30) null,			--������
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_deviceInfo] PRIMARY KEY CLUSTERED 
(
	[deviceID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
insert deviceInfo(deviceID, deviceName, devicePhotoFile, buildDate, scrappedDate, keeperID, keeper)
values('ZZ20130001','װ��1','','2013-01-01',null,'00001','¬έ')

insert deviceRepairInfo(repairID, deviceID, deviceName, repairStartTime,remark)
values('WX20130001','ZZ20130001','װ��1','2013-01-07','װ�õ���')

--2.װ��״̬һ�����ñ�ֻ�Ǽ�װ��ά��״̬������ʱ��Ϊ����״̬
select * from deviceRepairInfo
drop TABLE deviceRepairInfo
CREATE TABLE deviceRepairInfo(
	repairID varchar(10) not null,		--������װ��ά�޵����,��ϵͳʹ�õ�71�ź��뷢����������'ZZ'+4λ��ݴ���+4λ��ˮ�ţ�
	deviceID varchar(10) not null,		--����/�����װ�ñ��
	deviceName nvarchar(30) null,		--װ�����ƣ��������
	repairManID varchar(10) null,		--ά�޸�����ID
	repairMan nvarchar(10) null,		--ά�޸�����
	repairStartTime smalldatetime null,	--ά�޿�ʼʱ��
	repairEndTime smalldatetime null,	--ά��Ԥ�ƽ���ʱ��
	remark nvarchar(300) not null,		--˵����ԭ��
	isCompleted smallint default(0),	--�Ƿ���ɣ�0->δ�깤��1->���깤
	completedTime smalldatetime null,	--ά��ʵ�����ʱ��
	completedDesc nvarchar(300) null,	--ά��������
	
	--������ͳ��ʹ�õ��ֶΣ������ݿ��Զ�ά��
	repairMinute int default(0),		--����ά��ʱ�䣺��λ������
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_deviceRepairInfo] PRIMARY KEY CLUSTERED 
(
	[repairID] ASC,
	[deviceID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[deviceRepairInfo] WITH CHECK ADD CONSTRAINT [FK_deviceRepairInfo_deviceInfo] FOREIGN KEY([deviceID])
REFERENCES [dbo].[deviceInfo] ([deviceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[deviceRepairInfo] CHECK CONSTRAINT [FK_deviceRepairInfo_deviceInfo]
GO

--������
--ά��ʱ��������
CREATE NONCLUSTERED INDEX [IX_deviceRepairInfo] ON [dbo].[deviceRepairInfo] 
(
	[deviceID] ASC,
	[repairStartTime] ASC,
	[repairEndTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop FUNCTION getDeviceStatus
/*
	name:		getDeviceStatus
	function:	0.��ȡװ��״̬
	input: 
				@deviceID varchar(10),		--װ�ñ��
				@statusTime smalldatetime	--״̬ʱ��
	output: 
				return xml					--����
											N'<root>
												<status>����</status>
												<statusCode>1</statusCode>
												<remark>˵����<remark>'
											</root>
											״̬�룺0->���豸������1->����-1->ά����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create FUNCTION getDeviceStatus
(  
	@deviceID varchar(10),	--װ�ñ��
	@statusTime smalldatetime	--״̬ʱ��
)  
RETURNS xml	
WITH ENCRYPTION
AS      
begin
	DECLARE @statusRemark nvarchar(300);
	select top 1 @statusRemark = remark from deviceRepairInfo 
	where deviceID = @deviceID and @statusTime BETWEEN repairStartTime and isnull(repairEndTime,getdate())
	if (@statusRemark is null)
		set @statusRemark = '<root><status>����</status><statusCode>1</statusCode><remark></remark></root>'
	else
		set @statusRemark = '<root><status>ά����</status><statusCode>-1</statusCode><remark>'+@statusRemark+'</remark></root>'
	
	return @statusRemark
end


drop PROCEDURE queryDeviceInfoLocMan
/*
	name:		queryDeviceInfoLocMan
	function:	1.��ѯָ��װ���Ƿ��������ڱ༭
	input: 
				@deviceID varchar(10),		--װ�ñ��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����װ�ò�����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE queryDeviceInfoLocMan
	@deviceID varchar(10),		--װ�ñ��
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from deviceInfo where deviceID= @deviceID),'')
	set @Ret = 0
GO


drop PROCEDURE lockDeviceInfo4Edit
/*
	name:		lockDeviceInfo4Edit
	function:	2.����װ�ñ༭������༭��ͻ
	input: 
				@deviceID varchar(10),			--װ�ñ��
				@lockManID varchar(10) output,	--�����ˣ������ǰװ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������װ�ò����ڣ�2:Ҫ������װ�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE lockDeviceInfo4Edit
	@deviceID varchar(10),		--װ�ñ��
	@lockManID varchar(10) output,	--�����ˣ������ǰװ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������װ���Ƿ����
	declare @count as int
	set @count=(select count(*) from deviceInfo where deviceID= @deviceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from deviceInfo where deviceID= @deviceID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update deviceInfo
	set lockManID = @lockManID 
	where deviceID= @deviceID
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
	values(@lockManID, @lockManName, getdate(), '����װ�ñ༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������װ��['+ @deviceID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockDeviceInfoEditor
/*
	name:		unlockDeviceInfoEditor
	function:	3.�ͷ�װ�ñ༭��
				ע�⣺�����̲����װ���Ƿ���ڣ�
	input: 
				@deviceID varchar(10),			--װ�ñ��
				@lockManID varchar(10) output,	--�����ˣ������ǰװ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE unlockDeviceInfoEditor
	@deviceID varchar(10),			--װ�ñ��
	@lockManID varchar(10) output,	--�����ˣ������ǰװ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from deviceInfo where deviceID= @deviceID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update deviceInfo set lockManID = '' where deviceID= @deviceID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�װ�ñ༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���װ��['+ @deviceID +']�ı༭����')
GO

drop PROCEDURE addDeviceInfo
/*
	name:		addDeviceInfo
	function:	4.���װ����Ϣ
	input: 
				@deviceName nvarchar(30),		--װ������
				@devicePhotoFile varchar(128),	--װ������ͼ�ļ�·��
				@buildDate varchar(10),			--װ�ý�������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),			--�����˹���

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@deviceID varchar(10) output	--װ�ñ��,��ϵͳʹ�õ�70�ź��뷢����������'ZZ'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE addDeviceInfo
	@deviceName nvarchar(30),		--װ������
	@devicePhotoFile varchar(128),	--װ������ͼ�ļ�·��
	@buildDate varchar(10),			--װ�ý�������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),			--�����˹���

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@deviceID varchar(10) output	--װ�ñ��,��ϵͳʹ�õ�70�ź��뷢����������'ZZ'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������װ�ñ�ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 70, 1, @curNumber output
	set @deviceID = @curNumber

	--ȡ������/�����˵�������
	declare @keeper nvarchar(300), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert deviceInfo(deviceID, deviceName, devicePhotoFile, buildDate, keeperID, keeper,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@deviceID, @deviceName, @devicePhotoFile, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '�Ǽ�װ��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ���װ�á�' + @deviceName + '['+@deviceID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@deviceID varchar(10)
exec dbo.addDeviceInfo 'װ��2', '', '2012-12-30', '00002', '00002', @Ret output, @createTime output, @deviceID output
select @Ret, @deviceID

select * from deviceInfo
select * from deviceRepairInfo
delete deviceInfo


drop PROCEDURE updateDeviceInfo
/*
	name:		updateDeviceInfo
	function:	5.�޸�װ����Ϣ
	input: 
				@deviceID varchar(10),			--װ�ñ��
				@deviceName nvarchar(30),		--װ������
				@devicePhotoFile varchar(128),	--װ������ͼ�ļ�·��
				@buildDate varchar(10),			--װ�ý�������:���á�yyyy-MM-dd����ʽ����
				@scrappedDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),			--�����˹���

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�װ�ò����ڣ�
							2:Ҫ�޸ĵ�װ���������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE updateDeviceInfo
	@deviceID varchar(10),			--װ�ñ��
	@deviceName nvarchar(30),		--װ������
	@devicePhotoFile varchar(128),	--װ������ͼ�ļ�·��
	@buildDate varchar(10),			--װ�ý�������:���á�yyyy-MM-dd����ʽ����
	@scrappedDate varchar(10),		--��������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),			--�����˹���

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������װ���Ƿ����
	declare @count as int
	set @count=(select count(*) from deviceInfo where deviceID= @deviceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from deviceInfo where deviceID= @deviceID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--������/ȡά���˵�������
	declare @keeper nvarchar(300)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update deviceInfo
	set deviceName = @deviceName, devicePhotoFile = @devicePhotoFile, buildDate = @buildDate, scrappedDate = @scrappedDate, 
		keeperID = @keeperID, keeper = @keeper,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where deviceID= @deviceID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�װ��', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸���װ�á�' + @deviceName + '['+@deviceID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delDeviceInfo
/*
	name:		delDeviceInfo
	function:	6.ɾ��ָ����װ��
	input: 
				@deviceID varchar(10),			--װ�ñ��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰװ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����װ�ò����ڣ�2��Ҫɾ����װ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 

*/
create PROCEDURE delDeviceInfo
	@deviceID varchar(10),			--װ�ñ��
	@delManID varchar(10) output,	--ɾ���ˣ������ǰװ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������װ���Ƿ����
	declare @count as int
	set @count=(select count(*) from deviceInfo where deviceID= @deviceID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from deviceInfo where deviceID= @deviceID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete deviceInfo where deviceID= @deviceID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��װ��', '�û�' + @delManName
												+ 'ɾ����װ��['+@deviceID+']��')

GO


--------------------------------------------װ��ά�޴洢����----------------------------------
drop PROCEDURE queryDeviceRepairLocMan
/*
	name:		queryDeviceRepairLocMan
	function:	10.��ѯָ��װ��ά�����뵥�Ƿ��������ڱ༭
	input: 
				@repairID varchar(10),		--װ��ά�����뵥��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����װ��ά�����뵥������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE queryDeviceRepairLocMan
	@repairID varchar(10),		--װ��ά�����뵥��
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from deviceRepairInfo where repairID= @repairID),'')
	set @Ret = 0
GO

drop PROCEDURE lockDeviceRepair4Edit
/*
	name:		lockDeviceRepair4Edit
	function:	11.����װ��ά�����뵥�༭������༭��ͻ
	input: 
				@repairID varchar(10),			--װ��ά�����뵥��
				@lockManID varchar(10) output,	--�����ˣ������ǰװ��ά�����뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������װ��ά�����뵥�����ڣ�2:Ҫ������װ��ά�����뵥���ڱ����˱༭��
							3:�õ����Ѿ���ɣ����ܱ༭����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE lockDeviceRepair4Edit
	@repairID varchar(10),			--װ��ά�����뵥��
	@lockManID varchar(10) output,	--�����ˣ������ǰװ��ά�����뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������װ��ά�����뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from deviceRepairInfo where repairID= @repairID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������뵥��״̬��
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--�жϵ���״̬��
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	update deviceRepairInfo
	set lockManID = @lockManID 
	where repairID= @repairID
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
	values(@lockManID, @lockManName, getdate(), '����װ��ά�ޱ༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������װ��ά�����뵥['+ @repairID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockDeviceRepairEditor
/*
	name:		unlockDeviceRepairEditor
	function:	12.�ͷ�װ��ά�����뵥�༭��
				ע�⣺�����̲����װ��ά�����뵥�Ƿ���ڣ�
	input: 
				@repairID varchar(10),			--װ��ά�����뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰװ��ά�����뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE unlockDeviceRepairEditor
	@repairID varchar(10),			--װ��ά�����뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰװ��ά�����뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from deviceRepairInfo where repairID= @repairID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update deviceRepairInfo set lockManID = '' where repairID= @repairID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�װ��ά�ޱ༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���װ��ά�޵�['+ @repairID +']�ı༭����')
GO


	
drop PROCEDURE addDeviceRepairInfo
/*
	name:		addDeviceRepairInfo
	function:	13.���װ��ά�޵�
	input: 
				@deviceID varchar(10),			--װ�ñ��
				@repairManID varchar(10),		--ά�޸�����ID
				@repairStartTime varchar(19),	--ά�޿�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
				@repairEndTime varchar(19),		--ά��Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
				@remark nvarchar(300),			--˵����ԭ��

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1:��װ�û���δ��ɵ�ά�޹��̣�9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@repairID varchar(10) output	--װ��ά�޵����,��ϵͳʹ�õ�71�ź��뷢����������'ZZ'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE addDeviceRepairInfo
	@deviceID varchar(10),			--װ�ñ��
	@repairManID varchar(10),		--ά�޸�����ID
	@repairStartTime varchar(19),	--ά�޿�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
	@repairEndTime varchar(19),		--ά��Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
	@remark nvarchar(300),			--˵����ԭ��

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@repairID varchar(10) output	--װ��ά�޵����,��ϵͳʹ�õ�71�ź��뷢����������'ZZ'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ���δ��ɵ�ά�ޣ�
	declare @count int
	set @count = isnull((select count(*) from deviceRepairInfo where deviceID = @deviceID and isCompleted = 0),0)
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--ʹ�ú��뷢��������װ�ñ�ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 71, 1, @curNumber output
	set @repairID = @curNumber

	--ȡװ�����ƣ�
	declare @deviceName nvarchar(30)
	set @deviceName = isnull((select deviceName from deviceInfo where deviceID = @deviceID),'')
	
	--ά�޸�����/�����˵�������
	declare @repairMan nvarchar(300), @createManName nvarchar(30)
	set @repairMan = isnull((select cName from userInfo where jobNumber = @repairManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--���㱾��ά��ʱ�䣺
	declare @repairMinute int --��λ������
	set @repairMinute = DATEDIFF(MINUTE,@repairStartTime, @repairEndTime)

	set @createTime = getdate()
	insert deviceRepairInfo(repairID, deviceID, deviceName, repairManID, repairMan, 
					repairStartTime, repairEndTime, remark, repairMinute,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@repairID, @deviceID, @deviceName, @repairManID, @repairMan, 
					@repairStartTime, @repairEndTime, @remark, @repairMinute,
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
	values(@createManID, @createManName, @createTime, '�Ǽ�װ��ά��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ���װ�á�' + @deviceName + '����ά�޵�['+@repairID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@repairID varchar(10)
exec dbo.addDeviceRepairInfo 'ZZ20130025', '00001', '2013-1-9 12:00:00', '2013-1-10 12:00:00', '��ȱ���', '00002',
		 @Ret output, @createTime output, @repairID output
select @Ret, @repairID


select * from deviceInfo
select * from deviceRepairInfo
delete deviceRepairInfo


drop PROCEDURE updateDeviceRepairInfo
/*
	name:		updateDeviceRepairInfo
	function:	14.�޸�װ��ά�޵���Ϣ
	input: 
				@repairID varchar(10),			--װ��ά�޵����
				@deviceID varchar(10),			--װ�ñ��
				@repairManID varchar(10),		--ά�޸�����ID
				@repairStartTime varchar(19),	--ά�޿�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
				@repairEndTime varchar(19),		--ά��Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
				@remark nvarchar(300),			--˵����ԭ��

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�װ��ά�޵������ڣ�
							2:Ҫ�޸ĵ�װ��ά�޵��������������༭��
							3:��ά�޵��Ѿ���ɣ������޸�
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 
*/
create PROCEDURE updateDeviceRepairInfo
	@repairID varchar(10),			--װ��ά�޵����
	@deviceID varchar(10),			--װ�ñ��
	@repairManID varchar(10),		--ά�޸�����ID
	@repairStartTime varchar(19),	--ά�޿�ʼʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
	@repairEndTime varchar(19),		--ά��Ԥ�ƽ���ʱ�䣺����"yyyy-MM-dd hh:mm:ss"��ʽ����
	@remark nvarchar(300),			--˵����ԭ��

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������װ��ά�޵��Ƿ����
	declare @count as int
	set @count=(select count(*) from deviceRepairInfo where repairID= @repairID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--������뵥��״̬��
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--�жϵ���״̬��
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	--ȡװ�����ƣ�
	declare @deviceName nvarchar(30)
	set @deviceName = isnull((select deviceName from deviceInfo where deviceID = @deviceID),'')
	
	--ά�޸�����/ȡά���˵�����
	declare @repairMan nvarchar(300)
	set @repairMan = isnull((select cName from userInfo where jobNumber = @repairManID),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--���㱾��ά��ʱ�䣺
	declare @repairMinute int --��λ������
	set @repairMinute = DATEDIFF(MINUTE,@repairStartTime, @repairEndTime)

	set @modiTime = getdate()
	update deviceRepairInfo
	set deviceID = @deviceID, deviceName = @deviceName, repairManID = @repairManID, repairMan = @repairMan, 
					repairStartTime = @repairStartTime, repairEndTime = @repairEndTime, 
					remark = @remark, repairMinute = @repairMinute,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where deviceID= @deviceID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�װ��ά�޵�', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸���װ�á�' + @deviceName + '����ά�޵�['+@repairID+']������Ϣ��')
GO

drop PROCEDURE delDeviceRepairInfo
/*
	name:		delDeviceRepairInfo
	function:	15.ɾ��ָ����װ��ά�޵�
	input: 
				@repairID varchar(10),			--װ��ά�޵����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰװ��ά�޵����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����װ��ά�޵������ڣ�2��Ҫɾ����װ��ά�޵���������������
							3:��ά�޵��Ѿ���ɣ�����ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 

*/
create PROCEDURE delDeviceRepairInfo
	@repairID varchar(10),			--װ��ά�޵����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰװ��ά�޵����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������װ��ά�޵��Ƿ����
	declare @count as int
	set @count=(select count(*) from deviceRepairInfo where repairID= @repairID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--�жϵ���״̬��
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	delete deviceRepairInfo where repairID= @repairID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��װ��ά�޵�', '�û�' + @delManName
												+ 'ɾ����װ��ά�޵�['+@repairID+']��')
GO

drop PROCEDURE completeDeviceRepair
/*
	name:		completeDeviceRepair
	function:	15.���ָ��װ�õ�ά�ޣ���ά�޵�����Ϊ���״̬
				ע�⣺����ʹ�õ���װ�ñ�ţ�ϵͳ�Զ���λ��δ��ɵ�ά�޵���
	input: 
				@deviceID varchar(10),			--װ�ñ��
				@completedTime varchar(19),		--ά��ʵ�����ʱ��:���á�yyyy-MM-dd  hh:mm:ss����ʽ����
				@completedDesc nvarchar(300),	--ά��������
				@completerID varchar(10) output,--����ˣ������ǰװ��ά�޵����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1����ǰװ�ò�����ά��״̬��2��Ҫ��ɵ�װ��ά�޵���������������
							3:�õ����Ѿ������״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-9
	UpdateDate: 

*/
create PROCEDURE completeDeviceRepair
	@deviceID varchar(10),			--װ�ñ��
	@completedTime varchar(19),		--ά��ʵ�����ʱ��:���á�yyyy-MM-dd  hh:mm:ss����ʽ����
	@completedDesc nvarchar(300),	--ά��������
	@completerID varchar(10) output,--����ˣ������ǰװ��ά�޵����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--��ȡ��ǰ����ά�޵ĵ��ţ�
	declare @repairID varchar(10)
	set @repairID = isnull((select top 1 repairID from deviceRepairInfo where deviceID = @deviceID and isCompleted = 0),'')
	--�ж�Ҫ������װ��ά�޵��Ƿ����
	if (@repairID='')	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isCompleted smallint
	select @thisLockMan = isnull(lockManID,''), @isCompleted = isCompleted from deviceRepairInfo where repairID= @repairID
	if (@thisLockMan <> '' and @thisLockMan <> @completerID)
	begin
		set @completerID = @thisLockMan
		set @Ret = 2
		return
	end
	--�жϵ���״̬��
	if (@isCompleted=1)
	begin
		set @Ret = 3
		return
	end

	--ȡ���������
	declare @completer nvarchar(30)
	set @completer = isnull((select userCName from activeUsers where userID = @completerID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update deviceRepairInfo 
	set isCompleted = 1, completedTime = @completedTime, completedDesc = @completedDesc,
		repairMinute = DATEDIFF(MINUTE,repairStartTime, @completedTime),
		--����ά�����:
		modiManID = @completerID, modiManName = @completer, modiTime = @modiTime
	where repairID= @repairID
	set @Ret = 0


	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@completerID, @completer, @modiTime, '���װ��ά��', '�û�' + @completer
												+ '�����װ��ά�޵��趨�������ά�޵�['+@repairID+']��')
GO


--װ�õ�ǰ״̬��ѯ��䣺
select deviceID, deviceName, devicePhotoFile, buildDate, scrappedDate, keeperID, keeper, 
	dbo.getDeviceStatus(deviceID, GETDATE()) statusRemark	--����{status:"����", statusCode:1, remark:""} Json����״̬�룺0->���豸������1->����-1->ά����
from deviceInfo

	
--װ����ʷ״̬��ѯ��䣺
select deviceID, deviceName, devicePhotoFile, buildDate, scrappedDate, keeperID, keeper, 
	dbo.getDeviceStatus(deviceID, '2012-01-01') statusRemark	--����{status:"����", statusCode:1, remark:""} Json����״̬�룺0->���豸������1->����-1->ά����
from deviceInfo

select cast(N'<root><status>����</status><statusCode>1</statusCode><remark></remark></root>'  as XML)


select convert(smalldatetime, '2012-01-01', 120)


--ά�����뵥��ѯ��䣺
select repairID, deviceID, deviceName, repairManID, repairMan, repairStartTime, repairEndTime, remark
from deviceRepairInfo

