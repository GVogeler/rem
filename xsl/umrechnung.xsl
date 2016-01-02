<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output indent="yes" exclude-result-prefixes="#all"/>
    <xsl:template match="/">
        <test><xsl:apply-templates select="//tei:measure"/></test>
    </xsl:template>
    <xsl:template match="tei:measure">
        <!-- Inhalte in Zahlen umrechnen:
                        Ich gehe davon aus, daß es nur eine Recheneinheit in jedem tei:measure gibt
                        Ich gehe davon aus, daß es nur gerechnet werden soll, wenn es tei:num enthalten ist
                        Ich gehe davon aus, daß das letzte Wort die Recheneinheit bezeichnet
                        Ich gehe davon aus, daß hochgestellte 100er und 1000er mit <seg rend="superscript"> gekennzeichnet sind
                        Ich gehe davon aus, daß es nur ijvxlcm und j/ gibt.
                        
                        1. Zerlegen in Einzelzeichen
                        2. wenn das Folgezeichen "höher" ist als das Ausgangszeichen, dann gibt es eine Subtraktion, sonst eine Addition
                        3. Wenn ein hochgestelltes m/c folgt, dann wird der gesamte Wert damit multipliziert
                        TODO: Die Adressierung des "folgenden" Knotens funktioniert noch nicht: Warum wird aus lxxxij => 78?!
                    -->
        <xsl:variable name="content" select="tokenize(normalize-space(.), ' ')"/>
        <!-- ToDo: die superscript-m/c sind hier noch enthalten und machen Mist bei der Vorzeichenauswahl -->
        <m><unit>
            <xsl:value-of select="$content[last()]"/>
        </unit>
            <xsl:for-each select="$content">
                <xsl:if test="position() != last()"><value>
                    <text><xsl:value-of select="."/></text>
                    <xsl:variable name="chars">
                        <xsl:for-each select="bk:chars(.)">
                            <char><xsl:value-of select="."/></char>
                        </xsl:for-each>
                    </xsl:variable>
                    <chars><xsl:copy-of select="$chars"/></chars>
                    <xsl:variable name="values" select="bk:wert($chars)"/>
                    <values sum="{sum($values)}"><xsl:copy-of select="$values"/></values>
                </value></xsl:if>
        </xsl:for-each>
        </m>
    </xsl:template>
    <xsl:function name="bk:wert">
        <xsl:param name="input"/>
        <!-- $input ist eine Struktur aus römischen Einzelwerten mit @value für die Ziffer -->
            <xsl:for-each select="$input/char">
                <xsl:variable name="value-me" select="bk:roman2arabic(./text())"/>
                <xsl:variable name="value-next" select="bk:roman2arabic($input/char[current()/position() + 1]/text())" />
                <xsl:choose>
                    <xsl:when test="$value-me lt $value-next">
                        <val><xsl:value-of select="-1 * $value-me"/></val>
                    </xsl:when>
                    <xsl:otherwise><val><xsl:value-of select="$value-me"/></val></xsl:otherwise>
            </xsl:choose>
            </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="bk:roman2arabic">
        <xsl:param name="input"/>
        <xsl:choose>
            <xsl:when test="matches($input,'[ijIJ]')">1</xsl:when>
            <xsl:when test="matches($input,'[vV]')">5</xsl:when>
            <xsl:when test="matches($input,'[xX]')">10</xsl:when>
            <xsl:when test="matches($input,'[lL]')">50</xsl:when>
            <xsl:when test="matches($input,'[mM]')">1000</xsl:when>
            <xsl:when test="matches($input,'[cC]')">100</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="bk:chars" as="xs:string*" 
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:sequence select=" 
            for $ch in string-to-codepoints($arg)
            return codepoints-to-string($ch)
            "/>
        
    </xsl:function></xsl:stylesheet>