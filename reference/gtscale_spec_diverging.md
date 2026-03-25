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
  labels = scales::label_comma(),
  title = NULL,
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

  Two endpoint colors or three diverging colors.

- domain:

  Optional numeric limits. If omitted, these can be inferred when the
  spec is applied to a `gt` table.

- midpoint:

  Numeric midpoint used to anchor the diverging scale.

- breaks:

  Optional numeric break values for the legend.

- labels:

  A labeling function or character vector for the legend.

- title:

  Optional legend title.

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
