#' Color a numeric `gt` column and add a matching continuous legend
#'
#' This is the primary interface for continuous scales in `gtscales`.
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A numeric column to color and legendize.
#' @param palette A vector of colors used in the table and legend gradient. A
#'   single named palette can also be supplied.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param breaks Optional numeric break values to display below the gradient.
#' @param labels A labeling function or a character vector for the breaks.
#' @param title Optional legend title.
#' @param transform Transformation used for color mapping and break placement.
#' @param direction CSS gradient direction. Defaults to `"to right"`.
#' @param width Width of the legend bar.
#' @param height Height of the legend bar.
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
#' @param fn Optional `scales` function passed to [gt::data_color()]. For the
#'   legend, `palette` is preferred because it is more reliable than inspecting
#'   closure internals.
#'
#' @return A modified [gt::gt] table.
#' @export
#'
#' @examples
#' library(gt)
#'
#' exibble |>
#'   gt() |>
#'   gtscale_data_color_continuous(
#'     column = num,
#'     palette = c('#A0442C', 'white', '#0063B1'),
#'     title = 'Value'
#'   )
gtscale_data_color_continuous <- function(
  data,
  column,
  palette = NULL,
  domain = NULL,
  breaks = NULL,
  labels = scales::label_comma(),
  title = NULL,
  transform = c('identity', 'log10', 'sqrt'),
  direction = 'to right',
  width = '160px',
  height = '14px',
  apply_to = c('fill', 'text'),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  accessibility = c('none', 'warn'),
  autocolor_text = TRUE,
  contrast_algo = c('apca', 'wcag'),
  autocolor_light = '#FFFFFF',
  autocolor_dark = '#000000',
  fn = NULL
) {
  transform <- match.arg(transform)
  column <- substitute(column)
  spec <- gtscale_spec_continuous(
    column = column,
    palette = palette,
    domain = domain,
    breaks = breaks,
    labels = labels,
    title = title,
    transform = transform,
    direction = direction,
    width = width,
    height = height,
    fn = fn
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
