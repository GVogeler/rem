<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" 
    xmlns:r="http://gams.uni-graz.at/rem/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <!-- 5.6.14: lbd als Währungsbezeichner ergänzt, GV -->
    <!--<xsl:include href="conversions.xsl"/>-->
    <xsl:function name="bk:umrechnung">
        <xsl:param name="wert"/>
        <xsl:param name="name"/>
        <xsl:variable name="zielwert"/>
        <xsl:choose>
            <xsl:when test="empty($wert)">0</xsl:when>
            <xsl:when test="$name='sol.d.'">
                <xsl:value-of select="sum($wert) * 8"/>
            </xsl:when>
            <xsl:when test="$name='d.'">
                <xsl:value-of select="sum($wert)"/>
            </xsl:when>
            <xsl:when test="$name='gul'">
                <xsl:value-of select="sum($wert) * 288"/>
            </xsl:when>
            <xsl:when test="$name='legr'">
                <xsl:value-of select="sum($wert) * 12"/>
            </xsl:when>
            <xsl:when test="$name='gr'">
                <xsl:value-of select="sum($wert) * 12"/>
            </xsl:when>
            <!-- ?? -->
            <xsl:when test="$name='lew'">
                <xsl:value-of select="sum($wert) * 1"/>
            </xsl:when>
            <!-- ?? -->
            <xsl:when test="$name='m'">
                <xsl:value-of select="sum($wert) * 720"/>
            </xsl:when>
            <!-- ?? -->
            <xsl:when test="$name='sc'">
                <xsl:value-of select="sum($wert) * 30"/>
            </xsl:when>
            <xsl:when test="$name='lb' or $name='lbd' or $name='lib.d.' or $name='tl' or $name='lb_d'">
                <xsl:value-of select="sum($wert) * 240"/>
            </xsl:when>
            <xsl:when test="$name='d'">
                <xsl:value-of select="sum($wert) * 1"/>
            </xsl:when>
            <xsl:when test="$name='lb_amb'"><xsl:value-of select="sum($wert) * 120"/>
            </xsl:when>
            <xsl:when test="$name='d_amb'"><xsl:value-of select="sum($wert) * 0.5"/>
            </xsl:when>
            <xsl:when test="$name='ß_d'"><xsl:value-of select="sum($wert) * 8"/>
            </xsl:when>
            <xsl:when test="$name='ß'"><xsl:value-of select="sum($wert) * 8"/>
            </xsl:when>
            <xsl:when test="$name='d_Rat'"><xsl:value-of select="sum($wert) * 1"/></xsl:when>
            <!-- ? -->
            <xsl:when test="$name='lb_Rat'"><xsl:value-of select="sum($wert) * 240"/>
            </xsl:when>
            <!-- ? -->
            <xsl:when test="$name='ß_rat_d'">
                <xsl:value-of select="sum($wert) * 8"/>
            </xsl:when>
            <!-- ? -->
            <xsl:when test="$name='ß_rat'"><xsl:value-of select="sum($wert) * 8"/>
            </xsl:when>
            <!-- ? -->
            <xsl:when test="$name='lb_Rat_d'"><xsl:value-of select="sum($wert) * 240"/>
            </xsl:when>
            <!-- ? -->
            <xsl:when test="$name='ß_amb'"><xsl:value-of select="sum($wert) * 4"/></xsl:when>
            <xsl:when test="$name='fl'"><xsl:value-of select="sum($wert) * 120"/></xsl:when>
            <!-- e_543: 74 fl = 17 lb d?
            -->
            <xsl:when test="$name='fl_rheinisch'"><xsl:value-of select="sum($wert) * 58"/></xsl:when>
            <!-- e_577: 25 fl = 8 lb d
                 e_602 = 12 lb - 5 d-->
            <xsl:when test="$name='fl_ungarisch'"><xsl:value-of select="sum($wert) * 120"/></xsl:when>
            <!-- ? -->
            <xsl:when test="$name='ß-w'"><xsl:value-of select="sum($wert) * 12"/>
            </xsl:when>
            <!-- ?? -->
        </xsl:choose>
    </xsl:function>
    <xsl:function name="bk:reduce">
        <xsl:param name="value"/>
        <xsl:param name="vorzeichen"/>
        <!-- Reduziert einen Pfenningwert auf lb, ß und d nicht-bayerischer Rechnungsweise -->
        <xsl:value-of select="concat($vorzeichen,floor($value div 240))" /> lb
        <xsl:value-of select="concat($vorzeichen,floor(($value mod 240) div 12))"/> ß
        <xsl:value-of select="concat($vorzeichen,(($value mod 240) mod 12))"/> d
    </xsl:function>
    <xsl:template name="zahlen">
        <xsl:param name="input"/>
        <!-- /text() ist einfach numerisch
        /r:sup ist Multiplikation -->
        <xsl:variable name="expo">
            <xsl:choose>
                <xsl:when test="$input/r:sup">
                    <xsl:number value="bk:roman2int($input/r:sup)"/>
                </xsl:when>
                <xsl:otherwise><xsl:number value="1"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="bk:roman2int($input/text()) * $expo"/>
    </xsl:template>
    <xsl:function name="bk:roman2int">
        <!-- ToDo: Das ist ein Platzhalter, der durch eine Java-Funktion zu ersetzen ist, welche die römischen Zahlen in Integer umrechnet -->
        <xsl:param name="input"/>
        <xsl:number value="1"/>
    </xsl:function>
</xsl:stylesheet>