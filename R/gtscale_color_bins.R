#' Add only a binned color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_bins()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column An optional numeric, Date, POSIXt, or difftime column in the
#'   underlying table used to infer `domain`.
#' @param palette A vector of colors, palette endpoints, a single named
#'   palette, or a palette function used to color the bins.
#' @param domain A vector of length 2 giving the scale limits. When omitted,
#'   the limits are inferred from `column`.
#' @param bins Optional bin boundaries or a break function. When omitted,
#'   breaks are generated from `domain`, `column`, and `transform`.
#' @param transform A transformation specification understood by
#'   [scales::as.transform()]. This is used when generating default bins or
#'   when interpreting break functions.
#' @param labels An optional labeling function or a character vector for the
#'   bins. When a function is supplied, it is applied to the bin boundaries
#'   before interval labels are constructed.
#' @param oob Out-of-bounds handling function or shortcut. Use a function like
#'   [scales::oob_squish()] or a shortcut such as `"censor"` or `"squish"`.
#' @param right Whether intervals should be closed on the right. The default of
#'   `FALSE` yields intervals like `[a, b)`.
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
#'     columns = currency,
#'     method = 'bin',
#'     palette = c('#f7fbff', '#08306b'),
#'     bins = c(0, 10, 100, 1000, 10000000)
#'   ) |>
#'   gtscale_color_bins(
#'     column = currency,
#'     palette = c('#f7fbff', '#08306b'),
#'     bins = c(0, 10, 100, 1000, 10000000),
#'     title = 'Binned values'
#'   )
gtscale_color_bins <- function(
  data,
  column = NULL,
  palette,
  domain = NULL,
  bins = NULL,
  transform = NULL,
  oob = NULL,
  right = FALSE,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px'
) {
  column <- substitute(column)
  spec <- gtscale_spec_bins(
    column = column,
    palette = palette,
    bins = bins,
    domain = domain,
    transform = transform,
    oob = oob,
    right = right,
    labels = labels,
    title = title,
    width = width,
    height = height
  ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'source_note')

  gtscale_legend(data = data, spec = spec)
}
