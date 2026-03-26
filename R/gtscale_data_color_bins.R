#' Color a numeric `gt` column and add a matching binned legend
#'
#' This is the primary interface for binned scales in `gtscales`.
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A numeric column to color and legendize.
#' @param palette A vector of colors, palette endpoints, or a single named
#'   palette used for the bins.
#' @param bins A numeric vector of bin boundaries.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param labels A labeling function or a character vector for the bins. When a
#'   function is supplied, it is applied to the bin boundaries before interval
#'   labels are constructed.
#' @param title Optional legend title.
#' @param width Width of the legend.
#' @param height Height of the swatches.
#' @param apply_to Whether colors should be applied to cell fill or text.
#' @param na_color Color used for missing values.
#' @param alpha Alpha applied by [gt::data_color()].
#' @param reverse Whether to reverse the color mapping.
#' @param accessibility Whether to warn about low-contrast adjacent legend
#'   colors.
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
#'   gtscale_data_color_bins(
#'     column = currency,
#'     palette = c('#f7fbff', '#08306b'),
#'     bins = c(0, 10, 100, 1000, 10000, 70000),
#'     title = 'Currency bins'
#'   )
gtscale_data_color_bins <- function(
  data,
  column,
  palette,
  bins,
  domain = NULL,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px',
  apply_to = c('fill', 'text'),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  accessibility = c('none', 'warn'),
  autocolor_text = TRUE,
  contrast_algo = c('apca', 'wcag'),
  autocolor_light = '#FFFFFF',
  autocolor_dark = '#000000'
) {
  column <- substitute(column)
  spec <- gtscale_spec_bins(
    column = column,
    palette = palette,
    bins = bins,
    domain = domain,
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
      accessibility = accessibility,
      autocolor_text = autocolor_text,
      contrast_algo = contrast_algo,
      autocolor_light = autocolor_light,
      autocolor_dark = autocolor_dark
    ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'source_note')

  gtscale_apply_legend(data = data, spec = spec)
}
