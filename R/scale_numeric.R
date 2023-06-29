#' Add a scale for a numeric column
#'
#' @param data A `gt` table with class `gt_tbl`
#' @param fn a function from `scales`
#' @param direction orientation of the scale. Default is `'to right'`.
#'
#' @return A [gt::gt]
#' @export
#'
#' @examples
#' party_purple <- scales::col_numeric(
#'   domain = c(0, 1),
#'   palette = c('#A0442C', 'white', '#0063B1')
#')
gtscale_color_continuous <- function(data, fn, direction = 'to right') {
  pltt <- paste0(get_palette(fn), collapse = ', ')
  clrs <- glue::glue(
    '<pre> <div style="background: linear-gradient({direction}, {pltt});" </div> </pre>'
  ) # need pre tag to retain space. div = full width, span needs spaces

  data |>
    gt::tab_source_note(
      source_note = gt::html(clrs)
    )
}

gtscale_color_discrete <- function(data, fn, direction) {

}
