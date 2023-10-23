#' get_metric function
#' Extract data for RelBiomass and input parameters from Atlantis output .txt and xml files.
#'
#' @param base_path The path to the folder containing the output folders.
#'
#' @return A list of datasets for relative biomass (final/initial biomass values) and parameter values from biology input xml file.
#' @export
#' @examples
#' get_metric("your/output/files/path")

get_metric <- function(base_path) {


  # getData <- function(folder) {
    
  #   # Load the XML file
  #   xml_files <- list.files(folder, pattern = "EA_biol.*\\.xml$", full.names = TRUE)
  #   xml_data <- data.frame()

  #   if (length(xml_files) > 0) {
  #     xml_file <- read_xml(xml_files[1])

  #     # Extract value from XML file for C and mQ
  #     node_C <- xml_find_all(xml_file, "//Attribute[@AttributeName='InvertebrateClearanceRate']/GroupValue[@GroupName='ZG']")
  #     attribute_value_C <- xml_attr(node_C, "AttributeValue")

  #     node_mQ <- xml_find_all(xml_file, "//Attribute[@AttributeName='FLAG_MQ_T15']/GroupValue[@GroupName='ZG']")
  #     attribute_value_mQ <- xml_attr(node_mQ, "AttributeValue")

  #     xml_data <- data.frame(
  #       Folder = basename(folder),
  #       C = as.numeric(attribute_value_C),
  #       mQ = as.numeric(attribute_value_mQ),
  #       stringsAsFactors = FALSE
  #     )
  #   } else {
  #     warning(paste("No XML file containing 'EA_biol' found in folder:", folder))
  #   }

  #   # RelBiomass: get the file containing "BiomIndex"
  #   files <- list.files(folder, pattern = "_BiomIndx", full.names = TRUE)

  #   # Filter out NA values
  #   files <- files[!is.na(files)]

  #   # Read the data from each file and combine into a single data frame
  #   my_data <- lapply(files, function(file) {
  #     if (file.exists(file)) {
  #       read_table(file, col_names = TRUE)
  #     } else {
  #       warning(paste("File does not exist:", file))
  #       return(data.frame()) # returns an empty dataframe if file does not exist
  #     }
  #   })

  #   my_data <- bind_rows(my_data)
  #   if (nrow(my_data) == 0) return(list(xml_data = xml_data, biom_data = NULL))

  #   my_data2 <- my_data %>%
  #     group_by(Time) %>%
  #     summarise_all(mean, na.rm = TRUE)

  #   # Convert the wide format to a long format
  #   my_data2_long <- my_data2 %>%
  #     gather(key = "variable", value = "value", -Time)

  #   my_data2_long$Folder <- basename(folder)

  #   list(xml_data = xml_data, biom_data = my_data2_long)
  # }

  # out_folders <- list.dirs(path = base_path, full.names = TRUE, recursive = FALSE)
  # out_folders <- out_folders[grepl("output", basename(out_folders))]

  # # Get data from all folders
  # all_data <- lapply(out_folders, getData)

  # Separate the xml and biom data into different lists
  xml_data_list <- lapply(all_data, `[[`, "xml_data")
  biom_data_list <- lapply(all_data, `[[`, "biom_data")

  # Remove NULLs
  xml_data_list <- xml_data_list[!sapply(xml_data_list, is.null)]
  biom_data_list <- biom_data_list[!sapply(biom_data_list, is.null)]

  if (length(xml_data_list) == 0) {
    stop("No valid XML data found.")
  }

  if (length(biom_data_list) == 0) {
    stop("No valid Biom data found.")
  }

  # Combine all xml data into a single data frame
  combined_xml_data <- bind_rows(xml_data_list)

  # Combine all biom data into a single data frame
  combined_biom_data <- bind_rows(biom_data_list)

  # Filter the combined data to keep only variables that start with "Rel"
  combined_biom_data <- combined_biom_data[grep("^Rel", combined_biom_data$variable), ]

  if (nrow(combined_biom_data) == 0) {
    stop("No variables starting with 'Rel' found.")
  }

  # Adding this line to assign the last value of the dataset to a variable
  combined_biom_data <- combined_biom_data %>%
  group_by(variable, Folder) %>%
  filter(Time == max(Time)) %>%
  slice(n()) %>%
  ungroup()

  metrics_data <- list(xml_data = combined_xml_data, biom_data = combined_biom_data)

  biomass_data <- metrics_data$biom_data
  param_data <- metrics_data$xml_data

  combined_data <- inner_join(biomass_data, param_data, by = "Folder")
  
  return(combined_data)
}