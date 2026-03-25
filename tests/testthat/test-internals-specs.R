test_that("continuous specs store application and legend metadata", {
  spec <- gtscale_spec_continuous(
    num,
    palette = c("#A0442C", "white", "#0063B1"),
    title = "Value"
  ) |>
    gtscale_spec_set_application(
      apply_to = "text",
      reverse = TRUE,
      contrast_algo = "wcag"
    ) |>
    gtscale_spec_set_legend(
      output = "html",
      placement = "source_note"
    )

  expect_s3_class(spec, "gtscale_spec")
  expect_equal(spec$application$apply_to, "text")
  expect_true(spec$application$reverse)
  expect_equal(spec$application$contrast_algo, "wcag")
  expect_equal(spec$legend$output, "html")
  expect_equal(spec$legend$placement, "source_note")
})

test_that("non-html legend outputs fail explicitly for now", {
  spec <- gtscale_spec_continuous(
    num,
    palette = c("#A0442C", "white", "#0063B1"),
    title = "Value"
  ) |>
    gtscale_spec_set_legend(output = "latex")

  expect_error(
    gtscale_apply_legend(gt::gt(gt::exibble), spec),
    "Legend rendering for LaTeX is not implemented yet."
  )
})

test_that("unimplemented html placements fail explicitly", {
  spec <- gtscale_spec_discrete(
    status,
    values = c("#2166ac", "#f7f7f7", "#b2182b"),
    labels = c("Safe D", "Toss-up", "Safe R"),
    title = "Race rating"
  ) |>
    gtscale_spec_set_legend(output = "html", placement = "stub")

  expect_error(
    gtscale_legend(gt::gt(data.frame(status = c("Safe D", "Toss-up", "Safe R"))), spec),
    "Legend placement `stub` is not implemented yet."
  )
})

test_that("public spec workflow can color and legendize a table", {
  spec <- gtscale_spec_bins(
    currency,
    palette = c("#f7fbff", "#08306b"),
    bins = c(0, 10, 100, 1000, 10000, 70000),
    title = "Currency bins"
  )

  tbl <- gt::gt(gt::exibble) |>
    gtscale_apply_legend(spec)

  expect_s3_class(tbl, "gt_tbl")
  expect_match(tbl[["_source_notes"]][[1]], "Currency bins")
})
