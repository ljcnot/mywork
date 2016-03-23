use newfTradeDB2
/*
	武大外贸合同管理信息系统-系统用户表设计
	根据警用地理信息系统、设备管理系统改编，由原userInfo表改造而来。
	author:		卢苇
	客户要求：
	用户分级问题：
	1.用户分四类：学校用户、外贸公司用户、供货单位用户、游客
	2.支持游客，只能查询，不能生成报表
	CreateDate:	2012-4-18
	UpdateDate: 
				
*/
select * from sysUserInfo where cName = '毕卫民' or cName = '方萍'

--1.系统用户信息表 （sysUserInfo）：
alter table sysUserInfo add unitID varchar(12)	--所属单位编码
select * from userInfo where cName = '毕卫民'

select * from sysUserInfo  where cName = '毕卫民'
update sysUserInfo  
set unitID='000'
where cName = '毕卫民'

select * from contractInfo where contractID='20120019'
select * from sysUserRole where userID = '00200977'
select * from supplierManInfo where mobile = '18907125599'
select * from sysRole
insert sysUserRole(userID, sysUserName, sysRoleID, sysRoleName, sysRoleType)
values('00200977','毕卫民',1,'超级用户',1)
drop TABLE sysUserInfo
select * from sysUserInfo
CREATE TABLE sysUserInfo
(
	userType int not null,				--用户类别：由101号代码字典定义
	--可以用来登录的ID：
	userID varchar(10) not null,		--主键：用户识别号
	pID varchar(18) null,				--身份证号：要做唯一性检查
	mobile varchar(30) null,			--联系手机：要做唯一性检查
	e_mail varchar(30) null,			--E_mail地址：要做唯一性检查
	
	--个人信息：
	cName nvarchar(30) not null,		--姓名：冗余设计
	unitID varchar(12) not null,		--所属单位编码
	unitName nvarchar(30) not null,		--所属单位名称:冗余设计。学校员工登记隶属学院名称,公司员工登记公司名称

	--系统登录信息：
	sysUserName varchar(30) not null,	--用户名:要做唯一性检查
	sysUserDesc nvarchar(100) null,		--系统用户描述性文字
	sysPassword varchar(128) null,		--系统登录密码：密码要使用加密算法加密！
	pswProtectQuestion varchar(40) null,--密码保护问题
	psqProtectAnswer varchar(40) null,	--密码保护问题的答案

	isOff int default(0),				--是否注销：0->未注销，1->已注销
	setOffDate smalldatetime,			--注销日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10) null,			--当前正在锁定编辑人工号
CONSTRAINT [PK_sysUserInfo] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--除其他授权用户和游客外，其他人员的信息填写由其他存储过程维护，并一致化到系统用户表

--从设备系统中转入数据：
insert sysUserInfo(userType, userID, pID, mobile,
	cName, unitName,
	--系统登录信息：
	sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer, 
	isOff, setOffDate)
select 1, u.jobNumber, u.pID, u.mobileNum,
	u.cName, clg.clgName,
	--系统登录信息：
	u.sysUserName, u.sysUserDesc, u.sysPassword, u.pswProtectQuestion, u.psqProtectAnswer, 
	u.isOff, u.setOffDate
from epdc2.dbo.userInfo u left join college clg on u.clgCode = clg.clgCode

select * from sysUserInfo

drop PROCEDURE checkSuperManRights
/*
	name:		checkSuperManRights
	function:	0.1.检查指定用户是否拥有“超级用户”角色，如果拥有，检查超级用户是否拥有全部的系统权限
				如果未拥有则提示用户需要更新
	input: 
				@userID varchar(10),			--用户识别号
	output: 
				@Ret		int output			--操作成功标识
							0:不需要更新，1：需要更新，2：该用户不存在
							9：未知错误
	author:		卢苇
	CreateDate:	2012-8-8
	UpdateDate: 
*/
create PROCEDURE checkSuperManRights
	@userID varchar(10),			--用户识别号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from sysUserInfo where userID = @userID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	--检查该用户是否拥有“超级用户”角色：
	set @count = (select COUNT(*) from sysUserRole 
					where userID = @userID and sysRoleID = 1 and sysRoleName='超级用户')
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
exec dbo.checkSuperManRights '00200977',@Ret output
select @Ret

delete sysRoleDataOpr where sysRoleID=1 and rightKind = 1

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
exec dbo.updateSuperManRights '00200977',@Ret output
select @Ret

drop FUNCTION getSysUserRole
/*
	name:		getSysUserRole
	function:	1.根据用户工号获取用户角色名
	input: 
				@userID varchar(10)			--用户标识
	output: 
				return varchar(1024)		--用户角色名：多个角色名采用“,”分隔
	author:		卢苇
	CreateDate:	2012-6-9
	UpdateDate: 
*/
create FUNCTION getSysUserRole
(  
				@userID varchar(10)		--用户标识
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
	where userID = @userID
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
select dbo.getSysUserRole('00200977')
select * from sysUserRole
select * from userInfo
select * from sysUserRole

drop PROCEDURE checkSysUserName
/*
	name:		checkSysUserName
	function:	0.1.检查用户名是否唯一
	input: 
				@userID varchar(10),		--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
				@sysUserName varchar(30),		--系统登录用户名
	output: 
				@Ret		int output
							0:唯一，>1：不唯一，-1：未知错误
	author:		卢苇
	CreateDate:	2010-5-30
	UpdateDate: 
*/
create PROCEDURE checkSysUserName
	@userID varchar(10),		--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
	@sysUserName varchar(30),		--系统登录用户名
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from sysUserInfo where sysUserName = @sysUserName and userID <> @userID)
GO

drop PROCEDURE addSysUser
/*
	name:		addSysUser
	function:	1.添加系统用户
				注意：这个存储过程检查用户ID、系统登陆名、身份证号、手机号码、E-mail的唯一性！
					  本存储从原设备系统中用户管理模块中移植过来，但不锁定记录。
					  本存储过程可以被添加供货单位员工、外贸公司员工、学校教职工及其他授权用户使用，但是添加其他授权用户的时候请注意锁定。
	input: 
				@userType int,				--用户类别：由101号代码字典定义
				@userID varchar(10),		--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
				--个人信息：
				@cName nvarchar(30),		--姓名
				@unitID varchar(12),		--所属单位编码
				@unitName nvarchar(30),		--所属单位名称，学校员工登记隶属学院名称
				@pID varchar(18),			--身份证号
				@mobile varchar(30),		--手机号码
				@e_mail varchar(30),		--E_mail地址

				--系统登录信息：
				@sysUserName varchar(30),	--用户名:要做唯一性检查
				@sysUserDesc nvarchar(100),	--系统用户描述性文字
				@sysPassword varchar(128),	--系统登录密码
				@pswProtectQuestion varchar(40),--密码保护问题
				@psqProtectAnswer varchar(40),	--密码保护问题的答案

				--最新维护情况:
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output,
							0:成功，1:该用户标识号已经登记过，2:该用户名已经被注册过了，
							3：该身份证号已经被注册过了，4：该手机号码已经被注册过了，5：该E-mail地址已经被注册过了，
							9:未知错误
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2012-4-22
	UpdateDate: modi by lw 2012-11-07增加所属单位代码字段
*/
create PROCEDURE addSysUser
	@userType int,				--用户类别：由101号代码字典定义
	@userID varchar(10),		--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
	--个人信息：
	@cName nvarchar(30),		--姓名
	@unitID varchar(12),		--所属单位编码
	@unitName nvarchar(30),		--所属单位名称，学校员工登记隶属学院名称
	@pID varchar(18),			--身份证号
	@mobile varchar(30),		--手机号码
	@e_mail varchar(30),		--E_mail地址

	--系统登录信息：
	@sysUserName varchar(30),	--用户名:要做唯一性检查
	@sysUserDesc nvarchar(100),	--系统用户描述性文字
	@sysPassword varchar(128),	--系统登录密码
	@pswProtectQuestion varchar(40),--密码保护问题
	@psqProtectAnswer varchar(40),	--密码保护问题的答案

	--最新维护情况:
	@createManID varchar(10),	--创建人工号

	@Ret int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查工号是否唯一：
	declare @count as int
	set @count = (select count(*) from sysUserInfo where userID = @userID)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--检查名称是否唯一：
	set @count = (select count(*) from sysUserInfo where sysUserName = @sysUserName)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--检查身份证号、手机、E-mail的唯一性：

	--取添加人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert sysUserInfo (userType, userID,
				--个人信息：
				cName, unitID, unitName, pID, mobile, e_mail,
				--系统登录信息：
				sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer,
				--最新维护情况:
				modiManID, modiManName, modiTime)
	values(@userType, @userID,
				--个人信息：
				@cName, @unitID, @unitName, @pID, @mobile, @e_mail,
				--系统登录信息：
				@sysUserName, @sysUserDesc, @sysPassword, @pswProtectQuestion, @psqProtectAnswer,
				--最新维护情况:
				@createManID, @createManName, @createTime)

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'注册用户','系统根据' + @createManName + 
								'的要求注册了用户[' + @cName + '('+ @sysUserName +')]的信息。')
GO

drop PROCEDURE clearUserRole
/*
	name:		clearUserRole
	function:	1.1.清除角色
	input: 
				@userID varchar(10),			--用户ID
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
	@userID varchar(10),			--用户ID
	@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from sysUserInfo where userID = @userID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete sysUserRole where userID = @userID
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '清除用户角色', '用户' + @delManName
												+ '清除了用户['+ @userID +']的全部角色。')

GO

drop PROCEDURE addUserRole
/*
	name:		addUserRole
	function:	1.2.添加用户角色
	input: 
				@userID varchar(10),		--用户ID
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
	@userID varchar(10),		--用户ID
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
	set @count=(select count(*) from sysUserInfo where userID = @userID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查角色是否唯一：
	set @count = (select count(*) from sysUserRole where userID = @userID and sysRoleID = @sysRoleID)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--获取用户名：
	declare @sysUserName varchar(30)
	set @sysUserName = isnull((select sysUserName from sysUserInfo where userID = @userID),'')
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--获取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = isnull((select sysRoleName from sysRole where sysRoleID = @sysRoleID),'')

	insert sysUserRole(userID, sysUserName, sysRoleID, sysRoleName, sysRoleType)
	select @userID, @sysUserName, sysRoleID, sysRoleName, sysRoleType 
	from sysRole
	where sysRoleID = @sysRoleID

	set @updateTime = getdate()
	update sysUserInfo 
	set --维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where userID = @userID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '添加用户角色', '用户' + @modiManName 
												+ '给用户['+ @sysUserName + '('+ @userID +')]的添加了角色['+ @sysRoleName +']。')
GO

/*
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

*/

drop PROCEDURE querySysUserLockMan
/*
	name:		querySysUserLockMan
	function:	5.查询指定系统用户是否有人正在编辑
	input: 
				@userID varchar(10),		--用户ID
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：查询出错，可能是该用户不存在
				@lockManID varchar(10) output		--当前正在编辑的人工号
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE querySysUserLockMan
	@userID varchar(10),		--用户ID
	@Ret		int output,		--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人工号
	WITH ENCRYPTION 
AS
	set @Ret = 1
	set @lockManID = isnull((select lockManID from sysUserInfo where userID = @userID),'')
	set @Ret = 0
GO

drop PROCEDURE lockSysUser4Edit
/*
	name:		lockSysUser4Edit
	function:	6.锁定系统用户编辑，避免编辑冲突
	input: 
				@userID varchar(10),		--用户ID
				@lockManID varchar(10) output,	--锁定人，如果当前系统用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的系统用户不存在，2:要锁定的系统用户正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE lockSysUser4Edit
	@userID varchar(10),		--用户ID
	@lockManID varchar(10) output,	--锁定人，如果当前系统用户正在被人占用编辑则返回该人的工号
	@Ret		int output	--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的系统用户是否存在
	declare @count as int
	set @count=(select count(*) from sysUserInfo where userID = @userID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update sysUserInfo 
	set lockManID = @lockManID 
	where userID = @userID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定用户编辑', '系统根据' + @lockManName
												+ '的要求锁定了用户['+ @userID +']为独占式编辑。')
GO

drop PROCEDURE unlockSysUserEditor
/*
	name:		unlockSysUserEditor
	function:	7.释放系统用户编辑锁
				注意：本过程不检查用户是否存在！
	input: 
				@userID varchar(10),		--用户ID
				@lockManID varchar(10) output,	--锁定人，如果当前系统用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 
*/
create PROCEDURE unlockSysUserEditor
	@userID varchar(10),		--用户ID
	@lockManID varchar(10) output,	--锁定人，如果当前系统用户正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin 
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update sysUserInfo set lockManID = '' where userID = @userID
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
												+ '的要求释放了用户['+ @userID +']的编辑锁。')
GO

drop PROCEDURE updateSysUserInfo
/*
	name:		updateSysUserInfo
	function:	8.更新指定的系统用户信息
				注意：这个存储过程检查用户ID、系统登陆名、身份证号、手机号码、E-mail的唯一性！
					  本存储从原设备系统中用户管理模块中移植过来。
					  本存储过程可以被添加供货单位员工、外贸公司员工、学校教职工及其他授权用户使用，但是修改其他授权用户的时候请注意锁定。
	input: 
				@userType int,				--用户类别：由101号代码字典定义，本字段不能更改！
				@userID varchar(10),		--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等，本字段不能更改！
				--个人信息：
				@cName nvarchar(30),		--姓名
				@unitID varchar(12),		--所属单位编码
				@unitName nvarchar(30),		--所属单位名称，学校员工登记隶属学院名称
				@pID varchar(18),			--身份证号
				@mobile varchar(30),		--手机号码
				@e_mail varchar(30),		--E_mail地址

				--系统登录信息：
				@sysUserName varchar(30),	--用户名:要做唯一性检查
				@sysUserDesc nvarchar(100),	--系统用户描述性文字
				@sysPassword varchar(128),	--系统登录密码
				@pswProtectQuestion varchar(40),--密码保护问题
				@psqProtectAnswer varchar(40),	--密码保护问题的答案

				--维护情况:
				@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，2:该用户名已经被注册过了，
							3：该身份证号已经被注册过了，4：该手机号码已经被注册过了，5：该E-mail地址已经被注册过了，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-4-22
	UpdateDate: modi by lw 2012-11-07增加所属单位代码字段
*/
create PROCEDURE updateSysUserInfo
	@userType int,				--用户类别：由101号代码字典定义，本字段不能更改！
	@userID varchar(10),		--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等，本字段不能更改！
	--个人信息：
	@cName nvarchar(30),		--姓名
	@unitID varchar(12),		--所属单位编码
	@unitName nvarchar(30),		--所属单位名称，学校员工登记隶属学院名称
	@pID varchar(18),			--身份证号
	@mobile varchar(30),		--手机号码
	@e_mail varchar(30),		--E_mail地址

	--系统登录信息：
	@sysUserName varchar(30),	--用户名:要做唯一性检查
	@sysUserDesc nvarchar(100),	--系统用户描述性文字
	@sysPassword varchar(128),	--系统登录密码
	@pswProtectQuestion varchar(40),--密码保护问题
	@psqProtectAnswer varchar(40),	--密码保护问题的答案

	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查名称是否唯一：
	declare @count int
	set @count = (select count(*) from sysUserInfo where sysUserName = @sysUserName and userID <> @userID)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--检查身份证号、手机、E-mail的唯一性：

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran	--modi by lw 2012-4-27确保没有原始信息也能更新
		delete sysUserInfo where userID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end

		insert sysUserInfo (userType, userID,
					--个人信息：
					cName, unitID, unitName, pID, mobile, e_mail,
					--系统登录信息：
					sysUserName, sysUserDesc, sysPassword, pswProtectQuestion, psqProtectAnswer,
					--最新维护情况:
					modiManID, modiManName, modiTime)
		values(@userType, @userID,
					--个人信息：
					@cName, @unitID, @unitName, @pID, @mobile, @e_mail,
					--系统登录信息：
					@sysUserName, @sysUserDesc, @sysPassword, @pswProtectQuestion, @psqProtectAnswer,
					--最新维护情况:
					@modiManID, @modiManName, @updateTime)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新用户信息', '用户' + @modiManName 
												+ '更新了用户['+ @userID +']的信息。')
GO

DROP PROCEDURE sysUserSetOff
/*
	name:		sysUserSetOff
	function:	9.注销指定的系统用户
	input: 
				@userID varchar(10),			--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
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
create PROCEDURE sysUserSetOff
	@userID varchar(10),			--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
	@setOffDate smalldatetime,		--注销日期

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前用户正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
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
	update sysUserInfo
	set isOff = 1, setOffDate = @setOffDate,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where userID = @userID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '注销用户', '用户' + @modiManName 
												+ '注销了系统用户['+ @userID +']。')
GO

DROP PROCEDURE sysUserSetActive
/*
	name:		sysUserSetActive
	function:	10.激活指定的用户
	input: 
				@userID varchar(10),			--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等

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
create PROCEDURE sysUserSetActive
	@userID varchar(10),			--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等

	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前用户正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
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
	update sysUserInfo
	set isOff = 0, setOffDate = null,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where userID = @userID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '激活用户', '用户' + @modiManName 
												+ '激活了系统用户['+ @userID +']。')
GO

drop PROCEDURE delSysUserInfo
/*
	name:		delSysUserInfo
	function:	11.删除指定的系统用户
	input: 
				@userID varchar(10),			--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
				@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该用户不存在，2:要删除的用户信息正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: modi by lw 2011-6-7发现该存储过程没有执行删除命令
*/
create PROCEDURE delSysUserInfo
	@userID varchar(10),			--用户识别号：对应供货单位员工编号、外贸公司员工编号、学校教职工工号等
	@delManID varchar(10) output,	--删除人，如果当前用户正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户是否存在
	declare @count as int
	set @count=(select count(*) from sysUserInfo where userID = @userID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysUserInfo where userID = @userID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	begin tran
		delete sysUserRight where userID = @userID
		delete sysUserInfo where userID = @userID
	commit
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除用户', '用户' + @delManName
												+ '删除了系统用户['+ @userID +']的信息。')

GO
--测试：
declare @delManID varchar(10), @Ret int
set @delManID = '2010112301'
exec dbo.delUserInfo '1234561234', @delManID output, @Ret output
select @Ret

select * from userInfo
delete userInfo where jobNumber=''
update userInfo
set lockManID = null



select * from activeUsers
--2.当前活动用户表(activeUsers)：
truncate table activeUsers
drop table activeUsers
CREATE TABLE activeUsers
(
	userType int not null,				--用户类别：由101号代码字典定义	--add by lw 2012-5-9
	userID varchar(10) not null,		--用户工号
	userName varchar(30) not null,		--用户名
	userCName nvarchar(30) not null,	--用户中文名
	--modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
	psw	varchar(128) not null,			--登录密码
	userIP varchar(40) not null,		--会话客户端IP
	dynaPsw	varchar(36) not null,		--动态密钥
	loginTime smalldatetime not null,	--登录时间
 CONSTRAINT [PK_activeUsers] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE login
/*
	name:		login
	function:	1.用户登录：检查该用户的用户名、密码是否正确，如正确清除以前的登录，登记当前的状态
	input: 
				@userName varchar(30) output,--用户名	modi by lw 2011-6-28,支持工号登录，所以改为返回型参数
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：用户名或密码错，2:系统在清除该用户的编辑锁时出错，9：未知错误
				@dynaPsw varchar(36) output,	--如成功，放动态密钥
				@userCName nvarchar(30) output,	--如成功，放用户中文名
				@userType int output,			--用户类别：由101号代码字典定义	--add by lw 2012-5-9
				@userID varchar(10) output,		--用户工号
				@pID varchar(18) output,		--身份证号
				@mobile varchar(30) output,		--联系手机
				@e_mail varchar(30) output,		--E_mail地址
				@unitID varchar(12) output,		--所属单位代码
				@unitName nvarchar(30) output,	--所属单位名称
				@sysUserDesc nvarchar(100) output--系统用户描述性文字
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2011-6-5 根据前台权限控制的需要增加返回用户的基本信息,删除返回权限列表。
				modi by lw 2011-6-28增加工号登录
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
				modi by lw 2011-9-4增加角色分级类型
				modi by lw 2011-9-19因为用户角色设计的修改而作相应修改，将获取用户角色的信息独立成一个高级程序中的服务，
									将获取用户的权限改为一个动态计算的存储过程。
				modi by lw 2012-4-19根据新设计的系统用户表修改参数，并增加支持手机、身份证号、E-mail账号登录
				modi by lw 2012-5-9增加用户类型
				modi by lw 2012-11-5增加用户所在单位编码字段
*/
create PROCEDURE login
	@userName varchar(30) output,	--用户名
	@psw	varchar(128),			--登录密码
	@userIP varchar(40),			--会话客户端IP

	@Ret	int output,				--操作成功标识
	@dynaPsw varchar(36) output,	--动态密钥
	@userCName nvarchar(30) output, --用户中文名
	@userType int output,			--用户类别：由101号代码字典定义	--add by lw 2012-5-9
	@userID varchar(10) output,		--用户工号
	@pID varchar(18) output,		--身份证号
	@mobile varchar(30) output,		--联系手机
	@e_mail varchar(30) output,		--E_mail地址
	@unitID varchar(12) output,		--所属单位代码
	@unitName nvarchar(30) output,	--所属单位名称
	@sysUserDesc nvarchar(100) output--系统用户描述性文字
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查用户名、密码是否正确，并获取用户的中文名称和工号等基本信息：
	select @userName = sysUserName, @userCName = cName, @userType = userType, @userID = userID, @pID = pID, 
			@mobile = mobile, @e_mail = e_mail,
			@unitID=unitID, @unitName = unitName, @sysUserDesc = sysUserDesc
	from sysUserInfo
	where (sysUserName = @userName or userID = @userName or pID = @userName or mobile = @userName or e_mail = @userName) 
			and sysPassword = @psw
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
		delete activeUsers where userName = @userName	--清除以前的登录
	end

	--清除该用户所有的编辑锁：
	declare @retUnlock as int
	exec dbo.unlockAllEditor @userID, @retUnlock output
	if (@retUnlock <> 0)
	begin
		set @Ret = 2
		return
	end

	--登记登录信息：
	set @dynaPsw = (select newid())		--生成动态密码
	declare @loginTime smalldatetime	--登录时间
	set @loginTime = getdate()
	insert activeUsers(userType, userID, userName, userCName, psw, userIP, dynaPsw, loginTime)
	values(@userType, @userID, @userName, @userCName, @psw, @userIP, @dynaPsw, @loginTime)

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userCName, @loginTime, '登录', '用户' + @userCName 
								+ '在IP为['+ @userIP +']的工作站上登录了系统。\r\n同时系统清除了该用户在其他机器上的登录！')

GO

--测试：
declare	@Ret int , @dynaPsw varchar(36), @userCName varchar(30), @userID varchar(10), @userType int
declare	@pID varchar(18), @mobile varchar(30), @e_mail varchar(30), @unitID varchar(12),	@unitName nvarchar(30)
declare	@sysUserDesc nvarchar(100)
exec dbo.login 'W0000036', '3ECEB86DA53CEE19867EF813ECB47EC5', '127.0.0.1', @Ret output, @dynaPsw output, @userCName output, 
	@userType output, @userID output,
	@pID output, @mobile output, @e_mail output, @unitID output, @unitName output, @sysUserDesc output
select @Ret, @dynaPsw, @userCName, @userType, @userID,
	@pID, @mobile, @e_mail, @unitID, @unitName, @sysUserDesc

update userInfo
set sysPassword ='00200977'
where jobNumber = '00200977'


select sysPassword, LEN(sysPassword) from userInfo where jobNumber = '00200977'
select * from userInfo


update sysUserInfo 
set sysPassword='9369A71B2CA05876A068A505462AD673'
where sysUserName='zgly'


drop PROCEDURE reLogin
/*
	name:		reLogin
	function:	1.1.在线用户重新登录：检查该用户的用户名、密码是否正确，如正确检查是否为在线用户，如果是在线用户唤醒
				本过程使用在超时时重新登录！
	input: 
				@userName varchar(30) output,--用户名	modi by lw 2011-6-28,支持工号登录，所以改为返回型参数
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
	output: 
				@Ret		int output		--操作成功标识
							0：成功，1：用户名或密码错，
							2：无效用户（包括不是原用户、在其他工作站登录或被系统管理员踢出系统），
							9：未知错误
				@dynaPsw varchar(36) output,	--如成功，放动态密钥
				@userCName nvarchar(30) output,	--如成功，放用户中文名
				@userType int output,			--用户类别：由101号代码字典定义	--add by lw 2012-5-9
				@userID varchar(10) output,		--用户工号
				@pID varchar(18) output,		--身份证号
				@mobile varchar(30) output,		--联系手机
				@e_mail varchar(30) output,		--E_mail地址
				@unitID varchar(12) output,		--所属单位代码
				@unitName nvarchar(30) output,	--所属单位名称
				@sysUserDesc nvarchar(100) output--系统用户描述性文字
	author:		卢苇
	CreateDate:	2012-8-15
	UpdateDate: modi by lw 2012-11-5增加所属单位代码字段
*/
create PROCEDURE reLogin
	@userName varchar(30) output,	--用户名
	@psw	varchar(128),			--登录密码
	@userIP varchar(40),			--会话客户端IP

	@Ret	int output,				--操作成功标识
	@dynaPsw varchar(36) output,	--如成功，放动态密钥
	@userCName nvarchar(30) output,	--如成功，放用户中文名
	@userType int output,			--用户类别：由101号代码字典定义	--add by lw 2012-5-9
	@userID varchar(10) output,		--用户工号
	@pID varchar(18) output,		--身份证号
	@mobile varchar(30) output,		--联系手机
	@e_mail varchar(30) output,		--E_mail地址
	@unitID varchar(12) output,		--所属单位代码
	@unitName nvarchar(30) output,	--所属单位名称
	@sysUserDesc nvarchar(100) output--系统用户描述性文字
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查用户名、密码是否正确，并获取用户的中文名称和工号等基本信息：
	select @userName = sysUserName, @userCName = cName, @userType = userType, @userID = userID, @pID = pID, @mobile = mobile, @e_mail = e_mail,
			@unitID=unitID, @unitName = unitName, @sysUserDesc = sysUserDesc
	from sysUserInfo
	where (sysUserName = @userName or userID = @userName or pID = @userName or mobile = @userName or e_mail = @userName) and sysPassword = @psw
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
				@userName varchar(30),		--用户名
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
				@dynaPsw varchar(36),		--动态密钥
	output: 

				@Ret		int output		--标识
							1:是，0：不是，-1：未知错误
	author:		卢苇
	CreateDate:	2011-9-20
	UpdateDate: 
*/
create PROCEDURE validateActiveUser
	@userName varchar(30),		--用户名
	@psw	varchar(128),		--登录密码
	@userIP varchar(40),		--会话客户端IP
	@dynaPsw varchar(36),		--动态密钥
	@Ret		int output		--标识
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
	function:	3.安全退出
	input: 
				@userName varchar(30),		--用户名
				@psw	varchar(128),		--登录密码
				@userIP varchar(40),		--会话客户端IP
				@dynaPsw varchar(36),		--动态密钥
	output: 
				@Ret		int output		--标识
							1:是，0：没有该用户，2：在释放该用户可能的编辑锁的时候出错，-1：未知错误
	author:		卢苇
	CreateDate:	2010-2-1
	UpdateDate: 2010-5-10增加工作日志处理
				modi by lw 2011-6-28增加释放用户可能存在的编辑锁
				modi by lw 2011-7-5因为密码使用加密程序，延长密码长度！
*/
create PROCEDURE logout
	@userName varchar(30),		--用户名
	@psw	varchar(128),		--登录密码
	@userIP varchar(40),		--会话客户端IP
	@dynaPsw varchar(36),		--动态密钥

	@Ret		int output		--标识
	WITH ENCRYPTION 
AS
	set @Ret = -1

	declare @count as int
	set @count=(select count(*) from activeUsers 
								where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw)
	declare @userCName nvarchar(30), @userID int --用户中文名\用户身份证号
	if @count > 0
	begin
		--获取用户中文名\用户身份证号：
		select @userCName = userCName, @userID = userId 
		from activeUsers 
		where userName = @userName and psw = @psw and userIP = @userIP and dynaPsw = @dynaPsw
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
	end
	else
		set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userCName, getdate(), '登出', '用户' + @userCName + '安全地退出了系统。')
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
*/
create PROCEDURE unlockAllEditor
	@userID varchar(10),		--用户工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	begin tran
		--字典类表的编辑锁：
		update codeDictionary set lockManID = '' where lockManID = @userID	--代码字典编辑锁
		update userInfo set lockManID = '' where lockManID = @userID		--学校员工编辑锁
		update supplierInfo set lockManID = '' where lockManID = @userID	--供货单位编辑锁
		update supplierManInfo set lockManID = '' where lockManID = @userID	--供货单位员工编辑锁
		update traderInfo set lockManID = '' where lockManID = @userID		--外贸公司编辑锁
		update traderManInfo set lockManID = '' where lockManID = @userID	--外贸公司员工编辑锁

		--业务类表的编辑锁：
		update contractInfo set lockManID = '' where lockManID = @userID	--外贸合同编辑锁
		update convertInfo set lockManID = '' where lockManID = @userID		--外汇牌价表编辑锁
		update evaluateInfo set lockManID = '' where lockManID = @userID	--业务情况反馈表

		--权限控制类表的编辑锁：
		update sysRole set lockManID = '' where lockManID = @userID			--系统角色编辑锁
		update sysUserInfo set lockManID = '' where lockManID = @userID		--系统用户编辑锁

		--运维类表的编辑锁：
		update bulletinInfo set lockManID = '' where lockManID = @userID	--系统公告板编辑锁
	commit tran
	set @Ret = 0

GO
--测试：
declare @Ret int
exec dbo.unlockAllEditor '0000000001',@Ret output
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
	UpdateDate: 
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
		update codeDictionary set lockManID = ''--代码字典编辑锁
		update userInfo set lockManID = ''		--学校员工编辑锁
		update supplierInfo set lockManID = ''	--供货单位编辑锁
		update supplierManInfo set lockManID = ''--供货单位员工编辑锁
		update traderInfo set lockManID = ''	--外贸公司编辑锁
		update traderManInfo set lockManID = ''	--外贸公司员工编辑锁
		
		--业务类表的编辑锁：
		update contractInfo set lockManID = ''	--外贸合同编辑锁
		update convertInfo set lockManID = ''	--外汇牌价表编辑锁
		update evaluateInfo set lockManID = ''	--业务情况反馈表

		--权限控制类表的编辑锁：
		update sysRole set lockManID = ''			--系统角色编辑锁
		update sysUserInfo set lockManID = ''			--系统用户编辑锁

		--运维类表的编辑锁：
		update bulletinInfo set lockManID = ''		--系统公告板编辑锁
	commit tran
	set @Ret = 0

GO
--测试：
declare @Ret int
exec dbo.unlockAllEditor '0000000001',@Ret output
select @Ret

drop PROCEDURE modiPassword
/*
	name:		modiPassword
	function:	6.修改密码
				注意：这个存储过程不检查原密码是否与数据库中登记的一致！
	input: 
				@userID varchar(10),		--用户ID
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
				modi by lw 2012-4-19 修改了取被修改人的姓名错误，根据新的系统用户表修改接口
*/
create PROCEDURE modiPassword
	@userID varchar(10),		--用户ID
	@newPassword varchar(128),	--新系统登录密码

	--最新维护情况:
	@modiManID varchar(10),		--修改人工号

	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
		 
	--取维护人和被修改密码的用户的姓名：
	declare @modiManName nvarchar(30), @cName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @cName = isnull((select cName from sysUserInfo where userID = @userID),'')
	
	if @cName is null
	begin
		set @Ret = 1
	end

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	update sysUserInfo 
	set sysPassword = @newPassword
	where userID = @userID
	
	--如果是当前用户更改了密码，需要将活动用户表更新：
	if (@modiManID = @userID)
	begin	
		update activeUsers
		set psw = @newPassword
		where  userID = @userID
	end
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, 
								'重置密码','系统根据' + @modiManName + 
								'的要求重置了用户[' + @cName + '('+@userID+')]的密码。')
GO


select * from userInfo where cName='高卫星'
select * from sysUserInfo where userID='00002656'
select * from sysUserRole where userID='00002656'
select sysRoleID, sysRoleName, sysRoleType
from sysUserRole
where userID='00002656'
order by sysRoleID
select rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc  
from sysRoleRight 
where sysRoleID in (select sysRoleID from sysUserRole where userID = '00201536') 
group by rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc 
order by rightKind, rightClass, rightItem; 
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprPartSize) oprPartSize 
from sysRoleDataOpr 
where sysRoleID in (select sysRoleID from sysUserRole where userID = '00201536') 
group by rightKind, rightClass, rightItem, sortNum, oprType, oprName, oprEName, oprDesc 
order by rightKind, rightClass, rightItem, sortNum, oprType

insert sysUserRole
values('00002656','gwx',1,'超级用户',1)

select * from userInfo 
select * from sysUserInfo
where sysUserName='gwx'
update sysUserInfo
set sysuserName='gwx2'
where userID='00201536'
update userInfo
set sysPassword = jobNumber


select userType, userID, pID, mobile, e_mail, cName, unitID,unitName, sysUserName, sysUserDesc
from sysUserInfo
where isOff=0
