# svg2vd

Convert svg files to Android VectorDrawable (xml).

Lean, java-free alternative to the 'Import SVG' feature in AndroidStudio.

## About

This repository contains an XSLT stylesheet, that can be used to convert svg files to Android's xml-based Vector Drawable format.

It was inspired by the work of [Rob Gilbert](https://github.com/fox015/svg2vectordrawable).

## Usage

```bash
> xsltproc [-o output.xml] convert.xsl [input1.svg ...]
```

On Ubuntu for example, the `xsltproc` command is available via apt.

Of course, any other XSLT processor may be used just as well. The stylesheet does not require any XSLT 2.0 features.

## Features

Currently supports:

* Most common shapes
  * Paths
  * Polygons
  * Rectangles
  * Circles
  * Lines
  * SVG Groups (group name and transform)
* Most common attributes
  * Fill color
  * Stroke color / width / linecaps
  * Draw order
  * Attribute inheritance
* Gradients
  * Linear
* Colors and transparency
* Different SVG formats
  * "Regular" SVG
  * Inkscape SVG

## Known issues

- Some svg features may not be supported (yet)

* In a very rare case with `<polygon>` elements, the path-data may not be converted correctly
  * This results in the 'out-breaking' of single path-points
  * To me this happened only once, with a huge 2.5MB test svg file (exported from Adobe Illustrator)
