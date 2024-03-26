#' run_docker_sql
#' @export

run_docker_sql <- function(local_path_to_prm_files, docker_image, db_path) {
  library(RSQLite)

  # Connect to the SQLite database
  conn <- dbConnect(SQLite(), dbname = db_path)
    # Check if the processed_files table exists, if not, create it
  if (!dbExistsTable(conn, "processed_files")) {
    dbExecute(conn, "CREATE TABLE processed_files (id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)")
  }


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

    # Check if the file has been processed before
    query <- dbSendQuery(conn, paste("SELECT * FROM processed_files WHERE filename = '", prm_file, "'"))
    result <- dbFetch(query)
    dbClearResult(query)

    # If the file has been processed, skip it
    if (nrow(result) > 0) {
      cat("File", prm_file, "has already been processed. Skipping.\n")
      next
    }

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

    # After running Docker successfully, record the processed file in the database
    dbExecute(conn, paste("INSERT INTO processed_files (filename) VALUES ('", prm_file, "')"))

  }

  # Disconnect from the database
  dbDisconnect(conn)
}
