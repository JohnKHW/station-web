<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template name='menubar'>
	<div class="header">
            <div class="container-basic-info">
                <div class="logo align-bot">
                    <div class="sponsor">
                        <a href="https://www.collaction.hk/s/station/">
                            <img src="./Image/station_logo_black.png"/>
                        </a>
                    </div>
                    <div class="sponsor">
                        <a href="https://www.eatonworkshop.com/hotel/hong-kong">
                            <img src="./Image/eaton_logo_black.png"/>
                        </a>
                    </div>
                </div>
                <div class="user align-bot">
                    <div class="user-info">
                        <div class="welcome-msg basic-info-font">
                            <span>Welcome Back!</span>
                        </div>
                        <div class="user-data">
							<a href='/account'>
								<div class="user-icon align-bot">
									<img src="./Image/user_icon.jpg" alt="user_icon"/>
									<img>
										<!--<xsl:attribute name="src" select='session/icon'/>-->
									</img>
								</div>
								<div class="user-name align-bot basic-info-font">
									<xsl:value-of select='session/name'/>
								</div>
								<div class="user-score align-bot basic-info-font">
									<span> Point<xsl:if test='session/mark!=1'>s</xsl:if>: <xsl:value-of select='session/mark'/></span>
								</div>
							</a>
                        </div>
                    </div>
                </div>
            </div>
            <div class="container-menu">
                <div class="menu-icon" onclick="toggNavBar(this)">
                    <div></div>
                    <div></div>
                    <div></div>
                </div>
            </div>
        </div>
        
        <div class=" menu-content">
            <ul>
                <li><a href="/home">Home</a></li>
                <li><a href="">Subject</a></li>
                <li><a href="https://www.collaction.hk/s/station/">Station for Open Cultures</a></li>
                <li><a href="https://www.eatonworkshop.com/hotel/hong-kong">EatonHK</a></li>
                <li><a href="https://g0vhk.io/">g0vhk</a></li>
				<xsl:if test='session/role="SysOp"'>
					<li><a href="/sysop/account">Accounts</a></li>
					<li><a href="/sysop/subjects">Lessons</a></li>
				</xsl:if>
            </ul>
        </div>
	<hr/>
</xsl:template>
</xsl:stylesheet>
