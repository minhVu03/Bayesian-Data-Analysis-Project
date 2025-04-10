//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=1> N; // Number of observations = 8140
  vector[N] y;//suicide rate count (per 100,000 people) -> rate, continous

  int<lower=0, upper=1> time[N];      // Time indicator: 0 = 2019, 1 = 2021

  int<lower=1> R; //number of regions = 185
  int<lower=1, upper=R> region[N];  //Region (country) index
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real mu; // Global mean suicide rate
  real beta; // time effect (2019 vs 2021)

  vector[R] u_raw; // Raw region effects
  real<lower=0> sigma_u; //Region effect SD
  real<lower=0> sigma; //observation noise
}

transformed parameters {
  vector[R] u = sigma_u * u_raw;       // Scaled region random effects
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  // Priors (from lit review)
  mu ~ normal(9.2, 3);                  
  beta ~ normal(0.1, 0.05);
  u_raw ~ normal(0, 1);                //random intercepts
  sigma_u ~ exponential(1);
  sigma ~ exponential(1);

  // Likelihood
  for (n in 1:N)
    y[n] ~ normal(mu + beta * time[n] + u[region[n]], sigma);
}

