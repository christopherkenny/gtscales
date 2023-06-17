if (FALSE) {
  library(gt)

  tbl <- exibble |>
    gt() |>
    data_color(
      method = "numeric",
      palette = c("red", "green")
    ) |>
    tab_source_note(html('<span style="background: #00CCCC;">text inside</span>: discrete')) |>
    tab_source_note(html('<pre><span style="background-color: #FD0E35;">     </span>: or as color</pre>')) |># pre tag to note lose spaces
    tab_source_note(html('<pre> <span style="background: linear-gradient(to right, red, orange, yellow, green, blue, indigo, violet);"    </span>      </pre>'))
tbl
}
