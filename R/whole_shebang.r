#' whole_shebang
#'
#' @param base_path The path to the folder containing the output folders.
#'
#' @return Optimisation process for Atlantis model.
#' @export


# Get metrics and params -> do Bayesian optimisation
# Update parameters based on optimisation step
# Run docker instances for each parameter combination
# Extract RelBiomass and parameters from output files

whole_shebang <- function(prm_file, base_path) {
  # Get RelBiomass and parameters from output files
  combined_data <- get_metric(base_path)
  optimised_vals <- optimise_bayesian(combined_data)
  new_params <- optimised_vals$new_params
  new_vals <- optimised_vals$new_vals
  updated_prm <- update_prm(prm_file, new_params, new_vals)
  return(updated_prm)

}
