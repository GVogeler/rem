<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:bas="http://gams.uni-graz.at/srbas/ns/1.0"
    exclude-result-prefixes="#default bk tei"
    version="2.0">
    <xsl:decimal-format name="european" decimal-separator=',' grouping-separator='.' />
    <!-- Ausgabe als Tabelle für DebuggingZwecke
        
        2015-03-25: Hervorhebung für addSpan
        2014-07-30: Seitensummen aus dem richtigen CommonAncestor gebildet, GV
        2014-06-05: Aufruf von Templates aus Divisions aufgeräumt, GV
    -->
    <!-- ToDo: 
        * matches(@ana,"#bs_Remanet") mit berechneten Summen versehen = bs_Einnahmen - bs_Ausgaben
    -->
    <xsl:output indent="yes"/>
    <xsl:variable name="ids">
        <xsl:for-each select="//*/@xml:id">
            <id><xsl:value-of select="."/></id>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template mode="tab-debug" match="tei:teiHeader"/>
    <xsl:template mode="tab-debug" match="tei:*[@ana='#bk_total-fol' or @ana='#bk_total-col']"/>
    <xsl:template mode="tab-debug" match="tei:head"/>
    <xsl:template mode="tab-debug" match="tei:body">
        <!-- ToDo: Suche würde $context zur Auswahl der einschlägigen Einträge verwenden -->
        <table class="grid">
            <thead>
                <tr><td colspan="5" style="margin-bottom:20px"><h1><xsl:apply-templates select="//tei:teiHeader//tei:titleStmt//tei:title"/></h1></td></tr>
                <tr><td colspan="20">Die Rechnung hat <xsl:value-of select="count(//tei:pb)"/> Seitenanfänge kodiert.</td></tr>
<!--                <tr><td colspan="20"><a href="?mode=default"/>&lt;Zurück zur Standardansicht&gt;</td></tr>-->
                <tr>
                    <td>Kategorie</td><td>Originaltext</td>
                    <td>Betrag in 1 lb = 20 ß = 240 d</td><xsl:if test=".//tei:*[@ana='#bk_entry']//tei:term">
                        <td>Errechnete Summe in lb</td>
                        <td>Betrag in Pfennig</td>
                        <td>Errechnete Summe in Pfennig</td><td>Schlagwörter</td></xsl:if>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates mode="tab-debug"><xsl:with-param name="level">0</xsl:with-param></xsl:apply-templates></tbody>
        </table>
    </xsl:template>
    <xsl:template mode="tab-debug" match="tei:div|tei:list">
        <xsl:param name="level"/>
        <!-- Ordnet nach Konten -->
        <!-- ToDo: Man könnte noch die normalisierten Kontenbezeichner einbauen -->
        <xsl:if test="tei:head"><tr><td class="grid"><b><xsl:call-template name="striche"><xsl:with-param name="level-max" select="$level"/><xsl:with-param name="level-curr">0</xsl:with-param></xsl:call-template><xsl:value-of select="tei:head"/></b></td></tr></xsl:if>
        <xsl:apply-templates select="tei:div|tei:list|tei:item/tei:list|tei:item/tei:div|tei:pb|tei:p|.//tei:fw|tei:closer|tei:note|tei:head" mode="tab-debug">
            <xsl:with-param name="level" select="number($level)+1"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="tei:*[matches(@ana,'#bk_total')]" mode="tab-debug" >
        <!-- Die Summen -->
        <xsl:variable name="betraege">
            <xsl:choose>
                <xsl:when test="matches(@ana,'#bk_page')">
                    <!-- Alle #bk_entry, die zwischen der aktuellen Summe und dem letzten pb liegen:
                    current()/preceding::pb[1] = von
                    . = bis
                    => alle auf Von folgenden sind:
                    //*[preceding::$von]
                    Alle Bis vorangehenden sind:
                    //*[fowllowing:bis]
                    + Kaysian Intersection:
                    $ns1[count(.|$ns2)=count($ns2)]
                    <xsl:variable name="vtextBN-MandN" select="$vtextPostM[count(.|$vtextPreN) = count($vtextPreN)]"/>
                    
                    Ist aber sehr teuer (50 Seiten/ca. 40 Seitensummen, auch mit der erste gemeinsame Ancestor-Knoten ./preceding::tei:pb[1]/ancestor::tei:*[current()][1}
                    
                    Umstellen auf fragment.xsl?
                    -->
                    <xsl:variable name="bis" select="./@xml:id"/>
                    <xsl:variable name="commonAncestor" select="./preceding::tei:pb[1]/ancestor::tei:*[.//tei:*[@xml:id=$bis]][1]"/>
                    <xsl:variable name="von" select="preceding::tei:pb[1]/@xml:id"/>
                    <xsl:variable name="NachVon" select="$commonAncestor//tei:*[preceding::tei:*[@xml:id=$von] and matches(@ana,'#bk_entry')]"/>
                    <xsl:variable name="VorBis" select="$commonAncestor//tei:*[following::tei:*[@xml:id=$bis] and matches(@ana,'#bk_entry')]"/>
                    <xsl:variable name="InBeträgeUmzuwandeln" select="$NachVon[count(.|$VorBis) = count($VorBis)]"/>
                    <xsl:for-each select="$InBeträgeUmzuwandeln">
                        <betrag><xsl:call-template name="betrag"/></betrag>                        
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="ancestor::tei:div[1]//tei:*[matches(@ana,'#bk_entry')]">
                        <betrag><xsl:call-template name="betrag"/></betrag>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sumCalc" select="string(sum($betraege/*/number(text())))"/>
        <xsl:variable name="sumReal">
            <xsl:for-each select="tei:*[@ana='#bk_amount']"><xsl:call-template name="betrag"/></xsl:for-each>
        </xsl:variable>
        <xsl:variable name="correct">
            <xsl:if test="$sumCalc != $sumReal/text()"><xsl:text>attention</xsl:text></xsl:if>
        </xsl:variable>
        <tr>
            <td />
            <td><xsl:attribute name="class">Buchungstext Summe grid<xsl:if test="preceding-sibling::*[1]/name()='addSpan'"><xsl:text> addSpan</xsl:text></xsl:if></xsl:attribute><xsl:apply-templates select="."/></td>
            <td class="grid Summe {$correct}"><xsl:apply-templates mode="tab-reduce" select="tei:*[@ana='#bk_amount']"/></td>
            <td class="ErrechneteSumme Summe lg grid {$correct}"><xsl:value-of select="bk:reduce(sum($betraege/*/number(text())),'')"/></td>
            <!-- Berechnete Summe:
                Alle ancestor::tei:div[1]//tei:*[matches(@ana,'#bk_entry')]//tei:seg[matches(@ana,'#bk_amount')] summieren
                
            -->
            <td class="Buchungsbetrag Summe grid {$correct}"><xsl:apply-templates select="tei:*[@ana='#bk_amount']" mode="tab-debug"/></td>
            <td class="ErrechneteSumme Summe grid {$correct}">
                <xsl:value-of select="format-number(number($sumCalc),'###.###', 'european')"/>
            </td>
        </tr>
    </xsl:template>
    
<!--    <xsl:template mode="tab-debug" match="tei:*[@ana='#bk_entry']">
        <!-\- Die einzelnen Buchungssätze -\->
        <tr>
            <td/>
            <td><xsl:attribute name="class">Buchungstext grid<xsl:if test="preceding-sibling::*[1]/name()='addSpan'"><xsl:text> addSpan</xsl:text></xsl:if></xsl:attribute><xsl:apply-templates select="."/></td>
            <xsl:choose>
                <xsl:when test="count(.//tei:*[@ana='#bk_amount']) gt 1 ">
                    <td class="grid">
                        <table>
                            <xsl:for-each select=".//tei:*[matches(@ana,'#bk_amount')]">
                                <tr>
                                    <td><xsl:apply-templates mode="tab-reduce" select="."/></td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                    <td></td>
                    <td clas="grid">
                        <table>
                            <xsl:for-each select=".//tei:*[@ana='#bk_amount']">
                                <tr>
                                    <td class="Buchungsbetrag"><xsl:apply-templates select="." mode="tab-debug"/></td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td class="grid"><xsl:apply-templates mode="tab-reduce" select=".//tei:*[@ana='#bk_amount']"/></td>
                    <td></td>
                    <td class="Buchungsbetrag grid"><xsl:apply-templates select=".//tei:*[@ana='#bk_amount']" mode="tab-debug"/></td>
                </xsl:otherwise>
            </xsl:choose>
        </tr>
    </xsl:template>-->
    
    <xsl:template mode="tab-debug" match="tei:*[@ana='#bk_entry']">
        <!-- FixMe: hier müßte ich eigentlich wieder die blöde Fragmentierung einsetzen:
            1. Baue eine Zeile für jeden Eintrag
            2. Wenn ein Eintrag einen anderne Eintrag enthält (total|entry), dann baue
                a. eine Zeile für den Teil vor dem inneren Eintrag
                b. eine Zeile für den inneren Eintrag
                c. eine Zeile für den Rest des Eintrags
                
             Könnte es auch mehrere Einschübe geben?
            -->
        <xsl:choose>
            <xsl:when test=".//tei:*[matches(@ana,'#(bk|gl)_(total|entry)')]">
                <xsl:variable name="einschub" select="(tei:*[matches(@ana,'#(bk|gl)_(total|entry)')]|tei:pb)"/>
                <xsl:variable name="liste">
                    <xsl:element name="opener" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="xml:id" select="@xml:id"/>
                        <xsl:attribute name="ana">#bk_entry</xsl:attribute>
                        <xsl:copy-of select="(node()|text()) intersect ($einschub[1]/preceding-sibling::*|$einschub[1]/preceding-sibling::text())"/>
                    </xsl:element>
                   <!-- <xsl:for-each select="$einschub">
                        <xsl:element name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id" select="@xml:id"/>
                            <xsl:attribute name="ana" select="@ana"/>
                            <xsl:copy-of select="(node()|text())"/>
                        </xsl:element>
                    </xsl:for-each>-->
                    <xsl:element name="closer" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="ana">#bk_entry</xsl:attribute>
                        <xsl:copy-of select="(node()|text()) intersect ($einschub[last()]/following-sibling::*|$einschub[last()]/following-sibling::text())"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:apply-templates select="$liste/tei:opener" mode="tab-debug"/>
                <xsl:for-each select="(tei:*[matches(@ana,'#(bk|gl)_(total|entry)')]|tei:pb)">
                    <xsl:variable name="test" select="."/>
                    <xsl:apply-templates select="." mode="tab-debug"/>
                </xsl:for-each>
                <xsl:apply-templates select="$liste/tei:closer" mode="tab-debug"/>
            </xsl:when>
            <xsl:otherwise>
                <tr id="{@xml:id}">
                    <td/>
                    <td class="Buchungstext grid"><xsl:apply-templates select="(text()|tei:*[not(matches(@ana,'#(bk|gl)_(total|entry)') or ./name()='pb' or ./name()='fw')])"/></td>
                    <td class="Buchungsbetrag grid right"><xsl:apply-templates select="(tei:*[matches(@ana,'#(bk|gl)_amount')] | .//tei:*[not(matches(@ana,'#(bk|gl)_(entry|total)'))]//tei:*[matches(@ana,'#(bk|gl)_amount')])" mode="tab"/></td>
                    <td><xsl:apply-templates mode="tab-reduce" select="(tei:*[matches(@ana,'#(bk|gl)_amount')] | .//tei:*[not(matches(@ana,'#(bk|gl)_(entry|total)'))]//tei:*[matches(@ana,'#(bk|gl)_amount')])"/></td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:p[not(matches(@ana,'#bk_'))]|tei:body/tei:note|tei:body/tei:head|tei:body//tei:fw" priority="-1" mode="tab-debug">
        <tr><td colspan="100"><xsl:attribute name="class">grid<xsl:if test="preceding-sibling::*[1]/name()='addSpan'"><xsl:text> addSpan</xsl:text></xsl:if></xsl:attribute><xsl:apply-templates /></td></tr>
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
    
    <xsl:template mode="tab-debug" match="tei:*[@ana='#bk_amount']">
        <!-- Beträge -->
        <xsl:variable name="data_as">
            <xsl:value-of select="ancestor-or-self::node()[matches(@ana,'^.*?(#bk_[id]).*?$') ][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1')"/>
        </xsl:variable>
        <xsl:if test="@rend='rbms'">
            <xsl:text> ------- </xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:if test="$data_as = '#bk_d'">
            <xsl:text>-</xsl:text>
        </xsl:if>
        <xsl:call-template name="betrag"/>
    </xsl:template>
    
    <xsl:template match="tei:pb" mode="tab-debug">
        <xsl:variable name="seitenzahl" select="bas:folioangabe(.)"/>
       <tr id="{@xml:id}"><td><span class="pb">[fol. <xsl:value-of select="$seitenzahl"/>]</span></td><td colspan="3"><span class="pb">-------------------------------------------------------------------------</span></td></tr>
    </xsl:template>
    
    <xsl:template name="test-for-id">
        <xsl:variable name="refs">
            <xsl:for-each select="distinct-values(//@*[contains(.,' #') or starts-with(.,'#')])">
                <!-- ToDo: Ein regex? -->
                <xsl:for-each select="tokenize(current(),' ')">
                    <xsl:if test="starts-with(.,'#')">
                        <id>
                            <xsl:value-of select="substring-after(.,'#')"/>
                        </id>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <!-- intersection: $ns1[count(.|$ns2)=count($ns2)]
            -->
        <ul>
            <xsl:for-each select="$refs/*">
                <xsl:variable name="ref" select="current()/text()"/>
                <xsl:if test="not($ids/id[text()=$ref])">
                    <li>
                        <xsl:value-of select="$ref"/>
                        <xsl:text> not found</xsl:text>
                    </li>
                </xsl:if>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    
</xsl:stylesheet>