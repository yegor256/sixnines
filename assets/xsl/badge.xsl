<?xml version="1.0" encoding="UTF-8"?>
<!--
 * SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
 * SPDX-License-Identifier: MIT
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
            <xsl:choose>
              <xsl:when test="number(availability) &gt; 99.9">
                <xsl:text>#44cc11</xsl:text>
              </xsl:when>
              <xsl:when test="number(availability) &gt; 99">
                <xsl:text>#dfb317</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>#d9644d</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </path>
      </g>
      <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
        <xsl:if test="$style = 'round'">
          <path fill="#1a1a1a" d="m 21.017582,3.7319286 c -2.483022,1.311e-4 -5.133155,0.3831153 -7.111622,1.5312198 -3.891615,2.258079 -3.668122,5.9360826 -3.534133,7.2969576 5.026459,-5.9542088 12.544865,-5.6655121 12.544865,-5.6655121 0,0 -10.657503,3.6556341 -13.7877374,10.9866011 -0.24721,0.578724 1.1599794,1.331692 1.4811064,0.647488 0.958496,-2.038767 2.294044,-3.567942 2.294044,-3.567942 1.97055,0.73328 5.379204,1.592345 7.795301,-0.107782 3.209246,-2.258486 2.881089,-7.2646822 7.462411,-9.7023653 C 28.83062,4.7948736 25.155952,3.7317098 21.017582,3.7319286 Z"/>
        </xsl:if>
        <path fill="#ffffff" d="m 21.102809,3.0223871 c -2.483021,1.311e-4 -5.133154,0.3831153 -7.111621,1.5312198 -3.891615,2.258079 -3.668122,5.9360821 -3.534133,7.2969571 5.026459,-5.9542083 12.544864,-5.6655116 12.544864,-5.6655116 0,0 -10.657502,3.6556352 -13.7877356,10.9866016 -0.24721,0.578724 1.1599786,1.331692 1.4811056,0.647488 0.958496,-2.038767 2.294044,-3.567942 2.294044,-3.567942 1.97055,0.73328 5.379204,1.592345 7.7953,-0.107782 3.209246,-2.258487 2.881089,-7.2646827 7.462411,-9.7023658 0.668803,-0.3557201 -3.005865,-1.4188839 -7.144235,-1.4186651 z"/>
        <xsl:if test="$style = 'round'">
          <text x="102.5" y="15" fill="#010101" fill-opacity=".3" text-anchor="end">
            <xsl:value-of select="text"/>
          </text>
        </xsl:if>
        <text x="102.5" y="14" text-anchor="end">
          <xsl:value-of select="text"/>
        </text>
      </g>
    </svg>
  </xsl:template>
</xsl:stylesheet>
