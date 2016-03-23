use hustOA
/*
	ǿ�ų����İ칫ϵͳ-���Ϲ���
	���������ó��ͬ������Ϣϵͳ���Ϲ���ı�
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
--1��ý�����Ϲ����
--��ý���ļ�����~\upload\resouce\Ŀ¼�У�������ţ��ֱ�Ϊ��picture��ͼƬ����media��Ӱ���ļ�����doc���ĵ�����template��ģ�壩
select * from resourceInfo
update resourceInfo
set isPublish='Y'

drop TABLE resourceInfo
CREATE TABLE resourceInfo(
	resourceTheme nvarchar(30) not null,--�������
	resourceName nvarchar(30) not null,	--��������
	resourceType varchar(30) not null,	--�������ͣ�picture��ͼƬ����media��Ӱ���ļ�����doc���ĵ�����template��ģ�壩
	rFilename varchar(128) not NULL,	--�����ļ�Ψһ�ļ����������ϴ��ؼ��������ļ�������·����
	notes nvarchar(100) null,			--˵��
	uploadDate smalldatetime default(getdate()), --�ϴ�����
	isPublish char(1) default('N'),		--�Ƿ񷢲�
	orderNum smallint default(-1),		--��ʾ�����
	usedTimes bigint default(0),		--ʹ�ô������������ȶ�ͳ��ʹ�õ�
	createrID varchar(10) null,			--�����˹���
	createrName varchar(30) null,		--������
 CONSTRAINT [PK_resourceInfo] PRIMARY KEY CLUSTERED 
(
	[resourceType] ASC,
	[rFilename] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����������
CREATE NONCLUSTERED INDEX [IX_resourceInfo] ON [dbo].[resourceInfo]
(
	[createrID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��ʾ����������
CREATE NONCLUSTERED INDEX [IX_resourceInfo_01] ON [dbo].[resourceInfo]
(
	[orderNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�������������
CREATE NONCLUSTERED INDEX [IX_resourceInfo_0] ON [dbo].[resourceInfo]
(
	[resourceTheme] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�Ƿ񷢲�������
CREATE NONCLUSTERED INDEX [IX_resourceInfo_1] ON [dbo].[resourceInfo]
(
	[isPublish] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--ʹ��Ƶ��������
CREATE NONCLUSTERED INDEX [IX_resourceInfo_2] ON [dbo].[resourceInfo]
(
	[usedTimes] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��������������
CREATE NONCLUSTERED INDEX [IX_resourceInfo_4] ON [dbo].[resourceInfo]
(
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�����������������
CREATE NONCLUSTERED INDEX [IX_resourceInfo_5] ON [dbo].[resourceInfo]
(
	[resourceType] ASC,
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.���ϻ���վ���û�ɾ�������ϲ�����ʵɾ�������Ƿ���һ��RecycleBin��Ŀ¼��ͬ���������
drop TABLE resourceRecycle
CREATE TABLE resourceRecycle(
	resourceTheme nvarchar(30) not null,--����
	resourceName nvarchar(30) not null,	--��������
	resourceType varchar(30) not null,	--�������ͣ�picture��ͼƬ����media��Ӱ���ļ�����doc���ĵ�����template��ģ�壩
	rFilename varchar(128) not NULL,	--�����ļ�Ψһ�ļ���
	notes nvarchar(100) null,			--˵��
	uploadDate smalldatetime default(getdate()), --�ϴ�����
	usedTimes bigint default(0),			--ʹ�ô������������ȶ�ͳ��ʹ�õ�
	delDate smalldatetime default(getdate()),--ɾ������
	createrID varchar(10) null,			--������
	createrName varchar(30) null,		--����������
 CONSTRAINT [PK_resourceRecycle] PRIMARY KEY CLUSTERED 
(
	[resourceType] ASC,
	[rFilename] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_resourceRecycle] ON [dbo].[resourceRecycle]
(
	[createrID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--ɾ������������
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_1] ON [dbo].[resourceRecycle]
(
	[delDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--ʹ��Ƶ��������
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_2] ON [dbo].[resourceRecycle]
(
	[usedTimes] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��������������
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_3] ON [dbo].[resourceRecycle]
(
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�����������������
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_4] ON [dbo].[resourceRecycle]
(
	[resourceType] ASC,
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE addResource
/*
	name:		1.addResource
	function:	�������
				@resourceTheme nvarchar(30),--����
				@resourceName nvarchar(30),	--��������
				@resourceType varchar(30),	--�������ͣ�picture��ͼƬ����media��Ӱ���ļ�����doc���ĵ�����template��ģ�壩
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���
				@notes nvarchar(100),		--˵��
				@createrID varchar(10),		--������
	output: 
				@Ret		int output		--�����ɹ���ʶ
										0:�ɹ���1�������ļ�����Ψһ��9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-26
	UpdateDate: 
*/
create PROCEDURE addResource
	@resourceTheme nvarchar(30),--����
	@resourceName nvarchar(30),	--��������
	@resourceType varchar(30),	--�������ͣ�picture��ͼƬ����media��Ӱ���ļ�����doc���ĵ�����template��ģ�壩
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���
	@notes nvarchar(100),		--˵��
	@createrID varchar(10),		--������
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж������ļ����Ƿ�Ψһ
	declare @count as int
	set @count=(select count(*) from resourceInfo where resourceType = @resourceType and resourceName = @resourceName)	
	if (@count > 0)	--���Ƴ�ͻ
	begin
		set @Ret = 1
		return
	end

	
	--ȡ�����˵�������
	declare @createrName nvarchar(30)
	set @createrName = isnull((select userCName from activeUsers where userID = @createrID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	insert resourceInfo(resourceTheme, resourceName, resourceType, rFilename, notes, createrID, createrName,uploadDate)
	values(@resourceTheme, @resourceName, @resourceType, @rFilename, @notes, @createrID, @createrName, @updateTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	declare @attachmentName varchar(100)
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createrID, @createrName, @updateTime, '�������', '�û�' + @createrName
												+ '�����һ�����Ϊ['+@resourceType+']����Ϊ['+ @resourceName +']�����ϡ�')
GO

drop PROCEDURE delResource
/*
	name:		delResource
	function:	2.ɾ��ָ�����ļ���������
				ע�⣺ϵͳ��û����ʵɾ�������ǽ������������վ
	input: 
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

				@delManID varchar(10) output,--ɾ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ�������ϲ����ڣ�2�������վ���ļ�����ͻ��9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-26
	UpdateDate: 

*/
create PROCEDURE delResource
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

	@delManID varchar(10) output,--ɾ����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--�ж��Ƿ������վ���ļ�����ͻ
	set @count=(select count(*) from resourceRecycle where rFilename = @rFilename)	
	if (@count > 0)	--��ͻ
	begin
		set @Ret = 2
		return
	end

	declare @delDate smalldatetime
	set @delDate = GETDATE()
	insert resourceRecycle(resourceTheme,resourceName, resourceType, rFilename, notes, createrID, createrName, uploadDate, usedTimes, delDate)
	select resourceTheme,resourceName, resourceType, rFilename, notes, createrID, createrName, uploadDate, usedTimes, @delDate
	from resourceInfo
	where rFilename = @rFilename
	
	delete resourceInfo where rFilename = @rFilename
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')
	--ȡ��������\���
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delDate, 'ɾ������', '�û�' + @delManName
												+ 'ɾ�������Ϊ['+ @resourceType +']������['+@resourceName+']��')
GO


drop PROCEDURE publishResource
/*
	name:		3.publishResource
	function:	��������
	input: 
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

				@publishManID varchar(10) output,--������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ�������ϲ����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-26
	UpdateDate: 
*/
create PROCEDURE publishResource
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

	@publishManID varchar(10) output,--������
	@Ret int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from resourceInfo where isPublish='Y'),0) + 1
	update resourceInfo
	set isPublish = 'Y', orderNum=@curMaxOrderNum
	where rFilename = @rFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0

	--ȡ������������
	declare @shareName varchar(30)
	set @shareName = isnull((select userCName from activeUsers where userID = @publishManID),'')
	--ȡ��������\���
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@publishManID, @shareName, GETDATE(), '��������', '�û�' + @shareName
												+ '���������Ϊ['+ @resourceType +']������['+@resourceName+']��')
GO

drop PROCEDURE closeResource
/*
	name:		4.closeResource
	function:	������������
	input: 
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

				@closeManID varchar(10) output,--������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ�������ϲ����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-19
	UpdateDate: 
*/
create PROCEDURE closeResource
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

	@closeManID varchar(10) output,--������
	@Ret int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	update resourceInfo
	set isPublish = 'N'
	where rFilename = @rFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0

	--ȡ������������
	declare @shareName varchar(30)
	set @shareName = isnull((select userCName from activeUsers where userID = @closeManID),'')
	--ȡ��������\���
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@closeManID, @shareName, GETDATE(), '�������Ϸ���', '�û�' + @shareName
												+ '���������Ϊ['+ @resourceType +']������['+@resourceName+']�ķ�����')
GO

drop PROCEDURE addUsedTimes
/*
	name:		4.addUsedTimes
	function:	��������ʹ�ô���
	input: 
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

				@useManID varchar(10) output,--ʹ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ�������ϲ����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-26
	UpdateDate: 
*/
create PROCEDURE addUsedTimes
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

	@useManID varchar(10) output,--ʹ����
	@Ret int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	update resourceInfo
	set usedTimes = usedTimes+1
	where rFilename = @rFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0
/*
	--ȡʹ����������
	declare @useManName varchar(30)
	set @useManName = isnull((select userCName from activeUsers where userID = @useManID),'')
	--ȡ��������\���
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@useManID, @useManName, GETDATE(), '��������', '�û�' + @useManName
												+ 'ʹ�������Ϊ['+ @resourceType +']������['+@resourceName+']��')
*/
GO

DROP PROCEDURE setResourceToTop
/*
	name:		setResourceToTop
	function:	10.��ָ�����ѷ����������ö�
	input: 
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

				--ά�����:
				@modiManID varchar(10),		--ά����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ö������ϲ����ڣ�3.������δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE setResourceToTop
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

	--ά�����:
	@modiManID varchar(10),		--ά����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--�������״̬:
	declare @resourceName nvarchar(30)	--��������
	declare @isPublish char(1)	--�Ƿ񷢲�
	select @isPublish = isPublish, @resourceName=resourceName from resourceInfo where rFilename = @rFilename
	if (@isPublish <> 'Y')
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ѷ�����������������
	declare @tab table
					(
						rFilename varchar(128) not null,		--�����ļ�Ψһ�ļ���
						orderNum smallint default(-1)			--��ʾ�����
					)
	insert @tab
	select rFilename, orderNum from resourceInfo 
	where isPublish ='Y' and rFilename <> @rFilename
	order by orderNum
	begin tran
		declare @rf varchar(128), @i int
		set @i = 2
		declare tar cursor for
		select rFilename from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @rf
		WHILE @@FETCH_STATUS = 0
		begin
			update resourceInfo
			set orderNum = @i
			where rFilename = @rf
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @rf
		end
		CLOSE tar
		DEALLOCATE tar
		--��ָ���������ö���	
		update resourceInfo
		set orderNum = 1
		where rFilename = @rFilename
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
												+ '������['+ @resourceName +']�ö���')
GO
--���ԣ�
select * from resourceInfo 
where isPublish ='Y'
order by orderNum

declare @Ret int 
exec dbo.setResourceToTop '/hustoa/upload/resouce/201304/0514211b-76c9-42ac-a1f0-d17fd84f95c2.jpg', '00200977', @Ret output

DROP PROCEDURE setResourceToLast
/*
	name:		setResourceToLast
	function:	11.��ָ�����ѷ�������������һ��
	input: 
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

				--ά�����:
				@modiManID varchar(10),		--ά����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ������ϲ����ڣ�3.������δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE setResourceToLast
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

	--ά�����:
	@modiManID varchar(10),		--ά����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--�������״̬:
	declare @resourceName nvarchar(30)	--��������
	declare @isPublish char(1)			--�Ƿ񷢲�
	declare @myOrderNum smallint		--�����ϵ������
	select @isPublish = isPublish, @resourceName=resourceName, @myOrderNum=orderNum from resourceInfo where rFilename = @rFilename
	if (@isPublish <> 'Y')
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ѷ�����λ���ڱ�����ǰ���������������
	declare @tab table
					(
						rFilename varchar(128) not null,		--�����ļ�Ψһ�ļ���
						orderNum smallint default(-1)			--��ʾ�����
					)
	insert @tab
	select rFilename, orderNum from resourceInfo 
	where isPublish ='Y' and orderNum < @myOrderNum
	order by orderNum
	begin tran
		declare @rf varchar(128), @i int
		set @i = 1
		declare tar cursor for
		select rFilename from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @rf
		WHILE @@FETCH_STATUS = 0
		begin
			update resourceInfo
			set orderNum = @i
			where rFilename = @rf
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @rf
		end
		CLOSE tar
		DEALLOCATE tar
		--��ָ������������һ�У�	
		update resourceInfo
		set orderNum = @i
		where rFilename = @rf
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update resourceInfo
		set orderNum = @i - 1
		where rFilename = @rFilename
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
												+ '������['+ @resourceName +']������һ�С�')
GO
--���ԣ�
select * from resourceInfo 
where isPublish ='Y'
order by orderNum

declare @Ret int 
exec dbo.setResourceToLast '/hustoa/upload/resouce/201306/3948954f-cd5c-49ce-a1e5-9819e3e1ec7b.jpg', '00200977', @Ret output

DROP PROCEDURE setResourceToNext
/*
	name:		setResourceToNext
	function:	12.��ָ�����ѷ�������������һ��
	input: 
				@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

				--ά�����:
				@modiManID varchar(10),		--ά����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ������ϲ����ڣ�3.������δ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE setResourceToNext
	@rFilename varchar(128),	--�����ļ�Ψһ�ļ���

	--ά�����:
	@modiManID varchar(10),		--ά����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--�������״̬:
	declare @resourceName nvarchar(30)	--��������
	declare @isPublish char(1)			--�Ƿ񷢲�
	declare @myOrderNum smallint		--�����ϵ������
	select @isPublish = isPublish, @resourceName=resourceName, @myOrderNum=orderNum from resourceInfo where rFilename = @rFilename
	if (@isPublish <> 'Y')
	begin
		set @Ret = 3
		return
	end


	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--������������һ�����Ͻ���λ�ã�
	declare @nextRFilename varchar(128), @nextOrderNum smallint
	select top 1 @nextRFilename = rFilename, @nextOrderNum = orderNum 
	from resourceInfo 
	where isPublish ='Y' and orderNum > @myOrderNum
	order by orderNum
	
	if (@nextRFilename is not null)
	begin
		begin tran
			update resourceInfo
			set orderNum = @nextOrderNum
			where rFilename = @rFilename
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update resourceInfo
			set orderNum = @myOrderNum
			where rFilename = @nextRFilename
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
												+ '������['+ @resourceName +']������һ�С�')
GO
--���ԣ�
select * from resourceInfo 
where isPublish ='Y'
order by orderNum

declare @Ret int 
exec dbo.setResourceToNext '/hustoa/upload/resouce/201306/3948954f-cd5c-49ce-a1e5-9819e3e1ec7b.jpg', '00200977', @Ret output


--��ѯ��䣺
select resourceTheme, resourceName, resourceType, rFilename, notes, createrID, createrName, convert(varchar(10),uploadDate,120) uploadDate, 
isPublish, usedTimes, 
case  when datediff(day,uploadDate,getdate())<8 then datediff(day,uploadDate,getdate()) else 8 end recently
from resourceInfo
order by uploadDate desc    --Ĭ�������Ƿ�������ϴ���ʹ��Ƶ��
