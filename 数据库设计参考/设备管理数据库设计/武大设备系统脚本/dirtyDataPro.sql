/*
	武大设备管理信息系统-数据清理
	author:		卢苇
	CreateDate:	2011-11-20
	UpdateDate: 
*/
use epdc2
--国别缺失或国别代码错误的设备：
select * from equipmentList where cCode not in (select cCode from country)
and cCode = ''
update equipmentList
set cCode = '203'
where cCode = '200'
update equipmentList
set cCode = '203'
where cCode = '810'

update equipmentList
set cCode = '156'
where cCode = '000'

update equipmentList
set cCode = '156'
where cCode = ''

select * from country where cName like '中国'
	--增加一个“其他”国别
	

--生成厂家缺失的设备：
select * from equipmentList where isnull(factory,'') = '' or factory = '*'
	--填“*”
update equipmentList 
set factory='*'
where isnull(factory,'') = '' or factory = '*'
	
--销售单位缺失的设备：
select * from equipmentList where isnull(business,'') = '' or business = '*'
	--把生产厂家填入销售单位
update equipmentList
set business = factory
where isnull(business,'') = '' or business = '*'
	

--经费来源缺失或代码错误的设备：
select fCode,aCode, * from equipmentList where fCode not in(select fCode from fundSrc)
	--原代码为“9”的改为“教育事业费”
select * from equipmentList where fCode not in(select fCode from fundSrc)
update equipmentList 
set fCode=1
where fCode not in(select fCode from fundSrc)

	--根据使用方向确定：“教学”-》“教育事业费”，“科研”-》“科研”
select * from appDir
select * from fundSrc
	
--使用方向缺失或代码错误的设备：
select * from equipmentList where aCode not in(select aCode from appDir)

--生产日期的设备：
select * from equipmentList where makeDate is null
	--手工确认
update equipmentList 
set makeDate='2001-11-19'
where eCode='03010006'

update equipmentList 
set makeDate='2000-01-01'
where makeDate is null

--销售日期的设备：
	--手工确认
select * from equipmentList where buyDate is null
update equipmentList 
set buyDate='2000-01-01'
where buyDate is null
	
--设备分类代码错误或不符合最后两位不能为“00”规则的设备：
use epdc2
select '="'+eTypeCode+'"' [教育部编码], eTypeName [教育部分类名], '="'+aTypeCode+'"' [财政部编码], '="'+eCode+'"', '="'+acceptApplyID+'"', e.* , c.clgName, u.uName
from equipmentList e left join college c on e.clgCode=c.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode not in(select eTypeCode from typeCodes)
order by [教育部编码]
	--手工确认
select eTypeCode, aTypeCode, * from equipmentList where isnull(eTypeCode,'') = ''

select eTypeCode, aTypeCode, * 
from equipmentList 
where isnull(eTypeCode,'') = '' and eName like '%DELL%'

update equipmentList 
set eTypeCode='04070704',
	eTypeName='空气调节器（空调机）',
	aTypeCode='165000'
where isnull(eTypeCode,'') = '' and eName like '%空调%'

select * from typeCodes
where eTypeCode='04070704'

update equipmentList 
set eTypeCode='05010104',
	eTypeName='专用服务器',
	aTypeCode='711104'
where isnull(eTypeCode,'') = '' and eName like '%DELL%'

update equipmentList 
set eTypeCode='03170318',
	eTypeName='数字化照相系统',
	aTypeCode='464302'
where eCode = '10000777'

--09004555	阅片服务器软件
update equipmentList 
set eTypeCode='05010710',
	eTypeName='测金系统',
	aTypeCode='719000  '
where eCode = '09004555'

--10010814	冰柜
update equipmentList 
set eTypeCode='04070711',
	eTypeName='保鲜柜',
	aTypeCode='163000  '
where eCode = '10010814'

--10T01731	电源
update equipmentList 
set eTypeCode='03021018',
	eTypeName='不间断电源',
	aTypeCode='614202'
where eCode = '10T01731'

--11000080	万兆ISCSI存储
update equipmentList 
set eTypeCode='05010535',
	eTypeName='磁盘存储器',
	aTypeCode='712199'
where eCode = '11000080'

--11002647	液氮容器
update equipmentList 
set eTypeCode='04170910',
	eTypeName='液氮生物容器(液氮罐)',
	aTypeCode='352900'
where eCode = '11002647'

update equipmentList 
set eTypeCode='05010105',
	eTypeName='微型电子计算机',
	aTypeCode='711105'
where eCode = '11002423'

update equipmentList 
set eTypeCode='05010549',
	eTypeName='激光打印机',
	aTypeCode='714103'
where eCode = '05000699'

update equipmentList 
set eTypeCode='03010132',
	eTypeName='数字温度仪',
	aTypeCode='741129'
where etypecode='03010100'

update equipmentList 
set eTypeCode='03020408',
	eTypeName='万能电桥',
	aTypeCode='742401'
where etypecode='03020400' and eName = '非平衡电桥'

update equipmentList 
set eTypeCode='05040301',
	eTypeName='主控机',
	aTypeCode='708500'
where eTypeCode='03011100' and eName like '%中控%'

update equipmentList 
set eTypeCode='03061601',
	eTypeName='固结仪',
	aTypeCode='746805'
where eTypeCode='03021601'

update equipmentList 
set eTypeCode='03021018',
	eTypeName='不间断电源',
	aTypeCode='614202'
where eTypeCode='03011018'

update equipmentList 
set eTypeCode='03150840',
	eTypeName='高频电路实验装置',
	aTypeCode='764107'
where eTypeCode='03041815'


update equipmentList 
set eTypeCode='04070304',
	eTypeName='离心风机',
	aTypeCode='134100'
where eCode = '04005312'

update equipmentList 
set eTypeCode='03060906',
	eTypeName='电热恒温培养箱',
	aTypeCode='746499'
where eTypeCode='03066906'

update equipmentList 
set eTypeCode='03060220',
	eTypeName='真空系统',
	aTypeCode='746799'
where eCode in('03003221')

update equipmentList 
set eTypeCode='05010522',
	eTypeName='读卡片机',
	aTypeCode='714900'
where  eTypeCode not in(select eTypeCode from typeCodes) and (eName like '%学生票证防伪识别器')


select eTypeCode [教育部编码], eTypeName [教育部分类名], aTypeCode [财政部编码], * from equipmentList where eTypeCode not in(select eTypeCode from typeCodes)
order by eName

select eTypeCode,* from equipmentList  where eTypeCode not in(select eTypeCode from typeCodes) and (eName like '%学生票证防伪识别器') 
order by eName

select eTypeCode,* from equipmentList  where eTypeCode in('03040310') and eName like '%卡'
select eTypeCode,* from equipmentList  where len(eTypeCode)=7
select eTypeCode,* from equipmentList  where eTypeCode not in(select eTypeCode from typeCodes) and RIGHT(eTypeCode,2)<>'00' and eName like '%激%打%'
select * from typeCodes
where eTypeName like '%读卡%'
where eTypeCode='05010919'

WHERE eKind = '13'


select * from kindTypeCodes
select * from classTypeCodes
WHERE eKind = '13'
select * from subClassTypeCodes
WHERE eKind = '03'

select eTypeCode a, aTypeCode, * from equipmentList where eTypeCode not in(select eTypeCode from typeCodes) and RIGHT(eTypeCode,2)<>'00'
order by a

--没有院部的设备：
select clgCode a, * from equipmentList where clgCode not in(select clgCode from college)
order by a
	--不足3位的编码补“0”
select clgCode a, * from equipmentList where clgCode not in(select clgCode from college) and LEN(clgCode) < 3
order by a
update equipmentList 
set clgCode = '0' + clgCode
where clgCode not in(select clgCode from college) and LEN(clgCode) < 3
	--手工确认
update equipmentList 
set clgCode = '123'
where eCode = '11015937'

select * from college where clgName like '%生命%'

--没有使用单位或使用单位与代码表中不一致的设备：
select clgCode a, keeper, oprman, uCode, * from equipmentList where clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit)
order by a
	--手工确认
update equipmentList 
set uCode = '15602'
where clgCode ='156' and keeper='汪春红' and (clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit))

select clgcode,uCode from equipmentList where keeper='汪春红'
select clgCode,uCode,* from userInfo where cName ='洪昕林'
select * from useUnit
select * from equipmentList 
where clgCode ='0' and (clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit))


--上次数据清理的时候处理的重号设备：
select * from equipmentList where eCode like '%T%'


--设备状态有问题的列表：
select curEqpStatus,* from equipmentList
where eCode in
(
select eCode from sEquipmentScrapDetail 
where scrapNum = '0000002303'
)

select * from bEquipmentScrapDetail
where oldEqpStatus is null

update bEquipmentScrapDetail
set oldEqpStatus = 1
where oldEqpStatus is null

update sEquipmentScrapDetail 
set oldEqpStatus = 1
where scrapNum = '0000002303'


--再次通过报废单确认报废设备：
select * from equipmentScrap where replyState in ('1','2')
	--全部同意的单据：
select * from equipmentScrap where replyState in ('1')
	--部分同意的小型设备报废单：
select * from equipmentScrap where replyState in ('2')

	--未生效的报废单：
select * from equipmentScrap where replyState in ('0')

	--不同意报废的报废单中签署意见有问题的单据：
select * from equipmentScrap where replyState in ('3') and processDesc <> '全部不同意' and processDesc <> '不同意'


	--小型设备报废单中同意报废的设备：
select eCode from sEquipmentScrapDetail 
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2'))
	and processState = '1'
	--大型设备报废单中同意报废的设备：
select eCode,* from bEquipmentScrapDetail
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1'))
	--这个报废单的状态有问题：应该为全部同意！
select eCode,* from bEquipmentScrapDetail
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('2'))
	--经复查是原始单据的问题，直接删除这两个明细单据：
delete bEquipmentScrapDetail
where scrapNum in ('0000000069','0000001235')

	--单据是小型的，但是明细表是大型的单据：共175台设备
select '="' + scrapNum + '"','="' + eCode + '"', eName, * from bEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 0
)

select isBigEquipment, '="' + b.scrapNum + '"','="' + eCode + '"', eName, * 
from bEquipmentScrapDetail b right join equipmentScrap e on  b.scrapNum= e.scrapNum and isnull(e.isBigEquipment,0) = 1
where eCode in
(
	select eCode from bEquipmentScrapDetail
	where scrapNum in(
		select scrapNum from equipmentScrap 
		where isBigEquipment = 0
	)
)

select * from bEquipmentScrapDetail
where eCode in (
	select eCode from bEquipmentScrapDetail
	where scrapNum in(
		select scrapNum from equipmentScrap 
		where isBigEquipment = 0
	)
)
order by eCode

	--单据是大型的，但是明细表是小型的单据：
select eCode,* from sEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 1
)

select curEqpStatus, * from equipmentList e
where eCode in
(
select eCode from sEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 1
)
)
order by e.curEqpStatus

select * from bEquipmentScrapDetail
where eCode in ('01009356','00021927')

select eCode,* from sEquipmentScrapDetail
where scrapNum in ('0000000069','0000001235')

select * from equipmentScrap
where scrapNum in ('0000000069','0000001235')

	--小型报废设备报废单中部分同意报废的设备
select * from sEquipmentScrapDetail 
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('2'))
	and processState = '1'


	--已经报废但设备状态不对的设备：只处理了2011-10-01以后的单据！
select curEqpStatus, scrapDate, * from equipmentList 
where eCode in (
		select eCode from sEquipmentScrapDetail 
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2')  and convert(char(10),scrapDate,120) > '2011-10-01') and processState = '1'
		union all
		select eCode from bEquipmentScrapDetail
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1') and convert(char(10),scrapDate,120) > '2011-10-01')
		)
and curEqpStatus <> '6'


update equipmentList 
set curEqpStatus = '6'
where eCode in (
		select eCode from sEquipmentScrapDetail 
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2')  and convert(char(10),scrapDate,120) > '2011-10-01') and processState = '1'
		union all
		select eCode from bEquipmentScrapDetail
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1') and convert(char(10),scrapDate,120) > '2011-10-01')
		)
and curEqpStatus <> '6'





select * from bEquipmentScrapDetail b left join equipmentScrap e on b.scrapNum = e.scrapNum and isBigEquipment = 1
where eCode in
(
	select eCode from equipmentList 
	where eCode in (
			--select eCode from sEquipmentScrapDetail 
			--where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2')) and processState = '1'
			--union all
			select eCode from bEquipmentScrapDetail
			where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1'))
			)
	and curEqpStatus <> '6'
)

--重新计算待报废设备：
select * from 
equipmentScrap 
where isBigEquipment = 1 and replyState in ('0')

select e.scrapNum, * 
from bEquipmentScrapDetail b inner join equipmentScrap e on b.scrapNum = e.scrapNum and e.isBigEquipment = 1
where e.replyState in ('0')

select curEqpStatus, * from equipmentList
where eCode in
(
	select b.eCode 
	from bEquipmentScrapDetail b inner join equipmentScrap e on b.scrapNum = e.scrapNum and e.isBigEquipment = 1
	where e.replyState in ('0')
)

select b.eCode, count(*) 
from bEquipmentScrapDetail b inner join equipmentScrap e on b.scrapNum = e.scrapNum and e.isBigEquipment = 1
where e.replyState in ('0')
group by b.eCode
having count(*) > 1

--删除了两张重复的大型设备报废单：
0000001329,0000002234
201110190002,0000002235  这两张单据时保留的

update equipmentList
set curEqpStatus = 4
where eCode in
(
select eCode from bEquipmentScrapDetail
where scrapNum in ('201110190002','0000002235')
)

--删除了两张重复的小型设备报废单：
0000002477,0000002478
0000002479保留了这张单据
update equipmentList
set curEqpStatus = 4
where eCode in
(
select eCode from sEquipmentScrapDetail
where scrapNum in ('0000002479')
)

select * from bEquipmentScrapDetail 
where eCode in ('06000054','20H00566')


select * from 
equipmentScrap 
where isBigEquipment = 0 and replyState in ('0')

select s.eCode, count(*) 
from sEquipmentScrapDetail s inner join equipmentScrap e on s.scrapNum = e.scrapNum and e.isBigEquipment = 0
where e.replyState in ('0')
group by s.eCode
having count(*) > 1
select * from sEquipmentScrapDetail
where eCode in('15010035','15010050')



select curEqpStatus, * from equipmentList
where eCode in
(
	select s.eCode
	from sEquipmentScrapDetail s inner join equipmentScrap e on s.scrapNum = e.scrapNum and e.isBigEquipment = 0
	where e.replyState in ('0')
) and curEqpStatus <> '4'

--缺少验收信息的设备：
select acceptApplyID, acceptDate, oprMan, acceptManID, acceptMan, * from equipmentList 
where isnull(acceptApplyID,'') ='' or isnull(acceptDate,'') = '' or isnull(oprMan,'')='' or isnull(acceptManID,'') = '' or isnull(acceptMan,'') = ''
	--发现部分设备的验收人可以使用验收单中的验收人填充：
select acceptManID, acceptMan, * from eqpAcceptInfo where acceptApplyID = '0000032773'
select * from userInfo where cName = '刘  静'	--这个人不存在了！
	--没有验收单又没有报废的设备：使用2010-12-31集中盘点入库？
select acceptApplyID, acceptDate, oprMan, acceptManID, acceptMan, curEqpStatus, * from equipmentList 
where isnull(acceptApplyID,'') ='' and curEqpStatus <> '6'

--验收单的补齐工作应该按这样的流程做：
--1.先补齐设备的信息：
--2.将报废的设备一致化：
--3.根据设备信息集中入库：（这里有一个问题，会计科目的设定！）
	--3.1根据设备清单生成验收单：
	--3.2生成设备生命周期：
--4.集中盘点设备：更正设备的保管信息和扩展信息
--按销售日期作为验收日期！！！

--检查没有生命周期表信息的设备：
select * from equipmentList
where eCode not in (select eCode from eqpLifeCycle)
