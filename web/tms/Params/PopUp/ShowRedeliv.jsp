<%-- 
    Document   : ShowRedeliv
    Created on : Sep 24, 2018, 3:01:10 PM
    Author     : dwi.oktaviandi
--%>
<%@include file="../appGlobal/pageTop.jsp"%>
<%@page import="com.fz.tms.params.model.DODetil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%run(new com.fz.tms.params.PopUp.ShowRedelivController());%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../appGlobal/headTop.jsp"%>
    </head>
    <body>
        <%@include file="../appGlobal/bodyTop.jsp"%>
        
        <br>
        <h4>Report Redelive
            <span class="glyphicon glyphicon-refresh hover" aria-hidden="true" onclick="location.reload();"></span>
        </h4>
        <br>
        <label class="fzLabel">Branch:</label> 
        <label class="fzLabel" id="branch"><%=get("branch")%></label>
        
        <br>
        <label class="fzLabel">RunID:</label> 
        <label id="RunIdClick" class="fzLabel"><%=get("runId")%></label>
        
        <br>
        <br>
        <table id="table">
            <thead>
                <tr style="background-color:orange">
                    <th width="100px" class="center">Customer</th>
                    <th width="100px" class="center">DO</th>
                    <th width="100px" class="center">Description</th>
                    <th width="100px" class="center">Qty</th>
                    <th width="100px" class="center"></th>
                </tr>
            </thead>
            <tbody>
                <%for (DODetil j : (List<DODetil>) getList("listCust")) { %> 
                <tr >
                    <td class="center"><%=j.Customer_ID%></td>
                    <td class="center"><%=j.DO_Number%></td>
                    <td class="center"><%=j.Product_Description%></td>
                    <td class="center"><%=j.DOQty%></td>
                    <td class="center"><%=j.DOQtyUOM%></td>
                </tr>
                <%}%>
            </tbody>
        </table>
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>
