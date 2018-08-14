USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_AlgoRunner_N]    Script Date: 14/08/2018 15:47:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_AlgoRunner_N] --exec [dbo].[TMS_AlgoRunner_N] 'GT,FS,IT','20180711_141742896','D312',20,2,35
@Channel varchar(100), @runID varchar(100), @plant varchar(100),@distance varchar(100),@buffTime varchar(100), @SpeedKmPHour varchar(100)
AS
SET NOCOUNT ON;
DECLARE @stat AS TABLE
	(
		chn VARCHAR(100)
	);
insert into @stat EXEC bosnet1.dbo.TMS_GetCustLongLat @plant;

insert into BOSNET1.dbo.TMS_PreRouteParams select @runID, param, value from BOSNET1.dbo.TMS_Params where param not in('DefaultDistance','TrafficFactor','SpeedKmPHour');
insert into BOSNET1.dbo.TMS_PreRouteParams values(@runID, 'DefaultDistance', @distance);
insert into BOSNET1.dbo.TMS_PreRouteParams values(@runID, 'TrafficFactor', @buffTime);
insert into BOSNET1.dbo.TMS_PreRouteParams values(@runID, 'SpeedKmPHour', @SpeedKmPHour);

insert into @stat exec [dbo].[TMS_insertPreRouteVehicle] @Channel,@runID,@plant

exec [dbo].[TMS_QueryCust] @plant,@runID,'D312',-30



