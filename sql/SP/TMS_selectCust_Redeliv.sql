USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_selectCust_Redeliv]    Script Date: 27/08/2018 13:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_selectCust_Redeliv] --exec [dbo].[TMS_selectCust] '20180720_160216815','20180720_160216815',-90
@RunId varchar(100), @prev varchar(100), @dt int
--set @RunId = '20180720_160216815';
--set @prev = '20180827_100709803';
--set @dt = -90;
AS
SET NOCOUNT ON;
--select * from BOSNET1.dbo.TMS_PreRouteJob where RunId = '20180720_153914708' and RedeliveryCount is not null

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
	jb.total_kg,
	jb.total_cubication,
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
	jb.Gross_Amount,
	jb.DOQty,
	jb.DOQtyUOM,
	jb.Name1,
	jb.Street,
	jb.Distribution_Channel,
	jb.Customer_Order_Block_all,
	jb.Customer_Order_Block,
	jb.Request_Delivery_Date,
	jb.Desa_Kelurahan,
	jb.Kecamatan,
	jb.Kodya_Kabupaten,
	jb.Batch,
	jb.Ket_DO,
	case when jb.RedeliveryCount is null then '' else jb.RedeliveryCount end RedeliveryCount
FROM
	(
		SELECT
			REPLACE(
				RunId,
				'_',
				''
			) runs,
			*
		FROM
			bosnet1.dbo.TMS_PreRouteJob
	) jb
LEFT OUTER JOIN(
		SELECT
			DISTINCT DO_Number
		FROM
			bosnet1.dbo.TMS_ShipmentPlan
		WHERE
			--already_shipment = 'N' AND notused_flag IS NULL AND 
			incoterm = 'FCO'
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
LEFT OUTER JOIN SFAUtility.dbo.TCS_RedeliveryStatus rd ON
	jb.DO_Number = rd.DONumber
	AND jb.RedeliveryCount = rd.RedeliveryCount
LEFT OUTER JOIN(
		SELECT
			tu.Delivery_Number,
			SUBSTRING( tu.Shipment_Number_Dummy, 1, 17 ) Shipment_Number_Dummy
		FROM
			BOSNET1.dbo.TMS_Result_Shipment ty
		INNER JOIN BOSNET1.dbo.TMS_Status_Shipment tu ON
			ty.Delivery_Number = tu.Delivery_Number
		WHERE
			tu.SAP_Status IS NULL
	) ss ON
	sp.DO_Number = ss.Delivery_Number
	AND jb.runs = ss.Shipment_Number_Dummy
--LEFT OUTER JOIN(
--		SELECT
--			ty.Delivery_Number,
--			SUBSTRING( ty.Shipment_Number_Dummy, 1, 17 ) Shipment_Number_Dummy
--		FROM
--			BOSNET1.dbo.TMS_Result_Shipment ty
--		LEFT OUTER JOIN BOSNET1.dbo.TMS_Status_Shipment tu ON
--			ty.Delivery_Number = tu.Delivery_Number
--		WHERE
--			tu.Delivery_Number IS NULL
--	) sn ON
--	sp.DO_Number = sn.Delivery_Number
--	AND jb.runs = sn.Shipment_Number_Dummy
WHERE
	--jb.DO_Number in ('8020127691','8020127305') and
	ss.Delivery_Number IS NULL
	--AND sn.Delivery_Number IS NULL
	AND jb.RunId = @prev
	AND jb.Is_Exclude = 'inc'
	AND jb.Is_Edit = 'edit'
	--AND(
	--	(
	--		sp.DO_Number IS NULL
	--		AND jb.RedeliveryCount IS NOT NULL
	--	)
	--	OR(
	--		sp.DO_Number IS NOT NULL
	--		AND jb.RedeliveryCount IS NULL
	--	)
	--);