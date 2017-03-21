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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2000/svg" version="2.0">
  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:template match="/history">
    <xsl:variable name="minx" select="@minx"/>
    <xsl:variable name="maxx" select="@maxx"/>
    <xsl:variable name="width" select="$maxx - $minx"/>
    <xsl:variable name="miny" select="@miny"/>
    <xsl:variable name="maxy" select="@maxy"/>
    <xsl:variable name="height" select="$maxy - $miny"/>
    <svg width="800" height="600">
      <xsl:for-each select="p">
        <circle r="2" stroke-width="0" fill="black"
          cx="(@time - $minx) / $width * 800"
          cy="(@msec - $miny) / $height * 600" />
      </xsl:for-each>
    </svg>
  </xsl:template>
</xsl:stylesheet>
