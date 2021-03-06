# R("-e 'str(as.list(Sys.getenv()))' --slave")
R <- function(options, path = tempdir(), env_vars = NULL, ...) {
  options <- paste(
    "--no-site-file", "--no-environ", "--no-save", "--no-restore",
    options)
  r_path <- file.path(R.home("bin"), "R")

  # If rtools has been detected, add it to the path only when running R...
  if (!is.null(get_rtools_path())) {
    old <- add_path(get_rtools_path(), 0)
    on.exit(set_path(old))
  }

  withr::with_dir(path, system_check(r_path, options, c(r_profile(),
                                               r_env_vars(), env_vars), ...))
}

#' Run R CMD xxx from within R
#'
#' @param cmd one of the R tools available from the R CMD interface.
#' @param options a charater vector of options to pass to the command
#' @param path the directory to run the command in.
#' @param env_vars environment variables to set before running the command.
#' @param ... additional arguments passed to \code{\link{system_check}}
#' @return \code{TRUE} if the command succeeds, throws an error if the command
#' fails.
#' @export
RCMD <- function(cmd, options, path = tempdir(), env_vars = NULL, ...) {
  options <- paste(options, collapse = " ")
  R(paste("CMD", cmd, options), path = path, env_vars = env_vars, ...)
}

#' Environment variables to set when calling R
#'
#' Devtools sets a number of environmental variables to ensure consistent
#' between the current R session and the new session, and to ensure that
#' everything behaves the same across systems. It also suppresses a common
#' warning on windows, and sets \code{NOT_CRAN} so you can tell that your
#' code is not running on CRAN. If \code{NOT_CRAN} has been set externally, it
#' is not overwritten.
#'
#' @keywords internal
#' @return a named character vector
#' @export
r_env_vars <- function() {
  vars <- c(
    "R_LIBS" = paste(.libPaths(), collapse = .Platform$path.sep),
    "CYGWIN" = "nodosfilewarning",
    # When R CMD check runs tests, it sets R_TESTS. When the tests
    # themselves run R CMD xxxx, as is the case with the tests in
    # devtools, having R_TESTS set causes errors because it confuses
    # the R subprocesses. Un-setting it here avoids those problems.
    "R_TESTS" = "",
    "R_BROWSER" = "false",
    "R_PDFVIEWER" = "false",
    "TAR" = auto_tar())

  if (is.na(Sys.getenv("NOT_CRAN", unset = NA))) {
    vars[["NOT_CRAN"]] <- "true"
  }

  vars
}

# Create a temporary .Rprofile based on the current "repos" option
# and return a named vector that corresponds to environment variables
# that need to be set to use this .Rprofile
r_profile <- function() {
  tmp_user_profile <- file.path(tempdir(), "Rprofile-devtools")
  tmp_user_profile_con <- file(tmp_user_profile, "w")
  on.exit(close(tmp_user_profile_con), add = TRUE)
  writeLines("options(repos =", tmp_user_profile_con)
  dput(getOption("repos"), tmp_user_profile_con)
  writeLines(")", tmp_user_profile_con)

  c(R_PROFILE_USER = tmp_user_profile)
}

# Determine the best setting for the TAR environmental variable
# This is needed for R <= 2.15.2 to use internal tar. Later versions don't need
# this workaround, and they use R_BUILD_TAR instead of TAR, so this has no
# effect on them.
auto_tar <- function() {
  tar <- Sys.getenv("TAR", unset = NA)
  if (!is.na(tar)) return(tar)

  windows <- .Platform$OS.type == "windows"
  no_rtools <- is.null(get_rtools_path())
  if (windows && no_rtools) "internal" else ""
}
