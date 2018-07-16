/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.ffbv3.api.TMS;

import com.fz.generic.Db;
import com.fz.tms.params.model.OptionModel;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.Produces;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PUT;
import javax.ws.rs.core.MediaType;

/**
 * REST Web Service
 *
 * @author dwi.oktaviandi
 */
@Path("HistoryAPI")
public class HistoryAPI {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of HistoryAPI
     */
    public HistoryAPI() {
    }

    /**
     * Retrieves representation of an instance of com.fz.ffbv3.api.TMS.HistoryAPI
     * @return an instance of java.lang.String
     */
    @GET
    @Produces(MediaType.APPLICATION_XML)
    public String getXml() {
        //TODO return proper representation object
        throw new UnsupportedOperationException();
    }

    /**
     * PUT method for updating or creating an instance of HistoryAPI
     * @param content representation for the resource
     */
    @PUT
    @Consumes(MediaType.APPLICATION_XML)
    public void putXml(String content) {
    }
    
    @POST
    @Path("submit")
    @Produces(MediaType.APPLICATION_JSON)
    public String getDO(String content) {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String str = "ERROR";
        try {
            OptionModel he = gson.fromJson(content.contains("json")
                    ? decodeContent(content) : content, OptionModel.class);
            
            str = dell(he);

        } catch (Exception e) {
            str = "ERROR";
        }
        //TODO return proper representation object
        //throw new UnsupportedOperationException();
        String jsonOutput = gson.toJson(str);
        return jsonOutput;
    }
    
    public String dell(OptionModel op) throws Exception{
        String str = "ERROR";
        String sql = "delete from BOSNET1.dbo.TMS_History where NIK = '"+op.Display+"' and Pages = '"+op.Value+"'";
        try (
            Connection con = (new Db()).getConnection("jdbc/fztms");
            PreparedStatement psHdr = con.prepareStatement(sql
                    , Statement.RETURN_GENERATED_KEYS);
            )  {
            //con.setAutoCommit(false);
            //psHdr.executeUpdate();            
            //con.setAutoCommit(true);
            str = "OK";
            psHdr.close();
        }
        return str;
    }
    
    public static String decodeContent(String content) throws UnsupportedEncodingException {
        content = java.net.URLDecoder.decode(content, "UTF-8");
        content = content.substring(5);

        return content;
    }
}
