use epdc211
/*
	����豸����ϵͳ-��ά���ʹ洢������ƣ�����Ȩ�޹���͹�����־
	author:		¬έ
	CreateDate:	2010-11-22
	UpdateDate: 2011-9-12�������Ȩ�ޱ�
				1.ԭsysRight���������޸�Ϊֻ����ϵͳ����ģ������ݶ����������ɵ�������ָ���û�����ʹ�õĹ���ģ���������Դ��
				2.����sysDataOpr(���ݲ�������������ϵͳ������Դ��֧�ֵĲ�������Ϊ4���������ѯ���༭����������ƣ��ɵ�99�Ŵ����ֵ�������
				3.��Ӧ�޸Ľ�ɫȨ�޺����ӽ�ɫȨ�޲�����
				4.��ԭ�û�Ȩ�ޱ�ȥ������Ϊ�û���ɫ���û���Ȩ�޸�Ϊ��̬���㡣
				5.���ӹ�����־���ݹ���
				2012-8-4�޸����Ȩ�ޱ�
				1.��ϵͳȨ�ޱ�����ʿ����ȷ���
*/
--1.0Ȩ�ޱ�
select * from sysRight
drop table sysRight
CREATE TABLE [dbo].[sysRight]
(
	rightName nvarchar(30) not null,	--Ȩ������
	rightEName varchar(30) not null,	--Ȩ�޵�Ӣ����������
	Url varchar(200) null,				--Ȩ�޹��ܶ�Ӧ��Url add by lw 2011-6-5
	rightType char(1) not null,			--Ȩ�����F->����ģ�飬D->���ݶ���
	rightKind smallint not null,		--����������
	rightClass smallint default(0),		--����������
	rightItem smallint default(0),		--������С��
	canUse char(1) not null,			--�ܹ���Ϊ��ʹ�á����䣺Y->�ܣ�N->������
	rightDesc nvarchar(100) null,		--Ȩ������
 CONSTRAINT [PK_sysRight] PRIMARY KEY CLUSTERED 
(
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
--���Ȩ�ޣ�by lw 2012-10-13
insert sysRight(rightName, rightEName,Url, rightType, rightKind, rightClass,rightItem,canUse,rightDesc )
select '�����豸','overageEqpList','overView/overageEqpList.html', rightType, rightKind, 5,rightItem,canUse,'���Բ�ѯ�����������豸�����Ȩ����'
from sysRight
where rightKind = 4 and rightClass = 2

insert sysRight(rightName, rightEName,Url, rightType, rightKind, rightClass,rightItem,canUse,rightDesc )
select '�ҵ��豸','myEqpList','overView/myEqpList.html', rightType, rightKind, 6,rightItem,canUse,'��ѯ�ҵ�ȫ���豸��Ȩ����'
from sysRight
where rightKind = 4 and rightClass = 2


use epdc211
select partSize, objDesc partSizeName, * from sysRightPartSize s left join codeDictionary cd on s.partSize = cd.objCode and cd.classCode = 98


select * from sysRightPartSize
--1.1Ȩ�ޣ�ϵͳ��Դ�����ȱ�
DROP TABLE [dbo].[sysRightPartSize]
CREATE TABLE [dbo].[sysRightPartSize]
(
	rightKind smallint not null,		--����������
	rightClass smallint default(0),		--����������
	rightItem smallint default(0),		--������С��
	partSize int not null,				--ϵͳȨ�ޣ���Դ���Ŀ������ȣ��ɵ�98�Ŵ����ֵ䶨��
 CONSTRAINT [PK_sysRightPartSize] PRIMARY KEY CLUSTERED 
(
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC,
	[partSize] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
--���������
ALTER TABLE [dbo].[sysRightPartSize]  WITH CHECK ADD  CONSTRAINT [FK_sysRightPartSize_sysRight] FOREIGN KEY([rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRight] ([rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRightPartSize] CHECK CONSTRAINT [FK_sysRightPartSize_sysRight] 
go
--���Ȩ�ޣ�by lw 2012-10-13
--�����豸��
insert sysRightPartSize(rightKind,rightClass,rightItem,partSize)
select rightKind,5,rightItem,partSize from sysRightPartSize where rightKind = 4 and rightClass = 2

insert sysDataOpr(sortNum, rightKind,rightClass,rightItem,oprType,oprName,oprEName,oprDesc)
select sortNum, rightKind,5,rightItem,oprType,oprName,oprEName,oprDesc from sysDataOpr where rightKind = 4 and rightClass = 2
--�ҵ��豸��
insert sysRightPartSize(rightKind,rightClass,rightItem,partSize)
values(4,6,0,1)
select * from sysRightPartSize where rightKind = 4 and rightClass = 6
insert sysDataOpr(sortNum, rightKind,rightClass,rightItem,oprType,oprName,oprEName,oprDesc)
select sortNum, rightKind,6,rightItem,oprType,oprName,oprEName,oprDesc from sysDataOpr where rightKind = 4 and rightClass = 2
select * from sysDataOpr where rightKind = 4 and rightClass = 6


--�������뵥�ͱ��ϵ�û��ʹ�õ�λ��������ȣ�add by lw 2012-10-19
select rightKind,rightClass,rightItem, partSize from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2
delete from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2

--1.2���ݲ�����������������ݱ�Ϊ��̬���ݣ����Բ�û�н�������������Ƴ�һ������
alter table [dbo].[sysDataOpr] add sortNum smallint default(0)				--�������
drop table sysDataOpr
CREATE TABLE [dbo].[sysDataOpr]
(
	sortNum smallint null,				--�������
	rightKind smallint not null,		--�������Ӧ�����ݶ������
	rightClass smallint default(0),		--�������Ӧ�����ݶ�������
	rightItem smallint default(0),		--�������Ӧ�����ݶ���С��
	oprType smallint not null,			--����������ɵ�99�Ŵ����ֵ䶨��
	oprName varchar(20) not null,		--����������
	oprEName varchar(20) not null,		--������Ӣ������
	oprDesc varchar(100) null			--����������
 CONSTRAINT [PK_sysDataOpr] PRIMARY KEY CLUSTERED 
(
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC,
	[oprName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--���������
ALTER TABLE [dbo].[sysDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysDataOpr_sysRight] FOREIGN KEY([rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRight] ([rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysDataOpr] CHECK CONSTRAINT [FK_sysDataOpr_sysRight] 
go


--����ϵͳȨ�ޣ�add by lw 2013-10-30
select * from sysDataOpr where rightKind=3 and rightClass=6 order by sortNum
update sysDataOpr 
set sortNum = sortNum+1
where rightKind=3 and rightClass=6 and sortNum>6

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(7,3,6,0,2,'չ��','cmdExceeding','���¶���ָ���豸��鵥��Ԥ�ƽ�������')

update sysDataOpr 
set sortNum = sortNum+1
where rightKind=3 and rightClass=6 and sortNum>4

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(5,3,6,0,1,'�����豸','cmdCheckMyEqps','��ʾ�豸��鵥����Ҫ��������豸')

update sysDataOpr 
set oprName='�鿴�豸'
where rightKind=3 and rightClass=6 and oprEName='cmdCheckEqps'
update sysDataOpr 
set oprName='�����豸'
where rightKind=3 and rightClass=6 and oprEName='cmdCheckMyEqps'



--���Ȩ�ޣ�by lw 2012-10-13
insert sysDataOpr(rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
select rightKind,5,rightItem,oprType, oprName, oprEName,oprDesc from [sysDataOpr] where rightKind = 4 and rightClass = 2

--����ϵͳȨ�ޣ�add by lw 2012-10-13
delete sysDataOpr
where sortNum=13 and rightKind =3 and  rightClass = 1 and rightItem=0
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(13,3,1,0,4,'����','cmdChange','�����豸��һ�����������뱣�ܵ�λ���ܸ���')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(14,3,1,0,4,'���','cmdAudit','�����Ч�豸һ�������������Ϣ')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(15,3,1,0,2,'״̬','cmdStatus','�趨�豸��״̬')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(16,3,1,0,1,'�����豸','cmdLockList','��ѯȫ�����������豸')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(17,3,1,0,1,'������ʷ','cmdChangeHistory','��ѯ�豸�ĸ�����ʷ���')

select * from sysDataOpr where rightKind=3 order by rightKind, rightclass,sortNum

insert sysDataOpr(sortNum, rightKind,rightClass,rightItem,oprType,oprName,oprEName,oprDesc)
select sortNum, rightKind,5,rightItem,oprType,oprName,oprEName,oprDesc from sysDataOpr where rightKind = 4 and rightClass = 2

--�������뵥�ͱ��ϵ�û��ʹ�õ�λ��������ȣ�add by lw 2012-10-19
select rightKind,rightClass,rightItem, partSize from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2
delete from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2

--����һ������Ĳ�����Ӧɾ����by lw 2012-10-13
select * from sysDataOpr
where rightKind = 2 and rightClass = 1 and oprEName='cmdCancelVerify'
delete sysDataOpr
where rightKind = 2 and rightClass = 1 and oprEName='cmdCancelVerify'

--��ȡϵͳ���еĲ�����
select distinct oprType, oprName, oprEName, oprDesc 
from sysDataOpr

/*
Ȩ�޹滮��													
		F��ʾΪ�����ܣ�D��ʾΪ�����б�											
����ģ������ݶ���	Ӣ������			URL								Ȩ�����	����	����	С��	����ʹ��	���ݶ����ѯ��Χ������Լ��		��ѯ������		...		Ȩ������
																														ȫУ	��Ժ��	����λ			ɸѡ	���Ŀ�Ƭ...		
�豸�ɹ�			planApplyForm										F			1		0		0		��																	���Բ����豸�ɹ������ܵ�Ȩ����
	�ɹ����뵥		eqpPlanApplyList	planApply/eqpPlanApplyList.html	D			1		1		0		��			��		��		��				��		��		...		���Բ������ɹ����뵥����Ȩ�ޣ������Բɹ����뵥�Ĳ�ѯ���༭����������ƣ�ִ�У���Ȩ����
	���üƻ�		eqpPlanList			planApply/eqpPlanList.html		D			1		2		0		��			��		��		��				��		��		...		���Բ��������üƻ�����Ȩ�ޣ������Թ��üƻ��Ĳ�ѯ�������ͳ���Ȩ����
...
��ϸ������μ����人��ѧ�豸������ϢϵͳȨ�޹滮��
*/


--2.0.��ɫ��
--��ɫ����ƻ��ṩ�Ĺ��ܣ�
--1.���ݽ�ɫID��ȡ��ɫ�Ļ�����Ϣ
--2.���ݽ�ɫID��ȡ��ɫ��Ȩ����Ϣ
--3.��ӽ�ɫ������Ϣ
--4.�޸Ľ�ɫ������Ϣ
--5.ɾ��ȫ����ɫ��Ȩ��
--6.��ӽ�ɫ��Ȩ�ޣ�������
--7.������������
--8.ɾ����ɫ
--9.���ݻ�ȡ�û���Ȩ�޻�ȡ��ɫ��Ȩ��
drop TABLE [dbo].[sysRole]
CREATE TABLE [dbo].[sysRole] 
(
	sysRoleID smallint IDENTITY(1,1) NOT NULL,	--��ɫID
	sysRoleName varchar(50) null,				--��ɫ������
	sysRoleDesc nvarchar(100) null,				--��ɫ����
	--add by lw 2011-9-4���ӽ�ɫ�ּ���
	sysRoleType smallint default(1),			--��ɫ�����ɵ�100�Ŵ����ֵ䶨�壺1��>ͨ�õ�У����ɫ��2->ͨ�õ�Ժ������ɫ��3->ͨ�õĵ�λ��ɫ��4->�������ض�Ժ���Ľ�ɫ,5->�������ض���λ�Ľ�ɫ
	sysRoleTypeName varchar(100) default('ͨ�õ�У����ɫ'),	--��ɫ��������ƣ�������� add by lw 2012-8-3
	--�ض�����Ľ�ɫ����Ժ����λ
	clgCode char(3) null,						--ѧԺ����
	clgName nvarchar(30) null,					--ѧԺ���ƣ������ֶΣ����ǿ��Խ�����ʷ����	add by lw 2012-8-3
	uCode varchar(8) null,						--ʹ�õ�λ����
	uName nvarchar(30) null,					--ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����add by lw 2012-8-3
	
	isOff int default(0),				--�Ƿ�ע����0->δע����1->��ע��
	setOffDate smalldatetime,			--ע������

	--�����ˣ�add by lw 2012-10-29Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���:modi by lw 2012-11-06�ſ��ǿ���֤
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10) null,			--��ǰ���������༭�˹���

 CONSTRAINT [PK_sysRole] PRIMARY KEY CLUSTERED 
(
	[sysRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET IDENTITY_INSERT dbo.sysRole ON

--Ԥ����Ľ�ɫ��
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType, modiManID)
values('�����û�', 'ϵͳԤ���ӵ��ȫ��Ȩ�޵��û�', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('У��ϵͳ����Ա', 'ϵͳԤ���ӵ��ȫ��Ȩ�޵��û�', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('Ժ��ϵͳ����Ա', 'ϵͳԤ���������Ժ����ϵͳ����Ա��ӵ�б�Ժ���ض���ɫ����Ȩ��', 2, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('��λϵͳ����Ա', 'ϵͳԤ��������ڵ�λ��ϵͳ����Ա��ӵ�б���λ�ض���ɫ����Ȩ��', 3, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('һ���û�', 'ϵͳԤ�����ͨ�û���ϵͳĬ�Ϸ���ý�ɫ��ÿһ���½��û������û�ֻӵ�б���λ�ĵ��ݲ�ѯȨ��', 3, '0000000000')

select * from codeDictionary where classCode = 100
select * from sysRole

--2.1.��ɫȨ�ޱ�
DROP TABLE [dbo].[sysRoleRight] 
CREATE TABLE [dbo].[sysRoleRight] 
(
	sysRoleID smallint not null,		--���:��ɫID
	rightName nvarchar(30) not null,	--Ȩ������:�����ֶ�
	rightEName varchar(30) not null,	--Ȩ�޵�Ӣ���������� add by lw 2011-6-5
	Url varchar(200) null,				--Ȩ�޹��ܶ�Ӧ��Url add by lw 2011-6-5
	rightType char(1) not null,			--Ȩ�����F->�����ܣ�D->�����б�
	rightKind smallint not null,		--����:����
	rightClass smallint not null,		--����:����
	rightItem smallint not null,		--����:С��
	rightDesc nvarchar(100) null,		--Ȩ������:�����ֶ�
 CONSTRAINT [PK_sysRoleRight] PRIMARY KEY CLUSTERED 
(
	[sysRoleID] ASC,
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--�����������ϵͳ��ɫ����������
ALTER TABLE [dbo].[sysRoleRight]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleRight_sysRole] FOREIGN KEY([sysRoleID])
REFERENCES [dbo].[sysRole] ([sysRoleID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleRight] CHECK CONSTRAINT [FK_sysRoleRight_sysRole]
go

--�����������ϵͳȨ�ޱ���������
ALTER TABLE [dbo].[sysRoleRight]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleRight_sysRight] FOREIGN KEY([rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRight] ([rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleRight] CHECK CONSTRAINT [FK_sysRoleRight_sysRight]
go


--��ȡָ���û���Ȩ�ޣ�
select rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, 
canUse, max(canQuery) canQuery, max(canEdit) canEdit, max(canOutput) canOutput, max(canCheck) canCheck, rightDesc 
from sysRoleRight
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '0000000000')
group by rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse, rightDesc 
order by rightKind, rightClass, rightItem

--��ȡָ���û���Ȩ�޲�����
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprLocal) oprLocal
from sysRoleDataOpr
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '0000000000')
group by rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc

select * from [sysRoleDataOpr]
where rightKind = 3 and rightClass = 2
--2.2.��ɫȨ�޲�����
alter TABLE [dbo].[sysRoleDataOpr] add oprPartSize int	--ϵͳȨ�ޣ���Դ���Ĳ������ȣ��ɵ�98�Ŵ����ֵ䶨��
update [dbo].[sysRoleDataOpr]
set oprPartSize = oprLocal

alter TABLE [dbo].[sysRoleDataOpr] add	sortNum smallint null				--�������
update [dbo].[sysRoleDataOpr]
set sortNum = 0

DROP TABLE [dbo].[sysRoleDataOpr] 
CREATE TABLE [dbo].[sysRoleDataOpr] 
(
	sysRoleID smallint not null,		--���:��ɫID
	sortNum smallint null,				--�������
	rightKind smallint not null,		--����:����
	rightClass smallint not null,		--����:����
	rightItem smallint not null,		--����:С��
	oprType smallint not null,			--����������ɵ�99�Ŵ����ֵ䶨��
	oprName varchar(20) not null,		--����������
	oprEName varchar(20) not null,		--������Ӣ������
	oprDesc varchar(100) null,			--����������
	oprPartSize int not null,			--ϵͳȨ�ޣ���Դ���Ĳ������ȣ��ɵ�98�Ŵ����ֵ䶨��
 CONSTRAINT [PK_sysRoleDataOpr] PRIMARY KEY CLUSTERED 
(
	[sysRoleID] ASC,
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC,
	[oprType] ASC,
	[oprName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--�����������ϵͳ��ɫ����������
ALTER TABLE [dbo].[sysRoleDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleDataOpr_sysRole] FOREIGN KEY([sysRoleID])
REFERENCES [dbo].[sysRole] ([sysRoleID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleDataOpr] CHECK CONSTRAINT [FK_sysRoleDataOpr_sysRole]
go

--��������������ݲ���������������
ALTER TABLE [dbo].[sysRoleDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleDataOpr_sysDataOpr] FOREIGN KEY([rightKind],[rightClass],[rightItem],[oprName])
REFERENCES [dbo].[sysDataOpr] ([rightKind],[rightClass],[rightItem],[oprName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleDataOpr] CHECK CONSTRAINT [FK_sysRoleDataOpr_sysDataOpr]
go

--������������ɫȨ�ޱ���������:�������ᵼ�¶���·��������Ҫ�ֹ�ά�����ɫȨ�ޱ�ļ���������
ALTER TABLE [dbo].[sysRoleDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleDataOpr_sysRoleRight] FOREIGN KEY([sysRoleID],[rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRoleRight] ([sysRoleID],[rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleDataOpr] CHECK CONSTRAINT [FK_sysRoleDataOpr_sysRoleRight]
go

--�������ݣ�2011-10-16
select * from sysRoleDataOpr where sysRoleID = 1

delete sysRoleDataOpr  where sysRoleID = 1 and rightKind = 3 and rightClass = 3 and oprName='ȡ������'

insert sysRoleDataOpr(sysRoleID, rightKind, rightClass, rightItem, 
		oprType, oprName, oprEName, oprDesc, oprLocal)
values(1, 3,3,0,4,'ȡ������','cmdCancelCheck','ȡ�����ݵĸ���ִ��', 9)

insert sysRoleDataOpr(sysRoleID, rightKind, rightClass, rightItem, 
		oprType, oprName, oprEName, oprDesc, oprLocal)
values(7,6,0,2,'�ظ�','cmdAnswer','�ظ�ָ�����û����',9)

select * from sysRoleDataOpr where sysRoleID = 1
select * from sysRole where sysRoleID = 1
select * from sysRoleRight where sysRoleID = 1

select * from sysRole
select * from wd.dbo.sysRole
use epdc211
select * from userInfo where sysUserName='axs'
select * from sysUserRole where jobNumber = '00011680'
select * from sysRoleDataOpr where rightKind= '3' and rightClass='1' and sysRoleID in (4,5)
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprPartSize) oprPartSize
from sysRoleDataOpr
where rightKind= '3' and rightClass='1' and sysRoleID in (4,5)
group by rightKind, rightClass, rightItem, sortNum, oprType, oprName, oprEName, oprDesc


select rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc  
from sysRoleRight 
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '00200977') 
group by rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc 
order by rightKind, rightClass, rightItem; 
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprPartSize) oprPartSize 
from sysRoleDataOpr 
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '00200977') 
group by rightKind, rightClass, rightItem, sortNum, oprType, oprName, oprEName, oprDesc 
order by rightKind, rightClass, rightItem, sortNum, oprType


select * from sysRolePartSize where rightKind= '3' and rightClass='1' and sysRoleID in (4,5)
select * from sysRoleRight
--3.�û���ɫ��
drop table sysUserRole
CREATE TABLE [dbo].[sysUserRole] 
(
	jobNumber varchar(10) not null,		--���:����
	sysUserName varchar(30) not null,	--�û���:�����ֶ�
	sysRoleID smallint not null,		--���:��ɫID
	sysRoleName varchar(50) null,		--��ɫ������:�����ֶ�
	sysRoleType smallint not null		--��ɫ����:�����ֶ�,�ɵ�100�Ŵ����ֵ䶨�壺1��>ͨ�õ�У����ɫ��2->ͨ�õ�Ժ������ɫ��3->ͨ�õĵ�λ��ɫ��4->�������ض�Ժ���Ľ�ɫ,5->�������ض���λ�Ľ�ɫ
 CONSTRAINT [PK_sysUserRole] PRIMARY KEY CLUSTERED 
(
	[jobNumber] ASC,
	[sysRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--������������û�����������
ALTER TABLE [dbo].[sysUserRole]  WITH CHECK ADD  CONSTRAINT [FK_sysUserRole_userInfo] FOREIGN KEY([jobNumber])
REFERENCES [dbo].[userInfo] ([jobNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysUserRole] CHECK CONSTRAINT [FK_sysUserRole_userInfo]
go

--�����������ϵͳ��ɫ����������
ALTER TABLE [dbo].[sysUserRole]  WITH CHECK ADD  CONSTRAINT [FK_sysUserRole_sysRole] FOREIGN KEY([sysRoleID])
REFERENCES [dbo].[sysRole] ([sysRoleID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysUserRole] CHECK CONSTRAINT [FK_sysUserRole_sysRole]
go

select * from sysRole
drop PROCEDURE addSysRole
/*
	name:		addSysRole
	function:	3.1.��ӽ�ɫ
				ע�⣺����洢���̽�ɫ����Ψһ�ԣ�������Ϊ��ռʽ�༭��
	input: 
				@sysRoleName varchar(50),		--��ɫ������
				@sysRoleDesc nvarchar(100),		--��ɫ����
				@sysRoleType smallint,			--��ɫ�����ɵ�100�Ŵ����ֵ䶨�壺1��>ͨ�õ�У����ɫ��2->ͨ�õ�Ժ������ɫ��3->ͨ�õĵ�λ��ɫ��4->�������ض�Ժ���Ľ�ɫ,5->�������ض���λ�Ľ�ɫ
				@clgCode char(3),				--ѧԺ����
				@uCode varchar(8),				--ʹ�õ�λ���룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������.modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	

				--����ά�����:
				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output,
							0:�ɹ���1:�ý�ɫ���Ѿ��Ǽǹ���9:δ֪����
				@createTime smalldatetime output,
				@sysRoleID int output		--��ɫID
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: modi by lw 2012-8-3���ӽ�ɫ�����������ơ�Ժ�����ƺ�ʹ�õ�λ����
				modi by lw 2012-10-29���Ӵ����˴���
*/
create PROCEDURE addSysRole
	@sysRoleName varchar(50),		--��ɫ������
	@sysRoleDesc nvarchar(100),		--��ɫ����
	@sysRoleType smallint,			--��ɫ�����ɵ�100�Ŵ����ֵ䶨�壺1��>ͨ�õ�У����ɫ��2->ͨ�õ�Ժ������ɫ��3->ͨ�õĵ�λ��ɫ��4->�������ض�Ժ���Ľ�ɫ,5->�������ض���λ�Ľ�ɫ
	@clgCode char(3),				--ѧԺ����
	@uCode varchar(8),				--ʹ�õ�λ����
	@createManID varchar(10),		--�����˹���

	@Ret		int output,			--0:�ɹ���1:�ý�ɫ���Ѿ��Ǽǹ���9:δ֪����
	@createTime smalldatetime output,
	@sysRoleID int output		--��ɫID
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����ɫ���Ƿ�Ψһ��
	declare @count as int
	set @count = (select count(*) from sysRole where sysRoleName = @sysRoleName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	--��ȡ��ɫ���������/ѧԺ����/ʹ�õ�λ����:
	declare @sysRoleTypeName varchar(100),@clgName nvarchar(30), @uName nvarchar(30)
	set @sysRoleTypeName = isnull((select objDesc from codeDictionary where classCode = 100 and objCode = @sysRoleType),'')
	if (@clgCode <> '')
		set @clgName = (select clgName from college where clgCode = @clgCode)
	else
		set @clgName = ''
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else
		set @uName = ''

	--ȡ����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert sysRole(sysRoleName, sysRoleDesc, sysRoleType, sysRoleTypeName, clgCode, clgName, uCode, uName,
				--�������:
				createManID, createManName, createTime, lockManID)
	values(@sysRoleName, @sysRoleDesc, @sysRoleType, @sysRoleTypeName, @clgCode, @clgName, @uCode, @uName,
				--�������:
				@createManID, @createManName, @createTime, @createManID)
	--��ȡID:
	set @sysRoleID = (select sysRoleID from sysRole where sysRoleName = @sysRoleName)
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'��ӽ�ɫ','ϵͳ����' + @createManName + 
								'��Ҫ������˽�ɫ[' + @sysRoleName +']��')
GO

/*
	name:		checkSysRoleName
	function:	3.2.����ɫ���Ƿ�Ψһ
	input: 
				@sysRoleName varchar(50),		--��ɫ������
	output: 
				@Ret		int output
							0:Ψһ��>1����Ψһ��-1��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE checkSysRoleName
	@sysRoleName varchar(50),		--��ɫ������
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from sysRole where sysRoleName = @sysRoleName)
GO


drop PROCEDURE querySysRoleLockMan
/*
	name:		querySysRoleLockMan
	function:	3.3.��ѯָ����ɫ�Ƿ��������ڱ༭
	input: 
				@sysRoleID smallint,	--��ɫID
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���1����ѯ���������Ǹ�ID�Ľ�ɫ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˹���
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE querySysRoleLockMan
	@sysRoleID smallint,		--��ɫID
	@Ret		int output,		--�����ɹ���ʶ
	@lockManID varchar(10) output--��ǰ���ڱ༭���˹���
	WITH ENCRYPTION 
AS
	set @Ret = 1
	set @lockManID = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	set @Ret = 0
GO

drop PROCEDURE lockSysRole4Edit
/*
	name:		lockSysRole4Edit
	function:	3.4.������ɫ�༭������༭��ͻ
	input: 
				@sysRoleID smallint,		--��ɫID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ľ�ɫ�����ڣ�2:Ҫ�����Ľ�ɫ���ڱ����˱༭��9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE lockSysRole4Edit
	@sysRoleID smallint,		--��ɫID
	@lockManID varchar(10) output,--�����ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output	--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ�Ա�Ƿ����
	declare @count as int
	set @count = (select count(*) from sysRole where sysRoleID = @sysRoleID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update sysRole
	set lockManID = @lockManID 
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	
	--ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = isnull((select sysRoleName from sysRole where sysRoleID = @sysRoleID),'')
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������ɫ�༭', 'ϵͳ����' + @lockManName
												+ '��Ҫ�������˽�ɫ['+ @sysRoleName +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockSysRoleEditor
/*
	name:		unlockSysRoleEditor
	function:	3.5.�ͷŽ�ɫ�༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@sysRoleID smallint,		--��ɫID
				@lockManID varchar(10) output,	--�����ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE unlockSysRoleEditor
	@sysRoleID smallint,		--��ɫID
	@lockManID varchar(10) output,	--�����ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin 
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update sysRole set lockManID = '' where sysRoleID = @sysRoleID
	end
	else
	begin
		set @Ret = 0
		return
	end
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = isnull((select sysRoleName from sysRole where sysRoleID = @sysRoleID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷŽ�ɫ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˽�ɫ['+ @sysRoleName +']�ı༭����')
GO

drop PROCEDURE updateSysRoleInfo
/*
	name:		updateSysRoleInfo
	function:	3.6.����ָ���Ľ�ɫ�Ļ�����Ϣ
	input: 
				@sysRoleID smallint,			--��ɫID
				@sysRoleName varchar(50),		--��ɫ������
				@sysRoleDesc nvarchar(100),		--��ɫ����
				@sysRoleType smallint,			--��ɫ�����ɵ�100�Ŵ����ֵ䶨�壺1��>ͨ�õ�У����ɫ��2->ͨ�õ�Ժ������ɫ��3->ͨ�õĵ�λ��ɫ��4->�������ض�Ժ���Ľ�ɫ,5->�������ض���λ�Ľ�ɫ
				@clgCode char(3),				--ѧԺ����
				@uCode varchar(8),				--ʹ�õ�λ���룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������.modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĽ�ɫ��Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: modi by lw 2012-8-3���ӽ�ɫ�����������ơ�Ժ�����ƺ�ʹ�õ�λ����
*/
create PROCEDURE updateSysRoleInfo
	@sysRoleID smallint,			--��ɫID
	@sysRoleName varchar(50),		--��ɫ������
	@sysRoleDesc nvarchar(100),		--��ɫ����
	@sysRoleType smallint,			--��ɫ�����ɵ�100�Ŵ����ֵ䶨�壺1��>ͨ�õ�У����ɫ��2->ͨ�õ�Ժ������ɫ��3->ͨ�õĵ�λ��ɫ��4->�������ض�Ժ���Ľ�ɫ,5->�������ض���λ�Ľ�ɫ
	@clgCode char(3),				--ѧԺ����
	@uCode varchar(8),				--ʹ�õ�λ���룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������.modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--��ȡ��ɫ���������/ѧԺ����/ʹ�õ�λ����:
	declare @sysRoleTypeName varchar(100),@clgName nvarchar(30), @uName nvarchar(30)
	set @sysRoleTypeName = isnull((select objDesc from codeDictionary where classCode = 100 and objCode = @sysRoleType),'')
	if (@clgCode <> '')
		set @clgName = (select clgName from college where clgCode = @clgCode)
	else
		set @clgName = ''
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else
		set @uName = ''

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--��ȡԭ��ɫ����
	declare @oldSysRoleName varchar(50)
	set @oldSysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	set @updateTime = getdate()

	update sysRole
	set sysRoleName = @sysRoleName, sysRoleDesc = @sysRoleDesc, 
		sysRoleType = @sysRoleType, sysRoleTypeName = @sysRoleTypeName,
		clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--����û��Ƿ��޸��˽�ɫ����
	declare @notes varchar(100)
	set @notes = '�û�' + @modiManName + '�����˽�ɫ['+ @oldSysRoleName +']�Ļ�����Ϣ��'
	if @oldSysRoleName <> @sysRoleName
	begin
		set @notes = @notes + 'ע�⣺��ɫ����Ϊ�ˣ�' + @oldSysRoleName + '��'
	end
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���½�ɫ�Ļ�����Ϣ', @notes)
GO


drop PROCEDURE clearSysRoleRights
/*
	name:		clearSysRoleRights
	function:	3.7.�����ɫ��Ȩ�ޱ�
	input: 
				@sysRoleID smallint,			--��ɫID

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĽ�ɫ��Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE clearSysRoleRights
	@sysRoleID smallint,			--��ɫID

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	begin tran
		delete sysRoleRight
		where sysRoleID = @sysRoleID

		update sysRole
		set --ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where sysRoleID = @sysRoleID
	commit tran	
		
	set @Ret = 0

	--��ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����ɫ��Ȩ��', '�û�' + @modiManName + '����˽�ɫ['+ @sysRoleName +']��Ȩ�ޡ�')
GO

drop PROCEDURE clearSysRoleDataOprs
/*
	name:		clearSysRoleDataOprs
	function:	3.7.1.�����ɫ�����ݲ���
	input: 
				@sysRoleID smallint,			--��ɫID

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĽ�ɫ��Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-24
	UpdateDate: 
*/
create PROCEDURE clearSysRoleDataOprs
	@sysRoleID smallint,			--��ɫID

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		delete sysRoleDataOpr
		where sysRoleID = @sysRoleID

		update sysRole
		set --ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where sysRoleID = @sysRoleID
	commit tran	
	
	set @Ret = 0

	--��ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����ɫ�����ݲ�����', '�û�' + @modiManName + '����˽�ɫ['+ @sysRoleName +']�����ݲ�������')
GO

use epdc2
drop PROCEDURE addSysRoleRight
/*
	name:		addSysRoleRight
	function:	3.8.��ӽ�ɫ��Ȩ��
				ע�⣺�������û��ά�������ά����¼�͵Ǽǹ�����־
	input: 
				@sysRoleID smallint,		--��ɫID
				@rightKind smallint,		--����:����
				@rightClass smallint,		--����:����
				@rightItem smallint,		--����:С��

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĽ�ɫ��Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: modi by lw 2012-8-4 ���ݱ���Ƶı仯�޸Ľӿ�
*/
create PROCEDURE addSysRoleRight
	@sysRoleID smallint,		--��ɫID
	@rightKind smallint,		--����:����
	@rightClass smallint,		--����:����
	@rightItem smallint,		--����:С��

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--��ȡȨ�޵��������ֶΣ�
	declare @rightName nvarchar(30)	--Ȩ������:�����ֶ�
	declare @rightEName varchar(30)	--Ȩ�޵�Ӣ���������� add by lw 2011-6-5
	declare @Url varchar(200)		--Ȩ�޹��ܶ�Ӧ��Url add by lw 2011-6-5
	declare @rightType char(1)		--Ȩ�����F->�����ܣ�D->�����б�
	declare @rightDesc nvarchar(100)--Ȩ������:�����ֶ�
	select @rightName = rightName, @rightEName = rightEName, @Url = Url, @rightType = rightType, @rightDesc = rightDesc
	from sysRight
	where rightKind = @rightKind and rightClass = @rightClass and rightItem = @rightItem

	insert sysRoleRight(sysRoleID, rightName, rightEName, Url, rightType,
						rightKind, rightClass, rightItem,
						rightDesc)
	values(@sysRoleID, @rightName, @rightEName, @Url, @rightType,
						@rightKind, @rightClass, @rightItem,
						@rightDesc)
	
	set @Ret = 0
GO
--���ԣ�
select * from sysRoleRight where sysRoleID = 2
select * from sysRoleDataOpr where sysRoleID = 2

delete sysRoleRight where sysRoleID = 2

drop PROCEDURE addSysRoleDataOpr
/*
	name:		addSysRoleDataOpr
	function:	3.8.1.��ӽ�ɫ�����ݲ���
				ע�⣺�������û��ά�������ά����¼�͵Ǽǹ�����־
	input: 
				@sysRoleID smallint,		--��ɫID
				@rightKind smallint,		--����:����
				@rightClass smallint,		--����:����
				@rightItem smallint,		--����:С��
				@oprType smallint,			--����������ɵ�99�Ŵ����ֵ䶨��
				@oprName varchar(20),		--����������
				@oprEName varchar(20),		--������Ӣ������
				@oprDesc varchar(100),		--����������
				@oprPartSize int,			--ϵͳȨ�ޣ���Դ���Ĳ������ȣ��ɵ�98�Ŵ����ֵ䶨��

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĽ�ɫ��Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-24
	UpdateDate: modi by lw 2012-8-4 ���ݱ���Ƶı仯�޸Ľӿ�
				modi by lw 2012-8-8 ���Ӳ��������ֶδ���
*/
create PROCEDURE addSysRoleDataOpr
	@sysRoleID smallint,		--��ɫID
	@rightKind smallint,		--����:����
	@rightClass smallint,		--����:����
	@rightItem smallint,		--����:С��
	@oprType smallint,			--����������ɵ�99�Ŵ����ֵ䶨��
	@oprName varchar(20),		--����������
	@oprEName varchar(20),		--������Ӣ������
	@oprDesc varchar(100),		--����������
	@oprPartSize int,			--ϵͳȨ�ޣ���Դ���Ĳ������ȣ��ɵ�98�Ŵ����ֵ䶨��

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	insert sysRoleDataOpr(sysRoleID, sortNum, rightKind, rightClass, rightItem, 
						oprType, oprName, oprEName, oprDesc, oprPartSize)
	select @sysRoleID, sortNum, @rightKind, @rightClass, @rightItem, 
						@oprType, @oprName, @oprEName, @oprDesc, @oprPartSize
	from sysDataOpr
	where rightKind = @rightKind and rightClass = @rightClass and rightItem = @rightItem 
			and oprEName = @oprEName
	
	set @Ret = 0
GO


DROP PROCEDURE sysRoleSetOff
/*
	name:		sysRoleSetOff
	function:	3.9.ע��ָ���Ľ�ɫ
	input: 
				@sysRoleID smallint,				--��ɫID
				@setOffDate smalldatetime,			--ע������

				--ά�����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĽ�ɫ��Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE sysRoleSetOff
	@sysRoleID smallint,				--��ɫID
	@setOffDate smalldatetime,			--ע������

	--ά�����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update sysRole
	set isOff = 1, setOffDate = @setOffDate,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--��ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 'ע����ɫ', '�û�' + @modiManName 
												+ 'ע���˽�ɫ['+ @sysRoleName +']��')
GO

drop PROCEDURE delSysRoleInfo
/*
	name:		delSysRoleInfo
	function:	3.10.ɾ��ָ���Ľ�ɫ
	input: 
				@sysRoleID smallint,			--��ɫID
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1���ý�ɫ�����ڣ�2:Ҫɾ���Ľ�ɫ��Ϣ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate:
*/
create PROCEDURE delSysRoleInfo
	@sysRoleID smallint,			--��ɫID
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ľ�ɫ�Ƿ����
	declare @count as int
	set @count=(select count(*) from sysRole where sysRoleID = @sysRoleID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--��ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	delete sysRole where sysRoleID = @sysRoleID
	--Ȩ�ޱ��Զ�����ɾ����
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����ɫ', '�û�' + @delManName
												+ 'ɾ���˽�ɫ['+ @sysRoleName +']����Ϣ��')

GO
--���ԣ�

DROP PROCEDURE sysRoleSetActive
/*
	name:		sysRoleSetActive
	function:	3.11.����ָ���Ľ�ɫ
	input: 
				@sysRoleID smallint,			--��ɫID

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ����Ľ�ɫ�����ڣ�2��Ҫ����Ľ�ɫ�������������༭��9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE sysRoleSetActive
	@sysRoleID smallint,				--��ɫID

	--ά�����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ��ɫ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���Ľ�ɫ�Ƿ����
	declare @count as int
	set @count=(select count(*) from sysRole where sysRoleID = @sysRoleID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update sysRole
	set isOff = 0, setOffDate = null,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--��ȡ��ɫ����
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '�����ɫ', '�û�' + @modiManName 
												+ '�����˽�ɫ['+ @sysRoleName +']��')
GO

use epdc2
select distinct actions from workNote
--4.������־��
truncate TABLE [dbo].[workNote]
drop TABLE [dbo].[workNote]
alter TABLE [dbo].[workNote] alter column workNoteID bigint
CREATE TABLE [dbo].[workNote] (
	userID varchar(10) not null,								--�û����ID�����ţ�
	userName nvarchar(30) NOT NULL ,							--�û���
	actionTime smalldatetime NOT NULL ,							--�ʱ��
	actions nvarchar(10) COLLATE Chinese_PRC_CI_AS NOT NULL ,	--�����
	actionObject nvarchar(500) COLLATE Chinese_PRC_CI_AS NULL ,	--���������
	workNoteID bigint IDENTITY (1, 1) NOT NULL 
CONSTRAINT [PK_workNote] PRIMARY KEY CLUSTERED 
(
	[workNoteID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_workNote] ON [dbo].[workNote] 
(
	[userID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_workNote_1] ON [dbo].[workNote] 
(
	[actions] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_workNote_2] ON [dbo].[workNote] 
(
	[actionTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

drop TABLE [dbo].[workNoteBak]
alter TABLE [dbo].[workNoteBak] alter column workNoteID bigint
CREATE TABLE [dbo].[workNoteBak] (
	userID varchar(10) not null,								--�û����ID�����ţ�
	userName nvarchar(30) NOT NULL ,							--�û���
	actionTime smalldatetime NOT NULL ,							--�ʱ��
	actions nvarchar(10) COLLATE Chinese_PRC_CI_AS NOT NULL ,	--�����
	actionObject nvarchar(500) COLLATE Chinese_PRC_CI_AS NULL ,	--���������
	workNoteID bigint NOT NULL 
CONSTRAINT [PK_workNoteBak] PRIMARY KEY CLUSTERED 
(
	[workNoteID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_workNoteBak] ON [dbo].[workNoteBak] 
(
	[userID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_workNoteBak_1] ON [dbo].[workNoteBak] 
(
	[actions] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_workNoteBak_2] ON [dbo].[workNoteBak] 
(
	[actionTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


select * from workNote
--��ȡ��������䣺
select * from workNote

drop PROCEDURE addWorkNote
/*
	name:		addWorkNote
	function:	4.1.�Ǽǹ�����־
				ע������һ���ṩ���ϲ��������������ݿ��ʱ�����Ǽ���־�ĺ���
	input: 
				@modiManID varchar(10),			--ά����(�Ǽ���)
				@actions nvarchar(10),			--�����
				@actionObject nvarchar(500),	--���������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE addWorkNote
	--ά�����:
	@modiManID varchar(10),			--ά����(�Ǽ���)
	@actions nvarchar(10),			--�����
	@actionObject nvarchar(500),	--���������

	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	--�Ǽ�ʱ��
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, @actions, @actionObject)
	set @Ret = 0
GO

drop PROCEDURE delWorkNote
/*
	name:		delWorkNote
	function:	4.2.ɾ��ָ����Χ�Ĺ�����־
	input: 
				@where varchar(460),			--ָ���ķ�Χ
				@modiManID varchar(10),			--ά����(�Ǽ���)
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-10-15
	UpdateDate: 
*/
create PROCEDURE delWorkNote
	--ά�����:
	@where varchar(460),			--ָ���ķ�Χ
	@modiManID varchar(10),			--ά����(�Ǽ���)
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	--�Ǽ�ʱ��
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	
	begin tran
		--ɾ��ǰǿ�Ʊ��ݹ�����־��
		insert workNoteBak
		select * from workNote where workNoteID not in (select workNoteID from workNoteBak)
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end    
		
		--ɾ����־��
		exec(N'delete workNote ' + @where)
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end    
	commit tran
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, 'ɾ��������־', '�û�' + @modiManName
												+ 'ɾ���˷�ΧΪ['+ @where +']�Ĺ�����־��')
	set @Ret = 0
GO
--���ԣ�
declare @Ret int
declare @where varchar(460)
--set @where = 'where actions=' + char(39) + 'ɾ��������־' + char(39)
exec dbo.delWorkNote @where, '0000000000', @ret output
select @Ret
select * from workNoteBak
select * from workNote


use epdc2
select * from sysUserRole

insert sysUserRole
select jobNumber, sysUserName, 1, '�����û�', 1 from userInfo



