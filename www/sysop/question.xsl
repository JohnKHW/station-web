<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:import href='/menubar.xsl'/>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template match='/question'>
	<html>
		<head>
			<title>SysOp: Lesson</title>
			<link rel="stylesheet" type="text/css" href="../base.css"/>
			<script type='application/ecmascript' src='../delete_disable.js' async=''/>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<a>
				<xsl:attribute name='href'>../lesson/<xsl:value-of select='lesson'/></xsl:attribute>
				Back
			</a>
			<section>
				<h1>Question <xsl:value-of select='number'/></h1>
				<form method='POST'>
					<xsl:attribute name='action'>../question/<xsl:value-of select='identifier'/></xsl:attribute>
					<input type='hidden' name='lesson'>
						<xsl:attribute name='value'><xsl:value-of select='lesson'/></xsl:attribute>
					</input>
					<div class='flex'>
						<textarea name='text'><xsl:value-of select='text'/></textarea>
					</div>
					<label>Delete<input type='checkbox' name='delete'/></label>
					<br/>
					<button type='submit'>Modify</button>
				</form>
			</section>
			<section>
				<h1>Answer<xsl:if test='count(answers/answer)!=1'>s</xsl:if></h1>
				<xsl:for-each select='answers/answer'>
					<form method='POST'>
						<xsl:attribute name='action'>../answer/<xsl:value-of select='identifier'/></xsl:attribute>
						<input type='hidden' name='identifier'>
							<xsl:attribute name='value'><xsl:value-of select='identifier'/></xsl:attribute>
						</input>
						<input type='hidden' name='question'>
							<xsl:attribute name='value'><xsl:value-of select='../../identifier'/></xsl:attribute>
						</input>
						<div class='flex'>
							<input type='text' name='text'>
								<xsl:attribute name='value'><xsl:value-of select='text'/></xsl:attribute>
							</input>
						</div>
						<label>
							<div>
								Mark
								<input type='number' name='mark'>
									<xsl:attribute name='value'><xsl:value-of select='mark'/></xsl:attribute>
								</input>
								<label>Delete<input type='checkbox' name='delete'/></label>
							</div>
						</label>
						<button type='submit'>Modify</button>
					</form>
				</xsl:for-each>
				<form method='POST'>
					<xsl:attribute name='action'>../answer/new/<xsl:value-of select='identifier'/></xsl:attribute>
					<input type='hidden' name='question'>
						<xsl:attribute name='value'><xsl:value-of select='identifier'/></xsl:attribute>
					</input>
					<div class='flex'>
						<input type='text' name='text'/>
					</div>
					<label>
						<div>
							Mark
							<input type='number' name='mark' value='0'/>
						</div>
					</label>
					<button type='submit'>Create</button>
				</form>
			</section>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
