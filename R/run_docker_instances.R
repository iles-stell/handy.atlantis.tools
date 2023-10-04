#' run_docker_instances
#'
#' @param local_path_to_prm_files Local path where Docker should look for the .prm files, including the modified ones, to mount them into the container. The path needs to be in quotes ("my/file/path").
#' @param docker_image The name of the Docker image that you are using to run the model (e.g., atlantis_docker).
#'
#' @return Runs a new Docker container for each modified .prm file found in the specified directory.
#' @examples run_docker_instances(local_path_to_prm_files = "my/file/path", docker_image = 'atlantis_docker')

run_docker_instances <- function(local_path_to_prm_files, docker_image) {

  # List of all .prm files, including the modified ones
  all_prm_files <- list.files(path = local_path_to_prm_files, pattern = ".*\\.prm$", full.names = TRUE)

  # Validate if there are no PRM files
  if (length(all_prm_files) == 0) {
    cat("No .prm files found in the specified directory.\n")
    return()
  }

  # Loop over each file and start a new Docker container for modified PRM files
  for (full_prm_file_path in all_prm_files) {

    prm_file <- basename(full_prm_file_path)
    # prm_subfolder_path <- file.path(local_path_to_prm_files, prm_subfolder)

    # Set the environment variable with the PRM file name
    # (allows bash and R to talk)
    # Sys.setenv(PRM_SUBFOLDER_PATH = prm_subfolder_path)
    Sys.setenv(PRM_FILE = prm_file)


    # Create a unique name for each output directory
    sanitized_prm_name <- gsub("[^a-zA-Z0-9_.-]",
    "", prm_file) # Sanitizing the .prm file name
    sanitized_prm_name <- gsub("\\.prm$",
    "", sanitized_prm_name) # Removing .prm from the name

    output_dir <- paste0("output_EA_", format(Sys.time(), "%Y%m%d"), "_", sanitized_prm_name)
    Sys.setenv(OUTPUT_DIR = output_dir) # env variable

    # Unique container name
    unique_name <- paste0("c_", format(Sys.time(), "%Y%m%d"), "_", sanitized_prm_name)

    # Forming the command to run the Docker container
    docker_command <- sprintf(
      'docker run --name %s -d -e PRM_FILE="%s" -e OUTPUT_DIR="%s" -v "%s:/app/model" %s',

      unique_name,
      prm_file,  # pass the environment variable
      output_dir,  # environment variable
      local_path_to_prm_files,
      docker_image
    )

    cat("Running command: ", docker_command, "\n")
    system(docker_command)

  }
}
