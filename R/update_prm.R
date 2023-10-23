#' update_prm
#'
#' Change parameter value in a bgm file for the Atlantis model.
#' The function does not overwrite the old file, but creates a new one with details of the change in its name.
#'
#' @param prm_file the bgm file that contains the parameter you want to change. Write as "bgm_file.prm"
#' @param parameter_name the parameter that you want to change. Write as "parameter_name"
#' @param new_value the new value for the parameter
#' @param output_file_name customised name to be appended to original file name. Write as "output_file_name"
#'
#' @return An updated bgm file with a new value for the parameter of interest
#' @export
#' @examples
#' update_prm(biology.prm, ecotest, 0, "TEST")

update_prm <- function(prm_file, parameter_names, new_values, output_file_name = NULL) {
  # Ensure parameter_names and new_values have the same length
  if (length(parameter_names) != length(new_values)) {
    stop("The number of parameter names and values provided do not match.")
  }

  # Read the PRM file into R
  lines <- readLines(prm_file)
  prm_file_path <- dirname(prm_file)
  # Validate all parameters exist in the file
  for (parameter_name in parameter_names) {
    if (!any(grepl(paste0("^\\s*", parameter_name, "\\s"), lines))) {
      stop(paste0("Parameter '", parameter_name, "' not found in file '", prm_file, "'. Execution stopped."))
    }
  }

  # Replace values in parameters of interest
  for (j in seq_along(parameter_names)) {
    parameter_name <- parameter_names[j]
    new_value <- sprintf("%.9g", as.numeric(new_values[j]))  # <-- This line is changed

    for (i in seq_along(lines)) {
      if (grepl(paste0("^\\s*", parameter_name, "\\s"), lines[i])) {
        pattern <- paste0("(", parameter_name, "\\s+)([0-9.eE+-]+)")  # Changed this regex to capture scientific notation
        replacement <- paste0("\\1", new_value)
        lines[i] <- sub(pattern, replacement, lines[i])
        cat(paste0("Parameter '", parameter_name, "' updated to ", new_value, ".\n"))
        break
      }
    }
  }

  # # Check existing folders and name the new folder with a sequential number
  # existing_folders <- list.dirs(path = prm_file_path, full.names = TRUE, recursive = FALSE)
  # new_folders <- grep("new_prm_files_", existing_folders, value = TRUE)
  # new_folder_number <- length(new_folders) + 1
  # timestamp <- format(Sys.time(), "%y%m%d")
  # new_folder <- file.path(prm_file_path, paste0("new_prm_files_", timestamp, "_", new_folder_number))

  # if (!dir.exists(new_folder)) {
  #   dir.create(new_folder)
  # }

  # Generate a new file name if not provided by the user
  if (is.null(output_file_name)) {
    base_name <- gsub("\\.[a-z]+$", "", basename(prm_file))
    change_details <- paste(sapply(1:length(parameter_names), function(i) {
      paste0("_", parameter_names[i], "_", new_values[i])
    }), collapse = "")
    output_file_name <- paste0(base_name, change_details, ".prm")
  }

  # Write the modified content back to the new PRM file
  base_name <- gsub("\\.[a-z]+$", "", basename(prm_file))
  new_file_path <- file.path(prm_file_path, paste0(base_name, "_", output_file_name))
  writeLines(lines, new_file_path)
  cat(paste0("Updated file saved as '", new_file_path, "'.\n"))
}