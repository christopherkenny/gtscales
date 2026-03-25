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
  heading <- data[['_heading']]
  title <- heading$title
  subtitle <- legend

  if (!is.null(heading$subtitle)) {
    subtitle <- append_contextual_text(heading$subtitle, legend)
  }

  gt::tab_header(
    data = data,
    title = title,
    subtitle = subtitle
  )
}

append_contextual_text <- function(existing, addition) {
  if (is.list(existing) || is.list(addition)) {
    contexts <- unique(c(names(existing), names(addition)))

    return(stats::setNames(
      lapply(
        contexts,
        function(context) {
          existing_value <- if (is.list(existing) && context %in% names(existing)) existing[[context]] else existing
          addition_value <- if (is.list(addition) && context %in% names(addition)) addition[[context]] else addition
          append_contextual_text(existing_value, addition_value)
        }
      ),
      contexts
    ))
  }

  if (inherits(existing, 'html')) {
    return(gt::html(paste0(as.character(existing), '<br/>', as.character(addition))))
  }

  if (inherits(existing, 'from_latex')) {
    return(gt::latex(paste0(as.character(existing), '\\\\', as.character(addition))))
  }

  paste0(as.character(existing), '\n', as.character(addition))
}
