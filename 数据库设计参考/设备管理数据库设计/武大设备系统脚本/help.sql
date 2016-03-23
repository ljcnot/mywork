/*
	����豸������Ϣϵͳ-�ɹ��ƻ������洢����
	author:		¬έ
	�����ݿ�ӳ��γ��������־־��õ�����Ϣϵͳ-����HELP�����ֲ
	CreateDate:	2011-1-23
	UpdateDate: 
*/
use epdc211


truncate table helper
select * from helper
drop table helper
CREATE TABLE [dbo].[helper](
	[indexNum] [int] NOT NULL,					--������
	[kindCode] [int] NOT NULL,					--�£����ࣩ
	[classCode] [int] NOT NULL,					--�ڣ����ࣩ
	[objCode] [int] NOT NULL,					--ҳ��
	[objTitle] [varchar](100) NOT NULL,			--����
	[keyDesc] [varchar](200) NOT NULL,			--�ؼ��֣��������¸�ʽ��ţ��ؼ���1,�ؼ���2,...�ؼ���n
	[pageDetail] NTEXT NOT NULL,					--HELPҳ���ļ���HTML)
 CONSTRAINT [PK_helper] PRIMARY KEY CLUSTERED 
(
	indexNum asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--������
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

--����ȫ��������
drop FULLTEXT INDEX ON helper
drop FULLTEXT CATALOG helpFulltext
drop INDEX helper.keyIndex

CREATE UNIQUE INDEX keyIndex ON helper(indexNum);
CREATE FULLTEXT CATALOG helpFulltext AS DEFAULT;
CREATE FULLTEXT INDEX ON helper(keyDesc) KEY INDEX keyIndex;

--����:
select * from helper
WHERE FREETEXT(keyDesc,'ϵͳĿ��')

select * from helper
WHERE CONTAINS(keyDesc,'ϵͳ����')


