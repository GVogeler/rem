<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:rm="org.emile.roman.Roman"
    xmlns:html="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#default bk tei"
    version="2.0">
    <xsl:import href="default.xsl"/>
    <xsl:import href="tab_debug.xsl"/>
    <xsl:import href="tab.xsl"/> <!-- Alle templates mit mode="tab" -->
    <xsl:import href="http://gams.uni-graz.at/rem/Umrechnungselemente.xsl"/>
<!--    <xsl:import href="http://gams.uni-graz.at/archive/objects/cirilo:srbas/datastreams/STYLESHEET.CONVERSIONS/content"/>-->
    <xsl:param name="context"/>  <!-- = Suchparameter -->
    <xsl:param name="mode"/>
    <xsl:param name="locale"/>
    <xsl:variable name="pid" select="replace(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='PID']/text(),'info:fedora/','')"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:value-of
                        select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
                </title>
                <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
                <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js">/* test */</script>
                <!-- Das JavaScript, das die Buchungen summiert und in div@id=calculations schreibt: 
                http://gams.uni-graz.at/rem/
                -->
                <script src="http://gams.uni-graz.at/rem/bookkeeping.js" type="text/javascript">/* test */</script>
                <script type="text/javascript" src="http://gams.uni-graz.at/rem/navigation.js">/* test*/</script>   
                <link rel="stylesheet" href="http://gams.uni-graz.at/rem/yaml/core/base.min.css"
                    type="text/css"/>
                <link rel="stylesheet" href="http://gams.uni-graz.at/rem/anzeige.css"
                    type="text/css"/>
                <style>
                    td {
                    vertical-align:top;
                    /* border-style:solid; */
                    }
                    .addSpan {
                    background-color: 90EE90;
                    }
                </style>
            </head>
            <body>
                <a name="top"/>
                <xsl:choose>
                    <xsl:when test="$mode='tab'">
                        <xsl:apply-templates mode="tab"/>
                    </xsl:when>
<!--                    <xsl:when test="$mode='debug'">
                        <xsl:apply-templates mode="debug"/>
                    </xsl:when>
-->                    <xsl:when test="$mode='tab-debug'">
                        <xsl:apply-templates mode="tab-debug"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
