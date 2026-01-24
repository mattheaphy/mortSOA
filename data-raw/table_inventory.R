## code to prepare `table_inventory` dataset goes here

# Get list of all tables
library(httr2)
library(dplyr)

# Base URL
url <- "https://mort.soa.org/WebService.asmx/GetListOfTables"

# Build the POST body (match jqGrid postData)
body <- list(
  page = 1,
  rows = 10000,
  sidx = "TableIdentity",
  sord = "asc",
  keyWords = "",
  type = -1,
  usage = -1,
  nation = -1
)

# Create and send request
resp <- request(url) |>
  req_method("POST") |>
  req_headers(
    "Content-Type" = "application/json; charset=utf-8"
  ) |>
  req_body_json(body, auto_unbox = TRUE) |>
  req_perform()

# Parse JSON response
resp_json <- resp |>
  resp_body_json(simplifyVector = TRUE)

# jqGrid jsonReader mapping
rows <- resp_json$d$rows

# Convert rows to a data frame
table_inventory <- as_tibble(rows) |>
  rename(
    table_id = TableIdentity,
    name = TableName,
    usage = ContentType,
    nation = Nation,
    layout = Type
  ) |>
  relocate(layout, .before = usage)

# separate out the name and description
table_inventory <- table_inventory |>
  tidyr::separate_wider_delim(
    name,
    delim = "&nbsp;<br/>",
    names = c("name", "description")
  )

attr(table_inventory, "as_of") <- Sys.Date()

usethis::use_data(table_inventory, overwrite = TRUE)
