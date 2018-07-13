/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.fz.tms.params.PopUp;

import com.fz.generic.BusinessLogic;
import com.fz.generic.Db;
import com.fz.tms.params.model.DODetil;
import com.fz.tms.service.run.RouteJob;
import com.fz.util.FZUtil;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 *
 * @author dwi.oktaviandi
 */
public class CekShipment  implements BusinessLogic {
    //DecimalFormat df = new DecimalFormat("##.0");
        
    @Override
    public void run(HttpServletRequest request, HttpServletResponse response
            , PageContext pc) throws Exception {
        String branch = FZUtil.getHttpParam(request, "branch");
        
        List<DODetil> ar = getData(branch);
        
        request.setAttribute("DOList", ar);
    }
    
    public List<DODetil> getData(String branch) throws Exception{
        List<DODetil> ar = new ArrayList<DODetil>();
        DODetil dos = new DODetil();
        
        String sql = "{call bosnet1.dbo.TMS_CekShipment(?)}";
        
        try (Connection con = (new Db()).getConnection("jdbc/fztms");
                java.sql.CallableStatement stmt =
                con.prepareCall(sql)) {
            stmt.setString(1, branch);
            try(ResultSet rs = stmt.executeQuery()){
                while (rs.next()) {
                    dos = new DODetil();
                    int i = 1;
                    
                    dos.Customer_ID = FZUtil.getRsString(rs, i++, "");
                    dos.Name1 = FZUtil.getRsString(rs, i++, "");
                    dos.DO_Number = FZUtil.getRsString(rs, i++, "");
                    dos.ShipPlant = FZUtil.getRsString(rs, i++, "");
                    dos.RDD = FZUtil.getRsString(rs, i++, "");
                    dos.DeliveryDeadline = FZUtil.getRsString(rs, i++, "");
                    dos.StatusShip = FZUtil.getRsString(rs, i++, "");
                    dos.noShipSAP = FZUtil.getRsString(rs, i++, "");
                    dos.ResultShip = FZUtil.getRsString(rs, i++, "");
                    dos.GoodsMovementStat = FZUtil.getRsString(rs, i++, "");
                    dos.PODStatus = FZUtil.getRsString(rs, i++, "");
                    ar.add(dos);
                }
            }
        }
        return ar;
    }
    
}
