use newfTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-ѧУ�û������
	���ݾ��õ�����Ϣϵͳ���豸����ϵͳ�ı࣬���û���ĳ�ѧУԱ���ǼǱ�������ϵͳ��¼�û�����룡ϵͳ��¼�û��������sysUserInfo���С�
	author:		¬έ
	�ͻ�Ҫ��
	�û��ּ����⣺
	1.�û���������У����Ժ�������Ҽ������Ե��ĵ�Ȩ�޷ֱ�Ϊ��ȫУ��ȫԺ��ȫ���ҵ��豸.ʹ�ý�ɫ�ּ������ݶ���Ĳ�����ΧԼ��ʵ��!
	2.֧���οͣ�ֻ�ܲ�ѯ���������ɱ���
	CreateDate:	2010-11-22
	UpdateDate: by lw 2011-9-12 �޸��û���֧�ֶ��ؽ�ɫ��ȥ���û�Ȩ�ޱ����û�Ȩ�޸�Ϊ��̬���㡣
				
*/
select * from userInfo
--1.ѧУ�û���Ϣ�� ��userInfo����
select u.jobNumber,u.cName,u.pID,u.mobileNum,u.telNum,u.e_mail,u.homeAddress,u.clgCode,u.clgName,u.uCode,u.uName,
	s.sysUserName,s.sysUserDesc,
    case s.isOff when '0' then '��' else '' end isOff,
    case s.isOff when '0' then '' else convert(char(10), setOffDate, 120) end offDate,
    u.modiManID,u.modiManName,u.modiTime,u.lockManID
from userInfo u left join sysUserInfo s on u.jobNumber= s.userID and s.userType = 1

	--����userInfo��
alter TABLE userInfo drop column sysUserName
alter TABLE userInfo drop column sysUserDesc
alter TABLE userInfo drop column sysPassword
alter TABLE userInfo drop column pswProtectQuestion
alter TABLE userInfo drop column psqProtectAnswer
alter TABLE userInfo drop column isOff
alter TABLE userInfo drop column setOffDate
	--���豸����ϵͳ�������ݣ�
insert userInfo(jobNumber, cName, pID, mobileNum, telNum, e_mail, homeAddress, clgCode, clgName, uCode, uName)
select jobNumber, cName, pID, mobileNum, telNum, e_mail, homeAddress, clgCode, clgName, uCode, uName
from epdc211.dbo.userInfo

alter TABLE userInfo add	inputCode varchar(5) null			--���������� add by lw 2012-4-24
update userInfo
set inputCode = upper(dbo.getChinaPYCode(cName))

select * from userInfo where cName like '%л����%'
drop TABLE userInfo
CREATE TABLE userInfo
(
	jobNumber varchar(10) not null,		--���ţ�����
	
	--������Ϣ��
	cName nvarchar(30) not null,		--����
	inputCode varchar(5) null,			--���������� add by lw 2012-4-24
	pID varchar(18) null,				--���֤��
	mobileNum varchar(20) null,			--�ֻ�����
	telNum varchar(30) null,			--�绰����
	e_mail varchar(30) null,			--E_mail��ַ
	homeAddress nvarchar(100) null,		--סַ
	
	--������Ϣ:
	clgCode char(3) not null,			--����ѧԺ����
	clgName nvarchar(30) not null,		--����ѧԺ����:�������
	uCode varchar(8) null,				--����ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) null,			--����ʹ�õ�λ����:�������

	--����ά�����:
	modiManID varchar(10) null,		--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10) null,			--��ǰ���������༭�˹���
CONSTRAINT [PK_userInfo] PRIMARY KEY CLUSTERED 
(
	[jobNumber] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


select * from userInfo

drop PROCEDURE checkJobNumber
/*
	name:		checkJobNumber
	function:	0.1.��鹤���Ƿ�Ψһ
	input: 
				@jobNumber varchar(10),		--����
	output: 
				@Ret		int output
							0:Ψһ��>1����Ψһ��-1��δ֪����
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE checkJobNumber
	@jobNumber varchar(10),		--����
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from userInfo where jobNumber = @jobNumber)
GO

drop PROCEDURE addUser
/*
	name:		addUser
	function:	1.����û�
				ע�⣺����洢���̼�鹤�ź�ϵͳ��½����Ψһ�ԣ�
	input: 
				@jobNumber varchar(10),		--���ţ�����
				--������Ϣ��
				@cName nvarchar(30),		--����
				@pID varchar(18),			--���֤��
				@mobileNum varchar(20),		--�ֻ�����
				@telNum varchar(30),		--�绰����
				@e_mail varchar(30),		--E_mail��ַ
				@homeAddress nvarchar(100),	--סַ
				
				--������Ϣ��
				@clgCode char(3),			--����ѧԺ����
				@uCode varchar(8),			--����ʹ�õ�λ����
				
				--����ά�����:
				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output,
							0:�ɹ���1:�ù����Ѿ��Ǽǹ���2:���û����Ѿ���ע����ˣ�9:δ֪����
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2011-9-4ȥ����ɫ�����������ӽ�ɫ�ּ����ʹ���
				modi by lw 2011-9-12�޸��û���֧�ֶ��ؽ�ɫ��ȥ���û�Ȩ�ޱ����û�Ȩ�޸�Ϊ��̬���㡣
				modi by lw 2012-4-18����ϵͳ��¼�û���������Ҫ��ɾ����Ӧ�ĵ�¼��Ϣ
*/
create PROCEDURE addUser
	@jobNumber varchar(10),		--���ţ�����
	--������Ϣ��
	@cName nvarchar(30),		--����
	@pID varchar(18),			--���֤��
	@mobileNum varchar(20),		--�ֻ�����
	@telNum varchar(30),		--�绰����
	@e_mail varchar(30),		--E_mail��ַ
	@homeAddress nvarchar(100),	--סַ
	
	--������Ϣ��
	@clgCode char(3),			--����ѧԺ����
	@uCode varchar(8),			--����ʹ�õ�λ����
	
	--����ά�����:
	@createManID varchar(10),	--�����˹���

	@Ret int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��鹤���Ƿ�Ψһ��
	declare @count as int
	set @count = (select count(*) from userInfo where jobNumber = @jobNumber)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--ȡԺ�����ƺ�ʹ�õ�λ���ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)		--����ѧԺ���ơ�����ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
		 
	--ȡ����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert userInfo (jobNumber,
				--������Ϣ��
				cName, pID, mobileNum, telNum, e_mail, homeAddress,
				--������Ϣ��
				clgCode, clgName, uCode, uName,
				--����ά�����:
				modiManID, modiManName, modiTime)
	values(@jobNumber,
				--������Ϣ��
				@cName, @pID, @mobileNum, @telNum, @e_mail, @homeAddress,
				--������Ϣ��
				@clgCode, @clgName, @uCode, @uName,
				--����ά�����:
				@createManID, @createManName, @createTime)

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'ע���û�','ϵͳ����' + @createManName + 
								'��Ҫ��Ǽ���ѧУԱ��[' + @cName + '('+ @jobNumber +')]����Ϣ��')
GO


--1.2�����LOGOͼƬ�ļ����ǼǱ� ��logoFileInfo����
drop TABLE logoFileInfo
CREATE TABLE logoFileInfo
(
	myID varchar(10) NOT NULL,			--LOGOͼƬ��Ӧ�Ķ���ID
	logoID int NOT NULL,				--logo��ID
	logoGUID36 varchar(36) NULL,		--logo��Ӧ��36λȫ��Ψһ�����ļ���
	logoExtFileName varchar(4) NULL,	--logo����չ��
CONSTRAINT [PK_logoFileInfo] PRIMARY KEY CLUSTERED 
(
	[myID] ASC,
	[logoID]
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE addLogo
/*
	name:		addLogo
	function:	��ǰͼƬ�������Ҳ�����µ�ͼƬ
				ע�⣺����ҪͼƬ�ı���������ģ�����ɾ����Ҫ���⴦��
	input: 
				@myID varchar(10),			--LOGOͼƬ��Ӧ�Ķ���ID
				@curLogo int,				--��ǰͼƬ�ı��
				@insertDir smallint,		--����ķ���1->�Ҳ� -1->���
				@logoExtFileName varchar(4),--�����Logo�ļ���չ��
	output: 
				@Ret		int output,	--�����ɹ���ʶ
							0:�ɹ���1������

				@logoGUID36 varchar(36) output,--ϵͳ�����Ψһ�ļ���
				@thisLogoID int output		--�����Logo���
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE addLogo
	@myID varchar(10),			--LOGOͼƬ��Ӧ�Ķ���ID
	@curLogo int,				--��ǰͼƬ�ı��
	@insertDir smallint,		--����ķ���1->�Ҳ� -1->���
	@logoExtFileName varchar(4),--�����Logo�ļ���չ��

	@Ret int output,			--�����ɹ���ʶ
	@logoGUID36 varchar(36) output,--ϵͳ�����Ψһ�ļ���
	@thisLogoID int output		--�����Logo���
	WITH ENCRYPTION 
AS
	set @Ret = 1

	--�жϵ�ǰ��ŵ�ͼƬ�Ƿ���ڣ����ݷ�������Ҫ�����ͼƬ�ı��
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @myID and logoID = @curLogo)	
	begin tran
		if (@count > 0)	--��ͼƬ���ڣ��������ͼƬ�ı��
		begin
			if (@insertDir = 1)	--���Ҳ����
			begin
				update logoFileInfo
				set logoID = logoID + 1 
				where myID = @myID and logoID > @curLogo
				set @thisLogoID = @curlogo + 1
			end
			else	--��������
			begin
				update logoFileInfo
				set logoID = logoID + 1 
				where myID = @myID and logoID >= @curLogo
				set @thisLogoID = @curlogo 
			end
		end
		else 	--��1�β���ͼƬ
		begin
			set @thisLogoID = 0
		end

		--����Ψһ���ļ�����
		set @logoGUID36 = (select newid())

		--�Ǽ�ͼƬ��Ϣ��
		insert dbo.logoFileInfo(myID, logoID, logoGUID36, logoExtFileName)
		values(@myID, @thisLogoID, @logoGUID36, @logoExtFileName)
	commit tran
	set @Ret = 0
GO

drop PROCEDURE delLogo
/*
	name:		delLogo
	function:	ɾ��ָ������ĵ�ǰͼƬ
				ע�⣺����Ҫ����ͼƬ�ı���������ģ�����ɾ����Ҫ���⴦��
	input: 
				@myID varchar(10),			--LOGOͼƬ��Ӧ�Ķ���ID
				@curLogo int,				--��ǰͼƬ�ı��
	output: 
				@Ret		int output,	--�����ɹ���ʶ
							0:�ɹ���1��Ҫɾ����ͼƬ�����ڣ�2������
				@logoGUID36 varchar(36) output,--��ǰͼƬ���ļ���
				@thisLogoID int output		--ɾ����ǰ��ͼƬ�ı��
	author:		¬έ
	CreateDate:	2010-5-28
	UpdateDate: 
*/
create PROCEDURE delLogo
	@myID varchar(10),			--LOGOͼƬ��Ӧ�Ķ���ID
	@curLogo int,				--��ǰͼƬ�ı��

	@Ret int output,			--�����ɹ���ʶ
	@logoGUID36 varchar(36) output,--��ǰͼƬ���ļ���
	@thisLogoID int output		--ɾ����ǰ��ͼƬ�ı��
	WITH ENCRYPTION 
AS
	set @Ret = 2
	set @thisLogoID = @curLogo

	--�жϵ�ǰ��ŵ�ͼƬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @myID and logoID = @curLogo)	
	if (@count = 0)	--��ͼƬ������
	begin
		set @Ret = 1
		return
	end
	
	begin tran
	--��ȡҪɾ���ĵ�ǰͼƬ���ļ�����
	declare @GUID36 varchar(36), @extFileName varchar(4)
	select @GUID36 = logoGUID36, @extFileName = logoExtFileName
	from logoFileInfo
	where myID = @myID and logoID = @curLogo
	set @logoGUID36 = @GUID36 + @extFileName 

	delete logoFileInfo where myID = @myID and logoID = @curLogo
	update logoFileInfo set logoID = logoID - 1 where myID = @myID and logoID > @curLogo

	--�ж��Ƿ�ɾ���������һ��ͼƬ�������������ǰͼƬ������
	set @count=isnull((select max(logoID) from logoFileInfo where myID = @myID),0)
	if (@count < @curLogo)
	begin
		set @curLogo = @curLogo - 1
	end
	set @thisLogoID = @curLogo

	commit tran
	set @Ret = 0
GO


drop PROCEDURE addUserLogo
/*
	name:		addUserLogo
	function:	3.����û���Logo
	input: 
				@jobNumber varchar(10),		--����
				@curLogo int,				--��ǰͼƬ�ı��
				@insertDir smallint,		--����ķ���1->�Ҳ� -1->���
				@logoExtFileName varchar(4),--�����Logo�ļ���չ��

				@addManID varchar(10) output,	--����ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output,			--�����ɹ���ʶ
							0:�ɹ���1:�����ڸ��û���2:���û���Ϣ��������������9:δ֪����
				@logoGUID36 varchar(36) output,--ϵͳ�����Ψһ�ļ���
				@thisLogoID int output		--�����Logo���
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE addUserLogo
	@jobNumber varchar(10),		--����
	@curLogo int,				--��ǰͼƬ�ı��
	@insertDir smallint,		--����ķ���1->�Ҳ� -1->���
	@logoExtFileName varchar(4),--�����Logo�ļ���չ��

	@addManID varchar(10) output,		--����ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@Ret int output,			--�����ɹ���ʶ
	@logoGUID36 varchar(36) output,--ϵͳ�����Ψһ�ļ���
	@thisLogoID int output		--�����Logo���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����û��Ƿ����
	declare @count as int
	set @count = (select count(*) from userInfo where jobNumber = @jobNumber)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @addManID)
	begin
		set @addManID = @thisLockMan
		set @Ret = 2
		return
	end

	exec dbo.addLogo @jobNumber, @curLogo, @insertDir, @logoExtFileName, 
			@Ret output, @logoGUID36 output, @thisLogoID output
	if @Ret = 1
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	declare @addTime as smalldatetime
	set @addTime = getdate()

	--ȡ����˵�������
	declare @addManName nvarchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')

	--�Ǽ�ά����Ϣ��
	update userInfo
	set modiManID = @addManID, modiManName = @addManName, modiTime = @addTime
	where jobNumber = @jobNumber

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @addTime, '����û�Logo', @addManName
												+ '������û�['+ @jobNumber +']��һ��Logo��')
GO

drop PROCEDURE delUserLogo
/*
	name:		delUserLogo
	function:	4.ɾ��ָ���û��ĵ�ǰͼƬ
				ע�⣺����Ҫ�û�ͼƬ�ı���������ģ�����ɾ����Ҫ���⴦��
	input: 
				@jobNumber varchar(10),		--����
				@curLogo int,				--��ǰͼƬ�ı��

				@delManID varchar(10) output,--ɾ���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output,	--�����ɹ���ʶ
							0:�ɹ���1��Ҫɾ����ͼƬ�����ڣ�2:���û���Ϣ��������������9:δ֪����
				@logoGUID36 varchar(36) output,--��ǰͼƬ���ļ���
				@thisLogoID int output		--ɾ����ǰ��ͼƬ�ı��
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE delUserLogo
	@jobNumber varchar(10),		--����
	@curLogo int,				--��ǰͼƬ�ı��

	@delManID varchar(10) output,--ɾ���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@Ret int output,			--�����ɹ���ʶ
	@logoGUID36 varchar(36) output,--��ǰͼƬ���ļ���
	@thisLogoID int output		--ɾ����ǰ��ͼƬ�ı��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @thisLogoID = @curLogo

	--�жϵ�ǰͼƬ�Ƿ����
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @jobNumber)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	exec dbo.delLogo @jobNumber, @curLogo, @Ret output, @logoGUID36 output, @thisLogoID output
	if @Ret = 2
	begin
		set @Ret = 9
		return
	end

	declare @delTime as smalldatetime
	set @delTime = getdate()

	--ȡɾ���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽ�ά����Ϣ��
	update userInfo
	set modiManID = @delManID, modiManName = @delManName, modiTime = @delTime
	where jobNumber = @jobNumber

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, 'ɾ���û�Logo', @delManName
												+ 'ɾ�����û�['+ @jobNumber +']��һ��Logo��')
GO


drop PROCEDURE queryUserLockMan
/*
	name:		queryUserLockMan
	function:	5.��ѯָ���û��Ƿ��������ڱ༭
	input: 
				@jobNumber varchar(10),		--����
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1����ѯ���������Ǹù��ŵ��û�������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˹���
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE queryUserLockMan
	@jobNumber varchar(10),		--����
	@Ret		int output,		--�����ɹ���ʶ
	@lockManID varchar(10) output--��ǰ���ڱ༭���˹���
	WITH ENCRYPTION 
AS
	set @Ret = 1
	set @lockManID = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	set @Ret = 0
GO

drop PROCEDURE lockUser4Edit
/*
	name:		lockUser4Edit
	function:	6.�����û��༭������༭��ͻ
	input: 
				@jobNumber varchar(10),		--����
				@lockManID varchar(10) output,	--�����ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�������û������ڣ�2:Ҫ�������û����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE lockUser4Edit
	@jobNumber varchar(10),		--����
	@lockManID varchar(10) output,	--�����ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output	--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ�Ա�Ƿ����
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update userInfo 
	set lockManID = @lockManID 
	where jobNumber = @jobNumber
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����û��༭', 'ϵͳ����' + @lockManName
												+ '��Ҫ���������û�['+ @jobNumber +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockUserEditor
/*
	name:		unlockUserEditor
	function:	7.�ͷ��û��༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@jobNumber varchar(10),		--����
				@lockManID varchar(10) output,	--�����ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE unlockUserEditor
	@jobNumber varchar(10),		--����
	@lockManID varchar(10) output,	--�����ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin 
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update userInfo set lockManID = '' where jobNumber = @jobNumber
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
	values(@lockManID, @lockManName, getdate(), '�ͷ��û��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����û�['+ @jobNumber +']�ı༭����')
GO

drop PROCEDURE updateUserInfo
/*
	name:		updateUserInfo
	function:	8.����ָ�����û���Ϣ
	input: 
				@jobNumber varchar(10),		--���ţ�����
				--������Ϣ��
				@cName nvarchar(30),		--����
				@pID varchar(18),			--���֤��
				@mobileNum varchar(20),		--�ֻ�����
				@telNum varchar(30),		--�绰����
				@e_mail varchar(30),		--E_mail��ַ
				@homeAddress nvarchar(100),	--סַ
				
				--������Ϣ��
				@clgCode char(3),			--����ѧԺ����
				@uCode varchar(8),			--����ʹ�õ�λ����

				--ά�����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ��û���Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-20
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2011-9-4ȥ����ɫ�����������ӽ�ɫ�ּ����ʹ���
				modi by lw 2011-9-12�޸��û���֧�ֶ��ؽ�ɫ��ȥ���û�Ȩ�ޱ����û�Ȩ�޸�Ϊ��̬���㡣
				modi by lw 2011-9-24�޸��û���Ϣ��ʱ�������޸����롣
*/
create PROCEDURE updateUserInfo
	@jobNumber varchar(10),		--���ţ�����
	--������Ϣ��
	@cName nvarchar(30),		--����
	@pID varchar(18),			--���֤��
	@mobileNum varchar(20),		--�ֻ�����
	@telNum varchar(30),		--�绰����
	@e_mail varchar(30),		--E_mail��ַ
	@homeAddress nvarchar(100),	--סַ
	
	--������Ϣ��
	@clgCode char(3),			--����ѧԺ����
	@uCode varchar(8),			--����ʹ�õ�λ����
	
	--ά�����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--ȡԺ�����ƺ�ʹ�õ�λ���ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)		--����ѧԺ���ơ�����ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update userInfo 
	set cName = @cName, pID = @pID, mobileNum = @mobileNum, telNum = @telNum, e_mail = @e_mail, homeAddress = @homeAddress,
		--������Ϣ��
		clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����û���Ϣ', '�û�' + @modiManName 
												+ '�������û�['+ @jobNumber +']����Ϣ��')
GO

drop PROCEDURE delUserInfo
/*
	name:		delUserInfo
	function:	10.ɾ��ָ�����û�
	input: 
				@jobNumber varchar(10),			--����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1�����û������ڣ�2:Ҫɾ�����û���Ϣ��������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-6-7���ָô洢����û��ִ��ɾ������
*/
create PROCEDURE delUserInfo
	@jobNumber varchar(10),			--����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����û��Ƿ����
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete sysUserInfo where userID = @jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end

		delete userInfo where jobNumber = @jobNumber
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���û�', '�û�' + @delManName
												+ 'ɾ�����û�['+ @jobNumber +']����Ϣ��')

GO
--���ԣ�
declare @delManID varchar(10), @Ret int
set @delManID = '2010112301'
exec dbo.delUserInfo '1234561234', @delManID output, @Ret output
select @Ret

select * from userInfo
delete userInfo where jobNumber=''
update userInfo
set lockManID = null

