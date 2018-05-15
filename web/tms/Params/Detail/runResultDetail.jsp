<%@page import="com.fz.util.FZUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../appGlobal/pageTop.jsp"%>
<%@page import="com.fz.tms.service.run.RouteJob"%>
<%run(new com.fz.tms.params.Detail.runResultDetailController());%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Jobs</title>
    </head>
    <body>
        <style>
            tr { 
                border-bottom: 2px solid lightgray;
            }
            
            .hover:hover {
               cursor: pointer; 
            }
            
            #wrapper {
                <%--position: absolute;--%>
                top:100px;
                bottom:0;
                left:0;
                right:0;
            }
            .cell {
                position:absolute;
                overflow: hidden;
            }
            .col1 {
                left:0;
                width:50px;
                border-right:2px black solid;
            }
            .col2 {
                left:50px;
                right:0;
            }
            .row1 {
                top:0;
                height:50px;
                border-bottom: 2px black solid;
            }
            .row2 {
                top:50px;
                bottom:0;
            }
            #col-wrapper{
                bottom:17px;
            }
            #row-wrapper{
                right:17px;
            }
            #row, #col{
                position:relative;
            }
            #table{
                overflow: scroll;
            }
            th,tr {
                height: 50px;
            }
            th, td {
                border: 1px solid black;
                text-align: center;
                font-variant:small-caps;
            }


        </style>
        <%@include file="../appGlobal/bodyTop.jsp"%>
        
        <script>
            $(document).ready(function () {                
                //$('#table').eFreezeTableHead();
                tables();
                $('.vCodeClick').click(function () {
                    //Some code
                    //alert( $("#runID").text()+"&vCode="+$(this).text() ); 
                    if ($(this).text().length > 2) {
                        window.open("../map/GoogleDirMap.jsp?runID=" + $("#runID").val() + "&vCode=" + $(this).text(), null,
                                "scrollbars=1,resizable=1,height=530,width=530");
                        return true;
                    }
                });
                $('.custIDClick').click(function () {
                    //Some code
                    //alert( $(this).text() ); 
                    if ($(this).text().length > 0) {
                        window.open("../PopUp/popupDetilDOCust.jsp?custId=" + $(this).text() + "&runId=" + $("#runID").val(), null,
                                "scrollbars=1,resizable=1,height=500,width=750");
                        return true;
                    }
                });
            });
            
            function tables() {
                function scrollHandler(e) {
                    $('#row').css('left', -$('#table').get(0).scrollLeft);
                    $('#col').css('top', -$('#table').get(0).scrollTop);
                }
                $('#table').scroll(scrollHandler);
                $('#table').resize(scrollHandler);

                    var animate = false;
                $('#wrapper').keydown(function(event) {
                    if (animate) {event.preventDefault();};
                    if (event.keyCode == 37 && !animate) {
                        animate = true;
                        $('#table').animate({ scrollLeft: "-=200" }, "fast", function() {
                            animate = false;
                        });
                        event.preventDefault();
                    } else if (event.keyCode == 39 && !animate) {
                    animate = true;
                    $('#table').animate({ scrollLeft: "+=200" }, "fast", function() {
                        animate = false;
                    });
                    event.preventDefault();
                    } else if (event.keyCode == 38 && !animate) {
                    animate = true;
                    $('#table').animate({ scrollTop: "-=200" }, "fast", function() {
                        animate = false;
                    });
                    event.preventDefault();
                    } else if (event.keyCode == 40 && !animate) {
                    animate = true;
                    $('#table').animate({ scrollTop: "+=200" }, "fast", function() {
                        animate = false;
                    });
                    event.preventDefault();
                    }
                });
            }
            function klik(kode) {
                //alert('tes : ' + kode);
                window.open("../PopUp/popupEditCust.jsp?runId=" + $("#runID").val() + "&custId=" + kode, null,
                        "scrollbars=1,resizable=1,height=500,width=750");
            }
        </script>
        <input class="fzInput" id="runID" 
               name="runID" value="<%=get("runID")%>" hidden="true"/>
        <div id="cover" style="width: 100%;height: 100%">
            <div id="wrapper" tabindex="0">
                <div class="cell col1 row1">
                    <table>
                        <thead>
                            <tr style="background-color:orange;">
                                <th style="min-width: 50px" class="fzCol center">color</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div id="row-wrapper" class="cell col2 row1">
                    <div id="row">
                    <table>
                        <thead>
                            <tr style="background-color:orange;">
                                <th style="min-width: 30px" class="fzCol center">No.</th>
                                <th style="min-width: 180px" class="fzCol center">Truck</th>
                                <th style="min-width: 85px" class="fzCol center">CustID</th>
                                <th style="min-width: 45px" class="fzCol center">Arrv</th>
                                <th style="min-width: 55px" class="fzCol center">Depart</th>
                                <th style="min-width: 95px" class="fzCol center">DO</th>
                                <th style="min-width: 35px" class="fzCol center">Srvc Time</th>
                                <th style="min-width: 115px" class="fzCol center">Name</th>
                                <th style="min-width: 65px" class="fzCol center">Priority</th>
                                <th style="min-width: 35px" class="fzCol center">Dist Chl</th>
                                <th style="min-width: 110px" class="fzCol center">Street</th>
                                <th style="min-width: 55px" class="fzCol center">Weight (KG)</th>
                                <th style="min-width: 55px" class="fzCol center">Volume (M3)</th>
                                <th style="min-width: 40px" class="fzCol center">RDD</th>
                                <th style="min-width: 75px" class="fzCol center">Transport Cost</th>
                                <th style="min-width: 35px" class="fzCol center">Dist</th>
            <!--                    <th width="100px" class="fzCol">Send SAP</th>-->
                                <th width="100px" class="fzCol center" style="min-width: 35px">Edit</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                </div>
                <div id="col-wrapper" class="cell col1 row2">
                    <div id="col">
                        <table>
                            <tbody>
                                <%--for (RouteJob k : (List<RouteJob>) getList("JobList")) { %> 
                                    <tr><td class="fzCell" style="background-color: <%=k.color%>"></td></tr>
                                <%} // for ProgressRecord --%>
                                <%
                                    List<RouteJob> js = (List<RouteJob>) request.getAttribute("JobList");
                                    for(RouteJob category : js) {
                                        out.println("<tr style=\"height: 73px;\"><td  class=\"fzCell\" style=\"min-width: 50px; background-color: "+category.color+"\"></td></tr>");
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div id="table" class="cell col2 row2">
                    <table>
                        <tbody>
                            <%for (RouteJob j : (List<RouteJob>) getList("JobList")) { %> 
                                <tr 
                                    <%if (j.vehicleCode.equals("NA")) {%>
                                    style="height: 73px;color: red"
                                    <%} else if (j.arrive.length() == 0 && j.depart.length() > 0) {%>
                                    style="height: 73px;background-color: lightyellow"
                                    <%} else if (j.arrive.length() == 0 && j.name1.length() == 0) {%>
                                    style="height: 73px;background-color: #e6ffe6"
                                    <%} else {%>
                                    style="height: 73px;"
                                    <%}%> >
                                    <td class="fzCell center" style="min-width: 30px"><%=j.no%></td>
                                    <td class="vCodeClick center  hover" style="color: blue;min-width: 180px"><%=j.vehicleCode%></td>
                                    <td class="custIDClick center  hover" style="color: blue;min-width: 85px"><%=j.custID%></td>
                                    <td class="fzCell center" style="min-width: 45px"><%=j.arrive%></td>
                                    <td class="fzCell center" style="min-width: 55px"><%=j.depart%></td>                    
                                    <td class="fzCell center" style="<%if (j.bat == "1" ) {%> 
                                        background-color: #ffe6e6 <%}%>;min-width: 95px;" ><%=j.DONum%></td>
                                    <td class="fzCell center" style="min-width: 35px"><%=j.getServiceTime()%></td>
                                    <td class="fzCell center" style="min-width: 115px">
                                        <%if (j.arrive.length() > 0) {%>
                                        <a href="<%=j.getMapLink()%>" target="_blank"><%=j.name1%></a>
                                        <%} else {%><%=j.name1%><%}%>
                                    <td class="fzCell center" style="min-width: 65px"><%=j.custPriority%></td>
                                    <td class="fzCell center" style="min-width: 35px"><%=j.distrChn%></td>
                                    <td class="fzCell center" style="min-width: 110px"><%=j.street%></td>
                                    <td class="fzCell center" style="min-width: 55px"><%=j.weight%></td>
                                    <td class="fzCell center" style="min-width: 55px"><%=j.volume%></td>
                                    <td class="fzCell center" style="min-width: 40px"><%=j.rdd%></td>
                                    <td class="fzCell center" style="min-width: 75px"><%=j.transportCost%></td>
                                    <td class="fzCell center" style="min-width: 35px"><%=j.dist%></td>
                <!--                    <td class="fzCell" 
                                        <%if (j.send != null && (j.send.equalsIgnoreCase("OK") || j.send.equalsIgnoreCase("DELL"))) {%>
                                        onclick="sendSAP('<%=j.vehicleCode%>','<%=j.send%>')" style="color: green;"
                                        <%}%> ><%=j.send%></td>-->
                                    <td class="editCust center hover" onclick="klik(<%=j.custID%>)" style="color: blue;min-width: 35px"><%=j.edit%></td>
                                </tr>

                                <%} // for ProgressRecord %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>        
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>
