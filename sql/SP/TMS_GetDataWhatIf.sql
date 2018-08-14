USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_GetDataWhatIf]    Script Date: 14/08/2018 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_GetDataWhatIf] --exec [dbo].[TMS_GetDataWhatIf] '20180706_093140065'
@RunId varchar(50)
AS
SET NOCOUNT ON;
--use BOSNET1;
--declare @arr varchar(max);
--set @arr= '0,NA,5820010266|1,B9103TCH,start|2,B9103TCH,5810002520|3,B9103TCH,5810002824|4,B9103TCH,end|5,B9104TCH,start|6,B9104TCH,5810002820|7,B9104TCH,end|8,B9307IR,start|9,B9307IR,5810003007|10,B9307IR,5810101406|11,B9307IR,5820001887|12,B9307IR,end|13,B9310IR,start|14,B9310IR,5810003013|15,B9310IR,end|16,B9601IJ,start|17,B9601IJ,5810003429|18,B9601IJ,5810053636|19,B9601IJ,5810030332|20,B9601IJ,5810061868|21,B9601IJ,5810052076|22,B9601IJ,5810053668|23,B9601IJ,5810053622|24,B9601IJ,5810030276|25,B9601IJ,5810030290|26,B9601IJ,5810030259|27,B9601IJ,5810064707|28,B9601IJ,5810030355|29,B9601IJ,5810058831|30,B9601IJ,5810067267|31,B9601IJ,5810046975|32,B9601IJ,5810050054|33,B9601IJ,5810046977|34,B9601IJ,5810064420|35,B9601IJ,5810035620|36,B9601IJ,5810108868|37,B9601IJ,end|38,B9603IJ,start|39,B9603IJ,5810003750|40,B9603IJ,5810049136|41,B9603IJ,5810059074|42,B9603IJ,5820000297|43,B9603IJ,end|44,Beliroo_02_L300D312_1,start|45,Beliroo_02_L300D312_1,5810003753|46,Beliroo_02_L300D312_1,5810069644|47,Beliroo_02_L300D312_1,5810091284|48,Beliroo_02_L300D312_1,end|49,Beliroo_02_L300D312_2,start|50,Beliroo_02_L300D312_2,5810020141|51,Beliroo_02_L300D312_2,5810112299|52,Beliroo_02_L300D312_2,end|53,Beliroo_02_L300D312_3,start|54,Beliroo_02_L300D312_3,5810023688|55,Beliroo_02_L300D312_3,5810041010|56,Beliroo_02_L300D312_3,end|57,Beliroo_02_L300D312_4,start|58,Beliroo_02_L300D312_4,5810024318|59,Beliroo_02_L300D312_4,5810051255|60,Beliroo_02_L300D312_4,5810108867|61,Beliroo_02_L300D312_4,end|62,Beliroo_02_L300D312_5,start|63,Beliroo_02_L300D312_5,5810029143|64,Beliroo_02_L300D312_5,end|65,Beliroo_02_L300D312_6,start|66,Beliroo_02_L300D312_6,5810030107|67,Beliroo_02_L300D312_6,end|68,Beliroo_02_L300D312_7,start|69,Beliroo_02_L300D312_7,5810030251|70,Beliroo_02_L300D312_7,5810052743|71,Beliroo_02_L300D312_7,end|72,Beliroo_02_L300D312_8,start|73,Beliroo_02_L300D312_8,5810052334|74,Beliroo_02_L300D312_8,5810078676|75,Beliroo_02_L300D312_8,5810062121|76,Beliroo_02_L300D312_8,5810058769|77,Beliroo_02_L300D312_8,end|78,Beliroo_02_L300D312_9,start|79,Beliroo_02_L300D312_9,5810052432|80,Beliroo_02_L300D312_9,end|81,Deliveree_01_L300D312_1,start|82,Deliveree_01_L300D312_1,5810062473|83,Deliveree_01_L300D312_1,end|84,Deliveree_01_L300D312_2,start|85,Deliveree_01_L300D312_2,5810065215|86,Deliveree_01_L300D312_2,5810093146|87,Deliveree_01_L300D312_2,5810099385|88,Deliveree_01_L300D312_2,5810102044|89,Deliveree_01_L300D312_2,5810102048|90,Deliveree_01_L300D312_2,5810102046|91,Deliveree_01_L300D312_2,5810099386|92,Deliveree_01_L300D312_2,5810106496|93,Deliveree_01_L300D312_2,5810102047|94,Deliveree_01_L300D312_2,5810104404|95,Deliveree_01_L300D312_2,5810103293|96,Deliveree_01_L300D312_2,5810106495|97,Deliveree_01_L300D312_2,5810099951|98,Deliveree_01_L300D312_2,5810113218|99,Deliveree_01_L300D312_2,5810103411|100,Deliveree_01_L300D312_2,5810102445|101,Deliveree_01_L300D312_2,end|102,Deliveree_01_VAND312_1,start|103,Deliveree_01_VAND312_1,5810079502|104,Deliveree_01_VAND312_1,end|105,Deliveree_01_L300D312_3,start|106,Deliveree_01_L300D312_3,5810101308|107,Deliveree_01_L300D312_3,end';

--DECLARE @tb AS TABLE
--(
--	nm VARCHAR(100) NULL,
--	vehi VARCHAR(100) NULL,
--	cust VARCHAR(100)
--);
--INSERT
--	INTO
--		@tb SELECT
--			LEFT(
--				name,
--				CHARINDEX(
--					',',
--					name
--				)- 1
--			) nm,
--			SUBSTRING( name, CHARINDEX( ',', name )+ 1, CHARINDEX( ',', RIGHT( name, len( name )- CHARINDEX( ',', name )))- 1 ) vehi,
--			RIGHT(
--				name,
--				len(name)- CHARINDEX(
--					',',
--					name
--				)- CHARINDEX(
--					',',
--					RIGHT(
--						name,
--						len(name)- CHARINDEX(
--							',',
--							name
--						)
--					)
--				)
--			) cust
--		FROM
--			dbo.splitstring(
--				@arr,
--				'|'
--			);

--SELECT
--	*
--FROM
--	@tb 
SELECT
	rj.job_id,
	rj.customer_id,
	rj.do_number,
	rj.vehicle_code,
	rj.activity,
	rj.routeNb,
	rj.jobNb,
	rj.arrive,
	rj.depart,
	rj.runID,
	rj.create_dtm,
	rj.branch,
	rj.shift,
	rj.lon,
	rj.lat,
	rj.weight,
	rj.volume,
	rj.transportCost,
	rj.activityCost,
	rj.Dist,
	rj.isFix,
	cost.costPerM,
	prj.Service_time
FROM
	BOSNET1.dbo.TMS_RouteJob rj
LEFT OUTER JOIN(
		SELECT
			DISTINCT costPerM,
			runId,
			vehicle_code
		FROM
			BOSNET1.dbo.TMS_PreRouteVehicle
	) cost ON
	cost.runId = rj.runID
	AND cost.vehicle_code = rj.vehicle_code
LEFT OUTER JOIN(
		SELECT
			DISTINCT Service_time,
			customer_id,
			RunId
		FROM
			BOSNET1.dbo.TMS_PreRouteJob prj
	) prj ON
	prj.customer_id = rj.customer_id
	AND prj.RunId = rj.runID
WHERE
	rj.runID = @RunId
ORDER BY
	rj.routeNb,
	rj.jobNb