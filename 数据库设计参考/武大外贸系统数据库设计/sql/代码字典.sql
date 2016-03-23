use fTradeDB2
/*
	武大外贸合同管理信息系统-代码字典数据库设计
	根据设备管理系统修改
	author:		卢苇
	CreateDate:	2010-7-11
	UpdateDate: 
*/
truncate table codeDictionary
--1.代码字典(codeDictionary)：
	--class = 0	描述字典类型：

--1：系统参数代码表：
select * from codeDictionary where classCode = 1

--2：设备现状码：
select * from codeDictionary where classCode = 2

--3：币种代码：
select * from codeDictionary where classCode = 3
select b.objCode, c.cCode, b.objDesc, c.cName 
from codeDictionary b left join country c on b.objCode=c.cCode 
where classCode = 3

--4：付款方式：
select * from codeDictionary where classCode = 4

--5：附件类型：指需要扫描归档的合同、协议原件
select * from codeDictionary where classCode = 5

--10：使用单位类型：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 10, '使用单位类型', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 1, '教学')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 2, '科研')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 3, '行政')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 4, '后勤')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 9, '其他')

--98.系统数据（系统权限，系统资源）颗粒度代码：
select * from codeDictionary where classCode = 98

--99.系统数据对象操作分类
select * from codeDictionary where classCode = 99

--100.角色分级类型
select * from codeDictionary where classCode = 100

--101.系统用户类别
select * from codeDictionary where classCode = 101




--10.存储过程：
--设计要求（应提供的功能）：
--1.查询全部大类情况
--2.查询指定的大类中的条目
--3.查询条目标准代码和描述
--4.查询全部的代码字典
------------以上功能直接使用查询语句查询封装在一个查询服务类内，不需要“安全认证”
------------以下功能需要“安全认证”，不能直接使用数据操作语句，要调用存储过程，封装在一个维护服务类内
--10.查询指定代码是否有人正在编辑（只查询到大分类）：queryCDLockMan
--11.锁定代码字典编辑，避免编辑冲突:lockCD4Edit
--12.释放代码字典编辑锁:unlockCDEditor
--13.增加一个分类（只增加分类编号、分类名称，要检查编号是否有重号，其他项目由高级语言调用修改修改命令完成）
--14.增加一个条目（只增加分类编号、条目编号、条目描述，要检查编号是否有重号，其他项目由高级语言调用修改修改命令完成）

--15.修改一个分类（除分类编号和索引图像外的其他字段的修改）
--16.修改一个条目（除分类编号、条目编号和索引图像外的其他字段的修改）
------------修改索引图片请使用高级语言流操作

--17.修改一个分类编号（要求自动检查是否重复编码，检查引用的表，完成相关修改）
--18.修改一个条目编号（要求自动检查是否重复编码，检查引用的表，完成相关修改）

--19.删除一个分类（要求自动检查引用的表，如果有引用返回出错信息）
--20.删除一个条目（要求自动检查引用的表，如果有引用返回出错信息）
--21.强制删除一个分类（要求自动检查引用的表，如果有引用返回有引用信息，但完成删除）
--22.强制删除一个条目（要求自动检查引用的表，如果有引用返回有引用信息，但完成删除）

select * from codeDictionary
	--	代码字典表（codeDictionary）：
alter TABLE codeDictionary alter column lockManID varchar(10) null			--当前正在锁定编辑的人身份ID
alter TABLE codeDictionary drop	column modiManType	--维护人类别：2->商家管理员，3->营运商管理员
alter TABLE codeDictionary alter column modiManID varchar(10)	--维护人身份ID

drop table codeDictionary
CREATE TABLE codeDictionary (
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	classCode int NOT NULL ,	--分类编码
	objCode int NOT NULL ,		--代码（条目编码） 计划：modi by lw 2010-3-30 由smallint 改为 int
	objDesc varchar(100) COLLATE Chinese_PRC_CI_AS NULL ,	--条目描述
	inputCode varchar(6) null,								--输入码
	objEngDesc varchar(100) NULL ,	--条目英文描述	
	objDetail varchar(500) NULL ,	--条目详细解释
	standardName varchar(100) COLLATE Chinese_PRC_CI_AS NULL ,	--引用标准名
	GBDigiCode varchar(10) null,		--国标数字代码
	GBEngCode varchar(10) null,			--国标字母代码
	cdImage varchar(128) null,			--代码字典图片路径

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：add by lw 2013-1-10
	--大类的停用就表示停止整个分类的代码字典，条目的停用表示独立条目停用！
	isOff char(1) default('0') null,	--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,	--维护人工号
	modiManName nvarchar(30) null,--维护人姓名
	modiTime smalldatetime null,--最后维护时间
	--编辑锁定人：
	lockManID varchar(10),		--当前正在锁定编辑的人工号
 CONSTRAINT [PK_codeDictionary] PRIMARY KEY CLUSTERED 
(
	[classCode] ASC,
	[objCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--输入码索引：
CREATE NONCLUSTERED INDEX [IX_codeDictionary] ON [dbo].[codeDictionary] 
(
	[inputCode] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--查询代码字典的编目：
select * from codeDictionary where classCode = 0

--查询第X号代码字典：
select * from codeDictionary where classCode = 1

drop PROCEDURE queryCDLockMan
/*
	name:		queryCDLockMan
	function:	1.查询指定代码是否有人正在编辑（锁只锁定到大分类）
	input: 
				@classCode int,			--分类编码
	output: 
				@Ret		int output	--操作成功标识
							0:成功，9：查询出错，可能是该代码字典不存在
				@lockManID varchar(10) output	--当前正在编辑的人工号
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE queryCDLockMan
	@classCode	int,			--分类编码
	@Ret		int output,		--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = (select lockManID from codeDictionary where classCode = 0 and objCode = @classCode)
	set @Ret = 0
GO

drop PROCEDURE lockCD4Edit
/*
	name:		lockCD4Edit
	function:	2.锁定代码字典编辑，避免编辑冲突
	input: 
				@classCode	int,				--分类编码
				@lockManID varchar(10) output,	--锁定人，如果当前代码字典正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的代码字典不存在，2:要锁定的代码字典正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE lockCD4Edit
	@classCode	int,		--分类编码
	@lockManID varchar(10) output,	--锁定人，如果当前代码字典正在被人占用编辑则返回该人的工号
	@Ret		int output	--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的代码字典是否存在
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取维护人的姓名：
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定代码字典编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了代码字典['+ ltrim(str(@classCode,6)) +']为独占式编辑。')
GO

drop PROCEDURE unlockCDEditor
/*
	name:		unlockCDEditor
	function:	3.释放代码字典编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@classCode	int,				--分类编码
				@lockManID varchar(10) output,	--锁定人，如果当前代码字典正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：要释放编辑锁的锁定人不是自己，2：未知错误
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE unlockCDEditor
	@classCode	int,				--分类编码
	@lockManID varchar(10) output,	--锁定人，如果当前代码字典正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
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

	--取维护人的姓名：
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放代码字典编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了代码字典['+ ltrim(str(@classCode,6)) +']的编辑锁。')

GO


drop PROCEDURE addClass
/*
	name:		addClass
	function:	4.增加一个分类（只增加分类编号、分类名称，要检查编号是否有重号，其他项目由高级语言调用修改命令完成）
				注意：增加一个分类以后自动上锁！
	input: 
				@classCode	int,			--分类编码
				@className	nvarchar(100),	--分类名称
				@addManID varchar(10),		--添加人
				
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要增加的类别已经被占用，9->未知错误
				@createTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE addClass
	@classCode	int,			--分类编码
	@className	nvarchar(100),	--分类名称
	@addManID varchar(10),		--添加人

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查唯一性：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @createTime, '添加代码字典', '系统根据用户' + @addManName + 
							'的要求添加了代码字典[' + ltrim(str(@classCode,6)) + ']。')
GO

drop PROCEDURE addObj
/*
	name:		5.addObj
	function:	增加一个条目（只增加分类编号、条目编号、条目描述，要检查编号是否有重号，其他项目由高级语言调用修改命令完成）
	input: 
				@classCode int,				--分类编码
				@objCode int,				--条目编码
				@objDesc nvarchar(100),		--条目描述

				@addManID varchar(10) output,--添加人，如果当前代码字典正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要增加的条目已经被占用，2：该条目所在的代码字典并不存在，
							3:该类代码字典正在被别人编辑，9->未知错误
				@createTime smalldatetime output--添加时间
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE addObj
	@classCode int,			--分类编码
	@objCode int,			--条目编码
	@objDesc nvarchar(100),	--条目描述

	@addManID varchar(10) output,--添加人，如果当前代码字典正在被人占用编辑则返回该人的工号

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查唯一性：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--判断隶属的大类是否存在：
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @addManID)
	begin
		set @addManID = @thisLockMan
		set @Ret = 3
		return
	end

	--取维护人的姓名：
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
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @createTime, '添加代码字典条目', '系统根据用户' + @addManName + 
							'的要求添加了代码字典[' + ltrim(str(@classCode,6)) 
							+ ']的一个条目['+ ltrim(str(@objCode ,6)) + ']：' + @objDesc +'。')
GO


drop PROCEDURE modiClass
/*
	name:		modiClass
	function:	6.修改一个代码字典名称等属性（除分类编号外的其他字段的修改）
	input: 
				@classCode 	int,			--分类编码
				@className	nvarchar(100),	--分类名称
				@inputCode varchar(6),		--输入码
				@objEngDesc varchar(100) ,	--英文描述	
				@objDetail nvarchar(500),	--详细解释
				@standardName nvarchar(100),--引用标准名
				@GBDigiCode varchar(10),	--国标数字代码
				@GBEngCode varchar(10),		--国标字母代码
				@cdImage varchar(128),		--代码字典图片路径

				@modiManID varchar(10) output,		--维护人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要修改的代码字典不存在，2：要修改的代码字典正被别人锁定，9：未知错误
				@modiTime smalldatetime output	--更新日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE modiClass
	@classCode 	int,			--分类编码
	@className	nvarchar(100),	--分类名称
	@inputCode varchar(6),		--输入码
	@objEngDesc varchar(100) ,	--英文描述	
	@objDetail nvarchar(500),	--详细解释
	@standardName nvarchar(100),--引用标准名
	@GBDigiCode varchar(10),	--国标数字代码
	@GBEngCode varchar(10),		--国标字母代码
	@cdImage varchar(128),		--代码字典图片路径

	@modiManID varchar(10) output,		--维护人，如果当前代码字典正在被人占用编辑则返回该人工号
	@Ret	 int output,	
	@modiTime smalldatetime output	--更新日期
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '更新代码字典', '用户' + @modiManName 
												+ '更新了代码字典['+ ltrim(str(@classCode,6)) +']的信息。')
GO

drop PROCEDURE modiObj
/*
	name:		modiObj
	function:	7.修改一个条目（除分类编号、条目编号和索引图像外的其他字段的修改）
	input: 
				@classCode int,				--分类编码
				@objCode int,				--条目编码
				@objDesc nvarchar(100),		--条目描述
				@inputCode varchar(6),		--输入码
				@objEngDesc varchar(100) ,	--条目英文描述	
				@objDetail nvarchar(500),	--条目详细解释
				@standardName nvarchar(100),--引用标准名
				@GBDigiCode varchar(10),	--国标数字代码
				@GBEngCode varchar(10),		--国标字母代码
				@cdImage varchar(128),		--代码字典图片路径

				@modiManID varchar(10) output,	--维护人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该条目不存在，2：要更新的代码字典正被别人锁定，9：未知错误
				@modiTime smalldatetime output	--更新日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE modiObj
	@classCode int,				--分类编码
	@objCode int,				--条目编码
	@objDesc nvarchar(100),		--条目描述
	@inputCode varchar(6),		--输入码
	@objEngDesc varchar(100) ,	--条目英文描述	
	@objDetail nvarchar(500),	--条目详细解释
	@standardName nvarchar(100),--引用标准名
	@GBDigiCode varchar(10),	--国标数字代码
	@GBEngCode varchar(10),		--国标字母代码
	@cdImage varchar(128),		--代码字典图片路径

	@modiManID varchar(10) output,--维护人，如果当前代码字典正在被人占用编辑则返回该人工号

	@Ret	 int output,	
	@modiTime smalldatetime output--更新日期
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '更新代码字典条目', '用户' + @modiManName 
							+ '更新了代码字典['+ ltrim(str(@classCode,6)) +']中的['+ ltrim(str(@objCode,6)) +']条目的信息。')
GO


drop PROCEDURE modiClassCode
/*
	name:		modiClassCode
	function:	8.修改一个分类的代码
				注意：这个过程会同步修改所有使用过这个代码的表，所以要求锁定全部的引用表，如果发生冲突则回滚。
	input: 
				@oldClassCode int,	--老分类编码
				@newClassCode int,	--新分类编码
				@modiManID varchar(10) output,--维护人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：该分类不存在，2:要修改的分类正被别人占用编辑，
							3：目标分类已经被别人使用，
							4：在修改引用代码的表的时候发生冲突，系统回滚了所有数据，
							9：未知错误
				@modiTime smalldatetime output	--更新日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE modiClassCode
	@oldClassCode 	int,
	@newClassCode	int,

	@modiManID varchar(10) output,--维护人，如果当前代码字典正在被人占用编辑则返回该人工号

	@Ret	 int output,	
	@modiTime smalldatetime output	--更新日期
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查源分类是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @oldClassCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @oldClassCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查目标代码字典是否被占用
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @newClassCode)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName varchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		--检查所有引用该代码字典的表，如果有引用则要全部修改引用的数据。这要等全部数据库设计完在添加！！！
		
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '严重警告', '用户' + @modiManName 
								+ '将代码字典['+ ltrim(str(@oldClassCode,6)) +']的代码更改为['+ ltrim(str(@newClassCode,6)) +']。'
								+ '\r\n这将会影响到所有引用该代码字典的数据！')
GO

drop PROCEDURE modiObjCode
/*
	name:		modiObjCode
	function:	9.修改一个条目编号
				注意：这个过程会同步修改所有使用过这个代码的表，所以要求锁定全部的引用表，如果发生冲突则回滚。
	input: 
				@classCode int,		--分类编码
				@oldObjCode int,	--老条目编码
				@newObjCode int,	--新条目编码

				@modiManID varchar(10) output,--维护人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该条目不存在，2:要修改的代码字典正被别人占用编辑，
							3：目标条目编号已经被占用，4：在修改引用代码的表的时候发生冲突，系统回滚了所有数据，
							9：未知错误
				@modiTime smalldatetime output	--更新日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE modiObjCode
	@classCode 	int,
	@oldObjCode int,
	@newObjCode int,

	@modiManID varchar(10) output,--维护人，如果当前代码字典正在被人占用编辑则返回该人工号

	@Ret	 int output,	
	@modiTime smalldatetime output	--更新日期
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @oldObjCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end


	--检查新条目编码是否被占用
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @newObjCode)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName varchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		--检查所有引用该代码的表，如果有引用则要全部修改引用的数据。这要等全部数据库设计完在添加！！！

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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '严重警告', '用户' + @modiManName 
					+ '将代码字典['+ ltrim(str(@ClassCode,6)) +']中的['+ ltrim(str(@oldObjCode,6)) 
					+']条目的代码更改为['+ ltrim(str(@newObjCode,6)) +']。'
					+ '\r\n这将会影响到所有引用该代码字典的数据！')
GO


drop PROCEDURE setClassOff
/*
	name:		setClassOff
	function:	10.停用指定的类别的代码字典
	input: 
				@classCode int,					--分类编码
				@stopManID varchar(10) output,	--停用人，如果当前分类正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的分类不存在，2：要停用的分类正被别人锁定，3：该分类本就是停用状态，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setClassOff
	@classCode int,					--分类编码
	@stopManID varchar(10) output,	--停用人，如果当前分类正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的分类是否存在
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode=@classCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
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
	--检查状态：
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

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用代码字典', '用户' + @stopManName
												+ '停用了第[' + str(@classCode,8) + ']号代码字典。')
GO

drop PROCEDURE setClassActive
/*
	name:		setClassActive
	function:	11.启用指定的分类的代码字典
	input: 
				@classCode int,					--分类编码
				@activeManID varchar(10) output,	--启用人，如果当前分类正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的分类不存在，2：要启用的分类正被别人锁定，3：该分类本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setClassActive
	@classCode int,					--分类编码
	@activeManID varchar(10) output,--启用人，如果当前分类正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的分类是否存在
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode=@classCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
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
	--检查状态：
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

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '启用代码字典', '用户' + @activeManName
												+ '重新启用了第[' + str(@classCode,8) + ']号代码字典。')
GO


drop PROCEDURE setItemOff
/*
	name:		setItemOff
	function:	12.停用代码字典的指定条目
	input: 
				@classCode int,					--分类编码
				@objCode int,					--条目编码
				@stopManID varchar(10) output,	--停用人，如果当前分类正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的条目不存在，2：要停用的分类正被别人锁定，3：该条目本就是停用状态，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setItemOff
	@classCode int,					--分类编码
	@objCode int,					--条目编码
	@stopManID varchar(10) output,	--停用人，如果当前分类正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的条目是否存在
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode=@objCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
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
	--检查状态：
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

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用代码字典', '用户' + @stopManName
												+ '停用了第[' + str(@classCode,8) + ']号代码字典的第['+STR(@objCode,8)+']条。')
GO

drop PROCEDURE setItemActive
/*
	name:		setItemActive
	function:	13.启用指定分类的代码字典条目
	input: 
				@classCode int,					--分类编码
				@objCode int,					--条目编码
				@activeManID varchar(10) output,--启用人，如果当前分类正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的条目不存在，2：要启用的条目正被别人锁定，3：该条目本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-10
	UpdateDate: 

*/
create PROCEDURE setItemActive
	@classCode int,					--分类编码
	@objCode int,					--条目编码
	@activeManID varchar(10) output,--启用人，如果当前分类正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的条目是否存在
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode=@objCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
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
	--检查状态：
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

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '启用代码字典', '用户' + @activeManName
												+ '重新启用了第[' + str(@classCode,8) + ']号代码字典的第['+STR(@objCode,8)+']号条目。')
GO



drop PROCEDURE delClass
/*
	name:		delClass
	function:	14.删除一个分类（要求自动检查引用的表，如果有引用返回出错信息）
	input: 
				@classCode int,			--分类编码

				@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：该代码字典不存在，2：要删除的代码字典正被别人锁定，3：该代码字典已经被引用，9：未知错误
				@delTime smalldatetime output	--删除日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE delClass
	@classCode 	int,

	@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	@Ret	 int output,	
	@delTime smalldatetime output	--删除日期
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查分类是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查新条目编码是否被引用，这要等全部数据库设计完在添加！！！
	--如果被引用，返回3号出错代码
	--set @Ret = 3

	set @delTime = getdate()
	begin tran
		--删除全部条目
		delete codeDictionary 
		where classCode = @ClassCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--删除大类
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

	--取维护人的姓名：
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '严重警告', '用户' + @delManName
									+ '删除了代码字典['+ ltrim(str(@ClassCode,6)) +']。'
									+ '\r\n这将会影响到所有引用该代码字典的数据！')
GO

drop PROCEDURE forceDelClass
/*
	name:		forceDelClass
	function:	15.强制删除一个分类（这里不检查引用的表，完成删除，应给出提示）
	input: 
				@classCode int,			--分类编码

				@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：该代码字典不存在，2：要删除的代码字典正被别人锁定，9：未知错误
				@delTime smalldatetime output	--删除日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE forceDelClass
	@classCode 	int,

	@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	@Ret	 int output,	
	@delTime smalldatetime output	--删除日期
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查分类是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = 0 and objCode = @classCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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
		--删除全部条目
		delete codeDictionary 
		where classCode = @ClassCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--删除大类
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

	--取维护人的姓名：
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '严重警告', '用户' + @delManName
									+ '删除了代码字典['+ ltrim(str(@ClassCode,6)) +']。'
									+ '\r\n这将会影响到所有引用该代码字典的数据！')
GO


drop PROCEDURE delItem
/*
	name:		delItem
	function:	16.删除指定代码字典中的一个条目（要求自动检查引用的表，如果有引用返回出错信息）
	input: 
				@classCode int,		--分类编码
				@ObjCode int,		--条目编码

				@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：该条目不存在，2：要删除的代码字典正被别人锁定，3：该条目已经被引用，9：未知错误
				@delTime smalldatetime output	--删除日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE delItem
	@classCode 	int,
	@ObjCode	int,

	@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	@Ret	 int output,	
	@delTime smalldatetime output	--删除日期
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from codeDictionary where classCode = 0 and objCode = @classCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查新条目编码是否被引用，这要等全部数据库设计完再添加！！！
	--如果被引用，返回3号出错代码
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

	--取维护人的姓名：
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '严重警告', '用户' + @delManName
							+ '删除了代码字典['+ ltrim(str(@ClassCode,6)) +']中的第['+ ltrim(str(@ObjCode,6)) +']号条目。'
							+ '\r\n这将会影响到所有引用该代码字典的数据！')
GO

drop PROCEDURE forceDelItem
/*
	name:		forceDelItem
	function:	17.强制删除一个条目（这里不检查引用的表，完成删除，应给出提示）
	input: 
				@classCode int,		--分类编码
				@ObjCode int,		--条目编码

				@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：该条目不存在，2：要删除的代码字典正被别人锁定，9：未知错误
				@delTime smalldatetime output	--删除日期
	author:		卢苇
	CreateDate:	2010-5-29
	UpdateDate: modi by lw 2013-1-1一致化维护情况字段，修正接口
*/
create PROCEDURE forceDelItem
	@classCode 	int,
	@ObjCode	int,

	@delManID varchar(10) output,--删除人，如果当前代码字典正在被人占用编辑则返回该人工号
	@Ret	 int output,	
	@delTime smalldatetime output	--删除日期
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否存在：
	declare @count as int
	set @count=(select count(*) from codeDictionary where classCode = @classCode and objCode = @objCode)
	if @count = 0
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
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

	--取维护人的姓名：
	declare @delManName varchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delTime, '严重警告', '用户' + @delManName
							+ '删除了代码字典['+ ltrim(str(@ClassCode,6)) +']中的第['+ ltrim(str(@ObjCode,6)) +']号条目。'
							+ '\r\n这将会影响到所有引用该代码字典的数据！')
GO

---------------------------------------相关的表和存储过程：---------------------------------------

--图片的存储和显示
drop table indexPic
CREATE TABLE [indexPic] (
	[indexNum] [varchar] (20) NOT NULL,		--图片索引号
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
	名称::	CreateIndexPic
	
	功能:	根据指定的索引号(可省略)创建图象文件
	注意：	pic字段不能为NULL，否则上传的存储过程不能正常工作，可以初始化为一个字符串
	
	wrt  by lw 2004-07-22
*/
CREATE PROCEDURE CreateIndexPic
	@indexNum 	varchar(20) output
AS
	if @indexNum <> ''	--检查该索引号是否唯一
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
	名称::	UploadImageFirst
	
	功能:	根据指定的索引号上传图象文件数据
		因为要清空原来的数据所以第1次要特殊处理
	
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
	名称::	UploadImage
	
	功能:	根据指定的索引号上传图象文件数据,这是第1次处理后的其他处理程序。
	
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

--图象下传直接使用PICTUREBOX等控件与ADODC绑定浏览


--测试：
declare @image_data varbinary(1024)
set @image_data= cast('Hello' as varbinary(1024))

declare @indexNum as varchar(50)
set @indexNum = '000'

exec UploadImageFirst @image_data, @indexNum

set @image_data= cast('This is a test....' as varbinary(1024))

exec UploadImage @image_data, @indexNum


--数据制作：
use epdc2
--1：系统参数代码表
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 1, '系统参数', '', '')
insert codeDictionary(classCode, objCode, objDesc)	--系统使用单位代码
values(1, 1, '10486')
insert codeDictionary(classCode, objCode, objDesc)	--系统使用单位名称
values(1, 2, '武汉大学')

--2：设备现状码：
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 2, '设备现状码', '高等学校仪器设备管理基本信息集', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 1, '在用', 1, '1')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 2, '多余', 1, '2')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 3, '待修', 1, '3')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 4, '待报废', 1, '4')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 5, '丢失', 1, '5')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 6, '报废', 1, '6')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 7, '调出', 1, '7')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 8, '降档', 1, '8')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 9, '其他', 1, '9')

--3：币种代码：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 3, '币种代码', '中国海关总署标准')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 110, '港币', '110','HKD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 113, '伊朗里亚尔', '113','IRR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 116, '日本元', '116','JPY')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 118, '科威特第纳尔', '118','KWD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 121, '澳门元', '121','MOP')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 122, '马来西亚林吉特', '122','MYR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 127, '巴基斯坦卢比', '127','PKR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 129, '菲律宾比索', '129','PHP')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 132, '新加坡元', '132','SGD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 136, '泰国铢', '136','THB')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 142, '人民币', '142','CNY')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 143, '台币', '143','TWD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 300, '欧元', '300','EUR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 302, '丹麦克朗', '302','DKK')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 303, '英镑', '303','GBP')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 326, '挪威克朗', '326','NOK')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 330, '瑞典克朗', '330','SEK')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 331, '瑞士法郎', '331','CHF')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 332, '苏联卢布', '332','SUR')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 398, '清算瑞士法郎', '398','ASF')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 501, '加拿大元', '501','CAD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 502, '美元', '502','USD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 601, '澳大利亚元', '601','AUD')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(3, 602, '新西兰元', '602','NZD')

--4：付款方式：
select * from codeDictionary where classCode = 4
delete codeDictionary where classCode = 4
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 4, '付款方式', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(4, 1, '货到付款', '','')
--货前付款方式从10开始
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(4, 10, '分期付款', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(4, 12, '全额垫付', '','')

--5：附件类型：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 5, '附件类型', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 1, '进口设备供货及技术服务协议', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 2, '外贸合同', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 3, '委托代理进口协议', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 4, '报关单', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 5, '免表', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 6, '机电证', '','')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode,GBEngCode)
values(5, 7, '其他附件', '','')

--98.系统数据（系统权限，系统资源）颗粒度代码：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 98, '（系统权限，系统资源）颗粒度代码', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 1, '本人')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 4, '本单位')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 8, '全校')

--99.系统数据对象操作分类
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 99, '系统数据对象操作分类', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 1, '查询类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 2, '编辑类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 3, '导出类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 4, '审计类操作')

--100：角色分级类型：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 100, '角色分级类型', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 1, '学校设备处外贸采购主管')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 2, '通用的最终用户角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 10, '通用的外贸公司管理员角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 11, '通用的外贸公司员工角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 20, '通用的供货单位管理员角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 21, '通用的供货单位员工角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 30, '特定院部的最终用户角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 31, '特定外贸公司的员工角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 32, '特定供货单位的员工角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 100, '通用的海关监管员角色')

--101：系统用户类别：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 101, '系统用户类别', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 1, '学校员工')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 2, '供货单位员工')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 3, '外贸公司员工')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 4, '其他授权用户')
insert codeDictionary(classCode, objCode, objDesc)
values(101, 9, '游客')


update codeDictionary
set inputCode = upper(dbo.getChinaPYCode(objDesc))



select * from codeDictionary where classCode=0 and objCode=3


