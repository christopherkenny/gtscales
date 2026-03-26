#' Add only a discrete color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_discrete()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param values A vector of color values or a single named discrete palette.
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
#'   category = c('Low', 'Medium', 'High'),
#'   value = c(12, 47, 83)
#' ) |>
#'   gt() |>
#'   data_color(
#'     columns = category,
#'     method = 'factor',
#'     palette = c('#1b9e77', '#d95f02', '#7570b3')
#'   ) |>
#'   gtscale_color_discrete(
#'     values = c('#1b9e77', '#d95f02', '#7570b3'),
#'     labels = c('Low', 'Medium', 'High'),
#'     title = 'Category'
#'   )
gtscale_color_discrete <- function(
  data,
  values,
  labels = values,
  title = NULL,
  swatch_size = '12px'
) {
  spec <- gtscale_spec_discrete(
    column = NULL,
    values = values,
    labels = labels,
    title = title,
    swatch_size = swatch_size
  ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'source_note')

  gtscale_legend(data = data, spec = spec)
}
