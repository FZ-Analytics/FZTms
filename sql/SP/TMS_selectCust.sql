USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_selectCust]    Script Date: 27/08/2018 13:26:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_selectCust] --exec [dbo].[TMS_selectCust] '20180720_160216815','20180720_160216815',-90
@RunId varchar(100), @prev varchar(100), @dt int
--set @RunId = '20180720_160216815';
--set @prev = '20180827_100709803';
--set @dt = -90;
AS
SET NOCOUNT ON;
--select * from BOSNET1.dbo.TMS_PreRouteJob where RunId = '20180720_153914708' and RedeliveryCount is not null
DECLARE @PreRouteJob AS TABLE
	(
		RunId VARCHAR(18),
		Customer_ID VARCHAR(40),
		DO_Number VARCHAR(40),
		Long VARCHAR(100),
		Lat VARCHAR(100),
		Customer_priority INT,
		Service_time INT,
		deliv_start VARCHAR(5),
		deliv_end VARCHAR(5),
		vehicle_type_list VARCHAR(255),
		total_kg VARCHAR(100),
		total_cubication VARCHAR(100),
		DeliveryDeadline VARCHAR(100),
		DayWinStart VARCHAR(100),
		DayWinEnd VARCHAR(100),
		UpdatevDate VARCHAR(20),
		CreateDate VARCHAR(20),
		isActive VARCHAR(1),
		Is_Exclude VARCHAR(5),
		Product_Description VARCHAR(500),
		Gross_Amount VARCHAR(100),
		DOQty VARCHAR(100),
		DOQtyUOM VARCHAR(5),
		Name1 VARCHAR(500),
		Street VARCHAR(500),
		Distribution_Channel VARCHAR(35),
		Customer_Order_Block_all VARCHAR(5) null,
		Customer_Order_Block VARCHAR(5) null,
		Request_Delivery_Date VARCHAR(25),
		Desa_Kelurahan VARCHAR(100),
		Kecamatan VARCHAR(100),
		Kodya_Kabupaten VARCHAR(100),
		Batch VARCHAR(100),
		Ket_DO VARCHAR(200),
		RedeliveryCount VARCHAR(3) null
	);

insert into @PreRouteJob 
SELECT
	@RunId AS RunId,
	jb.Customer_ID,
	jb.DO_Number,
	jb.Long,
	jb.Lat,
	jb.Customer_priority,
	jb.Service_time,
	jb.deliv_start,
	jb.deliv_end,
	jb.vehicle_type_list,
	CAST(jb.total_kg as varchar) total_kg,
	CAST(jb.total_cubication as varchar) total_cubication,
	jb.DeliveryDeadline,
	jb.DayWinStart,
	jb.DayWinEnd,
	CAST(
		FORMAT(
			getdate(),
			'yyyy-MM-dd hh-mm'
		) AS VARCHAR
	) AS UpdatevDate,
	CAST(
		FORMAT(
			getdate(),
			'yyyy-MM-dd hh-mm'
		) AS VARCHAR
	) AS CreateDate,
	jb.isActive,
	jb.Is_Exclude,
	jb.Product_Description,
	CAST(jb.Gross_Amount as varchar) Gross_Amount,
	CAST(jb.DOQty as varchar) DOQty,
	jb.DOQtyUOM,
	jb.Name1,
	jb.Street,
	jb.Distribution_Channel,
	Customer_Order_Block_all,
	Customer_Order_Block,
	jb.Request_Delivery_Date,
	jb.Desa_Kelurahan,
	jb.Kecamatan,
	jb.Kodya_Kabupaten,
	jb.Batch,
	jb.Ket_DO,
	jb.RedeliveryCount
FROM
	bosnet1.dbo.TMS_PreRouteJob jb
INNER JOIN(
		SELECT
			DISTINCT DO_Number
		FROM
			bosnet1.dbo.TMS_ShipmentPlan
		WHERE
			already_shipment = 'N'
			AND notused_flag IS NULL
			AND incoterm = 'FCO'
			AND(
				Order_Type = 'ZDCO'
				OR Order_Type = 'ZDTO'
			)
			AND create_date >= DATEADD(
				DAY,
				@dt,
				GETDATE()
			)
	) sp ON
	jb.DO_Number = sp.DO_Number
LEFT OUTER JOIN(
		SELECT
			tu.Delivery_Number
		FROM
			BOSNET1.dbo.TMS_Result_Shipment ty
		INNER JOIN BOSNET1.dbo.TMS_Status_Shipment tu ON
			ty.Delivery_Number = tu.Delivery_Number
		WHERE
			tu.SAP_Status IS NULL
	) ss ON
	sp.DO_Number = ss.Delivery_Number
LEFT OUTER JOIN(
		SELECT
			ty.Delivery_Number
		FROM
			BOSNET1.dbo.TMS_Result_Shipment ty
		LEFT OUTER JOIN BOSNET1.dbo.TMS_Status_Shipment tu ON
			ty.Delivery_Number = tu.Delivery_Number
		WHERE
			tu.Delivery_Number IS NULL
	) sn ON
	sp.DO_Number = sn.Delivery_Number
WHERE
	ss.Delivery_Number IS NULL
	AND sn.Delivery_Number IS NULL
	AND jb.RedeliveryCount is null
	AND jb.RunId = @prev
	AND jb.Is_Exclude = 'inc'
	AND jb.Is_Edit = 'edit';

insert into @PreRouteJob exec bosnet1.dbo.TMS_selectCust_Redeliv @RunId,@prev,@dt;

select * from @PreRouteJob;