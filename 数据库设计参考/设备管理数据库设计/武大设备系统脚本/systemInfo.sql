use epdc211
/*
	�豸����ϵͳ-ϵͳ������־����
	ע����OAϵͳ����ֲ
	author:		¬έ
	CreateDate:	2013-3-24
	UpdateDate: 
*/
--1.ϵͳ������־��
drop table systemInfo
CREATE TABLE systemInfo(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	logTime smalldatetime,				--��־ʱ��
	logInfo nvarchar(500) null,			--��־����
 CONSTRAINT [PK_systemInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE addSystemInfo
/*
	name:		addSystemInfo
	function:	1.���ϵͳ������־
	input: 
				@logInfo nvarchar(500)			--��־����
	output: 
	author:		¬έ
	CreateDate:	2013-03-24
	UpdateDate: 
*/
create PROCEDURE addSystemInfo
	@logInfo nvarchar(500)			--��־����
	WITH ENCRYPTION 
AS
	insert systemInfo(logTime, logInfo)
	values(GETDATE(), @logInfo)
GO

select * from systemInfo