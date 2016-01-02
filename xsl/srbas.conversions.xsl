
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:r="http://gams.uni-graz.at/rem/ns/1.0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
          <xd:doc>
            <xd:desc>Collection of functions/templates to convert medieval/early modern currency values into calculable formats, by Georg Vogeler georg.vogeler@uni-graz.at, 2014 under reuse of previous work by James Cummings</xd:desc>
          </xd:doc>
          <xd:doc>
            <xd:desc>
              <xd:p>transform classical currency units (e.g. pound, shilling etc.) into basic unit</xd:p>
              <xd:p>
                <xd:b>ToDo</xd:b> Should be based on an external ontology</xd:p>
            </xd:desc>
          </xd:doc>
          <xsl:function name="bk:umrechnung">
            <xsl:param name="wert"></xsl:param>
            <xsl:param name="name"></xsl:param>
            <xsl:variable name="zielwert"></xsl:variable>
            <xsl:choose>
              <xsl:when test="empty($wert)">0</xsl:when>
              <xsl:when test="$name=&apos;sol.d.&apos;">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;d.&apos;">
                <xsl:value-of select="sum($wert)"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;gul&apos;">
                <xsl:value-of select="sum($wert) * 288"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;legr&apos;">
                <xsl:value-of select="sum($wert) * 12"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;gr&apos;">
                <xsl:value-of select="sum($wert) * 12"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;lew&apos;">
                <xsl:value-of select="sum($wert) * 1"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;m&apos;">
                <xsl:value-of select="sum($wert) * 720"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;sc&apos;">
                <xsl:value-of select="sum($wert) * 30"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;lb&apos; or $name=&apos;lbd&apos; or $name=&apos;lib.d.&apos; or $name=&apos;tl&apos; or $name=&apos;lb_d&apos;">
                <xsl:value-of select="sum($wert) * 240"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;d&apos;">
                <xsl:value-of select="sum($wert) * 1"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;lb_amb&apos;">
                <xsl:value-of select="sum($wert) * 120"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;d_amb&apos;">
                <xsl:value-of select="sum($wert) * 0.5"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;ß_d&apos;">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;ß&apos;">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;d_Rat&apos;">
                <xsl:value-of select="sum($wert) * 1"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;lb_Rat&apos;">
                <xsl:value-of select="sum($wert) * 240"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;ß_rat_d&apos;">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;ß_rat&apos;">
                <xsl:value-of select="sum($wert) * 8"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;lb_Rat_d&apos;">
                <xsl:value-of select="sum($wert) * 240"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;ß_amb&apos;">
                <xsl:value-of select="sum($wert) * 4"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;fl&apos;">
                <xsl:value-of select="sum($wert) * 120"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;fl_rheinisch&apos;">
                <xsl:value-of select="sum($wert) * 58"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;fl_ungarisch&apos;">
                <xsl:value-of select="sum($wert) * 120"></xsl:value-of>
              </xsl:when>
              <xsl:when test="$name=&apos;ß-w&apos;">
                <xsl:value-of select="sum($wert) * 12"></xsl:value-of>
              </xsl:when>
            </xsl:choose>
          </xsl:function>
          <xd:doc>
            <xd:desc>Converts a value in penny into pound/shilling/penny (&quot;short shilling&quot;)</xd:desc>
          </xd:doc>
          <xsl:function name="bk:reduce">
            <xsl:param name="value"></xsl:param>
            <xsl:param name="vorzeichen"></xsl:param>
            <xsl:param name="unit"></xsl:param>
            <xsl:if test="$unit=&apos;&apos; or $unit=&apos;lb&apos;">
              <xsl:value-of select="concat($vorzeichen,floor($value div 240))"></xsl:value-of>
              <xsl:text> lb</xsl:text>
            </xsl:if>
            <xsl:if test="$unit=&apos;&apos;">
              <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:if>
            <xsl:if test="$unit=&apos;&apos; or $unit=&apos;ß&apos;">
              <xsl:value-of select="concat($vorzeichen,floor(($value mod 240) div 12))"></xsl:value-of>
              <xsl:text> ß</xsl:text>
            </xsl:if>
            <xsl:if test="$unit=&apos;&apos;">
              <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:if>
            <xsl:if test="$unit=&apos;&apos; or $unit=&apos;d&apos;">
              <xsl:value-of select="concat($vorzeichen,(($value mod 240) mod 12))"></xsl:value-of>
              <xsl:text> d</xsl:text>
            </xsl:if>
          </xsl:function>
          <xsl:template name="zahlen">
            <xsl:param name="input"></xsl:param>
            <xd:doc>
              <xd:desc>deprecated! everything should already be done in the bk:roman2int functions</xd:desc>
            </xd:doc>
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
            <xd:doc>
              <xd:desc>converts roman numbers into numerical values considering r:sup/r:exp as an exponent</xd:desc>
            </xd:doc>
            <xsl:choose>
              <xsl:when test="count($liste) = 1">
                <xsl:value-of select="bk:roman2int(normalize-space($liste))"></xsl:value-of>
              </xsl:when>
              <xsl:when test="($liste[2][self::r:sup] or $liste[2][self::r:exp]) and $liste[1][self::text()]">
                <xsl:variable name="rest" select="$liste[2]/following-sibling::node()"></xsl:variable>
                <xsl:value-of select="(bk:roman2int($liste[1]) * bk:roman2int($liste[2])) + bk:roman2int-ext($rest) "></xsl:value-of>
              </xsl:when>
              <xsl:when test="count($liste) gt 2">
                <xsl:value-of select="bk:roman2int-ext($liste[1]/following-sibling::node())"></xsl:value-of>
              </xsl:when>
              <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
          </xsl:function>
          <xd:doc>
            <xd:desc>Converts roman numbers into numerical values, using ̶ for half values. Based heavily on James Cummings work at https://github.com/jamescummings/conluvies/blob/master/xslt-misc/romanMoney2TEI.xsl</xd:desc>
          </xd:doc>
          <xsl:function name="bk:roman2int">
            <xsl:param as="xs:string" name="r"></xsl:param>
            <xsl:variable name="r2" select="translate(upper-case(normalize-space($r)), &apos;J&apos;, &apos;I&apos;)"></xsl:variable>
            <xsl:choose>
              <xsl:when test="ends-with($r2,&apos;XC&apos;)">
                <xsl:sequence select="90 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;XL&apos;)">
                <xsl:sequence select="40 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;L&apos;)">
                <xsl:sequence select="50 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;C&apos;)">
                <xsl:sequence select="100 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;D&apos;)">
                <xsl:sequence select="500 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;M&apos;)">
                <xsl:sequence select="1000 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;IV&apos;)">
                <xsl:sequence select="4 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;IX&apos;)">
                <xsl:sequence select="9 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;IIX&apos;)">
                <xsl:sequence select="8 + bk:roman2int(substring($r2,1,string-length($r2)-2))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;I&apos;)">
                <xsl:sequence select="1 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;V&apos;)">
                <xsl:sequence select="5 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;X&apos;)">
                <xsl:sequence select="10 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:when test="ends-with($r2,&apos;̶&apos;)">
                <xsl:sequence select="-0.5 + bk:roman2int(substring($r2,1,string-length($r2)-1))"></xsl:sequence>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="0"></xsl:sequence>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:function>
        </xsl:stylesheet>
