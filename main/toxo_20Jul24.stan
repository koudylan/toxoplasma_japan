
// proportion of testing in 2019 and 2021 used

data {
  int T;
  int K;
  real Sus[T,K];
  int N;
  real Dos[N, K];
  real prop[K];
}

parameters {
  real<lower=0> foi[K];
  real<lower=0> shape[K];
  real<lower=0> rate[K];
  real<lower=0> sigma;
}

// The transformed parameters
transformed parameters {
  
  real inf_pre[T-1, K]; //infected at 1 month before pregnancy
  for (k in 1:K)
  for (t in 1:(T-1))
  inf_pre[t,k] = Sus[t+1, k]*(1-exp(-foi[k]));
  
  real inf[T, K]; // infected at the first month of pregnancy
  for (k in 1:K)
  for (t in 1:T)
  inf[t, k] = Sus[t, k]*(1-exp(-foi[k]));
  
  real inf_post[T, K]; // infected at the second month of pregnancy
  for (k in 1:K)
  for (t in 2:T)
  inf_post[t, k] = Sus[t-1, k]*exp(-foi[k])*(1-exp(-foi[k]));
  
  real c[T, K]; // newly treated cases
  for (k in 1:K)
  for (t in 1:13) // spiramycin is not available before Aug 2018
  c[t, k] = 0;
  for (k in 1:K)
  for (t in 14:T)
  c[t, k] = prop[k]*(inf_pre[t-2, k] + inf[t-2, k] + inf_post[t-1, k]);
  
  real dose_m[T, K];
  for (k in 1:K)
  for (t in 1:9)
  dose_m[t, k] = 0;
  for (k in 1:K)
  for (t in 10:T)
  dose_m[t, k] = 180*(c[t, k]+c[t-1, k]+c[t-2, k]+c[t-3, k]+c[t-4, k]+c[t-5, k]+c[t-6, k]+c[t-7, k]+c[t-8, k]+c[t-9, k]);
  
  real dose_y[N, K];
  for (k in 1:K)
  dose_y[1, k]=sum(dose_m[12:21, k]); // Apr 2018 to Mar 2019
  for (k in 1:K)
  dose_y[2, k]=sum(dose_m[22:33, k]); // Apr 2019 to Mar 2020
  for (k in 1:K)
  dose_y[3, k]=sum(dose_m[34:45, k]); // Apr 2020 to Mar 2021
  for (k in 1:K)
  dose_y[4, k]=sum(dose_m[46:57, k]); // Apr 2021 to Mar 2022
}

model {
  for (k in 1:K) {
  shape[k] ~ normal(0,1);
  rate[k] ~ normal(0,1);
  foi[k] ~ gamma(shape[k], rate[k]);
}
  for (k in 1:K)
   for (n in 2:N){
  Dos[n, k] ~ normal(log(sum(dose_y[2:4,k])/3), sigma);
   }
}

generated quantities{
  real all_inf[T, K]; //newly infected pregnancy at calendar time t
  real inf_2m[T, K]; //infected at the third month of pregnancy
  real inf_3m[T, K]; //infected at the fourth month of pregnancy
  real inf_4m[T, K]; //infected at the fifth month of pregnancy
  real inf_5m[T, K]; //infected at the sixth month of pregnancy
  real inf_6m[T, K]; //infected at the seventh month of pregnancy
  real inf_7m[T, K]; //infected at the eighth month of pregnancy
  real inf_8m[T, K]; //infected at the ninth month of pregnancy
  real inf_9m[T, K]; //infected at the tenth month of pregnancy
  real infected_2019[K]; //cumulative infected in 2019
  real infected_2020[K]; //cumulative infected in 2020
  real infected_2021[K]; //cumulative infected in 2021
  real treated_2019[K]; //treated proportion in 2019
  real treated_2020[K]; //treated proportion in 2020
  real treated_2021[K]; //treated proportion in 2021
  real vertical[T, K]; //pregnancy leading to vertical transmission
  real vertical_2019[K]; //cumulative congenital infections in 2019
  real vertical_2020[K]; //cumulative congenital infections in 2020
  real vertical_2021[K]; //cumulative congenital infections in 2021
  
  for (k in 1:K){
    for (t in 3:T)
    inf_2m[t, k] = Sus[t-2, k]*exp(-foi[k])^2*(1-exp(-foi[k]));
    for (t in 4:T)
    inf_3m[t, k] = Sus[t-3, k]*exp(-foi[k])^3*(1-exp(-foi[k]));
    for (t in 5:T)
    inf_4m[t, k] = Sus[t-4, k]*exp(-foi[k])^4*(1-exp(-foi[k]));
    for (t in 6:T)
    inf_5m[t, k] = Sus[t-5, k]*exp(-foi[k])^5*(1-exp(-foi[k]));
    for (t in 7:T)
    inf_6m[t, k] = Sus[t-6, k]*exp(-foi[k])^6*(1-exp(-foi[k]));
    for (t in 8:T)
    inf_7m[t, k] = Sus[t-7, k]*exp(-foi[k])^7*(1-exp(-foi[k]));
    for (t in 9:T)
    inf_8m[t, k] = Sus[t-8, k]*exp(-foi[k])^8*(1-exp(-foi[k]));
    for (t in 10:T)
    inf_9m[t, k] = Sus[t-9, k]*exp(-foi[k])^9*(1-exp(-foi[k]));
    for (t in 10:(T-1))
    all_inf[t, k] = inf_pre[t,k] + inf[t, k] + inf_post[t, k] + inf_2m[t, k] +
    inf_3m[t, k] + inf_4m[t, k] + inf_5m[t, k] + inf_6m[t, k] + inf_7m[t, k] +
    inf_8m[t, k] + inf_9m[t, k];
    
    for (t in 10:(T-1))
    vertical[t, k] = 0.1/0.5*(1-prop[k])*(inf_pre[t,k] + inf[t, k] + inf_post[t, k]) + // CT in non-testing women in 1st TM
    0.1*prop[k]*(inf_pre[t,k] + inf[t, k] + inf_post[t, k]) + // CT in tesing women in 1st TM
    0.1/0.5*(inf_2m[t, k] + inf_3m[t, k]) +  0.2/0.5*(inf_4m[t, k] + inf_5m[t, k] + inf_6m[t, k] + inf_7m[t, k]) +
    1*(inf_8m[t, k] + inf_9m[t, k]); // spiramycin assume to reduce riks of transmission by 50%
    
    infected_2019[k] = sum(all_inf[19:30, k]);
    infected_2020[k] = sum(all_inf[31:42, k]);
    infected_2021[k] = sum(all_inf[43:54, k]);
    
    treated_2019[k] = sum(c[19:30, k])/sum(all_inf[19:30,k]);
    treated_2020[k] = sum(c[31:42, k])/sum(all_inf[31:42,k]);
    treated_2021[k] = sum(c[43:54, k])/sum(all_inf[43:54,k]);
    
    vertical_2019[k] = sum(vertical[19:30, k]);
    vertical_2020[k] = sum(vertical[31:42, k]);
    vertical_2021[k] = sum(vertical[43:54, k]);
    
  }
}

