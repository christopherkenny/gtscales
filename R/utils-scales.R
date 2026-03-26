resolve_domain <- function(data, column, domain = NULL) {
  if (!is.null(domain)) {
    if (length(domain) != 2) {
      rlang::abort('`domain` must be a vector of length 2.')
    }

    domain <- domain[order(as.numeric(domain))]

    if (anyNA(domain)) {
      rlang::abort('`domain` cannot contain missing values.')
    }

    return(domain)
  }

  column_data <- resolve_column_data(data, column)

  if (is.null(column_data)) {
    rlang::abort('Supply `domain` or provide a compatible `column` to infer the range.')
  }

  if (!is.numeric(column_data) && !inherits(column_data, c('Date', 'POSIXt', 'difftime'))) {
    rlang::abort(
      paste(
        '`column` must be numeric, Date, POSIXt, or difftime when `domain`',
        'is inferred from the `gt` data.'
      )
    )
  }

  domain <- range(column_data, na.rm = TRUE, finite = TRUE)

  if (any(!is.finite(domain))) {
    rlang::abort('Could not infer a finite numeric domain from `column`.')
  }

  domain
}

default_transform_for_domain <- function(domain) {
  if (inherits(domain, 'Date')) {
    return(scales::transform_date())
  }

  if (inherits(domain, 'POSIXt')) {
    return(scales::transform_time())
  }

  if (inherits(domain, 'difftime')) {
    return(scales::transform_timespan())
  }

  scales::transform_identity()
}

resolve_transform <- function(transform = NULL, domain = NULL) {
  if (is.null(transform)) {
    return(default_transform_for_domain(domain))
  }

  scales::as.transform(transform)
}

validate_transform_domain <- function(domain, transform) {
  transform <- resolve_transform(transform, domain = domain)
  transformed <- suppressWarnings(transform$transform(domain))
  original_domain <- as.numeric(domain)

  if (anyNA(transformed) || any(!is.finite(transformed))) {
    rlang::abort(
      paste0(
        'The `',
        transform$name,
        '` transform cannot be applied to the supplied `domain`.'
      )
    )
  }

  if (any(original_domain < transform$domain[[1]] | original_domain > transform$domain[[2]])) {
    rlang::abort(
      paste0(
        'The supplied `domain` falls outside the allowed range of the `',
        transform$name,
        '` transform.'
      )
    )
  }

  transform
}

transform_values <- function(values, transform) {
  transform_spec <- resolve_transform(transform, domain = values)
  transform_spec$transform(values)
}

inverse_transform_values <- function(values, transform) {
  transform_spec <- resolve_transform(transform)
  transform_spec$inverse(values)
}

rescale_break_positions <- function(breaks, domain, transform = 'identity', to = c(0, 100)) {
  transform <- validate_transform_domain(domain, transform)

  transformed_domain <- transform_values(domain, transform)
  transformed_breaks <- transform_values(breaks, transform)

  scales::rescale(transformed_breaks, to = to, from = transformed_domain)
}

resolve_na_legend_color <- function(spec, default = '#D9D9D9') {
  spec$legend$na_color %||% spec$application$na_color %||% default
}

invoke_palette_function <- function(palette, n, discrete = FALSE) {
  if (is.null(n) || length(n) != 1 || is.na(n) || n < 1) {
    rlang::abort('Palette functions need a positive `n` to generate legend colors.')
  }

  n <- as.integer(n)
  positions <- seq(0, 1, length.out = n)
  attempts <- if (isTRUE(discrete)) {
    list(
      function() palette(n),
      function() palette(seq_len(n)),
      function() palette(positions)
    )
  } else {
    list(
      function() palette(positions),
      function() palette(n),
      function() palette(seq_len(n))
    )
  }

  for (attempt in attempts) {
    values <- tryCatch(attempt(), error = function(...) NULL)

    if (!is.null(values) && length(values) == n) {
      return(as.character(values))
    }
  }

  rlang::abort(
    paste(
      'Could not generate colors from `palette`.',
      'Supply a vector of colors or a palette function compatible with `scales`.'
    )
  )
}

resolve_palette_name <- function(palette_name, n, discrete = FALSE) {
  palette_pals <- grDevices::palette.pals()
  hcl_pals <- grDevices::hcl.pals()

  palette_match <- palette_pals[tolower(palette_pals) == tolower(palette_name)]
  hcl_match <- hcl_pals[tolower(hcl_pals) == tolower(palette_name)]

  if (discrete && length(palette_match) > 0) {
    return(unname(grDevices::palette.colors(n, palette = palette_match[[1]], recycle = FALSE)))
  }

  if (length(hcl_match) > 0) {
    return(unname(grDevices::hcl.colors(n, palette = hcl_match[[1]])))
  }

  if (!discrete && length(palette_match) > 0) {
    return(unname(grDevices::palette.colors(n, palette = palette_match[[1]], recycle = TRUE)))
  }

  NULL
}

resolve_palette <- function(palette = NULL, fn = NULL, n = NULL, discrete = FALSE) {
  if (!is.null(palette)) {
    if (is.function(palette)) {
      return(invoke_palette_function(palette = palette, n = n, discrete = discrete))
    }

    if (is.character(palette) && length(palette) == 1) {
      palette_from_name <- resolve_palette_name(
        palette_name = palette,
        n = n %||% if (discrete) 8 else 7,
        discrete = discrete
      )

      if (!is.null(palette_from_name)) {
        return(as.character(palette_from_name))
      }
    }

    return(as.character(palette))
  }

  if (is.null(fn)) {
    rlang::abort('Supply either `palette` or `fn`.')
  }

  if (!is.function(fn)) {
    rlang::abort('`fn` must be a function, typically from `scales`.')
  }

  fn_env <- rlang::get_env(fn)
  env_names <- rlang::env_names(fn_env)

  if (!'palette' %in% env_names) {
    rlang::abort('Could not discover a `palette` value in `fn`; supply `palette` directly.')
  }

  as.character(rlang::env_get(fn_env, 'palette'))
}

resolve_labels <- function(values, labels) {
  if (is.null(labels)) {
    return(default_labels(values))
  }

  if (is.function(labels)) {
    return(as.character(labels(values)))
  }

  if (length(labels) != length(values)) {
    rlang::abort('`labels` must have the same length as the values being labeled.')
  }

  as.character(labels)
}

default_labels <- function(values) {
  if (inherits(values, 'Date')) {
    return(as.character(scales::label_date()(values)))
  }

  if (inherits(values, 'POSIXt')) {
    return(as.character(scales::label_date_short()(values)))
  }

  if (inherits(values, 'difftime')) {
    return(as.character(scales::label_timespan()(values)))
  }

  as.character(scales::label_comma()(values))
}

default_breaks <- function(domain, n = 5, transform = NULL) {
  transform <- validate_transform_domain(domain, transform)
  breaks <- transform$breaks(domain)
  breaks <- breaks[!is.na(breaks)]
  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (length(breaks) < 2) {
    breaks <- domain
  }

  breaks[order(as.numeric(breaks))]
}

resolve_breaks <- function(domain, breaks = NULL, transform = NULL) {
  transform <- validate_transform_domain(domain, transform)

  if (is.null(breaks)) {
    return(default_breaks(domain = domain, transform = transform))
  }

  if (is.function(breaks)) {
    breaks <- breaks(domain)
  }

  breaks <- breaks[!is.na(breaks)]
  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (length(breaks) < 1) {
    breaks <- domain
  }

  breaks[order(as.numeric(breaks))]
}

resolve_oob <- function(oob = NULL, default = c('censor', 'squish')) {
  default <- match.arg(default)

  if (is.null(oob)) {
    return(
      switch(default,
        censor = scales::oob_censor,
        squish = scales::oob_squish
      )
    )
  }

  if (is.character(oob) && length(oob) == 1) {
    oob <- switch(oob,
      censor = scales::oob_censor,
      squish = scales::oob_squish,
      keep = scales::oob_keep,
      discard = scales::oob_discard,
      rlang::abort('Unknown `oob` specification.')
    )
  }

  if (!is.function(oob)) {
    rlang::abort('`oob` must be a function or one of "censor", "squish", "keep", or "discard".')
  }

  oob
}

apply_oob <- function(values, oob, range, scale_type = 'scale') {
  out <- oob(values, range = range)

  if (length(out) != length(values)) {
    rlang::abort(
      paste0(
        'Out-of-bounds handlers for table ',
        scale_type,
        ' scales must preserve input length. ',
        'Functions like `scales::oob_discard()` are not supported here.'
      )
    )
  }

  out
}

resolve_quantile_breaks <- function(data, column, quantiles) {
  column_data <- resolve_column_data(data, column)

  if (is.null(column_data) || (!is.numeric(column_data) && !inherits(column_data, c('Date', 'POSIXt', 'difftime')))) {
    rlang::abort('`column` must be numeric, Date, POSIXt, or difftime for quantile scales.')
  }

  if (!is.numeric(quantiles) || length(quantiles) != 1 || is.na(quantiles) || quantiles < 1) {
    rlang::abort('`quantiles` must be a single positive number.')
  }

  probs <- seq(0, 1, length.out = quantiles + 1)

  if (inherits(column_data, 'Date')) {
    return(as.Date(
      stats::quantile(as.numeric(column_data), probs = probs, na.rm = TRUE, names = FALSE),
      origin = '1970-01-01'
    ))
  }

  if (inherits(column_data, 'POSIXt')) {
    tz <- attr(column_data, 'tzone', exact = TRUE) %||% 'UTC'
    return(as.POSIXct(
      stats::quantile(as.numeric(column_data), probs = probs, na.rm = TRUE, names = FALSE),
      origin = '1970-01-01',
      tz = tz
    ))
  }

  if (inherits(column_data, 'difftime')) {
    units <- attr(column_data, 'units', exact = TRUE) %||% 'secs'
    return(as.difftime(
      stats::quantile(as.numeric(column_data, units = units), probs = probs, na.rm = TRUE, names = FALSE),
      units = units
    ))
  }

  stats::quantile(column_data, probs = probs, na.rm = TRUE, names = FALSE)
}

resolve_quantile_colors <- function(palette, n_intervals) {
  palette <- resolve_palette(palette = palette, n = n_intervals)

  if (length(palette) == n_intervals) {
    return(as.character(palette))
  }

  as.character(
    scales::gradient_n_pal(palette)(
      seq(0, 1, length.out = n_intervals)
    )
  )
}

normalize_color_hex <- function(color) {
  rgb <- grDevices::col2rgb(color)
  vapply(
    seq_len(ncol(rgb)),
    function(i) {
      paste0(
        '#',
        toupper(sprintf('%02X%02X%02X', rgb[1, i], rgb[2, i], rgb[3, i]))
      )
    },
    character(1)
  )
}

describe_color <- function(color) {
  hex <- normalize_color_hex(color)
  named_colors <- grDevices::colors()
  named_rgb <- grDevices::col2rgb(named_colors)
  target_rgb <- grDevices::col2rgb(hex)

  nearest_name <- vapply(
    seq_len(ncol(target_rgb)),
    function(i) {
      distances <- colSums((named_rgb - target_rgb[, i])^2)
      named_colors[[which.min(distances)]]
    },
    character(1)
  )

  paste0(nearest_name, ' (', hex, ')')
}
