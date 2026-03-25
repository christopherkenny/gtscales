# Color a numeric `gt` column and add a matching quantile legend

This is the primary interface for quantile scales in `gtscales`.

## Usage

``` r
gtscale_data_color_quantiles(
  data,
  column,
  palette,
  quantiles = 4,
  labels = NULL,
  title = NULL,
  width = "180px",
  height = "14px",
  apply_to = c("fill", "text"),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  accessibility = c("none", "warn"),
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

  A numeric column to color and legendize.

- palette:

  A vector of colors or palette endpoints used for the quantile groups.

- quantiles:

  The number of quantile groups.

- labels:

  A labeling function or a character vector for the quantile ranges.
  When a function is supplied, it is applied to the quantile boundaries
  before interval labels are constructed.

- title:

  Optional legend title.

- width:

  Width of the legend.

- height:

  Height of the swatches.

- apply_to:

  Whether colors should be applied to cell fill or text.

- na_color:

  Color used for missing values.

- alpha:

  Alpha applied by
  [`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html).

- reverse:

  Whether to reverse the color mapping.

- accessibility:

  Whether to warn about low-contrast adjacent legend colors.

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

exibble |>
  gt() |>
  gtscale_data_color_quantiles(
    column = num,
    palette = c('#fdd49e', '#fdbb84', '#ef6548', '#990000'),
    quantiles = 4,
    title = 'Quantile bins'
  )


  

num
```

char

fctr

date

time

datetime

currency

row

group

1.111e-01

apricot

one

2015-01-15

13:35

2018-01-01 02:22

49.950

row_1

grp_a

2.222e+00

banana

two

2015-02-15

14:40

2018-02-02 14:33

17.950

row_2

grp_a

3.333e+01

coconut

three

2015-03-15

15:45

2018-03-03 03:44

1.390

row_3

grp_a

4.444e+02

durian

four

2015-04-15

16:50

2018-04-04 15:55

65100.000

row_4

grp_a

5.550e+03

NA

five

2015-05-15

17:55

2018-05-05 04:00

1325.810

row_5

grp_b

NA

fig

six

2015-06-15

NA

2018-06-06 16:11

13.255

row_6

grp_b

7.770e+05

grapefruit

seven

NA

19:10

2018-07-07 05:22

NA

row_7

grp_b

8.880e+06

honeydew

eight

2015-08-15

20:20

NA

0.440

row_8

grp_b

Quantile bins

0 - 1818 - 444444 - 391,275391,275 - 8,880,000
