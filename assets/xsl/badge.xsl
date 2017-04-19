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
          <text x="102.5" y="15" fill="#010101" fill-opacity=".3" text-anchor="end">
              <xsl:value-of select="availability"/>
          </text>
        </xsl:if>
        <text x="102.5" y="14" text-anchor="end">
          <xsl:value-of select="availability"/>
        </text>
      </g>
      <path
              d="m 18.60837,2.6065916 c 0,0 1.239845,3.0331878 -4.073899,5.0705689 -2.887366,1.1067458 -5.1050337,3.9434445 -2.45714,8.3254405 0.219289,-1.95868 1.159585,-6.2773135 5.202805,-7.2627919 0,0 -3.763186,1.4071579 -4.095614,7.7767859 1.933681,0.271487 6.468735,0.453917 7.815176,-3.481621 C 22.777674,7.8352591 18.60837,2.6065916 18.60837,2.6065916 Z"
              style="font-size:medium;font-family:'DejaVu Sans', Verdana, Geneva, sans-serif;text-anchor:middle;fill:#cccccc" />
      <path
              d="M 13.186276,16.490092 C 17.291327,14.851785 20.278247,11.013851 20.690489,6.4322768 19.851277,4.1685634 18.60837,2.6065916 18.60837,2.6065916 c 0,0 1.239845,3.0331878 -4.073899,5.0705689 -2.887366,1.1067458 -5.1050337,3.9434445 -2.45714,8.3254405 0.219289,-1.95868 1.159585,-6.2773135 5.202805,-7.2627919 -2.23e-4,2.78e-5 -3.752218,1.4036779 -4.09386,7.7502829 z"
              style="font-size:medium;font-family:'DejaVu Sans', Verdana, Geneva, sans-serif;text-anchor:middle;fill:#ffffff" />
    </svg>
  </xsl:template>
</xsl:stylesheet>
