USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_insertPreRouteVehicle]    Script Date: 14/08/2018 15:51:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_insertPreRouteVehicle] --exec [dbo].[TMS_insertPreRouteVehicle] 'GT,FS,IT','20180711_141742896','D312'
@Channel varchar(100), @runID varchar(100), @plant varchar(100)
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

INSERT
	INTO
		bosnet1.dbo.TMS_PreRouteVehicle(
			RunId,
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
			UpdatevDate,
			CreateDate,
			isActive,
			fixedCost,
			costPerM,
			costPerServiceMin,
			costPerTravelMin,
			IdDriver,
			NamaDriver,
			agent_priority,
			max_cust
		) SELECT
			@runID AS RunId,
			v.vehicle_code,
			CASE
				WHEN vh.vehicle_code IS NULL THEN va.weight
				ELSE vh.weight
			END AS weight,
			CAST(
				CASE
					WHEN vh.vehicle_code IS NULL THEN va.volume
					ELSE vh.volume
				END AS NUMERIC(
					18,
					3
				)
			)* 1000000 AS volume,
			CASE
				WHEN vh.vehicle_code IS NULL THEN va.vehicle_type
				ELSE vh.vehicle_type
			END AS vehicle_type,
			CASE
				WHEN vh.vehicle_code IS NULL THEN va.branch
				ELSE vh.plant
			END AS branch,
			va.startLon,
			va.startLat,
			va.endLon,
			va.endLat,
			va.startTime,
			CONVERT(
				VARCHAR(5),
				dateadd(
					HOUR,
					- 1,
					CAST(
						va.endTime AS TIME
					)
				)
			) endTime,
			va.source1,
			'2018-07-13' AS UpdatevDate,
			'2018-07-13' AS CreateDate,
			'1' AS isActive,
			va.fixedCost,
			pr.value /(
				va.costPerM * 1000
			) AS costPerM,
			0 AS costPerServiceMin,
			0 AS costPerTravelMin,
			va.IdDriver,
			va.NamaDriver,
			CASE
				WHEN va.agent_priority IS NULL THEN rt.value
				ELSE va.agent_priority
			END AS agent_priority,
			CASE
				WHEN va.max_cust IS NULL THEN ry.value
				ELSE va.max_cust
			END AS max_cust
		FROM
			(
				SELECT
					DISTINCT vehicle_code
				FROM
					(
						SELECT
							vehicle_code
						FROM
							bosnet1.dbo.vehicle
						WHERE
							plant = @plant
					UNION SELECT
							vehicle_code
						FROM
							bosnet1.dbo.TMS_VehicleAtr
						WHERE
							branch = @plant
							AND included = 1
					) vi
			) v
		LEFT OUTER JOIN bosnet1.dbo.vehicle vh ON
			v.vehicle_code = vh.vehicle_code
		LEFT OUTER JOIN bosnet1.dbo.TMS_vehicleAtr va ON
			v.vehicle_code = va.vehicle_code
		LEFT OUTER JOIN BOSNET1.dbo.TMS_Progress ru ON
			ru.runID = '20180713_142338628'
		LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams pr ON
			pr.param = 'HargaSolar'
			AND pr.RunId = ru.OriRunId
		LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams bm ON
			bm.param = 'DefaultKonsumsiBBm'
			AND bm.RunId = ru.OriRunId
		LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams rt ON
			rt.param = 'Defaultagentpriority'
			AND rt.RunId = ru.OriRunId
		LEFT OUTER JOIN bosnet1.dbo.TMS_PreRouteParams ry ON
			ry.param = 'DefaultMaxCust'
			AND ry.RunId = ru.OriRunId
		WHERE
			va.included = 1
			AND va.Channel IN(
				SELECT
					*
				FROM
					@tb
			);

select 'OK'