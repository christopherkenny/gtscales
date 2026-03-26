# Using gtscales

``` r
library(gt)
library(gtscales)
library(scales)
```

`gtscales` adds matched legends to color-encoded `gt` tables. The
package is built around two common needs:

1.  Color a table column and attach a matching legend in one step.
2.  Reuse a scale definition across multiple tables, placements, or
    output formats.

The package supports continuous, diverging, binned, quantile, and
discrete scales. It is designed to work naturally with `scales` helpers
such as label functions, break functions, transform specifications, and
palette functions.

## One-step helpers

For most work, the `gtscale_data_color_*()` helpers are the fastest
path. They call
[`gt::data_color()`](https://gt.rstudio.com/reference/data_color.html)
and then attach a matching legend.

``` r
exibble |>
  gt() |>
  gtscale_data_color_continuous(
    column = num,
    palette = c("#A0442C", "white", "#0063B1"),
    title = "Numeric scale"
  )
```

[TABLE]

Binned scales are useful when you want fixed intervals rather than a
smooth gradient.

``` r
exibble |>
  gt() |>
  gtscale_data_color_bins(
    column = currency,
    palette = c("#f7fbff", "#08306b"),
    bins = c(0, 10, 100, 1000, 10000, 70000),
    title = "Currency bins"
  )
```

[TABLE]

Quantile scales instead split the data into equally sized groups.

``` r
exibble |>
  gt() |>
  gtscale_data_color_quantiles(
    column = num,
    palette = c("#fdd49e", "#fdbb84", "#ef6548", "#990000"),
    quantiles = 4,
    title = "Quartiles"
  )
```

[TABLE]

Discrete legends are useful when colors encode categories rather than
ordered values.

``` r
data.frame(
  district = c("A", "B", "C", "D"),
  status = c("Safe D", "Toss-up", "Lean R", "Safe R"),
  margin = c(18, 2, -6, -21)
) |>
  gt() |>
  gtscale_data_color_discrete(
    column = status,
    values = c("#2166ac", "#f7f7f7", "#ef8a62", "#b2182b"),
    labels = c("Safe D", "Toss-up", "Lean R", "Safe R"),
    title = "Race rating"
  )
```

[TABLE]

## Legend-only helpers

Sometimes the table is already colored, or the color mapping is handled
elsewhere. In that case, the `gtscale_color_*()` helpers attach only the
legend.

``` r
exibble |>
  gt() |>
  gt::data_color(
    columns = num,
    method = "numeric",
    palette = c("#A0442C", "white", "#0063B1")
  ) |>
  gtscale_color_continuous(
    column = num,
    palette = c("#A0442C", "white", "#0063B1"),
    title = "Numeric scale"
  )
```

[TABLE]

## Scale specifications

For more control, use a `gtscale_spec`. Specs separate scale definition
from application and legend placement.

``` r
spec <- gtscale_spec_continuous(
  num,
  palette = c("#A0442C", "white", "#0063B1"),
  title = "Numeric scale"
) |>
  gtscale_spec_set_application(apply_to = "fill") |>
  gtscale_spec_set_legend(placement = "subtitle")

exibble |>
  gt() |>
  gtscale_apply_legend(spec)
```

[TABLE]

This becomes more useful when the same scale needs to be reused or when
you want to separate coloring from legend placement.

## Working with scales

`gtscales` is designed to accept the same kinds of helpers you would
already use in plots.

### Labels and breaks

You can pass label functions and break functions directly.

``` r
data.frame(share = c(0.12, 0.33, 0.57, 0.91)) |>
  gt() |>
  gtscale_data_color_bins(
    column = share,
    palette = c("#f7fbff", "#08306b"),
    bins = c(0, 0.25, 0.5, 0.75, 1),
    labels = label_percent(),
    title = "Share bins"
  )
```

[TABLE]

### Palette functions

Palette functions from `scales` can be supplied directly.

``` r
data.frame(value = c(1, 10, 100, 1000)) |>
  gt() |>
  gtscale_data_color_continuous(
    column = value,
    palette = pal_viridis(),
    transform = "log10",
    breaks = breaks_log(),
    labels = label_number(),
    title = "Log scale"
  )
```

[TABLE]

### Date and time data

Date-like columns work through the continuous and binned workflows. In
many cases, `gtscales` can infer the appropriate transform from the
column class.

``` r
data.frame(
  when = as.Date(c("2024-01-01", "2024-01-20", "2024-02-10", "2024-03-05")),
  value = c(10, 18, 35, 52)
) |>
  gt() |>
  gtscale_data_color_bins(
    column = when,
    palette = pal_viridis(),
    bins = breaks_width("1 month"),
    title = "Monthly bins"
  )
```

[TABLE]

## Legend placement

Legends can be attached as source notes, subtitles, or titles.

Source notes are the default and are the most portable across outputs.

``` r
exibble |>
  gt() |>
  gtscale_legend(
    gtscale_spec_continuous(
      num,
      palette = c("#A0442C", "white", "#0063B1"),
      title = "Numeric scale"
    ) |>
      gtscale_spec_set_legend(placement = "source_note")
  )
```

[TABLE]

When you want the legend closer to the table heading, use `subtitle` or
`title`.

``` r
exibble |>
  gt() |>
  gtscale_legend(
    gtscale_spec_quantiles(
      num,
      palette = c("#fdd49e", "#fdbb84", "#ef6548", "#990000"),
      quantiles = 4,
      title = "Quartiles"
    ) |>
      gtscale_spec_set_legend(placement = "subtitle")
  )
```

[TABLE]

``` r
exibble |>
  gt() |>
  gtscale_legend(
    gtscale_spec_continuous(
      num,
      palette = c("#A0442C", "white", "#0063B1"),
      title = "Numeric scale"
    ) |>
      gtscale_spec_set_legend(placement = "title")
  )
```

[TABLE]

If you attach multiple legends to the same heading area, use
`layout = "inline"` to place them side by side.

``` r
gt(data.frame(a = 1:3, b = 4:6)) |>
  gtscale_legend(
    gtscale_spec_continuous(a, palette = c("#f7fbff", "#08306b"), title = "A") |>
      gtscale_spec_set_legend(placement = "subtitle", layout = "inline")
  ) |>
  gtscale_legend(
    gtscale_spec_continuous(b, palette = c("#fff5eb", "#7f2704"), title = "B") |>
      gtscale_spec_set_legend(placement = "subtitle", layout = "inline")
  )
```

[TABLE]

## Output support

The most mature output path is still `gt` HTML. The package also has
validated workflows for LaTeX/PDF and Typst through the example files in
`inst/examples`.

Current boundaries:

- HTML through `gt` is supported.
- LaTeX and Quarto PDF are supported through contextual legends.
- Typst is supported through the render-only workflow and example files.
- Word is not currently supported.

That means the safest general recommendation is to use source-note
placement when you want the most consistent behavior across outputs, and
then use heading placement when you control the rendering path more
tightly.
