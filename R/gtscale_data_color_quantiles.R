#' Color a numeric `gt` column and add a matching quantile legend
#'
#' This is the primary interface for quantile scales in `gtscales`.
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A numeric, Date, POSIXt, or difftime column to color and
#'   legendize.
#' @param palette A vector of colors, palette endpoints, a single named
#'   palette, or a palette function used for the quantile groups.
#' @param quantiles The number of quantile groups.
#' @param oob Out-of-bounds handling function or shortcut. Use a function like
#'   [scales::oob_squish()] or a shortcut such as `"censor"` or `"squish"`.
#' @param right Whether intervals should be closed on the right. The default of
#'   `FALSE` yields intervals like `[a, b)`.
#' @param labels An optional labeling function or a character vector for the
#'   quantile ranges. When a function is supplied, it is applied to the
#'   quantile boundaries before interval labels are constructed.
#' @param title Optional legend title.
#' @param width Width of the legend.
#' @param height Height of the swatches.
#' @param apply_to Whether colors should be applied to cell fill or text.
#' @param na_color Color used for missing values.
#' @param alpha Alpha applied by [gt::data_color()].
#' @param reverse Whether to reverse the color mapping.
#' @param autocolor_text Whether to automatically adjust text color.
#' @param contrast_algo Contrast algorithm passed to [gt::data_color()].
#' @param autocolor_light Light text color used by [gt::data_color()].
#' @param autocolor_dark Dark text color used by [gt::data_color()].
#'
#' @return A modified [gt::gt] table.
#' @export
#'
#' @examples
#' library(gt)
#'
#' exibble |>
#'   gt() |>
#'   gtscale_data_color_quantiles(
#'     column = num,
#'     palette = c('#fdd49e', '#fdbb84', '#ef6548', '#990000'),
#'     quantiles = 4,
#'     title = 'Quantile bins'
#'   )
gtscale_data_color_quantiles <- function(
  data,
  column,
  palette,
  quantiles = 4,
  oob = NULL,
  right = FALSE,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px',
  apply_to = c('fill', 'text'),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  autocolor_text = TRUE,
  contrast_algo = c('apca', 'wcag'),
  autocolor_light = '#FFFFFF',
  autocolor_dark = '#000000'
) {
  column <- substitute(column)
  spec <- gtscale_spec_quantiles(
    column = column,
    palette = palette,
    quantiles = quantiles,
    oob = oob,
    right = right,
    labels = labels,
    title = title,
    width = width,
    height = height
  ) |>
    gtscale_spec_set_application(
      apply_to = apply_to,
      na_color = na_color,
      alpha = alpha,
      reverse = reverse,
      autocolor_text = autocolor_text,
      contrast_algo = contrast_algo,
      autocolor_light = autocolor_light,
      autocolor_dark = autocolor_dark
    ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'source_note')

  gtscale_apply_legend(data = data, spec = spec)
}
