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
<%@ page import = "com.pingidentity.sample.util.DisplayUtil" %>
<%@ page import = "com.pingidentity.sample.util.URLUtil" %>
<%@ page import = "com.pingidentity.sample.idp.manage.ConfigManager" %>
<%@ page import = "com.pingidentity.sample.idp.manage.SampleAppConfig" %>
<%@ page import = "com.pingidentity.sample.idp.manage.SampleConstants" %>
<%@ page import = "java.util.*" %>
<%@ page import = "org.apache.commons.collections.MultiMap" %>
<%@ page import = "org.apache.commons.collections.map.MultiValueMap" %>
<%@ page import = "com.pingidentity.sample.token.SampleAppOpenTokenHelper" %>
<%@ page import = "com.pingidentity.opentoken.TokenException" %>
<%@ page import = "com.pingidentity.opentoken.TokenExpiredException" %>



<%

    response.setHeader("Cache-Control","no-cache");
    response.setHeader("Pragma","no-cache");
    response.setHeader("Expires","0");

    MultiMap userInfo = null;
    
    // First, check to see if the userInfo is in the local session.
    if (session != null)
    {
        userInfo = (MultiMap)session.getAttribute(SampleConstants.USER_INFO);
    }
    
    if (userInfo == null)
    {
        try
        {
            // Get user attributes from the OpenToken if the user has it
            SampleAppOpenTokenHelper sampleAppOpenTokenHelper = new SampleAppOpenTokenHelper();
            userInfo = sampleAppOpenTokenHelper.parseOpenToken(request, response);          
        }
        catch (TokenExpiredException tokenExpiredEx)
        {
            userInfo = null;
        }
        catch (TokenException tokenEx)
        {
            userInfo = null;
        }
    }
    
    String idpStartSLO = URLUtil.getIdpSLOUrl();
    String errorPageUrl = URLUtil.getIdpErrorPageUrl();

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">

<html>
    <head>
    <META http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <LINK media=screen href="<%=request.getContextPath()%>/images/main.css" type=text/css rel=stylesheet>
    <link href="<%=request.getContextPath()%>/images/favicon.ico" rel="shortcut icon" type="image/x-icon"/>
    <title>Java Integration Kit Sample Main Page</title>
    <script type="text/javascript" src="<%=request.getContextPath()%>/scripts/common.js"></script>
    
    </head>
    <body onload="createSSOLink('<%= errorPageUrl %>'); <% if (userInfo != null) { %> createSLOLink('<%=idpStartSLO%>', '<%= errorPageUrl %>'); <% } %>">
        <div class="body-container">
            <div id="" class="ping-body-container">
                <div class="header-block">
                    
                    <div id="" class="header">IdP Application</div>
                    <div id="" class="left-header"><a href="<%= URLUtil.getConfigOptionsUrl(request) %>">Configuration</a></div>
                    <div class="right-header">
                                <%  if (userInfo != null) { %>
                                    <a href="<%= URLUtil.getLocalLogoutUrl(request) %>">Local Logout</a>
                                <%  } else{ %>
                                <a href="<%= URLUtil.getLocalLoginUrl(request) %>">Local Login</a>
                                <%
                                    }
                                %>
                    </div>
                </div>
                <form name="mainForm" action="<%= URLUtil.getActionWithParams(request) %>" method="POST" >
                <div class="form-container">
                <div class="sso-container">

                        <%-- Generate the html for either the connections dropdown list which is built with a
                             web service call to PingFederate or display an error message. --%>
                        <div class="ping-input">
                            <label class="ping-input-label">SP Connections
                            <div class="ping-input-container">
                                <div class="select-wrapper">
                                    <select class="input-select" name="PartnerSpId" id="PartnerSpId" onchange="createSSOLink('<%= errorPageUrl %>')">
                                        <%
                                        List<String> connectionList = new ArrayList<String>();
                                        try {
                                            connectionList = DisplayUtil.writeHtmlConnectionListOrErrorMsg(request, response);
                                        }
                                        catch(Exception e){
                                            String errorMessage = e.getMessage();
                                            System.out.println(errorMessage);
                                        }
                                        for(int i=0;i<connectionList.size();i++){
                                            String connectionId = connectionList.get(i);
                                            String ssoUrl = URLUtil.getIdpStartSSOLink(connectionId, null, null);
                                        %>
                                            <option value="<%= ssoUrl %>"><%= connectionId %></option>
                                        <%
                                        }
                                        %>
                                    </select>
                                </div>
                            </div>
                            </label>
                        </div>

                        <div class="ping-input">
                            <label class="ping-input-label">Target URL
                            <div class="ping-input-container">
                                <input type="text" id="TargetResource" name="TargetResource"/>
                            </div>
                            </label>
                        </div>


                        <%-- Generate the html for either the adapters dropdown list which is built with a web service call to PingFederate or display an error message. --%>
                        <div class="ping-input">
                            <label class="ping-input-label">IdP Adapter Instances
                            <div class="ping-input-container">
                            <div class="select-wrapper">
                                <select class="input-select" name="IdpAdapterId" id="IdpAdapterId">
                                <%
                                List<String> adapterList = new ArrayList<String>();
                                try{
                                    adapterList = DisplayUtil.writeHtmlAdapterInstanceListOrErrorMsg(request, response);
                                } catch (Exception e) {
                                    String errorMessage = e.getMessage();
                                }

                                for(int i=0;i<adapterList.size();i++){
                                    String adapterName = adapterList.get(i);
                                
                                %>
                                    <option value ="<%= adapterName %>"> <%= adapterName %> </option>
                                <%
                                }
                                %>
                                </select>
                            </div>
                            </div>
                            </label>
                        </div>

                    <div class="ping-input">
                        <div class="ping-checkbox-container">
                            <input type="checkbox" id="SsoInErrorResource" name="SsoInErrorResource" value="true" onchange="createSSOLink('<%= errorPageUrl %>');"/>
                        </div>
                        <label class="ping-checkbox-label" for="SsoInErrorResource">Use SSO "InErrorResource"</label>
                    </div>

                    <div class="ping-input">
                        <label class="ping-input-label">Start SSO URL
                        <div class="ping-input-container">
                            <div class="sso-url-group sso-tooltip">
                              <input id="ssolink" class="sso-url" READONLY="true" type="text">
                              <span class="copy-sso-url-span">
                                <button class="copy-sso-url-btn" type="button" onclick="copySsoUrl();">
                                  <img class="copy-sso-url-icon" src="<%=request.getContextPath()%>/images/clippy.svg" alt="Copy to clipboard">
                                </button>
                                <span class="sso-tooltip-text">Copied!</span>
                              </span>
                            </div>
                        </div>
                        </label>
                    </div>

                    <div class="sso-button-container">
                            <input id="startSso" class="table-button" type="submit" name="cmd" value="Single Sign-On" />
                    </div>


                </div>
                    <div class="attributes-container">

                        <div class="ping-input">
                            <label class="ping-input-label">User Attributes</label>
                        
                        
                        <%  if (userInfo != null) { %>


                            <table class="attributes-table">
                                <%= DisplayUtil.writeHtmlUserAttributes(userInfo) %>
                            </table>
                        </div>

                        <div class="ping-input">
                            <div class="ping-checkbox-container">
                                <input type="checkbox" id="SloInErrorResource" name="SloInErrorResource" value="true" onchange="createSLOLink('<%=idpStartSLO%>', '<%= errorPageUrl %>');"/>
                            </div>
                            <label class="ping-checkbox-label" for="SloInErrorResource">Use SLO "InErrorResource"</label>
                        </div>

                        <div class="ping-input">
                            <label class="ping-input-label">Start SLO URL
                            <div class="ping-input-container">
                                <div class="sso-url-group">
                                  <input id="slolink" class="sso-url" READONLY="true" type="text">
                                  <span class="copy-slo-url-span">
                                    <button class="copy-slo-url-btn" type="button" onclick="copySloUrl();">
                                      <img class="copy-sso-url-icon" src="<%=request.getContextPath()%>/images/clippy.svg" alt="Copy to clipboard">
                                    </button>
                                    <span class="slo-tooltip-text">Copied!</span>
                                  </span>
                                </div>

                            </div>
                            </label>
                        </div>

                        <div class="slo-button-container">
                            <input class="table-button" type="submit" name="cmd" value="Single Logout"/>
                        </div>

                        

                        <% } else {%>
                        </div>
                        <div class="ping-input">
                                <div class="ping-input-container">No user is logged in.</div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </form>
        </div>
        <div class="ping-footer-container">
            <div class="ping-footer">
                <div class="ping-credits"></div>
                <div class="ping-copyright">Copyright © 2003-2018. Ping Identity Corporation. All rights reserved.</div>
            </div>
        </div>
    </div>
</body>
</html>


