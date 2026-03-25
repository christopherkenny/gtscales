# Add only a continuous color legend to a `gt` table

This is a lower-level helper for cases where table coloring is already
handled elsewhere. For the usual "color and legendize" workflow, prefer
[`gtscale_data_color_continuous()`](https://christophertkenny.com/gtscales/reference/gtscale_data_color_continuous.md).

## Usage

``` r
gtscale_color_continuous(
  data,
  column = NULL,
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

- data:

  A `gt_tbl` created by
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- column:

  An optional numeric column in the underlying table used to infer
  `domain`.

- palette:

  A vector of colors used in the legend gradient.

- domain:

  A numeric vector of length 2 giving the scale limits. When omitted,
  the limits are inferred from `column`.

- breaks:

  Optional numeric break values to display below the gradient.

- labels:

  A labeling function or a character vector for the breaks.

- title:

  Optional legend title.

- direction:

  CSS gradient direction. Defaults to `"to right"`.

- width:

  Width of the legend bar.

- height:

  Height of the legend bar.

- fn:

  Backward-compatible fallback for passing a `scales` palette function.
  `palette` is preferred.

## Value

A modified [gt::gt](https://gt.rstudio.com/reference/gt.html) table.

## Examples

``` r
library(gt)

exibble |>
  gt() |>
  data_color(
    columns = num,
    method = 'numeric',
    palette = c('#A0442C', 'white', '#0063B1')
  ) |>
  gtscale_color_continuous(
    column = num,
    palette = c('#A0442C', 'white', '#0063B1'),
    title = 'Value'
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

Value

08,880,000
