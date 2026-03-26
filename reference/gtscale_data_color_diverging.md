# Color a numeric `gt` column with a diverging scale and add a matching legend

This is the primary interface for midpoint-aware diverging scales in
`gtscales`.

## Usage

``` r
gtscale_data_color_diverging(
  data,
  column,
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
  apply_to = c("fill", "text"),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  autocolor_text = TRUE,
  contrast_algo = c("apca", "wcag"),
  autocolor_light = "#FFFFFF",
  autocolor_dark = "#000000",
  mid_color = "#FFFFFF"
)
```

## Arguments

- data:

  A `gt_tbl` created by
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- column:

  A numeric column or shared set of numeric columns to color and
  legendize.

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

- apply_to:

  Whether colors should be applied to cell fill or text.

- na_color:

  Color used for missing values.

- alpha:

  Alpha applied by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- reverse:

  Whether to reverse the color mapping.

- autocolor_text:

  Whether to automatically adjust text color.

- contrast_algo:

  Contrast algorithm passed to
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- autocolor_light:

  Light text color used by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- autocolor_dark:

  Dark text color used by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- mid_color:

  Midpoint color when `palette` supplies only two endpoint colors.

## Value

A modified [gt::gt](https://gt.rstudio.com/reference/gt.html) table.
