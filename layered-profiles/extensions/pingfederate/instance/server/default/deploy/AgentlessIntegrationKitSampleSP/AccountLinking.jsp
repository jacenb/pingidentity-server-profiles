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
	  > 1 - SelectUser.jsp        <- this page
	    2 - ConfirmAttributes.jsp  
		3 - SubmitToSP.jsp 

	This IdP Application page shows the user attributes for the selected user, lets the user modify them
	and submits them to the SubmitToSP page.
--%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>PingFederate Agentless Integration Kit Sample : Account Linking</title>
	<link href="css/stylesheet.css" rel="stylesheet" type="text/css" />
</head>

<%@ include file="configuration.jsp" %>
<% //Store resumePath.
   String resumePath = request.getParameter("resumePath"); %>
<body>
  <div class="width"> 
    <div class="header">
  		PingFederate Agentless Integration Kit Sample<br/>
		<div class="sp">Service Provider (SP) Application</div>
	</div>
    <div class="mainbody">
        <h1>Account Linking</h1>
        <div class="info">
        On sucessful Login the username will be sent to PingFederate to be stored in the Account Linking DB.<br/><br/>
        </div>

        <form action="PostAccountLinking.jsp" method="post">
		    <input type="hidden" name="resumePath" value="<%=resumePath%>">
  <table class="cell" style="margin-left: auto; margin-right: auto;">
    <tr>
      <td colspan=2 style="text-align: center;">
        <h1>Account Linking Login</h1>
        <hr class="cell"/>
      </td>
    </tr>
        <tr>
            <td align="right">Username:</td>
            <td>
        <select id="userName" name="userName" STYLE="width:150px">
		    <option value="7b5d3c15-b020-4628-8813-d117f8ec825e">7b5d3c15-b020-4628-8813-d117f8ec825e</option>
		    <option value="5d2a2b6b-18c2-47c8-a84b-9078de87ae54">5d2a2b6b-18c2-47c8-a84b-9078de87ae54</option>
		    <option value="e3fa14a8-833d-40a3-abaf-7adde6e089dd">e3fa14a8-833d-40a3-abaf-7adde6e089dd</option>
		</select>
            </td>
        </tr>
        <tr>                
            <td align="right">Password:</td>
            <td><input type="password" name="password" style="width:150px;"/></td>
        </tr>
        <tr>                
            <td></td><td><input type="Submit" value="Login"/></td>
        </tr>
      </table>    
        </form>
    </div>
  </div>
</body>
</html>