validate_gt_tbl <- function(data) {
  if (!inherits(data, "gt_tbl")) {
    rlang::abort("`data` must be a `gt_tbl` created by `gt::gt()`.")
  }
}

resolve_column_name <- function(column) {
  if (is.null(column) || identical(column, quote(NULL))) {
    return(NULL)
  }

  if (is.character(column) && length(column) == 1) {
    return(column)
  }

  if (is.symbol(column)) {
    return(as.character(column))
  }

  rlang::abort("`column` must be supplied as a bare column name or a single string.")
}

gt_data_get <- function(data) {
  validate_gt_tbl(data)
  data[["_data"]]
}

resolve_column_data <- function(data, column) {
  table_data <- gt_data_get(data)

  if (is.null(column) || identical(column, quote(NULL))) {
    return(NULL)
  }

  column_name <- resolve_column_name(column)

  if (!column_name %in% names(table_data)) {
    rlang::abort(paste0("Column `", column_name, "` was not found in the `gt` data."))
  }

  table_data[[column_name]]
}

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

legend_title_html <- function(title) {
  if (is.null(title)) {
    return("")
  }

  paste0(
    "<div style=\"font-weight:600; margin-bottom:4px;\">",
    title,
    "</div>"
  )
}

attach_legend_note <- function(data, html) {
  gt::tab_source_note(
    data = data,
    source_note = gt::html(html)
  )
}

default_breaks <- function(domain, n = 3) {
  breaks <- pretty(domain, n = n)
  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (length(breaks) < 2) {
    breaks <- domain
  }

  breaks
}

data_color_with_legend <- function(data, column, data_color_args, legend_fn, legend_args) {
  column_name <- resolve_column_name(column)

  colored <- do.call(
    gt::data_color,
    c(
      list(
        data = data,
        columns = rlang::sym(column_name)
      ),
      data_color_args
    )
  )

  legend_formals <- names(formals(legend_fn))
  legend_lead <- list(data = colored)

  if ("column" %in% legend_formals) {
    legend_lead$column <- rlang::sym(column_name)
  }

  do.call(
    legend_fn,
    c(
      legend_lead,
      legend_args
    )
  )
}
