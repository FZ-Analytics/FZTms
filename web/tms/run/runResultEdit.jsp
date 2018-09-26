<%@page import="com.fz.tms.params.model.Delivery"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../appGlobal/pageTop.jsp"%>
<%@page import="com.fz.tms.service.run.RouteJob"%>
<%run(new com.fz.tms.service.run.RouteJobListingResultEdit());%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../appGlobal/headTop.jsp"%>
    </head>
    <body>
        <style>
            td {
                border: 1px solid lightgray;
            }
            th {
                border: 1px solid black;
            }
            
            #oriRunId {
                display:none;
                visibility:hidden;
            }
            .menu {
                width: 170px;
                background-color: #FFFFFF;
                color: #000000;
                position:absolute;
                display: none;
                box-shadow: 0 0 5px #713C3C;
            }
            .menu ul {
                list-style: none;
                padding: 0;
                margin:0;
            }
            .menu ul {
                text-decoration: none;
            }
            .menu ul li {
                padding: 6%;
                background-color: #FFFFFF;
                color: #000000;
                font-size: 10px;
            }
            .menu ul li:hover {
                background-color: orange;
                color: black;
                cursor: pointer;
            }
            .hover:hover {
                cursor: pointer; 
            }
            .center {
                text-align: center;
            }
            .button {
                background-color: orange; /* Green */
                border: none;
                color: white;
                padding: 10px 25px;
                text-align: center;
                text-decoration: none;
                display: inline-block;
                font-size: 8px;
            }
        </style>
        <%@include file="../appGlobal/bodyTop.jsp"%>
        <%
            url = request.getRequestURL().toString();
            String urls = url + "?" + request.getQueryString();
        %>

        <script>
            var rowIdx = 0;
            var colorTop = "";
            var colorBottom = "";
            var vNoTop = "";
            var vNoBottom = "";
            var custIdTop = "";
            var custIdBottom = "";
            var arrOfRow = [];
            var klikStatus = 1;
            var vehicleCode = "";
            var arrSignedIndex = [];
            $(document).ready(function () {
                $('.custIDClick').click(function () {
                    if ($(this).text().length > 0) {
                        window.open("../Params/PopUp/popupDetilDOCust.jsp?custId=" + $(this).text() + "&runId=" + $("#OriRunID").val(), null,
                                "scrollbars=1,resizable=1,height=500,width=750");
                        return true;
                    }
                });
                $('.vCodeClick').click(function () {
                    if ($(this).text().length > 2) {
                        window.open("../Params/map/GoogleDirMap.jsp?runID=" + $("#RunIdClick").text() + "&vCode=" + $(this).text(), null,
                                "scrollbars=1,resizable=1,height=530,width=530");
                        return true;
                    }
                });
                $('#mapAll').click(function () {
                    if ($(this).text().length > 0) {
                        window.open("../Params/Detail/runResultMapDetail.jsp?runID=" + $("#RunIdClick").text() + '&channel=' + $('#channel').text(), null,
                                "scrollbars=1,resizable=1,height=530,width=530");
                        return true;
                    }
                });
                initContextMenu();
            });
            function initContextMenu() {
                klikStatus = 1;
                $(".tableRows").on("contextmenu", function (e) {
                    //prevent default context menu for right click
                    e.preventDefault();
                    rowIdx = this.rowIndex;
                    vNoTop = document.getElementById('table').rows[rowIdx - 1].cells[2].innerHTML;
                    vNoBottom = document.getElementById('table').rows[rowIdx + 1].cells[2].innerHTML;
                    colorTop = document.getElementById('table').rows[rowIdx - 1].cells[0].style.backgroundColor;
                    colorBottom = document.getElementById('table').rows[rowIdx + 1].cells[0].style.backgroundColor;
                    custIdTop = document.getElementById('table').rows[rowIdx - 1].cells[3].innerHTML;
                    custIdBottom = document.getElementById('table').rows[rowIdx + 1].cells[3].innerHTML;
                    arriveBottom = document.getElementById('table').rows[rowIdx + 1].cells[4].innerHTML;
                    var menu = $(".menu");
                    //hide menu if already shown
                    menu.hide();
                    //get x and y values of the click event
                    var pageX = e.pageX;
                    var pageY = e.pageY;
                    //position menu div near mouse cliked area
                    menu.css({top: pageY, left: pageX});
                    var mwidth = menu.width();
                    var mheight = menu.height();
                    var screenWidth = $(window).width();
                    var screenHeight = $(window).height();
                    //if window is scrolled
                    var scrTop = $(window).scrollTop();
                    //if the menu is close to right edge of the window
                    if (pageX + mwidth > screenWidth) {
                        menu.css({left: pageX - mwidth});
                    }
                    //if the menu is close to bottom edge of the window
                    if (pageY + mheight > screenHeight + scrTop) {
                        menu.css({top: pageY - mheight});
                    }
                    if (klikStatus === 1) {
                        $("#pasteAtTop").css("color", "grey");
                        $("#pasteAtBottom").css("color", "grey");
                        $("#cut").css("color", "black");
                        $("#switchHelper").css("color", "grey");
                        $("#switch").css("color", "black");
                    } else if (klikStatus === 2) {
                        $("#pasteAtTop").css("color", "black");
                        $("#pasteAtBottom").css("color", "black");
                        $("#cut").css("color", "grey");
                        $("#switchHelper").css("color", "grey");
                        $("#switch").css("color", "grey");
                    } else if (klikStatus === 3) {
                        $("#pasteAtTop").css("color", "grey");
                        $("#pasteAtBottom").css("color", "grey");
                        $("#cut").css("color", "grey");
                        $("#switchHelper").css("color", "black");
                        $("#switch").css("color", "grey");
                    }
                    //finally show the menu
                    menu.show();
                });
                $("html").on("click", function () {
                    $(".menu").hide();
                });
            }
            
            function rgb2hex(rgb) {
                rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
                function hex(x) {
                    return ("0" + parseInt(x).toString(16)).slice(-2);
                }
                return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
            }
            function switchTruck() {
                if (klikStatus === 1) {
                    vehicleCode = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                    var tableLength = document.getElementById('table').rows.length - 1;
                    for (var i = 0; i <= tableLength; i++) {
                        var currentVehicleCode = document.getElementById('table').rows[i].cells[2].innerHTML;
                        if (currentVehicleCode === vehicleCode) {
                            document.getElementById('table').rows[i].cells[2].style.color = 'orange';
                            $(document.getElementById('table').rows[i].cells[2]).fadeIn("fast").fadeOut("fast").fadeIn("fast").fadeOut("fast").fadeIn("fast").fadeOut("fast").fadeIn("fast");
                            arrSignedIndex.push(i);
                        }
                    }
                    klikStatus = 3;
                }
            }
            function switchHelper() {
                if (klikStatus === 3) {
                    switchWithThisTruck();
                    emptyArrSignedIndex();
                    klikStatus = 1;
                }
            }
            function switchWithThisTruck() {
                var vCode = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                for (var i = arrSignedIndex[0]; i < arrSignedIndex[arrSignedIndex.length - 1] + 1; i++) {
                    var currentVehicleCode = document.getElementById('table').rows[i].cells[2].innerHTML;
                    if (currentVehicleCode !== "") {
                        document.getElementById('table').rows[i].cells[2].style.color = 'blue';
                        document.getElementById('table').rows[i].cells[2].innerHTML = vCode;
                    }
                }
                var tableLength = document.getElementById('table').rows.length - 1;
                for (var i = 0; i <= tableLength; i++) {
                    var currentVehicleCode = document.getElementById('table').rows[i].cells[2].innerHTML;
                    if (currentVehicleCode !== "" && currentVehicleCode === vCode && arrSignedIndex.indexOf(i) === -1) {
                        document.getElementById('table').rows[i].cells[2].innerHTML = vehicleCode;
                    }
                }
            }
            function emptyArrSignedIndex() {
                while (arrSignedIndex.length > 0) {
                    arrSignedIndex.pop();
                }
            }
            function deleteRow() {
                vehicleCode = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                if (klikStatus === 1) {
                    //put data row to array
                    for (i = 0; i <= 17; i++) {
                        arrOfRow[i] = document.getElementById('table').rows[rowIdx].cells[i].innerHTML;
                    }
                    document.getElementById("table").deleteRow(rowIdx);
                    //remove break row: case 1
                    var nextVehicleCode = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                    var prevArrive = document.getElementById('table').rows[rowIdx - 1].cells[4].innerHTML;
                    try {
                        var nextDepart = document.getElementById('table').rows[rowIdx + 1].cells[5].innerHTML;
                        if (nextVehicleCode.length == 0 && prevArrive.length == 0 && nextDepart.length == 0) {
                            document.getElementById("table").deleteRow(rowIdx);
                        }
                    } catch (err) {
                        klikStatus = 2;
                        orderNo();
                    }
                    //remove break row: case 2
                    try {
                        var prevVehicleCode = document.getElementById('table').rows[rowIdx - 1].cells[2].innerHTML;
                        var prevPrevArrive = document.getElementById('table').rows[rowIdx - 2].cells[4].innerHTML;
                        try {
                            var currentDepart = document.getElementById('table').rows[rowIdx].cells[5].innerHTML;
                            if (prevVehicleCode.length == 0 && prevPrevArrive.length == 0 && currentDepart.length == 0) {
                                document.getElementById("table").deleteRow(rowIdx - 1);
                            }
                        } catch (err) {
                            klikStatus = 2;
                            orderNo();
                        }
                    } catch (err) {
                        
                    }
                }
                klikStatus = 2;
                orderNo();
            }
            function paste(s) {
                if (klikStatus === 2) {
                    var table = document.getElementById("table");
                    if (s === 'top') {
                        var row = table.insertRow(rowIdx);
                    } else {
                        var row = table.insertRow(rowIdx + 1);
                    }
                    for (i = 0; i <= 17; i++) {
                        //color row
                        if(i == 0) {
                            if (colorBottom === colorTop) {
                                var cell = row.insertCell(i);
                                cell.style.width = "30px";
                                cell.style.backgroundColor = colorBottom;
                            } else if(vNoBottom !== vNoTop) {
                                if(s === "top") {
                                    var cell = row.insertCell(i);
                                    cell.style.width = "30px";
                                    cell.style.backgroundColor = colorTop;
                                } else {
                                    if(vNoBottom.length > 0 && arriveBottom.length === 0) {
                                        var cell = row.insertCell(i);
                                        cell.style.width = "30px";
                                        cell.style.backgroundColor = colorTop;
                                    } else if(vNoBottom.length > 0) {
                                        var cell = row.insertCell(i);
                                        cell.style.width = "30px";
                                        cell.style.backgroundColor = colorBottom;
                                    } else {
                                        var cell = row.insertCell(i);
                                        cell.style.width = "30px";
                                        cell.style.backgroundColor = colorTop;
                                    }
                                }
                            }
                        }
                        //vehicle code row
                        else if (i == 2) {
                            var cell = row.insertCell(i);
                            //vehicle no row not empty
                            if (arrOfRow[i] !== "") {
                                //row move within the same vehicle no
                                if (vNoBottom === vNoTop) {
                                    //row move at different vehicle no
                                    if (vNoBottom !== arrOfRow[i]) {
                                        cell.innerHTML = vNoBottom;
                                        vehicleCode = vNoBottom;
                                    } else {
                                        cell.innerHTML = arrOfRow[i];
                                        vehicleCode = arrOfRow[i];
                                    }
                                }
                                //row move at the same vehicle no, but near break time
                                else if (vNoBottom === "" && vNoTop === arrOfRow[i] && custIdTop !== "") {
                                    cell.innerHTML = arrOfRow[i];
                                    vehicleCode = arrOfRow[i];
                                }
                                //row move at the same vehicle no, but near break time
                                else if (vNoTop === "" && vNoBottom === arrOfRow[i] && custIdBottom !== "") {
                                    cell.innerHTML = arrOfRow[i];
                                    vehicleCode = arrOfRow[i];
                                }
                                //row move between two different vehicle no
                                else if (vNoBottom !== vNoTop) {
                                    if (vNoTop === "NA") {
                                        if (s === "top") {
                                            cell.innerHTML = vNoTop;
                                            vehicleCode = vNoTop;
                                        } else {
                                            if (document.getElementById('table').rows[rowIdx].cells[2].innerHTML === "NA") {
                                                cell.innerHTML = "NA";
                                                vehicleCode = "NA";
                                            } else {
                                                cell.innerHTML = vNoBottom;
                                                vehicleCode = vNoBottom;
                                            }
                                        }
                                    } else if (vNoTop !== "Truck") {
                                        //row move between two different vehicle no and put at top
                                        if (s === "top") {
                                            cell.innerHTML = vNoTop;
                                            vehicleCode = vNoTop;
                                            if (vNoTop === "") {
                                                cell.innerHTML = document.getElementById('table').rows[rowIdx + 1].cells[2].innerHTML;
                                                vehicleCode = document.getElementById('table').rows[rowIdx + 1].cells[2].innerHTML;
                                            }
                                        }
                                        //row move between two different vehicle no and put at bottom
                                        else if (s === "bottom") {
                                            cell.innerHTML = vNoBottom;
                                            vehicleCode = vNoBottom;
                                            if (vNoBottom === "") {
                                                cell.innerHTML = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                                                vehicleCode = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                                            }
                                        }
                                    } else if (vNoTop === "Truck" && vNoBottom !== "NA") {
                                        if (s === "top") {
                                            cell.innerHTML = "NA";
                                            vehicleCode = "NA";
                                        } else {
                                            cell.innerHTML = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                                            vehicleCode = document.getElementById('table').rows[rowIdx].cells[2].innerHTML;
                                        }
                                    } else {
                                        cell.innerHTML = vNoBottom;
                                        vehicleCode = vNoBottom;
                                    }
                                } else {
                                    cell.innerHTML = vNoBottom;
                                    vehicleCode = vNoBottom;
                                }
                                cell.style.color = "blue";
                                cell.className = "vCodeClick";
                            } else {
                                row.style.backgroundColor = "#e6ffe6";
                            }
                            cell.style.textAlign = 'center';
                        }
                        //customer id row
                        else if (i == 3) {
                            var cell = row.insertCell(i);
                            cell.innerHTML = arrOfRow[i];
                            cell.style.color = "blue";
                            cell.className = "custIdClick";
                            cell.id = "custId";
                            cell.style.textAlign = 'center';
                        }
                        //edit row
                        else if (i == 17) {
                            var cell = row.insertCell(i);
                            cell.innerHTML = arrOfRow[i];
                            cell.style.color = "blue";
                            cell.className = "editCust";
                            cell.style.textAlign = 'center';
                        } else {
                            var cell = row.insertCell(i);
                            cell.innerHTML = arrOfRow[i];
                            cell.style.textAlign = 'center';
                        }
                    }
                    row.setAttribute('id', 'tableRow');
                    row.setAttribute('class', 'tableRows');
                }
                klikStatus = 1;
                initContextMenu();
                orderNo();
            }
            function orderNo() {
                var tableLength = document.getElementById('table').rows.length;
                var idx = 1;
                for (i = 0; i < tableLength; i++) {
                    //console.log(i+'|'+tableLength);
                    var currentVehicleCode = document.getElementById('table').rows[i].cells[2].innerHTML;
                    if (currentVehicleCode !== "NA") {
                        var custId = document.getElementById('table').rows[i].cells[3].innerHTML;
                        if (currentVehicleCode === vehicleCode && custId !== "") {
                            document.getElementById('table').rows[i].cells[1].innerHTML = idx;
                            idx++;
                        }
                    } else {
                        document.getElementById('table').rows[i].cells[1].innerHTML = "";
                    }
                }
            }
            function jumpToResult() {
                var table = document.getElementById("table");
                var tableArr2 = [];
                for (var i = 1; i < table.rows.length; i++) {
                    //var no = table.rows[i].cells[0].innerHTML; //no
                    var truck = table.rows[i].cells[2].innerHTML; //truck
                    var custId = "";
                    //if ((table.rows[i].cells[1].innerHTML !== "") && (table.rows[i].cells[2].innerHTML === "") && (table.rows[i].cells[4].innerHTML !== "")) {
                    //custId = "start" + "split";
                    var curArrv = table.rows[i].cells[4].innerHTML;
                    var curDepart = table.rows[i].cells[5].innerHTML;
                    var nextArrv = "";
                    var nextDepart = "";
                    var prevArrv = "";
                    var prevDepart = "";
                    if (i !== table.rows.length - 1) {
                        nextArrv = table.rows[i + 1].cells[4].innerHTML;
                        nextDepart = table.rows[i + 1].cells[5].innerHTML;
                    }
                    if (i !== 1) {
                        prevArrv = table.rows[i - 1].cells[4].innerHTML;
                        prevDepart = table.rows[i - 1].cells[5].innerHTML;
                    }
                    if (curArrv === "" && curDepart !== "" && nextArrv !== "" && nextDepart === "") {
                    } else if (curArrv !== "" && curDepart === "" && prevArrv === "" && prevDepart !== "") {
                    } else {
                        //custId = table.rows[i].cells[2].innerHTML + "split"; //custId
                        if ((table.rows[i].cells[2].innerHTML !== "") && (table.rows[i].cells[3].innerHTML === "") && (table.rows[i].cells[5].innerHTML !== "")) {
                            custId = "start" + "split";
                        } else {
                            custId = table.rows[i].cells[3].innerHTML + "split"; //custId
                        }
                        tableArr2.push(
                                //no,
                                truck,
                                custId
                                );
                    }
                }
                document.getElementById("submit").disabled = true;
                $("#submit").val('Loading...');
                var $apiAddress = '../../api/submitEditRouteJob/submitEditRouteJob';
                var jsonForServer = '{\"table\": \"' + tableArr2 + '\", \"runId\":\"' + $("#RunIdClick").text() + '\"}';
                $.post($apiAddress, {json: jsonForServer}).done(function (data) {
                    if (data == 'OK') {
                        console.log("OK");
                        document.getElementById("submit").disabled = false;
                        $("#submit").val('Edit');
                        var win = window.open('runResultEditResult.jsp?runId=' + $('#RunIdClick').text() + '&oriRunId=' + $('#OriRunID').val() + '&dateDeliv=' + $('#dateDeliv').val() + '&branchId=' + $('#branch').text() +
                                '&shift=' + $('#shift').text() + '&channel=' + $('#channel').text() + '&vehicle=' + $('#vehicles').text());// + '&array=' + tableArr2);
                        if (win) {
                            //Browser has allowed it to be opened
                            win.focus();
                        }
                    } else {
                        console.log("ERROR");
                        document.getElementById("submit").disabled = false;
                        $("#submit").val('Edit');
                        alert(data);
                    }
                });
            }
            function klik(kode) {
                window.open("../Params/PopUp/popupEditCust.jsp?runId=" + $("#RunIdClick").text() + "&custId=" + kode, null,
                        "scrollbars=1,resizable=1,height=500,width=750");
            }
            function saveHistory() {
                var $apiAddress = '../../api/popupEditCustBfror/savehistory';
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
            function openRedelive() {
                var win = window.open("../Params/PopUp/ShowRedeliv.jsp?runId=" + $("#RunIdClick").text() + "&branch=" + $('#branch').text() ,"Report Redelive",'height=500,width=400');
                 //+ '&tableArr=' + tableArr);
                if (win) {
                    //Browser has allowed it to be opened
                    win.focus();
                }
            }
        </script>
        <h4>Route Editor
            <span class="glyphicon glyphicon-refresh hover" aria-hidden="true" onclick="location.reload();"></span>
            <span class="glyphicon glyphicon-list-alt hover" aria-hidden="true" onclick="saveHistory()"></span>
        </h4>

        <input class="fzInput" id="OriRunID" name="OriRunID" value="<%=get("oriRunId")%>" hidden="true"/>
        <input class="fzInput" id="dateDeliv" name="dateDeliv" value="<%=get("dateDeliv")%>" hidden="true"/>

        <br>
        <label class="fzLabel">Branch:</label> 
        <label class="fzLabel" id="branch"><%=get("branch")%></label>

        <br>
        <label class="fzLabel">Channel:</label> 
        <label class="fzLabel" id="channel"><%=get("channel")%></label> 

        <br>
        <label class="fzLabel">Vehicles:</label> 
        <label class="fzLabel" id="vehicles"><%=get("vehicles")%></label>

        <br>
        <label class="fzLabel">RunID:</label> 
        <label id="RunIdClick" class="fzLabel"><%=get("runId")%></label>

        <br>
        <label class="fzLabel hover" id="mapAll" style="color: blue;">Map</label> 
        <input type="button" class="button" value="Show redelive" onclick="openRedelive();">

        <br><br>

        <table id="table">
            <thead>
                <tr style="background-color:orange">
                    <th width="100px" class="center">Color</th>
                    <th width="100px" class="center">No.</th>
                    <th width="100px" class="center">Truck</th>
                    <th width="100px" class="center">Cust. ID</th>
                    <th width="100px" class="center">Arrv</th>
                    <th width="100px" class="center">Depart</th>
                    <th width="100px" class="center">DO Count</th>
                    <th width="100px" class="center">Serv. Time</th>
                    <th width="100px" class="center">Name</th>
                    <th width="100px" class="center">Prty</th>
                    <th width="100px" class="center">Dist. Chl</th>
                    <th width="100px" class="center">Street</th>
                    <th width="100px" class="center">Kecamatan</th>
                    <th width="100px" class="center">Weight (KG)</th>
                    <th width="100px" class="center">Volume (M3)</th>
                    <th width="100px" class="center">RDD</th>
                    <th width="100px" class="center">Cost</th>
                    <th width="100px" class="center">Dist</th>
                    <th width="100px" class="center">Edit</th>
                </tr>
            </thead>
            <tbody>
                <%for (Delivery j : (List<Delivery>) getList("listDelivery")) { %> 
                <tr 
                    class="tableRows" id="tableRow"
                    <%if (j.vehicleCode.equals("NA")) {%>
                    style="color: red"
                    <%} else if (j.arrive.length() == 0 && j.depart.length() > 0) {%>
                    style="background-color: lightyellow"
                    <%} else if (j.arrive.length() == 0 && j.storeName.length() == 0) {%>
                    style="background-color: #e6ffe6"
                    <%} else if (j.bat == "1") {%>
                    style="background-color: #ffe6e6"
                    <%} else if (j.bat == "2") {%>
                    style="background-color: #FFFF66"
                    <%}%> >
                    <td class="color" style="width: 30px; background-color: <%=j.color%>"></td>
                    <td class="index center">
                        <%if (!j.no.equals("0")) {%>
                        <%=j.no%>
                        <%}%>
                    </td>
                    <td class="vCodeClick hover center" id="vehicleCode" style="color: blue; padding: 5px;"><%=j.vehicleCode%></td>
                    <td class="custIDClick hover center" id="custId" style="color: blue;"><%=j.custId%></td>
                    <td class="center"><%=j.arrive%></td>
                    <td class="center"><%=j.depart%></td>                    
                    <td class="center"><%=j.doNum%></td>
                    <td class="center">
                        <%if (!j.vehicleCode.equals("NA")) {
                            if (!j.serviceTime.equals("0")) {%>
                                <%=j.serviceTime%>
                            <%} else {
                                out.print("");
                            }
                        } else {
                            out.print("0");
                        }%>  
                    </td>
                    <td class="center" style="font-weight:bold;">
                        <%if (j.arrive.length() > 0) {%>
                            <a href="<%=j.getMapLink()%>" target="_blank"><%=j.storeName%></a>
                        <%} else {%>
                            <%=j.storeName%>
                        <%}%>
                    </td>
                    <td class="center">
                        <%if (!j.priority.equals("0")) {%>
                        <%=j.priority%>
                        <%} else {
                            out.print("");
                        }%>
                    </td>
                    <td class="center"><%=j.distChannel%></td>
                    <td class="center"><%=j.street%></td>
                    <td class="center"><%=j.kecamatan%></td>
                    <td class="center"><%=j.weight%></td>
                    <td class="center"><%=j.volume%></td>
                    <td class="center">
                        <%if (j.rdd != null) {%>
                            <%=j.rdd%>
                        <%} else {%>
                            <p></p>
                        <%}%>
                    </td>
                    <td class="center">
                        <%if (!j.custId.equals("")) {%>
                            <%=j.transportCost%>
                        <%} else {
                            out.print("");
                        }%>
                    </td>
                    <td class="center">
                        <%if (!j.custId.equals("")) {%>
                            <%=j.dist%>
                        <%} else {
                            out.print("");
                        }%>
                    </td>
                    <td class="editCust hover center" onclick="klik(<%=j.custId%>)" style="color: blue;">
                        <%if (j.doNum.length() > 0) {%>
                            edit
                        <%}%>
                    </td>
                </tr>
                <%}%>
            </tbody>
        </table>

        <br>
        <br>

        <div class="menu">
            <ul>
                <li id="cut" onclick="deleteRow()">Cut</li>
                <li id="switch" onclick="switchTruck()">Switch truck</li>
                <li id="switchHelper" onclick="switchHelper()">Switch with this truck</li>
                <li id="pasteAtTop" onclick="paste('top')">Paste at top of this row</li>
                <li id="pasteAtBottom" onclick="paste('bottom')">Paste at bottom of this row</li>
            </ul>
        </div>

        <input id="submit" class="btn fzButton" type="button" value="Edit" width="200" height="48" onclick="jumpToResult();" style="padding-left: 50px; padding-right: 50px; padding-bottom: 10px; padding-top: 10px; font-size: 16px" />

        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>