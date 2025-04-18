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
  int<lower=1> N;   // #of observations
  vector[N] y;//suicide rate (continuous)
  int<lower=0, upper=1> time[N];// Time indicator: 0 = 2019, 1 = 2021
  int<lower=1> R; // # regions (countries)
  int<lower=1, upper=R> region[N];//Region index per obs

  // CAR prior-specific inputs
  int<lower=0> N_edges; // # edges (adjacency links)
  int<lower=1, upper=R> node1[N_edges];
  int<lower=1, upper=R> node2[N_edges];
  int<lower=0> num_neighbors[R];// Number of neighbors per region
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real mu; // global mean suicide rate
  real beta; // time effect //remove this
  vector[R] phi;  //spatial random effect (for CAR)
  real<lower=0> sigma_phi; //SD for spatial effect
  real<lower=0> sigma;// Observation noise
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  // Priors
  mu ~ normal(9.2, 3); //lit reviewed global average
  beta ~ normal(0, 1);  //time effect prior
  sigma_phi ~ exponential(1);
  sigma ~ exponential(1);

  for (i in 1:N_edges) {
    target += -0.5 * square((phi[node1[i]] - phi[node2[i]]) / sigma_phi);
  }

  //soft sum-to-zero constraint for identifiability
  target += -0.5 * dot_self(phi) / (R * sigma_phi^2);

  //Likelihood
  for (n in 1:N) {
    y[n] ~ normal(mu + beta * time[n] + phi[region[n]], sigma);
  }
}

