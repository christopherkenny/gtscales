# Set how a `gtscales` legend should be rendered

Set how a `gtscales` legend should be rendered

## Usage

``` r
gtscale_spec_set_legend(
  spec,
  output = "contextual",
  placement = "source_note",
  layout = c("stack", "inline"),
  show_na = FALSE,
  na_label = "Missing",
  na_color = NULL
)
```

## Arguments

- spec:

  A `gtscale_spec`.

- output:

  Output target for the legend. Use `"contextual"` for `gt`-managed
  HTML/LaTeX source notes, or choose a specific output like `"html"`,
  `"latex"`, or `"typst"`.

- placement:

  Legend placement target. `"source_note"` and `"subtitle"` are
  currently implemented.

- layout:

  Whether multiple legends in the same heading area should stack
  vertically or sit inline.

- show_na:

  Whether to include an explicit missing-value legend entry.

- na_label:

  Label to use for missing values in the legend.

- na_color:

  Optional legend swatch color for missing values. When omitted and
  `show_na = TRUE`, a neutral gray swatch is used.

## Value

A modified `gtscale_spec`.
