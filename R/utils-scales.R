resolve_domain <- function(data, column, domain = NULL) {
  if (!is.null(domain)) {
    if (!is.numeric(domain) || length(domain) != 2) {
      rlang::abort('`domain` must be a numeric vector of length 2.')
    }

    domain <- sort(as.numeric(domain))

    if (anyNA(domain)) {
      rlang::abort('`domain` cannot contain missing values.')
    }

    return(domain)
  }

  column_data <- resolve_column_data(data, column)

  if (is.null(column_data)) {
    rlang::abort('Supply `domain` or provide a numeric `column` to infer the range.')
  }

  if (!is.numeric(column_data)) {
    rlang::abort('`column` must be numeric when `domain` is inferred from the `gt` data.')
  }

  domain <- range(column_data, na.rm = TRUE, finite = TRUE)

  if (any(!is.finite(domain))) {
    rlang::abort('Could not infer a finite numeric domain from `column`.')
  }

  domain
}

resolve_na_legend_color <- function(spec, default = '#D9D9D9') {
  spec$legend$na_color %||% spec$application$na_color %||% default
}

resolve_palette <- function(palette = NULL, fn = NULL) {
  if (!is.null(palette)) {
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
  if (is.function(labels)) {
    return(as.character(labels(values)))
  }

  if (length(labels) != length(values)) {
    rlang::abort('`labels` must have the same length as the values being labeled.')
  }

  as.character(labels)
}

default_breaks <- function(domain, n = 3) {
  breaks <- pretty(domain, n = n)
  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (length(breaks) < 2) {
    breaks <- domain
  }

  breaks
}

resolve_quantile_breaks <- function(data, column, quantiles) {
  column_data <- resolve_column_data(data, column)

  if (is.null(column_data) || !is.numeric(column_data)) {
    rlang::abort('`column` must be numeric for quantile scales.')
  }

  if (!is.numeric(quantiles) || length(quantiles) != 1 || is.na(quantiles) || quantiles < 1) {
    rlang::abort('`quantiles` must be a single positive number.')
  }

  stats::quantile(
    column_data,
    probs = seq(0, 1, length.out = quantiles + 1),
    na.rm = TRUE,
    names = FALSE
  )
}

resolve_quantile_colors <- function(palette, n_intervals) {
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

relative_luminance <- function(color) {
  rgb <- grDevices::col2rgb(normalize_color_hex(color)) / 255
  rgb <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  0.2126 * rgb[1, ] + 0.7152 * rgb[2, ] + 0.0722 * rgb[3, ]
}

contrast_ratio <- function(color_1, color_2) {
  lum_1 <- relative_luminance(color_1)
  lum_2 <- relative_luminance(color_2)
  lighter <- pmax(lum_1, lum_2)
  darker <- pmin(lum_1, lum_2)
  (lighter + 0.05) / (darker + 0.05)
}

spec_legend_colors <- function(spec) {
  legend_colors <- switch(spec$scale_type,
    continuous = spec$palette,
    diverging = spec$palette,
    bins = spec$values,
    quantiles = spec$values,
    discrete = spec$values,
    character(0)
  )

  if (isTRUE(spec$legend$show_na)) {
    c(legend_colors, resolve_na_legend_color(spec))
  } else {
    legend_colors
  }
}

warn_on_accessibility_risks <- function(spec) {
  if (!identical(spec$application$accessibility, 'warn')) {
    return(spec)
  }

  legend_colors <- normalize_color_hex(spec_legend_colors(spec))

  if (length(legend_colors) < 2) {
    return(spec)
  }

  pairwise_contrast <- vapply(
    seq_len(length(legend_colors) - 1),
    function(i) contrast_ratio(legend_colors[[i]], legend_colors[[i + 1]]),
    numeric(1)
  )

  if (any(pairwise_contrast < 1.25, na.rm = TRUE)) {
    rlang::warn(
      paste(
        'Some adjacent legend colors have very low contrast.',
        'Consider a more distinct palette for accessibility.'
      )
    )
  }

  spec
}
