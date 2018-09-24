USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_ArchieveTMS_PreRouteJob]    Script Date: 24/09/2018 14:26:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_ArchieveTMS_PreRouteJob] --q
AS
SET NOCOUNT ON;
Declare @at int; 
set @at = 20180701;

--take 2 month before
INSERT
	INTO
		BOSNET1.dbo.TMS_PreRouteJobArc SELECT
			sw.*
		FROM
			(
				SELECT
					DISTINCT CAST(
						SUBSTRING( RunId, 1, 8 ) AS INT
					) AS rn,
					RunId
				FROM
					BOSNET1.dbo.TMS_PreRouteJob
				WHERE
					len(RunId)> 15
			) aq
		INNER JOIN BOSNET1.dbo.TMS_PreRouteJob sw ON
			aq.RunId = sw.RunId
		WHERE
			rn < @at;

--delete <2month before
--BEGIN tran --commit rollback
 DELETE
	BOSNET1.dbo.TMS_PreRouteJob
WHERE
	RunId IN(
		SELECT
			DISTINCT sw.RunId
		FROM
			(
				SELECT
					DISTINCT CAST(
						SUBSTRING( RunId, 1, 8 ) AS INT
					) AS rn,
					RunId
				FROM
					BOSNET1.dbo.TMS_PreRouteJob
				WHERE
					len(RunId)> 15
			) aq
		INNER JOIN BOSNET1.dbo.TMS_PreRouteJob sw ON
			aq.RunId = sw.RunId
		WHERE
			rn < @at
	);