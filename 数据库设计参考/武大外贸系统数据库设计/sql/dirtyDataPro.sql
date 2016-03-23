/*
	武大设备管理信息系统-数据清理
	author:		卢苇
	CreateDate:	2011-11-20
	UpdateDate: 
*/
use epdc2
--国别缺失或国别代码错误的设备：
select * from equipmentList where cCode not in (select cCode from country)

--生成厂家缺失的设备：
select * from equipmentList where isnull(factory,'') = '' or factory = '*'

--销售单位缺失的设备：
select * from equipmentList where isnull(business,'') = '' or business = '*'

--经费来源缺失或代码错误的设备：
select * from equipmentList where fCode not in(select fCode from fundSrc)

--使用方向缺失或代码错误的设备：
select * from equipmentList where aCode not in(select aCode from appDir)

--设备分类代码错误或不符合最后两位不能为“00”规则的设备：
select eTypeCode, aTypeCode, * from equipmentList where eTypeCode not in(select eTypeCode from typeCodes)

--没有院部的设备：
select clgCode, * from equipmentList where clgCode not in(select clgCode from college)

--没有使用单位或使用单位与代码表中不一致的设备：
select clgCode, uCode, * from equipmentList where clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit)

--上次数据清理的时候处理的重号设备：
select * from equipmentList where eCode like '%T%'



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

	--已经报废但设备状态不对的设备：
select curEqpStatus, scrapDate, * from equipmentList 
where eCode in (
		select eCode from sEquipmentScrapDetail 
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2'))
		union all
		select eCode from bEquipmentScrapDetail
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2'))
		)
and curEqpStatus <> '6'


--缺少验收信息的设备：
select acceptApplyID, acceptDate, oprMan, acceptManID, acceptMan, * from equipmentList 
where isnull(acceptApplyID,'') ='' or isnull(acceptDate,'') = '' or isnull(oprMan,'')='' or isnull(acceptManID,'') = '' or isnull(acceptMan,'') = ''
	--发现部分设备的验收人可以使用验收单中的验收人填充：
select acceptManID, acceptMan, * from eqpAcceptInfo where acceptApplyID = '0000032773'
select * from userInfo where cName = '刘静'	--这个人不存在了！
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

--检查没有生命周期表信息的设备：
select * from equipmentList
where eCode not in (select eCode from eqpLifeCycle)
