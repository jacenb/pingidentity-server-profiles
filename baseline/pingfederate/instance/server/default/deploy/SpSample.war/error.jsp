 <%--
 *******************************************************************************
 * Copyright (C) 2010 Ping Identity Corporation All rights reserved.
 * 
 * This software is licensed under the Open Software License v2.1 (OSL v2.1).
 * 
 * A copy of this license has been provided with the distribution of this
 * software. Additionally, a copy of this license is available at:
 * http://www.pingidentity.com/license
 *  
 ******************************************************************************
 --%>

<%@ page import = "com.pingidentity.sample.util.URLUtil" %>

<html>
	<head>
	<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<LINK media=screen href="<%=request.getContextPath()%>/images/main.css" type=text/css rel=stylesheet>
	<link href="<%=request.getContextPath()%>/images/favicon.ico" rel="shortcut icon" type="image/x-icon"/>
	<title>Java Integration Kit Sample Error Page</title>
	
	</head>
<BODY>
    <div class="body-container">
        <div id="" class="ping-body-container">
            <div class="header-block">
                <div class="header">SP Error</div>
            </div>
            <div class="error-container">
                There was an error in the SP Sample Application. Please return with this link:<div style="text-align: center;"><a href="/SpSample/MainPage">SP Sample Application</a></div>
            </div>
        </div>
        <div class="ping-footer-container">
            <div class="ping-footer">
                <div class="ping-credits"></div>
                <div class="ping-copyright">Copyright © 2003-2018. Ping Identity Corporation. All rights reserved.</div>
            </div>
        </div>
    </div>


</BODY>
</HTML>