/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.params.model;

import java.sql.Timestamp;

/**
 *
 * @author Administrator
 */
public class RouteJobLog {
    public String jobId = "";
    public String custId = "";
    public String countDoNo = "";
    public String vehicleCode = "";
    public String activity = "";
    public int routeNb = 0;
    public int jobNb = 0;
    public String arrive = "";
    public String depart = "";
    public String runId = "";
    public Timestamp createTime;
    public String branch = "";
    public String shift = "";
    public String lon = "";
    public String lat = "";
    public String weight = "";
    public String volume = "";
    public int transportCost = 0;
    public double activityCost = 0;
    public double dist = 0;
    public String isFix = "";
    
    public String start;
    public String end;
    public String servicetime;
    public int times;
    public double costPerM;
    
    public String print(){
        System.out.println(jobId+"|"+custId+"|"+countDoNo+"|"+vehicleCode+"|"+activity+"|"+routeNb+"|"+jobNb+"|"+
                arrive+"|"+depart
                +"|"+runId+"|"+branch+"|"+shift+"|"+lon+"|"+lat+"|"+weight+"|"+volume
                +"|"+transportCost+"|"+activityCost+"|"+dist
        );
        return "";
    }
}
