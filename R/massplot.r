#' mass_plot function
#' Plot multiple instances of Atlantis output files.
#'
#' @param base_path The path to the folder containing the output folders.
#'
#' @return A facet plot with one panel per functional group, overlying lines for different model runs.
#' @export
#' @examples
#' mass_plot("your/output/files/path")

mass_plot <- function(base_path) {
  library(ggplot2)
  library(readr)
  library(dplyr)
  library(tidyr)

  getData <- function(folder) {
    # Get all subfolders that contain the word "output"
    subfolders <- list.dirs(folder, recursive = TRUE, full.names = TRUE)
    subfolders <- subfolders[grepl("output", subfolders)]

    # Get the file containing "BiomIndex" in each subfolder
    files <- lapply(subfolders, function(subfolder) {
      list.files(subfolder, pattern = "_AgeBiomIndx", full.names = TRUE)[1]
    })
    files <- unlist(files)

    # Filter out NA values
    files <- files[!is.na(files)]

    # Read the data from each file and combine into a single data frame
    my_data <- lapply(files, function(file) {
      if(file.exists(file)) {
        read_table(file, col_names = TRUE)
      } else {
        warning(paste("File does not exist:", file))
        return(data.frame()) # returns an empty dataframe if file does not exist
      }
    })

    my_data <- bind_rows(my_data)
    if(nrow(my_data) == 0) return(NULL) # return NULL if no data to avoid errors in summarise_all

    my_data2 <- my_data %>%
      group_by(Time) %>%
      summarise_all(mean, na.rm = TRUE) # Added na.rm = TRUE to handle NA values in columns

    # Convert the wide format to a long format
    my_data2_long <- my_data2 %>%
      gather(key = "variable", value = "value", -Time)

    my_data2_long$Folder <- basename(folder)
    return(my_data2_long)
  }

  out_folders <- list.dirs(path = base_path, full.names = TRUE, recursive = FALSE)
  out_folders <- out_folders[grepl("output", basename(out_folders))]

  # Get data from all folders
  all_data <- lapply(out_folders, getData)

  # Clean the all_data list to remove NULLs
  all_data <- all_data[!sapply(all_data, is.null)]

  if(length(all_data) == 0) {
    stop("No valid data found.")
  }

  # Combine all data into a single data frame
  combined_data <- bind_rows(all_data)

  # Create a facet plot with each column as a separate panel,
  # overlaying lines from different folders
  p <- ggplot(combined_data, aes(x = Time, y = value, color = Folder)) +
    geom_line() +
    facet_wrap(~ variable, scales = "free_y", ncol = 3) +
    theme(legend.position = "bottom") +
    guides(color = guide_legend(nrow = 10))

  # Return the plot
  return(p)
}