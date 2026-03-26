new_gtscale_spec <- function(
  scale_type,
  color_method,
  column = NULL,
  palette = NULL,
  domain = NULL,
  midpoint = NULL,
  transform = 'identity',
  oob = NULL,
  bins = NULL,
  quantiles = NULL,
  right = NULL,
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
      oob = oob,
      bins = bins,
      quantiles = quantiles,
      right = right,
      breaks = breaks,
      values = values,
      labels = labels,
      title = title,
      fn = fn,
      style = style,
      application = utils::modifyList(
        list(
          apply_to = 'fill',
          na_color = NULL,
          alpha = NULL,
          reverse = FALSE,
          autocolor_text = TRUE,
          contrast_algo = 'apca',
          autocolor_light = '#FFFFFF',
          autocolor_dark = '#000000'
        ),
        application
      ),
      legend = utils::modifyList(
        list(
          output = 'contextual',
          placement = 'source_note',
          layout = 'stack',
          align = 'left',
          show_border = TRUE,
          border_color = '#D0D7DE',
          border_radius = '8px',
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
  labels = NULL,
  title = NULL,
  transform = NULL,
  oob = NULL,
  direction = 'to right',
  width = '160px',
  height = '14px',
  fn = NULL
) {
  if (!is.null(transform) && !is.null(fn)) {
    rlang::abort('`transform` and `fn` cannot be supplied together.')
  }

  palette <- resolve_palette(palette = palette, fn = fn, n = 7)
  domain <- resolve_domain(data = data, column = column, domain = domain)
  transform <- validate_transform_domain(domain, transform)
  oob <- resolve_oob(oob, default = 'censor')

  breaks <- resolve_breaks(domain = domain, breaks = breaks, transform = transform)

  if (length(breaks) == 0) {
    breaks <- domain
  }

  if (is.null(fn)) {
    transformed_domain <- transform_values(domain, transform)

    fn <- function(x) {
      transformed_x <- transform_values(x, transform)
      transformed_x <- apply_oob(
        transformed_x,
        oob = oob,
        range = transformed_domain,
        scale_type = 'continuous'
      )
      out <- scales::col_numeric(
        palette = palette,
        domain = transformed_domain
      )(transformed_x)
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
    oob = oob,
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
  labels = NULL,
  title = NULL,
  transform = NULL,
  oob = NULL,
  direction = 'to right',
  width = '160px',
  height = '14px',
  mid_color = '#FFFFFF',
  reverse = FALSE,
  na_color = '#00000000'
) {
  domain <- resolve_domain(data = data, column = column, domain = domain)
  transform <- validate_transform_domain(domain, transform)
  oob <- resolve_oob(oob, default = 'censor')

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

  breaks <- resolve_breaks(domain = domain, breaks = breaks, transform = transform)

  if (!midpoint %in% breaks) {
    breaks <- c(breaks, midpoint)
    breaks <- breaks[order(as.numeric(breaks))]
  }

  values <- scales::rescale(
    transform_values(c(domain[[1]], midpoint, domain[[2]]), transform),
    to = c(0, 1),
    from = transform_values(domain, transform)
  )
  fn <- function(x) {
    transformed_x <- transform_values(x, transform)
    transformed_x <- apply_oob(
      transformed_x,
      oob = oob,
      range = transform_values(domain, transform),
      scale_type = 'diverging'
    )
    out <- scales::gradient_n_pal(colours = palette, values = values)(
      scales::rescale(
        transformed_x,
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
    oob = oob,
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
  bins = NULL,
  transform = NULL,
  oob = NULL,
  right = FALSE,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px',
  reverse = FALSE,
  na_color = '#00000000'
) {
  domain <- resolve_domain(data = data, column = column, domain = domain)
  oob <- resolve_oob(oob, default = 'squish')
  transform <- validate_transform_domain(domain, transform)
  bins <- resolve_breaks(domain = domain, breaks = bins, transform = transform)
  bins <- bins[order(as.numeric(bins))]

  if (bins[[1]] > domain[[1]]) {
    bins <- c(domain[[1]], bins)
  }

  if (bins[[length(bins)]] < domain[[2]]) {
    bins <- c(bins, domain[[2]])
  }

  if (length(bins) < 2) {
    rlang::abort('`bins` must contain at least two boundary values.')
  }

  n_intervals <- length(bins) - 1
  palette <- resolve_palette(palette = palette, n = n_intervals)

  colors <- if (length(palette) == n_intervals) {
    as.character(palette)
  } else {
    transformed_domain <- transform_values(domain, transform)
    transformed_bins <- transform_values(bins, transform)
    midpoints <- (transformed_bins[-1] + transformed_bins[-length(transformed_bins)]) / 2
    as.character(
      scales::col_numeric(
        palette = palette,
        domain = transformed_domain
      )(midpoints)
    )
  }

  bin_labels <- if (is.null(labels)) {
    paste0(
      default_labels(bins[-length(bins)]),
      ' - ',
      default_labels(bins[-1])
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

  fn <- function(x) {
    x_num <- as.numeric(x)
    x_num <- apply_oob(
      x_num,
      oob = oob,
      range = as.numeric(domain),
      scale_type = 'binned'
    )

    if (isTRUE(reverse)) {
      palette_values <- rev(colors)
    } else {
      palette_values <- colors
    }

    bin_ids <- cut(
      x_num,
      breaks = as.numeric(bins),
      labels = FALSE,
      include.lowest = TRUE,
      right = right
    )
    out <- unname(palette_values[bin_ids])
    out[is.na(x)] <- na_color
    out[is.na(bin_ids)] <- na_color
    out
  }

  new_gtscale_spec(
    scale_type = 'bins',
    color_method = 'bin',
    column = column,
    palette = as.character(palette),
    domain = domain,
    transform = transform,
    oob = oob,
    bins = bins,
    right = right,
    values = colors,
    labels = bin_labels,
    title = title,
    fn = fn,
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
  oob = NULL,
  right = FALSE,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px',
  reverse = FALSE,
  na_color = '#00000000'
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
    oob = oob,
    right = right,
    labels = labels,
    title = title,
    width = width,
    height = height,
    reverse = reverse,
    na_color = na_color
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
  autocolor_text = TRUE,
  contrast_algo = c('apca', 'wcag'),
  autocolor_light = '#FFFFFF',
  autocolor_dark = '#000000'
) {
  spec$application <- utils::modifyList(
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

set_scale_legend <- function(
  spec,
  output = 'contextual',
  placement = 'source_note',
  layout = c('stack', 'inline'),
  align = c('left', 'center', 'right'),
  show_border = TRUE,
  border_color = '#D0D7DE',
  border_radius = '8px',
  show_na = FALSE,
  na_label = 'Missing',
  na_color = NULL
) {
  validate_gtscale_spec(spec)
  spec$legend <- utils::modifyList(
    spec$legend,
    list(
      output = output,
      placement = placement,
      layout = match.arg(layout),
      align = match.arg(align),
      show_border = show_border,
      border_color = border_color,
      border_radius = border_radius,
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

  spec
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
      oob = spec$oob,
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
      oob = spec$oob,
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
      transform = spec$transform,
      oob = spec$oob,
      right = spec$right %||% FALSE,
      labels = spec$labels,
      title = spec$title,
      width = spec$style$width,
      height = spec$style$height,
      reverse = spec$application$reverse,
      na_color = spec$application$na_color %||% '#00000000'
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
      oob = spec$oob,
      right = spec$right %||% FALSE,
      labels = spec$labels,
      title = spec$title,
      width = spec$style$width,
      height = spec$style$height,
      reverse = spec$application$reverse,
      na_color = spec$application$na_color %||% '#00000000'
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
