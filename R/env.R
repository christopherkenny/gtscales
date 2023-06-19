get_palette <- function(fn) {
  rlang::env_get(rlang::get_env(fn), nm = 'palette')
}

get_all_env_vars <- function(x) {
  rlang::env_get_list(rlang::get_env(x), rlang::env_names(rlang::get_env(x)))
}
# list objects in environment
# rlang::env_names(rlang::get_env(fn))
