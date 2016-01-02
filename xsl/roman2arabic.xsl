<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:rm="org.emile.roman.Roman"
    xmlns:bk="http://gams.uni-graz.at/rem"
    version="2.0">
    <xsl:template match="/">
        <xsl:value-of select="rm:RomanToInt('LXViiij')"/>
    </xsl:template>
    <xsl:template match="//num/text()[matches(.,'[MCLXVI]+') and not(../* or ../@value)]">
        <xsl:element name="num">
            <attribute name="value">
                <xsl:value-of select="rm:RomanToInt(.)"/>
            </attribute>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>