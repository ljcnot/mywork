use hustOA
/*
	强磁场中心办公系统-消息管理
	修改说明：将原消息队列表限定为不管理即时通信消息，只处理重要的系统消息和与会议、学术报告相关联的消息，
	这些消息都需要系统做响应处理，并且有消息编号。
	另外创建即时通信消息和未发送即时消息表，该类消息没有消息编号！
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 
*/
--1.管理类消息队列表：
drop table messageInfo
CREATE TABLE messageInfo(
	messageID varchar(12) not null,		--主键：消息编号,本系统使用第11000号号码发生器产生（8位日期代码+4位流水号）
	messageClass int not null,			--消息类别：表示消息的来源与类别信息
										/*	0	服务器询问消息
											1	询问回答消息（注册） 
											2	服务器通知客户端验证结果消息
											3	会议通知消息
											4	会议回复消息
											5	学术报告通知消息
											6	学术报告回复消息
											7	讨论组成员对用户邀请消息
											8	用户对讨论组消息
											9	群主对用户的消息
											10	用户对群消息
											11	消息管理器出错信息
											99	即时通信消息（这类消息不在本列表中）
											100	服务器广播消息
										*/
	messageType nvarchar(30) null,		--消息类型
	messageLevel smallint default(1),	--重要级别：1~9，等级越高越重要，发送优先
	senderID varchar(10) not null,		--发送人工号
	sender nvarchar(30) not null,		--发送人
	sendTime datetime DEFAULT(GETDATE()),--发送时间:这是发送人将消息放入消息队列的时间
	isSend smallint default(0),			--是否发送：0->未发送，1->已发送
	isRead smallint default(0),			--是否阅读：0->未阅读，1->已阅读
	receiverType int not null,			--接收人类别：表示消息接收人的类别
										/*	0（服务器）
											1（用户）
											2（讨论组）
											3（群）
											4（会议）
											5（学术报告）
											9（所有用户）
											10（组织机构-院部）
											11（组织机构-部门）
										*/
	receiverID varchar(12) not null,	--接收人工号：modi by lw 2013-4-13修改字段长度
	receiver nvarchar(30) not null,		--接收人
	messageBody nvarchar(4000) null,	--消息内容
 CONSTRAINT [PK_messageInfo] PRIMARY KEY CLUSTERED 
(
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--发送时间索引：
CREATE NONCLUSTERED INDEX [IX_meetingInfo] ON [dbo].[messageInfo] 
(
	[sendTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--是否发送索引：
CREATE NONCLUSTERED INDEX [IX_meetingInfo_1] ON [dbo].[messageInfo] 
(
	[isSend] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.消息模板库：这个库暂时使用手工维护
drop table messageTemplate
CREATE TABLE messageTemplate(
	templateID varchar(12) not null,	--主键：消息模板编号,本系统使用第11001号号码发生器产生（8位日期代码+4位流水号）
	templateType nvarchar(30) null,		--消息模板类型
	templateBody nvarchar(4000) null,	--消息模板内容
 CONSTRAINT [PK_messageTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


select len(NEWID())

--3.即时通讯消息表（已送达）：
delete IMessageInfo
drop TABLE IMessageInfo
CREATE TABLE IMessageInfo(
	messageID varchar(36) default(''),	--全球唯一ID，当是给群组发送的消息的是否这个字段要设置值，群、组消息只保存一个副本
	messageType nvarchar(30) null,		--消息类型
	senderID varchar(10) not null,		--发送人工号
	sender nvarchar(30) not null,		--发送人
	sendTime datetime DEFAULT(GETDATE()),--发送时间
	receiverType int not null,			--消息接收人类别：表示消息接收人的类别，当消息被转发后就只能是：1（用户）
	receiverID varchar(12) not null,	--接收人工号：注意这里要保存的是用户的ID，发送给讨论组和群的消息最后要转换为具体的组员
	receiver nvarchar(30) not null,		--接收人
	--消息的原始来源：
	srcReceiverType int not null,		--消息最初发送时的接收人类别：
										/*	0（服务器）
											1（用户）
											2（讨论组）
											3（群）
											4（会议）
											5（学术报告）
											9（所有用户）
											10（组织机构-院部）
											11（组织机构-部门）
										*/
	srcReceiverID varchar(12) not null,	--接收人工号
	srcReceiver nvarchar(30) not null,	--接收人
	messageBody nvarchar(4000) null,	--消息内容
 CONSTRAINT [PK_IMessageInfo] PRIMARY KEY CLUSTERED 
(
	[receiverType] ASC,
	[receiverID] ASC,
	[sendTime] ASC,
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--4.未送达即时通讯消息：
drop TABLE undeliverableIMessageInfo
CREATE TABLE undeliverableIMessageInfo(
	messageID varchar(36) default(''),	--全球唯一ID，当是给群组发送的消息的是否这个字段要设置值，群、组消息每个用户都保存一个副本
	messageType nvarchar(30) null,		--消息类型
	senderID varchar(10) not null,		--发送人工号
	sender nvarchar(30) not null,		--发送人
	sendTime datetime DEFAULT(GETDATE()),--发送时间:这是发送人将消息放入消息队列的时间
	receiverType int not null,			--消息接收人类别：表示消息接收人的类别，当消息被转发后就只能是：1（用户）
	receiverID varchar(12) not null,	--接收人工号：注意这里要保存的是用户的ID，发送给讨论组和群的消息最后要转换为具体的组员
	receiver nvarchar(30) not null,		--接收人
	--消息的原始来源：
	srcReceiverType int not null,		--消息最初发送时的接收人类别：
										/*	0（服务器）
											1（用户）
											2（讨论组）
											3（群）
											4（会议）
											5（学术报告）
											9（所有用户）
											10（组织机构-院部）
											11（组织机构-部门）
										*/
	srcReceiverID varchar(12) not null,	--接收人工号
	srcReceiver nvarchar(30) not null,	--接收人
	messageBody nvarchar(4000) null,	--消息内容
 CONSTRAINT [PK_undeliverableIMessageInfo] PRIMARY KEY CLUSTERED 
(
	[receiverType] ASC,
	[receiverID] ASC,
	[sendTime] ASC,
	[messageID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE isSend
/*
	name:		isSend
	function:	1.将消息设置成已经发送(本过程计划废止,现在消息在获取的同时就已经标定了!)
	input: 
				@messageID varchar(12),		--消息编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE isSend
	@messageID varchar(12),		--消息编号
	@Ret int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	update messageInfo
	set isSend = 1
	where messageID =  @messageID
	set @Ret = 0
GO

drop PROCEDURE isRead
/*
	name:		isRead
	function:	1.1.将消息设置成已经阅读(同时也将发送状态设置为已发送)
	input: 
				@messageID varchar(12),		--消息编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-18
	UpdateDate: 
*/
create PROCEDURE isRead
	@messageID varchar(12),		--消息编号
	@Ret int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	update messageInfo
	set isSend=1, isRead = 1
	where messageID =  @messageID
	set @Ret = 0
GO


drop PROCEDURE getActiveUserIP
/*
	name:		getActiveUserIP
	function:	2.获取活动用户的IP
	input: 
				@userID varchar(10),		--用户工号
	output: 
				@userIP varchar(40) OUTPUT	--会话客户端IP
	author:		卢苇
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE getActiveUserIP
	@userID varchar(10),		--用户工号
	@userIP varchar(40) OUTPUT	--会话客户端IP
	WITH ENCRYPTION 
AS
	set @userIP = (select userIP from activeUsers where userID=@userID)
GO


drop PROCEDURE addMessageInfo
/*
	name:		addMessageInfo
	function:	4.添加消息
	input: 
				@messageClass int,			--消息类别：表示消息的来源与类别信息
											0	服务器询问消息
											1	询问回答消息（注册） 
											2	服务器通知客户端验证结果消息
											3	会议通知消息
											4	会议回复消息
											5	学术报告通知消息
											6	学术报告回复消息
											7	讨论组成员对用户邀请消息
											8	用户对讨论组消息
											9	群主对用户的消息
											10	用户对群消息
											11	消息管理器出错信息
											99	即时通信消息（这类消息不在本列表中）
											100	服务器广播消息
				@messageType nvarchar(30),	--消息类型
				@messageLevel smallint,		--重要级别：1~9，等级越高越重要，发送优先
				@senderID varchar(12),		--发送人工号
				@receiverType int,			--接收人类别：表示消息接收人的类别
													/*	0（服务器）
														1（用户）
														2（讨论组）
														3（群）
														4（会议）
														5（学术报告）
														9（所有用户）
														10（组织机构-院部）
														11（组织机构-部门）
													*/
				@receiverID varchar(12),	--接收人工号
				@messageBody nvarchar(4000),--消息内容
	output: 
				@Ret		int output			--操作成功标识：0:成功，9:未知错误
				@messageID varchar(12) output--主键：消息编号,本系统使用第11000号号码发生器产生（8位日期代码+4位流水号）
	author:		卢苇
	CreateDate:	2013-1-1
	UpdateDate: modi by lw 2013-4-13增加消息类别和接收人类别字段
*/
create PROCEDURE addMessageInfo
	@messageClass int,			--消息类别：表示消息的来源与类别信息
	@messageType nvarchar(30),	--消息类型
	@messageLevel smallint,		--重要级别：1~9，等级越高越重要，发送优先
	@senderID varchar(12),		--发送人工号
	@receiverType int,			--接收人类别：表示消息接收人的类别
	@receiverID varchar(12),	--接收人工号
	@messageBody nvarchar(4000),--消息内容
	@Ret		int output,
	@messageID varchar(12) output--主键：消息编号,本系统使用第11000号号码发生器产生（8位日期代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生消息编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 11000, 1, @curNumber output
	set @messageID = @curNumber

	--取发送人/接收人姓名
	declare @sender nvarchar(30), @receiver nvarchar(30)		--发送人/接收人
	set @sender = isnull((select cName from userInfo where jobNumber=@senderID),'')
	set @receiver = isnull((select cName from userInfo where jobNumber=@receiverID),'')
	
	declare @sendTime smalldatetime
	set @sendTime = getdate()	--发送时间
	insert messageInfo(messageClass, messageID, messageType, messageLevel, senderID, sender, receiverType, receiverID, receiver, messageBody)
	values(@messageClass,@messageID, @messageType, @messageLevel, @senderID, @sender, @receiverType, @receiverID, @receiver, @messageBody)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO
--测试：
declare	@Ret		int
declare	@messageID varchar(12)
declare @InviteForm nvarchar(2000)
set @InviteForm = 
N'<root>
	<groupID>201304130001</groupID>
	<groupName>测试群</groupName>
	<cmdType>Invite</cmdType>
	<applyID>201304130001</applyID> 
</root>'
exec addMessageInfo 9,'群邀请函', 9, 'G201300007', 1, '0000000000', 
	@InviteForm,
	@Ret output, @messageID output
select @Ret, @messageID

select * from messageInfo
use hustOA
select * from userInfo
select * from activeUsers

--定义的几个消息模板：
--1.会议通知
--2.会议时间变更通知
--3.会议场地变更通知
--4.会议取消通知
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130001','会议通知','<h3>会议通知</h3><br /><p>请您于{meetingTime}参加“{topic}”会议。'+
					'</p>详情请查阅:<a target="_blank" href=''http://www.oridway.com''>{meetingID}会议</a>')
					
select * from messageTemplate
where templateID='MB20130001'

select * from messageInfo

update messageInfo
set isSend = 0




--消息与任务的联合查询语句：
select 1 iType, messageID id, messageType topic, sendTime theTime, isRead iStatus 
from messageInfo
where day(sendTime)=DAY(GETDATE())
union all
select 2, taskID, topic, taskStartTime, case isOver 
										when 1 then 9	--已完成任务
										else case 
											 when DATEDIFF(s,getdate(), taskStartTime) > 0  then 0	--未超时任务
											 else 1	--超时任务
											 end
										end 
from taskInfo
where day(taskStartTime) = DAY(getdate())
order by theTime



select * from taskInfo



use hustOA
select messageID, messageType, messageLevel, 
	senderID, sender, convert(varchar(19),sendTime,120) sendTime, 
	isSend, isRead, receiverID, receiver, messageBody
from messageInfo


--会议模板：
use hustOA
select * from messageTemplate
delete messageTemplate
--会议通知:
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130001','会议通知',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">会议通知</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{InviteMan}老师/学生：请您于{meetingTime}参加“{meetingTopic}”会议。</p>
		<p style="text-indent:24px; line-height:30px;">详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议公告</a></p>
	</html>
</root>'
)

--会议变更通知:
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130002','会议变更通知',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">会议变更通知</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{InviteMan}老师/学生：原定于{meetingTime}在{meetingPlace}场地召开的“{meetingTopic}”会议</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">现有变更事项如下：</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{changeInfo}</p>
		<p style="text-indent:24px; line-height:30px;">详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议变更公告</a></p>
	</html>
')

--会议取消通知:
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130003','会议取消通知',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">会议取消通知</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{InviteMan}老师/学生：原定于{meetingTime}在{meetingPlace}场地召开的“{meetingTopic}”会议现在取消。</p>
		<p style="text-indent:24px; line-height:30px;">详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议取消公告</a></p>
	</html>
')

select * from meetingInfo
select * from  messageInfo
use hustOA

delete messageInfo
delete meetingInfo


<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">会议变更通知</h3>  <p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">胡颖老师/学生：原定于2013-01-30 12:00:00在B206场地召开的“测试会议通知”会议</p>  <p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">现有变更事项如下：</p>  <p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;"></p>  <p style="text-indent:24px; line-height:30px;">详情请查阅:<a target="_blank" href="http://localhost:19176/myWeb/meetingManager/meetingNotice/a7dc1a38-b8b0-46c7-9897-926f6f3480aa.html">测试会议通知会议变更公告</a></p>

select * from SMSInfo

会议变更通知\r\n  卢苇老师/学生：原定于2013-01-30 12:05:00在B206场地召开的“测试会议通知”会议\r\n  现有变更事项如下：\r\n  详情请查阅:<a target="_blank" href="http://localhost:19176/myWeb/meetingManager/meetingNotice/260522be-d975-4b36-8436-a32b9f2b4b19.html">测试会议通知会议变更公告</a>



drop PROCEDURE saveIMessageInfo
/*
	name:		saveIMessageInfo
	function:	5.将即时通讯消息保存到数据库中（这是服务器通讯管理器专用过程）
				注意：当是群组的消息时需要设置messageID，系统将只保存一个副本
	input: 
				@messageID varchar(36),		--全球唯一ID，当是给群组发送的消息的是否这个字段要设置值，群、组消息只保存一个副本
				@messageType nvarchar(30),	--消息类型
				@senderID varchar(12),		--发送人工号
				@sendTime varchar(19),		--发送时间:采用“yyyy-MM-dd hh:mm:ss”格式存放
				@receiverType int,			--消息接收人类别：表示消息接收人的类别，当消息被转发后就只能是：1（用户）
				@receiverID varchar(12),	--接收人工号：注意这里要保存的是用户的ID，发送给讨论组和群的消息最后要转换为具体的组员
				--消息的原始来源：
				@srcReceiverType int,		--消息最初发送时的接收人类别：
													/*	0（服务器）
														1（用户）
														2（讨论组）
														3（群）
														4（会议）
														5（学术报告）
														9（所有用户）
														10（组织机构-院部）
														11（组织机构-部门）
													*/
				@srcReceiverID varchar(12),	--接收人工号
				@srcReceiver nvarchar(30),	--接收人
				@messageBody nvarchar(4000),--消息内容
	output: 
				@Ret		int output		--操作成功标识：0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE saveIMessageInfo
	@messageID varchar(36),		--全球唯一ID，当是给群组发送的消息的是否这个字段要设置值，群、组消息只保存一个副本
	@messageType nvarchar(30),	--消息类型
	@senderID varchar(12),		--发送人工号
	@sendTime varchar(19),		--发送时间:采用“yyyy-MM-dd hh:mm:ss”格式存放
	@receiverType int,			--消息接收人类别：表示消息接收人的类别，当消息被转发后就只能是：1（用户）
	@receiverID varchar(12),	--接收人工号：注意这里要保存的是用户的ID，发送给讨论组和群的消息最后要转换为具体的组员
	--消息的原始来源：
	@srcReceiverType int,		--消息最初发送时的接收人类别
	@srcReceiverID varchar(12),	--接收人工号
	@srcReceiver nvarchar(30),	--接收人
	@messageBody nvarchar(4000),--消息内容
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--当为群组消息时检查messageID，系统将只保存一个副本：
	if (@srcReceiverType<>1 and @messageID<>'')
	begin
		declare @count int
		set @count = (select count(*) from IMessageInfo where messageID=@messageID)
		if (@count>0)
		begin
			set @Ret =0
			return
		end
	end
	--取发送人/接收人姓名
	declare @sender nvarchar(30), @receiver nvarchar(30)		--发送人/接收人
	set @sender = isnull((select cName from userInfo where jobNumber=@senderID),'')
	set @receiver = isnull((select cName from userInfo where jobNumber=@receiverID),'')
	
	insert IMessageInfo(messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
					srcReceiverType, srcReceiverID, srcReceiver, messageBody)
	values(@messageID, @messageType, @senderID, @sender, @sendTime, @receiverType, @receiverID, @receiver, 
					@srcReceiverType, @srcReceiverID, @srcReceiver, @messageBody)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO
declare @Ret		int 
exec dbo.saveIMessageInfo '123','测试','G201300040','2013-04-17',2,'G201300040',2,'201304150009','讨论组','测试',@Ret output
select @Ret
select * from IMessageInfo

drop PROCEDURE saveUndeliverableIMessageInfo
/*
	name:		saveUndeliverableIMessageInfo
	function:	6.将未送达即时通讯消息保存到数据库中（这是服务器通讯管理器和网页程序发送消息的专用过程）
	input: 
				@messageID varchar(36),		--全球唯一ID，当是给群组发送的消息的是否这个字段要设置值，群、组消息只保存一个副本
				@messageType nvarchar(30),	--消息类型
				@senderID varchar(12),		--发送人工号
				@receiverType int,			--消息接收人类别：表示消息接收人的类别，当消息被转发后就只能是：1（用户）
				@receiverID varchar(12),	--接收人工号：注意这里要保存的是用户的ID，发送给讨论组和群的消息最后要转换为具体的组员
				--消息的原始来源：
				@srcReceiverType int,		--消息最初发送时的接收人类别：
													/*	0（服务器）
														1（用户）
														2（讨论组）
														3（群）
														4（会议）
														5（学术报告）
														9（所有用户）
														10（组织机构-院部）
														11（组织机构-部门）
													*/
				@srcReceiverID varchar(12),	--接收人工号
				@srcReceiver nvarchar(30),	--接收人
				@messageBody nvarchar(4000),--消息内容
	output: 
				@Ret		int output			--操作成功标识：0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE saveUndeliverableIMessageInfo
	@messageID varchar(36),		--全球唯一ID，当是给群组发送的消息的是否这个字段要设置值，群、组消息只保存一个副本
	@messageType nvarchar(30),	--消息类型
	@senderID varchar(12),		--发送人工号
	@receiverType int,			--消息接收人类别：表示消息接收人的类别，当消息被转发后就只能是：1（用户）
	@receiverID varchar(12),	--接收人工号：注意这里要保存的是用户的ID，发送给讨论组和群的消息最后要转换为具体的组员
	--消息的原始来源：
	@srcReceiverType int,		--消息最初发送时的接收人类别
	@srcReceiverID varchar(12),	--接收人工号
	@srcReceiver nvarchar(30),	--接收人
	@messageBody nvarchar(4000),--消息内容
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取发送人/接收人姓名
	declare @sender nvarchar(30), @receiver nvarchar(30)		--发送人/接收人
	set @sender = isnull((select cName from userInfo where jobNumber=@senderID),'')
	set @receiver = isnull((select cName from userInfo where jobNumber=@receiverID),'')
	
	insert undeliverableIMessageInfo(messageID, messageType, senderID, sender, receiverType, receiverID, receiver,
					srcReceiverType, srcReceiverID, srcReceiver, messageBody)
	values(@messageID, @messageType, @senderID, @sender, @receiverType, @receiverID, @receiver,
					@srcReceiverType, @srcReceiverID, @srcReceiver, @messageBody)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
GO
select * from IMessageInfo
--测试：
declare @Ret		int 
exec dbo.saveUndeliverableIMessageInfo '123','测试','G201300040',2,'G201300040',2,'201304150009','讨论组','测试',@Ret output
select @Ret
select * from undeliverableIMessageInfo

drop PROCEDURE getUndeliverableIMessageInfo
/*
	name:		getUndeliverableIMessageInfo
	function:	7.获取指定用户与另一个指定用户（或组、群）的未送达即时通讯消息并将消息转存到已发送列表中
				注意：这个结果集只有未送达的即时通讯消息集合
	input: 
				@senderID varchar(12),			--发送人工号
				@userID varchar(10),			--查询人工号
	output: 
				@Ret		int output			--操作成功标识：0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE getUndeliverableIMessageInfo
	@senderID varchar(12),		--发送人工号
	@userID varchar(10),		--查询人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	select messageID, 99 messageClass, messageType, 9 messageLevel,
		senderID, sender, convert(varchar(19),sendTime,120) sendTime,
		receiverType, receiverID, receiver, 
		srcReceiverType, srcReceiverID, srcReceiver, messageBody
	from undeliverableIMessageInfo
	where (senderID = @senderID or (srcReceiverType in (2,3) and srcReceiverID=@senderID)) and receiverID = @userID
	order by sendTime
	
	begin tran
		insert IMessageInfo(messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
							srcReceiverType, srcReceiverID, srcReceiver, messageBody)
		select messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
				srcReceiverType, srcReceiverID, srcReceiver, messageBody
		from undeliverableIMessageInfo
		where (senderID = @senderID or (srcReceiverType in (2,3) and srcReceiverID=@senderID)) and receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		delete undeliverableIMessageInfo where (senderID = @senderID or (srcReceiverType in (2,3) and srcReceiverID=@senderID)) and receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0
GO
--测试：
declare	@Ret		int
exec dbo.getUndeliverableIMessageInfo '201304150009','0000000000',@Ret output
select @Ret

select * from undeliverableIMessageInfo

drop PROCEDURE getAllUndeliverableIMessageInfo
/*
	name:		getAllUndeliverableIMessageInfo
	function:	7.1获取指定用户的未送达即时通讯消息并将消息转存到已发送列表中
				注意：这个结果集只有未送达的即时通讯消息集合(是所有用户的)，这是消息管理器专用过程
	input: 
				@userID varchar(10),			--查询人工号
	output: 
				@Ret		int output			--操作成功标识：0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE getAllUndeliverableIMessageInfo
	@userID varchar(10),		--查询人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	select messageID, 99 messageClass, messageType, 9 messageLevel,
		senderID, sender, convert(varchar(19),sendTime,120) sendTime,
		receiverType, receiverID, receiver, 
		srcReceiverType, srcReceiverID, srcReceiver, messageBody
	from undeliverableIMessageInfo
	where receiverID = @userID
	order by sendTime
	
	begin tran
		insert IMessageInfo(messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
							srcReceiverType, srcReceiverID, srcReceiver, messageBody)
		select messageID, messageType, senderID, sender, sendTime, receiverType, receiverID, receiver, 
				srcReceiverType, srcReceiverID, srcReceiver, messageBody
		from undeliverableIMessageInfo
		where receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		delete undeliverableIMessageInfo where receiverID = @userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0
GO

--测试：
declare @ret int
exec dbo.getAllUndeliverableIMessageInfo 'G201300040',@ret output
select @ret

select * from IMessageInfo



drop PROCEDURE clearIMessageInfo
/*
	name:		clearIMessageInfo
	function:	8.清除指定用户的即时通讯消息
	input: 
				@userID varchar(10),		--操作人工号
	output: 
				@Ret		int output		--操作成功标识：0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-4-16
	UpdateDate: 
*/
create PROCEDURE clearIMessageInfo
	@userID varchar(10),		--操作人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete IMessageInfo where receiverID = @userID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	--取维护人的姓名：
	declare @userName nvarchar(30)
	set @userName = isnull((select userCName from activeUsers where userID = @userID),'')
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userName, GETDATE(), '清除即时通讯消息', '用户' + @userName
												+ '清除了自己的即时通讯消息。')
	set @Ret = 0
GO



--获取历史消息：
select '', 99, messageType, 9,
	senderID, sender, convert(varchar(19),sendTime,120) sendTime,
	receiverType, receiverID, receiver, srcReceiverType, srcReceiverID, srcReceiver, messageBody
from IMessageInfo
--where receiverID = @userID
order by sendTime


--获取未读消息之用户列表：
select distinct senderID, sender from undeliverableIMessageInfo
where srcReceiverType = 1
union all
select distinct srcReceiverID, srcReceiver from undeliverableIMessageInfo
where srcReceiverType in (2,3)
order by senderID


delete systemInfo
select * from systemInfo
select * from userInfo
select * from undeliverableIMessageInfo
select * from IMessageInfo
delete IMessageInfo
delete undeliverableIMessageInfo

delete communityGroup
select * from messageInfo
delete messageInfo where messageID<'201304180399'

select * from discussGroup
select * from discussGroupMember where discussID='201304180001'
delete discussGroupMember where rowNum=261



select * from IMessageInfo i
where ((senderID = '201304150009' or (srcReceiverType in (2,3) and srcReceiverID='201304150009')) and receiverID = 'G201300238')
or ((receiverID = '201304150009' or (srcReceiverType in (2,3) and srcReceiverID='201304150009')) and senderID = 'G201300238')


select * from communityGroup
select * from communityGroupMember
select * from communityGroupApply
select * from messageInfo

select * from undeliverableIMessageInfo where srcReceiverID='201304150009' and receiver='杨斌'


select * from messageInfo
select * from IMessageInfo order by sendTime desc
select * from IMessageInfo order by sendTime
select * from undeliverableIMessageInfo

delete messageInfo
delete IMessageInfo
delete systemInfo
delete activeUsers
delete undeliverableIMessageInfo

select * from undeliverableIMessageInfo
order by sendTime desc
select * from IMessageInfo 
order by sendTime desc
where sender='田富川'
order by messageID


select * from undeliverableIMessageInfo

select * from systemInfo
select * from activeUsers
select * from userInfo

select * from workNote order by actionTime desc
delete workNote