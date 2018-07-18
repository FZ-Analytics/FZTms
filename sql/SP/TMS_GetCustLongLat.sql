USE [BOSNET1]
GO
/****** Object:  StoredProcedure [dbo].[TMS_GetCustLongLat]    Script Date: 18/07/2018 09:45:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[TMS_GetCustLongLat] --'D322'

@Branch Varchar(10)

as Begin


DELETE FROM TMS_CustLongLat
WHERE BranchId = CASE WHEN @Branch  = '' THEN BranchId ELSE @Branch END

INSERT INTO TMS_CustLongLat
SELECT 
	BranchId,
	BranchName,
	CustId,
	CustName,
	Address = CASE WHEN LEFT(Address, 3) = ' - ' AND LEN(Address) >= 3 THEN RIGHT(Address, LEN(Address) - 3)
					WHEN LEFT(Address, 2) = '- ' AND LEN(Address) >= 2 THEN RIGHT(Address, LEN(Address) - 2)
					WHEN LEFT(Address, 2) = ' -' AND LEN(Address) >= 2 THEN RIGHT(Address, LEN(Address) - 2)
					WHEN LEFT(Address, 1) = '-' AND LEN(Address) >= 1 THEN RIGHT(Address, LEN(Address) - 1)
					ELSE Address END,
	MarketId,
	SubDistrict,
	District,
	City,
	Province,
	PostalCode,
	Long,
	Lat,
	Source
FROM
(
	SELECT DISTINCT
		BranchId = Sales_Office,
		BranchName = SalOffName,
		CustId = Customer_Id,
		CustName = REPLACE(REPLACE(REPLACE(REPLACE(Name1, char(9), ' '), '"', ' '), char(10), ' '), char(13), ' '), 
		Address = CASE WHEN BranchValidated = 1 AND S.Address IS NOT NULL THEN REPLACE(REPLACE(REPLACE(REPLACE(S.Address, char(9), ' '), '"', ' '), char(10), ' '), char(13), ' ') ELSE REPLACE(REPLACE(REPLACE(REPLACE(Street, char(9), ' '), '"', ' '), char(10), ' '), char(13), ' ') END,
		MarketId = M.MarketId,
		SubDistrict = CASE WHEN BranchValidated = 1 AND VI_Name IS NOT NULL THEN VI_Name ELSE desa_kelurahan END,
		District = CASE WHEN BranchValidated = 1 AND SU_Name IS NOT NULL THEN SU_Name ELSE Kecamatan END,
		City = CASE WHEN BranchValidated = 1 AND DI_Name IS NOT NULL THEN DI_Name ELSE Kodya_kabupaten END,
		Province = CASE WHEN BranchValidated = 1 AND A4.PR_Name IS NOT NULL THEN A4.PR_Name ELSE A5.PR_Name END,
		PostalCode = CASE WHEN BranchValidated = 1 AND mZipCode IS NOT NULL THEN mZipCode ELSE B.POSTAL_CODE END,
		Long = 
			CASE WHEN ImgLongLatValidated = 1 THEN CASE WHEN ImgLongitude <> '' THEN ImgLongitude ELSE S.Longitude END 
				ELSE CASE WHEN GLongLatValidated = 1 THEN GLongitude
					ELSE CASE WHEN RLongitude IS NOT NULL AND RLongitude <> '' THEN RLongitude
						ELSE B.Longitude END
					END
				END,
		Lat = CASE WHEN ImgLongLatValidated = 1 THEN CASE WHEN ImgLatitude <> '' THEN ImgLatitude ELSE S.Latitude END 
				ELSE CASE WHEN GLongLatValidated = 1 THEN GLatitude
					ELSE CASE WHEN RLatitude IS NOT NULL AND RLatitude <> '' THEN RLatitude
						ELSE B.Latitude END
					END
				END,
		Source = CASE WHEN ImgLongLatValidated = 1 THEN CASE WHEN ImgLatitude <> '' THEN 'ImgLongLat' ELSE 'LongLat' END  
				ELSE CASE WHEN GLongLatValidated = 1 THEN 'GLongLat'
					ELSE CASE WHEN RLatitude IS NOT NULL AND RLatitude <> '' THEN 'RLongLat'
						ELSE 'Bosnet1' END
					END
				END
	FROM BOSNET1.dbo.Customer B
	LEFT JOIN SysUtil.SFAUtility.dbo.SysCustomer S
	ON B.Customer_Id = S.CustId
	LEFT JOIN SysUtil.IBACONSOL.dbo.SALES_OFFICE BR
	ON B.Sales_Office = BR.SalOffCode COLLATE DATABASE_DEFAULT
	Left Join SysUtil.DATA.DBO.Area_Administration A4 
	ON S.PR_ID = A4.PR_ID and S.DI_ID = A4.DI_ID and S.SU_ID = A4.SU_ID and S.VI_ID = A4.VI_ID
	Left Join 
	(SELECT DISTINCT PR_ID, PR_NAME FROM SysUtil.DATA.DBO.Area_Administration) A5 
	ON B.Province_Code = A5.PR_ID
	LEFT JOIN SysUtil.SFAUtility.dbo.SysCustMarket M
	ON S.MarketId = M.MarketId
	WHERE 0=0
	and B.Sales_Office = CASE WHEN @Branch  = '' THEN B.Customer_ID ELSE @Branch END
) DATA

END

