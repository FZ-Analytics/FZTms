<%-- 
    Document   : hvsEstmList
    Created on : Sep 23, 2017, 5:07:33 AM
--%>

<%@page import="com.fz.util.FZUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../appGlobal/pageTop.jsp"%>
<%@page import="com.fz.tms.params.model.Branch"%>
<%run(new com.fz.tms.service.run.runEntry());%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../appGlobal/headTop.jsp"%>
    </head>
    <body>
        <%@include file="../appGlobal/bodyTop.jsp"%>
        <script>
        $( function() {
          $( "#dateDeliv" ).datepicker();
          $( "#dateDeliv" ).datepicker( "option", "dateFormat", "yy-mm-dd");
          $( "#dateDeliv" ).val(yyyymmddDate(new Date()));
        } );
        function br() {
            window.open('../Params/PopUp/CekShipment.jsp?branch=' + $('#branch').val(), null,
                    'scrollbars=1,resizable=1,height=500,width=950');

        }
        </script>
        <label style="float: right;" class="fzLabel"><a href="../usrMgt/logout.jsp">Log out</a></label>
        <br>
        
        <form class="container" action="runProcess.jsp" method="post">
            <div class="fzErrMsg">
                <%=get("errMsg")%>
            </div>
            <input class="fzInput" id="runId" 
                   name="runId" value="NA" hidden="true"/>
            <input class="fzInput" id="reRunId" 
                   name="reRun" value="N" hidden="true"/>
            <input class="fzInput" id="oriRunID" 
                   name="oriRunID" value="NA" hidden="true"/>

            <h4>Filter Intelligent Routing</h4>
            <br>
            <div>
                <div style="float: left; width: 50%">
                    <label class="fzLabel">Branch</label>
                    <%--<input class="fzInput" id="branch" 
                            name="branch" value="<%=WorkplaceID%>" readonly="true"/>--%>
                    <select class="fzInput" id="branch" name="branch">
                        <%for (Branch hd : (List<Branch>) getList("ListBranch")) { %>
                        <%--<%= makeOption(hd.branchId, hd.branchId, hd.name)%>--%>
                            <option value='<%=hd.branchId%>' <%if (hd.branchId.equals(WorkplaceID)) {%> selected="true" <%}%>><%=hd.branchId%> - <%=hd.name%></option>
                        <% } /* end for Branch Id */ %>
                    </select> 
                    <span class="glyphicon glyphicon-check" aria-hidden="true" onclick="br();"></span>

                    <br><br>            
                    <label class="fzLabel">Date Deliv</label>
                    <input class="fzInput" id="dateDeliv" 
                           name="dateDeliv" value=""/>

                    <br><br>
                    <label class="fzLabel">Shift</label>
                    <select class="fzInput" id="shift" name="shift" />
                        <option value="1">1</option>
                        <option value="2">2</option>
                    </select>

                    <br><br>
                    <label class="fzLabel">Channel</label>
                    <select class="fzInput" id="channel" name="channel" />
                        <option value="GT">GT</option>
                        <option value="MT">MT</option>
                        <option value="ALL">ALL</option>
                    </select>

                    <br><br>
                    <label class="fzLabel">Trip calculation</label>
                    <select class="fzInput" id="tripCalc" name="tripCalc" />
                        <option value="M">Distance based (faster process)</option>
                        <option value="G">Google's traffic based (longer, more precision)</option>
                    </select>
                </div>
                <div style="float: left; width: 50%">
                    <br><br>            
                    <label class="fzLabel">reDeliv</label>
                    <select class="fzInput" id="reDeliv" name="reDeliv" />
                        <option value="true">yes</option>
                        <option value="false" selected="true">no</option>                   
                    </select>
                    
                    <br><br>            
                    <label class="fzLabel">Max Distance</label>
                    <select class="fzInput" id="DefaultDistance" name="DefaultDistance" />
                        <option value="0">Unconstrain</option>
                        <option value="3">3</option>
                        <option value="5">5</option>
                        <option value="7" selected="true">7</option>
                        <option value="10">10</option>
                        <option value="15">15</option>
                        <option value="20">20</option>
                        <option value="25">25</option>                        
                    </select>
                    
                    <br><br>            
                    <label class="fzLabel">Speed</label>
                    <select class="fzInput" id="SpeedKmPHour" name="SpeedKmPHour" />
                        <option value="25" selected="true">25</option>
                        <option value="50">50</option>
                        <option value="75">75</option>
                        <option value="100">100</option>       
                    </select>
                    
                    <br><br>            
                    <label class="fzLabel">Buffer Time</label>
                    <select class="fzInput" id="buffTime" name="buffTime" />
                        <option value="2" selected="true">100%</option>
                        <option value="1.7">70%</option>
                        <option value="1.5">50%</option>
                        <option value="1.2">20%</option>
                        <option value="1">0%</option>
                    </select>
                    
                    <br><br><br>
                </div>
            </div>           

            <br><br>
            <button class="btn fzButton" type="submit" 
                    name="submit" value="run">Run</button>

        </form>         
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>
