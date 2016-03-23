--2013-05-01武大切换系统数据库导入：
use epdc211
delete accountTitle
delete activeUsers
delete appDir
delete bulletinInfo
delete bulletinResouce
delete college
delete country
delete eqpCheckInfo
delete fundSrc
delete moneySectionTotal
delete SMSInfo
delete userInfo
delete workNote
delete workNoteBak
delete userReport

delete userReportAnswer

delete userReportAppendFile



delete eqpAcceptInfo
select * from eqpAcceptInfo
insert eqpAcceptInfo(acceptApplyType, acceptApplyID, applyDate, acceptApplyStatus, procurementPlanID,	
	eTypeCode, eTypeName, aTypeCode, eName, eModel, eFormat, unit,
	cCode, factory, makeDate, serialNumber, buyDate, business, fCode, aCode,
	clgCode, clgName, uCode, uName, keeperID, keeper, eqpLocate,

	annexName, annexAmount, price, totalAmount, sumNumber, sumAmount,
	oprManID, oprMan, notes, startECode, endECode, accountCode,
	acceptDate, acceptManID, acceptMan, photoXml, 
	obtainMode, purchaseMode,
	createManID, createManName, createTime, modiManID, modiManName, modiTime, lockManID)
select acceptApplyType, acceptApplyID, applyDate, acceptApplyStatus, procurementPlanID,	
	eTypeCode, eTypeName, e.aTypeCode, eName, eModel, eFormat, g.unit,
	cCode, factory, makeDate, serialNumber, buyDate, isnull(business,factory), fCode, aCode,
	clgCode, clgName, uCode, uName, '', keeper, '',

	annexName, annexAmount, price, totalAmount, sumNumber, sumAmount,
	'', oprMan, notes, startECode, endECode, accountCode,
	acceptDate, acceptManID, acceptMan, '', 
	1, 2,
	modiManID, modiManName, modiTime, modiManID, modiManName, modiTime, lockManID
from epdc2.dbo.eqpAcceptInfo e left join GBT14885 g on g.aTypeCode = e.aTypeCode

select business,factory,* 
from epdc2.dbo.eqpAcceptInfo
where isnull(business,'')=''
order by acceptDate desc

delete eqpCodeList
delete equipmentAllocation
delete equipmentList
delete equipmentScrap
delete sysUserRole
delete useUnit

DELETE eqpLifeCycle
delete bEquipmentScrapDetail
delete sEquipmentScrapDetail
delete equipmentAllocationDetail
delete equipmentAnnex

--以下统计表没有导入：
delete totalCenter
delete appDirTotal
delete fundSrcTotal
delete subTotal
delete unitGroupTotal

--重置系统号码发生器：
delete sysNumbers


--发现一台设备明显验收日期和品名错误:
select * from equipmentList where eCode='02000340'

update equipmentList 
set makedate='2002-02-01',
	buyDate='2002-02-01',
	eName='针式打印机',
	eTypeCode='05010501',eTypeName='打印机',aTypeCode='714199'
where eCode='02000340'

--检查没有使用单位的设备：
select * from equipmentList where isnull(clgCode,'')=''
select * from equipmentList where isnull(uCode,'')='' or isnull(clgCode,'')=''
select acceptApplyID,clgCode,uCode, * from equipmentList where isnull(uCode,'')='' or isnull(clgCode,'')=''

select * from equipmentList where eCode in (select 设备编号 from e)
update equipmentList
set clgCode=e.院部代码, uCode=e.使用单位代码
from equipmentList m right join e on m.eCode=e.设备编号

select * from e

select distinct 验收单号 from e
select * from eqpAcceptInfo where acceptApplyID in (select 验收单号 from e)

update eqpAcceptInfo
set clgCode=e.院部代码, clgName = clg.clgName,
uCode=e.使用单位代码, uName = u.uName
from eqpAcceptInfo a right join e on a.acceptApplyID=e.验收单号 
left join college clg on e.院部代码 = clg.clgCode 
left join useUnit u on e.使用单位代码=u.uCode


--国别缺失或国别代码错误的设备：
select * from equipmentList where cCode not in (select cCode from country)
and cCode = ''
--发现一条脏数据：
12014049	201209170028	笔记本电脑	3AC		NULL	   	联想IBM	2012-08-09 00:00:00	R9RK3CF	武汉鑫恒越科技有限责任公司	2012-09-16 00:00:00			0.00	05010105	笔记本电脑	711105	2 	2 	4600.00	4600.00	134	13417	NULL	何亚伯	NULL		2012-09-17 11:24:00	NULL	帅青燕	00003914	周又聪	NULL	1	NULL	NULL	0	NULL	NULL	NULL	NULL	00003914	周又聪	2012-09-17 11:24:00	
直接修订为'中国'

update equipmentList 
set cCode = '156'
where eCode='12014049'

update eqpAcceptInfo
set cCode = '156'
where acceptApplyID='201209170028'

select * from country where cName='中国' 

--生成厂家缺失的设备：
select * from equipmentList where isnull(factory,'') = ''
order by acceptDate desc

--销售单位缺失的设备：
select * from equipmentList where isnull(business,'') = ''

--经费来源缺失或代码错误的设备：
select fCode,aCode, * from equipmentList where fCode not in(select fCode from fundSrc)

--使用方向缺失或代码错误的设备：
select * from equipmentList where aCode not in(select aCode from appDir)

--生产日期缺失的设备：
select * from equipmentList where makeDate is null

--销售日期缺失的设备：
select * from equipmentList where buyDate is null

--计算取得方式和采购组织形式：
update equipmentList
set obtainMode = 1,purchaseMode=2
select eCode,'自制' as status 
use epdc211

	--自制设备：
update equipmentList
set obtainMode = 7
where notes like '%自制%'
		or factory like '%武汉大学%'
		or eModel like '%自制%'
		or eFormat like '%自制%'
	--捐赠设备：
update equipmentList
set obtainMode = 4
where fCode = '6'




--2011年11月数据清理遗留的报废单问题处理：
	--单据是小型的，但是明细表是大型的单据：共175台设备
select '="' + scrapNum + '"','="' + eCode + '"', eName, * from bEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 0
)

	--单据是大型的，但是明细表是小型的单据：
select eCode,* from sEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 1
)



select * from equipmentList

--分类代码的修订与检查：
--设备分类代码错误或不符合最后两位不能为“00”规则的设备：
select '="'+eTypeCode+'"' [教育部编码], eTypeName [教育部分类名], '="'+aTypeCode+'"' [财政部编码], '="'+eCode+'"', '="'+acceptApplyID+'"', e.* , c.clgName, u.uName
from equipmentList e left join college c on e.clgCode=c.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode not in(select eTypeCode from typeCodes)
order by [教育部编码]


--检查财政部分类代码：
select aTypeCode, eTypeCode, eTypeName,* 
from equipmentList
where isnull(aTypeCode,'')=''


--计算计量单位：
update equipmentList
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode




--重新计算长事务锁：