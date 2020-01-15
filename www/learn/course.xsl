<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:import href='/menubar.xsl'/>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template match='/course'>
	<html>
		<head>
			<title>Station - Course</title>
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
			<a>
				<xsl:attribute name='href'>../subject/<xsl:value-of select='subject'/></xsl:attribute>
				Back to subject
			</a>
			<h1><xsl:value-of select='title'/></h1>
			<pre><xsl:value-of select='description'/></pre>
			<h1>Lessons</h1>
			<xsl:for-each select='lessons/lesson'>
				<p>
					<xsl:value-of select='number'/>.
					<a>
						<xsl:attribute name='href'>../lesson/<xsl:value-of select='identifier'/></xsl:attribute>
						<xsl:value-of select='title'/>
					</a>
				</p>
			</xsl:for-each>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
