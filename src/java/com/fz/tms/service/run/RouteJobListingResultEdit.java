/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.service.run;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.model.Delivery;
import com.fz.tms.params.model.OptionModel;
import com.fz.tms.params.model.PreRouteJobLog;
import com.fz.tms.params.model.PreRouteVehicleLog;
import com.fz.tms.params.map.GoogleDirMapAllVehi;
import com.fz.tms.params.model.RouteJobLog;
import com.fz.util.FZUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

public class RouteJobListingResultEdit implements BusinessLogic {

    String prevCustId = "";
    String previousCustId = "";
    String prevDepart = "";
    int breakTime = 0;
    double long1, lat1, long2, lat2;
    boolean b = true;

    ArrayList<RouteJobLog> alRjl = new ArrayList<>();
    String prevVehiCode = "";
    int routeNb = 0;
    int jobNb = 1;

    String oriRunId, runId, branch, shift, dateDeliv;

    boolean hasBreak = false;
    
    List<List<HashMap<String, String>>> mapColor = new ArrayList<List<HashMap<String, String>>>();

    @Override
    public void run(HttpServletRequest request, HttpServletResponse response, PageContext pc) throws Exception {
        oriRunId = FZUtil.getHttpParam(request, "OriRunID");
        runId = FZUtil.getHttpParam(request, "runId");
        branch = FZUtil.getHttpParam(request, "branch");
        shift = FZUtil.getHttpParam(request, "shift");
        dateDeliv = FZUtil.getHttpParam(request, "dateDeliv");
        String channel = FZUtil.getHttpParam(request, "channel");
        String vehicles = FZUtil.getHttpParam(request, "vehicles");
        String tableArr = FZUtil.getHttpParam(request, "tableArr");

        GoogleDirMapAllVehi map = new GoogleDirMapAllVehi();
        List<OptionModel> jss = new ArrayList<OptionModel>();
        mapColor = map.runs(runId, jss);
        System.out.println("SIZEEE " + mapColor);
        ArrayList<Delivery> alTableData = getTableData(oriRunId);
        
        insertToRouteJob(getListRouteJob(oriRunId, runId), runId);
        insertToPreRouteJob(getListPreRouteJob(oriRunId, runId), runId);
        insertPreRouteVehicle(getListPreRouteVehicle(oriRunId, runId), runId);

        request.setAttribute("listDelivery", alTableData);
        request.setAttribute("branch", branch);
        request.setAttribute("shift", shift);
        request.setAttribute("channel", channel);
        request.setAttribute("dateDeliv", dateDeliv);
        request.setAttribute("vehicles", vehicles);
        request.setAttribute("runId", runId);
        request.setAttribute("oriRunId", oriRunId);
        request.setAttribute("tableArr", tableArr);
    }

    public ArrayList<Delivery> getTableData(String runId) throws Exception {
        ArrayList<Delivery> alDelivery = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT\n"
                        + "    CASE WHEN rj.depart = '' THEN 0 ELSE rj.jobNb - 1 END No,\n"
                        + "    rj.vehicle_code,\n"
                        + "    rj.customer_id,\n"
                        + "    rj.arrive,\n"
                        + "    rj.depart,\n"
                        + "    CASE WHEN prj.DO_Number is null THEN '' ELSE prj.DO_number END DO_Number,\n"
                        + "    CASE WHEN rj.vehicle_code = 'NA' THEN 0 WHEN prj.Service_time is null THEN '' ELSE prj.Service_time END serviceTime,\n"
                        + "    CASE WHEN prj.Name1 is null THEN '' ELSE prj.Name1 END Name1,\n"
                        + "    CASE WHEN prj.Long is null THEN '' ELSE prj.Long END Long,\n"
                        + "    CASE WHEN prj.Lat is null THEN '' ELSE prj.Lat END Lat,\n"
                        + "    CASE WHEN prj.Customer_priority is null THEN '' ELSE prj.Customer_priority END Customer_priority,\n"
                        + "    CASE WHEN prj.Distribution_Channel is null THEN '' ELSE prj.Distribution_Channel END Distribution_Channel,\n"
                        + "    CASE WHEN prj.Street is null THEN '' ELSE prj.Street END Street,\n"
                        + "    rj.weight,\n"
                        + "    rj.volume,\n"
                        + "    prj.Request_Delivery_Date,\n"
                        + "    rj.transportCost TransportCost,\n"
                        + "    rj.Dist,\n"
                        + "    prv.startLon,\n"
                        + "    prv.startLat\n"
                        + "FROM \n"
                        + "	[BOSNET1].[dbo].[TMS_RouteJob] rj\n"
                        + "LEFT JOIN(\n"
                        + "	SELECT \n"
                        + "         *\n"
                        + "	FROM (\n"
                        + "         SELECT\n"
                        + " 		prj.customer_ID,\n"
                        + "		(SELECT\n"
                        + "                 (stuff(\n"
                        + "                     (SELECT\n"
                        + "                         '; ' + DO_Number\n"
                        + "                      FROM\n"
                        + "                         bosnet1.dbo.TMS_PreRouteJob\n"
                        + "                      WHERE\n"
                        + "                         Is_Edit = 'edit'\n"
                        + "                      AND Customer_ID = prj.Customer_ID\n"
                        + "                         AND RunId = '"+runId+"'\n"
                        + "                      GROUP BY\n"
                        + "                         DO_Number FOR xml PATH('')\n"
                        + "			),\n"
                        + "                     1,\n"
                        + "                     2,\n"
                        + "                     ''\n"
                        + "                     )\n"
                        + "                 )\n"
                        + "             ) AS DO_number,\n"
                        + "             prj.Service_time,\n"
                        + "             prj.RunId,\n"
                        + "             prj.Name1,\n"
                        + "             prj.Long,\n"
                        + "             prj.Lat,\n"
                        + "             prj.Customer_priority,\n"
                        + "             prj.Distribution_Channel,\n"
                        + "             prj.Street,\n"
                        + "             prj.Request_Delivery_Date,\n"
                        + "             ROW_NUMBER() OVER(PARTITION BY prj.customer_ID ORDER BY prj.Name1 DESC) rn\n"
                        + "         FROM \n"
                        + "             [BOSNET1].[dbo].[TMS_PreRouteJob] prj\n"
                        + "         WHERE \n"
                        + "             Is_Edit = 'edit' AND RunId = '"+runId+"'\n"
                        + "         ) a\n"
                        + "     WHERE\n"
                        + "         rn = 1"
                        + ") prj ON rj.runID = prj.RunId and rj.customer_id = prj.Customer_ID\n"
                        + "LEFT JOIN(\n"
                        + "	SELECT\n"
                        + "		prv.vehicle_code,\n"
                        + "		prv.startLon,\n"
                        + "		prv.startLat\n"
                        + "	FROM\n"
                        + "		[BOSNET1].[dbo].[TMS_PreRouteVehicle] prv\n"
                        + "	WHERE\n"
                        + "		prv.RunId = '" + runId + "'\n"
                        + ") prv ON prv.vehicle_code = rj.vehicle_code and rj.customer_id = ''\n"
                        + "WHERE \n"
                        + "	rj.runID = '" + runId + "'\n"
                        + "ORDER BY\n"
                        + "	rj.routeNb, rj.jobNb";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    String prevLong = "";
                    String prevLat = "";
                    while (rs.next()) {
                        Delivery ld = new Delivery(); //Used in view
                        /*
                         * Object used in view
                         */
                        ld.no = rs.getString("no");
                        ld.vehicleCode = rs.getString("vehicle_code");
                        ld.custId = rs.getString("customer_id");
                        if (hasBreak) {
                            ld.depart = addTime(rs.getString("depart"), breakTime);
                            ld.arrive = addTime(rs.getString("arrive"), breakTime);
                        } else {
                            ld.depart = rs.getString("depart");
                            ld.arrive = rs.getString("arrive");
                        }
                        ld.doNum = rs.getString("DO_Number");
                        ld.serviceTime = rs.getString("serviceTime");
                        ld.storeName = rs.getString("Name1");
                        ld.lon1 = prevLong;
                        ld.lat1 = prevLat;
                        ld.lon2 = rs.getString("Long");
                        ld.lat2 = rs.getString("Lat");
                        ld.priority = rs.getString("Customer_priority");
                        ld.distChannel = rs.getString("Distribution_Channel");
                        ld.street = rs.getString("Street");
                        try {
                            ld.weight = "" + Math.round((rs.getDouble("weight")) * 10) / 10.0;
                        } catch (Exception e) {
                            ld.weight = "";
                        }
                        try {
                            ld.volume = "" + Math.round((rs.getDouble("volume") / 1000000) * 10) / 10.0;
                        } catch (Exception e) {
                            ld.volume = "";
                        }
                        ld.rdd = rs.getString("Request_Delivery_Date");
                        ld.transportCost = rs.getInt("TransportCost");
                        ld.dist = "" + Math.round((rs.getDouble("Dist") / 1000) * 10) / 10.0;
                        ld.isOkay = isOkay(ld.doNum, runId);

                        alDelivery.add(ld);

                        if (ld.no.equals("0") && !ld.vehicleCode.equals("NA")) {
                            prevLong = rs.getString("startLon");
                            prevLat = rs.getString("startLat");
                        } else {
                            prevLong = ld.lon2;
                            prevLat = ld.lat2;
                        }

                        //break if depart + 60 minutes is more than 11:30
                        if (hasBreak == false && !ld.depart.equals("") && timeMoreThan(addTime(addTime(ld.arrive, Integer.parseInt(ld.serviceTime)), 60), "11:30")) {
                            Delivery ldBreak = new Delivery();
                            ldBreak.no = "";
                            ldBreak.vehicleCode = "";
                            ldBreak.custId = "";
                            ldBreak.doNum = "";
                            ldBreak.serviceTime = "0";
                            ldBreak.storeName = "";
                            ldBreak.priority = "";
                            ldBreak.distChannel = "";
                            ldBreak.street = "";
                            ldBreak.weight = "";
                            ldBreak.volume = "";
                            ldBreak.rdd = null;
                            ldBreak.transportCost = 0;
                            ldBreak.dist = "0";

                            hasBreak = true;
                            breakTime = getBreakTime(getDayByDate(dateDeliv));
                            alDelivery.add(ldBreak);
                        } else if (ld.depart.equals("")) {
                            hasBreak = false;
                        }
                        
                        if(!ld.vehicleCode.equalsIgnoreCase("NA")) {
                            System.out.println("IN " + mapColor.size());
                            for(int i = 0; i < mapColor.size(); i++) {
                                System.out.println("MAP SIZE: " + mapColor.get(i).size());
                                for(int os = 0; os < mapColor.get(i).size(); os++){
                                    if(mapColor.get(i).get(os).get("description").contains(ld.vehicleCode)){
                                        ld.color = "#"+mapColor.get(i).get(os).get("color").toUpperCase();
                                        System.out.println(ld.color);
                                    }
                                }                            
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return alDelivery;
    }

    public int countDoNo(String doNum) {
        String[] doSplit = doNum.split("; ");
        return doSplit.length;
    }

    public String getDayByDate(String dates) throws ParseException {
        String[] dateParse = dates.split("-");

        int year = Integer.parseInt(dateParse[0]);
        int month = Integer.parseInt(dateParse[1]);
        int day = Integer.parseInt(dateParse[2]);

        // First convert to Date. This is one of the many ways.
        String dateString = String.format("%d-%d-%d", year, month, day);
        Date date = new SimpleDateFormat("yyyy-M-d").parse(dateString);

        // Then get the day of week from the Date based on specific locale.
        String dayOfWeek = new SimpleDateFormat("EEEE", Locale.ENGLISH).format(date);

        return dayOfWeek;
    }

    public String addTime(String currentTime, double minToAdd) {
        String newTime = "";
        try {
            DateTimeFormatter df = DateTimeFormatter.ofPattern("HH:mm");
            LocalTime lt = LocalTime.parse(currentTime);
            newTime = df.format(lt.plusMinutes((int) minToAdd));
        } catch (Exception e) {

        }
        return newTime;
    }

    public boolean timeMoreThan(String currentTime, String comparedTime) {
        boolean moreThan = false;
        try {
            String[] currentTimeSplit = currentTime.split(":");
            String[] comparedTimeSplit = comparedTime.split(":");
            //Compare hour
            if (Integer.parseInt(currentTimeSplit[0]) > Integer.parseInt(comparedTimeSplit[0])) {
                moreThan = true;
            } //If hour is same than compare minutes
            else if (Integer.parseInt(currentTimeSplit[0]) == Integer.parseInt(comparedTimeSplit[0])) {
                if (Integer.parseInt(currentTimeSplit[1]) > Integer.parseInt(comparedTimeSplit[1])) {
                    moreThan = true;
                }
            }

        } catch (Exception e) {

        }
        return moreThan;
    }

    public boolean isOkay(String doNum, String runId) throws Exception {
        boolean isOkay = true;
        String errorStatus = "";
        String[] doNumSplit = doNum.split(";");
        for (int i = 0; i < doNumSplit.length; i++) {
            try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
                try (Statement stm = con.createStatement()) {
                    String sql = "";
                    sql = "SELECT\n"
                            + "	prj.DO_Number do,\n"
                            + "	table1.sp,\n"
                            + "	table1.ss,\n"
                            + "	table1.rs\n"
                            + "FROM\n"
                            + "	[BOSNET1].[dbo].[TMS_PreRouteJob] prj\n"
                            + "FULL JOIN(\n"
                            + "	SELECT\n"
                            + "		sp.DO_Number sp,\n"
                            + "		ss.Delivery_Number ss,\n"
                            + "		rs.Delivery_Number rs\n"
                            + "	FROM\n"
                            + "		[BOSNET1].[dbo].[TMS_ShipmentPlan] sp\n"
                            + "	LEFT JOIN(\n"
                            + "		SELECT\n"
                            + "			ss.Delivery_Number\n"
                            + "		FROM \n"
                            + "			[BOSNET1].[dbo].[TMS_Status_Shipment] ss\n"
                            + "		WHERE\n"
                            + "			ss.Delivery_Number = '"+doNumSplit[i]+"'\n"
                            + "	) ss ON ss.Delivery_Number = sp.DO_Number\n"
                            + "	LEFT JOIN(\n"
                            + "		SELECT\n"
                            + "			rs.Delivery_Number\n"
                            + "		FROM \n"
                            + "			[BOSNET1].[dbo].[TMS_Result_Shipment] rs\n"
                            + "		WHERE\n"
                            + "			rs.Delivery_Number = '"+doNumSplit[i]+"'\n"
                            + "	) rs ON rs.Delivery_Number = sp.DO_Number\n"
                            + "	WHERE\n"
                            + "		sp.DO_Number = '"+doNumSplit[i]+"'\n"
                            + "		AND (sp.Already_Shipment <> 'Y'\n"
                            + "		AND sp.Batch <> 'NULL'\n"
                            + "		AND sp.NotUsed_Flag is NULL\n"
                            + "		AND sp.Incoterm = 'FCO'\n"
                            + "		AND(\n"
                            + "			sp.Order_Type = 'ZDCO' OR sp.Order_Type = 'ZDTO'\n"
                            + "		)\n"
                            + "		AND sp.create_date >= DATEADD (DAY, - 7, GETDATE()))\n"
                            + ") table1 ON table1.sp = prj.DO_Number\n"
                            + "WHERE \n"
                            + "	prj.DO_Number = '"+doNumSplit[i]+"'\n"
                            + "	AND prj.runID = '"+runId+"'\n"
                            + "	AND prj.Is_Edit = 'edit'";
                    try (ResultSet rs = stm.executeQuery(sql)) {
                        while (rs.next()) {
                            if (rs.getString("sp") == null) {
                                errorStatus = "sp";
                                isOkay = false;
                                break;
                            }
                            if (rs.getString("ss") != null) {
                                errorStatus = "ss";
                                isOkay = false;
                                break;
                            }
                            if (rs.getString("rs") != null) {
                                errorStatus = "rs";
                                isOkay = false;
                                break;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                throw new Exception(e.getMessage());
            }
        }
        return isOkay;
    }

    public int getBreakTime(String day) throws Exception {
        int breakTime = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "";
                if (day.equals("Friday")) {
                    sql = "SELECT value FROM BOSNET1.dbo.TMS_Params WHERE param = 'fridayBreak'";
                } else {
                    sql = "SELECT value FROM BOSNET1.dbo.TMS_Params WHERE param = 'defaultBreak'";
                }
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        breakTime = rs.getInt("value");
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return breakTime;
    }

    public static Timestamp getTimeStamp() throws ParseException {
        String timeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(Calendar.getInstance().getTime());
        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        Date date = (Date) formatter.parse(timeStamp);
        java.sql.Timestamp timeStampDate = new Timestamp(date.getTime());

        return timeStampDate;
    }
    
    public ArrayList<PreRouteJobLog> getListPreRouteJob(String oriRunId, String runId) throws Exception {
        ArrayList<PreRouteJobLog> arlistPrj = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT RunId, Customer_ID, DO_Number, Long, Lat, Customer_priority, Service_time, deliv_start, deliv_end, vehicle_type_list, total_kg, "
                        + "total_cubication, DeliveryDeadline, DayWinStart, DayWinEnd, UpdatevDate, CreateDate, isActive, Is_Exclude, Is_edit, Product_Description, "
                        + "Gross_Amount, DOQty, DOQtyUOM, Name1, Street, Distribution_Channel, Customer_Order_Block_all, Customer_Order_Block, Request_delivery_date, MarketId "
                        + "FROM BOSNET1.dbo.TMS_PreRouteJob "
                        + "WHERE RunId = '" + oriRunId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        PreRouteJobLog p = new PreRouteJobLog();
                        p.runId = runId;
                        p.custId = rs.getString("Customer_ID");
                        p.doNum = rs.getString("DO_Number");
                        p.lon = rs.getString("Long");
                        p.lat = rs.getString("Lat");
                        p.custPriority = rs.getString("Customer_priority");
                        p.serviceTime = rs.getInt("Service_time");
                        p.delivStart = rs.getString("deliv_start");
                        p.delivEnd = rs.getString("deliv_end");
                        p.vehicleTypeList = rs.getString("vehicle_type_list");
                        p.totalKg = rs.getDouble("total_kg");
                        p.totalCubication = rs.getDouble("total_cubication");
                        p.deliveryDeadline = rs.getString("DeliveryDeadline");
                        p.dayWinStart = rs.getString("DayWinStart");
                        p.dayWinEnd = rs.getString("DayWinEnd");
                        p.updatevDate = rs.getString("UpdatevDate");
                        p.createDate = rs.getString("CreateDate");
                        p.isActive = rs.getString("isActive");
                        p.isExclude = rs.getString("Is_Exclude");
                        p.isEdit = rs.getString("Is_edit");
                        p.productDescription = rs.getString("Product_Description");
                        p.grossAmount = rs.getDouble("Gross_Amount");
                        p.doQty = rs.getDouble("DOQty");
                        p.doQtyUom = rs.getString("DOQtyUOM");
                        p.name1 = rs.getString("Name1");
                        p.street = rs.getString("Street");
                        p.distChannel = rs.getString("Distribution_Channel");
                        p.custOrderBlockAll = rs.getString("Customer_Order_Block_all");
                        p.custOrderBlock = rs.getString("Customer_Order_Block");
                        p.rdd = rs.getString("Request_delivery_date");
                        p.marketId = rs.getString("MarketId");
                        arlistPrj.add(p);
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return arlistPrj;
    }

    public ArrayList<PreRouteVehicleLog> getListPreRouteVehicle(String oriRunId, String runId) throws Exception {
        ArrayList<PreRouteVehicleLog> arlistPrv = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT vehicle_code, weight, volume, vehicle_type, branch, startLon, startLat, endLon, endLat, startTime, endTime, source1, UpdatevDate, "
                        + "CreateDate, isActive, fixedCost, costPerM, costPerServiceMin, costPerTravelMin, IdDriver, NamaDriver "
                        + "FROM BOSNET1.dbo.TMS_PreRouteVehicle "
                        + "WHERE RunId = '" + oriRunId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        PreRouteVehicleLog p = new PreRouteVehicleLog();
                        p.runId = runId;
                        p.vehicleCode = rs.getString("vehicle_code");
                        p.weight = rs.getString("weight");
                        p.volume = rs.getString("volume");
                        p.vehicleType = rs.getString("vehicle_type");
                        p.branch = rs.getString("branch");
                        p.startLon = rs.getString("startLon");
                        p.startLat = rs.getString("startLat");
                        p.endLon = rs.getString("endLon");
                        p.endLat = rs.getString("endLat");
                        p.startTime = rs.getString("startTime");
                        p.endTime = rs.getString("endTime");
                        p.source1 = rs.getString("source1");
                        p.updatevDate = rs.getString("UpdatevDate");
                        p.createDate = rs.getString("CreateDate");
                        p.isActive = rs.getString("isActive");
                        p.fixedCost = rs.getDouble("fixedCost");
                        p.costPerM = rs.getDouble("costPerM");
                        p.costPerminService = rs.getDouble("costPerServiceMin");
                        p.costPerTravelMin = rs.getDouble("costPerTravelMin");
                        p.IdDriver = rs.getString("IdDriver");
                        p.NamaDriver = rs.getString("NamaDriver");

                        arlistPrv.add(p);
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return arlistPrv;
    }
    
    public ArrayList<RouteJobLog> getListRouteJob(String oriRunId, String runId) throws Exception {
        ArrayList<RouteJobLog> arlistRj = new ArrayList<>();
        Timestamp createTime = getTimeStamp();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT job_id, customer_id, do_number, vehicle_code, activity, routeNb, jobNb, arrive, depart, runID, create_dtm, branch, shift, "
                        + "lon, lat, weight, volume, transportCost, activityCost, Dist, isFix "
                        + "FROM BOSNET1.dbo.TMS_RouteJob "
                        + "WHERE RunId = '" + oriRunId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        RouteJobLog p = new RouteJobLog();
                        p.jobId = rs.getString("job_id");
                        p.custId = rs.getString("customer_id");
                        p.countDoNo = rs.getString("do_number");
                        p.vehicleCode = rs.getString("vehicle_code");
                        p.activity = rs.getString("activity");
                        p.routeNb = rs.getInt("routeNb");
                        p.jobNb = rs.getInt("jobNb");
                        p.arrive = rs.getString("arrive");
                        p.depart = rs.getString("depart");
                        p.runId = runId;
                        p.createTime = createTime;
                        p.branch = rs.getString("branch");
                        p.shift = rs.getString("shift");
                        p.lon = rs.getString("lon");
                        p.lat = rs.getString("lat");
                        p.weight = rs.getString("weight");
                        p.volume = rs.getString("volume");
                        p.transportCost = rs.getInt("transportCost");
                        p.activityCost = rs.getDouble("activityCost");
                        p.dist = rs.getDouble("Dist");
                        p.isFix = rs.getString("isFix");

                        arlistRj.add(p);
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return arlistRj;
    }

    public void insertPreRouteVehicle(ArrayList<PreRouteVehicleLog> arlist, String runId) throws Exception {
        int rowNum = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT COUNT(*) total FROM bosnet1.dbo.TMS_PreRouteVehicle WHERE runID = '" + runId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        rowNum = rs.getInt("total");
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        if (rowNum == 0) {
            String sql = "INSERT INTO bosnet1.dbo.TMS_PreRouteVehicle "
                    + "(RunId, vehicle_code, weight, volume, vehicle_type, branch, startLon, startLat, endLon, endLat, startTime, "
                    + "endTime, source1, UpdatevDate, CreateDate, isActive, fixedCost, costPerM, costPerServiceMin, costPerTravelMin, IdDriver, NamaDriver) "
                    + "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";

            for (int i = 0; i < arlist.size(); i++) {
                PreRouteVehicleLog p = arlist.get(i);
                try (Connection con = (new Db()).getConnection("jdbc/fztms"); PreparedStatement psHdr = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);) {
                    psHdr.setString(1, p.runId);
                    psHdr.setString(2, p.vehicleCode);
                    psHdr.setString(3, p.weight);
                    psHdr.setString(4, p.volume);
                    psHdr.setString(5, p.vehicleType);
                    psHdr.setString(6, p.branch);
                    psHdr.setString(7, p.startLon);
                    psHdr.setString(8, p.startLat);
                    psHdr.setString(9, p.endLon);
                    psHdr.setString(10, p.endLat);
                    psHdr.setString(11, p.startTime);
                    psHdr.setString(12, p.endTime);
                    psHdr.setString(13, p.source1);
                    psHdr.setString(14, p.updatevDate);
                    psHdr.setString(15, p.createDate);
                    psHdr.setString(16, p.isActive);
                    psHdr.setDouble(17, p.fixedCost);
                    psHdr.setDouble(18, p.costPerM);
                    psHdr.setDouble(19, p.costPerminService);
                    psHdr.setDouble(20, p.costPerTravelMin);
                    psHdr.setString(21, p.IdDriver);
                    psHdr.setString(22, p.NamaDriver);

                    psHdr.executeUpdate();
                }
            }
        }
    }

    public void insertToRouteJob(ArrayList<RouteJobLog> arlist, String runId) throws Exception {
        Timestamp createTime = getTimeStamp();
        int rowNum = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT COUNT(*) total FROM bosnet1.dbo.TMS_RouteJob WHERE runID = '" + runId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        rowNum = rs.getInt("total");
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        if (rowNum == 0) {
            String sql = "INSERT INTO bosnet1.dbo.TMS_RouteJob "
                    + "(job_id, customer_id, do_number, vehicle_code, activity, routeNb, jobNb, arrive, depart, runID, create_dtm, branch, shift, lon, lat, weight, volume, transportCost, activityCost, Dist) "
                    + " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";

            for (int i = 0; i < arlist.size(); i++) {
                RouteJobLog r = arlist.get(i);
                try (Connection con = (new Db()).getConnection("jdbc/fztms"); PreparedStatement psHdr = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);) {
                    psHdr.setString(1, r.jobId);
                    psHdr.setString(2, r.custId);
                    psHdr.setString(3, r.countDoNo);
                    psHdr.setString(4, r.vehicleCode);
                    psHdr.setString(5, r.activity);
                    psHdr.setInt(6, r.routeNb);
                    psHdr.setInt(7, r.jobNb);
                    psHdr.setString(8, r.arrive);
                    psHdr.setString(9, r.depart);
                    psHdr.setString(10, r.runId);
                    psHdr.setTimestamp(11, createTime);
                    psHdr.setString(12, r.branch);
                    psHdr.setString(13, r.shift);
                    psHdr.setString(14, r.lon);
                    psHdr.setString(15, r.lat);
                    psHdr.setString(16, r.weight);
                    psHdr.setString(17, r.volume);
                    psHdr.setDouble(18, r.transportCost);
                    psHdr.setDouble(19, r.activityCost);
                    psHdr.setDouble(20, r.dist);

                    psHdr.executeUpdate();
                }
            }
        }
    }

    public void insertToPreRouteJob(ArrayList<PreRouteJobLog> arlist, String runId) throws Exception {
        int rowNum = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT COUNT(*) total FROM bosnet1.dbo.TMS_PreRouteJob WHERE runID = '" + runId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        rowNum = rs.getInt("total");
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        if (rowNum == 0) {
            String sql = "INSERT INTO bosnet1.dbo.TMS_PreRouteJob "
                    + "(RunId, Customer_ID, DO_Number, Long, Lat, Customer_priority, Service_time, deliv_start, deliv_end, vehicle_type_list, total_kg, "
                    + "total_cubication, DeliveryDeadline, DayWinStart, DayWinEnd, UpdatevDate, CreateDate, isActive, Is_Exclude, Is_Edit, Product_Description, "
                    + "Gross_Amount, DOQTY, DOQTYUOM, Name1, Street, Distribution_Channel, Customer_Order_Block_All, Customer_Order_Block, Request_Delivery_Date, MarketId) "
                    + " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";

            for (int i = 0; i < arlist.size(); i++) {
                PreRouteJobLog p = arlist.get(i);
                try (Connection con = (new Db()).getConnection("jdbc/fztms"); PreparedStatement psHdr = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);) {
                    psHdr.setString(1, p.runId);
                    psHdr.setString(2, p.custId);
                    psHdr.setString(3, p.doNum);
                    psHdr.setString(4, p.lon);
                    psHdr.setString(5, p.lat);
                    psHdr.setString(6, p.custPriority);
                    psHdr.setInt(7, p.serviceTime);
                    psHdr.setString(8, p.delivStart);
                    psHdr.setString(9, p.delivEnd);
                    psHdr.setString(10, p.vehicleTypeList);
                    psHdr.setDouble(11, p.totalKg);
                    psHdr.setDouble(12, p.totalCubication);
                    psHdr.setString(13, p.deliveryDeadline);
                    psHdr.setString(14, p.dayWinStart);
                    psHdr.setString(15, p.dayWinEnd);
                    psHdr.setString(16, p.updatevDate);
                    psHdr.setString(17, p.createDate);
                    psHdr.setString(18, p.isActive);
                    psHdr.setString(19, p.isExclude);
                    psHdr.setString(20, p.isEdit);
                    psHdr.setString(21, p.productDescription);
                    psHdr.setDouble(22, p.grossAmount);
                    psHdr.setDouble(23, p.doQty);
                    psHdr.setString(24, p.doQtyUom);
                    psHdr.setString(25, p.name1);
                    psHdr.setString(26, p.street);
                    psHdr.setString(27, p.distChannel);
                    psHdr.setString(28, p.custOrderBlockAll);
                    psHdr.setString(29, p.custOrderBlock);
                    psHdr.setString(30, p.rdd);
                    psHdr.setString(31, p.marketId);

                    psHdr.executeUpdate();
                }
            }
        }
    }
}
