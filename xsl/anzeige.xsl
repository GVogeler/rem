<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://www.cei.lmu.de/accounting/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#default bk tei"
    version="2.0">
    <xsl:output omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <!-- Anzeige von StV 1378 -->
    <xsl:template match="/">
        <html>
            <head>
                <title>Rechnung des Vitztums Peter von Eck 1335</title>
                <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
                <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js">var dummy;</script>
                <!-- Das JavaScript, das die Buchungen summerit und in div@id=calculations schreibt -->
                <script src="http://gams.uni-graz.at/rem/bookkeeping.js" type="text/javascript">var dummy;</script>
                <link rel="stylesheet" type="text/css" href="http://gams.uni-graz.at/rem/anzeige.css" />
            </head>
            <body>
                <div id="calc"><input type="button" value="Berechnen" onclick="summieren()" />
                <div id="calculations" />
                </div>
                <div id="main"><xsl:apply-templates select="//tei:body"/></div>
                <div id="back">
                    <div id="apparatus">
                        <xsl:apply-templates select="//tei:body//tei:rdg" mode="end" />
                    </div>
                    <div id="notes">
                        <xsl:apply-templates select="//tei:back"/>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:body">
        <xsl:apply-templates />
        <!-- Suche würde hier einen Parameter mit auswerten -->
    </xsl:template>
    <xsl:template match="tei:div">
        <div>
            <xsl:if test="substring-before(./@ana,':') = 'bk'">
                <xsl:attribute name="data-type"><xsl:value-of select="./@ana" /></xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="." />
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <xsl:template match="tei:list">
        <xsl:apply-templates select="tei:head" />
        <ul>
            <xsl:if test="substring-before(./@ana,':') = 'bk'">
                <xsl:attribute name="data-type"><xsl:value-of select="./@ana" /></xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="." />
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="tei:item"/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:head">
        <!-- Nach Hierarchiestufe zu differenzieren: Das Abziehen funktioniert nur bedingt -->
        <xsl:variable name="tiefe" select="concat('h',count(./ancestor-or-self::node()[name()='div' or name()='list']) - (if (count(./ancestor-or-self::node()[name()='div' or name()='list']) lt 3) then 0 else 2))" />
        <xsl:element name="{$tiefe}">
        	<xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
            <xsl:if test="substring-before(./@ana,':') = 'bk'">
                <xsl:attribute name="data-type"><xsl:value-of select="./@ana" /></xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="." />
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates />
        </p>
    </xsl:template>
    <xsl:template match="tei:item">
        <li>
            <xsl:if test="substring-before(./@ana,':') = 'bk'">
                <xsl:attribute name="data-type"><xsl:value-of select="./@ana" /></xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="." />
                </xsl:call-template>
            </xsl:if>
            
            
            <!--                Intersection between ancestor-or-self::node()[name()='div' or name()='list']/@anaana und //tei:taxonomy//tei:category/@xml:id
            <xsl:variable name="hierarchy">
                <html:hier xmlns:html="http://www.w3.org/1999/xhtml">
                    <xsl:for-each select="ancestor-or-self::node()[name()='div' or name()='list']/translate(@ana,':','_')">
                        <html:it><xsl:value-of select="."/></html:it>
                    </xsl:for-each>
                </html:hier>
            </xsl:variable>
            <xsl:variable name="taxonomy" select="//tei:taxonomy//tei:category/@xml:id" />
            <xsl:for-each select="$hierarchy//html:it">
                hi: <xsl:value-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="$taxonomy">
                tx: <xsl:value-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="$taxonomy[count(.|$hierarchy) = count($hierarchy)]">
                intersection: <xsl:value-of select="."/>
            </xsl:for-each>
             -->
            
            
            <xsl:apply-templates />
        </li>
    </xsl:template>

    <xsl:template match="tei:pb">
        <xsl:variable name="facs" select="substring-after(./@facs, '#')" />
        <p class="folio"><a>
            <xsl:attribute name="href"><xsl:value-of select="//tei:graphic[@xml:id = '{$facs}']/tei:url" /></xsl:attribute>
            <xsl:text>fol. </xsl:text><xsl:value-of select="./@n"/>
        </a></p>
    </xsl:template>
    
    <xsl:template match="tei:note">
        <!-- Unterscheidung zwischen inline und am Textende -->
        <!-- Fußnotenzählung: count(preceding::tei:note) -->
    	<p class="footnote">
    	    <xsl:apply-templates select="@xml:id"/>
    		<span class="footnote_number"><xsl:value-of select="substring-after(@xml:id,'-')" /></span>
    		<xsl:apply-templates />
    	</p>
    </xsl:template>

   <xsl:template match="*[./@corresp and not(substring-before(@ana,':') = 'bk')]">
    	<xsl:apply-templates />
    	<a class="footnote_reference">
    	<!-- hochgestellt und kursiv -->
    		<xsl:attribute name="href" select="./@corresp" />
    	    <!-- Fußnotenzählung: count(preceding::tei:note) -->
    	    <xsl:value-of select="substring-after(./@corresp,'-')" />
    	</a>
    </xsl:template>

    <xsl:template match="@xml:id">
        <a name="{./string()}" />
    </xsl:template>
    
    <xsl:template match="@rend">
    	<xsl:attribute name="class">
    		<xsl:value-of select="." />
    	</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
    	<span class="foreign">
    	<!-- das wäre normalerweise kursiv -->
    		<xsl:apply-templates />
    	</span>
    </xsl:template>
    
    <xsl:template match="tei:g">
        <!-- @type oder @rend darstellen -->
        <span title="{./@rend}">
            <xsl:apply-templates />
        </span>    
    </xsl:template>

    <!-- textkritisches: -->
    <xsl:template match="choice">
        <!-- Präferierte Auflösung markieren und Anzeigeform für die Alternative festlegen; Funktionalität zum Austauschen der beiden Formen -->
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="tei:seg[@rend='superscript']">
    <!-- hochgestellt -->
        <span class="sup"><xsl:apply-templates /></span>
    </xsl:template>
    <xsl:template match="tei:del">
        <del><xsl:apply-templates /></del>
    </xsl:template>
    <xsl:template match="tei:gap">
        <span>
            <xsl:attribute name="title"><xsl:value-of select="@reason"/></xsl:attribute>
            <xsl:text>[...]</xsl:text>
        </span>
    </xsl:template>
    <xsl:template match="tei:app|add">
    	<xsl:apply-templates />
    </xsl:template>
    <xsl:template match="tei:rdg">
        <xsl:variable name="n" select="generate-id(.)" />
        <a href="{concat('#',$n)}" class="footnote_reference"><xsl:value-of select="$n" /></a>
    </xsl:template>
    <xsl:template match="tei:rdg" mode="end">
        <xsl:variable name="n" select="generate-id(.)" />
        <a name="{concat('#',$n)}" class="footnote_number"><xsl:value-of select="$n" /></a>
        <xsl:apply-templates />        
    </xsl:template>
    
    <!-- Buchhaltung:  -->
    <xsl:template match="tei:measure">
        <span>
        <xsl:if test="substring-before(./@ana,':') = 'bk'">
            <xsl:attribute name="data-type"><xsl:value-of select="./@ana" /></xsl:attribute>
            <xsl:call-template name="bk">
                <xsl:with-param name="element" select="." />
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="tei:num">
        <span class="number">
            <xsl:attribute name="title"><xsl:value-of select="@value"/></xsl:attribute>
            <xsl:apply-templates />
        </span><xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template name="bk">
        <xsl:param name="element" />
        <!-- die Datenstruktur aus @ana="bk:" etc. aufbauen -->
        

        
        <xsl:if test="./@ana='bk:entry' or ./@ana='bk:total'">
            <xsl:attribute name="data-account" >
                <xsl:variable name="accounts">
                    <html:ul>
                    <xsl:for-each select="ancestor-or-self::node()[name()='div' or name()='list']/@ana">
                        <xsl:variable name="ana" select="translate(.,':','_')" />
                        <xsl:if test="//tei:taxonomy[@ana='bk:account']//tei:category[@xml:id = $ana]">
                            <html:item><xsl:value-of select="."/></html:item>
                        </xsl:if>
                    </xsl:for-each>
                    </html:ul>
                </xsl:variable>
                <xsl:for-each select="distinct-values($accounts//html:item)">
                    <xsl:value-of select="."/><xsl:text>/</xsl:text>    
                </xsl:for-each>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@ana='bk:total' or ./@ana='bk:balance'">
            <xsl:attribute name="data-corresp" select="@corresp" />
        </xsl:if>

        <!-- amount: --><xsl:apply-templates select="./tei:measure[./@type='currency'] | .//tei:*[@ana='bk:amount']" mode="bk-attributes"/>
        
    </xsl:template>
    

    <xsl:template match="tei:measure[./@type='currency']|tei:*[@ana='bk:amount']" mode="bk-attributes">
        <xsl:variable name="data_as">
            <xsl:value-of select="ancestor-or-self::node()[@ana='bk:d' or @ana='bk:i'][1]/@ana" />
        </xsl:variable>
        <xsl:attribute name="data-amount">
            <xsl:if test="$data_as = 'bk:d'">
                <xsl:text>-</xsl:text>
            </xsl:if>
            <xsl:call-template name="betrag" />
        </xsl:attribute>
        <xsl:attribute name="data-unit">d.</xsl:attribute>
    </xsl:template>
        
    <!-- Die Rechnungskonversionen -->
    
    <xsl:template match="muh">
        <!--tei:*[substring-before(@ana,':')='bk' and .//tei:measure]-->
        <!--  Das sind die Buchungsposten  -->
        <!-- Da sollte ich noch die ID übernehmen, oder? -->
        <!-- Die Summen wären auch noch anders zu behandeln -->
        <xsl:element name="{./@ana}">
            <!-- Datierung aus ./tei:date(@when oder @from/to oder .//tei:*[ana="bk:date"] -->
            <xsl:if test="./@ana='bk:total' or ./@ana='bk:balance'">
                <xsl:attribute name="bk:scope" select="@corresp" />
            </xsl:if>
            <xsl:attribute name="bk:id">
                <!-- Der Identifikator stammt aus @n -->
                <xsl:value-of select="./@n" />
            </xsl:attribute>
            <xsl:element name="bk:account">
                <!-- Die Taxonomie aus dem aktuellen Eintrag der _nächsten_ übergeordneten liste/div hinein (wenn ich die ganze Hierarchie sehen will, dann muß ich [1] weglassen)
                    ToDo: Überprüfen, ob es eine account-Taxonomie ist (taxonomy/...)
                -->
                <xsl:value-of select="ancestor-or-self::node()[name()='div' or name()='list'][1]/@ana" />
            </xsl:element>
            <xsl:apply-templates select="./tei:measure[./@type='currency'] | .//tei:*[@ana='bk:amount']"/>
            <!-- Das wären die Buchungssätze, die als solche wie in einer Tabelle ausgewertet werden könnten -->
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template name="betrag">
        <xsl:choose>
            <xsl:when test="not(./@quantity) or ./@quantity = 0">
                <!-- Die Summe aller untergeordneten tei:measure -->
                <!-- Die Währungseinheiten müßten noch über Variablen externalisiert werden -->                        
                <xsl:value-of select="sum(bk:umrechnung(.//tei:measure[./@type='currency']/@quantity, ./@unit)) 
                    + sum(bk:umrechnung(./tei:num/@value,./@unit))
                    + sum(.//tei:measure[./@type='currency']/bk:umrechnung(tei:num/@value,./@unit))
                    "
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="bk:umrechnung(./@quantity, ./@unit)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--<xsl:include href="conversions.xsl"/>-->
    <xsl:function name="bk:umrechnung">
        <xsl:param name="wert" />
        <xsl:param name="name" />
        <xsl:variable name="zielwert"/>
        <xsl:choose>
            <xsl:when test="empty($wert)">0</xsl:when>
            <xsl:when test="$name='lib.d.'"><xsl:value-of select="sum($wert) * 240" /></xsl:when>
            <xsl:when test="$name='sol.d.'"><xsl:value-of select="sum($wert) * 8" /></xsl:when>
            <xsl:when test="$name='d.'"><xsl:value-of select="sum($wert)" /></xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="bk:is_account">
        <xsl:param name="accounts" />
        <xsl:copy-of select="$accounts" />
<!--        <xsl:for-each select="$accounts//html:li"     xmlns:html="http://www.w3.org/1999/xhtml"
            >     <xsl:if test="//tei:taxonomy[@ana='bk:account']//tei:category[@xml:id/string() = string(.)]">
            <xsl:value-of select="." />            
        </xsl:if>
        </xsl:for-each>
-->        
    </xsl:template>
    
    <xsl:template name="currency">
<!--        Das müssen Triple aus Ausgangswährung, Zielwährung, Kurs werden, die übrigens auch im Ausgangsdokument enthalten sein könnten (bk:conversion ...) -->
        <xsl:param name="name" />
        <xsl:choose>
            <xsl:when test="$name='lib.d.'">240</xsl:when>
            <xsl:when test="$name='sol.d.'">8</xsl:when>
            <xsl:when test="$name='d.'">1</xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
</xsl:stylesheet>