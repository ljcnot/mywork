---内部激活：
USE master;
GO
ALTER DATABASE BookStore
      SET ENABLE_BROKER;
GO
USE BookStore;
GO

--创建消息类型:
CREATE MESSAGE TYPE [RequestMessage] VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [ReplyMessage] VALIDATION = WELL_FORMED_XML;
GO


--创建约定:
CREATE CONTRACT [SampleContract]
      ([RequestMessage]
       SENT BY INITIATOR,
       [ReplyMessage]
       SENT BY TARGET
      );
GO



--创建目标队列和服务:
CREATE QUEUE TargetQueueIntAct;

CREATE SERVICE
       [TargetService]
       ON QUEUE TargetQueueIntAct
          ([SampleContract]);
GO



--创建发起方队列和服务:
CREATE QUEUE InitiatorQueueIntAct;

CREATE SERVICE
       [InitiatorService]
       ON QUEUE InitiatorQueueIntAct;
GO



--创建内部激活存储过程:
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
       SELECT @ReplyMsg = N'<ReplyMsg>我已经接收到你的请求:'+@RecvReqMsg+'</ReplyMsg>';
 
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

--更改目标队列以指定内部激活:
ALTER QUEUE TargetQueueIntAct
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = TargetActivProc,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO


--启动会话并发送请求消息:
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
							'<theTitle>测试报表</theTitle>'+
							'<theYear>2011</theYear>'+
							'<totalEndDate>2011-12-31</totalEndDate>'+
							'<makeUnit>武汉大学</makeUnit>'+
							'<makerID>00000015</makerID>'+
						'</para>'+
						--'<Msg>请求执行储存过程makeCReport！</Msg>'+
					'</Msg>';

SEND ON CONVERSATION @InitDlgHandle
     MESSAGE TYPE 
     [RequestMessage]
     (@RequestMsg);

-- Diplay sent request.
SELECT @RequestMsg AS SentRequestMsg;

COMMIT TRANSACTION;
GO

--检查结果：
select * from test
delete test

--接收答复并结束会话：
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


--删除会话对象：
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





--（一）、启用数据库的Service Broker活动
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


--（二）、创建数据库主密钥
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

--（三）、管理消息类型
-- Managing Message Types

Use BookStore
GO
-- 发送图书订单的消息类型
CREATE MESSAGE TYPE [//SackConsulting/SendBookOrder]
VALIDATION = WELL_FORMED_XML
GO

--目标数据库发送的消息类型
CREATE MESSAGE TYPE [//SackConsulting/BookOrderReceived]
VALIDATION = WELL_FORMED_XML
GO

--执行同样的定义
Use BookDistribution
GO
-- 发送图书订单的消息类型
CREATE MESSAGE TYPE [//SackConsulting/SendBookOrder]
VALIDATION = WELL_FORMED_XML
GO

--目标数据库发送的消息类型
CREATE MESSAGE TYPE [//SackConsulting/BookOrderReceived]
VALIDATION = WELL_FORMED_XML
GO

--（四）、创建契约（Contract）
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

--（五）、创建队列
-- Creating Queues

Use BookStore
GO
--保存BookDistribution过来的消息
CREATE QUEUE BookStoreQueue
WITH STATUS=ON
GO

USE BookDistribution
GO
--保存BookStore过来的消息
CREATE QUEUE BookDistributionQueue
WITH STATUS=ON
GO

--（六）、创建服务
-- Creating Services

Use BookStore
GO
CREATE SERVICE [//SackConsulting/BookOrderService]
ON QUEUE dbo.BookStoreQueue--指定的队列绑定到契约
([//SackConsulting/BookOrderContract])
GO

USE BookDistribution
GO
CREATE SERVICE [//SackConsulting/BookDistributionService]
ON QUEUE dbo.BookDistributionQueue--指定的队列绑定到契约
([//SackConsulting/BookOrderContract])
GO

--（七）、启动对话
-- Initiating a Dialog

Use BookStore
GO

--保存会话句柄和订单信息
DECLARE @Conv_Handler uniqueidentifier
DECLARE @OrderMsg xml;

BEGIN DIALOG CONVERSATION @Conv_Handler--创建会话
FROM SERVICE [//SackConsulting/BookOrderService]
TO SERVICE '//SackConsulting/BookDistributionService'
ON CONTRACT [//SackConsulting/BookOrderContract];
SET @OrderMsg='<order id="3439" customer="22" orderdate="2/15/2011">
<LineItem ItemNumber="1" ISBN="1-59059-592-0" Quantity="1" />
</order>';
SEND ON CONVERSATION @Conv_Handler--发送到BookDistribution数据库的队列中
MESSAGE TYPE [//SackConsulting/SendBookOrder]
(@OrderMsg);

--（八）、查询队列中传入的消息
-- Querying the Queue for IncomingMessages

USE BookDistribution
GO
SELECT message_type_name, CAST(message_body as xml) message,
queuing_order, conversation_handle, conversation_group_id
FROM dbo.BookDistributionQueue

--（九）、检索并响应消息
-- Receiving and Responding to aMessage

USE BookDistribution
GO
--创建一个表存放接收到的订单信息
CREATE TABLE dbo.BookOrderReceived
(
	BookOrderReceivedID int IDENTITY(1,1) NOT NULL,
	conversation_handle uniqueidentifier NOT NULL,
	conversation_group_id uniqueidentifier NOT NULL,
	message_body xml NOT NULL
)
GO

-- 声明变量
DECLARE @Conv_Handler uniqueidentifier
DECLARE @Conv_Group uniqueidentifier
DECLARE @OrderMsg xml
DECLARE @TextResponseMsg varchar(8000)
DECLARE @ResponseMsg xml
DECLARE @OrderID int;

--从队列中获取消息，将接收值赋于局部变量
RECEIVE TOP(1) @OrderMsg= message_body,--TOP指定最多一条消息
@Conv_Handler= conversation_handle,
@Conv_Group= conversation_group_id
FROM dbo.BookDistributionQueue;

-- 将变量值插入表中
INSERT dbo.BookOrderReceived(conversation_handle, conversation_group_id, message_body)
VALUES(@Conv_Handler,@Conv_Group, @OrderMsg )

-- 使用XQuery进行抽取以响应消息订单
SELECT @OrderID=@OrderMsg.value('(/order/@id)[1]', 'int' )
SELECT @TextResponseMsg=
'<orderreceived id= "'+
CAST(@OrderID as varchar(10)) +
'"/>';
SELECT @ResponseMsg=CAST(@TextResponseMsg as xml);

-- 使用既有的会话句柄，发送响应消息到发起方
SEND ON CONVERSATION @Conv_Handler
MESSAGE TYPE [//SackConsulting/BookOrderReceived] 
(@OrderMsg)

--（十）、结束会话
-- Ending a Conversation

USE BookStore
GO
-- 创建订单确认表
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

-- 双方必须都结束会话
IF
@message_type_name='http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
BEGIN
END CONVERSATION @Conv_Handler;
END
