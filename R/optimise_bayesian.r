#' optimise_bayesian



optimise_bayesian  <- function(combined_data) {
  # Define Bayesian regression model
  model  <- brms::brm(
        value ~ C + mQ, # value = RelBiomass
        data = combined_data, family = gaussian(),
        iter = 3000, warmup = 1000
    )
  # Define objective function
  #   
  objective_function <- function(C, mQ) {
        newdata <- data.frame(C = C, mQ = mQ)
        predicted_value <- as.numeric(predict(model, newdata = newdata, allow_new_levels = TRUE))
        loss <- abs(1 - mean(predicted_value))  # ensure predicted_value is a single number
        # Return the loss as a named element of a list.
        # Loss represents the difference between predictions and target (i.e., RelBiomass = 1)
        return(list(Score = loss))
    }
  # Find values of C and mQ that minimise the objective function
  # Bayesian Optimisation evaluates performance of set of hyperparameters and chooses the best set.
  result <- BayesianOptimization(
        FUN = objective_function, # function to be optimised
        bounds = list(C = c(0.001, 0.009), mQ = c(1e-9, 1e-4)), # bounds for hyperparameters
        init_points = 10, # number of randomly chosen points to sample the target function before fitting
        n_iter = 20, # number of iterations to find the minimum
        acq = "ei", # ei = Expected Improvement
        kappa = 2.576 # kappa = trade-off between exploration and exploitation
    )
    best_params <- result$Best_Par # extract the best parameters
    new_C <- best_params['C']
    new_mQ <- best_params['mQ']

    # Return parameters to be updated in next round
    new_params  <- c("C_ZG_T15", "ZG_mQ")
    new_vals <- c(new_C, new_mQ)
    optimised_vals <- list(new_params = new_params, new_vals = new_vals)
    return(optimised_vals)

}

##########################################################################################################
# post_samples <- posterior_samples(model)
# library(tidyr)
# long_format <- gather(post_samples, key = "parameter", value = "value")

# # Plot density
# posterior_density_p <- ggplot(long_format, aes(x = value)) +
#   geom_density(fill = "skyblue", alpha = 0.5) +
#   facet_wrap(~ parameter, scales = "free") +
#   labs(title = "Posterior Density Plot", x = "Value", y = "Density") +
#   theme_minimal()
# posterior_density_p

# # 2D ellipse contour plot
# ellipse_contour_p <- ggplot(post_samples, aes(x = b_C, y = b_mQ)) +
#   geom_point(alpha = 0.1) +
#   geom_density_2d(color = "blue") +
#   labs(title = "2D Ellipse Contour Plot for Posterior Samples",
#        x = "Parameter b_C",
#        y = "Parameter b_mQ") +
#   theme_minimal()
# ellipse_contour_p

# # 3D bell curve plot
# density_estimate <- kde2d(post_samples$b_C, post_samples$b_mQ, n = 50) # Estimate the 2D density of two parameters
# # Plot
# bell_curve_p <- plot_ly(x = density_estimate$x, y = density_estimate$y, z = density_estimate$z) %>%
#   add_surface() %>%
#   layout(scene = list(xaxis = list(title = "b_C"), 
#                       yaxis = list(title = "b_mQ"), 
#                       zaxis = list(title = "Density")),
#          title = "3D Density Plot of Posterior Samples")
# bell_curve_p
