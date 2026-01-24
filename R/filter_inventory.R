#' Filter the inventory of tables
#'
#' Filter the [table_inventory] by keywords to find table identification numbers
#' quickly.
#'
#' @details
#' The mort.soa.org site contains a large number of tables indexed by
#' identification numbers. The `mortSOA` package includes a data set called
#' [table_inventory] that contains all available tables as of
#' `r attr(table_inventory, "as_of")`. This function can be used to filter that
#' table by name using keywords passed to the `...` argument. Filtering is
#' accomplished using [grepl()], so regular expressions are accepted.
#'
#' Multiple calls to `filter_inventory()` can be chained together using the pipe
#' operator.
#'
#' @param ... Keywords or regular expressions used to filter the
#'   [table_inventory] data set by the `name` column. Alternatively, the first
#'   argument passed to `...` can be a data frame containing a column called
#'   name. This feature allows [filter_inventory()] to be called in succession
#'   using the pipe operator.
#' @param type Type of filtering performed. If "and", names must match all
#'   expressions passed to `...`. If "or", names must match at least one
#'   expression passed to `...`.
#'
#' @examples
#' filter_inventory("2012 IAM", "Female")
#' # Same result using a regular expression
#' filter_inventory("2012 IAM.*Female")
#' # Chained version with type = "or"
#' filter_inventory("Pri-2012", "Retiree") |>
#'   filter_inventory("Blue", "White", type = "or")
#'
#' @returns A data frame (tibble)
#' @export
filter_inventory <- function(
  ...,
  type = c("and", "or")
) {
  patterns <- list(...)
  if (is.data.frame(patterns[[1]])) {
    dat <- patterns[[1]]
    if (!"name" %in% names(dat)) {
      cli::cli_abort(c(
        "If the first item passed to `patterns` is a data frame, then ",
        "it must contain a column called name"
      ))
    }
    patterns <- patterns[-1L]
  } else {
    dat <- table_inventory
  }
  type <- rlang::arg_match(type)
  funs <- lapply(patterns, \(x) \(y) grepl(x, y))
  if_fun <- switch(type, "and" = dplyr::if_all, "or" = dplyr::if_any)

  dat |> dplyr::filter(if_fun(name, funs))
}
