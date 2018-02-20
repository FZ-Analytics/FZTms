CREATE TABLE BOSNET1.dbo.TMS_Result_Shipment (
	Shipment_Type varchar(4),
	Plant varchar(4),
	Shipping_Type varchar(2),
	Shipment_Route varchar(6),
	Shipment_Number_Dummy varchar(30) NOT NULL,
	Description varchar(20),
	Status_Plan datetime,
	Status_Check_In datetime,
	Status_Load_Start datetime,
	Status_Load_End datetime,
	Status_Complete datetime,
	Status_Shipment_Start datetime,
	Status_Shipment_End datetime,
	Service_Agent_Id varchar(10),
	No_Pol varchar(20),
	Driver_Name varchar(30),
	Delivery_Number varchar(10) NOT NULL,
	Delivery_Item varchar(6) NOT NULL,
	Delivery_Quantity_Split decimal(17,3),
	Delivery_Quantity decimal(17,3),
	Delivery_Flag_Split varchar(1),
	Material varchar(18),
	Batch varchar(10),
	Vehicle_Number varchar(18),
	Vehicle_Type varchar(4),
	Time_Stamp datetime,
	Shipment_Number_SAP varchar(20),
	I_Status varchar(1),
	Shipment_Flag varchar(1),
	Distance decimal(18,0),
	Distance_Unit varchar(3),
	CONSTRAINT PK_TMS_Result_Shipment PRIMARY KEY (Shipment_Number_Dummy,Delivery_Number,Delivery_Item)
) ;
