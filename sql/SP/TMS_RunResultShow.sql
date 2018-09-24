USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_RunResultShow]    Script Date: 24/09/2018 13:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_RunResultShow] --exec [dbo].[TMS_RunResultShow] '20180717_104539450'
@RunId varchar(100)
AS
SET NOCOUNT ON;
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
		@sap EXEC [dbo].[TMS_CekDataShipmentSAP] @RunId;

SELECT
	j.customer_ID,
	(
		SELECT
			(
				stuff(
					(
						SELECT
							'; ' + DO_Number
						FROM
							bosnet1.dbo.TMS_PreRouteJob a
						WHERE
							Is_Edit = 'edit'
							AND Customer_ID = j.customer_ID
							AND RunId = j.runID
						GROUP BY
							DO_Number FOR xml PATH('')
					),
					1,
					2,
					''
				)
			)
	) AS DO_number,
	j.arrive,
	j.depart,
	j.lat,
	j.lon,
	j.vehicle_code,
	j.branch,
	j.shift,
	CASE
		WHEN d.name1 IS NULL
		AND Request_Delivery_Date IS NOT NULL THEN 'UNKNOWN'
		ELSE d.name1
	END name1,
	d.customer_priority,
	d.distribution_channel,
	d.street,
	CAST(
		CAST(
			(
				CAST(
					j.weight AS FLOAT
				)
			) AS NUMERIC(
				15,
				1
			)
		) AS VARCHAR
	) AS weight,
	CAST(
		CAST(
			(
				(
					CAST(
						j.volume AS FLOAT
					)/ 1000000
				)
			) AS NUMERIC(
				15,
				1
			)
		) AS VARCHAR
	) AS volume,
	CASE
		WHEN d.CreateDate <> d.UpdatevDate THEN 'edited'
		WHEN d.CreateDate = d.UpdatevDate THEN 'edit'
	END edit,
	CAST(
		CAST(
			j.transportCost AS NUMERIC(9)
		) AS VARCHAR
	) AS transportCost,
	CAST(
		Dist / 1000 AS NUMERIC(
			9,
			1
		)
	) AS Dist,
	Request_Delivery_Date,
	xq.RowNumber,
	CASE
		WHEN xw.DOSP IS NULL
		AND xw.DORS IS NULL
		AND xw.DOSS IS NULL THEN '0'
		ELSE '1'
	END batch
FROM
	bosnet1.dbo.tms_RouteJob j
LEFT OUTER JOIN(
		SELECT
			RunId,
			Customer_ID,
			MIN( Customer_priority ) Customer_priority,
			CreateDate,
			UpdatevDate,
			name1,
			street,
			distribution_channel,
			MIN( Request_Delivery_Date ) Request_Delivery_Date
		FROM
			(
				SELECT
					DISTINCT RunId,
					Customer_ID,
					Customer_priority,
					CreateDate,
					UpdatevDate,
					name1,
					street,
					distribution_channel,
					Request_Delivery_Date
				FROM
					bosnet1.dbo.TMS_PreRouteJob
				WHERE
					Is_Edit = 'edit'
			) a
		GROUP BY
			RunId,
			Customer_ID,
			CreateDate,
			UpdatevDate,
			name1,
			street,
			distribution_channel
	) d ON
	j.runID = d.RunId
	AND j.customer_id = d.Customer_ID
INNER JOIN @run xq ON
	xq.vehicle_code = j.vehicle_code
	AND xq.runID = j.runID
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
	xw.Cust = j.customer_ID
WHERE
	j.runID = @RunId
ORDER BY
	j.routeNb,
	j.jobNb,
	j.arrive;