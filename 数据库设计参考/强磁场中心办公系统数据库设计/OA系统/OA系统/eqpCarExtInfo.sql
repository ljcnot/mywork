use hustOA
/*
	����豸������Ϣϵͳ-�����豸������Ϣ
	author:		¬έ
	CreateDate:	2012-9-29
	UpdateDate: 
*/

--2.eqpCarExtInfo�������豸-������չ��Ϣ����
drop TABLE eqpCarExtInfo
CREATE TABLE eqpCarExtInfo(
	eCode char(8) not null,			--����/������豸���
	origin int null,				--��������(CheLCDID),�ɵ�20�Ŵ����ֵ䶨��
	carModle nvarchar(30) null,		--����ͺ�(Spec)
	chassisNumber nvarchar(36) null,--���ܺ�(CheJH)	
	licensePlate nvarchar(10) null,	--���ƺ�(ChePH)	
	brandModel nvarchar(20) null,	--�����ͺ�(ChangPXH)	
	engineNumber nvarchar(20) null,	--��������(FaDJH)	
	powerNumber varchar(4) null,	--������(PaiQL)	
	--arrangePlait int null,		--�������(BianZQKID),�ɵ�
	useDirection int null,			--������;���࣬�ɵ�21�Ŵ����ֵ䶨��

 CONSTRAINT [PK_eqpCarExtInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpCarExtInfo] WITH CHECK ADD CONSTRAINT [FK_eqpCarExtInfo_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpCarExtInfo] CHECK CONSTRAINT [FK_eqpCarExtInfo_equipmentList]
GO

--������
--���ƺ�:
CREATE NONCLUSTERED INDEX [IX_eqpCarExtInfo] ON [dbo].[eqpCarExtInfo] 
(
	[licensePlate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

