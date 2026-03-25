# gtscales (0.0.0.9000)

* Initial development release of `gtscales`, with matched legends for color-encoded `gt` tables.
* Scale support includes continuous, binned, quantile, discrete, and diverging or midpoint-aware palettes.
* The package includes both one-step helpers that pair `gt::data_color()` with a matching legend and lower-level legend-only helpers for custom coloring workflows.
* Reusable scale specification workflows are available through `gtscale_spec_*()`, `gtscale_apply()`, `gtscale_legend()`, and `gtscale_apply_legend()`.
* Shared scales can span multiple columns while keeping a single legend.
* Validated rendering workflows currently cover HTML, LaTeX or PDF, and Typst, including contextual legends for `gt` output and standalone Typst legend rendering.
* Legends can be placed in source notes or subtitles.
* Missing-value legend entries and optional accessibility warnings help with clearer defaults.
* Automated tests cover core behavior, internal scale workflows, LaTeX export, and visual regressions.
