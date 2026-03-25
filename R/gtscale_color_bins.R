#' Add only a binned color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_bins()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column An optional numeric column in the underlying table used to infer
#'   `domain`.
#' @param palette A vector of colors or palette endpoints used to color the bins.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param bins A numeric vector of bin boundaries.
#' @param labels A labeling function or a character vector for the bins. When a
#'   function is supplied, it is applied to the bin boundaries before interval
#'   labels are constructed.
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
#'     method = "bin",
#'     palette = c("#f7fbff", "#08306b"),
#'     bins = c(0, 10, 100, 1000, 10000000)
#'   ) |>
#'   gtscale_color_bins(
#'     column = currency,
#'     palette = c("#f7fbff", "#08306b"),
#'     bins = c(0, 10, 100, 1000, 10000000),
#'     title = "Binned values"
#'   )
gtscale_color_bins <- function(
    data,
    column = NULL,
    palette,
    domain = NULL,
    bins,
    labels = NULL,
    title = NULL,
    width = "180px",
    height = "14px") {
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
    gtscale_spec_set_legend(output = "html", placement = "source_note")

  gtscale_legend(data = data, spec = spec)
}
