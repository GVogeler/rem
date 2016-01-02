<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#default bk tei"
    version="2.0">
    <xsl:output omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <!-- Anzeige von Rechnungen, 2013-12-16:
    Standardansicht
    
    2014-08-28: Trefferhervorhebung über template@name="highlighting"
    2014-06-06: Betragsberechnungen verbesser: arabische Zahlen im Text nur, wenn es keine @quantity gibt
    2014-06-04: tei:p um Klammern erweitert. ToDo: Bei Klammern in Klammern funktioniert das vermutlich nicht, weil StandOff
    -->
    <xsl:variable name="accounts" select="//tei:taxonomy[@ana='#bk_account']"/>
    <xsl:variable name="xmlBaseAccounts" select="//tei:classDecl[.//tei:taxonomy/@ana='#bk_account']/@xml:base"/>
    <!-- = Suchparameter -->
    <xsl:template match="tei:TEI">
        <div class="ym-wrapper">
            <div class="ym-wbox">
                <!-- Der Header sollte natürlich auch Daten aus dem Projekt aufnehmen -->
                <div class="wbox header">
                    <h1 style="color:white;">
                        <a href="/rem" style="color:white;">&lt; REM /&gt;</a><br/>
                            <xsl:value-of
                                select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"
                            />
                    </h1>
                        <xsl:apply-templates
                            select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:p"
                        />
                    <p>ed. by <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor"/></p>
                    <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt//tei:p"></xsl:apply-templates>
                </div>
                <div class="ym-column">
                    <div class="ym-col1" id="Navigation">
                        <div class="ym-cbox">
                            <!-- Gliederung als Inhaltsverzeichnis
                            ToDo: Hierarchisch gliedern; 
                            Struktur ohne xml:id aufbauen?-->
                            <h2>Inhalt</h2>
                            <ul>
                                <xsl:apply-templates
                                    select="//tei:div[@xml:id and ./tei:head]|//tei:list[@xml:id and ./tei:head]"
                                    mode="toc"/>
                            </ul>
                        </div>
                    </div>
                    <div class="ym-col2" id="calc">
                        <!--                            <input type="button" value="Berechnen" onclick="summieren()"/>-->
                        <div class="ym-cbox">
                            <p><a href="http://gams.uni-graz.at/archive/objects/{$pid}/datastreams/TEI_SOURCE/content" target="_blank"><img src="http://gams.uni-graz.at/reko/img/tei_icon.gif"/> Quelldaten</a></p>
                            <form method="get">
                                <xsl:attribute name="action"><xsl:value-of  select="concat('/archive/get/',$pid,'/sdef:TEI/get')"/></xsl:attribute>
                                <p>
                                    <input name="context" type="text" size="20" value="{$context}"/>
                                    <input type="submit" value="Suchen"/><br/>
                                    <a href="#hit">Treffer</a>
                                </p>

                            </form>
                            <h2>
                                <a id="AnsichtUmschalter" href="javascript:diplomatic()"
                                    >Editionsansicht</a>
                            </h2>
                            <h2><a href="http://gams.uni-graz.at/archive/objects/{$pid}/methods/sdef:TEI/get?mode=tab">tabellarische Ansicht</a></h2>
                            <h2>Beträge</h2>
                            <p><a href="http://gams.uni-graz.at/archive/objects/{$pid}/datastreams/RDF/content">RDF/XML</a></p>
                            <div id="calculations">
                                <xsl:text> </xsl:text>
                            </div>
                        </div>
                    </div>
                    <div class="ym-col3" id="main">
                        <div class="ym-cbox">
                            <xsl:choose>
                                <xsl:when test="$mode='debugging'">
                                    <xsl:apply-templates select="//tei:body" mode="d"/>
                                    <!-- Die Templates für das Debugging stehen 'gams/rem/debugging.xsl'-->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="//tei:body"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                </div>
                <div id="back" class="ym-col3 appendix">
                    <div id="apparatus">
                        <xsl:apply-templates
                            select="//tei:body//tei:app/tei:rdg|//tei:body//tei:add|//tei:body//tei:del|//tei:body//tei:space|//tei:body//tei:sic|//tei:body//tei:supplied|//tei:body//tei:unclear|//tei:body//tei:gap|//tei:body//tei:choice|//tei:body//tei:damage"
                            mode="end"/>
                    </div>
                    <div id="notes">
                        <xsl:apply-templates select="//tei:note" mode="end"/>
                        <xsl:apply-templates select="//tei:back"/>
                    </div>
                </div>
                <footer><hr/><a href="#top">Top of page</a><br />Model by Georg Vogeler, 2012-2013, <a href="http://informationsmodellierung.uni-graz.at">Centre for Information Modeling - Austrian Centre for Digital Humanities, University of Graz</a>, with the help of <a href="http://gams.uni-graz.at"
                    >GAMS</a></footer>
            </div>
            <script type="text/javascript">
                summieren();
            </script>
        </div>
    </xsl:template>
    <xsl:template match="tei:body">
        <!-- Suche wertet hier einen Parameter mit aus: 
        Ist es anzustreben, daß nur die kleinste ausgewählte Einheit (bk:entry) in der übergeordneten Hierarchie angezeigt wird?
        
        Derzeit werden die Treffer einfach hervorgehoben und nur sie in die Rechnung einbezogen.
        -->
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:metamark">
        <!-- ToDo: 
            erfordert einen Prozeß, bei dem das Element aus @target über @function den über @spanTo gesammelten Elementen zugeordnet wird. Es wäre also "von hinten" aufzudröseln: @target hat bk:...-Aufgabe (z.B. Beträge). Die ist anzuwenden auf bestimmte bk:...-Elemente (z.B. Buchungen) und zwar über @function (z.B. repeat). 
            Eine zweite Frage ist, wie das zu visualisieren wäre. Dazu braucht es a) eine Visualisierung für die Klammer und b) eine Default-Visualisierung, wenn @rend nicht auswertbar ist.:
            klammerliste(1-last)(e oder target): 
                e[1]: ┐ 
                e[last()]: ┘ 
                e[*]: ┤ 
                b:├ (bzw. ┌└ wenn es am Enfang oder am ende steht
                
            Und das ganze ist wieder mal ein Stand-Off-Markup, das zwischengeschoben wird.
        -->
    </xsl:template>
    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="$context">
                <xsl:call-template name="bk:highlighter"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- FixMe: tabulator einbauen? -->
    </xsl:template>
    <xsl:template name="bk:highlighter">
        <xsl:analyze-string select="."
            regex="{$context}">
            <xsl:matching-substring>
                <span id="hit" name="hit" class="highlight"><a href="#hit" class="hitprev">[&lt;]</a>
                    <xsl:value-of select="."/>
                </span><a href="#" class="hitnext">[&gt;]</a>
            </xsl:matching-substring>                
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:function name="bk:tabulator">
        <xsl:param name="input"/>
        <xsl:if test="contains($input,'#|#')">
            <xsl:value-of select="substring-before($input,'#|#')"/>
            <span class="tab">
                <xsl:text>  </xsl:text>
            </span>
            <xsl:value-of select="substring-after($input,'#|#') "/>
        </xsl:if>        
    </xsl:function>
    <xsl:template match="tei:div">
        <div>
            <xsl:if test="substring-before(./@ana,'_') = '#bk'">
                <xsl:attribute name="data-type">
                    <xsl:value-of select="./@ana"/>
                </xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="."/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="@n"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="@n">
        <a name="{.}"> </a>
    </xsl:template>
    <xsl:template match="tei:list">
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@xml:id"><xsl:apply-templates select="@xml:id"/></xsl:when>
                <xsl:when test="tei:head"><a><xsl:attribute name="name">heading_<xsl:value-of select="translate(tei:head,' -+#?&amp;;.,!:()/§$%=`´\}][{*~|','')"/></xsl:attribute></a></xsl:when>
                <xsl:otherwise><a><xsl:attribute name="name"><xsl:value-of select="generate-id(.)"/></xsl:attribute></a></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:apply-templates select="tei:head"/>
        <ul class="entries undot">
            <xsl:if test="substring-before(./@ana,'_') = '#bk'">
                <xsl:attribute name="data-type">
                    <xsl:value-of select="./@ana"/>
                </xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="."/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="tei:item |tei:pb|tei:lb"/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:div|tei:list" mode="toc">
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
                <xsl:when test="tei:head">heading_<xsl:value-of select="translate(tei:head,' -+#?&amp;;.,!:()/§$%=`´\}][{*~|','')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <a href="#{$id}">
                <xsl:if test="$context and matches(.,$context)">
                    <xsl:attribute name="class">highlight</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="./tei:head"/>
            </a>
        </li>
    </xsl:template>
    <xsl:template match="tei:head">
        <!-- Nach Hierarchiestufe zu differenzieren: Das Abziehen funktioniert nur bedingt -->
        <xsl:variable name="tiefe"
            select="concat('h',count(./ancestor-or-self::node()[name()='div' or name()='list']) - (if (count(./ancestor-or-self::node()[name()='div' or name()='list']) lt 3) then 0 else 2))"/>
        <xsl:element name="{$tiefe}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:lb"><xsl:if test="@break='no'">-</xsl:if><br class="diplomatic visible"/></xsl:template>
    
    <!-- ToDo: Schlagwörter irgendwo "sichtbar" machen? -->
    <!-- ToDo: Die Seitentitel anders behandeln? -->
    <xsl:template match="tei:p|tei:fw|tei:closer">
        <a>
            <xsl:attribute name="name" select="./@xml:id"/>
        </a>
        <p>
            <xsl:if test="matches(@ana,'#bk_')">
                <xsl:attribute name="class">entry</xsl:attribute>
                <!-- ?ToDo: ist wirklich jeder #bk von der css-Klasse entry? -->
                <xsl:attribute name="data-type">
                    <xsl:value-of select="./@ana"/>
                </xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="."/>
                </xsl:call-template>
            </xsl:if>
            <!-- ToDo: Nur in der Tabellenansicht? -->
            <xsl:choose>
                <xsl:when test="concat('#',@xml:id) = preceding-sibling::tei:metamark[1]/@spanTo">
                    <span title="Hinter der Klammer"><xsl:text>└──▷</xsl:text></span>
                </xsl:when>            
                <xsl:when test="preceding-sibling::tei:metamark[1][contains(@rend,'Klammer')] and not(preceding-sibling::*[concat('#',@xml:id) = preceding::tei:metamark[1]/@spanTo])">
                   <span title="Klammer"><xsl:text>│</xsl:text></span>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:item">
        <a>
            <xsl:attribute name="name" select="./@xml:id"/>
        </a>
        <li>
            <xsl:if test="substring-before(./@ana,'_') = '#bk'">
                <xsl:attribute name="class">
                    <xsl:if test="$context">
                        <xsl:choose>
                            <xsl:when test="matches(.,$context)">hit</xsl:when>
                            <xsl:otherwise>nohit</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="translate(./@ana,':','_')"/>
                </xsl:attribute>
                <xsl:attribute name="data-type">
                    <xsl:value-of select="./@ana"/>
                </xsl:attribute>
                <xsl:if test="($context and matches(.,$context))">
                    <xsl:attribute name="style">background-color:yellow;</xsl:attribute>
                </xsl:if>
                <xsl:if test="(matches(.,$context)) or not($context)">
                    <xsl:call-template name="bk">
                        <xsl:with-param name="element" select="."/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
            <xsl:if test="preceding-sibling::tei:metamark[1]/contains(@rend,'Klammer')">
                <xsl:text>↓</xsl:text>
            </xsl:if>
            <xsl:if test="concat('#',@xml:id) = preceding::tei:metamark[1]/@spanTo">
                <xsl:text>└──→</xsl:text>
            </xsl:if>            
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="tei:pb">
        <!-- Seitenwechsel mit Link auf das Bild -->
        <xsl:variable name="facs" select="substring-after(./@facs, '#')"/>
        <xsl:variable name="seitenzahl">
            <xsl:choose>
                <xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="ceiling((count(preceding::tei:pb) + 1) div 2)"/>
                <xsl:choose><xsl:when test="(count(preceding::tei:pb) + 1) mod 2 = 1">r</xsl:when>
                <xsl:otherwise>v</xsl:otherwise></xsl:choose></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <a>
            <xsl:attribute name="name" select="./@xml:id"/>
        </a>
        <p class="ym-g20 folio editor">
            <a name="fol{$seitenzahl}"/>
            <a target="_blank">
                <xsl:attribute name="href">
                    <xsl:value-of select="//tei:surface[@xml:id = $facs]/tei:graphic/@url"/>
                </xsl:attribute>
                <xsl:text>fol. </xsl:text>
                <xsl:value-of select="$seitenzahl"/>
            </a>
        </p>
    </xsl:template>
    
    <xsl:template match="gb">
        <!-- ToDo: Die einzelnen Hefte sind ja eigentlich zu unterscheiden und die Seitenzahlen getrennt zu berechnen -->
    </xsl:template>

    <xsl:template match="tei:note">
        <!-- Unterscheidung zwischen inline und am Textende -->
        <!-- Fußnotenzählung: count(preceding::tei:note) oder */@corresp=*/@xml:id ? letzteres bildet die Reihenfolge der Fußnoten im Haupttext ab, ersteres die der Fußnotenliste -->
        <xsl:choose>
            <xsl:when test="ancestor::tei:body">
                <xsl:variable name="ref">
                    <xsl:choose>
                        <xsl:when test="@corresp"><xsl:value-of select="@corresp"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="concat('#',generate-id())"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <sup>
                    <a>
                        <xsl:attribute name="href" select="$ref"/>
                        <!-- ID generieren? -->
                        <xsl:choose><xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="count(preceding::tei:note) + 1"></xsl:value-of>
                        </xsl:otherwise></xsl:choose>
                    </a>
                </sup>
            </xsl:when>
            <xsl:otherwise>
                <p class="footnote">
                    <xsl:apply-templates select="@xml:id"/>
                    <span class="footnote_3">
                        <!--                <xsl:value-of select="count(*[./@corresp eq concat('#',@xml:id) or ./@key eq concat('#',@xml:id)][1]/preceding::*[(./@corresp and not(substring-before(@ana,'_') = '#bk')) or ./@key])" />-->
                        <xsl:value-of select="count(./preceding::tei:note) + 1"/>)
                        <!--                 <xsl:value-of select="count(//*[substring-after(./@corresp,'#') = ./@xml:id]/preceding::*[substring-after(./@corresp,'#') = //*/@xml:id]) + 1"/> liefert immer 1
-->
                    </span>
                    <!--<span class="footnote_number"><xsl:value-of select="substring-after(@xml:id,'-')" /></span>-->
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:note" mode="end">
        <xsl:variable name="ref">
            <xsl:choose>
                <xsl:when test="@xml:id"><xsl:value-of select="@corresp"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <p class="footnote">
            <xsl:element name="a"><xsl:attribute name="name" select="$ref"/></xsl:element>
            <span class="footnote_3">
                <!--                <xsl:value-of select="count(*[./@corresp eq concat('#',@xml:id) or ./@key eq concat('#',@xml:id)][1]/preceding::*[(./@corresp and not(substring-before(@ana,'_') = '#bk')) or ./@key])" />-->
                <xsl:value-of select="count(./preceding::tei:note) + 1"/>)
                <!--                 <xsl:value-of select="count(//*[substring-after(./@corresp,'#') = ./@xml:id]/preceding::*[substring-after(./@corresp,'#') = //*/@xml:id]) + 1"/> liefert immer 1
-->
            </span>
            <!--<span class="footnote_number"><xsl:value-of select="substring-after(@xml:id,'-')" /></span>-->
            <xsl:apply-templates/>
        </p>
    </xsl:template>        
    <xsl:template match="*[(./@corresp and not(substring-before(@ana,'_') = '#bk')) or ./@key]">
        <xsl:variable name="element" select="."/>
        <!--hochgestellt und kursiv-->
        <xsl:variable name="ref">
            <xsl:choose>
                <xsl:when test="./@target">
                    <!-- Das wäre also ganz normaler Link auf zulösen -->
                    <xsl:value-of select="./@target"/>
                </xsl:when>
                <xsl:when test="./@key">
                    <xsl:value-of select="./@key"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./@corresp"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <a class="object">
            <xsl:attribute name="href" select="$ref"/>
            <xsl:attribute name="title"
                select="//tei:note[@xml:id = substring-after($ref,'#')]/string()"/>
            <xsl:apply-templates/>
        </a>
        <!--
          <a class="footnote_reference">
          <!-\- Fußnotenzählung: -\->
            <xsl:attribute name="href" select="$ref"/>
            <xsl:value-of
                select="(count(//tei:note[@xml:id eq substring-after($element/@corresp,'#') or @xml:id eq substring-after($element/@key,'#')]/preceding::tei:note)) + 1"/>
            <!-\-<xsl:value-of select="substring-after(./@corresp,'-')" />-\->
        </a>-->
    </xsl:template>

    <xsl:template match="@xml:id">
        <a name="{./string()}"/>
    </xsl:template>

    <xsl:template match="@rend">
        <xsl:attribute name="class">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:foreign">
        <span class="foreign">
            <!-- das wäre normalerweise kursiv -->
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:g">
        <!-- @type oder @rend darstellen -->
        <span title="{./@rend}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- textkritisches: -->
    <xsl:template match="choice">
        <!-- Präferierte Auflösung markieren und Anzeigeform für die Alternative festlegen; Funktionalität zum Austauschen der beiden Formen -->
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:seg[@rend='super' or @rend='superscript']">
        <!-- hochgestellt -->
        <span class="sup">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!--    <xsl:template match="tei:del">
        <del>
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    -->
    <xsl:template match="tei:gap">
        <xsl:variable name="id" select="generate-id(.)"/>
        <xsl:text>[...]</xsl:text>
        <xsl:variable name="n" select="bk:textcriticalnote(.)"/>
        <a href="{concat('#',$id)}" class="footnote_reference">
            <xsl:value-of select="$n"/>
        </a>
    </xsl:template>
    <xsl:template match="tei:add|tei:del|tei:sic|tei:space|tei:unclear|tei:corr|tei:damage">
        <xsl:variable name="id" select="generate-id(.)"/>
        <!-- In der Fußnote steht entweder alles aus rdg, oder ToDo: die Kommentare aus add/gap/del ... mit einem Verweis auf die Handschrift und einem normierten Bezeichner ("gestrichen" etc.); tei:space kann auch ein nicht-kommentierungswürdiger Abstand der diplomatischen Ansicht sein ... 
        In der diplomatischen Abschrift könnte das auch visualisiert werden, z.B. space@dim="horizontal" @unit=... @quantity=...
        -->
        <xsl:apply-templates/>
        <!-- Das müßte noch mit modulo(26) versehen werden -->
        <xsl:variable name="n" select="bk:textcriticalnote(.)"/>
        <a href="{concat('#',$id)}" class="footnote_reference">
            <xsl:attribute name="title">
                <xsl:value-of select="concat(name(.), ' ', ./@reason, ' ', @extent)"/>
            </xsl:attribute>
            <xsl:value-of select="$n"/>
        </a>
    </xsl:template>
    <xsl:template match="tei:supplied">
        <xsl:variable name="id" select="generate-id(.)"/>
        <!-- In der Fußnote steht entweder alles aus rdg, oder ToDo: die Kommentare aus add/gap/del ... mit einem Verweis auf die Handschrift und einem normierten Bezeichner ("gestrichen" etc.); tei:space kann auch ein nicht-kommentierungswürdiger Abstand der diplomatischen Ansicht sein ... 
        In der diplomatischen Abschrift könnte das auch visualisiert werden, z.B. space@dim="horizontal" @unit=... @quantity=...
        -->
        <xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
        <!-- Das müßte noch mit modulo(26) versehen werden -->
        <xsl:variable name="n" select="bk:textcriticalnote(.)"/>
        <a href="{concat('#',$id)}" class="footnote_reference">
            <xsl:attribute name="title">
                <xsl:value-of select="concat(name(.), ' ', ./@reason, ' ', @extent)"/>
            </xsl:attribute>
            <xsl:value-of select="$n"/>
        </a>
    </xsl:template>
    <xsl:template match="tei:rdg">
        <xsl:variable name="id" select="generate-id(.)"/>
        <!-- Das müßte noch mit modulo(26) versehen werden -->
        <xsl:variable name="n" select="bk:textcriticalnote(.)"/>
        <a href="{concat('#',$id)}" class="footnote_reference">
            <xsl:value-of select="$n"/>
        </a>
    </xsl:template>
    <xsl:template
        match="tei:add|tei:del|tei:space|tei:sic|tei:supplied|tei:unclear|tei:gap|tei:corr|tei:choice/tei:orig|tei:choice/tei:reg|tei:damage"
        mode="end">
        <p class="note">
            <xsl:variable name="id" select="generate-id(.)"/>
            <xsl:variable name="n" select="bk:textcriticalnote(.)"/>
            <a name="{$id}" class="footnote_number">
                <xsl:value-of select="$n"/>) </a>
            <xsl:value-of select="concat(name(.), ' ', ./@reason, ' ', @extent)"/>
            <xsl:if test="@hand">von <xsl:value-of select="@hand"/> Hand</xsl:if>
            <xsl:choose>
                <xsl:when test="name(.) = 'del'">
                    <xsl:apply-templates/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="@wit"/>
        </p>
    </xsl:template>
    <xsl:template match="tei:app/tei:rdg" mode="end">
        <p class="note"><xsl:variable name="id" select="generate-id(.)"/>
            <xsl:variable name="n" select="bk:textcriticalnote(.)"/>
            <a name="{$id}" class="footnote_number">
                <xsl:value-of select="$n"/>
            </a>) <xsl:apply-templates/>
            <xsl:apply-templates select="@wit"/>
        </p>
    </xsl:template>
    <xsl:template match="tei:ref">
        <a href="{@target}"><xsl:apply-templates /></a>
    </xsl:template>
    <!-- ToDo: tei:choice richtig auswerten: corr/orig, reg/sic -->
    <xsl:template match="tei:choice">
        <xsl:apply-templates select="tei:corr|tei:sic"/>
    </xsl:template>

    <xsl:template match="tei:choice" mode="end">
        <!-- Das funktioniert so noch nicht richtig -->
        <xsl:apply-templates select="tei:orig|tei:reg"/>
    </xsl:template>

    <xsl:function name="bk:textcriticalnote">
        <xsl:param name="element"/>
        <!-- preceding erwischt nicht die umschließenden Eltern, also muß ich die ancesters auch mitzählen, weiß aber ToDo: bei tei:app/tei:rdg zu noch nicht aufgeräumtem Mist führt
        
        ToDo: Die Berechnung sollte noch modulo(26) ermöglichen, damit nahc dem z wieder bei a angefangen wird (oder aa oder a' oder wie auch immer)-->
        <xsl:value-of
            select="bk:alphanumerisch(count($element/preceding::tei:app|$element/preceding::tei:add|$element/preceding::tei:del|$element/preceding::tei:space|$element/preceding::tei:sic|$element/preceding::tei:supplied|$element/preceding::tei:unclear|$element/preceding::tei:gap|$element/ancestor::tei:choice|$element/preceding::tei:gap|$element/ancestor::tei:choice|$element/ancestor::tei:add|$element/ancestor::tei:del|$element/ancestor::tei:space|$element/ancestor::tei:sic|$element/ancestor::tei:supplied|$element/ancestor::tei:unclear|$element/ancestor::tei:gap))"
        />
    </xsl:function>

    <xsl:template match="@wit">
        <xsl:text> </xsl:text>
        <span class="editor">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    <xsl:function name="bk:alphanumerisch">
        <!-- Könnte man in einen allgemeinen "Berechne Fußnotenbezeichner" umwandeln, der
            ein Element hereinbekommt
            dazu Angaben über "Welche Elemente sollen in den Apparat einbezogen werden
            Fußnotenzeichenformat
        -->
        <xsl:param name="number"/>
        <!-- Hier bräuchte ich einen Mechanismus, der die Zahlen in Buchstabenfußnoten umrechnet und zwar 
            mit modulo(26) oder so -->
        <xsl:value-of select="codepoints-to-string(97+$number)"/>
    </xsl:function>

    <!-- Buchhaltung:  -->
    <xsl:template match="tei:measure">
        <span>
            <xsl:if test="substring-before(./@ana,'_') = '#bk'">
                <xsl:attribute name="data-type">
                    <xsl:value-of select="./@ana"/>
                </xsl:attribute>
                <xsl:call-template name="bk">
                    <xsl:with-param name="element" select="."/>
                </xsl:call-template>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="./tei:num">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Inhalte in Zahlen umrechnen:
                        Ich gehe davon aus, daß es nur eine Recheneinheit in jedem tei:measure gibt
                        Ich gehe davon aus, daß es nur gerechnet werden soll, wenn es tei:num enthalten ist
                        Ich gehe davon aus, daß das letzte Wort die Recheneinheit bezeichnet
                        Ich gehe davon aus, daß hochgestellte 100er und 1000er mit <seg rend="superscript"> gekennzeichnet sind
                        Ich gehe davon aus, daß es nur ijvxlcm und j/ gibt.
                        
                        1. Zerlegen in Einzelzeichen
                        2. wenn das Folgezeichen "höher" ist als das Ausgangszeichen, dann gibt es eine Subtraktion, sonst eine Addition
                        3. Wenn ein hochgestelltes m/c folgt, dann wird der gesamte Wert damit multipliziert
                    -->
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>

        </span>
    </xsl:template>
    <xsl:template match="tei:num">
        <span class="edition invisible">
            <xsl:value-of select="@value"/>
        </span>
        <span class="diplomatic visible">
            <xsl:attribute name="title">
                <xsl:value-of select="@value"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template name="bk">
        <xsl:param name="element"/>
        <!-- die Datenstruktur aus @ana="#bk_" etc. aufbauen -->
        <xsl:if test="./@ana='#bk_entry' or ./@ana='#bk_total'">
            <xsl:attribute name="data-account">
                <xsl:for-each select="ancestor-or-self::node()[name()='div' or name()='list']/tokenize(@ana,' ')">
                    <xsl:variable name="ana-token">
                        <xsl:value-of select="substring-after(translate(string(.),':','_'),'#')"/>
                    </xsl:variable>
                    <xsl:if                                     test="$accounts//tei:category[@xml:id/string() = $ana-token]">
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$ana-token"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@ana='#bk_total' or ./@ana='#bk_balance'">
            <xsl:attribute name="data-corresp" select="@corresp"/>
        </xsl:if>
        <!-- amount: -->
        <xsl:apply-templates select=".//tei:*[@ana='#bk_amount']"
            mode="bk-attributes"/>
        <!--<xsl:comment>
            #############
                ./tei:num/@value: <xsl:value-of                   select="sum(bk:umrechnung(./tei:num/@value,./@unit))"/>
                .//tei:measure/tei:num: <xsl:value-of select="sum(.//tei:measure[./@type='currency']/bk:umrechnung(tei:num/@value,@unit))"/>
                .//tei:measure/@quantitiy: <xsl:value-of
                  select="sum(.//tei:measure[./@type='currency' and ./@quantity]/bk:umrechnung(@quantity, @unit))"/>
            #############
        </xsl:comment>-->
    </xsl:template>
    
    <xsl:template name="account">
        <!-- Ermittelt die URI des Kontos -->
        <xsl:param name="accountID"/>
        <xsl:param name="URI" select="0"/>
        <xsl:if
            test="$accounts//tei:category[@xml:id/string() = $accountID]">
                <!-- Das müßte eigentlich die xml:base der verwendeten Taxonomie sein -->
                <xsl:choose>
                    <xsl:when test="$URI!=0"><xsl:value-of
                    select="concat($xmlBaseAccounts,.)"/></xsl:when>
                    <xsl:otherwise><xsl:value-of
                        select="."/></xsl:otherwise>
                </xsl:choose>
        </xsl:if>
        <!-- Einen "not applicable? -->
    </xsl:template>
    
    <xsl:template match="tei:*[@ana='#bk_amount']">
        <!-- @rend="rbms" = Rechtsbündig mit Strich -->
        <xsl:if test="@rend='rbms'"><xsl:text> -&#x00A0;- </xsl:text></xsl:if>
        <span class="amount">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:*[@ana='#bk_amount']"
        mode="bk-attributes">
        <xsl:variable name="data_as">
            <xsl:value-of select="ancestor-or-self::node()[@ana='#bk_d' or @ana='#bk_i'][1]/@ana"/>
        </xsl:variable>
        <xsl:attribute name="data-amount">
            <xsl:if test="$data_as = '#bk_d'">
                <xsl:text>-</xsl:text>
            </xsl:if>
            <xsl:call-template name="betrag"/>
        </xsl:attribute>
        <xsl:attribute name="data-unit">d.</xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:ex">
        <span class="edition invisible">
            <xsl:apply-templates/>
        </span>
        <span class="diplomatic visible abbr">
<!--            <xsl:text>(</xsl:text>-->
            <xsl:apply-templates/>
<!--            <xsl:text>)</xsl:text>-->
        </span>
    </xsl:template>

    <xsl:template match="tei:c[@type='long-s']">
        <!-- ToDo: Das kann nur gesucht werden, wenn ich die ganzen Wörter austausche: Evtl. also lieber ein ganzes Stylesheet dafür über den Mode laufen lassen... -->
        <span class="diplomatic visible">&#383;</span>
        <span class="edition invisible">s</span>
    </xsl:template>

    <!-- Die Rechnungskonversionen -->

    <xsl:template name="betrag">
        <!-- Gibt die auf d radizierten Beträge des aktuellen Elements -->
        <xsl:choose>
            <xsl:when test="(not(./@quantity) or ./@quantity = 0)">
                <!-- Die Summe aller untergeordneten tei:measure -->
                <!-- Die Währungseinheiten müßten noch über Variablen externalisiert werden -->
                <xsl:value-of
                    select="sum(bk:umrechnung(./tei:num/@value,./@unit))
                    + sum(sum(.//tei:measure[./@type='currency']/bk:umrechnung(tei:num/@value,@unit)))
                    +     sum(.//tei:measure[./@type='currency' and ./@quantity]/bk:umrechnung(@quantity, @unit))
                    +  sum(.//tei:measure[not(@quantity or tei:num) and string(number(substring-before(text()[1],' '))) != 'NaN']/bk:umrechnung(number(substring-before(text()[1],' ')), ./@unit))
                    "
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="bk:umrechnung(./@quantity, ./@unit)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="bk_is_account">
        <xsl:param name="accounts"/>
        <xsl:copy-of select="$accounts"/>
        <!--        <xsl:for-each select="$accounts//html:li"     xmlns:html="http://www.w3.org/1999/xhtml"
            >     <xsl:if test="//tei:taxonomy[@ana='bk:account']//tei:category[@xml:id/string() = string(.)]">
            <xsl:value-of select="." />            
        </xsl:if>
        </xsl:for-each>
-->
    </xsl:template>

    <xsl:template name="currency">
        <!--        Das müssen Triple aus Ausgangswährung, Zielwährung, Kurs werden, die übrigens auch im Ausgangsdokument enthalten sein könnten (bk:conversion ...) -->
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="$name='lib.d.'">240</xsl:when>
            <xsl:when test="$name='sol.d.'">8</xsl:when>
            <xsl:when test="$name='d.'">1</xsl:when>
            <xsl:when test="$name='gul'">288</xsl:when>
            <xsl:when test="$name='legr'">12</xsl:when>
            <xsl:when test="$name='gr'">12</xsl:when>
            <!-- ?? -->
            <xsl:when test="$name='lew'">1</xsl:when>
            <!-- ?? -->
            <xsl:when test="$name='lb'">240</xsl:when>
            <xsl:when test="$name='d'">1</xsl:when>
            <xsl:when test="$name='lb_amb'">120</xsl:when>
            <xsl:when test="$name='d_amb'">0.5</xsl:when>
            <xsl:when test="$name='ß_d'">8</xsl:when>
            <xsl:when test="$name='lb_d'">240</xsl:when>
            <xsl:when test="$name='ß'">8</xsl:when>
            <xsl:when test="$name='ß-w'">12</xsl:when>
            <xsl:when test="$name='d_Rat'">1</xsl:when>
            <!-- ? -->
            <xsl:when test="$name='lb_Rat'">240</xsl:when>
            <!-- ? -->
            <xsl:when test="$name='ß_rat_d'">8</xsl:when>
            <!-- ? -->
            <xsl:when test="$name='ß_rat'">8</xsl:when>
            <!-- ? -->
            <xsl:when test="$name='lb_Rat_d'">240</xsl:when>
            <!-- ? -->
            <xsl:when test="$name='ß_amb'">4</xsl:when>
            <xsl:when test="$name='fl'">120</xsl:when>
            <!-- e_543: 74 fl = 17 lb d?
            -->
            <xsl:when test="$name='fl_rheinisch'">58</xsl:when>
            <!-- e_577: 25 fl = 8 lb d
                 e_602 = 12 lb - 5 d-->
            <xsl:when test="$name='fl_ungarisch'">120</xsl:when>
            <!-- ? -->
        </xsl:choose>
    </xsl:template>
    <xsl:template name="striche">
        <xsl:param name="level-max"/>
        <xsl:param name="level-curr"/>
        <xsl:if test="$level-curr &lt; $level-max"><xsl:text>- </xsl:text><xsl:call-template name="striche"><xsl:with-param name="level-max" select="$level-max"/><xsl:with-param name="level-curr" select="$level-curr + 1"></xsl:with-param></xsl:call-template></xsl:if>
    </xsl:template>
    <xsl:template mode="tab-reduce" match="tei:*[@ana='#bk_amount']">
        <xsl:variable name="data_as">
            <xsl:if test="ancestor-or-self::node()[@ana='#bk_d' or @ana='#bk_i'][1]/@ana = '#bk_d'">
                <xsl:text>-</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="amount">
            <xsl:call-template name="betrag"/>            
        </xsl:variable>
        <xsl:value-of select="bk:reduce(number($amount), $data_as)"/>
    </xsl:template>
    
</xsl:stylesheet>
