# Create a quantile `gtscales` spec

Create a quantile `gtscales` spec

## Usage

``` r
gtscale_spec_quantiles(
  column,
  palette,
  quantiles = 4,
  oob = NULL,
  right = FALSE,
  labels = NULL,
  title = NULL,
  width = "180px",
  height = "14px"
)
```

## Arguments

- column:

  A numeric, Date, POSIXt, or difftime column to target.

- palette:

  A vector of colors or palette endpoints used for the quantile groups.
  A single named palette or palette function can also be supplied.

- quantiles:

  The number of quantile groups.

- oob:

  Out-of-bounds handling function or shortcut. Use a function like
  [`scales::oob_squish()`](https://scales.r-lib.org/reference/oob.html)
  or a shortcut such as `"censor"` or `"squish"`.

- right:

  Whether intervals should be closed on the right. The default of
  `FALSE` yields intervals like `[a, b)`.

- labels:

  An optional labeling function or character vector for the legend. When
  omitted, labels are inferred from the quantile break values.

- title:

  Optional legend title.

- width:

  Width of the legend.

- height:

  Height of the swatches.

## Value

A `gtscale_spec`.
