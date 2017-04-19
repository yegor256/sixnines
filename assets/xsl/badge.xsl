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
          <path fill="#000000" d="m 15.845703,3.2807515 c 0,0 1.239525,3.0329314 -4.074219,5.0703125 -2.887366,1.1067458 -5.1049249,3.944176 -2.4570309,8.326172 0.219289,-1.95868 1.1599049,-6.278194 5.2031249,-7.263672 -5.6e-5,6.9e-6 -0.234678,0.087598 -0.591797,0.3183594 -9.57e-4,6.178e-4 -9.94e-4,0.00133 -0.002,0.00195 -0.17814,0.1152237 -0.386273,0.2658673 -0.611328,0.4589846 -0.316979,0.271822 -0.665757,0.632776 -1.009766,1.091797 -0.146588,0.195612 -0.292112,0.404112 -0.433593,0.638672 -0.118333,0.19612 -0.232832,0.405602 -0.34375,0.630859 -0.04843,0.09835 -0.09214,0.210315 -0.138672,0.314453 -0.06181,0.138347 -0.125718,0.27106 -0.183594,0.419922 -0.0998,0.256687 -0.193979,0.529039 -0.279297,0.818359 -0.08432,0.285942 -0.161738,0.588706 -0.228516,0.908203 -0.02269,0.108613 -0.03624,0.231131 -0.05664,0.34375 -0.04119,0.227297 -0.08418,0.45129 -0.115234,0.695313 -0.04472,0.35155 -0.07871,0.721743 -0.09961,1.109375 -5.14e-4,0.0095 -0.0015,0.01778 -0.002,0.02734 1.933681,0.271487 6.469965,0.453116 7.816406,-3.482422 0.806569,-2.358821 0.386251,-4.7177543 -0.310547,-6.5976565 1.17e-4,-0.0013 -1.16e-4,-0.00261 0,-0.00391 C 17.91729,7.0790005 17.9049,7.0545315 17.89444,7.0268345 17.814393,6.8148636 17.732086,6.6140575 17.646484,6.4155171 17.491231,6.0549475 17.334237,5.7310841 17.173828,5.4213765 17.006744,5.0989681 16.85365,4.8275414 16.699219,4.569814 16.636163,4.4642942 16.576371,4.3568055 16.517578,4.2631734 16.420064,4.1078505 16.411464,4.1004945 16.330078,3.9799702 16.057201,3.5687796 15.845703,3.2807515 15.845703,3.2807515 Z"/>
        </xsl:if>
        <path fill="#ffffff" d="m 15.846043,2.7700189 c 0,0 1.239525,3.032931 -4.074219,5.070313 -2.887366,1.1067451 -5.104925,3.9441761 -2.457031,8.3261721 0.219289,-1.95868 1.159905,-6.278194 5.203125,-7.263672 -5.6e-5,6e-6 -0.234678,0.0876 -0.591797,0.318359 -9.57e-4,6.18e-4 -9.94e-4,0.0013 -0.002,0.0019 -0.17814,0.115224 -0.386273,0.265867 -0.611328,0.458984 -0.316979,0.271823 -0.665757,0.632777 -1.009766,1.091798 -0.146588,0.195612 -0.292112,0.404112 -0.433593,0.638672 -0.118333,0.19612 -0.232832,0.405602 -0.34375,0.630859 -0.04843,0.09835 -0.09214,0.210315 -0.138672,0.314453 -0.06181,0.138347 -0.125718,0.27106 -0.183594,0.419922 -0.0998,0.256687 -0.193979,0.529039 -0.279297,0.818359 -0.08432,0.285942 -0.161738,0.588706 -0.228516,0.908203 -0.02269,0.108613 -0.03624,0.231131 -0.05664,0.34375 -0.04119,0.227297 -0.08418,0.45129 -0.115234,0.695313 -0.04472,0.35155 -0.07871,0.721743 -0.09961,1.109375 -5.14e-4,0.0095 -0.0015,0.01778 -0.002,0.02734 1.933681,0.271488 6.469965,0.453117 7.816406,-3.482421 0.806569,-2.358821 0.386251,-4.717755 -0.310547,-6.5976571 1.17e-4,-0.0013 -1.16e-4,-0.0026 0,-0.0039 -0.01035,-0.02791 -0.02274,-0.05238 -0.0332,-0.08008 -0.08005,-0.211971 -0.162354,-0.412777 -0.247956,-0.611317 -0.155253,-0.36057 -0.312247,-0.684433 -0.472656,-0.994141 -0.167084,-0.322408 -0.320178,-0.593835 -0.474609,-0.851562 -0.06306,-0.10552 -0.122848,-0.213009 -0.181641,-0.306641 -0.09751,-0.155323 -0.106114,-0.162679 -0.1875,-0.283203 -0.272877,-0.411191 -0.484375,-0.699219 -0.484375,-0.699219 z"/>
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