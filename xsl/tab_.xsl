<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#default bk tei"
    version="2.0">
    <!-- Ausgabe als Tabelle:
    ToDo: Suche einbinden-->
    <xsl:import href="conversions.xsl"/>
    <xsl:import href="default.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:template mode="tab" match="tei:teiHeader"/>
    <xsl:template mode="tab" match="tei:*[@ana='bk:total-fol' or @ana='bk:total-col']"/>
    <xsl:template mode="tab" match="tei:head"/>
    <xsl:template mode="tab" match="tei:body">
        <table>
            <xsl:apply-templates mode="tab"/>
        </table>
    </xsl:template>
    <xsl:template mode="tab" match="tei:category">
        <xsl:param name="level"/>
        <!-- Ordnet nach Konten -->
        <tr><td><b><xsl:call-template name="striche"><xsl:with-param name="level-max" select="$level"/><xsl:with-param name="level-curr">0</xsl:with-param></xsl:call-template><xsl:value-of select="tei:catDesc"/></b></td></tr>
        <xsl:apply-templates select="tei:category" mode="tab">
            <xsl:with-param name="level" select="number($level)+1"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="//tei:*[@ana=translate(current()/@xml:id,'_',':')]/tei:*[@ana='bk:entry']|//tei:*[@ana=@xml:id]/tei:*[@ana='bk:entry']" mode="tab"/>
        <xsl:apply-templates select="//tei:*[@ana=translate(current()/@xml:id,'_',':')]/tei:*[@ana='bk:total']|//tei:*[@ana=@xml:id]/tei:*[@ana='bk:total']" mode="tab"/>
    </xsl:template>
    <xsl:template mode="tab" match="tei:*[@ana='bk:total']">
        <!-- Die Summen -->
        <tr><td/>
            <td class="Buchungstext Summe"><xsl:value-of select="."/></td>
            <!-- Das folgende geht nicht bei Splitbuchungen mit mehreren amounts -->
            <td class="Buchungsbetrag Summe"><table><xsl:apply-templates select="tei:*[@ana='bk:amount']" mode="tab"/></table></td></tr>
    </xsl:template>
    <xsl:template mode="tab" match="tei:*[@ana='bk:entry']">
        <!-- Die einzelnen Buchungssätze -->
        <tr><td/>
            <td class="Buchungstext"><xsl:value-of select="."/></td>
            <!-- Das folgende geht nicht bei Splitbuchungen mit mehreren amounts -->
            <td class="Buchungsbetrag"><table><xsl:apply-templates select="tei:*[@ana='bk:amount']" mode="tab"/></table></td></tr>
    </xsl:template>
    <xsl:template mode="tab" match="tei:*[@ana='bk:amount']">
        <xsl:variable name="data_as">
            <xsl:value-of select="ancestor-or-self::node()[@ana='bk:d' or @ana='bk:i'][1]/@ana"/>
        </xsl:variable>
        <tr><td><xsl:if test="$data_as = 'bk:d'">
            <xsl:text>-</xsl:text>
        </xsl:if>
        <xsl:call-template name="betrag"/></td></tr>
    </xsl:template>
    
    <xsl:template name="striche">
        <xsl:param name="level-max"/>
        <xsl:param name="level-curr"/>
        <xsl:if test="$level-curr &lt; $level-max"><xsl:text>- </xsl:text><xsl:call-template name="striche"><xsl:with-param name="level-max" select="$level-max"/><xsl:with-param name="level-curr" select="$level-curr + 1"></xsl:with-param></xsl:call-template></xsl:if>
    </xsl:template>
    
    
    
</xsl:stylesheet>