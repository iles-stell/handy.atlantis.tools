#' combo
#'
#' Function that creates an array of all possible permutations given a set of parameters and values.
#' The function does not overwrite the old file, but creates a new one with details of the change in its name.
#'
#' @param prm_file the bgm file that contains the parameter you want to change. Write as "bgm_file.prm".
#' 
#' @return A suite of prm files, each with a different combination of values.
#' @export
#' @examples
#'     range_perc <- seq(-0.5, 0.5, 0.25) # Calculate parameter changes for each range percentage

combo <- function(prm_file, parameter_names, range_perc) {
    # Read the PRM file into R
    lines <- readLines(prm_file)
    prm_file_path <- dirname(prm_file)
    
    # Validate all parameters exist in the file
    for (parameter_name in parameter_names) {
        if (!any(grepl(paste0("^\\s*", parameter_name, "\\s"), lines))) {
            stop(paste0("Parameter '", parameter_name, "' not found in file '", prm_file, "'. Execution stopped."))
        }
    }
    
    # Define a function to extract the first value after a parameter name
    extract_first_value <- function(parameter_name, lines) {
        # Find lines containing the parameter name
        matching_lines <- grep(paste0("^\\s*", parameter_name, "\\s+([^#]+)"), lines, value = TRUE)
        if (length(matching_lines) == 0) {
            stop(paste0("Parameter '", parameter_name, "' not found in file '", prm_file, "'. Execution stopped."))
        }
        # Extract the value part from the first matching line
        value_part <- matching_lines[1]  # Only consider the first matching line
        value <- gsub("#.*", "", value_part)  # Remove comments from the line
        value <- gsub(paste0("^\\s*", parameter_name, "\\s+"), "", value)  # Remove parameter name
        values <- unlist(strsplit(value, "\\s+"))
        as.numeric(values[1]) # Return the first value after the parameter name
    } 
    
    # Apply the function to each parameter name and store the results in a list
    parameter_values <- sapply(parameter_names, extract_first_value, lines = lines)
    
    # Calculate number of permutations needed
    num_params <- length(parameter_names)
    num_perms <- length(range_perc)
    
    # Create all possible permutations of parameter combinations
    permutations <- expand.grid(replicate(num_params, range_perc, simplify = FALSE))
    names(permutations) <- parameter_names
    
    # Loop over each permutation to generate a new PRM file
    for (i in seq_len(nrow(permutations))) {
        # Extract values for this permutation
        new_values <- permutations[i, ]
        # Prepare to build the filename based on the permutation values
        filename_parts <- character(num_params)
        
        # Construct parts of the filename for each parameter
        for (j in seq_along(parameter_names)) {
            parameter_name <- parameter_names[j]
            param_value <- new_values[[parameter_name]][[1]]  # Extract value from list
            
            # Clean the parameter name for use in the filename
            param_name_clean <- gsub("[^A-Za-z0-9_]", "_", parameter_name)
            
            # Format the parameter detail in the filename
            clean_param_value <- as.numeric(gsub("[^A-Za-z0-9_]", "", sprintf("%.9g", param_value)))
            param_detail <- paste0(param_name_clean,
                                    ifelse(param_value > 0, paste0("_plus", clean_param_value),
                                           ifelse(param_value < 0, paste0("_minus", abs(clean_param_value)), clean_param_value)))
            
            # Store the parameter detail in the filename parts
            filename_parts[j] <- param_detail
        }
        
        # Generate the final filename based on assembled parts
        base_name <- gsub("\\.[a-z]+$", "", basename(prm_file))
        output_file_name <- paste0(base_name, "_", paste(filename_parts, collapse = "_"), ".prm")
        
        # Write the modified content to a new PRM file for this permutation
        new_file_path <- file.path(dirname(prm_file), output_file_name)
        new_lines <- lines
        
        # Replace parameter values in the new_lines with the current permutation values
        for (j in seq_along(parameter_names)) {
            parameter_name <- parameter_names[j]
            new_value <- sprintf("%.9g", as.numeric(new_values[[parameter_name]]))
            
            for (k in seq_along(new_lines)) {
                if (grepl(paste0("^\\s*", parameter_name, "\\s"), new_lines[k])) {
                    pattern <- paste0("(", parameter_name, "\\s+)([0-9.eE+-]+)")
                    replacement <- paste0("\\1", new_value)
                    new_lines[k] <- sub(pattern, replacement, new_lines[k])
                    break
                }
            }
        }
        
        # Write the modified content back to the new PRM file for this permutation
        writeLines(new_lines, new_file_path)
        cat(paste0("Updated file saved as '", new_file_path, "'.\n"))
        
    }
        # Print the number of permutations
    cat(paste("There are", nrow(permutations), "possible permutations.\n"))
}
