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

	This SP Application page completes the SSO from the IdP by retrieving the user attributes from the ReferenceID adapter
    and displaying them to the user.  The query parameter REF passes the reference value used to pickup the attribute values
    from the IdP.  
--%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>PingFederate Agentless Integration Kit Sample : SP</title>
	<link href="css/stylesheet.css" rel="stylesheet" type="text/css" />
</head>

<body>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.security.KeyManagementException" %>
<%@ page import="java.security.KeyStore" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.security.cert.Certificate" %>
<%@ page import="java.security.cert.CertificateException" %>
<%@ page import="java.security.cert.CertificateFactory" %>
<%@ page import="java.security.cert.X509Certificate" %>
<%@ page import="javax.net.ssl.*" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>
<%@ page import="org.json.simple.*" %>
<%@ page import="org.json.simple.parser.*" %>

<%@ include file="configuration.jsp" %>

 <div class="width">
     <div class="header">
   		PingFederate Agentless Integration Kit Sample<br/>
 		<div class="sp">Service Provider</div>
 	</div>

<%
	try
	{
		// 1 - Get the attribute reference value from the REF parameter.  
		
		String spReferenceValue = request.getParameter("REF");
		
		// 2 - Use reference value to retrieve attributes from adapter
		
		Map<String,String> userAttributes = pickUpAttributesFromReferenceIdAdapter( spReferenceValue );

		// 3 - Display the attributes 
%>			
	    <div class="mainbody">
	        <h1>Attribute Pick-up</h1>
	        <div class="info">Success!  The following user attributes were picked up from PingFederate by the SP application.<br/><br/>
	        A "real world" SP would now identify the user and create a session based on the received attributes.
	        </div>
	        <br/>
	        <table>
	            <tr>
					<th>Attribute Name</th>
					<th>Attribute Value</th>
				</tr>
				<tr>
					<td>subject</td>
					<td><%=userAttributes.get("subject")%></td>
				</tr>
				<tr>
					<td>username</td>
					<td><%=userAttributes.get("username")%></td>
				</tr>
				<!--<tr>
					<td>status</td>
					<td><%=userAttributes.get("status")%></td>
				</tr>
				<tr>
					<td>groups</td>
					<td><%=userAttributes.get("groups")%></td>
				</tr>-->
			</table>
		</div>
		<div class="header"></div>
		<div class="mainbody">
		<%-- 
			Commenting out the link to launch defederation (terminate account linking) since it 
			is not configured by default in the data.zip packaged with the Sample Applications.  
			With account linking not configured by default clicking on this link always leads to
			an error from PingFederate that is cryptic to most users.
--%>
			<div class=info>
			    To demenstrate Unlinking the User's Account, use <a href="https://sso.test-win4.com:9031/sp/defederate.ping">Unlink Account</a>
			</div>
        	<div class="info">
        		To demonstrate SP-initiated SSO, use the <a href="Login.jsp">SP Login Page</a>
        	</div>
        </div>
<%			
	}
	catch (Exception e)
	{
		// If something went wrong, log error and forward to error page.
		request.setAttribute("errorMessage", e.toString());
		System.err.println( ""+new Date()+" ShowAttributes.jsp caught exception: "+e );
		e.printStackTrace(System.err);
		getServletConfig().getServletContext().getRequestDispatcher("/error.jsp").forward(request, response);
		return;
	}
%>	
</div>

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
    JSONObject userAttributesJSON = (JSONObject)new JSONParser().parse(streamReader);
    if ( userAttributesJSON == null || userAttributesJSON.size() == 0 ) 
    	throw new Exception( "Problem retrieving attributes from adapter!");

	// 6 - Return attributes as a Map.  Make sure all attributes were provided.
	
	Map<String,String> userAttributes = new HashMap<String,String>();
	String subjectAttr = (String)userAttributesJSON.get( "subject");
	String usernameAttr = (String)userAttributesJSON.get( "username");	
	/**String statusAttr = (String)userAttributesJSON.get( "status");
	Object groupsObj = userAttributesJSON.get( "groups");
	String groupsAttr = groupsObj != null ? groupsObj.toString() : null;
	if(groupsObj instanceof List){
		groupsAttr = "";
		List<Object> multiValueAttr = (List) groupsObj;
		for(Object attr : multiValueAttr){
			if(attr instanceof String){
				groupsAttr = groupsAttr.concat(attr.toString() + " | ");
			}
		}
		groupsAttr = groupsAttr.substring(0, groupsAttr.length()-3);
	}**/

	if ( subjectAttr != null && usernameAttr != null  )
	{
		userAttributes.put( "subject", subjectAttr);
		userAttributes.put( "username", usernameAttr );
		/**userAttributes.put( "status", statusAttr );
		userAttributes.put( "groups", groupsAttr );**/
	}
	else
	{
		throw new Exception("Missing attributes!");
	}
	return userAttributes;
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
</body>
</html>