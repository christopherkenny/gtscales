new_gtscale_spec <- function(
  scale_type,
  color_method,
  column = NULL,
  palette = NULL,
  domain = NULL,
  midpoint = NULL,
  transform = 'identity',
  bins = NULL,
  quantiles = NULL,
  breaks = NULL,
  values = NULL,
  labels = NULL,
  title = NULL,
  fn = NULL,
  style = list(),
  application = list(),
  legend = list()
) {
  structure(
    list(
      scale_type = scale_type,
      color_method = color_method,
      column = column,
      palette = palette,
      domain = domain,
      midpoint = midpoint,
      transform = transform,
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
          apply_to = 'fill',
          na_color = NULL,
          alpha = NULL,
          reverse = FALSE,
          accessibility = 'none',
          autocolor_text = TRUE,
          contrast_algo = 'apca',
          autocolor_light = '#FFFFFF',
          autocolor_dark = '#000000'
        ),
        application
      ),
      legend = modifyList(
        list(
          output = 'contextual',
          placement = 'source_note',
          layout = 'stack',
          show_na = FALSE,
          na_label = 'Missing',
          na_color = NULL
        ),
        legend
      )
    ),
    class = 'gtscale_spec'
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
  transform = 'identity',
  direction = 'to right',
  width = '160px',
  height = '14px',
  fn = NULL
) {
  if (!identical(transform, 'identity') && !is.null(fn)) {
    rlang::abort('`transform` and `fn` cannot be supplied together.')
  }

  palette <- resolve_palette(palette = palette, fn = fn, n = 7)
  domain <- resolve_domain(data = data, column = column, domain = domain)
  validate_transform_domain(domain, transform)

  if (is.null(breaks)) {
    breaks <- default_breaks(domain, transform = transform)
  }

  breaks <- sort(unique(as.numeric(breaks)))
  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (length(breaks) == 0) {
    breaks <- domain
  }

  if (is.null(fn) && !identical(transform, 'identity')) {
    transformed_domain <- transform_values(domain, transform)

    fn <- function(x) {
      out <- scales::col_numeric(
        palette = palette,
        domain = transformed_domain
      )(transform_values(x, transform))
      out[is.na(x)] <- '#00000000'
      out
    }
  }

  new_gtscale_spec(
    scale_type = 'continuous',
    color_method = 'numeric',
    column = column,
    palette = palette,
    domain = domain,
    transform = transform,
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

build_diverging_spec <- function(
  data,
  column,
  palette,
  domain = NULL,
  midpoint = 0,
  breaks = NULL,
  labels = scales::label_comma(),
  title = NULL,
  transform = 'identity',
  direction = 'to right',
  width = '160px',
  height = '14px',
  mid_color = '#FFFFFF',
  reverse = FALSE,
  na_color = '#00000000'
) {
  domain <- resolve_domain(data = data, column = column, domain = domain)
  validate_transform_domain(domain, transform)

  if (!is.numeric(midpoint) || length(midpoint) != 1 || is.na(midpoint)) {
    rlang::abort('`midpoint` must be a single finite number.')
  }

  if (midpoint < domain[[1]] || midpoint > domain[[2]]) {
    rlang::abort('`midpoint` must fall inside the scale `domain`.')
  }

  palette <- resolve_palette(palette = palette, n = 3)

  if (length(palette) == 2) {
    palette <- c(palette[[1]], mid_color, palette[[2]])
  } else if (length(palette) != 3) {
    rlang::abort('`palette` must contain two endpoint colors or three diverging colors.')
  }

  if (isTRUE(reverse)) {
    palette <- rev(palette)
  }

  if (is.null(breaks)) {
    breaks <- sort(unique(c(domain[[1]], midpoint, domain[[2]])))
  } else {
    breaks <- sort(unique(as.numeric(breaks)))
  }

  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (!midpoint %in% breaks) {
    breaks <- sort(unique(c(breaks, midpoint)))
  }

  values <- scales::rescale(
    transform_values(c(domain[[1]], midpoint, domain[[2]]), transform),
    to = c(0, 1),
    from = transform_values(domain, transform)
  )
  fn <- function(x) {
    out <- scales::gradient_n_pal(colours = palette, values = values)(
      scales::rescale(
        transform_values(x, transform),
        to = c(0, 1),
        from = transform_values(domain, transform)
      )
    )
    out[is.na(x)] <- na_color
    out
  }

  new_gtscale_spec(
    scale_type = 'diverging',
    color_method = 'numeric',
    column = column,
    palette = palette,
    domain = domain,
    midpoint = midpoint,
    transform = transform,
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
  width = '180px',
  height = '14px'
) {
  domain <- resolve_domain(data = data, column = column, domain = domain)

  if (missing(bins)) {
    rlang::abort('`bins` must be supplied for binned scales.')
  }

  bins <- sort(unique(as.numeric(bins)))

  if (length(bins) < 2) {
    rlang::abort('`bins` must contain at least two boundary values.')
  }

  if (bins[[1]] > domain[[1]] || bins[[length(bins)]] < domain[[2]]) {
    rlang::abort('`bins` must span the full `domain`.')
  }

  n_intervals <- length(bins) - 1
  palette <- resolve_palette(palette = palette, n = n_intervals)

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
      ' - ',
      label_fn(bins[-1])
    )
  } else if (is.function(labels)) {
    boundary_labels <- as.character(labels(bins))
    paste0(
      boundary_labels[-length(boundary_labels)],
      ' - ',
      boundary_labels[-1]
    )
  } else {
    resolve_labels(seq_len(n_intervals), labels)
  }

  new_gtscale_spec(
    scale_type = 'bins',
    color_method = 'bin',
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
  width = '180px',
  height = '14px'
) {
  palette <- resolve_palette(palette = palette, n = quantiles)
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
      scale_type = 'quantiles',
      color_method = 'quantile',
      palette = palette,
      quantiles = quantiles
    )
}

build_discrete_spec <- function(
  column,
  values,
  labels = values,
  title = NULL,
  swatch_size = '12px',
  levels = NULL,
  ordered = FALSE
) {
  if (missing(values) || length(values) == 0) {
    rlang::abort('`values` must contain at least one color.')
  }

  values <- resolve_palette(palette = values, n = length(labels), discrete = TRUE)

  new_gtscale_spec(
    scale_type = 'discrete',
    color_method = 'factor',
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
  if (!inherits(spec, 'gtscale_spec')) {
    rlang::abort('`spec` must be a `gtscale_spec`.')
  }

  spec
}

set_scale_application <- function(
  spec,
  apply_to = c('fill', 'text'),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  accessibility = c('none', 'warn'),
  autocolor_text = TRUE,
  contrast_algo = c('apca', 'wcag'),
  autocolor_light = '#FFFFFF',
  autocolor_dark = '#000000'
) {
  spec$application <- modifyList(
    spec$application,
    list(
      apply_to = match.arg(apply_to),
      na_color = na_color,
      alpha = alpha,
      reverse = reverse,
      accessibility = match.arg(accessibility),
      autocolor_text = autocolor_text,
      contrast_algo = match.arg(contrast_algo),
      autocolor_light = autocolor_light,
      autocolor_dark = autocolor_dark
    )
  )

  spec
}

set_scale_legend <- function(
  spec,
  output = 'contextual',
  placement = 'source_note',
  layout = c('stack', 'inline'),
  show_na = FALSE,
  na_label = 'Missing',
  na_color = NULL
) {
  validate_gtscale_spec(spec)
  spec$legend <- modifyList(
    spec$legend,
    list(
      output = output,
      placement = placement,
      layout = match.arg(layout),
      show_na = show_na,
      na_label = na_label,
      na_color = na_color
    )
  )

  spec
}

finalize_spec_metadata <- function(spec) {
  if (isTRUE(spec$legend$show_na) && is.null(spec$application$na_color) && is.null(spec$legend$na_color)) {
    spec$legend$na_color <- '#D9D9D9'
  }

  warn_on_accessibility_risks(spec)
}

finalize_scale_spec <- function(spec, data = NULL) {
  spec <- validate_gtscale_spec(spec)

  if (!is.null(data)) {
    validate_gt_tbl(data)
  }

  if (identical(spec$scale_type, 'continuous')) {
    if (is.null(data) && is.null(spec$domain)) {
      rlang::abort('Continuous specs need `data` or an explicit `domain` to be finalized.')
    }

    return(build_continuous_spec(
      data = data,
      column = spec$column,
      palette = spec$palette,
      domain = spec$domain,
      breaks = spec$breaks,
      labels = spec$labels,
      title = spec$title,
      transform = spec$transform,
      direction = spec$style$direction,
      width = spec$style$width,
      height = spec$style$height,
      fn = spec$fn
    ) |>
      modify_gtscale_spec(
        application = spec$application,
        legend = spec$legend
      ) |>
      finalize_spec_metadata())
  }

  if (identical(spec$scale_type, 'diverging')) {
    if (is.null(data) && is.null(spec$domain)) {
      rlang::abort('Diverging specs need `data` or an explicit `domain` to be finalized.')
    }

    return(build_diverging_spec(
      data = data,
      column = spec$column,
      palette = spec$palette,
      domain = spec$domain,
      midpoint = spec$midpoint,
      breaks = spec$breaks,
      labels = spec$labels,
      title = spec$title,
      transform = spec$transform,
      direction = spec$style$direction,
      width = spec$style$width,
      height = spec$style$height,
      mid_color = spec$style$mid_color %||% '#FFFFFF',
      reverse = spec$application$reverse,
      na_color = spec$application$na_color %||% '#00000000'
    ) |>
      modify_gtscale_spec(
        application = spec$application,
        legend = spec$legend
      ) |>
      finalize_spec_metadata())
  }

  if (identical(spec$scale_type, 'bins')) {
    if (is.null(data) && is.null(spec$domain)) {
      rlang::abort('Binned specs need `data` or an explicit `domain` to be finalized.')
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
      ) |>
      finalize_spec_metadata())
  }

  if (identical(spec$scale_type, 'quantiles')) {
    if (is.null(data)) {
      rlang::abort('Quantile specs need `data` to be finalized.')
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
      ) |>
      finalize_spec_metadata())
  }

  if (identical(spec$scale_type, 'discrete')) {
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
      ) |>
      finalize_spec_metadata())
  }

  rlang::abort(paste0('Unsupported scale type `', spec$scale_type, '`.'))
}
