resolve_domain <- function(data, column, domain = NULL) {
  if (!is.null(domain)) {
    if (!is.numeric(domain) || length(domain) != 2) {
      rlang::abort("`domain` must be a numeric vector of length 2.")
    }

    domain <- sort(as.numeric(domain))

    if (anyNA(domain)) {
      rlang::abort("`domain` cannot contain missing values.")
    }

    return(domain)
  }

  column_data <- resolve_column_data(data, column)

  if (is.null(column_data)) {
    rlang::abort("Supply `domain` or provide a numeric `column` to infer the range.")
  }

  if (!is.numeric(column_data)) {
    rlang::abort("`column` must be numeric when `domain` is inferred from the `gt` data.")
  }

  domain <- range(column_data, na.rm = TRUE, finite = TRUE)

  if (any(!is.finite(domain))) {
    rlang::abort("Could not infer a finite numeric domain from `column`.")
  }

  domain
}

resolve_palette <- function(palette = NULL, fn = NULL) {
  if (!is.null(palette)) {
    return(as.character(palette))
  }

  if (is.null(fn)) {
    rlang::abort("Supply either `palette` or `fn`.")
  }

  if (!is.function(fn)) {
    rlang::abort("`fn` must be a function, typically from `scales`.")
  }

  fn_env <- rlang::get_env(fn)
  env_names <- rlang::env_names(fn_env)

  if (!"palette" %in% env_names) {
    rlang::abort("Could not discover a `palette` value in `fn`; supply `palette` directly.")
  }

  as.character(rlang::env_get(fn_env, "palette"))
}

resolve_labels <- function(values, labels) {
  if (is.function(labels)) {
    return(as.character(labels(values)))
  }

  if (length(labels) != length(values)) {
    rlang::abort("`labels` must have the same length as the values being labeled.")
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
    rlang::abort("`column` must be numeric for quantile scales.")
  }

  if (!is.numeric(quantiles) || length(quantiles) != 1 || is.na(quantiles) || quantiles < 1) {
    rlang::abort("`quantiles` must be a single positive number.")
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
  paste0(
    "#",
    toupper(sprintf("%02X%02X%02X", rgb[1, 1], rgb[2, 1], rgb[3, 1]))
  )
}
