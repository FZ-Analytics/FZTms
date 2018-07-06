/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.service.run;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.Detail.runResultMapDetailController;
import com.fz.tms.params.map.Constava;
//import com.fz.tms.params.map.GoogleDirMapAllVehi;
import com.fz.tms.params.model.DODetil;
import com.fz.tms.params.model.OptionModel;
import com.fz.tms.params.model.SummaryVehicle;
import com.fz.tms.params.model.Vehicle;
import com.fz.tms.params.service.Other;
import com.fz.tms.params.service.VehicleAttrDB;
import com.fz.util.FZUtil;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 *
 */
public class RouteJobListing implements BusinessLogic {

    //DecimalFormat df = new DecimalFormat("##.0");
    Set<String> vehicles = new HashSet<String>();
    String shift = "";
    String branch = "";
    String key = Constava.googleKey;
    String runID = "";
    String OriRunID = "";
    String dateDeliv = "";
    String channel = "";
    List<List<HashMap<String, String>>> all = new ArrayList<List<HashMap<String, String>>>();

    @Override
    public void run(HttpServletRequest request, HttpServletResponse response,
            PageContext pc) throws Exception {

        runID = FZUtil.getHttpParam(request, "runID");
        OriRunID = FZUtil.getHttpParam(request, "OriRunID");
        channel = FZUtil.getHttpParam(request, "channel");
        dateDeliv = FZUtil.getHttpParam(request, "dateDeliv");
        branch = FZUtil.getHttpParam(request, "branch");

        runResultMapDetailController map = new runResultMapDetailController();
        List<OptionModel> jss = new ArrayList<OptionModel>();

        //all = map.runs(runID, jss);

        //TMS_Progress for what if
        insertNextProgress();

        /*Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String jsonOutput = gson.toJson(all);
        System.out.println(jsonOutput);

        request.setAttribute("key", key);
        request.setAttribute("test", jsonOutput.toString());
        request.setAttribute("JobOptionModel", jss);*/

        request.setAttribute("channel", channel);
        //List<RouteJob> js = getAll(runID, OriRunID);
        //request.setAttribute("JobList", js);
        request.setAttribute("OriRunID", OriRunID);
        request.setAttribute("nextRunId", getNextRunId(runID));
        request.setAttribute("dateDeliv", dateDeliv);

        request.setAttribute("vehicleCount", vehiCount(runID));
        request.setAttribute("runID", runID);
        request.setAttribute("branch", branch);
        request.setAttribute("shift", shift);
        request.setAttribute("OriRunID", OriRunID);
    }

    public static String getNextRunId(String runId) {
        String[] id = runId.split("_");
        String date = id[0];
        String time = "";
        System.out.println("CHAR AT 0: " + id[1].charAt(0));
        //Jam 10 pagi ke atas
        if (id[1].charAt(0) != '0') {
            int waktu = 0;
            waktu = Integer.parseInt(id[1]) + 1;
            time = "" + waktu;
        } //Sebelum jam 10 pagi
        else {
            int waktu = 0;
            waktu = Integer.parseInt(id[1]) + 1;
            time = "0" + waktu;
        }
        return date + "_" + time;
    }

    public static Timestamp getTimeStamp() throws ParseException {
        String timeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(Calendar.getInstance().getTime());
        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        Date date = (Date) formatter.parse(timeStamp);
        java.sql.Timestamp timeStampDate = new Timestamp(date.getTime());

        return timeStampDate;
    }

    public void insertNextProgress() throws Exception {
        Timestamp createTime = getTimeStamp();
        int rowNum = 0;
        String originalRunId = "";
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT COUNT(*) total FROM bosnet1.dbo.TMS_Progress WHERE runID = '" + getNextRunId(runID) + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        rowNum = rs.getInt("total");
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        try (Connection con = (new Db()).getConnection("jdbc/fztms")) {
            try (Statement stm = con.createStatement()) {
                String sql = "SELECT OriRunId FROM bosnet1.dbo.TMS_Progress WHERE runID = '" + runID + "';";
                try (ResultSet rs = stm.executeQuery(sql)) {
                    while (rs.next()) {
                        originalRunId = rs.getString("OriRunId");
                    }
                }
            }
        } catch (Exception e) {
            throw new Exception(e.getMessage());
        }
        if (rowNum == 0) {
            String sql = "INSERT INTO bosnet1.dbo.TMS_Progress "
                    + "(runID, status, msg, pct, mustFinish, branch, shift, tripCalc, lastUpd, created, maxIter, DelivDate, Re_RunId, OriRunId, Channel) "
                    + "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";

            try (Connection con = (new Db()).getConnection("jdbc/fztms"); PreparedStatement psHdr = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);) {
                psHdr.setString(1, getNextRunId(runID));
                psHdr.setString(2, "DONE");
                psHdr.setString(3, "Done");
                psHdr.setString(4, "100");
                psHdr.setString(5, null);
                psHdr.setString(6, branch);
                psHdr.setString(7, "1");
                psHdr.setString(8, "M");
                psHdr.setString(9, "" + createTime);
                psHdr.setString(10, "" + createTime);
                psHdr.setString(11, null);
                psHdr.setString(12, dateDeliv);
                psHdr.setString(13, "-");
                psHdr.setString(14, originalRunId);
                psHdr.setString(15, channel);

                psHdr.executeUpdate();
            }
        }
    }

    public String sendSAP(Vehicle he) throws Exception {
        String str = "ERROR";

        String sql = "update\n"
                + "	bosnet1.dbo.TMS_RouteJob\n"
                + " set\n"
                + "	isFix = '1'\n"
                + " where\n"
                + "	runID = '" + he.RunId + "'\n"
                + "	and vehicle_code = '" + he.vehicle_code + "'\n"
                + "	and isFix is null";
        try (
                Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement psHdr = con.prepareStatement(sql,
                        Statement.RETURN_GENERATED_KEYS);) {
            con.setAutoCommit(false);

            psHdr.executeUpdate();

            con.setAutoCommit(true);
            str = "OK";
        }
        return str;
    }

    public String DeleteResultShipment(Vehicle he) throws Exception {
        String str = "ERROR";

        String sql = "DELETE\n"
                + "FROM\n"
                + "	BOSNET1.dbo.TMS_Result_Shipment\n"
                + "WHERE\n"
                + "	Shipment_Number_Dummy = (SELECT\n"
                + "		DISTINCT concat(\n"
                + "			REPLACE(\n"
                + "				runID,\n"
                + "				'_',\n"
                + "				''\n"
                + "			),\n"
                + "			vehicle_code\n"
                + "		)\n"
                + "	FROM\n"
                + "		bosnet1.dbo.tms_RouteJob\n"
                + "	WHERE\n"
                + "		runID = '" + he.RunId + "'\n"
                + "		AND vehicle_code = '" + he.vehicle_code + "')";
        try (
                Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement psHdr = con.prepareStatement(sql,
                        Statement.RETURN_GENERATED_KEYS);) {
            con.setAutoCommit(false);

            psHdr.executeUpdate();

            con.setAutoCommit(true);
            str = "OK";
        }
        return str;
    }

    public List<HashMap<String, String>> cekData(String runID, String custId) throws Exception {
        String sub = "";
        if (custId.length() > 0) {
            sub = "	AND prj.Customer_ID = '" + custId + "'\n";
        }
        String sql = "SELECT\n"
                + "	prj.DO_Number AS DOPR,\n"
                + "	sp.DO_Number AS DOSP,\n"
                + "	ss.Delivery_Number AS DOSS,\n"
                + "	sn.Delivery_Number AS DORS\n"
                + "FROM\n"
                + "	(\n"
                + "		SELECT\n"
                + "			DISTINCT RunId,\n"
                + "			DO_Number,\n"
                + "			Customer_ID\n"
                + "		FROM\n"
                + "			BOSNET1.dbo.TMS_PreRouteJob\n"
                + "	) prj\n"
                + "LEFT OUTER JOIN(\n"
                + "		SELECT\n"
                + "			DISTINCT DO_Number\n"
                + "		FROM\n"
                + "			bosnet1.dbo.TMS_ShipmentPlan\n"
                + "		WHERE\n"
                + "			already_shipment = 'N'\n"
                + "			AND notused_flag IS NULL\n"
                + "			AND incoterm = 'FCO'\n"
                + "			AND Order_Type IN(\n"
                + "				'ZDCO',\n"
                + "				'ZDTO'\n"
                + "			)\n"
                + "			AND create_date >= DATEADD(\n"
                + "				DAY,\n"
                + "				- 7,\n"
                + "				GETDATE()\n"
                + "			)\n"
                + "			AND batch IS NOT NULL\n"
                + "	) sp ON\n"
                + "	prj.DO_Number = sp.DO_Number\n"
                + "LEFT OUTER JOIN(\n"
                + "		SELECT\n"
                + "			DISTINCT Delivery_Number\n"
                + "		FROM\n"
                + "			BOSNET1.dbo.TMS_Status_Shipment\n"
                + "		WHERE\n"
                + "			SAP_Message IS NULL\n"
                + "	) ss ON\n"
                + "	prj.DO_Number = ss.Delivery_Number\n"
                + "LEFT OUTER JOIN(\n"
                + "		SELECT\n"
                + "			DISTINCT Delivery_Number\n"
                + "		FROM\n"
                + "			BOSNET1.dbo.TMS_Result_Shipment\n"
                + "	) sn ON\n"
                + "	prj.DO_Number = sn.Delivery_Number\n"
                + "WHERE\n"
                + "	prj.RunId ='" + runID + "'\n" + sub;
        List<HashMap<String, String>> px = new ArrayList<HashMap<String, String>>();
        HashMap<String, String> pl = new HashMap<String, String>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)) {
            //System.out.println(sql);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    pl = new HashMap<String, String>();
                    pl.put("DOPR", rs.getString("DOPR"));
                    pl.put("DOSP", rs.getString("DOSP"));
                    pl.put("DOSS", rs.getString("DOSS"));
                    pl.put("DORS", rs.getString("DORS"));
                    //System.out.println("pl"+pl.toString());
                    px.add(pl);

                    //con.setAutoCommit(false);
                    //ps.executeUpdate();
                    //con.setAutoCommit(true);
                }
            }
        }

        return px;
    }

    public String vehiCount(String runId) throws Exception {
        String vehi = "";

        String sql = "select count(distinct vehicle_code) as cnt from BOSNET1.dbo.TMS_RouteJob where RunId = '" + runId + "' and vehicle_code <> 'NA'";
        //List<HashMap<String, String>> px = new ArrayList<HashMap<String, String>>();
        //HashMap<String, String> pl = new HashMap<String, String>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)) {
            //System.out.println(sql);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    vehi = rs.getString("cnt");

                    //con.setAutoCommit(false);
                    //ps.executeUpdate();
                    //con.setAutoCommit(true);
                }
            }
        }

        return vehi;
    }
}
