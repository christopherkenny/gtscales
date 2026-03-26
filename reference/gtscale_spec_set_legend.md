# Set how a `gtscales` legend should be rendered

Set how a `gtscales` legend should be rendered

## Usage

``` r
gtscale_spec_set_legend(
  spec,
  output = "contextual",
  placement = "source_note",
  layout = c("stack", "inline"),
  align = c("left", "center", "right"),
  show_border = TRUE,
  border_color = "#D0D7DE",
  border_radius = "8px",
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

  Legend placement target. `"source_note"`, `"title"`, and `"subtitle"`
  are currently implemented.

- layout:

  Whether multiple legends in the same heading area should stack
  vertically or sit inline.

- align:

  Horizontal alignment for the legend container.

- show_border:

  Whether the legend bar, bin frame, and swatches should draw borders.

- border_color:

  Border color used for legend frames and swatches.

- border_radius:

  Border radius used for HTML and Typst legend frames.

- show_na:

  Whether to include an explicit missing-value legend entry.

- na_label:

  Label to use for missing values in the legend.

- na_color:

  Optional legend swatch color for missing values. When omitted and
  `show_na = TRUE`, a neutral gray swatch is used.

## Value

A modified `gtscale_spec`.
