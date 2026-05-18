# Reinsurance helper functions

policy_mean <- function(sev_model, policy, d = NULL, alpha = NULL) {
  if (policy == "none") {
    exp_retained <- sev_model$mean
    exp_ceded <- 0
  } else if (policy == "proportional") {
    if (is.null(alpha)) stop("alpha must be provided for proportional reinsurance.")
    
    exp_retained <- alpha * sev_model$mean
    exp_ceded <- (1 - alpha) * sev_model$mean
  } else if (policy == "EoL") {
    if (is.null(d)) stop("d must be provided for EoL reinsurance.")
    
    exp_retained <- sev_model$truncated_mean(d)
    exp_ceded <- sev_model$mean - exp_retained
  } else {
    stop("Unknown policy. Use 'none', 'proportional', or 'EoL'.")
  }
  
  list(
    exp_retained = exp_retained,
    exp_ceded = exp_ceded
  )
}

grid_search_proportional <- function(alpha_grid, n_sim, t, lambda, sev_model,
                                     c0, theta, xi) {
  results <- lapply(alpha_grid, function(a) {
    evaluate_policy(
      n_sim = n_sim,
      t = t,
      lambda = lambda,
      sev_model = sev_model,
      policy = "proportional",
      c0 = c0,
      theta = theta,
      xi = xi,
      alpha = a
    )
  })
  
  do.call(rbind, results)
}

grid_search_eol <- function(d_grid, n_sim, t, lambda, sev_model,
                            c0, theta, xi) {
  results <- lapply(d_grid, function(d) {
    evaluate_policy(
      n_sim = n_sim,
      t = t,
      lambda = lambda,
      sev_model = sev_model,
      policy = "EoL",
      c0 = c0,
      theta = theta,
      xi = xi,
      d = d
    )
  })
  
  do.call(rbind, results)
}

select_best_contract <- function(results, ruin_limit = 0.01) {
  feasible <- results[results$ruin_prob <= ruin_limit, ]
  
  if (nrow(feasible) == 0) {
    return(NULL)
  }
  
  feasible[which.max(feasible$expected_profit), ]
}