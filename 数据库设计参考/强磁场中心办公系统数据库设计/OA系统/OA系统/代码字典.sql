use hustOA
/*
	强磁场中心办公系统-代码字典数据库设计
	根据会员卡频道系统修改
	author:		卢苇
	CreateDate:	2010-7-11
	UpdateDate: 修改图片保存方式，修改维护信息字段modi by lw 2013-1-1
*/
--truncate table codeDictionary
--	代码字典表（codeDictionary）：
drop table codeDictionary
CREATE TABLE codeDictionary (
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	classCode int NOT NULL ,	--分类编码
	objCode int NOT NULL ,		--代码（条目编码） 计划：modi by lw 2010-3-30 由smallint 改为 int
	objDesc nvarchar(100) NULL,	--条目描述
	inputCode varchar(6) null,	--输入码
	objEngDesc varchar(100) NULL,--条目英文描述	
	objDetail nvarchar(500) NULL,--条目详细解释
	standardName nvarchar(100),	--引用标准名
	GBDigiCode varchar(10) null,--国标数字代码
	GBEngCode varchar(10) null,	--国标字母代码
	cdImage varchar(128) null,	--代码字典图片路径

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
-----以下存储过程废止，因为现在改用图片文件存放！-------------------------------------------------
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
--1.代码字典(codeDictionary)：
	--class = 0	描述字典类型：
select * from codeDictionary where classCode = 0

--1：系统参数代码表：
select * from codeDictionary where classCode = 0 and objCode = 1
select * from codeDictionary where classCode = 1
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 1, '单位基本信息', '', '')
insert codeDictionary(classCode, objCode, objDesc)	--单位代码
values(1, 1, '001')
insert codeDictionary(classCode, objCode, objDesc)	--单位名称
values(1, 2, '脉冲强磁场科学中心')
insert codeDictionary(classCode, objCode, objDesc)	--是否使用短信平台
values(1, 3, 'Y')
insert codeDictionary(classCode, objCode, objDesc)	--是否使用消息平台
values(1, 4, 'Y')
insert codeDictionary(classCode, objCode, objDesc)	--付费模式：1->后付费模式，2->预付费模式
values(1, 5, '1')
insert codeDictionary(classCode, objCode, objDesc)	--短信单价
values(1, 6, '0.06')

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
select * from codeDictionary where classCode = 3
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode, GBEngCode)
select classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode, GBEngCode
from fTradeDB.dbo.codeDictionary where classCode = 0 and objCode = 3

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode, GBEngCode)
select classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode, GBEngCode
from fTradeDB.dbo.codeDictionary where classCode = 3

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

--与财政部报表相关的字典:
--11.取得方式
select * from codeDictionary where classCode = 11
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 11, '设备取得方式', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 1, '购置')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 2, '调拨')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 3, '自建')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 4, '捐赠')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 5, '划拨')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 6, '置换')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 7, '自创')
insert codeDictionary(classCode, objCode, objDesc)
values(11, 8, '其他')


--12.使用状况
select * from codeDictionary where classCode = 12
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 12, '房屋取得方式', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(12, 1, '在用')
insert codeDictionary(classCode, objCode, objDesc)
values(12, 2, '未使用')
insert codeDictionary(classCode, objCode, objDesc)
values(12, 3, '不需用')
insert codeDictionary(classCode, objCode, objDesc)
values(12, 4, '危房不能用')
insert codeDictionary(classCode, objCode, objDesc)
values(12, 5, '毁坏不能用')
insert codeDictionary(classCode, objCode, objDesc)
values(12, 6, '待报废')
insert codeDictionary(classCode, objCode, objDesc)
values(12, 7, '其他')

--13.产权形式
select * from codeDictionary where classCode = 13
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 13, '产权形式', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(13, 1, '有产权')
insert codeDictionary(classCode, objCode, objDesc)
values(13, 2, '无产权')

--14.编制情况
select * from codeDictionary where classCode = 14
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 14, '编制情况', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(14, 1, '财政在编')
insert codeDictionary(classCode, objCode, objDesc)
values(14, 2, '非财政在编')

--15.资产使用方向
select * from codeDictionary where classCode = 15
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 15, '资产使用方向', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(15, 1, '自用')
insert codeDictionary(classCode, objCode, objDesc)
values(15, 2, '经营')
insert codeDictionary(classCode, objCode, objDesc)
values(15, 3, '出借')
insert codeDictionary(classCode, objCode, objDesc)
values(15, 4, '出租')
insert codeDictionary(classCode, objCode, objDesc)
values(15, 5, '闲置')	--该代码已经废弃!
insert codeDictionary(classCode, objCode, objDesc)
values(15, 6, '对外投资')
insert codeDictionary(classCode, objCode, objDesc)
values(15, 7, '担保')
insert codeDictionary(classCode, objCode, objDesc)
values(15, 8, '其他')

--18.采购组织形式
select * from codeDictionary where classCode = 18
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 18, '采购组织形式', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(18, 1, '政府集中机构采购')
insert codeDictionary(classCode, objCode, objDesc)
values(18, 2, '部门集中采购')
insert codeDictionary(classCode, objCode, objDesc)
values(18, 3, '分散采购')
insert codeDictionary(classCode, objCode, objDesc)
values(18, 4, '其他')


--车辆扩展信息代码字典：
--20.车辆产地
select * from codeDictionary where classCode = 20
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 20, '车辆产地', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(20, 1, '进口')
insert codeDictionary(classCode, objCode, objDesc)
values(20, 2, '国产(含组装)')

--21.车辆用途：
select * from codeDictionary where classCode = 21
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 21, '车辆用途', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(21, 1, '领导用车')
insert codeDictionary(classCode, objCode, objDesc)
values(21, 2, '公务用车')
insert codeDictionary(classCode, objCode, objDesc)
values(21, 3, '专业用车')
insert codeDictionary(classCode, objCode, objDesc)
values(21, 4, '生活用车')
insert codeDictionary(classCode, objCode, objDesc)
values(21, 5, '接待用车')
insert codeDictionary(classCode, objCode, objDesc)
values(21, 6, '其他用车')

--50.期刊性质：
select * from codeDictionary where classCode = 50
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 50, '期刊性质', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(50, 1, 'SCI')
insert codeDictionary(classCode, objCode, objDesc)
values(50, 2, 'EI')
insert codeDictionary(classCode, objCode, objDesc)
values(50, 3, 'ISTP')
insert codeDictionary(classCode, objCode, objDesc)
values(50, 4, 'SCIE')
insert codeDictionary(classCode, objCode, objDesc)
values(50, 5, 'A&HCI')
insert codeDictionary(classCode, objCode, objDesc)
values(50, 6, 'SSCI')
insert codeDictionary(classCode, objCode, objDesc)
values(50, 7, 'CSSCI')

--51.期刊类别：
select * from codeDictionary where classCode = 51
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 51, '期刊类别', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(51, 1, 'TOP1期刊')
insert codeDictionary(classCode, objCode, objDesc)
values(51, 2, 'TOP2期刊')
insert codeDictionary(classCode, objCode, objDesc)
values(51, 3, 'A类期刊')

--52.论文类别：
select * from codeDictionary where classCode = 52
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 52, '论文类别', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(52, 1, '国外论文')
insert codeDictionary(classCode, objCode, objDesc)
values(52, 2, '国内论文')
insert codeDictionary(classCode, objCode, objDesc)
values(52, 3, '国际会议论文')
insert codeDictionary(classCode, objCode, objDesc)
values(52, 4, '国内会议论文')
insert codeDictionary(classCode, objCode, objDesc)
values(52, 5, '国家自然科学基金资助论文')
insert codeDictionary(classCode, objCode, objDesc)
values(52, 6, '中国电机工程学会论文')

--53.专著类别：
select * from codeDictionary where classCode = 53
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 53, '专著类别', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(53, 1, '专著')
insert codeDictionary(classCode, objCode, objDesc)
values(53, 2, '教材')
insert codeDictionary(classCode, objCode, objDesc)
values(53, 3, '译著')
insert codeDictionary(classCode, objCode, objDesc)
values(53, 4, '科普著作')
insert codeDictionary(classCode, objCode, objDesc)
values(53, 5, '工具参考书')

--54.专利类型：
select * from codeDictionary where classCode = 54
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values (0, 54, '专利类型', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(54, 1, '发明')
insert codeDictionary(classCode, objCode, objDesc)
values(54, 2, '实用新型')
insert codeDictionary(classCode, objCode, objDesc)
values(54, 3, '外观设计')


--55.科研项目性质：
select * from codeDictionary where classCode = 55
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values (0, 55, '科研项目性质', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(55, 1, '重点实验室开放基金')
insert codeDictionary(classCode, objCode, objDesc)
values(55, 2, '武汉市科技攻关重点项目')
insert codeDictionary(classCode, objCode, objDesc)
values(55, 3, '湖北省农业科技成果转化资金项目')
insert codeDictionary(classCode, objCode, objDesc)
values(55, 4, '湖北省自然科学基金')
insert codeDictionary(classCode, objCode, objDesc)
values(55, 5, '湖北省自然科学基金（杰出人才） ')
insert codeDictionary(classCode, objCode, objDesc)
values(55, 6, '企事业委托')

--56.科研项目类型：
select * from codeDictionary where classCode = 56
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values (0, 56, '项目类型', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(56, 1, '基础研究')
insert codeDictionary(classCode, objCode, objDesc)
values(56, 2, '应用研究')
insert codeDictionary(classCode, objCode, objDesc)
values(56, 3, '试验发展')
insert codeDictionary(classCode, objCode, objDesc)
values(56, 4, 'R&D成果应用')
insert codeDictionary(classCode, objCode, objDesc)
values(56, 5, '科技服务')

--57.保密级别：
select * from codeDictionary where classCode = 57
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values (0, 57, '保密级别', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(57, 1, '非密')
insert codeDictionary(classCode, objCode, objDesc)
values(57, 2, '秘密')
insert codeDictionary(classCode, objCode, objDesc)
values(57, 3, '机密')
insert codeDictionary(classCode, objCode, objDesc)
values(57, 4, '绝密')

--58.委托单位性质：
select * from codeDictionary where classCode = 58
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values (0, 58, '委托单位性质', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 1, '国有企业')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 2, '集体企业')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 3, '私营企业')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 4, '有限责任公司')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 5, '股份有限公司')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 6, '港澳台商投资企业')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 7, '外资投资企业')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 8, '科研机构')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 9, '各级管理部门')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 10, '技术贸易机构')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 11, '个体经营')
insert codeDictionary(classCode, objCode, objDesc)
values(58, 99, '其他')

use hustOA
select * from codeDictionary where classCode = 99
delete codeDictionary where classCode = 99
--98.系统数据（系统权限，系统资源）颗粒度代码：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 98, '（系统权限，系统资源）颗粒度代码', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 1, '本人')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 2, '本部门')
insert codeDictionary(classCode, objCode, objDesc)
values(98, 4, '全中心')

--99.系统数据对象操作分类
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 99, '系统数据对象操作分类', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 1, '查询类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 2, '编辑类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 3, '审计类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 4, '导出类操作')

--100：角色分级类型：
select * from codeDictionary where classCode = 100
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 100, '角色分级类型', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 1, '通用的中心级角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 3, '通用的部门角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 5, '隶属于特定部门的角色')


--200：勤务状态：
select * from codeDictionary where classCode = 200
delete codeDictionary where classCode = 200
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 200, '勤务状态', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(200, 1, '在岗')	--不能由用户直接设定，默认状态就是在岗
insert codeDictionary(classCode, objCode, objDesc)
values(200, 2, '请假')	--不能由用户直接设定，要使用请假条
insert codeDictionary(classCode, objCode, objDesc)
values(200, 3, '外地出差')
insert codeDictionary(classCode, objCode, objDesc)
values(200, 4, '外出办事')
insert codeDictionary(classCode, objCode, objDesc)
values(200, 5, '外出开会')

--200~300人员属性的代码字典：
--国籍：引用国别数据库
--201性别：
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 201, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 3

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 201, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 3 

select * from codeDictionary where classCode = 201
select * from codeDictionary where classCode = 0
--202.民族
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 203, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 5

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 203, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 5

--宗教信仰：
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 209, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 19

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 209, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 19
--政治面貌
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 210, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 852

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 210, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 852

use hustOA
select * from codeDictionary where classCode = 211
--文化程度（简表）
--insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
--select classCode, 211, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
--from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 6
delete codeDictionary where classCode = 211
delete codeDictionary where classCode = 0 and objCode =211
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 211, '学历/学位', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(211, 10, '专科')
insert codeDictionary(classCode, objCode, objDesc)
values(211, 11, '本科')
insert codeDictionary(classCode, objCode, objDesc)
values(211, 12, '硕士')
insert codeDictionary(classCode, objCode, objDesc)
values(211, 13, '博士')
insert codeDictionary(classCode, objCode, objDesc)
values(211, 14, '博士后')
insert codeDictionary(classCode, objCode, objDesc)
values(211, 99, '其他')


--insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
--select 211, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
--from czMISbak.dbo.codeDictionary where classCode = 6
--文化程度（详表）
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 212, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 7

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 212, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 7

--婚姻状况
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 213, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 8

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 213, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 8
--健康状况（简表）
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 214, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 9

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 214, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 9
--健康状况（详表）
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 215, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 10

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 215, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 10
--职业类表（简表）
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 216, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 15

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 216, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 15
--职业类表（详表）
insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select classCode, 217, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 0 and objCode = 16

insert codeDictionary(classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode) 
select 217, objCode, objDesc, inputCode, objEngDesc, objDetail, standardName,GBDigiCode,GBEngCode
from czMISbak.dbo.codeDictionary where classCode = 16


--部门：引用部门代码字典
--岗位：暂时不使用代码字典
--218.职称
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 218, '职称', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(218, 1, '教授')
insert codeDictionary(classCode, objCode, objDesc)
values(218, 2, '副教授')
insert codeDictionary(classCode, objCode, objDesc)
values(218, 3, '讲师')

--250.密码保护问题：
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 250, '密码保护问题', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 1, '我就读的第一所学校的名称?')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 2, '我最喜欢的休闲运动是什么?')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 3, '我最喜欢的运动员是谁?')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 4, '我最喜欢的物品的名称?')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 5, '我最喜欢的歌曲')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 6, '我最喜欢的食物')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 7, '我最爱的人的名字')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 8, '我最爱的电影')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 9, '我妈妈的生日')
insert codeDictionary(classCode, objCode, objDesc)
values(250, 10, '我的初恋日期')
insert codeDictionary(classCode, objCode, objDesc)	--选择这个问题要求用户另行输入问题！
values(250, 99, '其他问题')

select * from czMISbak.dbo.codeDictionary where classCode = 0
select * from codeDictionary where classCode = 0

--900：教育部报表类型
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 900, '教育部报表类型', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 901, '教学科研仪器设备表')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 902, '教学科研仪器设备增减变动情况表')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 903, '贵重仪器设备表')

--901：财政部报表类型
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 901, '财政部报表类型', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 1, '土地')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 2, '房屋构筑物')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 3, '通用设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 4, '专用设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 5, '交通运输设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 6, '电气设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 7, '电子产品及通信设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 8, '仪器仪表及量具')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 9, '文艺体育设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 10, '图书文物及陈列品')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 11, '家具用具及其他类')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 12, '无形资产')


update codeDictionary
set inputCode = upper(dbo.getChinaPYCode(objDesc))
where ISNULL(inputCode,'')=''



use hustOA
select * from codeDictionary where classCode = 203





select rowNum, classCode, objCode, objDesc, inputCode, objEngDesc, objDetail, 
	standardName, GBDigiCode, GBEngCode, cdImage, isOff, offDate
from codeDictionary 
