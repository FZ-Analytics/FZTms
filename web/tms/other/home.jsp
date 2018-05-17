<%-- 
    Document   : home
    Created on : Apr 4, 2018, 1:42:42 PM
    Author     : dwi.oktaviandi
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.fz.generic.Db"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../appGlobal/pageTop.jsp"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
        <%@include file="../appGlobal/bodyTop.jsp"%>
        <form class="container" method="post">
            <br>
            <br>
            <label class="fzLabel">Name</label>
            <label class="fzLabel">: <%=UserName%></label>

            <br>
            <label class="fzLabel">Id</label>
            <label class="fzLabel">: <%=EmpyID%></label>

            <br>
            <label class="fzLabel">Branch</label>
            <%
                String str = "";
                try (Connection con = (new Db()).getConnection("jdbc/DB10")){            
                    try (Statement stm = con.createStatement()){

                        // create sql
                        String br = WorkplaceID;
                        br = br.length() == 0 ? "999" : br;
                        br = "where SalOffCode = '" + br + "'";
                        String sql ;
                        sql = "SELECT distinct SalOffCode, SalOffName FROM IBACONSOL.dbo.SALES_OFFICE "+br+" order by SalOffCode asc;";

                        // query
                        try (ResultSet rs = stm.executeQuery(sql)){
                            if (rs.next()){   
                                str = rs.getString("SalOffCode") + " - " + rs.getString("SalOffName");
                            }
                        }
                    }
                }
                catch (Exception e){
                    throw new Exception(e.getMessage());
                }
            %>
            <label class="fzLabel">: <%=str%></label>
        </form>
        <%@include file="../appGlobal/bodyBottom.jsp"%>
    </body>
</html>
