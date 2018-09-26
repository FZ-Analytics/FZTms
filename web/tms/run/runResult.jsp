<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../appGlobal/pageTop.jsp"%>
<%@page import="com.fz.tms.service.run.RouteJob"%>
<%run(new com.fz.tms.service.run.RouteJobListing());%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../appGlobal/headTop.jsp"%>
    </head>
    <body style="height: 700px">
        <style>
            tr { 
                border-bottom: 2px solid lightgray;
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
            String str =  url + "?" + request.getQueryString();
            str = str.replace("http://","");
            str = str.replace(":","9ETR9");
            str = str.replace(".","9DOT9");
            str = str.replace("/","9AK9");
            str = str.replace("?","9ASK9");
            str = str.replace("&","9END9");
            str = str.replace("=","9EQU9");
            str = str.replace("-","9MIN9");
            String urls =  url + "?" + request.getQueryString();
        %>
        <input type="hidden" value="<%=str%>" id="urls"/>
        <link href="../appGlobal/eFreezeTable.css" rel="stylesheet">
        <script src="../appGlobal/eFreezeTable.js"></script>
        <script>
            $(document).ready(function () {                
                //$('#table').eFreezeTableHead();
                //runMapAll();
                $('.custIDClick').click(function () {
                    //Some code
                    //alert( $(this).text() ); 
                    if ($(this).text().length > 0) {
                        window.open("../Params/PopUp/popupDetilDOCust.jsp?custId=" + $(this).text() + "&runId=" + $("#RunIdClick").text(), null,
                                "scrollbars=1,resizable=1,height=500,width=750");
                        return true;
                    }
                });
                $('.vCodeClick').click(function () {
                    //Some code
                    //alert( $("#runID").text()+"&vCode="+$(this).text() ); 
                    if ($(this).text().length > 2) {
                        window.open("../Params/map/GoogleDirMap.jsp?runID=" + $("#RunIdClick").text() + "&vCode=" + $(this).text(), null,
                                "scrollbars=1,resizable=1,height=530,width=530");
                        return true;
                    }
                });
                $('#RunIdClick').click(function () {
                    //Some code
                    //alert( $("#runID").text()+"&vCode="+$(this).text() ); 
                    if ($(this).text().length > 0) {
                        window.open("../Params/PopUp/popupDetilRunId.jsp?runID=" + $("#RunIdClick").text() + "&oriRunID=" + $("#nextRunId").text() + "&flag=runResult" + "&branch=" + $("#branch").text(), null,
                                "scrollbars=1,resizable=1,height=500,width=850");
                        return true;
                    }
                });
                $('#mapAll').click(function () {
                    //Some code
                    //alert( $("#runID").text()+"&vCode="+$(this).text() ); 
                    if ($(this).text().length > 0) {
                        window.open("../Params/map/GoogleDirMapAllVehi.jsp?runID=" + $("#RunIdClick").text() + '&channel=' + $('#channel').text(), null,
                                "scrollbars=1,resizable=1,height=530,width=530");
                        return true;
                    }
                });

                $('#reRun').click(function () {
                    var dateNow = $.datepicker.formatDate('yy-mm-dd', new Date());//currentDate.getFullYear()+"-"+(currentDate.getMonth()+1)+"-"+currentDate.getDate();

                    var win = window.location.replace('runProcess.jsp?shift=1&dateDeliv=' + dateNow + '&branch=' + $('#branch').text() + '&runId=' + $("#RunIdClick").text() + '&oriRunID=' + $("#OriRunID").val() + '&reRun=A' + '&channel=' + $('#channel').text() + '&url=' + $("#urls").val(), '_blank');
                    if (win) {
                        //Browser has allowed it to be opened
                        win.focus();
                    }
                    //}, 3000);
                });
            });

            function openEditRoutePage() {
                var table = document.getElementById("table");

                var tableArr = [];
                /*for (var i = 1; i < table.rows.length; i++) {
                    var no = table.rows[i].cells[0].innerHTML; //no
                    var truck = table.rows[i].cells[1].innerHTML; //truck
                    var custId = "";
                    if ((table.rows[i].cells[1].innerHTML !== "") && (table.rows[i].cells[2].innerHTML === "") && (table.rows[i].cells[4].innerHTML !== "")) {
                        custId = "start" + "split";
                    } else {
                        custId = table.rows[i].cells[2].innerHTML + "split"; //custId
                    }
                    tableArr.push(
                            no,
                            truck,
                            custId
                            );
                }*/

                var win = window.open('runResultEdit.jsp?&OriRunID=' + $('#RunIdClick').text() + '&runId=' + $('#nextRunId').text() + '&channel=' + $('#channel').text() +
                        '&branch=' + $('#branch').text() + '&shift=' + $('#shift').text() + '&vehicles=' + $('#vehicles').text() + '&dateDeliv=' + $('#dateDeliv').text(),"Route Editor",'height=600,width=800');
                 //+ '&tableArr=' + tableArr);
                if (win) {
                    //Browser has allowed it to be opened
                    win.focus();
                }
            }

            function klik(kode) {
                //alert('tes : ' + kode);
                window.open("../Params/PopUp/popupEditCust.jsp?runId=" + $("#RunIdClick").text() + "&custId=" + kode, null,
                        "scrollbars=1,resizable=1,height=500,width=750");
            }

            function sendSAP(kode, kd) {
                if(kd == 'DELL'){
                    deletes(kode);
                }else{
                    send(kode);
                }                               
                //var data = [];
                
            }
            
            function deletes(kode){
                var $apiAddress = '';
                var jsonForServer = '';
                
                $apiAddress = '../../api/runResult/DeleteShipmentPlan';
                jsonForServer = '{\"RunId\": \"' + $("#RunIdClick").text() + '\",\"vehicle_code\":\"' + kode + '\"}';
                $.post($apiAddress, {json: jsonForServer}).done(function (data) {
                    if (data == 'OK') {                            
                        send(kode);
                    }else {
                        alert('submit Status error');
                    }
                });
            }
            
            function send(kode){
                $apiAddress = '../../api/submitToSap/submitToSap';
                jsonForServer = '{\"RunId\": \"' + $("#RunIdClick").text() + 'split' + $("#RunIdClick").text() + '\",\"vehicle_no\":\"' + kode + '\"}';
                $.post($apiAddress, {json: jsonForServer}).done(function (data) {
                    if(data == 'OK'){
                        //alert('data: ' + data + 'stat: ' + stat);
                        $apiAddress = '../../api/runResult/SubmitShipmentPlan';
                        jsonForServer = '{\"RunId\": \"' + $("#RunIdClick").text() + '\",\"vehicle_code\":\"' + kode + '\"}';

                        $.post($apiAddress, {json: jsonForServer}).done(function (data) {
                            if (data == 'OK') {
                                alert('sukses');
                                location.reload();
                            } else {
                                alert('submit Status error');
                            }
                        });
                    }else{
                        alert( 'submit SAP error' ); 
                    }
                }); 
            }

            function fnExcelReport()
            {
                //var t = document.getElementById('btnHi');
                //t.hidden = true;
                var tab_text = "<table border='2px'><tr bgcolor='#87AFC6'>";
                var textRange;
                var j = 0;
                tab = document.getElementById('t_table'); // id of table

                for (j = 0; j < tab.rows.length; j++)
                {
                    tab_text = tab_text + tab.rows[j].innerHTML + "</tr>";
                    //tab_text=tab_text+"</tr>";
                }

                tab_text = tab_text + "</table>";
                tab_text = tab_text.replace(/<A[^>]*>|<\/A>/g, "");//remove if u want links in your table
                tab_text = tab_text.replace(/<img[^>]*>/gi, ""); // remove if u want images in your table
                tab_text = tab_text.replace(/<input[^>]*>|<\/input>/gi, ""); // reomves input params

                var ua = window.navigator.userAgent;
                var msie = ua.indexOf("MSIE ");

                if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))      // If Internet Explorer
                {
                    txtArea1.document.open("txt/html", "replace");
                    txtArea1.document.write(tab_text);
                    txtArea1.document.close();
                    txtArea1.focus();
                    sa = txtArea1.document.execCommand("SaveAs", true, "Say Thanks to Sumit.xls");
                } else                 //other browser not tested on IE 11
                    sa = window.open('data:application/vnd.ms-excel,' + encodeURIComponent(tab_text));

                return (sa);
            }
            
            function Vklik() {
                window.open('../Params/PopUp/ShowPreRouteVehicle.jsp?runId=' + $('#RunIdClick').text() + '&stat=run', null,
                        'scrollbars=1,resizable=1,height=500,width=950');

            }
            function saveHistory() {
                var $apiAddress = '../../api/popupEditCustBfror/savehistory';
                var jsonForServer = '{\"Value\": \"' + '<%=urls%>' + '\",\"NIK\":\"' + '<%=EmpyID%>' + '"}';
                var data = [];

                $.post($apiAddress, {json: jsonForServer}).done(function (data) {
                    if(data == 'OK'){
                        alert( 'sukses' );
                        //location.reload();
                    }else{
                        alert( 'submit error' ); 
                    }
                });
            }
            function setSize() {
                var height = $(window).height();
                height = height + (height/2);
                alert(height);
                console.log($(window).height()+''+height);
                document.getElementById('cover').style.height= height;
                
                //document.getElementById('body').style.height= height;
            }
            
            function runMapAll() {
                console.log("detikawal" + new Date().getTime());
                var map = null;
                var infowindow = new google.maps.InfoWindow();
                var bounds = new google.maps.LatLngBounds();

                //label dibuat beda
                var labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                var labelx = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                var labelIndex = 0;
                var labelxIndex = 0;
                var tr = null;

                //The list of points to be connected
                var txt = document.getElementById("txt").value;
                //var markers = eval(txt);
                //alert(txt);
                var mark = null;
                var markers = JSON.parse(txt);

                var service = new google.maps.DirectionsService();
                var directionsTaskTimer;

                //    var map;
                function initialize() {
                    mark = markers[0];
                    var mapOptions = {
                        center: new google.maps.LatLng(
                                parseFloat(mark[0].lat),
                                parseFloat(mark[0].lng)),
                        zoom: 30,
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                    };

                    var infoWindow = new google.maps.InfoWindow();
                    map = new google.maps.Map(document.getElementById("map"), mapOptions);
                    var lat_lng = new Array();

                    
                    for (var a = 0; a < markers.length; a++) {
                        mark = null;
                        mark = markers[a];
                        labelIndex = 0;
                        //t = labelx[labelxIndex++ % labelx.length];
                        //sleep(a);
                        var nt = 1;
                        for (var i = 0; i < mark.length; i++) {
                            if ((i + 1) < mark.length && mark[i].jobNb != "0") {
                                var clr = mark[i].color;
                                var descriptionSrc = mark[i].description;
                                var src = new google.maps.LatLng(parseFloat(mark[i].lat),
                                        parseFloat(mark[i].lng));
                                var des = new google.maps.LatLng(parseFloat(mark[i + 1].lat),
                                            parseFloat(mark[i + 1].lng));
                                if(mark[i].jobNb == "-1"){
                                    tr = labels[labelIndex++ % labels.length];
                                    nt++;
                                    createMarker(src, descriptionSrc, -1, clr, mark[i].channel);

                                    tr = null;
                                    
                                    var descriptionDes = mark[i + 1].description;
                                }else{
                                    tr = labels[labelIndex++ % labels.length];
                                    
                                    createMarker(src, descriptionSrc, nt++, clr, mark[i].channel);

                                    tr = null;
                                    
                                    var descriptionDes = mark[i + 1].description;
                                    //createMarker(des, descriptionDes, tr, mark[i].color);
                                    //  poly.setPath(path);     

                                    //directionsTaskTimer = setInterval(function () {    
                                }            
                                recursive(src, des, a, i, clr);
                            }else if(mark[i].jobNb == "0"){
                                console.log(mark[i].jobNb);
                                var clr = mark[i].color;

                                //tr = labels[labelIndex++ % labels.length];
                                var src = new google.maps.LatLng(parseFloat(mark[i].lat),
                                        parseFloat(mark[i].lng));
                                var descriptionSrc = mark[i].description;
                                createMarker(src, descriptionSrc, 0, clr, mark[i].channel);
                            }
                        }

                        //sleep();
                    }
                    //console.log("final?" + new Date().getTime());
                    //service = new google.maps.DirectionsService();
                }

                function recursive(src, des, a, b, clr)
                {
                    //window.clearInterval(directionsTaskTimer);
                    //console.log("clearInterval " + directionsTaskTimer);
                    var d = new Date();
                    //console.log("route awal " + a + " ; " + b + " status: awal" + "detik " + d.getSeconds());                    
                    //sleep(a);
                    //console.log("send src " + src + " des " + des + " " + a + " " + b);
                    setTimeout(function () {
                        service.route({
                            origin: src,
                            destination: des,
                            travelMode: google.maps.DirectionsTravelMode.DRIVING
                        }, function (result, status) {
                            if (status === google.maps.DirectionsStatus.OK) {
                                //console.log("recieve src " + src + " des " + des + " " + a + " " + b);
                                var path = new google.maps.MVCArray();
                                var poly = new google.maps.Polyline({
                                    map: map,
                                    strokeColor: '#'+clr//,
                                            //strokeWidth : 1,
                                            //width : 1
                                });
                                for (var i = 0, len = result.routes[0].overview_path.length; i < len; i++) {
                                    path.push(result.routes[0].overview_path[i]);
                                }
                                poly.setPath(path);
                                map.fitBounds(bounds);

                                //console.log("line" + a +" ; " + b);
                            } else if (status == google.maps.DirectionsStatus.OVER_QUERY_LIMIT) {
                                //console.log("resend src " + src + " des " + des + " Status" + status);
                                //sleep(src, des);
                                recursive(src, des, a, b, clr);
                            }
                        });
                    }, 3000);
                }

                function createMarker(latLng, str, lbl, clr, channel) {
                    //alert(clr);
                    if(lbl > 0){
                        if(lbl == 1){
                            str = 'DEPO'; 
                            var pinImage = new google.maps.MarkerImage('http://chart.apis.google.com/chart?chst=d_map_xpin_icon&chld=pin|civic-building|ffffff|000000',
                                new google.maps.Size(21, 34),
                                new google.maps.Point(0, 0),
                                new google.maps.Point(10, 34));
                        }else if(lbl > 1){
                            var url = 'http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|';
                            var pinImage = new google.maps.MarkerImage(url+clr+'|8|b|'+(lbl-1),
                                new google.maps.Size(21, 34),
                                new google.maps.Point(0, 0),
                                new google.maps.Point(10, 34));
                        }
                        
                        var marker = new google.maps.Marker({
                            position: latLng,
                            map: map,
                            draggable: false,
                            icon: pinImage
                        });
                    }else if(lbl <= 0){
                        //untuk NA
                        var marker = new google.maps.Marker({position:latLng});
                        marker.setMap(map);
                    }
                    
                    bounds.extend(marker.getPosition());
                    google.maps.event.addListener(marker, "click", function (evt) {
                        infowindow.setContent(str);
                        infowindow.open(map, this);
                    });
                }
                //console.log("detikakhira" + new Date().getTime());
                google.maps.event.addDomListener(window, 'load', initialize());
                //console.log("detikakhirb" + new Date().getTime());
            }
            
            window.onload = function(){
                opensDetail();opensMap();
                //console.log(a.src);
                //alert(a.src);
            };
            
            function opensDetail() {
                var link = "../Params/Detail/runResultDetail.jsp?runID="+$("#RunIdClick").text()+"&OriRunID="+$("#OriRunID").val();
                $('#iframe1').attr('src', link);
            }
            
            function opensMap() {
                var link2 = "../Params/Detail/runResultMapDetail.jsp?runID="+$("#RunIdClick").text()+"&OriRunID="+$("#OriRunID").val();
                $('#iframe2').attr('src', link2);
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
        <h4>Routing Result 
            <span class="glyphicon glyphicon-refresh hover" aria-hidden="true" onclick="location.reload();"></span>
            <span class="glyphicon glyphicon-list-alt hover" aria-hidden="true" onclick="saveHistory()"></span>
        </h4>

        <label class="fzInput" id="nextRunId" hidden="true"><%=get("nextRunId")%></label>
        <label class="fzInput" id="dateDeliv" hidden="true"><%=get("dateDeliv")%></label>

        <input class="fzInput" id="OriRunID" 
               name="OriRunID" value="<%=get("OriRunID")%>" hidden="true"/>

        <div style="float: left; width: 50%">
            
            <br>
            <label class="fzLabel">RunID:</label> 
            <label class="fzLabel hover" id="RunIdClick" style="color: blue;"><%=get("runID")%></label> 
            
            <br>

            <br>
            <%--<label class="fzLabel" id="mapAll" style="color: blue;">Map</label>--%> 
            <label class="fzLabel hover" id="Vehicle" style="color: blue;" onclick="Vklik();">Vehicle</label>
            <label class="fzLabel hover" id="reRun" style="color: blue;">Re-Routing</label>
            <%--<label class="fzLabel hover" id="test" style="color: blue;" onclick="fnExcelReport()">Convert Excel</label>--%>

            <input id="clickMe" class="btn fzButton" type="button" value="Edit Route Manually" onclick="openEditRoutePage();" />   
            <input type="button" class="button" value="Show redelive" onclick="openRedelive();">
        </div>
        
        <div style="float: left; width: 50%">
            <br>
            <label class="fzLabel">Channel:</label> 
            <label class="fzLabel" id="channel"><%=get("channel")%></label>     
            
            <%--<br>
            <label class="fzLabel">Shift:</label> 
            <label class="fzLabel" id="shift"><%=get("shift")%></label>--%>
            
            <br>
            <label class="fzLabel">Branch:</label> 
            <label class="fzLabel" id="branch"><%=get("branch")%></label>      
            
            <br>
            <label class="fzLabel">Vehicles:</label> 
            <label class="fzLabel" id="vehicles"><%=get("vehicleCount")%></label>
        </div>
        
        <br><br><br><br><br><br>
        <div id="cover" style="width: 100%">
            <div id="thediv" style="float: left;width: 65%;"><%--overflow-y: scroll;--%>
                <div style="width: 100%; text-align: center"><a onClick="opensDetail()" class="hover" target="iframe1"><h4>Result Detail</h4></a></div>
                <div style="height: 500px; width: 100%;border-style: double">
                    <iframe name="iframe1" id="iframe1" src="" frameborder="0" height="100%" width="100%"></iframe>
                </div>
            </div>
            <div style="float: left;width: 35%;">
                <div style="width: 100%; text-align: center"><a onClick="opensMap()" class="hover" target="iframe2"><h4>MAP</h4></a></div>
                <%--<script src='https://maps.googleapis.com/maps/api/js?key=<%=get("key")%>'></script>
                <input type="text" id="txt" value='<%=request.getAttribute("test")%>' hidden="true"/>
                <div id="map" style="width: 100%;height: 500px;border-style: double"></div>--%>
                <div style="width: 100%;height: 500px;border-style: double;">
                    <iframe name="iframe2" id="iframe2" src="" allowfullscreen frameborder="0" height="100%" width="100%" scrolling="no"></iframe>
                </div>
            </div>
        </div>
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>
