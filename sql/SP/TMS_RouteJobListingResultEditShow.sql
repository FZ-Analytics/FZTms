USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_RouteJobListingResultEditShow]    Script Date: 18/07/2018 09:48:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_RouteJobListingResultEditShow] --exec [dbo].[TMS_RouteJobListingResultEditShow] '20180621_154747795'
@RunId varchar(100), @OriRunId VARCHAR(100)
AS
SET NOCOUNT ON;
--DECLARE @RunId VARCHAR(100)= '20180621_154747795';

IF(
	SELECT
		COUNT(*)
	FROM
		bosnet1.dbo.TMS_RouteJob
	WHERE
		RunID = @RunId
)= 0 BEGIN --PRINT 'Hi Ravi Anand';

--bosnet1.dbo.TMS_RouteJob
 INSERT
	INTO
		bosnet1.dbo.TMS_RouteJob SELECT
			job_id,
			customer_id,
			do_number,
			vehicle_code,
			activity,
			routeNb,
			jobNb,
			arrive,
			depart,
			@RunId,
			getdate(),
			branch,
			shift,
			lon,
			lat,
			weight,
			volume,
			transportCost,
			activityCost,
			Dist,
			isFix
		FROM
			BOSNET1.dbo.TMS_RouteJob
		WHERE
			RunId = @OriRunId;

--bosnet1.dbo.TMS_PreRouteJob
 INSERT
	INTO
		bosnet1.dbo.TMS_PreRouteJob SELECT
			@RunId,
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
			format(getdate(),'yyyy-MM-dd hh:mm'),
			format(getdate(),'yyyy-MM-dd hh:mm'),
			isActive,
			Is_Exclude,
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
			MarketId,
			Desa_Kelurahan,
			Kecamatan,
			Kodya_Kabupaten,
			Batch,
			Ket_DO
		FROM
			bosnet1.dbo.TMS_PreRouteJob
		WHERE
			RunId = @OriRunId;

--BOSNET1.dbo.TMS_PreRouteVehicle
 INSERT
	INTO
		bosnet1.dbo.TMS_PreRouteVehicle SELECT
			@RunId,
			vehicle_code,
			weight,
			volume,
			vehicle_type,
			branch,
			startLon,
			startLat,
			endLon,
			endLat,
			startTime,
			endTime,
			source1,
			format(getdate(),'yyyy-MM-dd'),
			format(getdate(),'yyyy-MM-dd'),
			isActive,
			fixedCost,
			costPerM,
			costPerServiceMin,
			costPerTravelMin,
			IdDriver,
			NamaDriver,
			agent_priority,
			max_cust
		FROM
			bosnet1.dbo.TMS_PreRouteVehicle
		WHERE
			RunId = @OriRunId;
END DECLARE @sap AS TABLE
(
	Cust VARCHAR(100) NULL,
	DOPR VARCHAR(100) NULL,
	DOSP VARCHAR(100) NULL,
	DOSS VARCHAR(100) NULL,
	DORS VARCHAR(100) NULL
);

INSERT
	INTO
		@sap EXEC dbo.TMS_CekDataShipmentSAP @RunId;

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
	xq.RowNumber,
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
	rj.jobNb;