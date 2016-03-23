use epdc211
/*
	武大设备管理信息系统-用户个性化设置
	author:		卢苇
	CreateDate:	2012-3-15
	UpdateDate: modi by lw 2012-5-21根据外贸系统最新设计一致化！
*/
--用户个性化设置表：
select * from  userOption
drop TABLE userOption
CREATE TABLE userOption
(
	rowNum int default(0),				--序号:为了保证用户登录时取最近的可能样式而增加
	userID varchar(10) not null,		--用户工号
	userName varchar(30) not null,		--用户名
	userCName nvarchar(30) not null,	--用户中文名
	userIP varchar(40) not null,		--会话客户端IP

	privateTheme varchar(128),			--用户个性化主题（样式表路径）
	privateDialogStyle varchar(128),	--用户个性化对话合风格
	privateDialogSkin varchar(128),		--用户个性化对话合皮肤
	
	--以下为定义对话合内的文字、边框、输入栏底色等元素样式：
	privateFormCss varchar(8000),		--用户个性化业务表单样式表
	privateReadOnlyFormCss varchar(8000),	--用户个性化只读业务表单样式表
	privateDialogCss varchar(8000),		--用户个性化对话合样式表

CONSTRAINT [PK_userOption] PRIMARY KEY CLUSTERED 
(
	[userID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_userOption] ON [dbo].[userOption] 
(
	[userIP] ASC,
	[rowNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from userOption

drop PROCEDURE setOption
/*
	name:		setOption
	function:	1.设置用户个性化参数
				注意：因为这个设置过程现在没有发现并发情况，所以没有上锁。
	input: 
				@userID varchar(10),				--用户工号
				@userIP varchar(40),				--会话客户端IP
				@privateTheme varchar(128),			--用户个性化样式表路径
				@privateDialogStyle varchar(128),	--用户个性化对话合风格
				@privateDialogSkin varchar(128),	--用户个性化对话合皮肤
				@privateFormCss varchar(8000),		--用户个性化业务表单样式表
				@privateReadOnlyFormCss varchar(8000),--用户个性化只读业务表单样式表
				@privateDialogCss varchar(8000),	--用户个性化对话合样式表
	output: 
				@Ret int output				--操作成功标识：0:成功，9：出错
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-5-20扩展个性化参数，支持对话合风格、对话合皮肤已经元素的样式
*/
create PROCEDURE setOption
	@userID varchar(10),				--用户工号
	@userIP varchar(40),				--会话客户端IP
	@privateTheme varchar(128),			--用户个性化样式表路径
	@privateDialogStyle varchar(128),	--用户个性化对话合风格
	@privateDialogSkin varchar(128),	--用户个性化对话合皮肤
	@privateFormCss varchar(8000),		--用户个性化业务表单样式表
	@privateReadOnlyFormCss varchar(8000),--用户个性化只读业务表单样式表
	@privateDialogCss varchar(8000),	--用户个性化对话合样式表
	@Ret int output						--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--取用户名和姓名：
	declare @userName varchar(30), @userCName nvarchar(30)	--用户名/用户中文名
	select @userName = sysUserName, @userCName = cName from userInfo where jobNumber = @userID

	--删除该用户的原设定：
	delete userOption where userID = @userID
	
	--将该IP上的个性化设置重新排序：
	update userOption
	set rowNum = s.RowID
	from userOption u left join (select ROW_NUMBER() OVER(order by rowNum) AS RowID, userID
									from userOption where userIP = @userIP) as s on u.userID = s.userID
	where u.userIP = @userIP
	
	insert userOption(userID, userName, userCName, userIP, 
			privateTheme, privateDialogStyle, privateDialogSkin, 
			privateFormCss, privateReadOnlyFormCss, privateDialogCss)
	values(@userID, @userName, @userCName, @userIP, 
			@privateTheme, @privateDialogStyle, @privateDialogSkin, 
			@privateFormCss, @privateReadOnlyFormCss, @privateDialogCss)
	if @@ERROR <> 0 
	begin
		return
	end    
	set @Ret = 0
GO


drop PROCEDURE updateUserLoginIP
/*
	name:		updateUserLoginIP
	function:	2.更新用户登录IP，如果存在该用户的个性化设置，将其设置为该IP的默认设置
				注意：因为这个设置过程现在没有发现并发情况，所以没有上锁。
	input: 
				@userID varchar(10),				--用户工号
				@userIP varchar(40),				--会话客户端IP
	output: 
				@Ret int output						--操作成功标识：0:成功，1:该用户没有个性化设置，9：出错
	author:		卢苇
	CreateDate:	2012-5-21
	UpdateDate: 
*/
create PROCEDURE updateUserLoginIP
	@userID varchar(10),				--用户工号
	@userIP varchar(40),				--会话客户端IP
	@Ret int output						--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count as int
	set @count = (select count(*) from userOption where userID = @userID)
	if (@count = 0)
	begin
		set @Ret = 1
		return
	end
	
	--将该IP上的个性化设置重新排序：
	update userOption
	set rowNum = s.RowID
	from userOption u left join (select ROW_NUMBER() OVER(order by rowNum) AS RowID, userID
									from userOption where userIP = @userIP) as s on u.userID = s.userID
	where u.userIP = @userIP
	
	update userOption
	set userIP = @userIP, rowNum = 0
	where userID = @userID

	set @Ret = 0
GO
