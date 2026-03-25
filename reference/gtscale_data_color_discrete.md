# Color a categorical `gt` column and add a matching discrete legend

This is the primary interface for discrete scales in `gtscales`.

## Usage

``` r
gtscale_data_color_discrete(
  data,
  column,
  values,
  labels = values,
  title = NULL,
  swatch_size = "12px",
  levels = NULL,
  ordered = FALSE,
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  apply_to = c("fill", "text"),
  autocolor_text = TRUE,
  contrast_algo = c("apca", "wcag"),
  autocolor_light = "#FFFFFF",
  autocolor_dark = "#000000"
)
```

## Arguments

- data:

  A `gt_tbl` created by
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- column:

  A categorical column to color and legendize.

- values:

  A vector of color values used in the table and legend.

- labels:

  Labels for each color swatch. Defaults to `values`.

- title:

  Optional legend title.

- swatch_size:

  Size of each discrete color swatch.

- levels:

  Optional factor levels passed to
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- ordered:

  Whether the scale should be treated as ordered.

- na_color:

  Color used for missing values.

- alpha:

  Alpha applied by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- reverse:

  Whether to reverse the color mapping.

- apply_to:

  Whether colors should be applied to cell fill or text.

- autocolor_text:

  Whether to automatically adjust text color.

- contrast_algo:

  Contrast algorithm passed to
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- autocolor_light:

  Light text color used by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- autocolor_dark:

  Dark text color used by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

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
  gtscale_data_color_discrete(
    column = category,
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
