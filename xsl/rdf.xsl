<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/"
    xmlns:gl="http://www.xbrl.org/GLTaxonomy/"
    xmlns:g2o="http://gams.uni-graz.at/onto/#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="2.0">
    <!--  TEI-Namespace um / erweitern oder # erweitern? -->
    <xsl:import href="http://gams.uni-graz.at/rem/conversions.xsl"/>
    <xsl:output omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <!--            ToDo: auf das aktuelle Dokument als Base-URI anpassen! -->
    <xsl:variable name="pid"
        select="replace(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='PID']/text(),'info:fedora/','')"/>
    <xsl:variable name="base-uri"
        select="concat('http://gams.uni-graz.at/archive/get/',$pid,'/sdef:TEI/get#')"/>
    <xsl:variable name="accounts" select="//tei:taxonomy[@ana='#bk_account']"/>
    <xsl:variable name="xmlBaseAccounts" select="//tei:classDecl[.//tei:taxonomy/@ana='#bk_account']/@xml:base"/>
    <!-- 
    gl-cor:entryDetail 
    gl-cor:amount
    gl-cor:signOfAmount
    gl-cor:account
    gl-cor:debitCreditCode
    -->
    <!-- ToDo: Eine Beziehung "mainAccount" einführen, damit die Buchungen auch nur unter dem jeweils engsten Konto gefunden werden können -->
    <xsl:template match="/">
        <rdf:RDF>
            <rdf:Description rdf:about="http://gams.uni-graz.at/{$pid}">
                <!-- Allgemeine Metadaten -->
                <tei:msIdentifier><xsl:value-of select="//tei:msIdentifier"/></tei:msIdentifier>
                <dc:date><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#int</xsl:attribute><xsl:value-of select="//tei:teiHeader//tei:sourceDesc//tei:origDate[1]/substring-before(@to,'-')"/></dc:date>
            </rdf:Description>
            <!-- Kontenhierarchie -->
            <xsl:apply-templates select="//tei:taxonomy[matches(@ana,'#bk_account') or matches(@ana,'#gl_account')]"/>
            <xsl:apply-templates select="//tei:*[matches(@ana,'#bk_entry') or matches(@ana,'#gl_entryDetail') or matches(@ana, '#bk_total')]"/><!-- Sind das alle Einträge, die ich in der Datenbank haben will, oder will ich noch mehr? -->
            <!-- Alle formalen Daten herausziehen:
    Das könnte sein:
    1. alle @ana mit #bk_*
    2. die dazugehörige Taxonomie
    3. alle @key
    4. alle @corresp, die auf tei:note verweisen?
    -->
            <!--<xsl:apply-templates select="//tei:*[@key]" />-->
        </rdf:RDF>
    </xsl:template>
    <xsl:template match="*[substring-before(@ana,'_')='#bk']|*[substring-before(@ana,'_')='#gl']" priority="-2">
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="./@xml:id">
                    <xsl:value-of select="./@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$base-uri"/>
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <rdf:type>
                <xsl:attribute name="rdf:resource"
                    select="replace(./@ana,'bk:','http://gams.uni-graz.at/rem/bookkeeping/#')"/>
            </rdf:type>
            <!-- ToDo: gl: => replace(./@ana,'gl:','http://www.xbrl.org/GLTaxonomy/#')-->
            <!-- ToDo: rdfs für Buchhaltung anlegen -->
            <!-- ToDo: Buchungstext einfügen -->
            <!-- Jeder Buchungseintrag ist Teil vom Gesamtobjekt. ToDo: OA? SharedCanvas? -->
            <g2o:partOf rdf:resource="http://gams.uni-graz.at/{$pid}"/>
            <!-- Der Identifikator stammt aus @n -->
            <bk:label>
                <xsl:value-of select="./@n"/>
            </bk:label>
            <xsl:for-each select="ancestor-or-self::node()[name()='div' or name()='list' or name()='tr' or name()='table' or name()='ab']/tokenize(@ana,' ')">
                <!-- Kann ich die Auswahl der Element, die Konten enthalten können, noch allgemeiner formulieren? -->
                <xsl:call-template name="account">
                    <xsl:with-param name="accountID" select="substring-after(translate(string(.),':','_'),'#')"/>
                    <xsl:with-param name="position" select="position()"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:apply-templates
                select="./tei:measure[./@type='currency'] | .//tei:*[@ana='#bk_amount']"/>
            <bk:inhalt>
                <xsl:apply-templates mode="text"/>
            </bk:inhalt>
            <!--<xsl:for-each select="tokenize(translate(.,'.!,()?/;:',''),'\s')">
                <xsl:if test="not(.='')"><g2o:hasToken><xsl:value-of select="."/></g2o:hasToken></xsl:if>
            </xsl:for-each>-->
        </rdf:Description>

    </xsl:template>


<!--     Beträge     -->
    
    <xsl:template match="tei:measure[./@type='currency']|tei:*[@ana='#bk_amount']" priority="-1">
        <xsl:element name="bk:amount">
            <xsl:element name="rdf:Description">
                <xsl:variable name="vorzeichen">
                    <xsl:if test="ancestor-or-self::node()[matches(@ana,'#bk_d') or matches(@ana,'#bk_i')][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1')='#bk_d'">-</xsl:if>
                </xsl:variable>
                
                <xsl:attribute name="rdf:about" select="concat($base-uri,./@xml:id)"/>
                <xsl:element name="bk:as">
                    <!-- Zu-/Abgang: das *nächste* übergeordnete Element, das bk:i oder bk:d heißt, kommt in  
                @bk:as (mit D(ecrease) und I(ncrease)) 
                -->
                    <xsl:attribute name="rdf:resource"
                        select="concat('http://gams.uni-graz.at/rem/bookkeping/',ancestor-or-self::node()[matches(@ana,'#bk_d') or matches(@ana,'#bk_i')][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1'))"
                    />
                </xsl:element>
                <xsl:element name="bk:num">
                    <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#decimal</xsl:attribute>
                    <!-- Der Betrag  -->
                    <xsl:call-template name="betrag">
                        <xsl:with-param name="vorzeichen" select="$vorzeichen"/>
                    </xsl:call-template>
                </xsl:element>
                <xsl:element name="bk:unit">
                    <xsl:attribute name="rdf:resource">http://gams.uni-graz.at/rem/currencies/#d</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
<!--         
        Den Einträgen Konten zuweisen: 
-->
    <xsl:template name="account">
        <!-- ToDo: Aus default.xsl übernehmen? -->
        <xsl:param name="accountID"/>
        <xsl:param name="position"/>
        <xsl:if
            test="$accounts//tei:category[@xml:id/string() = $accountID]">
            <xsl:element name="bk:account">
                <!-- Das müßte eigentlich die xml:base der verwendeten Taxonomie sein -->
                <xsl:attribute name="rdf:resource"
                    select="concat($xmlBaseAccounts,.)"/>
            </xsl:element>
            <xsl:if test="$position=last()">
                <xsl:element name="bk:mainAccount">
                    <xsl:attribute name="rdf:resource"
                        select="concat($xmlBaseAccounts,.)"/>                
                </xsl:element>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <!-- Kontenhierarchie: -->
    <xsl:template match="//tei:taxonomy[@ana='#bk_account']">
        <rdf:Description rdf:about="{concat($xmlBaseAccounts,'#toplevel')}">
            <bk:accountPath>/</bk:accountPath> 
        </rdf:Description>
        <xsl:apply-templates select="tei:category" mode="accounts"/>
    </xsl:template>
    <xsl:template match="tei:category" mode="accounts">
        <xsl:param name="accountPath"/>
        <rdf:Description rdf:about="{concat($xmlBaseAccounts,'#',@xml:id)}">
            <xsl:variable name="levelup">
                <xsl:choose>
                    <xsl:when test="parent::tei:category"><xsl:value-of select="concat($xmlBaseAccounts,'#',parent::tei:category/@xml:id)"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="concat($xmlBaseAccounts,'#toplevel')"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <rdf:type rdf:resource="http://gams.uni-graz.at/rem/bookkeeping/#account"/>
            <bk:subAccountOf rdf:resource="{$levelup}"/>
            <bk:accountPath><xsl:value-of select="concat($accountPath,'/',./@xml:id)"/></bk:accountPath>
        </rdf:Description>
        <xsl:apply-templates select="//tei:*[matches(@ana,current()/@xml:id)]/*[matches(@ana,'#bk_total') and not(matches(@ana,'#bk_page'))]">
            <xsl:with-param name="konto"><xsl:value-of select="concat($xmlBaseAccounts,'#',@xml:id)"/></xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="tei:category" mode="accounts">
           <xsl:with-param name="accountPath" select="concat($accountPath,'/',@xml:id)"/>
        </xsl:apply-templates>
    </xsl:template>
    
    
    <!-- Summen pro Konto: -->
    <xsl:template match="tei:*[matches(@ana,'#bk_total') and not(matches(@ana,'#bk_page'))]">
        <xsl:param name="konto"/>
        <xsl:variable name="betraege">
            <!-- Die im Konto vorkommenden Beträge -->
            <xsl:for-each select="ancestor::tei:div[1]//tei:*[matches(@ana,'#bk_entry')]">
                <betrag><xsl:call-template name="betrag"/></betrag>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vorzeichen">
            <xsl:if test="ancestor-or-self::node()[matches(@ana,'#bk_d') or matches(@ana,'#bk_i')][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1')='#bk_d'">-</xsl:if>
        </xsl:variable>
        
        <rdf:Description>
            <xsl:attribute name="rdf:about" select="concat($base-uri,./@xml:id)"/>
            <rdf:type rdf:resource="http://gams.uni-graz.at/rem/bookkeeping/#bk_total_calc"/>
            <xsl:if test="$konto">
                <bk:account rdf:resource="{$konto}"/>
            </xsl:if>
            <g2o:partOf rdf:resource="http://gams.uni-graz.at/{$pid}"/>
            <bk:amount> 
                <rdf:Description>
                    <xsl:attribute name="rdf:about" select="concat($base-uri,./tei:seg[matches(@ana,'#bk_amount')]/@xml:id)"/>
                <bk:num rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="string(format-number(sum($betraege/*/number(text())),'#0'))"/></bk:num>
                <bk:unit rdf:resource="http://gams.uni-graz.at/rem/currencies/#d"/>
                <xsl:element name="bk:as">
                    <xsl:attribute name="rdf:resource"                        select="concat('http://gams.uni-graz.at/rem/bookkeping/',ancestor-or-self::node()[matches(@ana,'#bk_d') or matches(@ana,'#bk_i')][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1'))"
                    />
                </xsl:element>
            </rdf:Description>
        </bk:amount>
        </rdf:Description>
    </xsl:template>
    

    <!-- Buchhaltung: 
        Auslagern von Betrag aus default.xsl?-->
    <xsl:template name="betrag">
        <xsl:param name="vorzeichen"/>
        <xsl:variable name="vorz" select="number(concat($vorzeichen,'1'))"/>
        <xsl:choose>
            <xsl:when test="(not(./@quantity) or ./@quantity = 0)">
                <!-- Die Summe aller untergeordneten tei:measure -->
                <!-- Die Währungseinheiten müßten noch über Variablen externalisiert werden -->
                <xsl:value-of
                    select="$vorz*(sum(bk:umrechnung(./tei:num/@value,./@unit))
                    + sum(sum(.//tei:measure[./@type='currency']/bk:umrechnung(tei:num/@value,@unit)))
                    +     sum(.//tei:measure[./@type='currency' and ./@quantity]/bk:umrechnung(@quantity, @unit))
                    +  sum(.//tei:measure[string(number(substring-before(text()[1],' '))) != 'NaN']/bk:umrechnung(number(substring-before(text()[1],' ')), ./@unit)))
                    "
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$vorz*(bk:umrechnung(./@quantity, ./@unit))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*|@*" priority="-3"/>
</xsl:stylesheet>
