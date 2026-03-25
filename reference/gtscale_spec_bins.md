# Create a binned `gtscales` spec

Create a binned `gtscales` spec

## Usage

``` r
gtscale_spec_bins(
  column,
  palette,
  bins,
  domain = NULL,
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

  A vector of colors or palette endpoints used for the bins.

- bins:

  A numeric vector of bin boundaries.

- domain:

  Optional numeric limits. If omitted, these can be inferred when the
  spec is applied to a `gt` table.

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
