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
			<title>Station - Subject</title>
			<link rel="stylesheet" type="text/css" href="/base.css"/>
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
			<div class="container-content">
				<div class="subject">
					<div class="subject-title" onclick="switchSubject(0)">
						<a href=""><span><xsl:value-of select='title'/></span></a>
					</div>
				</div>
				<div class="content">
					<xsl:for-each select='courses/course'>
						<div class="card-course">
							<div class="title">
								<xsl:value-of select='title'/>
							</div>
							<div class="description">
								<span>
									<xsl:value-of select='description'/>
								</span>
							</div>
							<div class="tail">
								<div class="enroll">
									<a>
										<xsl:attribute name='href'>../course/<xsl:value-of select='identifier'/></xsl:attribute>
										Enroll Now
									</a>
								</div>
								<div class="point">95 Points</div>
							</div>
						</div>
					</xsl:for-each>
				</div>
			</div>
		</body>
	</html>
</xsl:template>
</xsl:stylesheet>
