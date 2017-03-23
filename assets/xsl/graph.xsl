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
  <xsl:template match="/history">
    <xsl:variable name="minx" select="@maxx - 60 * 1000"/>
    <xsl:variable name="maxx" select="@maxx"/>
    <xsl:variable name="width" select="$maxx - $minx"/>
    <xsl:variable name="miny" select="@miny"/>
    <xsl:variable name="maxy" select="@maxy"/>
    <xsl:variable name="height" select="$maxy - $miny"/>
    <xsl:variable name="W" select="640"/>
    <xsl:variable name="H" select="160"/>
    <xsl:variable name="LM" select="25"/>
    <xsl:variable name="RM" select="25"/>
    <xsl:variable name="TM" select="10"/>
    <xsl:variable name="BM" select="10"/>
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
      <rect width="{$W}" height="{$H}" style="fill:rgb(255,255,255);stroke-width:1;stroke:rgb(20,20,20)" />
      <line x1="{$LM}" y1="{$H - $BM}" x2="{$W - $RM}" y2="{$H - $BM}" style="stroke:rgb(200,200,200);stroke-width:1" />
      <text x="{$W - $RM}" y="{$H - $BM}" font-family="monospace" font-size="8" fill="#c8c8c8" text-anchor="end" dominant-baseline="hanging">
        <xsl:value-of select="$miny"/>
        <xsl:text>ms</xsl:text>
      </text>
      <line x1="{$LM}" y1="{$TM}" x2="{$W - $RM}" y2="{$TM}" style="stroke:rgb(200,200,200);stroke-width:1" />
      <text x="{$W - $RM}" y="{$TM}" font-family="monospace" font-size="8" fill="#c8c8c8" text-anchor="end">
        <xsl:value-of select="$maxy"/>
        <xsl:text>ms</xsl:text>
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
          <circle r="2" stroke-width="0"
            cx="{(@time - $minx) div $width * ($W - $LM - $RM) + $LM}"
            cy="{($H - $TM - $BM) - ((@msec - $miny) div $height * ($H - $TM - $BM)) + $TM}">
            <xsl:attribute name="fill">
              <xsl:if test="@code=200">
                <xsl:text>#4c1</xsl:text>
              </xsl:if>
              <xsl:if test="@code!=200">
                <xsl:text>#d9644d</xsl:text>
              </xsl:if>
            </xsl:attribute>
          </circle>
        </xsl:if>
      </xsl:for-each>
    </svg>
  </xsl:template>
</xsl:stylesheet>
