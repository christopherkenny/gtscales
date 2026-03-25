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

#' Add only a discrete color legend to a `gt` table
#'
#' This is a lower-level helper for cases where table coloring is already
#' handled elsewhere. For the usual "color and legendize" workflow, prefer
#' [gtscale_data_color_discrete()].
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param values A vector of color values.
#' @param labels Labels for each color swatch. Defaults to `values`.
#' @param title Optional legend title.
#' @param swatch_size Size of each discrete color swatch.
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
#'   data_color(
#'     columns = category,
#'     method = "factor",
#'     palette = c("#1b9e77", "#d95f02", "#7570b3")
#'   ) |>
#'   gtscale_color_discrete(
#'     values = c("#1b9e77", "#d95f02", "#7570b3"),
#'     labels = c("Low", "Medium", "High"),
#'     title = "Category"
#'   )
gtscale_color_discrete <- function(
    data,
    values,
    labels = values,
    title = NULL,
    swatch_size = "12px") {
  validate_gt_tbl(data)

  if (missing(values) || length(values) == 0) {
    rlang::abort("`values` must contain at least one color.")
  }

  values <- as.character(values)
  labels <- resolve_labels(values, labels)

  discrete_html <- paste0(
    "<div>",
    legend_title_html(title),
    "<div style=\"display:flex; flex-wrap:wrap; gap:10px 14px; align-items:center;\">",
    paste(
      vapply(
        seq_along(values),
        function(i) {
          paste0(
            "<span style=\"display:inline-flex; align-items:center; gap:6px;\">",
            "<span style=\"display:inline-block; width:", swatch_size, "; height:", swatch_size,
            "; border-radius:3px; border:1px solid #d0d7de; background:", values[[i]], ";\"></span>",
            "<span>", labels[[i]], "</span>",
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

  attach_legend_note(data, discrete_html)
}

#' Color a numeric `gt` column and add a matching continuous legend
#'
#' This is the primary interface for continuous scales in `gtscales`.
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A numeric column to color and legendize.
#' @param palette A vector of colors used in the table and legend gradient.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param breaks Optional numeric break values to display below the gradient.
#' @param labels A labeling function or a character vector for the breaks.
#' @param title Optional legend title.
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
#' @param fn Optional `scales` function passed to [gt::data_color()]. For the
#'   legend, `palette` is preferred because it is more reliable than inspecting
#'   closure internals.
#'
#' @return A modified [gt::gt] table.
#' @export
#'
#' @examples
#' library(gt)
#'
#' exibble |>
#'   gt() |>
#'   gtscale_data_color_continuous(
#'     column = num,
#'     palette = c("#A0442C", "white", "#0063B1"),
#'     title = "Value"
#'   )
gtscale_data_color_continuous <- function(
    data,
    column,
    palette = NULL,
    domain = NULL,
    breaks = NULL,
    labels = scales::label_comma(),
    title = NULL,
    direction = "to right",
    width = "160px",
    height = "14px",
    apply_to = c("fill", "text"),
    na_color = NULL,
    alpha = NULL,
    reverse = FALSE,
    autocolor_text = TRUE,
    contrast_algo = c("apca", "wcag"),
    autocolor_light = "#FFFFFF",
    autocolor_dark = "#000000",
    fn = NULL) {
  column <- substitute(column)
  palette <- resolve_palette(palette = palette, fn = fn)
  domain <- resolve_domain(data = data, column = column, domain = domain)

  data_color_with_legend(
    data = data,
    column = column,
    data_color_args = list(
      method = "numeric",
      palette = palette,
      domain = domain,
      na_color = na_color,
      alpha = alpha,
      reverse = reverse,
      apply_to = apply_to,
      autocolor_text = autocolor_text,
      contrast_algo = contrast_algo,
      autocolor_light = autocolor_light,
      autocolor_dark = autocolor_dark,
      fn = fn
    ),
    legend_fn = gtscale_color_continuous,
    legend_args = list(
      palette = palette,
      domain = domain,
      breaks = breaks,
      labels = labels,
      title = title,
      direction = direction,
      width = width,
      height = height
    )
  )
}

#' Color a numeric `gt` column and add a matching binned legend
#'
#' This is the primary interface for binned scales in `gtscales`.
#'
#' @param data A `gt_tbl` created by [gt::gt()].
#' @param column A numeric column to color and legendize.
#' @param palette A vector of colors or palette endpoints used for the bins.
#' @param bins A numeric vector of bin boundaries.
#' @param domain A numeric vector of length 2 giving the scale limits. When
#'   omitted, the limits are inferred from `column`.
#' @param labels A labeling function or a character vector for the bins. When a
#'   function is supplied, it is applied to the bin boundaries before interval
#'   labels are constructed.
#' @param title Optional legend title.
#' @param width Width of the legend.
#' @param height Height of the swatches.
#' @param apply_to Whether colors should be applied to cell fill or text.
#' @param na_color Color used for missing values.
#' @param alpha Alpha applied by [gt::data_color()].
#' @param reverse Whether to reverse the color mapping.
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
#' exibble |>
#'   gt() |>
#'   gtscale_data_color_bins(
#'     column = currency,
#'     palette = c("#f7fbff", "#08306b"),
#'     bins = c(0, 10, 100, 1000, 10000, 70000),
#'     title = "Currency bins"
#'   )
gtscale_data_color_bins <- function(
    data,
    column,
    palette,
    bins,
    domain = NULL,
    labels = NULL,
    title = NULL,
    width = "180px",
    height = "14px",
    apply_to = c("fill", "text"),
    na_color = NULL,
    alpha = NULL,
    reverse = FALSE,
    autocolor_text = TRUE,
    contrast_algo = c("apca", "wcag"),
    autocolor_light = "#FFFFFF",
    autocolor_dark = "#000000") {
  column <- substitute(column)
  domain <- resolve_domain(data = data, column = column, domain = domain)

  data_color_with_legend(
    data = data,
    column = column,
    data_color_args = list(
      method = "bin",
      palette = palette,
      domain = domain,
      bins = bins,
      na_color = na_color,
      alpha = alpha,
      reverse = reverse,
      apply_to = apply_to,
      autocolor_text = autocolor_text,
      contrast_algo = contrast_algo,
      autocolor_light = autocolor_light,
      autocolor_dark = autocolor_dark
    ),
    legend_fn = gtscale_color_bins,
    legend_args = list(
      palette = palette,
      domain = domain,
      bins = bins,
      labels = labels,
      title = title,
      width = width,
      height = height
    )
  )
}

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

  data_color_with_legend(
    data = data,
    column = column,
    data_color_args = list(
      method = "factor",
      palette = values,
      levels = levels,
      ordered = ordered,
      na_color = na_color,
      alpha = alpha,
      reverse = reverse,
      apply_to = apply_to,
      autocolor_text = autocolor_text,
      contrast_algo = contrast_algo,
      autocolor_light = autocolor_light,
      autocolor_dark = autocolor_dark
    ),
    legend_fn = gtscale_color_discrete,
    legend_args = list(
      values = values,
      labels = labels,
      title = title,
      swatch_size = swatch_size
    )
  )
}
