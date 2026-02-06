# Filter the inventory of tables

Filter the
[table_inventory](https://mattheaphy.github.io/mortSOA/reference/table_inventory.md)
by keywords to find table identification numbers quickly.

## Usage

``` r
filter_inventory(..., type = c("and", "or"))
```

## Arguments

- ...:

  Keywords or regular expressions used to filter the
  [table_inventory](https://mattheaphy.github.io/mortSOA/reference/table_inventory.md)
  data set by the `name` column. Alternatively, the first argument
  passed to `...` can be a data frame containing a column called name.
  This feature allows `filter_inventory()` to be called in succession
  using the pipe operator.

- type:

  Type of filtering performed. If "and", names must match all
  expressions passed to `...`. If "or", names must match at least one
  expression passed to `...`.

## Value

A data frame (tibble)

## Details

The mort.soa.org site contains a large number of tables indexed by
identification numbers. The `mortSOA` package includes a data set called
[table_inventory](https://mattheaphy.github.io/mortSOA/reference/table_inventory.md)
that contains all available tables as of 2026-01-24. This function can
be used to filter that table by name using keywords passed to the `...`
argument. Filtering is accomplished using
[`grepl()`](https://rdrr.io/r/base/grep.html), so regular expressions
are accepted.

Multiple calls to `filter_inventory()` can be chained together using the
pipe operator.

## References

Society of Actuaries Mortality and Other Rate Tables
<https://mort.soa.org>

## Examples

``` r
filter_inventory("2012 IAM", "Female")
#> # A tibble: 2 × 6
#>   table_id name                                description   layout usage nation
#>      <int> <chr>                               <chr>         <chr>  <chr> <chr> 
#> 1     2582 2012 IAM Basic Table – Female, ANB  2012 Individ… Aggre… Annu… Unite…
#> 2     2586 2012 IAM Period Table – Female, ANB 2012 Individ… Aggre… Annu… Unite…
# Same result using a regular expression
filter_inventory("2012 IAM.*Female")
#> # A tibble: 2 × 6
#>   table_id name                                description   layout usage nation
#>      <int> <chr>                               <chr>         <chr>  <chr> <chr> 
#> 1     2582 2012 IAM Basic Table – Female, ANB  2012 Individ… Aggre… Annu… Unite…
#> 2     2586 2012 IAM Period Table – Female, ANB 2012 Individ… Aggre… Annu… Unite…
# Chained version with type = "or"
filter_inventory("Pri-2012", "Retiree") |>
  filter_inventory("Blue", "White", type = "or")
#> # A tibble: 4 × 6
#>   table_id name                                 description  layout usage nation
#>      <int> <chr>                                <chr>        <chr>  <chr> <chr> 
#> 1     3549 Pri-2012 Female Retiree Blue Collar  Pri-2012 Am… Aggre… Annu… Unite…
#> 2     3550 Pri-2012 Male Retiree Blue Collar    Pri-2012 Am… Aggre… Annu… Unite…
#> 3     3555 Pri-2012 Female Retiree White Collar Pri-2012 Am… Aggre… Annu… Unite…
#> 4     3556 Pri-2012 Male Retiree White Collar   Pri-2012 Am… Aggre… Annu… Unite…
```
