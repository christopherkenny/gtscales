# Create a continuous `gtscales` spec

Create a continuous `gtscales` spec

## Usage

``` r
gtscale_spec_continuous(
  column,
  palette = NULL,
  domain = NULL,
  breaks = NULL,
  labels = NULL,
  title = NULL,
  transform = NULL,
  oob = NULL,
  direction = "to right",
  width = "160px",
  height = "14px",
  fn = NULL
)
```

## Arguments

- column:

  A column to target.

- palette:

  A vector of colors used in the scale. A single named palette such as
  `"viridis"` or `"Blues 3"`, or a palette function, can also be
  supplied.

- domain:

  Optional numeric limits. If omitted, these can be inferred when the
  spec is applied to a `gt` table.

- breaks:

  Optional break values or a break function for the legend.

- labels:

  An optional labeling function or character vector for the legend. When
  omitted, labels are inferred from the data or transform.

- title:

  Optional legend title.

- transform:

  A transformation specification understood by
  [`scales::as.transform()`](https://scales.r-lib.org/reference/new_transform.html).
  When omitted, an appropriate identity, date, time, or timespan
  transform is inferred from the data.

- oob:

  Out-of-bounds handling function or shortcut passed through to the
  internal color mapper. Use a function like
  [`scales::oob_squish()`](https://scales.r-lib.org/reference/oob.html)
  or a shortcut such as `"censor"`, `"squish"`, `"keep"`, or
  `"discard"`.

- direction:

  CSS gradient direction. Defaults to `"to right"`.

- width:

  Width of the legend bar.

- height:

  Height of the legend bar.

- fn:

  Optional `scales` function for numeric coloring.

## Value

A `gtscale_spec`.
