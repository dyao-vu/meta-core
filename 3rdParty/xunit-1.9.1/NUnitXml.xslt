<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output cdata-section-elements="message stack-trace"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="assemblies">
    <test-results>
      <xsl:attribute name="name">
        <xsl:for-each select="assembly">
          <xsl:value-of select="@name"/>;</xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="date">
        <xsl:value-of select="assembly/@run-date"/>
      </xsl:attribute>
      <xsl:attribute name="time">
        <xsl:value-of select="assembly/@run-time"/>
      </xsl:attribute>
      <xsl:attribute name="total">
        <xsl:value-of select="sum(assembly/@total)"/>
      </xsl:attribute>
      <xsl:attribute name="failures">
        <xsl:value-of select="sum(assembly/@failed)"/>
      </xsl:attribute>
      <xsl:attribute name="not-run">
        <xsl:value-of select="sum(assembly/@skipped)"/>
      </xsl:attribute>
      <!-- mandatory according to nunit xsd: errors="0" inconclusive="0" ignored="0" invalid="0" skipped="0"  -->
      <xsl:apply-templates select="assembly"/>
    </test-results>
  </xsl:template>
  <xsl:template match="assembly">
      <test-suite>
        <xsl:attribute name="name">
          <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:attribute name="success">
          <xsl:if test="@failed > 0">False</xsl:if>
          <xsl:if test="@failed = 0">True</xsl:if>
        </xsl:attribute>
        <xsl:attribute name="time">
          <xsl:value-of select="@time"/>
        </xsl:attribute>
        <results>
          <xsl:apply-templates select="class"/>
        </results>
      </test-suite>
  </xsl:template>

  <xsl:template match="class">
    <test-suite>
      <xsl:attribute name="name">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:attribute name="success">
        <xsl:if test="@failed > 0">False</xsl:if>
        <xsl:if test="@failed = 0">True</xsl:if>
      </xsl:attribute>
      <xsl:attribute name="time">
        <xsl:value-of select="@time"/>
      </xsl:attribute>
      <xsl:if test="failure">
        <xsl:copy-of select="failure"/>
      </xsl:if>
      <xsl:if test="reason">
        <reason>
          <xsl:apply-templates select="reason"/>
        </reason>
      </xsl:if>
      <results>
        <xsl:apply-templates select="test"/>
      </results>
    </test-suite>
  </xsl:template>

  <xsl:template match="test">
    <test-case>
      <xsl:attribute name="name">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:attribute name="executed">
        <xsl:if test="@result='Skip'">False</xsl:if>
        <xsl:if test="@result!='Skip'">True</xsl:if>
      </xsl:attribute>
      <xsl:if test="@result!='Skip'">
        <xsl:attribute name="success">
          <xsl:if test="@result='Fail'">False</xsl:if>
          <xsl:if test="@result='Pass'">True</xsl:if>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@time">
        <xsl:attribute name="time">
          <xsl:value-of select="@time"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="traits"/>
      <xsl:apply-templates select="failure"/>
    </test-case>
  </xsl:template>

  <xsl:template match="traits">
    <properties>
      <xsl:apply-templates select="trait"/>
    </properties>
  </xsl:template>

  <xsl:template match="trait">
    <property>
      <xsl:attribute name="name">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:attribute name="value">
        <xsl:value-of select="@value"/>
      </xsl:attribute>
    </property>
  </xsl:template>

  <xsl:template match="failure">
    <failure>
      <xsl:copy-of select="node()"/>
    </failure>
  </xsl:template>

</xsl:stylesheet>