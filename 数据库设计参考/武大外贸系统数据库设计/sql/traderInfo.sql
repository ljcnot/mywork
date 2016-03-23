use fTradeDB
/*
	�����ó��ͬ������Ϣϵͳ--��ó��˾����
	author:		¬έ
	CreateDate:	2012-3-28
	UpdateDate: 
*/
--1.��ó��˾��
alter TABLE traderInfo add abbTraderName nvarchar(6) null		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
select SUBSTRING(traderName,3,2),* from traderInfo
update traderInfo set abbTraderName = SUBSTRING(traderName,3,2)
delete traderInfo
select * from traderInfo
drop TABLE traderInfo
CREATE TABLE traderInfo
(
	traderID varchar(12) not null,		--��������ó��˾���
	traderName nvarchar(30) null,		--��ó��˾����
	abbTraderName nvarchar(6) null,		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
	inputCode varchar(5) null,			--����������
	registeredCapital money null,		--ע���ʱ�
	legal nvarchar(30) null,			--����
	managerID varchar(18) null,			--������ID
	manager nvarchar(30) null,			--�������������������
	managerMobile varchar(30) null,		--��������ϵ�ֻ����������
	e_mail varchar(30) null,			--E_mail��ַ���������
	tel varchar(30) null,				--��˾��ϵ�绰
	tAddress nvarchar(100) null,		--��˾��ַ
	
	--����ά�����:
	buildDate smalldatetime default(getdate()),	--��������
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

 CONSTRAINT [PK_traderInfo] PRIMARY KEY CLUSTERED 
(
	[traderID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_traderInfo] ON [dbo].[traderInfo] 
(
	[traderName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_traderInfo_1] ON [dbo].[traderInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.��ó��˾Ա����(�����¼ϵͳ����Ա)
delete traderManInfo
drop TABLE traderManInfo
CREATE TABLE traderManInfo
(
	traderID varchar(12) not null,		--�������ó��˾���
	manID varchar(10) not null,			--������Ա��ID
	pID varchar(18) null,				--���֤�ţ�Ҫ��Ψһ�Լ��
	manName nvarchar(30) not null,		--Ա������
	inputCode varchar(5) null,			--����������
	post nvarchar(30) null,				--ְ��
	mobile varchar(30) null,			--��ϵ�ֻ�
	tel varchar(30) null,				--�����绰
	e_mail varchar(30) null,			--E_mail��ַ
	hAddress nvarchar(100) null,		--��ͥ��ַ
	
	--����ά�����:
	buildDate smalldatetime default(getdate()),	--��������
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

 CONSTRAINT [PK_traderManInfo] PRIMARY KEY CLUSTERED 
(
	[manID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[traderManInfo] WITH CHECK ADD CONSTRAINT [FK_traderManInfo_traderInfo] FOREIGN KEY([traderID])
REFERENCES [dbo].[traderInfo] ([traderID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[traderManInfo] CHECK CONSTRAINT [FK_traderManInfo_traderInfo]
GO

--������
CREATE NONCLUSTERED INDEX [IX_traderManInfo] ON [dbo].[traderManInfo] 
(
	[manName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_traderManInfo_1] ON [dbo].[traderManInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

	
insert traderInfo(traderID, traderName, abbTraderName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, tAddress,
	buildDate, modiManID, modiManName, modiTime)
select traderID, traderName, abbTraderName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, tAddress,
	buildDate, modiManID, modiManName, modiTime 
from fTradeDB0.dbo.traderInfo
select * from traderInfo
	
insert traderManInfo(traderID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime)
select traderID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime
from fTradeDB0.dbo.traderManInfo

select * from traderManInfo


drop PROCEDURE addTraderInfo
/*
	name:		addTraderInfo
	function:	1.�����ó��˾
				ע�⣺�ô洢�����Զ�������¼
	input: 
				@traderName nvarchar(30),		--��ó��˾����
				@abbTraderName nvarchar(6),		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
				@inputCode varchar(5),			--����������
				@registeredCapital money,		--ע���ʱ�
				@legal nvarchar(30),			--����
				@manager nvarchar(30),			--������
				@managerMobile varchar(30),		--��������ϵ�ֻ������Ψһ��
				@e_mail varchar(30),			--E_mail��ַ
				@tel varchar(30),				--��˾��ϵ�绰
				@tAddress nvarchar(100),		--��˾��ַ

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1:�ø����˵��ֻ��Ѿ������˵Ǽǹ�,9:δ֪����
				@createTime smalldatetime output--���ʱ��
				@traderID varchar(12) output	--��������ó��˾���
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: modi by lw 2012-4-27���Ӽ��

*/
create PROCEDURE addTraderInfo
	@traderName nvarchar(30),		--��ó��˾����
	@abbTraderName nvarchar(6),		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
	@inputCode varchar(5),			--����������
	@registeredCapital money,		--ע���ʱ�
	@legal nvarchar(30),			--����
	@manager nvarchar(30),			--������
	@managerMobile varchar(30),		--��������ϵ�ֻ������Ψһ��
	@e_mail varchar(30),			--E_mail��ַ
	@tel varchar(30),				--��˾��ϵ�绰
	@tAddress nvarchar(100),		--��˾��ַ

	@createManID varchar(10),		--�����˹���

	@Ret		int output,			--�����ɹ���ʶ
	@createTime smalldatetime output,--���ʱ��
	@traderID varchar(12) output	--��������ó��˾���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢����������ó��˾��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 12, 1, @curNumber output
	set @traderID = @curNumber
	--ʹ�ú��뷢��������Ա����ţ�
	declare @managerID varchar(18)			--������ID
	exec dbo.getClassNumber 13, 1, @curNumber output
	set @managerID = @curNumber

	--����ֻ���Ψһ�ԣ�
	declare @iCount int
	if (@managerMobile<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where mobile = @managerMobile)
		if (@iCount = 0)	--���������ó��˾Ա��
			set @iCount = (select count(*) from traderManInfo where mobile = @managerMobile)
		if (@iCount = 0)	--�������ѧУԱ��
			set @iCount = (select count(*) from userInfo where mobileNum = @managerMobile)
		if (@iCount = 0)	--�������������Ȩ�û�
			set @iCount = (select count(*) from sysUserInfo where mobile = @managerMobile)
		if (@iCount > 0)
		begin
			set @Ret = 1
			return
		end
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	begin tran
		insert traderInfo(traderID, traderName, abbTraderName, inputCode, registeredCapital, legal, managerID, manager, managerMobile, e_mail, tel, tAddress,
				lockManID, modiManID, modiManName, modiTime) 
		values (@traderID, @traderName, @abbTraderName, @inputCode, @registeredCapital, @legal, @managerID, @manager, @managerMobile, @e_mail, @tel, @tAddress,
				@createManID, @createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		  
		--�Ǽ�Ա����
		declare @managerInputCode varchar(5)
		set @managerInputCode = (select dbo.getChinaPYCode(@manager))
		insert traderManInfo(traderID, manID, manName, inputCode, post, mobile, tel, e_mail, hAddress)
		values(@traderID, @managerID, @manager, @managerInputCode, '�ܾ���', @managerMobile, @tel, @e_mail, '')
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		--�Ǽ�ϵͳ�û���
		insert sysUserInfo(userType, userID, pID, mobile, cName, unitName, sysUserName)
		values(3, @managerID, '', @managerMobile, @manager, @traderName, '')
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
	commit tran

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�����ó��˾', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ���������ó��˾[' + @traderName + '('+@traderID+')]��')
GO
--���ԣ�
declare @Ret int, @createTime smalldatetime, @traderID varchar(12)
exec dbo.addTraderInfo ' �人����ó�׹�˾', 'WHJMS', 100000, 'wt', '����', '18702702392', 'lw_bk@163.com', '02781693105','�й��人'	,
	'00201314', @Ret output, @createTime output, @traderID output
select @Ret, @createTime, @traderID

select * from traderInfo 
select * from traderManInfo
update traderInfo set lockManID=''

drop PROCEDURE queryTraderInfoLocMan
/*
	name:		queryTraderInfoLocMan
	function:	2.��ѯָ����ó��˾�Ƿ��������ڱ༭
	input: 
				@traderID varchar(12),	--��ó��˾���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ������ó��˾������
				@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE queryTraderInfoLocMan
	@traderID varchar(12),	--��ó��˾���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from traderInfo where traderID = @traderID),'')
	set @Ret = 0
GO


drop PROCEDURE lockTraderInfo4Edit
/*
	name:		lockTraderInfo4Edit
	function:	3.������ó��˾�༭������༭��ͻ
	input: 
				@traderID varchar(12),	--��ó��˾���
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ��������ó��˾�����ڣ�2:Ҫ��������ó��˾���ڱ����˱༭
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE lockTraderInfo4Edit
	@traderID varchar(12),	--��ó��˾���
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ��������ó��˾�Ƿ����
	declare @count as int
	set @count=(select count(*) from traderInfo where traderID = @traderID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderInfo 
	where traderID = @traderID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update traderInfo 
	set lockManID = @lockManID 
	where traderID = @traderID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������ó��˾�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ����������ó��˾['+ @traderID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockTraderInfoEditor
/*
	name:		unlockTraderInfoEditor
	function:	4.�ͷ���ó��˾�༭��
				ע�⣺�����̲������ó��˾�Ƿ���ڣ�
	input: 
				@traderID varchar(12),	--��ó��˾���
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE unlockTraderInfoEditor
	@traderID varchar(12),	--��ó��˾���
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from traderInfo where traderID = @traderID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update traderInfo set lockManID = '' where traderID = @traderID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ���ó��˾�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�����ó��˾['+ @traderID +']�ı༭����')
GO

drop PROCEDURE updateTraderInfo
/*
	name:		updateTraderInfo
	function:	5.������ó��˾
	input: 
				@traderID varchar(12),		--��������ó��˾���
				@traderName nvarchar(30),		--��ó��˾����
				@abbTraderName nvarchar(6),		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
				@inputCode varchar(5),			--����������
				@registeredCapital money,		--ע���ʱ�
				@legal nvarchar(30),			--����
				@tel varchar(30),				--��˾��ϵ�绰
				@tAddress nvarchar(100),		--��˾��ַ
				
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ������ó��˾�����ڣ�2��Ҫ���µ���ó��˾��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: modi by lw 2012-4-27���Ӽ��
*/
create PROCEDURE updateTraderInfo
	@traderID varchar(12),		--��������ó��˾���
	@traderName nvarchar(30),		--��ó��˾����
	@abbTraderName nvarchar(6),		--��ó��˾���	add by lw 2012-4-27���ݿͻ�Ҫ������
	@inputCode varchar(5),			--����������
	@registeredCapital money,		--ע���ʱ�
	@legal nvarchar(30),			--����
	@tel varchar(30),				--��˾��ϵ�绰
	@tAddress nvarchar(100),		--��˾��ַ
	
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ������ó��˾�Ƿ����
	declare @count as int
	set @count=(select count(*) from traderInfo where traderID = @traderID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from traderInfo
	where traderID = @traderID
	--���༭����
	if (@thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update traderInfo
	set traderName = @traderName, abbTraderName = @abbTraderName,
		inputCode = @inputCode,
		registeredCapital = @registeredCapital,
		legal = @legal,
		tel = @tel,
		tAddress = @tAddress,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	where traderID = @traderID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '������ó��˾', '�û�' + @modiManName 
												+ '��������ó��˾['+ @traderID +']��')
GO

drop PROCEDURE updateTraderManger
/*
	name:		updateTraderManger
	function:	6.��ָ��Ա������Ϊ��ó��˾������
				ע��:�ø����˱�������Ա�����ж���!
	input: 
				@managerID varchar(18),			--������ID
				
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ������ó��˾�����ڣ�2��Ҫ���µ���ó��˾��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: modi by lw 2012-4-27�򻯽ӿ�
*/
create PROCEDURE updateTraderManger
	@managerID varchar(18),			--������ID
	
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @traderID varchar(12)	--��ó��˾���
	set @traderID = (select traderID from traderManInfo where manID=@managerID)
	--�ж�ָ������ó��˾�Ƿ����
	if (@traderID is null)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from traderInfo
	where traderID = @traderID
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

	set @updateTime = getdate()
	update traderInfo
	set managerID = @managerID,
		manager = m.manName,
		managerMobile = m.mobile,
		e_mail =  m.e_mail,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	from traderInfo s inner join traderManInfo m on s.traderID = m.traderID and m.manID = @managerID
	where s.traderID = @traderID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '������ó��˾������', '�û�' + @modiManName 
												+ '��������ó��˾['+ @traderID +']�ĸ����ˡ�')
GO
--���ԣ�
select * from traderInfo
select * from traderManInfo
declare @updateTime smalldatetime	--����ʱ��
declare @Ret		int				--�����ɹ���ʶ
exec dbo.updateTraderManger '201204190002', '2012041906', '00201314', @updateTime output, @Ret output
select @updateTime, @Ret


drop PROCEDURE delTraderInfo
/*
	name:		delTraderInfo
	function:	7.ɾ��ָ������ó��˾
	input: 
				@traderID char(12),			--��ó��˾���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ������ó��˾�����ڣ�2��Ҫɾ������ó��˾��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 

*/
create PROCEDURE delTraderInfo
	@traderID char(12),			--��ó��˾���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ó��˾���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫָ������ó��˾�Ƿ����
	declare @count as int
	set @count=(select count(*) from traderInfo where traderID = @traderID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderInfo 
	where traderID = @traderID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		--ɾ������Ա���ĵ�¼��Ϣ��
		delete sysUserInfo where userID in (select manID from traderManInfo where traderID = @traderID)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--ɾ����ó��˾��Ա����Ϣ��Ա������ɾ����
		delete traderInfo where traderID = @traderID
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
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����ó��˾', '�û�' + @delManName
												+ 'ɾ������ó��˾['+ @traderID +']��')

GO
--���ԣ�
select * from traderInfo
select * from traderManInfo
declare @Ret		int				--�����ɹ���ʶ
exec dbo.delTraderInfo '201204190003', '00201314', @Ret output
select @Ret




drop PROCEDURE addTraderManInfo
/*
	name:		addTraderManInfo
	function:	10.�����ó��˾Ա��������Ϣ
				ע�⣺�ô洢�����Զ�������¼
	input: 
				@traderID varchar(12),		--�������ó��˾���
				@pID varchar(18),			--���֤�ţ�Ҫ��Ψһ�Լ��
				@manName nvarchar(30),		--Ա������
				@inputCode varchar(5),		--����������
				@post nvarchar(30),			--ְ��
				@mobile varchar(30),		--��ϵ�ֻ���Ҫ��Ψһ�Լ��
				@tel varchar(30),			--�����绰
				@e_mail varchar(30),		--E_mail��ַ
				@hAddress nvarchar(100),	--��ͥ��ַ

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1:��Ա�������֤���Ѿ������˵Ǽǹ��� 2:��Ա�����ֻ��Ѿ������˵Ǽǹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
				@manID varchar(10) output	--������Ա��ID
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 

*/
create PROCEDURE addTraderManInfo
	@traderID varchar(12),	--�������ó��˾���
	@pID varchar(18),			--���֤�ţ�Ҫ��Ψһ�Լ��
	@manName nvarchar(30),		--Ա������
	@inputCode varchar(5),		--����������
	@post nvarchar(30),			--ְ��
	@mobile varchar(30),		--��ϵ�ֻ�
	@tel varchar(30),			--�����绰
	@e_mail varchar(30),		--E_mail��ַ
	@hAddress nvarchar(100),	--��ͥ��ַ

	@createManID varchar(10),	--�����˹���

	@Ret		int output,		--�����ɹ���ʶ
	@createTime smalldatetime output,--���ʱ��
	@manID varchar(10) output	--������Ա��ID
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������Ա����ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 13, 1, @curNumber output
	set @manID = @curNumber

	--������֤��Ψһ�ԣ����֤����ȷ����ǰ̨��֤��
	declare @iCount int
	if (@pID<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where pID = @pID)
		if (@iCount = 0)	--���������ó��˾Ա��
			set @iCount = (select count(*) from traderManInfo where pID = @pID)
		if (@iCount = 0)	--�������ѧУԱ��
			set @iCount = (select count(*) from userInfo where pID = @pID)
		if (@iCount = 0)	--�������������Ȩ�û�
			set @iCount = (select count(*) from sysUserInfo where pID = @pID)
		if (@iCount > 0)
		begin
			set @Ret = 1
			return
		end
	end
	
	--����ֻ���Ψһ�ԣ�
	if (@mobile<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
		if (@iCount = 0)	--���������ó��˾Ա��
			set @iCount = (select count(*) from supplierManInfo where mobile = @mobile)
		if (@iCount = 0)	--�������ѧУԱ��
			set @iCount = (select count(*) from userInfo where mobileNum = @mobile)
		if (@iCount = 0)	--�������������Ȩ�û�
			set @iCount = (select count(*) from sysUserInfo where mobile = @mobile)
		if (@iCount > 0)
		begin
			set @Ret = 2
			return
		end
	end
		
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	--�Ǽ�Ա����
	insert traderManInfo(traderID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress)
	values(@traderID, @manID, @pID, @manName, @inputCode, @post, @mobile, @tel, @e_mail, @hAddress)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�����ó��˾Ա��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ���������ó��˾Ա��[' + @manName + '('+@manID+')]��')
GO

--���ԣ�
declare @manID varchar(10)	--������Ա��ID
declare @Ret int, @createTime smalldatetime
exec dbo.addTraderManInfo '201204190001', '420111197009014113', '¬έ', 'LW', '�ܲ�', '18602702392', '027-87889011', 'lw_bk@163.com','���ô��¸绪'	,
	'00201314', @Ret output, @createTime output, @manID output
select @Ret, @createTime, @manID

select * from traderInfo 
select * from traderManInfo

drop PROCEDURE queryTraderManInfoLocMan
/*
	name:		queryTraderManInfoLocMan
	function:	12.��ѯָ����ó��˾Ա���Ƿ��������ڱ༭
	input: 
				@manID varchar(10),			--Ա��ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����Ա��������
				@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE queryTraderManInfoLocMan
	@manID varchar(10),			--Ա��ID
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from traderManInfo where manID = @manID),'')
	set @Ret = 0
GO


drop PROCEDURE lockTraderManInfo4Edit
/*
	name:		lockTraderManInfo4Edit
	function:	13.������ó��˾Ա���༭������༭��ͻ
	input: 
				@manID varchar(10),			--Ա��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ó��˾Ա�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������Ա�������ڣ�2:Ҫ������Ա�����ڱ����˱༭
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE lockTraderManInfo4Edit
	@manID varchar(10),			--Ա��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ó��˾Ա�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ��������ó��˾Ա���Ƿ����
	declare @count as int
	set @count=(select count(*) from traderManInfo where manID = @manID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update traderManInfo 
	set lockManID = @lockManID 
	where manID = @manID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����Ա���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ����������ó��˾Ա��['+ @manID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockTraderManInfoEditor
/*
	name:		unlockTraderManInfoEditor
	function:	14.�ͷ���ó��˾Ա���༭��
				ע�⣺�����̲������ó��˾Ա���Ƿ���ڣ�
	input: 
				@manID varchar(10),				--Ա��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE unlockTraderManInfoEditor
	@manID varchar(10),				--Ա��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update traderManInfo set lockManID = '' where manID = @manID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�Ա���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�����ó��˾Ա��['+ @manID +']�ı༭����')
GO

drop PROCEDURE updateTraderManInfo
/*
	name:		updateTraderManInfo
	function:	15.������ó��˾Ա��������Ϣ
	input: 
				@manID varchar(10),			--Ա��ID
				@pID varchar(18),			--���֤�ţ�Ҫ��Ψһ�Լ��
				@manName nvarchar(30),		--Ա������
				@inputCode varchar(5),		--����������
				@post nvarchar(30),			--ְ��
				@mobile varchar(30),		--��ϵ�ֻ���Ҫ��Ψһ�Լ��
				@tel varchar(30),			--�����绰
				@e_mail varchar(30),		--E_mail��ַ
				@hAddress nvarchar(100),	--��ͥ��ַ
				
				@modiManID varchar(10) output,	--ά���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ա�������ڣ�2��Ҫ���µ�Ա����������������
							3:��Ա�������֤���Ѿ������˵Ǽǹ��� 4:��Ա�����ֻ��Ѿ������˵Ǽǹ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 
*/
create PROCEDURE updateTraderManInfo
	@manID varchar(10),			--Ա��ID
	@pID varchar(18),			--���֤�ţ�Ҫ��Ψһ�Լ��
	@manName nvarchar(30),		--Ա������
	@inputCode varchar(5),		--����������
	@post nvarchar(30),			--ְ��
	@mobile varchar(30),		--��ϵ�ֻ���Ҫ��Ψһ�Լ��
	@tel varchar(30),			--�����绰
	@e_mail varchar(30),		--E_mail��ַ
	@hAddress nvarchar(100),	--��ͥ��ַ
	
	@modiManID varchar(10) output,	--ά���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ��������ó��˾Ա���Ƿ����
	declare @count as int
	set @count=(select count(*) from traderManInfo where manID = @manID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--������֤��Ψһ�ԣ����֤����ȷ����ǰ̨��֤��
	declare @iCount int
	if (@pID<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where pID = @pID and manID <> @manID)
		if (@iCount = 0)	--������鹩����λԱ��
			set @iCount = (select count(*) from supplierManInfo where pID = @pID)
		if (@iCount = 0)	--�������ѧУԱ��
			set @iCount = (select count(*) from userInfo where pID = @pID)
		if (@iCount = 0)	--�������������Ȩ�û�
			set @iCount = (select count(*) from sysUserInfo where pID = @pID and userID <> @manID)
		if (@iCount > 0)
		begin
			set @Ret = 3
			return
		end
	end

	--����ֻ���Ψһ�ԣ�
	if (@mobile<>'')
	begin
		set @iCount = (select count(*) from traderManInfo where mobile = @mobile and manID <> @manID)
		if (@iCount = 0)	--������鹩����λԱ��
			set @iCount = (select count(*) from supplierManInfo where mobile = @mobile)
		if (@iCount = 0)	--�������ѧУԱ��
			set @iCount = (select count(*) from userInfo where mobileNum = @mobile)
		if (@iCount = 0)	--�������������Ȩ�û�
			set @iCount = (select count(*) from sysUserInfo where mobile = @mobile and userID <> @manID)
		if (@iCount > 0)
		begin
			set @Ret = 4
			return
		end
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		update traderManInfo
		set pID = @pID,
			manName = @manName,
			inputCode = @inputCode,
			post = @post,
			mobile = @mobile,
			tel = @tel,
			e_mail = @e_mail,
			hAddress = @hAddress,
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
		where manID = @manID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		--����Ա���Ƿ��Ѿ��Ǽǵ�¼��Ϣ������Ǽ�������Ӧ�޸ģ�
		set @count = (select count(*) from sysUserInfo where userID = @manID)
		if (@count > 0)
		begin
			update sysUserInfo
			set pID = @pID,
				mobile = @mobile,
				cName = @manName
			where userID = @manID
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
	values(@modiManID, @modiManName, @updateTime, '����Ա��������Ϣ', '�û�' + @modiManName 
												+ '��������ó��˾Ա��['+ @manID +']�Ļ�����Ϣ��')
GO

drop PROCEDURE delTraderManInfo
/*
	name:		delTraderManInfo
	function:	17.ɾ��ָ������ó��˾Ա��
	input: 
				@manID varchar(10),				--Ա��ID
				@delManID varchar(10) output,	--ɾ���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ա�������ڣ�2��Ҫɾ����Ա����������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-19
	UpdateDate: 

*/
create PROCEDURE delTraderManInfo
	@manID varchar(10),				--Ա��ID
	@delManID varchar(10) output,	--ɾ���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ��������ó��˾Ա���Ƿ����
	declare @count as int
	set @count=(select count(*) from traderManInfo where manID = @manID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from traderManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete traderManInfo where manID = @manID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
		
		--ɾ����¼��Ϣ������ɾ���û���ɫ
		delete sysUserInfo where userID = @manID
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
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��Ա��', '�û�' + @delManName
												+ 'ɾ������ó��˾Ա��['+ @manID +']��')
GO
--���ԣ�
select * from traderInfo
select * from traderManInfo
select * from sysUserInfo
declare @Ret		int				--�����ɹ���ʶ
exec dbo.delTraderManInfo 'W0000003', '00201314', @Ret output
select @Ret


select * from traderInfo


select * from sysUserInfo where userID = 'W0000009'