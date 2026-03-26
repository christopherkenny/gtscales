# Set how a `gtscales` spec is applied

Set how a `gtscales` spec is applied

## Usage

``` r
gtscale_spec_set_application(
  spec,
  apply_to = c("fill", "text"),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  autocolor_text = TRUE,
  contrast_algo = c("apca", "wcag"),
  autocolor_light = "#FFFFFF",
  autocolor_dark = "#000000"
)
```

## Arguments

- spec:

  A `gtscale_spec`.

- apply_to:

  Whether colors should be applied to cell fill or text.

- na_color:

  Color used for missing values.

- alpha:

  Alpha applied by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- reverse:

  Whether to reverse the color mapping.

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

A modified `gtscale_spec`.
