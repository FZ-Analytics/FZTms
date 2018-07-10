USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_CekShipment]    Script Date: 09/07/2018 16:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_CekShipment] --exec [dbo].[TMS_CekShipment] 'D312'
@BrId varchar(100)
AS
SET NOCOUNT ON;

SELECT
	aq.Customer_ID,
	ju.Name1,
	aq.DO_Number,
	sw.DO_Number ShipPlant,
	sw.Request_Delivery_Date RDD,
	hy.DeliveryDeadline,
	de.Ship_No_SAP StatusShip,
	fr.Delivery_Number ResultShip,
	gt.GoodsMovementStat,
	gt.PODStatus
FROM
	(
		SELECT
			DISTINCT Customer_ID,
			DO_Number,
			Plant
		FROM
			BOSNET1.dbo.TMS_ShipmentPlan aq
		WHERE
			create_date >= DATEADD(
				DAY,
				- 30,
				GETDATE()
			)
	) aq
LEFT OUTER JOIN(
		SELECT
			DISTINCT DO_Number,
			Request_Delivery_Date
		FROM
			BOSNET1.dbo.TMS_ShipmentPlan aq
		WHERE
			create_date >= DATEADD(
				DAY,
				- 30,
				GETDATE()
			)
			AND already_shipment = 'N'
			AND notused_flag IS NULL
			AND incoterm = 'FCO'
			AND Order_Type IN(
				'ZDCO',
				'ZDTO'
			)
			AND batch IS NOT NULL
	) sw ON
	aq.DO_Number = sw.DO_Number
LEFT OUTER JOIN(
		SELECT
			DISTINCT Delivery_Number,
			Ship_No_SAP
		FROM
			BOSNET1.dbo.TMS_Status_Shipment
		WHERE
			SAP_Message IS NULL
	) de ON
	aq.DO_Number = de.Delivery_Number
LEFT OUTER JOIN(
		SELECT
			DISTINCT Delivery_Number
		FROM
			BOSNET1.dbo.TMS_Result_Shipment
	) fr ON
	aq.DO_Number = fr.Delivery_Number
LEFT OUTER JOIN(
		SELECT
			DISTINCT DONumber,
			GoodsMovementStat,
			PODStatus
		FROM
			sysutil.PICONSOL.dbo.PI_DeliveryOrder
		WHERE
			(
				GoodsMovementStat = 'C'
				OR PODStatus = 'C'
			)
	) gt ON
	aq.DO_Number = gt.DONumber
LEFT OUTER JOIN(
		SELECT
			DISTINCT customer_id,
			DeliveryDeadline
		FROM
			BOSNET1.dbo.TMS_CustAtr
	) hy ON
	aq.Customer_ID = hy.customer_id
LEFT OUTER JOIN(
		SELECT
			DISTINCT Customer_ID,
			Name1
		FROM
			BOSNET1.dbo.Customer
	) ju ON
	aq.Customer_ID = ju.Customer_ID
WHERE
	aq.Plant = @BrId


