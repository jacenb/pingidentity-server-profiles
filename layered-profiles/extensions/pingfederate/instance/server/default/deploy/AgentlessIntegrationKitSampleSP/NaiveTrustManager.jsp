<%--************************************************************
* Copyright (C) 2012 Ping Identity Corporation                 *
* All rights reserved.                                         *
*                                                              *
* The contents of this file are subject to the terms of the    *
* PingFederate Agentless Integration Kit Users Guide.          *
************************************************************--%>

<%--
DO NOT USE IN PRODUCTION!  This implementation reduces security.

Define a naive X509TrustManager which accepts all certificates and the method acceptAllCertificates()
which sets a URLConnection SSLContext to use it.

This file is intended to be included by a JSP that invokes the acceptAllCertificates() method via
<%@ include file="SubmitToSP.jsp" %>.  See ShowAttributes.jsp for example.

DO NOT USE IN PRODUCTION!  This implementation reduces security.
--%>

<%!
/**
 * Modify the URLConnection to accept all certificates. DO NOT USE IN PRODUCTION! Creates an SSLContext with a naive
 * X509TrustManager that accepts all certificates.
 */
private void acceptAllCertificates(URLConnection urlConnection) throws NoSuchAlgorithmException, KeyManagementException
{
	SSLContext sslContext = SSLContext.getInstance("TLS");
	sslContext.init(null, new TrustManager[]
	{ naiveTrustManager }, null);
	SSLSocketFactory socketFactory = sslContext.getSocketFactory();
	HttpsURLConnection httpsURLConnection = (HttpsURLConnection) urlConnection;
	httpsURLConnection.setSSLSocketFactory(socketFactory);
}

/**
 * A naive X509TrustManager that will trust any server certificate. DO NOT USE IN PRODUCTION!
 */
X509TrustManager naiveTrustManager = new X509TrustManager()
{
	public void checkClientTrusted(X509Certificate[] x509Certs, String s) throws CertificateException
	{}

	public void checkServerTrusted(X509Certificate[] x509Certs, String s) throws CertificateException
	{}

	public X509Certificate[] getAcceptedIssuers()
	{
		return new X509Certificate[0];
	}
};
%>
