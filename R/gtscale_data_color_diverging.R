#' Color a numeric `gt` column with a diverging scale and add a matching legend
#'
#' This is the primary interface for midpoint-aware diverging scales in
#' `gtscales`.
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A numeric column or shared set of numeric columns to color and
#'   legendize.
#' @param palette Two endpoint colors, three diverging colors, or a single named
#'   palette.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param midpoint Numeric midpoint used to anchor the diverging scale.
#' @param breaks Optional break values or a break function to display below the
#'   gradient.
#' @param labels An optional labeling function or a character vector for the
#'   breaks.
#' @param title Optional legend title.
#' @param transform A transformation specification understood by
#'   [scales::as.transform()]. When omitted, an appropriate transform is
#'   inferred from the data.
#' @param oob Out-of-bounds handling function or shortcut. Use a function like
#'   [scales::oob_squish()] or a shortcut such as `"censor"`, `"squish"`,
#'   `"keep"`, or `"discard"`.
#' @param direction CSS gradient direction. Defaults to `"to right"`.
#' @param width Width of the legend bar.
#' @param height Height of the legend bar.
#' @param apply_to Whether colors should be applied to cell fill or text.
#' @param na_color Color used for missing values.
#' @param alpha Alpha applied by [gt::data_color()].
#' @param reverse Whether to reverse the color mapping.
#' @param autocolor_text Whether to automatically adjust text color.
#' @param contrast_algo Contrast algorithm passed to [gt::data_color()].
#' @param autocolor_light Light text color used by [gt::data_color()].
#' @param autocolor_dark Dark text color used by [gt::data_color()].
#' @param mid_color Midpoint color when `palette` supplies only two endpoint
#'   colors.
#'
#' @return A modified [gt::gt] table.
#' @export
gtscale_data_color_diverging <- function(
  data,
  column,
  palette,
  domain = NULL,
  midpoint = 0,
  breaks = NULL,
  labels = NULL,
  title = NULL,
  transform = NULL,
  oob = NULL,
  direction = 'to right',
  width = '160px',
  height = '14px',
  apply_to = c('fill', 'text'),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  autocolor_text = TRUE,
  contrast_algo = c('apca', 'wcag'),
  autocolor_light = '#FFFFFF',
  autocolor_dark = '#000000',
  mid_color = '#FFFFFF'
) {
  column <- substitute(column)
  spec <- gtscale_spec_diverging(
    column = column,
    palette = palette,
    domain = domain,
    midpoint = midpoint,
    breaks = breaks,
    labels = labels,
    title = title,
    transform = transform,
    oob = oob,
    direction = direction,
    width = width,
    height = height,
    mid_color = mid_color
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
