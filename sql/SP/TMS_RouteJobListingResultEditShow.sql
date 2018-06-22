USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_RouteJobListingResultEditShow]    Script Date: 22/06/2018 10:38:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_RouteJobListingResultEditShow] --exec [dbo].[TMS_RouteJobListingResultEditShow] '20180621_154747795'
@RunId varchar(100)
AS
SET NOCOUNT ON;
--DECLARE @RunId varchar(100) = '20180621_154747795';
DECLARE @sap AS TABLE
	(
		Cust VARCHAR(100) NULL,
		DOPR VARCHAR(100) NULL,
		DOSP VARCHAR(100) NULL,
		DOSS VARCHAR(100) NULL,
		DORS VARCHAR(100) NULL
	);

INSERT
	INTO
		@sap EXEC [dbo].[TMS_CekDataShipmentSAP] @RunId;
SELECT
	CASE
		WHEN rj.depart = '' THEN 0
		ELSE rj.jobNb - 1
	END NO,
	rj.vehicle_code,
	rj.customer_id,
	rj.arrive,
	rj.depart,
	CASE
		WHEN prj.DO_Number IS NULL THEN ''
		ELSE prj.DO_number
	END DO_Number,
	CASE
		WHEN rj.vehicle_code = 'NA' THEN 0
		WHEN prj.Service_time IS NULL THEN ''
		ELSE prj.Service_time
	END serviceTime,
	CASE
		WHEN prj.Name1 IS NULL THEN ''
		ELSE prj.Name1
	END Name1,
	CASE
		WHEN prj.Customer_priority IS NULL THEN ''
		ELSE prj.Customer_priority
	END Customer_priority,
	CASE
		WHEN prj.Distribution_Channel IS NULL THEN ''
		ELSE prj.Distribution_Channel
	END Distribution_Channel,
	CASE
		WHEN prj.Street IS NULL THEN ''
		ELSE prj.Street
	END Street,
	rj.weight,
	rj.volume,
	prj.Request_Delivery_Date,
	rj.transportCost TransportCost,
	rj.Dist,
	CASE
		WHEN xw.DOSP IS NULL
		AND xw.DORS IS NULL
		AND xw.DOSS IS NULL THEN '0'
		ELSE '1'
	END bat
FROM
	BOSNET1.dbo.TMS_RouteJob rj
LEFT JOIN(
		SELECT
			customer_ID,
			DO_number,
			Service_time,
			RunId,
			Name1,
			MIN( Customer_priority ) Customer_priority,
			Distribution_Channel,
			Street,
			MIN( Request_Delivery_Date ) Request_Delivery_Date
		FROM
			(
				SELECT
					DISTINCT prj.customer_ID,
					(
						SELECT
							(
								stuff(
									(
										SELECT
											'; ' + DO_Number
										FROM
											bosnet1.dbo.TMS_PreRouteJob
										WHERE
											Is_Edit = 'edit'
											AND Customer_ID = prj.Customer_ID
											AND RunId = @RunId
										GROUP BY
											DO_Number FOR xml PATH('')
									),
									1,
									2,
									''
								)
							)
					) AS DO_number,
					prj.Service_time,
					prj.RunId,
					prj.Name1,
					prj.Customer_priority,
					prj.Distribution_Channel,
					prj.Street,
					prj.Request_Delivery_Date
				FROM
					BOSNET1.dbo.TMS_PreRouteJob prj
				WHERE
					Is_Edit = 'edit'
					AND RunId = @RunId
			) sr
		GROUP BY
			customer_ID,
			DO_number,
			Service_time,
			RunId,
			Name1,
			Distribution_Channel,
			Street
	) prj ON
	rj.runID = prj.RunId
	AND rj.customer_id = prj.Customer_ID
LEFT OUTER JOIN(
		SELECT
			DISTINCT s.Cust,
			MIN( s.DOSP ) DOSP,
			MIN( s.DORS ) DORS,
			MIN( s.DOSS ) DOSS
		FROM
			@sap s
		GROUP BY
			s.Cust
	) xw ON
	xw.Cust = rj.customer_ID
WHERE
	rj.runID = @RunId
ORDER BY
	rj.routeNb,
	rj.jobNb