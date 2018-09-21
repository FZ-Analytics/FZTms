/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.params.map;

import static com.fz.ffbv3.api.TMS.CustomerAttrViewAPI.decodeContent;
import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.Detail.runResultMapDetailController;
import com.fz.tms.params.model.Polyline_Decoder.Point;
import com.fz.tms.params.model.Polyline_Decoder.PolylineDecoder;
import com.fz.tms.params.model.googleMap.GMapsModel;
import com.fz.util.FZUtil;
import com.fz.util.UrlResponseGetter;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author dwi.rangga
 */
public class LeafLetmap implements BusinessLogic {

    String key = Constava.googleKey;

    @Override
    public void run(HttpServletRequest request, HttpServletResponse response,
             PageContext pc) throws Exception {
        String runID = FZUtil.getHttpParam(request, "runID");
        String vCode = FZUtil.getHttpParam(request, "vCode");
        
        String sql = "{call bosnet1.dbo.TMS_LeafletShow(?,?)}";

        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                java.sql.CallableStatement stmt =
                con.prepareCall(sql)) {
            stmt.setString(1, runID);
            stmt.setString(2, vCode);
            try(ResultSet rs = stmt.executeQuery()){
                ArrayList<ArrayList<String>> nodes = new ArrayList<ArrayList<String>>();
                ArrayList<String> lonlat = new ArrayList<String>();
                
                JSONArray arrs = new JSONArray();
                int p = 0;
                while (rs.next()) {
                    /*lonlat = new ArrayList<String>();
                    lonlat.add(rs.getString("lat"));
                    lonlat.add(rs.getString("lon"));
                    nodes.add(lonlat);*/
                    
                    JSONObject jb = new JSONObject();
                    jb.put("lat", rs.getDouble("lat"));
                    jb.put("lng", rs.getDouble("lon"));
                    jb.put("name", rs.getString("Name1"));
                    jb.put("lbl", rs.getString("jobNb"));
                    jb.put("vehicle_code", rs.getString("vehicle_code"));
                    jb.put("clr", rs.getString("vehicle_code"));
                    String clr = "";
                    if(!jb.get("vehicle_code").equals("NA"))
                        clr = "#" + runResultMapDetailController.myList[Integer.valueOf(jb.getString("lbl"))].toUpperCase();
                    
                    arrs.put(jb);
                }
                //String str = asd.toString();
                System.out.println(arrs.toString());
                Gson gson = new GsonBuilder().setPrettyPrinting().create();
                request.setAttribute("testMap", nodes.toString());
                //request.setAttribute("branch", br);

            }
        }
    }

}
