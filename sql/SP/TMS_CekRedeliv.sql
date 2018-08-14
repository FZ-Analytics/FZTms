USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_CekRedeliv]    Script Date: 14/08/2018 15:49:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_CekRedeliv] --exec [dbo].[TMS_CekRedeliv] '20180525_154124248'
--@RunId varchar(100), @chn varchar(100)
AS
SET NOCOUNT ON;
--yang bisa di redeliv
SELECT --top 10
	rd.DONumber--,rj.DO_Number,rd.RedeliveryCount,rj.RedeliveryCount, rj.runs, sn.Shipment_Number_Dummy,ss.Shipment_Number_Dummy,SAP_Message
FROM
	SFAUtility.dbo.TCS_RedeliveryStatus rd
INNER JOIN(
		SELECT
			prj.DO_Number,
			MAX( prj.RedeliveryCount ) RedeliveryCount,
			prj.runs
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
				INNER JOIN(
						SELECT
							DISTINCT runId,
							customer_id,
							vehicle_code
						FROM
							BOSNET1.dbo.TMS_RouteJob
					) rj ON
					prj.runId = rj.runId
					AND prj.customer_id = rj.customer_id
			) prj
		--WHERE
			--prj.RedeliveryCount IS NOT NULL
			--AND prj.RedeliveryCount <> ''
		GROUP BY
			prj.DO_Number,
			prj.runs
	) rj ON 
	rd.DONumber = rj.DO_Number
LEFT OUTER JOIN(
		SELECT
			DISTINCT Delivery_Number,SUBSTRING(Shipment_Number_Dummy, 1, 17) Shipment_Number_Dummy,SAP_Message
		FROM
			BOSNET1.dbo.TMS_Status_Shipment
		--WHERE
			--SAP_Message IS NULL
	) ss ON
	rj.DO_Number = ss.Delivery_Number
	and rj.runs = ss.Shipment_Number_Dummy
LEFT OUTER JOIN(
		SELECT
			DISTINCT Delivery_Number,SUBSTRING(Shipment_Number_Dummy, 1, 17) Shipment_Number_Dummy
		FROM
			BOSNET1.dbo.TMS_Result_Shipment
	) sn ON
	rj.DO_Number = sn.Delivery_Number
	and rj.runs = sn.Shipment_Number_Dummy
WHERE
	rd.RedeliveryStatus = 1 and rd.RedeliveryCount > case when rj.RedeliveryCount is null or rj.RedeliveryCount = '' then 0 else rj.RedeliveryCount end
	AND (sn.Shipment_Number_Dummy is not null and ss.Shipment_Number_Dummy is not null) and ss.SAP_Message is null
	--AND ((ss.Shipment_Number_Dummy is not null and ss.SAP_Message is null and sn.Shipment_Number_Dummy is not null) or (sn.Shipment_Number_Dummy is not null and ss.Shipment_Number_Dummy is not null))

