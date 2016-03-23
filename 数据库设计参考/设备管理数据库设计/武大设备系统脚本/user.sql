use ydepdc211
/*
	����豸����ϵͳ-ϵͳ�û������
	author:		¬έ
	�ͻ�Ҫ��
	�û��ּ����⣺
	1.�û���������У����Ժ�������Ҽ������Ե��ĵ�Ȩ�޷ֱ�Ϊ��ȫУ��ȫԺ��ȫ���ҵ��豸.ʹ�ý�ɫ�ּ������ݶ���Ĳ�����ΧԼ��ʵ��!
	2.֧���οͣ�ֻ�ܲ�ѯ���������ɱ���
	CreateDate:	2010-11-22
	UpdateDate: by lw 2011-9-12 �޸��û���֧�ֶ��ؽ�ɫ��ȥ���û�Ȩ�ޱ����û�Ȩ�޸�Ϊ��̬���㡣
				
*/
select * from college
select * from useunit
select top 200 clgCode, clgName, manager, inputCode from college where isOff='0' and inputCode like '0%' order by inputCode

--1.ϵͳ�û���Ϣ�� ��userInfo����
drop TABLE userInfo
CREATE TABLE userInfo
(
	jobNumber varchar(10) not null,		--���ţ�����
	
	--������Ϣ��
	cName nvarchar(30) not null,		--����
	pID varchar(18) null,				--���֤��
	mobileNum varchar(20) null,			--�ֻ�����
	telNum varchar(30) null,			--�绰����
	e_mail varchar(30) null,			--E_mail��ַ
	homeAddress nvarchar(100) null,		--סַ
	
	--������Ϣ��
	clgCode char(3) not null,			--����ѧԺ����
	clgName nvarchar(30) not null,		--����ѧԺ����:�������
	uCode varchar(8) null,				--����ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) null,			--����ʹ�õ�λ����:�������
	
	--ϵͳ��¼��Ϣ��
	sysUserName varchar(30) not null,	--�û���:Ҫ��Ψһ�Լ��
	sysUserDesc nvarchar(100) null,		--ϵͳ�û�����������
	
	--modi by lw 2011-7-5��Ϊʹ�ü��ܳ���Ҫ���ֶγ����ӳ���
	sysPassword varchar(128) null,		--ϵͳ��¼���룺����Ҫʹ�ü����㷨���ܣ�
	pswProtectQuestion varchar(40) null,--���뱣������
	psqProtectAnswer varchar(40) null,	--���뱣������Ĵ�

	isOff int default(0),				--�Ƿ�ע����0->δע����1->��ע��
	setOffDate smalldatetime,			--ע������

	--����ά�����:
	modiManID varchar(10) null,		--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10) null,			--��ǰ���������༭�˹���
CONSTRAINT [PK_memberInfo] PRIMARY KEY CLUSTERED 
(
	[jobNumber] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
select * from college

insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('2010112301','¬έ','001','��ί�칫��','lw','930522','2010112301')


drop PROCEDURE checkSuperManRights
/*
	name:		checkSuperManRights
	function:	0.1.���ָ���û��Ƿ�ӵ�С������û�����ɫ�����ӵ�У���鳬���û��Ƿ�ӵ��ȫ����ϵͳȨ��
				���δӵ������ʾ�û���Ҫ����
	input: 
				@jobNumber varchar(10)		--���ţ�����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:����Ҫ���£�1����Ҫ���£�2�����û�������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-8
	UpdateDate: 
*/
create PROCEDURE checkSuperManRights
	@jobNumber varchar(10),			--����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����û��Ƿ����
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--������
	begin
		set @Ret = 2
		return
	end

	--�����û��Ƿ�ӵ�С������û�����ɫ��
	set @count = (select COUNT(*) from sysUserRole 
					where jobNumber = @jobNumber and sysRoleID = 1 and sysRoleName='�����û�')
	if (@count = 0)	--������
	begin
		set @Ret = 0
		return
	end
	
	--��顰�����û�����ɫ�Ƿ�ӵ����ȫ����ϵͳȨ�ޣ�
	set @count = (select COUNT(*) from sysRight
					where canUse='Y' and rightKind * 1000 + rightClass * 100 + rightItem 
							not in (select rightKind * 1000 + rightClass * 100 + rightItem 
									from sysRoleRight where sysRoleID = 1))
	if (@count > 0)	--����
	begin
		set @Ret = 1
		return
	end

	--��顰�����û�����ɫ�Ƿ�ӵ����ȫ����ϵͳ��Դ�Ĳ�������������������Χ��
	declare @rightKind smallint, @rightClass smallint, @rightItem smallint
	declare @oprEName varchar(20)	--������Ӣ������

	declare tar cursor for
	select d.rightKind, d.rightClass, d.rightItem, d.oprEName
	from sysRight s inner join sysDataOpr d on s.rightKind = d.rightKind and s.rightClass = d.rightClass
			and s.rightItem = d.rightItem
	where canUse='Y'
	OPEN tar
	FETCH NEXT FROM tar INTO @rightKind, @rightClass, @rightItem, @oprEName
	WHILE @@FETCH_STATUS = 0
	begin
		set @count = (select COUNT(*) from sysRoleDataOpr
						where sysRoleID = 1 and rightKind = @rightKind and rightClass = @rightClass 
								and rightItem = @rightItem and oprEName = @oprEName)
		if (@count <> 1)
		begin
			set @Ret = 1
			CLOSE tar
			DEALLOCATE tar
			return
		end
		declare @maxPartSize int, @partSize int	--���������Χ
		--��ȡ�����������ʷ�Χ��
		set @maxPartSize = (select max(partSize) from sysRightPartSize 
							where rightKind = @rightKind and rightClass = @rightClass 
								and rightItem = @rightItem)
		--��ȡ�����û��Ĳ�����Χ��
		set @partSize = isnull((select oprPartSize from sysRoleDataOpr
								where sysRoleID = 1 and rightKind = @rightKind and rightClass = @rightClass 
										and rightItem = @rightItem and oprEName = @oprEName),0)
		if (@maxPartSize <> @partSize)
		begin
			set @Ret = 1
			CLOSE tar
			DEALLOCATE tar
			return
		end

		FETCH NEXT FROM tar INTO @rightKind, @rightClass, @rightItem, @oprEName
	end
	CLOSE tar
	DEALLOCATE tar
	
	set @Ret = 0
GO
--���ԣ�
declare @Ret int	--�����ɹ���ʶ
exec dbo.checkSuperManRights '00200977',@Ret output
select @Ret

delete sysRoleDataOpr where sysRoleID=1 and rightKind = 1

drop PROCEDURE updateSuperManRights
/*
	name:		updateSuperManRights
	function:	0.2.���³����û�Ȩ��
	input: 
				@updateManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1���޳����û���ɫ��9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-8
	UpdateDate: 
*/
create PROCEDURE updateSuperManRights
	@updateManID varchar(10),		--�����˹���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�жϳ����û���ɫ�Ƿ����
	declare @count as int
	set @count = (select COUNT(*) from sysRole 
					where sysRoleID = 1 and sysRoleName='�����û�')
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--��顰�����û�����ɫ�Ƿ�ӵ����ȫ����ϵͳȨ�ޣ�
	set @count = (select COUNT(*) from sysRight
					where canUse='Y' and rightKind * 1000 + rightClass * 100 + rightItem 
							not in (select rightKind * 1000 + rightClass * 100 + rightItem 
									from sysRoleRight where sysRoleID = 1))
	if (@count > 0)	--����
	begin
		insert sysRoleRight(sysRoleID, rightName, rightEName, Url,
					rightType, rightKind, rightClass, rightItem, rightDesc)
		select 1, rightName, rightEName, Url,
					rightType, rightKind, rightClass, rightItem, rightDesc 
		from sysRight
		where canUse='Y' and rightKind * 1000 + rightClass * 100 + rightItem 
				not in (select rightKind * 1000 + rightClass * 100 + rightItem 
						from sysRoleRight where sysRoleID = 1)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
	end

	--��顰�����û�����ɫ�Ƿ�ӵ����ȫ����ϵͳ��Դ�Ĳ�������������������Χ��
	declare @rightKind smallint, @rightClass smallint, @rightItem smallint
	declare @oprEName varchar(20)	--������Ӣ������

	declare tar cursor for
	select d.rightKind, d.rightClass, d.rightItem, d.oprEName
	from sysRight s inner join sysDataOpr d on s.rightKind = d.rightKind and s.rightClass = d.rightClass
			and s.rightItem = d.rightItem
	where canUse='Y'
	OPEN tar
	FETCH NEXT FROM tar INTO @rightKind, @rightClass, @rightItem, @oprEName
	WHILE @@FETCH_STATUS = 0
	begin
		declare @maxPartSize int, @partSize int	--���������Χ
		--��ȡ�����������ʷ�Χ��
		set @maxPartSize = (select max(partSize) from sysRightPartSize 
							where rightKind = @rightKind and rightClass = @rightClass 
								and rightItem = @rightItem)
		set @count = (select COUNT(*) from sysRoleDataOpr
						where sysRoleID = 1 and rightKind = @rightKind and rightClass = @rightClass 
								and rightItem = @rightItem and oprEName = @oprEName)
		if (@count = 0)
		begin
			insert sysRoleDataOpr(sysRoleID, sortNum, rightKind, rightClass, rightItem, oprType,
									oprName, oprEName, oprDesc, oprPartSize)
			select 1, sortNum, rightKind, rightClass, rightItem, oprType,
					oprName, oprEName, oprDesc, @maxPartSize
			from sysDataOpr
			where rightKind = @rightKind and rightClass = @rightClass 
					and rightItem = @rightItem and oprEName = @oprEName
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				CLOSE tar
				DEALLOCATE tar
				return
			end    
		end
		else
		begin
			set @partSize = isnull((select oprPartSize from sysRoleDataOpr
								where sysRoleID = 1 and rightKind = @rightKind and rightClass = @rightClass 
										and rightItem = @rightItem and oprEName = @oprEName),0)
			if (@maxPartSize <> @partSize)
			begin
				update sysRoleDataOpr
				set oprPartSize = @maxPartSize
				where sysRoleID = 1 and rightKind = @rightKind and rightClass = @rightClass 
										and rightItem = @rightItem and oprEName = @oprEName
				if @@ERROR <> 0 
				begin
					set @Ret = 9
					CLOSE tar
					DEALLOCATE tar
					return
				end    
			end
		end
		FETCH NEXT FROM tar INTO @rightKind, @rightClass, @rightItem, @oprEName
	end
	CLOSE tar
	DEALLOCATE tar
	
	--ȡ����˵�������
	declare @updateManName nvarchar(30)
	set @updateManName = isnull((select userCName from activeUsers where userID = @updateManID),'')
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@updateManID, @updateManName, GETDATE(), 
								'���³����û���Ȩ��','ϵͳ����' + @updateManName + 
								'��Ҫ������˳����û���Ȩ�ޱ�')
	set @Ret = 0
GO
--���ԣ�
declare @Ret int	--�����ɹ���ʶ
exec dbo.updateSuperManRights '00200977',@Ret output
select @Ret

drop FUNCTION getSysUserRole
/*
	name:		getSysUserRole
	function:	1.�����û����Ż�ȡ�û���ɫ��
	input: 
				@jobNumber varchar(10)		--���ţ�����
	output: 
				return varchar(1024)		--�û���ɫ���������ɫ�����á�,���ָ�
	author:		¬έ
	CreateDate:	2012-6-9
	UpdateDate: 
*/
create FUNCTION getSysUserRole
(  
	@jobNumber varchar(10)		--���ţ�����
)  
RETURNS varchar(1024)
WITH ENCRYPTION
AS      
begin
	declare @result as varchar(1024), @i as int
	set @result = ''; set @i = 0;
	declare @sysRoleName varchar(50)	--��ɫ������
	declare tar cursor for
	select sysRoleName from sysUserRole
	where jobNumber = @jobNumber
	order by sysRoleID
	OPEN tar
	FETCH NEXT FROM tar INTO @sysRoleName
	WHILE @@FETCH_STATUS = 0
	begin
		set @result = @result + @sysRoleName + ','
		set @i = @i+1
		if (@i >= 20)
		begin
			set @result = SUBSTRING(@result,1,len(@result) -1) + '...,'
			break
		end
		FETCH NEXT FROM tar INTO @sysRoleName
	end
	CLOSE tar
	DEALLOCATE tar
	if (len(@result) > 0 )
		set @result = SUBSTRING(@result,1,len(@result) -1)
	return @result
end
--���ԣ�
select dbo.getSysUserRole('00000021')

select * from userInfo
select * from sysUserRole

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
				
				--ϵͳ��¼��Ϣ��
				@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
				@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
				@sysPassword varchar(128),	--ϵͳ��¼����
				@pswProtectQuestion varchar(40),--���뱣������
				@psqProtectAnswer varchar(40),	--���뱣������Ĵ�

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
	
	--ϵͳ��¼��Ϣ��
	@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
	@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
	@sysPassword varchar(128),	--ϵͳ��¼����
	@pswProtectQuestion varchar(40),--���뱣������
	@psqProtectAnswer varchar(40),	--���뱣������Ĵ�

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
	
	--��������Ƿ�Ψһ��
	set @count = (select count(*) from userInfo where sysUserName = @sysUserName)
	if @count > 0
	begin
		set @Ret = 2
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
				--ϵͳ��¼��Ϣ��
				sysUserName, sysUserDesc,
				sysPassword, pswProtectQuestion, psqProtectAnswer,
				--����ά�����:
				modiManID, modiManName, modiTime)
	values(@jobNumber,
				--������Ϣ��
				@cName, @pID, @mobileNum, @telNum, @e_mail, @homeAddress,
				--������Ϣ��
				@clgCode, @clgName, @uCode, @uName,
				--ϵͳ��¼��Ϣ��
				@sysUserName, @sysUserDesc,
				@sysPassword, @pswProtectQuestion, @psqProtectAnswer,
				--����ά�����:
				@createManID, @createManName, @createTime)

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'ע���û�','ϵͳ����' + @createManName + 
								'��Ҫ��ע�����û�[' + @cName + '('+ @sysUserName +')]����Ϣ��')
GO

drop PROCEDURE clearUserRole
/*
	name:		clearUserRole
	function:	1.1.�����ɫ
	input: 
				@jobNumber varchar(10),			--����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1�����û������ڣ�2:��ǰ�û���Ϣ��������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-12
	UpdateDate: 
*/
create PROCEDURE clearUserRole
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
	
	delete sysUserRole where jobNumber = @jobNumber
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '����û���ɫ', '�û�' + @delManName
												+ '������û�['+ @jobNumber +']��ȫ����ɫ��')

GO

drop PROCEDURE addUserRole
/*
	name:		addUserRole
	function:	1.2.����û���ɫ
	input: 
				@jobNumber varchar(10),		--����
				@sysRoleID smallint,		--��ɫID

				--����ά�����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1.���û������ڣ�2�����û��������������༭��3:�ý�ɫ�Ѿ��Ǽǹ���9:δ֪����
	author:		¬έ
	CreateDate:	2011-9-12
	UpdateDate: 
*/
create PROCEDURE addUserRole
	@jobNumber varchar(10),		--����
	@sysRoleID smallint,		--��ɫID

	--����ά�����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
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
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--����ɫ�Ƿ�Ψһ��
	set @count = (select count(*) from sysUserRole where jobNumber = @jobNumber and sysRoleID = @sysRoleID)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--��ȡ�û�����
	declare @sysUserName varchar(30)
	set @sysUserName = isnull((select sysUserName from userInfo where jobNumber = @jobNumber),'')
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--��ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = isnull((select sysRoleName from sysRole where sysRoleID = @sysRoleID),'')

	insert sysUserRole(jobNumber, sysUserName, sysRoleID, sysRoleName, sysRoleType)
	select @jobNumber, @sysUserName, sysRoleID, sysRoleName, sysRoleType 
	from sysRole
	where sysRoleID = @sysRoleID

	set @updateTime = getdate()
	update userInfo 
	set --ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����û���ɫ', '�û�' + @modiManName 
												+ '���û�['+ @jobNumber +']������˽�ɫ['+ @sysRoleName +']��')
GO


drop PROCEDURE checkJobNumber
/*
	name:		checkJobNumber
	function:	2.1.��鹤���Ƿ�Ψһ
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


drop PROCEDURE checkSysUserName
/*
	name:		checkSysUserName
	function:	2.2.����û����Ƿ�Ψһ
	input: 
				@sysUserName varchar(30),		--ϵͳ��¼�û���
	output: 
				@Ret		int output
							0:Ψһ��>1����Ψһ��-1��δ֪����
	author:		¬έ
	CreateDate:	2010-5-30
	UpdateDate: 
*/
create PROCEDURE checkSysUserName
	@sysUserName varchar(30),		--ϵͳ��¼�û���
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from userInfo where sysUserName = @sysUserName)
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
				
				--ϵͳ��¼��Ϣ��
				@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
				@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
				--@sysPassword varchar(128),	--ϵͳ��¼����	del by lw 2011-9-24
				@pswProtectQuestion varchar(40),--���뱣������
				@psqProtectAnswer varchar(40),	--���뱣������Ĵ�

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
	
	--ϵͳ��¼��Ϣ��
	@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
	@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
	--@sysPassword varchar(128),	--ϵͳ��¼����
	@pswProtectQuestion varchar(40),--���뱣������
	@psqProtectAnswer varchar(40),	--���뱣������Ĵ�

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
		--��½��Ϣ��
		sysUserName = @sysUserName, sysUserDesc = @sysUserDesc,
		pswProtectQuestion = @pswProtectQuestion, psqProtectAnswer = @psqProtectAnswer,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����û���Ϣ', '�û�' + @modiManName 
												+ '�������û�['+ @jobNumber +']����Ϣ��')
GO

DROP PROCEDURE userSetOff
/*
	name:		userSetOff
	function:	9.ע��ָ�����û�
	input: 
				@jobNumber varchar(10),			--���ţ�����
				@setOffDate smalldatetime,		--ע������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ��û���Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE userSetOff
	@jobNumber varchar(10),		--���ţ�����
	@setOffDate smalldatetime,		--ע������

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

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update userInfo
	set isOff = 1, setOffDate = @setOffDate,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 'ע���û�', '�û�' + @modiManName 
												+ 'ע�����û�['+ @jobNumber +']��')
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
		--delete sysUserRight where jobNumber = @jobNumber --�ñ��Ѿ��ϳ���
		delete userInfo where jobNumber = @jobNumber --ϵͳ�Զ�����ɾ�����û���ɫ��
	commit tran
	
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
set @delManID = '00000008'
exec dbo.delUserInfo '00000001', @delManID output, @Ret output
select @Ret

select * from userInfo
delete userInfo where jobNumber=''
update userInfo
set lockManID = null

DROP PROCEDURE userSetActive
/*
	name:		userSetActive
	function:	11.����ָ�����û�
	input: 
				@jobNumber varchar(10),			--����

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ��û���Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-6-7
	UpdateDate: 
*/
create PROCEDURE userSetActive
	@jobNumber varchar(10),		--����

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

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update userInfo
	set isOff = 0, setOffDate = null,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����û�', '�û�' + @modiManName 
												+ '�������û�['+ @jobNumber +']��')
GO


alter table activeUsers alter column psw	varchar(128) not null			--��¼����
select * from activeUsers
--2.��ǰ��û���(activeUsers)��
truncate table activeUsers
drop table activeUsers
CREATE TABLE activeUsers
(
	userID varchar(10) not null,		--�û�����
	userName varchar(30) not null,		--�û���
	userCName nvarchar(30) not null,	--�û�������
	--modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
	psw	varchar(128) not null,			--��¼����
	userIP varchar(40) not null,		--�Ự�ͻ���IP
	dynaPsw	varchar(36) not null,		--��̬��Կ
	loginTime smalldatetime not null,	--��¼ʱ��
 CONSTRAINT [PK_activeUsers] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

use epdc2
drop PROCEDURE login
/*
	name:		login
	function:	1.�û���¼�������û����û����������Ƿ���ȷ������ȷ�����ǰ�ĵ�¼���Ǽǵ�ǰ��״̬
	input: 
				@userName varchar(30) output,--�û���	modi by lw 2011-6-28,֧�ֹ��ŵ�¼�����Ը�Ϊ�����Ͳ���
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1���û����������2:ϵͳ��������û��ı༭��ʱ����9��δ֪����
				@dynaPsw varchar(36) output,		��ɹ����Ŷ�̬��Կ
				@userCName nvarchar(30) output,	��ɹ������û�������
				@userID varchar(10) output,		--�û�����
				--add by lw 2011-6-5 ����ǰ̨Ȩ�޿��Ƶ���Ҫ���ӵĲ�����
				@pID varchar(18) output,		--���֤��
				@clgCode char(3) output,		--����ѧԺ����
				@clgName nvarchar(30) output,	--����ѧԺ����
				@uCode varchar(8) output,		--����ʹ�õ�λ����
				@uName nvarchar(30) output,		--����ʹ�õ�λ����
				@sysUserDesc nvarchar(100) output,--ϵͳ�û�����������
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2011-6-5 ����ǰ̨Ȩ�޿��Ƶ���Ҫ���ӷ����û��Ļ�����Ϣ,ɾ������Ȩ���б�
				modi by lw 2011-6-28���ӹ��ŵ�¼
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2011-9-4���ӽ�ɫ�ּ�����
				modi by lw 2011-9-19��Ϊ�û���ɫ��Ƶ��޸Ķ�����Ӧ�޸ģ�����ȡ�û���ɫ����Ϣ������һ���߼������еķ���
									����ȡ�û���Ȩ�޸�Ϊһ����̬����Ĵ洢���̡�
*/
create PROCEDURE login
	@userName varchar(30) output,	--�û���
	@psw	varchar(128),			--��¼����
	@userIP varchar(40),			--�Ự�ͻ���IP

	@Ret	int output,				--�����ɹ���ʶ
	@dynaPsw varchar(36) output,	--��̬��Կ
	@userCName nvarchar(30) output, --�û�������
	@userID varchar(10) output,		--�û�����
	--add by lw 2011-6-5 ����ǰ̨Ȩ�޿��Ƶ���Ҫ���ӵĲ�����
	@pID varchar(18) output,		--���֤��
	@clgCode char(3) output,		--����ѧԺ����
	@clgName nvarchar(30) output,	--����ѧԺ����
	@uCode varchar(8) output,		--����ʹ�õ�λ����
	@uName nvarchar(30) output,		--����ʹ�õ�λ����
	@sysUserDesc nvarchar(100) output--ϵͳ�û�����������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����û����������Ƿ���ȷ������ȡ�û����������ƺ͹��ŵȻ�����Ϣ��
	select @userName = sysUserName, @userCName = cName, @userID = jobNumber, @pID = pID,
			@clgCode = clgCode, @clgName = clgName, @uCode = uCode, @uName = uName,
			@sysUserDesc = sysUserDesc
	from userInfo
	where (sysUserName = @userName or jobNumber = @userName) and sysPassword = @psw
	if (@userID is null)
	begin
		set @Ret = 1
		return
	end
	--����Ƿ���ǰ�е�¼��
	declare @count int
	set @count=(select count(*) from activeUsers where userID = @userID)
	if @count > 0
	begin
		delete activeUsers where userName = @userName	--�����ǰ�ĵ�¼
	end

	--������û����еı༭����
	declare @retUnlock as int
	exec dbo.unlockAllEditor @userID, @retUnlock output
	if (@retUnlock <> 0)
	begin
		set @Ret = 2
		return
	end

	--�Ǽǵ�¼��Ϣ��
	set @dynaPsw = (select newid())		--���ɶ�̬����
	declare @loginTime smalldatetime	--��¼ʱ��
	set @loginTime = getdate()
	insert activeUsers(userID, userName, userCName, psw, userIP, dynaPsw, loginTime)
	values(@userID, @userName, @userCName, @psw, @userIP, @dynaPsw, @loginTime)

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userCName, @loginTime, '��¼', '�û�' + @userCName 
								+ '��IPΪ['+ @userIP +']�Ĺ���վ�ϵ�¼��ϵͳ��\r\nͬʱϵͳ����˸��û������������ϵĵ�¼��')

GO

--���ԣ�
declare	@Ret int , @dynaPsw varchar(36), @userCName varchar(30), @userID int
declare	@pID varchar(18), @clgCode char(3),	@clgName nvarchar(30), @uCode varchar(8)
declare	@uName nvarchar(30), @sysUserDesc nvarchar(100)
exec dbo.login '00200977', '00200977', '127.0.0.1', @Ret output, @dynaPsw output, @userCName output, @userID output,
	@pID output, @clgCode output, @clgName output, @uCode output,
	@uName output, @sysUserDesc output
select @Ret, @dynaPsw, @userCName, @userID,
	@pID, @clgCode, @clgName, @uCode,
	@uName, @sysUserDesc
update userInfo
set sysPassword ='00200977'
where jobNumber = '00200977'


select sysPassword, LEN(sysPassword) from userInfo where jobNumber = '00200977'
select * from userInfo


drop PROCEDURE reLogin
/*
	name:		reLogin
	function:	1.1.�����û����µ�¼�������û����û����������Ƿ���ȷ������ȷ����Ƿ�Ϊ�����û�������������û�����
				������ʹ���ڳ�ʱʱ���µ�¼��
	input: 
				@userName varchar(30) output,--�û���	modi by lw 2011-6-28,֧�ֹ��ŵ�¼�����Ը�Ϊ�����Ͳ���
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1���û����������
							2����Ч�û�����������ԭ�û�������������վ��¼��ϵͳ����Ա�߳�ϵͳ����
							9��δ֪����
				@dynaPsw varchar(36) output,		��ɹ����Ŷ�̬��Կ
				@userCName nvarchar(30) output,	��ɹ������û�������
				@userID varchar(10) output,		--�û�����
				--add by lw 2011-6-5 ����ǰ̨Ȩ�޿��Ƶ���Ҫ���ӵĲ�����
				@pID varchar(18) output,		--���֤��
				@clgCode char(3) output,		--����ѧԺ����
				@clgName nvarchar(30) output,	--����ѧԺ����
				@uCode varchar(8) output,		--����ʹ�õ�λ����
				@uName nvarchar(30) output,		--����ʹ�õ�λ����
				@sysUserDesc nvarchar(100) output,--ϵͳ�û�����������
	author:		¬έ
	CreateDate:	2012-8-15
	UpdateDate: 
*/
create PROCEDURE reLogin
	@userName varchar(30) output,	--�û���
	@psw	varchar(128),			--��¼����
	@userIP varchar(40),			--�Ự�ͻ���IP

	@Ret	int output,				--�����ɹ���ʶ
	@dynaPsw varchar(36) output,	--��̬��Կ
	@userCName nvarchar(30) output, --�û�������
	@userID varchar(10) output,		--�û�����
	--add by lw 2011-6-5 ����ǰ̨Ȩ�޿��Ƶ���Ҫ���ӵĲ�����
	@pID varchar(18) output,		--���֤��
	@clgCode char(3) output,		--����ѧԺ����
	@clgName nvarchar(30) output,	--����ѧԺ����
	@uCode varchar(8) output,		--����ʹ�õ�λ����
	@uName nvarchar(30) output,		--����ʹ�õ�λ����
	@sysUserDesc nvarchar(100) output--ϵͳ�û�����������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����û����������Ƿ���ȷ������ȡ�û����������ƺ͹��ŵȻ�����Ϣ��
	select @userName = sysUserName, @userCName = cName, @userID = jobNumber, @pID = pID,
			@clgCode = clgCode, @clgName = clgName, @uCode = uCode, @uName = uName,
			@sysUserDesc = sysUserDesc
	from userInfo
	where (sysUserName = @userName or jobNumber = @userName) and sysPassword = @psw
	if (@userID is null)
	begin
		set @Ret = 1
		return
	end
	
	--����Ƿ���ǰ�е�¼��
	declare @oldUserIP varchar(40)		--�ǼǵĻỰ�ͻ���IP
	select @oldUserIP = userIP, @dynaPsw = dynaPsw from activeUsers where userID = @userID
	if (@oldUserIP is null or @oldUserIP<>@userIP)
	begin
		set @Ret = 2
		return
	end

	set @Ret = 0
GO

drop PROCEDURE isActiveUser
/*
	name:		isActiveUser
	function:	2.����Ƿ�Ϊ��û�
	input: 
				@userName varchar(30),		--�û���
				@psw	varchar(128),		--��¼����
	output: 
				@userIP varchar(40) output,	--�Ự�ͻ���IP
				@Ret		int output		--��ʶ
							1:�ǣ�0�����ǣ�-1��δ֪����
	author:		¬έ
	CreateDate:	2010-2-1
	UpdateDate: modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2011-9-19ɾ����̬������֤�����ỰIP��Ϊ����ֵ����ԭ��֤��û��Ĺ��̵���ΪvalidateActiveUser����
*/
create PROCEDURE isActiveUser
	@userName varchar(30),		--�û���
	@psw	varchar(128),		--��¼����
	@userIP varchar(40) output,	--�Ự�ͻ���IP

	@Ret		int output		--��ʶ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers where userName = @userName and psw = @psw)
	if @count > 0
	begin
		set @userIP = (select userIP from activeUsers where userName = @userName and psw = @psw)
		set @Ret = 1
	end
	else
		set @Ret = 0
GO

drop PROCEDURE validateActiveUser
/*
	name:		validateActiveUser
	function:	2.1.ʹ�����롢IP����̬������֤�û��Ƿ�Ϊ�Ϸ���û�
	input: 
				@userName varchar(30),		--�û���
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
				@dynaPsw varchar(36),		--��̬��Կ
	output: 

				@Ret		int output		--��ʶ
							1:�ǣ�0�����ǣ�-1��δ֪����
	author:		¬έ
	CreateDate:	2011-9-20
	UpdateDate: 
*/
create PROCEDURE validateActiveUser
	@userName varchar(30),		--�û���
	@psw	varchar(128),		--��¼����
	@userIP varchar(40),		--�Ự�ͻ���IP
	@dynaPsw varchar(36),		--��̬��Կ
	@Ret		int output		--��ʶ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers 
								where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw)
	if @count > 0
		set @Ret = 1
	else
		set @Ret = 0
GO

drop PROCEDURE logout
/*
	name:		logout
	function:	3.��ȫ�˳�
	input: 
				@userID varchar(10),		--�û�ID
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
				@dynaPsw varchar(36),		--��̬��Կ
	output: 
				@Ret		int output		--��ʶ
							1:�ǣ�0��û�и��û���2�����ͷŸ��û����ܵı༭����ʱ�����-1��δ֪����
	author:		¬έ
	CreateDate:	2010-2-1
	UpdateDate: 2010-5-10���ӹ�����־����
				modi by lw 2011-6-28�����ͷ��û����ܴ��ڵı༭��
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
*/
create PROCEDURE logout
	@userID varchar(10),		--�û�ID
	@psw	varchar(128),		--��¼����
	@userIP varchar(40),		--�Ự�ͻ���IP
	@dynaPsw varchar(36),		--��̬��Կ

	@Ret		int output		--��ʶ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers 
								where @userID= @userID and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw)
	declare @userCName nvarchar(30),@userName varchar(30)	--�û�������\�û���

	if @count > 0
	begin
		--��ȡ�û�������\�û����֤�ţ�
		select @userCName = userCName, @userName = userName
		from activeUsers 
		where userId = @userId and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
		--ɾ����û���
		delete activeUsers 
		where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
		set @Ret = 1
		--������ܵ��û��༭����
		declare @retUnlock as int
		exec dbo.unlockAllEditor @userID, @retUnlock output
		if (@retUnlock <> 0)
		begin
			set @Ret = 2
			return
		end
	end
	else
		set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userCName, getdate(), '�ǳ�', '�û�' + @userCName + '��ȫ���˳���ϵͳ��')
GO

drop PROCEDURE delActiveUser
/*
	name:		delActiveUser
	function:	3.1ɾ�������û�
	input: 
				@userID varchar(10),			--�û�����
				@delManID varchar(10),			--ɾ���˹���
	output: 
				@Ret		int output		--��ʶ
							1:�ǣ�0��û�и��û���-1��δ֪����
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: 
*/
create PROCEDURE delActiveUser
	@userID varchar(10),			--�û�����
	@delManID varchar(10),			--ɾ���˹���
	@Ret		int output	--��ʶ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers where userID = @userID)
	declare @userCName nvarchar(30), @userName varchar(30)	--�û�������\�û���¼��
	if @count > 0
	begin
		--��ȡ�û�������\�û����֤�ţ�
		select @userCName = userCName, @userName = userName
		from activeUsers 
		where @userID = userId 

		--�ͷŸ��û������б༭����
		declare @retUnlock as int
		exec dbo.unlockAllEditor @userID, @retUnlock output
		if (@retUnlock <> 0)
		begin
			set @Ret = -1
			return
		end

		--ɾ����û���
		delete activeUsers 
		where userId = @userID
		set @Ret = 1
	end
	else
	begin
		set @Ret = 0
		return
	end

	declare @delManCName nvarchar(30) --�û�������
	--��ȡ�û�������\�û����֤�ţ�
	select @delManCName = userCName
	from activeUsers 
	where userId  = @delManID

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManCName, getdate(), '��������û�', 
			'ϵͳ����Ա��'+ @delManCName + '���û���' + @userCName + '['+ @userName +']�߳���ϵͳ��')
GO

drop PROCEDURE getActiveUserInfo
/*
	name:		getActiveUserInfo
	function:	4.�����û����Ż�ȡָ���û��Ļ��Ϣ
	input: 
				@userID varchar(10),		--�û�����
	output: 
				@Ret		int output		--��ʶ
							1:�ɹ���0�����û����ڻ�û�֮�У�-1��δ֪����
				@psw	varchar(128) output,		--��¼����
				@userCName nvarchar(30) output,	--�û�������
				@userIP varchar(40) output,		--�Ự�ͻ���IP
				@dynaPsw varchar(36) output		--��̬��Կ
	author:		¬έ
	CreateDate:	2010-2-1
	UpdateDate:modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�

*/
create PROCEDURE getActiveUserInfo
	@userID varchar(10),			--�û�����

	@Ret	int output,				--��ʶ
	@psw	varchar(128) output,		--��¼����
	@userCName nvarchar(30) output,	--�û�������
	@userIP varchar(40) output,		--�Ự�ͻ���IP
	@dynaPsw varchar(36) output		--��̬��Կ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers where userID = @userID)
	if @count > 0
	begin
		set @Ret = 1
		select @psw = psw, @userCName = userCName, @userIP = userIP, @dynaPsw = dynaPsw
		from activeUsers 
		where userID = @userID
	end
	else
		set @Ret = 0
GO

drop PROCEDURE unlockAllEditor
/*
	name:		unlockAllEditor
	function:	5.�ͷ�ָ���û������б༭�������Ǹ����˺�ϵͳ����Աʹ�õĹ��ܣ�
				�ڽ���༭ϵͳ��ʱ��Ӧ������ע�������������ϵĵ�¼�����ͷ������Լ������ı༭
	input: 
				@userID varchar(10),		--�û�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2011-9-5����ϵͳ��ɫ���û��ı༭������
*/
create PROCEDURE unlockAllEditor
	@userID varchar(10),		--�û�����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	begin tran
		--�����ֵ����ı༭����
		update codeDictionary set lockManID = '' where lockManID = @userID	--�����ֵ�༭��
		update typeCodes set lockManID = '' where lockManID = @userID		--�豸��������༭��
		update country set lockManID = '' where lockManID = @userID			--����༭��
		update fundSrc set lockManID = '' where lockManID = @userID			--������Դ�༭��
		update appDir set lockManID = '' where lockManID = @userID			--ʹ�÷���༭��
		update college set lockManID = '' where lockManID = @userID			--ѧԺ��༭��
		update useUnit set lockManID = '' where lockManID = @userID			--ʹ�õ�λ�༭��
		update accountTitle set lockManID = '' where lockManID = @userID	--��ƿ�Ŀ�����ֵ��༭��
		update collegeCode set lockManID = '' where lockManID = @userID		--����������λ����ת����

		--ҵ�����ı༭����
		update eqpPlanInfo set lockManID = ''  where lockManID = @userID	--�ɹ��ƻ����༭��
		update eqpAcceptInfo set lockManID = '' where lockManID = @userID	--�������뵥�༭��
		update equipmentList set lockManID = '' where lockManID = @userID	--�豸��༭��
		--update equipmentAnnex set lockManID = '' where lockManID = @userID	--�豸�����༭��del by lw 2012-10-5
		update equipmentScrap set lockManID = '' where lockManID = @userID	--�豸���ϵ��༭��
		update equipmentAllocation set lockManID = '' where lockManID = @userID	--�豸�������༭��
		update eqpCheckInfo set lockManID = '' where lockManID = @userID	--�豸�������༭��
		update eqpCheckDetailInfo set lockManID = '' where lockManID = @userID	--�豸���������ϸ��༭��
		update statisticTemplate set lockManID = '' where lockManID = @userID	--ͳ��ģ���༭��

		--Ȩ�޿������ı༭����
		update sysRole set lockManID = '' where lockManID = @userID			--ϵͳ��ɫ�༭��
		update userInfo set lockManID = '' where lockManID = @userID		--ϵͳ�û��༭��

		--��ά���ı༭����
		update bulletinInfo set lockManID = '' where lockManID = @userID	--ϵͳ�����༭��
	commit tran
	set @Ret = 0

GO
--���ԣ�
declare @Ret int
exec dbo.unlockAllEditor '0000000001',@Ret output
select @Ret

drop PROCEDURE unlockAllUserLock
/*
	name:		unlockAllUserLock
	function:	5.1�ͷ������û��ı༭�������Ǹ�ϵͳ����Աʹ�õĹ��ܣ������������������������û�
	input: 
				@userID varchar(10),		--�û�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-10-7
	UpdateDate: 
*/
create PROCEDURE unlockAllUserLock
	@userID varchar(10),		--�û�����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	begin tran
		--ɾ��������������л�û���
		delete activeUsers 
		where userId <> @userID 

		--�ͷű༭����
		--�����ֵ����ı༭����
		update codeDictionary set lockManID = ''--�����ֵ�༭��
		update typeCodes set lockManID = ''		--�豸��������༭��
		update country set lockManID = ''		--����༭��
		update fundSrc set lockManID = ''		--������Դ�༭��
		update appDir set lockManID = ''		--ʹ�÷���༭��
		update college set lockManID = ''		--ѧԺ��༭��
		update useUnit set lockManID = ''		--ʹ�õ�λ�༭��
		update accountTitle set lockManID = ''	--��ƿ�Ŀ�����ֵ��༭��
		update collegeCode set lockManID = ''	--����������λ����ת����
		
		--ҵ�����ı༭����
		update eqpPlanInfo set lockManID = ''	--�ɹ��ƻ����༭��
		update eqpAcceptInfo set lockManID = ''	--�������뵥�༭��
		update equipmentList set lockManID = '' --�豸��༭��
		--update equipmentAnnex set lockManID = ''--�豸�����༭��del by lw 2012-10-5
		update equipmentScrap set lockManID = ''--�豸���ϵ��༭��
		update equipmentAllocation set lockManID = ''--�豸�������༭��
		update statisticTemplate set lockManID = ''	--ͳ��ģ���༭��
		update eqpCheckInfo set lockManID = ''	--�豸�������༭��
		update eqpCheckDetailInfo set lockManID = ''--�豸���������ϸ��༭��
		update eqpCheckInfo set lockManID = ''	--�豸�̵㵥�༭��

		--Ȩ�޿������ı༭����
		update sysRole set lockManID = ''			--ϵͳ��ɫ�༭��
		update userInfo set lockManID = ''			--ϵͳ�û��༭��

		--��ά���ı༭����
		update bulletinInfo set lockManID = ''		--ϵͳ�����༭��
	commit tran
	set @Ret = 0

GO
--���ԣ�
declare @Ret int
exec dbo.unlockAllEditor '0000000001',@Ret output
select @Ret

drop PROCEDURE modiPassword
/*
	name:		modiPassword
	function:	6.�޸�����
				ע�⣺����洢���̲����ԭ�����Ƿ������ݿ��еǼǵ�һ�£�
	input: 
				@jobNumber varchar(10),		--���ţ�����
				--ϵͳ��¼��Ϣ��
				@newPassword varchar(128),	--��ϵͳ��¼����

				--����ά�����:
				@modiManID varchar(10),		--�޸��˹���
	output: 
				@Ret		int output,
							0:�ɹ���1:���û������ڣ�9:δ֪����
	author:		¬έ
	CreateDate:	2011-7-5
	UpdateDate: modi by lw 2011-10-16������־�ǼǴ���
				modi by lw 2012-4-19 �޸���ȡ���޸��˵���������
*/
create PROCEDURE modiPassword
	@jobNumber varchar(10),		--���ţ�����
	@newPassword varchar(128),	--��ϵͳ��¼����

	--����ά�����:
	@modiManID varchar(10),		--�޸��˹���

	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
		 
	--ȡά���˵�������
	declare @modiManName nvarchar(30), @cName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @cName = isnull((select cName from userInfo where jobNumber = @jobNumber),'')
	
	if @cName is null
	begin
		set @Ret = 1
	end

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update userInfo 
	set sysPassword = @newPassword
	where jobNumber = @jobNumber
	
	--����ǵ�ǰ�û����������룬��Ҫ����û�����£�
	if (@modiManID = @jobNumber)
	begin	
		update activeUsers
		set psw = @newPassword
		where  userID = @jobNumber
	end
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, 
								'��������','ϵͳ����' + @modiManName + 
								'��Ҫ���������û�[' + @cName + '('+@jobNumber+')]�����롣')
GO


select * from userInfo where cName='������'
update userInfo
set sysPassword = jobNumber



