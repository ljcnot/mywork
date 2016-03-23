use epdc211
/*
	设备管理系统-系统工作日志管理
	注：从OA系统中移植
	author:		卢苇
	CreateDate:	2013-3-24
	UpdateDate: 
*/
--1.系统工作日志：
drop table systemInfo
CREATE TABLE systemInfo(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	logTime smalldatetime,				--日志时间
	logInfo nvarchar(500) null,			--日志内容
 CONSTRAINT [PK_systemInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE addSystemInfo
/*
	name:		addSystemInfo
	function:	1.添加系统工作日志
	input: 
				@logInfo nvarchar(500)			--日志内容
	output: 
	author:		卢苇
	CreateDate:	2013-03-24
	UpdateDate: 
*/
create PROCEDURE addSystemInfo
	@logInfo nvarchar(500)			--日志内容
	WITH ENCRYPTION 
AS
	insert systemInfo(logTime, logInfo)
	values(GETDATE(), @logInfo)
GO

select * from systemInfo