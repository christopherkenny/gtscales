new_gtscale_spec <- function(
    scale_type,
    color_method,
    column = NULL,
    palette = NULL,
    domain = NULL,
    bins = NULL,
    quantiles = NULL,
    breaks = NULL,
    values = NULL,
    labels = NULL,
    title = NULL,
    fn = NULL,
    style = list(),
    application = list(),
    legend = list()) {
  structure(
    list(
      scale_type = scale_type,
      color_method = color_method,
      column = column,
      palette = palette,
      domain = domain,
      bins = bins,
      quantiles = quantiles,
      breaks = breaks,
      values = values,
      labels = labels,
      title = title,
      fn = fn,
      style = style,
      application = modifyList(
        list(
          apply_to = "fill",
          na_color = NULL,
          alpha = NULL,
          reverse = FALSE,
          autocolor_text = TRUE,
          contrast_algo = "apca",
          autocolor_light = "#FFFFFF",
          autocolor_dark = "#000000"
        ),
        application
      ),
      legend = modifyList(
        list(
          output = "html",
          placement = "source_note"
        ),
        legend
      )
    ),
    class = "gtscale_spec"
  )
}

build_continuous_spec <- function(
    data,
    column,
    palette = NULL,
    domain = NULL,
    breaks = NULL,
    labels = scales::label_comma(),
    title = NULL,
    direction = "to right",
    width = "160px",
    height = "14px",
    fn = NULL) {
  palette <- resolve_palette(palette = palette, fn = fn)
  domain <- resolve_domain(data = data, column = column, domain = domain)

  if (is.null(breaks)) {
    breaks <- default_breaks(domain)
  }

  breaks <- sort(unique(as.numeric(breaks)))
  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (length(breaks) == 0) {
    breaks <- domain
  }

  new_gtscale_spec(
    scale_type = "continuous",
    color_method = "numeric",
    column = column,
    palette = palette,
    domain = domain,
    breaks = breaks,
    labels = resolve_labels(breaks, labels),
    title = title,
    fn = fn,
    style = list(
      direction = direction,
      width = width,
      height = height
    )
  )
}

build_bins_spec <- function(
    data,
    column,
    palette,
    domain = NULL,
    bins,
    labels = NULL,
    title = NULL,
    width = "180px",
    height = "14px") {
  domain <- resolve_domain(data = data, column = column, domain = domain)

  if (missing(bins)) {
    rlang::abort("`bins` must be supplied for binned scales.")
  }

  bins <- sort(unique(as.numeric(bins)))

  if (length(bins) < 2) {
    rlang::abort("`bins` must contain at least two boundary values.")
  }

  if (bins[[1]] > domain[[1]] || bins[[length(bins)]] < domain[[2]]) {
    rlang::abort("`bins` must span the full `domain`.")
  }

  n_intervals <- length(bins) - 1

  colors <- if (length(palette) == n_intervals) {
    as.character(palette)
  } else {
    midpoints <- (bins[-1] + bins[-length(bins)]) / 2
    as.character(
      scales::col_numeric(
        palette = palette,
        domain = domain
      )(midpoints)
    )
  }

  bin_labels <- if (is.null(labels)) {
    label_fn <- scales::label_comma()
    paste0(
      label_fn(bins[-length(bins)]),
      " - ",
      label_fn(bins[-1])
    )
  } else if (is.function(labels)) {
    boundary_labels <- as.character(labels(bins))
    paste0(
      boundary_labels[-length(boundary_labels)],
      " - ",
      boundary_labels[-1]
    )
  } else {
    resolve_labels(seq_len(n_intervals), labels)
  }

  new_gtscale_spec(
    scale_type = "bins",
    color_method = "bin",
    column = column,
    palette = as.character(palette),
    domain = domain,
    bins = bins,
    values = colors,
    labels = bin_labels,
    title = title,
    style = list(
      width = width,
      height = height
    )
  )
}

build_quantiles_spec <- function(
    data,
    column,
    palette,
    quantiles = 4,
    labels = NULL,
    title = NULL,
    width = "180px",
    height = "14px") {
  breaks <- resolve_quantile_breaks(data = data, column = column, quantiles = quantiles)
  colors <- resolve_quantile_colors(palette = palette, n_intervals = length(breaks) - 1)

  build_bins_spec(
    data = data,
    column = column,
    palette = colors,
    domain = range(breaks, finite = TRUE),
    bins = breaks,
    labels = labels,
    title = title,
    width = width,
    height = height
  ) |>
    modify_gtscale_spec(
      scale_type = "quantiles",
      color_method = "quantile",
      palette = as.character(palette),
      quantiles = quantiles
    )
}

build_discrete_spec <- function(
    column,
    values,
    labels = values,
    title = NULL,
    swatch_size = "12px",
    levels = NULL,
    ordered = FALSE) {
  if (missing(values) || length(values) == 0) {
    rlang::abort("`values` must contain at least one color.")
  }

  values <- as.character(values)

  new_gtscale_spec(
    scale_type = "discrete",
    color_method = "factor",
    column = column,
    values = values,
    labels = resolve_labels(values, labels),
    title = title,
    bins = levels,
    breaks = ordered,
    style = list(
      swatch_size = swatch_size
    )
  )
}

modify_gtscale_spec <- function(spec, ...) {
  updates <- list(...)
  spec[names(updates)] <- updates
  spec
}

validate_gtscale_spec <- function(spec) {
  if (!inherits(spec, "gtscale_spec")) {
    rlang::abort("`spec` must be a `gtscale_spec`.")
  }

  spec
}

set_scale_application <- function(
    spec,
    apply_to = c("fill", "text"),
    na_color = NULL,
    alpha = NULL,
    reverse = FALSE,
    autocolor_text = TRUE,
    contrast_algo = c("apca", "wcag"),
    autocolor_light = "#FFFFFF",
    autocolor_dark = "#000000") {
  spec$application <- modifyList(
    spec$application,
    list(
      apply_to = match.arg(apply_to),
      na_color = na_color,
      alpha = alpha,
      reverse = reverse,
      autocolor_text = autocolor_text,
      contrast_algo = match.arg(contrast_algo),
      autocolor_light = autocolor_light,
      autocolor_dark = autocolor_dark
    )
  )

  spec
}

set_scale_legend <- function(spec, output = "html", placement = "source_note") {
  validate_gtscale_spec(spec)
  spec$legend <- modifyList(
    spec$legend,
    list(
      output = output,
      placement = placement
    )
  )

  spec
}

finalize_scale_spec <- function(spec, data = NULL) {
  spec <- validate_gtscale_spec(spec)

  if (!is.null(data)) {
    validate_gt_tbl(data)
  }

  if (identical(spec$scale_type, "continuous")) {
    if (is.null(data) && is.null(spec$domain)) {
      rlang::abort("Continuous specs need `data` or an explicit `domain` to be finalized.")
    }

    return(build_continuous_spec(
      data = data,
      column = spec$column,
      palette = spec$palette,
      domain = spec$domain,
      breaks = spec$breaks,
      labels = spec$labels,
      title = spec$title,
      direction = spec$style$direction,
      width = spec$style$width,
      height = spec$style$height,
      fn = spec$fn
    ) |>
      modify_gtscale_spec(
        application = spec$application,
        legend = spec$legend
      ))
  }

  if (identical(spec$scale_type, "bins")) {
    if (is.null(data) && is.null(spec$domain)) {
      rlang::abort("Binned specs need `data` or an explicit `domain` to be finalized.")
    }

    return(build_bins_spec(
      data = data,
      column = spec$column,
      palette = spec$palette,
      domain = spec$domain,
      bins = spec$bins,
      labels = spec$labels,
      title = spec$title,
      width = spec$style$width,
      height = spec$style$height
    ) |>
      modify_gtscale_spec(
        application = spec$application,
        legend = spec$legend
      ))
  }

  if (identical(spec$scale_type, "quantiles")) {
    if (is.null(data)) {
      rlang::abort("Quantile specs need `data` to be finalized.")
    }

    return(build_quantiles_spec(
      data = data,
      column = spec$column,
      palette = spec$palette,
      quantiles = spec$quantiles,
      labels = spec$labels,
      title = spec$title,
      width = spec$style$width,
      height = spec$style$height
    ) |>
      modify_gtscale_spec(
        application = spec$application,
        legend = spec$legend
      ))
  }

  if (identical(spec$scale_type, "discrete")) {
    return(build_discrete_spec(
      column = spec$column,
      values = spec$values,
      labels = spec$labels,
      title = spec$title,
      swatch_size = spec$style$swatch_size,
      levels = spec$bins,
      ordered = spec$breaks
    ) |>
      modify_gtscale_spec(
        application = spec$application,
        legend = spec$legend
      ))
  }

  rlang::abort(paste0("Unsupported scale type `", spec$scale_type, "`."))
}
