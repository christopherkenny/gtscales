# Create a diverging `gtscales` spec

Create a diverging `gtscales` spec

## Usage

``` r
gtscale_spec_diverging(
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
  mid_color = "#FFFFFF"
)
```

## Arguments

- column:

  A column or shared set of columns to target.

- palette:

  Two endpoint colors or three diverging colors. A single named palette
  such as `"Blue-Red 3"` or `"viridis"`, or a palette function, can also
  be supplied.

- domain:

  Optional numeric limits. If omitted, these can be inferred when the
  spec is applied to a `gt` table.

- midpoint:

  Numeric midpoint used to anchor the diverging scale.

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

- mid_color:

  Midpoint color when `palette` supplies only two endpoint colors.

## Value

A `gtscale_spec`.
