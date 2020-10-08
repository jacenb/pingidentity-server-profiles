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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.pingidentity.sample.idp.manage.SampleConstants" %>
<%@ page import = "com.pingidentity.sample.util.DisplayUtil" %>
<%@ page import = "java.util.*" %>

<%
    String resumePath = request.getParameter(SampleConstants.OTK_RESUME_PATH);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
    <META http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <LINK media="screen" href="<%=request.getContextPath()%>/images/main.css" type=text/css rel=stylesheet>
    <link href="<%=request.getContextPath()%>/images/favicon.ico" rel="shortcut icon" type="image/x-icon"/>
    <title>Java Integration Kit Sample Login</title>
    <script language="javascript">
        window.onload = function() {
            document.getElementById('userName').focus();
        }
    </script>
</head>

<body>


    <div class="body-container">
        <div class="ping-body-container">
        <div class="header-block">
        <div class="header">Identity Provider Login</div>
        </div>
        <%  String errorMessage = request.getParameter("error");
    if (errorMessage != null) {
%>
        <div class="login-failure"><%= errorMessage %></div>
<%
    }
%>
            <div class="login-container">
            <form method="post" action="<%=request.getContextPath()%>/MainPage?cmd=login">
                <% if (resumePath != null) { %>
                    <input type="hidden" name="<%= SampleConstants.OTK_RESUME_PATH %>" value="<%= resumePath %>">
                <% } %>

                    <div class="ping-input">
                        <label class="ping-input-label">Username
                        <div class="ping-input-container">
                            <div class="ping-input-container login-tooltip">
                                <input type="text" id="userName" name="userName" autofocus />
                                <span class="login-tooltip-text">The IdP application's default users are "joe", "sarah" and "idp". They share a default password of "test". These values can be configured in the {idpApplicationRoot}/config/pingfederate-idp-demo-users.props file.
                                </span>
                            </div>

                        </div>
                        </label>
                    </div>

                    <div class="ping-input">
                        <label class="ping-input-label">Password
                            <div class="ping-input-container">
                                <input type="password" id="password" name="password"/>
                            </div>
                        </label>
                    </div>

                    <div class="login-button-container">
                        <input id="login" class="table-button" type="submit" value="Login"/>
                    </div>
                </form>
            </div>
        </div>
            <div class="ping-footer-container">
                <div class="ping-footer">
                    <div class="ping-credits"></div>
                    <div class="ping-copyright">Copyright © 2003-2018. Ping Identity Corporation. All rights reserved.</div>
                </div>
            </div>
        </div>
    </div>
</BODY>
</html>
