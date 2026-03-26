# Create a discrete `gtscales` spec

Create a discrete `gtscales` spec

## Usage

``` r
gtscale_spec_discrete(
  column,
  values,
  labels = values,
  title = NULL,
  swatch_size = "12px",
  levels = NULL,
  ordered = FALSE
)
```

## Arguments

- column:

  A column to target.

- values:

  A vector of color values or a single named discrete palette.

- labels:

  Labels for each legend swatch. Defaults to `values`.

- title:

  Optional legend title.

- swatch_size:

  Size of each discrete color swatch.

- levels:

  Optional factor levels.

- ordered:

  Whether the scale should be treated as ordered.

## Value

A `gtscale_spec`.
