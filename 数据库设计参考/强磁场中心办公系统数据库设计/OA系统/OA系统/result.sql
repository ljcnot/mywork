use hustOA
/*
	强磁场中心办公系统-成果管理
	author:		卢苇
	CreateDate:	2012-12-21
	UpdateDate: 
*/

--1.论文登记表：
alter TABLE thesisInfo alter column	thesisTitle nvarchar(100) null		--论文题目
update thesisInfo 
set affectFact = affectFact*10

alter TABLE thesisInfo alter column	firstAuthorID varchar(10) null	--第一作者工号
alter TABLE thesisInfo drop column	elseAuthorID

alter TABLE thesisInfo alter column	thesisTitle nvarchar(300) null		--论文题目,modi by lw 2014-4-18根据程远老师的意见延长至300字
alter TABLE thesisInfo alter column	periodicalName nvarchar(100) not null--期刊(会议）名称,modi by lw 2014-4-18根据程远老师的意见延长至100字

select * from thesisInfo
select str(affectFact/100.0,4,2), * from thesisInfo
drop table thesisInfo
CREATE TABLE thesisInfo(
	thesisId varchar(10) not null,		--主键：论文编号,本系统使用第100号号码发生器产生（'LW'+4位年份代码+4位流水号）
	thesisTitle nvarchar(300) null,		--论文题目,modi by lw 2014-4-18根据程远老师的意见延长至300字
	summary nvarchar(300) null,			--内容简介
	keys nvarchar(30) null,				--关键字：多个关键字使用","分隔

	firstAuthorType smallint null,		--第一作者类别：1->教工，9->学生, 0->情况不明 add by lw 2014-4-4
	firstAuthorID varchar(10) null,		--第一作者工号 modi by lw 2014-4-4根据程远老师的要求支持非系统用户
	firstAuthor nvarchar(30) not null,	--第一作者姓名。冗余设计
	tutorID varchar(10) null,			--导师工号:当第一作者为学生时要求输入
	tutorName nvarchar(30) null,		--导师姓名:当第一作者为学生时要求输入。冗余设计

	--elseAuthorID varchar(100) not null,	--其他作者工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放,这个字段暂时没有意思，没有启用！del by lw 2014-4-8
	elseAuthor nvarchar(300) not null,	--其他作者姓名。支持多个人，采用"1":"V1";"2":"V2";键值对格式存放。
	
	periodicalName nvarchar(100) not null,--期刊(会议）名称,modi by lw 2014-4-18根据程远老师的意见延长至100字
	ISSN varchar(16) not null,			--期刊号：国际标准刊号ISSN 以ISSN为前缀，由8位数字组成。8位数字分为前后两段各4位，中间用连接号相连，格式如下：ISSN XXXX-XXXX
										--		  国内统一刊号CN CN刊号标准格式是：CNXX-XXXX，其中前两位是各省（区、市）区号。而印有“CN（HK）”或“CNXXX（HK）/R”的依然不是合法的国内统一刊号。
	periodicalNature int not null,		--期刊性质：由第50号代码字典
	periodicalType int not null,		--期刊类别：由第51号代码字典
	publishTime smalldatetime null,		--发表（会议）时间
	authorRank smallint default(0),		--作者排名
	thesisType int null,				--论文分类：引用第52代码字典
	affectFact smallint default(0),		--影响因子:应该是小数，采用*100计算
	citedTimes smallint default(0),		--被引用频次
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_thesisInfo] PRIMARY KEY CLUSTERED 
(
	[thesisId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--关键字索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo] ON [dbo].[thesisInfo] 
(
	[keys] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--第一作者工号索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_0] ON [dbo].[thesisInfo] 
(
	[firstAuthorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--第一作者姓名索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_1] ON [dbo].[thesisInfo] 
(
	[firstAuthor] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--期刊号索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_2] ON [dbo].[thesisInfo] 
(
	[ISSN] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--期刊性质索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_3] ON [dbo].[thesisInfo] 
(
	[periodicalNature] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--期刊类别索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_4] ON [dbo].[thesisInfo] 
(
	[periodicalType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--发表（会议）时间索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_5] ON [dbo].[thesisInfo] 
(
	[publishTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--论文分类索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_6] ON [dbo].[thesisInfo] 
(
	[thesisType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--导师工号索引：
CREATE NONCLUSTERED INDEX [IX_thesisInfo_7] ON [dbo].[thesisInfo] 
(
	[tutorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.专著登记表：
drop table monographInfo
CREATE TABLE monographInfo(
	monographId varchar(10) not null,		--主键：专著编号,本系统使用第101号号码发生器产生（'ZZ'+4位年份代码+4位流水号）
	monographName nvarchar(40) null,		--专著名称
	summary nvarchar(300) null,				--内容简介
	keys nvarchar(30) null,					--关键字：多个关键字使用","分隔
	monographType int not null,				--专著类别：由第53号代码字典定义
	firstAuthorType smallint null,			--第一作者类别：1->教工，9->学生
	firstAuthorID varchar(10) not null,		--第一作者工号
	firstAuthor nvarchar(30) not null,		--第一作者姓名。冗余设计
	tutorID varchar(10) null,				--导师工号:当第一作者为学生时要求输入
	tutorName nvarchar(30) null,			--导师姓名:当第一作者为学生时要求输入。冗余设计

	elseAuthorID varchar(100) not null,		--其他作者工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	elseAuthor nvarchar(300) not null,		--其他作者姓名。支持多个人，采用"XXX,XXX"格式存放。冗余设计

	ISBN varchar(30) null,					--出版号，全称为“标准书号”，是标识出版管理部门注册的出版者所出版的每一种出版物的每个版本的国际性的唯一代码。
											--我国采用国际标准书号International Standard Book Numbering（ISBN）作为中国标准书号。
											--一个完整的国际标准书号由标识符ISBN和10位（新标准前面加了EAN前缀3位数字变为13位码）数字组成，其中数字又包括四部分：
											--组区号：代表出版者的国家、地理区域，由国际ISBN中心统一设置分配，我国为“7”，表示可以出1亿种书。
											--出版者号：代表一个组区，由中国ISBN中心分别设置和分配，长度为2至7位。
											--出版序号：即1个图书1个号，由出版社自行分配。
											--校验码：固定用1位数字。
											--例如：《江泽民文选》第一卷（平装本）书号为ISBN 7-01-005674-9。
	publishHouse nvarchar(60) null,			--出版社
	publishTime smalldatetime null,			--出版时间
	frontCoverFile varchar(128) null,		--封面上传的图片路径
	summaryCopyFile varchar(128) null,		--内容简介的图片路径
	backCoverFile varchar(128) null,		--封底上传的图片路径
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_monographInfo] PRIMARY KEY CLUSTERED 
(
	[monographId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--关键字索引：
CREATE NONCLUSTERED INDEX [IX_monographInfo] ON [dbo].[monographInfo] 
(
	[keys] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--类别索引：
CREATE NONCLUSTERED INDEX [IX_monographInfo_0] ON [dbo].[monographInfo] 
(
	[monographType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--作者工号索引：
CREATE NONCLUSTERED INDEX [IX_monographInfo_1] ON [dbo].[monographInfo] 
(
	[firstAuthorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--作者姓名索引：
CREATE NONCLUSTERED INDEX [IX_monographInfo_2] ON [dbo].[monographInfo] 
(
	[firstAuthor] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--ISBN书号索引：
CREATE NONCLUSTERED INDEX [IX_monographInfo_3] ON [dbo].[monographInfo] 
(
	[ISBN] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--出版时间索引：
CREATE NONCLUSTERED INDEX [IX_monographInfo_4] ON [dbo].[monographInfo] 
(
	[publishTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--3.专利登记表
drop table patentInfo
CREATE TABLE patentInfo(
	patentId varchar(10) not null,		--主键：专利编号,本系统使用第102号号码发生器产生（'ZL'+4位年份代码+4位流水号）
	invenName nvarchar(40) not null,	--发明名称
	patentType int not null,			--专利类型：由第54号代码字典定义
	invenManID varchar(100) null,		--申请人（发明人，当专利批准后申请人就是发明人）工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	invenMan nvarchar(300) null,		--申请人（发明人，当专利批准后申请人就是发明人），采用"XXX,XXX"格式存放。冗余设计
	applyTime smalldatetime null,		--申请时间
	isWarranted char(1) default('N'),	--是否已授权：'N'->未授权，'Y'已授权
	warrantTime smalldatetime null,		--授权时间
	patentNum varchar(13) null,			--专利号：专利申请号编号形式（共12位数字，加上一个小数点）:申请年号+专利申请种类+申请顺序号+计算机校验位
										--前4位数字表示申请年号，第5位数字表示申请种类：
										--1=发明专利申请,2=实用新型专利申请,3=外观设计专利申请,8=进入中国国家阶段的PCT发明专利申请,9=进入中国国家阶段的PCT实用新型专利申请
										--例：2003 1 0100002.X 表示发明专利申请
										--    2003 2 0100002.5 表示实用新型专利申请
	patentCopyFile varchar(128) null,	--专利复印件上传图片
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_patentInfo] PRIMARY KEY CLUSTERED 
(
	[patentId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--专利类型索引：
CREATE NONCLUSTERED INDEX [IX_patentInfo_1] ON [dbo].[patentInfo] 
(
	[patentType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--申请人（发明人）工号索引：
CREATE NONCLUSTERED INDEX [IX_patentInfo_2] ON [dbo].[patentInfo] 
(
	[invenManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--申请人（发明人）姓名索引：
CREATE NONCLUSTERED INDEX [IX_patentInfo_3] ON [dbo].[patentInfo] 
(
	[invenMan] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--申请时间索引：
CREATE NONCLUSTERED INDEX [IX_patentInfo_4] ON [dbo].[patentInfo] 
(
	[applyTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--授权时间索引：
CREATE NONCLUSTERED INDEX [IX_patentInfo_5] ON [dbo].[patentInfo] 
(
	[warrantTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--4.获奖信息登记表
drop table awardInfo
CREATE TABLE awardInfo(
	awardId varchar(10) not null,		--主键：获奖编号,本系统使用第103号号码发生器产生（'HJ'+4位年份代码+4位流水号）
	awardName nvarchar(30) not null,	--获奖名称
	completeManId nvarchar(100) null,	--完成人员及排名工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放，如果是外部人员空缺编号
	completeMan nvarchar(300) null,		--完成人员及排名，采用"XXX,XXX"格式存放。冗余设计，如果是外部人员空缺编号
	unitRank nvarchar(300) null,		--单位排名：支持多个单位，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	awardTime smalldatetime null,		--获奖时间：采用"yyyy-MM-dd"格式存放
	certiCopyFile varchar(128) null,	--证书复印件上传图片
	remark nvarchar(100) null,			--备注
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_awardInfo] PRIMARY KEY CLUSTERED 
(
	[awardId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--获奖名称索引：
CREATE NONCLUSTERED INDEX [IX_awardInfo_1] ON [dbo].[awardInfo] 
(
	[awardName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--获奖时间索引：
CREATE NONCLUSTERED INDEX [IX_awardInfo_2] ON [dbo].[awardInfo] 
(
	[awardTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--5.科研项目登记表
drop table projectInfo
CREATE TABLE projectInfo(
	projectId varchar(10) not null,		--主键：项目内部编号,本系统使用第104号号码发生器产生（'XM'+4位年份代码+4位流水号）
	projectNum varchar(30) null,		--项目编号（学校的编号）
	consignUnit nvarchar(60) null,		--委托单位
	consignUnitLocateCode varchar(6) null,	--委托单位来源地区编码
	securityClass int null,				--密级：由第57号代码字典定义
	projectName nvarchar(30) not null,	--项目名称
	applyTime smalldatetime null,		--项目申报时间
	
	projectNature int not null,			--项目性质：由第55号代码字典定义
	projectType int null,				--项目类别：由第56号代码字典定义
	projectFund numeric(12,2) null,		--项目经费（万元）
	startTime smalldatetime null,		--开始时间
	endTime smalldatetime null,			--结束时间
	projectManagerID varchar(10) null,	--项目负责人工号
	projectManager nvarchar(30) null,	--项目负责人
	summary nvarchar(300) null,			--研究内容摘要
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_projectInfo] PRIMARY KEY CLUSTERED 
(
	[projectId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--申报时间索引：
CREATE NONCLUSTERED INDEX [IX_projectInfo_1] ON [dbo].[projectInfo] 
(
	[applyTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--项目编号索引：
CREATE NONCLUSTERED INDEX [IX_projectInfo_2] ON [dbo].[projectInfo] 
(
	[projectNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--密级索引：
CREATE NONCLUSTERED INDEX [IX_projectInfo_3] ON [dbo].[projectInfo] 
(
	[securityClass] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--项目性质索引：
CREATE NONCLUSTERED INDEX [IX_projectInfo_4] ON [dbo].[projectInfo] 
(
	[projectNature] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--项目类别索引：
CREATE NONCLUSTERED INDEX [IX_projectInfo_5] ON [dbo].[projectInfo] 
(
	[projectType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--项目负责人工号索引：
CREATE NONCLUSTERED INDEX [IX_projectInfo_6] ON [dbo].[projectInfo] 
(
	[projectManagerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryThesisInfoLocMan
/*
	name:		queryThesisInfoLocMan
	function:	1.查询指定论文是否有人正在编辑
	input: 
				@thesisId varchar(10),		--论文编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的论文不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryThesisInfoLocMan
	@thesisId varchar(10),		--论文编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	set @Ret = 0
GO


drop PROCEDURE lockThesisInfo4Edit
/*
	name:		lockThesisInfo4Edit
	function:	2.锁定论文编辑，避免编辑冲突
	input: 
				@thesisId varchar(10),		--论文编号
				@lockManID varchar(10) output,	--锁定人，如果当前论文正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的论文不存在，2:要锁定的论文正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockThesisInfo4Edit
	@thesisId varchar(10),		--论文编号
	@lockManID varchar(10) output,	--锁定人，如果当前论文正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的论文是否存在
	declare @count as int
	set @count=(select count(*) from thesisInfo where thesisId= @thesisId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update thesisInfo
	set lockManID = @lockManID 
	where thesisId= @thesisId
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定论文编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了论文['+ @thesisId +']为独占式编辑。')
GO

drop PROCEDURE unlockThesisInfoEditor
/*
	name:		unlockThesisInfoEditor
	function:	3.释放论文编辑锁
				注意：本过程不检查论文是否存在！
	input: 
				@thesisId varchar(10),			--论文编号
				@lockManID varchar(10) output,	--锁定人，如果当前论文正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockThesisInfoEditor
	@thesisId varchar(10),			--论文编号
	@lockManID varchar(10) output,	--锁定人，如果当前论文呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update thesisInfo set lockManID = '' where thesisId= @thesisId
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
	values(@lockManID, @lockManName, getdate(), '释放论文编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了论文['+ @thesisId +']的编辑锁。')
GO

drop PROCEDURE addThesisInfo
/*
	name:		addThesisInfo
	function:	4.添加论文信息
	input: 
				@thesisTitle nvarchar(300),	--论文题目
				@summary nvarchar(300),		--内容简介
				@keys nvarchar(30),			--关键字：多个关键字使用","分隔

				@firstAuthorType smallint,	--第一作者类别：1->教工，9->学生
				@firstAuthorID varchar(10),	--第一作者工号
				@firstAuthor nvarchar(30),	--第一作者姓名。非系统用户直接使用姓名
				@tutorID varchar(10),		--导师工号:当第一作者为学生时要求输入
				@tutorName nvarchar(30),	--导师姓名:当第一作者为学生时要求输入。非系统用户直接使用姓名

				@elseAuthor nvarchar(300),	--其他作者姓名。支持多个人，采用"1":"V1";"2":"V2";键值对格式存放。
				
				@periodicalName nvarchar(100),--期刊(会议）名称
				@ISSN varchar(16),			--期刊号：国际标准刊号ISSN 以ISSN为前缀，由8位数字组成。8位数字分为前后两段各4位，中间用连接号相连，格式如下：ISSN XXXX-XXXX
											--		  国内统一刊号CN CN刊号标准格式是：CNXX-XXXX，其中前两位是各省（区、市）区号。而印有“CN（HK）”或“CNXXX（HK）/R”的依然不是合法的国内统一刊号。
				@periodicalNature int,		--期刊性质：由第50号代码字典
				@periodicalType int,		--期刊类别：由第51号代码字典
				@publishTime varchar(10),	--发表（会议）时间:采用“yyyy-MM-dd”格式存放
				@authorRank smallint,		--作者排名
				@thesisType int,			--论文分类：引用第52代码字典
				@affectFact smallint,		--影响因子:应该是小数，采用*100计算
				@citedTimes smallint,		--被引用频次

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,	--添加时间
				@thesisId varchar(10) output		--论文编号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: modi by lw 2014-4-4根据程远老师的要求支持非系统用户，2014-4-9将其他作者改成键值对方式
				modi by lw 2014-4-18根据程远老师的意见延长thesisTitle和periodicalName字段
*/
create PROCEDURE addThesisInfo
	@thesisTitle nvarchar(300),	--论文题目
	@summary nvarchar(300),		--内容简介
	@keys nvarchar(30),			--关键字：多个关键字使用","分隔

	@firstAuthorType smallint,	--第一作者类别：1->教工，9->学生
	@firstAuthorID varchar(10),	--第一作者工号
	@firstAuthor nvarchar(30),	--第一作者姓名。非系统用户直接使用姓名
	@tutorID varchar(10),		--导师工号:当第一作者为学生时要求输入
	@tutorName nvarchar(30),	--导师姓名:当第一作者为学生时要求输入。非系统用户直接使用姓名

	@elseAuthor nvarchar(300),	--其他作者姓名。支持多个人，采用"1":"V1";"2":"V2";键值对格式存放。
	
	@periodicalName nvarchar(100),--期刊(会议）名称
	@ISSN varchar(16),			--期刊号：国际标准刊号ISSN 以ISSN为前缀，由8位数字组成。8位数字分为前后两段各4位，中间用连接号相连，格式如下：ISSN XXXX-XXXX
										--		  国内统一刊号CN CN刊号标准格式是：CNXX-XXXX，其中前两位是各省（区、市）区号。而印有“CN（HK）”或“CNXXX（HK）/R”的依然不是合法的国内统一刊号。
	@periodicalNature int,		--期刊性质：由第50号代码字典
	@periodicalType int,		--期刊类别：由第51号代码字典
	@publishTime varchar(10),	--发表（会议）时间:采用“yyyy-MM-dd”格式存放
	@authorRank smallint,		--作者排名
	@thesisType int,			--论文分类：引用第52代码字典
	@affectFact smallint,		--影响因子:应该是小数，采用*100计算
	@citedTimes smallint,		--被引用频次

	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@thesisId varchar(10) output		--论文编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生论文编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 100, 1, @curNumber output
	set @thesisId = @curNumber

	--取第一作者姓名/导师姓名:当第一作者为学生时要求输入/创建人的姓名：
	declare @createManName nvarchar(30)
	if (@firstAuthorID is not null and @firstAuthorID<>'')
		set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=1)
		set @tutorName = ''
	else if (@tutorID is not null and @tutorID<>'')
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert thesisInfo(thesisId, thesisTitle, summary, keys, 
					firstAuthorType, firstAuthorID, firstAuthor, tutorID, tutorName,  elseAuthor, 
					periodicalName, ISSN, periodicalNature, periodicalType, publishTime, 
					authorRank, thesisType, affectFact,citedTimes,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@thesisId, @thesisTitle, @summary, @keys, 
					@firstAuthorType, @firstAuthorID, @firstAuthor, @tutorID, @tutorName, @elseAuthor, 
					@periodicalName, @ISSN, @periodicalNature, @periodicalType, @publishTime, 
					@authorRank, @thesisType, @affectFact,@citedTimes,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记论文', '系统根据用户' + @createManName + 
					'的要求登记论文“' + @thesisTitle + '['+@thesisId+']”。')
GO
--测试：
declare @Ret		int, @createTime smalldatetime, @thesisId varchar(10)
exec dbo.addThesisInfo '测试外来作者','测试','测试',1,'','王小二','','','','测试杂志','1213',1,1,'2014-04-04',1,1,10.05,1,'G201300052',
	@ret output,@createTime output, @thesisId output
select * from thesisInfo order by thesisId desc


drop PROCEDURE updateThesisInfo
/*
	name:		updateThesisInfo
	function:	5.修改论文信息
	input: 
				@thesisId varchar(10),		--论文编号
				@thesisTitle nvarchar(300),	--论文题目
				@summary nvarchar(300),		--内容简介
				@keys nvarchar(30),			--关键字：多个关键字使用","分隔

				@firstAuthorType smallint,	--第一作者类别：1->教工，9->学生
				@firstAuthorID varchar(10),	--第一作者工号
				@firstAuthor nvarchar(30),	--第一作者姓名。非系统用户直接使用姓名
				@tutorID varchar(10),		--导师工号:当第一作者为学生时要求输入
				@tutorName nvarchar(30),	--导师姓名:当第一作者为学生时要求输入。非系统用户直接使用姓名

				@elseAuthor nvarchar(300),	--其他作者姓名。支持多个人，采用"1":"V1";"2":"V2";键值对格式存放。
				
				@periodicalName nvarchar(100),--期刊(会议）名称
				@ISSN varchar(16),			--期刊号：国际标准刊号ISSN 以ISSN为前缀，由8位数字组成。8位数字分为前后两段各4位，中间用连接号相连，格式如下：ISSN XXXX-XXXX
													--		  国内统一刊号CN CN刊号标准格式是：CNXX-XXXX，其中前两位是各省（区、市）区号。而印有“CN（HK）”或“CNXXX（HK）/R”的依然不是合法的国内统一刊号。
				@periodicalNature int,		--期刊性质：由第50号代码字典
				@periodicalType int,		--期刊类别：由第51号代码字典
				@publishTime varchar(10),	--发表（会议）时间:采用“yyyy-MM-dd”格式存放
				@authorRank smallint,		--作者排名
				@thesisType int,				--论文分类：引用第52代码字典
				@affectFact smallint,		--影响因子:应该是小数，采用*10计算
				@citedTimes smallint,		--被引用频次

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的论文不存在，
							2:要修改的论文正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: modi by lw 2014-4-4根据程远老师的要求支持非系统用户，2014-4-9将其他作者改成键值对方式
				modi by lw 2014-4-18根据程远老师的意见延长thesisTitle和periodicalName字段
*/
create PROCEDURE updateThesisInfo
	@thesisId varchar(10),		--论文编号
	@thesisTitle nvarchar(300),	--论文题目
	@summary nvarchar(300),		--内容简介
	@keys nvarchar(30),			--关键字：多个关键字使用","分隔

	@firstAuthorType smallint,	--第一作者类别：1->教工，9->学生
	@firstAuthorID varchar(10),	--第一作者工号
	@firstAuthor nvarchar(30),	--第一作者姓名。非系统用户直接使用姓名
	@tutorID varchar(10),		--导师工号:当第一作者为学生时要求输入
	@tutorName nvarchar(30),	--导师姓名:当第一作者为学生时要求输入。非系统用户直接使用姓名

	@elseAuthor nvarchar(300),	--其他作者姓名。支持多个人，采用"1":"V1";"2":"V2";键值对格式存放。
	
	@periodicalName nvarchar(100),--期刊(会议）名称
	@ISSN varchar(16),			--期刊号：国际标准刊号ISSN 以ISSN为前缀，由8位数字组成。8位数字分为前后两段各4位，中间用连接号相连，格式如下：ISSN XXXX-XXXX
										--		  国内统一刊号CN CN刊号标准格式是：CNXX-XXXX，其中前两位是各省（区、市）区号。而印有“CN（HK）”或“CNXXX（HK）/R”的依然不是合法的国内统一刊号。
	@periodicalNature int,		--期刊性质：由第50号代码字典
	@periodicalType int,		--期刊类别：由第51号代码字典
	@publishTime varchar(10),	--发表（会议）时间:采用“yyyy-MM-dd”格式存放
	@authorRank smallint,		--作者排名
	@thesisType int,				--论文分类：引用第52代码字典
	@affectFact smallint,		--影响因子:应该是小数，采用*10计算
	@citedTimes smallint,		--被引用频次

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的论文是否存在
	declare @count as int
	set @count=(select count(*) from thesisInfo where thesisId= @thesisId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--取第一作者姓名/导师姓名:当第一作者为学生时要求输入/创建人的姓名：
	if (@firstAuthorID is not null and @firstAuthorID<>'')
		set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=1)
		set @tutorName = ''
	else if (@tutorID is not null and @tutorID<>'')
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	
	set @modiTime = getdate()
	update thesisInfo
	set thesisId = @thesisId, thesisTitle = @thesisTitle, summary = @summary, keys = @keys, 
		firstAuthorType = @firstAuthorType, firstAuthorID = @firstAuthorID, firstAuthor = @firstAuthor, 
		tutorID = @tutorID, tutorName = @tutorName, elseAuthor = @elseAuthor, 
		periodicalName = @periodicalName, ISSN = @ISSN, periodicalNature = @periodicalNature, periodicalType = @periodicalType, 
		publishTime = @publishTime, authorRank = @authorRank, thesisType = @thesisType, affectFact = @affectFact, citedTimes = @citedTimes,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where thesisId= @thesisId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改论文', '系统根据用户' + @modiManName + 
					'的要求修改了论文“' + @thesisTitle + '['+@thesisId+']”的登记信息。')
GO

drop PROCEDURE delThesisInfo
/*
	name:		delThesisInfo
	function:	6.删除指定的论文
	input: 
				@thesisId varchar(10),		--论文编号
				@delManID varchar(10) output,	--删除人，如果当前论文正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的论文不存在，2：要删除的论文正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delThesisInfo
	@thesisId varchar(10),		--论文编号
	@delManID varchar(10) output,	--删除人，如果当前论文正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的论文是否存在
	declare @count as int
	set @count=(select count(*) from thesisInfo where thesisId= @thesisId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete thesisInfo where thesisId= @thesisId
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除论文', '用户' + @delManName
												+ '删除了论文['+@thesisId+']。')

GO


--论文的查询语句：
select t.thesisId, t.thesisTitle, t.summary, t.keys,
	t.firstAuthorType, t.firstAuthorID, t.firstAuthor, t.tutorID, t.tutorName,
	t.elseAuthorID, t.elseAuthor,
	t.periodicalName, t.ISSN, t.periodicalNature, cd1.objDesc periodicalNatureDesc, t.periodicalType, cd2.objDesc periodicalTypeDesc, t.publishTime,
	t.authorRank, t.thesisType, t.affectFact, t.citedTimes
from thesisInfo t
left join codeDictionary cd1 on t.periodicalNature = cd1.objCode and cd1.classCode=50
left join codeDictionary cd2 on t.periodicalType = cd2.objCode and cd2.classCode=51



drop PROCEDURE queryMonographInfoLocMan
/*
	name:		queryMonographInfoLocMan
	function:	11.查询指定专著是否有人正在编辑
	input: 
				@monographId varchar(10),	--专著编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的专著不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryMonographInfoLocMan
	@monographId varchar(10),	--专著编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	set @Ret = 0
GO


drop PROCEDURE lockMonographInfo4Edit
/*
	name:		lockMonographInfo4Edit
	function:	12.锁定专著编辑，避免编辑冲突
	input: 
				@monographId varchar(10),		--专著编号
				@lockManID varchar(10) output,	--锁定人，如果当前专著正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的专著不存在，2:要锁定的专著正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockMonographInfo4Edit
	@monographId varchar(10),		--专著编号
	@lockManID varchar(10) output,	--锁定人，如果当前专著正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的专著是否存在
	declare @count as int
	set @count=(select count(*) from monographInfo where monographId= @monographId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update monographInfo
	set lockManID = @lockManID 
	where monographId= @monographId
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定专著编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了专著['+ @monographId +']为独占式编辑。')
GO

drop PROCEDURE unlockMonographInfoEditor
/*
	name:		unlockMonographInfoEditor
	function:	13.释放专著编辑锁
				注意：本过程不检查专著是否存在！
	input: 
				@monographId varchar(10),		--专著编号
				@lockManID varchar(10) output,	--锁定人，如果当前专著正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockMonographInfoEditor
	@monographId varchar(10),		--专著编号
	@lockManID varchar(10) output,	--锁定人，如果当前专著呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update monographInfo set lockManID = '' where monographId= @monographId
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
	values(@lockManID, @lockManName, getdate(), '释放专著编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了专著['+ @monographId +']的编辑锁。')
GO


drop PROCEDURE addMonographInfo
/*
	name:		addMonographInfo
	function:	14.添加专著信息
	input: 
				@monographName nvarchar(40),		--专著名称
				@summary nvarchar(300),				--内容简介
				@keys nvarchar(30) ,				--关键字：多个关键字使用","分隔
				@monographType int,					--专著类别：由第53号代码字典定义
				@firstAuthorType smallint,			--第一作者类别：1->教工，9->学生
				@firstAuthorID varchar(10),			--第一作者工号
				@tutorID varchar(10),				--导师工号:当第一作者为学生时要求输入

				@elseAuthorID varchar(10),			--其他作者工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@elseAuthor nvarchar(30),			--其他作者姓名。支持多个人，采用"XXX,XXX"格式存放。冗余设计

				@ISBN varchar(30),					--出版号，全称为“标准书号”，是标识出版管理部门注册的出版者所出版的每一种出版物的每个版本的国际性的唯一代码。
														--我国采用国际标准书号International Standard Book Numbering（ISBN）作为中国标准书号。
														--一个完整的国际标准书号由标识符ISBN和10位（新标准前面加了EAN前缀3位数字变为13位码）数字组成，其中数字又包括四部分：
														--组区号：代表出版者的国家、地理区域，由国际ISBN中心统一设置分配，我国为“7”，表示可以出1亿种书。
														--出版者号：代表一个组区，由中国ISBN中心分别设置和分配，长度为2至7位。
														--出版序号：即1个图书1个号，由出版社自行分配。
														--校验码：固定用1位数字。
														--例如：《江泽民文选》第一卷（平装本）书号为ISBN 7-01-005674-9。
				@publishHouse nvarchar(60),			--出版社
				@publishTime varchar(10),			--出版时间
				@frontCoverFile varchar(128),		--封面上传的图片路径
				@summaryCopyFile varchar(128),		--内容简介的图片路径
				@backCoverFile varchar(128),		--封底上传的图片路径

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,	--添加时间
				@monographId varchar(10) output		--专著编号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addMonographInfo
	@monographName nvarchar(40),		--专著名称
	@summary nvarchar(300),				--内容简介
	@keys nvarchar(30) ,				--关键字：多个关键字使用","分隔
	@monographType int,					--专著类别：由第53号代码字典定义
	@firstAuthorType smallint,			--第一作者类别：1->教工，9->学生
	@firstAuthorID varchar(10),			--第一作者工号
	@tutorID varchar(10),				--导师工号:当第一作者为学生时要求输入

	@elseAuthorID varchar(10),			--其他作者工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@elseAuthor nvarchar(30),			--其他作者姓名。支持多个人，采用"XXX,XXX"格式存放。冗余设计

	@ISBN varchar(30),					--出版号，全称为“标准书号”，是标识出版管理部门注册的出版者所出版的每一种出版物的每个版本的国际性的唯一代码。
											--我国采用国际标准书号International Standard Book Numbering（ISBN）作为中国标准书号。
											--一个完整的国际标准书号由标识符ISBN和10位（新标准前面加了EAN前缀3位数字变为13位码）数字组成，其中数字又包括四部分：
											--组区号：代表出版者的国家、地理区域，由国际ISBN中心统一设置分配，我国为“7”，表示可以出1亿种书。
											--出版者号：代表一个组区，由中国ISBN中心分别设置和分配，长度为2至7位。
											--出版序号：即1个图书1个号，由出版社自行分配。
											--校验码：固定用1位数字。
											--例如：《江泽民文选》第一卷（平装本）书号为ISBN 7-01-005674-9。
	@publishHouse nvarchar(60),			--出版社
	@publishTime varchar(10),			--出版时间
	@frontCoverFile varchar(128),		--封面上传的图片路径
	@summaryCopyFile varchar(128),		--内容简介的图片路径
	@backCoverFile varchar(128),		--封底上传的图片路径

	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@monographId varchar(10) output		--专著编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生专著编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 101, 1, @curNumber output
	set @monographId = @curNumber

	--取第一作者姓名/导师姓名:当第一作者为学生时要求输入/创建人的姓名：
	declare @firstAuthor nvarchar(30), @tutorName nvarchar(30), @createManName nvarchar(30)
	set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=9)
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	else
		set @tutorName = ''
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert monographInfo(monographId, monographName, summary, keys, monographType,
					firstAuthorType, firstAuthorID, firstAuthor, tutorID, tutorName, elseAuthorID, elseAuthor, 
					ISBN, publishHouse, publishTime, frontCoverFile, 
					summaryCopyFile, backCoverFile,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@monographId, @monographName, @summary, @keys, @monographType,
					@firstAuthorType, @firstAuthorID, @firstAuthor, @tutorID, @tutorName, @elseAuthorID, @elseAuthor, 
					@ISBN, @publishHouse, @publishTime, @frontCoverFile, 
					@summaryCopyFile, @backCoverFile,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记专著', '系统根据用户' + @createManName + 
					'的要求登记专著“' + @monographName + '['+@monographId+']”。')
GO

drop PROCEDURE updateMonographInfo
/*
	name:		updateMonographInfo
	function:	15.修改专著信息
	input: 
				@monographId varchar(10),			--专著编号
				@monographName nvarchar(40),		--专著名称
				@summary nvarchar(300),				--内容简介
				@keys nvarchar(30) ,				--关键字：多个关键字使用","分隔
				@monographType int,					--专著类别：由第53号代码字典定义
				@firstAuthorType smallint,			--第一作者类别：1->教工，9->学生
				@firstAuthorID varchar(10),			--第一作者工号
				@tutorID varchar(10),				--导师工号:当第一作者为学生时要求输入

				@elseAuthorID varchar(10),			--其他作者工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@elseAuthor nvarchar(30),			--其他作者姓名。支持多个人，采用"XXX,XXX"格式存放。冗余设计

				@ISBN varchar(30),					--出版号，全称为“标准书号”，是标识出版管理部门注册的出版者所出版的每一种出版物的每个版本的国际性的唯一代码。
														--我国采用国际标准书号International Standard Book Numbering（ISBN）作为中国标准书号。
														--一个完整的国际标准书号由标识符ISBN和10位（新标准前面加了EAN前缀3位数字变为13位码）数字组成，其中数字又包括四部分：
														--组区号：代表出版者的国家、地理区域，由国际ISBN中心统一设置分配，我国为“7”，表示可以出1亿种书。
														--出版者号：代表一个组区，由中国ISBN中心分别设置和分配，长度为2至7位。
														--出版序号：即1个图书1个号，由出版社自行分配。
														--校验码：固定用1位数字。
														--例如：《江泽民文选》第一卷（平装本）书号为ISBN 7-01-005674-9。
				@publishHouse nvarchar(60),			--出版社
				@publishTime varchar(10),			--出版时间
				@frontCoverFile varchar(128),		--封面上传的图片路径
				@summaryCopyFile varchar(128),		--内容简介的图片路径
				@backCoverFile varchar(128),		--封底上传的图片路径

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的专著不存在，
							2:要修改的专著正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updateMonographInfo
	@monographId varchar(10),			--专著编号
	@monographName nvarchar(40),		--专著名称
	@summary nvarchar(300),				--内容简介
	@keys nvarchar(30) ,				--关键字：多个关键字使用","分隔
	@monographType int,					--专著类别：由第53号代码字典定义
	@firstAuthorType smallint,			--第一作者类别：1->教工，9->学生
	@firstAuthorID varchar(10),			--第一作者工号
	@tutorID varchar(10),				--导师工号:当第一作者为学生时要求输入

	@elseAuthorID varchar(10),			--其他作者工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@elseAuthor nvarchar(30),			--其他作者姓名。支持多个人，采用"XXX,XXX"格式存放。冗余设计

	@ISBN varchar(30),					--出版号，全称为“标准书号”，是标识出版管理部门注册的出版者所出版的每一种出版物的每个版本的国际性的唯一代码。
											--我国采用国际标准书号International Standard Book Numbering（ISBN）作为中国标准书号。
											--一个完整的国际标准书号由标识符ISBN和10位（新标准前面加了EAN前缀3位数字变为13位码）数字组成，其中数字又包括四部分：
											--组区号：代表出版者的国家、地理区域，由国际ISBN中心统一设置分配，我国为“7”，表示可以出1亿种书。
											--出版者号：代表一个组区，由中国ISBN中心分别设置和分配，长度为2至7位。
											--出版序号：即1个图书1个号，由出版社自行分配。
											--校验码：固定用1位数字。
											--例如：《江泽民文选》第一卷（平装本）书号为ISBN 7-01-005674-9。
	@publishHouse nvarchar(60),			--出版社
	@publishTime varchar(10),			--出版时间
	@frontCoverFile varchar(128),		--封面上传的图片路径
	@summaryCopyFile varchar(128),		--内容简介的图片路径
	@backCoverFile varchar(128),		--封底上传的图片路径

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的专著是否存在
	declare @count as int
	set @count=(select count(*) from monographInfo where monographId= @monographId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--取第一作者姓名/导师姓名:当第一作者为学生时要求输入：
	declare @firstAuthor nvarchar(30), @tutorName nvarchar(30)
	set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=9)
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	else
		set @tutorName = ''
	
	set @modiTime = getdate()
	update monographInfo
	set monographId = @monographId, monographName = @monographName, summary = @summary, keys = @keys, monographType = @monographType,
		firstAuthorType = @firstAuthorType, firstAuthorID = @firstAuthorID, firstAuthor = @firstAuthor, tutorID = @tutorID, tutorName = @tutorName, 
		elseAuthorID = @elseAuthorID, elseAuthor = @elseAuthor, 
		ISBN = @ISBN, publishHouse = @publishHouse, publishTime = @publishTime, 
		frontCoverFile = @frontCoverFile, summaryCopyFile = @summaryCopyFile, backCoverFile = @backCoverFile,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where monographId= @monographId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改专著', '系统根据用户' + @modiManName + 
					'的要求修改了专著“' + @monographName + '['+@monographId+']”的登记信息。')
GO

drop PROCEDURE delMonographInfo
/*
	name:		delMonographInfo
	function:	6.删除指定的专著
	input: 
				@monographId varchar(10),		--专著编号
				@delManID varchar(10) output,	--删除人，如果当前专著正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的专著不存在，2：要删除的专著正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delMonographInfo
	@monographId varchar(10),		--专著编号
	@delManID varchar(10) output,	--删除人，如果当前专著正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的专著是否存在
	declare @count as int
	set @count=(select count(*) from monographInfo where monographId= @monographId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete monographInfo where monographId= @monographId
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除专著', '用户' + @delManName
												+ '删除了专著['+@monographId+']。')

GO

--专著查询语句：
select m.monographId, m.monographName, m.summary, m.keys, 
	m.monographType, cd1.objDesc monographTypeDesc,
	m.firstAuthorType, m.firstAuthorID, m.firstAuthor, m.tutorID, m.tutorName,
	m.elseAuthorID, m.elseAuthor,
	m.ISBN, m.publishHouse, CONVERT(varchar(10), m.publishTime, 120) publishTime, m.frontCoverFile, m.summaryCopyFile, m.backCoverFile
from monographInfo m
left join codeDictionary cd1 on m.monographType = cd1.objCode and cd1.classCode = 53


drop PROCEDURE queryPatentInfoLocMan
/*
	name:		queryPatentInfoLocMan
	function:	11.查询指定专利是否有人正在编辑
	input: 
				@patentId varchar(10),		--专利编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的专利不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryPatentInfoLocMan
	@patentId varchar(10),		--专利编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	set @Ret = 0
GO


drop PROCEDURE lockPatentInfo4Edit
/*
	name:		lockPatentInfo4Edit
	function:	12.锁定专利编辑，避免编辑冲突
	input: 
				@patentId varchar(10),			--专利编号
				@lockManID varchar(10) output,	--锁定人，如果当前专利正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的专利不存在，2:要锁定的专利正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockPatentInfo4Edit
	@patentId varchar(10),			--专利编号
	@lockManID varchar(10) output,	--锁定人，如果当前专利正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的专利是否存在
	declare @count as int
	set @count=(select count(*) from patentInfo where patentId= @patentId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update patentInfo
	set lockManID = @lockManID 
	where patentId= @patentId
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定专利编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了专利['+ @patentId +']为独占式编辑。')
GO

drop PROCEDURE unlockPatentInfoEditor
/*
	name:		unlockPatentInfoEditor
	function:	13.释放专利编辑锁
				注意：本过程不检查专利是否存在！
	input: 
				@patentId varchar(10),			--专利编号
				@lockManID varchar(10) output,	--锁定人，如果当前专利正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockPatentInfoEditor
	@patentId varchar(10),			--专利编号
	@lockManID varchar(10) output,	--锁定人，如果当前专利呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update patentInfo set lockManID = '' where patentId= @patentId
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
	values(@lockManID, @lockManName, getdate(), '释放专利编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了专利['+ @patentId +']的编辑锁。')
GO



drop PROCEDURE addPatentInfo
/*
	name:		addPatentInfo
	function:	14.添加专利信息
	input: 
				@invenName nvarchar(40),	--发明名称
				@patentType int,			--专利类型：由第54号代码字典定义
				@invenManID varchar(100),	--申请人（发明人，当专利批准后申请人就是发明人）工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@invenMan nvarchar(300),	--申请人（发明人，当专利批准后申请人就是发明人），采用"XXX,XXX"格式存放。冗余设计
				@applyTime varchar(10),		--申请时间:采用"yyyy-MM-dd"格式存放
				@isWarranted char(1),		--是否已授权：'N'->未授权，'Y'已授权
				@warrantTime varchar(10),	--授权时间:采用"yyyy-MM-dd"格式存放
				@patentNum varchar(13),		--专利号：专利申请号编号形式（共12位数字，加上一个小数点）:申请年号+专利申请种类+申请顺序号+计算机校验位
											--前4位数字表示申请年号，第5位数字表示申请种类：
											--1=发明专利申请,2=实用新型专利申请,3=外观设计专利申请,8=进入中国国家阶段的PCT发明专利申请,9=进入中国国家阶段的PCT实用新型专利申请
											--例：2003 1 0100002.X 表示发明专利申请
											--    2003 2 0100002.5 表示实用新型专利申请
				@patentCopyFile varchar(128),--专利复印件上传图片

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@patentId varchar(10) output--专利编号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addPatentInfo
	@invenName nvarchar(40),	--发明名称
	@patentType int,			--专利类型：由第54号代码字典定义
	@invenManID varchar(100),	--申请人（发明人，当专利批准后申请人就是发明人）工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@invenMan nvarchar(300),	--申请人（发明人，当专利批准后申请人就是发明人），采用"XXX,XXX"格式存放。冗余设计
	@applyTime varchar(10),		--申请时间:采用"yyyy-MM-dd"格式存放
	@isWarranted char(1),		--是否已授权：'N'->未授权，'Y'已授权
	@warrantTime varchar(10),	--授权时间:采用"yyyy-MM-dd"格式存放
	@patentNum varchar(13),		--专利号：专利申请号编号形式（共12位数字，加上一个小数点）:申请年号+专利申请种类+申请顺序号+计算机校验位
								--前4位数字表示申请年号，第5位数字表示申请种类：
								--1=发明专利申请,2=实用新型专利申请,3=外观设计专利申请,8=进入中国国家阶段的PCT发明专利申请,9=进入中国国家阶段的PCT实用新型专利申请
								--例：2003 1 0100002.X 表示发明专利申请
								--    2003 2 0100002.5 表示实用新型专利申请
	@patentCopyFile varchar(128),--专利复印件上传图片

	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@patentId varchar(10) output--专利编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生专利编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 102, 1, @curNumber output
	set @patentId = @curNumber

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert patentInfo(patentId, invenName, patentType, invenManID, invenMan, 
					applyTime, isWarranted, warrantTime, patentNum,patentCopyFile,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@patentId, @invenName, @patentType, @invenManID, @invenMan, 
					@applyTime, @isWarranted, @warrantTime, @patentNum, @patentCopyFile,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记专利', '系统根据用户' + @createManName + 
					'的要求登记专利“' + @invenName + '['+@patentId+']”。')
GO

drop PROCEDURE updatePatentInfo
/*
	name:		updatePatentInfo
	function:	15.修改专利信息
	input: 
				@patentId varchar(10),		--专利编号
				@invenName nvarchar(40),	--发明名称
				@patentType int,			--专利类型：由第54号代码字典定义
				@invenManID varchar(100),	--申请人（发明人，当专利批准后申请人就是发明人）工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@invenMan nvarchar(300),	--申请人（发明人，当专利批准后申请人就是发明人），采用"XXX,XXX"格式存放。冗余设计
				@applyTime varchar(10),		--申请时间:采用"yyyy-MM-dd"格式存放
				@isWarranted char(1),		--是否已授权：'N'->未授权，'Y'已授权
				@warrantTime varchar(10),	--授权时间:采用"yyyy-MM-dd"格式存放
				@patentNum varchar(13),		--专利号：专利申请号编号形式（共12位数字，加上一个小数点）:申请年号+专利申请种类+申请顺序号+计算机校验位
											--前4位数字表示申请年号，第5位数字表示申请种类：
											--1=发明专利申请,2=实用新型专利申请,3=外观设计专利申请,8=进入中国国家阶段的PCT发明专利申请,9=进入中国国家阶段的PCT实用新型专利申请
											--例：2003 1 0100002.X 表示发明专利申请
											--    2003 2 0100002.5 表示实用新型专利申请
				@patentCopyFile varchar(128),--专利复印件上传图片

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的专利不存在，
							2:要修改的专利正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updatePatentInfo
	@patentId varchar(10),		--专利编号
	@invenName nvarchar(40),	--发明名称
	@patentType int,			--专利类型：由第54号代码字典定义
	@invenManID varchar(100),	--申请人（发明人，当专利批准后申请人就是发明人）工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@invenMan nvarchar(300),	--申请人（发明人，当专利批准后申请人就是发明人），采用"XXX,XXX"格式存放。冗余设计
	@applyTime varchar(10),		--申请时间:采用"yyyy-MM-dd"格式存放
	@isWarranted char(1),		--是否已授权：'N'->未授权，'Y'已授权
	@warrantTime varchar(10),	--授权时间:采用"yyyy-MM-dd"格式存放
	@patentNum varchar(13),		--专利号：专利申请号编号形式（共12位数字，加上一个小数点）:申请年号+专利申请种类+申请顺序号+计算机校验位
								--前4位数字表示申请年号，第5位数字表示申请种类：
								--1=发明专利申请,2=实用新型专利申请,3=外观设计专利申请,8=进入中国国家阶段的PCT发明专利申请,9=进入中国国家阶段的PCT实用新型专利申请
								--例：2003 1 0100002.X 表示发明专利申请
								--    2003 2 0100002.5 表示实用新型专利申请
	@patentCopyFile varchar(128),--专利复印件上传图片

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的专利是否存在
	declare @count as int
	set @count=(select count(*) from patentInfo where patentId= @patentId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update patentInfo
	set patentId = @patentId, invenName = @invenName, patentType = @patentType, invenManID = @invenManID, invenMan = @invenMan, 
		applyTime = @applyTime, isWarranted = @isWarranted, warrantTime = @warrantTime,patentNum = @patentNum, patentCopyFile= @patentCopyFile,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where patentId= @patentId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改专利', '系统根据用户' + @modiManName + 
					'的要求修改了专利“' + @invenName + '['+@patentId+']”的登记信息。')
GO

drop PROCEDURE delPatentInfo
/*
	name:		delPatentInfo
	function:	6.删除指定的专利
	input: 
				@patentId varchar(10),			--专利编号
				@delManID varchar(10) output,	--删除人，如果当前专利正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的专利不存在，2：要删除的专利正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delPatentInfo
	@patentId varchar(10),			--专利编号
	@delManID varchar(10) output,	--删除人，如果当前专利正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的专利是否存在
	declare @count as int
	set @count=(select count(*) from patentInfo where patentId= @patentId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete patentInfo where patentId= @patentId
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除专利', '用户' + @delManName
												+ '删除了专利['+@patentId+']。')

GO


--专利查询语句:
select p.patentId, p.invenName, p.patentType, cd1.objDesc patentTypeDesc,
	p.invenManID, p.invenMan, convert(varchar(10),p.applyTime,120) applyTime, p.isWarranted, 
	convert(varchar(10),p.warrantTime,120) warrantTime, p.patentNum, p.patentCopyFile
from patentInfo p
left join codeDictionary cd1 on p.patentType = cd1.objCode and cd1.classCode = 54


drop PROCEDURE queryAwardInfoLocMan
/*
	name:		queryAwardInfoLocMan
	function:	11.查询指定获奖是否有人正在编辑
	input: 
				@awardId varchar(10),		--获奖编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的获奖不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryAwardInfoLocMan
	@awardId varchar(10),		--获奖编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	set @Ret = 0
GO


drop PROCEDURE lockAwardInfo4Edit
/*
	name:		lockAwardInfo4Edit
	function:	12.锁定获奖编辑，避免编辑冲突
	input: 
				@awardId varchar(10),			--获奖编号
				@lockManID varchar(10) output,	--锁定人，如果当前获奖正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的获奖不存在，2:要锁定的获奖正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockAwardInfo4Edit
	@awardId varchar(10),			--获奖编号
	@lockManID varchar(10) output,	--锁定人，如果当前获奖正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的获奖是否存在
	declare @count as int
	set @count=(select count(*) from awardInfo where awardId= @awardId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update awardInfo
	set lockManID = @lockManID 
	where awardId= @awardId
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定获奖编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了获奖['+ @awardId +']为独占式编辑。')
GO

drop PROCEDURE unlockAwardInfoEditor
/*
	name:		unlockAwardInfoEditor
	function:	13.释放获奖编辑锁
				注意：本过程不检查获奖是否存在！
	input: 
				@awardId varchar(10),			--获奖编号
				@lockManID varchar(10) output,	--锁定人，如果当前获奖正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockAwardInfoEditor
	@awardId varchar(10),			--获奖编号
	@lockManID varchar(10) output,	--锁定人，如果当前获奖呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update awardInfo set lockManID = '' where awardId= @awardId
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
	values(@lockManID, @lockManName, getdate(), '释放获奖编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了获奖['+ @awardId +']的编辑锁。')
GO


drop PROCEDURE addAwardInfo
/*
	name:		addAwardInfo
	function:	14.添加获奖信息
	input: 
				@awardName nvarchar(30),		--获奖名称
				@completeManId nvarchar(100),	--完成人员及排名工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放，如果是外部人员空缺编号
				@completeMan nvarchar(300),		--完成人员及排名，采用"XXX,XXX"格式存放。冗余设计，如果是外部人员空缺编号
				@unitRank nvarchar(300),		--单位排名：支持多个单位，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@awardTime varchar(10),			--获奖时间：采用"yyyy-MM-dd"格式存放
				@certiCopyFile varchar(128),	--证书复印件上传图片
				@remark nvarchar(100),			--备注

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,--添加时间
				@awardId varchar(10) output--获奖编号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addAwardInfo
	@awardName nvarchar(30),		--获奖名称
	@completeManId nvarchar(100),	--完成人员及排名工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放，如果是外部人员空缺编号
	@completeMan nvarchar(300),		--完成人员及排名，采用"XXX,XXX"格式存放。冗余设计，如果是外部人员空缺编号
	@unitRank nvarchar(300),		--单位排名：支持多个单位，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@awardTime varchar(10),			--获奖时间：采用"yyyy-MM-dd"格式存放
	@certiCopyFile varchar(128),	--证书复印件上传图片
	@remark nvarchar(100),			--备注

	@createManID varchar(10),	--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@awardId varchar(10) output--获奖编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生获奖编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 103, 1, @curNumber output
	set @awardId = @curNumber

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert awardInfo(awardId, awardName, completeManId, completeMan, unitRank, awardTime, certiCopyFile, remark,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@awardId, @awardName, @completeManId, @completeMan, @unitRank, @awardTime, @certiCopyFile, @remark,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记获奖', '系统根据用户' + @createManName + 
					'的要求登记获奖“' + @awardName + '['+@awardId+']信息”。')
GO


drop PROCEDURE updateAwardInfo
/*
	name:		updateAwardInfo
	function:	15.修改获奖信息
	input: 
				@awardId varchar(10),		--获奖编号
				@awardName nvarchar(30),		--获奖名称
				@completeManId nvarchar(100),	--完成人员及排名工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放，如果是外部人员空缺编号
				@completeMan nvarchar(300),		--完成人员及排名，采用"XXX,XXX"格式存放。冗余设计，如果是外部人员空缺编号
				@unitRank nvarchar(300),		--单位排名：支持多个单位，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
				@awardTime varchar(10),			--获奖时间：采用"yyyy-MM-dd"格式存放
				@certiCopyFile varchar(128),	--证书复印件上传图片
				@remark nvarchar(100),			--备注

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的获奖不存在，
							2:要修改的获奖正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updateAwardInfo
	@awardId varchar(10),		--获奖编号
	@awardName nvarchar(30),		--获奖名称
	@completeManId nvarchar(100),	--完成人员及排名工号：支持多个人，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放，如果是外部人员空缺编号
	@completeMan nvarchar(300),		--完成人员及排名，采用"XXX,XXX"格式存放。冗余设计，如果是外部人员空缺编号
	@unitRank nvarchar(300),		--单位排名：支持多个单位，采用"XXXXXXXXXX,XXXXXXXXXX"格式存放
	@awardTime varchar(10),			--获奖时间：采用"yyyy-MM-dd"格式存放
	@certiCopyFile varchar(128),	--证书复印件上传图片
	@remark nvarchar(100),			--备注

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的获奖是否存在
	declare @count as int
	set @count=(select count(*) from awardInfo where awardId= @awardId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update awardInfo
	set awardId = @awardId, awardName = @awardName, completeManId = @completeManId, completeMan = @completeMan, 
		unitRank = @unitRank, awardTime = @awardTime, certiCopyFile = @certiCopyFile, remark = @remark,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where awardId= @awardId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改获奖', '系统根据用户' + @modiManName + 
					'的要求修改了获奖“' + @awardName + '['+@awardId+']”的登记信息。')
GO

drop PROCEDURE delAwardInfo
/*
	name:		delAwardInfo
	function:	6.删除指定的获奖
	input: 
				@awardId varchar(10),			--获奖编号
				@delManID varchar(10) output,	--删除人，如果当前获奖正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的获奖不存在，2：要删除的获奖正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delAwardInfo
	@awardId varchar(10),			--获奖编号
	@delManID varchar(10) output,	--删除人，如果当前获奖正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的获奖是否存在
	declare @count as int
	set @count=(select count(*) from awardInfo where awardId= @awardId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete awardInfo where awardId= @awardId
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除获奖', '用户' + @delManName
												+ '删除了获奖['+@awardId+']信息。')

GO

--获奖查询语句：
select a.awardId, a.awardName, a.completeManId, a.completeMan, a.unitRank, 
	convert(varchar(10),a.awardTime,120) awardTime, a.certiCopyFile, a.remark
from awardInfo a

drop PROCEDURE queryProjectInfoLocMan
/*
	name:		queryProjectInfoLocMan
	function:	11.查询指定科研项目是否有人正在编辑
	input: 
				@projectId varchar(10),		--科研项目编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的科研项目不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryProjectInfoLocMan
	@projectId varchar(10),		--科研项目编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	set @Ret = 0
GO


drop PROCEDURE lockProjectInfo4Edit
/*
	name:		lockProjectInfo4Edit
	function:	12.锁定科研项目编辑，避免编辑冲突
	input: 
				@projectId varchar(10),			--科研项目编号
				@lockManID varchar(10) output,	--锁定人，如果当前科研项目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的科研项目不存在，2:要锁定的科研项目正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockProjectInfo4Edit
	@projectId varchar(10),			--科研项目编号
	@lockManID varchar(10) output,	--锁定人，如果当前科研项目正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的科研项目是否存在
	declare @count as int
	set @count=(select count(*) from projectInfo where projectId= @projectId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update projectInfo
	set lockManID = @lockManID 
	where projectId= @projectId
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定科研项目编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了科研项目['+ @projectId +']为独占式编辑。')
GO

drop PROCEDURE unlockProjectInfoEditor
/*
	name:		unlockProjectInfoEditor
	function:	13.释放科研项目编辑锁
				注意：本过程不检查科研项目是否存在！
	input: 
				@projectId varchar(10),			--科研项目编号
				@lockManID varchar(10) output,	--锁定人，如果当前科研项目正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockProjectInfoEditor
	@projectId varchar(10),			--科研项目编号
	@lockManID varchar(10) output,	--锁定人，如果当前科研项目呢正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update projectInfo set lockManID = '' where projectId= @projectId
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
	values(@lockManID, @lockManName, getdate(), '释放科研项目编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了科研项目['+ @projectId +']的编辑锁。')
GO


drop PROCEDURE addProjectInfo
/*
	name:		addProjectInfo
	function:	14.添加科研项目信息
	input: 
				@projectNum varchar(30),			--项目编号（学校的编号）
				@consignUnit nvarchar(60),			--委托单位
				@consignUnitLocateCode varchar(6),	--委托单位来源地区编码
				@securityClass int,					--密级：由第57号代码字典定义
				@projectName nvarchar(30),			--项目名称
				@applyTime varchar(10),				--项目申报时间:采用"yyyy-MM-dd"格式存放
				
				@projectNature int,					--项目性质：由第55号代码字典定义
				@projectType int,					--项目类别：由第56号代码字典定义
				@projectFund numeric(12,2),			--项目经费（万元）
				@startTime varchar(10),				--开始时间:采用"yyyy-MM-dd"格式存放
				@endTime varchar(10),				--结束时间:采用"yyyy-MM-dd"格式存放
				@projectManagerID varchar(10),		--项目负责人工号
				@summary nvarchar(300),				--研究内容摘要

				@createManID varchar(10),			--创建人工号
	output: 
				@Ret		int output				--操作成功标识:0:成功，9:未知错误
				@createTime smalldatetime output,	--添加时间
				@projectId varchar(10) output		--科研项目编号(系统内部编号)
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addProjectInfo
	@projectNum varchar(30),			--项目编号（学校的编号）
	@consignUnit nvarchar(60),			--委托单位
	@consignUnitLocateCode varchar(6),	--委托单位来源地区编码
	@securityClass int,					--密级：由第57号代码字典定义
	@projectName nvarchar(30),			--项目名称
	@applyTime varchar(10),				--项目申报时间:采用"yyyy-MM-dd"格式存放
	
	@projectNature int,					--项目性质：由第55号代码字典定义
	@projectType int,					--项目类别：由第56号代码字典定义
	@projectFund numeric(12,2),			--项目经费（万元）
	@startTime varchar(10),				--开始时间:采用"yyyy-MM-dd"格式存放
	@endTime varchar(10),				--结束时间:采用"yyyy-MM-dd"格式存放
	@projectManagerID varchar(10),		--项目负责人工号
	@summary nvarchar(300),				--研究内容摘要

	@createManID varchar(10),			--创建人工号
	@Ret		int output,
	@createTime smalldatetime output,
	@projectId varchar(10) output		--科研项目编号(系统内部编号)
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生科研项目编号：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 104, 1, @curNumber output
	set @projectId = @curNumber

	--取创建人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--取项目负责人姓名：
	declare @projectManager nvarchar(30)		--项目负责人
	set @projectManager = isnull((select cName from userInfo where jobNumber = @projectManagerID),'')
	
	set @createTime = getdate()
	insert projectInfo(projectId, projectNum, consignUnit, consignUnitLocateCode, securityClass, projectName, applyTime,
					projectNature, projectType, projectFund, startTime, endTime, projectManagerID, projectManager, summary,
					--最新维护情况:
					modiManID, modiManName, modiTime)
	values(@projectId, @projectNum, @consignUnit, @consignUnitLocateCode, @securityClass, @projectName, @applyTime,
					@projectNature, @projectType, @projectFund, @startTime, @endTime, @projectManagerID, @projectManager, @summary,
					--最新维护情况:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记科研项目', '系统根据用户' + @createManName + 
					'的要求登记科研项目“' + @projectName + '['+@projectId+']信息”。')
GO

drop PROCEDURE updateProjectInfo
/*
	name:		updateProjectInfo
	function:	15.修改科研项目信息
	input: 
				@projectId varchar(10),				--科研项目编号
				@projectNum varchar(30),			--项目编号（学校的编号）
				@consignUnit nvarchar(60),			--委托单位
				@consignUnitLocateCode varchar(6),	--委托单位来源地区编码
				@securityClass int,					--密级：由第57号代码字典定义
				@projectName nvarchar(30),			--项目名称
				@applyTime varchar(10),				--项目申报时间:采用"yyyy-MM-dd"格式存放
				
				@projectNature int,					--项目性质：由第55号代码字典定义
				@projectType int,					--项目类别：由第56号代码字典定义
				@projectFund numeric(12,2),			--项目经费（万元）
				@startTime varchar(10),				--开始时间:采用"yyyy-MM-dd"格式存放
				@endTime varchar(10),				--结束时间:采用"yyyy-MM-dd"格式存放
				@projectManagerID varchar(10),		--项目负责人工号
				@summary nvarchar(300),				--研究内容摘要

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要修改的科研项目不存在，
							2:要修改的科研项目正被别人锁定编辑，
							9:未知错误
				@modiTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updateProjectInfo
	@projectId varchar(10),				--科研项目编号
	@projectNum varchar(30),			--项目编号（学校的编号）
	@consignUnit nvarchar(60),			--委托单位
	@consignUnitLocateCode varchar(6),	--委托单位来源地区编码
	@securityClass int,					--密级：由第57号代码字典定义
	@projectName nvarchar(30),			--项目名称
	@applyTime varchar(10),				--项目申报时间:采用"yyyy-MM-dd"格式存放
	
	@projectNature int,					--项目性质：由第55号代码字典定义
	@projectType int,					--项目类别：由第56号代码字典定义
	@projectFund numeric(12,2),			--项目经费（万元）
	@startTime varchar(10),				--开始时间:采用"yyyy-MM-dd"格式存放
	@endTime varchar(10),				--结束时间:采用"yyyy-MM-dd"格式存放
	@projectManagerID varchar(10),		--项目负责人工号
	@summary nvarchar(300),				--研究内容摘要

	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的科研项目是否存在
	declare @count as int
	set @count=(select count(*) from projectInfo where projectId= @projectId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--取项目负责人姓名：
	declare @projectManager nvarchar(30)		--项目负责人
	set @projectManager = isnull((select cName from userInfo where jobNumber = @projectManagerID),'')

	set @modiTime = getdate()
	update projectInfo
	set projectId = @projectId, projectNum = @projectNum, consignUnit = @consignUnit, consignUnitLocateCode = @consignUnitLocateCode, 
					securityClass = @securityClass, projectName = @projectName, applyTime = @applyTime,
					projectNature = @projectNature, projectType = @projectType, projectFund = @projectFund, 
					startTime = @startTime, endTime = @endTime, projectManagerID = @projectManagerID, projectManager = @projectManager, summary = @summary,
		--最新维护情况:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where projectId= @projectId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改科研项目', '系统根据用户' + @modiManName + 
					'的要求修改了科研项目“' + @projectName + '['+@projectId+']”的登记信息。')
GO

drop PROCEDURE delProjectInfo
/*
	name:		delProjectInfo
	function:	6.删除指定的科研项目
	input: 
				@projectId varchar(10),			--科研项目编号
				@delManID varchar(10) output,	--删除人，如果当前科研项目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的科研项目不存在，2：要删除的科研项目正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delProjectInfo
	@projectId varchar(10),			--科研项目编号
	@delManID varchar(10) output,	--删除人，如果当前科研项目正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的科研项目是否存在
	declare @count as int
	set @count=(select count(*) from projectInfo where projectId= @projectId)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete projectInfo where projectId= @projectId
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除科研项目', '用户' + @delManName
												+ '删除了科研项目['+@projectId+']信息。')

GO

--科研项目：
select p.projectId, p.projectNum, p.consignUnit, p.consignUnitLocateCode, p.securityClass, cd1.objDesc securityClassDesc,
	p.projectName, convert(varchar(10),p.applyTime,120) applyTime, p.projectNature, cd2.objDesc projectNatureDesc,
	p.projectType, cd3.objDesc projectTypeDesc,
	p.projectFund, convert(char(10),p.startTime,120) startTime, convert(varchar(10),p.endTime,120)endTime,
	p.projectManagerID, p.projectManager, p.summary
from projectInfo p
left join codeDictionary cd1 on p.securityClass = cd1.objCode and cd1.classCode = 57
left join codeDictionary cd2 on p.projectNature = cd2.objCode and cd2.classCode = 55
left join codeDictionary cd3 on p.projectType = cd3.objCode and cd3.classCode = 56


