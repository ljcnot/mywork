---�ڲ����
USE master;
GO
ALTER DATABASE BookStore
      SET ENABLE_BROKER;
GO
USE BookStore;
GO

--������Ϣ����:
CREATE MESSAGE TYPE [RequestMessage] VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [ReplyMessage] VALIDATION = WELL_FORMED_XML;
GO


--����Լ��:
CREATE CONTRACT [SampleContract]
      ([RequestMessage]
       SENT BY INITIATOR,
       [ReplyMessage]
       SENT BY TARGET
      );
GO



--����Ŀ����кͷ���:
CREATE QUEUE TargetQueueIntAct;

CREATE SERVICE
       [TargetService]
       ON QUEUE TargetQueueIntAct
          ([SampleContract]);
GO



--�������𷽶��кͷ���:
CREATE QUEUE InitiatorQueueIntAct;

CREATE SERVICE
       [InitiatorService]
       ON QUEUE InitiatorQueueIntAct;
GO



--�����ڲ�����洢����:
alter PROCEDURE TargetActivProc
AS
  DECLARE @RecvReqDlgHandle UNIQUEIDENTIFIER;
  DECLARE @RecvReqMsg NVARCHAR(300);
  DECLARE @RecvReqMsgName sysname;

  WHILE (1=1)
  BEGIN

    BEGIN TRANSACTION;

    WAITFOR
    ( RECEIVE TOP(1)
        @RecvReqDlgHandle = conversation_handle,
        @RecvReqMsg = message_body,
        @RecvReqMsgName = message_type_name
      FROM TargetQueueIntAct
    ), TIMEOUT 5000;

    IF (@@ROWCOUNT = 0)
    BEGIN
      ROLLBACK TRANSACTION;
      BREAK;
    END

    IF @RecvReqMsgName = N'RequestMessage'
    BEGIN
       DECLARE @ReplyMsg NVARCHAR(300);
       SELECT @ReplyMsg = N'<ReplyMsg>���Ѿ����յ��������:'+@RecvReqMsg+'</ReplyMsg>';
 
       SEND ON CONVERSATION @RecvReqDlgHandle
              MESSAGE TYPE 
              [ReplyMessage]
              (@ReplyMsg);

		insert test(a)
		values('body:'+left(@RecvReqMsg,40))
    END
    ELSE IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
       END CONVERSATION @RecvReqDlgHandle;
    END
    ELSE IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN
       END CONVERSATION @RecvReqDlgHandle;
    END
      
    COMMIT TRANSACTION;
  END
GO

--����Ŀ�������ָ���ڲ�����:
ALTER QUEUE TargetQueueIntAct
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = TargetActivProc,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO


--�����Ự������������Ϣ:
DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
DECLARE @RequestMsg NVARCHAR(300);

BEGIN TRANSACTION;

BEGIN DIALOG @InitDlgHandle
     FROM SERVICE [InitiatorService]
     TO SERVICE N'TargetService'
     ON CONTRACT [SampleContract]
     WITH ENCRYPTION = OFF;

-- Send a message on the conversation
SELECT @RequestMsg =N'<Msg>'+
						'<oprType>Exec makeCReport</oprType>'+
						'<para>'+
							'<theTitle>���Ա���</theTitle>'+
							'<theYear>2011</theYear>'+
							'<totalEndDate>2011-12-31</totalEndDate>'+
							'<makeUnit>�人��ѧ</makeUnit>'+
							'<makerID>00000015</makerID>'+
						'</para>'+
						--'<Msg>����ִ�д������makeCReport��</Msg>'+
					'</Msg>';

SEND ON CONVERSATION @InitDlgHandle
     MESSAGE TYPE 
     [RequestMessage]
     (@RequestMsg);

-- Diplay sent request.
SELECT @RequestMsg AS SentRequestMsg;

COMMIT TRANSACTION;
GO

--�������
select * from test
delete test

--���մ𸴲������Ự��
DECLARE @RecvReplyMsg NVARCHAR(300);
DECLARE @RecvReplyDlgHandle UNIQUEIDENTIFIER;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @RecvReplyDlgHandle = conversation_handle,
    @RecvReplyMsg = message_body
    FROM InitiatorQueueIntAct
), TIMEOUT 8000;

END CONVERSATION @RecvReplyDlgHandle;

-- Display recieved request.
SELECT @RecvReplyMsg AS ReceivedReplyMsg;

COMMIT TRANSACTION;
GO


--ɾ���Ự����
IF EXISTS (SELECT * FROM sys.objects
           WHERE name = N'TargetActivProc')
     DROP PROCEDURE TargetActivProc;

IF EXISTS (SELECT * FROM sys.services
           WHERE name = N'TargetService')
     DROP SERVICE [TargetService];

IF EXISTS (SELECT * FROM sys.service_queues
           WHERE name = N'TargetQueueIntAct')
     DROP QUEUE TargetQueueIntAct;

-- Drop the intitator queue and service if they already exist.
IF EXISTS (SELECT * FROM sys.services
           WHERE name = N'InitiatorService')
     DROP SERVICE [InitiatorService];

IF EXISTS (SELECT * FROM sys.service_queues
           WHERE name = N'InitiatorQueueIntAct')
     DROP QUEUE InitiatorQueueIntAct;

-- Drop contract and message type if they already exist.
IF EXISTS (SELECT * FROM sys.service_contracts
           WHERE name = N'SampleContract')
     DROP CONTRACT [SampleContract];

IF EXISTS (SELECT * FROM sys.service_message_types
           WHERE name = N'RequestMessage')
     DROP MESSAGE TYPE [RequestMessage];

IF EXISTS (SELECT * FROM sys.service_message_types
           WHERE name = N'ReplyMessage')
     DROP MESSAGE TYPE [ReplyMessage];





--��һ�����������ݿ��Service Broker�
-- Enabling Databases for Service Broker Activity

USE master
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name ='BookStore')
CREATE DATABASE BookStore
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name ='BookDistribution')
CREATE DATABASE BookDistribution
GO
ALTER DATABASE BookStore SET ENABLE_BROKER
GO
ALTER DATABASE BookStore SET TRUSTWORTHY ON
GO
ALTER DATABASE BookDistribution SET ENABLE_BROKER
GO
ALTER DATABASE BookDistribution SET TRUSTWORTHY ON


--���������������ݿ�����Կ
-- Creating the DatabaseMaster Key for Encryption

USE BookStore
GO
CREATE MASTER KEY
ENCRYPTION BY PASSWORD ='I5Q7w1d3'
GO

USE BookDistribution
GO
CREATE MASTER KEY
ENCRYPTION BY PASSWORD ='D1J3q5z8X6y4'
GO

--��������������Ϣ����
-- Managing Message Types

Use BookStore
GO
-- ����ͼ�鶩������Ϣ����
CREATE MESSAGE TYPE [//SackConsulting/SendBookOrder]
VALIDATION = WELL_FORMED_XML
GO

--Ŀ�����ݿⷢ�͵���Ϣ����
CREATE MESSAGE TYPE [//SackConsulting/BookOrderReceived]
VALIDATION = WELL_FORMED_XML
GO

--ִ��ͬ���Ķ���
Use BookDistribution
GO
-- ����ͼ�鶩������Ϣ����
CREATE MESSAGE TYPE [//SackConsulting/SendBookOrder]
VALIDATION = WELL_FORMED_XML
GO

--Ŀ�����ݿⷢ�͵���Ϣ����
CREATE MESSAGE TYPE [//SackConsulting/BookOrderReceived]
VALIDATION = WELL_FORMED_XML
GO

--���ģ���������Լ��Contract��
-- Creating Contracts

Use BookStore
GO
CREATE CONTRACT
[//SackConsulting/BookOrderContract]
( [//SackConsulting/SendBookOrder]
SENT BY INITIATOR,
[//SackConsulting/BookOrderReceived]
SENT BY TARGET
)
GO

USE BookDistribution
GO
CREATE CONTRACT
[//SackConsulting/BookOrderContract]
( [//SackConsulting/SendBookOrder]
SENT BY INITIATOR,
[//SackConsulting/BookOrderReceived]
SENT BY TARGET
)
GO

--���壩����������
-- Creating Queues

Use BookStore
GO
--����BookDistribution��������Ϣ
CREATE QUEUE BookStoreQueue
WITH STATUS=ON
GO

USE BookDistribution
GO
--����BookStore��������Ϣ
CREATE QUEUE BookDistributionQueue
WITH STATUS=ON
GO

--����������������
-- Creating Services

Use BookStore
GO
CREATE SERVICE [//SackConsulting/BookOrderService]
ON QUEUE dbo.BookStoreQueue--ָ���Ķ��а󶨵���Լ
([//SackConsulting/BookOrderContract])
GO

USE BookDistribution
GO
CREATE SERVICE [//SackConsulting/BookDistributionService]
ON QUEUE dbo.BookDistributionQueue--ָ���Ķ��а󶨵���Լ
([//SackConsulting/BookOrderContract])
GO

--���ߣ��������Ի�
-- Initiating a Dialog

Use BookStore
GO

--����Ự����Ͷ�����Ϣ
DECLARE @Conv_Handler uniqueidentifier
DECLARE @OrderMsg xml;

BEGIN DIALOG CONVERSATION @Conv_Handler--�����Ự
FROM SERVICE [//SackConsulting/BookOrderService]
TO SERVICE '//SackConsulting/BookDistributionService'
ON CONTRACT [//SackConsulting/BookOrderContract];
SET @OrderMsg='<order id="3439" customer="22" orderdate="2/15/2011">
<LineItem ItemNumber="1" ISBN="1-59059-592-0" Quantity="1" />
</order>';
SEND ON CONVERSATION @Conv_Handler--���͵�BookDistribution���ݿ�Ķ�����
MESSAGE TYPE [//SackConsulting/SendBookOrder]
(@OrderMsg);

--���ˣ�����ѯ�����д������Ϣ
-- Querying the Queue for IncomingMessages

USE BookDistribution
GO
SELECT message_type_name, CAST(message_body as xml) message,
queuing_order, conversation_handle, conversation_group_id
FROM dbo.BookDistributionQueue

--���ţ�����������Ӧ��Ϣ
-- Receiving and Responding to aMessage

USE BookDistribution
GO
--����һ�����Ž��յ��Ķ�����Ϣ
CREATE TABLE dbo.BookOrderReceived
(
	BookOrderReceivedID int IDENTITY(1,1) NOT NULL,
	conversation_handle uniqueidentifier NOT NULL,
	conversation_group_id uniqueidentifier NOT NULL,
	message_body xml NOT NULL
)
GO

-- ��������
DECLARE @Conv_Handler uniqueidentifier
DECLARE @Conv_Group uniqueidentifier
DECLARE @OrderMsg xml
DECLARE @TextResponseMsg varchar(8000)
DECLARE @ResponseMsg xml
DECLARE @OrderID int;

--�Ӷ����л�ȡ��Ϣ��������ֵ���ھֲ�����
RECEIVE TOP(1) @OrderMsg= message_body,--TOPָ�����һ����Ϣ
@Conv_Handler= conversation_handle,
@Conv_Group= conversation_group_id
FROM dbo.BookDistributionQueue;

-- ������ֵ�������
INSERT dbo.BookOrderReceived(conversation_handle, conversation_group_id, message_body)
VALUES(@Conv_Handler,@Conv_Group, @OrderMsg )

-- ʹ��XQuery���г�ȡ����Ӧ��Ϣ����
SELECT @OrderID=@OrderMsg.value('(/order/@id)[1]', 'int' )
SELECT @TextResponseMsg=
'<orderreceived id= "'+
CAST(@OrderID as varchar(10)) +
'"/>';
SELECT @ResponseMsg=CAST(@TextResponseMsg as xml);

-- ʹ�ü��еĻỰ�����������Ӧ��Ϣ������
SEND ON CONVERSATION @Conv_Handler
MESSAGE TYPE [//SackConsulting/BookOrderReceived] 
(@OrderMsg)

--��ʮ���������Ự
-- Ending a Conversation

USE BookStore
GO
-- ��������ȷ�ϱ�
CREATE TABLE dbo.BookOrderConfirmation
(
	BookOrderConfirmationID int IDENTITY (1,1) NOT NULL,
	conversation_handle uniqueidentifier NOT NULL,
	DateReceived datetime NOT NULL DEFAULT(GETDATE()),
	message_body xml NOT NULL
)

DECLARE @Conv_Handler uniqueidentifier
DECLARE @Conv_Group uniqueidentifier
DECLARE @OrderMsg xml
DECLARE @TextResponseMsg varchar(8000);

RECEIVE TOP(1) @Conv_Handler= conversation_handle,
@OrderMsg= message_body
FROM dbo.BookStoreQueue

INSERT dbo.BookOrderConfirmation
(conversation_handle, message_body)
VALUES (@Conv_Handler,@OrderMsg );

END CONVERSATION @Conv_Handler;
GO

USE BookDistribution
GO
DECLARE @Conv_Handler uniqueidentifier
DECLARE @Conv_Group uniqueidentifier
DECLARE @OrderMsg xml
DECLARE @message_type_name nvarchar(256);

RECEIVE TOP(1) @Conv_Handler= conversation_handle,
@OrderMsg= message_body,
@message_type_name= message_type_name
FROM dbo.BookDistributionQueue

-- ˫�����붼�����Ự
IF
@message_type_name='http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
BEGIN
END CONVERSATION @Conv_Handler;
END
