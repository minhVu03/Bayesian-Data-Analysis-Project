# Bayesian Spatial Analysis on Global Suicide Rates
## Description

Understanding the geographic distribution of suicide rates may be important for the development of target mental health policies and preventative measures. In this study, we apply a Bayesian hierarchical model with a conditionally autoregressive (CAR) prior to investigate spatial patterns in suicide rates across countries. We model the suicide rate as a continuous outcome using a Gaussian likelihood, with a global intercept, a temporal effect comparing 2019 and 2021, and spatial random effects that capture regional deviations.

Our main research question is: Are there identifiable spatial patterns that persist after taking global and temporal effects into account, and did suicide rates change significantly between 2019 and 2021 at a global level?

This data comes from the World Health Organization.

---

## Model, Stan, and Posterior

We chose our priors based on literature reviews, which resulted in the following model: 

<img width="381" height="310" alt="Screenshot 2025-11-19 at 3 30 24 PM" src="https://github.com/user-attachments/assets/a51cbbc8-68ae-40bc-a880-725244002918" />

Since our dataset does not include information on the neighbors of each country, we've used an additional dataset *rnaturalearthdata* to inform the conditional autoregressive aspect of the model. Then, we built our list of data inputs formatted for our Stan model and estimated the posterior.
```
# Estimate the posterior
model <- stan_model(file = "model.stan")
fit <- sampling(model, data = stan_data, iter = 4000, warmup = 2000, chains = 4, seed = 123)
```

---

## Model Diagnostics

To assess the fit of the model, we create trace plots:
```
# Create trace plots
head(summary(fit)$summary)
mcmc_trace(as.array(fit), pars = c("mu", "sigma", "sigma_phi"))
```
Output:

<img width="591" height="275" alt="Screenshot 2025-11-19 at 3 36 35 PM" src="https://github.com/user-attachments/assets/6db89a8b-8909-4ef9-9e04-412b69ce5216" />

We observe that the trace plots for $\sigma$ and $\sigma_{phi}$ seem to be mixing well and converging, indicating that $\sigma$ is reliably estimated and the CAR prior is sampling effectively. However, the trace plot for $\mu$ shows that additional steps may need to be taken to obtain a better estimate.

---

## Posterior Visualization

This visualization tells us how much each country deviates from the global average suicide rate, after adjusting for time. Countries that are darker in color indicate a lower-than-expected suicide rate, while countries that are lighter in color indicate a higher-than-expected suicide rate.

<img width="557" height="345" alt="Screenshot 2025-11-19 at 3 41 00 PM" src="https://github.com/user-attachments/assets/e12bfc0b-5f5f-45e5-8785-46ccb41b871b" />

---

## Findings and Suggestions

This analysis provides strong evidence that there is a spatial pattern in suicide rates. Based on these results, it may be beneficial to focus on employing more mental health resources in countries like Russia and South Africa, where the suicide rates are higher than expected.

Note that the focus of this analysis is whether or not there is a spatial relationship between location and suicide rate, but it does not consider underlying factors, such as culture, mental health resources, and economic state. For example, the topic of mental health is considered to be taboo in many countries, resulting in limited access to mental health resources. 

The next step would be to incorporate Rao Blackwellization or another form of model reduction to reduce the number of parameters and procide easier interpretability. It may also be helpful to look further into these underlying factors and determine whether or not there is a relationship between the factor and suicide rate. This can be combined with information about the distribution of suicide rates across gender and age to give more insight into which subset of groups should be targeted for suicide prevention methods in certain countries. 
