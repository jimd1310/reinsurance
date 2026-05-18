# Confidence Intervals

wilson_interval <- function(x, n, conf_level = 0.95) {
  if (n <= 0) stop("n must be positive.")
  if (x < 0 || x > n) stop("x must be between 0 and n.")
  
  z <- qnorm(1 - (1 - conf_level) / 2)
  p_hat <- x / n
  
  denom <- 1 + z^2 / n
  centre <- p_hat + z^2 / (2 * n)
  margin <- z * sqrt((p_hat * (1 - p_hat) / n) + z^2 / (4 * n^2))
  
  lower <- (centre - margin) / denom
  upper <- (centre + margin) / denom
  
  c(lower = lower, upper = upper)
}