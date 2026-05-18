# Severity Models 
# Helpers for fitting and computing moments of severity models.

# EMPIRICAL DISTRIBUTION ======================================================

empirical_severity_model <- function(sev) {
  rseverity <- function(n) {
    sample(sev, size = n, replace = TRUE)
  }
  
  truncated_mean <- function(d) {
   return(mean(pmin(sev, d))) 
  }
  
  return (
    list(name = "Empirical",
    rseverity = rseverity,
    mean = mean(sev),
    truncated_mean = truncated_mean,
    params = list(
      severity_values = sev,
      n_claims = length(sev),
      mean = mean(sev),
      median = median(sev),
      q95 = as.numeric(quantile(sev, 0.95)),
      q99 = as.numeric(quantile(sev, 0.99)),
      max = max(sev)))
  )
}

# EMPIRICAL DISTRIBUTION + PARETO TAIL ========================================

# Pareto helper
# Type I Pareto with lower bound u:
# P(Y > y | Y > u) = (u / y)^alpha, y >= u
rpareto <- function(n, u, alpha) {
  U <- runif(n)
  return(u * (1 - U)^(-1 / alpha))
}

# Returns the truncated mean of the Pareto distribution
truncated_mean_pareto <- function(d, u, alpha) {
  
  if (d <= u) {
    return(d)
  }
  
  if (alpha == 1) {
    return(u * (1 + log(d / u)))
  }
  
  return(
    (alpha * u - u^alpha * d^(1 - alpha)) /
      (alpha - 1)
  )
}

fit_pareto_tail <- function(sev, threshold_q = 0.95) {
  
  u <- as.numeric(quantile(sev, threshold_q))
  tail_vals <- sev[sev > u]
  body_vals <- sev[sev <= u]
  
  if (length(tail_vals) < 30) {
    warning("Very few tail observations. Consider lowering threshold_q.")
  }
  
  alpha <- length(tail_vals) / sum(log(tail_vals / u))
  p_tail <- length(tail_vals) / length(sev)
  
  if (alpha <= 1) {
    warning("Pareto alpha <= 1, tail mean is infinite. Use empirical baseline or higher threshold.")
    tail_mean <- Inf
  } else {
    tail_mean <- alpha * u / (alpha - 1)
  }
  
  body_mean <- mean(body_vals)
  hybrid_mean <- (1 - p_tail) * body_mean + p_tail * tail_mean
  
  return(
    list(u = u,
    threshold_q = threshold_q,
    alpha = alpha,
    p_tail = p_tail,
    body_vals = body_vals,
    tail_vals = tail_vals,
    body_mean = body_mean,
    tail_mean = tail_mean,
    mean = hybrid_mean)
  )
}

empirical_pareto_severity_model <- function(sev, threshold_q = 0.95) {
  fit <- fit_pareto_tail(sev, threshold_q)
  
  rseverity <- function(n) {
    is_tail <- runif(n) < fit$p_tail
    
    y <- numeric(n)
    
    n_body <- sum(!is_tail)
    n_tail <- sum(is_tail)
    
    if (n_body > 0) {
      y[!is_tail] <- sample(fit$body_vals, size = n_body, replace = TRUE)
    }
    
    if (n_tail > 0) {
      y[is_tail] <- rpareto(n_tail, u = fit$u, alpha = fit$alpha)
    }
    return(y)
  }
  
  # Computing truncated mean E(min(X, d))
  truncated_mean <- function(d) {
    body_part <- mean(pmin(fit$body_vals, d))
    
    tail_part <- truncated_mean_pareto(
      d = d,
      u = fit$u,
      alpha = fit$alpha
    )
    
    return((1 - fit$p_tail) * body_part +
           fit$p_tail * tail_part)
  }
  
  return(
  list(name = paste0("Empirical body + Pareto tail, q=", fit$threshold_q),
    rseverity = rseverity,
    mean = fit$mean,
    truncated_mean = truncated_mean,
    params = fit)
  )
}

# GAMMA DISTRIBUTION ==========================================================

# MLE for Gamma(shape = alpha, rate = beta) parameters.
gamma_model <- function(sev) {
  
  xbar <- mean(sev)
  s <- log(xbar) - mean(log(sev))
  
  f <- function(alpha) log(alpha) - digamma(alpha) - s
  
  upper <- 1
  while (f(upper) > 0) upper <- upper * 2
  
  alpha <- uniroot(f, lower = 1e-8, upper = upper)$root
  beta <- alpha / xbar
  
  rseverity <- function(n) {
    rgamma(n, shape = alpha, rate = beta)
  }
  
  truncated_mean <- function(d) {
    (alpha / beta) * pgamma(d, shape = alpha + 1, rate = beta) +
    d * (1- pgamma(d, shape = alpha, rate = beta))
  }
  
  return(list(name = "Gamma",
         rseverity = rseverity,
         mean = alpha / beta,
         truncated_mean = truncated_mean,
         params = list(alpha = alpha, beta = beta))
  )
}

# LOGNORMAL DISTRIBUTION ======================================================

# MLE for LogNormal(mu, sigma^2) parameters.
lognormal_model <- function(sev) {
  n <- length(sev)
  mu <- sum(log(sev)) / n
  sigma2 <- sum((log(sev) - mu)^2) / n
  
  rseverity <- function(n) {
    rlnorm(n, meanlog = mu, sdlog = sqrt(sigma2))
  }
  
  truncated_mean <- function(d) {
    a <- (log(d) - mu) / sqrt(sigma2)
    
    return(
      exp(mu + 0.5 * sigma2) * pnorm(a - sqrt(sigma2)) +
      d * (1 - pnorm(a))
    )
  }
  
  return(list(name = "LogNormal", 
         rseverity = rseverity,
         mean = exp(mu + 0.5 * sigma2),
         truncated_mean = truncated_mean,
         list(mu = mu, sigma2 = sigma2))
  )
}


