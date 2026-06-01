#' Biomass_analysis function
#' #' @export

biomass_analysis <- function(base_path, baseline_output) {
  library(ggplot2)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(handy.atlantis) # run command install_github("iles-stell/handy.atlantis")

  getData <- function(folder) {
    subfolders <- list.dirs(folder, recursive = TRUE, full.names = TRUE)
    subfolders <- subfolders[grepl("output", subfolders)]

    files <- lapply(subfolders, function(subfolder) {
      list.files(subfolder, pattern = "_AgeBiomIndx", full.names = TRUE)[1]
    })
    files <- unlist(files)
    files <- files[!is.na(files)]

    my_data <- lapply(files, function(file) {
      if (file.exists(file)) {
        read_table(file, col_names = TRUE)
      } else {
        warning(paste("File does not exist:", file))
        return(data.frame())
      }
    })

    my_data <- bind_rows(my_data)
    if (nrow(my_data) == 0) return(NULL)

    my_data2 <- my_data %>%
      group_by(Time) %>%
      summarise_all(mean, na.rm = TRUE)

    my_data2_long <- my_data2 %>%
      pivot_longer(-Time, names_to = "variable", values_to = "value")

    my_data2_long$Folder <- basename(folder)
    return(my_data2_long)
  }

  # ------------------------
  # Load baseline data
  # ------------------------
  baseline_data <- getData(baseline_output)

  if (is.null(baseline_data)) {
    stop("Baseline data could not be read.")
  }

  # Rename baseline column for clarity
  baseline_data <- baseline_data %>%
    rename(baseline_value = value) %>%
    select(Time, variable, baseline_value)

  # ------------------------
  # Load all scenario runs
  # ------------------------
  out_folders <- list.dirs(path = base_path, full.names = TRUE, recursive = FALSE)
  out_folders <- out_folders[grepl("output", basename(out_folders))]

  all_data <- lapply(out_folders, getData)
  all_data <- all_data[!sapply(all_data, is.null)]

  if (length(all_data) == 0) {
    stop("No valid data found.")
  }

  combined_data <- bind_rows(all_data)

  # ------------------------
  # Calculate anomaly
  # ------------------------
  combined_data <- combined_data %>%
    left_join(baseline_data, by = c("Time", "variable")) %>%
    mutate(anomaly = value - baseline_value)

  # ------------------------
  # Plot anomaly
  # ------------------------
  p <- ggplot(combined_data, aes(x = Time, y = anomaly, color = Folder)) +
    geom_line() +
    facet_wrap(~ variable, scales = "free_y", ncol = 3) +
    theme(legend.position = "bottom") +
    guides(color = guide_legend(nrow = 10)) +
    ylab("Anomaly (relative to baseline)")

  return(p)
}
