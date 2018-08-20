USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_QueryCust_RedelivFromManual]    Script Date: 20/08/2018 15:25:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_QueryCust_RedelivFromManual] --exec [dbo].[TMS_QueryCust_RedelivFromManual] '20180525_154124248','MT,GT,FS,IT','D361',-30,'edit'
@RunId varchar(100), @chn varchar(100), @branch varchar(100), @dt int, @str varchar(100)
--set @RunId='20180525_154124248';
--set @chn='MT,GT,FS,IT';
--set @branch='D361';
--set @dt=-30;
--set @str='edit';
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

SELECT
	@RunId RunId,
	sp.Customer_ID,
	sp.DO_Number,
	cl.Long,
	cl.Lat,
	1 Customer_priority,
	case when ca.Service_time is null then dr.value else ca.Service_time end Service_time,
	case when ca.deliv_start is null then dg.value else ca.deliv_start end deliv_start,
	case when ca.deliv_end is null then dt.value else ca.deliv_end end deliv_end,
	case when ca.vehicle_type_list is null then dh.value else ca.vehicle_type_list end vehicle_type_list,
	sp.total_kg_item total_kg,
	sp.total_cubication,
	case when ca.DeliveryDeadline is null then dd.value else ca.DeliveryDeadline end DeliveryDeadline,
	case when ca.DayWinStart is null then ds.value else ca.DayWinStart end DayWinStart,
	case when ca.DayWinEnd is null then de.value else ca.DayWinEnd end DayWinEnd,
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
	@str Is_Edit,
	sp.Product_Description,
	sp.Gross_Amount,
	sp.DOQty,
	sp.DOQtyUOM,
	cs.Name1,
	cs.Street,
	cs.Distribution_Channel,
	cs.Customer_Order_Block_all,
	cs.Customer_Order_Block,
	CAST(
		FORMAT(
			sp.Request_Delivery_Date,
			'yyyy-MM-dd'
		) AS VARCHAR
	) AS Request_Delivery_Date,
	cl.MarketId,
	cs.Desa_Kelurahan,
	cs.Kecamatan,
	cs.Kodya_Kabupaten,
	'0' Batch,
	'manual to redeliv' Ket_DO,
	rs.RedeliveryCount
FROM
	BOSNET1.dbo.TMS_ShipmentPlan sp
INNER JOIN SFAUtility.dbo.TCS_RedeliveryStatus rs ON
	sp.DO_Number = rs.DONumber
LEFT OUTER JOIN BOSNET1.dbo.TMS_Status_Shipment ss ON
	rs.DONumber = ss.Delivery_Number
LEFT OUTER JOIN BOSNET1.dbo.TMS_CustLongLat cl ON
	sp.Customer_ID = cl.CustId
LEFT OUTER JOIN BOSNET1.dbo.TMS_CustAtr ca ON
	sp.Customer_ID = ca.customer_id
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
	sp.Customer_ID = cs.Customer_ID
LEFT OUTER JOIN bosnet1.dbo.TMS_Params dd ON
	dd.param = 'DeliveryDeadLine'
LEFT OUTER JOIN bosnet1.dbo.TMS_Params ds ON
	ds.param = 'DayWinStart'
LEFT OUTER JOIN bosnet1.dbo.TMS_Params de ON
	de.param = 'DayWinEnd'
LEFT OUTER JOIN bosnet1.dbo.TMS_Params df ON
	df.param = 'DefaultCustPriority'
LEFT OUTER JOIN bosnet1.dbo.TMS_Params dr ON
	dr.param = 'DefaultCustServiceTime'
LEFT OUTER JOIN bosnet1.dbo.TMS_Params dg ON
	dg.param = 'DefaultCustStartTime'
LEFT OUTER JOIN bosnet1.dbo.TMS_Params dt ON
	dt.param = 'DefaultCustEndTime'
LEFT OUTER JOIN bosnet1.dbo.TMS_Params dh ON
	dh.param = 'DefaultCustVehicleTypes'	
WHERE
	rs.RedeliveryStatus = 1
	AND ss.Delivery_Number IS NULL
	AND sp.plant = @branch
	AND sp.notused_flag IS NULL
	AND sp.incoterm = 'FCO'
	AND(
		sp.Order_Type = 'ZDCO'
		OR sp.Order_Type = 'ZDTO'
	)
	AND sp.create_date >= DATEADD(
		DAY,
		@dt,
		GETDATE()
	)
	AND Distribution_Channel IN(
		SELECT
			*
		FROM
			@tb
	);