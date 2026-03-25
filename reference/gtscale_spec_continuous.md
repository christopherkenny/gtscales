# Create a continuous `gtscales` spec

Create a continuous `gtscales` spec

## Usage

``` r
gtscale_spec_continuous(
  column,
  palette = NULL,
  domain = NULL,
  breaks = NULL,
  labels = scales::label_comma(),
  title = NULL,
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

  A vector of colors used in the scale.

- domain:

  Optional numeric limits. If omitted, these can be inferred when the
  spec is applied to a `gt` table.

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

- fn:

  Optional `scales` function for numeric coloring.

## Value

A `gtscale_spec`.
