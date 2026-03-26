# Changelog

## gtscales 0.0.1

- Initial development release of `gtscales`, focused on matched legends
  for color-encoded `gt` tables.
- `gtscale_data_color_*()` and `gtscale_color_*()` support continuous,
  binned, quantile, discrete, and diverging or midpoint-aware scales.
- `gtscale_spec_*()`,
  [`gtscale_apply()`](https://christophertkenny.com/gtscales/reference/gtscale_apply.md),
  [`gtscale_legend()`](https://christophertkenny.com/gtscales/reference/gtscale_legend.md),
  and
  [`gtscale_apply_legend()`](https://christophertkenny.com/gtscales/reference/gtscale_apply_legend.md)
  support reusable scale definitions, shared scales across multiple
  columns, and custom legend workflows.
- Named palette shortcuts are recognized automatically from
  [`grDevices::hcl.colors()`](https://rdrr.io/r/grDevices/palettes.html)
  and
  [`grDevices::palette.colors()`](https://rdrr.io/r/grDevices/palette.html),
  including palettes such as `"viridis"`, `"Blues 3"`, and
  `"Okabe-Ito"`.
- Legends can be placed in source notes or subtitles and can include
  explicit missing-value entries.
