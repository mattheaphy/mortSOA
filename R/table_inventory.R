#' Inventory of tables from mort.soa.org
#'
#' A complete inventory of available tables on mort.soa.org last updated on
#' `r attr(table_inventory, "as_of")`.
#'
#' @format
#' A `r format(nrow(table_inventory), big.mark = ",")` x
#' `r ncol(table_inventory)` data frame containing an inventory of available
#' tables with the following columns:
#'
#' - `table_id`
#' - `name` - Name of the table
#' - `description` - A detailed description of the table
#' - `layout` - Table layout
#' - `usage` - Intended usage
#' - `nation` - Nation of origin
#'
#' @name table_inventory

NULL
#' @rdname table_inventory
#' "table_inventory"
