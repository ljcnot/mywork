use hustOA
/*
	����豸������Ϣϵͳ-�����ֵ������洢����
	author:		¬έ
	CreateDate:	2010-8-13
	UpdateDate: 2010-10-30 �������µĽ�����ǿ�Զ���ɿؼ�Ҫ�����д����ֵ���������������ֶ�
				modi by lw 1011-10-16���豸��������ֲ��4�����������ࡢ���ࡢ�������������ӷ���������ʽ�ֶ�
				�������ֵ�����typeCode.sql
*/

--2.����country����

drop table country
CREATE TABLE country(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	cCode char(3) not null,			--���������Ҵ���
	cName nvarchar(60) not null,	--��������	
	enName nvarchar(60) null,		--����Ӣ������
	fullName nvarchar(100) null,	--������Ӣ��ȫ��
	inputCode varchar(5) null,		--������

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,	--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_country] PRIMARY KEY CLUSTERED 
(
	[cCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_country] ON [dbo].[country] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop PROCEDURE checkCountryCode
/*
	name:		checkCountryCode
	function:	0.1.���ָ���Ĺ��Ҵ����Ƿ��Ѿ�����
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@cCode char(3),			--���������Ҵ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkCountryCode
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@cCode char(3),			--���������Ҵ���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ù��Ҵ����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from country where cCode = @cCode and rowNum<>@rowNum)
	set @Ret = @count
GO

/*
	name:		checkCountryName
	function:	0.2.���ָ���Ĺ��������Ƿ��Ѿ�����
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@cName nvarchar(60),	--��������	
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkCountryName
	@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@cName nvarchar(60),	--��������	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ù����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from country where cName = @cName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCountryEnName
/*
	name:		checkCountryEnName
	function:	0.3.���ָ���Ĺ���Ӣ�������Ƿ��Ѿ�����
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@enName nvarchar(60),	--����Ӣ������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-9-9
	UpdateDate: 
*/
create PROCEDURE checkCountryEnName
	@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@enName nvarchar(60),	--����Ӣ������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ù����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from country where enName = @enName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCountryFullName
/*
	name:		checkCountryFullName
	function:	0.4.���ָ���Ĺ�����Ӣ��ȫ���Ƿ��Ѿ�����
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@fullName nvarchar(100),--������Ӣ��ȫ��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-9-9
	UpdateDate: 
*/
create PROCEDURE checkCountryFullName
	@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@fullName nvarchar(100),--������Ӣ��ȫ��
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ù����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from country where fullName = @fullName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addCountry
/*
	name:		addCountry
	function:	1.��ӹ���
				ע�⣺���洢���̲������༭��
	input: 
				@cCode char(3),				--���������Ҵ���
				@cName nvarchar(60),		--��������	
				@enName nvarchar(60),		--����Ӣ������
				@fullName nvarchar(100),	--������Ӣ��ȫ��
				@inputCode varchar(5),		--������

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���ù������ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE addCountry
	@cCode char(3),				--���������Ҵ���
	@cName nvarchar(60),		--��������	
	@enName nvarchar(60),		--����Ӣ������
	@fullName nvarchar(100),	--������Ӣ��ȫ��
	@inputCode varchar(5),		--������

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@rowNum		int output,		--���
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from country where cCode = @cCode or cName = @cName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert country(cCode, cName, enName, fullName, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@cCode, @cName, @enName, @fullName, @inputCode,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from country where cCode = @cCode)

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӹ���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˹���[' + @cName +'('+ @cCode +')' + ']��')
GO

drop PROCEDURE queryCountryLocMan
/*
	name:		queryCountryLocMan
	function:	2.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ĺ��𲻴���
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryCountryLocMan
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from country where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockCountry4Edit
/*
	name:		lockCountry4Edit
	function:	3.��������༭������༭��ͻ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ��𲻴��ڣ�2:Ҫ�����Ĺ������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockCountry4Edit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update country
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '��������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������к�Ϊ��[' + str(@rowNum,6) + ']�Ĺ���Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockCountryEditor
/*
	name:		unlockCountryEditor
	function:	4.�ͷŹ���༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockCountryEditor
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update country set lockManID = '' where rowNum = @rowNum
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
												+ '��Ҫ���ͷ����к�Ϊ��[' + str(@rowNum,6) + ']�Ĺ���ı༭����')
GO


drop PROCEDURE updateCountry
/*
	name:		updateCountry
	function:	5.���¹���
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@cCode char(3),				--���������Ҵ���
				@cName nvarchar(60),		--��������	
				@enName nvarchar(60),		--����Ӣ������
				@fullName nvarchar(100),	--������Ӣ��ȫ��
				@inputCode varchar(5),		--������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĹ�����������������2:���ظ��Ĺ����������ƣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE updateCountry
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@cCode char(3),				--���������Ҵ���
	@cName nvarchar(60),		--��������	
	@enName nvarchar(60),		--����Ӣ������
	@fullName nvarchar(100),	--������Ӣ��ȫ��
	@inputCode varchar(5),		--������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from country where (cCode = @cCode or cName = @cName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update country
	set cCode = @cCode, cName = @cName, enName = @enName, fullName = @fullName, inputCode = @inputCode,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���¹���', '�û�' + @modiManName 
												+ '�������к�Ϊ��[' + str(@rowNum,6) + ']�Ĺ���')
GO

drop PROCEDURE delCountry
/*
	name:		delCountry
	function:	6.ɾ��ָ���Ĺ���
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ��𲻴��ڣ�2��Ҫɾ���Ĺ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delCountry
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete country where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ��[' + str(@rowNum,6) + ']�Ĺ���')
GO

drop PROCEDURE setCountryOff
/*
	name:		setCountryOff
	function:	7.ͣ��ָ���Ĺ���
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ��𲻴��ڣ�2��Ҫͣ�õĹ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCountryOff
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update country
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ�ù���', '�û�' + @stopManName
												+ 'ͣ�����к�Ϊ��[' + str(@rowNum,6) + ']�Ĺ���')
GO

drop PROCEDURE setCountryActive
/*
	name:		setCountryActive
	function:	8.����ָ���Ĺ���
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@activeManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ĺ��𲻴��ڣ�2��Ҫ���õĹ�����������������3���ù��𱾾��Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCountryActive
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@activeManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ĺ����Ƿ����
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	declare @status char(1)
	set @status = isnull((select isOff from country where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update country
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '�������ù���', '�û�' + @activeManName
												+ '�����������к�Ϊ��[' + str(@rowNum,6) + ']�Ĺ���')
GO

--3.fundSrc��������Դ����
drop TABLE fundSrc
CREATE TABLE fundSrc(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	fCode char(2) not null,			--������������Դ����
	fName nvarchar(20) not null,	--������Դ����	
	inputCode varchar(5) null,		--������

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,		--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_fundSrc] PRIMARY KEY CLUSTERED 
(
	[fCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_fundSrc] ON [dbo].[fundSrc] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from fundSrc

drop PROCEDURE checkFundSrcCode
/*
	name:		checkFundSrcCode
	function:	0.1.���ָ���ľ�����Դ�����Ƿ��Ѿ�����
	input: 
				@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@fCode char(2),			--������������Դ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31�����޸�״̬�µļ��
*/
create PROCEDURE checkFundSrcCode
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@fCode char(2),			--������������Դ����
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ô����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from fundSrc where fCode = @fCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkFundSrcName
/*
	name:		checkFundSrcName
	function:	0.2.���ָ���ľ�����Դ�����Ƿ��Ѿ�����
	input: 
				@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@fName nvarchar(20),	--������Դ����	
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31�����޸�״̬�µļ��
*/
create PROCEDURE checkFundSrcName
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@fName nvarchar(20),	--������Դ����	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from fundSrc where fName = @fName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addFundSrc
/*
	name:		addFundSrc
	function:	1.��Ӿ�����Դ
				ע�⣺���洢���̲������༭��
	input: 
				@fCode char(2),			--������������Դ����
				@fName nvarchar(20),	--������Դ����	
				@inputCode varchar(5),	--������

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���þ�����Դ���ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE addFundSrc
	@fCode char(2),			--������������Դ����
	@fName nvarchar(20),	--������Դ����	
	@inputCode varchar(5),	--������

	@createManID varchar(10),--�����˹���

	@Ret		int output,
	@rowNum		int output,		--���
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from fundSrc where fCode = @fCode or fName = @fName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert fundSrc(fCode, fName, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@fCode, @fName, @inputCode,
			'', @createManID, @createManName, @createTime)

	set @rowNum =(select rowNum from fundSrc where fCode = @fCode or fName = @fName)

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��Ӿ�����Դ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˾�����Դ[' + @fName +'('+ @fCode +')' + ']��')
GO

drop PROCEDURE queryFundSrcLocMan
/*
	name:		queryFundSrcLocMan
	function:	2.��ѯָ��������Դ�Ƿ��������ڱ༭
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ľ�����Դ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryFundSrcLocMan
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockFundSrc4Edit
/*
	name:		lockFundSrc4Edit
	function:	3.����������Դ�༭������༭��ͻ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ľ�����Դ�����ڣ�2:Ҫ�����ľ�����Դ���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockFundSrc4Edit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ľ�����Դ�Ƿ����
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update fundSrc
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����������Դ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������к�Ϊ��[' + str(@rowNum,6) + ']�ľ�����ԴΪ��ռʽ�༭��')
GO

drop PROCEDURE unlockFundSrcEditor
/*
	name:		unlockFundSrcEditor
	function:	4.�ͷž�����Դ�༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockFundSrcEditor
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update fundSrc set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷž�����Դ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����к�Ϊ��[' + str(@rowNum,6) + ']�ľ�����Դ�ı༭����')
GO


drop PROCEDURE updateFundSrc
/*
	name:		updateFundSrc
	function:	5.���¾�����Դ
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@fCode char(2),			--������������Դ����
				@fName nvarchar(20),	--������Դ����	
				@inputCode varchar(5),	--������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µľ�����Դ��������������2:���ظ��ľ�����Դ��������ƣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE updateFundSrc
	@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@fCode char(2),			--������������Դ����
	@fName nvarchar(20),	--������Դ����	
	@inputCode varchar(5),	--������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from fundSrc where (fCode = @fCode or fName = @fName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update fundSrc
	set fCode = @fCode, fName = @fName, inputCode = @inputCode,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���¾�����Դ', '�û�' + @modiManName 
												+ '�������к�Ϊ��[' + str(@rowNum,6) + ']�ľ�����Դ��')
GO

drop PROCEDURE delFundSrc
/*
	name:		delFundSrc
	function:	6.ɾ��ָ���ľ�����Դ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ľ�����Դ�����ڣ�2��Ҫɾ���ľ�����Դ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delFundSrc
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ľ�����Դ�Ƿ����
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete fundSrc where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��������Դ', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ��[' + str(@rowNum,6) + ']�ľ�����Դ��')
GO

drop PROCEDURE setFundSrcOff
/*
	name:		setFundSrcOff
	function:	7.ͣ��ָ���ľ�����Դ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ľ�����Դ�����ڣ�2��Ҫͣ�õľ�����Դ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setFundSrcOff
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ľ�����Դ�Ƿ����
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update fundSrc
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ�þ�����Դ', '�û�' + @stopManName
												+ 'ͣ�����к�Ϊ��[' + str(@rowNum,6) + ']�ľ�����Դ��')
GO

drop PROCEDURE setFundSrcActive
/*
	name:		setFundSrcActive
	function:	8.����ָ���ľ�����Դ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@activeManID varchar(10) output,	--�����ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ľ�����Դ�����ڣ�2��Ҫ���õľ�����Դ��������������3���þ�����Դ�����Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setFundSrcActive
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@activeManID varchar(10) output,	--�����ˣ������ǰ������Դ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ľ�����Դ�Ƿ����
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	declare @status char(1)
	set @status = isnull((select isOff from fundSrc where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update fundSrc
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '�������þ�����Դ', '�û�' + @activeManName
												+ '�����������к�Ϊ��[' + str(@rowNum,6) + ']�ľ�����Դ��')
GO

--4.appDir��ʹ�÷��򣩣�
CREATE TABLE appDir(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	aCode varchar(2) not null,		--������ʹ�÷������
	aName nvarchar(20) not null,	--ʹ�÷�������	
	inputCode varchar(5) null,		--������

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,		--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_appDir] PRIMARY KEY CLUSTERED 
(
	[aCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_appDir] ON [dbo].[appDir] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE checkAppDirCode
/*
	name:		checkAppDirCode
	function:	0.1.���ָ����ʹ�÷�������Ƿ��Ѿ�����
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@aCode char(2),			--������ʹ�÷������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31�����޸�״̬�µļ��
*/
create PROCEDURE checkAppDirCode
	@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@aCode char(2),			--������ʹ�÷������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ô����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from appDir where aCode = @aCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkAppDirName
/*
	name:		checkAppDirName
	function:	0.2.���ָ����ʹ�÷��������Ƿ��Ѿ�����
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@aName nvarchar(20),	--ʹ�÷�������	
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31�����޸�״̬�µļ��
*/
create PROCEDURE checkAppDirName
	@rowNum int,			--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@aName nvarchar(20),	--ʹ�÷�������	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from appDir where aName = @aName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addAppDir
/*
	name:		addAppDir
	function:	1.���ʹ�÷���
				ע�⣺���洢���̲������༭��
	input: 
				@aCode char(2),			--������ʹ�÷������
				@aName nvarchar(20),	--ʹ�÷�������	
				@inputCode varchar(5),	--������

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1����ʹ�÷������ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw ���ݱ༭Ҫ������rowNum���ز���
*/
create PROCEDURE addAppDir
	@aCode char(2),			--������ʹ�÷������
	@aName nvarchar(20),	--ʹ�÷�������	
	@inputCode varchar(5),	--������

	@createManID varchar(10),--�����˹���

	@Ret		int output,
	@rowNum		int output,		--���
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from appDir where aCode = @aCode or aName = @aName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert appDir(aCode, aName, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@aCode, @aName, @inputCode,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from appDir where aCode = @aCode or aName = @aName)

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '���ʹ�÷���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������ʹ�÷���[' + @aName +'('+ @aCode +')' + ']��')
GO

drop PROCEDURE queryAppDirLocMan
/*
	name:		queryAppDirLocMan
	function:	2.��ѯָ��ʹ�÷����Ƿ��������ڱ༭
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ʹ�÷��򲻴���
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryAppDirLocMan
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockAppDir4Edit
/*
	name:		lockAppDir4Edit
	function:	3.����ʹ�÷���༭������༭��ͻ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ʹ�÷��򲻴��ڣ�2:Ҫ������ʹ�÷������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockAppDir4Edit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ʹ�÷����Ƿ����
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update appDir
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ʹ�÷���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�÷���Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockAppDirEditor
/*
	name:		unlockAppDirEditor
	function:	4.�ͷ�ʹ�÷���༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockAppDirEditor
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update appDir set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�ʹ�÷���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�÷���ı༭����')
GO


drop PROCEDURE updateAppDir
/*
	name:		updateAppDir
	function:	5.����ʹ�÷���
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@aCode char(2),			--������ʹ�÷������
				@aName nvarchar(20),	--ʹ�÷�������	
				@inputCode varchar(5),	--������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�ʹ�÷�����������������2:���ظ���ʹ�÷����������ƣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE updateAppDir
	@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@aCode char(2),			--������ʹ�÷������
	@aName nvarchar(20),	--ʹ�÷�������	
	@inputCode varchar(5),	--������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from appDir where (aCode = @aCode or aName = @aName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update appDir
	set aCode = @aCode, aName = @aName, inputCode = @inputCode,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����ʹ�÷���', '�û�' + @modiManName 
												+ '�������к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�÷���')
GO

drop PROCEDURE delAppDir
/*
	name:		delAppDir
	function:	6.ɾ��ָ����ʹ�÷���
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@delManID varchar(10) output,	--ɾ���ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ʹ�÷��򲻴��ڣ�2��Ҫɾ����ʹ�÷�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delAppDir
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@delManID varchar(10) output,	--ɾ���ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ʹ�÷����Ƿ����
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete appDir where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ʹ�÷���', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�÷���')
GO

drop PROCEDURE setAppDirOff
/*
	name:		setAppDirOff
	function:	7.ͣ��ָ����ʹ�÷���
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ʹ�÷��򲻴��ڣ�2��Ҫͣ�õ�ʹ�÷�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAppDirOff
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ʹ�÷����Ƿ����
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update appDir
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ��ʹ�÷���', '�û�' + @stopManName
												+ 'ͣ�����к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�÷���')
GO

drop PROCEDURE setAppDirActive
/*
	name:		setAppDirActive
	function:	8.����ָ����ʹ�÷���
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@activeManID varchar(10) output,	--�����ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ʹ�÷��򲻴��ڣ�2��Ҫ���õ�ʹ�÷�����������������3����ʹ�÷��򱾾��Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAppDirActive
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@activeManID varchar(10) output,	--�����ˣ������ǰʹ�÷������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ʹ�÷����Ƿ����
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	declare @status char(1)
	set @status = isnull((select isOff from appDir where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update appDir
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '��������ʹ�÷���', '�û�' + @activeManName
												+ '�����������к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�÷���')
GO


--5.college��Ժ������
--ָѧԺ��ϵ�����о�����ʵ�����ļ�������λ
use hustOA
select * from college
alter TABLE college add abbClgName nvarchar(6) null		--Ժ�����	add by lw 2012-5-19���ݿͻ�Ҫ������
alter TABLE college add managerID varchar(10) null			--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
alter TABLE college add postName nvarchar(10) null			--ְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
alter TABLE college add deputyManID varchar(10) null		--��ְ�����˹��ţ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
alter TABLE college add deputyMan nvarchar(30) null		--��ְ�����ˣ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
alter TABLE college add deputyPost nvarchar(10) null		--��ְְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
drop table college
CREATE TABLE college(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	clgCode char(3) not null,			--������Ժ������
	clgName nvarchar(30) not null,		--Ժ������	
	abbClgName nvarchar(6) null,		--Ժ�����	����óϵͳһ�»����ӣ���óϵͳadd by lw 2012-5-19���ݿͻ�Ҫ�����ӣ�
	managerID varchar(10) null,			--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
	manager nvarchar(30) null,			--Ժ��������
	postName nvarchar(10) null,			--ְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	deputyManID varchar(10) null,		--��ְ�����˹��ţ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	deputyMan nvarchar(30) null,		--��ְ�����ˣ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	deputyPost nvarchar(10) null,		--��ְְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	inputCode varchar(5) null,			--������

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,		--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_college] PRIMARY KEY CLUSTERED 
(
	[clgCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_college] ON [dbo].[college] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select clgCode, clgName, manager, inputCode from college order by inputCode

drop PROCEDURE checkCollegeCode
/*
	name:		checkCollegeCode
	function:	0.1.���ָ����Ժ�������Ƿ��Ѿ�����
	input: 
				@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@clgCode char(3),	--������Ժ������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/

create PROCEDURE checkCollegeCode
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@clgCode char(3),	--������Ժ������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ô����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from college where clgCode = @clgCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCollegeName
/*
	name:		checkCollegeName
	function:	0.2.���ָ����Ժ�������Ƿ��Ѿ�����
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@clgName nvarchar(30),		--Ժ������	
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkCollegeName
	@rowNum int,				--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@clgName nvarchar(30),		--Ժ������	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from college where clgName = @clgName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCollegeAbbName
/*
	name:		checkCollegeAbbName
	function:	0.3.���ָ����Ժ������Ƿ��Ѿ�����
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@abbClgName nvarchar(6),	--Ժ�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-5-19
	UpdateDate: 
*/
create PROCEDURE checkCollegeAbbName
	@rowNum int,				--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@abbClgName nvarchar(6),	--Ժ�����
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from college where abbClgName = @abbClgName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addCollege
/*
	name:		addCollege
	function:	1.���Ժ��
				ע�⣺���洢���̲������༭��
	input: 
				@clgCode char(3),			--������Ժ������
				@clgName nvarchar(30),		--Ժ������	
				@abbClgName nvarchar(6),	--Ժ�����
				@managerID varchar(10),		--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
				@manager nvarchar(30),		--Ժ��������
				@postName nvarchar(10),		--ְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@deputyManID varchar(10),	--��ְ�����˹��ţ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@deputyMan nvarchar(30),	--��ְ�����ˣ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@deputyPost nvarchar(10),	--��ְְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@inputCode varchar(5),		--������

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1����Ժ�����ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw ���ݱ༭Ҫ������rowNum���ز���
				modi by lw 2012-5-19 ���ݿͻ�Ҫ�����Ӽ��
				modi by lw 2012-6-4 ���Ӹ�����ID
				modi by lw 2012-12-29���ݹ���������Ҫ����ְ���븱ְ���ֶ�
*/
create PROCEDURE addCollege
	@clgCode char(3),			--������Ժ������
	@clgName nvarchar(30),		--Ժ������	
	@abbClgName nvarchar(6),	--Ժ�����
	@managerID varchar(10),		--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
	@manager nvarchar(30),		--Ժ��������
	@postName nvarchar(10),		--ְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@deputyManID varchar(10),	--��ְ�����˹��ţ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@deputyMan nvarchar(30),	--��ְ�����ˣ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@deputyPost nvarchar(10),	--��ְְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@inputCode varchar(5),		--������

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@rowNum		int output,		--���
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from college where clgCode = @clgCode or clgName = @clgName or abbClgName = @abbClgName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--����Ƿ��и�����ID����������»�ȡ������
	if (@managerID<>'')
	begin
		set @manager = isnull((select cName from userInfo where jobNumber=@managerID),'')
	end
	if (@deputyManID<>'') --��ְ�����˹���
	begin
		set @deputyMan = isnull((select cName from userInfo where jobNumber=@deputyManID),'')
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert college(clgCode, clgName, abbClgName, managerID, manager, inputCode,
						postName, deputyManID, deputyMan, deputyPost,
						lockManID, modiManID, modiManName, modiTime) 
	values (@clgCode, @clgName, @abbClgName, @managerID, @manager, @inputCode,
			@postName, @deputyManID, @deputyMan, @deputyPost,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from college where clgCode = @clgCode or clgName = @clgName)
	

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '���Ժ��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������Ժ��[' + @clgName +'('+ @clgCode +')' + ']��')
GO

drop PROCEDURE queryCollegeLocMan
/*
	name:		queryCollegeLocMan
	function:	2.��ѯָ��Ժ���Ƿ��������ڱ༭
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����Ժ��������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryCollegeLocMan
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from college where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockCollege4Edit
/*
	name:		lockCollege4Edit
	function:	3.����Ժ���༭������༭��ͻ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������Ժ�������ڣ�2:Ҫ������Ժ�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockCollege4Edit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������Ժ���Ƿ����
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update college
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����Ժ���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������к�Ϊ��[' + str(@rowNum,6) + ']��Ժ��Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockCollegeEditor
/*
	name:		unlockCollegeEditor
	function:	4.�ͷ�Ժ���༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockCollegeEditor
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update college set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�Ժ���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����к�Ϊ��[' + str(@rowNum,6) + ']��Ժ���ı༭����')
GO


drop PROCEDURE updateCollege
/*
	name:		updateCollege
	function:	5.����Ժ��
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@clgCode char(3),			--������Ժ������
				@clgName nvarchar(30),		--Ժ������	
				@abbClgName nvarchar(6),	--Ժ�����
				@managerID varchar(10),		--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
				@manager nvarchar(30),		--Ժ��������
				@postName nvarchar(10),		--ְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@deputyManID varchar(10),	--��ְ�����˹��ţ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@deputyMan nvarchar(30),	--��ְ�����ˣ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@deputyPost nvarchar(10),	--��ְְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
				@inputCode varchar(5),		--������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�Ժ����������������2:���ظ���Ժ����������ƣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-19 ���ݿͻ�Ҫ�����Ӽ��
				modi by lw 2012-6-4 ���Ӹ�����ID
				modi by lw 2012-12-29���ݹ���������Ҫ����ְ���븱ְ���ֶ�
*/
create PROCEDURE updateCollege
	@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@clgCode char(3),			--������Ժ������
	@clgName nvarchar(30),		--Ժ������	
	@abbClgName nvarchar(6),	--Ժ�����
	@managerID varchar(10),		--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
	@manager nvarchar(30),		--Ժ��������
	@postName nvarchar(10),		--ְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@deputyManID varchar(10),	--��ְ�����˹��ţ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@deputyMan nvarchar(30),	--��ְ�����ˣ�����Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@deputyPost nvarchar(10),	--��ְְ������Ӧ����������Ҫ���ӵ��ֶ� add by lw 2012-12-29
	@inputCode varchar(5),		--������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from college where (clgCode = @clgCode or clgName = @clgName or abbClgName = @abbClgName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--����Ƿ��и�����ID����������»�ȡ������
	if (@managerID<>'')
	begin
		set @manager = isnull((select cName from userInfo where jobNumber=@managerID),'')
	end
	if (@deputyManID<>'') --��ְ�����˹���
	begin
		set @deputyMan = isnull((select cName from userInfo where jobNumber=@deputyManID),'')
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update college
	set clgCode = @clgCode, clgName = @clgName, abbClgName = @abbClgName,
		managerID = @managerID, manager = @manager, inputCode = @inputCode,
		postName = @postName, deputyManID = @deputyManID, deputyMan = @deputyMan, deputyPost = @deputyPost,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����Ժ��', '�û�' + @modiManName 
												+ '�������к�Ϊ��[' + str(@rowNum,6) + ']��Ժ����')
GO

drop PROCEDURE delCollege
/*
	name:		delCollege
	function:	6.ɾ��ָ����Ժ��
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@delManID varchar(10) output,	--ɾ���ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ժ�������ڣ�2��Ҫɾ����Ժ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delCollege
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@delManID varchar(10) output,	--ɾ���ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����Ժ���Ƿ����
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete college where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��Ժ��', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ��[' + str(@rowNum,6) + ']��Ժ����')
GO

drop PROCEDURE setCollegeOff
/*
	name:		setCollegeOff
	function:	7.ͣ��ָ����Ժ��
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ժ�������ڣ�2��Ҫͣ�õ�Ժ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCollegeOff
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����Ժ���Ƿ����
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update college
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ��Ժ��', '�û�' + @stopManName
												+ 'ͣ�����к�Ϊ��[' + str(@rowNum,6) + ']��Ժ����')
GO

drop PROCEDURE setCollegeActive
/*
	name:		setCollegeActive
	function:	8.����ָ����Ժ��
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@activeManID varchar(10) output,	--�����ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ժ�������ڣ�2��Ҫ���õ�Ժ����������������3����Ժ�������Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCollegeActive
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@activeManID varchar(10) output,	--�����ˣ������ǰԺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����Ժ���Ƿ����
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	declare @status char(1)
	set @status = isnull((select isOff from college where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update college
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '��������Ժ��', '�û�' + @activeManName
												+ '�����������к�Ϊ��[' + str(@rowNum,6) + ']��Ժ����')
GO

use epdc2
select * from useUnit where manager like '%¬έ%'
--6.useUnit��ʹ�õ�λ����
alter table useUnit add	managerID varchar(10) null			--ʹ�õ�λ�����˹��� add by lw 2012-12-27
drop table useUnit
CREATE TABLE useUnit(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	uCode varchar(8) not null,			--������ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) not null,		--ʹ�õ�λ����	
	managerID varchar(10) null,			--ʹ�õ�λ�����˹��� add by lw 2012-12-27
	manager nvarchar(30) null,			--ʹ�õ�λ������
	uType smallint not null,			--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣1����ѧ��2�����У�3��������4�����ڣ�9������ add by lw 2011-1-26
	clgCode char(3) not null,			--�����ѧԺ����
	inputCode varchar(5) null,			--������

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,	--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_useUnit] PRIMARY KEY CLUSTERED 
(
	[uCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_useUnit] ON [dbo].[useUnit] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[useUnit] WITH CHECK ADD CONSTRAINT [FK_useUnit_college] FOREIGN KEY([clgCode])
REFERENCES [dbo].[college] ([clgCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[useUnit] CHECK CONSTRAINT [FK_useUnit_college]
GO

select u.uCode, u.uName, u.manager, u.clgCode, c.clgName, u.inputCode 
from useUnit u left join college c on u.clgCode = c.clgCode 
order by inputCode

drop PROCEDURE autoUseUnitCode
/*
	name:		autoUseUnitCode
	function:	0.0.����Ժ�������Զ������Ƽ���λ����
	input: 
				@clgCode char(3),			--����ѧԺ����
	output: 
				@uCode varchar(8) output	--�Ƽ���ʹ�õ�λ����
	author:		¬έ
	CreateDate:	2011-10-17
	UpdateDate: 
*/
create PROCEDURE autoUseUnitCode
	@clgCode char(3),			--����ѧԺ����
	@uCode varchar(8) output	--�Ƽ���ʹ�õ�λ����
	WITH ENCRYPTION 
AS
	set @uCode = ''

	if (LTRIM(rtrim(isnull(@clgCode,''))) = '')
	begin	
		return
	end

	declare @lastUCode varchar(8)
	set @lastUCode = isnull((select top 1 uCode from useUnit where left(uCode,3) = @clgCode order by uCode desc),'00000')
	
	declare @len int
	set @len = LEN(@lastUCode) - 3
	
	declare @num int
	set @num = cast(SUBSTRING(@lastUCode,4,@len) as int) + 1
	if @@ERROR <> 0 return
	
	set @uCode = @clgCode + right('00000' + CAST(@num as varchar(5)), @len)
GO
--���ԣ�
declare @uCode varchar(8), @clgCode char(3)
set @clgCode = '004'
exec dbo.autoUseUnitCode @clgCode, @uCode output
select @uCode
select * from useUnit where clgCode = @clgCode order by uCode desc

drop PROCEDURE checkUseUnitCode
/*
	name:		checkUseUnitCode
	function:	0.1.���ָ����ʹ�õ�λ�����Ƿ��Ѿ�����
	input: 
				@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@uCode varchar(8),	--������ʹ�õ�λ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-10-17�����޸�״̬�µļ��
*/
create PROCEDURE checkUseUnitCode
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@uCode varchar(8),	--������ʹ�õ�λ����
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ����룺
	declare @count int
	set @count = (select count(*) from useUnit where uCode = @uCode and rowNum <> @rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkUseUnitName
/*
	name:		checkUseUnitName
	function:	0.2.���ָ����ʹ�õ�λ�����Ƿ��Ѿ��ڱ�Ժ���ڵǼ�
	input: 
				@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@clgCode char(3),	--����ѧԺ����
				@uName nvarchar(30),--ʹ�õ�λ����	
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�8��δ����Ժ�����룬�޷���飬9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-10-17Ӧ�ͻ�Ҫ��������Ψһ�Լ��,�޸�Ϊ�ڱ�Ժ���ڲ���Ψһ�Լ�飡�����޸�״̬�µü�顣
*/
create PROCEDURE checkUseUnitName
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@clgCode char(3),		--����ѧԺ����
	@uName nvarchar(30),	--ʹ�õ�λ����	
	@Ret		int output
	WITH ENCRYPTION 
AS
	if (LTRIM(rtrim(isnull(@clgCode,''))) = '')
	begin	
		set @Ret = 8
		return
	end
	
	set @Ret = 9
	--����Ƿ��ڱ�Ժ�����������ĵ�λ��
	declare @count int
	set @count = (select count(*) from useUnit where clgCode = @clgCode and uName = @uName and rowNum <> @rowNum)
	set @Ret = @count
GO

drop PROCEDURE addUseUnit
/*
	name:		addUseUnit
	function:	1.���ʹ�õ�λ
				ע�⣺���洢���̲������༭��
	input: 
				@uCode varchar(8),	--������ʹ�õ�λ����
				@uName nvarchar(30),	--ʹ�õ�λ����	
				@managerID varchar(10),	--ʹ�õ�λ�����˹��ţ����ﲻ��鹤���������Ĺ�ϵ����
				@manager nvarchar(30),	--ʹ�õ�λ������
				@clgCode char(3),		--�����ѧԺ����
				@inputCode varchar(5),	--������
				@uType smallint,		--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣1����ѧ��2�����У�3��������4�����ڣ�9������ add by lw 2011-2-11

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1����ʹ�õ�λ�����Ѵ��ڣ�2����ʹ�õ�λ�����Ѵ��ڣ���Ժ���ڣ���9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw ���ݱ༭Ҫ������rowNum���ز���
				modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�,�����û���λ�����ֶ�
				modi by lw 2011-10-17Ӧ�ͻ�Ҫ��������Ψһ�Լ��,�޸�Ϊ�ڱ�Ժ���ڲ���Ψһ�Լ�飡
				modi by lw 2013-2-26���ӵ�λ�����˹����ֶ�
*/
create PROCEDURE addUseUnit
	@uCode varchar(8),	--������ʹ�õ�λ����
	@uName nvarchar(30),	--ʹ�õ�λ����	
	@managerID varchar(10),	--ʹ�õ�λ�����˹���
	@manager nvarchar(30),	--ʹ�õ�λ������
	@clgCode char(3),		--�����ѧԺ����
	@inputCode varchar(5),	--������
	@uType smallint,		--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣1����ѧ��2�����У�3��������4�����ڣ�9������ add by lw 2011-2-11

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@rowNum		int output,		--���
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ����룺
	declare @count int
	set @count = (select count(*) from useUnit where uCode = @uCode)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--����Ƿ��ڱ�Ժ�����������ĵ�λ��
	set @count = (select count(*) from useUnit where clgCode = @clgCode and uName = @uName)
	if @count > 0
	begin
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	if @uType=0
		set @uType = null
	set @createTime = getdate()
	insert useUnit(uCode, uName, managerID, manager, clgCode, inputCode, uType,
						lockManID, modiManID, modiManName, modiTime) 
	values (@uCode, @uName, @managerID, @manager, @clgCode, @inputCode, @uType,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from useUnit where uCode = @uCode)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '���ʹ�õ�λ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������ʹ�õ�λ[' + @uName +'('+ @uCode +')' + ']��')
GO
--���ԣ�
select * from college
declare @createManID varchar(10)
declare @Ret		int
declare @rowNum		int
declare @createTime smalldatetime
exec dbo.addUseUnit '11001111',	'ʹ�õ�λ����', 'lw', '000','', 1, '000000000', @Ret output, @rowNum output, @createTime output
select @Ret


drop PROCEDURE queryUseUnitLocMan
/*
	name:		queryUseUnitLocMan
	function:	2.��ѯָ��ʹ�õ�λ�Ƿ��������ڱ༭
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ʹ�õ�λ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryUseUnitLocMan
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockUseUnit4Edit
/*
	name:		lockUseUnit4Edit
	function:	3.����ʹ�õ�λ�༭������༭��ͻ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ʹ�õ�λ�����ڣ�2:Ҫ������ʹ�õ�λ���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockUseUnit4Edit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ʹ�õ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update useUnit
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ʹ�õ�λ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�õ�λΪ��ռʽ�༭��')
GO

drop PROCEDURE unlockUseUnitEditor
/*
	name:		unlockUseUnitEditor
	function:	4.�ͷ�ʹ�õ�λ�༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockUseUnitEditor
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update useUnit set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�ʹ�õ�λ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�õ�λ�ı༭����')
GO


drop PROCEDURE updateUseUnit
/*
	name:		updateUseUnit
	function:	5.����ʹ�õ�λ
	input: 
				@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@uCode varchar(8),		--������ʹ�õ�λ����
				@uName nvarchar(30),	--ʹ�õ�λ����	
				@managerID varchar(10),	--ʹ�õ�λ�����˹��ţ����ﲻ��鹤���������Ĺ�ϵ����
				@manager nvarchar(30),	--ʹ�õ�λ������
				@clgCode char(3),		--�����ѧԺ����
				@inputCode varchar(5),	--������
				@uType smallint,		--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣1����ѧ��2�����У�3��������4�����ڣ�9������ add by lw 2011-2-11

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�ʹ�õ�λ��������������
							2:���ظ���ʹ�õ�λ���룬
							3:���ظ���ʹ�õ�λ���ƣ���Ժ���ڣ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ����ӵ�λ�����ֶ�
				modi by lw 2011-10-17Ӧ�ͻ�Ҫ��������Ψһ�Լ��,�޸�Ϊ�ڱ�Ժ���ڲ���Ψһ�Լ�飡
				modi by lw 2013-2-26���ӵ�λ�����˹����ֶ�
*/
create PROCEDURE updateUseUnit
	@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@uCode varchar(8),		--������ʹ�õ�λ����
	@uName nvarchar(30),	--ʹ�õ�λ����	
	@managerID varchar(10),	--ʹ�õ�λ�����˹��ţ����ﲻ��鹤���������Ĺ�ϵ����
	@manager nvarchar(30),	--ʹ�õ�λ������
	@clgCode char(3),		--�����ѧԺ����
	@inputCode varchar(5),	--������
	@uType smallint,		--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣1����ѧ��2�����У�3��������4�����ڣ�9������ add by lw 2011-2-11

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ����룺
	declare @count int
	set @count = (select count(*) from useUnit where uCode = @uCode and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--����ڱ�Ժ�����Ƿ���������
	set @count = (select count(*) from useUnit where clgCode = @clgCode and uName = @uName and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update useUnit
	set uCode = @uCode, uName = @uName, managerID = @managerID, manager = @manager, clgCode = @clgCode, inputCode = @inputCode,
		uType = @uType,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����ʹ�õ�λ', '�û�' + @modiManName 
												+ '�������к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�õ�λ��')
GO

drop PROCEDURE delUseUnit
/*
	name:		delUseUnit
	function:	6.ɾ��ָ����ʹ�õ�λ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@delManID varchar(10) output,	--ɾ���ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ʹ�õ�λ�����ڣ�2��Ҫɾ����ʹ�õ�λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delUseUnit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@delManID varchar(10) output,	--ɾ���ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ʹ�õ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete useUnit where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ʹ�õ�λ', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�õ�λ��')
GO

drop PROCEDURE setUseUnitOff
/*
	name:		setUseUnitOff
	function:	7.ͣ��ָ����ʹ�õ�λ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ʹ�õ�λ�����ڣ�2��Ҫͣ�õ�ʹ�õ�λ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setUseUnitOff
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ʹ�õ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update useUnit
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ��ʹ�õ�λ', '�û�' + @stopManName
												+ 'ͣ�����к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�õ�λ��')
GO

drop PROCEDURE setUseUnitActive
/*
	name:		setUseUnitActive
	function:	8.����ָ����ʹ�õ�λ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@activeManID varchar(10) output,	--�����ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ʹ�õ�λ�����ڣ�2��Ҫ���õ�ʹ�õ�λ��������������3����ʹ�õ�λ�����Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setUseUnitActive
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@activeManID varchar(10) output,	--�����ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ʹ�õ�λ�Ƿ����
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	declare @status char(1)
	set @status = isnull((select isOff from useUnit where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update useUnit
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '��������ʹ�õ�λ', '�û�' + @activeManName
												+ '�����������к�Ϊ��[' + str(@rowNum,6) + ']��ʹ�õ�λ��')
GO


--�����ֵ䣨��Ҫ�ǵ�λ�������ϲ���һ�ֱ����ա�һ�ֳ����µ�λ�����޸ġ�ɾ��

--7.��ƿ�Ŀ�����ֵ��
drop table accountTitle
CREATE TABLE accountTitle(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	accountCode varchar(9) not null,		--��������ƿ�Ŀ����
	accountName nvarchar(30) not null,		--��ƿ�Ŀ��������
	accountEName varchar(60) null,			--��ƿ�ĿӢ������
	accountTypeCode char(1) not null,		--��Ŀ���
	accountTypeName nvarchar(30) not null,	--��Ŀ�����������
	accountTypeEName varchar(60) null,		--��Ŀ���Ӣ������
	inputCode varchar(5) null,				--������
	
	--���ݱϴ���������ӻ�ƿ�Ŀͬʹ�÷���ļ���add by lw 2011-2-19
	aCode char(2) not null,					--ʹ�÷������
	aName nvarchar(20) not null,			--ʹ�÷������ƣ������ֶΣ�
	

	--Ϊ�˱�֤�������ʷ������ȷ�ԣ��������ú�ͣ�ù��ܶ����ӵ��ֶΣ�
	isOff char(1) default('0') null,		--ͣ�ñ�ʶ:��0���������ã���1������ͣ��
	offDate smalldatetime null,			--ͣ������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_accountTitle] PRIMARY KEY CLUSTERED 
(
	[accountCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
CREATE NONCLUSTERED INDEX [IX_accountTitle] ON [dbo].[accountTitle] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_accountTitle_1] ON [dbo].[accountTitle] 
(
	[accountTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_accountTitle_2] ON [dbo].[accountTitle] 
(
	[aCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop PROCEDURE checkAccountTitleCode
/*
	name:		checkAccountTitleCode
	function:	0.1.���ָ���Ļ�ƿ�Ŀ�����Ƿ��Ѿ�����
	input: 
				@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@accountCode varchar(9),	--��������ƿ�Ŀ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-10-17�����޸�״̬�µļ��
*/
create PROCEDURE checkAccountTitleCode
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@accountCode varchar(9),	--��������ƿ�Ŀ����
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ô����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from accountTitle where accountCode = @accountCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkAccountTitleName
/*
	name:		checkAccountTitleName
	function:	0.2.���ָ���Ļ�ƿ�Ŀ�����Ƿ��Ѿ�����
	input: 
				@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
				@accountName nvarchar(30),		--��ƿ�Ŀ��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-10-17�����޸�״̬�µļ��
*/
create PROCEDURE checkAccountTitleName
	@rowNum int,		--���:Ϊ�˱�֤�û����޸�״̬����Ψһ�Լ������ӵĶ�λ�кţ�Ϊ��0��ʱ��ʾ����״̬
	@accountName nvarchar(30),		--��ƿ�Ŀ��������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from accountTitle where accountName = @accountName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addAccountTitle
/*
	name:		addAccountTitle
	function:	1.��ӻ�ƿ�Ŀ
				ע�⣺���洢���̲������༭��
	input: 
				@accountCode varchar(9),	--��������ƿ�Ŀ����
				@accountName nvarchar(30),		--��ƿ�Ŀ��������
				@accountEName varchar(60),		--��ƿ�ĿӢ������
				@accountTypeCode char(1),		--��Ŀ���
				@accountTypeName nvarchar(30),	--��Ŀ�����������
				@accountTypeEName varchar(60),	--��Ŀ���Ӣ������
				@inputCode varchar(5),			--������
				--������ʹ�÷���add by lw 2011-2-19
				@aCode char(2),					--ʹ�÷������

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���û�ƿ�Ŀ���ƻ�����Ѵ��ڣ�9��δ֪����
				@rowNum		int output,		--���
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw ���ݱ༭Ҫ������rowNum���ز���
				2011-2-19 by lw ����ʹ�÷���ļ���
*/
create PROCEDURE addAccountTitle
	@accountCode varchar(9),	--��������ƿ�Ŀ����
	@accountName nvarchar(30),		--��ƿ�Ŀ��������
	@accountEName varchar(60),		--��ƿ�ĿӢ������
	@accountTypeCode char(1),		--��Ŀ���
	@accountTypeName nvarchar(30),	--��Ŀ�����������
	@accountTypeEName varchar(60),	--��Ŀ���Ӣ������
	@inputCode varchar(5),			--������
	--������ʹ�÷���add by lw 2011-2-19
	@aCode char(2),					--ʹ�÷������

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@rowNum		int output,		--���
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from accountTitle where accountCode = @accountCode or accountName = @accountName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--��ȡ������ʹ�÷������ƣ�
	declare @aName nvarchar(20)
	set @aName = (select aName from appDir where aCode = @aCode)

	set @createTime = getdate()
	insert accountTitle(accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode,
						aCode, aName,
						lockManID, modiManID, modiManName, modiTime) 
	values (@accountCode, @accountName, @accountEName, @accountTypeCode, @accountTypeName, @accountTypeEName, @inputCode,
			@aCode, @aName,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from accountTitle where accountCode = @accountCode or accountName = @accountName)

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӻ�ƿ�Ŀ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˻�ƿ�Ŀ[' + @accountName +'('+ @accountCode +')' + ']��')
GO

drop PROCEDURE queryAccountTitleLocMan
/*
	name:		queryAccountTitleLocMan
	function:	2.��ѯָ����ƿ�Ŀ�Ƿ��������ڱ༭
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ļ�ƿ�Ŀ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryAccountTitleLocMan
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockAccountTitle4Edit
/*
	name:		lockAccountTitle4Edit
	function:	3.������ƿ�Ŀ�༭������༭��ͻ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ļ�ƿ�Ŀ�����ڣ�2:Ҫ�����Ļ�ƿ�Ŀ���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockAccountTitle4Edit
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ļ�ƿ�Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update accountTitle
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������ƿ�Ŀ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������к�Ϊ��[' + str(@rowNum,6) + ']�Ļ�ƿ�ĿΪ��ռʽ�༭��')
GO

drop PROCEDURE unlockAccountTitleEditor
/*
	name:		unlockAccountTitleEditor
	function:	4.�ͷŻ�ƿ�Ŀ�༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockAccountTitleEditor
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update accountTitle set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷŻ�ƿ�Ŀ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����к�Ϊ��[' + str(@rowNum,6) + ']�Ļ�ƿ�Ŀ�ı༭����')
GO


drop PROCEDURE updateAccountTitle
/*
	name:		updateAccountTitle
	function:	5.���»�ƿ�Ŀ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@accountCode varchar(9),		--��������ƿ�Ŀ����
				@accountName nvarchar(30),		--��ƿ�Ŀ��������
				@accountEName varchar(60),		--��ƿ�ĿӢ������
				@accountTypeCode char(1),		--��Ŀ���
				@accountTypeName nvarchar(30),	--��Ŀ�����������
				@accountTypeEName varchar(60),	--��Ŀ���Ӣ������
				@inputCode varchar(5),			--������
				--������ʹ�÷���add by lw 2011-2-19
				@aCode char(2),					--ʹ�÷������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĻ�ƿ�Ŀ��������������2:���ظ��Ļ�ƿ�Ŀ��������ƣ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-2-19������ʹ�÷���ļ���
*/
create PROCEDURE updateAccountTitle
	@rowNum int,					--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@accountCode varchar(9),		--��������ƿ�Ŀ����
	@accountName nvarchar(30),		--��ƿ�Ŀ��������
	@accountEName varchar(60),		--��ƿ�ĿӢ������
	@accountTypeCode char(1),		--��Ŀ���
	@accountTypeName nvarchar(30),	--��Ŀ�����������
	@accountTypeEName varchar(60),	--��Ŀ���Ӣ������
	@inputCode varchar(5),			--������
	--������ʹ�÷���add by lw 2011-2-19
	@aCode char(2),					--ʹ�÷������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from accountTitle where (accountCode = @accountCode or accountName = @accountName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--��ȡ������ʹ�÷������ƣ�
	declare @aName nvarchar(20)
	set @aName = (select aName from appDir where aCode = @aCode)

	set @updateTime = getdate()
	update accountTitle
	set accountCode = @accountCode, accountName = @accountName, accountEName = @accountEName, 
		accountTypeCode = @accountTypeCode, accountTypeName = @accountTypeName, accountTypeEName = @accountTypeEName, 
		inputCode = @inputCode,
		aCode = @aCode, aName = @aName,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���»�ƿ�Ŀ', '�û�' + @modiManName 
												+ '�������к�Ϊ��[' + str(@rowNum,6) + ']�Ļ�ƿ�Ŀ��')
GO

drop PROCEDURE delAccountTitle
/*
	name:		delAccountTitle
	function:	6.ɾ��ָ���Ļ�ƿ�Ŀ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ�ƿ�Ŀ�����ڣ�2��Ҫɾ���Ļ�ƿ�Ŀ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delAccountTitle
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ�ƿ�Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete accountTitle where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����ƿ�Ŀ', '�û�' + @delManName
												+ 'ɾ�����к�Ϊ��[' + str(@rowNum,6) + ']�Ļ�ƿ�Ŀ��')
GO

drop PROCEDURE setAccountTitleOff
/*
	name:		setAccountTitleOff
	function:	7.ͣ��ָ���Ļ�ƿ�Ŀ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ�ƿ�Ŀ�����ڣ�2��Ҫͣ�õĻ�ƿ�Ŀ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAccountTitleOff
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ�ƿ�Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update accountTitle
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ�û�ƿ�Ŀ', '�û�' + @stopManName
												+ 'ͣ�����к�Ϊ��[' + str(@rowNum,6) + ']�Ļ�ƿ�Ŀ��')
GO

drop PROCEDURE setAccountTitleActive
/*
	name:		setAccountTitleActive
	function:	8.����ָ���Ļ�ƿ�Ŀ
	input: 
				@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
				@activeManID varchar(10) output,	--�����ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ�ƿ�Ŀ�����ڣ�2��Ҫ���õĻ�ƿ�Ŀ��������������3���û�ƿ�Ŀ�����Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAccountTitleActive
	@rowNum int,				--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@activeManID varchar(10) output,	--�����ˣ������ǰ��ƿ�Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ�ƿ�Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	declare @status char(1)
	set @status = isnull((select isOff from accountTitle where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update accountTitle
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '�������û�ƿ�Ŀ', '�û�' + @activeManName
												+ '�����������к�Ϊ��[' + str(@rowNum,6) + ']�Ļ�ƿ�Ŀ��')
GO



select * from wd.dbo.accountTitle

