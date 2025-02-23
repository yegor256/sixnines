<?xml version="1.0" encoding="UTF-8"?>
<!--
 * SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
 * SPDX-License-Identifier: MIT
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2000/svg" version="1.0">
  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:variable name="W" select="440"/> <!-- width -->
  <xsl:variable name="H" select="100"/> <!-- height -->
  <xsl:variable name="LP" select="0"/> <!-- left padding -->
  <xsl:variable name="RP" select="0"/> <!-- right padding -->
  <xsl:variable name="LM" select="0"/> <!-- left margin -->
  <xsl:variable name="RM" select="0"/> <!-- right margin -->
  <xsl:variable name="TM" select="15"/> <!-- top margin -->
  <xsl:variable name="BM" select="15"/> <!-- bottom margin -->
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
      <rect width="{$W}" height="{$H}" stroke-width="0" fill="rgb(255,255,255)" stroke="rgb(20,20,20)" />
      <g id="average-line">
        <line x1="{$LM}" x2="{$W - $RM}" stroke="rgb(74,141,152)" stroke-width="1">
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
        <text x="{$LM}" font-family="monospace" font-size="12" fill="#4A8D98" dominant-baseline="hanging">
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
      </g>
      <g id="min-line">
        <line x1="{$LM}" y1="{$H - $BM}" x2="{$W - $RM}" y2="{$H - $BM}" stroke="rgb(200,200,200)" stroke-width="1" />
        <text x="{$W - $RM}" y="{$H - $BM + 2}" font-family="monospace" font-size="12" fill="#c8c8c8" text-anchor="end" dominant-baseline="hanging">
          <tspan>
            <xsl:value-of select="$miny"/>
            <xsl:text>ms</xsl:text>
          </tspan>
        </text>
      </g>
      <g id="max-line">
        <line x1="{$LM}" y1="{$TM}" x2="{$W - $RM}" y2="{$TM}" stroke="rgb(200,200,200)" stroke-width="1" />
        <text x="{$W - $RM}" y="{$TM - 2}" font-family="monospace" font-size="12" fill="#c8c8c8" text-anchor="end">
          <tspan>
            <xsl:value-of select="$maxy"/>
            <xsl:text>ms</xsl:text>
          </tspan>
        </text>
      </g>
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
          <xsl:choose>
            <xsl:when test="@msec &gt; $maxy">
              <circle r="3" stroke-width="0" fill="#cccccc">
                <xsl:attribute name="cx">
                  <xsl:call-template name="time-to-x">
                    <xsl:with-param name="time" select="@time"/>
                  </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="cy">
                  <xsl:call-template name="msec-to-y">
                    <xsl:with-param name="msec" select="$maxy"/>
                  </xsl:call-template>
                </xsl:attribute>
                <title>
                  <xsl:value-of select="@msec"/>
                </title>
              </circle>
            </xsl:when>
            <xsl:otherwise>
              <circle r="3" stroke-width="0">
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
                  <xsl:choose>
                    <xsl:when test="@code = 200">
                      <xsl:text>#44cc11</xsl:text>
                    </xsl:when>
                    <xsl:when test="@code &lt; 300">
                      <xsl:text>#ffd479</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>#d9644d</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
              </circle>
            </xsl:otherwise>
          </xsl:choose>
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
    <xsl:value-of select="($time - $minx) div $width * ($W - $LM - $RM - $LP - $RP) + $LM + $LP"/>
  </xsl:template>
</xsl:stylesheet>
