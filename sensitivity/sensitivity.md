toxoplasma_japan: sensitivity analysis
================
Ko
2024-11-28

## R markdown

This is an R Markdown document on toxoplasmosis in Japan.

## Data processing

``` r
rm(list=ls(all=TRUE))
library(tidyverse)
library(rstan)

preg <- read.csv("pregnancy_report.csv") # monthly pregnancy report from Jan 2018 to Oct 2021, corresponding to monthly pregnancy from Nov 2017 to Aug 2021
offspr <- read.csv("offsprings.csv") # monthly offspring report from Jun 2022 to Dec 2022, corresponding to monthly pregnancy from  Sep 2021 to Mar 2022
offspr2 <- read.csv("offsprings2.csv") # monthly offspring report from Apr 2018 to Jul 2018, corresponding to monthly pregnancy from Jul 2017 to Oct 2017
dose1 <- read.csv("spiramycin.csv")

# Generate a sequence of months from Jul 2017 to March 2022
months <- seq(as.Date("2017-07-01"), as.Date("2022-03-01"), by = "month")

# Generate a vector of new monthly pregnancies 
df1 <- rbind(offspr2, preg, offspr)
df1$X <- months

df2 <- subset(df1, select = c(Tokyo, Hyogo)) 
dose1 <- subset(dose1, select = c(Tokyo, Hyogo))
```

## run stan modeling

``` r
data <- list(T=57, K=2, Preg=df2, N=4, Dos=log(dose1), prop= c((0.539+0.550)/2, (0.623+0.689)/2), prev = c(0.06, 0.035)) 

stanmodel <- stan_model(file = 'sensitivity.stan') # model caring for false positive
```

    ## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
    ## using C compiler: ‘Apple clang version 17.0.0 (clang-1700.0.13.3)’
    ## using SDK: ‘MacOSX15.4.sdk’
    ## clang -arch x86_64 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DUSE_STANC3 -DSTRICT_R_HEADERS  -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION  -D_HAS_AUTO_PTR_ETC=0  -include '/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/opt/R/x86_64/include    -fPIC  -falign-functions=64 -Wall -g -O2  -c foo.c -o foo.o
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/Eigen/Core:19:
    ## /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:679:10: fatal error: 'cmath' file not found
    ##   679 | #include <cmath>
    ##       |          ^~~~~~~
    ## 1 error generated.
    ## make: *** [foo.o] Error 1

``` r
fit <- sampling(
  stanmodel,
  data=data,
  seed = 1234,
  chains=4, iter=2000, warmup=500, thin=1
)
```

    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 0.000199 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 1.99 seconds.
    ## Chain 1: Adjust your expectations accordingly!
    ## Chain 1: 
    ## Chain 1: 
    ## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 1: Iteration:  501 / 2000 [ 25%]  (Sampling)
    ## Chain 1: Iteration:  700 / 2000 [ 35%]  (Sampling)
    ## Chain 1: Iteration:  900 / 2000 [ 45%]  (Sampling)
    ## Chain 1: Iteration: 1100 / 2000 [ 55%]  (Sampling)
    ## Chain 1: Iteration: 1300 / 2000 [ 65%]  (Sampling)
    ## Chain 1: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    ## Chain 1: Iteration: 1700 / 2000 [ 85%]  (Sampling)
    ## Chain 1: Iteration: 1900 / 2000 [ 95%]  (Sampling)
    ## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 1: 
    ## Chain 1:  Elapsed Time: 1.358 seconds (Warm-up)
    ## Chain 1:                15.3 seconds (Sampling)
    ## Chain 1:                16.658 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 8.6e-05 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.86 seconds.
    ## Chain 2: Adjust your expectations accordingly!
    ## Chain 2: 
    ## Chain 2: 
    ## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 2: Iteration:  501 / 2000 [ 25%]  (Sampling)
    ## Chain 2: Iteration:  700 / 2000 [ 35%]  (Sampling)
    ## Chain 2: Iteration:  900 / 2000 [ 45%]  (Sampling)
    ## Chain 2: Iteration: 1100 / 2000 [ 55%]  (Sampling)
    ## Chain 2: Iteration: 1300 / 2000 [ 65%]  (Sampling)
    ## Chain 2: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    ## Chain 2: Iteration: 1700 / 2000 [ 85%]  (Sampling)
    ## Chain 2: Iteration: 1900 / 2000 [ 95%]  (Sampling)
    ## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 2: 
    ## Chain 2:  Elapsed Time: 2.198 seconds (Warm-up)
    ## Chain 2:                2.734 seconds (Sampling)
    ## Chain 2:                4.932 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 0.000101 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 1.01 seconds.
    ## Chain 3: Adjust your expectations accordingly!
    ## Chain 3: 
    ## Chain 3: 
    ## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 3: Iteration:  501 / 2000 [ 25%]  (Sampling)
    ## Chain 3: Iteration:  700 / 2000 [ 35%]  (Sampling)
    ## Chain 3: Iteration:  900 / 2000 [ 45%]  (Sampling)
    ## Chain 3: Iteration: 1100 / 2000 [ 55%]  (Sampling)
    ## Chain 3: Iteration: 1300 / 2000 [ 65%]  (Sampling)
    ## Chain 3: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    ## Chain 3: Iteration: 1700 / 2000 [ 85%]  (Sampling)
    ## Chain 3: Iteration: 1900 / 2000 [ 95%]  (Sampling)
    ## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 3: 
    ## Chain 3:  Elapsed Time: 2.286 seconds (Warm-up)
    ## Chain 3:                6.024 seconds (Sampling)
    ## Chain 3:                8.31 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 0.000113 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 1.13 seconds.
    ## Chain 4: Adjust your expectations accordingly!
    ## Chain 4: 
    ## Chain 4: 
    ## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
    ## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
    ## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
    ## Chain 4: Iteration:  501 / 2000 [ 25%]  (Sampling)
    ## Chain 4: Iteration:  700 / 2000 [ 35%]  (Sampling)
    ## Chain 4: Iteration:  900 / 2000 [ 45%]  (Sampling)
    ## Chain 4: Iteration: 1100 / 2000 [ 55%]  (Sampling)
    ## Chain 4: Iteration: 1300 / 2000 [ 65%]  (Sampling)
    ## Chain 4: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    ## Chain 4: Iteration: 1700 / 2000 [ 85%]  (Sampling)
    ## Chain 4: Iteration: 1900 / 2000 [ 95%]  (Sampling)
    ## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
    ## Chain 4: 
    ## Chain 4:  Elapsed Time: 7.287 seconds (Warm-up)
    ## Chain 4:                3.668 seconds (Sampling)
    ## Chain 4:                10.955 seconds (Total)
    ## Chain 4:

``` r
ms <- rstan::extract(fit)
```

## Statistics for parameters

``` r
# Create a function to calculate the desired quantile
calculate_quantiles <- function(column) {
  quantile(column, probs = c(0.025, 0.5, 0.975))
}

# List of columns to calculate quantiles (base scenario)
columns <- list(ms$foi[,1], ms$foi[,2])
# Apply the function to each column and store the results
quantiles <- lapply(columns, calculate_quantiles)
# Print the results
quantiles
```

    ## [[1]]
    ##          2.5%           50%         97.5% 
    ## 6.583910e-150  1.662191e-04  7.484123e-04 
    ## 
    ## [[2]]
    ##         2.5%          50%        97.5% 
    ## 1.197930e-70 1.605890e-07 1.525154e-04

## cumulative incidence in pregnant women

``` r
# Tokyo
i2019tk <- quantile(x=ms$infected_2019[,1], probs = c(0.025, 0.5, 0.975))
i2020tk <- quantile(x=ms$infected_2020[,1], probs = c(0.025, 0.5, 0.975))
i2021tk <- quantile(x=ms$infected_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hyogo
i2019hg <- quantile(x=ms$infected_2019[,2], probs = c(0.025, 0.5, 0.975))
i2020hg <- quantile(x=ms$infected_2020[,2], probs = c(0.025, 0.5, 0.975))
i2021hg <- quantile(x=ms$infected_2021[,2], probs = c(0.025, 0.5, 0.975))

df_infected <- tibble(
  X = rep(c("2019", "2020", "2021"),2),
  prefecture =c(rep("Tokyo", 3), rep("Hyogo", 3)),
  "50%" = c(i2019tk[2], i2020tk[2], i2021tk[2], i2019hg[2], i2020hg[2], i2021hg[2]),
  "2.5%" = c(i2019tk[1], i2020tk[1], i2021tk[1], i2019hg[1], i2020hg[1], i2021hg[1]),
  "97.5%" = c(i2019tk[3], i2020tk[3], i2021tk[3], i2019hg[3], i2020hg[3], i2021hg[3])
)

#df for infection per 10000 pregnancies
df_infected_pregnancy <- tibble(
  X = rep(c("2019", "2020", "2021"),2),
  prefecture =c(rep("Tokyo", 3), rep("Hyogo", 3)),
  "50%" = 10000*c(i2019tk[2]/sum(df1$Tokyo[19:30]), i2020tk[2]/sum(df1$Tokyo[31:42]), i2021tk[2]/sum(df1$Tokyo[43:54]), i2019hg[2]/sum(df1$Hyogo[19:30]), i2020hg[2]/sum(df1$Hyogo[31:42]), i2021hg[2]/sum(df1$Hyogo[43:54])),
  "2.5%" = 10000*c(i2019tk[1]/sum(df1$Tokyo[19:30]), i2020tk[1]/sum(df1$Tokyo[31:42]), i2021tk[1]/sum(df1$Tokyo[43:54]), i2019hg[1]/sum(df1$Hyogo[19:30]), i2020hg[1]/sum(df1$Hyogo[31:42]), i2021hg[1]/sum(df1$Hyogo[43:54])),
  "97.5%" = 10000*c(i2019tk[3]/sum(df1$Tokyo[19:30]), i2020tk[3]/sum(df1$Tokyo[31:42]), i2021tk[3]/sum(df1$Tokyo[43:54]),  i2019hg[3]/sum(df1$Hyogo[19:30]), i2020hg[3]/sum(df1$Hyogo[31:42]), i2021hg[3]/sum(df1$Hyogo[43:54]))
)
```

## cumulative CT

``` r
# df for vertical
# Tokyo
v2019tk <- quantile(x=ms$vertical_2019[,1], probs = c(0.025, 0.5, 0.975))
v2020tk <- quantile(x=ms$vertical_2020[,1], probs = c(0.025, 0.5, 0.975))
v2021tk <- quantile(x=ms$vertical_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hyogo
v2019hg <- quantile(x=ms$vertical_2019[,2], probs = c(0.025, 0.5, 0.975))
v2020hg <- quantile(x=ms$vertical_2020[,2], probs = c(0.025, 0.5, 0.975))
v2021hg <- quantile(x=ms$vertical_2021[,2], probs = c(0.025, 0.5, 0.975))

df_vertical <- tibble(
  X = rep(c("2019", "2020", "2021"),2),
  prefecture =c( rep("Tokyo", 3), rep("Hyogo", 3)),
  "50%" = c( v2019tk[2], v2020tk[2], v2021tk[2],  v2019hg[2], v2020hg[2], v2021hg[2]),
  "2.5%" = c( v2019tk[1], v2020tk[1], v2021tk[1], v2019hg[1], v2020hg[1], v2021hg[1]),
  "97.5%" = c( v2019tk[3], v2020tk[3], v2021tk[3],  v2019hg[3], v2020hg[3], v2021hg[3])
)

# df for vertical transmission per 10000 pregnancies
df_vertical_pregnancy <- tibble(
  X = rep(c("2019", "2020", "2021"),2),
  prefecture =c( rep("Tokyo", 3),  rep("Hyogo", 3)),
  "50%" = 10000*c( v2019tk[2]/sum(df1$Tokyo[19:30]), v2020tk[2]/sum(df1$Tokyo[31:42]), v2021tk[2]/sum(df1$Tokyo[43:54]),  v2019hg[2]/sum(df1$Hyogo[19:30]), v2020hg[2]/sum(df1$Hyogo[31:42]), v2021hg[2]/sum(df1$Hyogo[43:54])),
  "2.5%" = 10000*c( v2019tk[1]/sum(df1$Tokyo[19:30]), v2020tk[1]/sum(df1$Tokyo[31:42]), v2021tk[1]/sum(df1$Tokyo[43:54]), v2019hg[1]/sum(df1$Hyogo[19:30]), v2020hg[1]/sum(df1$Hyogo[31:42]), v2021hg[1]/sum(df1$Hyogo[43:54])),
  "97.5%" = 10000*c( v2019tk[3]/sum(df1$Tokyo[19:30]), v2020tk[3]/sum(df1$Tokyo[31:42]), v2021tk[3]/sum(df1$Tokyo[43:54]),  v2019hg[3]/sum(df1$Hyogo[19:30]), v2020hg[3]/sum(df1$Hyogo[31:42]), v2021hg[3]/sum(df1$Hyogo[43:54]))
)
```
