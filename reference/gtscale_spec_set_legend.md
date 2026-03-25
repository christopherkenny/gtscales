# Set how a `gtscales` legend should be rendered

Set how a `gtscales` legend should be rendered

## Usage

``` r
gtscale_spec_set_legend(spec, output = "html", placement = "source_note")
```

## Arguments

- spec:

  A `gtscale_spec`.

- output:

  Output target for the legend. Use `"contextual"` for `gt`-managed
  HTML/LaTeX source notes, or choose a specific output like `"html"`,
  `"latex"`, or `"typst"`.

- placement:

  Legend placement target. Currently only `"source_note"` is
  implemented.

## Value

A modified `gtscale_spec`.
