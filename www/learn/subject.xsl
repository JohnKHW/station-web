<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:import href='/menubar.xsl'/>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template match='/subject'>
	<html>
		<head>
			<title>Station - Subject</title>
			<link rel="stylesheet" type="text/css" href="/base.css"/>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<h1><xsl:value-of select='title'/></h1>
			<pre><xsl:value-of select='description'/></pre>
			<h1>Courses</h1>
			<xsl:for-each select='courses/course'>
				<h2>
					<a>
						<xsl:attribute name='href'>../course/<xsl:value-of select='identifier'/></xsl:attribute>
						<xsl:value-of select='title'/>
					</a>
				</h2>
				<pre><xsl:value-of select='description'/></pre>
			</xsl:for-each>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
