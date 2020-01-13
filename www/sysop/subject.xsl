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
			<title>SysOp: Subject</title>
			<link rel="stylesheet" type="text/css" href="../base.css"/>
			<link rel="stylesheet" type="text/css" href="/base.css"/>
			<script type='application/ecmascript' src='../delete_disable.js' async=''/>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<a href='../subjects'>Back</a>
			<section>
				<h1>Subject</h1>
				<h2><xsl:value-of select='title'/></h2>
				<form method='POST'>
					<label>
						Title
						<div class='flex'>
							<input type='text' name='title'>
								<xsl:attribute name='value'><xsl:value-of select='title'/></xsl:attribute>
							</input>
						</div>
					</label>
					<label>
						Description
						<div class='flex'>
							<textarea name='description'><xsl:value-of select='description'/></textarea>
						</div>
					</label>
					<label>Delete<input type='checkbox' name='delete'/></label>
					<br/>
					<button type='submit'>Modify</button>
				</form>
			</section>
			<section>
				<h1>Create course</h1>
				<form method='POST'>
					<xsl:attribute name='action'>../course/new/<xsl:value-of select='identifier'/></xsl:attribute>
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
				<h1>Modify existing courses</h1>
				<xsl:for-each select='courses/course'>
					<h2>
						<a>
							<xsl:attribute name='href'>../course/<xsl:value-of select='identifier'/></xsl:attribute>
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
