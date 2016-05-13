--附件表   
drop table attachment 
create table attachment(
uidFilename varchar(128) not null,	--UID文件名
billType	 smallint default(0)	not	null,	--票据类型：0，借支单，1：报销单
billID	varchar(13)	not	null,	--票据编号
aFilename varchar(128) null,		--原始文件名
fileSize bigint null,				--文件尺寸
fileType varchar(10),				--文件类型
uploadTime smalldatetime default(getdate()),	--上传日期
fileLog varchar(128) null,			--文件log：如果没有没有定义，则使用默认的文件类型LOG
--主键
	 CONSTRAINT [PK_attachment] PRIMARY KEY CLUSTERED 
(
	uidFilename ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


--添加附件
drop PROCEDURE addAttachment
/*
	name:		addAttachment
	function:	1.添加附件
				注意：本存储过程不锁定编辑！
	input: 
				@uidFilename varchar(128),	--UID文件名
				@billType	 smallint,		--票据类型：0，借支单，1：报销单
				@billID	varchar(13),		--票据编号
				@aFilename varchar(128),	--原始文件名
				@fileSize bigint,			--文件尺寸
				@fileType varchar(10),		--文件类型
				@fileLog varchar(128),		--文件log：如果没有没有定义，则使用默认的文件类型LOG

				@createManID varchar(10),		--创建人工号

	output: 
				@Ret		int output,     --成功标识,0:成功,9:未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-5-13

*/

create PROCEDURE addAttachment			
				@uidFilename varchar(128),	--UID文件名
				@billType	 smallint,		--票据类型：0，借支单，1：报销单
				@billID	varchar(13),		--票据编号
				@aFilename varchar(128),	--原始文件名
				@fileSize bigint,			--文件尺寸
				@fileType varchar(10),		--文件类型
				@fileLog varchar(128),		--文件log：如果没有没有定义，则使用默认的文件类型LOG

				@createManID varchar(10),		--创建人工号

				@Ret		int output,     --成功标识,0:成功,9:未知错误
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @createTime = getdate()

	insert attachment(
				uidFilename,	--UID文件名
				billType	,	--票据类型：0，借支单，1：报销单
				billID,		--票据编号
				aFilename,	--原始文件名
				fileSize,	--文件尺寸
				fileType,	--文件类型
				fileLog		--文件log：如果没有没有定义，则使用默认的文件类型LOG
							) 
	values (		
				@uidFilename,	--UID文件名
				@billType	,	--票据类型：0，借支单，1：报销单
				@billID,		--票据编号
				@aFilename,	--原始文件名
				@fileSize,	--文件尺寸
				@fileType,	--文件类型
				@fileLog		--文件log：如果没有没有定义，则使用默认的文件类型LOG
				) 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加附件', '系统根据用户' + @createManName + 
		'的要求添加了附件[' + @uidFilename + ']。')		
GO


--删除附件
drop PROCEDURE delAttachment
/*
	name:		delAttachment
	function:	1.删除附件
				注意：本存储过程不锁定编辑！
	input: 
				@uidFilename varchar(128),		--UID文件名
				@lockManID varchar(10),		--锁定人工号
	output: 
				@Ret		int output		  --成功标示，0：成功，1：该附件不存在,9:未知错误
				@createTime smalldatetime output
	author:		卢嘉诚
	CreateDate:	2016-5-13
*/

create PROCEDURE delAttachment			
				@uidFilename varchar(128),		--UID文件名
				@lockManID varchar(10),		--锁定人工号

				@Ret		int output,			--成功标示，0：成功，1：该附件不存在,9:未知错误
				@createTime smalldatetime output

	WITH ENCRYPTION 
AS

	set @Ret = 9
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	set @createTime = getdate()
		
	--判断要删除的附件是否存在
	declare @count as int
	set @count=(select count(*) from attachment where uidFilename= @uidFilename)	
	if (@count = 0)	--不存在
		begin
			set @Ret = 1
			return
		end
	--删除附件
	delete FROM attachment where uidFilename= @uidFilename 


	if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @createManName, @createTime, '删除附件', '系统根据用户' + @createManName + 
		'的要求删除了附件[' + @uidFilename + ']。')		
GO
