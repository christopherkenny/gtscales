test_that("gtscale_postprocess_docx repairs broken OOXML image embeds", {
  testthat::skip_if_not_installed("rmarkdown")

  tbl <- gt::exibble |>
    gt::gt() |>
    gtscale_data_color_continuous(
      column = num,
      palette = c("#A0442C", "white", "#0063B1"),
      labels = scales::label_number(scale_cut = scales::cut_short_scale()),
      width = "220px",
      title = "Numeric scale"
    )

  out_dir <- tempfile("gtscales-docx-postprocess-")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  md_path <- file.path(out_dir, "table.md")
  docx_path <- file.path(out_dir, "table.docx")
  unzip_dir <- file.path(out_dir, "unzipped")

  word_md_text <- paste(
    "```{=openxml}",
    enc2utf8(gt::as_word(tbl)),
    "```",
    sep = "\n"
  )
  writeLines(word_md_text, md_path, useBytes = TRUE)

  rmarkdown::pandoc_convert(input = md_path, output = docx_path)

  expect_true(file.exists(docx_path))

  utils::unzip(zipfile = docx_path, exdir = unzip_dir)
  broken_rels <- readLines(
    file.path(unzip_dir, "word", "_rels", "document.xml.rels"),
    warn = FALSE,
    encoding = "UTF-8"
  )
  broken_doc <- readLines(
    file.path(unzip_dir, "word", "document.xml"),
    warn = FALSE,
    encoding = "UTF-8"
  )

  expect_false(dir.exists(file.path(unzip_dir, "word", "media")))
  expect_false(any(grepl("relationships/image", broken_rels, fixed = TRUE)))
  expect_true(any(grepl('r:embed="C:/.+gtscales-word-.+\\.png"', broken_doc)))

  unlink(unzip_dir, recursive = TRUE, force = TRUE)

  gtscale_postprocess_docx(docx_path)

  utils::unzip(zipfile = docx_path, exdir = unzip_dir)
  fixed_rels <- readLines(
    file.path(unzip_dir, "word", "_rels", "document.xml.rels"),
    warn = FALSE,
    encoding = "UTF-8"
  )
  fixed_content_types <- readLines(
    file.path(unzip_dir, "[Content_Types].xml"),
    warn = FALSE,
    encoding = "UTF-8"
  )
  fixed_doc <- readLines(
    file.path(unzip_dir, "word", "document.xml"),
    warn = FALSE,
    encoding = "UTF-8"
  )
  media_files <- list.files(file.path(unzip_dir, "word", "media"))

  expect_true(length(media_files) > 0)
  expect_true(any(grepl("relationships/image", fixed_rels, fixed = TRUE)))
  expect_true(any(grepl('Target="media/', fixed_rels, fixed = TRUE)))
  expect_true(any(grepl('Extension="png"', fixed_content_types, fixed = TRUE)))
  expect_true(any(grepl('r:embed="rId', fixed_doc, fixed = TRUE)))
  expect_false(any(grepl('r:embed="C:/.+gtscales-word-.+\\.png"', fixed_doc)))
})
