<!--
*******************************************************************************
* Copyright (C) 2010 Ping Identity Corporation All rights reserved.
*
* This software is licensed under the Open Software License v2.1 (OSL v2.1).
*
*
******************************************************************************
-->
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@ page import = "java.lang.StringBuilder" %>
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
<%@ page import="javax.servlet.http.*" %>
<%@ include file="configuration.jsp" %>

<%
	/* 
		Redirect requests to SpSample/ to SpSample/Mainpage while preserving any query params.
	*/
	
	try
	{
		// 1 - Get the attribute reference value from the REFID in the reqeust Payload.		
		String spReferenceValue = "";
		Map<String, String[]> map = request.getParameterMap();
        //Reading the Map
        //Works for GET && POST Method
        for(String paramName:map.keySet()) {
            String[] paramValues = map.get(paramName);

            //Get Values of Param Name
            for(String valueOfParam:paramValues) {
                //Output the Values
                //System.out.println("Value of Param with Name "+paramName+": "+valueOfParam);
				if ( paramName.equals("REF") )
				{
					spReferenceValue = valueOfParam;
					//System.out.println("Value of spReferenceValue= "+spReferenceValue);
			    }
            }
        }

		// 2 - Use reference value to retrieve attributes from adapter		
		Map<String,String> attributes = pickUpAttributesFromReferenceIdAdapter( spReferenceValue );
		
		// 3 - Kill the SP Apps Session
		HttpSession spSession = request.getSession(false);
		System.out.println("Value of SessionId= "+spSession.getId());
		if ( spSession != null )
		{
			spSession.invalidate();
			System.out.println("Session has been invalidated!!!!!");
		}
			
		// 4 - Get the resumePath and complete the Unlinking Flow
	    response.sendRedirect(PF_BASE_URL + ":" + PF_PRIMARY_SSL_PORT + attributes.get("resumePath") + "?source=" + REFID_INSTANCE_ID);
	}
	catch (Exception e)
	{
		// If something went wrong, log error and forward to error page.
		request.setAttribute("errorMessage", e.toString());
		System.err.println( ""+new Date()+" ShowAttributes.jsp caught exception: "+e );
		e.printStackTrace(System.err);
		getServletConfig().getServletContext().getRequestDispatcher("/error.jsp").forward(request, response);
	}
%>
<%!
/** Pick up attributes from the ReferenceID adapter using the the reference value received in the SSO request.
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
 * @return Map of attributes
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

	// 5 - Get ref attributes from adapter service response as a JSON object.

	// Use UTF-8 if no encoding found in request.
    String encoding = urlConnection.getContentEncoding();
    InputStream is = urlConnection.getInputStream();
    InputStreamReader streamReader = new InputStreamReader(is, encoding != null ? encoding : "UTF-8");
    JSONObject attributesJSON = (JSONObject)new JSONParser().parse(streamReader);
    if ( attributesJSON == null || attributesJSON.size() == 0 ) 
    	throw new Exception( "Problem retrieving attributes from adapter!");

	// 6 - Return attributes as a Map.  Make sure all attributes were provided.
	
	Map<String,String> attributes = new HashMap<String,String>();
	String resumeAttr = (String)attributesJSON.get( "resumePath");
	String sessionAttr = (String)attributesJSON.get( "sessionid");	
	String instanceIdAttr = (String)attributesJSON.get( "com.pingidentity.plugin.instanceid");

	if ( resumeAttr != null )
	{
		attributes.put( "resumePath", resumeAttr );
		attributes.put( "sessionId", sessionAttr );
		attributes.put( "instanceId", instanceIdAttr );
		//System.out.println("resumePath= " + resumeAttr);
		//System.out.println("sessionId= " + sessionAttr);
		//System.out.println("instanceId= " + instanceIdAttr);
	}
	else
	{
		throw new Exception("Missing attributes!");
	}
	return attributes;
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