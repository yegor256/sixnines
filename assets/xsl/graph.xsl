<?xml version="1.0"?>
<!--
 * Copyright (c) 2017 Yegor Bugayenko
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2000/svg" version="1.0">
  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:variable name="W" select="440"/>
  <xsl:variable name="H" select="120"/>
  <xsl:variable name="LM" select="0"/>
  <xsl:variable name="RM" select="0"/>
  <xsl:variable name="TM" select="15"/>
  <xsl:variable name="BM" select="15"/>
  <xsl:variable name="minx" select="/history/@maxx - 60 * 1000"/>
  <xsl:variable name="maxx" select="/history/@now"/>
  <xsl:variable name="width" select="$maxx - $minx"/>
  <xsl:variable name="miny" select="/history/@miny"/>
  <xsl:variable name="maxy" select="/history/@maxy"/>
  <xsl:variable name="height" select="$maxy - $miny"/>
  <xsl:template match="/history">
    <svg width="{$W}" height="{$H}">
      <xsl:comment>
        <xsl:text>minx=</xsl:text>
        <xsl:value-of select="$minx"/>
        <xsl:text>; maxx=</xsl:text>
        <xsl:value-of select="$maxx"/>
        <xsl:text>; width=</xsl:text>
        <xsl:value-of select="$width"/>
        <xsl:text>; miny=</xsl:text>
        <xsl:value-of select="$miny"/>
        <xsl:text>; maxy=</xsl:text>
        <xsl:value-of select="$maxy"/>
        <xsl:text>; height=</xsl:text>
        <xsl:value-of select="$height"/>
      </xsl:comment>
      <rect width="{$W}" height="{$H}" style="fill:#fcfcfc;;stroke-width:0;stroke:rgb(20,20,20)" />
      <line x1="{$LM}" x2="{$W - $RM}" style="stroke:rgb(74,141,152);stroke-width:1">
        <xsl:attribute name="y1">
          <xsl:call-template name="msec-to-y">
            <xsl:with-param name="msec" select="@avg"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="y2">
          <xsl:call-template name="msec-to-y">
            <xsl:with-param name="msec" select="@avg"/>
          </xsl:call-template>
        </xsl:attribute>
      </line>
      <text x="{$LM}" font-family="monospace" font-size="15" fill="rgba(0, 155, 221, .7)" dominant-baseline="hanging">
        <xsl:attribute name="y">
          <xsl:call-template name="msec-to-y">
            <xsl:with-param name="msec" select="@avg"/>
          </xsl:call-template>
        </xsl:attribute>
        <tspan>
          <xsl:value-of select="@avg"/>
          <xsl:text>ms</xsl:text>
        </tspan>
      </text>
      <line x1="{$LM}" y1="{$H - $BM - 10}" x2="{$W - $RM}" y2="{$H - $BM - 10}" style="stroke:rgb(200,200,200);stroke-width:1" />
      <text x="{$W - $RM}" y="{$H - $BM + 2}" font-family="monospace" font-size="15" fill="rgba(0, 155, 221, .7)" text-anchor="end" dominant-baseline="hanging">
        <tspan>
          <xsl:value-of select="$miny"/>
          <xsl:text>ms</xsl:text>
        </tspan>
      </text>
      <line x1="{$LM}" y1="{$TM + 10}" x2="{$W - $RM}" y2="{$TM + 10}" style="stroke:rgb(200,200,200);stroke-width:1" />
      <text x="{$W - $RM}" y="{$TM - 2}" font-family="monospace" font-size="15" fill="rgba(0, 155, 221, .7)" text-anchor="end">
        <tspan>
          <xsl:value-of select="$maxy"/>
          <xsl:text>ms</xsl:text>
        </tspan>
      </text>
      <xsl:for-each select="p">
        <xsl:if test="@time &lt; $maxx and @time &gt; $minx">
          <xsl:comment>
            <xsl:text>time=</xsl:text>
            <xsl:value-of select="@time"/>
            <xsl:text>; msec=</xsl:text>
            <xsl:value-of select="@msec"/>
            <xsl:text>; code=</xsl:text>
            <xsl:value-of select="@code"/>
          </xsl:comment>
          <circle r="2" stroke-width="0">
            <xsl:attribute name="cx">
              <xsl:call-template name="time-to-x">
                <xsl:with-param name="time" select="@time"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="cy">
              <xsl:call-template name="msec-to-y">
                <xsl:with-param name="msec" select="@msec"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="fill">
              <xsl:if test="@code=200">
                <xsl:text>rgba(0, 155, 221, .7)</xsl:text>
              </xsl:if>
              <xsl:if test="@code!=200">
                <xsl:text>#DD4A68</xsl:text>
              </xsl:if>
            </xsl:attribute>
          </circle>
        </xsl:if>
      </xsl:for-each>
    </svg>
  </xsl:template>
  <xsl:template name="msec-to-y">
    <xsl:param name="msec"/>
    <xsl:value-of select="($H - $TM - $BM) - (($msec - $miny) div $height * ($H - $TM - $BM)) + $TM"/>
  </xsl:template>
  <xsl:template name="time-to-x">
    <xsl:param name="time"/>
    <xsl:value-of select="($time - $minx) div $width * ($W - $LM - $RM) + $LM"/>
  </xsl:template>
</xsl:stylesheet>
