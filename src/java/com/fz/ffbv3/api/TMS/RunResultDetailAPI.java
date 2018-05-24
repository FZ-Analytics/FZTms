/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.ffbv3.api.TMS;

import com.fz.tms.params.Detail.runResultDetailController;
import com.fz.tms.params.model.RunResult;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.UnsupportedEncodingException;
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
 * @author dwi.oktaviandi
 */
@Path("RunResultDetail")
public class RunResultDetailAPI {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of RunResultDetailAPI
     */
    public RunResultDetailAPI() {
    }

    /**
     * Retrieves representation of an instance of com.fz.ffbv3.api.TMS.RunResultDetailAPI
     * @return an instance of java.lang.String
     */
    @GET
    @Produces(MediaType.APPLICATION_XML)
    public String getXml() {
        //TODO return proper representation object
        throw new UnsupportedOperationException();
    }

    /**
     * PUT method for updating or creating an instance of RunResultDetailAPI
     * @param content representation for the resource
     */
    @PUT
    @Consumes(MediaType.APPLICATION_XML)
    public void putXml(String content) {
    }
    
    @POST
    @Path("submit")
    @Produces(MediaType.APPLICATION_JSON)
    public String test(String content) {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        String str = "ERROR";
        try {
            runResultDetailController db = new runResultDetailController();
            RunResult he = gson.fromJson(content.contains("json")
                    ? decodeContent(content) : content, RunResult.class);
            str = db.exclude(he);

        } catch (Exception e) {
            str = "ERROR";
        }
        //TODO return proper representation object
        //throw new UnsupportedOperationException();
        String jsonOutput = gson.toJson(str);
        return jsonOutput;
    }
    
    public static String decodeContent(String content) throws UnsupportedEncodingException {
        content = java.net.URLDecoder.decode(content, "UTF-8");
        content = content.substring(5);

        return content;
    }
}
