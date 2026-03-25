resolve_column_name <- function(column) {
  column_names <- resolve_column_names(column)

  if (length(column_names) != 1) {
    rlang::abort('`column` must resolve to exactly one column name here.')
  }

  column_names[[1]]
}

resolve_column_names <- function(column) {
  if (is.null(column) || identical(column, quote(NULL))) {
    return(character(0))
  }

  if (is.character(column)) {
    if (length(column) == 0 || anyNA(column) || any(column == '')) {
      rlang::abort('`column` names must be non-missing strings.')
    }

    return(unname(column))
  }

  if (is.symbol(column)) {
    return(as.character(column))
  }

  if (rlang::is_call(column, 'c')) {
    column_parts <- as.list(column)[-1]

    if (length(column_parts) == 0) {
      rlang::abort('`column` must contain at least one column name.')
    }

    return(vapply(column_parts, resolve_column_name, character(1)))
  }

  rlang::abort(
    paste(
      '`column` must be supplied as a bare column name, a character vector,',
      'or `c(col1, col2, ...)` for shared scales.'
    )
  )
}

capture_spec_column <- function(column_expr, env = parent.frame()) {
  if (rlang::is_call(column_expr, 'c')) {
    return(as.call(c(list(quote(c)), lapply(as.list(column_expr)[-1], capture_spec_column, env = env))))
  }

  if (is.symbol(column_expr)) {
    column_name <- as.character(column_expr)

    if (exists(column_name, envir = env, inherits = FALSE)) {
      column_value <- get(column_name, envir = env, inherits = FALSE)

      if (
        is.null(column_value) ||
          is.symbol(column_value) ||
          (is.character(column_value) && length(column_value) == 1)
      ) {
        return(column_value)
      }
    }
  }

  column_expr
}

resolve_column_data <- function(data, column) {
  table_data <- gt_data_get(data)

  if (is.null(column) || identical(column, quote(NULL))) {
    return(NULL)
  }

  column_names <- resolve_column_names(column)

  missing_names <- setdiff(column_names, names(table_data))

  if (length(missing_names) > 0) {
    rlang::abort(
      paste0(
        'Column `',
        missing_names[[1]],
        '` was not found in the `gt` data.'
      )
    )
  }

  if (length(column_names) == 1) {
    return(table_data[[column_names[[1]]]])
  }

  unlist(table_data[column_names], use.names = FALSE)
}
