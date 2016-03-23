use epdc211
/*
	����豸������Ϣϵͳ-��������
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: 
*/
--1.վ�ڹ���һ����bulletinInfo����
select bulletinID a,* from bulletinInfo where isActive =1 order by isActive desc, orderNum, a desc
update bulletinInfo
set lockManID = ''

drop TABLE bulletinInfo
CREATE TABLE bulletinInfo
(
	bulletinID char(12) not null,			--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
	bulletinTime datetime null,				--����ʱ��
	bulletinTitle nvarchar(100) null,		--�������
	bulletinHTML nvarchar(max) null,		--��������

	isActive int default(0),				--�Ƿ���ʾ�������0->δ���1->�Ѽ���
	activeDate smalldatetime null,			--��������
	orderNum smallint default(-1),			--��ʾ�����
	autoCloseDate smalldatetime null,		--�Զ��ر�����

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

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,
				@bulletinID char(12) output		--�����������ţ�ʹ�õ� 10010 �ź��뷢��������
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2011-12-4���ӹ������ں��Զ��ر����ڲ���

*/
create PROCEDURE addBulletinInfo
	@bulletinTitle nvarchar(100),		--�������
	@bulletinTime varchar(10),		--��������
	@autoCloseDate varchar(10),		--�����Զ��ر�����
	@bulletinHTML nvarchar(max),		--��������

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

	insert bulletinInfo(bulletinID, bulletinTime, autoCloseDate, bulletinTitle, bulletinHTML,
							lockManID, modiManID, modiManName, modiTime) 
	values (@bulletinID, @bulletinTime, @autoCloseDate, @bulletinTitle, @bulletinHTML,
							@createManID, @createManID, @createManName, @createTime)
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


DROP PROCEDURE activeBulletinInfo
/*
	name:		activeBulletinInfo
	function:	2.����ָ���Ĺ��棬���Զ����������
	input: 
				@bulletinID char(12),			--������
				@autoCloseDate varchar(10),		--�Զ��ر�����
				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ����Ĺ��治���ڣ�2:Ҫ����Ĺ������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: 
*/
create PROCEDURE activeBulletinInfo
	@bulletinID char(12),			--������
	@autoCloseDate varchar(10),		--�Զ��ر�����

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
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���Ĭ�Ϲر�ʱ�䣺
	if (@autoCloseDate ='')
		set @autoCloseDate = convert(varchar(10), dateadd(day, 7, getdate()), 120)
	
	set @updateTime = getdate()
	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from bulletinInfo where isActive = 1),0)
	update bulletinInfo
	set isActive = 1, activeDate = @updateTime,
		autoCloseDate = @autoCloseDate,
		
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID

	--���ù����ö���
	declare @execRet int
	exec dbo.setBulletinToTop @bulletinID, @modiManID output, @execRet output

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����', '�û�' + @modiManName 
												+ '�����˹���['+ @bulletinID +']��')
GO

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
							0:�ɹ���1��Ҫ���ߵĹ��治���ڣ�2:Ҫ���ߵĹ������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-23
	UpdateDate: 
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
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = -1,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�رչ���', '�û�' + @modiManName 
												+ '�ر��˹���['+ @bulletinID +']��')
GO

drop PROCEDURE delBulletinInfo
/*
	name:		delBulletinInfo
	function:	3.ɾ��ָ���Ĺ���
	input: 
				@bulletinID char(12),			--������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1���ù��治���ڣ�2:Ҫɾ���Ĺ�����Ϣ��������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-24
	UpdateDate:
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
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete bulletinInfo where bulletinID = @bulletinID
	
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
	function:	4.����ָ���Ĺ������ݻ����
	input: 
				@bulletinID char(12),			--������
				@bulletinTitle nvarchar(100),	--�������
				@bulletinTime varchar(10),		--��������
				@autoCloseDate varchar(10),		--�����Զ��ر�����
				@bulletinHTML nvarchar(max),	--��������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�޸ĵĹ��治���ڣ�2:Ҫ�޸ĵĹ������ڱ����˱༭��3.�ù����Ѽ��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-24
	UpdateDate: modi by lw 2011-12-4���ӹ������ں��Զ��ر����ڲ���

*/
create PROCEDURE updateBulletinInfo
	@bulletinID char(12),			--������
	@bulletinTitle nvarchar(100),	--�������
	@bulletinTime varchar(10),		--��������
	@autoCloseDate varchar(10),		--�����Զ��ر�����
	@bulletinHTML nvarchar(max),	--��������

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
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��鹫��״̬:
	declare @isActive int
	set @isActive = (select isActive from bulletinInfo where bulletinID = @bulletinID)
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
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�޸Ĺ���', '�û�' + @modiManName 
												+ '�޸��˹���['+ @bulletinID +']��')
GO


drop PROCEDURE closeDieingBulletinInfo
/*
	name:		closeDieingBulletinInfo
	function:	5.�Զ��رյ��ڵĹ��棨��������Ǹ�ά���ƻ������ã��û����ð�װ��
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
	set @count=(select count(*) from bulletinInfo where isActive =1 and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120))	
	if (@count = 0)	--������
	begin
		return
	end

	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = 0
	where isActive =1 and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120)

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('', 'System', getdate(), '�Զ��رյ��ڹ���', 'ϵͳִ�����Զ��رյ��ڹ���ļƻ��ر���'+cast(@count as varchar(10))+'�����ڵĹ��档')
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
	function:	6.��ָ���Ŀ���ʾ�����ö�
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ö��Ĺ��治���ڣ�2:Ҫ�ö��Ĺ������ڱ����˱༭��3.�ù���δ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-27
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
	values(@modiManID, @modiManName, getdate(), '�����ö�', '�û�' + @modiManName 
												+ '������['+ @bulletinID +']�ö���')
GO
--���ԣ�
select * from bulletinInfo
declare @Ret int 
exec dbo.setBulletinToTop '201111260001', '00200977', @Ret output

DROP PROCEDURE setBulletinToLast
/*
	name:		setBulletinToLast
	function:	7.��ָ���Ŀ���ʾ��������һ��
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ��Ĺ��治���ڣ�2:Ҫ�ƶ��Ĺ������ڱ����˱༭��3.�ù���δ���
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
	function:	8.��ָ���Ŀ���ʾ��������һ��
	input: 
				@bulletinID char(12),			--������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ��Ĺ��治���ڣ�2:Ҫ�ƶ��Ĺ������ڱ����˱༭��3.�ù���δ���
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
	function:	9.��ѯָ�������Ƿ��������ڱ༭
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
	function:	10.�������濪ʼ�༭������༭��ͻ
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
	function:	11.�ͷŹ���༭��
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
	name:		12.addResource
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
	function:	13.ɾ��ָ������Դ�ļ�
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
