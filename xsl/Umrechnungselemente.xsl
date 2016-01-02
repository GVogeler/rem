<xsl:stylesheet xmlns:bk="http://gams.uni-graz.at/rem/bookkeeping/" xmlns:r="http://gams.uni-graz.at/rem/ns/1.0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xs" version="2.0">
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
              <xsl:when test="$name='lew'">
                <xsl:value-of select="sum($wert) * 1"/>
              </xsl:when>
              <xsl:when test="$name='m'">
                <xsl:value-of select="sum($wert) * 720"/>
              </xsl:when>
              <xsl:when test="$name='sc'">
                <xsl:value-of select="sum($wert) * 30"/>
              </xsl:when>
              <xsl:when test="$name='lb' or $name='lbd' or $name='lib.d.' or $name='tl' or $name='lb_d'">
                <xsl:value-of select="sum($wert) * 240"/>
              </xsl:when>
              <xsl:when test="$name='d'">
                <xsl:value-of select="sum($wert) * 1"/>
              </xsl:when>
              <xsl:when test="$name='lb_amb'">
                <xsl:value-of select="sum($wert) * 120"/>
              </xsl:when>
              <xsl:when test="$name='d_amb'">
                <xsl:value-of select="sum($wert) * 0.5"/>
              </xsl:when>
              <xsl:when test="$name='ß_d'">
                <xsl:value-of select="sum($wert) * 8"/>
              </xsl:when>
              <xsl:when test="$name='ß'">
                <xsl:value-of select="sum($wert) * 8"/>
              </xsl:when>
              <xsl:when test="$name='d_Rat'">
                <xsl:value-of select="sum($wert) * 1"/>
              </xsl:when>
              <xsl:when test="$name='lb_Rat'">
                <xsl:value-of select="sum($wert) * 240"/>
              </xsl:when>
              <xsl:when test="$name='ß_rat_d'">
                <xsl:value-of select="sum($wert) * 8"/>
              </xsl:when>
              <xsl:when test="$name='ß_rat'">
                <xsl:value-of select="sum($wert) * 8"/>
              </xsl:when>
              <xsl:when test="$name='lb_Rat_d'">
                <xsl:value-of select="sum($wert) * 240"/>
              </xsl:when>
              <xsl:when test="$name='ß_amb'">
                <xsl:value-of select="sum($wert) * 4"/>
              </xsl:when>
              <xsl:when test="$name='fl'">
                <xsl:value-of select="sum($wert) * 120"/>
              </xsl:when>
              <xsl:when test="$name='fl_rheinisch'">
                <xsl:value-of select="sum($wert) * 58"/>
              </xsl:when>
              <xsl:when test="$name='fl_ungarisch'">
                <xsl:value-of select="sum($wert) * 120"/>
              </xsl:when>
              <xsl:when test="$name='ß-w'">
                <xsl:value-of select="sum($wert) * 12"/>
              </xsl:when>
            </xsl:choose>
          </xsl:function>
          <xd:doc>
            <xd:desc>Converts a value in penny into pound/shilling/penny ("short shilling")</xd:desc>
          </xd:doc>
          <xsl:function name="bk:reduce">
            <xsl:param name="value"/>
            <xsl:param name="vorzeichen"/>
            <xsl:variable name="unit"/>
            <xsl:if test="$unit='' or $unit='lb'">
              <xsl:value-of select="concat($vorzeichen,floor($value div 240))"/>
              <xsl:text> lb</xsl:text>
            </xsl:if>
            <xsl:if test="$unit=''">
              <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:if>
            <xsl:if test="$unit='' or $unit='ß'">
              <xsl:value-of select="concat($vorzeichen,floor(($value mod 240) div 12))"/>
              <xsl:text> ß</xsl:text>
            </xsl:if>
            <xsl:if test="$unit=''">
              <xsl:text xml:space="preserve"> </xsl:text>
            </xsl:if>
            <xsl:if test="$unit='' or $unit='d'">
              <xsl:value-of select="concat($vorzeichen,(($value mod 240) mod 12))"/>
              <xsl:text> d</xsl:text>
            </xsl:if>
          </xsl:function>
          <xsl:template name="zahlen">
            <xsl:param name="input"/>
            <xd:doc>
              <xd:desc>deprecated! everything should already be done in the bk:roman2int functions</xd:desc>
            </xd:doc>
            <xsl:variable name="expo">
              <xsl:choose>
                <xsl:when test="$input/r:sup">
                  <xsl:number value="bk:roman2int($input/r:sup)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:number value="1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="bk:roman2int($input/text()) * $expo"/>
          </xsl:template>
          <xsl:function as="xs:decimal" name="bk:roman2int-ext">
            <xsl:param name="liste"/>
            <xd:doc>
              <xd:desc>converts roman numbers into numerical values considering r:sup/r:exp as an exponent</xd:desc>
            </xd:doc>
            <xsl:choose>
              <xsl:when test="count($liste) = 1">
                <xsl:value-of select="bk:roman2int(normalize-space($liste))"/>
              </xsl:when>
              <xsl:when test="($liste[2][self::r:sup] or $liste[2][self::r:exp]) and $liste[1][self::text()]">
                <xsl:variable name="rest" select="$liste[2]/following-sibling::node()"/>
                <xsl:value-of select="(bk:roman2int($liste[1]) * bk:roman2int($liste[2])) + bk:roman2int-ext($rest) "/>
              </xsl:when>
              <xsl:when test="count($liste) gt 2">
                <xsl:value-of select="bk:roman2int-ext($liste[1]/following-sibling::node())"/>
              </xsl:when>
              <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
          </xsl:function>
          <xd:doc>
            <xd:desc>Converts roman numbers into numerical values, using ̶ for half values. Based heavily on James Cummings work at https://github.com/jamescummings/conluvies/blob/master/xslt-misc/romanMoney2TEI.xsl</xd:desc>
          </xd:doc>
          <xsl:function name="bk:roman2int">
            <xsl:param as="xs:string" name="r"/>
            <xsl:variable name="r2" select="translate(upper-case(normalize-space($r)), 'J', 'I')"/>
            <xsl:choose>
              <xsl:when test="ends-with($r2,'XC')">
                <xsl:sequence select="90 + bk:roman2int(substring($r2,1,string-length($r2)-2))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'XL')">
                <xsl:sequence select="40 + bk:roman2int(substring($r2,1,string-length($r2)-2))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'L')">
                <xsl:sequence select="50 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'C')">
                <xsl:sequence select="100 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'D')">
                <xsl:sequence select="500 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'M')">
                <xsl:sequence select="1000 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'IV')">
                <xsl:sequence select="4 + bk:roman2int(substring($r2,1,string-length($r2)-2))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'IX')">
                <xsl:sequence select="9 + bk:roman2int(substring($r2,1,string-length($r2)-2))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'IIX')">
                <xsl:sequence select="8 + bk:roman2int(substring($r2,1,string-length($r2)-2))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'I')">
                <xsl:sequence select="1 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'V')">
                <xsl:sequence select="5 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'X')">
                <xsl:sequence select="10 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:when test="ends-with($r2,'̶')">
                <xsl:sequence select="-0.5 + bk:roman2int(substring($r2,1,string-length($r2)-1))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="0"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:function>
        </xsl:stylesheet>
