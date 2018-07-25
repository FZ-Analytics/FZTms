USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_QueryCust_Redeliv]    Script Date: 25/07/2018 15:22:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TMS_QueryCust_Redeliv] --exec [dbo].[TMS_QueryCust_Redeliv] '20180525_154124248'
@RunId varchar(100), @chn varchar(100)
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
				@chn,
				','
			);
INSERT
	INTO
		BOSNET1.dbo.TMS_PreRouteJob SELECT
			@RunId RunId,
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
			format(
				getdate(),
				'yyyy/MM/dd hh:mm'
			) UpdatevDate,
			format(
				getdate(),
				'yyyy/MM/dd hh:mm'
			) CreateDate,
			1 isActive,
			'inc' Is_Exclude,
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
			0 MarketId,
			Desa_Kelurahan,
			Kecamatan,
			Kodya_Kabupaten,
			0 Batch,
			'-' Ket_DO,
			rd.RedeliveryCount RedeliveryCount
		FROM
			SFAUtility.dbo.TCS_RedeliveryStatus rd
		INNER JOIN(
				SELECT
					prj.Customer_ID,
					prj.DO_Number,
					prj.Long,
					prj.Lat,
					prj.Customer_priority,
					prj.Service_time,
					prj.deliv_start,
					prj.deliv_end,
					prj.vehicle_type_list,
					prj.total_kg,
					prj.total_cubication,
					prj.DeliveryDeadline,
					prj.DayWinStart,
					prj.DayWinEnd,
					prj.Is_Edit,
					prj.Product_Description,
					prj.Gross_Amount,
					prj.DOQty,
					prj.DOQtyUOM,
					prj.Name1,
					cs.Street,
					prj.Distribution_Channel,
					prj.Customer_Order_Block_all,
					prj.Customer_Order_Block,
					prj.Request_Delivery_Date,
					prj.MarketId,
					cs.Desa_Kelurahan,
					cs.Kecamatan,
					cs.Kodya_Kabupaten,
					prj.Batch,
					prj.Ket_DO,
					MAX( prj.RedeliveryCount ) RedeliveryCount
				FROM
					(
						SELECT
							concat(
								REPLACE(
									prj.RunId,
									'_',
									''
								),
								rj.vehicle_code
							) runs,
							prj.*
						FROM
							BOSNET1.dbo.TMS_PreRouteJob prj
						INNER JOIN(
								SELECT
									DISTINCT runId,
									customer_id,
									vehicle_code
								FROM
									BOSNET1.dbo.TMS_RouteJob
							) rj ON
							prj.runId = rj.runId
							AND prj.customer_id = rj.customer_id
					) prj
				INNER JOIN BOSNET1.dbo.TMS_Status_Shipment ss ON
					prj.runs = ss.Shipment_Number_Dummy
				INNER JOIN(
						SELECT
							a.*
						FROM
							(
								SELECT
									ROW_NUMBER() OVER(
										PARTITION BY Customer_ID
									ORDER BY
										Customer_ID
									) AS noId,
									*
								FROM
									bosnet1.dbo.customer
								WHERE
									(
										Customer_Order_Block IS NULL
										OR Customer_Order_Block = ''
									)
									AND(
										Customer_Order_Block_all IS NULL
										OR Customer_Order_Block_all = ''
									)
							) a
						WHERE
							a.noid = 1
					) cs ON
					prj.Customer_ID = cs.Customer_ID
				WHERE
					ss.SAP_Status IS NULL
				GROUP BY
					prj.Customer_ID,
					prj.DO_Number,
					prj.Long,
					prj.Lat,
					prj.Customer_priority,
					prj.Service_time,
					prj.deliv_start,
					prj.deliv_end,
					prj.vehicle_type_list,
					prj.total_kg,
					prj.total_cubication,
					prj.DeliveryDeadline,
					prj.DayWinStart,
					prj.DayWinEnd,
					prj.Is_Edit,
					prj.Product_Description,
					prj.Gross_Amount,
					prj.DOQty,
					prj.DOQtyUOM,
					prj.Name1,
					cs.Street,
					prj.Distribution_Channel,
					prj.Customer_Order_Block_all,
					prj.Customer_Order_Block,
					prj.Request_Delivery_Date,
					prj.MarketId,
					cs.Desa_Kelurahan,
					cs.Kecamatan,
					cs.Kodya_Kabupaten,
					prj.Batch,
					prj.Ket_DO
			) rj ON
			rd.DONumber = rj.DO_Number
			AND(
				rd.RedeliveryCount > rj.RedeliveryCount
				OR rj.RedeliveryCount IS NULL
			)
		WHERE
			rd.RedeliveryStatus = 1
			AND Customer_ID IS NOT NULL
			AND Distribution_Channel IN(
		SELECT
			*
		FROM
			@tb
	)
SELECT
	'ok';