<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:import href='/menubar.xsl'/>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template match='/lesson'>
	<html>
		<head>
			<title>Station - Lesson</title>
			<link rel="stylesheet" type="text/css" href="/base.css"/>
			<script src='../lesson.js' type='application/ecmascript'></script>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<a>
				<xsl:attribute name='href'>../course/<xsl:value-of select='course'/></xsl:attribute>
				Back to course
			</a>
			<h1><xsl:value-of select='number'/>. <xsl:value-of select='title'/></h1>
			<pre><xsl:value-of select='content'/></pre>
			<h1>Questions</h1>
			<form method='POST'>
				<ol>
					<xsl:for-each select='questions/question'>
						<li>
							<xsl:attribute name='value'><xsl:value-of select='number'/></xsl:attribute>
							<xsl:value-of select='text'/>
							<fieldset>
								<legend>
									Full mark: <xsl:value-of select='mark'/> point<xsl:if test='mark!=1'>s</xsl:if>
								</legend>
								<xsl:for-each select='answers/answer'>
									<label style='display:block'>
										<input type='radio' required=''>
											<xsl:attribute name='name'><xsl:value-of select='../../identifier'/></xsl:attribute>
											<xsl:attribute name='value'><xsl:value-of select='identifier'/></xsl:attribute>
											<xsl:if test='@answered'>
												<xsl:attribute name='checked'/>
											</xsl:if>
										</input>
										<xsl:value-of select='text'/>
										<xsl:if test='@answered'>
											(<b><xsl:value-of select='@answered'/> point<xsl:if test='@answered!=1'>s</xsl:if></b>)
										</xsl:if>
									</label>
								</xsl:for-each>
							</fieldset>
						</li>
					</xsl:for-each>
				</ol>
				<input type='submit' value='Submit'/>
			</form>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
