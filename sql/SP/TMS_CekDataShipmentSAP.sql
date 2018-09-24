USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_CekDataShipmentSAP]    Script Date: 24/09/2018 14:26:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_CekDataShipmentSAP] --exec [dbo].[TMS_CekDataShipmentSAP] '20180525_100044389'
@RunId varchar(100)
AS
SET NOCOUNT ON;
SELECT
	prj.Customer_ID as Cust,
	prj.DO_Number AS DOPR,
	CASE
		WHEN sp.DO_Number IS NULL THEN '802000000'
		ELSE NULL
	END AS DOSP,
	ss.Delivery_Number AS DOSS,
	sn.Delivery_Number AS DORS
FROM
	(
		SELECT
			DISTINCT RunId,
			DO_Number,
			Customer_ID
		FROM
			BOSNET1.dbo.TMS_PreRouteJob
	) prj
LEFT OUTER JOIN(
		SELECT
			DISTINCT DO_Number
		FROM
			bosnet1.dbo.TMS_ShipmentPlan
		WHERE
			already_shipment = 'N'
			AND notused_flag IS NULL
			AND incoterm = 'FCO'
			AND Order_Type IN(
				'ZDCO',
				'ZDTO'
			)
			AND create_date >= DATEADD(
				DAY,
				- 30,
				GETDATE()
			)
			AND batch IS NOT NULL
	) sp ON
	prj.DO_Number = sp.DO_Number
LEFT OUTER JOIN(
		SELECT
			DISTINCT Delivery_Number
		FROM
			BOSNET1.dbo.TMS_Status_Shipment
		WHERE
			SAP_Message IS NULL
	) ss ON
	prj.DO_Number = ss.Delivery_Number
LEFT OUTER JOIN(
		SELECT
			DISTINCT Delivery_Number
		FROM
			BOSNET1.dbo.TMS_Result_Shipment
	) sn ON
	prj.DO_Number = sn.Delivery_Number
WHERE
	prj.RunId = @RunId
order by
	prj.DO_Number