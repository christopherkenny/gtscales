#' Create a continuous `gtscales` spec
#'
#' @param column A column to target.
#' @param palette A vector of colors used in the scale.
#' @param domain Optional numeric limits. If omitted, these can be inferred when
#'   the spec is applied to a `gt` table.
#' @param breaks Optional numeric break values for the legend.
#' @param labels A labeling function or character vector for the legend.
#' @param title Optional legend title.
#' @param direction CSS gradient direction. Defaults to `"to right"`.
#' @param width Width of the legend bar.
#' @param height Height of the legend bar.
#' @param fn Optional `scales` function for numeric coloring.
#'
#' @return A `gtscale_spec`.
#' @export
gtscale_spec_continuous <- function(
  column,
  palette = NULL,
  domain = NULL,
  breaks = NULL,
  labels = scales::label_comma(),
  title = NULL,
  direction = 'to right',
  width = '160px',
  height = '14px',
  fn = NULL
) {
  column <- capture_spec_column(substitute(column), parent.frame())

  new_gtscale_spec(
    scale_type = 'continuous',
    color_method = 'numeric',
    column = column,
    palette = palette,
    domain = domain,
    breaks = breaks,
    labels = labels,
    title = title,
    fn = fn,
    style = list(
      direction = direction,
      width = width,
      height = height
    )
  )
}

#' Create a binned `gtscales` spec
#'
#' @param column A column to target.
#' @param palette A vector of colors or palette endpoints used for the bins.
#' @param bins A numeric vector of bin boundaries.
#' @param domain Optional numeric limits. If omitted, these can be inferred when
#'   the spec is applied to a `gt` table.
#' @param labels A labeling function or character vector for the legend.
#' @param title Optional legend title.
#' @param width Width of the legend.
#' @param height Height of the swatches.
#'
#' @return A `gtscale_spec`.
#' @export
gtscale_spec_bins <- function(
  column,
  palette,
  bins,
  domain = NULL,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px'
) {
  column <- capture_spec_column(substitute(column), parent.frame())

  new_gtscale_spec(
    scale_type = 'bins',
    color_method = 'bin',
    column = column,
    palette = palette,
    domain = domain,
    bins = bins,
    labels = labels,
    title = title,
    style = list(
      width = width,
      height = height
    )
  )
}

#' Create a quantile `gtscales` spec
#'
#' @param column A column to target.
#' @param palette A vector of colors or palette endpoints used for the quantile
#'   groups.
#' @param quantiles The number of quantile groups.
#' @param labels A labeling function or character vector for the legend.
#' @param title Optional legend title.
#' @param width Width of the legend.
#' @param height Height of the swatches.
#'
#' @return A `gtscale_spec`.
#' @export
gtscale_spec_quantiles <- function(
  column,
  palette,
  quantiles = 4,
  labels = NULL,
  title = NULL,
  width = '180px',
  height = '14px'
) {
  column <- capture_spec_column(substitute(column), parent.frame())

  new_gtscale_spec(
    scale_type = 'quantiles',
    color_method = 'quantile',
    column = column,
    palette = palette,
    quantiles = quantiles,
    labels = labels,
    title = title,
    style = list(
      width = width,
      height = height
    )
  )
}

#' Create a discrete `gtscales` spec
#'
#' @param column A column to target.
#' @param values A vector of color values.
#' @param labels Labels for each legend swatch. Defaults to `values`.
#' @param title Optional legend title.
#' @param swatch_size Size of each discrete color swatch.
#' @param levels Optional factor levels.
#' @param ordered Whether the scale should be treated as ordered.
#'
#' @return A `gtscale_spec`.
#' @export
gtscale_spec_discrete <- function(
  column,
  values,
  labels = values,
  title = NULL,
  swatch_size = '12px',
  levels = NULL,
  ordered = FALSE
) {
  column <- capture_spec_column(substitute(column), parent.frame())

  new_gtscale_spec(
    scale_type = 'discrete',
    color_method = 'factor',
    column = column,
    values = values,
    labels = labels,
    title = title,
    bins = levels,
    breaks = ordered,
    style = list(
      swatch_size = swatch_size
    )
  )
}

#' Set how a `gtscales` spec is applied
#'
#' @inheritParams gtscale_data_color_continuous
#' @param spec A `gtscale_spec`.
#'
#' @return A modified `gtscale_spec`.
#' @export
gtscale_spec_set_application <- function(
  spec,
  apply_to = c('fill', 'text'),
  na_color = NULL,
  alpha = NULL,
  reverse = FALSE,
  autocolor_text = TRUE,
  contrast_algo = c('apca', 'wcag'),
  autocolor_light = '#FFFFFF',
  autocolor_dark = '#000000'
) {
  set_scale_application(
    spec = spec,
    apply_to = apply_to,
    na_color = na_color,
    alpha = alpha,
    reverse = reverse,
    autocolor_text = autocolor_text,
    contrast_algo = contrast_algo,
    autocolor_light = autocolor_light,
    autocolor_dark = autocolor_dark
  )
}

#' Set how a `gtscales` legend should be rendered
#'
#' @param spec A `gtscale_spec`.
#' @param output Output target for the legend. Use `"contextual"` for
#'   `gt`-managed HTML/LaTeX source notes, or choose a specific output like
#'   `"html"`, `"latex"`, or `"typst"`.
#' @param placement Legend placement target. Currently only `"source_note"` is
#'   implemented.
#'
#' @return A modified `gtscale_spec`.
#' @export
gtscale_spec_set_legend <- function(
  spec,
  output = 'html',
  placement = 'source_note'
) {
  set_scale_legend(
    spec = spec,
    output = output,
    placement = placement
  )
}

#' Apply only the color component of a `gtscales` spec
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param spec A `gtscale_spec`.
#'
#' @return A modified [gt::gt] table.
#' @export
gtscale_apply <- function(data, spec) {
  spec <- finalize_scale_spec(spec = spec, data = data)
  apply_scale_color(data = data, spec = spec)
}

#' Attach only the legend component of a `gtscales` spec
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param spec A `gtscale_spec`.
#'
#' @return A modified [gt::gt] table.
#' @export
gtscale_legend <- function(data, spec) {
  spec <- finalize_scale_spec(spec = spec, data = data)
  attach_scale_legend(data = data, spec = spec)
}

#' Apply a `gtscales` spec and attach its legend
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param spec A `gtscale_spec`.
#'
#' @return A modified [gt::gt] table.
#' @export
#'
#' @examples
#' library(gt)
#'
#' spec <- gtscale_spec_continuous(
#'   num,
#'   palette = c('#A0442C', 'white', '#0063B1'),
#'   title = 'Value'
#' )
#'
#' exibble |>
#'   gt() |>
#'   gtscale_apply_legend(spec)
gtscale_apply_legend <- function(data, spec) {
  spec <- finalize_scale_spec(spec = spec, data = data)
  apply_scale_with_legend(data = data, spec = spec)
}
