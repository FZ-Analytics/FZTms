USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_QueryCust_Redeliv]    Script Date: 03/09/2018 09:33:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_QueryCust_Redeliv] --exec [dbo].[TMS_QueryCust_Redeliv] select concat(format(getdate(),'yyyyMMddhhmmss'),'x'),'GT,FS,MT,IT','D361',-90
@RunId varchar(100), @chn varchar(100), @br varchar(100), @dt int
--declare @RunId varchar(100), @chn varchar(100), @br varchar(100), @dt int;
--select @RunId=concat(format(getdate(),'yyyyMMddhhmmss'),'x')
--print @RunId
--set @chn = 'MT,GT,FS,IT';
--set @br = 'D312';
--set @dt = -90;
AS
SET NOCOUNT ON;
DECLARE @tb AS TABLE
	(
		chn VARCHAR(100)
	);

INSERT
	INTO
		@tb SELECT
			*
		FROM
			dbo.splitstring(
				@chn,
				','
			);

DECLARE @PreRouteJob AS TABLE
	(
		RunId VARCHAR(18),
		Customer_ID VARCHAR(40),
		DO_Number VARCHAR(40),
		Long VARCHAR(100),
		Lat VARCHAR(100),
		Customer_priority INT,
		Service_time INT,
		deliv_start VARCHAR(5),
		deliv_end VARCHAR(5),
		vehicle_type_list VARCHAR(255),
		total_kg DECIMAL(
			38,
			3
		),
		total_cubication DECIMAL(
			38,
			3
		),
		DeliveryDeadline VARCHAR(MAX),
		DayWinStart VARCHAR(MAX),
		DayWinEnd VARCHAR(MAX),
		UpdatevDate VARCHAR(20),
		CreateDate VARCHAR(20),
		isActive VARCHAR(1),
		Is_Exclude VARCHAR(5),
		Is_Edit VARCHAR(5),
		Product_Description VARCHAR(100),
		Gross_Amount DECIMAL(
			18,
			2
		),
		DOQty DECIMAL(
			17,
			3
		),
		DOQtyUOM VARCHAR(5),
		Name1 VARCHAR(100),
		Street VARCHAR(100),
		Distribution_Channel VARCHAR(35),
		Customer_Order_Block_all VARCHAR(2) null,
		Customer_Order_Block VARCHAR(2) null,
		Request_Delivery_Date VARCHAR(25),
		MarketId VARCHAR(100),
		Desa_Kelurahan VARCHAR(100),
		Kecamatan VARCHAR(100),
		Kodya_Kabupaten VARCHAR(100),
		Batch VARCHAR(10),
		Ket_DO VARCHAR(200),
		RedeliveryCount VARCHAR(3)
	);
declare @GT int, @MT int;
select @GT = count(*) from @tb where chn = 'GT';
select @MT = count(*) from @tb where chn = 'MT'
print concat(@GT,' ',@MT)

--ALL
if(@GT = 1 and @MT = 1)
begin
insert into @PreRouteJob
SELECT
	@RunId RunId,
	Customer_ID,
	DO_Number,
	Long,
	Lat,
	Customer_priority,
	Service_time,
	deliv_start,
	deliv_end,
	vehicle_type_list,
	total_kg,
	total_cubication,
	DeliveryDeadline,
	DayWinStart,
	DayWinEnd,
	format(
		getdate(),
		'yyyy/MM/dd hh:mm'
	) UpdatevDate,
	format(
		getdate(),
		'yyyy/MM/dd hh:mm'
	) CreateDate,
	1 isActive,
	'inc' Is_Exclude,
	Is_Edit,
	Product_Description,
	Gross_Amount,
	DOQty,
	DOQtyUOM,
	Name1,
	Street,
	Distribution_Channel,
	Customer_Order_Block_all,
	Customer_Order_Block,
	Request_Delivery_Date,
	0 MarketId,
	Desa_Kelurahan,
	Kecamatan,
	Kodya_Kabupaten,
	0 Batch,
	'-' Ket_DO,
	rd.RedeliveryCount RedeliveryCount
FROM
	SFAUtility.dbo.TCS_RedeliveryStatus rd
INNER JOIN(
		SELECT
			prj.Customer_ID,
			prj.DO_Number,
			prj.Long,
			prj.Lat,
			prj.Customer_priority,
			prj.Service_time,
			prj.deliv_start,
			prj.deliv_end,
			prj.vehicle_type_list,
			prj.total_kg,
			prj.total_cubication,
			prj.DeliveryDeadline,
			prj.DayWinStart,
			prj.DayWinEnd,
			prj.Is_Edit,
			prj.Product_Description,
			prj.Gross_Amount,
			prj.DOQty,
			prj.DOQtyUOM,
			prj.Name1,
			prj.Street,
			prj.Distribution_Channel,
			prj.Customer_Order_Block_all,
			prj.Customer_Order_Block,
			prj.Request_Delivery_Date,
			prj.MarketId,
			prj.Desa_Kelurahan,
			prj.Kecamatan,
			prj.Kodya_Kabupaten,
			prj.Batch,
			prj.Ket_DO,
			MAX( prj.RedeliveryCount ) RedeliveryCount
		FROM
			(
				SELECT
					prj.Customer_ID,
					prj.DO_Number,
					prj.Long,
					prj.Lat,
					prj.Customer_priority,
					prj.Service_time,
					prj.deliv_start,
					prj.deliv_end,
					prj.vehicle_type_list,
					prj.total_kg,
					prj.total_cubication,
					prj.DeliveryDeadline,
					prj.DayWinStart,
					prj.DayWinEnd,
					prj.Is_Edit,
					prj.Product_Description,
					prj.Gross_Amount,
					prj.DOQty,
					prj.DOQtyUOM,
					prj.Name1,
					cs.Street,
					prj.Distribution_Channel,
					prj.Customer_Order_Block_all,
					prj.Customer_Order_Block,
					prj.Request_Delivery_Date,
					prj.MarketId,
					cs.Desa_Kelurahan,
					cs.Kecamatan,
					cs.Kodya_Kabupaten,
					'0' Batch,
					prj.Ket_DO,
					CASE
						WHEN prj.RedeliveryCount IS NULL THEN 0
						ELSE prj.RedeliveryCount
					END RedeliveryCount
				FROM
					(
						SELECT
							REPLACE(
								prj.RunId,
								'_',
								''
							) runs,
							prj.*
						FROM
							BOSNET1.dbo.TMS_PreRouteJob prj
						where prj.Distribution_Channel in('GT','MT','FS','IT')
					) prj
				INNER JOIN (select SUBSTRING(shipment_number_dummy,1,17) runs, * from BOSNET1.dbo.TMS_Status_Shipment where SAP_Status is null) ss ON
					prj.runs = ss.runs and prj.DO_Number = ss.Delivery_Number
				INNER JOIN(
						SELECT
							a.*
						FROM
							(
								SELECT
									ROW_NUMBER() OVER(
										PARTITION BY Customer_ID
									ORDER BY
										Customer_ID
									) AS noId,
									*
								FROM
									bosnet1.dbo.customer
								WHERE
									(
										Customer_Order_Block IS NULL
										OR Customer_Order_Block = ''
									)
									AND(
										Customer_Order_Block_all IS NULL
										OR Customer_Order_Block_all = ''
									)
							) a
						WHERE
							a.noid = 1
					) cs ON
					prj.Customer_ID = cs.Customer_ID
				WHERE
					ss.Plant = @br
			) prj
		GROUP BY
			prj.Customer_ID,
			prj.DO_Number,
			prj.Long,
			prj.Lat,
			prj.Customer_priority,
			prj.Service_time,
			prj.deliv_start,
			prj.deliv_end,
			prj.vehicle_type_list,
			prj.total_kg,
			prj.total_cubication,
			prj.DeliveryDeadline,
			prj.DayWinStart,
			prj.DayWinEnd,
			prj.Is_Edit,
			prj.Product_Description,
			prj.Gross_Amount,
			prj.DOQty,
			prj.DOQtyUOM,
			prj.Name1,
			prj.Street,
			prj.Distribution_Channel,
			prj.Customer_Order_Block_all,
			prj.Customer_Order_Block,
			prj.Request_Delivery_Date,
			prj.MarketId,
			prj.Desa_Kelurahan,
			prj.Kecamatan,
			prj.Kodya_Kabupaten,
			prj.Batch,
			prj.Ket_DO
	) rj ON
	rd.DONumber = rj.DO_Number
	AND rd.RedeliveryCount > rj.RedeliveryCount
WHERE
	rd.RedeliveryStatus = 1
	AND Customer_ID IS NOT NULL
	AND Distribution_Channel IN(
		SELECT
			*
		FROM
			@tb
	);
end;
--GT
if(@GT = 1 and @MT = 0)
begin
insert into @PreRouteJob
SELECT
	@RunId RunId,
	Customer_ID,
	DO_Number,
	Long,
	Lat,
	Customer_priority,
	Service_time,
	deliv_start,
	deliv_end,
	vehicle_type_list,
	total_kg,
	total_cubication,
	DeliveryDeadline,
	DayWinStart,
	DayWinEnd,
	format(
		getdate(),
		'yyyy/MM/dd hh:mm'
	) UpdatevDate,
	format(
		getdate(),
		'yyyy/MM/dd hh:mm'
	) CreateDate,
	1 isActive,
	'inc' Is_Exclude,
	Is_Edit,
	Product_Description,
	Gross_Amount,
	DOQty,
	DOQtyUOM,
	Name1,
	Street,
	Distribution_Channel,
	Customer_Order_Block_all,
	Customer_Order_Block,
	Request_Delivery_Date,
	0 MarketId,
	Desa_Kelurahan,
	Kecamatan,
	Kodya_Kabupaten,
	0 Batch,
	'-' Ket_DO,
	rd.RedeliveryCount RedeliveryCount
FROM
	SFAUtility.dbo.TCS_RedeliveryStatus rd
INNER JOIN(
		SELECT
			prj.Customer_ID,
			prj.DO_Number,
			prj.Long,
			prj.Lat,
			prj.Customer_priority,
			prj.Service_time,
			prj.deliv_start,
			prj.deliv_end,
			prj.vehicle_type_list,
			prj.total_kg,
			prj.total_cubication,
			prj.DeliveryDeadline,
			prj.DayWinStart,
			prj.DayWinEnd,
			prj.Is_Edit,
			prj.Product_Description,
			prj.Gross_Amount,
			prj.DOQty,
			prj.DOQtyUOM,
			prj.Name1,
			prj.Street,
			prj.Distribution_Channel,
			prj.Customer_Order_Block_all,
			prj.Customer_Order_Block,
			prj.Request_Delivery_Date,
			prj.MarketId,
			prj.Desa_Kelurahan,
			prj.Kecamatan,
			prj.Kodya_Kabupaten,
			prj.Batch,
			prj.Ket_DO,
			MAX( prj.RedeliveryCount ) RedeliveryCount
		FROM
			(
				SELECT
					prj.Customer_ID,
					prj.DO_Number,
					prj.Long,
					prj.Lat,
					prj.Customer_priority,
					prj.Service_time,
					prj.deliv_start,
					prj.deliv_end,
					prj.vehicle_type_list,
					prj.total_kg,
					prj.total_cubication,
					prj.DeliveryDeadline,
					prj.DayWinStart,
					prj.DayWinEnd,
					prj.Is_Edit,
					prj.Product_Description,
					prj.Gross_Amount,
					prj.DOQty,
					prj.DOQtyUOM,
					prj.Name1,
					cs.Street,
					prj.Distribution_Channel,
					prj.Customer_Order_Block_all,
					prj.Customer_Order_Block,
					prj.Request_Delivery_Date,
					prj.MarketId,
					cs.Desa_Kelurahan,
					cs.Kecamatan,
					cs.Kodya_Kabupaten,
					'0' Batch,
					prj.Ket_DO,
					CASE
						WHEN prj.RedeliveryCount IS NULL THEN 0
						ELSE prj.RedeliveryCount
					END RedeliveryCount
				FROM
					(
						SELECT
							REPLACE(
								prj.RunId,
								'_',
								''
							) runs,
							prj.*
						FROM
							BOSNET1.dbo.TMS_PreRouteJob prj
						where prj.Distribution_Channel in('GT','FS','IT')
					) prj
				INNER JOIN (select SUBSTRING(shipment_number_dummy,1,17) runs, * from BOSNET1.dbo.TMS_Status_Shipment where SAP_Status is null) ss ON
					prj.runs = ss.runs and prj.DO_Number = ss.Delivery_Number
				INNER JOIN(
						SELECT
							a.*
						FROM
							(
								SELECT
									ROW_NUMBER() OVER(
										PARTITION BY Customer_ID
									ORDER BY
										Customer_ID
									) AS noId,
									*
								FROM
									bosnet1.dbo.customer
								WHERE
									(
										Customer_Order_Block IS NULL
										OR Customer_Order_Block = ''
									)
									AND(
										Customer_Order_Block_all IS NULL
										OR Customer_Order_Block_all = ''
									)
							) a
						WHERE
							a.noid = 1
					) cs ON
					prj.Customer_ID = cs.Customer_ID
				WHERE
					ss.Plant = @br
			) prj
		GROUP BY
			prj.Customer_ID,
			prj.DO_Number,
			prj.Long,
			prj.Lat,
			prj.Customer_priority,
			prj.Service_time,
			prj.deliv_start,
			prj.deliv_end,
			prj.vehicle_type_list,
			prj.total_kg,
			prj.total_cubication,
			prj.DeliveryDeadline,
			prj.DayWinStart,
			prj.DayWinEnd,
			prj.Is_Edit,
			prj.Product_Description,
			prj.Gross_Amount,
			prj.DOQty,
			prj.DOQtyUOM,
			prj.Name1,
			prj.Street,
			prj.Distribution_Channel,
			prj.Customer_Order_Block_all,
			prj.Customer_Order_Block,
			prj.Request_Delivery_Date,
			prj.MarketId,
			prj.Desa_Kelurahan,
			prj.Kecamatan,
			prj.Kodya_Kabupaten,
			prj.Batch,
			prj.Ket_DO
	) rj ON
	rd.DONumber = rj.DO_Number
	AND rd.RedeliveryCount > rj.RedeliveryCount
WHERE
	rd.RedeliveryStatus = 1
	AND Customer_ID IS NOT NULL
	AND Distribution_Channel IN(
		SELECT
			*
		FROM
			@tb
	);
END;
--MT
if(@GT = 0 and @MT = 1)
begin
insert into @PreRouteJob
SELECT
	@RunId RunId,
	Customer_ID,
	DO_Number,
	Long,
	Lat,
	Customer_priority,
	Service_time,
	deliv_start,
	deliv_end,
	vehicle_type_list,
	total_kg,
	total_cubication,
	DeliveryDeadline,
	DayWinStart,
	DayWinEnd,
	format(
		getdate(),
		'yyyy/MM/dd hh:mm'
	) UpdatevDate,
	format(
		getdate(),
		'yyyy/MM/dd hh:mm'
	) CreateDate,
	1 isActive,
	'inc' Is_Exclude,
	Is_Edit,
	Product_Description,
	Gross_Amount,
	DOQty,
	DOQtyUOM,
	Name1,
	Street,
	Distribution_Channel,
	Customer_Order_Block_all,
	Customer_Order_Block,
	Request_Delivery_Date,
	0 MarketId,
	Desa_Kelurahan,
	Kecamatan,
	Kodya_Kabupaten,
	0 Batch,
	'-' Ket_DO,
	rd.RedeliveryCount RedeliveryCount
FROM
	SFAUtility.dbo.TCS_RedeliveryStatus rd
INNER JOIN(
		SELECT
			prj.Customer_ID,
			prj.DO_Number,
			prj.Long,
			prj.Lat,
			prj.Customer_priority,
			prj.Service_time,
			prj.deliv_start,
			prj.deliv_end,
			prj.vehicle_type_list,
			prj.total_kg,
			prj.total_cubication,
			prj.DeliveryDeadline,
			prj.DayWinStart,
			prj.DayWinEnd,
			prj.Is_Edit,
			prj.Product_Description,
			prj.Gross_Amount,
			prj.DOQty,
			prj.DOQtyUOM,
			prj.Name1,
			prj.Street,
			prj.Distribution_Channel,
			prj.Customer_Order_Block_all,
			prj.Customer_Order_Block,
			prj.Request_Delivery_Date,
			prj.MarketId,
			prj.Desa_Kelurahan,
			prj.Kecamatan,
			prj.Kodya_Kabupaten,
			prj.Batch,
			prj.Ket_DO,
			MAX( prj.RedeliveryCount ) RedeliveryCount
		FROM
			(
				SELECT
					prj.Customer_ID,
					prj.DO_Number,
					prj.Long,
					prj.Lat,
					prj.Customer_priority,
					prj.Service_time,
					prj.deliv_start,
					prj.deliv_end,
					prj.vehicle_type_list,
					prj.total_kg,
					prj.total_cubication,
					prj.DeliveryDeadline,
					prj.DayWinStart,
					prj.DayWinEnd,
					prj.Is_Edit,
					prj.Product_Description,
					prj.Gross_Amount,
					prj.DOQty,
					prj.DOQtyUOM,
					prj.Name1,
					cs.Street,
					prj.Distribution_Channel,
					prj.Customer_Order_Block_all,
					prj.Customer_Order_Block,
					prj.Request_Delivery_Date,
					prj.MarketId,
					cs.Desa_Kelurahan,
					cs.Kecamatan,
					cs.Kodya_Kabupaten,
					'0' Batch,
					prj.Ket_DO,
					CASE
						WHEN prj.RedeliveryCount IS NULL THEN 0
						ELSE prj.RedeliveryCount
					END RedeliveryCount
				FROM
					(
						SELECT
							REPLACE(
								prj.RunId,
								'_',
								''
							) runs,
							prj.*
						FROM
							BOSNET1.dbo.TMS_PreRouteJob prj
						where prj.Distribution_Channel in('MT')
					) prj
				INNER JOIN (select SUBSTRING(shipment_number_dummy,1,17) runs, * from BOSNET1.dbo.TMS_Status_Shipment where SAP_Status is null) ss ON
					prj.runs = ss.runs and prj.DO_Number = ss.Delivery_Number
				INNER JOIN(
						SELECT
							a.*
						FROM
							(
								SELECT
									ROW_NUMBER() OVER(
										PARTITION BY Customer_ID
									ORDER BY
										Customer_ID
									) AS noId,
									*
								FROM
									bosnet1.dbo.customer
								WHERE
									(
										Customer_Order_Block IS NULL
										OR Customer_Order_Block = ''
									)
									AND(
										Customer_Order_Block_all IS NULL
										OR Customer_Order_Block_all = ''
									)
							) a
						WHERE
							a.noid = 1
					) cs ON
					prj.Customer_ID = cs.Customer_ID
				WHERE
					ss.Plant = @br
			) prj
		GROUP BY
			prj.Customer_ID,
			prj.DO_Number,
			prj.Long,
			prj.Lat,
			prj.Customer_priority,
			prj.Service_time,
			prj.deliv_start,
			prj.deliv_end,
			prj.vehicle_type_list,
			prj.total_kg,
			prj.total_cubication,
			prj.DeliveryDeadline,
			prj.DayWinStart,
			prj.DayWinEnd,
			prj.Is_Edit,
			prj.Product_Description,
			prj.Gross_Amount,
			prj.DOQty,
			prj.DOQtyUOM,
			prj.Name1,
			prj.Street,
			prj.Distribution_Channel,
			prj.Customer_Order_Block_all,
			prj.Customer_Order_Block,
			prj.Request_Delivery_Date,
			prj.MarketId,
			prj.Desa_Kelurahan,
			prj.Kecamatan,
			prj.Kodya_Kabupaten,
			prj.Batch,
			prj.Ket_DO
	) rj ON
	rd.DONumber = rj.DO_Number
	AND rd.RedeliveryCount > rj.RedeliveryCount
WHERE
	rd.RedeliveryStatus = 1
	AND Customer_ID IS NOT NULL
	AND Distribution_Channel IN(
		SELECT
			*
		FROM
			@tb
	);
END;
INSERT
	INTO
		@PreRouteJob EXEC dbo.TMS_QueryCust_RedelivFromManual @RunId,
		@chn,
		@br,
		@dt,
		'edit';

INSERT
	INTO
		@PreRouteJob EXEC dbo.TMS_QueryCust_RedelivFromManual @RunId,
		@chn,
		@br,
		@dt,
		'ori';

IF(
	(select count(*) cnt from @PreRouteJob) > 0
) BEGIN 
INSERT
	INTO
		BOSNET1.dbo.TMS_PreRouteJob SELECT
			*
		FROM
			@PreRouteJob;
select 'ok';
END;

--select * from @PreRouteJob;