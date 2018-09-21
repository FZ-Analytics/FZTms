/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.ffbv3.api.TMS;

import com.fz.generic.Db;
import com.fz.tms.params.model.ResultShipment;
import com.fz.tms.params.model.RunResultEditResultSubmitToSap;
import com.fz.tms.params.service.Other;
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
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.Consumes;
import javax.ws.rs.Produces;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PUT;
import javax.ws.rs.core.MediaType;
import org.eclipse.persistence.jpa.jpql.parser.DateTime;

/**
 * REST Web Service
 *
 * @author Administrator
 */
@Path("submitToSap")
public class SubmitToSapAPI {

    String runId = "";
    String flag = "";
    String vNo = "";
    @Context
    private UriInfo context;

    /**
     * Creates a new instance of SubmitToSapResource
     */
    public SubmitToSapAPI() {
    }

    /**
     * Retrieves representation of an instance of
     * com.fz.ffbv3.Test.SubmitToSapResource
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
     * PUT method for updating or creating an instance of SubmitToSapResource
     *
     * @param content representation for the resource
     */
    @PUT
    @Consumes(MediaType.APPLICATION_XML)
    public void putXml(String content) {
    }

    @POST
    @Path("submitToSap")
    @Produces(MediaType.APPLICATION_JSON)
    public String submitToSap(String content) {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String ret = "OK";
        ResultShipment rs = new ResultShipment();
        String doN = "";
        String err = "";
        try {
            RunResultEditResultSubmitToSap he = gson.fromJson(content.contains("json") ? decodeContent(content) : content, RunResultEditResultSubmitToSap.class);
            vNo = he.vehicle_no;
            flag = he.flag;
            if (flag.equals("runResult")) {
                runId = he.runId;
            } else if (flag.equals("runResultEditResult")) {
                runId = he.runId;
            }

            HashMap<String, String> hmPRV = getFromPreRouteVehicle(runId, he.vehicle_no);
            ArrayList<String> alCustId = getCustomerId(runId, he.vehicle_no);
            ArrayList<String> alStartAndEndTime = getStartAndEndTime(runId, he.vehicle_no);
            Timestamp time = getTimeID();
            String route = getLongestRoute(alCustId, he.vehicle_no, runId);
            boolean isAlreadyOnce = false;

            //check if any route is null
            boolean isRouteNull = false;
            for (int i = 0; i < alCustId.size(); i++) {
                if (getRoute(alCustId.get(i)) == null) {
                    ret = "Aborted: One of the route is empty on Customer ID: " + alCustId.get(i);
                    isRouteNull = true;
                    break;
                }
                if (getFromShipmentPlan(runId, alCustId.get(i)).isEmpty()) {
                    ret = "Aborted: Goods is already sent or Batch is NULL for DO on Customer ID: " + alCustId.get(i);
                    isRouteNull = true;
                    break;
                }
            }
            if (isRouteNull == false) {
                String str = "ERROR";
                for (int i = 0; i < alCustId.size(); i++) {

                    ArrayList<HashMap<String, String>> alSP = getFromShipmentPlan(runId, alCustId.get(i));
                    System.out.println("alcust size: " + alSP.size());
                    for (int j = 0; j < alSP.size(); j++) {
                        HashMap<String, String> hmSP = alSP.get(j); //HashMap Shipment Plan
                        
                        doN = hmSP.get("DO_Number");
                        err = "add model";
                        
                        rs.Shipment_Type = hmPRV.get("source1");
                        rs.Plant = hmSP.get("Plant");
                        rs.Shipment_Route = route;
                        rs.Description = "";
                        rs.Status_Plan = getNextDate(parseRunId(runId, true), true, 1);
                        rs.Status_Check_In = null;
                        rs.Status_Load_Start = null;
                        rs.Status_Load_End = null;
                        rs.Status_Complete = null;
                        rs.Status_Shipment_Start = getNextDate(alStartAndEndTime.get(3), false,0) + " " + alStartAndEndTime.get(0);
                        int nxt = Integer.parseInt(alStartAndEndTime.get(2)) > 0 ? 1 : 0;
                        rs.Status_Shipment_End = getNextDate(alStartAndEndTime.get(3), false,nxt) + " " + alStartAndEndTime.get(1);
                        rs.Service_Agent_Id = hmPRV.get("IdDriver");
                        if (rs.Shipment_Type.equals("ZDSI")) {
                            rs.Shipment_Number_Dummy = runId.replace("_", "") + he.vehicle_no;
                            rs.No_Pol = he.vehicle_no;
                            rs.Driver_Name = hmPRV.get("NamaDriver");
                            rs.Vehicle_Number = he.vehicle_no;
                        } else {
                            rs.Shipment_Number_Dummy = runId.replace("_", "") + getVendorId(he.vehicle_no);
                            rs.No_Pol = getExtVehicleType(he.vehicle_no);
                            rs.Driver_Name = getVendorName(he.vehicle_no);
                            rs.Vehicle_Number = getExtVehicleType(he.vehicle_no);
                            vNo = getVendorId(he.vehicle_no);
                        }

                        rs.Delivery_Number = hmSP.get("DO_Number");
                        rs.Delivery_Item = hmSP.get("Item_Number");
                        rs.Delivery_Quantity_Split = 0.000;
                        rs.Delivery_Quantity = Double.parseDouble(hmSP.get("DOQty"));
                        rs.Delivery_Flag_Split = "";
                        rs.Material = hmSP.get("Product_ID");
                        rs.Vehicle_Type = hmPRV.get("vehicle_type");
                        rs.Batch = hmSP.get("Batch");
                        rs.Time_Stamp = time;
                        rs.Shipment_Number_SAP = "";
                        rs.I_Status = "0";
                        rs.Shipment_Flag = "";
                        if (isAlreadyOnce == false) {
                            rs.distance = "" + getTotalDist(runId, he.vehicle_no);
                            isAlreadyOnce = true;
                        } else {
                            rs.distance = null;
                        }
                        rs.distanceUnit = "M";

                        //untuk test comment disini
                        err = "insertResultShipment";
                        str = insertResultShipment(rs);
                    }
                    if (!ret.equals("OK")) {                        
                        break;
                    }
                }
                if(str.equalsIgnoreCase("OK")){
                    err = "moveShip";
                    moveShip(rs);
                    err = "";
                }
                if (!ret.equals("OK")) {
                    err = ret;
                    throw new Exception(); 
                }
            }
        } catch (Exception e) {
            HashMap<String, String> pl = new HashMap<String, String>();
            
            pl.put("ID", runId);
            pl.put("fileNmethod", "submitToSap Exc");
            pl.put("datas", "");
            pl.put("msg", doN+" | "+err+" | "+e.getMessage());
            DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm");
            Date date = new Date();
            pl.put("dates", dateFormat.format(date).toString());
            try { 
                Other.insertLog(pl);
            } catch (Exception ex) {
                
            }
        }

        String jsonOutput = gson.toJson(ret);
        return jsonOutput;
    }
    
    public void moveShip(ResultShipment rs) throws Exception{
        String sql = "INSERT\n" +
                "	INTO\n" +
                "		BOSNET1.dbo.TMS_Result_Shipment(\n" +
                "			Shipment_Type,\n" +
                "			Plant,\n" +
                "			Shipping_Type,\n" +
                "			Shipment_Route,\n" +
                "			Shipment_Number_Dummy,\n" +
                "			Description,\n" +
                "			Status_Plan,\n" +
                "			Status_Check_In,\n" +
                "			Status_Load_Start,\n" +
                "			Status_Load_End,\n" +
                "			Status_Complete,\n" +
                "			Status_Shipment_Start,\n" +
                "			Status_Shipment_End,\n" +
                "			Service_Agent_Id,\n" +
                "			No_Pol,\n" +
                "			Driver_Name,\n" +
                "			Delivery_Number,\n" +
                "			Delivery_Item,\n" +
                "			Delivery_Quantity_Split,\n" +
                "			Delivery_Quantity,\n" +
                "			Delivery_Flag_Split,\n" +
                "			Material,\n" +
                "			Batch,\n" +
                "			Vehicle_Number,\n" +
                "			Vehicle_Type,\n" +
                "			Time_Stamp,\n" +
                "			Shipment_Number_SAP,\n" +
                "			I_Status,\n" +
                "			Shipment_Flag,\n" +
                "			Distance,\n" +
                "			Distance_Unit\n" +
                "		)(\n" +
                "			SELECT\n" +
                "				Shipment_Type,\n" +
                "				Plant,\n" +
                "				Shipping_Type,\n" +
                "				Shipment_Route,\n" +
                "				Shipment_Number_Dummy,\n" +
                "				Description,\n" +
                "				Status_Plan,\n" +
                "				Status_Check_In,\n" +
                "				Status_Load_Start,\n" +
                "				Status_Load_End,\n" +
                "				Status_Complete,\n" +
                "				Status_Shipment_Start,\n" +
                "				Status_Shipment_End,\n" +
                "				Service_Agent_Id,\n" +
                "				No_Pol,\n" +
                "				Driver_Name,\n" +
                "				Delivery_Number,\n" +
                "				Delivery_Item,\n" +
                "				Delivery_Quantity_Split,\n" +
                "				Delivery_Quantity,\n" +
                "				Delivery_Flag_Split,\n" +
                "				Material,\n" +
                "				Batch,\n" +
                "				Vehicle_Number,\n" +
                "				Vehicle_Type,\n" +
                "				format(\n" +
                "					getdate(),\n" +
                "					'yyyy-MM-dd hh:mm:ss.000'\n" +
                "				) Time_Stamp,\n" +
                "				Shipment_Number_SAP,\n" +
                "				I_Status,\n" +
                "				Shipment_Flag,\n" +
                "				Distance,\n" +
                "				Distance_Unit\n" +
                "			FROM\n" +
                "				BOSNET1.dbo.TMS_Result_ShipmentArc\n" +
                "			WHERE\n" +
                "				Shipment_Number_Dummy = '"+rs.Shipment_Number_Dummy+"'\n" +
                "		)";
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)) {

            con.setAutoCommit(false);
            ps.executeUpdate();
            con.setAutoCommit(true);
            ps.close();
        }
    }

    public static String decodeContent(String content) throws UnsupportedEncodingException {
        content = java.net.URLDecoder.decode(content, "UTF-8");
        content = content.substring(5);

        return content;
    }

    public String getNextDate(String date, boolean full, int nxt) throws ParseException {
        SimpleDateFormat dateFormat;
        if (full) {
            dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss:sss");
        } else {
            dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        }
        Calendar cal = Calendar.getInstance();
        cal.setTime(dateFormat.parse(date));
        cal.add(Calendar.DATE, nxt);
        String convertedDate = dateFormat.format(cal.getTime());

        return "" + convertedDate;
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

    public String getVendorId(String v) {
        String[] vSplit = v.split("_");
        return vSplit[1] + vSplit[3];
    }

    public String getExtVehicleType(String v) {
        String[] vSplit = v.split("_");
        return vSplit[2];
    }

    public String getVendorName(String v) {
        String[] vSplit = v.split("_");
        return vSplit[0];
    }

    public Timestamp getTimeID() throws ParseException {
        String time = (new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
        Timestamp ts = Timestamp.valueOf(time);
        return ts;
    }

    public String reFormatLongLat(String longlat) {
        String ret = "";
        //Sometimes long lat use "," instead of "."
        if (!longlat.contains(",")) {
            ret = longlat;
        } else {
            ret = longlat.replaceAll(",", ".");
        }
        return ret;
    }

    public String parseRunId(String runId, boolean fullRunId) {
        String[] runIdSplit = runId.split("_");
        String date = runIdSplit[0];
        String time = runIdSplit[1];
        String y = "", m = "", d = "", h = "", min = "", s = "", ms = "";
        for (int i = 0; i < date.length(); i++) {
            if (i <= 3) {
                y += date.charAt(i);
            } else if (i >= 4 && i <= 5) {
                m += date.charAt(i);
            } else if (i >= 6) {
                d += date.charAt(i);
            }
        }
        if (fullRunId) {
            for (int i = 0; i < time.length(); i++) {
                if (i <= 1) {
                    h += time.charAt(i);
                } else if (i >= 2 && i <= 3) {
                    min += time.charAt(i);
                } else if (i >= 4 && i <= 5) {
                    s += time.charAt(i);
                } else if (i >= 6) {
                    ms += time.charAt(i);
                }
            }
            return y + "-" + m + "-" + d + " " + h + ":" + min + ":" + s + ":" + ms;
        } else {
            return y + "-" + m + "-" + d;
        }
    }

    public HashMap<String, String> getFromPreRouteVehicle(String runId, String vehicleNo) throws Exception {
        HashMap<String, String> hm = new HashMap<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT "
                        + "vehicle_type, "
                        + "IdDriver, "
                        + "NamaDriver, "
                        + "CASE "
                        + "WHEN source1 = 'INT' THEN 'ZDSI' "
                        + "ELSE 'ZDSH' "
                        + "END as source1 "
                        + "FROM BOSNET1.dbo.TMS_PreRouteVehicle "
                        + "WHERE runID = '" + runId + "' and vehicle_code = '" + vehicleNo + "';";

                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        hm.put("source1", rs.getString("source1"));
                        hm.put("vehicle_type", rs.getString("vehicle_type"));
                        hm.put("IdDriver", rs.getString("IdDriver"));
                        if (rs.getString("NamaDriver") == null) {
                            hm.put("NamaDriver", "");
                        } else {
                            hm.put("NamaDriver", rs.getString("NamaDriver"));
                        }
                    }
                }
            }
        } 
        return hm;
    }

    public ArrayList<HashMap<String, String>> getFromShipmentPlan(String runId, String custId) throws Exception {
        ArrayList<HashMap<String, String>> al = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT DISTINCT\n"
                        + "     sp.DO_Number,\n"
                        + "     sp.Route,\n"
                        + "     sp.Item_Number,\n"
                        + "	pr.branch Plant,\n"
                        + "     sp.DOQty,\n"
                        + "     sp.Product_ID,\n"
                        + "     sp.Batch,\n"
                        + "     sp.NotUsed_Flag,\n"
                        + "     sp.Incoterm,\n"
                        + "     sp.Order_Type,\n"
                        + "     sp.Create_Date,\n"
                        + "     rj.arrive,\n"
                        + "     rj.depart\n"
                        + "FROM\n"
                        + "     [BOSNET1].[dbo].[TMS_ShipmentPlan] sp\n"
                        + "INNER JOIN (\n"
                        + "	SELECT\n"
                        + "		rj.customer_id,\n"
                        + "		rj.arrive,\n"
                        + "		rj.depart\n"
                        + "	FROM\n"
                        + "		[BOSNET1].[dbo].[TMS_RouteJob] rj\n"
                        + "	WHERE\n"
                        + "		rj.runId = '" + runId + "'\n"
                        + "		AND rj.Customer_ID = '" + custId + "') rj ON rj.customer_id = sp.Customer_ID\n"
                        + "INNER JOIN (\n"
                        + "	SELECT DISTINCT\n"
                        + "		prj.Request_Delivery_Date\n"
                        + "	FROM \n"
                        + "		[BOSNET1].[dbo].[TMS_PreRouteJob] prj\n"
                        + "	WHERE \n"
                        + "		prj.runId = '" + runId + "'\n"
                        + "             AND prj.Customer_ID = '" + custId + "') prj "
                        + "     ON \n"
                        + "             prj.Request_Delivery_Date = \n"
                        + "             CASE \n"
                        + "			WHEN \n"
                        + "				DATENAME(dw, sp.Request_Delivery_Date) = 'Sunday'\n"
                        + "			THEN \n"
                        + "				DATEADD(day, -1, sp.Request_Delivery_Date)\n"
                        + "			ELSE\n"
                        + "				sp.Request_Delivery_Date\n"
                        + "		END\n"
                        + "INNER JOIN BOSNET1.dbo.TMS_Progress pr ON"
                        + "	pr.runId = '" + runId + "'"
                        + "WHERE\n"
                        + "         sp.Customer_ID = '" + custId + "'\n"
                        + "         AND sp.Already_Shipment <> 'Y'\n"
                        + "         AND sp.Batch <> 'NULL'\n"
                        + "         AND sp.NotUsed_Flag is NULL\n"
                        + "         AND sp.incoterm = 'FCO'\n"
                        + "         AND(\n"
                        + "		sp.Order_Type = 'ZDCO'\n"
                        + "		OR sp.Order_Type = 'ZDTO'\n"
                        + "         )\n"
                        + "         AND sp.create_date >= DATEADD(\n"
                        + "		DAY,\n"
                        + "		- 90,\n"
                        + "		GETDATE()\n"
                        + "         )\n"
                        + "ORDER BY\n"
                        + "         sp.DO_Number";

                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        HashMap<String, String> hm = new HashMap<>();
                        hm.put("arrive", rs.getString("arrive"));
                        hm.put("depart", rs.getString("depart"));
                        hm.put("DO_Number", rs.getString("DO_Number"));
                        hm.put("Route", rs.getString("Route"));
                        hm.put("Item_Number", rs.getString("Item_Number"));
                        hm.put("Plant", rs.getString("Plant"));
                        hm.put("DOQty", rs.getString("DOQty"));
                        hm.put("Product_ID", rs.getString("Product_ID"));
                        hm.put("Batch", rs.getString("Batch"));

                        al.add(hm);
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return al;
    }

    public String getLongestRoute(ArrayList<String> alCustId, String vNo, String runId) throws Exception {
        double longestDist = 0;
        String custId = "";
        for (int i = 0; i < alCustId.size(); i++) {
            HashMap<String, String> hmLongLat = getLongLat(alCustId.get(i), runId, vNo);
            double distance1 = calcMeterDist(Double.parseDouble(hmLongLat.get("Long")), Double.parseDouble(hmLongLat.get("Lat")), Double.parseDouble(hmLongLat.get("Long")), Double.parseDouble(hmLongLat.get("startLat")));
            double distance2 = calcMeterDist(Double.parseDouble(hmLongLat.get("Long")), Double.parseDouble(hmLongLat.get("startLat")), Double.parseDouble(hmLongLat.get("startLon")), Double.parseDouble(hmLongLat.get("startLat")));
            double temp = distance1 + distance2;
            if (temp > longestDist) {
                longestDist = temp;
                custId = alCustId.get(i);
            }
        }
        return getRoute(custId);
    }

    public double getTotalDist(String runId, String vehicleCode) throws Exception {
        double totDist = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT Dist FROM BOSNET1.dbo.TMS_RouteJob WHERE runID = '" + runId + "' and vehicle_code = '" + vehicleCode + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        totDist += Math.round(rs.getDouble("Dist"));
                    }
                }
            } catch (Exception e) {
                throw new Exception(e.getMessage());
            }
        }
        return totDist;
    }

    public String getRoute(String custId) throws Exception {
        String route = "";
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT DISTINCT Route FROM BOSNET1.dbo.TMS_ShipmentPlan WHERE Customer_ID = '" + custId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        route = rs.getString("Route");
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return route;
    }

    public HashMap<String, String> getLongLat(String custId, String runId, String vNo) throws Exception {
        HashMap<String, String> hmLongLat = new HashMap<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT DISTINCT "
                        + "     prj.Long, "
                        + "     prj.Lat, "
                        + "     (SELECT "
                        + "         prv.startLon "
                        + "     FROM "
                        + "         BOSNET1.dbo.TMS_PreRouteVehicle prv "
                        + "     WHERE "
                        + "         prv.RunID = '" + runId + "' "
                        + "         and prv.vehicle_code = '" + vNo + "') startLon, "
                        + "     (SELECT "
                        + "         prv.startLat "
                        + "     FROM "
                        + "         BOSNET1.dbo.TMS_PreRouteVehicle prv "
                        + "     WHERE "
                        + "         prv.RunID = '" + runId + "' "
                        + "         and prv.vehicle_code = '" + vNo + "') startLat "
                        + "FROM "
                        + "     BOSNET1.dbo.TMS_PreRouteJob prj "
                        + "WHERE "
                        + "     prj.RunID = '" + runId + "' "
                        + "     and prj.Customer_ID = '" + custId + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        hmLongLat.put("Long", reFormatLongLat(rs.getString("Long")));
                        hmLongLat.put("Lat", reFormatLongLat(rs.getString("Lat")));
                        hmLongLat.put("startLon", reFormatLongLat(rs.getString("startLon")));
                        hmLongLat.put("startLat", reFormatLongLat(rs.getString("startLat")));
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception("OUCH: " + e.getMessage());
        }
        return hmLongLat;
    }

    public ArrayList<String> getCustomerId(String runId, String vehicleCode) throws Exception {
        ArrayList<String> al = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT customer_id FROM BOSNET1.dbo.TMS_RouteJob where runID = '" + runId + "' and vehicle_code = '" + vehicleCode + "' and customer_id != '';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        al.add(rs.getString("customer_id"));
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        return al;
    }

    public ArrayList<String> getStartAndEndTime(String runId, String vehicleCode) throws Exception {
        ArrayList<String> al = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql;
                sql = "SELECT\n" +
                        "	arrive,\n" +
                        "	depart,\n" +
                        "	cnt,\n" +
                        "	DelivDate\n" +
                        "FROM\n" +
                        "	BOSNET1.dbo.TMS_RouteJob aw,\n" +
                        "	(\n" +
                        "		SELECT\n" +
                        "			COUNT(*) cnt\n" +
                        "		FROM\n" +
                        "			(\n" +
                        "				SELECT\n" +
                        "					CAST(\n" +
                        "						arrive AS DATETIME2\n" +
                        "					) arrive,\n" +
                        "					CAST(\n" +
                        "						depart AS DATETIME2\n" +
                        "					) depart\n" +
                        "				FROM\n" +
                        "					BOSNET1.dbo.TMS_RouteJob\n" +
                        "				WHERE\n" +
                        "					runID = '"+runId+"'\n" +
                        "					AND vehicle_code = '"+vehicleCode+"'\n" +
                        "			) ad\n" +
                        "		WHERE\n" +
                        "			ad.arrive >= CAST(\n" +
                        "				'00:01' AS DATETIME2\n" +
                        "			)\n" +
                        "			AND ad.arrive <= CAST(\n" +
                        "				'05:00' AS DATETIME2\n" +
                        "			)\n" +
                        "	) aq,\n" +
                        "	BOSNET1.dbo.TMS_Progress p\n" +
                        "WHERE\n" +
                        "	aw.runID = '"+runId+"'\n" +
                        "	AND aw.runID = p.runID\n" +
                        "	AND vehicle_code = '"+vehicleCode+"'\n" +
                        "	AND customer_id = '';";
                System.out.println(sql);
                try (ResultSet rs = stm.executeQuery(sql)) {
                    int i = 0;
                    while (rs.next()) {
                        if (i == 0) {
                            al.add(rs.getString("depart"));
                        } else {
                            al.add(rs.getString("arrive"));
                            al.add(rs.getString("cnt"));
                            al.add(rs.getString("DelivDate"));
                        }
                        i++;
                    }
                }
            }
        }
        return al;
    }

    public String insertResultShipment(ResultShipment rs) throws Exception {
        int isExist = 0;
        String error = "";
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT\n"
                        + "	COUNT(*) isExist,\n"
                        + "	ss.SAP_Message error,\n"
                        + "     rs.I_Status\n"
                        + "FROM\n"
                        + "	BOSNET1.dbo.TMS_Result_Shipment rs\n"
                        + "FULL JOIN (\n"
                        + "	SELECT \n"
                        + "		ss.SAP_Message,\n"
                        + "		ss.Delivery_Number,\n"
                        + "		ss.Delivery_Item\n"
                        + "	FROM \n"
                        + "		bosnet1.dbo.TMS_Status_Shipment ss\n"
                        + "	WHERE \n"
                        + "		ss.Delivery_Number = '" + rs.Delivery_Number + "' and ss.Delivery_Item = '" + rs.Delivery_Item + "'\n"
                        + ") ss ON ss.Delivery_Number = rs.Delivery_Number\n"
                        + "WHERE\n"
                        + "    rs.Delivery_Number = '" + rs.Delivery_Number + "'\n"
                        + "    AND rs.Delivery_Item = '" + rs.Delivery_Item + "'\n"
                        + "GROUP BY SAP_Message, rs.I_Status\n"
                        + "UNION ALL\n"
                        + "SELECT\n"
                        + "	COUNT(*) isExist,\n"
                        + "	ss.SAP_Message error,\n"
                        + "     rs.I_Status\n"
                        + "FROM\n"
                        + "	BOSNET1.dbo.TMS_Result_ShipmentArc rs\n"
                        + "FULL JOIN (\n"
                        + "	SELECT \n"
                        + "		ss.SAP_Message,\n"
                        + "		ss.Delivery_Number,\n"
                        + "		ss.Delivery_Item\n"
                        + "	FROM \n"
                        + "		bosnet1.dbo.TMS_Status_Shipment ss\n"
                        + "	WHERE \n"
                        + "		ss.Delivery_Number = '" + rs.Delivery_Number + "' and ss.Delivery_Item = '" + rs.Delivery_Item + "'\n"
                        + ") ss ON ss.Delivery_Number = rs.Delivery_Number\n"
                        + "WHERE\n"
                        + "    rs.Delivery_Number = '" + rs.Delivery_Number + "'\n"
                        + "    AND rs.Delivery_Item = '" + rs.Delivery_Item + "'\n"
                        + "GROUP BY SAP_Message, rs.I_Status";

                try (ResultSet rst = stm.executeQuery(sql)) {
                    while (rst.next()) {
                        isExist += rst.getInt("isExist");
                        error = rst.getString("error");
                        System.out.println(isExist + " " + error);
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        //It means current DO is failed to be submitted to SAP, the row at Result Shipment and Status Shipment will be deleted
        if (isExist > 0 && error != null) {
            deleteFromResultShipment(rs);
            deleteFromStatusShipment(rs);
        }

        String ret = "error";
        if ((isExist == 0) || (isExist > 0 && error != null)) {            
            
            String sql = "INSERT INTO bosnet1.dbo.TMS_Result_ShipmentArc "
                    + "(Shipment_Type, Plant, Shipping_Type, Shipment_Route, Shipment_Number_Dummy, Description, Status_Plan, Status_Check_In, Status_Load_Start, Status_Load_End, "
                    + "Status_Complete, Status_Shipment_Start, Status_Shipment_End, Service_Agent_Id, No_Pol, Driver_Name, Delivery_Number, Delivery_Item, Delivery_Quantity_Split, "
                    + "Delivery_Quantity, Delivery_Flag_Split, Material, Batch, Vehicle_Number, Vehicle_Type, Time_Stamp, Shipment_Number_SAP, I_Status, Shipment_Flag, Distance, Distance_Unit) "
                    + "values('"+rs.Shipment_Type+"','"+rs.Plant+"',"+rs.Shipping_Type+",'"+rs.Shipment_Route+"','"+rs.Shipment_Number_Dummy+"'"
                    + ",'"+rs.Description+"','"+rs.Status_Plan+"',"+rs.Status_Check_In+","+rs.Status_Load_Start+","+rs.Status_Load_End+","+rs.Status_Complete+""
                    + ",'"+rs.Status_Shipment_Start+"','"+rs.Status_Shipment_End+"','"+rs.Service_Agent_Id+"','"+rs.No_Pol+"','"+rs.Driver_Name+"'"
                    + ",'"+rs.Delivery_Number+"','"+rs.Delivery_Item+"',"+rs.Delivery_Quantity_Split+","+rs.Delivery_Quantity+",'"+rs.Delivery_Flag_Split+"'"
                    + ",'"+rs.Material+"','"+rs.Batch+"','"+rs.Vehicle_Number+"','"+rs.Vehicle_Type+"',(select format(getdate(),'yyyy-MM-dd hh:mm:ss.000') Time_Stamp)"
                    + ",'"+rs.Shipment_Number_SAP+"','"+rs.I_Status+"','"+rs.Shipment_Flag+"',"+rs.distance+",'"+rs.distanceUnit+"');";
            System.out.println("insert TMS_Result_Shipment "+sql);
            try (Connection con = (new Db()).getConnection("jdbc/fztms"); 
                    PreparedStatement psHdr = con.prepareStatement(sql);) {
                psHdr.executeUpdate();
                psHdr.close();  
                ret = "OK";
            }
        }
        return ret;
    }

    public int deleteFromStatusShipment(ResultShipment rs) throws Exception {
        int ret = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql
                        = "DELETE "
                        + "FROM "
                        + "   bosnet1.dbo.TMS_Status_Shipment "
                        + "WHERE "
                        + "   Delivery_Number = '" + rs.Delivery_Number + "'"
                        + "   AND Delivery_Item = '" + rs.Delivery_Item + "';";
                ret = stm.executeUpdate(sql);
            }
        }
        return ret;
    }

    public int deleteFromResultShipment(ResultShipment rs) throws Exception {
        int ret = 0;
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql
                        = "DELETE "
                        + "FROM "
                        + "   bosnet1.dbo.TMS_Result_Shipment "
                        + "WHERE "
                        + "   Delivery_Number = '" + rs.Delivery_Number + "'"
                        + "   AND Delivery_Item = '" + rs.Delivery_Item + "';";
                stm.executeQuery(sql);
            }
        }
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql
                        = "DELETE "
                        + "FROM "
                        + "   bosnet1.dbo.TMS_Result_ShipmentArc "
                        + "WHERE "
                        + "   Delivery_Number = '" + rs.Delivery_Number + "'"
                        + "   AND Delivery_Item = '" + rs.Delivery_Item + "';";
                stm.executeQuery(sql);
            }
        } 
        return ret;
    }
}
