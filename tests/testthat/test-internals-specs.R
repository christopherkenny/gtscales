test_that('continuous specs store application and legend metadata', {
  spec <- gtscale_spec_continuous(
    num,
    palette = c('#A0442C', 'white', '#0063B1'),
    title = 'Value'
  ) |>
    gtscale_spec_set_application(
      apply_to = 'text',
      reverse = TRUE,
      contrast_algo = 'wcag'
    ) |>
    gtscale_spec_set_legend(
      output = 'contextual',
      placement = 'source_note'
    )

  expect_s3_class(spec, 'gtscale_spec')
  expect_equal(spec$application$apply_to, 'text')
  expect_true(spec$application$reverse)
  expect_equal(spec$application$contrast_algo, 'wcag')
  expect_equal(spec$legend$output, 'contextual')
  expect_equal(spec$legend$placement, 'source_note')
})

test_that('contextual source-note legends render in latex', {
  spec <- gtscale_spec_continuous(
    num,
    palette = c('#A0442C', 'white', '#0063B1'),
    title = 'Value'
  ) |>
    gtscale_spec_set_legend(output = 'contextual')

  tbl <- gtscale_apply_legend(gt::gt(gt::exibble), spec)
  latex <- as.character(gt::as_latex(tbl))

  expect_match(latex, '\\\\textbf\\{Value\\}', perl = TRUE)
  expect_match(latex, 'A0442C', fixed = TRUE)
  expect_match(latex, 'FFFFFF', fixed = TRUE)
})

test_that('contextual source-note legends render in word xml', {
  spec <- gtscale_spec_continuous(
    num,
    palette = c('#A0442C', 'white', '#0063B1'),
    title = 'Value'
  ) |>
    gtscale_spec_set_legend(output = 'contextual')

  tbl <- gtscale_legend(gt::gt(gt::exibble), spec)
  word_note <- as.character(tbl[['_source_notes']][[1]]$word)
  word <- gt::as_word(tbl)

  expect_match(word_note, '![](', fixed = TRUE)
  expect_match(word, 'w:drawing', fixed = TRUE)
})

test_that('unimplemented html placements fail explicitly', {
  spec <- gtscale_spec_discrete(
    status,
    values = c('#2166ac', '#f7f7f7', '#b2182b'),
    labels = c('Safe D', 'Toss-up', 'Safe R'),
    title = 'Race rating'
  ) |>
    gtscale_spec_set_legend(output = 'html', placement = 'stub')

  expect_error(
    gtscale_legend(gt::gt(data.frame(status = c('Safe D', 'Toss-up', 'Safe R'))), spec),
    'Legend placement `stub` is not implemented yet.'
  )
})

test_that('subtitle placement stores contextual legend content in table heading', {
  spec <- gtscale_spec_bins(
    num,
    palette = c('#f7fbff', '#08306b'),
    bins = c(0, 1, 2, 3, 4),
    domain = c(0, 4),
    title = 'Legend'
  ) |>
    gtscale_spec_set_legend(output = 'contextual', placement = 'subtitle')

  tbl <- gtscale_legend(gt::gt(data.frame(num = 1:4)), spec)

  expect_length(tbl[['_source_notes']], 0)
  expect_type(tbl[['_heading']]$subtitle, 'list')
  expect_match(tbl[['_heading']]$subtitle$html, 'Legend')
  expect_match(tbl[['_heading']]$subtitle$latex, 'Legend')
})

test_that('subtitle placement can compose legends inline', {
  tbl <- gt::gt(data.frame(a = 1:3, b = 4:6)) |>
    gtscale_legend(
      gtscale_spec_continuous(a, palette = c('#f7fbff', '#08306b'), title = 'A') |>
        gtscale_spec_set_legend(placement = 'subtitle', layout = 'inline')
    ) |>
    gtscale_legend(
      gtscale_spec_continuous(b, palette = c('#fff5eb', '#7f2704'), title = 'B') |>
        gtscale_spec_set_legend(placement = 'subtitle', layout = 'inline')
    )

  expect_type(tbl[['_heading']]$subtitle, 'list')
  expect_match(tbl[['_heading']]$subtitle$html, 'A')
  expect_match(tbl[['_heading']]$subtitle$html, 'B')
})

test_that('public spec workflow can color and legendize a table', {
  spec <- gtscale_spec_bins(
    currency,
    palette = c('#f7fbff', '#08306b'),
    bins = c(0, 10, 100, 1000, 10000, 70000),
    title = 'Currency bins'
  )

  tbl <- gt::gt(gt::exibble) |>
    gtscale_apply_legend(spec)

  expect_s3_class(tbl, 'gt_tbl')
  expect_match(tbl[['_source_notes']][[1]]$html, 'Currency bins')
  expect_match(tbl[['_source_notes']][[1]]$latex, 'Currency bins')
  expect_match(tbl[['_source_notes']][[1]]$word, '![](', fixed = TRUE)
  expect_match(gt::as_word(tbl), 'w:drawing', fixed = TRUE)
})

test_that('diverging specs apply midpoint-aware legends', {
  spec <- gtscale_spec_diverging(
    net,
    palette = c('#2166AC', '#B2182B'),
    domain = c(-10, 10),
    midpoint = 0,
    title = 'Net'
  )

  tbl <- gt::gt(data.frame(net = c(-10, 0, 10))) |>
    gtscale_apply_legend(spec)

  note <- tbl[['_source_notes']][[1]]

  expect_match(note$html, '#2166AC', ignore.case = TRUE)
  expect_match(note$html, '#FFFFFF', ignore.case = TRUE)
  expect_match(note$html, '#B2182B', ignore.case = TRUE)
  expect_match(note$html, '>0<', perl = TRUE)
})

test_that('continuous specs support transformed scales', {
  spec <- gtscale_spec_continuous(
    value,
    palette = c('#f7fbff', '#08306b'),
    domain = c(1, 1000),
    transform = 'log10',
    breaks = c(1, 10, 100, 1000),
    title = 'Log scale'
  )

  tbl <- gt::gt(data.frame(value = c(1, 10, 100, 1000))) |>
    gtscale_apply_legend(spec)

  note <- tbl[['_source_notes']][[1]]

  expect_match(note$html, '>1<', perl = TRUE)
  expect_match(note$html, '>1,000<', perl = TRUE)
  expect_match(gt::as_raw_html(tbl), '#08306b', ignore.case = TRUE)
})

test_that('shared-column specs infer domains across multiple columns', {
  spec <- gtscale_spec_continuous(
    c(a, b),
    palette = c('#f7fbff', '#08306b'),
    title = 'Shared'
  )

  tbl <- gt::gt(data.frame(a = c(0, 5), b = c(10, 15))) |>
    gtscale_apply_legend(spec)

  note <- tbl[['_source_notes']][[1]]

  expect_match(note$html, '>0<', perl = TRUE)
  expect_match(note$html, '>15<', perl = TRUE)
})

test_that('named palettes can be resolved for numeric and discrete specs', {
  continuous_spec <- gtscale_spec_continuous(
    value,
    palette = 'viridis',
    domain = c(0, 1),
    title = 'Named palette'
  )
  discrete_spec <- gtscale_spec_discrete(
    status,
    values = 'Okabe-Ito',
    labels = c('A', 'B', 'C'),
    title = 'Discrete palette'
  )

  continuous_final <- finalize_scale_spec(continuous_spec, gt::gt(data.frame(value = c(0, 1))))
  discrete_final <- finalize_scale_spec(discrete_spec, gt::gt(data.frame(status = c('A', 'B', 'C'))))

  expect_gt(length(continuous_final$palette), 1)
  expect_equal(length(discrete_final$values), 3)
  expect_false(anyNA(discrete_final$values))
})

test_that('legend specs can show explicit missing-value entries', {
  spec <- gtscale_spec_discrete(
    status,
    values = c('#2166ac', '#b2182b'),
    labels = c('Safe D', 'Safe R'),
    title = 'Race rating'
  ) |>
    gtscale_spec_set_legend(
      output = 'contextual',
      show_na = TRUE,
      na_label = 'No rating',
      na_color = '#BBBBBB'
    )

  tbl <- gt::gt(data.frame(status = c('Safe D', 'Safe R', NA))) |>
    gtscale_legend(spec)

  note <- tbl[['_source_notes']][[1]]

  expect_match(note$html, 'No rating')
  expect_match(note$html, '#BBBBBB', ignore.case = TRUE)
  expect_match(note$latex, 'No rating')
  expect_match(note$latex, 'BBBBBB', fixed = TRUE)
})

test_that('accessibility warnings can be requested from specs', {
  spec <- gtscale_spec_continuous(
    num,
    palette = c('#FFFFFF', '#FEFEFE'),
    title = 'Low contrast'
  ) |>
    gtscale_spec_set_application(accessibility = 'warn')

  expect_warning(
    finalize_scale_spec(spec, gt::gt(data.frame(num = c(0, 1)))),
    'low contrast'
  )
})

test_that('public spec workflow can render typst legends', {
  spec <- gtscale_spec_continuous(
    num,
    palette = c('#fdd49e', '#fdbb84', '#ef6548', '#990000'),
    breaks = c(0, 18, 444, 8880000),
    title = 'Quartiles'
  )

  typst <- gtscale_render_legend(
    spec = spec,
    data = gt::gt(gt::exibble),
    output = 'typst'
  )

  expect_match(typst, '#stack\\(dir: ttb', perl = TRUE)
  expect_match(typst, '\\[\\*Quartiles\\*\\]', perl = TRUE)
  expect_match(typst, 'gradient\\.linear\\(', perl = TRUE)
  expect_match(typst, 'relative: "self"', fixed = TRUE)
  expect_match(typst, 'rgb\\("#FDD49E"\\)', perl = TRUE)
  expect_match(typst, 'rgb\\("#990000"\\)', perl = TRUE)
})
