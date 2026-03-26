#' Post-process a rendered Word document
#'
#' Repairs image relationships in a `.docx` produced from raw Word OOXML output.
#' In most current `gtscales` Word workflows this should not be necessary, but
#' it is available as a fallback if a rendered `.docx` needs its legend images
#' re-embedded.
#'
#' @param path Path to an existing `.docx` file.
#'
#' @return The input `path`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' out <- file.path(tempdir(), "report.docx")
#' quarto::quarto_render("report.qmd", output_file = out, output_format = "docx")
#' gtscale_postprocess_docx(out)
#' }
gtscale_postprocess_docx <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || identical(path, "")) {
    rlang::abort("`path` must be a single `.docx` file path.")
  }

  if (!file.exists(path)) {
    rlang::abort(paste0("`path` does not exist: ", path))
  }

  if (!identical(tolower(tools::file_ext(path)), "docx")) {
    rlang::abort("`path` must point to a `.docx` file.")
  }

  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  tmp_dir <- tempfile("gtscales-docx-rebuild-")
  dir.create(tmp_dir, recursive = TRUE, showWarnings = FALSE)
  utils::unzip(zipfile = path, exdir = tmp_dir)

  document_path <- file.path(tmp_dir, "word", "document.xml")
  rels_path <- file.path(tmp_dir, "word", "_rels", "document.xml.rels")
  content_types_path <- file.path(tmp_dir, "[Content_Types].xml")
  media_dir <- file.path(tmp_dir, "word", "media")
  dir.create(media_dir, recursive = TRUE, showWarnings = FALSE)

  docx <- xml2::read_xml(document_path)
  rels <- xml2::read_xml(rels_path)

  rel_nodes <- xml2::xml_children(rels)
  rel_ids <- xml2::xml_attr(rel_nodes, "Id")
  rel_nums <- suppressWarnings(as.integer(sub("^rId", "", rel_ids)))
  next_rel_id <- if (all(is.na(rel_nums))) 1L else max(rel_nums, na.rm = TRUE) + 1L

  blip_nodes <- xml2::xml_find_all(
    docx,
    ".//a:blip[@r:embed]",
    ns = c(
      a = "http://schemas.openxmlformats.org/drawingml/2006/main",
      r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    )
  )

  for (blip_node in blip_nodes) {
    embed <- xml2::xml_attr(
      blip_node,
      "r:embed",
      ns = c(r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
    )

    if (grepl("^rId[0-9]+$", embed)) {
      next
    }

    if (!file.exists(embed)) {
      rlang::abort(
        paste0(
          "Cannot repair DOCX because the legend image no longer exists: ",
          embed
        )
      )
    }

    media_name <- gsub("\\s+|_", "", basename(embed))
    media_target <- file.path("media", media_name)
    file.copy(embed, file.path(media_dir, media_name), overwrite = TRUE)

    rel_node <- xml2::xml_add_child(
      rels,
      "Relationship",
      Id = paste0("rId", next_rel_id),
      Type = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
      Target = media_target
    )

    xml2::xml_set_attr(
      blip_node,
      "r:embed",
      paste0("rId", next_rel_id),
      ns = c(r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
    )

    next_rel_id <- next_rel_id + 1L
  }

  # Word drawing ids must be numeric and unique. Pandoc can emit empty ids in
  # raw OOXML blocks, which makes the final document unreadable to Word.
  docpr_nodes <- xml2::xml_find_all(
    docx,
    ".//wp:docPr",
    ns = c(wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing")
  )
  cNvPr_nodes <- xml2::xml_find_all(
    docx,
    ".//pic:cNvPr",
    ns = c(pic = "http://schemas.openxmlformats.org/drawingml/2006/picture")
  )

  next_drawing_id <- 1L
  for (node in c(docpr_nodes, cNvPr_nodes)) {
    xml2::xml_set_attr(node, "id", as.character(next_drawing_id))
    next_drawing_id <- next_drawing_id + 1L
  }

  content_types <- getFromNamespace("create_xml_contents", "gt")()
  xml2::write_xml(docx, document_path)
  xml2::write_xml(rels, rels_path)
  xml2::write_xml(content_types, content_types_path)

  rebuilt_path <- tempfile("gtscales-docx-rebuilt-", fileext = ".docx")
  cur_dir <- getwd()

  on.exit(setwd(cur_dir), add = TRUE)
  on.exit(unlink(tmp_dir, recursive = TRUE, force = TRUE), add = TRUE)
  on.exit(unlink(rebuilt_path, force = TRUE), add = TRUE)

  setwd(tmp_dir)
  utils::zip(
    zipfile = rebuilt_path,
    files = list.files(path = ".", recursive = TRUE, all.files = TRUE, include.dirs = FALSE),
    flags = "-r9X -q"
  )

  file.copy(rebuilt_path, path, overwrite = TRUE)

  invisible(path)
}
