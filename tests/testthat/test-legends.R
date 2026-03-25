test_that("continuous legends use comma labels by default", {
  tbl <- gt::gt(data.frame(value = c(1000, 5000, 10000))) |>
    gtscale_data_color_continuous(
      column = value,
      domain = c(1000, 10000),
      palette = c("#A0442C", "white", "#0063B1"),
      breaks = c(1000, 5000, 10000),
      title = "Value"
    )

  note <- tbl[["_source_notes"]][[1]]

  expect_s3_class(tbl, "gt_tbl")
  expect_match(note$html, "Value")
  expect_match(note$html, "1,000")
  expect_match(note$html, "10,000")
  expect_match(note$latex, "1,000", fixed = TRUE)
})

test_that("binned legends apply label functions to boundaries", {
  tbl <- gt::gt(data.frame(share = c(0.1, 0.4, 0.7, 0.9))) |>
    gtscale_data_color_bins(
      column = share,
      palette = c("#f7fbff", "#08306b"),
      bins = c(0, 0.25, 0.5, 0.75, 1),
      domain = c(0, 1),
      labels = scales::label_percent(),
      title = "Share bins"
    )

  note <- tbl[["_source_notes"]][[1]]

  expect_match(note$html, "0% - 25%")
  expect_match(note$html, "75% - 100%")
  expect_match(note$latex, "0\\\\% - 25\\\\%", perl = TRUE)
})

test_that("quantile legends interpolate colors across quantile groups", {
  tbl <- gt::gt(gt::exibble) |>
    gtscale_color_quantiles(
      column = num,
      palette = c("#fff5eb", "#7f2704"),
      quantiles = 4,
      title = "Quartiles"
    )

  note <- tbl[["_source_notes"]][[1]]
  expected_colors <- gtscales:::resolve_quantile_colors(
    palette = c("#fff5eb", "#7f2704"),
    n_intervals = 4
  )

  expect_s3_class(tbl, "gt_tbl")
  expect_length(unique(expected_colors), 4)

  for (clr in expected_colors) {
    expect_match(note$html, clr, fixed = TRUE)
  }
})

test_that("legend helpers validate required inputs", {
  expect_error(
    gt::gt(gt::exibble) |>
      gtscale_color_continuous(),
    "Supply either `palette` or `fn`"
  )

  expect_error(
    gt::gt(gt::exibble) |>
      gtscale_color_bins(
        column = currency,
        palette = c("#f7fbff", "#08306b"),
        bins = c(0, 10)
      ),
    "`bins` must span the full `domain`"
  )
})

test_that("discrete wrappers add legend notes", {
  tbl <- data.frame(
    district = c("A", "B", "C"),
    status = c("Safe D", "Toss-up", "Safe R")
  ) |>
    gt::gt() |>
    gtscale_data_color_discrete(
      column = status,
      values = c("#2166ac", "#f7f7f7", "#b2182b"),
      labels = c("Safe D", "Toss-up", "Safe R"),
      title = "Race rating"
    )

  note <- tbl[["_source_notes"]][[1]]

  expect_s3_class(tbl, "gt_tbl")
  expect_match(note$html, "Race rating")
  expect_match(note$html, "Safe D")
  expect_match(note$html, "#2166ac", ignore.case = TRUE)
  expect_match(note$latex, "2166AC", fixed = TRUE)
})

test_that("latex export includes legend content from wrapper workflows", {
  tbl <- gt::gt(gt::exibble) |>
    gtscale_data_color_continuous(
      column = num,
      palette = c("#A0442C", "white", "#0063B1"),
      title = "Numeric scale"
    )

  latex <- as.character(gt::as_latex(tbl))

  expect_match(latex, "\\\\textbf\\{Numeric scale\\}", perl = TRUE)
  expect_match(latex, "A0442C", fixed = TRUE)
  expect_match(latex, "FFFFFF", fixed = TRUE)
  expect_match(latex, "0063B1", fixed = TRUE)
})
