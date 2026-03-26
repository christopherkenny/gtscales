validate_gt_tbl <- function(data) {
  if (!inherits(data, 'gt_tbl')) {
    rlang::abort('`data` must be a `gt_tbl` created by `gt::gt()`.')
  }
}

gt_data_get <- function(data) {
  validate_gt_tbl(data)
  data[['_data']]
}

attach_legend_note <- function(data, html) {
  source_note <- if (is.list(html)) html else gt::html(html)

  gt::tab_source_note(
    data = data,
    source_note = source_note
  )
}

attach_legend_subtitle <- function(data, legend) {
  attach_legend_heading(data, legend, field = 'subtitle')
}

attach_legend_title <- function(data, legend) {
  attach_legend_heading(data, legend, field = 'title')
}

attach_legend_heading <- function(data, legend, field = c('title', 'subtitle')) {
  field <- match.arg(field)
  heading <- data[['_heading']]
  title <- heading$title
  subtitle <- heading$subtitle
  updated_value <- legend

  if (!is.null(heading[[field]])) {
    updated_value <- append_contextual_text(
      heading[[field]],
      legend,
      layout = legend_layout_get(legend)
    )
  }

  if (identical(field, 'title')) {
    title <- updated_value
  } else {
    if (is.null(title)) {
      title <- heading_placeholder(updated_value)
    }
    subtitle <- updated_value
  }

  gt::tab_header(
    data = data,
    title = title,
    subtitle = subtitle
  )
}

heading_placeholder <- function(template) {
  if (is.list(template)) {
    placeholder <- list(
      html = gt::html('&nbsp;'),
      latex = gt::latex('~')
    )

    return(placeholder[intersect(names(template), names(placeholder))])
  }

  gt::html('&nbsp;')
}

legend_layout_get <- function(legend) {
  attr(legend, 'gtscales_layout', exact = TRUE) %||% 'stack'
}

set_legend_layout <- function(legend, layout = c('stack', 'inline')) {
  attr(legend, 'gtscales_layout') <- match.arg(layout)
  legend
}

append_contextual_text <- function(existing, addition, layout = c('stack', 'inline')) {
  layout <- match.arg(layout)

  if (is.list(existing) || is.list(addition)) {
    contexts <- unique(c(names(existing), names(addition)))

    return(stats::setNames(
      lapply(
        contexts,
        function(context) {
          existing_value <- if (is.list(existing) && context %in% names(existing)) existing[[context]] else existing
          addition_value <- if (is.list(addition) && context %in% names(addition)) addition[[context]] else addition
          append_contextual_text(existing_value, addition_value, layout = layout)
        }
      ),
      contexts
    ))
  }

  if (inherits(existing, 'html')) {
    separator <- if (identical(layout, 'inline')) {
      '</div><div>'
    } else {
      '</div><div style="margin-top:8px;">'
    }

    return(gt::html(paste0(
      '<div>',
      as.character(existing),
      separator,
      as.character(addition),
      '</div>'
    )))
  }

  if (inherits(existing, 'from_latex')) {
    separator <- if (identical(layout, 'inline')) ' \\qquad ' else '\\\\'
    return(gt::latex(paste0(as.character(existing), separator, as.character(addition))))
  }

  separator <- if (identical(layout, 'inline')) ' | ' else '\n'
  paste0(as.character(existing), separator, as.character(addition))
}
