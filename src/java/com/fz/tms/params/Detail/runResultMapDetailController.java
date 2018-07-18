/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.params.Detail;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.map.Constava;
import com.fz.tms.params.model.OptionModel;
import com.fz.tms.params.service.Other;
import com.fz.util.FZUtil;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 *
 * @author dwi.oktaviandi
 */
public class runResultMapDetailController implements BusinessLogic {
    String key = Constava.googleKey;
    List<String> vehi = new ArrayList<String>();  
    
    public static String[] myList = {"0019DC","A20CE8","FF0000","E8720C","FFD30D","6DA1BA","632152","00546B","E9FF00",
                    "FF8C91","E0AAFF","C6C641","FFF8DC","DC143C","00FFFF","00008B","008B8B","B8860B","A9A9A9","006400","BDB76B",
                    "8B008B","8B0000","556B2F","FF8C00","9932CC","E9967A","8FBC8F","483D8B","00CED1","9400D3","00CED1","9400D3",
                    "FF1493","B22222","00BFFF","228B22","FF00FF","1E90FF","FFD700","008000","FF69B4","CD5C5C","DAA520","ADFF2F",
                    "4B0082","F0E68C","FFF0F5","7CFC00","ADD8E6","F08080","90EE90","FFB6C1","FFA07A","20B2AA","00FF00","B0C4DE",
                    "87CEFA","FF00FF","66CDAA","BA55D3","9370DB","3CB371"};

    @Override
    public void run(HttpServletRequest request, HttpServletResponse response,
             PageContext pc) throws Exception {

        //KEY google AIzaSyB_lu1GKTDK0Lc08lT6p1f4WFZaFvILIGY
        String runID = FZUtil.getHttpParam(request, "runID");
        String vCode = FZUtil.getHttpParam(request, "vCode");
        String channel = FZUtil.getHttpParam(request, "channel");
        
        List<OptionModel> js = new ArrayList<OptionModel>();
        List<List<HashMap<String, String>>> all = runs(runID, js);
        
        //String str = asd.toString();
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String jsonOutput = gson.toJson(all);
        //jsonOutput = "{\"myObj\":" + jsonOutput + "}";
        System.out.println(jsonOutput.toString());                
        //request.setAttribute("branch", br);
        
        request.setAttribute("key", key);
        request.setAttribute("test", jsonOutput.toString());
        request.setAttribute("JobOptionModel", js);
    }
    
    
    
    public static String clr() {

        // create random object - reuse this as often as possible
        Random random = new Random();

        // create a big random number - maximum is ffffff (hex) = 16777215 (dez)
        int nextInt = random.nextInt(256*256*256);

        // format it as hexadecimal string (with hashtag and leading zeros)
        String colorCode = String.format("#%06x", nextInt);

        // print it
        System.out.println(colorCode);
        return colorCode.toUpperCase();
    }
    
    public List<List<HashMap<String, String>>> runs(String runID, List<OptionModel> js) throws Exception{
        List<List<HashMap<String, String>>> all = new ArrayList<List<HashMap<String, String>>>();
        String sql = "SELECT\n" +
                "	CASE\n" +
                "		WHEN aw.Is_Exclude = 'exc' THEN '-1'\n" +
                "		ELSE aq.jobNb\n" +
                "	END jobNb,\n" +
                "	CASE\n" +
                "		WHEN aw.Name1 IS NULL THEN aq.vehicle_code\n" +
                "		ELSE aw.Name1\n" +
                "	END AS title,\n" +
                "	aq.lat,\n" +
                "	aq.lon,\n" +
                "	CASE\n" +
                "		WHEN aq.depart = '' THEN(\n" +
                "			SELECT\n" +
                "				startTime\n" +
                "			FROM\n" +
                "				BOSNET1.dbo.TMS_VehicleAtr\n" +
                "			WHERE\n" +
                "				vehicle_code = aq.vehicle_code\n" +
                "				AND included = 1\n" +
                "		)\n" +
                "		ELSE aq.arrive\n" +
                "	END AS arrive,\n" +
                "	CASE\n" +
                "		WHEN aq.depart = '' THEN aq.arrive\n" +
                "		ELSE aq.depart\n" +
                "	END AS depart,\n" +
                "	aw.Street,\n" +
                "	aw.Distribution_Channel,\n" +
                "	aw.deliv,\n" +
                "	aw.DeliveryDeadline,\n" +
                "	aw.openDay,\n" +
                "	aw.Customer_priority,\n" +
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
                "							AND Customer_ID = aw.customer_ID\n" +
                "							AND RunId = aw.runID\n" +
                "						GROUP BY\n" +
                "							DO_Number FOR xml PATH('')\n" +
                "					),\n" +
                "					1,\n" +
                "					2,\n" +
                "					''\n" +
                "				)\n" +
                "			)\n" +
                "	) AS DO_number,\n" +
                "	aq.vehicle_code\n" +
                "FROM\n" +
                "	BOSNET1.dbo.TMS_RouteJob aq\n" +
                "LEFT OUTER JOIN(\n" +
                "		SELECT\n" +
                "			DISTINCT RunId,\n" +
                "			Customer_ID,\n" +
                "			Name1,\n" +
                "			Street,\n" +
                "			Distribution_Channel,\n" +
                "			deliv,\n" +
                "			DeliveryDeadline,\n" +
                "			openDay,\n" +
                "			MIN( Customer_priority ) Customer_priority,\n" +
                "			Is_Exclude\n" +
                "		FROM\n" +
                "			(\n" +
                "				SELECT\n" +
                "					RunId,\n" +
                "					Customer_ID,\n" +
                "					Name1,\n" +
                "					Street,\n" +
                "					Distribution_Channel,\n" +
                "					concat(\n" +
                "						deliv_start,\n" +
                "						' - ',\n" +
                "						deliv_end\n" +
                "					) AS deliv,\n" +
                "					DeliveryDeadline,\n" +
                "					concat(\n" +
                "						(\n" +
                "							DayWinStart - 1\n" +
                "						),\n" +
                "						'-',\n" +
                "						(\n" +
                "							DayWinEnd - 1\n" +
                "						)\n" +
                "					) openDay,\n" +
                "					Customer_priority,\n" +
                "					Is_Exclude\n" +
                "				FROM\n" +
                "					BOSNET1.dbo.TMS_PreRouteJob\n" +
                "				WHERE\n" +
                "					Is_Edit = 'edit'\n" +
                "			) a\n" +
                "		GROUP BY\n" +
                "			RunId,\n" +
                "			Customer_ID,\n" +
                "			Name1,\n" +
                "			Street,\n" +
                "			Distribution_Channel,\n" +
                "			deliv,\n" +
                "			DeliveryDeadline,\n" +
                "			openDay,\n" +
                "			Is_Exclude\n" +
                "	) aw ON\n" +
                "	aq.customer_id = aw.Customer_ID\n" +
                "	AND aq.RunId = aw.RunId\n" +
                "WHERE\n" +
                "	aq.runID = '"+runID+"'\n" +
                //"	AND aq.vehicle_code <> 'NA'\n" +
                "ORDER BY\n" +
                "	aq.vehicle_code,\n" +
                //"	aq.jobNb";
                "	aq.jobNb,\n" +
                "	aw.Distribution_Channel desc;";
        //GooAPICaller go = new GooAPICaller();
        //StringBuffer tr = new StringBuffer();
        //StringBuffer tu = new StringBuffer();
        //go.go("https://maps.googleapis.com/maps/api/directions/json?origin=-6.292103,106.842926&destination=-6.292103,106.842926&waypoints=-6.294761,106.834986|-6.294761,106.833986", tr, tu);
        
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)) {

            try (ResultSet rs = ps.executeQuery()) {                
                List<HashMap<String, String>> asd = new ArrayList<HashMap<String, String>>();
                //ArrayList<HashMap<String, String>> ar = new ArrayList<HashMap<String, String>>();
                HashMap<String, String> pl = new HashMap<String, String>();
                //https://www.w3schools.com/colors/colors_names.asp
                /*String[] myList = {"ff5050", "ffff52", "52ff52", "52ffff", "5252ff", "ff52ff", "ff7d52", "d4ff52", "52ff7d", 
                    "52d4ff", "7d52ff", "ff52d4", "ffa852", "a8ff52", "52ffa8", "52a8ff", "a852ff", "ff52a8", "ffd452", 
                    "7dff52", "52ffd4", "527dff", "d452ff", "ff527d"};*/                
                int p = 0;

                String vehi = "";
                String NB = "";
                String clr = "";
                
                //vehi();                
                OptionModel om = new OptionModel();
                while (rs.next()) {
                    pl = new HashMap<String, String>();
                    int i = 1;
                    pl.put("jobNb", FZUtil.getRsString(rs, i++, ""));
                    pl.put("title", FZUtil.getRsString(rs, i++, ""));
                    pl.put("lat", FZUtil.getRsString(rs, i++, ""));
                    pl.put("lng", FZUtil.getRsString(rs, i++, ""));
                    String arrive = FZUtil.getRsString(rs, i++, "");
                    String depart = FZUtil.getRsString(rs, i++, "");
                    String street = FZUtil.getRsString(rs, i++, "");
                    String Distribution_Channel = FZUtil.getRsString(rs, i++, "");
                    String deliv = FZUtil.getRsString(rs, i++, "");
                    String DeliveryDeadline = FZUtil.getRsString(rs, i++, "");
                    String openDay = FZUtil.getRsString(rs, i++, "7-7");
                    String Customer_priority = FZUtil.getRsString(rs, i++, "");
                    String DO_number = FZUtil.getRsString(rs, i++, "");
                    String vehicle_code = FZUtil.getRsString(rs, i++, "");
                    if(pl.get("jobNb").equalsIgnoreCase("0")){
                        System.out.println("com.fz.tms.params.map.GoogleDirMapAllVehi.runs()");
                    }
                    
                    String str = "<h2>" + pl.get("title") + "</h2><p>Channel : "+ Distribution_Channel + "(" + DeliveryDeadline + ")" 
                            + "</p><p>Priority : " + Customer_priority + " (" + vehicle_code + ")" + "</p> " + "</p><p>Street : " + street + "</p><p>Arrive : " 
                            + arrive + " - " + depart  + "</p><p>Open : " + day(String.valueOf(openDay.charAt(0))) + "-" 
                            + day(String.valueOf(openDay.charAt(2))) + " (" + deliv + ")" + "</p><p> Do: " + DO_number + "</p><p> lat;lng : "
                            + pl.get("lat") + ";" + pl.get("lng") + "</p>";
                    pl.put("description", str);
                    pl.put("color", myList[p].toUpperCase());
                    //pl.put("channel", FZUtil.getRsString(rs, i++, ""));
                    asd.add(pl);
                    
                    if(om.Display == null || 
                            !om.Display.equalsIgnoreCase(vehicle_code)){
                        om = new OptionModel();
                        om.Display = vehicle_code;
                        om.Value = "#" + myList[p].toUpperCase();
                        js.add(om);
                    }
                    
                    
                    if ((!pl.get("title").equalsIgnoreCase(vehi)
                            && street == ""
                            && !pl.get("jobNb").equalsIgnoreCase("1"))
                            || pl.get("jobNb").equalsIgnoreCase("0")) {
                        //clr = clr();
                        p = p + 1;
                        //remove & replace pertama dengan akhir 
                        asd.add(0, pl);
                        asd.remove(1);

                        vehi = pl.get("title");
                        all.add(asd);
                        asd = new ArrayList<HashMap<String, String>>();
                    }
                }
                ps.close();
            }
        }catch(Exception e){
            HashMap<String, String> pl = new HashMap<String, String>();
            pl.put("ID", runID);
            pl.put("fileNmethod", "GoogleDirMapAllVehi&run Exc");
            pl.put("datas", "");
            pl.put("msg", e.getMessage());
            DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm");
            Date date = new Date();
            pl.put("dates", dateFormat.format(date).toString());
            Other.insertLog(pl);
        }
        return all;
    }
    
    public String cek(String ttl){
        String str = "ERROR";
        for(int a=0;a<vehi.size();a++){
            if(ttl.equalsIgnoreCase(vehi.get(a))){
                str = "OK";
            }
        }
        return str; 
    }
    
    public void vehi() throws Exception{
        String str = "";
        
        String sql = "SELECT distinct vehicle_code FROM BOSNET1.dbo.TMS_VehicleAtr where included = 1";
        //GooAPICaller go = new GooAPICaller();
        //StringBuffer tr = new StringBuffer();
        //StringBuffer tu = new StringBuffer();
        //go.go("https://maps.googleapis.com/maps/api/directions/json?origin=-6.292103,106.842926&destination=-6.292103,106.842926&waypoints=-6.294761,106.834986|-6.294761,106.833986", tr, tu);
        
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)) {

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int i = 1;
                    vehi.add(FZUtil.getRsString(rs, i++, ""));
                }
                ps.close();
            }
        }
    }
    
    public String day(String str){
        String day = "";
        if(str.equalsIgnoreCase("1")){
            day = "Mon";
        }else if(str.equalsIgnoreCase("2")){
            day = "Tue";
        }else if(str.equalsIgnoreCase("3")){
            day = "Wed";
        }else if(str.equalsIgnoreCase("4")){
            day = "Thu";
        }else if(str.equalsIgnoreCase("5")){
            day = "Fri";
        }else if(str.equalsIgnoreCase("6")){
            day = "Sat";
        }else{
            day = new String();
        }        
        return day;
    }
}
