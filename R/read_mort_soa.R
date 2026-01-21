#' Read data from mort.soa.org
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
#' @returns An R object
#' @export
read_mort_soa <- function(table_id) {
  resp <- httr2::request("https://mort.soa.org") |>
    httr2::req_url_path_append("Export.aspx") |>
    httr2::req_url_query(Type = "xml", TableIdentity = table_id) |>
    httr2::req_perform()

  tryCatch(
    xml <- resp |> httr2::resp_body_xml(),
    error = function(e) {
      cli::cli_abort(
        "Table #{table_id} is not available on {.url https://mort.soa.org}"
      )
    }
  )

  # Child item 1 = meta data
  name <- xml |>
    xml2::xml_child(1) |>
    xml2::xml_find_all(".//TableName") |>
    xml2::xml_text()

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

    # Child item 2 = table
    qx <- xml2::xml_child(xml, 2) |>
      xml2::xml_find_all(".//Y") |>
      xml2::xml_double()

    dat <- do.call(tidyr::expand_grid, rev(axes)) |>
      dplyr::as_tibble() |>
      dplyr::mutate(qx = qx)

    attr(dat, "description") <- meta |>
      xml2::xml_find_all(".//TableDescription") |>
      xml2::xml_text()
    dat
  }

  tbls <- xml2::xml_find_all(xml, "Table")
  res <- purrr::map(tbls, xml_to_df)
  attr(res, "name") <- name
  res
}
