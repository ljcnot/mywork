use fTradeDB
/*
	�����ó������λ������Ϣϵͳ--������λ����
	author:		¬έ
	CreateDate:	2012-3-28
	UpdateDate: 
*/
--1.������λ��
select supplierID,supplierName,managerID,manager,managerMobile,tel,sAddress from supplierInfo
delete supplierInfo
drop TABLE supplierInfo
CREATE TABLE supplierInfo
(
	--������λ��
	supplierID varchar(12) not null,	--������������λ���
	supplierName nvarchar(30) null,		--������λ����
	abbSupplierName nvarchar(6) null,	--������λ���
	inputCode varchar(5) null,			--����������
	registeredCapital money default(0),	--ע���ʱ�
	legal nvarchar(30) null,			--����
	managerID varchar(18) null,			--������ID
	manager nvarchar(30) null,			--�������������������
	managerMobile varchar(30) null,		--��������ϵ�ֻ����������
	e_mail varchar(30) null,			--E_mail��ַ���������
	tel varchar(30) null,				--��˾��ϵ�绰
	sAddress nvarchar(100) null,		--��˾��ַ
	
	--����ά�����:
	buildDate smalldatetime default(getdate()),	--��������
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

 CONSTRAINT [PK_supplierInfo] PRIMARY KEY CLUSTERED 
(
	[supplierID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_supplierInfo] ON [dbo].[supplierInfo] 
(
	[supplierName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_supplierInfo_1] ON [dbo].[supplierInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�������ݣ�
insert supplierInfo(supplierID, supplierName, inputCode, managerID, manager, managerMobile, tel, sAddress)
values('0001','Sony ȫ��','SONY','0001','¬έ','18602702392','0012345','��������')

--2.������λԱ����(�����¼ϵͳ����Ա)
drop TABLE supplierManInfo
CREATE TABLE supplierManInfo
(
	supplierID varchar(12) not null,	--�����������λ���
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

 CONSTRAINT [PK_supplierManInfo] PRIMARY KEY CLUSTERED 
(
	[manID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[supplierManInfo] WITH CHECK ADD CONSTRAINT [FK_supplierManInfo_supplierInfo] FOREIGN KEY([supplierID])
REFERENCES [dbo].[supplierInfo] ([supplierID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[supplierManInfo] CHECK CONSTRAINT [FK_supplierManInfo_supplierInfo] 
GO

--������
CREATE NONCLUSTERED INDEX [IX_supplierManInfo] ON [dbo].[supplierManInfo] 
(
	[manName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_supplierManInfo_1] ON [dbo].[supplierManInfo] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


insert supplierInfo(supplierID, supplierName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, sAddress,
	buildDate, modiManID, modiManName, modiTime)
select supplierID, supplierName, inputCode, registeredCapital, legal,
	managerID, manager, managerMobile, e_mail, tel, sAddress,
	buildDate, modiManID, modiManName, modiTime 
from fTradeDB0.dbo.supplierInfo
select * from supplierInfo
	
insert supplierManInfo(supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime)
select supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
	buildDate, modiManID, modiManName, modiTime
from fTradeDB0.dbo.supplierManInfo

select * from supplierManInfo
delete supplierInfo

insert supplierManInfo(supplierID, manID, manName, inputCode, post, mobile, tel, hAddress)
values('0001','0001','¬έ','LW','�ܾ���','18602702392','','')


drop PROCEDURE addSupplierInfo
/*
	name:		addSupplierInfo
	function:	1.��ӹ�����λ
				ע�⣺�ô洢�����Զ�������¼
	input: 
				@supplierName nvarchar(30),		--������λ����
				@inputCode varchar(5),			--����������
				@registeredCapital money,		--ע���ʱ�
				@legal nvarchar(30),			--����
				@manager nvarchar(30),			--������
				@managerMobile varchar(30),		--��������ϵ�ֻ������Ψһ��
				@e_mail varchar(30),			--E_mail��ַ
				@tel varchar(30),				--��˾��ϵ�绰
				@sAddress nvarchar(100),		--��˾��ַ

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1:�ø����˵��ֻ��Ѿ������˵Ǽǹ�,9:δ֪����
				@createTime smalldatetime output--���ʱ��
				@supplierID varchar(12) output	--������������λ���
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-4-19�����ֻ�Ψһ�Լ��

*/
create PROCEDURE addSupplierInfo
	@supplierName nvarchar(30),		--������λ����
	@inputCode varchar(5),			--����������
	@registeredCapital money,		--ע���ʱ�
	@legal nvarchar(30),			--����
	@manager nvarchar(30),			--������
	@managerMobile varchar(30),		--��������ϵ�ֻ������Ψһ��
	@e_mail varchar(30),			--E_mail��ַ
	@tel varchar(30),				--��˾��ϵ�绰
	@sAddress nvarchar(100),		--��˾��ַ

	@createManID varchar(10),		--�����˹���

	@Ret		int output,			--�����ɹ���ʶ
	@createTime smalldatetime output,--���ʱ��
	@supplierID varchar(12) output	--������������λ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������������λ��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10, 1, @curNumber output
	set @supplierID = @curNumber
	--ʹ�ú��뷢��������Ա����ţ�
	declare @managerID varchar(18)			--������ID
	exec dbo.getClassNumber 11, 1, @curNumber output
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
		insert supplierInfo(supplierID, supplierName, inputCode, registeredCapital, legal, managerID, manager, managerMobile, e_mail, tel, sAddress,
				lockManID, modiManID, modiManName, modiTime) 
		values (@supplierID, @supplierName, @inputCode, @registeredCapital, @legal, @managerID, @manager, @managerMobile, @e_mail, @tel, @sAddress,
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
		insert supplierManInfo(supplierID, manID, manName, inputCode, post, mobile, tel, e_mail, hAddress)
		values(@supplierID, @managerID, @manager, @managerInputCode, '�ܾ���', @managerMobile, @tel, @e_mail, '')
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		--�Ǽ�ϵͳ�û���
		insert sysUserInfo(userType, userID, pID, mobile, cName, unitName, sysUserName)
		values(2, @managerID, '', @managerMobile, @manager, @supplierName, '')
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
	values(@createManID, @createManName, @createTime, '��ӹ�����λ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˹�����λ[' + @supplierName + '('+@supplierID+')]��')
GO
--���ԣ�
declare @Ret int, @createTime smalldatetime, @supplierID varchar(12)
exec dbo.addSupplierInfo '�������û�����˾', 'GJSYS', 'luwei', '18602702392', 'lw_bk@163.com', '02781693105','��������'	,
	'00201314', @Ret output, @createTime output, @supplierID output
select @Ret, @createTime, @supplierID

select * from supplierInfo 
select * from supplierManInfo


drop PROCEDURE fastAddSupplierInfo
/*
	name:		fastAddSupplierInfo
	function:	1.1.������ӹ�����λ��ֻ������ƣ�
				ע�⣺�ô洢���̲�������¼
	input: 
				@supplierName nvarchar(30),		--������λ����

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1:�����ƵĹ�����λ�Ѿ��Ǽǹ���,9:δ֪����
				@createTime smalldatetime output--���ʱ��
				@supplierID varchar(12) output	--������������λ���
	author:		¬έ
	CreateDate:	2012-4-27
	UpdateDate: modi by lw 2012-4-19�����ֻ�Ψһ�Լ��

*/
create PROCEDURE fastAddSupplierInfo
	@supplierName nvarchar(30),		--������λ����

	@createManID varchar(10),		--�����˹���

	@Ret		int output,			--�����ɹ���ʶ
	@createTime smalldatetime output,--���ʱ��
	@supplierID varchar(12) output	--������������λ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������������λ��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10, 1, @curNumber output
	set @supplierID = @curNumber

	set @supplierName = RTRIM(LTRIM(@supplierName))
	--������Ƶ�Ψһ�ԣ�
	declare @iCount int
	set @iCount = (select count(*) from supplierInfo where supplierName = @supplierName)
	if (@iCount>0)
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert supplierInfo(supplierID, supplierName, inputCode, 
						lockManID, modiManID, modiManName, modiTime) 
	values (@supplierID, @supplierName, dbo.getChinaPYCode(@supplierName),
			'', @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		rollback tran
		set @Ret = 9
		return
	end  
		  

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�ټӹ�����λ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ���������˹�����λ[' + @supplierName + '('+@supplierID+')]��')
GO


drop PROCEDURE querySupplierInfoLocMan
/*
	name:		querySupplierInfoLocMan
	function:	2.��ѯָ��������λ�Ƿ��������ڱ༭
	input: 
				@supplierID varchar(12),	--������λ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ĺ�����λ������
				@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE querySupplierInfoLocMan
	@supplierID varchar(12),	--������λ���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from supplierInfo where supplierID = @supplierID),'')
	set @Ret = 0
GO


drop PROCEDURE lockSupplierInfo4Edit
/*
	name:		lockSupplierInfo4Edit
	function:	3.����������λ�༭������༭��ͻ
	input: 
				@supplierID varchar(12),	--������λ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ�����λ�����ڣ�2:Ҫ�����Ĺ�����λ���ڱ����˱༭
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE lockSupplierInfo4Edit
	@supplierID varchar(12),	--������λ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ�����λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from supplierInfo where supplierID = @supplierID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierInfo 
	where supplierID = @supplierID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update supplierInfo 
	set lockManID = @lockManID 
	where supplierID = @supplierID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����������λ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˹�����λ['+ @supplierID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockSupplierInfoEditor
/*
	name:		unlockSupplierInfoEditor
	function:	4.�ͷŹ�����λ�༭��
				ע�⣺�����̲���鹩����λ�Ƿ���ڣ�
	input: 
				@supplierID varchar(12),	--������λ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE unlockSupplierInfoEditor
	@supplierID varchar(12),	--������λ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from supplierInfo where supplierID = @supplierID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update supplierInfo set lockManID = '' where supplierID = @supplierID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŹ�����λ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˹�����λ['+ @supplierID +']�ı༭����')
GO

select * from supplierInfo
drop PROCEDURE updateSupplierInfo
/*
	name:		updateSupplierInfo
	function:	5.���¹�����λ
	input: 
				@supplierID varchar(12),		--������������λ���
				@supplierName nvarchar(30),		--������λ����
				@inputCode varchar(5),			--����������
				@registeredCapital money,		--ע���ʱ�
				@legal nvarchar(30),			--����
				@tel varchar(30),				--��˾��ϵ�绰
				@sAddress nvarchar(100),		--��˾��ַ
				
				@modiManID varchar(10) output,	--ά���ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����λ�����ڣ�2��Ҫ���µĹ�����λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE updateSupplierInfo
	@supplierID varchar(12),		--������������λ���
	@supplierName nvarchar(30),		--������λ����
	@inputCode varchar(5),			--����������
	@registeredCapital money,		--ע���ʱ�
	@legal nvarchar(30),			--����
	@tel varchar(30),				--��˾��ϵ�绰
	@sAddress nvarchar(100),		--��˾��ַ
	
	@modiManID varchar(10) output,	--ά���ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���Ĺ�����λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from supplierInfo where supplierID = @supplierID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from supplierInfo
	where supplierID = @supplierID
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
	update supplierInfo
	set supplierName = @supplierName, 
		inputCode = @inputCode,
		registeredCapital = @registeredCapital,
		legal = @legal,
		tel = @tel,
		sAddress = @sAddress,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	where supplierID = @supplierID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���¹�����λ', '�û�' + @modiManName 
												+ '�����˹�����λ['+ @supplierID +']��')
GO

drop PROCEDURE updateSupplierManger
/*
	name:		updateSupplierManger
	function:	6.��ָ��Ա������Ϊ������λ������
				ע��:�ø����˱�������Ա�����ж���!
	input: 
				@managerID varchar(18),			--������ID
				
				@modiManID varchar(10) output,	--ά���ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����λ�����ڣ�2��Ҫ���µĹ�����λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-4-27�򻯽ӿ�
*/
create PROCEDURE updateSupplierManger
	@managerID varchar(18),			--������ID
	
	@modiManID varchar(10) output,	--ά���ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @supplierID varchar(12)		--������λ���
	set @supplierID = (select supplierID from supplierManInfo where manID=@managerID)
	--�ж�ָ���Ĺ�����λ�Ƿ����
	if (@supplierID is null)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from supplierInfo
	where supplierID = @supplierID
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
	update supplierInfo
	set managerID = @managerID,
		manager = m.manName,
		managerMobile = m.mobile,
		e_mail =  m.e_mail,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	from supplierInfo s inner join supplierManInfo m on s.supplierID = m.supplierID and m.manID = @managerID
	where s.supplierID = @supplierID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���¹�����λ������', '�û�' + @modiManName 
												+ '�����˹�����λ['+ @supplierID +']�ĸ����ˡ�')
GO
--���ԣ�
select * from supplierInfo
select * from supplierManInfo
declare @updateTime smalldatetime	--����ʱ��
declare @Ret		int				--�����ɹ���ʶ
exec dbo.updateSupplierManger '2012041906', '00201314', @updateTime output, @Ret output
select @updateTime, @Ret


drop PROCEDURE delSupplierInfo
/*
	name:		delSupplierInfo
	function:	7.ɾ��ָ���Ĺ�����λ
	input: 
				@supplierID char(12),			--������λ���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ�����λ�����ڣ�2��Ҫɾ���Ĺ�����λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-4-19 ����ɾ������Ա���ĵ�¼��Ϣ

*/
create PROCEDURE delSupplierInfo
	@supplierID char(12),			--������λ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ������λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫָ���Ĺ�����λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from supplierInfo where supplierID = @supplierID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierInfo 
	where supplierID = @supplierID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		--ɾ������Ա���ĵ�¼��Ϣ��
		delete sysUserInfo where userID in (select manID from supplierManInfo where supplierID = @supplierID)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		--ɾ��������λ��Ա����Ϣ��Ա������ɾ����
		delete supplierInfo where supplierID = @supplierID
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
	values(@delManID, @delManName, getdate(), 'ɾ��������λ', '�û�' + @delManName
												+ 'ɾ���˹�����λ['+ @supplierID +']��')

GO
--���ԣ�
select * from supplierInfo
select * from supplierManInfo
declare @Ret		int				--�����ɹ���ʶ
exec dbo.delSupplierInfo '201204190001', '00201314', @Ret output
select @Ret




drop PROCEDURE addSupplierManInfo
/*
	name:		addSupplierManInfo
	function:	10.��ӹ�����λԱ��������Ϣ
				ע�⣺�ô洢�����Զ�������¼
	input: 
				@supplierID varchar(12),	--�����������λ���
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
	CreateDate:	2012-4-18
	UpdateDate: 

*/
create PROCEDURE addSupplierManInfo
	@supplierID varchar(12),	--�����������λ���
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
	exec dbo.getClassNumber 11, 1, @curNumber output
	set @manID = @curNumber

	--������֤��Ψһ�ԣ����֤����ȷ����ǰ̨��֤��
	declare @iCount int
	if (@pID <> '')
	begin
		set @iCount = (select count(*) from supplierManInfo where pID = @pID)
		if (@iCount = 0)	--������鹩����λԱ��
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
	if (@mobile <> '')
	begin
		set @iCount = (select count(*) from supplierManInfo where mobile = @mobile)
		if (@iCount = 0)	--���������ó��˾Ա��
			set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
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
	insert supplierManInfo(supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress,
			lockManID, modiManID, modiManName, modiTime) 
		values(@supplierID, @manID, @pID, @manName, @inputCode, @post, @mobile, @tel, @e_mail, @hAddress,
				@createManID, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӹ�����λԱ��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˹�����λԱ��[' + @manName + '('+@manID+')]��')
GO

select * from supplierManInfo
--���ԣ�
declare @manID varchar(10)	--������Ա��ID
declare @Ret int, @createTime smalldatetime
exec dbo.addSupplierManInfo '201204220012', '420111197009014113', '¬έ', 'LW', '�ܲ�', '18602702381', '027-87889011', 'lw_bk@163.com','���ô��¸绪'	,
	'00201314', @Ret output, @createTime output, @manID output
select @Ret, @createTime, @manID

select * from supplierInfo 
select * from supplierManInfo

drop PROCEDURE fastAddSupplierManInfo
/*

	name:		fastAddSupplierManInfo
	function:	10.1.������ӹ�����λԱ��
				ע�⣺�ô洢���̲�������¼
	input: 
				@supplierID varchar(12),	--�����������λ���
				@manName nvarchar(30),		--Ա������

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1:��Ա���������Ѿ��Ǽǹ���9:δ֪����
				@createTime smalldatetime output--���ʱ��
				@manID varchar(10) output	--������Ա��ID
	author:		¬έ
	CreateDate:	2012-4-27
	UpdateDate: 

*/
create PROCEDURE fastAddSupplierManInfo
	@supplierID varchar(12),	--�����������λ���
	@manName nvarchar(30),		--Ա������

	@createManID varchar(10),	--�����˹���

	@Ret		int output,		--�����ɹ���ʶ
	@createTime smalldatetime output,--���ʱ��
	@manID varchar(10) output	--������Ա��ID
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������Ա����ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 11, 1, @curNumber output
	set @manID = @curNumber

	--���������Ψһ��
	set @manName = LTRIM(RTRIM(@manName))
	declare @iCount int
	set @iCount =(select count(*) from supplierManInfo where manName = @manName and supplierID = @supplierID)
	if (@iCount > 0)
	begin
		set @Ret = 1
		return
	end
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	--�Ǽ�Ա����
	insert supplierManInfo(supplierID, manID, manName, inputCode)
	values(@supplierID, @manID, @manName, dbo.getChinaPYCode(@manName))
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�ټӹ�����λԱ��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ���������˹�����λԱ��[' + @manName + '('+@manID+')]��')
GO
--���ԣ�
declare @Ret		int		--�����ɹ���ʶ
declare @createTime smalldatetime	--���ʱ��
declare @manID varchar(10)	--������Ա��ID
exec dbo.fastAddSupplierManInfo '201205150009','���Կ��ٱ���Ա��','00011275',@Ret output, @createTime output, @manID output
select @Ret, @createTime, @manID



drop PROCEDURE querySupplierManInfoLocMan
/*
	name:		querySupplierManInfoLocMan
	function:	12.��ѯָ��������λԱ���Ƿ��������ڱ༭
	input: 
				@manID varchar(10),			--Ա��ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����Ա��������
				@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE querySupplierManInfoLocMan
	@manID varchar(10),			--Ա��ID
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from supplierManInfo where manID = @manID),'')
	set @Ret = 0
GO


drop PROCEDURE lockSupplierManInfo4Edit
/*
	name:		lockSupplierManInfo4Edit
	function:	13.����������λԱ���༭������༭��ͻ
	input: 
				@manID varchar(10),			--Ա��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ������λԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������Ա�������ڣ�2:Ҫ������Ա�����ڱ����˱༭
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE lockSupplierManInfo4Edit
	@manID varchar(10),			--Ա��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰ������λԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ�����λԱ���Ƿ����
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update supplierManInfo 
	set lockManID = @lockManID 
	where manID = @manID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����Ա���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˹�����λԱ��['+ @manID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockSupplierManInfoEditor
/*
	name:		unlockSupplierManInfoEditor
	function:	14.�ͷŹ�����λԱ���༭��
				ע�⣺�����̲���鹩����λԱ���Ƿ���ڣ�
	input: 
				@manID varchar(10),				--Ա��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE unlockSupplierManInfoEditor
	@manID varchar(10),				--Ա��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update supplierManInfo set lockManID = '' where manID = @manID
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
												+ '��Ҫ���ͷ��˹�����λԱ��['+ @manID +']�ı༭����')
GO

drop PROCEDURE updateSupplierManInfo
/*
	name:		updateSupplierManInfo
	function:	15.���¹�����λԱ��������Ϣ
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
	CreateDate:	2012-4-18
	UpdateDate: 
*/
create PROCEDURE updateSupplierManInfo
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
	--�ж�Ҫ�����Ĺ�����λԱ���Ƿ����
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
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
		set @iCount = (select count(*) from supplierManInfo where pID = @pID and manID <> @manID)
		if (@iCount = 0)	--���������ó��˾Ա��
			set @iCount = (select count(*) from traderManInfo where pID = @pID)
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
		set @iCount = (select count(*) from supplierManInfo where mobile = @mobile and manID <> @manID)
		if (@iCount = 0)	--���������ó��˾Ա��
			set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
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
		update supplierManInfo
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
												+ '�����˹�����λԱ��['+ @manID +']�Ļ�����Ϣ��')
GO

drop PROCEDURE updateSupplierManMobile
/*
	name:		updateSupplierManMobile
	function:	15.1.���¹�����λԱ���ֻ�����
	input: 
				@manID varchar(10),			--Ա��ID
				@mobile varchar(30),		--��ϵ�ֻ���Ҫ��Ψһ�Լ��
				
				@modiManID varchar(10) output,	--ά���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ա�������ڣ�2��Ҫ���µ�Ա����������������
							4:��Ա�����ֻ��Ѿ������˵Ǽǹ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-27
	UpdateDate: 
*/
create PROCEDURE updateSupplierManMobile
	@manID varchar(10),			--Ա��ID
	@mobile varchar(30),		--��ϵ�ֻ���Ҫ��Ψһ�Լ��
	
	@modiManID varchar(10) output,	--ά���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ�����λԱ���Ƿ����
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--����ֻ���Ψһ�ԣ�
	declare @iCount int
	set @iCount = (select count(*) from supplierManInfo where mobile = @mobile and manID <> @manID)
	if (@iCount = 0)	--���������ó��˾Ա��
		set @iCount = (select count(*) from traderManInfo where mobile = @mobile)
	if (@iCount = 0)	--�������ѧУԱ��
		set @iCount = (select count(*) from userInfo where mobileNum = @mobile)
	if (@iCount = 0)	--�������������Ȩ�û�
		set @iCount = (select count(*) from sysUserInfo where mobile = @mobile and userID <> @manID)
	if (@iCount > 0)
	begin
		set @Ret = 4
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update supplierManInfo
	set mobile = @mobile,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @updateTime
	where manID = @manID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����Ա���ֻ�', '�û�' + @modiManName 
												+ '�����˹�����λԱ��['+ @manID +']���ֻ����롣')
GO


drop PROCEDURE delSupplierManInfo
/*
	name:		delSupplierManInfo
	function:	17.ɾ��ָ���Ĺ�����λԱ��
	input: 
				@manID varchar(10),				--Ա��ID
				@delManID varchar(10) output,	--ɾ���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ա�������ڣ�2��Ҫɾ����Ա����������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: 

*/
create PROCEDURE delSupplierManInfo
	@manID varchar(10),				--Ա��ID
	@delManID varchar(10) output,	--ɾ���ˣ������ǰԱ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ĺ�����λԱ���Ƿ����
	declare @count as int
	set @count=(select count(*) from supplierManInfo where manID = @manID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from supplierManInfo 
	where manID = @manID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete supplierManInfo where manID = @manID
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
												+ 'ɾ���˹�����λԱ��['+ @manID +']��')
GO
--���ԣ�
select * from supplierInfo
select * from supplierManInfo
select * from sysUserInfo
declare @Ret		int				--�����ɹ���ʶ
exec dbo.delSupplierManInfo 'G0000003', '00201314', @Ret output
select @Ret


delete supplierManInfo 
where manID='G0000035'; 
select supplierID, manID, pID, manName, inputCode, post, mobile, tel, e_mail, hAddress 
from supplierManInfo 
where manID='G0000029'; 
select userType, userID, pID, mobile, e_mail, cName, unitName, sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer, isOff, setOffDate 
from sysUserInfo 
where userID='G0000034';
select * from sysUserInfo


select UNICODE('��')