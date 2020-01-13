<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template name='menubar'>
	<div>
		<strong><xsl:value-of select='session/name'/></strong>:
		<em><xsl:value-of select='session/mark'/> point<xsl:if test='session/mark!=1'>s</xsl:if></em>
		|
		<a href='/home'>Home</a>
	</div>
	<hr/>
</xsl:template>
</xsl:stylesheet>
