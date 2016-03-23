/*
	武大设备管理信息系统-采购计划类表与存储过程
	author:		卢苇
	本数据库从长治城区公安分局警用地理信息系统-在线HELP设计移植
	CreateDate:	2011-1-23
	UpdateDate: 
*/
use epdc211


truncate table helper
select * from helper
drop table helper
CREATE TABLE [dbo].[helper](
	[indexNum] [int] NOT NULL,					--索引号
	[kindCode] [int] NOT NULL,					--章（门类）
	[classCode] [int] NOT NULL,					--节（中类）
	[objCode] [int] NOT NULL,					--页面
	[objTitle] [varchar](100) NOT NULL,			--标题
	[keyDesc] [varchar](200) NOT NULL,			--关键字，采用如下格式存放：关键字1,关键字2,...关键字n
	[pageDetail] NTEXT NOT NULL,					--HELP页面文件（HTML)
 CONSTRAINT [PK_helper] PRIMARY KEY CLUSTERED 
(
	indexNum asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_helper] ON [dbo].[helper] 
(
	[kindCode] ASC,                
	[classCode] ASC,
	[objCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_helper1] ON [dbo].[helper] 
(
	[keyDesc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

--创建全文索引：
drop FULLTEXT INDEX ON helper
drop FULLTEXT CATALOG helpFulltext
drop INDEX helper.keyIndex

CREATE UNIQUE INDEX keyIndex ON helper(indexNum);
CREATE FULLTEXT CATALOG helpFulltext AS DEFAULT;
CREATE FULLTEXT INDEX ON helper(keyDesc) KEY INDEX keyIndex;

--测试:
select * from helper
WHERE FREETEXT(keyDesc,'系统目的')

select * from helper
WHERE CONTAINS(keyDesc,'系统名称')


