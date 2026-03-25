legend_plot <- function(colors, labels, title = NULL) {
  grid::grid.newpage()

  if (!is.null(title)) {
    grid::grid.text(
      label = title,
      x = 0.02,
      y = 0.92,
      just = c("left", "center"),
      gp = grid::gpar(fontface = "bold", cex = 0.9)
    )
  }

  n <- length(colors)
  x_positions <- (seq_len(n) - 0.5) / n

  grid::grid.rect(
    x = x_positions,
    y = 0.58,
    width = 0.9 / n,
    height = 0.22,
    gp = grid::gpar(fill = colors, col = "#d0d7de")
  )

  grid::grid.text(
    label = labels,
    x = x_positions,
    y = 0.28,
    gp = grid::gpar(cex = 0.75)
  )
}

test_that("quantile palette interpolation has a stable visual sequence", {
  testthat::skip_if_not_installed("vdiffr")

  colors <- gtscales:::resolve_quantile_colors(
    palette = c("#fff5eb", "#7f2704"),
    n_intervals = 4
  )

  vdiffr::expect_doppelganger(
    "quantile-interpolated-colors",
    legend_plot(
      colors = colors,
      labels = c("Q1", "Q2", "Q3", "Q4"),
      title = "Quantile colors"
    )
  )
})

test_that("explicit quantile palette remains visually discrete", {
  testthat::skip_if_not_installed("vdiffr")

  vdiffr::expect_doppelganger(
    "quantile-explicit-colors",
    legend_plot(
      colors = c("#fdd49e", "#fdbb84", "#ef6548", "#990000"),
      labels = c("Q1", "Q2", "Q3", "Q4"),
      title = "Quartiles"
    )
  )
})

test_that("discrete legend palette order is visually stable", {
  testthat::skip_if_not_installed("vdiffr")

  vdiffr::expect_doppelganger(
    "discrete-race-rating-colors",
    legend_plot(
      colors = c("#2166ac", "#f7f7f7", "#ef8a62", "#b2182b"),
      labels = c("Safe D", "Toss-up", "Lean R", "Safe R"),
      title = "Race rating"
    )
  )
})
