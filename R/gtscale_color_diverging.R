#' Add only a diverging color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_diverging()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column An optional numeric column or shared set of numeric columns in
#'   the underlying table used to infer `domain`.
#' @param palette Two endpoint colors, three diverging colors, or a single named
#'   palette.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param midpoint Numeric midpoint used to anchor the diverging scale.
#' @param breaks Optional numeric break values to display below the gradient.
#' @param labels A labeling function or a character vector for the breaks.
#' @param title Optional legend title.
#' @param transform Transformation used for color mapping and break placement.
#' @param direction CSS gradient direction. Defaults to `"to right"`.
#' @param width Width of the legend bar.
#' @param height Height of the legend bar.
#' @param mid_color Midpoint color when `palette` supplies only two endpoint
#'   colors.
#'
#' @return A modified [gt::gt] table.
#' @export
gtscale_color_diverging <- function(
  data,
  column = NULL,
  palette,
  domain = NULL,
  midpoint = 0,
  breaks = NULL,
  labels = scales::label_comma(),
  title = NULL,
  transform = c('identity', 'log10', 'sqrt'),
  direction = 'to right',
  width = '160px',
  height = '14px',
  mid_color = '#FFFFFF'
) {
  transform <- match.arg(transform)
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
    direction = direction,
    width = width,
    height = height,
    mid_color = mid_color
  ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'source_note')

  gtscale_legend(data = data, spec = spec)
}
