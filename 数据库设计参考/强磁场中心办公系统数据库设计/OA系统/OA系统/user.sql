use hustOA
/*
	ǿ�ų����İ칫ϵͳ-ϵͳ�û������
	author:		¬έ
	�ͻ�Ҫ��
	�û��ּ����⣺
	1.�û���������У����Ժ�������Ҽ������Ե��ĵ�Ȩ�޷ֱ�Ϊ��ȫУ��ȫԺ��ȫ���ҵ��豸.ʹ�ý�ɫ�ּ������ݶ���Ĳ�����ΧԼ��ʵ��!
	2.֧���οͣ�ֻ�ܲ�ѯ���������ɱ���
	CreateDate:	2010-11-22
	UpdateDate: by lw 2011-9-12 �޸��û���֧�ֶ��ؽ�ɫ��ȥ���û�Ȩ�ޱ����û�Ȩ�޸�Ϊ��̬���㡣
				
*/
select * from userInfo where mobile='18602702392'
select * from sysRole
update sysRole
set sysRoleID = 1
where sysRoleID = 38
select * from workNote
select * from sysUserRole
select * from sysRoleRight
--1.ϵͳ�û���Ϣ�� ��userInfo����
drop TABLE userInfo
CREATE TABLE userInfo
(
	jobNumber varchar(10) not null,		--���������ţ���ϵͳ����Ϊ���Ǵ�����ϵͳ�л�ù��ţ����������˺��뷢������ʹ�õ�12000�ź��뷢����
	workNumber varchar(10) null,		--����֤�ţ������û���������ĺ��룬����Ψһ�Լ��
	manType smallint not null,			--���1->�̹���9->ѧ�� add by lw 2012-12-27
	
	--������Ϣ��
	cName nvarchar(30) not null,		--����������Ψһ�Լ��
	pID varchar(18) null,				--���֤��
	countryCode char(3) null,			--�������루���Ҵ��룩
	countryName nvarchar(60) null,		--�������ƣ��������ƣ�
	birthDay smalldatetime null,		--��������
	sex int null,						--�Ա�ʹ�õ�201�Ŵ����ֵ���ͣ�1->�У�2->Ů����������ѡ��򣬴����ֵ��е��������Ų��ã�
	bodyHeight int null,				--��ߣ���λ������
	homeTown nvarchar(20) null,			--����
	nationalityCode int null,			--�������:�ɵ�203�Ŵ����ֵ䶨��
	nationality nvarchar(30) null,		--����
	politicalScapeCode int null,		--������ò����:�ɵ�210�Ŵ����ֵ䶨��
	politicalScape nvarchar(10) null,	--������ò
	maritalStatusCode int null,			--����״�����룺�ɵ�213�Ŵ����ֵ䶨��
	maritalStatus nvarchar(8) null,		--����״��

	--������Ϣ��
	clgCode char(3) not null,			--��ϵͳ�����ã�����ѧԺ����:Ϊ���ּ����Թ̶�Ϊ001
	clgName nvarchar(30) not null,		--��ϵͳ�����ã�����ѧԺ����:Ϊ���ּ����Թ̶�Ϊǿ�ų����ġ��������
	uCode varchar(8) null,				--���Ŵ��루����ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�)
	uName nvarchar(30) null,			--�������ƣ�����ʹ�õ�λ����:������ƣ�
	tutorID varchar(10) null,			--��ʦ����:�����Ϊѧ��ʱҪ������ add by lw 2012-12-27
	tutorName nvarchar(30) null,		--��ʦ����:�����Ϊѧ��ʱҪ�����롣������� add by lw 2012-12-27
	
	--������Ϣ��
	workPos nvarchar(30) null,			--��λ
	workPostID int null,				--ְ��ID��ʹ�õ�218�Ŵ����ֵ�
	workPost nvarchar(10) null,			--ְ�����ƣ��������
	entryTime smalldatetime null,		--��ְʱ��

	--��ϵ��ʽ��	
	officeTel varchar(30) null,			--�칫�绰
	mobile varchar(20) null,			--�ֻ�����
	e_mail varchar(30) null,			--E_mail��ַ
	homeAddress nvarchar(100) null,		--סַ
	homeTel varchar(30) null,			--��ͥ�绰
	urgentConnecter nvarchar(30) null,	--������ϵ��
	urgentTel varchar(30) null,			--������ϵ�˵绰
	
	--ϵͳ��¼��Ϣ��
	sysUserName varchar(30) not null,	--�û���:Ҫ��Ψһ�Լ��
	sysUserDesc nvarchar(100) null,		--ϵͳ�û�����������
	
	--modi by lw 2011-7-5��Ϊʹ�ü��ܳ���Ҫ���ֶγ����ӳ���
	sysPassword varchar(128) null,		--ϵͳ��¼���룺����Ҫʹ�ü����㷨���ܣ�
	pswProtectQuestion varchar(40) null,--���뱣������
	psqProtectAnswer varchar(40) null,	--���뱣������Ĵ�

	isOff int default(1),				--�Ƿ񼤻0->���1->δ����
	setOffDate smalldatetime,			--ע������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
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

insert userInfo(jobNumber, manType, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('G201300001',1,'��Զ','001','����ǿ�ų���ѧ����','chengyuan','9369A71B2CA05876A068A505462AD673','0000000000')
insert userInfo(jobNumber, manType, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('G201300002',1,'¬έ','001','����ǿ�ų���ѧ����','lw','9369A71B2CA05876A068A505462AD673','0000000000')

use hustOA
select * from userInfo where cName='¬έ'
update userInfo
set sysPassword='9369A71B2CA05876A068A505462AD673'
where cName='¬έ'

--2.�û�ѧϰ������
drop TABLE userStudyInfo
CREATE TABLE userStudyInfo
(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--�к�
	jobNumber varchar(10) not null,		--���������
	cName nvarchar(30) not null,		--�������������
	eduLevelCode int null,				--ѧ��ѧλ���Ļ��̶ȣ����ɵ�211�Ŵ����ֵ䶨��
	eduLevel nvarchar(20) null,			--ѧ��ѧλ���Ļ��̶ȣ�
	beginTime smalldatetime null,		--��ʼʱ��
	endTime smalldatetime null,			--����ʱ��
	college nvarchar(30) null,			--��ҵѧУ
	discipline nvarchar(20) null,		--��ѧרҵ
	tutor nvarchar(30) null,			--��ʦ
	
CONSTRAINT [PK_userStudyInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[userStudyInfo] WITH CHECK ADD CONSTRAINT [FK_userStudyInfo_userInfo] FOREIGN KEY([jobNumber])
REFERENCES [dbo].[userInfo] ([jobNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[userStudyInfo] CHECK CONSTRAINT [FK_userStudyInfo_userInfo]
GO
select * from userInfo
--3.�û�����������
drop TABLE userWorkInfo
CREATE TABLE userWorkInfo
(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--�к�
	jobNumber varchar(10) not null,		--���������
	cName nvarchar(30) not null,		--�������������
	beginTime smalldatetime null,		--��ʼʱ��
	endTime smalldatetime null,			--����ʱ��
	postName nvarchar(10) null,			--ְλ����
	workUnit nvarchar(30) null,			--��ְ��λ
	changeReason nvarchar(30) null,		--�䶯ԭ��
CONSTRAINT [PK_userWorkInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[userWorkInfo] WITH CHECK ADD CONSTRAINT [FK_userWorkInfo_userInfo] FOREIGN KEY([jobNumber])
REFERENCES [dbo].[userInfo] ([jobNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[userWorkInfo] CHECK CONSTRAINT [FK_userWorkInfo_userInfo] 
GO

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
exec dbo.checkSuperManRights '0000000000',@Ret output
select @Ret

delete sysRoleDataOpr where sysRoleID=1 and rightKind = 1




select * from sysRoleDataOpr
order by rightKind, rightClass, rightItem, oprEName

update sysRoleDataOpr
set oprEName ='cmdUpdatePW'
where rightKind = 10 and rightClass = 3 and rightItem = 0 and sortNum = 5

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
		insert sysRoleRight(sysRoleID, rightID, rightName, rightEName, Url,
					rightType, rightKind, rightClass, rightItem, rightDesc)
		select 1, rightID, rightName, rightEName, Url,
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
exec dbo.updateSuperManRights '0000000000',@Ret output
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

drop FUNCTION getUserType
/*
	name:		getUserType
	function:	1.�����û����Ż�ȡ�û����ͻ�ʦ���š���������ʱѧ����ʱ�������ʦ�Ĺ��ź�������
	input: 
				@jobNumber varchar(10)		--���ţ�����
	output: 
				@Ret int output,				--�����ɹ���ʶ:0->�ɹ���9->ʧ��
				@manType smallint output,		--���1->�̹���9->ѧ�� add by lw 2012-12-27
				@tutorID varchar(10) output,	--��ʦ����:�����Ϊѧ��ʱҪ������ add by lw 2012-12-27
				@tutorName nvarchar(30) output	--��ʦ����:�����Ϊѧ��ʱҪ�����롣������� add by lw 2012-12-27
	author:		¬έ
	CreateDate:	2013-3-3
	UpdateDate: 
*/
create PROCEDURE getUserType
	@jobNumber varchar(10),			--����
	@Ret int output,				--�����ɹ���ʶ
	@manType smallint output,		--���1->�̹���9->ѧ�� add by lw 2012-12-27
	@tutorID varchar(10) output,	--��ʦ����:�����Ϊѧ��ʱҪ������ add by lw 2012-12-27
	@tutorName nvarchar(30) output	--��ʦ����:�����Ϊѧ��ʱҪ�����롣������� add by lw 2012-12-27
	WITH ENCRYPTION 
AS
	set @Ret = 9
	select @manType = manType, @tutorID = tutorID, @tutorName= tutorName
	from userInfo
	where jobNumber = @jobNumber
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0	
go

--���ԣ�
declare @Ret int, @manType smallint, @tutorID varchar(10), @tutorName nvarchar(30)
exec dbo.getUserType '00001', @Ret output, @manType output, @tutorID output, @tutorName output
select @Ret, @manType, @tutorID, @tutorName

update userInfo
set manType = 1
where jobNumber<>'00001'
select * from userInfo
select * from sysUserRole

update userInfo
set manType = 9, tutorID = '005006', tutorName='��ӱ'
where jobNumber = '00001'


drop PROCEDURE addUser
/*
	name:		addUser
	function:	1.����û�
				ע�⣺����洢���̼�鹤�ź�ϵͳ��½����Ψһ�ԣ�
	input: 
				@workNumber varchar(10),	--����֤�ţ������û���������ĺ��룬����Ψһ�Լ��
				@manType smallint,			--���1->�̹���9->ѧ�� add by lw 2012-12-27
				--������Ϣ��
				@cName nvarchar(30),		--����
				@pID varchar(18),			--���֤��
				@countryCode char(3),		--�������루���Ҵ��룩
				@birthDay varchar(10),		--��������
				@sex int,					--�Ա�ʹ�õ�201�Ŵ����ֵ���ͣ�1->�У�2->Ů����������ѡ��򣬴����ֵ��е��������Ų��ã�
				@bodyHeight int,			--��ߣ���λ������
				@homeTown nvarchar(20),		--����
				@nationalityCode int,		--�������:�ɵ�203�Ŵ����ֵ䶨��
				@politicalScapeCode int,	--������ò����:�ɵ�210�Ŵ����ֵ䶨��
				@maritalStatusCode int,		--����״�����룺�ɵ�213�Ŵ����ֵ䶨��
				--������Ϣ��
				@clgCode char(3),			--��ϵͳ�����ã�����ѧԺ����:Ϊ���ּ����Թ̶�Ϊ001
				@uCode varchar(8),			--���Ŵ��루����ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�)
				@tutorID varchar(10),		--��ʦ����:�����Ϊѧ��ʱҪ������ add by lw 2012-12-27
				--������Ϣ��
				@workPos nvarchar(30),		--��λ
				@workPostID int,			--ְ��ID��ʹ�õ�218�Ŵ����ֵ�
				@entryTime varchar(10),		--��ְʱ��
				--��ϵ��ʽ��	
				@officeTel varchar(30),		--�칫�绰
				@mobile varchar(20),		--�ֻ�����
				@e_mail varchar(30),		--E_mail��ַ
				@homeAddress nvarchar(100),	--סַ
				@homeTel varchar(30),		--��ͥ�绰
				@urgentConnecter nvarchar(30),	--������ϵ��
				@urgentTel varchar(30),		--������ϵ�˵绰
				--ϵͳ��¼��Ϣ��
				@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
				@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
				@sysPassword varchar(128),	--ϵͳ��¼����
				@pswProtectQuestion varchar(40),--���뱣������
				@psqProtectAnswer varchar(40),	--���뱣������Ĵ�
				--ѧϰ������
				@studyInfo xml,
				--����������
				@workInfo xml,
				
				--����ά�����:
				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output,
							0:�ɹ���2:���û����Ѿ���ע����ˣ�3:���ֻ��Ѿ���ע�ᣬ4���������Ѿ���ע�ᣬ9:δ֪����
				@jobNumber varchar(10) output	--��Ա��ţ���ϵͳʹ�õ�12000�ź��뷢����������'G'+4λ��ݴ���+5λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2011-9-4ȥ����ɫ�����������ӽ�ɫ�ּ����ʹ���
				modi by lw 2011-9-12�޸��û���֧�ֶ��ؽ�ɫ��ȥ���û�Ȩ�ޱ����û�Ȩ�޸�Ϊ��̬���㡣
				modi by lw 2013-1-1������Ա���ӿ�
				modi by lw 2013-1-11�������ݿ��ֶα仯���ӽӿڣ����Ӻ��뷢�������Զ����ɹ���
				modi by lw 2013-1-25����ѧϰ�������������������ж�
				modi by lw 2013-7-12�����ֻ���eMail��ַ��Ψһ���ж�
*/
create PROCEDURE addUser
	@workNumber varchar(10),	--����֤�ţ������û���������ĺ��룬����Ψһ�Լ��
	@manType smallint,			--���1->�̹���9->ѧ�� add by lw 2012-12-27
	--������Ϣ��
	@cName nvarchar(30),		--����
	@pID varchar(18),			--���֤��
	@countryCode char(3),		--�������루���Ҵ��룩
	@birthDay varchar(10),		--��������
	@sex int,					--�Ա�ʹ�õ�201�Ŵ����ֵ���ͣ�1->�У�2->Ů����������ѡ��򣬴����ֵ��е��������Ų��ã�
	@bodyHeight int,			--��ߣ���λ������
	@homeTown nvarchar(20),		--����
	@nationalityCode int,		--�������:�ɵ�203�Ŵ����ֵ䶨��
	@politicalScapeCode int,	--������ò����:�ɵ�210�Ŵ����ֵ䶨��
	@maritalStatusCode int,		--����״�����룺�ɵ�213�Ŵ����ֵ䶨��
	--������Ϣ��
	@clgCode char(3),			--��ϵͳ�����ã�����ѧԺ����:Ϊ���ּ����Թ̶�Ϊ001
	@uCode varchar(8),			--���Ŵ��루����ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�)
	@tutorID varchar(10),		--��ʦ����:�����Ϊѧ��ʱҪ������ add by lw 2012-12-27
	--������Ϣ��
	@workPos nvarchar(30),		--��λ
	@workPostID int,			--ְ��ID��ʹ�õ�218�Ŵ����ֵ�
	@entryTime varchar(10),		--��ְʱ��
	--��ϵ��ʽ��	
	@officeTel varchar(30),		--�칫�绰
	@mobile varchar(20),		--�ֻ�����
	@e_mail varchar(30),		--E_mail��ַ
	@homeAddress nvarchar(100),	--סַ
	@homeTel varchar(30),		--��ͥ�绰
	@urgentConnecter nvarchar(30),	--������ϵ��
	@urgentTel varchar(30),		--������ϵ�˵绰
	--ϵͳ��¼��Ϣ��
	@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
	@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
	@sysPassword varchar(128),	--ϵͳ��¼����
	@pswProtectQuestion varchar(40),--���뱣������
	@psqProtectAnswer varchar(40),	--���뱣������Ĵ�
	--ѧϰ������
	@studyInfo xml,
	--����������
	@workInfo xml,
	
	--����ά�����:
	@createManID varchar(10),	--�����˹���

	@Ret int output,
	@jobNumber varchar(10) output	--��Ա��ţ���ϵͳʹ�õ�12000�ź��뷢����������'G'+4λ��ݴ���+5λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���ϵͳ��¼�˺����Ƿ�Ψһ��
	declare @count as int
	set @count = (select count(*) from userInfo where sysUserName = @sysUserName)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	--����ֻ��Ƿ�Ψһ��
	set @mobile=LTRIM(rtrim(@mobile))
	if (@mobile <>'')
	set @count = (select count(*) from userInfo where mobile = @mobile)
	if @count > 0
	begin
		set @Ret = 3
		return
	end

	--��������Ƿ�Ψһ��
	set @e_mail=LTRIM(rtrim(@e_mail))
	if (@e_mail <>'')
	set @count = (select count(*) from userInfo where e_mail = @e_mail)
	if @count > 0
	begin
		set @Ret = 4
		return
	end

	--ʹ�ú��뷢�����������ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 12000, 1, @curNumber output
	set @jobNumber = @curNumber

	--ȡԺ�����ƺ�ʹ�õ�λ\��ʦ���ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30), @tutorName nvarchar(30)		--����ѧԺ���ơ�����ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	
	--���ݴ���ȡ���ҡ����塢������ò������״̬�����ƣ�
	declare @countryName nvarchar(60) ,	@nationality nvarchar(30)
	declare @politicalScape nvarchar(10), @maritalStatus nvarchar(8)
	set @countryName = isnull((select cName from country where cCode = @countryCode),'')
	set @nationality = isnull((select objDesc from codeDictionary where classCode = 203 and objCode = @nationalityCode),'')
	set @politicalScape  = isnull((select objDesc from codeDictionary where classCode = 210 and objCode = @politicalScapeCode),'')
	set @maritalStatus = isnull((select objDesc from codeDictionary where classCode = 213 and objCode = @maritalStatusCode),'')

		 
	--ְ�����ƣ�
	declare @workPost nvarchar(10)
	set @workPost = isnull((select objDesc from codeDictionary where classCode = 218 and objCode = @workPostID),'')

	--ȡ����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	--�����쳣�������ݣ�
	declare @rBrithDay smalldatetime, @rEntryTime smalldatetime
	if (@birthDay='')	--��������
		set @rBrithDay = null
	else
		set @rBrithDay = convert(smalldatetime,@birthDay,120)
		
	if (@entryTime='')	--��ְʱ��
		set @rEntryTime = getdate()
	else
		set @rEntryTime = convert(smalldatetime,@entryTime,120)
		
	declare @createTime smalldatetime
	set @createTime = getdate()
	begin tran
		insert userInfo (jobNumber, workNumber, manType,
				--������Ϣ��
				cName, pID, countryCode, countryName, birthDay, 
				sex,
				bodyHeight, homeTown, nationalityCode, nationality, 
				politicalScapeCode, politicalScape, maritalStatusCode, maritalStatus,
				--������Ϣ��
				clgCode, clgName, uCode, uName, tutorID, tutorName,
				--������Ϣ��
				workPos, workPostID, workPost, entryTime,
				--��ϵ��ʽ��	
				officeTel, mobile, e_mail, homeAddress, homeTel, urgentConnecter, urgentTel,
				--ϵͳ��¼��Ϣ��
				sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer,
				--����ά�����:
				modiManID, modiManName, modiTime)
		values(@jobNumber, @workNumber, @manType,
				--������Ϣ��
				@cName, @pID, @countryCode, @countryName, @rBrithDay, 
				@sex,
				@bodyHeight, @homeTown, @nationalityCode, @nationality, 
				@politicalScapeCode, @politicalScape, @maritalStatusCode, @maritalStatus,
				--������Ϣ��
				@clgCode, @clgName, @uCode, @uName, @tutorID, @tutorName,
				--������Ϣ��
				@workPos, @workPostID, @workPost, @rEntryTime,
				--��ϵ��ʽ��	
				@officeTel, @mobile, @e_mail, @homeAddress, @homeTel, @urgentConnecter, @urgentTel,
				--ϵͳ��¼��Ϣ��
				@sysUserName, @sysUserDesc, @sysPassword, @pswProtectQuestion, @psqProtectAnswer,
				--����ά�����:
				@createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		--�Ǽ�ѧϰ������
		set @count = (select @studyInfo.value('count(/root/row)','int'))
		if (@count >0)
		begin
			insert userStudyInfo(jobNumber, cName, eduLevelCode, eduLevel, beginTime, endTime, college, discipline, tutor)
			select @jobNumber, @cName, cast(cast(T.x.query('data(./eduLevelCode)') as varchar(8)) as int) eduLevelCode,
				cast(T.x.query('data(./eduLevel)') as nvarchar(20)) eduLevel,
				cast(T.x.query('data(./beginTime)') as varchar(10)) beginTime,
				cast(T.x.query('data(./endTime)') as varchar(10)) endTime,
				cast(T.x.query('data(./college)') as nvarchar(30)) college,
				cast(T.x.query('data(./discipline)') as nvarchar(20)) discipline,
				cast(T.x.query('data(./tutor)') as nvarchar(30)) tutor 
				from (select @studyInfo.query('/root/row') Col1) A
					OUTER APPLY A.Col1.nodes('/row') AS T(x)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end
		--�Ǽǹ���������
		set @count = (select @workInfo.value('count(/root/row)','int'))
		if (@count >0)
		begin
			insert userWorkInfo(jobNumber, cName, beginTime, endTime, postName, workUnit, changeReason)
			select @jobNumber, @cName, 
				cast(T.x.query('data(./beginTime)') as varchar(10)) beginTime,
				cast(T.x.query('data(./endTime)') as varchar(10)) endTime,
				cast(T.x.query('data(./postName)') as nvarchar(10)) postName,
				cast(T.x.query('data(./workUnit)') as nvarchar(30)) workUnit,
				cast(T.x.query('data(./changeReason)') as nvarchar(30)) changeReason 
				from (select @workInfo.query('/root/row') Col1) A
					OUTER APPLY A.Col1.nodes('/row') AS T(x)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end
	commit tran

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'ע���û�','ϵͳ����' + @createManName + 
								'��Ҫ��ע�����û�[' + @cName + '('+ @sysUserName +')]����Ϣ��')
GO
--���ԣ�
declare @studyInfo xml
set @studyInfo = N'<root>
						<row id="1">
							<eduLevelCode>40</eduLevelCode>
							<eduLevel>�е�ְҵ��</eduLevel>
							<beginTime>2013-01-01</beginTime>
							<endTime>2013-01-26</endTime>
							<college>΢���й�</college>
							<discipline>������</discipline>
							<tutor>��֪��</tutor>
						</row>
				  </root>'
declare @workInfo xml
set @workInfo = N'<root>
						<row id="1">
							<beginTime>2011-01-01</beginTime>
							<endTime>2015-01-01</endTime>
							<postName>����ʦ</postName>
							<workUnit>IBM</workUnit>
							<changeReason>����ԭ��</changeReason>
						</row>
						<row id="2">
							<beginTime>2015-01-01</beginTime>
							<endTime>2019-01-01</endTime>
							<postName>����ʦ</postName>
							<workUnit>IBM ��˾</workUnit>
							<changeReason>ԭ��</changeReason>
						</row>
					</root>'	
declare	@Ret int
declare	@jobNumber varchar(10)
select * from useUnit
exec dbo.addUser '����֤', 1, '�����û�', '001002003', '004', '1970-09-01', 1, 156, '��', 0, 0, 0, '001', '001001','','����',
	0, '','87889011','18602702392','lw_bk@163.com', '�人','87889010','lc','13329723988','lw8888454','cesh123i','12345','Hello','a',@studyInfo,@workInfo, 
	'0000000000', @ret output, @jobNumber output
select @ret, @jobNumber
select * from userInfo
select * from userStudyInfo

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
				@workNumber varchar(10),	--����֤�ţ������û���������ĺ��룬����Ψһ�Լ��
				@manType smallint,			--���1->�̹���9->ѧ�� add by lw 2012-12-27
				--������Ϣ��
				@cName nvarchar(30),		--����
				@pID varchar(18),			--���֤��
				@countryCode char(3),		--�������루���Ҵ��룩
				@birthDay varchar(10),		--��������
				@sex int,					--�Ա�ʹ�õ�201�Ŵ����ֵ���ͣ�1->�У�2->Ů����������ѡ��򣬴����ֵ��е��������Ų��ã�
				@bodyHeight int,			--��ߣ���λ������
				@homeTown nvarchar(20),		--����
				@nationalityCode int,		--�������:�ɵ�203�Ŵ����ֵ䶨��
				@politicalScapeCode int,	--������ò����:�ɵ�210�Ŵ����ֵ䶨��
				@maritalStatusCode int,		--����״�����룺�ɵ�213�Ŵ����ֵ䶨��
				--������Ϣ��
				@clgCode char(3),			--��ϵͳ�����ã�����ѧԺ����:Ϊ���ּ����Թ̶�Ϊ001
				@uCode varchar(8),			--���Ŵ��루����ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�)
				@tutorID varchar(10),		--��ʦ����:�����Ϊѧ��ʱҪ������ add by lw 2012-12-27
				--������Ϣ��
				@workPos nvarchar(30),		--��λ
				@workPostID int,			--ְ��ID��ʹ�õ�218�Ŵ����ֵ�
				@entryTime varchr(10),		--��ְʱ��
				--��ϵ��ʽ��	
				@officeTel varchar(30),		--�칫�绰
				@mobile varchar(20),		--�ֻ�����
				@e_mail varchar(30),		--E_mail��ַ
				@homeAddress nvarchar(100),	--סַ
				@homeTel varchar(30),		--��ͥ�绰
				@urgentConnecter nvarchar(30),	--������ϵ��
				@urgentTel varchar(30),		--������ϵ�˵绰
				--ϵͳ��¼��Ϣ��
				@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
				@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
				--@sysPassword varchar(128),	--ϵͳ��¼����
				@pswProtectQuestion varchar(40),--���뱣������
				@psqProtectAnswer varchar(40),	--���뱣������Ĵ�
				--ѧϰ������
				@studyInfo xml,
				--����������
				@workInfo xml,

				--ά�����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:���û������ڣ�2��Ҫ���µ��û���Ϣ��������������3:Ҫ���ĵ�ϵͳ��¼���Ѿ�������ʹ�ã�
							4:���ֻ��Ѿ���ע�ᣬ5���������Ѿ���ע�ᣬ9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-20
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2011-9-4ȥ����ɫ�����������ӽ�ɫ�ּ����ʹ���
				modi by lw 2011-9-12�޸��û���֧�ֶ��ؽ�ɫ��ȥ���û�Ȩ�ޱ����û�Ȩ�޸�Ϊ��̬���㡣
				modi by lw 2011-9-24�޸��û���Ϣ��ʱ�������޸����롣
				modi by lw 2013-1-1�����û����ӿ�
				modi by lw 2013-1-11�������ݿ������ֶ����ӽӿڣ������û��������ж�
				modi by lw 2013-1-25����ѧϰ�������������������жϣ���ֹ�û�ʹ�ñ������޸����룡
				modi by lw 2013-7-12�����ֻ���eMail��ַ��Ψһ���ж�
*/
create PROCEDURE updateUserInfo
	@jobNumber varchar(10),		--���ţ�����
	@workNumber varchar(10),	--����֤�ţ������û���������ĺ��룬����Ψһ�Լ��
	@manType smallint,			--���1->�̹���9->ѧ�� add by lw 2012-12-27
	--������Ϣ��
	@cName nvarchar(30),		--����
	@pID varchar(18),			--���֤��
	@countryCode char(3),		--�������루���Ҵ��룩
	@birthDay varchar(10),		--��������
	@sex int,					--�Ա�ʹ�õ�201�Ŵ����ֵ���ͣ�1->�У�2->Ů����������ѡ��򣬴����ֵ��е��������Ų��ã�
	@bodyHeight int,			--��ߣ���λ������
	@homeTown nvarchar(20),		--����
	@nationalityCode int,		--�������:�ɵ�203�Ŵ����ֵ䶨��
	@politicalScapeCode int,	--������ò����:�ɵ�210�Ŵ����ֵ䶨��
	@maritalStatusCode int,		--����״�����룺�ɵ�213�Ŵ����ֵ䶨��
	--������Ϣ��
	@clgCode char(3),			--��ϵͳ�����ã�����ѧԺ����:Ϊ���ּ����Թ̶�Ϊ001
	@uCode varchar(8),			--���Ŵ��루����ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�)
	@tutorID varchar(10),		--��ʦ����:�����Ϊѧ��ʱҪ������ add by lw 2012-12-27
	--������Ϣ��
	@workPos nvarchar(30),		--��λ
	@workPostID int,			--ְ��ID��ʹ�õ�218�Ŵ����ֵ�
	@entryTime varchar(10),	--��ְʱ��
	--��ϵ��ʽ��	
	@officeTel varchar(30),		--�칫�绰
	@mobile varchar(20),		--�ֻ�����
	@e_mail varchar(30),		--E_mail��ַ
	@homeAddress nvarchar(100),	--סַ
	@homeTel varchar(30),		--��ͥ�绰
	@urgentConnecter nvarchar(30),	--������ϵ��
	@urgentTel varchar(30),		--������ϵ�˵绰
	--ϵͳ��¼��Ϣ��
	@sysUserName varchar(30),	--�û���:Ҫ��Ψһ�Լ��
	@sysUserDesc nvarchar(100),	--ϵͳ�û�����������
	--@sysPassword varchar(128),	--ϵͳ��¼����
	@pswProtectQuestion varchar(40),--���뱣������
	@psqProtectAnswer varchar(40),	--���뱣������Ĵ�
	--ѧϰ������
	@studyInfo xml,
	--����������
	@workInfo xml,
	--ά�����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�����û��Ƿ���ڣ�
	declare @count int
	set @count = ISNULL((select count(*) from userInfo where jobNumber = @jobNumber),0)
	if (@count=0)
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

	--���ϵͳ��¼�˺����Ƿ�Ψһ��
	set @count = isnull((select count(*) from userInfo where sysUserName = @sysUserName and jobNumber<>@jobNumber),0)
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	--����ֻ��Ƿ�Ψһ��
	set @mobile=LTRIM(rtrim(@mobile))
	if (@mobile <>'')
	set @count = (select count(*) from userInfo where mobile = @mobile and jobNumber <> @jobNumber)
	if @count > 0
	begin
		set @Ret = 4
		return
	end

	--��������Ƿ�Ψһ��
	set @e_mail=LTRIM(rtrim(@e_mail))
	if (@e_mail <>'')
	set @count = (select count(*) from userInfo where e_mail = @e_mail and jobNumber <> @jobNumber)
	if @count > 0
	begin
		set @Ret = 5
		return
	end

	--ȡԺ�����ƺ�ʹ�õ�λ\��ʦ���ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30), @tutorName nvarchar(30)		--����ѧԺ���ơ�����ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	
	--���ݴ���ȡ���ҡ����塢������ò������״̬�����ƣ�
	declare @countryName nvarchar(60) ,	@nationality nvarchar(30)
	declare @politicalScape nvarchar(10), @maritalStatus nvarchar(8)
	set @countryName = isnull((select cName from country where cCode = @countryCode),'')
	set @nationality = isnull((select objDesc from codeDictionary where classCode = 203 and objCode = @nationalityCode),'')
	set @politicalScape  = isnull((select objDesc from codeDictionary where classCode = 210 and objCode = @politicalScapeCode),'')
	set @maritalStatus = isnull((select objDesc from codeDictionary where classCode = 213 and objCode = @maritalStatusCode),'')

		 
	--ְ�����ƣ�
	declare @workPost nvarchar(10)
	set @workPost = isnull((select objDesc from codeDictionary where classCode = 218 and objCode = @workPostID),'')

	--�����쳣�������ݣ�
	declare @rBrithDay smalldatetime, @rEntryTime smalldatetime
	if (@birthDay='')	--��������
		set @rBrithDay = null
	else
		set @rBrithDay = convert(smalldatetime,@birthDay,120)
		
	if (@entryTime='')	--��ְʱ��
		set @rEntryTime = getdate()
	else
		set @rEntryTime = convert(smalldatetime,@entryTime,120)

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')


	declare @updateTime smalldatetime	--����ʱ��
	set @updateTime = getdate()
	begin tran
		update userInfo 
		set workNumber = @workNumber, manType = @manType,
			--������Ϣ��
			cName = @cName, pID = @pID, countryCode = @countryCode, countryName = @countryName, 
			birthDay = @rBrithDay, sex = @sex,
			bodyHeight = @bodyHeight, homeTown = @homeTown, nationalityCode = @nationalityCode, nationality = @nationality, 
			politicalScapeCode = @politicalScapeCode, politicalScape = @politicalScape, 
			maritalStatusCode = @maritalStatusCode, maritalStatus = @maritalStatus,
			--������Ϣ��
			clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName, tutorID = @tutorID, tutorName = @tutorName,
			--������Ϣ��
			workPos = @workPos, workPostID = @workPostID, workPost = @workPost, entryTime = @rEntryTime,
			--��ϵ��ʽ��	
			officeTel = @officeTel, mobile = @mobile, e_mail = @e_mail, homeAddress = @homeAddress, homeTel = @homeTel, 
			urgentConnecter = @urgentConnecter, urgentTel = @urgentTel,
			--ϵͳ��¼��Ϣ��
			sysUserName = @sysUserName, sysUserDesc = @sysUserDesc, --sysPassword = @sysPassword, 
			pswProtectQuestion = @pswProtectQuestion, psqProtectAnswer = @psqProtectAnswer,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where jobNumber = @jobNumber
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--�Ǽ�ѧϰ������
		delete userStudyInfo where jobNumber = @jobNumber
		set @count = (select @studyInfo.value('count(/root/row)','int'))
		if (@count >0)
		begin
			insert userStudyInfo(jobNumber, cName, eduLevelCode, eduLevel, beginTime, endTime, college, discipline, tutor)
			select @jobNumber, @cName, cast(cast(T.x.query('data(./eduLevelCode)') as varchar(8)) as int) eduLevelCode,
				cast(T.x.query('data(./eduLevel)') as nvarchar(20)) eduLevel,
				cast(T.x.query('data(./beginTime)') as varchar(10)) beginTime,
				cast(T.x.query('data(./endTime)') as varchar(10)) endTime,
				cast(T.x.query('data(./college)') as nvarchar(30)) college,
				cast(T.x.query('data(./discipline)') as nvarchar(20)) discipline,
				cast(T.x.query('data(./tutor)') as nvarchar(30)) tutor 
				from (select @studyInfo.query('/root/row') Col1) A
					OUTER APPLY A.Col1.nodes('/row') AS T(x)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end
		--�Ǽǹ���������
		delete userWorkInfo where jobNumber = @jobNumber
		set @count = (select @workInfo.value('count(/root/row)','int'))
		if (@count >0)
		begin
			insert userWorkInfo(jobNumber, cName, beginTime, endTime, postName, workUnit, changeReason)
			select @jobNumber, @cName, 
				cast(T.x.query('data(./beginTime)') as varchar(10)) beginTime,
				cast(T.x.query('data(./endTime)') as varchar(10)) endTime,
				cast(T.x.query('data(./postName)') as nvarchar(10)) postName,
				cast(T.x.query('data(./workUnit)') as nvarchar(30)) workUnit,
				cast(T.x.query('data(./changeReason)') as nvarchar(30)) changeReason 
				from (select @workInfo.query('/root/row') Col1) A
					OUTER APPLY A.Col1.nodes('/row') AS T(x)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end
	commit tran

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����û���Ϣ', '�û�' + @modiManName 
												+ '�������û�['+ @jobNumber +']����Ϣ��')
GO
--���ԣ�
declare @workInfo xml
set @workInfo = N'<root>
						<row id="1">
							<beginTime>2011-01-01</beginTime>
							<endTime>2015-01-01</endTime>
							<postName>����ʦ</postName>
							<workUnit>IBM</workUnit>
							<changeReason>����ԭ��</changeReason>
						</row>
						<row id="2">
							<beginTime>2015-01-01</beginTime>
							<endTime>2010-01-01</endTime>
							<postName>����ʦ</postName>
							<workUnit>IBM ��˾</workUnit>
							<changeReason>ԭ��</changeReason>
						</row>
					</root>'	
declare	@Ret int
declare	@modiManID varchar(10)		--ά���ˣ������ǰ�û����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
set @modiManID = '0000000000' 
exec dbo.updateUserInfo 'G201300020', '����֤', 1, '�����û�', '001002003', '004', '1970-09-01', 1, 156, '��', 0, 0, 0, '001', '001001','','����',
	0, '','87889011','18602702392','lw_bk@163.com', '�人','87889010','lc','13329723988','ceshi','12345','Hello','a','','', 
	@modiManID output,@Ret output
select @Ret

select * from userInfo




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

	--ȡ�û���/ά���˵�������
	declare @userCName nvarchar(30)
	set @userCName = isnull((select cName from userInfo where jobNumber = @jobNumber),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	--����Ƿ�Ϊ���û�����û��Ȩ�޵��û���������һ���û�����Ȩ�޷��������
	begin tran
		declare @count int
		set @count = isnull((select count(*) from sysUserRole where jobNumber=@jobNumber),0)
		if (@count=0)
		begin
			insert sysUserRole(jobNumber, sysUserName, sysRoleID, sysRoleName, sysRoleType)
			select @jobNumber,@userCName,sysRoleID, sysRoleName, sysRoleType 
			from sysRole 
			where sysRoleName='һ���û�'
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
		
		update userInfo
		set isOff = 0, setOffDate = null,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where jobNumber = @jobNumber
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
	values(@modiManID, @modiManName, @updateTime, '�����û�', '�û�' + @modiManName 
												+ '�������û�['+ @jobNumber +']��')
GO


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
	--���ӵĵ�¼״̬���û���ǰ״̬����Ϣ��add by lw 2013-5-31
	activeTime smalldatetime null,		--�ϴλʱ�䣺�����ʷ����ʱ�䣬��������ж��Ƿ���˯���û�
	loginByBrower smallint default(0),	--ʹ���������¼��0->�Ǳ���ʽ��¼
	loginByClient smallint default(0),	--ʹ��PC�ͻ��˵�¼
	loginByAndroid smallint default(0),	--ʹ�ð�׿�ͻ��˵�¼
 CONSTRAINT [PK_activeUsers] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

use hustOA
drop PROCEDURE login
/*
	name:		login
	function:	1.�û���¼�������û����û����������Ƿ���ȷ������ȷ�����ǰ�ĵ�¼���Ǽǵ�ǰ��״̬
	input: 
				@userName varchar(30) output,--�û���	modi by lw 2011-6-28,֧�ֹ��ŵ�¼�����Ը�Ϊ�����Ͳ���
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
				@loginMode smallint,		--��¼��ʽ��1->��ҳ��¼��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1���û����������
							2��ϵͳ��������û��ı༭��ʱ����
							3��ϵͳ�޷�ʶ��õ�¼��ʽ
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
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2011-6-5 ����ǰ̨Ȩ�޿��Ƶ���Ҫ���ӷ����û��Ļ�����Ϣ,ɾ������Ȩ���б�
				modi by lw 2011-6-28���ӹ��ŵ�¼
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2011-9-4���ӽ�ɫ�ּ�����
				modi by lw 2011-9-19��Ϊ�û���ɫ��Ƶ��޸Ķ�����Ӧ�޸ģ�����ȡ�û���ɫ����Ϣ������һ���߼������еķ���
									����ȡ�û���Ȩ�޸�Ϊһ����̬����Ĵ洢���̡�
				modi by lw 2013-5-31���ӵ�¼��ʽ
*/
create PROCEDURE login
	@userName varchar(30) output,	--�û���
	@psw	varchar(128),			--��¼����
	@userIP varchar(40),			--�Ự�ͻ���IP
	@loginMode smallint,			--��¼��ʽ��1->��ҳ��¼��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼

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
		delete activeUsers where userID = @userID	--�����ǰ�ĵ�¼
	end

	--������û����еı༭����
	declare @retUnlock as int
	exec dbo.unlockAllEditor @userID, @retUnlock output
	if (@retUnlock <> 0)
	begin
		set @Ret = 2
		return
	end
	--��¼��ʽ��
	declare @actionObject nvarchar(500) --��־
	declare @loginByBrower smallint--ʹ���������¼
	declare @loginByClient smallint	--ʹ��PC�ͻ��˵�¼
	declare @loginByAndroid smallint	--ʹ�ð�׿�ͻ��˵�¼
	set @loginByBrower = 0
	set @loginByClient = 0
	set @loginByAndroid = 0
	if (@loginMode=1)
	begin
		set @loginByBrower = 1
		set @actionObject='�û�' + @userCName + '��IPΪ['+ @userIP +']�Ĺ���վ��ʹ���������¼��ϵͳ��\r\nͬʱϵͳ����˸��û������������ϵĵ�¼��'
	end
	else if (@loginMode=2)
	begin
		set @loginByClient = 1
		set @actionObject='�û�' + @userCName + '��IPΪ['+ @userIP +']�Ĺ���վ��ʹ�ÿͻ��˵�¼��ϵͳ��\r\nͬʱϵͳ����˸��û������������ϵĵ�¼��'
	end
	else if (@loginMode=3)
	begin
		set @loginByAndroid = 1
		set @actionObject='�û�' + @userCName + '��IPΪ['+ @userIP +']���ֻ���ƽ����ʹ�ÿͻ��˵�¼��ϵͳ��\r\nͬʱϵͳ����˸��û������������ϵĵ�¼��'
	end
	else
	begin
		set @Ret = 3
		return
	end
	
	--�Ǽǵ�¼��Ϣ��
	set @dynaPsw = (select newid())		--���ɶ�̬����
	declare @loginTime smalldatetime	--��¼ʱ��
	set @loginTime = getdate()
	insert activeUsers(userID, userName, userCName, psw, userIP, dynaPsw, loginTime,activeTime,loginByBrower,loginByClient,loginByAndroid)
	values(@userID, @userName, @userCName, @psw, @userIP, @dynaPsw, @loginTime,@loginTime,@loginByBrower,@loginByClient,@loginByAndroid)

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userCName, @loginTime, '��¼', @actionObject)

GO

--���ԣ�
declare	@Ret int , @dynaPsw varchar(36), @userCName varchar(30), @userID varchar(10)
declare	@pID varchar(18), @clgCode char(3),	@clgName nvarchar(30), @uCode varchar(8)
declare	@uName nvarchar(30), @sysUserDesc nvarchar(100)
exec dbo.login 'chengyuan', '9369A71B2CA05876A068A505462AD673', '127.0.0.1', @Ret output, @dynaPsw output, @userCName output, @userID output,
	@pID output, @clgCode output, @clgName output, @uCode output,
	@uName output, @sysUserDesc output
select @Ret, @dynaPsw, @userCName, @userID,
	@pID, @clgCode, @clgName, @uCode,
	@uName, @sysUserDesc


select * from workNote order by actionTime desc
update userInfo
set sysPassword ='00200977'
where jobNumber = '00200977'


commit
select sysPassword, LEN(sysPassword) from userInfo where jobNumber = '0000000001'
select * from userInfo

select * from activeUsers


drop PROCEDURE addLoginMode
/*
	name:		addLoginMode
	function:	1.2.����û���¼��ʽ
				ע�⣺���洢�����Ǹ��ͻ���ʹ�õġ����ͻ����ȵ�¼����ҳ�ٵ�¼ʱ������ӿͻ��˵ĵ�¼״̬,������֤�ͻ��˲����ߣ�
	input: 
				@userID varchar(10),			--�û�����
				@psw	varchar(128),			--��¼����
				@dynaPsw varchar(36),			--��̬��Կ
				@userIP varchar(40),			--�Ự�ͻ���IP
				@loginMode smallint,			--��¼��ʽ��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1�����û���û�е�¼��2��ϵͳ�޷�ʶ��õ�¼��ʽ��9��δ֪����
	author:		¬έ
	CreateDate:	2013-5-31
	UpdateDate: 
*/
create PROCEDURE addLoginMode
	@userID varchar(10),			--�û�����
	@psw	varchar(128),			--��¼����
	@dynaPsw varchar(36),			--��̬��Կ
	@userIP varchar(40),			--�Ự�ͻ���IP
	@loginMode smallint,			--��¼��ʽ��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼

	@Ret	int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--����Ƿ���ǰ�е�¼��
	select * from activeUsers
	declare @count int
	set @count=(select count(*) from activeUsers where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--��ӿͻ��˵�¼��ʽ��
	declare @actionObject nvarchar(500) --��־
	if (@loginMode=2)
	begin
		update activeUsers
		set loginByClient = 1
		where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
	end
	else if (@loginMode=3)
	begin
		update activeUsers
		set loginByAndroid = 1
		where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
	end
	else
	begin
		set @Ret = 2
		return
	end
	set @Ret = 0

GO

drop PROCEDURE clearLoginMode
/*
	name:		clearLoginMode
	function:	1.3.���ָ���û��Ŀͻ��˻�׿��¼��ʽ��
				ע�⣺����һ��������ר�õ���Կͻ��˶���ʹ�õĹ��̣�
	input: 
				@userID varchar(10),			--�û�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-6-2
	UpdateDate: 
*/
create PROCEDURE clearLoginMode
	@userID varchar(10),			--�û�����

	@Ret	int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	update activeUsers
	set loginByAndroid = 0, loginByClient = 0
	where userID = @userID

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('0000000000', 'ϵͳ�û�', GETDATE(), '�����¼��ʽ', '�����û����ߣ�ϵͳ�Զ�������û�['+@userID+']�Ŀͻ��˵�¼��ʽ')
GO

drop PROCEDURE reLogin
/*
	name:		reLogin
	function:	1.1.�����û����µ�¼�������û����û����������Ƿ���ȷ������ȷ����Ƿ�Ϊ�����û�������������û�����
				������ʹ���ڳ�ʱʱ���µ�¼��
	input: 
				@userName varchar(30) output,--�û���	modi by lw 2011-6-28,֧�ֹ��ŵ�¼�����Ը�Ϊ�����Ͳ���
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
				@loginMode smallint,			--��¼��ʽ��1->��ҳ��¼��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1���û����������
							2����Ч�û�����������ԭ�û�������������վ��¼��ϵͳ����Ա�߳�ϵͳ����
							3��ϵͳ�޷�ʶ��õ�¼��ʽ
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
	UpdateDate: modi by lw 2013-5-31���ӵ�¼��ʽ
*/
create PROCEDURE reLogin
	@userName varchar(30) output,	--�û���
	@psw	varchar(128),			--��¼����
	@userIP varchar(40),			--�Ự�ͻ���IP
	@loginMode smallint,			--��¼��ʽ��1->��ҳ��¼��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼

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
	
	--��д��¼��ʽ��
	if (@loginMode=1)
	begin
		update activeUsers
		set loginByBrower = 1
		where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
	end
	else if (@loginMode=2)
	begin
		update activeUsers
		set loginByClient = 1
		where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
	end
	else if (@loginMode=3)
	begin
		update activeUsers
		set loginByAndroid = 1
		where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
	end
	else
	begin
		set @Ret = 3
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
				@userID varchar(12),		--�û�ID
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
				@dynaPsw varchar(36),		--��̬��Կ
	output: 

				@Ret		int output		--��ʶ
							1:�ǣ�0�����ǣ�-1��δ֪����
	author:		¬έ
	CreateDate:	2011-9-20
	UpdateDate: modi by lw 2013-4-17���û����ĳ��û�ID
				modi by lw 2013-5-31���ӵǼ��û�����ʱ�䣬�Ա���ϵͳ�ж�˯���û�
*/
create PROCEDURE validateActiveUser
	@userID varchar(12),		--�û�ID
	@psw	varchar(128),		--��¼����
	@userIP varchar(40),		--�Ự�ͻ���IP
	@dynaPsw varchar(36),		--��̬��Կ
	@Ret		int output		--��ʶ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers 
								where userID = @userID and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw)
	if @count > 0
	begin
		set @Ret = 1
		--�Ǽǿͻ��˱��η���ʱ�䣺
		update activeUsers
		set activeTime=GETDATE()
		where userID = @userID and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
	end
	else
		set @Ret = 0
GO


drop PROCEDURE clearSleepUsers
/*
	name:		clearSleepUsers
	function:	2.2.���˯���û�
				ע�⣺����ϵͳ�Զ�ִ�еĴ洢���̣���ÿ������ִ�С�ϵͳֻ�����ҳ��һ��¼���û���
					�ô洢����Ҳ�ṩ���߼��û����˯���û��ã�
				˯���û����ж���׼�ǣ�20������û�в������û���
	input: 
	output: 
	author:		¬έ
	CreateDate:	2013-5-31
	UpdateDate: 
*/
create PROCEDURE clearSleepUsers
	WITH ENCRYPTION 
AS
	delete activeUsers where DATEDIFF(minute,activeTime,GETDATE())>20 and loginByBrower=1 and loginByAndroid=0 and loginByClient =0
GO

drop PROCEDURE logout
/*
	name:		logout
	function:	3.��ȫ�˳�
	input: 
				@userName varchar(30),		--�û���
				@psw	varchar(128),		--��¼����
				@userIP varchar(40),		--�Ự�ͻ���IP
				@logoutMode smallint,		--�˳��ĵ�¼��ʽ��1->��ҳ��¼��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼
				@dynaPsw varchar(36),		--��̬��Կ
	output: 
				@Ret		int output		--��ʶ
							1:�ǣ�
							0��û�и��û���
							2�����ͷŸ��û����ܵı༭����ʱ�����
							3��ϵͳ�޷�ʶ���˳���¼�ķ�ʽ
							-1��δ֪����
	author:		¬έ
	CreateDate:	2010-2-1
	UpdateDate: 2010-5-10���ӹ�����־����
				modi by lw 2011-6-28�����ͷ��û����ܴ��ڵı༭��
				modi by lw 2011-7-5��Ϊ����ʹ�ü��ܳ����ӳ����볤�ȣ�
				modi by lw 2013-5-31�����˳��ĵ�¼��ʽ
*/
create PROCEDURE logout
	@userName varchar(30),		--�û���
	@psw	varchar(128),		--��¼����
	@userIP varchar(40),		--�Ự�ͻ���IP
	@logoutMode smallint,		--�˳��ĵ�¼��ʽ��1->��ҳ��¼��2->PC�ͻ��˵�¼��3->��׿�ͻ��˵�¼
	@dynaPsw varchar(36),		--��̬��Կ

	@Ret		int output		--��ʶ
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers 
								where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw)
	declare @userCName nvarchar(30), @userID varchar(10) --�û�������\�û�ID
	if @count > 0
	begin
		--��ȡ�û�������\�û����֤�ţ�
		select @userCName = userCName, @userID = userId 
		from activeUsers 
		where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
		--�����Ӧ�ĵ�¼��ʽ��
		if (@logoutMode=1)
		begin
			update activeUsers
			set loginByBrower = 0
			where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
		end
		else if (@logoutMode=2)
		begin
			update activeUsers
			set loginByClient = 0
			where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
		end
		else if (@logoutMode=3)
		begin
			update activeUsers
			set loginByAndroid = 0
			where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP
		end
		else
		begin
			set @Ret = 3
			return
		end
		--�ж��Ƿ��û�ȫ���ĵ�¼��ʽ���Ѿ��˳���
		declare @actionObject nvarchar(500) --��־
		declare @loginByBrower smallint--ʹ���������¼
		declare @loginByClient smallint	--ʹ��PC�ͻ��˵�¼
		declare @loginByAndroid smallint	--ʹ�ð�׿�ͻ��˵�¼
		select @loginByBrower = loginByBrower, @loginByClient = loginByClient, @loginByAndroid = loginByAndroid 
		from activeUsers 
		where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
		if (@loginByBrower = 0 and @loginByClient = 0 and @loginByAndroid = 0)
		begin
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
			--�Ǽǹ�����־��
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@userID, @userCName, getdate(), '�ǳ�', '�û�' + @userCName + '��ȫ���˳���ϵͳ��')
		end
		set @Ret = 1
	end
	else
		set @Ret = 0
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
				modi by lw 2013-2-24���ӹ�����ʵ�����״̬�ָ���
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

		--�ճ̹������ı༭����
		update taskInfo set lockManID = '' where lockManID = @userID		--��������
		update dutyStatusInfo set lockManID = '' where lockManID = @userID	--����״̬�ǼǱ�

		--�ʼ�������ı༭����
		update mailBindOption set lockManID = '' where lockManID = @userID	--������ǼǱ�༭��
		update signInfo set lockManID = '' where lockManID = @userID		--ǩ���༭��

		--ԤԼ�������ı༭����
		update shareEqpStatus set lockManID = '' where lockManID = @userID		--�����豸״̬��
		update eqpBorrowApplyInfo set lockManID = '' where lockManID = @userID	--�����豸���������
		update placeInfo set lockManID = '' where lockManID = @userID		--����һ����
		update placeApplyInfo set lockManID = '' where lockManID = @userID	--����ʹ�������
		update expStationInfo set lockManID = '' where lockManID = @userID		--����վһ����
		update expStationApplyInfo set lockManID = '' where lockManID = @userID	--����վʹ�������
		update gasInfo set lockManID = '' where lockManID = @userID		--����һ����
		update gasApplyInfo set lockManID = '' where lockManID = @userID	--����ʹ�������

		--�������ı༭����
		update meetingInfo set lockManID = '' where lockManID = @userID		--�������༭��

		--ѧ���������ı༭����
		update academicReports set lockManID = '' where lockManID = @userID		--ѧ������༭��

		--�������������ı༭����
		update workFlowTemplate set lockManID = '' where lockManID = @userID	--������ģ������
		update workFlowTemplateForms set lockManID = '' where lockManID = @userID--������ģ��������
		update workFlowInstance set lockManID = '' where lockManID = @userID	--������ʵ����
		--������ʵ�����״̬��
		update workflowInstanceActivity set activityStatus = 1 where receiverID = @userID and activityStatus=2
/*
		update leaveRequestInfo set lockManID = '' where lockManID = @userID	--������ǼǱ�
		update eqpApplyInfo set lockManID = '' where lockManID = @userID	--�豸�ɹ������
		update thesisPublishApplyInfo set lockManID = '' where lockManID = @userID	--���ķ��������
		update processApplyInfo set lockManID = '' where lockManID = @userID	--����ӹ������
		update otherApplyInfo set lockManID = '' where lockManID = @userID	--���������
*/
		--�豸�������ı༭����
		update equipmentList set lockManID = '' where lockManID = @userID	--�豸��༭��
		update equipmentScrap set lockManID = '' where lockManID = @userID	--�豸���ϵ��༭��
		update equipmentAllocation set lockManID = '' where lockManID = @userID	--�豸�������༭��
		update eqpCheckInfo set lockManID = '' where lockManID = @userID	--�豸�������༭��
		update eqpCheckDetailInfo set lockManID = '' where lockManID = @userID	--�豸���������ϸ��༭��
		update statisticTemplate set lockManID = '' where lockManID = @userID	--ͳ��ģ���༭��
				
		--�ɹ�������ı༭����
		update thesisInfo set lockManID = '' where lockManID = @userID	--���ĵǼǱ�༭��
		update monographInfo set lockManID = '' where lockManID = @userID	--ר���ǼǱ�༭��
		update patentInfo set lockManID = '' where lockManID = @userID	--ר���ǼǱ�༭��
		update awardInfo set lockManID = '' where lockManID = @userID	--����Ϣ�ǼǱ�༭��
		update projectInfo set lockManID = '' where lockManID = @userID	--������Ŀ�ǼǱ�༭��
		
		--Ȩ�޿������ı༭����
		update sysRole set lockManID = '' where lockManID = @userID			--ϵͳ��ɫ�༭��
		update userInfo set lockManID = '' where lockManID = @userID		--ϵͳ�û��༭��

		--��ά���ı༭����
		update bulletinInfo set lockManID = '' where lockManID = @userID	--ϵͳ�����༭��
		update SMSInfo set lockManID = '' where lockManID = @userID			--���Ź����
		update deviceInfo set lockManID = '' where lockManID = @userID		--װ��һ����
		
		--��������Ⱥ�ı༭����
		update discussGroup set lockManID = '' where lockManID = @userID		--������һ����
		update communityGroup set lockManID = '' where lockManID = @userID		--Ⱥ��һ����
		
	commit tran
	set @Ret = 0

GO
--���ԣ�
declare @Ret int
exec dbo.unlockAllEditor 'G201300001',@Ret output
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
	UpdateDate: modi by lw 2013-2-24���ӹ�����ʵ�����״̬�ָ���
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
		update codeDictionary set lockManID = ''	--�����ֵ�༭��
		update typeCodes set lockManID = ''			--�豸��������༭��
		update country set lockManID = ''			--����༭��
		update fundSrc set lockManID = ''			--������Դ�༭��
		update appDir set lockManID = ''			--ʹ�÷���༭��
		update college set lockManID = ''			--ѧԺ��༭��
		update useUnit set lockManID = ''			--ʹ�õ�λ�༭��
		update accountTitle set lockManID = ''		--��ƿ�Ŀ�����ֵ��༭��
		update collegeCode set lockManID = ''		--����������λ����ת����

		--�ճ̹������ı༭����
		update taskInfo set lockManID = ''			--��������
		update dutyStatusInfo set lockManID = ''	--����״̬�ǼǱ�

		--�ʼ�������ı༭����
		update mailBindOption set lockManID = ''	--������ǼǱ�༭��
		update signInfo set lockManID = ''			--ǩ���༭��

		--ԤԼ�������ı༭����
		update shareEqpStatus set lockManID = ''	--�����豸״̬��
		update eqpBorrowApplyInfo set lockManID = '' --�����豸���������
		update placeInfo set lockManID = ''			--����һ����
		update placeApplyInfo set lockManID = ''	--����ʹ�������
		update expStationInfo set lockManID = ''	--����վһ����
		update expStationApplyInfo set lockManID = '' --����վʹ�������
		update gasInfo set lockManID = ''			--����һ����
		update gasApplyInfo set lockManID = ''		--����ʹ�������

		--�������ı༭����
		update meetingInfo set lockManID = ''		--�������༭��

		--ѧ���������ı༭����
		update academicReports set lockManID = ''	--ѧ������༭��

		--�������������ı༭����
		update workFlowTemplate set lockManID = ''	--������ģ������
		update workFlowTemplateForms set lockManID = ''	--������ģ��������
		update workFlowInstance set lockManID = ''	--������ʵ����
		--������ʵ�����״̬��
		update workflowInstanceActivity set activityStatus = 1 where activityStatus=2
/*
		update leaveRequestInfo set lockManID = ''	--������ǼǱ�
		update eqpApplyInfo set lockManID = ''		--�豸�ɹ������
		update thesisPublishApplyInfo set lockManID = '' --���ķ��������
		update processApplyInfo set lockManID = ''	--����ӹ������
		update otherApplyInfo set lockManID = ''	--���������
*/

		--�豸�������ı༭����
		update equipmentList set lockManID = ''		--�豸��༭��
		update equipmentScrap set lockManID = ''	--�豸���ϵ��༭��
		update equipmentAllocation set lockManID = '' --�豸�������༭��
		update eqpCheckInfo set lockManID = ''		--�豸�������༭��
		update eqpCheckDetailInfo set lockManID = ''--�豸���������ϸ��༭��
		update statisticTemplate set lockManID = '' --ͳ��ģ���༭��
				
		--�ɹ�������ı༭����
		update thesisInfo set lockManID = ''	--���ĵǼǱ�༭��
		update monographInfo set lockManID = '' --ר���ǼǱ�༭��
		update patentInfo set lockManID = ''	--ר���ǼǱ�༭��
		update awardInfo set lockManID = ''		--����Ϣ�ǼǱ�༭��
		update projectInfo set lockManID = ''	--������Ŀ�ǼǱ�༭��
		
		--Ȩ�޿������ı༭����
		update sysRole set lockManID = ''		--ϵͳ��ɫ�༭��
		update userInfo set lockManID = ''		--ϵͳ�û��༭��

		--��ά���ı༭����
		update bulletinInfo set lockManID = ''	--ϵͳ�����༭��
		update SMSInfo set lockManID = ''		--���Ź����
		update deviceInfo set lockManID = ''	--װ��һ����

		--��������Ⱥ�ı༭����
		update discussGroup set lockManID = ''	--������һ����
		update communityGroup set lockManID = ''--Ⱥ��һ����
	commit tran
	set @Ret = 0

GO
--���ԣ�
declare @Ret int
exec dbo.unlockAllUserLock '0000000001',@Ret output
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

drop PROCEDURE modiPassword2
/*
	name:		modiPassword2
	function:	6.�޸�����
				ע�⣺����洢���̼��ԭ�����Ƿ������ݿ��еǼǵ�һ�£�
	input: 
				@jobNumber varchar(10),		--���ţ�����
				@oldPassword varchar(128),	--ԭϵͳ��¼����
				--ϵͳ��¼��Ϣ��
				@newPassword varchar(128),	--��ϵͳ��¼����

				--����ά�����:
				@modiManID varchar(10),		--�޸��˹���
	output: 
				@Ret		int output,
							0:�ɹ���1:���û������ڻ��������9:δ֪����
	author:		¬έ
	CreateDate:	2013-7-12
	UpdateDate: 
*/
create PROCEDURE modiPassword2
	@jobNumber varchar(10),		--���ţ�����
	@oldPassword varchar(128),	--ԭϵͳ��¼����
	@newPassword varchar(128),	--��ϵͳ��¼����

	--����ά�����:
	@modiManID varchar(10),		--�޸��˹���

	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
		 
	--ȡά���˵�������
	declare @modiManName nvarchar(30), @cName nvarchar(30)
	set @modiManName = isnull((select cName from userInfo where jobNumber = @modiManID),'')
	set @cName = isnull((select cName from userInfo where jobNumber = @jobNumber and sysPassword=@oldPassword),'')
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
--���ԣ�
exec dbo.modiPassword2
select * from epdc211.dbo.userInfo where cName='������'
update userInfo
set sysPassword = jobNumber



--��������ͼ��
create view [dbo].[userInfoView]
as
select jobNumber,cName,pID,mobileNum,telNum,e_mail,homeAddress,clgCode,clgName,uCode,uName,
sysUserName,sysUserDesc,dbo.getSysUserRole(jobNumber) sysRoleName,sysPassword,pswProtectQuestion,psqProtectAnswer,
case isOff when '0' then '��' else '' end isOff,
case isOff when '0' then '' else convert(char(10), setOffDate, 120) end offDate,
modiManID,modiManName,modiTime,lockManID
from userInfo
go

use hustOA
select * from userInfo





select jobNumber, workNumber, manType,
	--������Ϣ��
	cName, pID, countryCode, countryName, birthDay, sex, bodyHeight, homeTown, 
	nationalityCode, nationality, politicalScapeCode, politicalScape, maritalStatusCode, maritalStatus,
	--������Ϣ��
	clgCode, clgName, uCode, uName, tutorID, tutorName,
	--������Ϣ��
	workPos, workPostID, workPost, entryTime,
	--��ϵ��ʽ��	
	officeTel, mobile, e_mail, homeAddress, homeTel, urgentConnecter, urgentTel,
	--ϵͳ��¼��Ϣ��
	sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer,
	--ά����Ϣ��
	isOff, setOffDate,
	modiManID, modiManName, modiTime
from userInfo


select * from userInfo 
select * from codeDictionary where classCode='20'

select userID, userCName, loginByBrower, loginByClient, loginByAndroid, dynaPsw, case when DATEDIFF(minute,activeTime,GETDATE())>20 then 0 else 1 end activeStatus
from activeUsers 

update activeUsers 
set loginByClient=1 
where userid='G201300040'


update userInfo
set mobile=null, e_mail=null




select rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc  
from sysRoleRight 
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = 'G201300091') 
group by rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc 
order by rightKind, rightClass, rightItem; 

select * from sysRoleRight where sysRoleID=18
select sysRoleID,* from sysUserRole where jobNumber = 'G201300091'
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprPartSize) oprPartSize 
from sysRoleDataOpr 
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = 'G201300091') 
group by rightKind, rightClass, rightItem, sortNum, oprType, oprName, oprEName, oprDesc 
order by rightKind, rightClass, rightItem, sortNum, oprType