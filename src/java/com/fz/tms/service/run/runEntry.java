/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.service.run;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.generic.PageTopUtils;
import com.fz.tms.params.model.Branch;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 *
 * @author dwi.oktaviandi
 */
public class runEntry implements BusinessLogic {
    
    public static String EmpyID;
    public static String Key;

    @Override
    public void run(HttpServletRequest request, HttpServletResponse response
            , PageContext pc) throws Exception {
        String br = (String) pc.getSession().getAttribute("WorkplaceID");        
        List<Branch> lBr = getBranch(br);
        
        //update login
        EmpyID = (String) pc.getSession().getAttribute("EmpyID");
        Key = (String) pc.getSession().getAttribute("Key");
        RunThread R1 = new RunThread("Thread",EmpyID,Key);
        R1.start();
        
        
        request.setAttribute("ListBranch", lBr);
    }
    
    public List<Branch> getBranch(String br) throws Exception{
        Branch c = new Branch();
        List<Branch> ar = new ArrayList<Branch>();
        
        String str = "";
        if(br.length() > 0){
            str = "and plant = '" + br + "'";
        }
        try (Connection con = (new Db()).getConnection("jdbc/fztms")){            
            try (Statement stm = con.createStatement()){
            
                // create sql
                String sql = "SELECT\n" +
                        "	DISTINCT plant,\n" +
                        "	SalOffName\n" +
                        "FROM\n" +
                        "	BOSNET1.dbo.TMS_ShipmentPlan aq\n" +
                        "INNER JOIN BOSNET1.dbo.TMS_SalesOffice aw ON\n" +
                        "	aq.plant = aw.SalOffCode\n" +
                        "WHERE\n" +
                        "	plant LIKE 'D%'\n" +
                        "	"+str+"\n" +
                        "ORDER BY\n" +
                        "	plant ASC";
                
                // query
                try (ResultSet rs = stm.executeQuery(sql)){
                    while (rs.next()){   
                        c = new Branch();
                        c.branchId = rs.getString("plant");
                        c.name = rs.getString("SalOffName");
                        ar.add(c);
                    }
                }
            }
        }
        catch (Exception e){
            throw new Exception(e.getMessage());
        }
        return ar;
    }
    
}

class RunThread implements Runnable {
   private Thread t;
   private String threadName;
   private String EmpyID;
   private String Key;
   
   RunThread(String name, String EmpyID, String Key) {
       threadName = name;
       EmpyID = EmpyID;
       Key = Key;
   }
   
    public void run() {
        System.out.println("Running " +  threadName );
        try {
            Thread.sleep(50);
            PageTopUtils.setDate(runEntry.EmpyID, runEntry.Key);
            System.out.println("Finnish " +  threadName );
        } catch (InterruptedException e) {
           System.out.println("InterruptedException e" +  e.getMessage());
        } catch (Exception ex) {
           System.out.println("Thread ex" +  ex.getMessage());
       }
    }

    public void start () {
        if (t == null) {
            t = new Thread (this, threadName);
            t.start ();
        }
    }
}
