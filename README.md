# Data-Calibrated Reinsurance and Ruin Probability Modelling

This project calibrates a stylised insurer surplus model using open motor insurance claims data, then evaluates how reinsurance can reduce 5-year ruin risk while preserving expected profit.

The aim is to turn the classical Cramér–Lundberg ruin model into a practical reinsurance decision study: given observed claim frequency and empirical claim severities, should an insurer use proportional or excess-of-loss reinsurance to meet a solvency constraint?

## Summary

Using policy exposure and claim data, I estimate claim frequency and model severity by resampling from the empirical claim-size distribution. I then simulate 5-year surplus paths under:

* no reinsurance;
* proportional reinsurance;
* excess-of-loss reinsurance.

Reinsurance parameters are selected by maximising expected profit subject to a 1% 5-year ruin probability constraint, using Wilson confidence intervals to account for Monte Carlo uncertainty.

## Key Results

Baseline assumptions:

| Parameter                         |                       Value |
| --------------------------------- | --------------------------: |
| Portfolio size                    |              1,000 policies |
| Annual claim frequency per policy |                      0.0738 |
| Mean claim severity               |                    2,265.51 |
| Initial surplus                   | 0.5× annual expected claims |
| Insurer loading                   |                         10% |
| Reinsurer loading                 |                         15% |
| Ruin threshold                    |             1% over 5 years |

Main results:

| Contract       | Deductible | 5-year ruin probability | Wilson CI upper | Expected profit |
| -------------- | ---------: | ----------------------: | --------------: | --------------: |
| No reinsurance |          — |                  27.35% |          27.54% |          83,559 |
| Excess-of-loss |      9,000 |                   0.85% |           0.89% |          39,125 |

The selected excess-of-loss contract reduces 5-year ruin probability by approximately 26.5 percentage points, at an expected profit sacrifice of about 44,434. This corresponds to roughly 1,677 units of expected profit sacrificed per 1 percentage point reduction in ruin probability.

## Interpretation

The empirical claim severity distribution is strongly right-skewed, making large individual claims the main driver of solvency risk. Proportional reinsurance reduces all claims uniformly, while excess-of-loss reinsurance directly caps large retained losses.

In this setting, excess-of-loss reinsurance is more effective because it targets the tail losses that threaten surplus. The result illustrates a classic risk-transfer tradeoff: reinsurance can materially reduce ruin probability, but at a substantial cost to expected profit.

## Methodology

The insurer surplus process is modelled as:

[
C(t) = c_0 + \pi t - \sum_{i=1}^{N(t)} Y_i
]

where:

* (N(t)) follows a Poisson process calibrated from policy exposure and claim counts;
* (Y_i) is sampled from the empirical claim severity distribution;
* (c_0) is initial surplus;
* (\pi) is premium income under an expected value loading.

For excess-of-loss reinsurance with deductible (d):

[
Y_{\text{retained}} = \min(Y, d)
]

The reinsurance premium is charged using a reinsurer loading on expected ceded losses.

## Repository Structure

```text
.
├── analysis.Rmd
├── data/
│   ├── freMTPL2freq.rda
│   └── freMTPL2sev.rda
├── src/
│   ├── data_calibration.R
│   ├── severity_models.R
│   ├── ruin_simulation.R
│   ├── reinsurance.R
│   └── confidence_intervals.R
└── outputs/
    └── tables/
```

## How to Run

Open `analysis.Rmd` and run the chunks in order.

Required R packages are minimal; the core implementation uses base R simulation and data manipulation.

## Limitations

This is a stylised solvency model, not an industry-grade capital model.

Key limitations include:

* empirical severity resampling cannot generate claims larger than the historical maximum;
* claim frequency is assumed Poisson and stationary;
* claim sizes are assumed independent;
* premium and capital assumptions are chosen as business scenarios rather than estimated from insurer financial statements;
* Monte Carlo estimates contain simulation uncertainty;
* reinsurance pricing is simplified to an expected value loading.

Future extensions could include Pareto-tail sensitivity, capital buffer sensitivity, non-stationary frequency, dependence between claims, and more formal extreme-value modelling.
