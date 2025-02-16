#' @title Check a `pop_data` object for requested strata variables
#' @param pop_data a `pop_data` object
#' @param strata a [character] vector
#' @returns [NULL], invisibly
#' @examples
#' sees_pop_data_pk_100 |>
#'   check_strata(strata = c("ag", "catch", "Count")) |>
#'   try()
#' @dev
check_strata <- function(pop_data, strata) {
  if (!is.character(strata)) {
    cli::cli_abort(
      class = "strata are not strings",
      message = c(
        "x" = "Argument `strata` is not a character vector.",
        "i" = "Provide a character vector with names of stratifying variables."
      )
    )
  }

  present_strata_vars <- intersect(strata, names(pop_data))
  missing_strata_vars <- setdiff(strata, present_strata_vars)

  if (length(missing_strata_vars) > 0) {
    message0 <- c(
      "Can't stratify provided {.arg pop_data}
       with the provided {.arg strata}:",
      "i" = "variable {.var {missing_strata_vars}}
             {?is/are} missing in {.arg pop_data}."
    )

    partial_matches <-
      purrr::map(missing_strata_vars, function(x) {
        stringr::str_subset(string = names(pop_data), pattern = x) |>
          glue::backtick() |>
          and::or()
      }) |>
      rlang::set_names(missing_strata_vars) |>
      purrr::keep(~ length(.x) > 0)

    inputs_with_partial_matches <- names(partial_matches) # nolint: object_usage_linter

    if (length(partial_matches) > 0) {
      partial_matches <-
        glue::glue("\"{names(partial_matches)}\": {partial_matches}")

      message0 <- c(
        message0,
        "i" = "The following input{?s} to {.arg strata}
                  might be misspelled:
                  {.str {inputs_with_partial_matches}}",
        "i" = "Did you mean:",
        partial_matches |> rlang::set_names("*")
      )
    }

    cli::cli_abort(
      class = "missing_var",
      call = rlang::caller_env(),
      message = message0
    )
  }

  invisible(NULL)
}
