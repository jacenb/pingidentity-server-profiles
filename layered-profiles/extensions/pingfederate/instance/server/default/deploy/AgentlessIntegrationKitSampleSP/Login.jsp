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

	This SP Application page demonstrates SP-initiated SSO via the Login button.
--%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>PingFederate Agentless Integration Kit Sample : SP</title>
	<link href="css/stylesheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
<%@ include file="configuration.jsp" %>
	<div class="width">
		<div class="header">
			PingFederate Agentless Integration Kit Sample<br/>
			<div class="sp">Service Provider</div>
		</div>
		<div class="mainbody">
			<h1>SP Initiated SSO</h1>
			<div class="info">Demonstrate SP-initiated SSO.  Begin by pressing the Login button below.</div>
			<form action="<%=PF_BASE_URL + ":" + PF_PRIMARY_SSL_PORT + PF_START_SSO_ENDPOINT%>" method="get">
				<input class="submitButton" type="submit" value="Login" name="Login" />
				<input type="hidden" name="PartnerIdpId" value="<%=PARTNER_ENTITY_ID%>"/>
			</form>
		</div>
	</div>
</body>
</html>