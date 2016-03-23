use fTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-�����ֵ����ݿ����
	�����豸����ϵͳ�޸�
	author:		¬έ
	CreateDate:	2010-7-11
	UpdateDate: 
*/
truncate table codeDictionary
--1.�����ֵ�(codeDictionary)��
	--class = 0	�����ֵ����ͣ�

--1��ϵͳ���������
select * from codeDictionary where classCode = 1

--2���豸��״�룺
select * from codeDictionary where classCode = 2

--3�����ִ��룺
select * from codeDictionary where classCode = 3
select b.objCode, c.cCode, b.objDesc, c.cName 
from codeDictionary b left join country c on b.objCode=c.cCode 
where classCode = 3

--4�����ʽ��
select * from codeDictionary where classCode = 4

--5���������ͣ�ָ��Ҫɨ��鵵�ĺ�ͬ��Э��ԭ��
select * from codeDictionary where classCode = 5

--10��ʹ�õ�λ���ͣ�
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 10, 'ʹ�õ�λ����', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 1, '��ѧ')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 2, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 3, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 4, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 9, '����')

--98.ϵͳ���ݣ�ϵͳȨ�ޣ�ϵͳ��Դ�������ȴ��룺
select * from codeDictionary where classCode = 98

--99.ϵͳ���ݶ����������
select * from codeDictionary where classCode = 99

--100.��ɫ�ּ�����
select * from codeDictionary where classCode = 100

--101.ϵͳ�û����
select * from codeDictionary where classCode = 101




--10.�洢���̣�
--���Ҫ��Ӧ�ṩ�Ĺ��ܣ���
--1.��ѯȫ���������
--2.��ѯָ���Ĵ����е���Ŀ
--3.��ѯ��Ŀ��׼���������
--4.��ѯȫ���Ĵ����ֵ�
------------���Ϲ���ֱ��ʹ�ò�ѯ����ѯ��װ��һ����ѯ�������ڣ�����Ҫ����ȫ��֤��
------------���¹�����Ҫ����ȫ��֤��������ֱ��ʹ�����ݲ�����䣬Ҫ���ô洢���̣���װ��һ��ά����������
--10.��ѯָ�������Ƿ��������ڱ༭��ֻ��ѯ������ࣩ��queryCDLockMan
--11.���������ֵ�༭������༭��ͻ:lockCD4Edit
--12.�ͷŴ����ֵ�༭��:unlockCDEditor
--13.����һ�����ֻࣨ���ӷ����š��������ƣ�Ҫ������Ƿ����غţ�������Ŀ�ɸ߼����Ե����޸��޸�������ɣ�
--14.����һ����Ŀ��ֻ���ӷ����š���Ŀ��š���Ŀ������Ҫ������Ƿ����غţ�������Ŀ�ɸ߼����Ե����޸��޸�������ɣ�

--15.�޸�һ�����ࣨ�������ź�����ͼ����������ֶε��޸ģ�
--16.�޸�һ����Ŀ���������š���Ŀ��ź�����ͼ����������ֶε��޸ģ�
------------�޸�����ͼƬ��ʹ�ø߼�����������

--17.�޸�һ�������ţ�Ҫ���Զ�����Ƿ��ظ����룬������õı��������޸ģ�
--18.�޸�һ����Ŀ��ţ�Ҫ���Զ�����Ƿ��ظ����룬������õı��������޸ģ�

--19.ɾ��һ�����ࣨҪ���Զ�������õı���������÷��س�����Ϣ��
--20.ɾ��һ����Ŀ��Ҫ���Զ�������õı���������÷��س�����Ϣ��
--21.ǿ��ɾ��һ�����ࣨҪ���Զ�������õı���������÷�����������Ϣ�������ɾ����
--22.ǿ��ɾ��һ����Ŀ��Ҫ���Զ�������õı���������÷�����������Ϣ�������ɾ����

select * from codeDictionary
	--	�����ֵ��codeDictionary����
alter TABLE codeDictionary alter column lockManID varchar(10) null			--��ǰ���������༭�������ID
alter TABLE codeDictionary drop	column modiManType	--ά�������2->�̼ҹ���Ա��3->Ӫ���̹���Ա
alter TABLE codeDictionary alter column modiManID varchar(10)	--ά�������ID

drop table codeDictionary
CREATE TABLE codeDictionary (
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	classCode int NOT NULL ,	--�������
	objCode int NOT NULL ,		--���루��Ŀ���룩 �ƻ���modi by lw 2010-3-30 ��smallint ��Ϊ int
	objDesc varchar(100) COLLATE Chinese_PRC_CI_AS NULL ,	--��Ŀ����
	inputCode varchar(6) null,								--������
	objEngDesc varchar(100) NULL ,	--��ĿӢ������	
	objDetail varchar(500) NULL ,	--��Ŀ��ϸ����
	standardName varchar(100) COLLATE Chinese_PRC_CI_AS NULL ,	--���ñ�׼��
	GBDigiCode varchar(10) null,		--�������ִ���
	GBEngCode varchar(10) null,			--������ĸ����
	cdImage varchar(128) null,			--�����ֵ�ͼƬ·��

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�add by lw 2013-1-10
	--�����ͣ�þͱ�ʾֹͣ��������Ĵ����ֵ䣬��Ŀ��ͣ�ñ�ʾ������Ŀͣ�ã�
	isOff char(1) default('0') null,	--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,	--ά���˹���
	modiManName nvarchar(30) null,--ά��������
	modiTime smalldatetime null,--���ά��ʱ��
	--�༭�����ˣ�
	lockManID varchar(10),		--��ǰ���������༭���˹���
 CONSTRAINT [PK_codeDictionary] PRIMARY KEY CLUSTERED 
(
	[classCode] ASC,
	[objCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������������
CREATE NONCLUSTERED INDEX [IX_codeDictionary] ON [dbo].[codeDictionary] 
(
	[inputCode] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��ѯ�����ֵ�ı�Ŀ��
select * from codeDictionary where classCode = 0

--��ѯ��X�Ŵ����ֵ䣺
select * from codeDictionary where classCode = 1

drop PROCEDURE queryCDLockMan
/*
	name:		queryCDLockMan
	function:	1.��ѯָ�������Ƿ��������ڱ༭����ֻ����������ࣩ
	input: 
				@classCode int,			--�������
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ���������Ǹô����ֵ䲻����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˹���
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE queryCDLockMan
	@classCode	int,			--�������
	@Ret		int output,		--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˹���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = (select lockManID from codeDictionary where classCode = 0 and objCode = @classCode)
	set @Ret = 0
GO

drop PROCEDURE lockCD4Edit
/*
	name:		lockCD4Edit
	function:	2.���������ֵ�༭������༭��ͻ
	input: 
				@classCode	int,				--�������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĵ����ֵ䲻���ڣ�2:Ҫ�����Ĵ����ֵ����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE lockCD4Edit
	@classCode	int,		--�������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output	--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĵ����ֵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update codeDictionary 
	set lockManID = @lockManID 
	where classCode = 0 and objCode = @classCode
	set @Ret = 0
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	--ȡά���˵�������
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '���������ֵ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˴����ֵ�['+ ltrim(str(@classCode,6)) +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockCDEditor
/*
	name:		unlockCDEditor
	function:	3.�ͷŴ����ֵ�༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@classCode	int,				--�������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���2��δ֪����
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE unlockCDEditor
	@classCode	int,				--�������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update codeDictionary set lockManID = '' where classCode = 0 and objCode = @classCode
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
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷŴ����ֵ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˴����ֵ�['+ ltrim(str(@classCode,6)) +']�ı༭����')

GO


drop PROCEDURE addClass
/*
	name:		addClass
	function:	4.����һ�����ֻࣨ���ӷ����š��������ƣ�Ҫ������Ƿ����غţ�������Ŀ�ɸ߼����Ե����޸�������ɣ�
				ע�⣺����һ�������Ժ��Զ�������
	input: 
				@classCode	int,			--�������
				@className	nvarchar(100),	--��������
				@addManID varchar(10),		--�����
				
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���ӵ�����Ѿ���ռ�ã�9->δ֪����
				@createTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE addClass
	@classCode	int,			--�������
	@className	nvarchar(100),	--��������
	@addManID varchar(10),		--�����

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���Ψһ�ԣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @addManName varchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')
	
	set @createTime = getdate()
	insert codeDictionary(classCode, objCode, objDesc, modiManID, modiManName, modiTime, lockManID) 
	values ( 0, @classCode, @className, @addManID, @addManName, @createTime, @addManID)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @createTime, '��Ӵ����ֵ�', 'ϵͳ�����û�' + @addManName + 
							'��Ҫ������˴����ֵ�[' + ltrim(str(@classCode,6)) + ']��')
GO

drop PROCEDURE addObj
/*
	name:		5.addObj
	function:	����һ����Ŀ��ֻ���ӷ����š���Ŀ��š���Ŀ������Ҫ������Ƿ����غţ�������Ŀ�ɸ߼����Ե����޸�������ɣ�
	input: 
				@classCode int,				--�������
				@objCode int,				--��Ŀ����
				@objDesc nvarchar(100),		--��Ŀ����

				@addManID varchar(10) output,--����ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���ӵ���Ŀ�Ѿ���ռ�ã�2������Ŀ���ڵĴ����ֵ䲢�����ڣ�
							3:��������ֵ����ڱ����˱༭��9->δ֪����
				@createTime smalldatetime output--���ʱ��
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE addObj
	@classCode int,			--�������
	@objCode int,			--��Ŀ����
	@objDesc nvarchar(100),	--��Ŀ����

	@addManID varchar(10) output,--����ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���Ψһ�ԣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--�ж������Ĵ����Ƿ���ڣ�
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 2
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @addManID)
	begin
		set @addManID = @thisLockMan
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @addManName varchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')
	set @createTime = getdate()

	insert codeDictionary(classCode, objCode, objDesc, modiManID, modiManName, modiTime) 
	values (@classCode, @objCode, @objDesc, @addManID, @addManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @createTime, '��Ӵ����ֵ���Ŀ', 'ϵͳ�����û�' + @addManName + 
							'��Ҫ������˴����ֵ�[' + ltrim(str(@classCode,6)) 
							+ ']��һ����Ŀ['+ ltrim(str(@objCode ,6)) + ']��' + @objDesc +'��')
GO


drop PROCEDURE modiClass
/*
	name:		modiClass
	function:	6.�޸�һ�������ֵ����Ƶ����ԣ�����������������ֶε��޸ģ�
	input: 
				@classCode 	int,			--�������
				@className	nvarchar(100),	--��������
				@inputCode varchar(6),		--������
				@objEngDesc varchar(100) ,	--Ӣ������	
				@objDetail nvarchar(500),	--��ϸ����
				@standardName nvarchar(100),--���ñ�׼��
				@GBDigiCode varchar(10),	--�������ִ���
				@GBEngCode varchar(10),		--������ĸ����
				@cdImage varchar(128),		--�����ֵ�ͼƬ·��

				@modiManID varchar(10) output,		--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�޸ĵĴ����ֵ䲻���ڣ�2��Ҫ�޸ĵĴ����ֵ���������������9��δ֪����
				@modiTime smalldatetime output	--��������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE modiClass
	@classCode 	int,			--�������
	@className	nvarchar(100),	--��������
	@inputCode varchar(6),		--������
	@objEngDesc varchar(100) ,	--Ӣ������	
	@objDetail nvarchar(500),	--��ϸ����
	@standardName nvarchar(100),--���ñ�׼��
	@GBDigiCode varchar(10),	--�������ִ���
	@GBEngCode varchar(10),		--������ĸ����
	@cdImage varchar(128),		--�����ֵ�ͼƬ·��

	@modiManID varchar(10) output,		--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	@Ret	 int output,	
	@modiTime smalldatetime output	--��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName varchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @modiTime = getdate()
	update codeDictionary 
	set objDesc = @className, inputCode = @inputCode, 
		objEngDesc = @objEngDesc, objDetail = @objDetail,
		standardName = @standardName,
		GBDigiCode = @GBDigiCode, GBEngCode = @GBEngCode,
		 cdImage = @cdImage,
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where classCode = 0 and objCode = @classCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '���´����ֵ�', '�û�' + @modiManName 
												+ '�����˴����ֵ�['+ ltrim(str(@classCode,6)) +']����Ϣ��')
GO

drop PROCEDURE modiObj
/*
	name:		modiObj
	function:	7.�޸�һ����Ŀ���������š���Ŀ��ź�����ͼ����������ֶε��޸ģ�
	input: 
				@classCode int,				--�������
				@objCode int,				--��Ŀ����
				@objDesc nvarchar(100),		--��Ŀ����
				@inputCode varchar(6),		--������
				@objEngDesc varchar(100) ,	--��ĿӢ������	
				@objDetail nvarchar(500),	--��Ŀ��ϸ����
				@standardName nvarchar(100),--���ñ�׼��
				@GBDigiCode varchar(10),	--�������ִ���
				@GBEngCode varchar(10),		--������ĸ����
				@cdImage varchar(128),		--�����ֵ�ͼƬ·��

				@modiManID varchar(10) output,	--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1������Ŀ�����ڣ�2��Ҫ���µĴ����ֵ���������������9��δ֪����
				@modiTime smalldatetime output	--��������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE modiObj
	@classCode int,				--�������
	@objCode int,				--��Ŀ����
	@objDesc nvarchar(100),		--��Ŀ����
	@inputCode varchar(6),		--������
	@objEngDesc varchar(100) ,	--��ĿӢ������	
	@objDetail nvarchar(500),	--��Ŀ��ϸ����
	@standardName nvarchar(100),--���ñ�׼��
	@GBDigiCode varchar(10),	--�������ִ���
	@GBEngCode varchar(10),		--������ĸ����
	@cdImage varchar(128),		--�����ֵ�ͼƬ·��

	@modiManID varchar(10) output,--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���

	@Ret	 int output,	
	@modiTime smalldatetime output--��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName varchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @modiTime = getdate()
	update codeDictionary 
	set objDesc = @objDesc, inputCode = @inputCode, 
		 objEngDesc = @objEngDesc, objDetail = @objDetail,
		 standardName = @standardName,
		 GBDigiCode = @GBDigiCode, GBEngCode = @GBEngCode,
		 cdImage = @cdImage,
		 modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where classCode = @classCode and objCode = @objCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '���´����ֵ���Ŀ', '�û�' + @modiManName 
							+ '�����˴����ֵ�['+ ltrim(str(@classCode,6)) +']�е�['+ ltrim(str(@objCode,6)) +']��Ŀ����Ϣ��')
GO


drop PROCEDURE modiClassCode
/*
	name:		modiClassCode
	function:	8.�޸�һ������Ĵ���
				ע�⣺������̻�ͬ���޸�����ʹ�ù��������ı�����Ҫ������ȫ�������ñ����������ͻ��ع���
	input: 
				@oldClassCode int,	--�Ϸ������
				@newClassCode int,	--�·������
				@modiManID varchar(10) output,--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1���÷��಻���ڣ�2:Ҫ�޸ĵķ�����������ռ�ñ༭��
							3��Ŀ������Ѿ�������ʹ�ã�
							4�����޸����ô���ı��ʱ������ͻ��ϵͳ�ع����������ݣ�
							9��δ֪����
				@modiTime smalldatetime output	--��������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE modiClassCode
	@oldClassCode 	int,
	@newClassCode	int,

	@modiManID varchar(10) output,--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���

	@Ret	 int output,	
	@modiTime smalldatetime output	--��������
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--���Դ�����Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @oldClassCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @oldClassCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���Ŀ������ֵ��Ƿ�ռ��
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @newClassCode)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName varchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		--����������øô����ֵ�ı������������Ҫȫ���޸����õ����ݡ���Ҫ��ȫ�����ݿ����������ӣ�����
		
		update codeDictionary 
		set classCode = @newClassCode, modiManID = @modiManID, 
			modiManName = @modiManName, modiTime = @modiTime
		where classCode = @oldClassCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		update codeDictionary
		set objCode = @newClassCode, modiManID = @modiManID, 
			modiManName = @modiManName, modiTime = @modiTime
		where classCode = 0 and objCode = @oldClassCode
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
	values(@modiManID, @modiManName, @modiTime, '���ؾ���', '�û�' + @modiManName 
								+ '�������ֵ�['+ ltrim(str(@oldClassCode,6)) +']�Ĵ������Ϊ['+ ltrim(str(@newClassCode,6)) +']��'
								+ '\r\n�⽫��Ӱ�쵽�������øô����ֵ�����ݣ�')
GO

drop PROCEDURE modiObjCode
/*
	name:		modiObjCode
	function:	9.�޸�һ����Ŀ���
				ע�⣺������̻�ͬ���޸�����ʹ�ù��������ı�����Ҫ������ȫ�������ñ����������ͻ��ع���
	input: 
				@classCode int,		--�������
				@oldObjCode int,	--����Ŀ����
				@newObjCode int,	--����Ŀ����

				@modiManID varchar(10) output,--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1������Ŀ�����ڣ�2:Ҫ�޸ĵĴ����ֵ���������ռ�ñ༭��
							3��Ŀ����Ŀ����Ѿ���ռ�ã�4�����޸����ô���ı��ʱ������ͻ��ϵͳ�ع����������ݣ�
							9��δ֪����
				@modiTime smalldatetime output	--��������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE modiObjCode
	@classCode 	int,
	@oldObjCode int,
	@newObjCode int,

	@modiManID varchar(10) output,--ά���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���

	@Ret	 int output,	
	@modiTime smalldatetime output	--��������
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--����Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @oldObjCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end


	--�������Ŀ�����Ƿ�ռ��
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @newObjCode)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName varchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		--����������øô���ı������������Ҫȫ���޸����õ����ݡ���Ҫ��ȫ�����ݿ����������ӣ�����

		update codeDictionary
		set objCode = @newObjCode, 
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
		where classCode = @ClassCode and objCode = @oldObjCode
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
	values(@modiManID, @modiManName, @modiTime, '���ؾ���', '�û�' + @modiManName 
					+ '�������ֵ�['+ ltrim(str(@ClassCode,6)) +']�е�['+ ltrim(str(@oldObjCode,6)) 
					+']��Ŀ�Ĵ������Ϊ['+ ltrim(str(@newObjCode,6)) +']��'
					+ '\r\n�⽫��Ӱ�쵽�������øô����ֵ�����ݣ�')
GO


drop PROCEDURE setClassOff
/*
	name:		setClassOff
	function:	10.ͣ��ָ�������Ĵ����ֵ�
	input: 
				@classCode int,					--�������
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ķ��಻���ڣ�2��Ҫͣ�õķ�����������������3���÷��౾����ͣ��״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setClassOff
	@classCode int,					--�������
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode=@classCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10), @status char(1)
	select  @thisLockMan = isnull(lockManID,'') , @status = isOff
	from codeDictionary 
	where classCode = 0 and objCode=@classCode
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@status = '1')
	begin
		set @Ret = 3
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update codeDictionary
	set isOff = '1', offDate = @stopTime
	where classCode = 0 and objCode=@classCode
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ�ô����ֵ�', '�û�' + @stopManName
												+ 'ͣ���˵�[' + str(@classCode,8) + ']�Ŵ����ֵ䡣')
GO

drop PROCEDURE setClassActive
/*
	name:		setClassActive
	function:	11.����ָ���ķ���Ĵ����ֵ�
	input: 
				@classCode int,					--�������
				@activeManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ķ��಻���ڣ�2��Ҫ���õķ�����������������3���÷��౾���Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setClassActive
	@classCode int,					--�������
	@activeManID varchar(10) output,--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode=@classCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10), @status char(1)
	select  @thisLockMan = isnull(lockManID,'') , @status = isOff
	from codeDictionary 
	where classCode = 0 and objCode=@classCode
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update codeDictionary 
	set isOff = '0', offDate = null
	where classCode = 0 and objCode=@classCode
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '���ô����ֵ�', '�û�' + @activeManName
												+ '���������˵�[' + str(@classCode,8) + ']�Ŵ����ֵ䡣')
GO


drop PROCEDURE setItemOff
/*
	name:		setItemOff
	function:	12.ͣ�ô����ֵ��ָ����Ŀ
	input: 
				@classCode int,					--�������
				@objCode int,					--��Ŀ����
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ������Ŀ�����ڣ�2��Ҫͣ�õķ�����������������3������Ŀ������ͣ��״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setItemOff
	@classCode int,					--�������
	@objCode int,					--��Ŀ����
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ������Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode=@objCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	select  @thisLockMan = isnull(lockManID,'')
	from codeDictionary 
	where classCode = 0 and objCode=@classCode
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	declare @status char(1)
	select  @status = isOff from codeDictionary  where classCode = @classCode and objCode=@objCode
	if (@status = '1')
	begin
		set @Ret = 3
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update codeDictionary
	set isOff = '1', offDate = @stopTime
	where classCode = @classCode and objCode=@objCode
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ�ô����ֵ�', '�û�' + @stopManName
												+ 'ͣ���˵�[' + str(@classCode,8) + ']�Ŵ����ֵ�ĵ�['+STR(@objCode,8)+']����')
GO

drop PROCEDURE setItemActive
/*
	name:		setItemActive
	function:	13.����ָ������Ĵ����ֵ���Ŀ
	input: 
				@classCode int,					--�������
				@objCode int,					--��Ŀ����
				@activeManID varchar(10) output,--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ������Ŀ�����ڣ�2��Ҫ���õ���Ŀ��������������3������Ŀ�����Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setItemActive
	@classCode int,					--�������
	@objCode int,					--��Ŀ����
	@activeManID varchar(10) output,--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ������Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode=@objCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	select  @thisLockMan = isnull(lockManID,'')
	from codeDictionary 
	where classCode = 0 and objCode=@classCode
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	declare @status char(1)
	select  @status = isOff from codeDictionary  where classCode = @classCode and objCode=@objCode
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update codeDictionary 
	set isOff = '0', offDate = null
	where classCode = @classCode and objCode=@objCode
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '���ô����ֵ�', '�û�' + @activeManName
												+ '���������˵�[' + str(@classCode,8) + ']�Ŵ����ֵ�ĵ�['+STR(@objCode,8)+']����Ŀ��')
GO



drop PROCEDURE delClass
/*
	name:		delClass
	function:	14.ɾ��һ�����ࣨҪ���Զ�������õı���������÷��س�����Ϣ��
	input: 
				@classCode int,			--�������

				@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1���ô����ֵ䲻���ڣ�2��Ҫɾ���Ĵ����ֵ���������������3���ô����ֵ��Ѿ������ã�9��δ֪����
				@delTime smalldatetime output	--ɾ������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE delClass
	@classCode 	int,

	@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	@Ret	 int output,	
	@delTime smalldatetime output	--ɾ������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�������Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--�������Ŀ�����Ƿ����ã���Ҫ��ȫ�����ݿ����������ӣ�����
	--��������ã�����3�ų������
	--set @Ret = 3

	set @delTime = getdate()
	begin tran
		--ɾ��ȫ����Ŀ
		delete codeDictionary 
		where classCode = @ClassCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--ɾ������
		delete codeDictionary 
		where classCode = 0 and objCode = @ClassCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '���ؾ���', '�û�' + @delManName
									+ 'ɾ���˴����ֵ�['+ ltrim(str(@ClassCode,6)) +']��'
									+ '\r\n�⽫��Ӱ�쵽�������øô����ֵ�����ݣ�')
GO

drop PROCEDURE forceDelClass
/*
	name:		forceDelClass
	function:	15.ǿ��ɾ��һ�����ࣨ���ﲻ������õı����ɾ����Ӧ������ʾ��
	input: 
				@classCode int,			--�������

				@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1���ô����ֵ䲻���ڣ�2��Ҫɾ���Ĵ����ֵ���������������9��δ֪����
				@delTime smalldatetime output	--ɾ������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE forceDelClass
	@classCode 	int,

	@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	@Ret	 int output,	
	@delTime smalldatetime output	--ɾ������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�������Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	set @delTime = getdate()
	begin tran
		--ɾ��ȫ����Ŀ
		delete codeDictionary 
		where classCode = @ClassCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--ɾ������
		delete codeDictionary 
		where classCode = 0 and objCode = @ClassCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '���ؾ���', '�û�' + @delManName
									+ 'ɾ���˴����ֵ�['+ ltrim(str(@ClassCode,6)) +']��'
									+ '\r\n�⽫��Ӱ�쵽�������øô����ֵ�����ݣ�')
GO


drop PROCEDURE delItem
/*
	name:		delItem
	function:	16.ɾ��ָ�������ֵ��е�һ����Ŀ��Ҫ���Զ�������õı���������÷��س�����Ϣ��
	input: 
				@classCode int,		--�������
				@ObjCode int,		--��Ŀ����

				@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1������Ŀ�����ڣ�2��Ҫɾ���Ĵ����ֵ���������������3������Ŀ�Ѿ������ã�9��δ֪����
				@delTime smalldatetime output	--ɾ������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE delItem
	@classCode 	int,
	@ObjCode	int,

	@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	@Ret	 int output,	
	@delTime smalldatetime output	--ɾ������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	--�������Ŀ�����Ƿ����ã���Ҫ��ȫ�����ݿ����������ӣ�����
	--��������ã�����3�ų������
	--set @Ret = 3

	set @delTime = getdate()
	delete codeDictionary 
	where classCode = @ClassCode and objCode = @ObjCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--ȡά���˵�������
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '���ؾ���', '�û�' + @delManName
							+ 'ɾ���˴����ֵ�['+ ltrim(str(@ClassCode,6)) +']�еĵ�['+ ltrim(str(@ObjCode,6)) +']����Ŀ��'
							+ '\r\n�⽫��Ӱ�쵽�������øô����ֵ�����ݣ�')
GO

drop PROCEDURE forceDelItem
/*
	name:		forceDelItem
	function:	17.ǿ��ɾ��һ����Ŀ�����ﲻ������õı����ɾ����Ӧ������ʾ��
	input: 
				@classCode int,		--�������
				@ObjCode int,		--��Ŀ����

				@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1������Ŀ�����ڣ�2��Ҫɾ���Ĵ����ֵ���������������9��δ֪����
				@delTime smalldatetime output	--ɾ������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1һ�»�ά������ֶΣ������ӿ�
*/
create PROCEDURE forceDelItem
	@classCode 	int,
	@ObjCode	int,

	@delManID varchar(10) output,--ɾ���ˣ������ǰ�����ֵ����ڱ���ռ�ñ༭�򷵻ظ��˹���
	@Ret	 int output,	
	@delTime smalldatetime output	--ɾ������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ���ڣ�
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	set @delTime = getdate()
	delete codeDictionary 
	where classCode = @ClassCode and objCode = @ObjCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--ȡά���˵�������
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '���ؾ���', '�û�' + @delManName
							+ 'ɾ���˴����ֵ�['+ ltrim(str(@ClassCode,6)) +']�еĵ�['+ ltrim(str(@ObjCode,6)) +']����Ŀ��'
							+ '\r\n�⽫��Ӱ�쵽�������øô����ֵ�����ݣ�')
GO

---------------------------------------��صı�ʹ洢���̣�---------------------------------------

--ͼƬ�Ĵ洢����ʾ
drop table indexPic
CREATE TABLE [indexPic] (
	[indexNum] [varchar] (20) NOT NULL,		--ͼƬ������
	[pic] [image] NULL,
	CONSTRAINT [PK_indexPic] PRIMARY KEY  CLUSTERED 
	(
		[indexNum]
	)  ON [PRIMARY] 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


delete indexPic
select * from indexPic

drop PROCEDURE CreateIndexPic
/*
	����::	CreateIndexPic
	
	����:	����ָ����������(��ʡ��)����ͼ���ļ�
	ע�⣺	pic�ֶβ���ΪNULL�������ϴ��Ĵ洢���̲����������������Գ�ʼ��Ϊһ���ַ���
	
	wrt  by lw 2004-07-22
*/
CREATE PROCEDURE CreateIndexPic
	@indexNum 	varchar(20) output
AS
	if @indexNum <> ''	--�����������Ƿ�Ψһ
	begin
		declare @couter as int
		set @couter = (select count(indexNum) from indexPic where indexNum=@indexNum)
		if @couter > 0
		begin
			set @indexNum = ''
			return
		end		
	end
	else
	begin
		set @indexNum=(select max(indexNum) from indexPic)
		if @indexNum is null
		begin
			set @indexNum = '0000'
		end
		else
		begin
			set @indexNum = right('0000' + ltrim(str(cast(@indexNum as bigint) + 1)),4)
		end
	end
	insert indexPic values(@indexNum,'lw')
	
go

drop PROCEDURE UploadImageFirst
/*
	����::	UploadImageFirst
	
	����:	����ָ�����������ϴ�ͼ���ļ�����
		��ΪҪ���ԭ�����������Ե�1��Ҫ���⴦��
	
	wrt  by lw 2004-07-22
*/
CREATE PROCEDURE UploadImageFirst
	@image_data	varbinary(1024),
	@indexNum 	varchar(20)
AS
	declare @wptr varbinary(16)
	select @wptr = TEXTPTR(pic) from indexPic where indexnum=@indexNum
	UPDATETEXT indexPic.pic @wptr 0 null @image_data
go


drop PROCEDURE UploadImage
/*
	����::	UploadImage
	
	����:	����ָ�����������ϴ�ͼ���ļ�����,���ǵ�1�δ����������������
	
	wrt  by lw 2004-07-22
*/
CREATE PROCEDURE UploadImage
	@image_data	varbinary(1024),
	@indexNum 	varchar(20)
AS
	declare @wptr varbinary(16)
	select @wptr = TEXTPTR(pic) from indexPic where indexnum=@indexNum
	UPDATETEXT indexPic.pic @wptr null null @image_data
go

--ͼ���´�ֱ��ʹ��PICTUREBOX�ȿؼ���ADODC�����


--���ԣ�
declare @image_data varbinary(1024)
set @image_data= cast('Hello' as varbinary(1024))

declare @indexNum as varchar(50)
set @indexNum = '000'

exec UploadImageFirst @image_data, @indexNum

set @image_data= cast('This is a test....' as varbinary(1024))

exec UploadImage @image_data, @indexNum


--����������
use epdc2
--1��ϵͳ���������
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 1, 'ϵͳ����', '', '')
insert codeDictionary(classCode, objCode, objDesc)	--ϵͳʹ�õ�λ����
values(1, 1, '10486')
insert codeDictionary(classCode, objCode, objDesc)	--ϵͳʹ�õ�λ����
values(1, 2, '�人��ѧ')

--2���豸��״�룺
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 2, '�豸��״��', '�ߵ�ѧУ�����豸���������Ϣ��', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 1, '����', 1, '1')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 2, '����', 1, '2')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 3, '����', 1, '3')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 4, '������', 1, '4')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 5, '��ʧ', 1, '5')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 6, '����', 1, '6')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 7, '����', 1, '7')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 8, '����', 1, '8')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 9, '����', 1, '9')

--3�����ִ��룺
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 3, '���ִ���', '�й����������׼')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 110, '�۱�', '110','HKD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 113, '�������Ƕ�', '113','IRR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 116, '�ձ�Ԫ', '116','JPY')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 118, '�����ص��ɶ�', '118','KWD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 121, '����Ԫ', '121','MOP')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 122, '���������ּ���', '122','MYR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 127, '�ͻ�˹̹¬��', '127','PKR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 129, '���ɱ�����', '129','PHP')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 132, '�¼���Ԫ', '132','SGD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 136, '̩����', '136','THB')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 142, '�����', '142','CNY')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 143, '̨��', '143','TWD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 300, 'ŷԪ', '300','EUR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 302, '�������', '302','DKK')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 303, 'Ӣ��', '303','GBP')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 326, 'Ų������', '326','NOK')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 330, '������', '330','SEK')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 331, '��ʿ����', '331','CHF')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 332, '����¬��', '332','SUR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 398, '������ʿ����', '398','ASF')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 501, '���ô�Ԫ', '501','CAD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 502, '��Ԫ', '502','USD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 601, '�Ĵ�����Ԫ', '601','AUD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 602, '������Ԫ', '602','NZD')

--4�����ʽ��
select * from codeDictionary where classCode = 4
delete codeDictionary where classCode = 4
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 4, '���ʽ', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(4, 1, '��������', '','')
--��ǰ���ʽ��10��ʼ
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(4, 10, '���ڸ���', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(4, 12, 'ȫ��渶', '','')

--5���������ͣ�
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 5, '��������', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 1, '�����豸��������������Э��', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 2, '��ó��ͬ', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 3, 'ί�д������Э��', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 4, '���ص�', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 5, '���', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 6, '����֤', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 7, '��������', '','')

--98.ϵͳ���ݣ�ϵͳȨ�ޣ�ϵͳ��Դ�������ȴ��룺
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 98, '��ϵͳȨ�ޣ�ϵͳ��Դ�������ȴ���', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 1, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 4, '����λ')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 8, 'ȫУ')

--99.ϵͳ���ݶ����������
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 99, 'ϵͳ���ݶ����������', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 1, '��ѯ�����')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 2, '�༭�����')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 3, '���������')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 4, '��������')

--100����ɫ�ּ����ͣ�
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 100, '��ɫ�ּ�����', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 1, 'ѧУ�豸����ó�ɹ�����')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 2, 'ͨ�õ������û���ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 10, 'ͨ�õ���ó��˾����Ա��ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 11, 'ͨ�õ���ó��˾Ա����ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 20, 'ͨ�õĹ�����λ����Ա��ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 21, 'ͨ�õĹ�����λԱ����ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 30, '�ض�Ժ���������û���ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 31, '�ض���ó��˾��Ա����ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 32, '�ض�������λ��Ա����ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 100, 'ͨ�õĺ��ؼ��Ա��ɫ')

--101��ϵͳ�û����
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 101, 'ϵͳ�û����', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 1, 'ѧУԱ��')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 2, '������λԱ��')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 3, '��ó��˾Ա��')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 4, '������Ȩ�û�')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 9, '�ο�')


update codeDictionary
set inputCode = upper(dbo.getChinaPYCode(objDesc))



select * from codeDictionary where classCode=0 and objCode=3


