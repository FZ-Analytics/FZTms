<%-- 
    Document   : headTop
    Created on : Sep 3, 2018, 11:02:31 AM
    Author     : dwi.oktaviandi
--%>

<%@page import="com.fz.generic.PageTopUtils"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fz.util.FZUtil"%>
<%
    PageContext pc = pageContext;
    
    String title = "";    
    title = FZUtil.getHttpParam(request, "Title");
    if(title == null || title == ""){
        //if not first page
        //get title from session
        title = (String) pc.getSession().getAttribute("Title");      
    }else{
        //else first page
        //set title to session
        request.getSession().setAttribute("Title", title);
    }    
%>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="icon" href="../img/Favicon.ico" type="image/ico" sizes="16x16">
<title><%=title%></title>