#' Continuous integration
#'
#' @name ci
#' @aliases NULL
#' @inheritParams use_template
NULL


#' @section \code{use_travis}:
#' Add basic travis template to a package. Also adds \code{.travis.yml} to
#' \code{.Rbuildignore} so it isn't included in the built package.
#' @param browse open a browser window to enable Travis builds for the package
#' automatically.
#' @export
#' @rdname ci
use_travis <- function(browse = interactive(), base_path = ".") {
  if (!uses_github(base_path)) {
    stop("You must use_github() before using travis")
  }

  use_template(
    "travis.yml",
    ".travis.yml",
    ignore = TRUE,
    base_path = base_path
  )

  gh <- gh::gh_tree_remote(base_path)
  travis_url <- file.path("https://travis-ci.org", gh$username, "/", gh$repo)
  travis_img <- paste0(travis_url, ".svg?branch=master")

  message("Next:")
  use_badge("Travis build status", travis_url, travis_img, base_path = base_path)

  message("* Turn on travis for your repo at ", travis_url)
  if (browse) {
    utils::browseURL(travis_url)
  }

  invisible(TRUE)
}


uses_travis <- function(base_path = ".") {
  path <- file.path(base_path, ".travis.yml")
  file.exists(path)
}

#' @rdname ci
#' @param type CI tool to use. Currently supports codecov and coverall.
#' @section \code{use_coverage}:
#' Add test code coverage to basic travis template to a package.
#' @export
use_coverage <- function(type = c("codecov", "coveralls"), base_path = ".") {
  if (!uses_travis(base_path)) {
    stop("You must use_travis() first", call. = FALSE)
  }

  use_dependency("covr", "Suggests", base_path = base_path)

  gh <- gh::gh_tree_remote(base_path)
  type <- match.arg(type)

  message("Next:")
  switch(type,
    codecov = {
      use_template("codecov.yml", "codecov.yml", ignore = TRUE, base_path = base_path)
      use_badge("Coverage status",
        paste0("https://codecov.io/github/", gh$username, "/", gh$repo, "?branch=master"),
        paste0("https://img.shields.io/codecov/c/github/", gh$username, "/", gh$repo, "/master.svg")
      )
      message("* Add to `.travis.yml`:\n",
        "after_success:\n",
        "  - Rscript -e 'covr::codecov()'"
      )
    },

    coveralls = {
      message("* Turn on coveralls for this repo at https://coveralls.io/repos/new")
      use_badge("Coverage status",
        paste0("https://coveralls.io/r/", gh$username, "/", gh$repo, "?branch=master"),
        paste0("https://img.shields.io/coveralls/", gh$username, "/", gh$repo, ".svg")
      )
      message("* Add to `.travis.yml`:\n",
        "after_success:\n",
        "  - Rscript -e 'covr::coveralls()'"
      )
    })

  invisible(TRUE)
}

#' @rdname ci
#' @section \code{use_appveyor}:
#' Add basic AppVeyor template to a package. Also adds \code{appveyor.yml} to
#' \code{.Rbuildignore} so it isn't included in the built package.
#' @export
use_appveyor <- function(base_path = ".") {
  use_template("appveyor.yml", ignore = TRUE, base_path = base_path)

  gh <- gh::gh_tree_remote(base_path)
  message("Next: \n",
    "* Turn on AppVeyor for this repo at https://ci.appveyor.com/projects\n",
    "* Add an AppVeyor shield to your README.md:\n",
    "[![AppVeyor Build Status]",
    "(https://ci.appveyor.com/api/projects/status/github/", gh$username, "/", gh$repo, "?branch=master&svg=true)]",
    "(https://ci.appveyor.com/project/", gh$username, "/", gh$repo, ")"
  )

  invisible(TRUE)
}
