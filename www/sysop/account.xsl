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
			<link rel="stylesheet" href="../CSS/slide-show.css"/>
			<script type='application/ecmascript' src='delete_disable.js' async=''/>
		</head>
		<body>
			<xsl:call-template name='menubar'/>
			<div class="container-content">
				<div class="account-function">
					<div class="title">
						<span>Create New Account</span>
					</div>
					<div class="account-setting">
						<div class="container-attributes">
							<form method="POST">
								<div class="account-attribute attribute">
									<div class="attribute-name">
										<span>Name</span>
									</div>
									<div class="attribute-value">
										<input class="value" type="text" />
									</div>
								</div>
								<div class="account-attribute attribute">
									<div class="attribute-name">
										<span>Select Role</span>
									</div>
									<div class="attribute-value select">
										<select class="value" id="role" name='role'>
											<option value="User">Basic User</option>
											<option value="SysOp">System Operator</option>
										</select>
									</div>
								</div>
								<div class="account-attribute attribute final-attribute">
									<div class="attribute-name">
										<span>New Password</span>
									</div>
									<div class="attribute-value">
										<input class="value final-value" type="password" name='password' />
									</div>
								</div>
								<div class="attribute">
									<div class="attribute-name"></div>
									<div class="btn-submit">
										<input class="btn-add" type="submit" value="Add" />
									</div>
								</div>
							</form>
						</div>
					</div>
				</div>
				<div class="account-function">
					<div class="title">
						<span>Modify Existing Accounts</span>
					</div>
					<xsl:for-each select='user'>
						<form method='POST'>
							<div class="account-setting">
								<div class="container-attributes">
									<div class="account-attribute attribute">
										<div class="attribute-name">
											<span>Name</span>
										</div>
										<div class="attribute-value">
											<input class="value" type="text" name='user' readonly='' >
												<xsl:attribute name='value'>
													<xsl:value-of select='.'/>
												</xsl:attribute>
											</input>
										</div>
									</div>
									<div class="account-attribute attribute">
										<div class="attribute-name">
											<span>Mark</span>
										</div>
										<div class="attribute-value">
											<input class="value" type="text">
												<xsl:attribute name='value'>
													<xsl:value-of select='@mark'/>
												</xsl:attribute>
											</input>
										</div>
									</div>
									<div class="attribute">
										<div class="attribute-name"></div>
										<div class="btn-attribute">
											<img class="btn-image btn-lock" />
										</div>
									</div>
									<div class="attribute">
										<div class="attribute-name"></div>
										<div class="btn-attribute">
											<img class="btn-image btn-remove" />
										</div>
									</div>
								</div>
								<div class="container-attributes">
									<div class="account-attribute attribute">
										<div class="attribute-name">
											<span>Role</span>
										</div>
										<div class="attribute-value select">
											<select class="value" id="role" name="role">
												<option value="User">
													<xsl:if test='@role="User"'>
														<xsl:attribute name='selected'/>
													</xsl:if>
													Basic User
												</option>
												<option value="SysOp">
													<xsl:if test='@role="SysOp"'>
														<xsl:attribute name='selected'/>
													</xsl:if>
													System Operator
												</option>
											</select>
										</div>
									</div>
									<div class="account-attribute attribute final-attribute">
										<div class="attribute-name">
											<span>New Password</span>
										</div>
										<div class="attribute-value">
											<input class="value final-value" type="password" name='password' />
										</div>
									</div>
									<div class="attribute">
										<div class="attribute-name"></div>
										<div class="btn-submit">
											<input class="btn-save" type="submit" value="Save" />
										</div>
									</div>
								</div>
								<pre></pre>
							</div>
						</form>
					</xsl:for-each>
				</div>
			</div>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
