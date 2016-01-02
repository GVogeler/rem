<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://www.cei.lmu.de/accounting/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#default bk tei"
    version="2.0">
    <xsl:output encoding="utf-8" />
    <xsl:preserve-space elements="*"/>

    <xsl:template match="/">
    	<xsl:apply-templates />
    </xsl:template>
    <xsl:template match="@corresp">
    <xsl:choose>
    <xsl:when test="//tei:note/@xml:id = concat('o-',substring-after(.,'-'))">
    	<xsl:attribute name="corresp">
    		<xsl:text>#o-</xsl:text><xsl:value-of select="substring-after(.,'-')" />
    	</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
        <xsl:copy>
            <xsl:apply-templates select="node()|@*|processing-instruction()|comment()" />
        </xsl:copy>
    </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
    <xsl:template match="node()|@*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*|processing-instruction()|comment()" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
