/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.service.run;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.Detail.runResultMapDetailController;
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

    //List<List<HashMap<String, String>>> mapColor = new ArrayList<List<HashMap<String, String>>>();

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
        //breakTime = getBreakTime(getDayByDate(dateDeliv));

        GoogleDirMapAllVehi map = new GoogleDirMapAllVehi();
        //List<OptionModel> jss = new ArrayList<OptionModel>();
        //mapColor = map.runs(oriRunId, jss);
        ArrayList<Delivery> alTableData = getTableData(runId, oriRunId);

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

    public ArrayList<Delivery> getTableData(String runId, String oriRunId) throws Exception {
        ArrayList<Delivery> alDelivery = new ArrayList<>();
        String sql = "{call bosnet1.dbo.TMS_RouteJobListingResultEditShow(?,?,?)}";
        System.out.println("sql "+sql);
        System.out.println("runId()" + runId);
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                java.sql.CallableStatement stmt =
                con.prepareCall(sql)) {
            stmt.setString(1, runId);
            stmt.setString(2, oriRunId);
            stmt.setInt(3, AlgoRunner.dy);
            try(ResultSet rs = stmt.executeQuery()){
                    //String prevLong = "";
                    //String prevLat = "";
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
                    //ld.lon1 = prevLong;
                    //ld.lat1 = prevLat;
                    //ld.lon2 = rs.getString("Long");
                    //ld.lat2 = rs.getString("Lat");
                    ld.priority = rs.getString("Customer_priority");
                    ld.distChannel = rs.getString("Distribution_Channel");
                    ld.street = rs.getString("Street");
                    ld.kecamatan = rs.getString("Kecamatan");
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
                    if(ld.doNum.length() > 0) {
                        ld.isOkay = rs.getString("bat").equalsIgnoreCase("0") ? true : false;//isOkay(ld.doNum, runId);
                    }
                    
                    String mark = rs.getString("bat");
                    
                    if(mark.equalsIgnoreCase("1"))  ld.bat = "1";
                    else if(mark.equalsIgnoreCase("2"))  ld.bat = "2";
                    else ld.bat = "0";

                    alDelivery.add(ld);

                    if(!ld.vehicleCode.equals("NA")){
                        String clr = runResultMapDetailController.myList[Integer.valueOf((rs.getString("RowNumber")))-1].toUpperCase();
                        ld.color = "#" + clr;
                    }
                    if (ld.no.equals("0") && !ld.vehicleCode.equals("NA")) {
                        //prevLong = rs.getString("startLon");
                        //prevLat = rs.getString("startLat");                        
                    } else {
                        //prevLong = ld.lon2;
                        //prevLat = ld.lat2;
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

    public static Timestamp getTimeStamp() throws ParseException {
        String timeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(Calendar.getInstance().getTime());
        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        Date date = (Date) formatter.parse(timeStamp);
        java.sql.Timestamp timeStampDate = new Timestamp(date.getTime());

        return timeStampDate;
    }

}