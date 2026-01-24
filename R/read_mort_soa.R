#' Read data from mort.soa.org
#'
#'
#'
#' @details
#' This function first checks if the provided `table_id` is available on
#' mort.soa.org. If not found, an error is returned.
#'
#' If a match is found, a list containing all tables underneath `table_id` is
#' returned. The list contains several attributes that can be queried using
#' `attr({list}, "{attribute})`. Available attributes include:
#'
#' - `name` - Name of the table
#' - `table_id`
#' - `description` - A detailed description
#' - `usage` - Intended usage
#' - `layout` - Table layout
#' - `nation` - Nation of origin
#' - `sub_descriptions` - A vector containing detailed descriptions for each
#'   sub-table underneath `table_id`
#'
#' ## Table layout values
#'
#' - TODO
#'
#'
#' @param table_id An identification number for a mortality table on
#' <mort.soa.org>
#'
#' @references Society of Actuaries Mortality and Other Rate Tables
#' <https://mort.soa.org>
#'
#' @examples
#' if (interactive()) {
#'   # Get table #2586: 2012 IAM Period Table – Female, ANB
#'   read_mort_soa(2586)
#' }
#'
#' @returns A list containing any tables associated with `table_id` with
#'   metadata attributes described above.
#' @export
read_mort_soa <- function(table_id) {
  xml <- check_get_xml(table_id)
  content_meta <- extract_content_meta(xml)
  tbls <- xml2::xml_find_all(xml, "Table")
  res <- purrr::map(tbls, xml_to_df)
  content_meta$sub_descriptions <- purrr::map_chr(res, \(x) {
    attr(x, "description")
  })
  attributes(res) <- content_meta
  res
}

check_get_xml <- function(table_id) {
  resp <- httr2::request("https://mort.soa.org") |>
    httr2::req_url_path_append("Export.aspx") |>
    httr2::req_url_query(Type = "xml", TableIdentity = table_id) |>
    httr2::req_perform()

  tryCatch(
    resp |> httr2::resp_body_xml(),
    error = function(e) {
      cli::cli_abort(
        "Table #{table_id} is not available on {.url https://mort.soa.org}"
      )
    }
  )
}

extract_content_meta <- function(xml) {
  # Child item 1 = meta data
  content_meta <- xml |> xml2::xml_child(1)
  content_meta <- c(
    name = "TableName",
    table_id = "TableIdentity",
    description = "TableDescription",
    usage = "ContentType",
    kw = "KeyWord"
  ) |>
    get_meta(meta = content_meta)
  content_meta$layout <- content_meta$kw[[1]]
  content_meta$nation <- content_meta$kw[[length(content_meta$kw)]]
  content_meta$kw <- NULL
  content_meta
}

get_meta <- \(x, meta) {
  x |>
    # purrr::set_names() |>
    purrr::map(\(y) {
      xml2::xml_find_all(meta, paste0(".//", y)) |> xml2::xml_text()
    })
}

xml_to_df <- function(xml) {
  # Table child item 1 = meta data
  meta <- xml2::xml_child(xml, 1)
  # Get axis definitions
  axis_def <- xml2::xml_find_all(meta, "AxisDef") |> xml2::as_list()
  axes <- list()
  for (x in axis_def) {
    axes[[x$AxisName[[1]]]] <- seq.int(
      as.numeric(x$MinScaleValue[[1]]),
      as.numeric(x$MaxScaleValue[[1]]),
      by = as.numeric(x$Increment[[1]])
    )
  }

  qx <- xml2::xml_child(xml, 2) |>
    xml2::xml_find_all(".//Y") |>
    xml2::xml_double()

  dat <- do.call(tidyr::expand_grid, rev(axes)) |>
    dplyr::as_tibble() |>
    dplyr::mutate(qx = qx)

  attr(dat, "description") <- get_meta("TableDescription", meta)[[1]]

  dat
}
