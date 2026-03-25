# gtscales: Scale legends for gt tables

`gtscales` adds compact legends to color-encoded `gt` tables.

## Details

The package supports two complementary workflows:

- wrapper helpers like
  [`gtscale_data_color_continuous()`](http://christophertkenny.com/gtscales/reference/gtscale_data_color_continuous.md)
  for the common "color and add a matching legend" path

- reusable spec objects built with `gtscale_spec_*()` for more
  composable workflows

The spec workflow is intended to support future output backends beyond
HTML, including formats such as LaTeX and Typst.

## Author

**Maintainer**: Christopher T. Kenny <ctkenny@proton.me>
([ORCID](https://orcid.org/0000-0002-9386-6860))
