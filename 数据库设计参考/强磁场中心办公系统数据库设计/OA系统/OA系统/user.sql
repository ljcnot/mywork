use hustOA
/*
	强磁场中心办公系统-系统用户表设计
	author:		卢苇
	客户要求：
	用户分级问题：
	1.用户分三级：校级、院级、科室级，可以调阅的权限分别为：全校、全院、全科室的设备.使用角色分级和数据对象的操作范围约束实现!
	2.支持游客，只能查询，不能生成报表
	CreateDate:	2010-11-22
	UpdateDate: by lw 2011-9-12 修改用户表，支持多重角色，去除用户权限表，将用户权限改为动态计算。
				
*/
select * from userInfo where mobile='18602702392'
select * from sysRole
update sysRole
set sysRoleID = 1
where sysRoleID = 38
select * from workNote
select * from sysUserRole
select * from sysRoleRight
--1.系统用户信息表 （userInfo）：
drop TABLE userInfo
CREATE TABLE userInfo
(
	jobNumber varchar(10) not null,		--主键：工号：本系统中因为不是从人事系统中获得工号，所以增加了号码发生器，使用第12000号号码发生器
	workNumber varchar(10) null,		--工作证号：这是用户可以输入的号码，不做唯一性检查
	manType smallint not null,			--类别：1->教工，9->学生 add by lw 2012-12-27
	
	--个人信息：
	cName nvarchar(30) not null,		--姓名：不做唯一性检查
	pID varchar(18) null,				--身份证号
	countryCode char(3) null,			--国籍代码（国家代码）
	countryName nvarchar(60) null,		--国籍名称（国家名称）
	birthDay smalldatetime null,		--出生日期
	sex int null,						--性别：使用第201号代码字典解释，1->男，2->女，界面做成选择框，代码字典中的其他部门不用！
	bodyHeight int null,				--身高：单位：厘米
	homeTown nvarchar(20) null,			--籍贯
	nationalityCode int null,			--民族代码:由第203号代码字典定义
	nationality nvarchar(30) null,		--民族
	politicalScapeCode int null,		--政治面貌代码:由第210号代码字典定义
	politicalScape nvarchar(10) null,	--政治面貌
	maritalStatusCode int null,			--婚姻状况代码：由第213号代码字典定义
	maritalStatus nvarchar(8) null,		--婚姻状况

	--隶属信息：
	clgCode char(3) not null,			--本系统不适用：所属学院代码:为保持兼容性固定为001
	clgName nvarchar(30) not null,		--本系统不适用：所属学院名称:为保持兼容性固定为强磁场中心。冗余设计
	uCode varchar(8) null,				--部门代码（所属使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！)
	uName nvarchar(30) null,			--部门名称（所属使用单位名称:冗余设计）
	tutorID varchar(10) null,			--导师工号:当类别为学生时要求输入 add by lw 2012-12-27
	tutorName nvarchar(30) null,		--导师姓名:当类别为学生时要求输入。冗余设计 add by lw 2012-12-27
	
	--工作信息：
	workPos nvarchar(30) null,			--岗位
	workPostID int null,				--职称ID：使用第218号代码字典
	workPost nvarchar(10) null,			--职称名称：冗余设计
	entryTime smalldatetime null,		--入职时间

	--联系方式：	
	officeTel varchar(30) null,			--办公电话
	mobile varchar(20) null,			--手机号码
	e_mail varchar(30) null,			--E_mail地址
	homeAddress nvarchar(100) null,		--住址
	homeTel varchar(30) null,			--家庭电话
	urgentConnecter nvarchar(30) null,	--紧急联系人
	urgentTel varchar(30) null,			--紧急联系人电话
	
	--系统登录信息：
	sysUserName varchar(30) not null,	--用户名:要做唯一性检查
	sysUserDesc nvarchar(100) null,		--系统用户描述性文字
	
	--modi by lw 2011-7-5因为使用加密程序，要求将字段长度延长！
	sysPassword varchar(128) null,		--系统登录密码：密码要使用加密算法加密！
	pswProtectQuestion varchar(40) null,--密码保护问题
	psqProtectAnswer varchar(40) null,	--密码保护问题的答案

	isOff int default(1),				--是否激活：0->激活，1->未激活
	setOffDate smalldatetime,			--注销日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10) null,			--当前正在锁定编辑人工号
CONSTRAINT [PK_memberInfo] PRIMARY KEY CLUSTERED 
(
	[jobNumber] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
select * from college

insert userInfo(jobNumber, manType, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('G201300001',1,'程远','001','脉冲强磁场科学中心','chengyuan','9369A71B2CA05876A068A505462AD673','0000000000')
insert userInfo(jobNumber, manType, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('G201300002',1,'卢苇','001','脉冲强磁场科学中心','lw','9369A71B2CA05876A068A505462AD673','0000000000')

use hustOA
select * from userInfo where cName='卢苇'
update userInfo
set sysPassword='9369A71B2CA05876A068A505462AD673'
where cName='卢苇'

--2.用户学习经历表：
drop TABLE userStudyInfo
CREATE TABLE userStudyInfo
(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--行号
	jobNumber varchar(10) not null,		--外键：工号
	cName nvarchar(30) not null,		--姓名：冗余设计
	eduLevelCode int null,				--学历学位（文化程度）：由第211号代码字典定义
	eduLevel nvarchar(20) null,			--学历学位（文化程度）
	beginTime smalldatetime null,		--开始时间
	endTime smalldatetime null,			--结束时间
	college nvarchar(30) null,			--毕业学校
	discipline nvarchar(20) null,		--所学专业
	tutor nvarchar(30) null,			--导师
	
CONSTRAINT [PK_userStudyInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[userStudyInfo] WITH CHECK ADD CONSTRAINT [FK_userStudyInfo_userInfo] FOREIGN KEY([jobNumber])
REFERENCES [dbo].[userInfo] ([jobNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[userStudyInfo] CHECK CONSTRAINT [FK_userStudyInfo_userInfo]
GO
select * from userInfo
--3.用户工作经历表：
drop TABLE userWorkInfo
CREATE TABLE userWorkInfo
(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,--行号
	jobNumber varchar(10) not null,		--外键：工号
	cName nvarchar(30) not null,		--姓名：冗余设计
	beginTime smalldatetime null,		--开始时间
	endTime smalldatetime null,			--结束时间
	postName nvarchar(10) null,			--职位名称
	workUnit nvarchar(30) null,			--任职单位
	changeReason nvarchar(30) null,		--变动原因
CONSTRAINT [PK_userWorkInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
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
	function:	0.1.检查指定用户是否拥有“超级用户”角色，如果拥有，检查超级用户是否拥有全部的系统权限
				如果未拥有则提示用户需要更新
	input: 
				@jobNumber varchar(10)		--工号：主键
	output: 
				@Ret		int output			--操作成功标识
							0:不需要更新，1：需要更新，2：该用户不存在
							9：未知错误
	author:		卢苇
	CreateDate:	2012-8-8
	UpdateDate: 
*/
create PROCEDURE checkSuperManRights
	@jobNumber varchar(10),			--工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	--检查该用户是否拥有“超级用户”角色：
	set @count = (select COUNT(*) from sysUserRole 
					where jobNumber = @jobNumber and sysRoleID = 1 and sysRoleName='超级用户')
	if (@count = 0)	--不存在
	begin
		set @Ret = 0
		return
	end
	
	--检查“超级用户”角色是否拥有了全部的系统权限：
	set @count = (select COUNT(*) from sysRight
					where canUse='Y' and rightKind * 1000 + rightClass * 100 + rightItem 
							not in (select rightKind * 1000 + rightClass * 100 + rightItem 
									from sysRoleRight where sysRoleID = 1))
	if (@count > 0)	--存在
	begin
		set @Ret = 1
		return
	end

	--检查“超级用户”角色是否拥有了全部的系统资源的操作集并且是最大操作范围：
	declare @rightKind smallint, @rightClass smallint, @rightItem smallint
	declare @oprEName varchar(20)	--操作的英文名称

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
		declare @maxPartSize int, @partSize int	--操作的最大范围
		--获取操作的最大访问范围：
		set @maxPartSize = (select max(partSize) from sysRightPartSize 
							where rightKind = @rightKind and rightClass = @rightClass 
								and rightItem = @rightItem)
		--获取超级用户的操作范围：
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
--测试：
declare @Ret int	--操作成功标识
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
	function:	0.2.更新超级用户权限
	input: 
				@updateManID varchar(10),		--更新人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：无超级用户角色，9：未知错误
	author:		卢苇
	CreateDate:	2012-8-8
	UpdateDate: 
*/
create PROCEDURE updateSuperManRights
	@updateManID varchar(10),		--更新人工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断超级用户角色是否存在
	declare @count as int
	set @count = (select COUNT(*) from sysRole 
					where sysRoleID = 1 and sysRoleName='超级用户')
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查“超级用户”角色是否拥有了全部的系统权限：
	set @count = (select COUNT(*) from sysRight
					where canUse='Y' and rightKind * 1000 + rightClass * 100 + rightItem 
							not in (select rightKind * 1000 + rightClass * 100 + rightItem 
									from sysRoleRight where sysRoleID = 1))
	if (@count > 0)	--存在
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

	--检查“超级用户”角色是否拥有了全部的系统资源的操作集并且是最大操作范围：
	declare @rightKind smallint, @rightClass smallint, @rightItem smallint
	declare @oprEName varchar(20)	--操作的英文名称

	declare tar cursor for
	select d.rightKind, d.rightClass, d.rightItem, d.oprEName
	from sysRight s inner join sysDataOpr d on s.rightKind = d.rightKind and s.rightClass = d.rightClass
			and s.rightItem = d.rightItem
	where canUse='Y'
	OPEN tar
	FETCH NEXT FROM tar INTO @rightKind, @rightClass, @rightItem, @oprEName
	WHILE @@FETCH_STATUS = 0
	begin
		declare @maxPartSize int, @partSize int	--操作的最大范围
		--获取操作的最大访问范围：
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
	
	--取添加人的姓名：
	declare @updateManName nvarchar(30)
	set @updateManName = isnull((select userCName from activeUsers where userID = @updateManID),'')
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@updateManID, @updateManName, GETDATE(), 
								'更新超级用户的权限','系统根据' + @updateManName + 
								'的要求更新了超级用户的权限表。')
	set @Ret = 0
GO
--测试：
declare @Ret int	--操作成功标识
exec dbo.updateSuperManRights '0000000000',@Ret output
select @Ret

drop FUNCTION getSysUserRole
/*
	name:		getSysUserRole
	function:	1.根据用户工号获取用户角色名
	input: 
				@jobNumber varchar(10)		--工号：主键
	output: 
				return varchar(1024)		--用户角色名：多个角色名采用“,”分隔
	author:		卢苇
	CreateDate:	2012-6-9
	UpdateDate: 
*/
create FUNCTION getSysUserRole
(  
	@jobNumber varchar(10)		--工号：主键
)  
RETURNS varchar(1024)
WITH ENCRYPTION
AS      
begin
	declare @result as varchar(1024), @i as int
	set @result = ''; set @i = 0;
	declare @sysRoleName varchar(50)	--角色中文名
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
--测试：
select dbo.getSysUserRole('00000021')

select * from userInfo
select * from sysUserRole

drop FUNCTION getUserType
/*
	name:		getUserType
	function:	1.根据用户工号获取用户类别和或导师工号、姓名（当时学生的时候给出导师的工号和姓名）
	input: 
				@jobNumber varchar(10)		--工号：主键
	output: 
				@Ret int output,				--操作成功标识:0->成功，9->失败
				@manType smallint output,		--类别：1->教工，9->学生 add by lw 2012-12-27
				@tutorID varchar(10) output,	--导师工号:当类别为学生时要求输入 add by lw 2012-12-27
				@tutorName nvarchar(30) output	--导师姓名:当类别为学生时要求输入。冗余设计 add by lw 2012-12-27
	author:		卢苇
	CreateDate:	2013-3-3
	UpdateDate: 
*/
create PROCEDURE getUserType
	@jobNumber varchar(10),			--工号
	@Ret int output,				--操作成功标识
	@manType smallint output,		--类别：1->教工，9->学生 add by lw 2012-12-27
	@tutorID varchar(10) output,	--导师工号:当类别为学生时要求输入 add by lw 2012-12-27
	@tutorName nvarchar(30) output	--导师姓名:当类别为学生时要求输入。冗余设计 add by lw 2012-12-27
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

--测试：
declare @Ret int, @manType smallint, @tutorID varchar(10), @tutorName nvarchar(30)
exec dbo.getUserType '00001', @Ret output, @manType output, @tutorID output, @tutorName output
select @Ret, @manType, @tutorID, @tutorName

update userInfo
set manType = 1
where jobNumber<>'00001'
select * from userInfo
select * from sysUserRole

update userInfo
set manType = 9, tutorID = '005006', tutorName='胡颖'
where jobNumber = '00001'


drop PROCEDURE addUser
/*
	name:		addUser
	function:	1.添加用户
				注意：这个存储过程检查工号和系统登陆名的唯一性！
	input: 
				@workNumber varchar(10),	--工作证号：这是用户可以输入的号码，不做唯一性检查
				@manType smallint,			--类别：1->教工，9->学生 add by lw 2012-12-27
				--个人信息：
				@cName nvarchar(30),		--姓名
				@pID varchar(18),			--身份证号
				@countryCode char(3),		--国籍代码（国家代码）
				@birthDay varchar(10),		--出生日期
				@sex int,					--性别：使用第201号代码字典解释，1->男，2->女，界面做成选择框，代码字典中的其他部门不用！
				@bodyHeight int,			--身高：单位：厘米
				@homeTown nvarchar(20),		--籍贯
				@nationalityCode int,		--民族代码:由第203号代码字典定义
				@politicalScapeCode int,	--政治面貌代码:由第210号代码字典定义
				@maritalStatusCode int,		--婚姻状况代码：由第213号代码字典定义
				--隶属信息：
				@clgCode char(3),			--本系统不适用：所属学院代码:为保持兼容性固定为001
				@uCode varchar(8),			--部门代码（所属使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！)
				@tutorID varchar(10),		--导师工号:当类别为学生时要求输入 add by lw 2012-12-27
				--工作信息：
				@workPos nvarchar(30),		--岗位
				@workPostID int,			--职称ID：使用第218号代码字典
				@entryTime varchar(10),		--入职时间
				--联系方式：	
				@officeTel varchar(30),		--办公电话
				@mobile varchar(20),		--手机号码
				@e_mail varchar(30),		--E_mail地址
				@homeAddress nvarchar(100),	--住址
				@homeTel varchar(30),		--家庭电话
				@urgentConnecter nvarchar(30),	--紧急联系人
				@urgentTel varchar(30),		--紧急联系人电话
				--系统登录信息：
				@sysUserName varchar(30),	--用户名:要做唯一性检查
				@sysUserDesc nvarchar(100),	--系统用户描述性文字
				@sysPassword varchar(128),	--系统登录密码
				@pswProtectQuestion varchar(40),--密码保护问题
				@psqProtectAnswer varchar(40),	--密码保护问题的答案
				--学习经历：
				@studyInfo xml,
				--工作经历：
				@workInfo xml,
				
				--最新维护情况:
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output,
							0:成功，2:该用户名已经被注册过了，3:该手机已经被注册，4：该邮箱已经被注册，9:未知错误
				@jobNumber varchar(10) output	--人员编号：本系统使用第12000号号码发生器产生（'G'+4位年份代码+5位流水号）
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2011-9-4去除角色中文名，增加角色分级类型处理
				modi by lw 2011-9-12修改用户表，支持多重角色，去除用户权限表，将用户权限改为动态计算。
				modi by lw 2013-1-1增加人员类别接口
				modi by lw 2013-1-11根据数据库字段变化增加接口，增加号码发生器，自动生成工号
				modi by lw 2013-1-25增加学习经历、工作经历空行判断
				modi by lw 2013-7-12增加手机和eMail地址的唯一性判断
*/
create PROCEDURE addUser
	@workNumber varchar(10),	--工作证号：这是用户可以输入的号码，不做唯一性检查
	@manType smallint,			--类别：1->教工，9->学生 add by lw 2012-12-27
	--个人信息：
	@cName nvarchar(30),		--姓名
	@pID varchar(18),			--身份证号
	@countryCode char(3),		--国籍代码（国家代码）
	@birthDay varchar(10),		--出生日期
	@sex int,					--性别：使用第201号代码字典解释，1->男，2->女，界面做成选择框，代码字典中的其他部门不用！
	@bodyHeight int,			--身高：单位：厘米
	@homeTown nvarchar(20),		--籍贯
	@nationalityCode int,		--民族代码:由第203号代码字典定义
	@politicalScapeCode int,	--政治面貌代码:由第210号代码字典定义
	@maritalStatusCode int,		--婚姻状况代码：由第213号代码字典定义
	--隶属信息：
	@clgCode char(3),			--本系统不适用：所属学院代码:为保持兼容性固定为001
	@uCode varchar(8),			--部门代码（所属使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！)
	@tutorID varchar(10),		--导师工号:当类别为学生时要求输入 add by lw 2012-12-27
	--工作信息：
	@workPos nvarchar(30),		--岗位
	@workPostID int,			--职称ID：使用第218号代码字典
	@entryTime varchar(10),		--入职时间
	--联系方式：	
	@officeTel varchar(30),		--办公电话
	@mobile varchar(20),		--手机号码
	@e_mail varchar(30),		--E_mail地址
	@homeAddress nvarchar(100),	--住址
	@homeTel varchar(30),		--家庭电话
	@urgentConnecter nvarchar(30),	--紧急联系人
	@urgentTel varchar(30),		--紧急联系人电话
	--系统登录信息：
	@sysUserName varchar(30),	--用户名:要做唯一性检查
	@sysUserDesc nvarchar(100),	--系统用户描述性文字
	@sysPassword varchar(128),	--系统登录密码
	@pswProtectQuestion varchar(40),--密码保护问题
	@psqProtectAnswer varchar(40),	--密码保护问题的答案
	--学习经历：
	@studyInfo xml,
	--工作经历：
	@workInfo xml,
	
	--最新维护情况:
	@createManID varchar(10),	--创建人工号

	@Ret int output,
	@jobNumber varchar(10) output	--人员编号：本系统使用第12000号号码发生器产生（'G'+4位年份代码+5位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查系统登录账号名是否唯一：
	declare @count as int
	set @count = (select count(*) from userInfo where sysUserName = @sysUserName)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	--检查手机是否唯一：
	set @mobile=LTRIM(rtrim(@mobile))
	if (@mobile <>'')
	set @count = (select count(*) from userInfo where mobile = @mobile)
	if @count > 0
	begin
		set @Ret = 3
		return
	end

	--检查邮箱是否唯一：
	set @e_mail=LTRIM(rtrim(@e_mail))
	if (@e_mail <>'')
	set @count = (select count(*) from userInfo where e_mail = @e_mail)
	if @count > 0
	begin
		set @Ret = 4
		return
	end

	--使用号码发生器产生工号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 12000, 1, @curNumber output
	set @jobNumber = @curNumber

	--取院部名称和使用单位\导师名称：
	declare @clgName nvarchar(30), @uName nvarchar(30), @tutorName nvarchar(30)		--所属学院名称、所属使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	
	--根据代码取国家、民族、政治面貌、婚姻状态等名称：
	declare @countryName nvarchar(60) ,	@nationality nvarchar(30)
	declare @politicalScape nvarchar(10), @maritalStatus nvarchar(8)
	set @countryName = isnull((select cName from country where cCode = @countryCode),'')
	set @nationality = isnull((select objDesc from codeDictionary where classCode = 203 and objCode = @nationalityCode),'')
	set @politicalScape  = isnull((select objDesc from codeDictionary where classCode = 210 and objCode = @politicalScapeCode),'')
	set @maritalStatus = isnull((select objDesc from codeDictionary where classCode = 213 and objCode = @maritalStatusCode),'')

		 
	--职称名称：
	declare @workPost nvarchar(10)
	set @workPost = isnull((select objDesc from codeDictionary where classCode = 218 and objCode = @workPostID),'')

	--取添加人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	--处理异常日期数据：
	declare @rBrithDay smalldatetime, @rEntryTime smalldatetime
	if (@birthDay='')	--出生日期
		set @rBrithDay = null
	else
		set @rBrithDay = convert(smalldatetime,@birthDay,120)
		
	if (@entryTime='')	--入职时间
		set @rEntryTime = getdate()
	else
		set @rEntryTime = convert(smalldatetime,@entryTime,120)
		
	declare @createTime smalldatetime
	set @createTime = getdate()
	begin tran
		insert userInfo (jobNumber, workNumber, manType,
				--个人信息：
				cName, pID, countryCode, countryName, birthDay, 
				sex,
				bodyHeight, homeTown, nationalityCode, nationality, 
				politicalScapeCode, politicalScape, maritalStatusCode, maritalStatus,
				--隶属信息：
				clgCode, clgName, uCode, uName, tutorID, tutorName,
				--工作信息：
				workPos, workPostID, workPost, entryTime,
				--联系方式：	
				officeTel, mobile, e_mail, homeAddress, homeTel, urgentConnecter, urgentTel,
				--系统登录信息：
				sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer,
				--最新维护情况:
				modiManID, modiManName, modiTime)
		values(@jobNumber, @workNumber, @manType,
				--个人信息：
				@cName, @pID, @countryCode, @countryName, @rBrithDay, 
				@sex,
				@bodyHeight, @homeTown, @nationalityCode, @nationality, 
				@politicalScapeCode, @politicalScape, @maritalStatusCode, @maritalStatus,
				--隶属信息：
				@clgCode, @clgName, @uCode, @uName, @tutorID, @tutorName,
				--工作信息：
				@workPos, @workPostID, @workPost, @rEntryTime,
				--联系方式：	
				@officeTel, @mobile, @e_mail, @homeAddress, @homeTel, @urgentConnecter, @urgentTel,
				--系统登录信息：
				@sysUserName, @sysUserDesc, @sysPassword, @pswProtectQuestion, @psqProtectAnswer,
				--最新维护情况:
				@createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		--登记学习经历：
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
		--登记工作经历：
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'注册用户','系统根据' + @createManName + 
								'的要求注册了用户[' + @cName + '('+ @sysUserName +')]的信息。')
GO
--测试：
declare @studyInfo xml
set @studyInfo = N'<root>
						<row id="1">
							<eduLevelCode>40</eduLevelCode>
							<eduLevel>中等职业教</eduLevel>
							<beginTime>2013-01-01</beginTime>
							<endTime>2013-01-26</endTime>
							<college>微软中国</college>
							<discipline>软件设计</discipline>
							<tutor>不知道</tutor>
						</row>
				  </root>'
declare @workInfo xml
set @workInfo = N'<root>
						<row id="1">
							<beginTime>2011-01-01</beginTime>
							<endTime>2015-01-01</endTime>
							<postName>工程师</postName>
							<workUnit>IBM</workUnit>
							<changeReason>身体原因</changeReason>
						</row>
						<row id="2">
							<beginTime>2015-01-01</beginTime>
							<endTime>2019-01-01</endTime>
							<postName>工程师</postName>
							<workUnit>IBM 公司</workUnit>
							<changeReason>原因</changeReason>
						</row>
					</root>'	
declare	@Ret int
declare	@jobNumber varchar(10)
select * from useUnit
exec dbo.addUser '工作证', 1, '测试用户', '001002003', '004', '1970-09-01', 1, 156, '万', 0, 0, 0, '001', '001001','','测试',
	0, '','87889011','18602702392','lw_bk@163.com', '武汉','87889010','lc','13329723988','lw8888454','cesh123i','12345','Hello','a',@studyInfo,@workInfo, 
	'0000000000', @ret output, @jobNumber output
select @ret, @jobNumber
select * from userInfo
select * from userStudyInfo

drop PROCEDURE clearUserRole
/*
	name:		clearUserRole
	function:	1.1.清除角色
	input: 
				@jobNumber varchar(10),			--工号
				@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该用户不存在，2:当前用户信息正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-9-12
	UpdateDate: 
*/
create PROCEDURE clearUserRole
	@jobNumber varchar(10),			--工号
	@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '清除用户角色', '用户' + @delManName
												+ '清除了用户['+ @jobNumber +']的全部角色。')

GO

drop PROCEDURE addUserRole
/*
	name:		addUserRole
	function:	1.2.添加用户角色
	input: 
				@jobNumber varchar(10),		--工号
				@sysRoleID smallint,		--角色ID

				--最新维护情况:
				@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1.该用户不存在，2：该用户正被别人锁定编辑，3:该角色已经登记过，9:未知错误
	author:		卢苇
	CreateDate:	2011-9-12
	UpdateDate: 
*/
create PROCEDURE addUserRole
	@jobNumber varchar(10),		--工号
	@sysRoleID smallint,		--角色ID

	--最新维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查角色是否唯一：
	set @count = (select count(*) from sysUserRole where jobNumber = @jobNumber and sysRoleID = @sysRoleID)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--获取用户名：
	declare @sysUserName varchar(30)
	set @sysUserName = isnull((select sysUserName from userInfo where jobNumber = @jobNumber),'')
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--获取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = isnull((select sysRoleName from sysRole where sysRoleID = @sysRoleID),'')

	insert sysUserRole(jobNumber, sysUserName, sysRoleID, sysRoleName, sysRoleType)
	select @jobNumber, @sysUserName, sysRoleID, sysRoleName, sysRoleType 
	from sysRole
	where sysRoleID = @sysRoleID

	set @updateTime = getdate()
	update userInfo 
	set --维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '添加用户角色', '用户' + @modiManName 
												+ '给用户['+ @jobNumber +']的添加了角色['+ @sysRoleName +']。')
GO


drop PROCEDURE checkJobNumber
/*
	name:		checkJobNumber
	function:	2.1.检查工号是否唯一
	input: 
				@jobNumber varchar(10),		--工号
	output: 
				@Ret		int output
							0:唯一，>1：不唯一，-1：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE checkJobNumber
	@jobNumber varchar(10),		--工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from userInfo where jobNumber = @jobNumber)
GO


drop PROCEDURE checkSysUserName
/*
	name:		checkSysUserName
	function:	2.2.检查用户名是否唯一
	input: 
				@sysUserName varchar(30),		--系统登录用户名
	output: 
				@Ret		int output
							0:唯一，>1：不唯一，-1：未知错误
	author:		卢苇
	CreateDate:	2010-5-30
	UpdateDate: 
*/
create PROCEDURE checkSysUserName
	@sysUserName varchar(30),		--系统登录用户名
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from userInfo where sysUserName = @sysUserName)
GO

--1.2对象的LOGO图片文件名登记表 （logoFileInfo）：
drop TABLE logoFileInfo
CREATE TABLE logoFileInfo
(
	myID varchar(10) NOT NULL,			--LOGO图片对应的对象ID
	logoID int NOT NULL,				--logo的ID
	logoGUID36 varchar(36) NULL,		--logo对应的36位全球唯一编码文件名
	logoExtFileName varchar(4) NULL,	--logo的扩展名
CONSTRAINT [PK_logoFileInfo] PRIMARY KEY CLUSTERED 
(
	[myID] ASC,
	[logoID]
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE addLogo
/*
	name:		addLogo
	function:	向当前图片的左侧或右侧插入新的图片
				注意：这需要图片的编号是连续的，所以删除需要特殊处理！
	input: 
				@myID varchar(10),			--LOGO图片对应的对象ID
				@curLogo int,				--当前图片的编号
				@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
				@logoExtFileName varchar(4),--插入的Logo文件扩展名
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，1：出错

				@logoGUID36 varchar(36) output,--系统分配的唯一文件名
				@thisLogoID int output		--插入的Logo编号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE addLogo
	@myID varchar(10),			--LOGO图片对应的对象ID
	@curLogo int,				--当前图片的编号
	@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
	@logoExtFileName varchar(4),--插入的Logo文件扩展名

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--系统分配的唯一文件名
	@thisLogoID int output		--插入的Logo编号
	WITH ENCRYPTION 
AS
	set @Ret = 1

	--判断当前编号的图片是否存在，根据方向生成要插入的图片的编号
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @myID and logoID = @curLogo)	
	begin tran
		if (@count > 0)	--该图片存在，计算插入图片的编号
		begin
			if (@insertDir = 1)	--在右侧插入
			begin
				update logoFileInfo
				set logoID = logoID + 1 
				where myID = @myID and logoID > @curLogo
				set @thisLogoID = @curlogo + 1
			end
			else	--在左侧插入
			begin
				update logoFileInfo
				set logoID = logoID + 1 
				where myID = @myID and logoID >= @curLogo
				set @thisLogoID = @curlogo 
			end
		end
		else 	--第1次插入图片
		begin
			set @thisLogoID = 0
		end

		--生成唯一的文件名：
		set @logoGUID36 = (select newid())

		--登记图片信息：
		insert dbo.logoFileInfo(myID, logoID, logoGUID36, logoExtFileName)
		values(@myID, @thisLogoID, @logoGUID36, @logoExtFileName)
	commit tran
	set @Ret = 0
GO

drop PROCEDURE delLogo
/*
	name:		delLogo
	function:	删除指定对象的当前图片
				注意：这需要对象图片的编号是连续的，所以删除需要特殊处理！
	input: 
				@myID varchar(10),			--LOGO图片对应的对象ID
				@curLogo int,				--当前图片的编号
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，1：要删除的图片不存在，2：出错
				@logoGUID36 varchar(36) output,--当前图片的文件名
				@thisLogoID int output		--删除后当前的图片的编号
	author:		卢苇
	CreateDate:	2010-5-28
	UpdateDate: 
*/
create PROCEDURE delLogo
	@myID varchar(10),			--LOGO图片对应的对象ID
	@curLogo int,				--当前图片的编号

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--当前图片的文件名
	@thisLogoID int output		--删除后当前的图片的编号
	WITH ENCRYPTION 
AS
	set @Ret = 2
	set @thisLogoID = @curLogo

	--判断当前编号的图片是否存在
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @myID and logoID = @curLogo)	
	if (@count = 0)	--该图片不存在
	begin
		set @Ret = 1
		return
	end
	
	begin tran
	--获取要删除的当前图片的文件名：
	declare @GUID36 varchar(36), @extFileName varchar(4)
	select @GUID36 = logoGUID36, @extFileName = logoExtFileName
	from logoFileInfo
	where myID = @myID and logoID = @curLogo
	set @logoGUID36 = @GUID36 + @extFileName 

	delete logoFileInfo where myID = @myID and logoID = @curLogo
	update logoFileInfo set logoID = logoID - 1 where myID = @myID and logoID > @curLogo

	--判断是否删除的是最后一张图片，如果是修正当前图片索引号
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
	function:	3.添加用户的Logo
	input: 
				@jobNumber varchar(10),		--工号
				@curLogo int,				--当前图片的编号
				@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
				@logoExtFileName varchar(4),--插入的Logo文件扩展名

				@addManID varchar(10) output,	--添加人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output,			--操作成功标识
							0:成功，1:不存在该用户，2:该用户信息正被别人锁定，9:未知错误
				@logoGUID36 varchar(36) output,--系统分配的唯一文件名
				@thisLogoID int output		--插入的Logo编号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE addUserLogo
	@jobNumber varchar(10),		--工号
	@curLogo int,				--当前图片的编号
	@insertDir smallint,		--插入的方向：1->右侧 -1->左侧
	@logoExtFileName varchar(4),--插入的Logo文件扩展名

	@addManID varchar(10) output,		--添加人，如果当前用户正在被人占用编辑则返回该人的工号

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--系统分配的唯一文件名
	@thisLogoID int output		--插入的Logo编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查用户是否存在
	declare @count as int
	set @count = (select count(*) from userInfo where jobNumber = @jobNumber)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取添加人的姓名：
	declare @addManName nvarchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')

	--登记维护信息：
	update userInfo
	set modiManID = @addManID, modiManName = @addManName, modiTime = @addTime
	where jobNumber = @jobNumber

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @addTime, '添加用户Logo', @addManName
												+ '添加了用户['+ @jobNumber +']的一个Logo。')
GO

drop PROCEDURE delUserLogo
/*
	name:		delUserLogo
	function:	4.删除指定用户的当前图片
				注意：这需要用户图片的编号是连续的，所以删除需要特殊处理！
	input: 
				@jobNumber varchar(10),		--工号
				@curLogo int,				--当前图片的编号

				@delManID varchar(10) output,--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，1：要删除的图片不存在，2:该用户信息正被别人锁定，9:未知错误
				@logoGUID36 varchar(36) output,--当前图片的文件名
				@thisLogoID int output		--删除后当前的图片的编号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE delUserLogo
	@jobNumber varchar(10),		--工号
	@curLogo int,				--当前图片的编号

	@delManID varchar(10) output,--删除人，如果当前用户正在被人占用编辑则返回该人的工号

	@Ret int output,			--操作成功标识
	@logoGUID36 varchar(36) output,--当前图片的文件名
	@thisLogoID int output		--删除后当前的图片的编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @thisLogoID = @curLogo

	--判断当前图片是否存在
	declare @count as int
	set @count=(select count(*) from logoFileInfo where myID = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取删除人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记维护信息：
	update userInfo
	set modiManID = @delManID, modiManName = @delManName, modiTime = @delTime
	where jobNumber = @jobNumber

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '删除用户Logo', @delManName
												+ '删除了用户['+ @jobNumber +']的一个Logo。')
GO


drop PROCEDURE queryUserLockMan
/*
	name:		queryUserLockMan
	function:	5.查询指定用户是否有人正在编辑
	input: 
				@jobNumber varchar(10),		--工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：查询出错，可能是该工号的用户不存在
				@lockManID varchar(10) output		--当前正在编辑的人工号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE queryUserLockMan
	@jobNumber varchar(10),		--工号
	@Ret		int output,		--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人工号
	WITH ENCRYPTION 
AS
	set @Ret = 1
	set @lockManID = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	set @Ret = 0
GO

drop PROCEDURE lockUser4Edit
/*
	name:		lockUser4Edit
	function:	6.锁定用户编辑，避免编辑冲突
	input: 
				@jobNumber varchar(10),		--工号
				@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的用户不存在，2:要锁定的用户正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE lockUser4Edit
	@jobNumber varchar(10),		--工号
	@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output	--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会员是否存在
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取维护人的姓名：
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定用户编辑', '系统根据' + @lockManName
												+ '的要求锁定了用户['+ @jobNumber +']为独占式编辑。')
GO

drop PROCEDURE unlockUserEditor
/*
	name:		unlockUserEditor
	function:	7.释放用户编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@jobNumber varchar(10),		--工号
				@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE unlockUserEditor
	@jobNumber varchar(10),		--工号
	@lockManID varchar(10) output,	--锁定人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
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
	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放用户编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了用户['+ @jobNumber +']的编辑锁。')
GO


drop PROCEDURE updateUserInfo
/*
	name:		updateUserInfo
	function:	8.更新指定的用户信息
	input: 
				@jobNumber varchar(10),		--工号：主键
				@workNumber varchar(10),	--工作证号：这是用户可以输入的号码，不做唯一性检查
				@manType smallint,			--类别：1->教工，9->学生 add by lw 2012-12-27
				--个人信息：
				@cName nvarchar(30),		--姓名
				@pID varchar(18),			--身份证号
				@countryCode char(3),		--国籍代码（国家代码）
				@birthDay varchar(10),		--出生日期
				@sex int,					--性别：使用第201号代码字典解释，1->男，2->女，界面做成选择框，代码字典中的其他部门不用！
				@bodyHeight int,			--身高：单位：厘米
				@homeTown nvarchar(20),		--籍贯
				@nationalityCode int,		--民族代码:由第203号代码字典定义
				@politicalScapeCode int,	--政治面貌代码:由第210号代码字典定义
				@maritalStatusCode int,		--婚姻状况代码：由第213号代码字典定义
				--隶属信息：
				@clgCode char(3),			--本系统不适用：所属学院代码:为保持兼容性固定为001
				@uCode varchar(8),			--部门代码（所属使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！)
				@tutorID varchar(10),		--导师工号:当类别为学生时要求输入 add by lw 2012-12-27
				--工作信息：
				@workPos nvarchar(30),		--岗位
				@workPostID int,			--职称ID：使用第218号代码字典
				@entryTime varchr(10),		--入职时间
				--联系方式：	
				@officeTel varchar(30),		--办公电话
				@mobile varchar(20),		--手机号码
				@e_mail varchar(30),		--E_mail地址
				@homeAddress nvarchar(100),	--住址
				@homeTel varchar(30),		--家庭电话
				@urgentConnecter nvarchar(30),	--紧急联系人
				@urgentTel varchar(30),		--紧急联系人电话
				--系统登录信息：
				@sysUserName varchar(30),	--用户名:要做唯一性检查
				@sysUserDesc nvarchar(100),	--系统用户描述性文字
				--@sysPassword varchar(128),	--系统登录密码
				@pswProtectQuestion varchar(40),--密码保护问题
				@psqProtectAnswer varchar(40),	--密码保护问题的答案
				--学习经历：
				@studyInfo xml,
				--工作经历：
				@workInfo xml,

				--维护情况:
				@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:该用户不存在，2：要更新的用户信息正被别人锁定，3:要更改的系统登录名已经被别人使用，
							4:该手机已经被注册，5：该邮箱已经被注册，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-20
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2011-9-4去除角色中文名，增加角色分级类型处理
				modi by lw 2011-9-12修改用户表，支持多重角色，去除用户权限表，将用户权限改为动态计算。
				modi by lw 2011-9-24修改用户信息的时候不允许修改密码。
				modi by lw 2013-1-1增加用户类别接口
				modi by lw 2013-1-11根据数据库增加字段增加接口，增加用户不存在判断
				modi by lw 2013-1-25增加学习经历、工作经历空行判断，禁止用户使用本过程修改密码！
				modi by lw 2013-7-12增加手机和eMail地址的唯一性判断
*/
create PROCEDURE updateUserInfo
	@jobNumber varchar(10),		--工号：主键
	@workNumber varchar(10),	--工作证号：这是用户可以输入的号码，不做唯一性检查
	@manType smallint,			--类别：1->教工，9->学生 add by lw 2012-12-27
	--个人信息：
	@cName nvarchar(30),		--姓名
	@pID varchar(18),			--身份证号
	@countryCode char(3),		--国籍代码（国家代码）
	@birthDay varchar(10),		--出生日期
	@sex int,					--性别：使用第201号代码字典解释，1->男，2->女，界面做成选择框，代码字典中的其他部门不用！
	@bodyHeight int,			--身高：单位：厘米
	@homeTown nvarchar(20),		--籍贯
	@nationalityCode int,		--民族代码:由第203号代码字典定义
	@politicalScapeCode int,	--政治面貌代码:由第210号代码字典定义
	@maritalStatusCode int,		--婚姻状况代码：由第213号代码字典定义
	--隶属信息：
	@clgCode char(3),			--本系统不适用：所属学院代码:为保持兼容性固定为001
	@uCode varchar(8),			--部门代码（所属使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！)
	@tutorID varchar(10),		--导师工号:当类别为学生时要求输入 add by lw 2012-12-27
	--工作信息：
	@workPos nvarchar(30),		--岗位
	@workPostID int,			--职称ID：使用第218号代码字典
	@entryTime varchar(10),	--入职时间
	--联系方式：	
	@officeTel varchar(30),		--办公电话
	@mobile varchar(20),		--手机号码
	@e_mail varchar(30),		--E_mail地址
	@homeAddress nvarchar(100),	--住址
	@homeTel varchar(30),		--家庭电话
	@urgentConnecter nvarchar(30),	--紧急联系人
	@urgentTel varchar(30),		--紧急联系人电话
	--系统登录信息：
	@sysUserName varchar(30),	--用户名:要做唯一性检查
	@sysUserDesc nvarchar(100),	--系统用户描述性文字
	--@sysPassword varchar(128),	--系统登录密码
	@pswProtectQuestion varchar(40),--密码保护问题
	@psqProtectAnswer varchar(40),	--密码保护问题的答案
	--学习经历：
	@studyInfo xml,
	--工作经历：
	@workInfo xml,
	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该用户是否存在：
	declare @count int
	set @count = ISNULL((select count(*) from userInfo where jobNumber = @jobNumber),0)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查系统登录账号名是否唯一：
	set @count = isnull((select count(*) from userInfo where sysUserName = @sysUserName and jobNumber<>@jobNumber),0)
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	--检查手机是否唯一：
	set @mobile=LTRIM(rtrim(@mobile))
	if (@mobile <>'')
	set @count = (select count(*) from userInfo where mobile = @mobile and jobNumber <> @jobNumber)
	if @count > 0
	begin
		set @Ret = 4
		return
	end

	--检查邮箱是否唯一：
	set @e_mail=LTRIM(rtrim(@e_mail))
	if (@e_mail <>'')
	set @count = (select count(*) from userInfo where e_mail = @e_mail and jobNumber <> @jobNumber)
	if @count > 0
	begin
		set @Ret = 5
		return
	end

	--取院部名称和使用单位\导师名称：
	declare @clgName nvarchar(30), @uName nvarchar(30), @tutorName nvarchar(30)		--所属学院名称、所属使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (isnull(@uCode,'') <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	
	--根据代码取国家、民族、政治面貌、婚姻状态等名称：
	declare @countryName nvarchar(60) ,	@nationality nvarchar(30)
	declare @politicalScape nvarchar(10), @maritalStatus nvarchar(8)
	set @countryName = isnull((select cName from country where cCode = @countryCode),'')
	set @nationality = isnull((select objDesc from codeDictionary where classCode = 203 and objCode = @nationalityCode),'')
	set @politicalScape  = isnull((select objDesc from codeDictionary where classCode = 210 and objCode = @politicalScapeCode),'')
	set @maritalStatus = isnull((select objDesc from codeDictionary where classCode = 213 and objCode = @maritalStatusCode),'')

		 
	--职称名称：
	declare @workPost nvarchar(10)
	set @workPost = isnull((select objDesc from codeDictionary where classCode = 218 and objCode = @workPostID),'')

	--处理异常日期数据：
	declare @rBrithDay smalldatetime, @rEntryTime smalldatetime
	if (@birthDay='')	--出生日期
		set @rBrithDay = null
	else
		set @rBrithDay = convert(smalldatetime,@birthDay,120)
		
	if (@entryTime='')	--入职时间
		set @rEntryTime = getdate()
	else
		set @rEntryTime = convert(smalldatetime,@entryTime,120)

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')


	declare @updateTime smalldatetime	--更新时间
	set @updateTime = getdate()
	begin tran
		update userInfo 
		set workNumber = @workNumber, manType = @manType,
			--个人信息：
			cName = @cName, pID = @pID, countryCode = @countryCode, countryName = @countryName, 
			birthDay = @rBrithDay, sex = @sex,
			bodyHeight = @bodyHeight, homeTown = @homeTown, nationalityCode = @nationalityCode, nationality = @nationality, 
			politicalScapeCode = @politicalScapeCode, politicalScape = @politicalScape, 
			maritalStatusCode = @maritalStatusCode, maritalStatus = @maritalStatus,
			--隶属信息：
			clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName, tutorID = @tutorID, tutorName = @tutorName,
			--工作信息：
			workPos = @workPos, workPostID = @workPostID, workPost = @workPost, entryTime = @rEntryTime,
			--联系方式：	
			officeTel = @officeTel, mobile = @mobile, e_mail = @e_mail, homeAddress = @homeAddress, homeTel = @homeTel, 
			urgentConnecter = @urgentConnecter, urgentTel = @urgentTel,
			--系统登录信息：
			sysUserName = @sysUserName, sysUserDesc = @sysUserDesc, --sysPassword = @sysPassword, 
			pswProtectQuestion = @pswProtectQuestion, psqProtectAnswer = @psqProtectAnswer,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where jobNumber = @jobNumber
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--登记学习经历：
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
		--登记工作经历：
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新用户信息', '用户' + @modiManName 
												+ '更新了用户['+ @jobNumber +']的信息。')
GO
--测试：
declare @workInfo xml
set @workInfo = N'<root>
						<row id="1">
							<beginTime>2011-01-01</beginTime>
							<endTime>2015-01-01</endTime>
							<postName>工程师</postName>
							<workUnit>IBM</workUnit>
							<changeReason>身体原因</changeReason>
						</row>
						<row id="2">
							<beginTime>2015-01-01</beginTime>
							<endTime>2010-01-01</endTime>
							<postName>工程师</postName>
							<workUnit>IBM 公司</workUnit>
							<changeReason>原因</changeReason>
						</row>
					</root>'	
declare	@Ret int
declare	@modiManID varchar(10)		--维护人，如果当前用户正在被人占用编辑则返回该人的工号
set @modiManID = '0000000000' 
exec dbo.updateUserInfo 'G201300020', '工作证', 1, '测试用户', '001002003', '004', '1970-09-01', 1, 156, '万', 0, 0, 0, '001', '001001','','测试',
	0, '','87889011','18602702392','lw_bk@163.com', '武汉','87889010','lc','13329723988','ceshi','12345','Hello','a','','', 
	@modiManID output,@Ret output
select @Ret

select * from userInfo




DROP PROCEDURE userSetOff
/*
	name:		userSetOff
	function:	9.注销指定的用户
	input: 
				@jobNumber varchar(10),			--工号：主键
				@setOffDate smalldatetime,		--注销日期

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的用户信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE userSetOff
	@jobNumber varchar(10),		--工号：主键
	@setOffDate smalldatetime,		--注销日期

	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update userInfo
	set isOff = 1, setOffDate = @setOffDate,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where jobNumber = @jobNumber
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '注销用户', '用户' + @modiManName 
												+ '注销了用户['+ @jobNumber +']。')
GO

drop PROCEDURE delUserInfo
/*
	name:		delUserInfo
	function:	10.删除指定的用户
	input: 
				@jobNumber varchar(10),			--工号
				@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该用户不存在，2:要删除的用户信息正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-6-7发现该存储过程没有执行删除命令
*/
create PROCEDURE delUserInfo
	@jobNumber varchar(10),			--工号
	@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from userInfo where jobNumber = @jobNumber)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		--delete sysUserRight where jobNumber = @jobNumber --该表已经废除！
		delete userInfo where jobNumber = @jobNumber --系统自动级联删除了用户角色表
	commit tran
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除用户', '用户' + @delManName
												+ '删除了用户['+ @jobNumber +']的信息。')

GO
--测试：
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
	function:	11.激活指定的用户
	input: 
				@jobNumber varchar(10),			--工号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的用户信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-6-7
	UpdateDate: 
*/
create PROCEDURE userSetActive
	@jobNumber varchar(10),		--工号

	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from userInfo where jobNumber = @jobNumber),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取用户名/维护人的姓名：
	declare @userCName nvarchar(30)
	set @userCName = isnull((select cName from userInfo where jobNumber = @jobNumber),'')
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	--检查是否为新用户（或没有权限的用户），将“一般用户”的权限分配给他：
	begin tran
		declare @count int
		set @count = isnull((select count(*) from sysUserRole where jobNumber=@jobNumber),0)
		if (@count=0)
		begin
			insert sysUserRole(jobNumber, sysUserName, sysRoleID, sysRoleName, sysRoleType)
			select @jobNumber,@userCName,sysRoleID, sysRoleName, sysRoleType 
			from sysRole 
			where sysRoleName='一般用户'
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
		
		update userInfo
		set isOff = 0, setOffDate = null,
			--维护情况:
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '激活用户', '用户' + @modiManName 
												+ '激活了用户['+ @jobNumber +']。')
GO


select * from activeUsers
--2.当前活动用户表(activeUsers)：
truncate table activeUsers
drop table activeUsers
CREATE TABLE activeUsers
(
	userID varchar(10) not null,		--用户工号
	userName varchar(30) not null,		--用户名
	userCName nvarchar(30) not null,	--用户中文名
	--modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
	psw	varchar(128) not null,			--登录密码
	userIP varchar(40) not null,		--会话客户端IP
	dynaPsw	varchar(36) not null,		--动态密钥
	loginTime smalldatetime not null,	--登录时间
	--增加的登录状态和用户当前状态的信息：add by lw 2013-5-31
	activeTime smalldatetime null,		--上次活动时间：最后访问服务的时间，这个用来判断是否是睡眠用户
	loginByBrower smallint default(0),	--使用浏览器登录：0->非本方式登录
	loginByClient smallint default(0),	--使用PC客户端登录
	loginByAndroid smallint default(0),	--使用安卓客户端登录
 CONSTRAINT [PK_activeUsers] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

use hustOA
drop PROCEDURE login
/*
	name:		login
	function:	1.用户登录：检查该用户的用户名、密码是否正确，如正确清除以前的登录，登记当前的状态
	input: 
				@userName varchar(30) output,--用户名	modi by lw 2011-6-28,支持工号登录，所以改为返回型参数
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
				@loginMode smallint,		--登录方式：1->网页登录，2->PC客户端登录，3->安卓客户端登录
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1：用户名或密码错，
							2：系统在清除该用户的编辑锁时出错，
							3：系统无法识别该登录方式
							9：未知错误
				@dynaPsw varchar(36) output,		如成功，放动态密钥
				@userCName nvarchar(30) output,	如成功，放用户中文名
				@userID varchar(10) output,		--用户工号
				--add by lw 2011-6-5 根据前台权限控制的需要增加的参数：
				@pID varchar(18) output,		--身份证号
				@clgCode char(3) output,		--所属学院代码
				@clgName nvarchar(30) output,	--所属学院名称
				@uCode varchar(8) output,		--所属使用单位代码
				@uName nvarchar(30) output,		--所属使用单位名称
				@sysUserDesc nvarchar(100) output,--系统用户描述性文字
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2011-6-5 根据前台权限控制的需要增加返回用户的基本信息,删除返回权限列表。
				modi by lw 2011-6-28增加工号登录
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2011-9-4增加角色分级类型
				modi by lw 2011-9-19因为用户角色设计的修改而作相应修改，将获取用户角色的信息独立成一个高级程序中的服务，
									将获取用户的权限改为一个动态计算的存储过程。
				modi by lw 2013-5-31增加登录方式
*/
create PROCEDURE login
	@userName varchar(30) output,	--用户名
	@psw	varchar(128),			--登录密码
	@userIP varchar(40),			--会话客户端IP
	@loginMode smallint,			--登录方式：1->网页登录，2->PC客户端登录，3->安卓客户端登录

	@Ret	int output,				--操作成功标识
	@dynaPsw varchar(36) output,	--动态密钥
	@userCName nvarchar(30) output, --用户中文名
	@userID varchar(10) output,		--用户工号
	--add by lw 2011-6-5 根据前台权限控制的需要增加的参数：
	@pID varchar(18) output,		--身份证号
	@clgCode char(3) output,		--所属学院代码
	@clgName nvarchar(30) output,	--所属学院名称
	@uCode varchar(8) output,		--所属使用单位代码
	@uName nvarchar(30) output,		--所属使用单位名称
	@sysUserDesc nvarchar(100) output--系统用户描述性文字
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查用户名、密码是否正确，并获取用户的中文名称和工号等基本信息：
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
	--检查是否以前有登录：
	declare @count int
	set @count=(select count(*) from activeUsers where userID = @userID)
	if @count > 0
	begin
		delete activeUsers where userID = @userID	--清除以前的登录
	end

	--清除该用户所有的编辑锁：
	declare @retUnlock as int
	exec dbo.unlockAllEditor @userID, @retUnlock output
	if (@retUnlock <> 0)
	begin
		set @Ret = 2
		return
	end
	--登录方式：
	declare @actionObject nvarchar(500) --日志
	declare @loginByBrower smallint--使用浏览器登录
	declare @loginByClient smallint	--使用PC客户端登录
	declare @loginByAndroid smallint	--使用安卓客户端登录
	set @loginByBrower = 0
	set @loginByClient = 0
	set @loginByAndroid = 0
	if (@loginMode=1)
	begin
		set @loginByBrower = 1
		set @actionObject='用户' + @userCName + '在IP为['+ @userIP +']的工作站上使用浏览器登录了系统。\r\n同时系统清除了该用户在其他机器上的登录！'
	end
	else if (@loginMode=2)
	begin
		set @loginByClient = 1
		set @actionObject='用户' + @userCName + '在IP为['+ @userIP +']的工作站上使用客户端登录了系统。\r\n同时系统清除了该用户在其他机器上的登录！'
	end
	else if (@loginMode=3)
	begin
		set @loginByAndroid = 1
		set @actionObject='用户' + @userCName + '在IP为['+ @userIP +']的手机或平板上使用客户端登录了系统。\r\n同时系统清除了该用户在其他机器上的登录！'
	end
	else
	begin
		set @Ret = 3
		return
	end
	
	--登记登录信息：
	set @dynaPsw = (select newid())		--生成动态密码
	declare @loginTime smalldatetime	--登录时间
	set @loginTime = getdate()
	insert activeUsers(userID, userName, userCName, psw, userIP, dynaPsw, loginTime,activeTime,loginByBrower,loginByClient,loginByAndroid)
	values(@userID, @userName, @userCName, @psw, @userIP, @dynaPsw, @loginTime,@loginTime,@loginByBrower,@loginByClient,@loginByAndroid)

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userCName, @loginTime, '登录', @actionObject)

GO

--测试：
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
	function:	1.2.添加用户登录方式
				注意：本存储过程是给客户端使用的。当客户端先登录，网页再登录时重新添加客户端的登录状态,这样保证客户端不断线！
	input: 
				@userID varchar(10),			--用户工号
				@psw	varchar(128),			--登录密码
				@dynaPsw varchar(36),			--动态密钥
				@userIP varchar(40),			--会话客户端IP
				@loginMode smallint,			--登录方式：2->PC客户端登录，3->安卓客户端登录
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该用户还没有登录，2：系统无法识别该登录方式，9：未知错误
	author:		卢苇
	CreateDate:	2013-5-31
	UpdateDate: 
*/
create PROCEDURE addLoginMode
	@userID varchar(10),			--用户工号
	@psw	varchar(128),			--登录密码
	@dynaPsw varchar(36),			--动态密钥
	@userIP varchar(40),			--会话客户端IP
	@loginMode smallint,			--登录方式：2->PC客户端登录，3->安卓客户端登录

	@Ret	int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查是否以前有登录：
	select * from activeUsers
	declare @count int
	set @count=(select count(*) from activeUsers where userID = @userID and psw = @psw and dynaPsw=@dynaPsw and userIP=@userIP)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--添加客户端登录方式：
	declare @actionObject nvarchar(500) --日志
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
	function:	1.3.清除指定用户的客户端或安卓登录方式。
				注意：这是一个服务器专用的针对客户端断线使用的过程！
	input: 
				@userID varchar(10),			--用户工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-6-2
	UpdateDate: 
*/
create PROCEDURE clearLoginMode
	@userID varchar(10),			--用户工号

	@Ret	int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	update activeUsers
	set loginByAndroid = 0, loginByClient = 0
	where userID = @userID

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('0000000000', '系统用户', GETDATE(), '清除登录方式', '由于用户断线，系统自动清除了用户['+@userID+']的客户端登录方式')
GO

drop PROCEDURE reLogin
/*
	name:		reLogin
	function:	1.1.在线用户重新登录：检查该用户的用户名、密码是否正确，如正确检查是否为在线用户，如果是在线用户唤醒
				本过程使用在超时时重新登录！
	input: 
				@userName varchar(30) output,--用户名	modi by lw 2011-6-28,支持工号登录，所以改为返回型参数
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
				@loginMode smallint,			--登录方式：1->网页登录，2->PC客户端登录，3->安卓客户端登录
	output: 
				@Ret		int output		--操作成功标识
							0：成功，1：用户名或密码错，
							2：无效用户（包括不是原用户、在其他工作站登录或被系统管理员踢出系统），
							3：系统无法识别该登录方式
							9：未知错误
				@dynaPsw varchar(36) output,		如成功，放动态密钥
				@userCName nvarchar(30) output,	如成功，放用户中文名
				@userID varchar(10) output,		--用户工号
				--add by lw 2011-6-5 根据前台权限控制的需要增加的参数：
				@pID varchar(18) output,		--身份证号
				@clgCode char(3) output,		--所属学院代码
				@clgName nvarchar(30) output,	--所属学院名称
				@uCode varchar(8) output,		--所属使用单位代码
				@uName nvarchar(30) output,		--所属使用单位名称
				@sysUserDesc nvarchar(100) output,--系统用户描述性文字
	author:		卢苇
	CreateDate:	2012-8-15
	UpdateDate: modi by lw 2013-5-31增加登录方式
*/
create PROCEDURE reLogin
	@userName varchar(30) output,	--用户名
	@psw	varchar(128),			--登录密码
	@userIP varchar(40),			--会话客户端IP
	@loginMode smallint,			--登录方式：1->网页登录，2->PC客户端登录，3->安卓客户端登录

	@Ret	int output,				--操作成功标识
	@dynaPsw varchar(36) output,	--动态密钥
	@userCName nvarchar(30) output, --用户中文名
	@userID varchar(10) output,		--用户工号
	--add by lw 2011-6-5 根据前台权限控制的需要增加的参数：
	@pID varchar(18) output,		--身份证号
	@clgCode char(3) output,		--所属学院代码
	@clgName nvarchar(30) output,	--所属学院名称
	@uCode varchar(8) output,		--所属使用单位代码
	@uName nvarchar(30) output,		--所属使用单位名称
	@sysUserDesc nvarchar(100) output--系统用户描述性文字
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查用户名、密码是否正确，并获取用户的中文名称和工号等基本信息：
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
	
	--检查是否以前有登录：
	declare @oldUserIP varchar(40)		--登记的会话客户端IP
	select @oldUserIP = userIP, @dynaPsw = dynaPsw from activeUsers where userID = @userID
	if (@oldUserIP is null or @oldUserIP<>@userIP)
	begin
		set @Ret = 2
		return
	end
	
	--填写登录方式：
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
	function:	2.检查是否为活动用户
	input: 
				@userName varchar(30),		--用户名
				@psw	varchar(128),		--登录密码
	output: 
				@userIP varchar(40) output,	--会话客户端IP
				@Ret		int output		--标识
							1:是，0：不是，-1：未知错误
	author:		卢苇
	CreateDate:	2010-2-1
	UpdateDate: modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2011-9-19删除动态密码验证，将会话IP改为返回值，将原验证活动用户的过程单另为validateActiveUser过程
*/
create PROCEDURE isActiveUser
	@userName varchar(30),		--用户名
	@psw	varchar(128),		--登录密码
	@userIP varchar(40) output,	--会话客户端IP

	@Ret		int output		--标识
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
	function:	2.1.使用密码、IP、动态密码验证用户是否为合法活动用户
	input: 
				@userID varchar(12),		--用户ID
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
				@dynaPsw varchar(36),		--动态密钥
	output: 

				@Ret		int output		--标识
							1:是，0：不是，-1：未知错误
	author:		卢苇
	CreateDate:	2011-9-20
	UpdateDate: modi by lw 2013-4-17将用户名改成用户ID
				modi by lw 2013-5-31增加登记用户访问时间，以便与系统判定睡眠用户
*/
create PROCEDURE validateActiveUser
	@userID varchar(12),		--用户ID
	@psw	varchar(128),		--登录密码
	@userIP varchar(40),		--会话客户端IP
	@dynaPsw varchar(36),		--动态密钥
	@Ret		int output		--标识
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers 
								where userID = @userID and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw)
	if @count > 0
	begin
		set @Ret = 1
		--登记客户端本次访问时间：
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
	function:	2.2.清除睡眠用户
				注意：这是系统自动执行的存储过程，在每天晚上执行。系统只清除网页单一登录的用户。
					该存储过程也提供给高级用户清除睡眠用户用！
				睡眠用户的判定标准是：20分钟内没有操作的用户！
	input: 
	output: 
	author:		卢苇
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
	function:	3.安全退出
	input: 
				@userName varchar(30),		--用户名
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
				@logoutMode smallint,		--退出的登录方式：1->网页登录，2->PC客户端登录，3->安卓客户端登录
				@dynaPsw varchar(36),		--动态密钥
	output: 
				@Ret		int output		--标识
							1:是，
							0：没有该用户，
							2：在释放该用户可能的编辑锁的时候出错，
							3：系统无法识别退出登录的方式
							-1：未知错误
	author:		卢苇
	CreateDate:	2010-2-1
	UpdateDate: 2010-5-10增加工作日志处理
				modi by lw 2011-6-28增加释放用户可能存在的编辑锁
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2013-5-31增加退出的登录方式
*/
create PROCEDURE logout
	@userName varchar(30),		--用户名
	@psw	varchar(128),		--登录密码
	@userIP varchar(40),		--会话客户端IP
	@logoutMode smallint,		--退出的登录方式：1->网页登录，2->PC客户端登录，3->安卓客户端登录
	@dynaPsw varchar(36),		--动态密钥

	@Ret		int output		--标识
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers 
								where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw)
	declare @userCName nvarchar(30), @userID varchar(10) --用户中文名\用户ID
	if @count > 0
	begin
		--获取用户中文名\用户身份证号：
		select @userCName = userCName, @userID = userId 
		from activeUsers 
		where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
		--清除相应的登录方式：
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
		--判断是否用户全部的登录方式都已经退出：
		declare @actionObject nvarchar(500) --日志
		declare @loginByBrower smallint--使用浏览器登录
		declare @loginByClient smallint	--使用PC客户端登录
		declare @loginByAndroid smallint	--使用安卓客户端登录
		select @loginByBrower = loginByBrower, @loginByClient = loginByClient, @loginByAndroid = loginByAndroid 
		from activeUsers 
		where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
		if (@loginByBrower = 0 and @loginByClient = 0 and @loginByAndroid = 0)
		begin
			--删除活动用户：
			delete activeUsers 
			where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
			set @Ret = 1
			--清除可能的用户编辑锁：
			declare @retUnlock as int
			exec dbo.unlockAllEditor @userID, @retUnlock output
			if (@retUnlock <> 0)
			begin
				set @Ret = 2
				return
			end
			--登记工作日志：
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@userID, @userCName, getdate(), '登出', '用户' + @userCName + '安全地退出了系统。')
		end
		set @Ret = 1
	end
	else
		set @Ret = 0
GO

drop PROCEDURE delActiveUser
/*
	name:		delActiveUser
	function:	3.1删除在线用户
	input: 
				@userID varchar(10),			--用户工号
				@delManID varchar(10),			--删除人工号
	output: 
				@Ret		int output		--标识
							1:是，0：没有该用户，-1：未知错误
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: 
*/
create PROCEDURE delActiveUser
	@userID varchar(10),			--用户工号
	@delManID varchar(10),			--删除人工号
	@Ret		int output	--标识
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers where userID = @userID)
	declare @userCName nvarchar(30), @userName varchar(30)	--用户中文名\用户登录名
	if @count > 0
	begin
		--获取用户中文名\用户身份证号：
		select @userCName = userCName, @userName = userName
		from activeUsers 
		where @userID = userId 

		--释放该用户的所有编辑锁：
		declare @retUnlock as int
		exec dbo.unlockAllEditor @userID, @retUnlock output
		if (@retUnlock <> 0)
		begin
			set @Ret = -1
			return
		end

		--删除活动用户：
		delete activeUsers 
		where userId = @userID
		set @Ret = 1
	end
	else
	begin
		set @Ret = 0
		return
	end

	declare @delManCName nvarchar(30) --用户中文名
	--获取用户中文名\用户身份证号：
	select @delManCName = userCName
	from activeUsers 
	where userId  = @delManID

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManCName, getdate(), '清除在线用户', 
			'系统管理员：'+ @delManCName + '将用户：' + @userCName + '['+ @userName +']踢出了系统。')
GO

drop PROCEDURE getActiveUserInfo
/*
	name:		getActiveUserInfo
	function:	4.根据用户工号获取指定用户的活动信息
	input: 
				@userID varchar(10),		--用户工号
	output: 
				@Ret		int output		--标识
							1:成功，0：该用户不在活动用户之列，-1：未知错误
				@psw	varchar(128) output,		--登录密码
				@userCName nvarchar(30) output,	--用户中文名
				@userIP varchar(40) output,		--会话客户端IP
				@dynaPsw varchar(36) output		--动态密钥
	author:		卢苇
	CreateDate:	2010-2-1
	UpdateDate:modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！

*/
create PROCEDURE getActiveUserInfo
	@userID varchar(10),			--用户工号

	@Ret	int output,				--标识
	@psw	varchar(128) output,		--登录密码
	@userCName nvarchar(30) output,	--用户中文名
	@userIP varchar(40) output,		--会话客户端IP
	@dynaPsw varchar(36) output		--动态密钥
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
	function:	5.释放指定用户的所有编辑锁：这是给本人和系统管理员使用的功能，
				在进入编辑系统的时候应该首先注销在其他机器上的登录，并释放所有自己锁定的编辑
	input: 
				@userID varchar(10),		--用户工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2011-9-5增加系统角色和用户的编辑锁处理
				modi by lw 2013-2-24增加工作流实例活动的状态恢复！
*/
create PROCEDURE unlockAllEditor
	@userID varchar(10),		--用户工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	begin tran
		--代码字典类表的编辑锁：
		update codeDictionary set lockManID = '' where lockManID = @userID	--代码字典编辑锁
		update typeCodes set lockManID = '' where lockManID = @userID		--设备分类代码表编辑锁
		update country set lockManID = '' where lockManID = @userID			--国别编辑锁
		update fundSrc set lockManID = '' where lockManID = @userID			--经费来源编辑锁
		update appDir set lockManID = '' where lockManID = @userID			--使用方向编辑锁
		update college set lockManID = '' where lockManID = @userID			--学院表编辑锁
		update useUnit set lockManID = '' where lockManID = @userID			--使用单位编辑锁
		update accountTitle set lockManID = '' where lockManID = @userID	--会计科目代码字典表编辑锁
		update collegeCode set lockManID = '' where lockManID = @userID		--财政部报表单位代码转换表

		--日程管理类表的编辑锁：
		update taskInfo set lockManID = '' where lockManID = @userID		--任务管理表
		update dutyStatusInfo set lockManID = '' where lockManID = @userID	--勤务状态登记表

		--邮件类管理表的编辑锁：
		update mailBindOption set lockManID = '' where lockManID = @userID	--绑定邮箱登记表编辑锁
		update signInfo set lockManID = '' where lockManID = @userID		--签名编辑锁

		--预约管理类表的编辑锁：
		update shareEqpStatus set lockManID = '' where lockManID = @userID		--共享设备状态表
		update eqpBorrowApplyInfo set lockManID = '' where lockManID = @userID	--共享设备借用申请表
		update placeInfo set lockManID = '' where lockManID = @userID		--场地一览表
		update placeApplyInfo set lockManID = '' where lockManID = @userID	--场地使用申请表
		update expStationInfo set lockManID = '' where lockManID = @userID		--试验站一览表
		update expStationApplyInfo set lockManID = '' where lockManID = @userID	--试验站使用申请表
		update gasInfo set lockManID = '' where lockManID = @userID		--气体一览表
		update gasApplyInfo set lockManID = '' where lockManID = @userID	--气体使用申请表

		--会议类表的编辑锁：
		update meetingInfo set lockManID = '' where lockManID = @userID		--会议类表编辑锁

		--学术报告类表的编辑锁：
		update academicReports set lockManID = '' where lockManID = @userID		--学术报告编辑锁

		--工作流引擎类表的编辑锁：
		update workFlowTemplate set lockManID = '' where lockManID = @userID	--工作流模板管理表
		update workFlowTemplateForms set lockManID = '' where lockManID = @userID--工作流模板表单定义表
		update workFlowInstance set lockManID = '' where lockManID = @userID	--工作流实例表
		--工作流实例活动的状态：
		update workflowInstanceActivity set activityStatus = 1 where receiverID = @userID and activityStatus=2
/*
		update leaveRequestInfo set lockManID = '' where lockManID = @userID	--请假条登记表
		update eqpApplyInfo set lockManID = '' where lockManID = @userID	--设备采购申请表
		update thesisPublishApplyInfo set lockManID = '' where lockManID = @userID	--论文发表申请表
		update processApplyInfo set lockManID = '' where lockManID = @userID	--车间加工申请表
		update otherApplyInfo set lockManID = '' where lockManID = @userID	--其他申请表
*/
		--设备管理类表的编辑锁：
		update equipmentList set lockManID = '' where lockManID = @userID	--设备表编辑锁
		update equipmentScrap set lockManID = '' where lockManID = @userID	--设备报废单编辑锁
		update equipmentAllocation set lockManID = '' where lockManID = @userID	--设备调拨单编辑锁
		update eqpCheckInfo set lockManID = '' where lockManID = @userID	--设备清查任务编辑锁
		update eqpCheckDetailInfo set lockManID = '' where lockManID = @userID	--设备清查任务明细表编辑锁
		update statisticTemplate set lockManID = '' where lockManID = @userID	--统计模板表编辑锁
				
		--成果类管理表的编辑锁：
		update thesisInfo set lockManID = '' where lockManID = @userID	--论文登记表编辑锁
		update monographInfo set lockManID = '' where lockManID = @userID	--专著登记表编辑锁
		update patentInfo set lockManID = '' where lockManID = @userID	--专利登记表编辑锁
		update awardInfo set lockManID = '' where lockManID = @userID	--获奖信息登记表编辑锁
		update projectInfo set lockManID = '' where lockManID = @userID	--科研项目登记表编辑锁
		
		--权限控制类表的编辑锁：
		update sysRole set lockManID = '' where lockManID = @userID			--系统角色编辑锁
		update userInfo set lockManID = '' where lockManID = @userID		--系统用户编辑锁

		--运维类表的编辑锁：
		update bulletinInfo set lockManID = '' where lockManID = @userID	--系统公告板编辑锁
		update SMSInfo set lockManID = '' where lockManID = @userID			--短信管理表
		update deviceInfo set lockManID = '' where lockManID = @userID		--装置一览表
		
		--讨论组与群的编辑锁：
		update discussGroup set lockManID = '' where lockManID = @userID		--讨论组一览表
		update communityGroup set lockManID = '' where lockManID = @userID		--群组一览表
		
	commit tran
	set @Ret = 0

GO
--测试：
declare @Ret int
exec dbo.unlockAllEditor 'G201300001',@Ret output
select @Ret

drop PROCEDURE unlockAllUserLock
/*
	name:		unlockAllUserLock
	function:	5.1释放所有用户的编辑锁：这是给系统管理员使用的功能，并清除除本人外的所有在线用户
	input: 
				@userID varchar(10),		--用户工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2011-10-7
	UpdateDate: modi by lw 2013-2-24增加工作流实例活动的状态恢复！
*/
create PROCEDURE unlockAllUserLock
	@userID varchar(10),		--用户工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	begin tran
		--删除除本人外的所有活动用户：
		delete activeUsers 
		where userId <> @userID 

		--释放编辑锁：
		--代码字典类表的编辑锁：
		update codeDictionary set lockManID = ''	--代码字典编辑锁
		update typeCodes set lockManID = ''			--设备分类代码表编辑锁
		update country set lockManID = ''			--国别编辑锁
		update fundSrc set lockManID = ''			--经费来源编辑锁
		update appDir set lockManID = ''			--使用方向编辑锁
		update college set lockManID = ''			--学院表编辑锁
		update useUnit set lockManID = ''			--使用单位编辑锁
		update accountTitle set lockManID = ''		--会计科目代码字典表编辑锁
		update collegeCode set lockManID = ''		--财政部报表单位代码转换表

		--日程管理类表的编辑锁：
		update taskInfo set lockManID = ''			--任务管理表
		update dutyStatusInfo set lockManID = ''	--勤务状态登记表

		--邮件类管理表的编辑锁：
		update mailBindOption set lockManID = ''	--绑定邮箱登记表编辑锁
		update signInfo set lockManID = ''			--签名编辑锁

		--预约管理类表的编辑锁：
		update shareEqpStatus set lockManID = ''	--共享设备状态表
		update eqpBorrowApplyInfo set lockManID = '' --共享设备借用申请表
		update placeInfo set lockManID = ''			--场地一览表
		update placeApplyInfo set lockManID = ''	--场地使用申请表
		update expStationInfo set lockManID = ''	--试验站一览表
		update expStationApplyInfo set lockManID = '' --试验站使用申请表
		update gasInfo set lockManID = ''			--气体一览表
		update gasApplyInfo set lockManID = ''		--气体使用申请表

		--会议类表的编辑锁：
		update meetingInfo set lockManID = ''		--会议类表编辑锁

		--学术报告类表的编辑锁：
		update academicReports set lockManID = ''	--学术报告编辑锁

		--工作流引擎类表的编辑锁：
		update workFlowTemplate set lockManID = ''	--工作流模板管理表
		update workFlowTemplateForms set lockManID = ''	--工作流模板表单定义表
		update workFlowInstance set lockManID = ''	--工作流实例表
		--工作流实例活动的状态：
		update workflowInstanceActivity set activityStatus = 1 where activityStatus=2
/*
		update leaveRequestInfo set lockManID = ''	--请假条登记表
		update eqpApplyInfo set lockManID = ''		--设备采购申请表
		update thesisPublishApplyInfo set lockManID = '' --论文发表申请表
		update processApplyInfo set lockManID = ''	--车间加工申请表
		update otherApplyInfo set lockManID = ''	--其他申请表
*/

		--设备管理类表的编辑锁：
		update equipmentList set lockManID = ''		--设备表编辑锁
		update equipmentScrap set lockManID = ''	--设备报废单编辑锁
		update equipmentAllocation set lockManID = '' --设备调拨单编辑锁
		update eqpCheckInfo set lockManID = ''		--设备清查任务编辑锁
		update eqpCheckDetailInfo set lockManID = ''--设备清查任务明细表编辑锁
		update statisticTemplate set lockManID = '' --统计模板表编辑锁
				
		--成果类管理表的编辑锁：
		update thesisInfo set lockManID = ''	--论文登记表编辑锁
		update monographInfo set lockManID = '' --专著登记表编辑锁
		update patentInfo set lockManID = ''	--专利登记表编辑锁
		update awardInfo set lockManID = ''		--获奖信息登记表编辑锁
		update projectInfo set lockManID = ''	--科研项目登记表编辑锁
		
		--权限控制类表的编辑锁：
		update sysRole set lockManID = ''		--系统角色编辑锁
		update userInfo set lockManID = ''		--系统用户编辑锁

		--运维类表的编辑锁：
		update bulletinInfo set lockManID = ''	--系统公告板编辑锁
		update SMSInfo set lockManID = ''		--短信管理表
		update deviceInfo set lockManID = ''	--装置一览表

		--讨论组与群的编辑锁：
		update discussGroup set lockManID = ''	--讨论组一览表
		update communityGroup set lockManID = ''--群组一览表
	commit tran
	set @Ret = 0

GO
--测试：
declare @Ret int
exec dbo.unlockAllUserLock '0000000001',@Ret output
select @Ret

drop PROCEDURE modiPassword
/*
	name:		modiPassword
	function:	6.修改密码
				注意：这个存储过程不检查原密码是否与数据库中登记的一致！
	input: 
				@jobNumber varchar(10),		--工号：主键
				--系统登录信息：
				@newPassword varchar(128),	--新系统登录密码

				--最新维护情况:
				@modiManID varchar(10),		--修改人工号
	output: 
				@Ret		int output,
							0:成功，1:该用户不存在，9:未知错误
	author:		卢苇
	CreateDate:	2011-7-5
	UpdateDate: modi by lw 2011-10-16工作日志登记错误
				modi by lw 2012-4-19 修改了取被修改人的姓名错误
*/
create PROCEDURE modiPassword
	@jobNumber varchar(10),		--工号：主键
	@newPassword varchar(128),	--新系统登录密码

	--最新维护情况:
	@modiManID varchar(10),		--修改人工号

	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
		 
	--取维护人的姓名：
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
	
	--如果是当前用户更改了密码，需要将活动用户表更新：
	if (@modiManID = @jobNumber)
	begin	
		update activeUsers
		set psw = @newPassword
		where  userID = @jobNumber
	end
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, 
								'重置密码','系统根据' + @modiManName + 
								'的要求重置了用户[' + @cName + '('+@jobNumber+')]的密码。')
GO

drop PROCEDURE modiPassword2
/*
	name:		modiPassword2
	function:	6.修改密码
				注意：这个存储过程检查原密码是否与数据库中登记的一致！
	input: 
				@jobNumber varchar(10),		--工号：主键
				@oldPassword varchar(128),	--原系统登录密码
				--系统登录信息：
				@newPassword varchar(128),	--新系统登录密码

				--最新维护情况:
				@modiManID varchar(10),		--修改人工号
	output: 
				@Ret		int output,
							0:成功，1:该用户不存在或密码错误，9:未知错误
	author:		卢苇
	CreateDate:	2013-7-12
	UpdateDate: 
*/
create PROCEDURE modiPassword2
	@jobNumber varchar(10),		--工号：主键
	@oldPassword varchar(128),	--原系统登录密码
	@newPassword varchar(128),	--新系统登录密码

	--最新维护情况:
	@modiManID varchar(10),		--修改人工号

	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
		 
	--取维护人的姓名：
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
	
	--如果是当前用户更改了密码，需要将活动用户表更新：
	if (@modiManID = @jobNumber)
	begin	
		update activeUsers
		set psw = @newPassword
		where  userID = @jobNumber
	end
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, 
								'重置密码','系统根据' + @modiManName + 
								'的要求重置了用户[' + @cName + '('+@jobNumber+')]的密码。')
GO
--测试：
exec dbo.modiPassword2
select * from epdc211.dbo.userInfo where cName='毕卫民'
update userInfo
set sysPassword = jobNumber



--报表用视图：
create view [dbo].[userInfoView]
as
select jobNumber,cName,pID,mobileNum,telNum,e_mail,homeAddress,clgCode,clgName,uCode,uName,
sysUserName,sysUserDesc,dbo.getSysUserRole(jobNumber) sysRoleName,sysPassword,pswProtectQuestion,psqProtectAnswer,
case isOff when '0' then '√' else '' end isOff,
case isOff when '0' then '' else convert(char(10), setOffDate, 120) end offDate,
modiManID,modiManName,modiTime,lockManID
from userInfo
go

use hustOA
select * from userInfo





select jobNumber, workNumber, manType,
	--个人信息：
	cName, pID, countryCode, countryName, birthDay, sex, bodyHeight, homeTown, 
	nationalityCode, nationality, politicalScapeCode, politicalScape, maritalStatusCode, maritalStatus,
	--隶属信息：
	clgCode, clgName, uCode, uName, tutorID, tutorName,
	--工作信息：
	workPos, workPostID, workPost, entryTime,
	--联系方式：	
	officeTel, mobile, e_mail, homeAddress, homeTel, urgentConnecter, urgentTel,
	--系统登录信息：
	sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer,
	--维护信息：
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