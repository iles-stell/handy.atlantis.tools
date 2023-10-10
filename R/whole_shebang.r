# Bayesian optimisation
# Update parameters based on optimisation step
# Run docker instances for each parameter combination
# Extract RelBiomass and parameters from output files

whole_shebang <- function(base_path) {
  # Get RelBiomass and parameters from output files
  combined_data <- get_metric(base_path)

  # Fit Bayesian regression model to data
  bprob_fit <- brm(value ~ C + mQ, data = combined_data, family = gaussian())
  post_samples <- posterior_samples(bprob_fit)

  # FIND BEST ESTIMATE FOR PARAMETERS

  # Create parameter space
  newdata <- expand.grid(
  C = seq(min(combined_data$C), max(combined_data$C), length.out = 100),
  mQ = seq(min(combined_data$mQ), max(combined_data$mQ), length.out = 100))

  # Predict RelBiomass for each parameter combination
  predictions <- posterior_predict(bprob_fit, newdata = newdata)
  mean_predictions <- rowMeans(predictions)

  # Sanity check ...
  # [Checking for NA values in mean_predictions]
  print(any(is.na(mean_predictions)))
  # Print mean_predictions to check the values
  print(head(mean_predictions))

  # Find the parameter combination that gives a RelBiomass value closest to 1
  close_to_one <- which.min(abs(mean_predictions - 1))
  best_C_mQ <- newdata[close_to_one, ]
  #print(best_C_mQ)
  return(best_C_mQ)


}
