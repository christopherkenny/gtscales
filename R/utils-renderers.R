legend_title_html <- function(title) {
  if (is.null(title)) {
    return('')
  }

  paste0(
    '<div style="font-weight:600; margin-bottom:4px;">',
    title,
    '</div>'
  )
}

latex_escape_text <- function(text) {
  text <- gsub('\\\\', '\\\\textbackslash{}', text)
  text <- gsub('([#$%&_{}])', '\\\\\\1', text, perl = TRUE)
  text <- gsub('~', '\\\\textasciitilde{}', text, fixed = TRUE)
  text <- gsub('\\^', '\\\\textasciicircum{}', text)
  text
}

latex_color_box <- function(color, width = '1.4em', height = '0.9ex') {
  color <- toupper(gsub('^#', '', normalize_color_hex(color)))
  paste0('\\textcolor[HTML]{', color, '}{\\rule{', width, '}{', height, '}}')
}

typst_color <- function(color) {
  paste0('rgb("', normalize_color_hex(color), '")')
}

typst_color_box <- function(color) {
  paste0(
    'box(',
    'fill: ', typst_color(color), ', ',
    'stroke: rgb("#D0D7DE"), ',
    'inset: 0pt, ',
    'width: 1.2em, ',
    'height: 0.8em, ',
    'radius: 2pt',
    ')[ ]'
  )
}

typst_escape_text <- function(text) {
  text <- gsub('\\\\', '\\\\\\\\', text)
  text <- gsub('"', '\\\\"', text)
  text
}

render_scale_legend_contextual <- function(spec) {
  list(
    html = gt::html(render_scale_legend_html(spec)),
    latex = gt::latex(render_scale_legend_latex(spec)),
    word = render_scale_legend_word(spec)
  )
}

render_scale_legend <- function(spec, output = NULL) {
  output <- rlang::`%||%`(output, spec$legend$output)
  output <- match.arg(output, choices = c('contextual', 'html', 'latex', 'word', 'typst'))

  switch(output,
    contextual = render_scale_legend_contextual(spec),
    html = render_scale_legend_html(spec),
    latex = render_scale_legend_latex(spec),
    word = render_scale_legend_word(spec),
    typst = render_scale_legend_typst(spec)
  )
}

render_scale_legend_html <- function(spec) {
  switch(spec$scale_type,
    continuous = render_continuous_legend_html(spec),
    bins = render_bins_legend_html(spec),
    quantiles = render_bins_legend_html(spec),
    discrete = render_discrete_legend_html(spec),
    rlang::abort(paste0('Unsupported scale type `', spec$scale_type, '` for HTML legends.'))
  )
}

render_continuous_legend_html <- function(spec) {
  break_positions <- scales::rescale(spec$breaks, to = c(0, 100), from = spec$domain)

  paste0(
    '<div style="width:', spec$style$width, ';">',
    legend_title_html(spec$title),
    '<div style="height:', spec$style$height, '; border-radius:999px; border:1px solid #d0d7de; ',
    'background:linear-gradient(', spec$style$direction, ', ', paste(spec$palette, collapse = ', '), ');"></div>',
    '<div style="position:relative; width:', spec$style$width, '; height:20px; margin-top:4px; font-size:11px; color:#57606a;">',
    paste(
      vapply(
        seq_along(spec$labels),
        function(i) {
          paste0(
            '<span style="position:absolute; left:',
            formatC(break_positions[[i]], format = 'f', digits = 2),
            '%; transform:translateX(-50%); white-space:nowrap;">',
            spec$labels[[i]],
            '</span>'
          )
        },
        character(1)
      ),
      collapse = ''
    ),
    '</div>',
    '</div>'
  )
}

render_bins_legend_html <- function(spec) {
  n_intervals <- length(spec$bins) - 1
  swatch_width <- 100 / n_intervals

  paste0(
    '<div style="width:', spec$style$width, ';">',
    legend_title_html(spec$title),
    '<div style="display:flex; width:100%; overflow:hidden; border:1px solid #d0d7de; border-radius:8px;">',
    paste(
      vapply(
        seq_len(n_intervals),
        function(i) {
          paste0(
            '<span style="display:inline-block; width:',
            formatC(swatch_width, format = 'f', digits = 4),
            '%; height:',
            spec$style$height,
            '; background:',
            spec$values[[i]],
            ';"></span>'
          )
        },
        character(1)
      ),
      collapse = ''
    ),
    '</div>',
    '<div style="display:flex; justify-content:space-between; gap:8px; margin-top:4px; font-size:11px; color:#57606a;">',
    paste(
      vapply(
        spec$labels,
        function(label) {
          paste0('<span>', label, '</span>')
        },
        character(1)
      ),
      collapse = ''
    ),
    '</div>',
    '</div>'
  )
}

render_discrete_legend_html <- function(spec) {
  paste0(
    '<div>',
    legend_title_html(spec$title),
    '<div style="display:flex; flex-wrap:wrap; gap:10px 14px; align-items:center;">',
    paste(
      vapply(
        seq_along(spec$values),
        function(i) {
          paste0(
            '<span style="display:inline-flex; align-items:center; gap:6px;">',
            '<span style="display:inline-block; width:', spec$style$swatch_size, '; height:', spec$style$swatch_size,
            '; border-radius:3px; border:1px solid #d0d7de; background:', spec$values[[i]], ';"></span>',
            '<span>', spec$labels[[i]], '</span>',
            '</span>'
          )
        },
        character(1)
      ),
      collapse = ''
    ),
    '</div>',
    '</div>'
  )
}

render_scale_legend_latex <- function(spec) {
  switch(spec$scale_type,
    continuous = render_continuous_legend_latex(spec),
    bins = render_bins_legend_latex(spec),
    quantiles = render_bins_legend_latex(spec),
    discrete = render_discrete_legend_latex(spec),
    rlang::abort(paste0('Unsupported scale type `', spec$scale_type, '` for LaTeX legends.'))
  )
}

render_continuous_legend_latex <- function(spec) {
  title <- if (is.null(spec$title)) '' else paste0('\\textbf{', latex_escape_text(spec$title), '}\\\\')
  swatches <- paste(vapply(spec$palette, latex_color_box, character(1)), collapse = '\\,')
  labels <- paste(latex_escape_text(spec$labels), collapse = ' \\quad ')

  paste0(
    title,
    swatches,
    '\\\\',
    labels
  )
}

render_bins_legend_latex <- function(spec) {
  title <- if (is.null(spec$title)) '' else paste0('\\textbf{', latex_escape_text(spec$title), '}\\\\')
  entries <- paste(
    vapply(
      seq_along(spec$values),
      function(i) {
        paste0(
          latex_color_box(spec$values[[i]]),
          '\\ ',
          latex_escape_text(spec$labels[[i]])
        )
      },
      character(1)
    ),
    collapse = '\\quad '
  )

  paste0(title, entries)
}

render_discrete_legend_latex <- function(spec) {
  title <- if (is.null(spec$title)) '' else paste0('\\textbf{', latex_escape_text(spec$title), '}\\\\')
  entries <- paste(
    vapply(
      seq_along(spec$values),
      function(i) {
        paste0(
          latex_color_box(spec$values[[i]]),
          '\\ ',
          latex_escape_text(spec$labels[[i]])
        )
      },
      character(1)
    ),
    collapse = '\\quad '
  )

  paste0(title, entries)
}

render_scale_legend_word <- function(spec) {
  switch(spec$scale_type,
    continuous = render_continuous_legend_word(spec),
    bins = render_bins_legend_word(spec),
    quantiles = render_bins_legend_word(spec),
    discrete = render_discrete_legend_word(spec),
    rlang::abort(paste0('Unsupported scale type `', spec$scale_type, '` for Word legends.'))
  )
}

word_image_markdown <- function(path) {
  path <- normalizePath(path, winslash = '/', mustWork = TRUE)
  gt::md(paste0('![](', path, ')'))
}

write_word_legend_image <- function(spec, width = 480, height = 120) {
  path <- tempfile(pattern = 'gtscales-word-', fileext = '.png')
  grDevices::png(filename = path, width = width, height = height, bg = 'white')
  on.exit(grDevices::dev.off(), add = TRUE)

  grid::grid.newpage()

  switch(spec$scale_type,
    continuous = draw_continuous_legend_word(spec),
    bins = draw_bins_legend_word(spec),
    quantiles = draw_bins_legend_word(spec),
    discrete = draw_discrete_legend_word(spec),
    rlang::abort(paste0('Unsupported scale type `', spec$scale_type, '` for Word legends.'))
  )

  path
}

render_continuous_legend_word <- function(spec) {
  word_image_markdown(write_word_legend_image(spec, width = 520, height = 130))
}

render_bins_legend_word <- function(spec) {
  word_image_markdown(write_word_legend_image(spec, width = 560, height = 140))
}

render_discrete_legend_word <- function(spec) {
  word_image_markdown(write_word_legend_image(spec, width = 560, height = 160))
}

draw_word_legend_title <- function(title) {
  if (is.null(title) || identical(title, '')) {
    return(invisible(NULL))
  }

  grid::grid.text(
    label = title,
    x = 0.05,
    y = 0.88,
    just = c('left', 'center'),
    gp = grid::gpar(fontsize = 13, fontface = 'bold', col = '#111111')
  )
}

draw_continuous_legend_word <- function(spec) {
  draw_word_legend_title(spec$title)

  bar_left <- 0.07
  bar_right <- 0.93
  bar_bottom <- 0.46
  bar_top <- 0.64
  palette <- grDevices::colorRampPalette(spec$palette)(256)
  raster <- as.raster(matrix(palette, nrow = 1))

  grid::grid.raster(
    image = raster,
    x = (bar_left + bar_right) / 2,
    y = (bar_bottom + bar_top) / 2,
    width = bar_right - bar_left,
    height = bar_top - bar_bottom,
    interpolate = TRUE
  )
  grid::grid.rect(
    x = (bar_left + bar_right) / 2,
    y = (bar_bottom + bar_top) / 2,
    width = bar_right - bar_left,
    height = bar_top - bar_bottom,
    gp = grid::gpar(fill = NA, col = '#BDBDBD', lwd = 1)
  )

  break_positions <- scales::rescale(spec$breaks, to = c(bar_left, bar_right), from = spec$domain)

  for (i in seq_along(spec$labels)) {
    xpos <- break_positions[[i]]
    grid::grid.lines(
      x = grid::unit(c(xpos, xpos), 'npc'),
      y = grid::unit(c(bar_bottom - 0.02, bar_bottom - 0.08), 'npc'),
      gp = grid::gpar(col = '#555555', lwd = 0.8)
    )
    grid::grid.text(
      label = spec$labels[[i]],
      x = xpos,
      y = bar_bottom - 0.15,
      just = 'center',
      gp = grid::gpar(fontsize = 9, col = '#333333')
    )
  }
}

draw_bins_legend_word <- function(spec) {
  draw_word_legend_title(spec$title)

  n <- length(spec$values)
  left <- 0.07
  right <- 0.93
  bottom <- 0.50
  top <- 0.68
  xs <- seq(left, right, length.out = n + 1)

  for (i in seq_len(n)) {
    xmid <- (xs[[i]] + xs[[i + 1]]) / 2
    width <- xs[[i + 1]] - xs[[i]]
    grid::grid.rect(
      x = xmid,
      y = (bottom + top) / 2,
      width = width,
      height = top - bottom,
      gp = grid::gpar(fill = spec$values[[i]], col = '#BDBDBD', lwd = 1)
    )
    grid::grid.text(
      label = spec$labels[[i]],
      x = xmid,
      y = bottom - 0.13,
      just = 'center',
      gp = grid::gpar(fontsize = 8.5, col = '#333333')
    )
  }
}

draw_discrete_legend_word <- function(spec) {
  draw_word_legend_title(spec$title)

  n <- length(spec$values)
  cols <- min(2, n)
  rows <- ceiling(n / cols)
  start_x <- 0.10
  end_x <- 0.90
  start_y <- 0.66
  row_gap <- if (rows > 1) 0.24 else 0
  col_gap <- (end_x - start_x) / cols

  for (i in seq_len(n)) {
    row <- (i - 1) %/% cols
    col <- (i - 1) %% cols
    x_left <- start_x + col * col_gap
    y <- start_y - row * row_gap

    grid::grid.rect(
      x = x_left,
      y = y,
      width = 0.03,
      height = 0.08,
      just = c('left', 'center'),
      gp = grid::gpar(fill = spec$values[[i]], col = '#BDBDBD', lwd = 1)
    )
    grid::grid.text(
      label = spec$labels[[i]],
      x = x_left + 0.045,
      y = y,
      just = c('left', 'center'),
      gp = grid::gpar(fontsize = 9.5, col = '#333333')
    )
  }
}

render_scale_legend_typst <- function(spec) {
  switch(spec$scale_type,
    continuous = render_continuous_legend_typst(spec),
    bins = render_bins_legend_typst(spec),
    quantiles = render_bins_legend_typst(spec),
    discrete = render_discrete_legend_typst(spec),
    rlang::abort(paste0('Unsupported scale type `', spec$scale_type, '` for Typst legends.'))
  )
}

render_continuous_legend_typst <- function(spec) {
  title <- if (is.null(spec$title)) {
    ''
  } else {
    paste0('[*', typst_escape_text(spec$title), '*],')
  }

  labels <- paste(
    vapply(spec$labels, function(x) paste0('[', typst_escape_text(x), ']'), character(1)),
    collapse = ', '
  )
  gradient_stops <- paste(vapply(spec$palette, typst_color, character(1)), collapse = ', ')

  paste0(
    '#stack(dir: ttb, spacing: 0.35em, ',
    title,
    'rect(',
    'width: 14em, ',
    'height: 0.9em, ',
    'radius: 2pt, ',
    'stroke: 0.5pt + rgb("#D0D7DE"), ',
    'fill: gradient.linear(', gradient_stops, ', relative: "self")',
    '),',
    'box(width: 14em, stack(dir: ltr, spacing: 1fr, ', labels, ')))'
  )
}

render_bins_legend_typst <- function(spec) {
  title <- if (is.null(spec$title)) {
    ''
  } else {
    paste0('[*', typst_escape_text(spec$title), '*],')
  }
  entries <- paste(
    vapply(
      seq_along(spec$values),
      function(i) {
        paste0(
          'stack(dir: ltr, spacing: 0.35em, ',
          typst_color_box(spec$values[[i]]), ', ',
          '[', typst_escape_text(spec$labels[[i]]), '])'
        )
      },
      character(1)
    ),
    collapse = ', '
  )

  paste0(
    '#stack(dir: ttb, spacing: 0.35em, ',
    title,
    'stack(dir: ltr, spacing: 0.9em, ', entries, '))'
  )
}

render_discrete_legend_typst <- function(spec) {
  title <- if (is.null(spec$title)) {
    ''
  } else {
    paste0('[*', typst_escape_text(spec$title), '*],')
  }
  entries <- paste(
    vapply(
      seq_along(spec$values),
      function(i) {
        paste0(
          'stack(dir: ltr, spacing: 0.35em, ',
          typst_color_box(spec$values[[i]]), ', ',
          '[', typst_escape_text(spec$labels[[i]]), '])'
        )
      },
      character(1)
    ),
    collapse = ', '
  )

  paste0(
    '#stack(dir: ttb, spacing: 0.35em, ',
    title,
    'stack(dir: ltr, spacing: 0.9em, ', entries, '))'
  )
}

attach_scale_legend <- function(data, spec, output = NULL, placement = NULL) {
  output <- rlang::`%||%`(output, spec$legend$output)
  placement <- rlang::`%||%`(placement, spec$legend$placement)
  rendered <- render_scale_legend(spec = spec, output = output)

  if (identical(placement, 'source_note')) {
    return(attach_legend_note(data, rendered))
  }

  rlang::abort(paste0('Legend placement `', placement, '` is not implemented yet.'))
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

  if (identical(spec$color_method, 'numeric')) {
    data_color_args$palette <- spec$palette
    data_color_args$domain <- spec$domain
    data_color_args$fn <- spec$fn
  } else if (identical(spec$color_method, 'bin')) {
    data_color_args$palette <- spec$palette
    data_color_args$domain <- spec$domain
    data_color_args$bins <- spec$bins
  } else if (identical(spec$color_method, 'quantile')) {
    data_color_args$palette <- spec$palette
    data_color_args$quantiles <- spec$quantiles
  } else if (identical(spec$color_method, 'factor')) {
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
