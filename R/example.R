if (FALSE) {
  library(gt)

  tbl <- exibble |>
    gt(id = 'one') |>
    data_color(
      method = "numeric",
      palette = c("red", "green")
    ) |>
    tab_source_note(html('<span style="background: #00CCCC;">text inside</span>: discrete')) |>
    tab_source_note(html('<pre><span style="background-color: #FD0E35;">     </span>: or as color</pre>')) |># pre tag to note lose spaces
    tab_source_note(html('<pre> <span style="background: linear-gradient(to right, red, orange, yellow, green, blue, indigo, violet);"    </span>      </pre>')) |>
    opt_css(
      ' #one .gt_table {
      overflow: hidden;
      }

      #left {
        float: left;
        width: 180px;
      }

      #right {
        margin-left: 180px;
      background-color: #FD0E35;
      }
      '
    ) |>
    tab_source_note(html('<div id ="right"> <pre> <span style="background: linear-gradient(to right, red, orange, yellow, green, blue, indigo, violet);"    </span>      </pre> </div>'))
  tbl
}
