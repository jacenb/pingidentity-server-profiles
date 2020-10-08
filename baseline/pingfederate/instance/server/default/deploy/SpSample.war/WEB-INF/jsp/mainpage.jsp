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
<%@ page import = "com.pingidentity.sample.util.URLUtil" %>
<%@ page import = "com.pingidentity.sample.sp.manage.ConfigManager" %>
<%@ page import = "com.pingidentity.sample.sp.manage.SampleAppConfig" %>
<%@ page import = "com.pingidentity.sample.sp.manage.SampleConstants" %>
<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.Properties" %>
<%@ page import = "java.util.*" %>
<%@ page import = "org.apache.commons.collections.MultiMap" %>
<%@ page import = "org.apache.commons.collections.map.MultiValueMap" %>
<%@ page import = "javax.servlet.http.HttpUtils,java.util.Enumeration" %>
<%@ page import = "com.pingidentity.sample.token.SampleAppOpenTokenHelper" %>
<%@ page import = "com.pingidentity.opentoken.TokenException" %>
<%@ page import = "com.pingidentity.opentoken.TokenExpiredException" %>

<%

    
    ConfigManager configManager = ConfigManager.getInstance();
    Properties spConfigProperties = null;
    if (configManager != null)
    {
        SampleAppConfig sampleAppConfig = configManager.getConfig();
        if (sampleAppConfig != null)
        {
            spConfigProperties = sampleAppConfig.getSpConfig();
        }
    }
    
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
    
    String spStartSLO = URLUtil.getSpSLOUrl();
    String sloErrorMsg = "Error+during+sp-initiated+SLO";
    String ssoErrorMsg = "Error+during+sp-initiated+SSO";
    
    String errorPageUrl = URLUtil.getSpErrorPageUrl();

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">

<HTML>
<HEAD>
    <META http-equiv=Content-Type content="text/html; charset=utf-8">
    <LINK media=screen href="<%=request.getContextPath()%>/images/main.css" type=text/css rel=stylesheet>
    <link href="<%=request.getContextPath()%>/images/favicon.ico" rel="shortcut icon" type="image/x-icon"/>
    <title>Java Integration Kit Sample Main</title>
    <script type="text/javascript" src="<%=request.getContextPath()%>/scripts/common.js"></script>

</HEAD>

    <body onload="createSSOLink('<%= errorPageUrl %>'); <% if (userInfo != null) { %> createSLOLink('<%=spStartSLO%>', '<%= errorPageUrl %>'); <% } %>">
        <div class="body-container">
            <div id="" class="ping-body-container">
                <div class="header-block">
                    
                    <div id="" class="header">SP Application</div>
                    <div id="" class="left-header"><a href="<%= URLUtil.getConfigOptionsUrl(request) %>">Configuration</a></div>
                    <div class="right-header">
                                <%  if (userInfo != null) { %>
                                    <a href="<%= URLUtil.getLocalLogoutUrl(request) %>">Local Logout</a>
                                <% } %>
                    </div>
                </div> <!-- header-block -->
                <form name="mainForm" action="<%= URLUtil.getActionWithParams(request) %>" method="POST" >
                    <div class="form-container">
                        <div class="sso-container">
                            <div class="ping-input">
                                <label class="ping-input-label">IdP Connections
                                    <div class="ping-input-container">
                                        <div class="select-wrapper">
                                            <select class="input-select" name="PartnerIdpId" id="PartnerIdpId" onchange="createSSOLink('<%= errorPageUrl %>')">
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
                            </div> <!-- ping-input -->

                            <div class="ping-input">
                                <label class="ping-input-label">SP Adapter Instances
                                    <div class="ping-input-container">
                                        <div class="select-wrapper">
                                            <select class="input-select" name="SpAdapterId" id="SpAdapterId">
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
                            </div> <!-- ping-input -->

                            <div class="ping-input">
                                <div class="ping-checkbox-container">
                                    <input type="checkbox" id="IsPassive" name="IsPassive" value="true"/>
                                </div>
                                <label class="ping-checkbox-label" for="IsPassive">Is Passive</label>
                            </div> <!-- ping-input -->

                            <div class="ping-input">
                                <div class="ping-checkbox-container">
                                    <input type="checkbox" id="ForceAuthn" name="ForceAuthn"/>
                                </div>
                                <label class="ping-checkbox-label" for="ForceAuthn">Force Authn</label>
                            </div> <!-- ping-input -->

                            <div class="ping-input">
                                <div class="ping-checkbox-container">
                                    <input type="checkbox" id="SsoInErrorResource" name="SsoInErrorResource" value="true" onchange="createSSOLink('<%= errorPageUrl %>');"/>
                                </div>
                                <label class="ping-checkbox-label" for="SsoInErrorResource">Use SSO "InErrorResource"</label>
                            </div> <!-- ping-input -->

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
                            </div> <!-- ping-input -->

                            <div class="sso-button-container">
                                    <input id="startSso" class="table-button" type="submit" name="cmd" value="Single Sign-On" />
                            </div> <!-- sso-button-container -->
                        </div> <!-- sso-container -->

                        <div class="attributes-container">
                            <div class="ping-input">
                                <label class="ping-input-label">User Attributes</label>

                                <%  if (userInfo != null) { %>


                                <table class="attributes-table">
                                    <%= DisplayUtil.writeHtmlUserAttributes(userInfo) %>
                                </table>
                            </div> <!-- ping-input -->


                            <div class="ping-input">
                                <div class="ping-checkbox-container">
                                    <input type="checkbox" id="SloInErrorResource" name="SloInErrorResource" value="true" onchange="createSLOLink('<%=spStartSLO%>', '<%= errorPageUrl %>');"/>
                                </div>
                                <label class="ping-checkbox-label" for="SloInErrorResource">Use SLO "InErrorResource"</label>
                            </div> <!-- ping-input -->

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
                            </div> <!-- ping-input -->

                            <div class="slo-button-container">
                                <input class="table-button" type="submit" name="cmd" value="Single Logout"/>
                            </div> <!-- slo-button-container -->

                            <% } else {%>
                            </div> <!-- ping-input -->

                            <div class="ping-input">
                                <div class="ping-input-container">No user is logged in.</div>
                            </div> <!-- ping-input -->
                            <% } %>

                        </div> <!-- attributes-container -->
                    </div> <!-- form-container -->
                </form>
            </div> <!-- ping-body-container -->

            <div class="ping-footer-container">
                <div class="ping-footer">
                    <div class="ping-credits"></div>
                    <div class="ping-copyright">Copyright © 2003-2018. Ping Identity Corporation. All rights reserved.</div>
                </div>
            </div> <!-- ping-footer-container -->

        </div> <!-- body-container -->
        
    </body>
</html>