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
            
            getRunIdAndOriRunId(tableArrSplit[tableArrSplit.length - 1]);
            
            ArrayList<Double> alParam = getParam(runId);
            speedTruck = alParam.get(0);
            trafficFactor = alParam.get(1);
            for (int i = 0; i < tableArrSplit.length - 1; i++) {
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
            }
            updateRouteJob(arlistR, runId);
        } catch (Exception e) {
            System.out.println("ERROR" + e.getLocalizedMessage());
            ret = "ERROR";
        }
        String jsonOutput = gson.toJson(ret);
        return jsonOutput;
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
                            + "     runID = '" + runId + "' and vehicle_code = '" + vehicleCode + "' and " + param + "= ''";

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
                String sql = "SELECT value FROM BOSNET1.dbo.TMS_PreRouteParams WHERE RunId = (SELECT distinct OriRunId FROM BOSNET1.dbo.TMS_Progress where runID = '"+runId+"') and (param = 'SpeedKmPHour' OR param = 'TrafficFactor')";
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

    public void updateRouteJob(ArrayList<RouteJobLog> arlistR, String runId) throws Exception {
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
        String sql = "INSERT INTO bosnet1.dbo.TMS_RouteJob "
                + "(job_id, customer_id, do_number, vehicle_code, activity, routeNb, jobNb, arrive, depart, runID, create_dtm, branch, shift, lon, lat, weight, volume, transportCost, activityCost, Dist) "
                + "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";

        for (int i = 0; i < arlistR.size(); i++) {
            RouteJobLog r = arlistR.get(i);
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
