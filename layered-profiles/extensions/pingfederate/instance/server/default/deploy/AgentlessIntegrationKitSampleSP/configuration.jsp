<%--************************************************************
* Copyright (C) 2012 Ping Identity Corporation                 *
* All rights reserved.                                         *
*                                                              *
* The contents of this file are subject to the terms of the    *
* PingFederate Agentless Integration Kit Users Guide.          *
************************************************************--%>

<%--
Define constants corresponding to PingFederate configuration.

This file is intended to be included by another JSP via <%@ include file="configuration.jsp" %>.  
See ShowAttributes.jsp for example.
--%>

<%@ page import="java.util.*" %><%--Needed for USERS HashMap. --%>

<%!
//PingFederate URLs and endpoints
private final static String PF_BASE_URL = "https://sso.test-win4.com";
private final static String PF_PRIMARY_SSL_PORT = "9031";
private final static String PF_SECONDARY_SSL_PORT = "9032"; // Must match PF setting.
private final static String PF_START_SSO_ENDPOINT="/sp/startSSO.ping"; 
private final static String PF_START_SSO_ENDPOINT_IDP = "/idp/startSSO.ping"; 

// ReferenceID Adapter configuration
private final static String  REFID_DROPOFF_URL = "/ext/ref/dropoff";
private final static String REFID_PICKUP_URL = "/ext/ref/pickup";
//private final static String REFID_INSTANCE_ID = "SPREFID";
private final static String REFID_INSTANCE_ID = "SPREFAL";
private final static String REFID_USERNAME = "spuser";
private final static String REFID_PASSWORD = "sppassword";
private final static boolean REFID_USE_BASIC_HTTP_AUTH = true;  // If false, use proprietary ping.uname and ping.pwd headers
private final static boolean CERTIFICATE_AUTHENTICATION = false;
private final static String  CLIENT_KEY_FILE_PATH = "C:\\opt\\Ping\\certificates\\sampleClientSSLCert.p12"; // Full pathname for PKCS12 (.p12) key file.
private final static String  CLIENT_KEY_FILE_PASSWORD = "Password1";
private final static String  SERVER_CERTIFICATE_PATH = "C:\\opt\\Ping\\certificates\\pfserver.crt";  // Full pathname to X.509 Server SSL cert file.
private final static boolean SKIP_HOSTNAME_VERIFICATION = true;

// Connection configuration
//private final static String PARTNER_ENTITY_ID = "IDP:REFID";
private final static String PARTNER_ENTITY_ID = "IDP:REFAL";

// List of defined users.  Key is user subject, value is a Map of user attributes.
private final static Map<String,Map<String,String>> USERS = 
	new HashMap<String,Map<String,String>>()
	{{
		put("7b5d3c15-b020-4628-8813-d117f8ec825e",  new HashMap<String,String>(){{ put("username", "7b5d3c15-b020-4628-8813-d117f8ec825e"); put("status", "Silver"); put("groups", "Users,Developers");}});
	  	put("5d2a2b6b-18c2-47c8-a84b-9078de87ae54", new HashMap<String,String>(){{ put("username", "5d2a2b6b-18c2-47c8-a84b-9078de87ae54"); put("status", "Bronze"); put("groups", "Admins,Network Admins");}});
	  	put("e3fa14a8-833d-40a3-abaf-7adde6e089dd",  new HashMap<String,String>(){{ put("username", "e3fa14a8-833d-40a3-abaf-7adde6e089dd"); put("status", "Gold"); put("groups", "User,Customer");}});
	}};

%>
