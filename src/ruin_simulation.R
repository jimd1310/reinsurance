# Ruin Simulation
# Contains a function which simulates ruin under Cramér-Lundberg model with
# specified reinsurance

source("src/reinsurance.R")
source("src/confidence_intervals.R")

# Computes I(C(t) < 0)
# Specify EoL, proportional, or no reinsurance through policy parameter
ruin_check <- function(t, lambda, sev_model, policy,
                       d = NULL, alpha = NULL,
                       c0, theta, xi = 0) {
  
  means <- policy_mean(sev_model, policy, d, alpha)
  
  pi_insurer <- (1 + theta) * lambda * sev_model$mean
  pi_reinsurer <- if (policy == "none") {
    0
  } else {
    (1 + xi) * lambda * means$exp_ceded
  }
  
  pi_net <- pi_insurer - pi_reinsurer
  
  N <- rpois(1, lambda * t)
  
  if (N == 0) {
    return(FALSE)
  }
  
  arrivals <- sort(runif(N, min = 0, max = t))
  claims <- sev_model$rseverity(N)
  
  claims_retained <- if (policy == "none") {
    claims
  } else if (policy == "proportional") {
    alpha * claims
  } else if (policy == "EoL") {
    pmin(claims, d)
  } else {
    stop("Unknown policy.")
  }
  
  surplus <- c0 + pi_net * arrivals - cumsum(claims_retained)
  
  return(any(surplus < 0))
}

expected_profit <- function(t, lambda, sev_model, policy,
                            d = NULL, alpha = NULL,
                            theta, xi = 0) {
  
  means <- policy_mean(sev_model, policy, d, alpha)
  
  pi_insurer <- (1 + theta) * lambda * sev_model$mean
  pi_reinsurer <- if (policy == "none") {
    0
  } else {
    (1 + xi) * lambda * means$exp_ceded
  }
  
  pi_net <- pi_insurer - pi_reinsurer
  
  return(pi_net * t - lambda * t * means$exp_retained)
}

simulate_ruin_probability <- function(n_sim, t, lambda, sev_model, policy,
                                      c0, theta, xi = 0,
                                      d = NULL, alpha = NULL) {
  ruin <- replicate(n_sim, ruin_check(
    t = t,
    lambda = lambda,
    sev_model = sev_model,
    policy = policy,
    d = d,
    alpha = alpha,
    c0 = c0,
    theta = theta,
    xi = xi
  ))
  
  return(mean(ruin))
}

evaluate_policy <- function(n_sim, t, lambda, sev_model, policy,
                            c0, theta, xi = 0,
                            d = NULL, alpha = NULL) {
  ruin_prob <- simulate_ruin_probability(
    n_sim, t, lambda, sev_model, policy, c0, theta, xi, d, alpha
  )
  
  profit <- expected_profit(
    t = t,
    lambda = lambda,
    sev_model = sev_model,
    policy = policy,
    d = d,
    alpha = alpha,
    theta = theta,
    xi = xi
  )
  
  n_ruin <- round(ruin_prob * n_sim)
  
  ci <- wilson_interval(n_ruin, n_sim)
  
  data.frame(
    policy = policy,
    alpha = ifelse(is.null(alpha), NA_real_, alpha),
    d = ifelse(is.null(d), NA_real_, d),
    ruin_prob = ruin_prob,
    ci_lower = ci["lower"],
    ci_upper = ci["upper"],
    expected_profit = profit
  )
}

