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
			<title>SysOp: Lesson</title>
			<link rel="stylesheet" type="text/css" href="../base.css"/>
			<link rel="stylesheet" type="text/css" href="/base.css"/>
			<script type='application/ecmascript' src='../delete_disable.js' async=''/>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<a>
				<xsl:attribute name='href'>../course/<xsl:value-of select='course'/></xsl:attribute>
				Back
			</a>
			<section>
				<h1>Lesson</h1>
				<form method='POST'>
					<h2><xsl:value-of select='number'/>. <xsl:value-of select='title'/></h2>
					<input type='hidden' name='course'>
						<xsl:attribute name='value'><xsl:value-of select='course'/></xsl:attribute>
					</input>
					<input type='hidden' name='number'>
						<xsl:attribute name='value'><xsl:value-of select='number'/></xsl:attribute>
					</input>
					<label>
						Title
						<div class='flex'>
							<input type='text' name='title'>
								<xsl:attribute name='value'><xsl:value-of select='title'/></xsl:attribute>
							</input>
						</div>
					</label>
					<label>
						Content
						<div class='flex'>
							<textarea name='content'><xsl:value-of select='content'/></textarea>
						</div>
					</label>
					<label>Delete<input type='checkbox' name='delete'/></label>
					<br/>
					<button type='submit'>Modify</button>
				</form>
			</section>
			<section>
				<h1>Create question</h1>
				<form method='POST'>
					<xsl:attribute name='action'>../question/new/<xsl:value-of select='identifier'/></xsl:attribute>
					<label>
						Question
						<div class='flex'>
							<textarea name='text'/>
						</div>
					</label>
					<button type='submit'>Create</button>
				</form>
			</section>
			<section>
				<h1>Modify question</h1>
				<table>
					<xsl:for-each select='questions/question'>
						<tbody>
							<tr>
								<td>
									<a>
										<xsl:attribute name='href'>../question/<xsl:value-of select='identifier'/></xsl:attribute>
										<xsl:value-of select='number'/>
									</a>.
								</td>
								<td>
									<xsl:if test='number>1'>
										<form method='POST'>
											<xsl:attribute name='action'>
												../question/exchange/<xsl:value-of select='../../identifier'/>
											</xsl:attribute>
											<input type='hidden' name='0'>
												<xsl:attribute name='value'>
													<xsl:value-of select='identifier'/>
												</xsl:attribute>
											</input>
											<input type='hidden' name='1'>
												<xsl:attribute name='value'>
													<xsl:value-of select='preceding-sibling::*[1]/identifier'/>
												</xsl:attribute>
											</input>
											<button type='submit'>↑</button>
										</form>
									</xsl:if>
								</td>
								<td>
									<xsl:if test='count(../question)>number'>
										<form method='POST'>
											<xsl:attribute name='action'>
												../question/exchange/<xsl:value-of select='../../identifier'/>
											</xsl:attribute>
											<input type='hidden' name='0'>
												<xsl:attribute name='value'>
													<xsl:value-of select='identifier'/>
												</xsl:attribute>
											</input>
											<input type='hidden' name='1'>
												<xsl:attribute name='value'>
													<xsl:value-of select='following-sibling::*[1]/identifier'/>
												</xsl:attribute>
											</input>
											<button type='submit'>↓</button>
										</form>
									</xsl:if>
								</td>
								<td>
									<xsl:value-of select='text'/>
								</td>
							</tr>
						</tbody>
					</xsl:for-each>
				</table>
			</section>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
