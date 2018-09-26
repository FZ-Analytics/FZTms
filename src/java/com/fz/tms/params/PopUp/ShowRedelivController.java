/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.params.PopUp;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.model.DODetil;
import com.fz.util.FZUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 *
 * @author dwi.oktaviandi
 */
public class ShowRedelivController implements BusinessLogic {
    
    @Override
    public void run(HttpServletRequest request, HttpServletResponse response, PageContext pc) throws Exception {
        String runId = FZUtil.getHttpParam(request, "runId");
        String branch = FZUtil.getHttpParam(request, "branch");
        
        String sql = "SELECT distinct Customer_ID, DO_Number, RedeliveryCount, Product_Description, DOQty, DOQtyUOM FROM BOSNET1.dbo.TMS_PreRouteJob where RunId = '"+runId+"' and Is_Edit = 'edit' and Is_Exclude = 'inc' and RedeliveryCount <> '' and RedeliveryCount is not null";
        
        ArrayList<DODetil> alDo = new ArrayList<>();
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()){                   
                while (rs.next()) {                    
                    DODetil dd = new DODetil();
                    dd.Customer_ID = rs.getString("Customer_ID");
                    dd.DO_Number = rs.getString("DO_Number");
                    dd.Product_Description = rs.getString("Product_Description");
                    dd.DOQty = rs.getString("DOQty");
                    dd.DOQtyUOM = rs.getString("DOQtyUOM");
                    alDo.add(dd);
                }
                if(alDo.size() == 0){
                    DODetil dd = new DODetil();
                    dd.Customer_ID = "none";
                    dd.DO_Number = "none";
                    alDo.add(dd);
                }
            }
        }
        request.setAttribute("listCust", alDo);
        request.setAttribute("runId", runId);
        request.setAttribute("branch", branch);
    }
}