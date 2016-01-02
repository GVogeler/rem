<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:sr="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:decimal-format decimal-separator="," grouping-separator="." name="european" />
    <xsl:param name="mode" />
    <xsl:function name="bk:d2lb">
        <xsl:param name="denarii" />
        <xsl:value-of select="format-number($denarii div 240,'###.##0,00', 'european')" />
    </xsl:function>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>Volltextsuche</title>
                <script src="https://www.google.com/jsapi" type="text/javascript">&amp;nbsp;</script>
                <script type="text/javascript">
                    function addParams() {
                    document.Suche.params.value="$1|" + document.Suche.Stichwort.value ;
                    document.Suche.Stichwort.setAttribute("disabled", "disabled");
                    return true;
                    }
                </script>
                <link type="text/css" href="anzeige.css" rel="stylesheet"/>
            </head>
            <body>
                <h1>
                    <a href="http://gams.uni-graz.at/rem/">&lt;REM /&gt;</a> - Ergebnis Volltextsuche in Buchungen</h1>
                <p>Volltextsuche nur in Buchungen | <a href="http://gams.uni-graz.at/search/gsearch?query={sr:result[1]/sr:query[1]}&amp;hitPageSize=10&amp;hitPageStart=1&amp;pid=rem&amp;x2=http%3A%2F%2Fgams.uni-graz.at%2Frem%2Fgsearch.xsl">Volltextsuche im gesamten Dokument</a></p>
                <form action="/archive/objects/query:volltext/methods/sdef:Query/get" method="get" name="Suche" onSubmit="addParams()">
                    Suche nach: <input name="Stichwort" size="50" type="text" /><input type="hidden" name="params"/>
                    <input type="submit" />
                </form>
                <xsl:apply-templates select="//sr:results" />
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="sr:results">
        <p><xsl:value-of select="count(sr:result)"/> Treffer zur Suche "<xsl:value-of select="sr:result[1]/sr:query[1]"/>"</p>
        <table>
            <thead>
                <tr>
                    <td>Jahr</td>
                    <td>Konto</td>
                    <td>Text</td>
                    <td>Betrag (in lb)</td>
                </tr>
            </thead>
            <xsl:apply-templates select="sr:result" />
        </table>
    </xsl:template>
    <xsl:template match="sr:result">
        <xsl:variable name="signofamount">
            <xsl:if test="sr:signofamount='http://gams.uni-graz.at/rem/bookkeping/#bk_id'">-</xsl:if>
        </xsl:variable>
        <tr>
            <td>
                <a href="{sr:o/@uri}">
                    <xsl:apply-templates select="sr:jahr" />
                </a>
            </td>
            <td><a href="/archive/objects/query:totalstime/methods/sdef:Query/get?params=$1|&lt;{replace(sr:konto/@uri,'#','%23')}&gt;">
                <xsl:value-of select="substring-after(sr:konto/@uri,'/#bs_')" />
            </a></td>
            <td>
                <a href="{sr:entry/@uri}">
                    <xsl:apply-templates select="sr:text" />
                </a>
            </td>
            <td class="numeric">
                <xsl:value-of select="$signofamount" />
                <xsl:value-of select="sr:betrag/bk:d2lb(text())" />
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>