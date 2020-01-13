<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:import href='/menubar.xsl'/>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template match='/account'>
	<html>
		<head>
			<title>SysOp: Account</title>
			<link rel="stylesheet" type="text/css" href="base.css"/>
			<script type='application/ecmascript' src='delete_disable.js' async=''/>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<section>
				<h1>Create new account</h1>
				<p>
					<form method='POST'>
						<label>
							Name
							<input type='text' name='name'/>
						</label>
						<label>
							Role
							<select name='role'>
								<option value='User'>User</option>
								<option value='SysOp'>SysOp</option>
							</select>
						</label>
						<label>
							New Password
							<input type='text' name='password'/>
						</label>
						<button type='submit'>Save</button>
					</form>
				</p>
			</section>
			<section>
				<h1>Modify existing accounts</h1>
				<xsl:for-each select='user'>
					<p>
						<form method='POST'>
							<input type='text' name='user' readonly=''>
								<xsl:attribute name='value'>
									<xsl:value-of select='.'/>
								</xsl:attribute>
							</input>
							<label>
								Mark
								<input type='text' name='mark' readonly=''>
									<xsl:attribute name='value'><xsl:value-of select='@mark'/></xsl:attribute>
								</input>
							</label>
							<br/>
							<label>
								Name
								<input type='text' name='name'>
									<xsl:attribute name='value'><xsl:value-of select='.'/></xsl:attribute>
								</input>
							</label>
							<label>
								Role
								<select name='role'>
									<option value='User'>
										<xsl:if test='@role="User"'>
											<xsl:attribute name='selected'/>
										</xsl:if>
										User
									</option>
									<option value='SysOp'>
										<xsl:if test='@role="SysOp"'>
											<xsl:attribute name='selected'/>
										</xsl:if>
										SysOp
									</option>
								</select>
							</label>
							<label>
								New Password
								<input type='text' name='password'/>
							</label>
							<label>
								Lock
								<input type='checkbox' name='lock'>
									<xsl:if test='@lock'>
										<xsl:attribute name='checked'/>
									</xsl:if>
								</input>
							</label>
							<label>
								Delete
								<input type='checkbox' name='delete'/>
							</label>
							<button type='submit'>Save</button>
						</form>
					</p>
				</xsl:for-each>
			</section>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
