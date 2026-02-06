# Read data from mort.soa.org and return a list of data frames

Read data from mort.soa.org and return a list of data frames

## Usage

``` r
read_mort_soa(table_id)
```

## Arguments

- table_id:

  An identification number for a mortality table on \<mort.soa.org\>

## Value

A list containing any tables associated with `table_id` plus the
metadata attributes described above. Individual tables are data frames
(tibbles).

## Details

This function first checks if the provided `table_id` is available on
mort.soa.org. If not found, an error is returned.

If a match is found, a list containing all tables underneath `table_id`
is returned. The list contains several attributes that can be queried
using `attr({list}, "{attribute})`. Available attributes include:

- `name` - Name of the table

- `table_id`

- `description` - A detailed description of the table

- `usage` - Intended usage

- `layout` - Table layout

- `nation` - Nation of origin

- `sub_descriptions` - A character vector containing detailed
  descriptions for each sub-table underneath `table_id`

Most tables have either an "Aggregate" or "Select and Ultimate"
structure.

- Aggregate structures contains a single table with one dimension
  (usually Age).

- Select and Ultimate structures contain two tables. The first table
  contains two dimensions for Age and Duration. The second table
  contains a single dimension for Age.

For convenience, any two-dimensional tables are pivoted longer into a
"tidy" format with 3 columns: Age, Duration, and the mortality (or
other) rate.

## References

Society of Actuaries Mortality and Other Rate Tables
<https://mort.soa.org>

## See also

[`filter_inventory()`](https://mattheaphy.github.io/mortSOA/reference/filter_inventory.md)

## Examples

``` r
# Get table #2586: 2012 IAM Period Table – Female, ANB
read_mort_soa(2586)
#> [[1]]
#> # A tibble: 121 × 2
#>      age       qx
#>    <dbl>    <dbl>
#>  1     0 0.00162 
#>  2     1 0.000405
#>  3     2 0.000259
#>  4     3 0.000179
#>  5     4 0.000137
#>  6     5 0.000125
#>  7     6 0.000117
#>  8     7 0.00011 
#>  9     8 0.000095
#> 10     9 0.000088
#> # ℹ 111 more rows
#> 
#> attr(,"name")
#> [1] "2012 IAM Period Table – Female, ANB"
#> attr(,"table_id")
#> [1] "2586"
#> attr(,"description")
#> [1] "2012 Individual Annuity Mortality Period Table – Female. Basis: Age Nearest Birthday. Minimum Age: 0. Maximum Age: 120"
#> attr(,"usage")
#> [1] "Annuitant Mortality"
#> attr(,"layout")
#> [1] "Aggregate"
#> attr(,"nation")
#> [1] "United States of America"
#> attr(,"sub_descriptions")
#> [1] "2012 Individual Annuity Mortality Period Table – Female. Basis: Age Nearest Birthday. Minimum Age: 0. Maximum Age: 120"
```
