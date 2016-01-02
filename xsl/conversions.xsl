<?xml version="1.0" encoding="UTF-8"?>
<!-- ToDo: Umrechnungstabellen aus Tripelstore extrahieren.
Datenmodell: 
        * Datenmodell:
            * skos:concept, skos:label = Maßbezeichner, skos:prefLabel ...
            * conv:relatesTo <maßangabe>
            * conv:oneConvertsTo Wert (as xsd:floating)
            * conv:when als zeitliche Eingrenzung, conv:where als geographische Eingrenzung         
Dabei: when und where möglichst CIDOC-CRM-kompatibel, evtl. auch relatesTo und oneConvertsTo
-->
<xsl:stylesheet xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:r="http://gams.uni-graz.at/rem/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xs" version="2.0">
    <xsl:function name="bk:umrechnung">
        <xsl:param name="wert"></xsl:param>
        <xsl:param name="name"></xsl:param>
        <xsl:variable name="zielwert"></xsl:variable>
        <xsl:choose>
            <xsl:when test="empty($wert)">0</xsl:when>
            <xsl:when test="$name='sol.d.'">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='d.'">
                <xsl:value-of select="sum($wert)"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='gul'">
                <xsl:value-of select="sum($wert) * 288"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='legr'">
                <xsl:value-of select="sum($wert) * 12"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='gr'">
                <xsl:value-of select="sum($wert) * 12"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='lew'">
                <xsl:value-of select="sum($wert) * 1"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='m'">
                <xsl:value-of select="sum($wert) * 720"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='sc'">
                <xsl:value-of select="sum($wert) * 30"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='lb' or $name='lbd' or $name='lib.d.' or $name='tl' or $name='lb_d'">
                <xsl:value-of select="sum($wert) * 240"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='d'">
                <xsl:value-of select="sum($wert) * 1"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='lb_amb'">
                <xsl:value-of select="sum($wert) * 120"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='d_amb'">
                <xsl:value-of select="sum($wert) * 0.5"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='ß_d'">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='ß'">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='d_Rat'">
                <xsl:value-of select="sum($wert) * 1"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='lb_Rat'">
                <xsl:value-of select="sum($wert) * 240"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='ß_rat_d'">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='ß_rat'">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='lb_Rat_d'">
                <xsl:value-of select="sum($wert) * 240"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='ß_amb'">
                <xsl:value-of select="sum($wert) * 4"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$name='fl'">
                <xsl:value-of select="sum($wert) * 120"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='fl_rheinisch'">
                <xsl:value-of select="sum($wert) * 58"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='fl_ungarisch'">
                <xsl:value-of select="sum($wert) * 120"></xsl:value-of>
            </xsl:when>
            
            <xsl:when test="$name='ß-w'">
                <xsl:value-of select="sum($wert) * 12"></xsl:value-of>
            </xsl:when>
            
        </xsl:choose>
    </xsl:function>
    <xsl:function name="bk:reduce">
        <xsl:param name="value"></xsl:param>
        <xsl:param name="vorzeichen"></xsl:param>
        
        <xsl:value-of select="concat($vorzeichen,floor($value div 240))"></xsl:value-of> lb
        <xsl:value-of select="concat($vorzeichen,floor(($value mod 240) div 12))"></xsl:value-of> ß
        <xsl:value-of select="concat($vorzeichen,(($value mod 240) mod 12))"></xsl:value-of> d
    </xsl:function>
    <xsl:template name="zahlen">
        <xsl:param name="input"></xsl:param>
        
        <xsl:variable name="expo">
            <xsl:choose>
                <xsl:when test="$input/r:sup">
                    <xsl:number value="bk:roman2int($input/r:sup)"></xsl:number>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number value="1"></xsl:number>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="bk:roman2int($input/text()) * $expo"></xsl:value-of>
    </xsl:template>
    <xsl:function as="xs:decimal" name="bk:roman2int-ext">
        
        <xsl:param name="liste"></xsl:param>
        <xsl:choose>
            <xsl:when test="count($liste) = 1">
                
                <xsl:value-of select="bk:roman2int(normalize-space($liste))"></xsl:value-of>
            </xsl:when>
            <xsl:when test="$liste[2][self::r:sup] and $liste[1][self::text()]">
                
                <xsl:variable name="rest" select="$liste[2]/following-sibling::node()"></xsl:variable>
                <xsl:value-of select="(bk:roman2int($liste[1]) * bk:roman2int($liste[2])) + bk:roman2int-ext($rest) "></xsl:value-of>
            </xsl:when>
            <xsl:when test="count($liste) gt 2">
                
                <xsl:value-of select="bk:roman2int-ext($liste[1]/following-sibling::node())"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                
                0
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="bk:roman2int">
        
        <xsl:param as="xs:string" name="r"></xsl:param>
        <xsl:variable name="r2" select="translate(upper-case(normalize-space($r)), 'J', 'I')"></xsl:variable>
        <xsl:choose>
            <xsl:when test="ends-with($r2,'XC')">
                <xsl:sequence select="90 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'L')">
                <xsl:sequence select="50 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'C')">
                <xsl:sequence select="100 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'D')">
                <xsl:sequence select="500 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'M')">
                <xsl:sequence select="1000 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'IV')">
                <xsl:sequence select="4 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'IX')">
                <xsl:sequence select="9 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'IIX')">
                <xsl:sequence select="8 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'I')">
                <xsl:sequence select="1 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'V')">
                <xsl:sequence select="5 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'X')">
                <xsl:sequence select="10 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:when test="ends-with($r2,'̶')">
                <xsl:sequence select="0.5 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"></xsl:sequence>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
