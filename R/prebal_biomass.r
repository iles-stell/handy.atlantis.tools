# # Load the ncdf4 package
# library(ncdf4)

# # prebal <- function() {}
# #prebal_1 <- function(base_path) {
#   library(ggplot2)
#   library(readr)
#   library(dplyr)
#   library(tidyr)
#   library(reshape2)

#   getGroups <- function(input.folder, groups.file) {
#     # Get groups file
#     groups.data <- read.csv(file.path(input.folder, groups.file))
#     # Filter active groups
#     active.groups <- groups.data %>%
#         filter(IsTurnedOn == 1)
#     return(active.groups)
#     }
#     active.code <- active.groups$Code

#   getData <- function(folder) {
#     # Get all subfolders that contain the word "output"
#     subfolders <- list.dirs(folder, recursive = TRUE, full.names = TRUE)
#     subfolders <- subfolders[grepl("output", subfolders)]

#     # Get the file containing "BiomIndex" in each subfolder
#     files <- lapply(subfolders, function(subfolder) {
#       list.files(subfolder, pattern = "_BiomIndx", full.names = TRUE)[1]
#     })
#     files <- unlist(files)
#     # Filter out NA values
#     files <- files[!is.na(files)]

#     # Read the data from each file and combine into a single data frame
#     my_data <- lapply(files, function(file) {
#       if(file.exists(file)) {
#         read_table(file, col_names = TRUE)
#       } else {
#         warning(paste("File does not exist:", file))
#         return(data.frame()) # returns an empty dataframe if file does not exist
#       }
#     })
#   }
#     my_data <- bind_rows(my_data)
#     if(nrow(my_data) == 0) return(NULL) # return NULL if no data to avoid errors in summarise_all

#   # Subset dataframe to keep only columns matching the active codes
#     active.df <- my_data %>%
#         select(Time, all_of(active.code))

#     active.long <- active.df %>%
#         pivot_longer(cols = -Time, names_to = "Functional_Group", values_to = "Value")
#     # Filter data for Time = 0
#     active.long <- active.long %>% 
#         filter(Time == 0 & Functional_Group != "DIN" & Functional_Group != c("DL", "DR", "DC")) 

#     ggplot(active.long, aes(x = Functional_Group, y = Value)) +
#         geom_bar(stat = "identity") +
#         theme(axis.text.x = element_text(angle = 90, hjust = 1))
