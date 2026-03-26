# Add only a discrete color legend to a `gt` table

This is a lower-level helper for cases where table coloring is already
handled elsewhere. For the usual "color and legendize" workflow, prefer
[`gtscale_data_color_discrete()`](https://christophertkenny.com/gtscales/reference/gtscale_data_color_discrete.md).

## Usage

``` r
gtscale_color_discrete(
  data,
  values,
  labels = values,
  title = NULL,
  swatch_size = "12px"
)
```

## Arguments

- data:

  A `gt_tbl` created by
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- values:

  A vector of color values or a single named discrete palette.

- labels:

  Labels for each color swatch. Defaults to `values`.

- title:

  Optional legend title.

- swatch_size:

  Size of each discrete color swatch.

## Value

A modified [gt::gt](https://gt.rstudio.com/reference/gt.html) table.

## Examples

``` r
library(gt)

data.frame(
  category = c('Low', 'Medium', 'High'),
  value = c(12, 47, 83)
) |>
  gt() |>
  data_color(
    columns = category,
    method = 'factor',
    palette = c('#1b9e77', '#d95f02', '#7570b3')
  ) |>
  gtscale_color_discrete(
    values = c('#1b9e77', '#d95f02', '#7570b3'),
    labels = c('Low', 'Medium', 'High'),
    title = 'Category'
  )


  

category
```

value

Low

12

Medium

47

High

83

Category

LowMediumHigh
