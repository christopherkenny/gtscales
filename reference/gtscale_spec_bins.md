# Create a binned `gtscales` spec

Create a binned `gtscales` spec

## Usage

``` r
gtscale_spec_bins(
  column,
  palette,
  bins = NULL,
  domain = NULL,
  transform = NULL,
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

  A column to target.

- palette:

  A vector of colors or palette endpoints used for the bins. A single
  named palette or palette function can also be supplied.

- bins:

  Optional bin boundaries or a break function. When omitted, breaks are
  generated from the `domain`, `column`, and `transform`.

- domain:

  Optional limits. If omitted, these can be inferred when the spec is
  applied to a `gt` table.

- transform:

  A transformation specification understood by
  [`scales::as.transform()`](https://scales.r-lib.org/reference/new_transform.html).
  This is used when generating default bins or when interpreting break
  functions.

- oob:

  Out-of-bounds handling function or shortcut. Use a function like
  [`scales::oob_squish()`](https://scales.r-lib.org/reference/oob.html)
  or a shortcut such as `"censor"` or `"squish"`.

- right:

  Whether intervals should be closed on the right. The default of
  `FALSE` yields intervals like `[a, b)`.

- labels:

  An optional labeling function or character vector for the legend. When
  omitted, labels are inferred from the bin values.

- title:

  Optional legend title.

- width:

  Width of the legend.

- height:

  Height of the swatches.

## Value

A `gtscale_spec`.
