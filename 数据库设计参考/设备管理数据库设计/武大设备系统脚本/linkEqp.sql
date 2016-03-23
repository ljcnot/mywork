use HGDepdc211
/*
	�豸������Ϣϵͳ-���ӵ�ʡ��ϵͳ�豸��
	author:		¬έ
	CreateDate:	2012-12-24
	UpdateDate: 
*/
--1.linkEqpInfo�����ӵ��豸����
drop table [dbo].[linkEqpInfo]
CREATE TABLE [dbo].[linkEqpInfo](
	isUploaded nvarchar(4) null,	--�Ƿ��ϱ�
	ZCBH varchar(20) not null,		--�������ʲ����
	StdName nvarchar(30) null,		--�ʲ�����
	CatalogID varchar(7) null,		--�ʲ��������
	QTY	int null,					--����:�����������ɲ�ֵ��ʲ�����������1
	OrgnValue numeric(19,2)	null,	--��ֵ:��ֵ���Ͳ���"�޼�ֵ"ʱ����,��"�����Բ���"��"��ҵ����"��"�����ʽ�"�ϼ����
	SrcName	nvarchar(10) null,		--ȡ�÷�ʽ:����,����,����,����,�û�,����
	fundSrc nvarchar(10) null,		--�ʽ���Դ
	barCode varchar(30) null,		--һά���룺add by lw 2012-11-18
	curEqpStatus nvarchar(10) null,	--���ݱ���Ĺ涨���¶����豸����״���뺬�壺���ֶ��ɵ�2�Ŵ����ֵ䶨�� modi by lw 2011-1-26
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
	keeper nvarchar(30) null,		--������
	eqpLocate nvarchar(100) null,	--�豸���ڵ�ַ:�豸���ڵ�add by lw 2012-5-22�����豸���칦��
	invoiceNum varchar(30) null,	--���ƾ֤��
	acceptYear varchar(10) null,	--�������
	acceptDate varchar(20) null,	--��������
	loginDate varchar(20) null,		--¼������
	acceptMan nvarchar(30) null,	--¼����
	remark nvarchar(300) null,		--��ע

 CONSTRAINT [PK_linkEqpInfo] PRIMARY KEY CLUSTERED 
(
	[ZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

select totalAmount, * from equipmentList

insert linkEqpInfo(isUploaded, ZCBH, StdName, CatalogID, QTY, OrgnValue, SrcName, fundSrc, barCode, curEqpStatus, 
		keeper, eqpLocate, invoiceNum, acceptYear, acceptDate, loginDate, acceptMan,remark)
select
���ϱ�,�ʲ����,�ʲ�����,�������,����,����ԭֵ,���ӷ�ʽ,�ʽ���Դ,������,
ʹ��״��,������,�������,���ƾ֤��,�������,��������,¼������,¼����,��ע
from l

select distinct �ʲ���� from l

select * from linkEqpInfo where ZCBH in(
select l.ZCBH--, e.eCode, l.StdName, e.eName, l.OrgnValue, e.totalAmount, l.QTY, l.acceptYear, e.acceptDate, l.eqpLocate, clg.clgName, e.* , l.*
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join linkEqpInfo l on  e.eName = l.StdName
and e.totalAmount = l.OrgnValue
--and convert(char(4),YEAR(e.acceptDate)) = l.acceptYear
--and clg.clgName = l.eqpLocate
where l.ZCBH is not null)

select * from equipmentList where eName = '΢��' and totalAmount=4100 and eModel='����'

select * from linkEqpInfo

--�ϱ��ʲ����ڿ��豸���Ӻ�ı�
select l.ZCBH, e.eCode, l.StdName, e.eName, l.OrgnValue, e.totalAmount, l.QTY, l.acceptYear, e.acceptDate, l.eqpLocate, clg.clgName, e.* , l.*
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join linkEqpInfo l on  e.eName = l.StdName
and e.totalAmount = l.OrgnValue
--and convert(char(4),YEAR(e.acceptDate)) = l.acceptYear
--and clg.clgName = l.eqpLocate
where l.ZCBH is not null

--ƥ��õı��ϵ����е��豸��
select '=trim("'+l.ZCBH+'")', '=trim("'+e.eCode+'")', l.StdName, e.eName, l.OrgnValue, e.totalAmount, l.QTY, l.acceptYear, e.acceptDate, l.eqpLocate, clg.clgName, e.* , l.*
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join linkEqpInfo l on  e.eName = l.StdName
and e.totalAmount = l.OrgnValue
--and convert(char(4),YEAR(e.acceptDate)) = l.acceptYear
--and clg.clgName = l.eqpLocate
where e.eCode in (select �豸��� from info) and l.ZCBH is not null


--ʡ��ϵͳ���ݷ�����
--PurchaseApplicationDetail ���üƻ���ϸ��
--PurchaseApplicationMaster ���üƻ�����

--AssetTreamentMaster ������������
--AssetTreamentDetail ����������ϸ��

--BasAssetStock �ϱ������ݴ��
--BasAssetSourcesOfFunding ������Դ��
--ModalTable ����ģ���Զ����ֶ�������
--ModalTable_REP_ORDER ģ���ű�
--AccountItemTable ��Ƭ��ű�

--BasClassCode GBT14885-1994
--Basdatatable �����ֵ�
--BasDeptCode ѧУ���Ŵ����
--BasLocationCode ѧУ�ص��
--BASOrganInfo ѧУ������Ϣ��
--BASOrganLevel �����ּ���׼
--BASPersonLevel ���������
--BASProfession ְҵ�����
--BasAdminCode ��������

--ValidTable ��֤��Ϣ��
--MONAUDITFORMULA ������֤���ʽ��

--syxmdmb ʹ����Ŀ��������ݵ�ʹ�÷�ʽ��
--fundstypeCode �ʲ���Ŀ�����
--BJREPZCSYJINYMQKBCODE	�ʲ���ծ���ʲ���Ŀ

