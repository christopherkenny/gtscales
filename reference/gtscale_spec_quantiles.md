# Create a quantile `gtscales` spec

Create a quantile `gtscales` spec

## Usage

``` r
gtscale_spec_quantiles(
  column,
  palette,
  quantiles = 4,
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

  A vector of colors or palette endpoints used for the quantile groups.
  A single named palette can also be supplied.

- quantiles:

  The number of quantile groups.

- labels:

  A labeling function or character vector for the legend.

- title:

  Optional legend title.

- width:

  Width of the legend.

- height:

  Height of the swatches.

## Value

A `gtscale_spec`.
