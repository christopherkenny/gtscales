# Add only a diverging color legend to a `gt` table

This is a lower-level helper for cases where table coloring is already
handled elsewhere. For the usual "color and legendize" workflow, prefer
[`gtscale_data_color_diverging()`](https://christophertkenny.com/gtscales/reference/gtscale_data_color_diverging.md).

## Usage

``` r
gtscale_color_diverging(
  data,
  column = NULL,
  palette,
  domain = NULL,
  midpoint = 0,
  breaks = NULL,
  labels = NULL,
  title = NULL,
  transform = NULL,
  oob = NULL,
  direction = "to right",
  width = "160px",
  height = "14px",
  mid_color = "#FFFFFF"
)
```

## Arguments

- data:

  A `gt_tbl` created by
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- column:

  An optional numeric column or shared set of numeric columns in the
  underlying table used to infer `domain`.

- palette:

  Two endpoint colors, three diverging colors, or a single named
  palette.

- domain:

  A numeric vector of length 2 giving the scale limits. When omitted,
  the limits are inferred from `column`.

- midpoint:

  Numeric midpoint used to anchor the diverging scale.

- breaks:

  Optional break values or a break function to display below the
  gradient.

- labels:

  An optional labeling function or a character vector for the breaks.

- title:

  Optional legend title.

- transform:

  A transformation specification understood by
  [`scales::as.transform()`](https://scales.r-lib.org/reference/new_transform.html).
  When omitted, an appropriate transform is inferred from the data.

- oob:

  Out-of-bounds handling function or shortcut. Use a function like
  [`scales::oob_squish()`](https://scales.r-lib.org/reference/oob.html)
  or a shortcut such as `"censor"`, `"squish"`, `"keep"`, or
  `"discard"`.

- direction:

  CSS gradient direction. Defaults to `"to right"`.

- width:

  Width of the legend bar.

- height:

  Height of the legend bar.

- mid_color:

  Midpoint color when `palette` supplies only two endpoint colors.

## Value

A modified [gt::gt](https://gt.rstudio.com/reference/gt.html) table.
