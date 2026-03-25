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
