<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:import href='/menubar.xsl'/>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template match='/home'>
	<html>
		<head>
			<title>Station</title>
			<link rel="stylesheet" type="text/css" href="/base.css"/>
			<link rel="stylesheet" href="./CSS/global.css"/>
			<link rel="stylesheet" href="./CSS/header.css"/>
			<link rel="stylesheet" href="./CSS/slide-show.css"/>
			<link rel="stylesheet" href="./CSS/content.css"/>
			<script src="./Script/script.js"></script>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<xsl:call-template name='slider'/>
			<h1>Subject<xsl:if test='count(subjects/subject)!=1'>s</xsl:if></h1>
			<xsl:for-each select='subjects/subject'>
				<h2>
					<a>
						<xsl:attribute name='href'>learn/subject/<xsl:value-of select='identifier'/></xsl:attribute>
						<xsl:value-of select='title'/>
					</a>
				</h2>
				<pre><xsl:value-of select='description'/></pre>
			</xsl:for-each>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
