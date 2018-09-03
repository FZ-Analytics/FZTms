/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.service.run;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.Detail.runResultMapDetailController;
import com.fz.tms.params.map.GoogleDirMapAllVehi;
import com.fz.tms.params.model.Delivery;
import com.fz.tms.params.model.OptionModel;
import com.fz.tms.params.model.RouteJobLog;
import static com.fz.tms.service.run.RouteJobListing.EmpyID;
import static com.fz.tms.service.run.RouteJobListing.Key;
import com.fz.util.FZUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 *
 * @author rifki.nurfaiz
 */
public class LoadDelivery implements BusinessLogic {

    ArrayList<RouteJobLog> alRjl = new ArrayList<>();

    String oriRunId, runId, branch, shift, dateDeliv;
    //int breakTime = 0;
    boolean hasBreak = false;

    //List<List<HashMap<String, String>>> mapColor = new ArrayList<List<HashMap<String, String>>>();

    public static String EmpyID;
    public static String Key;
    
    @Override
    public void run(HttpServletRequest request, HttpServletResponse response, PageContext pc) throws Exception {
        runId = FZUtil.getHttpParam(request, "runId");
        branch = FZUtil.getHttpParam(request, "branchId");
        shift = FZUtil.getHttpParam(request, "shift");
        dateDeliv = FZUtil.getHttpParam(request, "dateDeliv");
        String channel = FZUtil.getHttpParam(request, "channel");
        String vehicle = "" + getVehicleNum(runId);
        oriRunId = FZUtil.getHttpParam(request, "oriRunId");
        //breakTime = getBreakTime(getDayByDate(dateDeliv));

        GoogleDirMapAllVehi map = new GoogleDirMapAllVehi();
        List<OptionModel> jss = new ArrayList<OptionModel>();
        //mapColor = map.runs(oriRunId, jss);

        ArrayList<Delivery> alTableData = getTableData(runId);
        request.setAttribute("branchId", branch);
        request.setAttribute("shift", shift);
        request.setAttribute("channel", channel);
        request.setAttribute("vehicle", vehicle);
        request.setAttribute("runId", runId);
        request.setAttribute("oriRunId", oriRunId);
        request.setAttribute("listDelivery", alTableData);
        
        //update login
        EmpyID = (String) pc.getSession().getAttribute("EmpyID");
        Key = (String) pc.getSession().getAttribute("Key");
        RunThread R1 = new RunThread("Thread",EmpyID,Key);
        R1.start();
    }

    public ArrayList<Delivery> getTableData(String runId) throws Exception {
        ArrayList<Delivery> alDelivery = new ArrayList<>();
        String sql = "{call bosnet1.dbo.TMS_runResultEditResultShow(?,?)}";
        System.out.println(sql + runId);
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                java.sql.CallableStatement stmt =
                con.prepareCall(sql)) {
            stmt.setString(1, runId);
            stmt.setInt(2, AlgoRunner.dy);
            try(ResultSet rs = stmt.executeQuery()){
                String prevLong = "";
                String prevLat = "";
                while (rs.next()) {
                    Delivery ld = new Delivery(); //Used in view
                    Delivery ldBreak = new Delivery(); //Used in view for break rows
                    /*
                     * Object used in view
                     */
                    ld.no = rs.getString("no");
                    ld.vehicleCode = rs.getString("vehicle_code");
                    ld.custId = rs.getString("customer_id");
                    if (hasBreak) {
                        ld.depart = addTime(rs.getString("depart"), Integer.parseInt(rs.getString("breaks")));
                        ld.arrive = addTime(rs.getString("arrive"), Integer.parseInt(rs.getString("breaks")));
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
                    ArrayList<String> al = new ArrayList<>();
                    al.add(0, rs.getString("deliv_start"));
                    al.add(1, rs.getString("deliv_end"));
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
                    try {
                        ld.dist = "" + Math.round((rs.getDouble("Dist") / 1000) * 10) / 10.0;
                    } catch (Exception e) {
                        ld.dist = "";
                    }
                    if (ld.custId.length() > 0 && !ld.vehicleCode.equals("NA")) {
                        ld.feasibleTruck = isTimeinRange(ld.arrive, rs.getString("startTime"), rs.getString("endTime"));
                        String vehicleType = rs.getString("vehicle_type");
                        String vehicleTypeList = rs.getString("vehicle_type_list");
                        if (vehicleTypeList.toLowerCase().contains(vehicleType.toLowerCase())) {
                            ld.feasibleAccess = "Yes";
                        } else {
                            ld.feasibleAccess = "No";
                        }
                        if (hasBreak) {
                            //ArrayList<String> al = getCustomerTime(runId, ld.custId);
                            ld.feasibleCustomer = isTimeinRange1(ld.arrive, al);
                        } else {
                            ld.feasibleCustomer = isTimeinRange1(ld.arrive, al);
                        }
                    } else {
                        if (ld.arrive.length() > 0) {
                            ld.feasibleTruck = isTimeinRange(ld.arrive, rs.getString("startTime"), addTime(rs.getString("endTime"), 60));
                        }
                    }
                    
                    if(!ld.vehicleCode.equals("NA")){
                        String clr = runResultMapDetailController.myList[Integer.valueOf((rs.getString("RowNumber")))-1].toUpperCase();
                        ld.color = "#" + clr;
                    }

                    if (ld.no.equals("0") && !ld.vehicleCode.equals("NA")) {
                        prevLong = rs.getString("startLon");
                        prevLat = rs.getString("startLat");
                        
                        
                    } else {
                        prevLong = ld.lon2;
                        prevLat = ld.lat2;
                    }
                    
                    //mark red
                    String mark = rs.getString("batch");
                    
                    if(mark.equalsIgnoreCase("1"))  ld.bat = "1";
                    else if(mark.equalsIgnoreCase("2"))  ld.bat = "2";
                    else ld.bat = "0";
                    
                    alDelivery.add(ld);

                    System.out.println(ld.custId + " " + ld.depart);
                    //break if depart + 60 minutes is more than 11:30
                    if (hasBreak == false && !ld.depart.equals("") && timeMoreThan(addTime(addTime(ld.arrive, Integer.parseInt(ld.serviceTime)), 60), "11:30")) {
                        System.out.println("BREAK " + ld.custId + " " + ld.depart);
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
                        ldBreak.dist = "null";

                        hasBreak = true;
                        alDelivery.add(ldBreak);
                    } else if (ld.depart.equals("")) {
                        hasBreak = false;
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

    public String getVehicleNum(String runId) throws Exception {
        String count = "";
        String sql = "select count(distinct vehicle_code) as cnt from BOSNET1.dbo.TMS_RouteJob where RunId = '" + runId + "' and vehicle_code <> 'NA'";
        try (Connection con = (new Db()).getConnection("jdbc/fztms"); PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getString("cnt");
                }
                ps.close();
            }
        }
        return count;
    }

    public int getBreakTime(String day) throws Exception {
        int breakTime = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "";
                if (day.equals("Friday")) {
                    sql = "SELECT value FROM BOSNET1.dbo.TMS_PreRouteParams WHERE param = 'fridayBreak' and RunId = (SELECT distinct OriRunId FROM BOSNET1.dbo.TMS_Progress where runID = '"+runId+"')";
                } else {
                    sql = "SELECT value FROM BOSNET1.dbo.TMS_PreRouteParams WHERE param = 'defaultBreak' and RunId = (SELECT distinct OriRunId FROM BOSNET1.dbo.TMS_Progress where runID = '"+runId+"')";
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

    public String addTime(String currentTime, long minToAdd) {
        String newTime = "";
        try {
            DateTimeFormatter df = DateTimeFormatter.ofPattern("HH:mm");
            LocalTime lt = LocalTime.parse(currentTime);
            newTime = df.format(lt.plusMinutes(minToAdd));
        } catch (Exception e) {

        }
        return newTime;
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

    public String isTimeinRange(String arrive, String startTime, String endTime) {
        String[] truckArriveSplit = arrive.split(":");
        String[] custOpenSplit = startTime.split(":");
        String[] custCloseSplit = endTime.split(":");

        int truckArriveHour = Integer.parseInt(truckArriveSplit[0]);
        int truckArriveMin = Integer.parseInt(truckArriveSplit[1]);
        int custOpenHour = Integer.parseInt(custOpenSplit[0]);
        int custCloseHour = Integer.parseInt(custCloseSplit[0]);
        int custCloseMin = Integer.parseInt(custCloseSplit[1]);

        String ret = "";
        if (custOpenHour <= truckArriveHour && truckArriveHour <= custCloseHour) {
            if (truckArriveHour == custCloseHour) {
                if (truckArriveMin < custCloseMin) {
                    ret = "Yes";
                } else {
                    ret = "No";
                }
            } else {
                ret = "Yes";
            }
        } else {
            ret = "No";
        }
        return ret;
    }

    public String isTimeinRange1(String arrive, ArrayList<String> al) {
        String[] truckArriveSplit = arrive.split(":");
        String[] custOpenSplit = al.get(0).split(":");
        String[] custCloseSplit = al.get(1).split(":");

        int truckArriveHour = Integer.parseInt(truckArriveSplit[0]);
        int truckArriveMin = Integer.parseInt(truckArriveSplit[1]);
        int custOpenHour = Integer.parseInt(custOpenSplit[0]);
        int custCloseHour = Integer.parseInt(custCloseSplit[0]);
        int custCloseMin = Integer.parseInt(custCloseSplit[1]);

        String ret = "";
        if (custOpenHour <= truckArriveHour && truckArriveHour <= custCloseHour) {
            if (truckArriveHour == custCloseHour) {
                if (truckArriveMin < custCloseMin) {
                    ret = "Yes";
                } else {
                    ret = "No";
                }
            } else {
                ret = "Yes";
            }
        } else {
            ret = "No";
        }
        return ret;
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

    /*public ArrayList<String> getCustomerTime(String runId, String custId) throws Exception {
        ArrayList<String> al = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT TOP 1 deliv_start, deliv_end FROM BOSNET1.dbo.TMS_PreRouteJob WHERE RunId = '" + runId + "' and Customer_ID = '" + custId + "';";
                // query
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        al.add(rs.getString("deliv_start"));
                        al.add(rs.getString("deliv_end"));
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return al;
    }*/
}
