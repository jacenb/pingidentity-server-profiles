<%--************************************************************
    * Copyright (C) 2012 Ping Identity Corporation                 *
    * All rights reserved.                                         *
    *                                                              *
    * The contents of this file are subject to the terms of the    *
    * PingFederate Agentless Integration Kit Users Guide.          *
    ************************************************************--%>
<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*"%>
<%@ page import="java.net.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.security.KeyManagementException"%>
<%@ page import="java.security.KeyStore"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>
<%@ page import="java.security.cert.Certificate"%>
<%@ page import="java.security.cert.CertificateException"%>
<%@ page import="java.security.cert.CertificateFactory"%>
<%@ page import="java.security.cert.X509Certificate"%>
<%@ page import="javax.net.ssl.*"%>
<%@ page import="org.apache.commons.codec.binary.Base64"%>
<%@ page import="org.json.simple.*"%>
<%@ page import="org.json.simple.parser.*"%>

<%--
    This page is part of the Agentless Integration Kit Sample which demonstrates the use of the kit.
    
    The IdP Application pages are:
    > 1 - SelectUser.jsp  <- this page
    2 - ConfirmAttributes.jsp
    3 - SubmitToSP.jsp
    
    This IdP Application page lets the user select a user from a list and submits to the ConfirmAttributes page.
    --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
        <title>PingFederate Agentless Integration Kit Sample : IdP</title>
        <link href="css/stylesheet.css" rel="stylesheet" type="text/css" />
    </head>
    <%@ include file="configuration.jsp"%>
    <body>
        <div class="width">
            <div class="header">
                PingFederate Agentless Integration Kit Sample<br />
                <div class="idp">Identity Provider</div>
            </div>
            <div class="mainbody">
                <h1>Step 1 : User Authentication</h1>
                <div class="info">
                    This is the Identity Provider (IdP) application that is responsible
                    for identifying and authenticating the user. A "real world"
                    application would require the user to login using some form of
                    authentication (e.g.: username and password).<br />
                    <br /> For the purpose of this sample, simply select a user from the
                    dropdown list and click the Login button. The resulting user
                    attributes will be read from local configuration.
                    <%
						// Store resumePath
						request.getSession(true).setAttribute("resumePath",request.getParameter("resumePath"));
                        String idpReferenceValue = request.getParameter("REF");
                        
                        if(idpReferenceValue != null)
                            {
                                Map<String,String> userAttributes = pickUpAttributesFromReferenceIdAdapter( idpReferenceValue );
                    %>
                    
                    
                    <div class="mainbody">
                        <div class="info">
                            The following attributes were sent by PingFederate as part of
                            current Authentication Policy.<br />
                            <br /> A "real world" IdP can leverage these for user identity and
                            perform addition authentication as required.
                        </div>
                        <br />
                        <table>
                            <tr>
                                <th>Attribute Name</th>
                                <th>Attribute Value</th>
                            </tr>
                            <%
                                for (Map.Entry<String, String> entry : userAttributes.entrySet()) {
                                    String key = entry.getKey();
                                    String value = entry.getValue();
                                %>
                            <tr>
                                <td><%=key%></td>
                                <td><%=value%></td>
                            </tr>
                            <%
                                }
                                %>
                        </table>
                    </div>
                    <%
                        }
                        %>
                    
                </div>
                <form action="ConfirmAttributes.jsp" method="post">
                    Select User: <select name="user">
                        <% for(String username:USERS.keySet()) { %>
                        <option><%=username%></option>
                        <% } %>
                    </select> <input class="submitButton" type="submit" value="Login"
                    name="Login" />
                </form>
            </div>
        </div>
    </body>
</html>


<%!
    /** Pick up user attributes from the ReferenceID adapter using the the reference value received in the SSO request.
    *
    *  Uses URLConnection class to connect to ReferenceID adapter using HTTPS with a custom Trust Manager.
        *  This is for demonstration purposes only and SHOULD NOT BE USED IN PRODUCTION!
        *
        *  Authenticate to the Reference Adapter using username and password passed via ONE of:
        *     - HTTP Basic Authentication authorization header
        *     - Ping proprietary special request properties ping.uname and ping.pwd
        *
        *  In addition, can authenticate using SSL Certificate.
        *
        * @return Map of user attributes
        */
        private Map<String,String> pickUpAttributesFromReferenceIdAdapter(String referenceValue) throws Exception
        {
        
        // 1 - Get an SSL connection for the attribute pickup service - use secondary port if certificate authentication specified
        
        URL pickupUrl = new URL(PF_BASE_URL +":" + (CERTIFICATE_AUTHENTICATION ? PF_SECONDARY_SSL_PORT : PF_PRIMARY_SSL_PORT) + REFID_PICKUP_URL + "?REF="+referenceValue);
        URLConnection urlConnection = pickupUrl.openConnection();
        
        // 2 - Identify the adapter to use.  Need to do if more than one ReferenceID adapter defined.
        
        urlConnection.setRequestProperty("ping.instanceId", REFID_INSTANCE_ID);
        
        // 3 - Authenticate to the service using username and password passed either as HTTP Basic Auth header or propriatary properties
        
        if ( REFID_USE_BASIC_HTTP_AUTH )
        {
        // 3A - Authenticate using HTTP Basic Authentication; values Base64 encoded
        String basicAuth = REFID_USERNAME + ":" + REFID_PASSWORD;
        urlConnection.setRequestProperty("Authorization", "Basic " + org.apache.commons.codec.binary.Base64.encodeBase64String(basicAuth.getBytes()));
        }
        else
        {
        // 3B - Authenticate using "special" properties
        urlConnection.setRequestProperty("ping.uname", REFID_USERNAME);
        urlConnection.setRequestProperty("ping.pwd", REFID_PASSWORD);
        }
        
        // 4 - Authenticate using Certificate if specified
        
        if ( CERTIFICATE_AUTHENTICATION )
        {
        configureCertificateAuthentication( urlConnection );
        }
        else
        {
        acceptAllCertificates(urlConnection);
        }
        
        // 5 - Get user attributes from adapter service response as a JSON object.
        
        // Use UTF-8 if no encoding found in request.
        String encoding = urlConnection.getContentEncoding();
        InputStream is = urlConnection.getInputStream();
        InputStreamReader streamReader = new InputStreamReader(is, encoding != null ? encoding : "UTF-8");
        JSONParser parser = new JSONParser();
        //Map<String,String> attrs = new HashMap<String,String>();
        Map jsonMap = (Map)parser.parse(streamReader);
        return jsonMap;
        }
        
        /** Configure urlConnection to accept all certificates. DO NOT USE IN PRODUCTION! **/
        private void acceptAllCertificates(URLConnection urlConnection) throws Exception
        {
        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, new TrustManager[] { new SimpleTrustManager() }, null);
        SSLSocketFactory socketFactory = sslContext.getSocketFactory();
        HttpsURLConnection httpsURLConnection = (HttpsURLConnection) urlConnection;
        httpsURLConnection.setSSLSocketFactory(socketFactory);
        if (SKIP_HOSTNAME_VERIFICATION)
        {
        httpsURLConnection.setHostnameVerifier(new SimpleHostnameVerifier());
        }
        }
        
        
        /** Configure urlConnection to accept specified certificate. */
        private void configureCertificateAuthentication(URLConnection urlConnection) throws Exception
        {
        InputStream keyInput = new FileInputStream(CLIENT_KEY_FILE_PATH);
        KeyStore keyStore = KeyStore.getInstance("PKCS12");
        keyStore.load(keyInput, CLIENT_KEY_FILE_PASSWORD.toCharArray());
        keyInput.close();
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance("SunX509", "SunJSSE");
        keyManagerFactory.init(keyStore, CLIENT_KEY_FILE_PASSWORD.toCharArray());
        KeyManager[] keyManager = keyManagerFactory.getKeyManagers();
        
        InputStream certStream = new FileInputStream(SERVER_CERTIFICATE_PATH);
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        Certificate certificate = certStream != null ? cf.generateCertificate(certStream) : null;
        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(keyManager, new TrustManager[] { new SimpleTrustManager((X509Certificate) certificate) }, null);
        SSLSocketFactory socketFactory = sslContext.getSocketFactory();
        
        HttpsURLConnection httpsURLConnection = (HttpsURLConnection) urlConnection;
        httpsURLConnection.setSSLSocketFactory(socketFactory);
        if (SKIP_HOSTNAME_VERIFICATION)
        {
        httpsURLConnection.setHostnameVerifier(new SimpleHostnameVerifier());
        }
        }
        
        
        /**
        * A simple X509TrustManager that will check the server certificate if one is specified, else trust all. This trust manager can be constructed
        * with a single trusted server certificate which will be checked by checkServerTrusted(). By default, no trusted certificate is specified.
        *
        * DO NOT USE IN PRODUCTION!
        */
        class SimpleTrustManager implements X509TrustManager
            {
            private X509Certificate trustedCertificate = null;
            
            
            /** Default constructor specifies null certificate. **/
            public SimpleTrustManager()
            {
            }
            
            
            /** Constructor specifies a trusted certificate which can be null. **/
            public SimpleTrustManager(X509Certificate trustedCertificate)
            {
            this.trustedCertificate = trustedCertificate;
            }
            
            
            /** All client certificates are trusted. **/
            public void checkClientTrusted(X509Certificate[] x509Certificates, String string)
            {
            }
            
            
            /**
            * If trustedCertificate is not null, compare it with first element of testCertificates array.
            *
            * @param testCertificates
            *            certificate to test, only first element is used
            * @throws CertificateException
            *             if trustedCertificate does not match testCertificate[0]
            */
            public void checkServerTrusted(X509Certificate[] testCertificates, String string) throws CertificateException
            {
            if (trustedCertificate != null && !testCertificates[0].equals(trustedCertificate))
            {
            throw new CertificateException("Server cert does not match trusted certificate!");
            }
            }
            
            
            public X509Certificate[] getAcceptedIssuers()
            {
            return new X509Certificate[0];
            }
            }
            
            /** Simple HostnameVerifier implementation that accepts all hostnames. DO NOT USE IN PRODUCTION! **/
            public class SimpleHostnameVerifier implements HostnameVerifier
                {
                public boolean verify(String hostname, SSLSession session)
                {
                return true;
                }
                }
%>
