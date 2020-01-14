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

	The IdP Application pages are:
	    1 - SelectUser.jsp
		2 - ConfirmAttributes.jsp
	  > 3 - SubmitToSP.jsp  <- this page

	This IdP Application page performs the SSO to the SP by dropping off the user attributes to the ReferenceID adapter
	and redirecting to the startSSO application endpoint with the reference value.  This page has no presentation.
--%>

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

<%
/** Perform SSO to partner connection by passing user attributes through ReferenceID adapter. 
 ** This page has no HTML presentation.  It redirects to the SP if success, else error page.
 **/
try
{
	// 1 - Get the user attributes from the request parameters and prepare them as a JSON object.
	
	JSONObject userAttributes = new JSONObject();
	userAttributes.put( "authnContext", request.getParameter("userName") );
	
	
	// 2 - Send the user attributes to the referenceID adapter and get the returned reference value
	
	String spReferenceValue = dropOffAttributesToRefererenceIdAdapter( userAttributes );
	
	// 3 - Redirect to PF to start SSO to partner, passing the attribute reference value
	String resumePath = (String)request.getParameter("resumePath");
	if(resumePath != null)
	{
		response.sendRedirect(PF_BASE_URL + ":" + PF_PRIMARY_SSL_PORT + resumePath + "?REF=" + spReferenceValue);
	}
	else{
		response.sendRedirect(PF_BASE_URL + ":" + PF_PRIMARY_SSL_PORT + PF_START_SSO_ENDPOINT_IDP + "?" + "PartnerSpId=" + PARTNER_ENTITY_ID + "&REF=" + spReferenceValue);
	}
}
catch (Exception e)
{
	// If something went wrong, log error and forward to error page.
	System.err.println( ""+new Date()+" SubmitToSP.jsp caught exception: "+e );
	e.printStackTrace(System.err);
	request.setAttribute("errorMessage", e.toString());
	getServletConfig().getServletContext().getRequestDispatcher("/error.jsp").forward(request, response);
}
%>
<%!
/** Drop off user attributes to the ReferenceID adapter and return the reference value string received in exchange.
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
 * @return reference value
 */
private String dropOffAttributesToRefererenceIdAdapter(JSONObject userAttributes) throws Exception
{
	// 1 - Get an SSL connection for the attribute dropoff service - use secondary port if certificate authentication specified
	
	URL dropOffUrl = new URL(PF_BASE_URL +":" + (CERTIFICATE_AUTHENTICATION ? PF_SECONDARY_SSL_PORT : PF_PRIMARY_SSL_PORT) + REFID_DROPOFF_URL);
	URLConnection urlConnection = dropOffUrl.openConnection();

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

	// 5 - Send the user attributes

	urlConnection.setDoOutput(true);
	OutputStreamWriter outputStreamWriter = new OutputStreamWriter(urlConnection.getOutputStream(), "UTF-8");
	userAttributes.writeJSONString(outputStreamWriter);
	outputStreamWriter.flush();
	outputStreamWriter.close();

	// 6 - Get the response and parse out the reference value from the JSON content

	InputStreamReader streamReader = new InputStreamReader(urlConnection.getInputStream(), "UTF-8");
	String referenceValue = (String) ((JSONObject) new JSONParser().parse(streamReader)).get("REF");

	return referenceValue;
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