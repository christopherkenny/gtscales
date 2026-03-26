#' Render a legend from a `gtscale_spec`
#'
#' @param spec A `gtscale_spec`.
#' @param data An optional `gt_tbl` used to finalize specs that infer domains or
#'   quantile boundaries from table data.
#' @param output Output target. Use `"html"`, `"latex"`, `"rtf"`, `"word"`,
#'   `"typst"`, or `"contextual"`.
#'
#' @return Rendered legend content for the requested output target.
#' @export
#'
#' @examples
#' spec <- gtscale_spec_quantiles(
#'   num,
#'   palette = c('#fdd49e', '#fdbb84', '#ef6548', '#990000'),
#'   quantiles = 4,
#'   title = 'Quartiles'
#' )
#'
#' gtscale_render_legend(
#'   spec = spec,
#'   data = gt::gt(gt::exibble),
#'   output = 'latex'
#' )
gtscale_render_legend <- function(spec, data = NULL, output = c('contextual', 'html', 'latex', 'rtf', 'word', 'typst')) {
  output <- match.arg(output)
  spec <- finalize_scale_spec(spec = spec, data = data)
  render_scale_legend(spec = spec, output = output)
}
