#' Add only a quantile color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_quantiles()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A numeric column in the underlying table used to infer quantile
#'   boundaries.
#' @param palette A vector of colors, palette endpoints, or a single named
#'   palette used to color the quantile bins.
#' @param quantiles The number of quantile groups.
#' @param labels A labeling function or a character vector for the quantile
#'   ranges. When a function is supplied, it is applied to the quantile
#'   boundaries before interval labels are constructed.
#' @param title Optional legend title.
#' @param width Width of the legend.
#' @param height Height of the swatches.
#'
#' @return A modified [gt::gt] table.
#' @export
#'
#' @examples
#' library(gt)
#'
#' exibble |>
#'   gt() |>
#'   data_color(
#'     columns = num,
#'     method = 'quantile',
#'     palette = c('#fdd49e', '#fdbb84', '#ef6548', '#990000'),
#'     quantiles = 4
#'   ) |>
#'   gtscale_color_quantiles(
#'     column = num,
#'     palette = c('#fdd49e', '#fdbb84', '#ef6548', '#990000'),
#'     quantiles = 4,
#'     title = 'Quantile bins'
#'   )
gtscale_color_quantiles <- function(
  data,
  column,
  palette,
  quantiles = 4,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px'
) {
  column <- substitute(column)
  spec <- gtscale_spec_quantiles(
    column = column,
    palette = palette,
    quantiles = quantiles,
    labels = labels,
    title = title,
    width = width,
    height = height
  ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'source_note')

  gtscale_legend(data = data, spec = spec)
}
