#' adv_update_prm
#'
#' Advanced function for changing parameter value in a bgm file for the Atlantis model.
#' The function does not overwrite the old file, but creates a new one with details of the change in its name.
#'
#' @param prm_file the bgm file that contains the parameter you want to change. Write as "bgm_file.prm".
#' @param parameter_name the parameter that you want to change. Write as "parameter_name".
#' @param new_value the new value for the parameter.
#' @param index the index number of the parameter value to change when dealing with multiple values per single parameter (e.g, pPrey, migration matrices).
#'
#' @return An updated bgm file with a new value for the parameter of interest
#' @export
#' @examples
#' Save new_value and indices as vectors with one or more values inside them.
#' E.g., for pPreyWHH, set new value <- 0.06 for prey index 28 (KR), and new value <- 0.04 for prey index 1 (FM):
#' new_values <- c(0.06, 0.04)
#' indices <- c(28, 1)
#' adv_update_prm(biology.prm, "pPreyWHH", new_values, indices, custom_details = "_ZGdiet_change")

adv_update_prm <- function(prm_file, parameter_names, new_values, indices, custom_details = NULL) {
  
  # Replicate parameter names to match the length of new_values
  parameter_names <- rep(parameter_names, length(new_values))

  # Check that all input vectors have the same length
  if (length(parameter_names) != length(new_values) || length(parameter_names) != length(indices)) {
    stop("The number of parameter names, values, and indices provided do not match.")
  }

  # Read the parameter file into a character vector
  lines <- readLines(prm_file)

  # Loop through each parameter, value, and index
  for (j in seq_along(parameter_names)) {
    parameter_name <- parameter_names[j]
    new_value <- new_values[j]
    index <- indices[j]

    # Check if the parameter is a pPREY type
    is_pPREY <- grepl("^pPREY", parameter_name, ignore.case = TRUE)

    # Search for the parameter in the file
    for (i in seq_along(lines)) {
      if (grepl(paste0("^\\s*", parameter_name, "\\s"), lines[i], ignore.case = TRUE)) {
        
        # If it's a pPREY parameter, the values are on the next line
        values_line_index <- if(is_pPREY) {i + 1} else {i}

        # Split the line into individual values
        values <- unlist(strsplit(lines[values_line_index], "\\s+"))

        # Check that the index is valid
        if (index > length(values) || index < 1) {
          stop(paste0("Index '", index, "' is out of bounds for parameter '", parameter_name, "'."))
        }

        # Update the value
        values[index] <- as.character(new_value)

        # Replace the line in the file with the updated values
        lines[values_line_index] <- paste0(values, collapse = "\t")
        break
      }
    }
  }

  # Generate the new file name
  base_name <- gsub("\\.[a-z]+$", "", basename(prm_file))

  # If custom details are provided, use them; otherwise, generate from parameters, indices, and values
  change_details <- if (is.null(custom_details)) {
    paste(sapply(1:length(parameter_names), function(i) {
      paste0("_", parameter_names[i], "_", indices[i], "_", new_values[i])
    }), collapse = "")
  } else {
    custom_details
  }

  # Generate the full path to the new file
  prm_file_path <- dirname(prm_file)
  output_file <- file.path(prm_file_path, paste0(base_name, change_details, ".prm"))

  # Write the updated content to the new file
  writeLines(lines, output_file)

  # Print the name of the new file to the console
  cat(paste0("Updated file saved as '", output_file, "'.\n"))
}
