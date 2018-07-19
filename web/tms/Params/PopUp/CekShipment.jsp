<%-- 
    Document   : CekShipment
    Created on : Jul 13, 2018, 3:36:20 PM
    Author     : dwi.oktaviandi
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../../appGlobal/pageTop.jsp"%>
<%@page import="com.fz.tms.params.model.DODetil"%>
<%run(new com.fz.tms.params.PopUp.CekShipment());%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>CekShipment</title>
    </head>
    <body>
        <%@include file="../appGlobal/bodyTop.jsp"%>
        <script src="../appGlobal/jquery.dataTables.min.js"></script>
        <script src="../appGlobal/datatables.js"></script>
        <script >
            $(document).ready(function () {
                $('.datatable').dataTable({
                    "sPaginationType": "bs_normal"
                });
                $('.datatable').each(function () {
                    var datatable = $(this);
                    // SEARCH - Add the placeholder for Search and Turn this into in-line form control
                    var search_input = datatable.closest('.dataTables_wrapper').find('div[id$=_filter] input');
                    search_input.attr('placeholder', 'Search');
                    search_input.addClass('form-control input-sm');
                    // LENGTH - Inline-Form control
                    var length_sel = datatable.closest('.dataTables_wrapper').find('div[id$=_length] select');
                    length_sel.addClass('form-control input-sm');
                });
            });
        </script>
        <br>
        <br>
        <table cellpadding="0" cellspacing="0" border="0" class="datatable table table-striped table-bordered">
            <thead>
                <tr style="background-color:orange">
                    <th width="100px" class="fzCol">Customer_ID</th>
                    <th width="100px" class="fzCol">Customer Name</th>
                    <th width="100px" class="fzCol">DO_Number</th>
                    <th width="100px" class="fzCol">ShipPlant</th>
                    <th width="100px" class="fzCol">RDD</th>
                    <th width="100px" class="fzCol">Create Date</th>
                    <th width="100px" class="fzCol">Delivery</th>
                    <th width="100px" class="fzCol">StatusShip</th>
                    <th width="100px" class="fzCol">noShipSAP</th>
                    <th width="100px" class="fzCol">ResultShip</th>
                    <th width="100px" class="fzCol">GI</th>
                    <th width="100px" class="fzCol">POD</th>
                </tr>
            </thead>
            <tbody>
                <%for (DODetil j : (List<DODetil>) getList("DOList")) { %> 
                <tr>
                    <td class="fzCell"><%=j.Customer_ID%></td>
                    <td class="fzCell"><%=j.Name1%></td>                    
                    <td class="fzCell"><%=j.DO_Number%></td>
                    <td class="fzCell"><%=j.ShipPlant%></td>
                    <td class="fzCell"><%=j.RDD%></td>
                    <td class="fzCell"><%=j.createDate%></td>
                    <td class="fzCell"><%=j.DeliveryDeadline%></td>
                    <td class="fzCell"><%=j.StatusShip%></td>
                    <td class="fzCell"><%=j.noShipSAP%></td>
                    <td class="fzCell"><%=j.ResultShip%></td>
                    <td class="fzCell"><%=j.GoodsMovementStat%></td>
                    <td class="fzCell"><%=j.PODStatus%></td>
                </tr>
                <%} // for ProgressRecord %>
            </tbody>
        </table>
             
            
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>