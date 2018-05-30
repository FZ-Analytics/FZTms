/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.params.Detail;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.map.GoogleDirMapAllVehi;
import com.fz.tms.params.model.OptionModel;
import com.fz.tms.params.model.RunResult;
import com.fz.tms.params.service.Other;
import com.fz.tms.params.service.VehicleAttrDB;
import com.fz.tms.service.run.RouteJob;
import com.fz.tms.service.run.RouteJobListing;
import com.fz.util.FZUtil;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 *
 * @author dwi.oktaviandi
 */
public class runResultDetailController implements BusinessLogic {    
    Set<String> vehicles = new HashSet<String>();
    String shift = "";
    String branch = "";
    @Override
    public void run(HttpServletRequest request, HttpServletResponse response
            , PageContext pc) throws Exception {
        RouteJobListing rj = new RouteJobListing();
        
        String runID = FZUtil.getHttpParam(request, "runID");
        String OriRunID = FZUtil.getHttpParam(request, "OriRunID");
        
        runResultMapDetailController map = new runResultMapDetailController();
        List<OptionModel> jss = new ArrayList<OptionModel>();

        List<List<HashMap<String, String>>> all = new ArrayList<List<HashMap<String, String>>>();
        //all = map.runs(runID, jss);
        
        List<RouteJob> js = getAll(runID, OriRunID, all);
        
        request.setAttribute("JobList", js);
        request.setAttribute("runID", runID);
    }
    
    public List<RouteJob> getAll(String runID, String OriRunID, List<List<HashMap<String, String>>> all) throws Exception{
        List<RouteJob> js = new ArrayList<RouteJob>();
        
        /*String sql = "SELECT\n" +
                "	j.customer_ID,\n" +
                "	(\n" +
                "		SELECT\n" +
                "			(\n" +
                "				stuff(\n" +
                "					(\n" +
                "						SELECT\n" +
                "							'; ' + DO_Number\n" +
                "						FROM\n" +
                "							bosnet1.dbo.TMS_PreRouteJob a\n" +
                "						WHERE\n" +
                "							Is_Edit = 'edit'\n" +
                "							AND Customer_ID = j.customer_ID\n" +
                "							AND RunId = j.runID\n" +
                "						GROUP BY\n" +
                "							DO_Number FOR xml PATH('')\n" +
                "					),\n" +
                "					1,\n" +
                "					2,\n" +
                "					''\n" +
                "				)\n" +
                "			)\n" +
                "	) AS DO_number,\n" +
                "	j.arrive,\n" +
                "	j.depart,\n" +
                "	j.lat,\n" +
                "	j.lon,\n" +
                "	j.vehicle_code,\n" +
                "	j.branch,\n" +
                "	j.shift,\n" +
                "	CASE\n" +
                "		WHEN d.name1 IS NULL\n" +
                "		AND Request_Delivery_Date IS NOT NULL THEN 'UNKNOWN'\n" +
                "		ELSE d.name1\n" +
                "	END name1,\n" +
                "	d.customer_priority,\n" +
                "	d.distribution_channel,\n" +
                "	d.street,\n" +
                "	CAST(\n" +
                "		CAST(\n" +
                "			(\n" +
                "				CAST(\n" +
                "					j.weight AS FLOAT\n" +
                "				)\n" +
                "			) AS NUMERIC(\n" +
                "				15,\n" +
                "				1\n" +
                "			)\n" +
                "		) AS VARCHAR\n" +
                "	) AS weight,\n" +
                "	CAST(\n" +
                "		CAST(\n" +
                "			(\n" +
                "				(\n" +
                "					CAST(\n" +
                "						j.volume AS FLOAT\n" +
                "					)/ 1000000\n" +
                "				)\n" +
                "			) AS NUMERIC(\n" +
                "				15,\n" +
                "				1\n" +
                "			)\n" +
                "		) AS VARCHAR\n" +
                "	) AS volume,\n" +
                "	CASE\n" +
                "		WHEN d.CreateDate <> d.UpdatevDate THEN 'edited'\n" +
                "		WHEN d.CreateDate = d.UpdatevDate THEN 'edit'\n" +
                "	END edit,\n" +
                "	CAST(\n" +
                "		CAST(\n" +
                "			j.transportCost AS NUMERIC(9)\n" +
                "		) AS VARCHAR\n" +
                "	) AS transportCost,\n" +
                "	CAST(\n" +
                "		Dist / 1000 AS NUMERIC(\n" +
                "			9,\n" +
                "			1\n" +
                "		)\n" +
                "	) AS Dist,\n" +
                "	Request_Delivery_Date\n" +
                "FROM\n" +
                "	bosnet1.dbo.tms_RouteJob j\n" +
                "LEFT OUTER JOIN(\n" +
                "		SELECT\n" +
                "			RunId,\n" +
                "			Customer_ID,\n" +
                "			MIN( Customer_priority ) Customer_priority,\n" +
                "			CreateDate,\n" +
                "			UpdatevDate,\n" +
                "			name1,\n" +
                "			street,\n" +
                "			distribution_channel,\n" +
                "			MIN( Request_Delivery_Date ) Request_Delivery_Date\n" +
                "		FROM\n" +
                "			(\n" +
                "				SELECT\n" +
                "					DISTINCT RunId,\n" +
                "					Customer_ID,\n" +
                "					Customer_priority,\n" +
                "					CreateDate,\n" +
                "					UpdatevDate,\n" +
                "					name1,\n" +
                "					street,\n" +
                "					distribution_channel,\n" +
                "					Request_Delivery_Date\n" +
                "				FROM\n" +
                "					bosnet1.dbo.TMS_PreRouteJob\n" +
                "				WHERE\n" +
                "					Is_Edit = 'edit'\n" +
                "			) a\n" +
                "		GROUP BY\n" +
                "			RunId,\n" +
                "			Customer_ID,\n" +
                "			CreateDate,\n" +
                "			UpdatevDate,\n" +
                "			name1,\n" +
                "			street,\n" +
                "			distribution_channel\n" +
                "	) d ON\n" +
                "	j.runID = d.RunId\n" +
                "	AND j.customer_id = d.Customer_ID\n" +
                "WHERE\n" +
                "	j.runID = '"+runID+"'\n" +
                "ORDER BY\n" +
                "	j.routeNb,\n" +
                "	j.jobNb,\n" +
                "	j.arrive";*/
        
        /*try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)){*/
        String sql = "{call bosnet1.dbo.TMS_RunResultShow(?)}";
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                java.sql.CallableStatement stmt =
                con.prepareCall(sql)) {
            stmt.setString(1, runID);
            try(ResultSet rs = stmt.executeQuery()){
            // get list
            //try (ResultSet rs = ps.executeQuery()){
                BigDecimal bcW = new BigDecimal(0);
                BigDecimal bcV = new BigDecimal(0);
                // populate list
                RouteJob prevJ = null;
                int km = 0;
                
                VehicleAttrDB ar = new VehicleAttrDB();
                int a = 1;
                    
                int p = 0;
                String vehicleCode = "";
                
                while (rs.next()) {
                    
                    RouteJob j = new RouteJob();
                    int i = 1;
                    j.runID = runID;
                    j.custID = FZUtil.getRsString(rs, i++, "");
                    j.DONum = FZUtil.getRsString(rs, i++, "");
                    j.arrive = FZUtil.getRsString(rs, i++, "");
                    j.depart = FZUtil.getRsString(rs, i++, "");
                    j.lat = FZUtil.getRsString(rs, i++, "");
                    j.lon = FZUtil.getRsString(rs, i++, "");
                    j.vehicleCode = FZUtil.getRsString(rs, i++, "");
                    j.branch = FZUtil.getRsString(rs, i++, "");
                    j.shift = FZUtil.getRsString(rs, i++, "");
                    
                    j.name1 = FZUtil.getRsString(rs, i++, "");
                    j.custPriority = FZUtil.getRsString(rs, i++, "");
                    j.distrChn = FZUtil.getRsString(rs, i++, "");
                    j.street = FZUtil.getRsString(rs, i++, "");
                    //j.district = FZUtil.getRsString(rs, i++, "");
                    //j.zip = FZUtil.getRsString(rs, i++, "");
                    //j.city = FZUtil.getRsString(rs, i++, "");  
                    
                    if(j.custID.length() > 0 && j.arrive.length() > 0){
                        j.no = a + "";
                        a++;
                    }else if(j.custID.length() == 0 && j.arrive.length() > 0){
                        a = 1;
                    }
                    
                    j.weight =  FZUtil.getRsString(rs, i++, "");
                    j.volume = FZUtil.getRsString(rs, i++, "");
                    j.edit = FZUtil.getRsString(rs, i++, "");
                    j.transportCost = FZUtil.getRsString(rs, i++, "");
                    j.dist = FZUtil.getRsString(rs, i++, "");
                    j.rdd = FZUtil.getRsString(rs, i++, "");
                    //j.send = FZUtil.getRsString(rs, i++, "");
                    //j.bat = FZUtil.getRsString(rs, i++, "").length() > 0 ? "1" : "0";
                    //System.out.println(j.custID +"_"+j.bat);
                    
                    js.add(j);
                    
                    if(j.custID.equalsIgnoreCase("5820001166")){
                        //System.out.println("com.fz.tms.service.run.RouteJobListing.run()");
                    }
                    
                    //color row
                    if(!j.vehicleCode.equalsIgnoreCase("NA")){                        
                        
                        /*for(int op = 0;op<all.size();op++){
                            for(int os = 0;os<all.get(op).size();os++){
                                if(all.get(op).get(os).get("description").contains(j.vehicleCode)){
                                    j.color = "#"+all.get(op).get(os).get("color").toUpperCase();
                                    System.out.println(j.color);
                                }
                                //System.out.println(all.get(op).get(os));
                            }                            
                        }*/
                        
                        //set color
                        GoogleDirMapAllVehi gv = new GoogleDirMapAllVehi();
                        String clr = gv.myList[Integer.valueOf(FZUtil.getRsString(rs, i++, ""))-1].toUpperCase();
                        j.color = "#" + clr;
                        
                        if(!j.vehicleCode.equalsIgnoreCase(vehicleCode)
                                && j.getServiceTime().equalsIgnoreCase("0")){
                            vehicleCode = j.vehicleCode;                            
                            
                            p++;
                        }
                    }else{
                        i++;
                    }
                    
                    //mark red
                    String mark = FZUtil.getRsString(rs, i++, "");
                    System.out.println(j.custID+"()"+mark);
                    j.bat = mark.equalsIgnoreCase("1") ? "1" : "";
                    
                    //System.out.println(j.toString());
                    //add break row
                    if(j.arrive != ""){
                        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
                        Date arv12 = sdf.parse("12:00");
                        Date arvA = sdf.parse(j.arrive);
                        RouteJob temp = null;
                        if(js.get((js.size()-2)).arrive != ""){
                            Date arvB = sdf.parse(js.get((js.size()-2)).arrive);
                            if(arvA.after(arv12) && arvB.before(arv12)){
                                //System.out.println(arvA + " " + arvB);
                                temp = j;
                                j = new RouteJob();
                                j.name1 = "";
                                j.custPriority = "";
                                j.distrChn = "";
                                j.street = "";
                                j.weight = "";
                                j.volume = "";
                                j.edit = "";     
                                j.rdd = "";
                                j.transportCost = "";
                                j.dist = "";
                                j.send = "";  
                                js.add((js.size()-1), j);
                                j = temp;
                            }
                        }
                    }
                    
                    if(!j.vehicleCode.equals("") && !j.vehicleCode.equals("NA"))    vehicles.add(j.vehicleCode);
                    
                    // if no prev job/first time
                    // , keep header infos in request attrib
                    if (prevJ == null){
                        branch = j.branch;
                        shift = j.shift;
                    }
                    // else if has prev job within same route
                    else if (prevJ.routeNb == j.routeNb){
                        
                        j.prevJob = prevJ;
                    }
                    
                    //5 =-> 7 
                    //link google map setelah break
                    if(js.get(js.size() - 1).prevJob == null && js.get(js.size() - 1).vehicleCode.length() > 2 && js.size() >= 3){
                        RouteJob pJ = new RouteJob();
                        pJ = (RouteJob) js.get(js.size() - 1);
                        pJ.prevJob = (RouteJob) js.get(js.size() - 3);
                    }
                    
                    // for next round
                    prevJ = j;
                }
                /*List<HashMap<String, String>> px = cekData(runID, "");
                int x = 0;
                while(x < js.size()){
                    int y = 0;
                    Boolean cek = true;
                    if(js.get(x).DONum.length() > 0){
                        while(y < px.size()){  
                            //cek jika do sama
                            if(js.get(x).DONum.equalsIgnoreCase("8020103331; 8020103633")&& px.get(y).get("DOPR").equalsIgnoreCase("8020103633")){
                                //System.out.println("test()"+js.get(x).DONum+"+");
                                //System.out.println(js.get(x).DONum+"()"+px.get(y).get("DOPR"));
                            }                            
                            if(js.get(x).DONum.contains(px.get(y).get("DOPR"))){
                                //cek shipmentplsn 
                                if(js.get(x).DONum.equalsIgnoreCase("8020103633")){
                                    //System.out.println(px.get(y).get("DOSP")+"()"+px.get(y).toString());
                                }
                                if(px.get(y).get("DOSP") == null
                                        || px.get(y).get("DOSS") != null
                                        || px.get(y).get("DORS") != null){
                                    cek = false;
                                    break;
                                }else{
                                    cek = true;
                                }
                                //System.out.println(js.get(x).DONum + "()" + px.get(y).get("DOPR"));                                
                            }
                            y++;
                        }
                        if(!cek)    js.get(x).bat = "1";//merah
                        //System.out.println(js.get(x).DONum + "()" + js.get(x).bat);
                    }                    
                    x++;
                }*/
                
                
            }            
        }catch(Exception e){
            HashMap<String, String> pl = new HashMap<String, String>();
            pl.put("ID", OriRunID+ "_" +runID);
            pl.put("fileNmethod", "RouteJobListing&run Exc");
            pl.put("datas", sql);
            pl.put("msg", e.getMessage());
            DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm");
            Date date = new Date();
            pl.put("dates", dateFormat.format(date).toString());
            Other.insertLog(pl);
        }
        
        return js;
    }
    
    public List<HashMap<String, String>> cekData(String runID, String custId) throws Exception{
        String sub = "";
        if(custId.length() > 0){
            sub = "	AND prj.Customer_ID = '"+custId+"'\n";
        }
        String sql = "SELECT\n" +
                "	prj.DO_Number AS DOPR,\n" +
                "	sp.DO_Number AS DOSP,\n" +
                "	ss.Delivery_Number AS DOSS,\n" +
                "	sn.Delivery_Number AS DORS\n" +
                "FROM\n" +
                "	(\n" +
                "		SELECT\n" +
                "			DISTINCT RunId,\n" +
                "			DO_Number,\n" +
                "			Customer_ID\n" +
                "		FROM\n" +
                "			BOSNET1.dbo.TMS_PreRouteJob\n" +
                "	) prj\n" +
                "LEFT OUTER JOIN(\n" +
                "		SELECT\n" +
                "			DISTINCT DO_Number\n" +
                "		FROM\n" +
                "			bosnet1.dbo.TMS_ShipmentPlan\n" +
                "		WHERE\n" +
                "			already_shipment = 'N'\n" +
                "			AND notused_flag IS NULL\n" +
                "			AND incoterm = 'FCO'\n" +
                "			AND Order_Type IN(\n" +
                "				'ZDCO',\n" +
                "				'ZDTO'\n" +
                "			)\n" +
                "			AND create_date >= DATEADD(\n" +
                "				DAY,\n" +
                "				- 7,\n" +
                "				GETDATE()\n" +
                "			)\n" +
                "			AND batch IS NOT NULL\n" +
                "	) sp ON\n" +
                "	prj.DO_Number = sp.DO_Number\n" +
                "LEFT OUTER JOIN(\n" +
                "		SELECT\n" +
                "			DISTINCT Delivery_Number\n" +
                "		FROM\n" +
                "			BOSNET1.dbo.TMS_Status_Shipment\n" +
                "		WHERE\n" +
                "			SAP_Message IS NULL\n" +
                "	) ss ON\n" +
                "	prj.DO_Number = ss.Delivery_Number\n" +
                "LEFT OUTER JOIN(\n" +
                "		SELECT\n" +
                "			DISTINCT Delivery_Number\n" +
                "		FROM\n" +
                "			BOSNET1.dbo.TMS_Result_Shipment\n" +
                "	) sn ON\n" +
                "	prj.DO_Number = sn.Delivery_Number\n" +
                "WHERE\n" +
                "	prj.RunId ='"+runID+"'\n" + sub;
        List<HashMap<String, String>> px = new ArrayList<HashMap<String, String>>();
        HashMap<String, String> pl = new HashMap<String, String>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)) {
            //System.out.println(sql);
            try (ResultSet rs = ps.executeQuery()){
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
    
    public String exclude(RunResult he) throws Exception{
        String str = "ERROR";
        
        String sql = "UPDATE\n" +
                "	bosnet1.dbo.TMS_PreRouteJob\n" +
                "SET\n" +
                "	Is_Exclude = 'exc'\n" +
                "WHERE\n" +
                "	RunId = '"+he.runId+"'\n" +
                "	AND Customer_ID = '"+he.custId+"'\n" +
                "	AND Is_Edit = 'edit'";
        try (
            Connection con = (new Db()).getConnection("jdbc/fztms");
            PreparedStatement psHdr = con.prepareStatement(sql
                    , Statement.RETURN_GENERATED_KEYS);
            )  {
            con.setAutoCommit(false);

            psHdr.executeUpdate();
            
            con.setAutoCommit(true);
            str = "OK";
        }
        
        return str;
    }
}

