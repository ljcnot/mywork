use fTradeDB
/*
	�����ó��ͬ������Ϣϵͳ-�����ֵ������洢����
	�����豸����ϵͳ�޸�,Ҫ���豸����ϵͳ�е����Ʊ�ͬʱ����!
	�ò��ֵı�ʹ洢���̲��������豸����ϵͳ��webService����;
	author:		¬έ
	CreateDate:	2010-8-13
	UpdateDate: 
*/

--2.����country����
select * from 
select * from country
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

drop PROCEDURE checkCountryName
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
	set @rowNum =(select rowNum from countrty where cCode = @cCode or cName = @cName)

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


--5.college��Ժ������
--ָѧԺ��ϵ�����о�����ʵ�����ļ�������λ
alter TABLE college add abbClgName nvarchar(6) null		--Ժ�����	add by lw 2012-5-19���ݿͻ�Ҫ������
alter TABLE college add managerID varchar(10) null			--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
drop table college
CREATE TABLE college(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	clgCode char(3) not null,			--������Ժ������
	clgName nvarchar(30) not null,		--Ժ������	
	abbClgName nvarchar(6) null,		--Ժ�����	add by lw 2012-5-19���ݿͻ�Ҫ������
	managerID varchar(10) null,			--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
	manager nvarchar(30) null,			--Ժ��������
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
*/
create PROCEDURE addCollege
	@clgCode char(3),			--������Ժ������
	@clgName nvarchar(30),		--Ժ������	
	@abbClgName nvarchar(6),	--Ժ�����
	@managerID varchar(10),		--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
	@manager nvarchar(30),		--Ժ��������
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

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert college(clgCode, clgName, abbClgName, managerID, manager, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@clgCode, @clgName, @abbClgName, @managerID, @manager, @inputCode,
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
*/
create PROCEDURE updateCollege
	@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@clgCode char(3),			--������Ժ������
	@clgName nvarchar(30),		--Ժ������	
	@abbClgName nvarchar(6),	--Ժ�����
	@managerID varchar(10),		--Ժ�������˹��� add by lw 2012-6-4Ϊ�����Ӷ��Ź��ܶ������ľ�ȷ��λ�����˵��ֶ�
	@manager nvarchar(30),		--Ժ��������
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

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update college
	set clgCode = @clgCode, clgName = @clgName, abbClgName = @abbClgName,
		managerID = @managerID, manager = @manager, inputCode = @inputCode,
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
drop table useUnit
CREATE TABLE useUnit(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	uCode varchar(8) not null,			--������ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) not null,		--ʹ�õ�λ����	
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
*/
create PROCEDURE addUseUnit
	@uCode varchar(8),	--������ʹ�õ�λ����
	@uName nvarchar(30),	--ʹ�õ�λ����	
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
	insert useUnit(uCode, uName, manager, clgCode, inputCode, uType,
						lockManID, modiManID, modiManName, modiTime) 
	values (@uCode, @uName, @manager, @clgCode, @inputCode, @uType,
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
*/
create PROCEDURE updateUseUnit
	@rowNum int,			--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	@uCode varchar(8),		--������ʹ�õ�λ����
	@uName nvarchar(30),	--ʹ�õ�λ����	
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
	set uCode = @uCode, uName = @uName, manager = @manager, clgCode = @clgCode, inputCode = @inputCode,
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


