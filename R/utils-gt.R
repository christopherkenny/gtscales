validate_gt_tbl <- function(data) {
  if (!inherits(data, "gt_tbl")) {
    rlang::abort("`data` must be a `gt_tbl` created by `gt::gt()`.")
  }
}

gt_data_get <- function(data) {
  validate_gt_tbl(data)
  data[["_data"]]
}

attach_legend_note <- function(data, html) {
  source_note <- if (is.list(html)) html else gt::html(html)

  gt::tab_source_note(
    data = data,
    source_note = source_note
  )
}
