# Add only a binned color legend to a `gt` table

This is a lower-level helper for cases where table coloring is already
handled elsewhere. For the usual "color and legendize" workflow, prefer
[`gtscale_data_color_bins()`](https://christophertkenny.com/gtscales/reference/gtscale_data_color_bins.md).

## Usage

``` r
gtscale_color_bins(
  data,
  column = NULL,
  palette,
  domain = NULL,
  bins = NULL,
  transform = NULL,
  oob = NULL,
  right = FALSE,
  labels = NULL,
  title = NULL,
  width = "180px",
  height = "14px"
)
```

## Arguments

- data:

  A `gt_tbl` created by
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- column:

  An optional numeric, Date, POSIXt, or difftime column in the
  underlying table used to infer `domain`.

- palette:

  A vector of colors, palette endpoints, a single named palette, or a
  palette function used to color the bins.

- domain:

  A vector of length 2 giving the scale limits. When omitted, the limits
  are inferred from `column`.

- bins:

  Optional bin boundaries or a break function. When omitted, breaks are
  generated from `domain`, `column`, and `transform`.

- transform:

  A transformation specification understood by
  [`scales::as.transform()`](https://scales.r-lib.org/reference/new_transform.html).
  This is used when generating default bins or when interpreting break
  functions.

- oob:

  Out-of-bounds handling function or shortcut. Use a function like
  [`scales::oob_squish()`](https://scales.r-lib.org/reference/oob.html)
  or a shortcut such as `"censor"` or `"squish"`.

- right:

  Whether intervals should be closed on the right. The default of
  `FALSE` yields intervals like `[a, b)`.

- labels:

  An optional labeling function or a character vector for the bins. When
  a function is supplied, it is applied to the bin boundaries before
  interval labels are constructed.

- title:

  Optional legend title.

- width:

  Width of the legend.

- height:

  Height of the swatches.

## Value

A modified [gt::gt](https://gt.rstudio.com/reference/gt.html) table.

## Examples

``` r
library(gt)

exibble |>
  gt() |>
  data_color(
    columns = currency,
    method = 'bin',
    palette = c('#f7fbff', '#08306b'),
    bins = c(0, 10, 100, 1000, 10000000)
  ) |>
  gtscale_color_bins(
    column = currency,
    palette = c('#f7fbff', '#08306b'),
    bins = c(0, 10, 100, 1000, 10000000),
    title = 'Binned values'
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

Binned values

0.4 - 1010.0 - 100100.0 - 1,0001,000.0 - 65,100
