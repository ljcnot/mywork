use newfTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-������
	author:		¬έ
	CreateDate:	2013-6-9
	UpdateDate: 
*/
select * from convertInfo
where convert(varchar(10),convertTime,120)='2013-10-07'
delete convertInfo
where convert(varchar(10),convertTime,120)='2013-10-07'

drop table convertInfo
CREATE TABLE convertInfo(
	currency smallint not null,			--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
	currencyName nvarchar(30) null,		--������ƣ���������
	convertTime smalldatetime not null,	--��������������
	
	purchasePrice money null,			--�ֻ������:ÿ��Ԫ��Ӧ����Ҽ۸�
	cashPurchaseprice money null,		--�ֳ������:ÿ��Ԫ��Ӧ����Ҽ۸�
	offerPrice money null,				--�ֻ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
	cashOfferPrice money null,			--�ֳ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
	discountedPrice money null,			--���������:ÿ��Ԫ��Ӧ����Ҽ۸�

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_convertInfo] PRIMARY KEY CLUSTERED 
(
	[currency] ASC,
	[convertTime]
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE addConvertInfo
/*
	name:		addConvertInfo
	function:	1.���ָ�����ڵ�����Ƽ�
	input: 
				@convertTime varchar(19),	--��������:���á�yyyy-MM-dd hh:mm:ss����ʽ���
				@priceList xml,				--��Ҽ۸���������¸�ʽ��ţ�
											N'<root>
											  <currency id="303" currencyName="Ӣ��">
													<purchasePrice>947.82</purchasePrice>
													<cashPurchaseprice>918.55</cashPurchaseprice>
													<offerPrice>955.43</offerPrice>
													<cashOfferPrice>955.43</cashOfferPrice>
													<discountedPrice>960.96</discountedPrice>
											  </currency>
											  <currency id="502" currencyName="��Ԫ">
													<purchasePrice>609.86</purchasePrice>
													<cashPurchaseprice>605.58</cashPurchaseprice>
													<offerPrice>612.92</offerPrice>
													<cashOfferPrice>612.92</cashOfferPrice>
													<discountedPrice>616.2</discountedPrice>
											  </currency>
											  ...
											</root>'
											
				@isOverlay char(1),			--�����ڸ����ڵĻ���ʱ�Ƿ񸲸�
				
				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1�����ֱ��ֵĻ����������������༭��2�����ֱ��ֵĵ�������Ѵ��ڣ�9:δ֪����
	author:		¬έ
	CreateDate:	2013-6-9
	UpdateDate: 
*/
create PROCEDURE addConvertInfo
	@convertTime varchar(19),	--��������:���á�yyyy-MM-dd hh:mm:ss����ʽ���
	@priceList xml,				--��Ҽ۸���������¸�ʽ��ţ�
	@isOverlay char(1),			--�����ڸ����ڵĻ���ʱ�Ƿ񸲸�

	@createManID varchar(10),	--�����˹���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @convertInfo table(
		currency smallint not null,			--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
		currencyName nvarchar(30) null,		--������ƣ���������
		purchasePrice money null,			--�ֻ������:ÿ��Ԫ��Ӧ����Ҽ۸�
		cashPurchaseprice money null,		--�ֳ������:ÿ��Ԫ��Ӧ����Ҽ۸�
		offerPrice money null,				--�ֻ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
		cashOfferPrice money null,			--�ֳ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
		discountedPrice money null			--���������:ÿ��Ԫ��Ӧ����Ҽ۸�
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
			
	--���༭����
	declare @count int
	set @count = ISNULL((select count(*) from convertInfo c inner join @convertInfo b 
							on c.currency = b.currency and convert(varchar(10),c.convertTime,120) = left(@convertTime,10)
							where isnull(lockManID,'')<>''),0)
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--����Ƿ��е������ݣ�
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
	
	--ȡά���˵�������
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�������Ƽ۱�', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������['+ LEFT(@convertTime,10)+']������Ƽۡ�')
GO
--���ԣ�
DECLARE @priceList xml				--��Ҽ۸���������¸�ʽ��ţ�
SET @priceList = N'<root>
					  <currency id="303" currencyName="Ӣ��">
							<purchasePrice>947.82</purchasePrice>
							<cashPurchaseprice>918.55</cashPurchaseprice>
							<offerPrice>955.43</offerPrice>
							<cashOfferPrice>955.43</cashOfferPrice>
							<discountedPrice>960.96</discountedPrice>
					  </currency>
					  <currency id="502" currencyName="��Ԫ">
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
    function:	2.��ѯָ������ָ�����ֵĻ����Ƿ��������ڱ༭
    input: 
                @convertTime varchar(10),	--��������:���á�yyyy-MM-dd����ʽ���
                @currency smallint,			--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
    output: 
                @Ret		int output		--�����ɹ���ʶ
                            0:�ɹ���9����ѯ����������ָ�����ڵ�ָ�����ֻ��ʲ�����
                @lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
    author:		¬έ
    CreateDate:	2013-06-09
    UpdateDate: 
*/
create PROCEDURE queryConvertInfoLocMan
	@convertTime varchar(10),	--��������:���á�yyyy-MM-dd����ʽ���
	@currency smallint,			--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from convertInfo where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency),'')
	set @Ret = 0
GO


drop PROCEDURE lockConvertInfo4Edit
/*
	name:		lockConvertInfo4Edit
	function:	3.����ָ������ָ�����ֵĻ��ʣ�����༭��ͻ
	input: 
				@convertTime varchar(10),	--��������:���á�yyyy-MM-dd����ʽ���
				@currency smallint,			--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ָ������ָ�����ֵĻ��ʲ����ڣ�
							2:Ҫ������ָ������ָ�����ֵĻ������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-09
	UpdateDate: 
*/
create PROCEDURE lockConvertInfo4Edit
	@convertTime varchar(10),		--��������:���á�yyyy-MM-dd����ʽ���
	@currency smallint,				--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from convertInfo where convert(varchar(10),convertTime,120)= @convertTime and currency=@currency)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������ʱ༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������ָ������['+@convertTime+']�ı���['+str(@currency,4)+']�Ļ���Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockConvertInfoEditor
/*
	name:		unlockConvertInfoEditor
	function:	4.�ͷ�ָ������ָ�����ֵĻ��ʱ༭��
				ע�⣺�����̲���������Ƿ���ڣ�
	input: 
				@convertTime varchar(10),	--��������:���á�yyyy-MM-dd����ʽ���
				@currency smallint,			--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-09
	UpdateDate: 
*/
create PROCEDURE unlockConvertInfoEditor
	@convertTime varchar(10),	--��������:���á�yyyy-MM-dd����ʽ���
	@currency smallint,			--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷŻ��ʱ༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���ָ������['+@convertTime+']�ı���['+str(@currency,4)+']�Ļ��ʵı༭����')
GO


drop PROCEDURE updateAConvertInfo
/*
	name:		updateAConvertInfo
	function:	5.����һ������ָ�����ڵĻ��ʣ��Ƽۣ�
	input: 
				@currency smallint,				--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
				@convertTime varchar(19),		--��������:���á�yyyy-MM-dd hh:mm:ss����ʽ���
				
				@purchasePrice money,			--�ֻ������:ÿ��Ԫ��Ӧ����Ҽ۸�
				@cashPurchaseprice money,		--�ֳ������:ÿ��Ԫ��Ӧ����Ҽ۸�
				@offerPrice money,				--�ֻ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
				@cashOfferPrice money,			--�ֳ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
				@discountedPrice money,			--���������:ÿ��Ԫ��Ӧ����Ҽ۸�

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĻ�����������������2���û��ʲ����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-09
	UpdateDate: 
*/
create PROCEDURE updateAConvertInfo
	@currency smallint,				--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
	@convertTime varchar(19),		--��������:���á�yyyy-MM-dd hh:mm:ss����ʽ���
	
	@purchasePrice money,			--�ֻ������:ÿ��Ԫ��Ӧ����Ҽ۸�
	@cashPurchaseprice money,		--�ֳ������:ÿ��Ԫ��Ӧ����Ҽ۸�
	@offerPrice money,				--�ֻ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
	@cashOfferPrice money,			--�ֳ�������:ÿ��Ԫ��Ӧ����Ҽ۸�
	@discountedPrice money,			--���������:ÿ��Ԫ��Ӧ����Ҽ۸�

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from convertInfo where convert(varchar(10),convertTime,120)= convert(varchar(10),@convertTime ,120) and currency=@currency),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--ȡ�������ƣ�
	declare @currencyName nvarchar(30)	--��������
	set @currencyName =isnull((select objDesc from codeDictionary where classCode=3 and objCode=@currency),'')
	if (@currencyName='')
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime --����ʱ��
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

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���»���', '�û�' + @modiManName 
												+ '������ָ������['+@convertTime+']�ı���['+@currencyName+']�Ļ��ʡ�')
GO

drop PROCEDURE delConvertInfo
/*
	name:		delConvertInfo
	function:	6.ɾ��ָ��������ָ�����ֵĻ���
	input: 
				@convertTime varchar(10),		--��������:���á�yyyy-MM-dd����ʽ���
				@currency smallint,				--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��ʲ����ڣ�2��Ҫɾ���Ļ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-06-09
	UpdateDate: 

*/
create PROCEDURE delConvertInfo
	@convertTime varchar(10),		--��������:���á�yyyy-MM-dd����ʽ���
	@currency smallint,				--���������ִ���,�ɵ�3�Ŵ����ֵ䶨��
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from convertInfo where convert(varchar(10),@convertTime,120)= @convertTime and currency=@currency)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
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

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ����ָ������['+@convertTime+']�ı���['+str(@currency,4)+']�Ļ��ʡ�')
GO



