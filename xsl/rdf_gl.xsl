<?xml version="1.0" encoding="UTF-8"?>
<!-- ToDo: die TEI-Konversion auf Global Ledger (d.h. @ana="gl:...") umstellen  
    gl-cor:entryDetail 
    gl-cor:amount
    gl-cor:signOfAmount
    gl-cor:account
    gl-cor:debitCreditCode


    Accounting Entries
        Document Information
        Entity Information Section
        Entry Information
            Date Posted
            Entry Creator
            Entry Last Modifier
            Entry Date
            Responsible Person
            Source Journal
            Journal Description
            Type Identifier
            Entry Origin
            Entry Identifier
            Entry Description
            Entry Qualifier
            Entry Qualifier Description
            Posting Code
            Batch ID for Entry Group
            Batch Description
            Number of Entries
            Total Debits
            Total Credits
            Type of Difference Between Book and Tax
            Elimination Code
            Budget Scenario Period Start
            Budget Scenario Period End
            Scenario Description
            Scenario Code
            Budget Allocation Code
            ID for Reversing, Standard or Master Entry
            Recurring Standard Description
            Frequency Interval
            Frequency Unit
            Repetitions Remaining
            Next Date Repeat
            Last Date Repeat
            End Date of Repeating Entry
            Reverse
            Reversing Date
            Entry Number Counter
            Entry Detail
                Line Number
                Line Number Counter
                Account Identifier
 *                   Main Account Number
                    Main Account Description
                    Account Classification
                    Account Classification Description
                    Parent Account Number
                    Purpose of Account
                    Description of Purpose of Account
                    Account Type
                    Account Type Description
                    Entry Accounting Method
                    Entry Accounting Method Description
                    Entry Accounting Method Purpose
                    Entry Accounting Method Purpose Description
                    Subaccount Information
*                    Monetary Amount
->                    Currency
                    Original Exchange Rate Date
->                    Amount in Original Currency
->                    Original Currency
->                    Original Exchange Rate
->                    Original Exchange Rate Source
                    Original Exchange Rate Comment
                    Original Amount in Triangulation Currency
                    Original Triangulation Currency
                    National to Triangulation Currency Exchange Rate
                    National to Triangulation Currency Exchange Rate Source
                    National to Triangulation Currency Exchange Rate Type
                    Original to Triangulation Currency Exchange Rate
                    Original to Triangulation Currency Exchange Rate Source
                    Original to Triangulation Currency Exchange Rate Type
*                    Sign Indication for Amount
*                    Debit/Credit Identifier
                    Posting Date
                    Memo Line
                    Allocation Code
                    Multicurrency Detail
                    Identifier Reference
                    Document Type
                    Document Type Description
                    Invoice Type
                    Document Number
                    Apply To Number
                    Document Reference
                    Document Date
                    Received Date
                    Chargeable or Reimbursable
                    Document Location
                    Payment Method
                    Posting Status
                    Posting Status Description
                    XBRL Information
->                    Description
                    Acknowledgement Date
                    Confirmation Date
                    Ship From
                    Date Shipped/Received
                    Maturity Date or Date Due
                    Payment Terms
->                    Measurable
                        Measurable Code
                        Measurable Code Description
                        Measurable Category
                        Measurable Identification
                        Schema for Measurable Identification
                        Secondary Measurable Identifier
                        Schema for Secondary Measurable Identification
                        Measurable Description
                        Quantity
                        Qualifier
                        Unit of Measure
                        Per Unit Cost/Price
                        Start Time
                        End Time
                        Measurable Active
                    Job Information
                    Depreciation Mortgage
                    Tax Information
                    Ticking Field
                    Document Remaining Balance
                    UCR
                    Originating Document - Heading
                    
	Annotated Instance Documents


-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/"
    xmlns:gl="http://www.xbrl.org/GLTaxonomy/"
    xmlns:g2o="http://gams.uni-graz.at/onto/#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <!--  ToDo: TEI-Namespace um / erweitern oder # erweitern? -->
    <xsl:import href="http://gams.uni-graz.at/rem/conversions.xsl"/>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 2012-06-29</xd:p>
            <xd:p><xd:b>Author:</xd:b> Georg Vogeler georg.vogeler@uni-graz.at</xd:p>
            <xd:p>Extrahiert die Buchhaltungsspezifischen Klassifikationen aus @ana (aus der Global-Ledger-Taxonomie übernommen) und fügt sie zusammen mit einschlägigen Werten in ein RDF ein.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <!--            ToDo: auf das aktuelle Dokument als Base-URI anpassen! -->
    <xsl:variable name="pid"
        select="replace(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='PID']/text(),'info:fedora/','')"/>
    <xsl:variable name="base-uri"
        select="concat('http://gams.uni-graz.at/archive/get/',$pid,'/sdef:TEI/get#')"/>
    <xsl:variable name="accounts" select="//tei:taxonomy[matches(@ana,'#gl_account')]"/>
    <xsl:variable name="xmlBaseAccounts" select="//tei:classDecl[.//tei:taxonomy/matches(@ana,'#gl_account')]/@xml:base"/>
    <xsl:template match="/">
        <rdf:RDF>
            <rdf:Description rdf:about="http://gams.uni-graz.at/{$pid}">
                <!-- Allgemeine Metadaten -->
                <tei:msIdentifier><xsl:value-of select="//tei:msIdentifier"/></tei:msIdentifier>
                <dc:date><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#int</xsl:attribute><xsl:value-of select="//tei:teiHeader//tei:sourceDesc//tei:origDate[1]/substring-before(@to,'-')"/></dc:date>
            </rdf:Description>
            <!-- Kontenhierarchie -->
            <xsl:apply-templates select="//tei:taxonomy[matches(@ana,'#gl_account')]"/>
            <xsl:apply-templates select="//tei:*[matches(@ana,'#gl_entryDetail')]"/>
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
                    select="replace(./@ana,'gl:','http://www.xbrl.org/GLTaxonomy/#')"/>
            </rdf:type>
            <!-- ToDo: rdfs für Buchhaltung anlegen -->
            <!-- ToDo: Buchungstext einfügen -->
            <!-- Jeder Buchungseintrag ist Teil vom Gesamtobjekt. ToDo: OA? SharedCanvas? -->
            <g2o:partOf rdf:resource="http://gams.uni-graz.at/{$pid}"/>
            <!-- Der Identifikator stammt aus @n -->
            <bk:label>
                <xsl:value-of select="./@n"/>
            </bk:label>
            <xsl:for-each select="ancestor-or-self::node()[name()='div' or name()='list']/tokenize(@ana,' ')">
                <xsl:call-template name="account">
                    <xsl:with-param name="accountID" select="substring-after(translate(string(.),':','_'),'#')"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:apply-templates
                select="./tei:measure[./@type='currency'] | .//tei:*[matches(@ana,'#gl_amount')]"/>
            <!--<bk:inhalt>
                <xsl:copy-of select="text()|node()"/>
            </bk:inhalt>-->
<!--            <xsl:for-each select="tokenize(translate(.,'.!,()?/;:',''),'\s')">
                <xsl:if test="not(.='')"><g2o:hasToken><xsl:value-of select="."/></g2o:hasToken></xsl:if>
            </xsl:for-each>
-->        </rdf:Description>

    </xsl:template>

    <xsl:template match="tei:measure[./@type='currency']|tei:*[matches(@ana,'#gl_amount') ]">
        <xsl:element name="gl:amount">
            <xsl:element name="rdf:Description">
                <xsl:variable name="vorzeichen">
                    <xsl:if test="ancestor-or-self::node()[matches(@ana,'#bk_d') or matches(@ana,'#bk_i')][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1')='#bk_d'">-</xsl:if>
                </xsl:variable>
                
                <xsl:attribute name="rdf:about" select="concat($base-uri,./@xml:id)"/>
                <xsl:element name="gl:signOfAmount">
                    <!-- Zu-/Abgang: das *nächste* übergeordnete Element, das bk:i oder bk:d heißt, kommt in  
                @bk:as (mit D(ecrease) und I(ncrease)) 
                -->
                    <xsl:variable name="bk_as"  select="ancestor-or-self::*[matches(@ana,'#bk_d') or matches(@ana,'#bk_i')][1]"/>
                        <xsl:choose>
                            <xsl:when test="$bk_as='#bk_d'">-</xsl:when>
                            <xsl:otherwise>+</xsl:otherwise>
                        </xsl:choose>
                    <!-- ToDo: gl:signOfAmount einbauen! 
                    
                    concat('http://gams.uni-graz.at/rem/bookkeping/',ancestor-or-self::node()[matches(@ana,'#bk_d') or matches(@ana,'#bk_i')][1]/replace(@ana,'^.*?(#bk_[id]).*?$','$1'))

                    -->
                </xsl:element>
                <xsl:element name="bk:num">
                    <!-- ToDo: Dafür gibt es kein gl-Element? -->
                    <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#decimal</xsl:attribute>
                    <!-- Der Betrag  -->
                    <xsl:call-template name="betrag">
                        <xsl:with-param name="vorzeichen" select="$vorzeichen"/>
                        <!-- ToDo: Das müßte eigentlich raus, weil ich ja gl:signOfAmount habe. -->
                    </xsl:call-template>
                </xsl:element>
                <xsl:element name="bk:unit">
                    <!-- ToDo: Dafür gibt es auch kein gl:Element? -->
                    <xsl:attribute name="rdf:resource">http://gams.uni-graz.at/rem/currencies/#d</xsl:attribute>
                </xsl:element>
                <!-- ToDo: Ganz konsequent wird's ja eigentlich erst, wenn ich auch eine "historische Dimension" einbaue, oder? -->
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="account">
        <!-- ToDo: Aus default.xsl übernehmen? -->
        <xsl:param name="accountID"/>
        <xsl:if
            test="$accounts//tei:category[@xml:id/string() = $accountID]">
            <xsl:element name="gl:account">
                <!-- Das müßte eigentlich die xml:base der verwendeten Taxonomie sein -->
                <xsl:attribute name="rdf:resource"
                    select="concat($xmlBaseAccounts,.)"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- Kontenhierarchie -->
    <xsl:template match="//tei:taxonomy[@ana='#gl_account']">
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
            <bk:subAccountOf rdf:resource="{$levelup}"/>
            <bk:accountPath><xsl:value-of select="concat($accountPath,'/',./@xml:id)"/></bk:accountPath>
        </rdf:Description>
        <xsl:apply-templates select="tei:category" mode="accounts">
           <xsl:with-param name="accountPath" select="concat($accountPath,'/',@xml:id)"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Buchhaltung: Auslagern von Betrag aus default.xsl?-->
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
</xsl:stylesheet>
