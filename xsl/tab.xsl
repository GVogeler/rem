<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#default bk tei"
    version="2.0">
    <!-- Ausgabe als Tabelle:
    ToDo: 
    choice/del/corr einbinden
    Suche einbinden-->
    <xsl:output indent="yes"/>
    <xsl:template mode="tab" match="tei:teiHeader"/>
    <xsl:template mode="tab" match="tei:*[@ana='#bk_total-fol' or @ana='#bk_total-col']"/>
    <xsl:template mode="tab" match="tei:head"/>
    <xsl:template mode="tab" match="tei:body">
        <!-- ToDo: Suche würde $context zur Auswahl der einschlägigen Einträge verwenden -->
        <table class="grid">
            <thead>
                <tr><td colspan="20"><a href="?mode=default"/>&lt;Zurück zur Standardansicht&gt;</td></tr>
                <tr><td>Kategorie</td><td>Originaltext</td>
                    <td>Betrag in Pfennig</td>
                    <td>Betrag in 1 lb = 20 ß = 240 d</td><xsl:if test=".//tei:*[@ana='#bk_entry']//tei:term"><td>Errechnete Summe</td><td></td><td>Schlagwörter</td></xsl:if></tr>
            </thead>
            <tbody><xsl:apply-templates mode="tab"><xsl:with-param name="level">0</xsl:with-param></xsl:apply-templates></tbody>
        </table>
    </xsl:template>
    <xsl:template mode="tab" match="tei:div|tei:list">
        <xsl:param name="level"/>
        <!-- Ordnet nach Konten -->
        <!-- ToDo: Die normalisierten Kontenbezeichner wären noch einzubauen -->
        <xsl:if test="tei:head"><tr><td class="grid"><b><xsl:call-template name="striche"><xsl:with-param name="level-max" select="$level"/><xsl:with-param name="level-curr">0</xsl:with-param></xsl:call-template><xsl:value-of select="tei:head"/></b></td></tr></xsl:if>
        <xsl:apply-templates select="tei:div|tei:list|tei:item/tei:list|tei:item/tei:div" mode="tab">
            <xsl:with-param name="level" select="number($level)+1"/>
        </xsl:apply-templates>
        <xsl:apply-templates select=".//tei:*[@ana='#bk_entry']|.//tei:*[matches(@ana,'#bk_total')]" mode="tab"/>
    </xsl:template>
    
    <xsl:template match="tei:*[matches(@ana,'#bk_total')]" mode="tab" >
        <!-- Die Summen -->
        <tr>
            <td />
            <td class="Buchungstext Summe grid"><xsl:apply-templates select="."/></td>
            <td class="Buchungsbetrag Summe grid"><xsl:apply-templates select="tei:*[@ana='#bk_amount']" mode="tab"/></td>
            <td class="grid"><xsl:apply-templates mode="tab-reduce" select="tei:*[@ana='#bk_amount']"/></td>
            <!-- ToDo: Berechnete Summe:
                Alle ancestor::tei:div[1]//tei:*[matches(@ana,'#bk_entry')]//tei:seg[matches(@ana,'#bk_amount')] summieren
                
            -->
            <xsl:variable name="betraege">
                <xsl:for-each select="ancestor::tei:div[1]//tei:*[matches(@ana,'#bk_entry')]">
                    <betrag><xsl:call-template name="betrag"/></betrag>
                </xsl:for-each>
            </xsl:variable>
            <td class="ErrechneteSumme grid">
                <xsl:value-of select="sum($betraege/*/number(text()))"/>
            </td>
            <td class="ErrechneteSumme lg grid"><xsl:value-of select="bk:reduce(sum($betraege/*/number(text())),'')"/></td>
            <td></td>
        </tr>
    </xsl:template>
    
    <xsl:template mode="tab" match="tei:*[@ana='#bk_entry']">
        <!-- Die einzelnen Buchungssätze -->
        <tr>
            <td/>
            <td class="Buchungstext grid"><xsl:apply-templates select="."/></td>
            <xsl:choose>
                <xsl:when test="count(.//tei:*[@ana='#bk_amount']) gt 1 ">
                    <td clas="grid">
                        <table>
                        <xsl:for-each select=".//tei:*[@ana='#bk_amount']">
                            <tr>
                                <td class="Buchungsbetrag"><xsl:apply-templates select="." mode="tab"/></td>
                            </tr>
                        </xsl:for-each>
                    </table>
                    </td>
                    <td class="grid">
                        <table>
                            <xsl:for-each select=".//tei:*[matches(@ana,'#bk_amount')]">
                                <tr>
                                    <td><xsl:apply-templates mode="tab-reduce" select="."/></td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td class="Buchungsbetrag grid"><xsl:apply-templates select=".//tei:*[@ana='#bk_amount']" mode="tab"/></td>
                    <td class="grid"><xsl:apply-templates mode="tab-reduce" select=".//tei:*[@ana='#bk_amount']"/></td>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Die Stichwörter -->
<!--            <xsl:apply-templates select=".//tei:term"/>-->
        </tr>
    </xsl:template>

    <xsl:template match="tei:term">
        <!-- Die Stichwörter -->
        <xsl:choose>
            <xsl:when test="@key">
                <!-- ToDo: @key in normalierte Form umwandeln -->
                <xsl:value-of select="@key"/>
            </xsl:when>
            <xsl:when test="@ref">
                <!-- ToDo: @key in normalierte Form umwandeln -->
                <xsl:value-of select="@ref"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="tab" match="tei:*[@ana='#bk_amount']">
        <!-- Beträge -->
        <xsl:variable name="data_as">
            <xsl:value-of select="ancestor-or-self::node()[matches(@ana,'^.*?(#bk_[id]).*?$') ][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1')"/>
        </xsl:variable>
        <xsl:if test="$data_as = '#bk_d'">
            <xsl:text>-</xsl:text>
        </xsl:if>
        <xsl:call-template name="betrag"/>
    </xsl:template>
    
</xsl:stylesheet>