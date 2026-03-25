#' Add only a discrete color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_discrete()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param values A vector of color values.
#' @param labels Labels for each color swatch. Defaults to `values`.
#' @param title Optional legend title.
#' @param swatch_size Size of each discrete color swatch.
#'
#' @return A modified [gt::gt] table.
#' @export
#'
#' @examples
#' library(gt)
#'
#' data.frame(
#'   category = c("Low", "Medium", "High"),
#'   value = c(12, 47, 83)
#' ) |>
#'   gt() |>
#'   data_color(
#'     columns = category,
#'     method = "factor",
#'     palette = c("#1b9e77", "#d95f02", "#7570b3")
#'   ) |>
#'   gtscale_color_discrete(
#'     values = c("#1b9e77", "#d95f02", "#7570b3"),
#'     labels = c("Low", "Medium", "High"),
#'     title = "Category"
#'   )
gtscale_color_discrete <- function(
    data,
    values,
    labels = values,
    title = NULL,
    swatch_size = "12px") {
  validate_gt_tbl(data)

  if (missing(values) || length(values) == 0) {
    rlang::abort("`values` must contain at least one color.")
  }

  values <- as.character(values)
  labels <- resolve_labels(values, labels)

  discrete_html <- paste0(
    "<div>",
    legend_title_html(title),
    "<div style=\"display:flex; flex-wrap:wrap; gap:10px 14px; align-items:center;\">",
    paste(
      vapply(
        seq_along(values),
        function(i) {
          paste0(
            "<span style=\"display:inline-flex; align-items:center; gap:6px;\">",
            "<span style=\"display:inline-block; width:", swatch_size, "; height:", swatch_size,
            "; border-radius:3px; border:1px solid #d0d7de; background:", values[[i]], ";\"></span>",
            "<span>", labels[[i]], "</span>",
            "</span>"
          )
        },
        character(1)
      ),
      collapse = ""
    ),
    "</div>",
    "</div>"
  )

  attach_legend_note(data, discrete_html)
}
