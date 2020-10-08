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
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@ page import = "com.pingidentity.sample.util.DisplayUtil" %>
<%@ page import = "com.pingidentity.sample.sp.manage.SampleConstants" %>

<%
    String resumePath = request.getParameter(SampleConstants.OTK_RESUME_PATH);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">
<HTML>

<HEAD>
    <TITLE>Java Integration Kit Sample Account Linking</TITLE>
    <META http-equiv=Content-Type content="text/html; charset=utf-8">
    <LINK media="screen" href="<%=request.getContextPath()%>/images/main.css" type=text/css rel=stylesheet>
    <link href="<%=request.getContextPath()%>/images/favicon.ico" rel="shortcut icon" type="image/x-icon"/>
    <script type="text/javascript" src="scripts/common.js"></script>
</HEAD>

<BODY>
    <div class="body-container">
        <div class="ping-body-container">
            <div class="header-block">
                <div class="header">SP Account Linking</div>
            </div>

            <%
                String errorMessage = request.getParameter("error");
                if (errorMessage != null) {
            %>
                    <div id="login-failure"><%= errorMessage %></div>
            <%
                }
            %>

            <div class="login-container">
                <form name="loginForm" method="post" action="<%=request.getContextPath()%>/MainPage?cmd=postloginaccountlink">
                     <% if (resumePath != null) { %>
                            <input type="hidden" name="<%= SampleConstants.OTK_RESUME_PATH %>" value="<%= resumePath %>">
                     <% } %>

                    <div class="ping-input">
                        <label class="ping-input-label">Username
                            <div class="ping-input-container">
                                <div class="ping-input-container login-tooltip">
                                    <input type="text" id="userName" name="userName" autofocus />
                                    <span class="login-tooltip-text">The IdP application's default users are "joe", "sarah" and "sp". They share a default password of "test". These values can be configured in the {spApplicationRoot}/config/pingfederate-sp-demo-users.props file.
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
                
                    <input type="hidden" name="action" value="login"/>
                </form>
            </div><!-- login-container -->
        </div> <!-- ping-body-container -->
        <div class="ping-footer-container">
            <div class="ping-footer">
                <div class="ping-credits"></div>
                <div class="ping-copyright">Copyright © 2003-2018. Ping Identity Corporation. All rights reserved.</div>
            </div>
        </div>
    </div> <!-- body-container -->


</BODY>
</HTML>

