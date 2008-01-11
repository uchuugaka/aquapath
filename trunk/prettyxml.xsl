<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:output method="xml" indent="yes"/>
	
	<xsl:template match="/">
			<xsl:choose>
				<xsl:when test="name(node()[1]) != 'TOD_nil'">
					<xsl:call-template name="start"/>
				</xsl:when>
				<xsl:otherwise>
					<html></html>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

    <xsl:template match="*" name="start">
		<html>
		<head>
			<style type="text/css">
				/*<![CDATA[*/
				body {
					margin-left:-15px;
				}
				.TOD_selectedNode {
					border:1px solid black;
				}
				
				.TOD_element {
					font-family:Monaco;
					font-size:12px;
					margin-left:15;
					white-space:nowrap;
				}
				.TOD_content {
					font-family:LucidaGrande;
				}
				.TOD_expandButton {
					cursor:pointer;
					padding:2px 5px;
					-khtml-user-select:none;
				}
				.TOD_startOpenBracket,
				.TOD_endOpenBracket,
				.TOD_startCloseBracket,
				.TOD_endCloseBracket {
					color:black;
				}
				.TOD_startCloseBracket {
					margin-left:15px;
				}
				.TOD_startElementName, .TOD_endElementName {
					color:purple;
					font-weight:normal;
				}
				.TOD_endElementName {
				}
				.TOD_attrName,
				.TOD_attrEquals {
					color:black;
					font-weight:normal;
				}
				.TOD_attrValue,
				.TOD_openAttrQuote,
				.TOD_closeAttrQuote {
					color:blue;
				}
				.TOD_comment,
				.TOD_pi {
					font-family:Monaco;
					font-size:12px;
					margin-left:30;
				}
				.TOD_comment {
					color:gray;
				}
				.TOD_pi {
					color:#449a9b;
				}
				/*]]>*/
			</style>
			<script type="text/javascript">
				//<![CDATA[
				function isShowing(el) {
					return "none" != el.style.display;
				}
				function toggle(el) {
					if (isShowing(el))
						el.style.display = "none";
					else
						el.style.display = "";
				}
				function expand(expandButton) {
					var expandArea = getNextSiblingByClassName(expandButton, "TOD_content");
					toggle(expandArea);
					if (isShowing(expandArea))
						expandButton.innerHTML = "- ";
					else
						expandButton.innerHTML = "+ ";
				}
				function getNextSiblingByClassName(element, className) {
					while (element = element.nextSibling) {
						if (element.nodeType == Node.ELEMENT_NODE) {
							if (-1 != element.className.indexOf(className)) {
								return element;
							}
						}
					}
					return null;
				}
				//]]>
			</script>
		</head>
		<body>
			<xsl:apply-templates/>
		</body>
		</html>
    </xsl:template>

    <xsl:template match="*">
        <div class="TOD_element">
            <span class="TOD_expandButton" onclick="expand(this);">-</span>
            <span class="TOD_startOpenBracket">&lt;</span>
            <span class="TOD_startElementName">
                <xsl:value-of select="name()"/>
            </span>
            <xsl:apply-templates select="@*"/>
            <span class="TOD_endOpenBracket">&gt;</span>            <span class="TOD_content">
            <xsl:apply-templates/>
            </span>
            <xsl:choose>
                <xsl:when test="count(*)">
                    <span class="TOD_startCloseBracket">&lt;/</span>
                </xsl:when>
                <xsl:otherwise>
                    <span class="TOD_leafStartCloseBracket">&lt;/</span>
                </xsl:otherwise>
            </xsl:choose>
            <span class="TOD_endElementName">
                <xsl:value-of select="name()"/>                </span>
            <span class="TOD_endCloseBracket">&gt;</span>        </div>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:text> </xsl:text>
        <span class="TOD_attrName">
            <xsl:value-of select="name()"/>
        </span>
        <span class="TOD_attrEquals">
            <xsl:text>=</xsl:text>
        </span>
        <span class="TOD_openAttrQuote">
            <xsl:text>"</xsl:text>
        </span>
        <span class="TOD_attrValue">
            <xsl:value-of select="."/>
        </span>
        <span class="TOD_closeAttrQuote">
            <xsl:text>"</xsl:text>
        </span>
    </xsl:template>

    <xsl:template match="comment()">
        <div class="TOD_comment">
        <xsl:text>&lt;!-- </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> --&gt;</xsl:text>
        </div>
    </xsl:template>

    <xsl:template match="processing-instruction()">
        <div class="TOD_pi">
        <xsl:text>&lt;?</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>?&gt;</xsl:text>
        </div>
    </xsl:template>

</xsl:stylesheet>