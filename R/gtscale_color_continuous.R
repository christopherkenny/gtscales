#' Add only a continuous color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_continuous()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column An optional numeric column in the underlying table used to infer
#'   `domain`.
#' @param palette A vector of colors used in the legend gradient.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param breaks Optional numeric break values to display below the gradient.
#' @param labels A labeling function or a character vector for the breaks.
#' @param title Optional legend title.
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
#'     method = "numeric",
#'     palette = c("#A0442C", "white", "#0063B1")
#'   ) |>
#'   gtscale_color_continuous(
#'     column = num,
#'     palette = c("#A0442C", "white", "#0063B1"),
#'     title = "Value"
#'   )
gtscale_color_continuous <- function(
    data,
    column = NULL,
    palette = NULL,
    domain = NULL,
    breaks = NULL,
    labels = scales::label_comma(),
    title = NULL,
    direction = "to right",
    width = "160px",
    height = "14px",
    fn = NULL) {
  column <- substitute(column)
  validate_gt_tbl(data)
  palette <- resolve_palette(palette = palette, fn = fn)
  domain <- resolve_domain(data = data, column = column, domain = domain)

  if (is.null(breaks)) {
    breaks <- default_breaks(domain)
  }

  breaks <- sort(unique(as.numeric(breaks)))
  breaks <- breaks[breaks >= domain[[1]] & breaks <= domain[[2]]]

  if (length(breaks) == 0) {
    breaks <- domain
  }

  labels <- resolve_labels(breaks, labels)
  break_positions <- scales::rescale(breaks, to = c(0, 100), from = domain)

  bar_html <- paste0(
    "<div style=\"width:", width, ";\">",
    legend_title_html(title),
    "<div style=\"height:", height, "; border-radius:999px; border:1px solid #d0d7de; ",
    "background:linear-gradient(", direction, ", ", paste(palette, collapse = ", "), ");\"></div>",
    "<div style=\"position:relative; width:", width, "; height:20px; margin-top:4px; font-size:11px; color:#57606a;\">",
    paste(
      vapply(
        seq_along(labels),
        function(i) {
          paste0(
            "<span style=\"position:absolute; left:",
            formatC(break_positions[[i]], format = "f", digits = 2),
            "%; transform:translateX(-50%); white-space:nowrap;\">",
            labels[[i]],
            "</span>"
          )
        },
        character(1)
      ),
      collapse = ""
    ),
    "</div>",
    "</div>"
  )

  attach_legend_note(data, bar_html)
}
