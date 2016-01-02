<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#default bk tei"
    version="2.0">
    <xsl:output omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <!-- Anzeige von StV 1378 -->
    <xsl:param name="context"/>
    <xsl:param name="mode"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>Bookkeeping ontology</title>
                <link rel="stylesheet"
                    href="http://gams.uni-graz.at/rem/yaml/core/base.min.css"
                    type="text/css"/>
                <link rel="stylesheet" href="http://gams.uni-graz.at/rem/anzeige.css"
                    type="text/css"/>
            </head>
            <body>
                <!-- Aus den interp in PvE1335 die Ontologie herausziehen, mit xbrl-gl korrellieren und hier anzeigbar machen 
                Über einen gams-mode referenzieren 
                -->
                <table>
                    <thead>
                        <tr>
                            <td>ID</td>
                            <td>label</td>
                            <td>description</td>
                        </tr>
                    </thead>
                    <xsl:apply-templates select="//tei:classCode[@xml:id='bk']//tei:interp"/>
                </table>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:interp">
        <tr>
            <td><a name="{substring-after(./@xml:id, '_')}" >
                <xsl:value-of select="substring-after(./@xml:id, '_')"/>
            </a>
            </td>
            <td>
                <xsl:value-of select="."/>
            </td>
            <td>
                <xsl:apply-templates select="tei:desc"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
