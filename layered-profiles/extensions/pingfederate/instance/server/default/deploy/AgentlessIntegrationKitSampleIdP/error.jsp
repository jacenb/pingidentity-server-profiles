<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%--************************************************************
* Copyright (C) 2012 Ping Identity Corporation                 *
* All rights reserved.                                         *
*                                                              *
* The contents of this file are subject to the terms of the    *
* PingFederate Agentless Integration Kit Users Guide.          *
************************************************************--%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>PingFederate Agentless Integration Kit Sample : IdP</title>
	<link href="css/stylesheet.css" rel="stylesheet" type="text/css" />
</head>

<%-- This is an error page used to provide basic information to the user when something goes wrong with the sample.  
     More detailed information should be written to System.err. prior to forwarding to this page.--%>

<body>
  <div class="width">
    <div class="header">
  		PingFederate Agentless Integration Kit Sample<br/>
		<div class="idp">Identity Provider</div>
	</div>
    <div class="mainbody">
        <div class="error">
            Error: <%=request.getAttribute("errorMessage")%><br/>
            See standard error output for details.
        </div>
    </div>
  </div>
</body>
</html>