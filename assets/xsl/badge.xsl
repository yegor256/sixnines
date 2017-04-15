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
  <xsl:template match="/endpoint">
    <svg width="120" height="20">
      <mask id="a">
        <rect width="120" height="20" rx="0" fill="#fff" style="fill:#fcfcfc;stroke-width:0;stroke:rgb(20,20,20)"/>
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
      <g fill="#fff" text-anchor="middle" font-size="11">
        <text x="19.5" y="15" fill="#fff" fill-opacity=".8" font-family="monospace">
          <xsl:if test="state='true'">
            <xsl:text>UP</xsl:text>
          </xsl:if>
          <xsl:if test="state='false'">
            <xsl:text>DOWN</xsl:text>
          </xsl:if>
        </text>
        <text x="102.5" y="14" text-anchor="end" font-family="monospace" font-weight='bold'>
            <xsl:value-of select="availability"/>
        </text>
      </g>
    </svg>
  </xsl:template>
</xsl:stylesheet>
