use newfTradeDB2
/*
	武大外贸合同管理信息系统-外汇管理
	author:		卢苇
	CreateDate:	2013-6-9
	UpdateDate: 
*/
select * from convertInfo
where convert(varchar(10),convertTime,120)='2013-10-07'
delete convertInfo
where convert(varchar(10),convertTime,120)='2013-10-07'

drop table convertInfo
CREATE TABLE convertInfo(
	currency smallint not null,			--主键：币种代码,由第3号代码字典定义
	currencyName nvarchar(30) null,		--冗余设计：币种名称
	convertTime smalldatetime not null,	--主键：换算日期
	
	purchasePrice money null,			--现汇买入价:每百元对应人民币价格
	cashPurchaseprice money null,		--现钞买入价:每百元对应人民币价格
	offerPrice money null,				--现汇卖出价:每百元对应人民币价格
	cashOfferPrice money null,			--现钞卖出价:每百元对应人民币价格
	discountedPrice money null,			--中行折算价:每百元对应人民币价格

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_convertInfo] PRIMARY KEY CLUSTERED 
(
	[currency] ASC,
	[convertTime]
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE addConvertInfo
/*
	name:		addConvertInfo
	function:	1.添加指定日期的外汇牌价
	input: 
				@convertTime varchar(19),	--换算日期:采用“yyyy-MM-dd hh:mm:ss”格式存放
				@priceList xml,				--外币价格表，采用如下格式存放：
											N'<root>
											  <currency id="303" currencyName="英镑">
													<purchasePrice>947.82</purchasePrice>
													<cashPurchaseprice>918.55</cashPurchaseprice>
													<offerPrice>955.43</offerPrice>
													<cashOfferPrice>955.43</cashOfferPrice>
													<discountedPrice>960.96</discountedPrice>
											  </currency>
											  <currency id="502" currencyName="美元">
													<purchasePrice>609.86</purchasePrice>
													<cashPurchaseprice>605.58</cashPurchaseprice>
													<offerPrice>612.92</offerPrice>
													<cashOfferPrice>612.92</cashOfferPrice>
													<discountedPrice>616.2</discountedPrice>
											  </currency>
											  ...
											</root>'
											
				@isOverlay char(1),			--当存在该日期的汇率时是否覆盖
				
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：部分币种的汇率正被别人锁定编辑，2：部分币种的当天汇率已存在，9:未知错误
	author:		卢苇
	CreateDate:	2013-6-9
	UpdateDate: 
*/
create PROCEDURE addConvertInfo
	@convertTime varchar(19),	--换算日期:采用“yyyy-MM-dd hh:mm:ss”格式存放
	@priceList xml,				--外币价格表，采用如下格式存放：
	@isOverlay char(1),			--当存在该日期的汇率时是否覆盖

	@createManID varchar(10),	--创建人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @convertInfo table(
		currency smallint not null,			--主键：币种代码,由第3号代码字典定义
		currencyName nvarchar(30) null,		--冗余设计：币种名称
		purchasePrice money null,			--现汇买入价:每百元对应人民币价格
		cashPurchaseprice money null,		--现钞买入价:每百元对应人民币价格
		offerPrice money null,				--现汇卖出价:每百元对应人民币价格
		cashOfferPrice money null,			--现钞卖出价:每百元对应人民币价格
		discountedPrice money null			--中行折算价:每百元对应人民币价格
	)
	
	insert @convertInfo(currency, currencyName, purchasePrice, cashPurchaseprice, offerPrice, cashOfferPrice, discountedPrice)
	select cast(cast(T.x.query('data(./@id)') as varchar(10)) as smallint) currency,
				cast(T.x.query('data(./@currencyName)') as nvarchar(30)) currencyName,
		   cast(cast(T.x.query('data(./purchasePrice)') as varchar(10)) as money) purchasePrice,
		   cast(cast(T.x.query('data(./cashPurchaseprice)') as varchar(10)) as money) cashPurchaseprice,
		   cast(cast(T.x.query('data(./offerPrice)') as varchar(10)) as money) offerPrice,
		   cast(cast(T.x.query('data(./cashOfferPrice)') as varchar(10)) as money) cashOfferPrice,
		   cast(cast(T.x.query('data(./discountedPrice)') as varchar(10)) as money) discountedPrice
		from (select @priceList.query('/root/currency') Col1) A
			OUTER APPLY A.Col1.nodes('/currency') AS T(x)
			
	--检查编辑锁：
	declare @count int
	set @count = ISNULL((select count(*) from convertInfo c inner join @convertInfo b 
							on c.currency = b.currency and convert(varchar(10),c.convertTime,120) = left(@convertTime,10)
							where isnull(lockManID,'')<>''),0)
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--检查是否有当日数据：
	if (@isOverlay='N')
	begin
		set @count = ISNULL((select count(*) from convertInfo c inner join @convertInfo b 
								on c.currency = b.currency and convert(varchar(10),c.convertTime,120) = left(@convertTime,10)),0)
		if (@count>0)
		begin
			set @Ret = 2
			return
		end
	end
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	declare @createTime as smalldatetime
	set @createTime=GETDATE()
	begin tran
		delete convertInfo 
		where convert(varchar(10),convertTime,120) = left(@convertTime,10) and currency in (select currency from @convertInfo)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  

		insert convertInfo(currency, currencyName, convertTime, 
							purchasePrice, cashPurchaseprice, offerPrice, cashOfferPrice, discountedPrice,
							modiManID, modiManName, modiTime)
		select currency, currencyName, @convertTime, 
							purchasePrice, cashPurchaseprice, offerPrice, cashOfferPrice, discountedPrice,
							@createManID, @createManName, @createTime
		from @convertInfo
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
	commit tran

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加外汇牌价表', '系统根据用户' + @createManName + 
					'的要求添加了['+ LEFT(@convertTime,10)+']的外汇牌价。')
GO
--测试：
DECLARE @priceList xml				--外币价格表，采用如下格式存放：
SET @priceList = N'<root>
					  <currency id="303" currencyName="英镑">
							<purchasePrice>947.82</purchasePrice>
							<cashPurchaseprice>918.55</cashPurchaseprice>
							<offerPrice>955.43</offerPrice>
							<cashOfferPrice>955.43</cashOfferPrice>
							<discountedPrice>960.96</discountedPrice>
					  </currency>
					  <currency id="502" currencyName="美元">
							<purchasePrice>609.86</purchasePrice>
							<cashPurchaseprice>605.58</cashPurchaseprice>
							<offerPrice>612.92</offerPrice>
							<cashOfferPrice>612.92</cashOfferPrice>
							<discountedPrice>616.2</discountedPrice>
					  </currency>
					</root>'
declare	@Ret		int 
	
exec dbo.addConvertInfo '2013-06-09 10:10:10', @priceList,'Y','0000000000', @Ret output
select @Ret

select * from convertInfo



drop PROCEDURE queryConvertInfoLocMan
/*
    name:		queryConvertInfoLocMan
    function:	2.查询指定日期指定币种的汇率是否有人正在编辑
    input: 
                @convertTime varchar(10),	--换算日期:采用“yyyy-MM-dd”格式存放
                @currency smallint,			--主键：币种代码,由第3号代码字典定义
    output: 
                @Ret		int output		--操作成功标识
                            0:成功，9：查询出错，可能是指定日期的指定币种汇率不存在
                @lockManID varchar(10) output		--当前正在编辑的人的工号
    author:		卢苇
    CreateDate:	2013-06-09
    UpdateDate: 
*/
create PROCEDURE queryConvertInfoLocMan
	@convertTime varchar(10),	--换算日期:采用“yyyy-MM-dd”格式存放
	@currency smallint,			--主键：币种代码,由第3号代码字典定义
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from convertInfo where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency),'')
	set @Ret = 0
GO


drop PROCEDURE lockConvertInfo4Edit
/*
	name:		lockConvertInfo4Edit
	function:	3.锁定指定日期指定币种的汇率，避免编辑冲突
	input: 
				@convertTime varchar(10),	--换算日期:采用“yyyy-MM-dd”格式存放
				@currency smallint,			--主键：币种代码,由第3号代码字典定义
				@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的指定日期指定币种的汇率不存在，
							2:要锁定的指定日期指定币种的汇率正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-06-09
	UpdateDate: 
*/
create PROCEDURE lockConvertInfo4Edit
	@convertTime varchar(10),		--换算日期:采用“yyyy-MM-dd”格式存放
	@currency smallint,				--主键：币种代码,由第3号代码字典定义
	@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的汇率是否存在
	declare @count as int
	set @count=(select count(*) from convertInfo where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from convertInfo where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update convertInfo
	set lockManID = @lockManID 
	where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定汇率编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了指定日期['+@convertTime+']的币种['+str(@currency,4)+']的汇率为独占式编辑。')
GO

drop PROCEDURE unlockConvertInfoEditor
/*
	name:		unlockConvertInfoEditor
	function:	4.释放指定日期指定币种的汇率编辑锁
				注意：本过程不检查数据是否存在！
	input: 
				@convertTime varchar(10),	--换算日期:采用“yyyy-MM-dd”格式存放
				@currency smallint,			--主键：币种代码,由第3号代码字典定义
				@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-09
	UpdateDate: 
*/
create PROCEDURE unlockConvertInfoEditor
	@convertTime varchar(10),	--换算日期:采用“yyyy-MM-dd”格式存放
	@currency smallint,			--主键：币种代码,由第3号代码字典定义
	@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from convertInfo where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update convertInfo set lockManID = '' where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency
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
	values(@lockManID, @lockManName, getdate(), '释放汇率编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了指定日期['+@convertTime+']的币种['+str(@currency,4)+']的汇率的编辑锁。')
GO


drop PROCEDURE updateAConvertInfo
/*
	name:		updateAConvertInfo
	function:	5.更新一个币种指定日期的汇率（牌价）
	input: 
				@currency smallint,				--主键：币种代码,由第3号代码字典定义
				@convertTime varchar(19),		--换算日期:采用“yyyy-MM-dd hh:mm:ss”格式存放
				
				@purchasePrice money,			--现汇买入价:每百元对应人民币价格
				@cashPurchaseprice money,		--现钞买入价:每百元对应人民币价格
				@offerPrice money,				--现汇卖出价:每百元对应人民币价格
				@cashOfferPrice money,			--现钞卖出价:每百元对应人民币价格
				@discountedPrice money,			--中行折算价:每百元对应人民币价格

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前汇率正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的汇率正被别人锁定，2：该汇率不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-09
	UpdateDate: 
*/
create PROCEDURE updateAConvertInfo
	@currency smallint,				--主键：币种代码,由第3号代码字典定义
	@convertTime varchar(19),		--换算日期:采用“yyyy-MM-dd hh:mm:ss”格式存放
	
	@purchasePrice money,			--现汇买入价:每百元对应人民币价格
	@cashPurchaseprice money,		--现钞买入价:每百元对应人民币价格
	@offerPrice money,				--现汇卖出价:每百元对应人民币价格
	@cashOfferPrice money,			--现钞卖出价:每百元对应人民币价格
	@discountedPrice money,			--中行折算价:每百元对应人民币价格

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前汇率正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from convertInfo where convert(varchar(10),convertTime,120)= convert(varchar(10),@convertTime ,120) and currency=@currency),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取币种名称：
	declare @currencyName nvarchar(30)	--币种名称
	set @currencyName =isnull((select objDesc from codeDictionary where classCode=3 and objCode=@currency),'')
	if (@currencyName='')
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime --更新时间
	set @updateTime = getdate()
	begin tran
		delete convertInfo 
		where convert(varchar(10),convertTime,120)= convert(varchar(10),@convertTime,120) and currency=@currency
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  

		insert convertInfo(currency, currencyName, convertTime, 
							purchasePrice, cashPurchaseprice, offerPrice, cashOfferPrice, discountedPrice,
							modiManID, modiManName, modiTime)
		values(@currency, @currencyName, @convertTime, 
				@purchasePrice, @cashPurchaseprice, @offerPrice, @cashOfferPrice, @discountedPrice,
				@modiManID, @modiManName, @updateTime)
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end  
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新汇率', '用户' + @modiManName 
												+ '更新了指定日期['+@convertTime+']的币种['+@currencyName+']的汇率。')
GO

drop PROCEDURE delConvertInfo
/*
	name:		delConvertInfo
	function:	6.删除指定的日期指定币种的汇率
	input: 
				@convertTime varchar(10),		--换算日期:采用“yyyy-MM-dd”格式存放
				@currency smallint,				--主键：币种代码,由第3号代码字典定义
				@delManID varchar(10) output,	--删除人，如果当前汇率正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的汇率不存在，2：要删除的汇率正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2013-06-09
	UpdateDate: 

*/
create PROCEDURE delConvertInfo
	@convertTime varchar(10),		--换算日期:采用“yyyy-MM-dd”格式存放
	@currency smallint,				--主键：币种代码,由第3号代码字典定义
	@delManID varchar(10) output,	--删除人，如果当前汇率正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的汇率是否存在
	declare @count as int
	set @count=(select count(*) from convertInfo where convert(varchar(10),@convertTime,120)= @convertTime and currency=@currency)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from convertInfo where convert(varchar(10),@convertTime,120)= @convertTime and currency=@currency),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete convertInfo where convert(varchar(10),@convertTime,120)= @convertTime and currency=@currency
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除汇率', '用户' + @delManName
												+ '删除了指定日期['+@convertTime+']的币种['+str(@currency,4)+']的汇率。')
GO



