<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>Rechnungen des Mittelaters - Datenansicht - GAMS</title>
            </head>
            <body>
                <h1><a href="/rem">&lt; REM /&gt;</a>
                    <br/>Datenansicht</h1>
                <xsl:choose>
                    <xsl:when test="count(/s:sparql/s:results/s:result) gt 0">
                        <table>
                            <thead>
                                <tr>
                                    <xsl:for-each select="/s:sparql/s:results/s:result[1]/s:*">
                                        <th>
                                            <xsl:value-of select="./name()"/>
                                        </th>
                                    </xsl:for-each>
                                    <th>value</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:apply-templates select="/s:sparql/s:results/s:result"/>
                            </tbody>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>Sorry, nothing found!</xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="s:variable">
        <th>
            <xsl:value-of select="@name"/>
        </th>
    </xsl:template>
    <xsl:template match="s:result">
        <tr>
            <xsl:for-each select="s:*">
                <td class="{name()}">
                    <xsl:apply-templates select=".|@*"/>
                </td>
            </xsl:for-each>
            <td>
                <xsl:value-of select="concat(s:sign,s:quant,' ',s:unit)"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="@uri">
        <a target="_blank">
            <xsl:attribute name="href">
                <xsl:value-of select="replace(.,'info:fedora/([^/]*?)/TEI_SOURCE','/$1')"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    <xsl:template match="s:result/s:*" priority="-2">
        <td>
            <xsl:value-of select="."/>
        </td>
    </xsl:template>
</xsl:stylesheet>
