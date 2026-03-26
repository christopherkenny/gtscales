# gtscales 0.0.1

* Initial development release of `gtscales`, focused on matched legends for color-encoded `gt` tables.
* `gtscale_data_color_*()` and `gtscale_color_*()` support continuous, binned, quantile, discrete, and diverging or midpoint-aware scales.
* `gtscale_spec_*()`, `gtscale_apply()`, `gtscale_legend()`, and `gtscale_apply_legend()` support reusable scale definitions, shared scales across multiple columns, and custom legend workflows.
* Named palette shortcuts are recognized automatically from `grDevices::hcl.colors()` and `grDevices::palette.colors()`, including palettes such as `"viridis"`, `"Blues 3"`, and `"Okabe-Ito"`.
* Legends can be placed in source notes or subtitles and can include explicit missing-value entries.
