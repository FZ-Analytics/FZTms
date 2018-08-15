/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.ffbv3.api.TMS;

import com.fz.generic.Db;
import com.fz.tms.params.model.RouteJobLog;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.UnsupportedEncodingException;
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
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.Consumes;
import javax.ws.rs.Produces;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PUT;
import javax.ws.rs.core.MediaType;

/**
 * REST Web Service
 *
 * @author Administrator
 */
@Path("submitEditRouteJob")
public class SubmitEditRouteJob {

    String prevDepart = "";
    String prevLon = "";
    String prevLat = "";
    int prevRouteNb = 0;
    int prevJobNb = 1;
    double long1, lat1, long2, lat2;

    ArrayList<RouteJobLog> arlistR = new ArrayList<>();

    String oriRunId, runId, branch, shift, dateDeliv;

    double speedTruck, trafficFactor;

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of SubmitEditRouteJob
     */
    public SubmitEditRouteJob() {
    }

    /**
     * Retrieves representation of an instance of
     * com.fz.ffbv3.api.TMS.SubmitEditRouteJob
     *
     * @return an instance of java.lang.String
     */
    @GET
    @Produces(MediaType.APPLICATION_XML)
    public String getXml() {
        //TODO return proper representation object
        throw new UnsupportedOperationException();
    }

    /**
     * PUT method for updating or creating an instance of SubmitEditRouteJob
     *
     * @param content representation for the resource
     */
    @PUT
    @Consumes(MediaType.APPLICATION_XML)
    public void putXml(String content) {
    }

    @POST
    @Path("submitEditRouteJob")
    @Produces(MediaType.APPLICATION_JSON)
    public String submitEditRouteJob(String content) throws Exception {        

        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String ret = "OK";
        try {
            String[] tableArrSplit = decodeContent(content);
            
            /*String strs = "";
            int x = 0;
            for(int a=0; a<tableArrSplit.length-1;a++){
                if(!tableArrSplit[a].equalsIgnoreCase(",,")){
                    strs += a>0? "|" : "";
                    String aw = tableArrSplit[a];
                    String aq = String.valueOf(aw.charAt(0));
                    aw = aw.substring(aw.length()-1).equalsIgnoreCase(",") ?
                            aw + "end" : aw;
                    strs += aq.equalsIgnoreCase(",") ?
                            x+++","+aw.substring(1) : x+++","+aw;
                }                
            }
            System.out.println(strs);*/
            
            getRunIdAndOriRunId(tableArrSplit[tableArrSplit.length - 1]);
            
            ArrayList<Double> alParam = getParam(runId);
            speedTruck = alParam.get(0);
            trafficFactor = alParam.get(1);
            /*for (int i = 0; i < tableArrSplit.length - 1; i++) {
                String str = tableArrSplit[i];
                String data = str;
                if (i != 0) {
                    data = str.substring(0, 0) + str.substring(0 + 1);
                }
                String[] dataSplit = data.split(",");
                if (dataSplit.length == 2) {
                    //truck go from DEPO or from other customer
                    setDataRow(dataSplit[0], dataSplit[1], runId);
                } else if (dataSplit.length == 1) {
                    //truck back to DEPO row
                    setDataRow(dataSplit[0], "end", runId);
                }
            }*/
            ArrayList<RouteJobLog> arr = changeRouteJob(tableArrSplit, speedTruck, trafficFactor, runId);
            updateRouteJob(arr, runId);
        } catch (Exception e) {
            System.out.println("ERROR" + e.getLocalizedMessage());
            ret = "ERROR";
        }
        String jsonOutput = gson.toJson(ret);
        return jsonOutput;
    }
    
    public ArrayList<RouteJobLog> changeRouteJob(String[] tableArrSplit, double speedTruck, double trafficFactor, String runId) throws Exception{
        ArrayList<RouteJobLog> arlistR = new ArrayList<>();
        ArrayList<RouteJobLog> arr = new ArrayList<>();
        
        String sql = "SELECT\n" +
                "	routeNb,\n" +
                "	jobNb,\n" +
                "	rj.job_id,\n" +
                "	rj.customer_id,\n" +
                "	rj.do_number,\n" +
                "	rj.vehicle_code,\n" +
                "	rj.activity,\n" +
                "	rj.branch,\n" +
                "	rj.shift,\n" +
                "	rj.weight,\n" +
                "	rj.volume,\n" +
                "	CASE\n" +
                "		WHEN job_id = 'DEPO' THEN rv.startLon\n" +
                "		ELSE rj.Lon\n" +
                "	END lon,\n" +
                "	CASE\n" +
                "		WHEN job_id = 'DEPO' THEN rv.endLat\n" +
                "		ELSE rj.Lat\n" +
                "	END lat,\n" +
                "	CASE\n" +
                "		WHEN job_id = 'DEPO' THEN rv.startTime\n" +
                "		ELSE prj.deliv_start\n" +
                "	END START,\n" +
                "	CASE\n" +
                "		WHEN job_id = 'DEPO' THEN rv.endTime\n" +
                "		ELSE prj.deliv_end\n" +
                "	END [end],\n" +
                "	prj.Service_time,\n" +
                "	rv.costPerM,\n" +
                "	rv.fixedCost,\n" +
                "	tp.DelivDate\n" +
                "FROM\n" +
                "	BOSNET1.dbo.TMS_RouteJob rj\n" +
                "LEFT OUTER JOIN(\n" +
                "		SELECT\n" +
                "			DISTINCT RunId,\n" +
                "			customer_id,\n" +
                "			long,\n" +
                "			lat,\n" +
                "			deliv_start,\n" +
                "			deliv_end,\n" +
                "			Service_time\n" +
                "		FROM\n" +
                "			BOSNET1.dbo.TMS_PreRouteJob\n" +
                "		WHERE\n" +
                "			isActive = 1\n" +
                "			AND Is_Edit = 'edit'\n" +
                "			AND Is_Exclude = 'inc'\n" +
                "	) prj ON\n" +
                "	rj.runID = prj.RunId\n" +
                "	AND rj.job_id = prj.Customer_ID\n" +
                "LEFT OUTER JOIN BOSNET1.dbo.TMS_PreRouteVehicle rv ON\n" +
                "	rj. runID = rv.RunId\n" +
                "	AND rj.vehicle_code = rv.vehicle_code\n" +
                "	AND rv.isActive = 1\n" +
                "INNER JOIN BOSNET1.dbo.TMS_Progress tp ON \n" +
                "	tp.runID = '"+runId+"'\n" +
                "	AND rj.runID = tp.Re_RunId\n" +
                "ORDER BY\n" +
                "	routeNb,\n" +
                "	jobNb";
        
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                Statement stm = con.createStatement()) {
            try (ResultSet rs = stm.executeQuery(sql)) {
                while (rs.next()) {
                    RouteJobLog r = new RouteJobLog();
                    r.jobId = rs.getString("job_id");
                    r.custId = rs.getString("customer_id");
                    r.countDoNo = rs.getString("do_number");
                    r.vehicleCode = rs.getString("vehicle_code");
                    r.activity = rs.getString("activity");
                    r.branch = rs.getString("branch");
                    r.shift = rs.getString("shift");
                    r.weight = rs.getString("weight");
                    r.volume = rs.getString("volume");
                    r.lon = rs.getString("lon");
                    r.lat = rs.getString("lat");
                    r.start = rs.getString("start");
                    r.end = rs.getString("end");
                    r.servicetime = rs.getString("Service_time");
                    r.costPerM = rs.getDouble("costPerM");
                    r.activityCost = rs.getDouble("fixedCost");
                    arlistR.add(r);
                }
            }
        }
        
        int minutes = 0;
        int routeNb = 0;
        int jobNb = 0;
        String vehi = "";
        String prevLon = " ";
        String prevLat = " ";
        
        for (int i = 0; i < tableArrSplit.length - 1; i++) {
            RouteJobLog s = new RouteJobLog();            
            
            String str = tableArrSplit[i];
            str = String.valueOf(tableArrSplit[i].charAt(0)).equalsIgnoreCase(",") ? 
                    str.substring(1) : str;
            String[] dataSplit = str.split(",");
            
            String yu = "";
            String data = "";
            
            if(dataSplit.length > 0){                
                if(dataSplit.length == 2){
                    if(dataSplit[1].equalsIgnoreCase("5810029995")){
                        System.out.println("com.fz.ffbv3.api.TMS.SubmitEditRouteJob.changeRouteJob()");
                    }
                    if(dataSplit[1].equalsIgnoreCase("start")){
                        //start            
                        yu = "vehi";
                        routeNb += 1;
                        jobNb = 1;
                        data = dataSplit[0];
                    }else if(dataSplit[0].length() > 0
                            && dataSplit[1].length() > 0){
                        if(dataSplit[0].equalsIgnoreCase("NA")){
                            yu = "NA";
                            routeNb = 0;
                            jobNb = 0;
                        }else{
                            //cust
                            yu = "cust";
                            jobNb += 1;
                        }
                        data = dataSplit[1];
                        
                    }
                }else if(dataSplit.length == 1){
                    //end
                    yu = "vehi";
                    jobNb += 1;               
                    data = dataSplit[0];
                }                

                s = loopRouteJobLog(runId, arlistR, data, yu, minutes, 
                        routeNb, jobNb, dataSplit[0], prevLon, prevLat,
                        speedTruck, trafficFactor);

                //System.out.println(tableArrSplit[i]);
                //s.print();
                
                //set var
                prevLon = s.lon;
                prevLat = s.lat;
                minutes = s.times;
                arr.add(s);
            }            
            
        }
        
        return arr;
    }
    
    public RouteJobLog loopRouteJobLog(String runId, ArrayList<RouteJobLog> arlistR, String str, String obj, int minutes, int routeNb, 
            int jobNb, String vehi, String prevLon, String prevLat, double speedTruck, double trafficFactor){
        //search from prev data
        RouteJobLog r = new RouteJobLog();
        for(int j=0;j<arlistR.size();j++){
            //System.out.println(arlistR.get(j).vehicleCode+"()"+arlistR.get(j).custId);
            //System.out.println(str);
            if(obj.equalsIgnoreCase("vehi")){
                if(arlistR.get(j).vehicleCode.equalsIgnoreCase(str)){
                    r = arlistR.get(j);
                }
            }else{//if(obj.equalsIgnoreCase("cust"))
                if(arlistR.get(j).custId.equalsIgnoreCase(str)){
                    r = arlistR.get(j);
                }
            }
        }
        
        if(str.equalsIgnoreCase("5810091915")){
            //System.out.println(vehi);
        }
        
        RouteJobLog t = new RouteJobLog();
        t.jobId = obj.equalsIgnoreCase("vehi") ? "DEPO" : r.custId;
        t.custId = obj.equalsIgnoreCase("vehi") ? "" : r.custId;
        t.countDoNo = obj.equalsIgnoreCase("vehi") ? "" : r.countDoNo;
        t.vehicleCode = vehi;        
        t.routeNb = routeNb; 
        t.jobNb = jobNb;
        if(obj.equalsIgnoreCase("vehi") && jobNb == 1){
            //start
            t.activity =  "DEPO";
            minutes = clockToMin(r.start);
            t.arrive = "";
            t.depart = r.start;      
            t.dist = 0;
            t.transportCost = 0;
            t.activityCost = r.activityCost;
        }else if(obj.equalsIgnoreCase("vehi") && jobNb > 1){
            //end
            t.activity = "DEPO";
            double distance1 = calcTraficDist(prevLon, prevLat, r.lon, r.lat);
            minutes += calcTraficTime(distance1, speedTruck, trafficFactor);
            minutes = minutes >= 1440 ? (minutes - 1440) : minutes;
            t.arrive = minToHour(minutes);
            t.depart = "";
            minutes = 0;
            t.dist = distance1;
            t.transportCost = (int) Math.round(r.costPerM * distance1);
            t.activityCost = 0;
        }else{
            //cust
            if(obj.equalsIgnoreCase("cust")){
                t.activity = r.custId;
                double distance1 = calcTraficDist(prevLon, prevLat, r.lon, r.lat);
                minutes += calcTraficTime(distance1, speedTruck, trafficFactor);
                minutes = minutes >= 1440 ? (minutes - 1440) : minutes;
                t.arrive = minToHour(minutes);
                minutes += Integer.valueOf(r.servicetime);
                t.depart = minToHour(minutes);
                t.dist = distance1;
                t.transportCost = (int) Math.round(r.costPerM * distance1);
                t.activityCost = 0;
            }else if(obj.equalsIgnoreCase("NA")){
                t.activity = "";
                t.arrive = "";
                t.depart = "";
                t.dist = 0;
                t.transportCost = 0;
                t.activityCost = 0;
            }
        }
        t.times = minutes;
        t.runId = runId;
        //t.createTime
        t.branch = r.branch;
        t.shift = r.shift;
        t.lon = r.lon;
        t.lat = r.lat;
        t.weight = obj.equalsIgnoreCase("vehi") ? "" : r.weight;
        t.volume = obj.equalsIgnoreCase("vehi") ? "" : r.volume;
        
        return t;
    }
    
    public double calcTraficDist(String prevLon, String prevLat, String lon, String lat){
        double distance1 = calcMeterDist(Double.parseDouble(prevLon), Double.parseDouble(prevLat), Double.parseDouble(lon), Double.parseDouble(lat));
        return distance1;
    }
    
    public int calcTraficTime(double distance1, double speedTruck, double trafficFactor){        
        int times = (int) Math.round((distance1 / (speedTruck * 1000 / 60)) * trafficFactor);        
        return times;
    }
    
    public String minToHour(int min){
        String str="";
        str = (String.valueOf(min/60).length() == 1 ? "0" + min/60 : min/60)
                + ":" + 
                (String.valueOf(min%60).length() == 1 ? "0" + min%60 : min%60);        
        return str;
    }
    
    public int clockToMin(String clock){
        String sh = clock.substring(0,2);
        String sm = clock.substring(3,5);
        int h = Integer.parseInt(sh);
        int m = Integer.parseInt(sm);
        int r = (h*60) + m;
        return r;
    }

    
    public static String[] decodeContent(String content) throws UnsupportedEncodingException {
        content = java.net.URLDecoder.decode(content, "UTF-8");
        content = content.substring(16);
        String[] contentSplit = content.split("split");
        return contentSplit;
    }
    
    public void getRunIdAndOriRunId(String arr) {
        String[] runIdArr = arr.split(",");
        String[] runIdSplit = runIdArr[1].split(":");
        runId = runIdSplit[1].replaceAll("\"", "").replace("}", "");
    }

    public void setDataRow(String vehicleCode, String custId, String runId) throws Exception {
        if (custId.equals("start") || custId.equals("end")) {
            String param;
            if (custId.equals("start")) {
                param = "arrive";
            } else {
                param = "depart";
            }
            try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
                try (Statement stm = con.createStatement()) {
                    String sql = "";
                    sql = "SELECT \n"
                            + "     job_id,\n"
                            + "     customer_id,\n"
                            + "     do_number,\n"
                            + "     activity,\n"
                            + "     jobNb,\n"
                            + "     arrive,\n"
                            + "     depart,\n"
                            + "     branch,\n"
                            + "     shift,\n"
                            + "     lon,\n"
                            + "     lat,\n"
                            + "     weight,\n"
                            + "     volume,\n"
                            + "     transportCost,\n"
                            + "     activityCost,\n"
                            + "     Dist,\n"
                            + "     isFix\n"
                            + "FROM \n"
                            + "     BOSNET1.dbo.TMS_RouteJob\n"
                            + "WHERE \n"
                            + "     runID = (select Re_RunId from BOSNET1.dbo.TMS_Progress where runid = '" + runId + "') and vehicle_code = '" + vehicleCode + "' and " + param + "= ''";
                    //System.out.println(sql);
                    try (ResultSet rs = stm.executeQuery(sql)) {
                        while (rs.next()) {
                            RouteJobLog r = new RouteJobLog();
                            r.jobId = rs.getString("job_id");
                            r.custId = rs.getString("customer_id");
                            r.countDoNo = rs.getString("do_number");
                            r.vehicleCode = vehicleCode;
                            r.activity = rs.getString("activity");
                            r.lon = rs.getString("lon");
                            r.lat = rs.getString("lat");
                            if (custId.equals("start")) {
                                r.jobNb = rs.getInt("jobNb");
                            } else {
                                r.jobNb = ++prevJobNb;
                                double distance1 = calcMeterDist(Double.parseDouble(prevLon), Double.parseDouble(prevLat), Double.parseDouble(prevLon), Double.parseDouble(r.lat));
                                double distance2 = calcMeterDist(Double.parseDouble(prevLon), Double.parseDouble(r.lat), Double.parseDouble(r.lon), Double.parseDouble(r.lat));
                                r.arrive = addTime(prevDepart, Math.round(trafficFactor * calcTripMinutes(distance1 + distance2, speedTruck)));
                            }
                            if(r.arrive.length() == 0 && !r.vehicleCode.equals("NA")) {
                                prevRouteNb++;
                            }
                            r.routeNb = prevRouteNb;
                            r.depart = rs.getString("depart");
                            r.runId = runId;
                            r.branch = rs.getString("branch");
                            r.shift = rs.getString("shift");
                            r.weight = rs.getString("weight");
                            r.volume = rs.getString("volume");
                            r.dist = rs.getInt("Dist");
                            r.isFix = null;

                            prevDepart = r.depart;
                            prevLon = r.lon;
                            prevLat = r.lat;
                            if (r.arrive.length() == 0) {
                                prevJobNb = 1;
                            }

                            arlistR.add(r);
                        }
                    }
                }
            } catch (Exception e) {
                throw new Exception(e.getMessage());
            }
        } else {
            try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
                try (Statement stm = con.createStatement()) {
                    String sql = "";
                    sql = "SELECT \n"
                            + "	rj.job_id,\n"
                            + "	rj.customer_id,\n"
                            + "	rj.do_number,\n"
                            + "	rj.branch,\n"
                            + "	rj.shift,\n"
                            + "	rj.lon,\n"
                            + "	rj.lat,\n"
                            + "	rj.weight,\n"
                            + "	rj.volume,\n"
                            + "	rj.activityCost,\n"
                            + "	cost.costPerM,\n"
                            + "	prj.Service_time\n"
                            + "FROM \n"
                            + "	BOSNET1.dbo.TMS_RouteJob rj\n"
                            + "FULL JOIN (\n"
                            + "	SELECT \n"
                            + "		TOP 1 costPerM,\n"
                            + "		runId\n"
                            + "	FROM \n"
                            + "		BOSNET1.dbo.TMS_PreRouteVehicle\n"
                            + "	WHERE \n"
                            + "		vehicle_code = '" + vehicleCode + "'\n"
                            + "		AND RunId = '" + runId + "') cost ON cost.runId = rj.runID\n"
                            + "INNER JOIN (\n"
                            + "	SELECT \n"
                            + "		TOP 1 Service_time,\n"
                            + "		customer_id\n"
                            + "	FROM \n"
                            + "		BOSNET1.dbo.TMS_PreRouteJob prj\n"
                            + "	WHERE \n"
                            + "		customer_id = '" + custId + "'\n"
                            + "		AND RunId = '" + runId + "') prj ON prj.customer_id = rj.customer_id\n"
                            + "WHERE rj.runID = '" + runId + "' and rj.customer_id = '" + custId + "'";
                    //System.out.println(sql);
                    try (ResultSet rs = stm.executeQuery(sql)) {
                        while (rs.next()) {
                            RouteJobLog r = new RouteJobLog();
                            r.jobId = rs.getString("job_id");
                            r.custId = rs.getString("customer_id");
                            r.countDoNo = rs.getString("do_number");
                            r.vehicleCode = vehicleCode;
                            r.lon = rs.getString("lon");
                            r.lat = rs.getString("lat");
                            if (!vehicleCode.equals("NA")) {
                                r.activity = rs.getString("customer_id");
                                r.routeNb = prevRouteNb;
                                r.jobNb = ++prevJobNb;
                                double distance1 = calcMeterDist(Double.parseDouble(prevLon), Double.parseDouble(prevLat), Double.parseDouble(prevLon), Double.parseDouble(r.lat));
                                double distance2 = calcMeterDist(Double.parseDouble(prevLon), Double.parseDouble(r.lat), Double.parseDouble(r.lon), Double.parseDouble(r.lat));
                                r.dist = distance1 + distance2;
                                r.transportCost = (int) Math.round(rs.getDouble("costPerM") * r.dist);
                                r.arrive = "" + addTime(prevDepart, Math.round(trafficFactor * calcTripMinutes(distance1 + distance2, speedTruck)));
                                r.depart = addTime(r.arrive, rs.getInt("Service_time"));
                            } else {
                                r.activity = "";
                                r.routeNb = 0;
                                r.jobNb = 0;
                                r.arrive = "";
                                r.depart = "";
                                r.transportCost = 0;
                            }
                            r.runId = runId;
                            r.branch = rs.getString("branch");
                            r.shift = rs.getString("shift");
                            r.weight = rs.getString("weight");
                            r.volume = rs.getString("volume");
                            r.activityCost = rs.getDouble("activityCost");
                            r.isFix = null;

                            prevDepart = r.depart;
                            prevLon = r.lon;
                            prevLat = r.lat;

                            arlistR.add(r);
                        }
                    }
                }
            } catch (Exception e) {
                throw new Exception(e.getMessage());
            }
        }
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

    public static double calcMeterDist(double lon1, double lat1, double lon2, double lat2) {
        double el1 = 0; // was in function param
        double el2 = 0; // was in function param
        final int R = 6371; // Radius of the earth

        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c * 1000; // convert to meters

        double height = el1 - el2;

        distance = Math.pow(distance, 2) + Math.pow(height, 2);

        return Math.sqrt(distance);
    }

    public static double calcTripMinutes(double distanceMtr, double speedKmPHr) {
        return ((distanceMtr / 1000) / speedKmPHr * 60);
    }

    public ArrayList<Double> getParam(String runId) throws Exception {
        ArrayList<Double> alParam = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT value FROM BOSNET1.dbo.TMS_PreRouteParams WHERE RunId = (SELECT distinct OriRunId FROM BOSNET1.dbo.TMS_Progress where runID = '"+runId+"') and (param = 'SpeedKmPHour' OR param = 'TrafficFactor') order by param asc";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        alParam.add(rs.getDouble("value")); // Index 0 = speed, index 1 = traffic factor
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return alParam;
    } 

    public static Timestamp getTimeStamp() throws ParseException {
        String timeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(Calendar.getInstance().getTime());
        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        Date date = (Date) formatter.parse(timeStamp);
        java.sql.Timestamp timeStampDate = new Timestamp(date.getTime());

        return timeStampDate;
    }

    public void updateRouteJob(ArrayList<RouteJobLog> arr, String runId) throws Exception {
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
        if (rowNum > 0) {
            try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
                try (Statement stm = con.createStatement()) {
                    String sql = "DELETE FROM bosnet1.dbo.TMS_RouteJob WHERE runID = '" + runId + "';";
                    stm.executeQuery(sql);
                }
            } catch (Exception e) {

            }
        }
        /*String sql = "INSERT INTO bosnet1.dbo.TMS_RouteJob "
                + "(job_id, customer_id, do_number, vehicle_code, activity, routeNb, jobNb, arrive, depart, runID, create_dtm, branch, shift, lon, lat, weight, volume, transportCost, activityCost, Dist) "
                + "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";*/
        
        for (int i = 0; i < arr.size(); i++) {
            RouteJobLog r = arr.get(i);
            String sql = "INSERT INTO bosnet1.dbo.TMS_RouteJob "
                    + "(job_id, customer_id, do_number, vehicle_code, activity, routeNb, jobNb, arrive, depart, runID, create_dtm, branch, shift, lon, lat, weight, volume, transportCost, activityCost, Dist) "
                    + "values('"+r.jobId+"','"+r.custId+"','"+r.countDoNo+"','"+r.vehicleCode+"','"+r.activity+"',"+r.routeNb+","+r.jobNb
                    +",'"+r.arrive+"','"+r.depart+"','"+r.runId+"',CONVERT(datetime, '"+createTime+"'),'"+r.branch+"','"+r.shift+"','"+r.lon+"','"+r.lat
                    +"','"+r.weight+"','"+r.volume+"',"+r.transportCost+","+r.activityCost+","+r.dist+");";

        
            try (Connection con = (new Db()).getConnection("jdbc/fztms"); 
                    PreparedStatement psHdr = con.prepareStatement(sql);) {
                //System.out.println(sql);
                psHdr.executeUpdate();
                psHdr.close();                
            }
        }
    }
}
