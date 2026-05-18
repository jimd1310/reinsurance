# Data Calibration 
# For loading in the data and converting it into model inputs.

load_fremtpl2 <- function(
    freq_path = "data/freMTPL2freq.rda",
    sev_path  = "data/freMTPL2sev.rda"
) {
  env <- new.env()
  
  load(freq_path, envir = env)
  load(sev_path, envir = env)
  
  list(
    freq = env$freMTPL2freq,
    sev  = env$freMTPL2sev
  )
}

extract_claim_frequency <- function(freq_data) {
  freq_data <- freq_data[freq_data$Exposure > 0, ]
  
  total_claims <- sum(freq_data$ClaimNb, na.rm = TRUE)
  total_exposure <- sum(freq_data$Exposure, na.rm = TRUE)
  
  lambda_per_policy <- total_claims / total_exposure
  
  return (
    list(total_claims = total_claims,
    total_exposure = total_exposure,
    lambda_per_policy = lambda_per_policy)
  )
}

extract_claim_amounts <- function(sev_data) {
  claim_amounts <- sev_data$ClaimAmount
  claim_amounts <- claim_amounts[!is.na(claim_amounts)]
  claim_amounts <- claim_amounts[claim_amounts > 0]
  
  claim_amounts
}

# Convert frequency and severity data into model inputs
make_portfolio_inputs <- function(lambda_per_policy,
                                  expected_severity,
                                  portfolio_size = 10000,
                                  capital_multiple = 0.5) {
  lambda_portfolio <- portfolio_size * lambda_per_policy
  
  annual_expected_claims <- lambda_portfolio * expected_severity
  
  # Set initial capital to be some multiple of annual expected claims
  c0 <- capital_multiple * annual_expected_claims
  
  return(
    list(portfolio_size = portfolio_size,
         lambda_per_policy = lambda_per_policy,
         lambda_portfolio = lambda_portfolio,
         expected_severity = expected_severity,
         annual_expected_claims = annual_expected_claims,
         c0 = c0,
         capital_multiple = capital_multiple)
  )
}









