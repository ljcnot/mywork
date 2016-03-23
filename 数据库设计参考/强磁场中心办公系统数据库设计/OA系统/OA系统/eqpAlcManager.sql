use hustOA
/*
	武大设备管理信息系统-设备调拨管理
	author:		卢苇
	CreateDate:	2010-11-28
	UpdateDate: 
*/

--1.设备调拨单：
--原设计调拨单只有一张表，每次调拨只有一个设备，附件跟随主件调拨
--现用户同意改成主从表结构，调拨增加时间
--单位合并的时候是通过调拨划拨设备
drop TABLE equipmentAllocation
CREATE TABLE equipmentAllocation(
	alcNum char(12) not null,			--主键：调拨单号,由第3号号码发生器产生
											--8位日期代码+4位流水号
	alcStatus int default(0),			--调拨单状态：0->未生效， 2->生效
	alcDate smalldatetime not null,		--调拨时间									

	oldClgCode char(3) not null,		--原院部代码
	oldClgName nvarchar(30) not null,	--原院部名称:冗余字段，但是可以保留历史名称
	oldClgManager nvarchar(30) null,	--原院部负责人:冗余字段，但是可以保留历史名称
	oldUCode varchar(8) not null,		--原使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	oldUName nvarchar(30) not null,		--原使用单位名称:冗余字段，但是可以保留历史名称	

	newClgCode char(3) not null,		--新院部代码
	newClgName nvarchar(30) not null,	--新院部名称:冗余字段，但是可以保留历史名称
	newClgManager nvarchar(30) null,	--新单位负责人:冗余字段，但是可以保留历史名称
	newUCode varchar(8) not null,		--新使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	newUName nvarchar(30) not null,		--新使用单位名称:冗余字段，但是可以保留历史名称

	alcReason nvarchar(300) null,		--调拨原因
	totalNum int default(0),			--总数量
	totalMoney money default(0),		--总金额（原值）

	--notes nvarchar(300) null,			--备注	add by lw 2011-12-15

	acceptComments nvarchar(300) null,	--接受意见
	acceptManID varchar(10) null,		--接受负责人工号 add by lw 2012-8-9
	acceptMan nvarchar(30) null,		--接受负责人
	eManagerID char(10) null,			--设备处管理负责人ID
	eManager nvarchar(30) null,			--设备处管理负责人

	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_equipmentAllocation] PRIMARY KEY CLUSTERED 
(
	[alcNum] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


select * from equipmentAllocationDetail
--2.设备调拨明细表：
drop table equipmentAllocationDetail
CREATE TABLE equipmentAllocationDetail(
	alcNum char(12) not null,			--外键：调拨单号
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	eCode char(8) not null,				--设备编号
	eName nvarchar(30) not null,		--设备名称:冗余数据
	totalAmount money null,				--总价, >0（单价+附件价格）
	
	--add by lw 2011-10-15处理从多个使用单位调入设备情况
	oldClgCode char(3) null,			--原学院代码
	oldUCode varchar(8) null,			--原使用单位代码
	oldUName nvarchar(30) null,			--原使用单位名称:冗余字段，但是可以保留历史名称	
	oldKeepID varchar(10) null,			--原保管人工号（设备管理员）,add by lw 2011-10-12计划增加设备的派生信息，如果管理员登记了，派生信息只能由管理员填写
	oldKeeper nvarchar(30) null,		--原保管人
	--add by lw 2012-8-9
	newKeeperID varchar(10) null,		--新保管人工号
	newKeeper nvarchar(30) null,		--新保管人
CONSTRAINT [PK_equipmentAllocationDetail] PRIMARY KEY CLUSTERED 
(
	[alcNum]ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[equipmentAllocationDetail] WITH CHECK ADD CONSTRAINT [FK_equipmentAllocationDetail_equipmentAllocation] FOREIGN KEY([alcNum])
REFERENCES [dbo].[equipmentAllocation] ([alcNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[equipmentAllocationDetail] CHECK CONSTRAINT [FK_equipmentAllocationDetail_equipmentAllocation]
GO




drop PROCEDURE addAlcApply
/*
	name:		addAlcApply
	function:	1.添加设备调拨申请单（概要信息）
				注意：本存储过程自动锁定编辑，需要手工释放编辑锁！
	input: 
				@alcDate varchar(10),		--调拨时间								
				@alcApplyDetail xml,		--使用xml存储的明细清单：N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>余  玮</newKeeper>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>余  玮</newKeeper>
																	--	</row>
																	--	...
																	--</root>'

				@oldClgCode char(3),		--原院部代码
				@oldUCode varchar(8),		--原使用单位代码
				--@oldKeeper nvarchar(30),	--原保管人del by lw 2012-8-9

				@newClgCode char(3),		--新院部代码
				@newUCode varchar(8),		--新使用单位代码
				--@newKeeper nvarchar(30),	--新保管人del by lw 2012-8-9

				@alcReason nvarchar(300),	--调拨原因

				@acceptComments nvarchar(300),--接受意见
				@acceptManID varchar(10),	--接受负责人工号 add by lw 2012-8-9
				--@acceptMan nvarchar(30),	--接受负责人del by lw 2012-8-9

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要调拨的设备有编辑锁或长事务锁，9：未知错误
				@createTime smalldatetime output,
				@alcNum varchar(12) output	--主键：调拨单号，使用第 3 号号码发生器产生
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-9增加接收人工号字段，删除原保管人、新保管人字段，将明细单的保存放在一起
*/
create PROCEDURE addAlcApply
	@alcDate varchar(10),		--调拨时间								
	@alcApplyDetail xml,		--使用xml存储的明细清单：N'<root>
														--	<row id="1">
														--		<eCode>10000014</eCode>
														--		<newKeeperID>00000008</newKeeperID>
														--		<newKeeper>余  玮</newKeeper>
														--	</row>
														--	<row id="2">
														--		<eCode>10000015</eCode>
														--		<newKeeperID>00000008</newKeeperID>
														--		<newKeeper>余  玮</newKeeper>
														--	</row>
														--	...
														--</root>'

	@oldClgCode char(3),		--原院部代码
	@oldUCode varchar(8),		--原使用单位代码

	@newClgCode char(3),		--新院部代码
	@newUCode varchar(8),		--新使用单位代码

	@alcReason nvarchar(300),	--调拨原因

	@acceptComments nvarchar(300),--接受意见
	@acceptManID varchar(10),	--接受负责人工号 add by lw 2012-8-9
	--@acceptMan nvarchar(30),	--接受负责人del by lw 2012-8-9

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@alcNum varchar(12) output	--主键：调拨单号，使用第 3 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查调拨的设备是否有编辑锁或长事务锁：
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @alcApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end

	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @alcNum = @curNumber

	--获取原单位和新单位的名称、负责人等：
	declare @oldClgName nvarchar(30), @oldClgManager nvarchar(30), @oldUName nvarchar(30)	--原院部名称\原院部负责人\原使用单位名称
	declare @newClgName nvarchar(30), @newClgManager nvarchar(30), @newUName nvarchar(30) 	--新院部名称\新单位负责人\新使用单位名称
	select @oldClgName = clgName, @oldClgManager = manager from college where clgCode = @oldClgCode
	select @oldUName = uName from useUnit where uCode = @oldUCode
	select @newClgName = clgName, @newClgManager = manager from college where clgCode = @newClgCode
	select @newUName = uName from useUnit where uCode = @newUCode

	--取接受负责人的姓名：
	declare @acceptMan nvarchar(30)
	set @acceptMan = isnull((select cName from userInfo where jobNumber = @acceptManID),'')
	
	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	begin tran
		insert equipmentAllocation(alcNum, alcDate,
								oldClgCode, oldClgName, oldClgManager, oldUCode, oldUName,
								newClgCode, newClgName, newClgManager, newUCode, newUName,
								alcReason, 
								acceptComments, acceptManID, acceptMan,
								lockManID, modiManID, modiManName, modiTime, 
								createManID, createManName, createTime) 
		values (@alcNum, @alcDate,
				@oldClgCode, @oldClgName, @oldClgManager, @oldUCode, @oldUName,
				@newClgCode, @newClgName, @newClgManager, @newUCode, @newUName,
				@alcReason, 
				@acceptComments, @acceptManID, @acceptMan,
				@createManID, @createManID, @createManName, @createTime,
				@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入明细表：
		declare @runRet int 
		exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
		if (@runRet <>0)
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加调拨申请单', '系统根据用户' + @createManName + 
					'的要求添加了调拨申请单[' + @alcNum + ']。')
GO

drop PROCEDURE queryAlcApplyLocMan
/*
	name:		queryAlcApplyLocMan
	function:	2.查询指定调拨申请单是否有人正在编辑
	input: 
				@alcNum char(12),			--调拨单号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的调拨单不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: 
*/
create PROCEDURE queryAlcApplyLocMan
	@alcNum char(12),			--调拨单号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockAlcApply4Edit
/*
	name:		lockAlcApply4Edit
	function:	3.锁定调拨单编辑，避免编辑冲突
	input: 
				@alcNum char(12),				--调拨单号
				@lockManID varchar(10) output,	--锁定人，如果当前调拨单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的调拨单不存在，2:要锁定的调拨单正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: 
*/
create PROCEDURE lockAlcApply4Edit
	@alcNum char(12),				--调拨单号
	@lockManID varchar(10) output,	--锁定人，如果当前调拨单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的调拨单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update equipmentAllocation
	set lockManID = @lockManID 
	where alcNum = @alcNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定调拨单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了调拨单['+ @alcNum +']为独占式编辑。')
GO

drop PROCEDURE unlockAlcApplyEditor
/*
	name:		unlockAlcApplyEditor
	function:	4.释放调拨单编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@alcNum char(12),				--调拨单号
				@lockManID varchar(10) output,	--锁定人，如果当前调拨单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: 
*/
create PROCEDURE unlockAlcApplyEditor
	@alcNum char(12),				--调拨单号
	@lockManID varchar(10) output,	--锁定人，如果当前调拨单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update equipmentAllocation set lockManID = '' where alcNum = @alcNum
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
	values(@lockManID, @lockManName, getdate(), '释放调拨单编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了调拨单['+ @alcNum +']的编辑锁。')
GO

drop PROCEDURE addAlcApplyDetail
/*
	name:		addAlcApplyDetail
	function:	5.添加设备调拨明细单
				注意：这个存储过程先删除全部的明细数据，然后再添加
	input: 
				@alcNum varchar(12),		--调拨单号
				@alcApplyDetail xml,		--使用xml存储的明细清单：N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>余  玮</newKeeper>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>余  玮</newKeeper>
																	--	</row>
																	--	...
																	--</root>'
				
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-10-15在明细单中增加保存原单位和保管人信息！
				modi by lw 2012-8-9增加设备长事务锁处理，增加新保管人信息，将该存储过程改成内部存储过程，取消事务处理！
				
*/
create PROCEDURE addAlcApplyDetail
	@alcNum varchar(12),		--调拨单号
	@alcApplyDetail xml,		--使用xml存储的明细清单
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--添加设备长事务锁：
	update equipmentList
	set lock4LongTime = '2', lInvoiceNum=@alcNum
	where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
					from(select @alcApplyDetail.query('/root/row') Col1) A
						OUTER APPLY A.Col1.nodes('/row') AS T(x)
					)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	--插入明细表：
	insert equipmentAllocationDetail(alcNum, eCode, eName, totalAmount,oldClgCode, oldUCode, oldKeepID, oldKeeper, newKeeperID, newKeeper)
	select @alcNum, d.eCode, e.eName, e.totalAmount, e.clgCode, e.uCode, e.keeperID, e.keeper, d.newKeeperID, d.newKeeper
	from (select cast(T.x.query('data(./eCode)') as char(8)) eCode,
				cast(T.x.query('data(./newKeeperID)') as varchar(10)) newKeeperID,
				cast(T.x.query('data(./newKeeper)') as nvarchar(30)) newKeeper
		from(select @alcApplyDetail.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		) as d left join equipmentList e on d.eCode = e.eCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	--计算汇总信息：
	declare @totalNum int, @totalMoney money			--总数量/总金额
	select @totalNum = count(*), @totalMoney = sum(totalAmount) 
	from equipmentAllocationDetail
	where alcNum = @alcNum
		
	update equipmentAllocation 
	set totalNum = @totalNum, totalMoney = @totalMoney
	where alcNum = @alcNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0
GO
--测试：
DECLARE @String xml;
set @String = N'
	<root>
		<row id="1">
			<eCode>10000014</eCode>
			<newKeeperID>00000008</newKeeperID>
			<newKeeper>余  玮</newKeeper>
		</row>
		<row id="2">
			<eCode>10000015</eCode>
			<newKeeperID>00000020</newKeeperID>
			<newKeeper>洪金水</newKeeper>
		</row>
	</root>
'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addAlcApplyDetail '10', @String, '2010112301', @updateTime output, @Ret output
select @Ret
select * from userInfo
select * from equipmentAllocation where alcNum = '10'
update equipmentAllocation
set alcStatus = 0
where alcNum = '10'

select * from equipmentAllocationDetail where alcNum = '10'
select * from workNote order by actionTime desc

drop PROCEDURE updateAlcApplyInfo
/*
	name:		updateAlcApplyInfo
	function:	6.更新调拨单
	input: 
				@alcNum varchar(12),		--主键：调拨单号,由第3号号码发生器产生
														--8位日期代码+4位流水号
				@alcDate varchar(10),		--调拨时间								
				@alcApplyDetail xml,		--使用xml存储的明细清单：N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>余  玮</newKeeper>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>余  玮</newKeeper>
																	--	</row>
																	--	...
																	--</root>'

				@oldClgCode char(3),		--原院部代码
				@oldUCode varchar(8),		--原使用单位代码
				--@oldKeeper nvarchar(30),	--原保管人 del by lw 2012-8-9

				@newClgCode char(3),		--新院部代码
				@newUCode varchar(5),		--新使用单位代码
				--@newKeeper nvarchar(30),	--新保管人 del by lw 2012-8-9

				@alcReason nvarchar(300),	--调拨原因

				@acceptComments nvarchar(300),--接受意见
				@acceptManID varchar(10),	--接受负责人工号 add by lw 2012-8-9
				--@acceptMan nvarchar(30),	--接受负责人del by lw 2012-8-9

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的调拨单不存在，2：要更新的调拨单正被别人锁定，3:该单据已经通过审核，不允许修改，
									4：该单据中的设备有编辑锁或长事务锁，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2012-8-9增加接收人工号字段，删除原保管人、新保管人字段，将明细表的存储过程放在一起
*/
create PROCEDURE updateAlcApplyInfo
	@alcNum varchar(12),		--主键：调拨单号,由第3号号码发生器产生
											--8位日期代码+4位流水号
	@alcDate varchar(10),		--调拨时间								
	@alcApplyDetail xml,		--使用xml存储的明细清单

	@oldClgCode char(3),		--原院部代码
	@oldUCode varchar(8),		--原使用单位代码

	@newClgCode char(3),		--新院部代码
	@newUCode varchar(8),		--新使用单位代码

	@alcReason nvarchar(300),	--调拨原因

	@acceptComments nvarchar(300),--接受意见
	@acceptManID varchar(10),	--接受负责人工号 add by lw 2012-8-9
	--@acceptMan nvarchar(30),	--接受负责人del by lw 2012-8-9

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的调拨单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @alcStatus int			--调拨单状态：0->未生效， 2->生效
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	--检查调拨的设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @alcApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> '0' and not(lock4LongTime = '2' and lInvoiceNum=@alcNum))))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end
	
	--获取原单位和新单位的名称、负责人等：
	declare @oldClgName nvarchar(30), @oldClgManager nvarchar(30), @oldUName nvarchar(30)	--原院部名称\原院部负责人\原使用单位名称
	declare @newClgName nvarchar(30), @newClgManager nvarchar(30), @newUName nvarchar(30) 	--新院部名称\新单位负责人\新使用单位名称
	select @oldClgName = clgName, @oldClgManager = manager from college where clgCode = @oldClgCode
	select @oldUName = uName from useUnit where uCode = @oldUCode
	select @newClgName = clgName, @newClgManager = manager from college where clgCode = @newClgCode
	select @newUName = uName from useUnit where uCode = @newUCode
	--取接受负责人的姓名：
	declare @acceptMan nvarchar(30)
	set @acceptMan = isnull((select cName from userInfo where jobNumber = @acceptManID),'')
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--更新主表：
		update equipmentAllocation
		set alcDate = @alcDate,
			oldClgCode = @oldClgCode, oldClgName = @oldClgName, oldClgManager = @oldClgManager, 
			oldUCode = @oldUCode, oldUName = @oldUName,
			newClgCode = @newClgCode, newClgName = @newClgName, newClgManager = @newClgManager, 
			newUCode = @newUCode, newUName = @newUName,
			alcReason = @alcReason, 
			acceptComments = @acceptComments, acceptManID = @acceptManID, acceptMan = @acceptMan,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--释放原明细表中的设备长事务锁：
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum=''
		where eCode in (select eCode from equipmentAllocationDetail where alcNum = @alcNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
		
		--删除原明细表记录：
		delete equipmentAllocationDetail where alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	
		--插入明细表：
		declare @runRet int 
		exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
		if (@runRet <>0)
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新调拨单', '用户' + @modiManName 
												+ '更新了调拨单['+ @alcNum +']。')
GO
select * from equipmentAllocation
drop PROCEDURE verifyAlcApply
/*
	name:		verifyAlcApply
	function:	7.审核（生效）调拨单
				注意：这个存储过程同时也生效调拨单
	input: 
				@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
														--8位日期代码+4位流水号
				@eManagerID char(10),			--设备处管理负责人ID
				
				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的调拨单息正被别人锁定，2:该单据已经通过审核（生效），不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-10-15增加设备生命周期表中的变动凭证登记！
				modi by lw 2012-8-9增加释放设备的长事务锁,修改新保管人处理
*/
create PROCEDURE verifyAlcApply
	@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
											--8位日期代码+4位流水号
	@eManagerID char(10),			--设备处管理负责人ID

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--检查单据状态:
	declare @alcStatus int			--调拨单状态：0->未生效， 2->生效
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 2
		return
	end
	
	--获取审核人姓名：
	declare @eManager nvarchar(30)		--设备处管理负责人
	set @eManager = isnull((select cName from userInfo where jobNumber = @eManagerID),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--获取新单位代码和名称：
	declare @newClgCode char(3), @newClgName nvarchar(30)		--新院部代码/新院部名称
	declare @newUCode varchar(8), @newUName nvarchar(30)		--新使用单位代码/新使用单位名称
	select @newClgCode = newClgCode, @newClgName = newClgName, @newUCode = newUCode, @newUName= newUName 
	from equipmentAllocation 
	where alcNum = @alcNum

	set @updateTime = getdate()

	--生效调拨单：
	begin tran
		--更新设备列表：
		update equipmentList
		set 
			clgCode = @newClgCode,
			uCode = @newUCode,
			keeperID = a.newKeeperID,
			keeper = a.newKeeper,
			lock4LongTime = '0', lInvoiceNum=''	--释放长事务锁
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--更新设备生命周期表：
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,
			changeType, changeInvoiceID) 
		select e.eCode, e.eName, e.eModel, e.eFormat, 
			e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper,
			e.annexAmount, e.price, e.totalAmount,
			@updateTime, '该设备被调拨到新单位：'+@newClgName+'[' + @newUName +']',
			'调拨', @alcNum
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
							left join useUnit u on e.uCode = u.uCode
		where e.eCode in (select eCode 
						from equipmentAllocationDetail 
						where alcNum = @alcNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		update equipmentAllocation
		set eManagerID = @eManagerID, eManager = @eManager,
			alcStatus = 2,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
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
	values(@modiManID, @modiManName, @updateTime, '审核生效调拨单', '用户' + @modiManName 
												+ '审核并生效了调拨单['+ @alcNum +']。')
GO
--测试：
declare @updateTime smalldatetime
declare @Ret		int
exec dbo.verifyAlcApply '10', '2010112301', '2010112301',  @updateTime output, @Ret output
select @updateTime, @Ret

select * from equipmentList 
where eCode in (select eCode 
				from equipmentAllocationDetail 
				where alcNum = '10')

select * from equipmentAllocation where alcNum = '10'

drop PROCEDURE effectAlcApply
/*
	name:		effectAlcApply
	function:	7.1.生效调拨单
				注意：这个存储过程不需要审核人，只能用在本院部内调拨。
	input: 
				@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
														--8位日期代码+4位流水号
				
				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的调拨单息正被别人锁定，2:该单据已经通过审核（生效），不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-15
	UpdateDate: modi by lw 2012-8-9增加释放设备的长事务锁,修改新保管人处理
				modi by lw 2013-8-19修订@newUCode长度错误问题

*/
create PROCEDURE effectAlcApply
	@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
											--8位日期代码+4位流水号

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--检查单据状态:
	declare @alcStatus int			--调拨单状态：0->未生效， 2->生效
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--获取新单位代码新保管人
	declare @newClgCode char(3)		--新院部代码
	declare @newUCode varchar(8)	--新使用单位代码
	select @newClgCode = newClgCode, @newUCode = newUCode from equipmentAllocation where alcNum = @alcNum
	set @updateTime = getdate()

	--生效调拨单：
	begin tran
	
		--更新设备列表：
		update equipmentList
		set 
			clgCode = @newClgCode,
			uCode = @newUCode,
			keeperID = a.newKeeperID,
			keeper = a.newKeeper,
			lock4LongTime = '0', lInvoiceNum=''	--释放长事务锁
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--更新设备生命周期表：
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,
			changeType, changeInvoiceID) 
		select e.eCode, e.eName, e.eModel, e.eFormat, 
			e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper,
			e.annexAmount, e.price, e.totalAmount,
			@updateTime, '该设备被调拨给新保管人：'+e.keeper,
			'调拨', @alcNum
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
							left join useUnit u on e.uCode = u.uCode
		where e.eCode in (select eCode 
						from equipmentAllocationDetail 
						where alcNum = @alcNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		update equipmentAllocation
		set eManagerID = @modiManID, eManager = @modiManName,
			alcStatus = 2,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
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
	values(@modiManID, @modiManName, @updateTime, '生效调拨单', '用户' + @modiManName 
												+ '生效了调拨单['+ @alcNum +']。')
GO
--测试：
declare	@updateTime smalldatetime --更新时间
declare	@Ret		int --操作成功标识

exec dbo.effectAlcApply '201308190001','G201300052',@updateTime output, @Ret output
select @Ret

update equipmentAllocation set alcStatus=0
select * from equipmentAllocationDetail
delete eqpLifeCycle where eCode='20130020'
select * from equipmentList where eCode='20130020'


/*
	name:		delAlcApply
	function:	8.删除指定的调拨申请单
	input: 
				@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
													--8位日期代码+4位流水号
				@delManID varchar(10) output,	--删除人，如果当前调拨申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的调拨申请单不存在，2：要删除的调拨申请单正被别人锁定，
							3：该申请单已经被审核生效，不能删除，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2012-8-9增加释放设备的长事务锁

*/
create PROCEDURE delAlcApply
	@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
											--8位日期代码+4位流水号
	@delManID varchar(10) output,	--删除人，如果当前调拨申请单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的调拨申请单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @alcStatus int			--调拨单状态：0->未生效， 2->生效
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 3
		return
	end
	begin tran
		--更新设备列表,释放长事务锁：
		update equipmentList
		set 
			lock4LongTime = '0', lInvoiceNum=''
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		delete equipmentAllocation where alcNum = @alcNum	--明细单会自动级联删除！
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
	values(@delManID, @delManName, getdate(), '删除调拨申请单', '用户' + @delManName
												+ '删除了调拨申请单['+ @alcNum +']。')

GO

drop PROCEDURE cancelVerifyAlcApply
/*
	name:		cancelVerifyAlcApply
	function:	9.撤销调拨单审核
				注意：这个存储过程检查调拨后是否有数据更动，如果有更动则返回出错信息！
	input: 
				@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
														--8位日期代码+4位流水号
				
				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的调拨单不存在,2：要取消审核的调拨单正被别人锁定，
							3：该单据不是已审核状态，
							4：该单据中的设备已经变动，5：该调拨单中的设备正被人编辑或有长事务锁，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-10-15
	UpdateDate: modi by lw 2012-8-9增加长事务锁处理
*/
create PROCEDURE cancelVerifyAlcApply
	@alcNum char(12),				--主键：调拨单号,由第3号号码发生器产生
											--8位日期代码+4位流水号

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前调拨单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的调拨单是否存在
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @alcStatus int			--调拨单状态：0->未生效， 2->生效
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 2)
	begin
		set @Ret = 3
		return
	end

	--检查该调拨单涉及的设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from equipmentAllocationDetail where alcNum = @alcNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> '0' and not(lock4LongTime = '2' and lInvoiceNum=@alcNum))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--逐个扫描检查生成的设备：检查调拨后变动
	declare @eCode char(8)
	declare tar cursor for
	select eCode from equipmentAllocationDetail
	where alcNum = @alcNum
	OPEN tar
	FETCH NEXT FROM tar INTO @eCode
	WHILE @@FETCH_STATUS = 0
	begin
		declare @lastChangeType varchar(10)
		declare @lastChangeInvoiceID varchar(30)
		select top 1 @lastChangeInvoiceID = changeInvoiceID, @lastChangeType = changeType 
		from eqpLifeCycle 
		where eCode = @eCode
		order by rowNum desc
		select @lastChangeInvoiceID , @lastChangeType 
		
		if (isnull(@lastChangeType,'')<>'调拨' and isnull(@lastChangeInvoiceID,'')<>@alcNum)	--有其他操作
		begin
			CLOSE tar
			DEALLOCATE tar
			set @Ret = 4
			return
		end
		FETCH NEXT FROM tar INTO @eCode
	end
	CLOSE tar
	DEALLOCATE tar

	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--撤销生效调拨单：
	begin tran
		--更新设备列表：
		update equipmentList
		set 
			clgCode = a.oldClgCode,
			uCode = a.oldUCode,
			keeperID = a.oldKeepID,
			keeper = a.oldKeeper,
			lock4LongTime = '2', lInvoiceNum=@alcNum	--重新锁定长事务锁
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--删除设备生命周期表中的调拨信息：
		delete eqpLifeCycle where changeInvoiceID= @alcNum and changeType = '调拨'
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		update equipmentAllocation
		set eManagerID = '', eManager = '',
			alcStatus = 0,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
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
	values(@modiManID, @modiManName, @updateTime, '取消调拨审核', '用户' + @modiManName 
												+ '取消了调拨单['+ @alcNum +']的审核。')
GO




use epdc2
select * from equipmentAllocation 
where alcNum in (select alcNum from equipmentAllocationDetail where eCode ='10000129')

select * from equipmentAllocationDetail where alcNum='201101150005'


--打印设计用视图：
--列表报表：
CREATE VIEW [dbo].[eqpAllocation]
AS
SELECT     dbo.equipmentAllocation.alcNum, dbo.equipmentAllocationDetail.eName, dbo.equipmentAllocationDetail.totalAmount, dbo.equipmentAllocation.alcDate, 
                      dbo.equipmentAllocation.oldClgName, dbo.equipmentAllocation.oldUName, dbo.equipmentAllocation.newClgName, dbo.equipmentAllocation.newUName, 
                      dbo.equipmentAllocation.totalNum, dbo.equipmentAllocation.totalMoney, dbo.equipmentAllocation.oldKeeper, dbo.equipmentAllocation.newKeeper
FROM         dbo.equipmentAllocation INNER JOIN
                      dbo.equipmentAllocationDetail ON dbo.equipmentAllocation.alcNum = dbo.equipmentAllocationDetail.alcNum

GO


--卡片报表：
CREATE VIEW eqpAlcDetail
AS
select a.alcNum, a.eCode, a.eName, e.eModel, e.eFormat, a.totalAmount 
from equipmentAllocationDetail a left join equipmentList e on a.eCode = e.eCode
go


