#' Write unit tests for selected code
#'
#' @description
#' This function queries an LLM to write unit tests for selected R code. To do
#' so, it:
#'
#' * Initializes a [ensurer()]: an ellmer [Chat()][ellmer::Chat()] that knows how
#'   to write testthat unit tests.
#' * Reads the contents of the active `.R` file as well as the current selection.
#' * Opens a corresponding test file (creating it if need be).
#' * Asks the LLM to write unit tests for the current selection, using the
#'   contents of the active `.R` file as context.
#' * Streams the response into the corresponding test file.
#'
#' @returns
#' `TRUE`, invisibly.
#'
#' @export
ensure_that <- function() {
  context <- rstudioapi::getSourceEditorContext()

  check_source(context$path)

  ensurer <- retrieve_ensurer()

  test_lines <- retrieve_test(context$path)

  turn <- assemble_turn(context, test_lines)

  tryCatch(
    stream_inline(
      ensurer = ensurer$clone(),
      turn = turn
    ),
    error = function(e) {
      rstudioapi::showDialog(
        "Error",
        paste("The ensurer ran into an issue: ", e$message)
      )
    }
  )

  invisible(TRUE)
}

assemble_turn <- function(context, test_lines) {
  selection <- rstudioapi::primary_selection(context)$text

  if (identical(selection, "")) {
    res <- c(
      "## Context and Selection",
      "",
      "The context and selection are the same; write tests for the whole file: ",
      "",
      context$contents
    )
  } else {
    res <-
      c(
        "## Context",
        "",
        context$contents,
        "",
        "Now, here's the selection you'll write tests for.",
        "",
        "## Selection",
        "",
        selection
      )
  }

  if (!is.null(test_lines)) {
    res <- c(
      res,
      "",
      "The current tests look like this:",
      "",
      test_lines,
      "",
      "Do your best to pattern-match how the existing tests create objects to test against.",
      ""
    )
  }

  res <- append_neighboring_files(context$path, res)

  res <- c(
    res,
    "Remember to reply with tests for _only_ the provided selection.",
    "Respond with only code; do not prefix the reply with any explanation.",
    "Do not prefix or suffix the code block with backticks."
  )

  paste0(res, collapse = "\n")
}

# TODO: more variables can be replaced with constants here, and logic
# probably simplified further
stream_inline <- function(ensurer, turn) {
  context <- rstudioapi::getSourceEditorContext()
  selection <- context$selection
  selection$range <- initial_range(context)

  output_lines <- character(0)
  stream <- ensurer$stream(turn)
  coro::loop(for (chunk in stream) {
    if (identical(chunk, "")) {next}
    output_lines <- paste(output_lines, chunk, sep = "")
    n_lines <- nchar(gsub("[^\n]+", "", output_lines)) + 1
    if (n_lines < 1) {
      output_padded <-
        paste0(
          output_lines,
          paste0(rep("\n", 2 - n_lines), collapse = "")
        )
    } else {
      output_padded <- paste(output_lines, "\n")
    }

    rstudioapi::modifyRange(
      selection$range,
      output_padded %||% output_lines,
      selection$id
    )

    n_selection <- selection$range$end[[1]] - selection$range$start[[1]]
    n_lines_res <- nchar(gsub("[^\n]+", "", output_padded %||% output_lines))
    if (n_selection < n_lines_res) {
      selection$range$end[["row"]] <- selection$range$start[["row"]] + n_lines_res
    }
  })

  rstudioapi::setCursorPosition(selection$range$start)
}

initial_range <- function(context) {
  n_lines <- length(context$contents)
  last_line_start <- rstudioapi::document_position(n_lines, 1)
  last_line_end <- rstudioapi::document_position(n_lines, 100000)

  rstudioapi::modifyRange(
    rstudioapi::document_range(last_line_start, last_line_end),
    paste0(context$contents[n_lines], "\n"),
    id = context$id
  )

  # TODO: set selection to the "right" place in the test file
  # if it exists--perhaps as an LLM tool call?
  new_loc <- rstudioapi::document_position(n_lines + 1, 1)
  rstudioapi::document_range(new_loc, new_loc)
}
