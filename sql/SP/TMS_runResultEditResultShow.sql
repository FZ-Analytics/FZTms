USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_runResultEditResultShow]    Script Date: 03/09/2018 09:38:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_runResultEditResultShow] --exec dbo.TMS_runResultEditResultShow '20180704_134354097'
@RunId varchar(100), @dt int
--declare @RunId varchar(100), @dt int;
--set @RunId='20180830_141919396';
--set @dt=-90;
AS
SET NOCOUNT ON;

DECLARE @DelivDate VARCHAR(100);

DECLARE @OriRunId VARCHAR(100);

SELECT
	@DelivDate = datename(
		dw,
		DelivDate
	),
	@OriRunId = OriRunId
FROM
	BOSNET1.dbo.TMS_Progress
WHERE
	runID = @RunId;

DECLARE @run AS TABLE
	(
		RowNumber VARCHAR(5) NOT NULL,
		vehicle_code VARCHAR(100) NOT NULL,
		runID VARCHAR(100) NOT NULL
	);

INSERT
	INTO
		@run SELECT
			ROW_NUMBER() OVER(
			ORDER BY
				vehicle_code
			) AS RowNumber,
			vehicle_code,
			runID
		FROM
			(
				SELECT
					DISTINCT aq.vehicle_code,
					aq.runID
				FROM
					BOSNET1.dbo.TMS_RouteJob aq
				WHERE
					runID = @RunId
			) t;

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
		@sap EXEC [dbo].[TMS_CekDataShipmentSAP] @RunId, @dt;

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
		WHEN prj.Long IS NULL THEN ''
		ELSE prj.Long
	END Long,
	CASE
		WHEN prj.Lat IS NULL THEN ''
		ELSE prj.Lat
	END Lat,
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
	prj.vehicle_type_list,
	prv.startLon,
	prv.startLat,
	prv1.startTime,
	prv1.endTime,
	prv1.vehicle_type,
	case when prj.deliv_start is null then '00:00' else prj.deliv_start end deliv_start,
	case when prj.deliv_end is null then '00:00' else prj.deliv_end end deliv_end,
	CASE
		WHEN @DelivDate = 'Friday' THEN prma.value
		ELSE prms.value
	END breaks,
	xq.RowNumber,
	CASE
		WHEN RedeliveryCount IS NULL OR RedeliveryCount = '' THEN CASE
			WHEN xw.DOSP IS NULL
			AND xw.DORS IS NULL
			AND xw.DOSS IS NULL THEN '0'
			ELSE '1'
		END
		ELSE '2'
	END batch
FROM
	BOSNET1.dbo.TMS_RouteJob rj
LEFT JOIN(
		SELECT
			customer_ID,
			DO_number,
			Service_time,
			RunId,
			Name1,
			Long,
			Lat,
			Customer_priority,
			Distribution_Channel,
			Street,
			MIN(Request_Delivery_Date) Request_Delivery_Date,
			vehicle_type_list,
			rn,
			deliv_start,
			deliv_end,
			MAX(RedeliveryCount) RedeliveryCount
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
					prj.Long,
					prj.Lat,
					prj.Customer_priority,
					prj.Distribution_Channel,
					prj.Street,
					prj.Request_Delivery_Date,
					prj.vehicle_type_list,
					ROW_NUMBER() OVER(
						PARTITION BY prj.customer_ID
					ORDER BY
						prj.Name1 DESC
					) rn,
					prj.deliv_start,
					prj.deliv_end,
					prj.RedeliveryCount
				FROM
					BOSNET1.dbo.TMS_PreRouteJob prj
				WHERE
					Is_Edit = 'edit'
					AND RunId = @RunId
			) a
		WHERE
			rn = 1
		group by
			customer_ID,
			DO_number,
			Service_time,
			RunId,
			Name1,
			Long,
			Lat,
			Customer_priority,
			Distribution_Channel,
			Street,
			vehicle_type_list,
			rn,
			deliv_start,
			deliv_end
	) prj ON
	rj.runID = prj.RunId
	AND rj.customer_id = prj.Customer_ID
LEFT JOIN(
		SELECT
			prv.vehicle_code,
			prv.startLon,
			prv.startLat
		FROM
			BOSNET1.dbo.TMS_PreRouteVehicle prv
		WHERE
			prv.RunId = @RunId
	) prv ON
	prv.vehicle_code = rj.vehicle_code
	AND rj.customer_id = '' FULL
JOIN(
		SELECT
			prv1.vehicle_type,
			prv1.vehicle_code,
			prv1.startTime,
			prv1.endTime
		FROM
			BOSNET1.dbo.TMS_PreRouteVehicle prv1
		WHERE
			prv1.RunId = @RunId
	) prv1 ON
	prv1.vehicle_code = rj.vehicle_code
INNER JOIN BOSNET1.dbo.TMS_PreRouteParams prma ON
	prma.RunId = @OriRunId
	AND prma.param = 'fridayBreak'
INNER JOIN BOSNET1.dbo.TMS_PreRouteParams prms ON
	prms.RunId = @OriRunId
	AND prms.param = 'defaultBreak'
INNER JOIN @run xq ON
	xq.vehicle_code = rj.vehicle_code
	AND xq.runID = rj.runID
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