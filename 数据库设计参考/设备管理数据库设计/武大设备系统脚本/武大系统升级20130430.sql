--2013-05-01����л�ϵͳ���ݿ⵼�룺
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

--����ͳ�Ʊ�û�е��룺
delete totalCenter
delete appDirTotal
delete fundSrcTotal
delete subTotal
delete unitGroupTotal

--����ϵͳ���뷢������
delete sysNumbers


--����һ̨�豸�����������ں�Ʒ������:
select * from equipmentList where eCode='02000340'

update equipmentList 
set makedate='2002-02-01',
	buyDate='2002-02-01',
	eName='��ʽ��ӡ��',
	eTypeCode='05010501',eTypeName='��ӡ��',aTypeCode='714199'
where eCode='02000340'

--���û��ʹ�õ�λ���豸��
select * from equipmentList where isnull(clgCode,'')=''
select * from equipmentList where isnull(uCode,'')='' or isnull(clgCode,'')=''
select acceptApplyID,clgCode,uCode, * from equipmentList where isnull(uCode,'')='' or isnull(clgCode,'')=''

select * from equipmentList where eCode in (select �豸��� from e)
update equipmentList
set clgCode=e.Ժ������, uCode=e.ʹ�õ�λ����
from equipmentList m right join e on m.eCode=e.�豸���

select * from e

select distinct ���յ��� from e
select * from eqpAcceptInfo where acceptApplyID in (select ���յ��� from e)

update eqpAcceptInfo
set clgCode=e.Ժ������, clgName = clg.clgName,
uCode=e.ʹ�õ�λ����, uName = u.uName
from eqpAcceptInfo a right join e on a.acceptApplyID=e.���յ��� 
left join college clg on e.Ժ������ = clg.clgCode 
left join useUnit u on e.ʹ�õ�λ����=u.uCode


--����ȱʧ�������������豸��
select * from equipmentList where cCode not in (select cCode from country)
and cCode = ''
--����һ�������ݣ�
12014049	201209170028	�ʼǱ�����	3AC		NULL	   	����IBM	2012-08-09 00:00:00	R9RK3CF	�人�κ�Խ�Ƽ��������ι�˾	2012-09-16 00:00:00			0.00	05010105	�ʼǱ�����	711105	2 	2 	4600.00	4600.00	134	13417	NULL	���ǲ�	NULL		2012-09-17 11:24:00	NULL	˧����	00003914	���ִ�	NULL	1	NULL	NULL	0	NULL	NULL	NULL	NULL	00003914	���ִ�	2012-09-17 11:24:00	
ֱ���޶�Ϊ'�й�'

update equipmentList 
set cCode = '156'
where eCode='12014049'

update eqpAcceptInfo
set cCode = '156'
where acceptApplyID='201209170028'

select * from country where cName='�й�' 

--���ɳ���ȱʧ���豸��
select * from equipmentList where isnull(factory,'') = ''
order by acceptDate desc

--���۵�λȱʧ���豸��
select * from equipmentList where isnull(business,'') = ''

--������Դȱʧ����������豸��
select fCode,aCode, * from equipmentList where fCode not in(select fCode from fundSrc)

--ʹ�÷���ȱʧ����������豸��
select * from equipmentList where aCode not in(select aCode from appDir)

--��������ȱʧ���豸��
select * from equipmentList where makeDate is null

--��������ȱʧ���豸��
select * from equipmentList where buyDate is null

--����ȡ�÷�ʽ�Ͳɹ���֯��ʽ��
update equipmentList
set obtainMode = 1,purchaseMode=2
select eCode,'����' as status 
use epdc211

	--�����豸��
update equipmentList
set obtainMode = 7
where notes like '%����%'
		or factory like '%�人��ѧ%'
		or eModel like '%����%'
		or eFormat like '%����%'
	--�����豸��
update equipmentList
set obtainMode = 4
where fCode = '6'




--2011��11���������������ı��ϵ����⴦��
	--������С�͵ģ�������ϸ���Ǵ��͵ĵ��ݣ���175̨�豸
select '="' + scrapNum + '"','="' + eCode + '"', eName, * from bEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 0
)

	--�����Ǵ��͵ģ�������ϸ����С�͵ĵ��ݣ�
select eCode,* from sEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 1
)



select * from equipmentList

--���������޶����飺
--�豸����������򲻷��������λ����Ϊ��00��������豸��
select '="'+eTypeCode+'"' [����������], eTypeName [������������], '="'+aTypeCode+'"' [����������], '="'+eCode+'"', '="'+acceptApplyID+'"', e.* , c.clgName, u.uName
from equipmentList e left join college c on e.clgCode=c.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode not in(select eTypeCode from typeCodes)
order by [����������]


--��������������룺
select aTypeCode, eTypeCode, eTypeName,* 
from equipmentList
where isnull(aTypeCode,'')=''


--���������λ��
update equipmentList
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode




--���¼��㳤��������