# Render a legend from a `gtscale_spec`

Render a legend from a `gtscale_spec`

## Usage

``` r
gtscale_render_legend(
  spec,
  data = NULL,
  output = c("contextual", "html", "latex", "typst")
)
```

## Arguments

- spec:

  A `gtscale_spec`.

- data:

  An optional `gt_tbl` used to finalize specs that infer domains or
  quantile boundaries from table data.

- output:

  Output target. Use `"html"`, `"latex"`, `"typst"`, or `"contextual"`.

## Value

Rendered legend content for the requested output target.

## Examples

``` r
spec <- gtscale_spec_quantiles(
  num,
  palette = c("#fdd49e", "#fdbb84", "#ef6548", "#990000"),
  quantiles = 4,
  title = "Quartiles"
)

gtscale_render_legend(
  spec = spec,
  data = gt::gt(gt::exibble),
  output = "latex"
)
#> [1] "\\textbf{Quartiles}\\\\\\textcolor[HTML]{FDD49E}{\\rule{1.4em}{0.9ex}}\\ 0 - 18\\quad \\textcolor[HTML]{FDBB84}{\\rule{1.4em}{0.9ex}}\\ 18 - 444\\quad \\textcolor[HTML]{EF6548}{\\rule{1.4em}{0.9ex}}\\ 444 - 391,275\\quad \\textcolor[HTML]{990000}{\\rule{1.4em}{0.9ex}}\\ 391,275 - 8,880,000"
```
