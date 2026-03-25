#' Color a categorical `gt` column and add a matching discrete legend
#'
#' This is the primary interface for discrete scales in `gtscales`.
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A categorical column to color and legendize.
#' @param values A vector of color values used in the table and legend.
#' @param labels Labels for each color swatch. Defaults to `values`.
#' @param title Optional legend title.
#' @param swatch_size Size of each discrete color swatch.
#' @param levels Optional factor levels passed to [gt::data_color()].
#' @param ordered Whether the scale should be treated as ordered.
#' @param na_color Color used for missing values.
#' @param alpha Alpha applied by [gt::data_color()].
#' @param reverse Whether to reverse the color mapping.
#' @param apply_to Whether colors should be applied to cell fill or text.
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
#' data.frame(
#'   category = c("Low", "Medium", "High"),
#'   value = c(12, 47, 83)
#' ) |>
#'   gt() |>
#'   gtscale_data_color_discrete(
#'     column = category,
#'     values = c("#1b9e77", "#d95f02", "#7570b3"),
#'     labels = c("Low", "Medium", "High"),
#'     title = "Category"
#'   )
gtscale_data_color_discrete <- function(
    data,
    column,
    values,
    labels = values,
    title = NULL,
    swatch_size = "12px",
    levels = NULL,
    ordered = FALSE,
    na_color = NULL,
    alpha = NULL,
    reverse = FALSE,
    apply_to = c("fill", "text"),
    autocolor_text = TRUE,
    contrast_algo = c("apca", "wcag"),
    autocolor_light = "#FFFFFF",
    autocolor_dark = "#000000") {
  column <- substitute(column)
  spec <- gtscale_spec_discrete(
    column = column,
    values = values,
    labels = labels,
    title = title,
    swatch_size = swatch_size,
    levels = levels,
    ordered = ordered
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
    gtscale_spec_set_legend(output = "html", placement = "source_note")

  gtscale_apply_legend(data = data, spec = spec)
}
