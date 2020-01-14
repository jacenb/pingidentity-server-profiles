<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%--************************************************************
* Copyright (C) 2012 Ping Identity Corporation                 *
* All rights reserved.                                         *
*                                                              *
* The contents of this file are subject to the terms of the    *
* PingFederate Agentless Integration Kit Users Guide.          *
************************************************************--%>

<%--
	This page is part of the Agentless Integration Kit Sample which demonstrates the use of the kit.  

	The IdP Application pages are:
	    1 - SelectUser.jsp
	  > 2 - ConfirmAttributes.jsp  <- this page
		3 - SubmitToSP.jsp 

	This IdP Application page shows the user attributes for the selected user, lets the user modify them
	and submits them to the SubmitToSP page.
--%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>PingFederate Agentless Integration Kit Sample : IdP</title>
	<link href="css/stylesheet.css" rel="stylesheet" type="text/css" />
</head>

<%@ include file="configuration.jsp" %>
<% // Get user attributes from parameter 'user' and corresponding values from configuration.
   String subject = request.getParameter("user");
   String name = USERS.get(subject).get("name");
   String status = USERS.get(subject).get("status");
   String groups = USERS.get(subject).get("groups"); %>
<body>
  <div class="width"> 
    <div class="header">
  		PingFederate Agentless Integration Kit Sample<br/>
		<div class="idp">Identity Provider</div>
	</div>
    <div class="mainbody">
        <h1>Step 2 : Drop off Attributes</h1>
        <div class="info">
        The following attributes for the selected user will be sent to the Service Provider (SP) application during Single Sign On (SSO).<br/><br/>
        Click the Submit button to drop off the attributes in PingFederate and initiate SSO.
        </div>

        <form action="SubmitToSP.jsp" method="post">
            <table>
                <tr>
                    <th>Attribute Name</th>
                    <th>Attribute Value</th>
                </tr>
                <tr>
                    <td>subject</td>
                    <td><input type="text" name="subject" value="<%=subject%>"/></td>
                </tr>
                <tr>
                    <td class="attributes">name</td>
                    <td class="attributes" bgcolor="LightGray"><input type="text" name="name" value="<%=name%>"/></td>
                </tr>
                <tr>
                    <td class="attributes">status</td>
                    <td class="attributes" bgcolor="LightGray"><input type="text" name="status" value="<%=status%>"/></td>
                </tr>
                <tr>
                    <td class="attributes">groups</td>
                    <td class="attributes" bgcolor="LightGray"><input type="text" name="groups" value="<%=groups%>"/></td>
                </tr>
            </table>
            <br/>
            <input type="submit" value="Submit"/>
        </form>
    </div>
  </div>
</body>
</html>