<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/"
    xmlns:sr="http://www.w3.org/2001/sw/DataAccess/rf1/result"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:param name="mode"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Volltextsuche</title>
            </head>
            <body>
                <h1>
                    <a href="http://gams.uni-graz.at/rem/">&lt;REM /&gt;</a> - Ergebnis
                    Volltextsuche Texten</h1>
                <p><a href="/archive/objects/query:volltext/methods/sdef:Query/get?params=$1|{//query}">Volltextsuche nur in Buchungen</a> | Volltextsuche im gesamten
                        Dokument</p>
                <form
                    action="http://gams.uni-graz.at/search/gsearch"
                    method="get" name="Suche"> Suche nach: <input
                        name="query" size="50" type="text"/>
                    <input type="hidden" name="hitPageSize" value="10"/><input type="hidden" name="hitPageStart" value="1"/><input type="hidden" name="pid" value="rem"/><input name="x2" value="http://gams.uni-graz.at/rem/gsearch.xsl" type="hidden"/>
                    <input type="submit"/>
                </form>
                <p><xsl:value-of select="//head/hitTotal"/> Treffer zur Suche "<xsl:value-of select="//query"/>"</p>
                <xsl:apply-templates select="//results"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="results">
        <xsl:for-each select="result[field[@name='fulltext' and @snippet='yes']]">
            <h2><a href="/{member/@uri}"><xsl:value-of select="memberTitle[1]"/>, <xsl:value-of select="memberCreator[1]"/></a></h2>
            <xsl:apply-templates select="field[@name='fulltext' and @snippet='yes']"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="field[@name='fulltext' and @snippet='yes']"><p class="snippet"><xsl:apply-templates /></p></xsl:template>
    <xsl:template match="field/text()">
<!--    ToDo: tokenize() geht nicht ...
            
            <xsl:variable name="absaetze"><xsl:call-template name="tokenize">
            <xsl:with-param name="delimiter"><xsl:text>
</xsl:text></xsl:with-param>
            <xsl:with-param name="pText" select="."/>
        </xsl:call-template></xsl:variable>
            <xsl:for-each select="$absaetze">
                <xsl:value-of select="normalize-space(.)"/><br/>
            </xsl:for-each>
-->
        <xsl:for-each select="tokenize(., '\n\s*\n')">
            <xsl:value-of select="normalize-space(.)"/><br/>
        </xsl:for-each>
<!--        <xsl:value-of select="."/>-->
    </xsl:template>
    <xsl:template match="span">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template name="tokenize">
        <xsl:param name="pText"/>
        <xsl:param name="delimiter"/>
        <xsl:if test="string-length($pText)">
            <tag>
                <xsl:value-of select="substring-before($pText, $delimiter)"/>
            </tag>
            <xsl:call-template name="tokenize">
                <xsl:with-param name="pText" select="substring-after($pText, $delimiter)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
