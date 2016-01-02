<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
<!--  Debugging  -->
    <xsl:template match="/">
        <html><head><title>Vitztumsrechnung 1335 - Debugging</title></head>
        <body>
        <h1>Debugging Vitztumsrechnung 1335</h1>
            <xsl:apply-templates select="//tei:body"/>
        </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:body">
        <xsl:apply-templates select="tei:div"/>
    </xsl:template>
    <xsl:template match="tei:div">
        <div>
            <xsl:apply-templates select="tei:div|tei:list"/>
        </div>
    </xsl:template>
    <xsl:template match="tei:list">
        <xsl:apply-templates select="tei:head"/>        
        <ul>
            <li>Test</li>
        </ul>
        <xsl:comment>Dieses ul-Element erzeugt eine Rekursion, die ich nicht verstehe, Gruß GeVo</xsl:comment>
    </xsl:template>
    <xsl:template match="tei:head">
        <xsl:variable name="tiefe"
            select="concat('h',count(./ancestor-or-self::node()[name()='div' or name()='list']) - (if (count(./ancestor-or-self::node()[name()='div' or name()='list']) lt 3) then 0 else 2))"/>
        <xsl:element name="{$tiefe}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>