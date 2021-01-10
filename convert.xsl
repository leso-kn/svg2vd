<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s="http://www.w3.org/2000/svg"
    xmlns:aapt="http://schemas.android.com/aapt"
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape">

    <xsl:output
        method="xml"
        indent="yes"
        encoding="utf-8"/>

    <xsl:template match="text()">
    </xsl:template>

<!--#
    #  Functions
    #  -->

    <xsl:template name="bytes-to-hex">
        <xsl:param name="opac" />

        <xsl:value-of select="concat(substring('FF', 1, (1 - number(number($opac) = number($opac))) * 2),
                              substring('0123456789ABCDEF', floor($opac * 0.0625) + 1,1),
                              substring('0123456789ABCDEF', floor($opac mod 16) + 1,1))" />
    </xsl:template>

    <xsl:template name="to-uppercase">
        <xsl:param name="text" />

        <xsl:value-of select="translate($text, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
    </xsl:template>

    <xsl:template name="un-unit">
        <xsl:param name="text" />

        <xsl:value-of select="translate($text, translate($text,'0123456789.',''), '')" />
    </xsl:template>

    <xsl:template name="string-replace-all">
        <xsl:param name="text" />
        <xsl:param name="replace" />
        <xsl:param name="by" />

        <xsl:choose>
            <xsl:when test="$text = '' or $replace = ''or not($replace)" >
                <!-- Prevent this routine from hanging -->
                <xsl:value-of select="$text" />
            </xsl:when>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)" />
                <xsl:value-of select="$by" />
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text,$replace)" />
                    <xsl:with-param name="replace" select="$replace" />
                    <xsl:with-param name="by" select="$by" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!--#
    #  Macro Templates
    #  -->

    <!-- Fill -->

    <xsl:template name="get-attr-fill">
        <xsl:choose>
            <xsl:when test="@fill">
                <xsl:value-of select="@fill" />
            </xsl:when>
            <xsl:when test="contains(@style, 'fill:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(@style, 'fill:'), ';')">
                        <xsl:value-of select="substring-before(substring-after(@style, 'fill:'), ';')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(@style, 'fill:')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="ancestor::*[@fill][1]/@fill">
                <xsl:value-of select="ancestor::*[@fill][1]/@fill" />
            </xsl:when>
            <xsl:when test="contains(ancestor::*[@style][1]/@style, 'fill:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(ancestor::*[@style][1]/@style, 'fill:'), ';')">
                        <xsl:value-of select="substring-before(substring-after(ancestor::*[@style][1]/@style, 'fill:'), ';')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(ancestor::*[@style][1]/@style, 'fill:')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>none</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-attr-fill-opacity">
        <xsl:choose>
            <xsl:when test="contains(@style, 'fill-opacity:')">
                <xsl:call-template name="bytes-to-hex">
                    <xsl:with-param name="opac">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(ancestor::*[@style][1]/@style, 'fill-opacity:'), ';')">
                                <xsl:value-of select="round(substring-before(substring-after(@style, 'fill-opacity:'), ';') * 255)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="round(substring-after(@style, 'fill-opacity:') * 255)" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>FF</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="set-attr-fill">
        <xsl:param name="fill" />
        <xsl:param name="fill-opacity" />

        <xsl:if test="$fill != 'none'">
            <xsl:choose>
                <xsl:when test="starts-with($fill, 'url(#')">
                    <!-- Use sub-element to describe fill -->
                    <aapt:attr name="android:fillColor">
                        <xsl:call-template name="linearGradient">
                            <xsl:with-param name="svg-el" select="../*[@id=substring-before(substring($fill, 6), ')')]" />
                        </xsl:call-template>
                    </aapt:attr>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Set fill color -->
                    <xsl:attribute name="android:fillColor">
                        <xsl:choose>
                            <xsl:when test="starts-with($fill, '#')">
                                <xsl:call-template name="to-uppercase">
                                    <xsl:with-param name="text" select="concat('#', $fill-opacity, substring($fill,2))" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>#FF000000</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- Stroke -->

    <xsl:template name="get-attr-stroke">
        <xsl:choose>
            <xsl:when test="@stroke">
                <xsl:value-of select="@stroke" />
            </xsl:when>
            <xsl:when test="contains(@style, 'stroke:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(@style, 'stroke:'), ';')">
                        <xsl:value-of select="substring-before(substring-after(@style, 'stroke:'), ';')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(@style, 'stroke:')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="ancestor::*[@stroke][1]/@stroke">
                <xsl:value-of select="ancestor::*[@stroke][1]/@stroke" />
            </xsl:when>
            <xsl:when test="contains(ancestor::*[@style][1]/@style, 'stroke:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(ancestor::*[@style][1]/@style, 'stroke:'), ';')">
                        <xsl:value-of select="substring-before(substring-after(ancestor::*[@style][1]/@style, 'stroke:'), ';')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(ancestor::*[@style][1]/@style, 'stroke:')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>none</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-attr-stroke-width">
        <xsl:call-template name="un-unit">
            <xsl:with-param name="text">
                <xsl:choose>
                    <xsl:when test="@stroke-width">
                        <xsl:value-of select="@stroke-width" />
                    </xsl:when>
                    <xsl:when test="contains(@style, 'stroke-width:')">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(@style, 'stroke-width:'), ';')">
                                <xsl:value-of select="substring-before(substring-after(@style, 'stroke-width:'), ';')" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after(@style, 'stroke-width:')" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:when test="ancestor::*[@stroke-width][1]/@stroke-width">
                        <xsl:value-of select="ancestor::*[@stroke-width][1]/@stroke-width" />
                    </xsl:when>
                    <xsl:when test="contains(ancestor::*[@style][1]/@style, 'stroke-width:')">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(ancestor::*[@style][1]/@style, 'stroke-width:'), ';')">
                                <xsl:value-of select="substring-before(substring-after(ancestor::*[@style][1]/@style, 'stroke-width:'), ';')" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after(ancestor::*[@style][1]/@style, 'stroke-width:')" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="get-attr-stroke-linecap">
        <xsl:choose>
            <xsl:when test="@stroke-linecap">
                <xsl:value-of select="@stroke-linecap" />
            </xsl:when>
            <xsl:when test="contains(@style, 'stroke-linecap:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(@style, 'stroke-linecap:'), ';')">
                        <xsl:value-of select="substring-before(substring-after(@style, 'stroke-linecap:'), ';')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(@style, 'stroke-linecap:')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="ancestor::*[@stroke-linecap][1]/@stroke-linecap">
                <xsl:value-of select="ancestor::*[@stroke-linecap][1]/@stroke-linecap" />
            </xsl:when>
            <xsl:when test="contains(ancestor::*[@style][1]/@style, 'stroke-linecap:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(ancestor::*[@style][1]/@style, 'stroke-linecap:'), ';')">
                        <xsl:value-of select="substring-before(substring-after(ancestor::*[@style][1]/@style, 'stroke-linecap:'), ';')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(ancestor::*[@style][1]/@style, 'stroke-linecap:')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>none</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-attr-stroke-opacity">
        <xsl:choose>
            <xsl:when test="contains(@style, 'stroke-opacity:')">
                <xsl:call-template name="bytes-to-hex">
                    <xsl:with-param name="opac">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(ancestor::*[@style][1]/@style, 'stroke-opacity:'), ';')">
                                <xsl:value-of select="round(substring-before(substring-after(@style, 'stroke-opacity:'), ';') * 255)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="round(substring-after(@style, 'stroke-opacity:') * 255)" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>FF</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="set-attr-stroke">
        <xsl:param name="stroke" />
        <xsl:param name="stroke-width" />
        <xsl:param name="stroke-linecap" />
        <xsl:param name="stroke-opacity" />

        <xsl:if test="$stroke-width > 0">
            <xsl:attribute name="android:strokeWidth">
                <xsl:value-of select="$stroke-width" />
            </xsl:attribute>
        </xsl:if>

        <xsl:if test="$stroke-linecap != 'none'">
            <xsl:attribute name="android:strokeLineCap">
                <xsl:value-of select="$stroke-linecap" />
            </xsl:attribute>
        </xsl:if>

        <xsl:if test="$stroke != 'none'">
            <xsl:choose>
                <xsl:when test="starts-with($stroke, 'url(#')">
                    <!-- Use sub-element to describe stroke -->
                    <aapt:attr name="android:strokeColor">
                        <xsl:call-template name="linearGradient">
                            <xsl:with-param name="svg-el" select="../*[@id=substring-before(substring($stroke, 6), ')')]" />
                        </xsl:call-template>
                    </aapt:attr>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Set stroke color -->
                    <xsl:attribute name="android:strokeColor">
                        <xsl:choose>
                            <xsl:when test="starts-with($stroke, '#')">
                                <xsl:call-template name="to-uppercase">
                                    <xsl:with-param name="text" select="concat('#', $stroke-opacity, substring($stroke,2))" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>#FF000000</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- Rendering -->

    <xsl:template name="get-attr-paint-order-stroke-first">
        <xsl:choose>
            <xsl:when test="@paint-order">
                <xsl:value-of select="contains(@paint-order, 'stroke fill')" />
            </xsl:when>
            <xsl:when test="contains(@style, 'paint-order:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(@style, 'paint-order:'), ';')">
                        <xsl:value-of select="contains(substring-before(substring-after(@style, 'paint-order:'), ';'), 'stroke fill')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="contains(substring-after(@style, 'paint-order:'), 'stroke fill')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="ancestor::*[@paint-order][1]/@paint-order">
                <xsl:value-of select="contains(ancestor::*[@paint-order][1]/@paint-order, 'stroke fill')" />
            </xsl:when>
            <xsl:when test="contains(ancestor::*[@style][1]/@style, 'paint-order:')">
                <xsl:choose>
                    <xsl:when test="contains(substring-after(ancestor::*[@style][1]/@style, 'paint-order:'), ';')">
                        <xsl:value-of select="contains(substring-before(substring-after(ancestor::*[@style][1]/@style, 'paint-order:'), ';'), 'stroke fill')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="contains(substring-after(ancestor::*[@style][1]/@style, 'paint-order:'), 'stroke fill')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Gradient -->

    <xsl:template name="linearGradient">
        <xsl:param name="svg-el" />
        <gradient android:startX="{$svg-el/@x1}"
                  android:startY="{$svg-el/@y1}"
                  android:endX="{$svg-el/@x2}"
                  android:endY="{$svg-el/@y2}"
                  android:type="linear">

            <xsl:for-each select="$svg-el/*[name()='stop']">
                <xsl:variable name="hex-opac">
                    <xsl:call-template name="bytes-to-hex">
                        <xsl:with-param name="opac" select="round(substring(@style, 33) * 255)" />
                    </xsl:call-template>
                </xsl:variable>
                <item android:offset="{@offset}">
                    <xsl:attribute name="android:color">
                        <xsl:call-template name="to-uppercase">
                            <xsl:with-param name="text" select="concat('#', $hex-opac, substring(@style, 13, 6))" />
                        </xsl:call-template>
                    </xsl:attribute>
                </item>
            </xsl:for-each>
        </gradient>
    </xsl:template>

<!--#
    #  Element Templates
    #  -->

    <xsl:template match="s:svg">
        <xsl:variable name="width">
            <xsl:call-template name="un-unit">
                <xsl:with-param name="text"><xsl:value-of select="@width" /></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="height">
            <xsl:call-template name="un-unit">
                <xsl:with-param name="text"><xsl:value-of select="@height" /></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>

        <vector xmlns:aapt="http://schemas.android.com/aapt"
                android:width="{$width}mm"
                android:height="{$height}mm"
                android:viewportWidth="{substring-before(substring-after(substring-after(@viewBox, ' '), ' '), ' ')}"
                android:viewportHeight="{substring-after(substring-after(substring-after(@viewBox, ' '), ' '), ' ')}">

            <xsl:apply-templates match="path"/>
        </vector>
    </xsl:template>

    <!-- <group> -->
    <xsl:template match="s:g">
        <group android:name="{@inkscape:label|@id}">
            <xsl:if test="contains(@transform, 'translate(')">
                <xsl:attribute name="android:translateX">
                    <xsl:value-of select="substring-before(substring-after(@transform, 'translate('), ',')" />
                </xsl:attribute>
                <xsl:attribute name="android:translateY">
                    <xsl:value-of select="substring-before(substring-after(substring-after(@transform, 'translate('), ','), ')')" />
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </group>
    </xsl:template>

    <!-- <path> -->
    <xsl:template match="s:path">
        <xsl:variable name="fill"><xsl:call-template name="get-attr-fill" /></xsl:variable>
        <xsl:variable name="fill-opacity"><xsl:call-template name="get-attr-fill-opacity" /></xsl:variable>
        
        <xsl:variable name="stroke"><xsl:call-template name="get-attr-stroke" /></xsl:variable>
        <xsl:variable name="stroke-width"><xsl:call-template name="get-attr-stroke-width" /></xsl:variable>
        <xsl:variable name="stroke-linecap"><xsl:call-template name="get-attr-stroke-linecap" /></xsl:variable>
        <xsl:variable name="stroke-opacity"><xsl:call-template name="get-attr-stroke-opacity" /></xsl:variable>

        <xsl:variable name="paint-order-stroke-first"><xsl:call-template name="get-attr-paint-order-stroke-first" /></xsl:variable>

        <xsl:if test="$fill != 'none' or $stroke != 'none'">
            <path android:pathData="{@d}">
                <xsl:call-template name="set-attr-stroke">
                    <xsl:with-param name="stroke" select="$stroke" />
                    <xsl:with-param name="stroke-width" select="$stroke-width * (1 - 0.5 * number($paint-order-stroke-first = 'true'))" />
                    <xsl:with-param name="stroke-linecap" select="$stroke-linecap" />
                    <xsl:with-param name="stroke-opacity" select="$stroke-opacity" />
                </xsl:call-template>

                <xsl:call-template name="set-attr-fill">
                    <xsl:with-param name="fill" select="$fill" />
                    <xsl:with-param name="fill-opacity" select="$fill-opacity" />
                </xsl:call-template>
            </path>
        </xsl:if>
    </xsl:template>

    <!-- <polygon> -->
    <xsl:template match="s:polygon">
        <xsl:variable name="fill"><xsl:call-template name="get-attr-fill" /></xsl:variable>
        <xsl:variable name="fill-opacity"><xsl:call-template name="get-attr-fill-opacity" /></xsl:variable>

        <xsl:variable name="stroke"><xsl:call-template name="get-attr-stroke" /></xsl:variable>
        <xsl:variable name="stroke-width"><xsl:call-template name="get-attr-stroke-width" /></xsl:variable>
        <xsl:variable name="stroke-linecap"><xsl:call-template name="get-attr-stroke-linecap" /></xsl:variable>
        <xsl:variable name="stroke-opacity"><xsl:call-template name="get-attr-stroke-opacity" /></xsl:variable>

        <xsl:variable name="paint-order-stroke-first"><xsl:call-template name="get-attr-paint-order-stroke-first" /></xsl:variable>

        <xsl:if test="$fill != 'none'">
            <path>
                <xsl:attribute name="android:pathData">
                    <xsl:text>M</xsl:text>
                    <xsl:call-template name="string-replace-all">
                        <xsl:with-param name="text" select="substring(normalize-space(@points),1,string-length(normalize-space(@points)) - 1)" />
                        <xsl:with-param name="replace" select="' '" />
                        <xsl:with-param name="by" select="'L'" />
                    </xsl:call-template>
                    <xsl:text>z</xsl:text>
                </xsl:attribute>
                
                <xsl:call-template name="set-attr-stroke">
                    <xsl:with-param name="stroke" select="$stroke" />
                    <xsl:with-param name="stroke-width" select="$stroke-width * (1 - 0.5 * number($paint-order-stroke-first = 'true'))" />
                    <xsl:with-param name="stroke-linecap" select="$stroke-linecap" />
                    <xsl:with-param name="stroke-opacity" select="$stroke-opacity" />
                </xsl:call-template>

                <xsl:call-template name="set-attr-fill">
                    <xsl:with-param name="fill" select="$fill" />
                    <xsl:with-param name="fill-opacity" select="$fill-opacity" />
                </xsl:call-template>
            </path>
        </xsl:if>
    </xsl:template>

    <!-- <rect> -->
    <xsl:template match="s:rect">
        <xsl:variable name="fill"><xsl:call-template name="get-attr-fill" /></xsl:variable>
        <xsl:variable name="fill-opacity"><xsl:call-template name="get-attr-fill-opacity" /></xsl:variable>

        <xsl:variable name="stroke"><xsl:call-template name="get-attr-stroke" /></xsl:variable>
        <xsl:variable name="stroke-width"><xsl:call-template name="get-attr-stroke-width" /></xsl:variable>
        <xsl:variable name="stroke-linecap"><xsl:call-template name="get-attr-stroke-linecap" /></xsl:variable>
        <xsl:variable name="stroke-opacity"><xsl:call-template name="get-attr-stroke-opacity" /></xsl:variable>

        <xsl:variable name="paint-order-stroke-first"><xsl:call-template name="get-attr-paint-order-stroke-first" /></xsl:variable>

        <path android:pathData="M{@x},{@y}l{@width},{@height}z">
            <xsl:call-template name="set-attr-stroke">
                <xsl:with-param name="stroke" select="$stroke" />
                <xsl:with-param name="stroke-width" select="$stroke-width * (1 - 0.5 * number($paint-order-stroke-first = 'true'))" />
                <xsl:with-param name="stroke-linecap" select="$stroke-linecap" />
                <xsl:with-param name="stroke-opacity" select="$stroke-opacity" />
            </xsl:call-template>

            <xsl:call-template name="set-attr-fill">
                <xsl:with-param name="fill" select="$fill" />
                <xsl:with-param name="fill-opacity" select="$fill-opacity" />
            </xsl:call-template>
        </path>
    </xsl:template>

    <!-- <circle> -->
    <xsl:template match="s:circle">
        <xsl:variable name="fill"><xsl:call-template name="get-attr-fill" /></xsl:variable>
        <xsl:variable name="fill-opacity"><xsl:call-template name="get-attr-fill-opacity" /></xsl:variable>

        <xsl:variable name="stroke"><xsl:call-template name="get-attr-stroke" /></xsl:variable>
        <xsl:variable name="stroke-width"><xsl:call-template name="get-attr-stroke-width" /></xsl:variable>
        <xsl:variable name="stroke-linecap"><xsl:call-template name="get-attr-stroke-linecap" /></xsl:variable>
        <xsl:variable name="stroke-opacity"><xsl:call-template name="get-attr-stroke-opacity" /></xsl:variable>
        
        <xsl:variable name="paint-order-stroke-first"><xsl:call-template name="get-attr-paint-order-stroke-first" /></xsl:variable>

        <xsl:variable name="r">
            <xsl:choose>
                <xsl:when test="$paint-order-stroke-first">
                    <xsl:value-of select="@r + $stroke-width * 0.5" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@r" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <path android:pathData="M{@cx - $r},{@cy}c0,{-$r * 0.5} {$r * 0.5},{-$r} {$r},{-$r}c{$r * 0.5},0 {$r},{$r * 0.5} {$r},{$r}c0,{$r * 0.5} {-$r * 0.5},{$r} {-$r},{$r}c{-$r * 0.5},0 {-$r},{-$r * 0.5} {-$r},{-$r}z">
            <xsl:call-template name="set-attr-stroke">
                <xsl:with-param name="stroke" select="$stroke" />
                <xsl:with-param name="stroke-width" select="$stroke-width * (1 - 0.5 * number($paint-order-stroke-first = 'true'))" />
                <xsl:with-param name="stroke-linecap" select="$stroke-linecap" />
                <xsl:with-param name="stroke-opacity" select="$stroke-opacity" />
            </xsl:call-template>

            <xsl:call-template name="set-attr-fill">
                <xsl:with-param name="fill" select="$fill" />
                <xsl:with-param name="fill-opacity" select="$fill-opacity" />
            </xsl:call-template>
        </path>
    </xsl:template>

    <!-- <ellipse> -->
    <xsl:template match="s:ellipse">
        <xsl:variable name="fill"><xsl:call-template name="get-attr-fill" /></xsl:variable>
        <xsl:variable name="fill-opacity"><xsl:call-template name="get-attr-fill-opacity" /></xsl:variable>

        <xsl:variable name="stroke"><xsl:call-template name="get-attr-stroke" /></xsl:variable>
        <xsl:variable name="stroke-width"><xsl:call-template name="get-attr-stroke-width" /></xsl:variable>
        <xsl:variable name="stroke-linecap"><xsl:call-template name="get-attr-stroke-linecap" /></xsl:variable>
        <xsl:variable name="stroke-opacity"><xsl:call-template name="get-attr-stroke-opacity" /></xsl:variable>
        
        <xsl:variable name="paint-order-stroke-first"><xsl:call-template name="get-attr-paint-order-stroke-first" /></xsl:variable>

        <xsl:variable name="rx">
            <xsl:choose>
                <xsl:when test="$paint-order-stroke-first">
                    <xsl:value-of select="@rx + $stroke-width * 0.5" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@rx" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ry">
            <xsl:choose>
                <xsl:when test="$paint-order-stroke-first">
                    <xsl:value-of select="@ry + $stroke-width * 0.5" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@ry" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <path android:pathData="M{@cx - $rx},{@cy}c0,{-$ry * 0.5} {$rx * 0.5},{-$ry} {$rx},{-$ry}c{$rx * 0.5},0 {$rx},{$ry * 0.5} {$rx},{$ry}c0,{$ry * 0.5} {-$rx * 0.5},{$ry} {-$rx},{$ry}c{-$rx * 0.5},0 {-$rx},{-$ry * 0.5} {-$rx},{-$ry}z">
            <xsl:call-template name="set-attr-stroke">
                <xsl:with-param name="stroke" select="$stroke" />
                <xsl:with-param name="stroke-width" select="$stroke-width * (1 - 0.5 * number($paint-order-stroke-first = 'true'))" />
                <xsl:with-param name="stroke-linecap" select="$stroke-linecap" />
                <xsl:with-param name="stroke-opacity" select="$stroke-opacity" />
            </xsl:call-template>

            <xsl:call-template name="set-attr-fill">
                <xsl:with-param name="fill" select="$fill" />
                <xsl:with-param name="fill-opacity" select="$fill-opacity" />
            </xsl:call-template>
        </path>
    </xsl:template>

    <!-- <line> -->
    <xsl:template match="s:line">
        <xsl:variable name="stroke"><xsl:call-template name="get-attr-stroke" /></xsl:variable>
        <xsl:variable name="stroke-width"><xsl:call-template name="get-attr-stroke-width" /></xsl:variable>
        <xsl:variable name="stroke-linecap"><xsl:call-template name="get-attr-stroke-linecap" /></xsl:variable>
        <xsl:variable name="stroke-opacity"><xsl:call-template name="get-attr-stroke-opacity" /></xsl:variable>

        <path android:pathData="M{@x1},{@y1}L{@x2},{@y2}z">
            
            <xsl:call-template name="set-attr-stroke">
                <xsl:with-param name="stroke" select="$stroke" />
                <xsl:with-param name="stroke-width" select="$stroke-width" />
                <xsl:with-param name="stroke-linecap" select="$stroke-linecap" />
                <xsl:with-param name="stroke-opacity" select="$stroke-opacity" />
            </xsl:call-template>
        </path>
    </xsl:template>

</xsl:stylesheet>
