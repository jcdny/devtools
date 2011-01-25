#' Load complete package.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param reset clear package environment and reset file cache before loading
#'   any pieces of the package.
#' 
#' @keywords programming
#' @export
load_all <- function(pkg, reset = FALSE) {
  pkg <- as.package(pkg)
  
  # If installed version of package loaded, unload it
  name <- env_name(pkg)
  if (any(name == search()) && environmentIsLocked(as.environment(name))) {
    detach(name, character.only = TRUE, force = TRUE)
  }
  
  # Load dependencies before creating environment so it sees all the required
  # packages
  load_deps(pkg)

  if (reset) {
    clear_cache()
    clear_classes(pkg)
    clear_pkg_env(pkg)
  }

  if (name %in% search())
    env <- as.environment(name)
  else
    env <- new.env(parent = globalenv())
  
  load_data(pkg, env)
  load_code(pkg, env)
  load_c(pkg)

  if (!(name %in% search()))
    attach(env, name = name)
  
  invisible()  
}

#' Load package as development or installed verison.
#' 
#' If package exists in known development location on disk, load it from
#' there.  Otherwise load the installed package with \code{\link{library}}.
#'
#' @keywords programming
#' @export
load_or_library <- function(pkg, ...) {
  path <- find_package(pkg)
  
  if (is.null(path)) {
    library(pkg, character.only = TRUE)
  } else {
    load_all(as.package(path), ...)
  }
}
