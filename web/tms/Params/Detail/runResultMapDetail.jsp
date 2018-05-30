<%-- 
    Document   : runResultMapDetail
    Created on : May 24, 2018, 2:21:56 PM
    Author     : dwi.oktaviandi
--%>

<%@include file="../../appGlobal/pageTop.jsp"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fz.tms.params.model.OptionModel"%>
<%run(new com.fz.tms.params.Detail.runResultMapDetailController());%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <style>            
            html, body {
                border: 0px;
                margin: 0px;
                padding: 0px;
            }
        </style>
    </head>
    <body> 
        <script src="../appGlobal/jquery.min.js?1"></script>        
        <%--<%@include file ="../appGlobal/bodyTop.jsp"%>--%>
        <input type="text" id="txt" value='<%=request.getAttribute("test")%>' hidden="true"/>
        <input type="text" id="channel" value='<%=request.getAttribute("channel")%>' hidden="true"/>
        <script>
            $(document).ready(function () {
                runMapAll();
            });
            
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
                //console.log("detikakhirb" + new Date().getTime());padding: 0px;
            }
        </script>        
        <script src='https://maps.googleapis.com/maps/api/js?key=<%=get("key")%>'></script>
        <div id="wrapper" style="width: 100%;height: 100vh;">
            <div id='map' style="width: 100%;height: 100%;"></div>
        </div>
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>

