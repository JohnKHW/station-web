<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
	version='1.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns='http://www.w3.org/1999/xhtml'
>
<xsl:output method='xml' version='1.0' encoding='UTF-8' indent='yes'/>
<xsl:template name='slider'>
    <div class="container-slide-show" onmouseover="stopAutoSlide()" onmouseout="contineSlide()">
        <div class="slide">
            <a href=""><img src="./Image/slide.jpeg"/></a>
        </div>
        <div class="slide">
            <a href=""><img src="./Image/slide.jpg"/></a>
        </div>
        <div class="slide">
            <a href=""><img src="./Image/slide.jpeg"/></a>
        </div>
        <div class="slide">
            <a href=""><img src="./Image/slide.jpg"/></a>
        </div>
        <div class="slide">
            <a href=""><img src="./Image/slide.jpeg"/></a>
        </div>
        <div class="container-btn-slide"> 
            <span class="btn-slide" onclick="setShowImgIndex(0)"></span>
            <span class="btn-slide" onclick="setShowImgIndex(1)"></span>
            <span class="btn-slide" onclick="setShowImgIndex(2)"></span>
            <span class="btn-slide" onclick="setShowImgIndex(3)"></span>
            <span class="btn-slide" onclick="setShowImgIndex(4)"></span>
        </div>
    </div>
</xsl:template>
</xsl:stylesheet>
