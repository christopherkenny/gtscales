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

capture_spec_column <- function(column_expr, env = parent.frame()) {
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

  column_name <- resolve_column_name(column)

  if (!column_name %in% names(table_data)) {
    rlang::abort(paste0("Column `", column_name, "` was not found in the `gt` data."))
  }

  table_data[[column_name]]
}
