legend_title_html <- function(title) {
  if (is.null(title)) {
    return("")
  }

  paste0(
    "<div style=\"font-weight:600; margin-bottom:4px;\">",
    title,
    "</div>"
  )
}

render_scale_legend <- function(spec, output = NULL) {
  output <- rlang::`%||%`(output, spec$legend$output)
  output <- match.arg(output, choices = c("html", "latex", "typst"))

  switch(
    output,
    html = render_scale_legend_html(spec),
    latex = rlang::abort("Legend rendering for LaTeX is not implemented yet."),
    typst = rlang::abort("Legend rendering for Typst is not implemented yet.")
  )
}

render_scale_legend_html <- function(spec) {
  switch(
    spec$scale_type,
    continuous = render_continuous_legend_html(spec),
    bins = render_bins_legend_html(spec),
    quantiles = render_bins_legend_html(spec),
    discrete = render_discrete_legend_html(spec),
    rlang::abort(paste0("Unsupported scale type `", spec$scale_type, "` for HTML legends."))
  )
}

render_continuous_legend_html <- function(spec) {
  break_positions <- scales::rescale(spec$breaks, to = c(0, 100), from = spec$domain)

  paste0(
    "<div style=\"width:", spec$style$width, ";\">",
    legend_title_html(spec$title),
    "<div style=\"height:", spec$style$height, "; border-radius:999px; border:1px solid #d0d7de; ",
    "background:linear-gradient(", spec$style$direction, ", ", paste(spec$palette, collapse = ", "), ");\"></div>",
    "<div style=\"position:relative; width:", spec$style$width, "; height:20px; margin-top:4px; font-size:11px; color:#57606a;\">",
    paste(
      vapply(
        seq_along(spec$labels),
        function(i) {
          paste0(
            "<span style=\"position:absolute; left:",
            formatC(break_positions[[i]], format = "f", digits = 2),
            "%; transform:translateX(-50%); white-space:nowrap;\">",
            spec$labels[[i]],
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
}

render_bins_legend_html <- function(spec) {
  n_intervals <- length(spec$bins) - 1
  swatch_width <- 100 / n_intervals

  paste0(
    "<div style=\"width:", spec$style$width, ";\">",
    legend_title_html(spec$title),
    "<div style=\"display:flex; width:100%; overflow:hidden; border:1px solid #d0d7de; border-radius:8px;\">",
    paste(
      vapply(
        seq_len(n_intervals),
        function(i) {
          paste0(
            "<span style=\"display:inline-block; width:",
            formatC(swatch_width, format = "f", digits = 4),
            "%; height:",
            spec$style$height,
            "; background:",
            spec$values[[i]],
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
        spec$labels,
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
}

render_discrete_legend_html <- function(spec) {
  paste0(
    "<div>",
    legend_title_html(spec$title),
    "<div style=\"display:flex; flex-wrap:wrap; gap:10px 14px; align-items:center;\">",
    paste(
      vapply(
        seq_along(spec$values),
        function(i) {
          paste0(
            "<span style=\"display:inline-flex; align-items:center; gap:6px;\">",
            "<span style=\"display:inline-block; width:", spec$style$swatch_size, "; height:", spec$style$swatch_size,
            "; border-radius:3px; border:1px solid #d0d7de; background:", spec$values[[i]], ";\"></span>",
            "<span>", spec$labels[[i]], "</span>",
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
}

attach_scale_legend <- function(data, spec, output = NULL, placement = NULL) {
  output <- rlang::`%||%`(output, spec$legend$output)
  placement <- rlang::`%||%`(placement, spec$legend$placement)
  rendered <- render_scale_legend(spec = spec, output = output)

  if (identical(output, "html") && identical(placement, "source_note")) {
    return(attach_legend_note(data, rendered))
  }

  if (!identical(output, "html")) {
    rlang::abort(paste0("Legend attachment for `", output, "` output is not implemented yet."))
  }

  rlang::abort(paste0("Legend placement `", placement, "` is not implemented yet."))
}

apply_scale_color <- function(data, spec) {
  column_name <- resolve_column_name(spec$column)

  data_color_args <- list(
    data = data,
    columns = rlang::sym(column_name),
    method = spec$color_method,
    na_color = spec$application$na_color,
    alpha = spec$application$alpha,
    reverse = spec$application$reverse,
    apply_to = spec$application$apply_to,
    autocolor_text = spec$application$autocolor_text,
    contrast_algo = spec$application$contrast_algo,
    autocolor_light = spec$application$autocolor_light,
    autocolor_dark = spec$application$autocolor_dark
  )

  if (identical(spec$color_method, "numeric")) {
    data_color_args$palette <- spec$palette
    data_color_args$domain <- spec$domain
    data_color_args$fn <- spec$fn
  } else if (identical(spec$color_method, "bin")) {
    data_color_args$palette <- spec$palette
    data_color_args$domain <- spec$domain
    data_color_args$bins <- spec$bins
  } else if (identical(spec$color_method, "quantile")) {
    data_color_args$palette <- spec$palette
    data_color_args$quantiles <- spec$quantiles
  } else if (identical(spec$color_method, "factor")) {
    data_color_args$palette <- spec$values
    data_color_args$levels <- spec$bins
    data_color_args$ordered <- spec$breaks
  }

  do.call(gt::data_color, data_color_args)
}

apply_scale_with_legend <- function(data, spec) {
  colored <- apply_scale_color(data = data, spec = spec)

  attach_scale_legend(data = colored, spec = spec)
}
