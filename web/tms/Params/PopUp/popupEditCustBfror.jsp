<%-- 
    Document   : popupEditCustBfror
    Created on : Nov 13, 2017, 12:22:11 PM
    Author     : Administrator
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../../appGlobal/pageTop.jsp"%>
<%@page import="com.fz.tms.params.model.Customer"%>
<%run(new com.fz.tms.params.PopUp.popupEditCustBfror());%>
<!DOCTYPE html>
<html>
    <head>
        <style>
            .hover:hover {
                cursor: pointer; 
            }

            #wrapper {
                <%--position: absolute;--%>
                top: 100px;
                bottom: 0;
                left: 0;
                right: 0;              
            }

            .cell {
                <%--position: absolute;--%>
                overflow: hidden;
            }

            .col1 {
                left: 0;
                width: 100px;
                border-right: 2px black solid;
            }

            .col2 {
                left: 100px;
                right: 0;
            }


            .column1 {
                width: 80px;
            }

            .column2 {
                width: 100px;
            }

            .column3 {
                width: 150px;
            }

            .column4 {
                width: 150px;
            }

            .column5 {
                width: 65px;
            }

            .column6 {
                width: 60px;
            }

            .column7 {
                width: 80px;
            }

            .column8 {
                width: 70px;
            }

            .column9 {
                width: 60px;
            }

            .column10 {
                width: 60px;
            }

            .column11 {
                width: 160px;
            }

            .column12 {
                width: 40px;
            }

            .column13 {
                width: 50px;
            }

            .row1 {
                top: 0;
                height: 50px;
                border-bottom: 2px black solid;
            }

            .row2 {
                top: 50px;
                bottom: 0;
            }

            #col-wrapper {
                bottom: 17px;
            }

            #row-wrapper {
                right: 17px;
            }

            #row,
            #col {
                position: relative;
            }

            #table {
                overflow: scroll;
                height: 450px;
            }

            th,
            tr {
                height: 50px;
            }

            th,
            td {
                border: 1px solid black;
                text-align: center;
                font-variant: small-caps;
                <%--min-width: 150px;--%>
            }
            #exclude {
                float: right;
                font-size: 13px;
                margin-bottom: 5px;
            }
        </style>
    </head>
    <body >
        <div style="width: 100%; height: 700px;">
            <%@include file="../appGlobal/bodyTop.jsp"%>
            <%
                url = request.getRequestURL().toString();
                String str = url + "?" + request.getQueryString();
                str = str.replace("http://", "");
                str = str.replace(":", "9ETR9");
                str = str.replace(".", "9DOT9");
                str = str.replace("/", "9AK9");
                str = str.replace("?", "9ASK9");
                str = str.replace("&", "9END9");
                str = str.replace("=", "9EQU9");
                str = str.replace("-", "9MIN9");
                String urls = url + "?" + request.getQueryString();
            %>
            <div class="fzErrMsg" id="errMsg">
                <%=get("errMsg")%>
            </div>
            <h4>Customer Editor 
                <span class="glyphicon glyphicon-refresh hover" aria-hidden="true" onclick="location.reload();"></span>
                <span class="glyphicon glyphicon-list-alt hover" aria-hidden="true" onclick="saveHistory()"></span>
            </h4>

            <input type="hidden" value="<%=str%>" id="urls"/>
            <div style="float: left; width: 50%">
                <br>
                <label class="fzLabel">Branch:</label> 
                <label class="fzLabel" id="branch"><%=get("branchCode")%></label>

                <%--<br>
                <label class="fzLabel">Shift:</label> 
                <label class="fzLabel"><%=get("shift")%></label>--%>

                <br>
                <label class="fzLabel">Date Deliv:</label> 
                <label class="fzLabel" id="dateDeliv"><%=get("dateDeliv")%></label>

                <br>
                <label class="fzLabel">RunID:</label> 
                <label class="fzLabel" id="runId"><%=get("runId")%></label> 
            </div>
            <div style="float: left; width: 50%">
                <br>
                <label class="fzLabel">Ori RunID:</label> 
                <label class="fzLabel" id="oriRunID"><%=get("oriRunID")%></label> 

                <%--<br>
                <label class="fzLabel" hidden="true">Prev RunID:</label> 
                <label class="fzLabel" id="reRun" hidden="true"><%=get("reRun")%></label> --%>

                <input type="hidden" value='<%=get("reRun")%>' id="reRun"/>

                <br>
                <label class="fzLabel">Channel:</label> 
                <label class="fzLabel" id="channel"><%=get("channel")%></label> 

                <br>
                <label class="fzLabel hover" id="re_Run" style="color: blue;">Routing</label>
                <label class="fzLabel hover" id="Vvehicle" style="color: blue;" onclick="Vklik();">Vehicle</label>
                <%--<input id="clickMe" class="btn fzButton" type="button" value="Manual Route" onclick="openManualRoutePage();" />--%>
            </div>

            <br>
            <div style="width: 100%"> 

            </div>
            <input style="" type="text" id="myInput" onkeyup="myFunction()" placeholder="Search..." title="Type in a name">
            <input id="exclude" class="btn fzButton" type="button" value="Exclude Selected" onclick="exlcudeViaCheckBox();" />
            <br><br>                
            <div style="width: 100%">                
                <div id="wrapper" tabindex="0">
                    <%--<div class="cell col1 row1">
                        <table>
                            <thead>
                                <tr>
                                    <th>IR</th>
                                </tr>
                            </thead>
                        </table>
                    </div>--%>
                    <div id="row-wrapper" class="cell col2 row1">
                        <div id="row">
                            <table style="width: 100%">
                                <thead>
                                    <tr style="background-color:orange;">
                                        <th onclick="sortTable(0)" class="text-center column1" style="">customer id</th>
                                        <th onclick="sortTable(1)" class="text-center column2" style="">do number</th>
                                        <th onclick="sortTable(2)" class="text-center column3" style="">long</th>
                                        <th onclick="sortTable(3)" class="text-center column4" style="">lat</th>
                                        <th onclick="sortTable(4)" class="text-center column5" style="">priority</th>
                                        <th onclick="sortTable(5)" class="text-center column6" style="">Channel</th>
                                        <th onclick="sortTable(6)" class="text-center column7" style="">RDD</th>
                                        <th onclick="sortTable(7)" class="text-center column8" style="">service time</th>
                                        <th onclick="sortTable(8)" class="text-center column9" style="">deliv start</th>
                                        <th onclick="sortTable(9)" class="text-center column10" style="">deliv end</th>
                                        <th onclick="sortTable(10)" class="text-center column11" style="">vehicle type list</th>
                                        <th onclick="sortTable(11)" class="text-center column12" style="">inc</th>
                                        <th onclick="sortTable(12)" class="text-center column13" style="">Edit</th>
                                        <th onclick="sortTable(13)" class="text-center column14" >remove</th>

                                    </tr>
                                </thead>
                            </table>
                        </div>
                    </div>
                    <%--<div id="col-wrapper" class="cell col1 row2">
                        <div id="col">
                            <table>
                                <tbody>
                                    <%for (Customer j : (List<Customer>) getList("CustList")) {%> 
                                    <tr><td></td></tr>
                                    <%} // for ProgressRecord %>
                                </tbody>
                            </table>
                        </div>
    </div>--%>
                    <div id="table" class="cell col2 row2">
                        <table id="myTable"style="width: 100%">
                            <tbody>
                                <%for (Customer j : (List<Customer>) getList("CustList")) {%> 
                                <tr >
                                    <td style="" class="custId column1"><%=j.customer_id%></td>
                                    <td style="" class="doNum column2"><%=j.do_number%></td>
                                    <td style="" class="column3"><%=j.lng%></td>
                                    <td style="" class="column4"><%=j.lat%></td>
                                    <td style="" class="column5"><%=j.customer_priority%></td>
                                    <td style="" class="column6"><%=j.channel%></td>
                                    <td style="" class="column7"><%=j.rdd%></td>
                                    <td style="" class="column8"><%=j.service_time%></td>
                                    <td style="" class="column9"><%=j.deliv_start%></td>
                                    <td style="" class="column10"><%=j.deliv_end%></td>
                                    <td style="" class="column11"><%=j.vehicle_type_list%></td>
                                    <td style="" class="column12"><%=j.isInc%></td>
                                    <td class="hover column13" onclick="klik('<%=j.customer_id%>')" style="width: 50px">

                                        <span class="glyphicon glyphicon-edit" aria-hidden="true"></span>
                                    </td>
                                    <!--<td class="hover" onclick="exclude('<%=j.customer_id%>','<%=j.do_number%>')" >
                                        <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
                                    </td>-->
                                    <td class="hover column14">
                                        <input type="checkbox" name="remove" value="remove" id="remove">
                                    </td>
                                </tr>

                                <%} // for ProgressRecord %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>            
            <%--<table cellpadding="0" cellspacing="0" border="0" class="datatable table table-striped table-bordered">
                <thead>
                    <tr style="background-color:orange">
                        <th width="100px" class="fzCol">customer id</th>
                        <th width="100px" class="fzCol">do number</th>
                        <th width="100px" class="fzCol">long</th>
                        <th width="100px" class="fzCol">lat</th>
                        <th width="100px" class="fzCol">customer priority</th>
                        <th width="100px" class="fzCol">Channel</th>
                        <th width="100px" class="fzCol">RDD</th>
                        <th width="100px" class="fzCol">service time</th>
                        <th width="100px" class="fzCol">deliv start</th>
                        <th width="100px" class="fzCol">deliv end</th>
                        <th width="100px" class="fzCol">vehicle type list</th>
                        <th width="100px" class="fzCol">inc</th>
                        <th width="100px" class="fzCol">Edit</th>
                        <th width="100px" class="fzCol">remove</th>
                    </tr>
                </thead>
                <tbody>
                    <%for (Customer j : (List<Customer>) getList("CustList")) {%> 
                    <tr >
                        <td class="fzCell" ><%=j.customer_id%></td>
                        <td class="fzCell" ><%=j.do_number%></td>
                        <td class="fzCell" ><%=j.lng%></td>
                        <td class="fzCell" ><%=j.lat%></td>
                        <td class="fzCell" ><%=j.customer_priority%></td>
                        <td class="fzCell" ><%=j.channel%></td>
                        <td class="fzCell" ><%=j.rdd%></td>
                        <td class="fzCell" ><%=j.service_time%></td>
                        <td class="fzCell" ><%=j.deliv_start%></td>
                        <td class="fzCell" ><%=j.deliv_end%></td>
                        <td class="fzCell" ><%=j.vehicle_type_list%></td>
                        <td class="fzCell" ><%=j.isInc%></td>
                        <td class="fzCell hover" onclick="klik('<%=j.customer_id%>')" >
                            <span class="glyphicon glyphicon-edit" aria-hidden="true"></span>
                        </td>
                        <td class="fzCell hover" onclick="exclude('<%=j.customer_id%>','<%=j.do_number%>')">
                            <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
                        </td>
                    </tr>

                    <%} // for ProgressRecord %>
                </tbody>
                <tfoot></tfoot>
            </table>--%>

            <script src="../appGlobal/jquery.dataTables.min.js"></script>
            <script src="../appGlobal/datatables.js"></script>
            <script >
                                        $(document).ready(function () {
                                            tables();
                                            $('input[type=checkbox]').each(function () {
                                                this.checked = false;
                                            });
                                            //setLength();
                                            /*$('.datatable').dataTable({
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
                                             });*/
                                            $('#re_Run').click(function () {
                                                //setTimeout(function () {
                                                //alert($("#urls").text());
                                                //var dateNow = $.datepicker.formatDate('yy-mm-dd', new Date());//currentDate.getFullYear()+"-"+(currentDate.getMonth()+1)+"-"+currentDate.getDate();
                                                //alert($('#dateDeliv').text() + '&branch=' + $('#branch').text() + '&runId=' + $("#runId").text() + '&oriRunID=' + $("#oriRunID").text()  + '&reRun=' + $("#reRun").text() + '&channel=' + $("#channel").text());
                                                //var win = window.open('../../run/runProcess.jsp?tripCalc=M&shift=1&dateDeliv=' + $('#dateDeliv').text() + '&branch=' + $('#branch').text() + '&runId=' + $("#runId").text() + '&oriRunID=' + $("#oriRunID").text()  + '&reRun=' + $("#reRun").text(), null);
                                                var win = window.location.replace('../../run/runProcess.jsp?shift=1&dateDeliv=' + $('#dateDeliv').text() + '&branch=' + $('#branch').text() + '&runId=' + $("#runId").text() + '&oriRunID=' + $("#oriRunID").text() + '&reRun=' + $("#reRun").val() + '&channel=' + $("#channel").text() + '&url=' + $("#urls").val());
                                                if (win) {
                                                    //Browser has allowed it to be opened
                                                    win.focus();
                                                }
                                                //}, 3000);
                                            });
                                        });

                                        function exlcudeViaCheckBox() {
                                            var found = false;
                                            var doNumber = "";
                                            $('#table').find('tr').each(function () {
                                                var row = $(this);
                                                if (row.find('input[type="checkbox"]').is(':checked')) {
                                                    found = true;
                                                    doNumber = doNumber.concat(row.find(".custId").html(), ",", row.find(".doNum").html(), ";");
                                                } else {

                                                }
                                            });
                                            if (!found) {
                                                alert("No data")
                                            } else {
                                                console.log(doNumber);
                                                exclude($("#runId").text(), doNumber);
                                            }
                                        }

                                        function klik(kode) {
                                            window.open('popupEditCust.jsp?runId=' + $('#runId').text() + '&custId=' + kode, null,
                                                    'scrollbars=1,resizable=1,height=500,width=750');

                                        }

                                        function Vklik() {
                                            window.open('ShowPreRouteVehicle.jsp?runId=' + $('#runId').text(), null,
                                                    'scrollbars=1,resizable=1,height=500,width=950');

                                        }

                                        function openManualRoutePage() {
                                            var win = window.open('../../run/runManualRoute.jsp?branch=' + $('#branch').text() + '&shift=' + $('#shift').text() + '&oriRunId=' + $('#runId').text() + '&channel=' + $('#channel').val());
                                            if (win) {
                                                //Browser has allowed it to be opened
                                                win.focus();
                                            }
                                        }

                                        function exclude(custId, doAndCustId) {
                                            var $apiAddress = '../../../api/popupEditCustBfror/excludeDO';
                                            var jsonForServer = '{\"runId\": \"' + custId + '\",\"data\":\"' + doAndCustId + '\",\"excInc\":\"exc\"}';
                                            var data = [];
                                            $.post($apiAddress, {json: jsonForServer}).done(function (data) {
                                                if (data == 'OK') {
                                                    alert('sukses');
                                                    //location.reload();
                                                } else {
                                                    alert('submit error');
                                                }
                                            });
                                        }

                                        function saveHistory() {
                                            var $apiAddress = '../../../api/popupEditCustBfror/savehistory';
                                            var jsonForServer = '{\"Value\": \"' + '<%=urls%>' + '\",\"NIK\":\"' + '<%=EmpyID%>' + '"}';
                                            var data = [];

                                            $.post($apiAddress, {json: jsonForServer}).done(function (data) {
                                                if (data == 'OK') {
                                                    alert('sukses');
                                                    //location.reload();
                                                } else {
                                                    alert('submit error');
                                                }
                                            });
                                        }
                                        function tables() {
                                            function scrollHandler(e) {
                                                $('#row').css('left', -$('#table').get(0).scrollLeft);
                                                $('#col').css('top', -$('#table').get(0).scrollTop);
                                            }
                                            $('#table').scroll(scrollHandler);
                                            $('#table').resize(scrollHandler);

                                            var animate = false;
                                            $('#wrapper').keydown(function (event) {
                                                if (animate) {
                                                    event.preventDefault();
                                                }
                                                ;
                                                if (event.keyCode == 37 && !animate) {
                                                    animate = true;
                                                    $('#table').animate({
                                                        scrollLeft: "-=200"
                                                    }, "fast", function () {
                                                        animate = false;
                                                    });
                                                    event.preventDefault();
                                                } else if (event.keyCode == 39 && !animate) {
                                                    animate = true;
                                                    $('#table').animate({
                                                        scrollLeft: "+=200"
                                                    }, "fast", function () {
                                                        animate = false;
                                                    });
                                                    event.preventDefault();
                                                } else if (event.keyCode == 38 && !animate) {
                                                    animate = true;
                                                    $('#table').animate({
                                                        scrollTop: "-=200"
                                                    }, "fast", function () {
                                                        animate = false;
                                                    });
                                                    event.preventDefault();
                                                } else if (event.keyCode == 40 && !animate) {
                                                    animate = true;
                                                    $('#table').animate({
                                                        scrollTop: "+=200"
                                                    }, "fast", function () {
                                                        animate = false;
                                                    });
                                                    event.preventDefault();
                                                }
                                            });
                                        }

                                        function setLength() {
                                            /*var table = document.getElementById("myTable");
                                             var tr = table.getElementsByTagName("tr");
                                             
                                             var rows = document.getElementById("myTable").rows[0].cells.length;
                                             var ty = 0;
                                             
                                             var td;
                                             
                                             //cek posisi data                     
                                             //collumn
                                             for (x = 0;x<rows;x++){
                                             //row
                                             for (i = 0; i < tr.length; i++) {
                                             td = tr[i].getElementsByTagName("td")[x];       
                                             var t = document.getElementsByTagName("td").rows[1].cells[1].offsetWidth;
                                             console.log(x + "|" + i + " " + t);
                                             }
                                             }*/
                                            var rows = document.getElementById("myTable").rows[0].cells.length;
                                            for (x = 0; x < rows; x++) {
                                                var footer = document.getElementsByTagName('td')[x];
                                                var header = document.getElementsByTagName('th')[x];

                                                var num = null;
                                                if (header.offsetWidth > footer.offsetWidth) {
                                                    num = header.offsetWidth + 'px';
                                                    footer.style.width = '200px';
                                                    num = header.offsetWidth + 'px';
                                                    console.log(header.offsetWidth + "|" + footer.offsetWidth + "header" + num);
                                                } else {
                                                    num = footer.offsetWidth + 'px';
                                                    header.style.width = num;
                                                    console.log(header.offsetWidth + "|" + footer.offsetWidth + "footer" + num);
                                                }
                                            }
                                        }

                                        function sortTable(n) {
                                            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
                                            table = document.getElementById("myTable");
                                            switching = true;
                                            //Set the sorting direction to ascending:
                                            dir = "asc";
                                            /*Make a loop that will continue until
                                             no switching has been done:*/
                                            while (switching) {
                                                //start by saying: no switching is done:
                                                switching = false;
                                                rows = table.getElementsByTagName("TR");
                                                /*Loop through all table rows (except the
                                                 first, which contains table headers):*/
                                                for (i = 0; i < (rows.length - 1); i++) {
                                                    //start by saying there should be no switching:
                                                    shouldSwitch = false;
                                                    /*Get the two elements you want to compare,
                                                     one from current row and one from the next:*/
                                                    x = rows[i].getElementsByTagName("TD")[n];
                                                    y = rows[i + 1].getElementsByTagName("TD")[n];
                                                    /*check if the two rows should switch place,
                                                     based on the direction, asc or desc:*/
                                                    if (dir == "asc") {
                                                        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    } else if (dir == "desc") {
                                                        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                                                            //if so, mark as a switch and break the loop:
                                                            shouldSwitch = true;
                                                            break;
                                                        }
                                                    }
                                                }
                                                if (shouldSwitch) {
                                                    /*If a switch has been marked, make the switch
                                                     and mark that a switch has been done:*/
                                                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                                                    switching = true;
                                                    //Each time a switch is done, increase this count by 1:
                                                    switchcount++;
                                                } else {
                                                    /*If no switching has been done AND the direction is "asc",
                                                     set the direction to "desc" and run the while loop again.*/
                                                    if (switchcount == 0 && dir == "asc") {
                                                        dir = "desc";
                                                        switching = true;
                                                    }
                                                }
                                            }
                                        }
                                        function myFunction() {
                                            var input, filter, table, tr, td, i;
                                            input = document.getElementById("myInput");
                                            filter = input.value.toUpperCase();
                                            table = document.getElementById("myTable");
                                            tr = table.getElementsByTagName("tr");

                                            var rows = document.getElementById("myTable").rows[0].cells.length;
                                            var ty = 0;
                                            //cek posisi data 
                                            //row
                                            for (i = 0; i < tr.length; i++) {
                                                //collumn
                                                for (x = 0; x < rows; x++) {
                                                    td = tr[i].getElementsByTagName("td")[x];
                                                    if (td) {
                                                        if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
                                                            ty = x;
                                                            //console.log(td.innerHTML.toUpperCase());
                                                        }
                                                    }
                                                }
                                            }

                                            //hilangkan yang tidak cocok
                                            //row
                                            for (i = 0; i < tr.length; i++) {
                                                td = tr[i].getElementsByTagName("td")[ty];
                                                if (td) {
                                                    if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
                                                        tr[i].style.display = "";
                                                    } else {
                                                        tr[i].style.display = "none";
                                                    }
                                                }
                                            }
                                        }
            </script>
        </div>
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>
