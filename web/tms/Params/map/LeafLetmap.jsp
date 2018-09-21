<%-- 
    Document   : map
    Created on : Oct 24, 2017, 4:19:31 PM
    Author     : dwi.rangga
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../appGlobal/pageTop.jsp"%>
<%run(new com.fz.tms.params.map.LeafLetmap());%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.2.0/dist/leaflet.css" />

        <style>
            #mapContainer {
                position:absolute;
                top:0;
                right:0;
                bottom:0;
                left: 0;
            }
        </style>
    </head>
    <body>
        <input type="text" hidden="true" id="txt" value="<%=get("testMap")%>"/>
        <%@include file="../appGlobal/bodyTop.jsp"%>
        <div id="mapContainer"></div>
        <%--<script src="https://unpkg.com/leaflet@1.2.0/dist/leaflet.js"></script>
        <script src="AnimatedMarker.js"></script>--%>
        <script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js"></script>
        <script src="../appGlobal/AnimatedMarker.js"></script>
        <script type="text/javascript">
            var map = L.map('mapContainer').setView([-6.292103, 106.842926], 10);

            var layer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);

            var markers = document.getElementById("txt").value.toString();
            //alert(txt);
            
            for ( var i=0; i < markers.length; ++i )
            {
             var ic = 'http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|' + markers[i].clr + '|8|b|' + markers[i].lbl + '';
             var myIcon = L.icon({
               iconUrl: ic,
               iconSize: [29, 24],
               iconAnchor: [9, 21],
               popupAnchor: [0, -14]
             });

             L.marker( [markers[i].lat, markers[i].lng], {icon: myIcon} )
              .bindPopup( '<p>' + markers[i].name + '</p>' )
              .addTo( map );
            }          
            
        </script>
        <h1>Hello World!</h1>
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>
