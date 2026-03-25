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
  validate_gt_tbl(data)
  domain <- resolve_domain(data = data, column = column, domain = domain)

  if (missing(bins)) {
    rlang::abort("`bins` must be supplied for `gtscale_color_bins()`.")
  }

  bins <- sort(unique(as.numeric(bins)))

  if (length(bins) < 2) {
    rlang::abort("`bins` must contain at least two boundary values.")
  }

  if (bins[[1]] > domain[[1]] || bins[[length(bins)]] < domain[[2]]) {
    rlang::abort("`bins` must span the full `domain`.")
  }

  n_intervals <- length(bins) - 1

  if (length(palette) == n_intervals) {
    colors <- palette
  } else {
    midpoints <- (bins[-1] + bins[-length(bins)]) / 2
    colors <- scales::col_numeric(
      palette = palette,
      domain = domain
    )(midpoints)
  }

  if (is.null(labels)) {
    label_fn <- scales::label_comma()
    labels <- paste0(
      label_fn(bins[-length(bins)]),
      " - ",
      label_fn(bins[-1])
    )
  } else if (is.function(labels)) {
    boundary_labels <- as.character(labels(bins))
    labels <- paste0(
      boundary_labels[-length(boundary_labels)],
      " - ",
      boundary_labels[-1]
    )
  } else {
    labels <- resolve_labels(seq_len(n_intervals), labels)
  }

  swatch_width <- 100 / n_intervals

  bins_html <- paste0(
    "<div style=\"width:", width, ";\">",
    legend_title_html(title),
    "<div style=\"display:flex; width:100%; overflow:hidden; border:1px solid #d0d7de; border-radius:8px;\">",
    paste(
      vapply(
        seq_len(n_intervals),
        function(i) {
          paste0(
            "<span style=\"display:inline-block; width:",
            formatC(swatch_width, format = "f", digits = 4),
            "%; height:",
            height,
            "; background:",
            colors[[i]],
            ";\"></span>"
          )
        },
        character(1)
      ),
      collapse = ""
    ),
    "</div>",
    "<div style=\"display:flex; justify-content:space-between; gap:8px; margin-top:4px; font-size:11px; color:#57606a;\">",
    paste(
      vapply(
        labels,
        function(label) {
          paste0("<span>", label, "</span>")
        },
        character(1)
      ),
      collapse = ""
    ),
    "</div>",
    "</div>"
  )

  attach_legend_note(data, bins_html)
}
