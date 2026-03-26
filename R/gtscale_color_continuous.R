#' Add only a continuous color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_continuous()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column An optional numeric column in the underlying table used to infer
#'   `domain`.
#' @param palette A vector of colors used in the legend gradient. A single named
#'   palette or palette function can also be supplied.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
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
#' @param fn Backward-compatible fallback for passing a `scales` palette
#'   function. `palette` is preferred.
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
#'     method = 'numeric',
#'     palette = c('#A0442C', 'white', '#0063B1')
#'   ) |>
#'   gtscale_color_continuous(
#'     column = num,
#'     palette = c('#A0442C', 'white', '#0063B1'),
#'     title = 'Value'
#'   )
gtscale_color_continuous <- function(
  data,
  column = NULL,
  palette = NULL,
  domain = NULL,
  breaks = NULL,
  labels = NULL,
  title = NULL,
  transform = NULL,
  oob = NULL,
  direction = 'to right',
  width = '160px',
  height = '14px',
  fn = NULL
) {
  column <- substitute(column)
  spec <- gtscale_spec_continuous(
    column = column,
    palette = palette,
    domain = domain,
    breaks = breaks,
    labels = labels,
    title = title,
    transform = transform,
    oob = oob,
    direction = direction,
    width = width,
    height = height,
    fn = fn
  ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'source_note')

  gtscale_legend(data = data, spec = spec)
}
