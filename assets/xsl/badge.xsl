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
  <xsl:param name="style"/>
  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:template match="/endpoint">
    <svg width="106" height="20">
      <xsl:if test="$style = 'round'">
        <linearGradient id="b" x2="0" y2="100%">
          <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
          <stop offset="1" stop-opacity=".1"/>
        </linearGradient>
      </xsl:if>
      <mask id="a">
        <rect width="106" height="20" fill="#fff">
          <xsl:if test="$style = 'round'">
            <xsl:attribute name="rx">
              <xsl:text>3</xsl:text>
            </xsl:attribute>
          </xsl:if>
        </rect>
      </mask>
      <g mask="url(#a)">
        <path fill="#555" d="M0 0h37v20H0z"/>
        <path d="M37 0h77v20H37z">
          <xsl:attribute name="fill">
            <xsl:if test="state='true'">
              <xsl:text>#4c1</xsl:text>
            </xsl:if>
            <xsl:if test="state='false'">
              <xsl:text>#d9644d</xsl:text>
            </xsl:if>
          </xsl:attribute>
        </path>
        <path fill="url(#b)" d="M0 0h106v20H0z"/>
      </g>
      <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
        <xsl:if test="$style = 'round'">
          <text x="19.5" y="15" fill="#010101" fill-opacity=".3">
            <xsl:if test="state='true'">
              <xsl:text>up</xsl:text>
            </xsl:if>
            <xsl:if test="state='false'">
              <xsl:text>down</xsl:text>
            </xsl:if>
          </text>
        </xsl:if>
        <text x="19.5" y="14">
          <xsl:if test="state='true'">
            <xsl:text>up</xsl:text>
          </xsl:if>
          <xsl:if test="state='false'">
            <xsl:text>down</xsl:text>
          </xsl:if>
        </text>
        <xsl:if test="$style = 'round'">
          <text x="102.5" y="15" fill="#010101" fill-opacity=".3" text-anchor="end">
              <xsl:value-of select="availability"/>
          </text>
        </xsl:if>
        <text x="102.5" y="14" text-anchor="end">
          <xsl:value-of select="availability"/>
        </text>
      </g>
    </svg>
  </xsl:template>
</xsl:stylesheet>
