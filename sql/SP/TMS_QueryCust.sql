USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_QueryCust]    Script Date: 25/07/2018 15:22:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_QueryCust] --exec [dbo].[TMS_QueryCust] 'GT,FS,IT','20180711_141742896','D312',-30
@Channel varchar(100), @runID varchar(100), @plant varchar(100), @day int
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
				@Channel,
				','
			);

--DECLARE @do AS TABLE
--	(
--		Customer_ID VARCHAR(100),
--		MarketId VARCHAR(100),
--		DO_Number VARCHAR(100),
--		Long VARCHAR(100),
--		Lat VARCHAR(100),
--		Customer_priority VARCHAR(100),
--		Service_time VARCHAR(100),
--		deliv_start VARCHAR(100),
--		deliv_end VARCHAR(100),
--		vehicle_type_list VARCHAR(100),
--		total_kg_item VARCHAR(100),
--		total_cubication VARCHAR(100),
--		DeliveryDeadline VARCHAR(100),
--		DayWinStart VARCHAR(100),
--		DayWinEnd VARCHAR(100),
--		UpdatevDate VARCHAR(100),
--		CreateDate VARCHAR(100),
--		Request_Delivery_Date VARCHAR(100),
--		Product_Description VARCHAR(100),
--		Gross_Amount VARCHAR(100),
--		DOQty VARCHAR(100),
--		DOQtyUOM VARCHAR(100),
--		Name1 VARCHAR(100),
--		Street VARCHAR(100),
--		Distribution_Channel VARCHAR(100),
--		Customer_Order_Block_all VARCHAR(100),
--		Customer_Order_Block VARCHAR(100),
--		Priority_value VARCHAR(100),
--		BufferEndDefault VARCHAR(100),
--		SatDelivDefault VARCHAR(100),
--		ChannelNullDefault VARCHAR(100),
--		Desa_Kelurahan VARCHAR(100),
--		Kecamatan VARCHAR(100),
--		Kodya_Kabupaten VARCHAR(100),
--		Batch VARCHAR(100)
--	);

--insert into @do 
SELECT
	sp.Customer_ID,
	cl.MarketId,
	sp.DO_Number,
	CASE
		WHEN cl.Long IS NULL
		OR cl.Long = '' THEN 'n/a'
		ELSE cl.Long
	END AS Long,
	CASE
		WHEN cl.Lat IS NULL
		OR cl.Lat = '' THEN 'n/a'
		ELSE cl.Lat
	END AS Lat,
	CASE
		WHEN cs.Customer_priority IS NULL THEN df.value
		ELSE SUBSTRING( CAST( cs.Customer_priority AS VARCHAR ), 2, 1 )
	END Customer_priority,
	CASE
		WHEN ca.Service_time IS NULL THEN dr.value
		ELSE ca.Service_time
	END Service_time,
	CASE
		WHEN ca.deliv_start IS NULL THEN dg.value
		ELSE ca.deliv_start
	END deliv_start,
	CASE
		WHEN ca.deliv_end IS NULL THEN dt.value
		ELSE ca.deliv_end
	END deliv_end,
	CASE
		WHEN ca.vehicle_type_list IS NULL THEN dh.value
		ELSE ca.vehicle_type_list
	END vehicle_type_list,
	sp.total_kg_item,
	sp.total_cubication,
	CASE
		WHEN ca.DeliveryDeadline IS NULL THEN CASE
			WHEN cs.Distribution_Channel = 'MT' THEN dy.value
			ELSE dd.value
		END
		ELSE ca.DeliveryDeadline
	END DeliveryDeadline,
	CASE
		WHEN ca.DayWinStart IS NULL
		OR ca.DayWinStart = '' THEN ds.value
		ELSE ca.DayWinStart
	END DayWinStart,
	CASE
		WHEN ca.DayWinEnd IS NULL
		OR ca.DayWinEnd = '' THEN de.value
		ELSE ca.DayWinEnd
	END DayWinEnd,
	CAST(
		FORMAT(
			getdate(),
			'yyyy-MM-dd hh-mm'
		) AS VARCHAR
	) AS UpdatevDate,
	CAST(
		FORMAT(
			getdate(),
			'yyyy-MM-dd hh-mm'
		) AS VARCHAR
	) AS CreateDate,
	CAST(
		FORMAT(
			sp.Request_Delivery_Date,
			'yyyy-MM-dd'
		) AS VARCHAR
	) AS Request_Delivery_Date,
	sp.Product_Description,
	sp.Gross_Amount,
	sp.DOQty,
	sp.DOQtyUOM,
	CASE
		WHEN cs.Name1 IS NULL THEN 'UNKNOWN'
		ELSE cs.Name1
	END AS Name1,
	CASE
		WHEN cs.Street IS NULL THEN 'UNKNOWN'
		ELSE cs.Street
	END AS Street,
	cs.Distribution_Channel,
	cs.Customer_Order_Block_all,
	cs.Customer_Order_Block,
	df.value AS Priority_value,
	dn.value AS BufferEndDefault,
	dj.value AS SatDelivDefault,
	du.value AS ChannelNullDefault,
	cs.Desa_Kelurahan,
	cs.Kecamatan,
	cs.Kodya_Kabupaten,
	sp.Batch
FROM
	bosnet1.dbo.TMS_ShipmentPlan sp
LEFT OUTER JOIN(
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
	sp.customer_id = cs.customer_id
LEFT JOIN(
		SELECT
			*
		FROM
			(
				SELECT
					ROW_NUMBER() OVER(
						PARTITION BY custid
					ORDER BY
						custid
					) AS noId,
					*
				FROM
					bosnet1.dbo.TMS_CustLongLat
			) a
		WHERE
			a.noid = 1
	) cl ON
	sp.customer_id = cl.custID
LEFT OUTER JOIN(
		SELECT
			tu.Delivery_Number
		FROM
			BOSNET1.dbo.TMS_Result_Shipment ty
		INNER JOIN BOSNET1.dbo.TMS_Status_Shipment tu ON
			ty.Delivery_Number = tu.Delivery_Number
		WHERE
			tu.SAP_Status IS NULL
	) ss ON
	sp.DO_Number = ss.Delivery_Number
LEFT OUTER JOIN(
		SELECT
			ty.Delivery_Number
		FROM
			BOSNET1.dbo.TMS_Result_Shipment ty
		LEFT OUTER JOIN BOSNET1.dbo.TMS_Status_Shipment tu ON
			ty.Delivery_Number = tu.Delivery_Number
		WHERE
			tu.Delivery_Number IS NULL
	) sn ON
	sp.DO_Number = sn.Delivery_Number
LEFT OUTER JOIN bosnet1.dbo.TMS_CustAtr ca ON
	sp.customer_id = ca.customer_id
LEFT OUTER JOIN bosnet1.dbo.TMS_Progress dm ON
	dm.runID = @runID
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dd ON
	dd.param = 'DeliveryDeadLine'
	AND dd.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams ds ON
	ds.param = 'DayWinStart'
	AND ds.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams de ON
	de.param = 'DayWinEnd'
	AND de.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams df ON
	df.param = 'DefaultCustPriority'
	AND df.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dr ON
	dr.param = 'DefaultCustServiceTime'
	AND dr.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dg ON
	dg.param = 'DefaultCustStartTime'
	AND dg.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dt ON
	dt.param = 'DefaultCustEndTime'
	AND dt.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dh ON
	dh.param = 'DefaultCustVehicleTypes'
	AND dh.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dy ON
	dy.param = 'MTDefault'
	AND dy.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dn ON
	dn.param = 'BufferEndDefault'
	AND dn.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams dj ON
	dj.param = 'SatDelivDefault'
	AND dj.RunId = dm.OriRunId
LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams du ON
	du.param = 'ChannelNullDefault'
	AND du.RunId = dm.OriRunId
WHERE
	sp.plant = @plant
	AND sp.already_shipment = 'N'
	AND sp.notused_flag IS NULL
	AND sp.incoterm = 'FCO'
	AND(
		sp.Order_Type = 'ZDCO'
		OR sp.Order_Type = 'ZDTO'
	)
	AND sp.create_date >= DATEADD(
		DAY,
		-30,
		GETDATE()
	)
	AND ss.Delivery_Number IS NULL
	AND sn.Delivery_Number IS NULL
	AND cs.Distribution_Channel IN(
		SELECT
			*
		FROM
			@tb
	)
ORDER BY
	sp.Customer_ID ASC;

--select * from @do
