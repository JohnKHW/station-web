<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:import href='/menubar.xsl'/>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template match='/subjects'>
	<html>
		<head>
			<title>SysOp: Subjects</title>
			<link rel="stylesheet" type="text/css" href="base.css"/>
			<link rel="stylesheet" type="text/css" href="/base.css"/>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<section>
				<h1>Create new subject</h1>
				<form method='POST'>
					<label>
						Title
						<div class='flex'>
							<input type='text' name='title'/>
						</div>
					</label>
					<label>
						Description
						<div class='flex'>
							<textarea name='description'/>
						</div>
					</label>
					<button type='submit'>Create</button>
				</form>
			</section>
			<section>
				<h1>Modify existing subjects</h1>
				<xsl:for-each select='item'>
					<h2>
						<a>
							<xsl:attribute name='href'>subject/<xsl:value-of select='identifier'/></xsl:attribute>
							<xsl:value-of select='title'/>
						</a>
					</h2>
					<pre><xsl:value-of select='description'/></pre>
				</xsl:for-each>
			</section>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
