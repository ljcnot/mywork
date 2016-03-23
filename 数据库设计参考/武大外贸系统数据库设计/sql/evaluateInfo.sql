use newfTradeDB2
/*
	武大外贸合同管理信息系统-评价系统
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 
*/
select * from evaluateInfo
--1.业务情况反馈表：
drop table evaluateInfo
CREATE TABLE evaluateInfo(
	traderID varchar(12) not null,		--主键/外键：外贸公司编号
	traderName nvarchar(30) null,		--外贸公司名称：冗余设计
	abbTraderName nvarchar(6) null,		--外贸公司简称：冗余设计
	contractID varchar(12) not null,	--主键：合同编号
	--填报单位：
	clgCode char(3) not null,			--主键：学院代码
	clgName nvarchar(30) null,			--学院名称:冗余设计，保存历史数据
	abbClgName nvarchar(6) null,		--院部简称
	--填表人：
	createrID varchar(10) not null,		--填表人ID
	creater nvarchar(30) not null,		--填表人
	--联系人与联系方式：
	ordererID varchar(10) not null,		--主键：联系人ID，与合同中的订货人一致
	orderer nvarchar(30) not null,		--联系人姓名
	mobile varchar(30) null,			--联系人手机
	tel varchar(30) null,				--联系人其他电话
	--环节延期：
	extensionRedLamp int default(0),	--红灯提醒次数
	extensionSMS int default(0),		--短信提醒次数
	--评价：
	qualityOption int default(0),		--外贸公司服务态度及质量：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
	abilityOption int default(0),		--外贸公司服务态度及质量：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
	--延迟到货主要原因
	extensionReason nvarchar(300) null,
	--要求及建议	
	suggestion nvarchar(300) null,
	--分值：
	score int default(0),

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_evaluateInfo] PRIMARY KEY CLUSTERED 
(
	[traderID] ASC,
	[contractID] ASC,
	[clgCode] ASC,
	[ordererID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[evaluateInfo] WITH CHECK ADD CONSTRAINT [FK_evaluateInfo_traderInfo] FOREIGN KEY([traderID])
REFERENCES [dbo].[traderInfo] ([traderID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[evaluateInfo] CHECK CONSTRAINT [FK_evaluateInfo_traderInfo]
GO


--2.外贸公司年度服务得分一览表：
drop table traderEvaluateInfo
CREATE TABLE traderEvaluateInfo(
	traderID varchar(12) not null,		--主键/外键：外贸公司编号
	theYear varchar(4) not null,		--年度
	traderName nvarchar(30) null,		--外贸公司名称：冗余设计
	abbTraderName nvarchar(6) null,		--外贸公司简称：冗余设计

	newContract int default(0),			--本年新增合同数
	newContractMoney money default(0),	--本年新增合同金额（美元）
	yearTotalCompletedContract int default(0),		--本年累计完成合同数
	yearTotalCompletedContractMoney money default(0),--本年累计完成合同金额（美元）
	evaluatedContract int default(0),	--本年累计已填报评价表合同数
	score int default(0)				--分值（平均分）：
 CONSTRAINT [PK_traderEvaluateInfo] PRIMARY KEY CLUSTERED 
(
	[traderID] ASC,
	[theYear] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[traderEvaluateInfo] WITH CHECK ADD CONSTRAINT [FK_traderEvaluateInfo_traderInfo] FOREIGN KEY([traderID])
REFERENCES [dbo].[traderInfo] ([traderID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[traderEvaluateInfo] CHECK CONSTRAINT [FK_traderEvaluateInfo_traderInfo]
GO

drop FUNCTION getScore
/*
	name:		getScore
	function:	0.根据分值档号获取得分
	input: 
				@id int	--分值分档号
	output: 
				return int		--分值
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create FUNCTION getScore
(  
	@id int	--分值分档号
)  
RETURNS int
WITH ENCRYPTION
AS      
begin
	declare @scoreStand xml
	set @scoreStand=N'<row id="1">100</row>
						<row id="2">90</row>
						<row id="3">80</row>
						<row id="4">75</row>
						<row id="5">70</row>
						<row id="6">60</row>
						<row id="7">55</row>
						<row id="8">30</row>
						<row id="9">0</row>'
	declare @score int
	set @score = (select score 
					from(
						SELECT cast(convert(varchar(3),T.x.query('data(./@id)')) as int) id, cast(convert(varchar(3),T.x.query('data(.)')) as int) score
						FROM (SELECT @scoreStand Col1) A
							OUTER APPLY A.Col1.nodes('/row') AS T(x)
						) as scoreTab
					where id = @id+1)
	return @score
end
--测试：
declare @s1 int,@s2 int
set @s1 = dbo.getScore(2)
set @s2 = dbo.getScore(2)*30/100 +  dbo.getScore(3)*30/100
select @s2

drop PROCEDURE addEvaluateInfo
/*
	name:		addEvaluateInfo
	function:	1.添加业务情况反馈表
				注意：该存储过程自动锁定记录
	input: 
				@contractID varchar(12),		--合同编号
				@clgCode char(3),				--填表单位：对应合同中的订货单位
				@ordererID varchar(10),			--联系人ID：对应合同中的订货人
				@mobile varchar(30),			--联系人手机
				@tel varchar(30),				--联系人其他电话
				--评价：
				@qualityOption int,				--外贸公司服务态度及质量：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
				@abilityOption int,				--外贸公司业务能力：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
				@extensionReason nvarchar(300),	--延迟到货主要原因
				@suggestion nvarchar(300),		--要求及建议	
				@createrID varchar(10),			--填表人ID
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1:该合同的评价表已经生成，2:该合同不存在,3:订货单位或订货人不是该合同中定义的，9:未知错误
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 

*/
create PROCEDURE addEvaluateInfo
	@contractID varchar(12),		--合同编号
	@clgCode char(3),				--填表单位：对应合同中的订货单位
	@ordererID varchar(10),			--联系人ID：对应合同中的订货人
	@mobile varchar(30),			--联系人手机
	@tel varchar(30),				--联系人其他电话
	--评价：
	@qualityOption int,				--外贸公司服务态度及质量：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
	@abilityOption int,				--外贸公司业务能力：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
	@extensionReason nvarchar(300),	--延迟到货主要原因
	@suggestion nvarchar(300),		--要求及建议	
	@createrID varchar(10),			--填表人ID
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查评价表是否已经定义：
	declare @count int
	set @count = ISNULL((select count(*) from evaluateInfo where contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count > 0)
	begin 
		set @Ret = 1
		return 
	end
	--根据合同编号获取外贸公司
	declare @traderID varchar(12), @traderName nvarchar(30), @abbTraderName nvarchar(6)--外贸公司编号、名称、简称
	select @traderID = c.traderID, @traderName = c.traderName, @abbTraderName = c.abbTraderName
	from contractInfo c left join contractCollege clg on c.contractID=clg.contractID
	where c.contractID = @contractID
	if (@traderName is null)
	begin
		set @Ret = 2
		return
	end
	--根据合同编号获取订货单位信息：
	declare @clgName nvarchar(30),@abbClgName nvarchar(6) --合同中的订货单位代码、名称、简称
	select @clgName = clg.clgName, @abbClgName = clg.abbClgName
	from contractCollege clg
	where contractID = @contractID and @clgCode=@clgCode and ordererID = @ordererID
	if (@clgName is null)
	begin
		set @Ret = 3
		return
	end
	
	--获取环节延期数据：
	declare @extensionYellowLamp int, @extensionRedLamp int, @extensionSMS int	--环节延期：黄灯、红灯、短信提醒次数
	select @extensionYellowLamp= isnull(sum(yellowLampTimes),0), @extensionRedLamp= isnull(sum(redLampTimes),0), @extensionSMS = isnull(SUM(SMSTimes),0)
	from contractFlow
	where contractID = @contractID and nodeNum <=5 --统计送交材料前的延期次数

	--获取联系人信息：	
	declare @orderer nvarchar(30)
	set @orderer = isnull((select cName from userInfo where jobNumber=@ordererID),'')
	--获取填表人姓名：
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @createrID),'')
	
	--计算分值：
	--总分值：100分，其中环节延期分值：40分，服务质量：30分，业务能力：30分。
	--环节延期：红灯一次扣1分，短信提醒一次扣1分；直至扣完为止；只统计“签订代理协议\签订外贸合同\开证付款\办理免表\报关\送交材料”这些外贸公司参与环节。
	--服务质量和业务能力中：优+   □ 100分，优    □ 90分，优-   □ 80分	良+   □ 75分，良   □ 70分，良-   □ 60分	差+   □ 55分，差   □  30分，差-   □ 0分
	--然后将该分值换算到总分值，即单项分值*30%。
	declare @score int
	set @score = 40-@extensionRedLamp-@extensionSMS
	if (@score<0)
		set @score = 0
	set @score = @score + dbo.getScore(@qualityOption) * 30/100 +  dbo.getScore(@abilityOption) * 30/100

	insert evaluateInfo(traderID, traderName, abbTraderName, contractID,
						--填报单位：
						clgCode, clgName, abbClgName,
						--填表人：
						createrID, creater,
						--联系人与联系方式：
						ordererID, orderer, mobile, tel,
						--环节延期：
						extensionRedLamp, extensionSMS,
						--评价：
						qualityOption, abilityOption,
						--延迟到货主要原因
						extensionReason,
						--要求及建议	
						suggestion,
						--分值：
						score,
						--维护情况：
						lockManID, modiManID, modiManName, modiTime) 
	values(@traderID, @traderName, @abbTraderName, @contractID,
						--填报单位：
						@clgCode, @clgName, @abbClgName,
						--填表人：
						@createrID, @creater,
						--联系人与联系方式：
						@ordererID, @orderer, @mobile, @tel,
						--环节延期：
						@extensionRedLamp, @extensionSMS,
						--评价：
						@qualityOption, @abilityOption,
						--延迟到货主要原因
						@extensionReason,
						--要求及建议	
						@suggestion,
						--分值：
						@score,
						--维护情况
						@createrID, @createrID, @creater, GETDATE())

	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  
		  
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createrID, @creater, GETDATE(), '添加评价表', '系统根据用户' + @creater + 
					'的要求添加了合同['+@contractID+']的业务情况反馈表。')
GO
--测试：
declare @Ret int
exec dbo.addEvaluateInfo '20130249','00006327','13902702392','87889011',0,0,'因为罢工','通关能力要增强','00006327',@Ret output
select @Ret

delete evaluateInfo 
select * from evaluateInfo 


drop PROCEDURE queryEvaluateInfoLocMan
/*
	name:		queryEvaluateInfoLocMan
	function:	2.查询指定业务情况反馈表是否有人正在编辑
	input: 
				@contractID varchar(12),	--合同编号
				@clgCode char(3),			--填表单位：对应合同中的订货单位
				@ordererID varchar(10),		--联系人ID：对应合同中的订货人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的业务情况反馈表不存在
				@lockManID varchar(10) output--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE queryEvaluateInfoLocMan
	@contractID varchar(12),	--合同编号
	@clgCode char(3),			--填表单位：对应合同中的订货单位
	@ordererID varchar(10),		--联系人ID：对应合同中的订货人
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from evaluateInfo 
						where contractID = @contractID and contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),'')
	set @Ret = 0
GO


drop PROCEDURE lockEvaluateInfo4Edit
/*
	name:		lockEvaluateInfo4Edit
	function:	3.锁定业务情况反馈表编辑，避免编辑冲突
	input: 
				@contractID varchar(12),		--合同编号
				@clgCode char(3),				--填表单位：对应合同中的订货单位
				@ordererID varchar(10),			--联系人ID：对应合同中的订货人
				@lockManID varchar(10) output,	--锁定人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：要锁定的业务情况反馈表不存在，2:要锁定的业务情况反馈表正在被别人编辑
							9：未知错误
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE lockEvaluateInfo4Edit
	@contractID varchar(12),		--合同编号
	@clgCode char(3),				--填表单位：对应合同中的订货单位
	@ordererID varchar(10),			--联系人ID：对应合同中的订货人
	@lockManID varchar(10) output,	--锁定人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的业务情况反馈表是否存在
	declare @count as int
	set @count = ISNULL((select count(*) from evaluateInfo 
						where contractID = @contractID and contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from evaluateInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update evaluateInfo 
	set lockManID = @lockManID 
	where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定评价表编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了合同['+ @contractID +']的业务情况反馈表为独占式编辑。')
GO

drop PROCEDURE unlockEvaluateInfoEditor
/*
	name:		unlockEvaluateInfoEditor
	function:	4.释放业务情况反馈表编辑锁
				注意：本过程不检查业务情况反馈表是否存在！
	input: 
				@contractID varchar(12),		--合同编号
				@clgCode char(3),				--填表单位：对应合同中的订货单位
				@ordererID varchar(10),			--联系人ID：对应合同中的订货人
				@lockManID varchar(10) output,	--锁定人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE unlockEvaluateInfoEditor
	@contractID varchar(12),		--合同编号
	@clgCode char(3),				--填表单位：对应合同中的订货单位
	@ordererID varchar(10),			--联系人ID：对应合同中的订货人
	@lockManID varchar(10) output,	--锁定人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from evaluateInfo 
						where contractID = @contractID and contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update evaluateInfo set lockManID = '' where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
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
	values(@lockManID, @lockManName, getdate(), '释放评价表表编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了合同['+ @contractID +']的业务情况反馈表的编辑锁。')
GO

select * from evaluateInfo
drop PROCEDURE updateEvaluateInfo
/*
	name:		updateEvaluateInfo
	function:	5.更新业务情况反馈表
	input: 
				@contractID varchar(12),		--合同编号
				@clgCode char(3),				--填表单位：对应合同中的订货单位
				@ordererID varchar(10),			--联系人ID：对应合同中的订货人
				@mobile varchar(30),			--联系人手机
				@tel varchar(30),				--联系人其他电话
				--评价：
				@qualityOption int,				--外贸公司服务态度及质量：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
				@abilityOption int,				--外贸公司业务能力：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
				@extensionReason nvarchar(300),	--延迟到货主要原因
				@suggestion nvarchar(300),		--要求及建议	

				@modiManID varchar(10) output,	--维护人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的业务情况反馈表不存在，2：要更新的业务情况反馈表正被别人锁定，
							3:该合同不存在,4:订货单位或订货人不是该合同中定义的，9：未知错误
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE updateEvaluateInfo
	@contractID varchar(12),		--合同编号
	@clgCode char(3),				--填表单位：对应合同中的订货单位
	@ordererID varchar(10),			--联系人ID：对应合同中的订货人
	@mobile varchar(30),			--联系人手机
	@tel varchar(30),				--联系人其他电话
	--评价：
	@qualityOption int,				--外贸公司服务态度及质量：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
	@abilityOption int,				--外贸公司服务态度及质量：0->优+,1->优,2->优-,3->良+,4->良,5->良-,6->差+,7->差,8->差-
	@extensionReason nvarchar(300),	--延迟到货主要原因
	@suggestion nvarchar(300),		--要求及建议	
	
	@modiManID varchar(10) output,	--维护人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查评价表是否已经定义：
	declare @count int
	set @count = ISNULL((select count(*) from evaluateInfo where contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count = 0)
	begin 
		set @Ret = 1
		return 
	end
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from evaluateInfo
	where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	--检查编辑锁：
	if (@thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--根据合同编号获取外贸公司信息：
	declare @traderID varchar(12), @traderName nvarchar(30), @abbTraderName nvarchar(6)--外贸公司编号、名称、简称
	select @traderID = c.traderID, @traderName = c.traderName, @abbTraderName = c.abbTraderName
	from contractInfo c left join contractCollege clg on c.contractID=clg.contractID
	where c.contractID = @contractID
	if (@traderName is null)
	begin
		set @Ret = 3
		return
	end
	--根据合同编号获取订货单位信息：
	declare @clgName nvarchar(30),@abbClgName nvarchar(6) --合同中的订货单位代码、名称、简称
	select @clgName = clg.clgName, @abbClgName = clg.abbClgName
	from contractCollege clg
	where contractID = @contractID and @clgCode=@clgCode and ordererID = @ordererID
	if (@clgName is null)
	begin
		set @Ret = 4
		return
	end
	
	--获取环节延期数据：
	declare @extensionYellowLamp int, @extensionRedLamp int, @extensionSMS int	--环节延期：黄灯、红灯、短信提醒次数
	select @extensionYellowLamp= isnull(sum(yellowLampTimes),0), @extensionRedLamp= isnull(sum(redLampTimes),0), @extensionSMS = isnull(SUM(SMSTimes),0)
	from contractFlow
	where contractID = @contractID and nodeNum <=5 --统计送交材料前的延期次数

	--获取联系人信息：	
	declare @orderer nvarchar(30)
	set @orderer = isnull((select cName from userInfo where jobNumber=@ordererID),'')
	--获取维护人姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--计算分值：
	--总分值：100分，其中环节延期分值：40分，服务质量：30分，业务能力：30分。
	--环节延期：红灯一次扣1分，短信提醒一次扣1分；直至扣完为止；只统计“签订代理协议\签订外贸合同\开证付款\办理免表\报关\送交材料”这些外贸公司参与环节。
	--服务质量和业务能力中：优+   □ 100分，优    □ 90分，优-   □ 80分	良+   □ 75分，良   □ 70分，良-   □ 60分	差+   □ 55分，差   □  30分，差-   □ 0分
	--然后将该分值换算到总分值，即单项分值*30%。
	declare @score int
	set @score = 40-@extensionRedLamp-@extensionSMS
	if (@score<0)
		set @score = 0
	set @score = @score + dbo.getScore(@qualityOption) * 30/100 +  dbo.getScore(@abilityOption) * 30/100

	update evaluateInfo
	set traderID = @traderID, traderName = @traderName, abbTraderName = @abbTraderName, contractID = @contractID,
	--填报单位：
	clgCode = @clgCode, clgName = @clgName, abbClgName = @abbClgName,
	--联系人与联系方式：
	ordererID = @ordererID, orderer = @orderer, mobile = @mobile, tel = @tel,
	--环节延期：
	extensionRedLamp = @extensionRedLamp, extensionSMS = @extensionSMS,
	--评价：
	qualityOption = @qualityOption, abilityOption = @abilityOption,
	--延迟到货主要原因
	extensionReason = @extensionReason,
	--要求及建议	
	suggestion = @suggestion,
	--分值：
	score = @score,
	--维护情况：
	modiManID = @modiManID, modiManName = @modiManName, modiTime = GETDATE() 
	where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  
		  
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, GETDATE(), '更新评价表', '系统根据用户' + @modiManName + 
					'的要求更新了合同['+@contractID+']的业务情况反馈表。')
GO


drop PROCEDURE delEvaluateInfo
/*
	name:		delEvaluateInfo
	function:	6.删除指定的业务情况反馈表
	input: 
				@contractID char(12),			--合同编号
				@clgCode char(3),				--填表单位：对应合同中的订货单位
				@ordererID varchar(10),			--联系人ID：对应合同中的订货人
				@delManID varchar(10) output,	--删除人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的业务情况反馈表不存在，2：要删除的业务情况反馈表正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-10-06
	UpdateDate: 

*/
create PROCEDURE delEvaluateInfo
	@contractID char(12),			--合同编号
	@clgCode char(3),				--填表单位：对应合同中的订货单位
	@ordererID varchar(10),			--联系人ID：对应合同中的订货人
	@delManID varchar(10) output,	--删除人，如果当前业务情况反馈表正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要指定的业务情况反馈表是否存在
	declare @count as int
	set @count = ISNULL((select count(*) from evaluateInfo where contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from evaluateInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete evaluateInfo where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除业务情况反馈表', '用户' + @delManName
												+ '删除了合同['+ @contractID +']的业务情况反馈表。')
GO
--测试：


drop proc makeTraderEvaluateInfo
/*
	name:		makeTraderEvaluateInfo
	function:	10.统计指定年度的外贸公司服务评价表
	input: 
				@theYear varchar(4),			--统计年度
				@makerID varchar(10),			--制表人工号
	output: 
				@Ret		int output			--操作成功标识：0:成功，9:未知错误
	author:		卢苇
	CreateDate:	2013-10-07
	UpdateDate: 
*/
create PROCEDURE makeTraderEvaluateInfo
	@theYear varchar(4),			--统计年度
	@makerID varchar(10),			--制表人工号
	@Ret int output					--操作成功标识：0:成功，9:未知错误
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--获取制表人姓名：
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--制表日期：
	declare @makeDate smalldatetime		--制表日期
	set @makeDate = GETDATE()

	begin tran
		--删除可能存在的年度统计表：
		delete traderEvaluateInfo where theYear=@theYear
		--逐个扫描外贸公司统计合同和得分：
		declare @traderID varchar(12),@traderName nvarchar(30),@abbTraderName nvarchar(6)		--主键/外键：外贸公司编号、名称、简称
		declare tar cursor for
		select traderID, traderName, abbTraderName from traderInfo order by traderID
		OPEN tar
		FETCH NEXT FROM tar INTO @traderID,@traderName,@abbTraderName
		WHILE @@FETCH_STATUS = 0
		begin
			declare @newContract int,@newContractMoney money			--本年新增合同数/本年新增合同金额（美元）
			declare @yearTotalCompletedContract int, @yearTotalCompletedContractMoney money		--本年累计完成合同数/本年累计完成合同金额（美元）
			declare @evaluatedContract int, @sumScore int	--本年累计已填报评价表合同数/总分
			set @newContract = (select count(*) from contractInfo	--新增合同
								where convert(varchar(4),startTime,120)=@theYear and traderID=@traderID)
			set @newContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--新增合同金额（美元）
								where convert(varchar(4),startTime,120)=@theYear and traderID=@traderID),0)
			set @yearTotalCompletedContract = (select count(*) from contractInfo	--本年累计完成合同数
								where convert(varchar(4),completedTime,120)=@theYear and traderID=@traderID)
			set @yearTotalCompletedContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--本年累计完成合同金额（美元）
								where convert(varchar(4),completedTime,120)=@theYear and traderID=@traderID),0)
			select @evaluatedContract = count(*), @sumScore=SUM(cScore/num)
			from (select count(*) num, SUM(score) cScore 
				from evaluateInfo e left join contractInfo c on e.contractID=c.contractID
				where convert(varchar(4),c.completedTime,120)=@theYear
				group by e.contractID) as t
			insert traderEvaluateInfo(traderID, theYear, traderName, abbTraderName,
					newContract, newContractMoney, yearTotalCompletedContract, yearTotalCompletedContractMoney, 
					evaluatedContract, score)
			values(@traderID, @theYear, @traderName, @abbTraderName,
					@newContract, @newContractMoney, @yearTotalCompletedContract, @yearTotalCompletedContractMoney, 
					@evaluatedContract, @sumScore/@evaluatedContract)
			if (@@ERROR <> 0)
			begin
				set @Ret = 9
				rollback tran
				CLOSE tar
				DEALLOCATE tar
				return
			end
			FETCH NEXT FROM tar INTO @traderID,@traderName,@abbTraderName
		end
		CLOSE tar
		DEALLOCATE tar
		set @Ret = 0
	commit tran
	--写工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '生成外贸服务评价表', '系统根据用户' + @maker + 
					'的要求生成了['+@theYear+']年度外贸公司服务得分表。')
GO
--测试：
declare @Ret		int
exec dbo.makeTraderEvaluateInfo '2012','0000000000',@Ret output
select @Ret
select * from traderEvaluateInfo


--评价表：
select e.traderID, e.traderName, e.abbTraderName, c.contractID, e.clgCode, e.clgName, e.abbClgName,
	e.createrID, e.creater, e.ordererID, e.orderer, e.mobile, e.tel, e.extensionRedLamp, e.extensionSMS,
	e.qualityOption, e.abilityOption, e.extensionReason, e.suggestion, e.score, 
	e.modiManID, e.modiManName, convert(varchar(10),e.modiTime,120) modiTime
from evaluateInfo e left join contractInfo c on e.contractID=c.contractID
where convert(varchar(4),c.completedTime,120)='2013' and e.traderID=''

--合同的外贸公司简要信息：
select c.contractID, c.traderID, c.traderName, c.abbTraderName, c.traderOprManID,c.traderOprMan,c.traderOprManMobile,c.traderOprManTel
from contractInfo c
--合同的订货单位简要信息：
select c.contractID, c.traderID, c.traderName, c.abbTraderName, c.traderOprManID,c.traderOprMan,c.traderOprManMobile,c.traderOprManTel
select * from contractInfo c
--合同设备简要信息：
select e.eName, e.eFormat, e.price, c.currency, cd.objDesc currencyName
from contractEqp e left join contractInfo c on e.contractID=c.contractID
left join codeDictionary cd on cd.classCode=3 and cd.objCode = c.currency

select * from contractEqp


select traderID, theYear, traderName, abbTraderName, 
	newContract, newContractMoney, yearTotalCompletedContract, yearTotalCompletedContractMoney, 
	evaluatedContract, score
from traderEvaluateInfo
