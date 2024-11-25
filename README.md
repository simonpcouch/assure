
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ensure

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/ensure)](https://CRAN.R-project.org/package=ensure)
[![R-CMD-check](https://github.com/simonpcouch/ensure/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simonpcouch/ensure/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The ensure package provides an addin for drafting testthat unit
testing code using LLMs. Triggering the addin will open a corresponding
test file and begin writing tests into it. The ensure *ensurer*
is familiar with testthat 3e as well as tidy style, and incorporates
context from the rest of your R package to write concise and relevant
tests.

## Installation

You can install ensure like so:

``` r
pak::pak("simonpcouch/ensure")
```

Then, ensure that you have an
[`ANTHROPIC_API_KEY`](https://console.anthropic.com/) environment
variable set, and you’re ready to go. If you’d like to use an LLM other
than Anthropic’s Claude 3.5 Sonnet—like OpenAI’s ChatGPT—to power the
ensurer, see the `ensurer()` documentation.

The ensurer is interfaced with the via the RStudio addin
“ensure: Test R code.” For easiest access, we recommend registering
the ensure addin to a keyboard shortcut. **In RStudio**, navigate to
`Tools > Modify Keyboard Shortcuts > Search "ensure"`—we suggest
`Ctrl+Alt+T` (or `Ctrl+Cmd+T` on macOS). The ensurer is currently
not available in Positron as Positron has yet to implement document
`id`s that ensure needs to toggle between source and test files.

Once those steps are completed, you’re ready to use the ensure addin
with a keyboard shortcut.

## Example

To use the ensurer, just trigger the addin (optionally selecting
some code to only write tests for a certain portion of the file) and
watch your testing code be written.

![](https://raw.githubusercontent.com/simonpcouch/ensure/refs/heads/main/inst/figs/ensure.gif)
