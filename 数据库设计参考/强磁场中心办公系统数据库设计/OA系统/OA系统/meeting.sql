use hustOA
/*
	强磁场中心办公系统-会议管理
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 
*/
--1.会议管理表：
select * from meetingInfo where meetingID='HY20130341'
select * from eqpApplyDetail
select * from eqpBorrowApplyInfo where linkInvoice='HY20130341'

select * from placeApplyInfo

alter TABLE meetingInfo add	remindBefore int default(15)		--会议提醒提前时间：单位为分钟，默认为15分钟 add by lw 2013-07-11
alter TABLE meetingInfo add	noticeTemplateUrl varchar(128) default('meetingTemplate.html')	--通知发布模板 add by lw 2013-07-11
update meetingInfo
set remindBefore=15,noticeTemplateUrl='meetingTemplate.html'

exec sp_rename 'meetingInfo.reportPlaceID','placeID','column';
exec sp_rename 'meetingInfo.reportPlace','place','column';
select * from meetingInfo
drop table meetingInfo
CREATE TABLE meetingInfo(
	meetingID varchar(10) not null,		--主键：会议编号,本系统使用第251号号码发生器产生（'HY'+4位年份代码+4位流水号）
	topic  nvarchar(40) null,			--会议议题
	organizerID varchar(10) null,		--会议发起人工号
	organizer nvarchar(30) null,		--会议发起人姓名。冗余设计
	meetingStartTime smalldatetime null,--会议开始时间
	meetingEndTime smalldatetime null,	--会议预计结束时间
	summary nvarchar(300) null,			--内容摘要(会议议程)
	
	placeID varchar(10) null,		--会议地点的标识号（场地ID）
	place nvarchar(60) null,		--会议地点
	placeIsReady smallint default(0),	--会议需要的场地是否准备好：0->未准备好，1->准备就绪
	
	needEqpCodes varchar(80) null,		--会议需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
	needEqpNames nvarchar(300) null,	--会议需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。
	eqpIsReady smallint default(0),		--会议需要的设备是否准备好：0->未准备好，1->准备就绪

	needSMSInvitation smallint default(0),--是否需要短信通知：0->需要, 1->不需要 add by lw 2013-1-3
	remindBefore int default(15),		--会议提醒提前时间：单位为分钟，默认为15分钟 add by lw 2013-07-11
	needSMSRemind smallint default(0),	--是否需要短信提醒（会议前1小时提醒）：0->不需要，1->需要 add by lw 2013-1-3
	
	noticeTemplateUrl varchar(128) defalut('meetingTemplate.html'),	--通知发布模板 add by lw 2013-07-11
	meetingNoticeUrl varchar(128) null,	--当前会议通知的页面路径 add by lw 2013-1-29
	isPublish smallint default(0),		--是否已经发布（发送通知）：0->未发布，1->已发布 add by lw 2013-1-29
	
	--统计数据：
	InviteManNum int default(0),		--会议邀请总人数
	replyManNum int default(0),			--回复总人数
	replyOKManNum int default(0),		--回复参加人数
	enterManNum int default(0),			--实际参加人数
	
	isOver smallint default(0),			--是否会议结束：0->未结束，1->会议结束
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_meetingInfo] PRIMARY KEY CLUSTERED 
(
	[meetingID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--会议开始时间索引：
CREATE NONCLUSTERED INDEX [IX_meetingInfo] ON [dbo].[meetingInfo] 
(
	[meetingStartTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--会议是否结束索引：
CREATE NONCLUSTERED INDEX [IX_meetingInfo_1] ON [dbo].[meetingInfo] 
(
	[isOver] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from meetingInfo
select * from AReportEnterMans

--2.会议邀请人员表：
select * from meetingEnterMans where meetingID='HY20130166'
use hustOA
update meetingEnterMans
set isSendMsg = 1
alter TABLE meetingEnterMans add taskID varchar(10) null			--关联的提醒任务编号 add by lw 2013-07-12 这个变量只在存储过程内部维护

drop table meetingEnterMans
CREATE TABLE meetingEnterMans(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号：排序使用
	meetingID varchar(10) not null,		--外键：会议编号
	--topic  nvarchar(40) null,			--主题：冗余设计del by lw 2013-1-3webservice接口未变
	
	InviteManID varchar(10) not null,	--邀请人员工号
	InviteMan nvarchar(30) not null,	--邀请人员姓名。冗余设计
	isSendMsg smallint default(0),		--通知是否已经发送：0->未发送，1->已发送
	sendTime smalldatetime null,		--会议通知送达时间
	isReadMsg smallint default(0),		--通知是否已经阅读：0->未阅读，1->已阅读
	readTime smalldatetime null,		--会议通知阅读时间
	
	replyTime smalldatetime null,		--回复时间
	isEnter smallint default(0),		--是否参加：0->未知，1->参加，-1->不参加
	taskID varchar(10) null,			--关联的提醒任务编号 add by lw 2013-07-12 这个变量只在存储过程内部维护
	--replyOpinion nvarchar(300) null,	--回复意见:del by lw 2013-1-3因为有多次回复意见，所以设计成一个独立的表
	
	checkManID varchar(10) null,		--考勤人工号
	checkMan nvarchar(30) null,			--考勤人姓名
	arriveTime smalldatetime null,		--到达时间
	isLate smallint default(0),			--是否迟到：0->未到达，1->正常到达，-1->迟到
 CONSTRAINT [PK_meetingEnterMans] PRIMARY KEY CLUSTERED 
(
	[meetingID] ASC,
	[InviteManID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[meetingEnterMans] WITH CHECK ADD CONSTRAINT [FK_meetingEnterMans_meetingInfo] FOREIGN KEY([meetingID])
REFERENCES [dbo].[meetingInfo] ([meetingID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[meetingEnterMans] CHECK CONSTRAINT [FK_meetingEnterMans_meetingInfo]
GO

--3.会议回复意见（参加会议人员可以多次回复）一览表：不要级联，否则无法保存历史数据！
drop TABLE meetingManDiscussInfo
CREATE TABLE meetingManDiscussInfo(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号：排序使用
	meetingID varchar(10) not null,		--主键：会议编号
	replyTime smalldatetime null,		--回复时间
	
	InviteManID varchar(10) not null,	--主键：讨论人（邀请人）工号
	InviteMan nvarchar(30) not null,	--讨论人（邀请人）姓名。冗余设计
	isEnter smallint default(0),		--是否参加：0->未知，1->参加，-1->不参加
	replyOpinion nvarchar(300) null,	--回复意见
CONSTRAINT [PK_meetingManDiscussInfo] PRIMARY KEY CLUSTERED 
(
	[meetingID] ASC,
	[rowNum] ASC,
	[InviteManID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--4.会议发布模板表
drop TABLE meetingNoticeTemplate
CREATE TABLE meetingNoticeTemplate(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号：排序使用
	templateName nvarchar(30) not null,	--模板名称
	url varchar(128) not null,			--模板页面文件路径
CONSTRAINT [PK_meetingNoticeTemplate] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

select templateName,url from meetingNoticeTemplate order by rowNum

--定义的几个消息模板：
--1.会议通知
--2.会议时间变更通知
--3.会议场地变更通知
--4.会议取消通知

delete messageTemplate
--会议通知模板：
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130001','会议通知',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">会议通知</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">亲爱的{InviteMan}：请您于{meetingTime}参加“{meetingTopic}”会议。</p>
		<p style="text-indent:24px; line-height:30px;">详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议公告</a></p>
	</html>
</root>')
--会议变更通知模板：
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130002','会议变更通知',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">会议变更通知</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">亲爱的{InviteMan}：
		原定于{meetingTime}在{meetingPlace}场地召开的“{meetingTopic}”会议</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">现有变更事项如下：</p>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">{changeInfo}</p>
		<p style="text-indent:24px; line-height:30px;">详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议公告</a></p>
	</html>  
</root>')
--会议取消通知模板：
insert messageTemplate(templateID, templateType, templateBody)
values('MB20130003','会议取消通知',
N'<root>
	<meetingID>{meetingID}</meetingID>
	<topic>{meetingTopic}</topic>
	<html>
		<h3 style="text-align:center; border-bottom:2px solid #ccc; line-height:30px;">会议取消通知</h3>
		<p style="text-indent:24px; line-height:30px; padding:0px 10px 0px;">亲爱的{InviteMan}：
		原定于{meetingTime}在{meetingPlace}场地召开的“{meetingTopic}”会议现在取消。</p>
		<p style="text-indent:24px; line-height:30px;">详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议公告</a></p>
	</html>
</root>')

select * from SMSTemplate
delete SMSTemplate
--会议通知模板:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130001','会议通知',
N'会议通知'+ char(13)+char(10)+
'亲爱的{InviteMan}：请您于{meetingTime}参加“{meetingTopic}”会议。'+ char(13)+char(10)+
'详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议公告</a>')
--会议变更通知:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130002','会议变更通知',
N'会议变更通知'+ char(13)+char(10)+
'亲爱的{InviteMan}：原定于{meetingTime}在{meetingPlace}场地召开的“{meetingTopic}”会议'+ char(13)+char(10)+
'现有变更事项如下：{changeInfo}'+ char(13)+char(10)+
'详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议公告</a>')

--会议取消通知:
insert SMSTemplate(templateID, templateType, templateBody)
values('MB20130003','会议取消通知',
N'会议取消通知'+ char(13)+char(10)+
'亲爱的{InviteMan}：原定于{meetingTime}在{meetingPlace}场地召开的“{meetingTopic}”会议现在取消。'+ char(13)+char(10)+
'详情请查阅:<a target="_blank" href="{url}">{meetingTopic}会议公告</a>')

	
drop PROCEDURE querymeetingInfoLocMan
/*
	name:		querymeetingInfoLocMan
	function:	1.查询指定会议是否有人正在编辑
	input: 
				@meetingID varchar(10),			--会议编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9：查询出错，可能是指定的会议不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 
*/
create PROCEDURE querymeetingInfoLocMan
	@meetingID varchar(10),			--会议编号
	@Ret int output,				--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	set @Ret = 0
GO


drop PROCEDURE lockmeetingInfo4Edit
/*
	name:		lockmeetingInfo4Edit
	function:	2.锁定会议编辑，避免编辑冲突
	input: 
				@meetingID varchar(10),			--会议编号
				@lockManID varchar(10) output,	--锁定人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要锁定的会议不存在，2:要锁定的会议正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 
*/
create PROCEDURE lockmeetingInfo4Edit
	@meetingID varchar(10),			--会议编号
	@lockManID varchar(10) output,	--锁定人，如果当前会议正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update meetingInfo
	set lockManID = @lockManID 
	where meetingID= @meetingID
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定会议编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了会议['+ @meetingID +']为独占式编辑。')
GO

drop PROCEDURE unlockmeetingInfoEditor
/*
	name:		unlockmeetingInfoEditor
	function:	3.释放会议编辑锁
				注意：本过程不检查会议是否存在！
	input: 
				@meetingID varchar(10),			--会议编号
				@lockManID varchar(10) output,	--锁定人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 
*/
create PROCEDURE unlockmeetingInfoEditor
	@meetingID varchar(10),			--会议编号
	@lockManID varchar(10) output,	--锁定人，如果当前会议呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update meetingInfo set lockManID = '' where meetingID= @meetingID
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放会议编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了会议['+ @meetingID +']的编辑锁。')
GO

drop PROCEDURE addMeetingInfo
/*
	name:		addMeetingInfo
	function:	4.添加会议信息
	input: 
				@topic  nvarchar(40),			--会议议题
				@organizerID varchar(10),		--会议发起人工号
				@meetingStartTime varchar(19),	--会议开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@meetingEndTime varchar(19),	--会议预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@summary nvarchar(300),			--内容摘要(会议议程)
				
				@placeID varchar(10),		--会议地点的标识号（场地ID）
				@place nvarchar(60),		--会议地点
				
				@needEqpCodes varchar(80),		--会议需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
				@needEqpNames nvarchar(300),	--会议需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

				@noticeTemplateUrl varchar(128),--通知发布模板 add by lw 2013-07-11
				@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
				@remindBefore int,				--会议提醒提前时间：单位为分钟，默认为15分钟 add by lw 2013-07-11
				@needSMSRemind smallint,		--是否需要短信提醒（会议前1小时提醒）：0->不需要，1->需要

				@meetingEnterMans xml,			--会议邀请参加人N'<root>
																--	<row id="1">
																--		<InviteManID>00001</InviteManID>
																--	</row>
																--	<row id="2">
																--		<InviteManID>00002</InviteManID>
																--	</row>
																--	...
																--</root>'
				--@meetingNoticeUrl varchar(128),	--当前会议通知的页面路径 add by lw 2013-1-29 这个应该是发布的时候动态生成！

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识：0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@meetingID varchar(10) output	--会议编号:本系统使用第251号号码发生器产生（'HY'+4位年份代码+4位流水号）
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-3增加短信接口
				modi by lw 2013-1-29增加会议通知页面接口参数
				modi by lw 2013-07-11增加会议模板支持和设定会议提醒时间
*/
create PROCEDURE addMeetingInfo
	@topic  nvarchar(40),			--会议议题
	@organizerID varchar(10),		--会议发起人工号
	@meetingStartTime varchar(19),	--会议开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@meetingEndTime varchar(19),	--会议预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@summary nvarchar(300),			--内容摘要(会议议程)
	
	@placeID varchar(10),		--会议地点的标识号（场地ID）
	@place nvarchar(60),		--会议地点
	
	@needEqpCodes varchar(80),		--会议需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
	@needEqpNames nvarchar(300),	--会议需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

	@noticeTemplateUrl varchar(128),--通知发布模板 add by lw 2013-07-11
	@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
	@remindBefore int,				--会议提醒提前时间：单位为分钟，默认为15分钟 add by lw 2013-07-11
	@needSMSRemind smallint,		--是否需要短信提醒（会议前1小时提醒）：0->不需要，1->需要

	@meetingEnterMans xml,			--会议邀请参加人N'<root>
													--	<row id="1">
													--		<InviteManID>00001</InviteManID>
													--	</row>
													--	<row id="2">
													--		<InviteManID>00002</InviteManID>
													--	</row>
													--	...
													--</root>'
	--@meetingNoticeUrl varchar(128),	--当前会议通知的页面路径 add by lw 2013-1-29 这个应该是发布的时候动态生成！

	@createManID varchar(10),		--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@meetingID varchar(10) output	--会议编号:本系统使用第251号号码发生器产生（'HY'+4位年份代码+4位流水号）
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生会议编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 251, 1, @curNumber output
	set @meetingID = @curNumber

	--取发起人、创建人的姓名：
	declare @organizer nvarchar(30)		--会议发起人姓名。冗余设计
	set @organizer = isnull((select cName from userInfo where jobNumber = @organizerID),'')
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	begin tran
		insert meetingInfo(meetingID, topic, organizerID, organizer, 
							meetingStartTime, meetingEndTime, summary,
							placeID, place, 
							needEqpCodes, needEqpNames,
							noticeTemplateUrl,needSMSInvitation,
							remindBefore, needSMSRemind,
							--最新维护情况:
							modiManID, modiManName, modiTime)
		values(@meetingID, @topic, @organizerID, @organizer, 
						@meetingStartTime, @meetingEndTime, @summary,
						@placeID, @place, 
						@needEqpCodes, @needEqpNames,
						@noticeTemplateUrl,@needSMSInvitation,
						@remindBefore, @needSMSRemind,
						--最新维护情况:
						@createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--登记会议参加人：
		insert meetingEnterMans(meetingID, InviteManID, InviteMan)
		select @meetingID, InviteManID, u.cName
		from (select cast(T.x.query('data(./InviteManID)') as varchar(10)) InviteManID 
			from(select @meetingEnterMans.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab left join userInfo u on tab.InviteManID = u.jobNumber
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	
		--更新统计数据：
		declare @InviteManNum int
		set @InviteManNum = isnull((select count(*) from meetingEnterMans where meetingID = @meetingID),0)
		update meetingInfo
		set InviteManNum = @InviteManNum
		where meetingID = @meetingID
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
	values(@createManID, @createManName, @createTime, '登记会议', '系统根据用户' + @createManName + 
					'的要求登记了会议“' + @topic + '['+@meetingID+']”。')
GO
--测试:
declare	@Ret		int
declare	@createTime smalldatetime
declare	@meetingID varchar(10)	--会议编号:本系统使用第251号号码发生器产生（'HY'+4位年份代码+4位流水号）
exec dbo.addmeetingInfo '需求分析会议', '00001', '2012-12-29 14:00:00','2012-12-29 16:00:00','讨论强磁场中心办公系统需求',
		'001','公司会议室', '00000001','投影仪',0,0,
			N'<root>
				<row id="1">
					<InviteManID>G201300001</InviteManID>
				</row>
				<row id="2">
					<InviteManID>G201300007</InviteManID>
				</row>
			</root>',
			'00002',
			@Ret output,
			@createTime output,
			@meetingID output
select @Ret
select * from meetingInfo
select * from meetingEnterMans
select * from userInfo

drop PROCEDURE updateMeetingInfo
/*
	name:		updateMeetingInfo
	function:	5.修改会议信息
	input: 
				@meetingID varchar(10),			--会议编号
				@topic  nvarchar(40),			--会议议题
				@organizerID varchar(10),		--会议发起人工号
				@meetingStartTime varchar(19),	--会议开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@meetingEndTime varchar(19),	--会议预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
				@summary nvarchar(300),			--内容摘要(会议议程)
				
				@placeID varchar(10),		--会议地点的标识号（场地ID）
				@place nvarchar(60),		--会议地点
				
				@needEqpCodes varchar(80),		--会议需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
				@needEqpNames nvarchar(300),	--会议需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

				@noticeTemplateUrl varchar(128),--通知发布模板 add by lw 2013-07-11
				@meetingNoticeUrl varchar(128),	--当前会议通知的页面路径 add by lw 2013-1-29 如果会议已经发布则要填入该参数
				@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
				@remindBefore int,				--会议提醒提前时间：单位为分钟，默认为15分钟 add by lw 2013-07-11
				@needSMSRemind smallint,		--是否需要短信提醒（会议前1小时提醒）：0->不需要，1->需要
				@meetingEnterMans xml,			--会议邀请参加人N'<root>
																--	<row id="1">
																--		<InviteManID>00001</InviteManID>
																--	</row>
																--	<row id="2">
																--		<InviteManID>00002</InviteManID>
																--	</row>
																--	...
																--</root>'

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的会议不存在，
							2:要修改的会议正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-3增加短信接口
				modi by lw 2013-1-29增加会议通知页面接口，增加会议变更处理！
				modi by lw 2013-07-11增加会议模板支持和设定会议提醒时间
*/
create PROCEDURE updateMeetingInfo
	@meetingID varchar(10),			--会议编号
	@topic  nvarchar(40),			--会议议题
	@organizerID varchar(10),		--会议发起人工号
	@meetingStartTime varchar(19),	--会议开始时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@meetingEndTime varchar(19),	--会议预计结束时间：采用"yyyy-MM-dd hh:mm:ss"格式存放
	@summary nvarchar(300),			--内容摘要(会议议程)
	
	@placeID varchar(10),		--会议地点的标识号（场地ID）
	@place nvarchar(60),		--会议地点
	
	@needEqpCodes varchar(80),		--会议需要的设备编号：支持多个设备，采用"XXXXXXXX,XXXXXXXX"格式存放
	@needEqpNames nvarchar(300),	--会议需要的设备名称：支持多个设备，采用"设备1,设备2"格式存放，冗余设计。

	@noticeTemplateUrl varchar(128),--通知发布模板 add by lw 2013-07-11
	@meetingNoticeUrl varchar(128),	--当前会议通知的页面路径 add by lw 2013-1-29 如果会议已经发布则要填入该参数
	@needSMSInvitation smallint,	--是否需要短信通知：0->需要, 1->不需要
	@remindBefore int,				--会议提醒提前时间：单位为分钟，默认为15分钟 add by lw 2013-07-11
	@needSMSRemind smallint,		--是否需要短信提醒（会议前1小时提醒）：0->不需要，1->需要
	@meetingEnterMans xml,			--会议邀请参加人N'<root>
													--	<row id="1">
													--		<InviteManID>00001</InviteManID>
													--	</row>
													--	<row id="2">
													--		<InviteManID>00002</InviteManID>
													--	</row>
													--	...
													--</root>'

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @oldTopic nvarchar(40)				--会议议题
	declare @oldOrganizer nvarchar(30)			--会议发起人姓名
	declare @oldMeetingStartTime smalldatetime	--会议开始时间
	declare @oldMeetingEndTime smalldatetime	--会议预计结束时间
	declare @oldSummary nvarchar(300)			--内容摘要(会议议程)
	declare @oldPlace nvarchar(60)		--会议地点
	declare @isPublish smallint					--是否已发送通知
	select @thisLockMan = isnull(lockManID,''), @oldTopic = topic, @oldOrganizer = organizer,
			@oldMeetingStartTime = meetingStartTime, @oldMeetingEndTime = meetingEndTime,
			@oldSummary = summary, @oldPlace = place, @isPublish = isPublish
	from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取发起人的姓名：
	declare @organizer nvarchar(30)
	set @organizer = isnull((select cName from userInfo where jobNumber = @organizerID),'')
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	begin tran
		update meetingInfo
		set topic = @topic, 
			organizerID = @organizerID, organizer = @organizer, 
			meetingStartTime = @meetingStartTime, meetingEndTime = @meetingEndTime, summary = @summary,
			placeID = @placeID, place = @place, 
			needEqpCodes = @needEqpCodes, needEqpNames = @needEqpNames,
			noticeTemplateUrl = @noticeTemplateUrl,	
			meetingNoticeUrl = @meetingNoticeUrl,
			needSMSInvitation = @needSMSInvitation,
			remindBefore = @remindBefore, needSMSRemind = @needSMSRemind,
			--最新维护情况:
			modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
		where meetingID= @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--更新会议参加人：
		delete meetingEnterMans where meetingID = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		insert meetingEnterMans(meetingID, InviteManID, InviteMan)
		select @meetingID, InviteManID, u.cName
		from (select cast(T.x.query('data(./InviteManID)') as varchar(10)) InviteManID 
			from(select @meetingEnterMans.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
				) as tab left join userInfo u on tab.InviteManID = u.jobNumber
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	
		--更新统计数据：
		declare @InviteManNum int
		set @InviteManNum = isnull((select count(*) from meetingEnterMans where meetingID = @meetingID),0)
		update meetingInfo
		set InviteManNum = @InviteManNum
		where meetingID = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran	
	--如果已经发送过通知，要发送变更通知：
	if (@isPublish=1)
	begin
		declare @changeInfo nvarchar(300)
		set @changeInfo = ''
		if (@oldTopic <> @topic)
			set @changeInfo = @changeInfo + '会议主题由“'+@oldTopic+'”变更为：' + @oldTopic + '<br />'
		if (@oldOrganizer <> @organizer)
			set @changeInfo = @changeInfo + '会议发起人由“'+@oldOrganizer+'”变更为：' + @organizer + '<br />'
		if (@oldMeetingStartTime <> @meetingStartTime)
			set @changeInfo = @changeInfo + '会议开始时间由“'+@oldMeetingStartTime+'”变更为：' + @meetingStartTime + '<br />'
		if (@oldMeetingEndTime <> @meetingEndTime)
			set @changeInfo = @changeInfo + '会议预计结束时间由“'+@oldMeetingEndTime+'”变更为：' + @meetingEndTime+ '<br />'
		if (@oldSummary <> @summary)
			set @changeInfo = @changeInfo + '会议内容（议程）由“'+replace(replace(@oldSummary,'\r',''),'\n','<br />')
								+'”<br />变更为：' + replace(replace(@summary,'\r',''),'\n','<br />'+ '<br />')
		if (@oldPlace <> @place)
			set @changeInfo = @changeInfo + '会议场地由“'+@oldPlace+'”变更为：' + @place+ '<br />'

		exec dbo.makeInvitation @meetingID, 'MB20130002', @changeInfo, @Ret output	--这里只有会议通知情况，变更在修改过程中自动处理了！
	end
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改会议', '系统根据用户' + @modiManName + 
					'的要求修改了会议“' + @topic + '['+@meetingID+']”的登记信息。')
GO
--测试:
declare	@Ret		int
declare	@modiTime smalldatetime
declare	@meetingID varchar(10)	--会议编号:本系统使用第251号号码发生器产生（'HY'+4位年份代码+4位流水号）
exec dbo.updatemeetingInfo 'HY20130097','需求分析会议', 'G201300005', '2012-12-30 14:00:00','2012-12-30 16:00:00','讨论强磁场中心办公系统需求',
		'001','公司会议室', '00000001','投影仪',0,0,
			N'<root>
				<row id="1">
					<InviteManID>G201300001</InviteManID>
				</row>
				<row id="2">
					<InviteManID>G201300007</InviteManID>
				</row>
			</root>',
			'00002',
			@Ret output,
			@modiTime output
select @Ret

select * from userInfo
select * from meetingInfo
select * from meetingEnterMans

drop PROCEDURE delMeetingLinkEqpApply
/*
	name:		delMeetingLinkEqpApply
	function:	5.1.删除会议相关的设备申请单
	input: 
				@meetingID varchar(10),			--会议编号
				@delManID varchar(10) output,	--删除人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:指定的会议不存在，
							2:指定的会议正被别人锁定编辑，
							9:未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-29增加会议通知页面接口，增加会议取消消息处理！
*/
create PROCEDURE delMeetingLinkEqpApply
	@meetingID varchar(10),			--会议编号

	@delManID varchar(10) output,	--删除人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete eqpBorrowApplyInfo where linkInvoiceType=2 and linkInvoice = @meetingID
	
	set @Ret = 0
GO

drop PROCEDURE delMeetingInfo
/*
	name:		delMeetingInfo
	function:	6.删除指定的会议
	input: 
				@meetingID varchar(10),			--会议编号
				@delManID varchar(10) output,	--删除人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：要删除的会议正被别人锁定，
							3：该会议已经完成，不能删除，
							4：在发送会议取消通知的时候出错，但会议已经删除！
							5：该会议已经发布
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-29增加会议取消通知，删除关联场地申请和设备申请
				modi by lw 2013-07-12将会议取消独立出来
*/
create PROCEDURE delMeetingInfo
	@meetingID varchar(10),			--会议编号
	@delManID varchar(10) output,	--删除人，如果当前会议正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10),@isOver smallint
	declare @isPublish smallint					--是否已发送通知
	select @thisLockMan = isnull(lockManID,''), @isPublish= isPublish, @isOver = isOver from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查会议状态：
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end
	--检查会议发布状态：
	if (@isPublish=1)
	begin
		set @Ret = 5
		return
	end
	
	begin tran
		delete meetingInfo where meetingID= @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--删除相关场地申请
		delete eqpBorrowApplyInfo where linkInvoiceType=2 and linkInvoice = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--删除相关设备申请
		delete placeApplyInfo where linkInvoiceType=2 and linkInvoice = @meetingID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除会议', '用户' + @delManName + '删除了会议['+@meetingID+']。')

GO
--测试：
declare	@Ret		int 
exec dbo.delMeetingInfo 'HY20130565','0000000000',@Ret output
select @Ret

select * from meetingInfo
delete messageInfo
select * from messageInfo
select * from userInfo

drop PROCEDURE cancelPublishMeetingInfo
/*
	name:		cancelPublishMeetingInfo
	function:	6.1.取消指定的会议
	input: 
				@meetingID varchar(10),			--会议编号
				@modiManID varchar(10) output,	--取消人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：要取消的会议正被别人锁定，
							3：该会议已经完成，不能取消，
							4：在发送会议取消通知的时候出错，但会议已经取消！
							5：该会议还没有发送通知
							9：未知错误
	author:		卢苇
	CreateDate:	2013-07-12
	UpdateDate: 
*/
create PROCEDURE cancelPublishMeetingInfo
	@meetingID varchar(10),			--会议编号
	@modiManID varchar(10) output,	--取消人，如果当前会议正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10),@isOver smallint
	declare @isPublish smallint					--是否已发送通知
	select @thisLockMan = isnull(lockManID,''), @isPublish= isPublish, @isOver = isOver from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查会议状态：
	if (@isOver=1)
	begin
		set @Ret = 3
		return
	end
	--检查会议是否发布：
	if (@isPublish<>1)
	begin
		set @Ret = 5
		return
	end
	
	declare @runRet int
	--发送会议取消通知：
	exec dbo.makeInvitation @meetingID,'MB20130003','',@runRet output

	update meetingInfo 
	set isPublish = 0
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	--删除参加人员的会议提醒任务：
	delete taskInfo where taskID in(select taskID from meetingEnterMans where meetingID= @meetingID)


	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @remark nvarchar(500)
	if (@runRet<>0)
	begin
		set @remark='用户' + @modiManName + '取消了会议['+@meetingID+'],但在发送会议取消通知的时候出错。'
		set @Ret = 4
	end
	else 
	begin
		set @remark='用户' + @modiManName + '取消了会议['+@meetingID+']。'
		set @Ret = 0
	end

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '取消会议', @remark)

GO
--测试：
declare	@Ret		int 
exec dbo.cancelPublishMeetingInfo 'HY20130565','0000000000',@Ret output
select @Ret

drop PROCEDURE placeIsReady4Meeting
/*
	name:		placeIsReady4Meeting
	function:	7.通知指定的会议场地已经准备好
	input: 
				@meetingID varchar(10),			--会议编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：指定的会议正被别人锁定，3:在发送会议通知的时候出错，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: modi by lw 2013-1-29修改消息和短息接口
				modi by lw 2013-07-11取消关联发送会议通知

*/
create PROCEDURE placeIsReady4Meeting
	@meetingID varchar(10),			--会议编号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update meetingInfo
	set placeIsReady = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
/*	--使用会议模板，无法获知通知页面，所以取消自动关联发布 del by lw 2013-07-11
	--客户要求不做设备关联检查，只要场地准备好了就立刻发送通知 add by lw 2013-1-29
	exec dbo.makeInvitation @meetingID, 'MB20130001', '', @Ret output	--这里只有会议通知情况，变更在修改过程中自动处理了！
	--检查是否设备也准备好，如果也准备好了就开始发送通知
	declare @eqpIsReady smallint
	set @eqpIsReady = (select eqpIsReady from meetingInfo where meetingID= @meetingID)
	if (@eqpIsReady=1)
	begin
		exec dbo.makeInvitation @meetingID, 'MB20130001', @Ret output	--这里只有会议通知情况，变更在修改过程中自动处理了！
		if (@Ret<>0)
			set @Ret = 3
	end
*/
GO

drop PROCEDURE eqpIsReady4Meeting
/*
	name:		eqpIsReady4Meeting
	function:	8.通知指定的会议设备已经准备好
	input: 
				@meetingID varchar(10),			--会议编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：指定的会议正被别人锁定，9：未知错误
							--3:在发送会议通知的时候出错，del by lw 2013-3-24
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE eqpIsReady4Meeting
	@meetingID varchar(10),			--会议编号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update meetingInfo
	set eqpIsReady = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
	--客户要求不做设备关联检查，只要场地准备好了就立刻发送通知 add by lw 2013-1-29
/*	--检查是否场地也准备好，如果也准备好了就开始发送通知
	declare @placeIsReady smallint
	set @placeIsReady = (select placeIsReady from meetingInfo where meetingID= @meetingID)
	if (@placeIsReady=1)
	begin
		exec dbo.makeInvitation @meetingID, 'MB20130001', @Ret output	--这里只有会议通知情况，变更在修改过程中自动处理了！
		if (@Ret<>0)
			set @Ret = 3
	end
*/
GO

use hustOA
-----------------------------------------会议消息用过程：-------------------------------
drop PROCEDURE makeInvitation
/*
	name:		makeInvitation
	function:	10.生成会议通知，将其加入消息队列
	input: 
				@meetingID varchar(10),			--会议编号
				@templateID varchar(10),		--使用的通知模板：'MB20130001'为会议通知，'MB20130002'为会议变更通知, 'MB20130003'为会议取消通知
				@changeInfo nvarchar(300),		--变更事项：变更通知填写，其他填''
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：指定的会议正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-1
	UpdateDate: modi by lw 2013-1-29增加会议变更事项接口，处理会议通知模板生成的页面

*/
create PROCEDURE makeInvitation
	@meetingID varchar(10),			--会议编号
	@templateID varchar(10),		--使用的通知模板：'MB20130001'为会议通知，'MB20130002'为会议变更通知, 'MB20130003'为会议取消通知
	@changeInfo nvarchar(300),		--变更事项：变更通知填写，其他填''
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	--获取会议的基本信息：
	declare @topic nvarchar(40), @organizerID varchar(10), @organizer nvarchar(30)	--会议议题/会议发起人工号/会议发起人姓名。冗余设计
	declare @meetingStartTime smalldatetime, @meetingEndTime smalldatetime --会议开始时间/会议预计结束时间
	declare @place nvarchar(60)		--会议地点
	declare @summary nvarchar(300)			--内容摘要(会议议程)
	declare @meetingNoticeUrl varchar(128)	--当前会议通知的页面路径 add by lw 2013-1-29
	declare @needSMSInvitation smallint		--是否需要短信通知：0->需要, 1->不需要 add by lw 2013-1-3
	select @topic = topic, @organizerID = organizerID, @organizer = organizer, 
		@meetingStartTime = meetingStartTime, @meetingEndTime = meetingEndTime,
		@place = place,@needSMSInvitation = needSMSInvitation,
		@summary = summary, @meetingNoticeUrl = isnull(meetingNoticeUrl,'')
	from meetingInfo
	where meetingID = @meetingID

	--获取会议模板：
	declare @meetingInvitationTemplate Nvarchar(4000), @SMSTemplate nvarchar(500)
	set @meetingInvitationTemplate = (select templateBody from messageTemplate where templateID=@templateID)
	set @SMSTemplate = (select templateBody from SMSTemplate where templateID=@templateID)
	--构造查阅会议通知详情的url：
	set @meetingInvitationTemplate = replace(replace(replace(replace(replace(replace(@meetingInvitationTemplate,'{meetingTopic}',@topic),
										'{meetingTime}',convert(varchar(19),@meetingStartTime,120)),'{url}',@meetingNoticeUrl),
										'{meetingID}',@meetingID),'{meetingPlace}',@place),
										'{changeInfo}',@changeInfo)
	set @SMSTemplate = replace(replace(replace(replace(replace(replace(@SMSTemplate,'{meetingTopic}',@topic),
										'{meetingTime}',convert(varchar(19),@meetingStartTime,120)),'{url}',@meetingNoticeUrl),
										'{meetingID}',@meetingID),'{meetingPlace}',@place),
										'{changeInfo}',@changeInfo)
	--获取通知类型：
	declare @noticeType nvarchar(10)
	if (@templateID='MB20130001')
		set @noticeType = '会议通知'
	else if (@templateID='MB20130002')
		set @noticeType = '会议变更通知'
	else if (@templateID='MB20130003')
		set @noticeType = '会议取消通知'
		
	--分别发送通知给会议邀请人员（已发送通知的人不再通知）的通知，所以如果是修改了场地或时间应该将发送状态清除！
	if (@noticeType = '会议变更通知' or @noticeType = '会议取消通知')
		update meetingEnterMans
		set isSendMsg = 0
		where meetingID = @meetingID
		
	declare @InviteManID varchar(10), @InviteMan nvarchar(30), @mobile varchar(20)	--邀请人员工号/邀请人员姓名/手机号码。
	declare mtar cursor for
	select m.InviteManID, m.InviteMan, isnull(u.mobile,'')
	from meetingEnterMans m left join userInfo u on m.InviteManID = u.jobNumber
	where m.meetingID = @meetingID and m.isSendMsg = 0
	order by m.rowNum
	
	declare @execRet int, @messageID varchar(12)
	declare @meetingInvitation nvarchar(4000), @SMS nvarchar(500)
	declare @errorMessage nvarchar(4000)
	OPEN mtar
	FETCH NEXT FROM mtar INTO @InviteManID, @InviteMan, @mobile
	WHILE @@FETCH_STATUS = 0
	begin
		set @meetingInvitation = replace(@meetingInvitationTemplate,'{InviteMan}',@InviteMan)
		exec dbo.addMessageInfo 3, @noticeType, 9, @organizerID, 1, @InviteManID, @meetingInvitation, @execRet output, @messageID output
		if (@execRet<>0)
		begin
			set @errorMessage = '系统在发送给['+ @InviteMan +']的会议['+ @meetingID +']通知时出现错误！'
			exec dbo.addMessageInfo 11,'通知发送错误', 9, '0000000000', 1, @organizerID, @errorMessage,@execRet output, @messageID output
		end
		
		--短信通知：
		if (@needSMSInvitation=1 and @mobile<>'')
		begin
			declare @SMSInfoID char(12)	--短信编号
			declare @createTime smalldatetime 
			set @SMS = replace(@SMSTemplate,'{InviteMan}',@InviteMan)
			exec dbo.addSMSInfo @organizerID,@InviteManID,@mobile,'',9,@SMS,@organizerID, @execRet output, @createTime output, @SMSInfoID output
			--发送短信：
			declare @snderID varchar(10)
			set @snderID = '0000000000'
			exec dbo.sendSMS @SMSInfoID,'', @snderID output,@createTime output,@execRet output
			if (@execRet<>0)
			begin
				set @errorMessage = '系统在发送手机短信给['+ @InviteMan +']的会议['+ @meetingID +']通知时出现错误！'
				exec dbo.addMessageInfo 11,'通知发送错误', 9, '0000000000', 1, @organizerID, @errorMessage,@execRet output, @messageID output
			end
		end
		FETCH NEXT FROM mtar INTO @InviteManID, @InviteMan, @mobile
	end
	CLOSE mtar
	DEALLOCATE mtar
	--标定会议为已发布：
	update meetingInfo 
	set isPublish = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	--标定通知已发布：
	update meetingEnterMans
	set isSendMsg = 1
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
GO
--测试：
declare @ret int
exec dbo.makeInvitation 'HY20130447','MB20130003','', @ret output
select @ret

select * from meetingInfo
select * from meetingEnterMans
select * from messageInfo
DELETE messageInfo

drop PROCEDURE isSendedInvitation
/*
	name:		isSendedInvitation
	function:	11.将参加会议人员的通知标记为已发送状态
				注意：发送会议通知使用后台调度程序自动发送，这是调度程序调用的过程
	input: 
				@meetingID varchar(10),			--会议编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：指定的会议正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE isSendedInvitation
	@meetingID varchar(10),			--会议编号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end
	
	update meetingEnterMans
	set isSendMsg = 1, sendTime = GETDATE()
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
GO

drop PROCEDURE readInvitation
/*
	name:		readInvitation
	function:	12.通知回执（到达参加会议人后阅读完(按“我知道了”按钮后)自动发送的消息）
				注意：发送会议通知阅读使用消息端自动发送，这是调度程序调用的过程
	input: 
				@meetingID varchar(10),			--会议编号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：指定的会议正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE readInvitation
	@meetingID varchar(10),			--会议编号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end
	
	update meetingEnterMans
	set isReadMsg = 1, readTime = GETDATE()
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	
	set @Ret = 0
GO

select * from meetingEnterMans where meetingID='HY20130573'
select * from meetingInfo where meetingID='HY20130573'
drop PROCEDURE replyMeeting
/*
	name:		replyMeeting
	function:	13.回复会议通知
				注意：可以多次回复,这里也不检测编辑锁,也不检测会议状态(如果会议完成就是会议的评价了)!
	input: 
				@meetingID varchar(10),			--会议编号
				@replyManID varchar(10),		--回复人（邀请人）工号
				@isEnter smallint,				--是否参加：0->未知，1->参加，-1->不参加
				@replyOpinion nvarchar(300),	--回复意见
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2.回复人已经不在邀请人员列表中,9：未知错误
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE replyMeeting
	@meetingID varchar(10),			--会议编号
	@replyManID varchar(10),		--回复人（邀请人）工号
	@isEnter smallint,				--是否参加：0->未知，1->参加，-1->不参加
	@replyOpinion nvarchar(300),	--回复意见
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要回复的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--判断回复人是否是邀请人员
	set @count=(select count(*) from meetingEnterMans where meetingID= @meetingID and InviteManID = @replyManID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	--取回复人姓名：
	declare @replyMan nvarchar(30)
	set @replyMan = isnull((select userCName from activeUsers where userID = @replyManID),'')

	declare @replyTime smalldatetime	--申请时间
	set @replyTime = GETDATE()
	
	begin tran	
		update meetingEnterMans
		set replyTime = @replyTime, isEnter = @isEnter
		where meetingID= @meetingID and InviteManID = @replyManID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		--更新会议主表中的统计数据：
		declare @replyManNum int, @replyOKManNum int
		set @replyManNum=(select count(*) from meetingEnterMans where meetingID= @meetingID and isEnter<>0)		--回复总人数
		set @replyOKManNum=(select count(*) from meetingEnterMans where meetingID= @meetingID and isEnter= 1)		--同意人数
		update meetingInfo
		set replyManNum=@replyManNum, replyOKManNum = @replyOKManNum
		where meetingID= @meetingID
		set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
		
		insert meetingManDiscussInfo(meetingID, InviteManID, InviteMan, isEnter, replyOpinion, replyTime)
		values(@meetingID, @replyManID, @replyMan, @isEnter, @replyOpinion, @replyTime)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	commit tran
	set @Ret = 0
	
	--获取会议的信息：
	declare @topic  nvarchar(40)			--会议议题
	declare @meetingStartTime smalldatetime	--会议开始时间
	declare @meetingEndTime smalldatetime	--会议预计结束时间
	declare @summary nvarchar(300)			--内容摘要(会议议程)
	declare @place nvarchar(60)		--会议地点
	declare @remindBefore int				--会议提醒提前时间：单位为分钟，默认为15分钟 add by lw 2013-07-11
	declare @needSMSRemind smallint			--是否需要短信提醒（会议前1小时提醒）：0->不需要，1->需要 add by lw 2013-1-3
	declare @meetingNoticeUrl varchar(128)	--当前会议通知的页面路径 add by lw 2013-1-29

	select @topic = topic, @meetingStartTime = meetingStartTime, @meetingEndTime = meetingEndTime, @summary = summary,
	@place = place, @remindBefore = remindBefore, @needSMSRemind = needSMSRemind, @meetingNoticeUrl = meetingNoticeUrl
	from meetingInfo where meetingID= @meetingID

	declare @ExecRet int, @createTime smalldatetime, @taskID varchar(10)
	--删除可能存在的以前的会议提醒任务：
	set @taskID = isnull((select taskID from meetingEnterMans where meetingID= @meetingID and InviteManID = @replyManID),'')
	if (@taskID<>'')
	begin
		delete taskInfo where taskID= @taskID

		update meetingEnterMans
		set taskID=''
		where meetingID= @meetingID and InviteManID = @replyManID
	end
	--如果是参加，添加一个会议任务提醒：
	if (@isEnter=1)
	begin
		set @summary = N'会议地点：' + @place + char(13)+char(10) + N'会议议程：' +char(13)+char(10) + @summary
		exec dbo.addTaskInfo @topic, @meetingStartTime, @meetingEndTime, @summary,
				0, @needSMSRemind, @remindBefore, @replyManID, @ExecRet output, @createTime output, @taskID output
		if (@ExecRet=0)
			update meetingEnterMans
			set taskID=@taskID
			where meetingID= @meetingID and InviteManID = @replyManID
	end
	--登记工作日志：
	declare @desc nvarchar(20)
	if (@isEnter=-1)
		set @desc = '不参加'
	else if(@isEnter=1)
		set @desc = '参加'
	else 
		set @desc = '还不能决定是否参加'
	
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@replyManID, @replyMan, @replyTime, '回复会议', '用户' + @replyMan
												+ '回复'+@desc+'会议['+@meetingID+']。')
GO
--测试：
declare @Ret int
exec dbo.applyEnterAReport 'BG20120019','00001', @Ret output
select @Ret

select * from taskInfo
select * from AReportEnterMans
select * from meetingInfo
select * from userInfo




--------------------------------------考勤用过程：-------------------------------------------------------
drop PROCEDURE checkEnterMeeting
/*
	name:		checkEnterMeeting
	function:	20.到达指定的会议（考勤）
	input: 
				@meetingID varchar(10),			--会议编号
				@enterManID varchar(10),		--到达人（原申请人）
				@checkManID varchar(10) output,	--检查人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output,			--操作成功标识
							0:成功，1：指定的会议不存在，2：要申请参加的会议正被别人锁定，9：未知错误
				@isLate smallint output			--系统返回的到达状态：1:正常到达，-1：迟到
	author:		卢苇
	CreateDate:	2012-12-28
	UpdateDate: 

*/
create PROCEDURE checkEnterMeeting
	@meetingID varchar(10),			--会议编号
	@enterManID varchar(10),		--到达人（原申请人）
	@checkManID varchar(10) output,	--检查人，如果当前会议正在被人占用编辑则返回该人的工号
	@Ret		int output,			--操作成功标识
	@isLate smallint output			--系统返回的到达状态：1:正常到达，-1：迟到
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @isLate = 0

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取到达人和考勤人的姓名：
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--取会议时间和到达时间：
	declare @meetingTime smalldatetime, @arriveTime smalldatetime
	set @meetingTime = (select meetingStartTime from meetingInfo where meetingID=@meetingID)
	set @arriveTime = GETDATE()
	if (@meetingTime > @arriveTime)
		set @isLate = 1
	else
		set @isLate = -1
	
	--检查是否报名分别处理：
	set @count =(select count(*) from meetingEnterMans where meetingID = @meetingID and InviteManID = @enterManID)
	if (@count = 0)	--未申请
	begin
		insert meetingEnterMans(meetingID, InviteManID, InviteMan, replyTime, checkManID, checkMan, arriveTime, isLate)
		select @meetingID, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from meetingInfo 
		where meetingID= @meetingID
	end
	else
	begin
		update meetingEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where meetingID= @meetingID and InviteManID = @enterManID
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, '会议点名', '用户' + @checkMan
												+ '将['+@enterMan+']设置为到达会议['+@meetingID+']。')
GO


drop PROCEDURE checkEnterMeetingByFlag
/*
	name:		checkEnterMeetingByFlag
	function:	21.使用标志状态考勤
	input: 
				@meetingID varchar(10),			--会议编号
				@enterManID varchar(10),		--到达人（原申请人）
				@isLate smallint,				--到达状态：1:正常到达， -1:迟到到达
				@checkManID varchar(10) output,	--检查人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：要申请参加的会议正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE checkEnterMeetingByFlag
	@meetingID varchar(10),			--会议编号
	@enterManID varchar(10),		--到达人（原申请人）
	@isLate smallint,				--到达状态：1:正常到达， -1:迟到到达
	@checkManID varchar(10) output,	--检查人，如果当前会议正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取到达人和考勤人的姓名：
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--取会议时间
	declare @meetingTime smalldatetime, @arriveTime smalldatetime
	set @meetingTime = (select meetingStartTime from meetingInfo where meetingID=@meetingID)
	--根据到达状态设置到达时间：正常到达设置为会议开始时间，迟到到达设置为会议开始后15分钟
	if (@isLate=1)
		set @arriveTime = @meetingTime
	else
		set @arriveTime = DATEADD(minute, 15, @meetingTime)
	
	--检查是否报名分别处理：
	set @count =(select count(*) from meetingEnterMans where meetingID = @meetingID and InviteManID = @enterManID)
	if (@count = 0)	--未申请
	begin
		insert meetingEnterMans(meetingID, InviteManID, InviteMan, replyTime, checkManID, checkMan, arriveTime, isLate)
		select @meetingID, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from meetingInfo 
		where meetingID= @meetingID
	end
	else
	begin
		update meetingEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where meetingID= @meetingID and InviteManID = @enterManID
	end

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, '会议点名', '用户' + @checkMan
												+ '将['+@enterMan+']设置为到达会议['+@meetingID+']。')
GO

drop PROCEDURE cancelCheckEnterMeeting
/*
	name:		cancelCheckEnterMeeting
	function:	22.取消到达（误操作后的取消功能）
	input: 
				@meetingID varchar(10),			--会议编号
				@enterManID varchar(10),		--到达人（原邀请人）
				@checkManID varchar(10) output,	--检查人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：要申请参加的会议正被别人锁定，3:没有该邀请人或还未到达，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE cancelCheckEnterMeeting
	@meetingID varchar(10),			--会议编号
	@enterManID varchar(10),		--到达人（原申请人）
	@checkManID varchar(10) output,	--检查人，如果当前会议正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from meetingInfo where meetingID= @meetingID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查邀请人是否存在并到达：
	set @count =(select count(*) from meetingEnterMans where meetingID = @meetingID and InviteManID = @enterManID and isLate<>0)
	if (@count=0)
	begin
		set @Ret =3
		return
	end

	--取到达人和考勤人的姓名：
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	update meetingEnterMans
	set checkManID = @checkManID, checkMan = @checkMan, arriveTime = null, isLate = 0
	where meetingID= @meetingID and InviteManID = @enterManID

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, GETDATE(), '取消会议到达', '用户' + @checkMan
												+ '将['+@enterMan+']设置为未到达会议['+@meetingID+']。')
GO


drop PROCEDURE meetingIsOver
/*
	name:		meetingIsOver
	function:	25.将指定的会议设置为完成状态
	input: 
				@meetingID varchar(10),			--会议编号
				@overManID varchar(10) output,	--完成设定人，如果当前会议正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会议不存在，2：指定的会议正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE meetingIsOver
	@meetingID varchar(10),			--会议编号
	@overManID varchar(10) output,	--完成设定人，如果当前会议正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要完成的会议是否存在
	declare @count as int
	set @count=(select count(*) from meetingInfo where meetingID= @meetingID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from meetingInfo where meetingID= @meetingID
	if (@thisLockMan <> '' and @thisLockMan <> @overManID)
	begin
		set @overManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @overMan nvarchar(30)
	set @overMan = isnull((select userCName from activeUsers where userID = @overManID),'')

	declare @overTime smalldatetime
	set @overTime = GETDATE()
	update meetingInfo
	set isOver = 1,
		--最新维护情况:
		modiManID = @overManID, modiManName = @overMan, modiTime = @overTime
	where meetingID= @meetingID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@overManID, @overMan, @overTime, '完成发布会议', '用户' + @overMan
												+ '将会议['+@meetingID+']设置为完成状态。')

GO

use hustOA
--在线会议查询语句：
select m.meetingID, m.topic, m.organizerID, m.organizer, 
	convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
	convert(varchar(19),m.meetingEndTime,120) meetingEndTime, 
	m.summary,
	m.placeID, m.place, m.placeIsReady, 
	m.needEqpCodes, m.needEqpNames, m.eqpIsReady,
	m.InviteManNum, m.replyManNum, m.replyOKManNum
from meetingInfo m
where isOver = 0

--历史会议查询语句：
select m.meetingID, m.topic, m.organizerID, m.organizer, 
	convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
	convert(varchar(19),m.meetingEndTime,120) meetingEndTime, 
	m.summary,
	m.placeID, m.place, m.placeIsReady, 
	m.needEqpCodes, m.needEqpNames, m.eqpIsReady,
	m.InviteManNum, m.replyManNum, m.replyOKManNum, enterManNum
from meetingInfo m
where isOver = 1

--会议邀请参加人员查询语句：
select a.meetingID, m.topic, 
	convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
	convert(varchar(19),m.meetingEndTime,120) meetingEndTime, 
	a.InviteManID, a.InviteMan, a.isSendMsg, a.isReadMsg,
	convert(varchar(19),a.replyTime,120) replyTime, a.isEnter,
	a.checkManID, a.checkMan, convert(varchar(19),a.arriveTime,120) arriveTime, a.isLate
from meetingEnterMans a
left join meetingInfo m on m.meetingID = a.meetingID
order by rowNum

--查询会议回复意见语句：
select meetingID,convert(varchar(19),replyTime,120) replyTime, InviteManID, InviteMan, isEnter, replyOpinion
from meetingManDiscussInfo
order by replyTime desc



use hustOA
select m.meetingID, m.topic, m.organizerID, m.organizer,
convert(varchar(19),m.meetingStartTime,120) meetingStartTime,
convert(varchar(19),m.meetingEndTime,120) meetingEndTime,
m.summary,m.placeID, m.place, m.placeIsReady,
m.needEqpCodes, m.needEqpNames, m.eqpIsReady,m.InviteManNum, 
m.replyManNum, m.replyOKManNum, m.enterManNum, m.isOver 
from meetingInfo m where meetingID='243423';
select a.meetingID, m.topic,convert(varchar(19),m.meetingStartTime,120) meetingStartTime,
convert(varchar(19),m.meetingEndTime,120) meetingEndTime,a.InviteManID, a.InviteMan, 
a.isSendMsg, a.isReadMsg,convert(varchar(19),a.replyTime,120) replyTime, a.isEnter, a.replyOpinion,a.checkManID, a.checkMan, 
convert(varchar(19),a.arriveTime,120) arriveTime, a.isLate 
from meetingEnterMans a left join meetingInfo m on m.meetingID = a.meetingID 
where a.meetingID='243423' order by rowNum

use hustOA
select * from meetingInfo
update meetingInfo
set topic = '年终总结会'
where meetingID='HY20130012'

select * from messageInfo
delete messageInfo
select * from messageTemplate

use hustOA

select * from meetingInfo
select * from placeApplyInfo where linkInvoice='HY20130122'

select * from eqpBorrowApplyInfo



select *
from bulletinInfo



select * from userInfo

select m.isOver, m.meetingID, m.topic, case m.organizerID when 'G201300040' then 9 else em.isEnter end meetingType, 
m.isPublish, m.organizerID, m.organizer, convert(varchar(19),m.meetingStartTime,120) meetingStartTime, 
convert(varchar(19),m.meetingEndTime,120) meetingEndTime, m.summary,m.placeID, m.place, m.placeIsReady, 
m.needEqpCodes, m.needEqpNames, m.eqpIsReady,m.InviteManNum, m.replyManNum, m.replyOKManNum,m.needSMSInvitation, needSMSRemind
from meetingInfo m left join meetingEnterMans em on m.meetingID = em.meetingID and em.InviteManID='G201300040'
where m.isOver=0 and (m.meetingID in (select meetingID from meetingEnterMans where InviteManID='G201300040' and isSendMsg=1) or m.organizerID='G201300040')


select meetingID,* from meetingEnterMans where InviteManID='G201300040'
