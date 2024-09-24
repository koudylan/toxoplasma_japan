toxoplasma_japan
================
Ko
2024-09-22

## R markdown

This is an R Markdown document on toxoplasmosis in Japan.

## Data processing

``` r
rm(list=ls(all=TRUE))
library(tidyverse)
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ## ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ## ✔ purrr     1.0.2     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(rstan)
```

    ## Loading required package: StanHeaders
    ## 
    ## rstan version 2.32.6 (Stan version 2.32.2)
    ## 
    ## For execution on a local, multicore CPU with excess RAM we recommend calling
    ## options(mc.cores = parallel::detectCores()).
    ## To avoid recompilation of unchanged Stan programs, we recommend calling
    ## rstan_options(auto_write = TRUE)
    ## For within-chain threading using `reduce_sum()` or `map_rect()` Stan functions,
    ## change `threads_per_chain` option:
    ## rstan_options(threads_per_chain = 1)
    ## 
    ## 
    ## Attaching package: 'rstan'
    ## 
    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

``` r
preg <- read.csv("pregnancy_report.csv") # monthly pregnancy report from Jan 2018 to Oct 2021, corresponding to monthly pregnancy from Nov 2017 to Aug 2021
offspr <- read.csv("offsprings.csv") # monthly offspring report from Jun 2022 to Dec 2022, corresponding to monthly pregnancy from  Sep 2021 to Mar 2022
offspr2 <- read.csv("offsprings2.csv") # monthly offspring report from Apr 2018 to Jul 2018, corresponding to monthly pregnancy from Jul 2017 to Oct 2017
dose1 <- read.csv("spiramycin.csv")

# Generate a sequence of months from Jul 2017 to March 2022
months <- seq(as.Date("2017-07-01"), as.Date("2022-03-01"), by = "month")

# Generate a vector of new monthly pregnancies 
df1 <- rbind(offspr2, preg, offspr)
df1$X <- months

# monthly susceptible pregnancy
df2 <- subset(df1, select = -c(X, Yamaguchi))
df2$All <- (1-0.061)*df2$All
df2$Hokkaido <- (1-0.036)*df2$Hokkaido
df2$Saitama <- (1-0.033)*df2$Saitama
df2$Chiba <- (1-0.04)*df2$Chiba
df2$Tokyo <- (1-0.06)*df2$Tokyo
df2$Osaka <- (1-0.06)*df2$Osaka
df2$Hyogo <- (1-0.035)*df2$Hyogo
df2$Nagasaki <- (1-0.021)*df2$Nagasaki
df2$Miyazaki <- (1-0.1)*df2$Miyazaki

dose1 <- subset(dose1, select = -c(X, Yamaguchi))
```

## run stan modeling

``` r
data <- list(T=57, K=9, Sus=df2, N=4, Dos=log(dose1), prop= c((0.468+0.478)/2, (0.828+0.822)/2, (0.516+0.483)/2, (0.555+0.755)/2, (0.539+0.550)/2, (0.33+0.292)/2, (0.623+0.689)/2, (0.603+0.644)/2, (0.644+0.729)/2)) # using average of testing rates in 2019 and 2021; excluding Yamaguchi

stanmodel <- stan_model(file = 'toxo_20Jul24.stan') 
```

    ## Trying to compile a simple C file

    ## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
    ## using C compiler: ‘Apple clang version 15.0.0 (clang-1500.0.40.1)’
    ## using SDK: ‘MacOSX14.0.sdk’
    ## clang -arch x86_64 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DUSE_STANC3 -DSTRICT_R_HEADERS  -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION  -D_HAS_AUTO_PTR_ETC=0  -include '/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/opt/R/x86_64/include    -fPIC  -falign-functions=64 -Wall -g -O2  -c foo.c -o foo.o
    ## In file included from <built-in>:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/Eigen/Dense:1:
    ## In file included from /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/Eigen/Core:19:
    ## /Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:679:10: fatal error: 'cmath' file not found
    ## #include <cmath>
    ##          ^~~~~~~
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
    ## Chain 1: Gradient evaluation took 0.000556 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 5.56 seconds.
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
    ## Chain 1:  Elapsed Time: 2.705 seconds (Warm-up)
    ## Chain 1:                6.034 seconds (Sampling)
    ## Chain 1:                8.739 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 0.000249 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 2.49 seconds.
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
    ## Chain 2:  Elapsed Time: 2.598 seconds (Warm-up)
    ## Chain 2:                6.051 seconds (Sampling)
    ## Chain 2:                8.649 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 0.000274 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 2.74 seconds.
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
    ## Chain 3:  Elapsed Time: 2.678 seconds (Warm-up)
    ## Chain 3:                6.034 seconds (Sampling)
    ## Chain 3:                8.712 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 0.000233 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 2.33 seconds.
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
    ## Chain 4:  Elapsed Time: 2.909 seconds (Warm-up)
    ## Chain 4:                6.14 seconds (Sampling)
    ## Chain 4:                9.049 seconds (Total)
    ## Chain 4:

    ## Warning in validityMethod(object): The following variables have undefined
    ## values: inf_post[1,1],The following variables have undefined values:
    ## inf_post[1,2],The following variables have undefined values: inf_post[1,3],The
    ## following variables have undefined values: inf_post[1,4],The following
    ## variables have undefined values: inf_post[1,5],The following variables have
    ## undefined values: inf_post[1,6],The following variables have undefined values:
    ## inf_post[1,7],The following variables have undefined values: inf_post[1,8],The
    ## following variables have undefined values: inf_post[1,9],The following
    ## variables have undefined values: all_inf[1,1],The following variables have
    ## undefined values: all_inf[2,1],The following variables have undefined values:
    ## all_inf[3,1],The following variables have undefined values: all_inf[4,1],The
    ## following variables have undefined values: all_inf[5,1],The following variables
    ## have undefined values: all_inf[6,1],The following variables have undefined
    ## values: all_inf[7,1],The following variables have undefined values:
    ## all_inf[8,1],The following variables have undefined values: all_inf[9,1],The
    ## following variables have undefined values: all_inf[57,1],The following
    ## variables have undefined values: all_inf[1,2],The following variables have
    ## undefined values: all_inf[2,2],The following variables have undefined values:
    ## all_inf[3,2],The following variables have undefined values: all_inf[4,2],The
    ## following variables have undefined values: all_inf[5,2],The following variables
    ## have undefined values: all_inf[6,2],The following variables have undefined
    ## values: all_inf[7,2],The following variables have undefined values:
    ## all_inf[8,2],The following variables have undefined values: all_inf[9,2],The
    ## following variables have undefined values: all_inf[57,2],The following
    ## variables have undefined values: all_inf[1,3],The following variables have
    ## undefined values: all_inf[2,3],The following variables have undefined values:
    ## all_inf[3,3],The following variables have undefined values: all_inf[4,3],The
    ## following variables have undefined values: all_inf[5,3],The following variables
    ## have undefined values: all_inf[6,3],The following variables have undefined
    ## values: all_inf[7,3],The following variables have undefined values:
    ## all_inf[8,3],The following variables have undefined values: all_inf[9,3],The
    ## following variables have undefined values: all_inf[57,3],The following
    ## variables have undefined values: all_inf[1,4],The following variables have
    ## undefined values: all_inf[2,4],The following variables have undefined values:
    ## all_inf[3,4],The following variables have undefined values: all_inf[4,4],The
    ## following variables have undefined values: all_inf[5,4],The following variables
    ## have undefined values: all_inf[6,4],The following variables have undefined
    ## values: all_inf[7,4],The following variables have undefined values:
    ## all_inf[8,4],The following variables have undefined values: all_inf[9,4],The
    ## following variables have undefined values: all_inf[57,4],The following
    ## variables have undefined values: all_inf[1,5],The following variables have
    ## undefined values: all_inf[2,5],The following variables have undefined values:
    ## all_inf[3,5],The following variables have undefined values: all_inf[4,5],The
    ## following variables have undefined values: all_inf[5,5],The following variables
    ## have undefined values: all_inf[6,5],The following variables have undefined
    ## values: all_inf[7,5],The following variables have undefined values:
    ## all_inf[8,5],The following variables have undefined values: all_inf[9,5],The
    ## following variables have undefined values: all_inf[57,5],The following
    ## variables have undefined values: all_inf[1,6],The following variables have
    ## undefined values: all_inf[2,6],The following variables have undefined values:
    ## all_inf[3,6],The following variables have undefined values: all_inf[4,6],The
    ## following variables have undefined values: all_inf[5,6],The following variables
    ## have undefined values: all_inf[6,6],The following variables have undefined
    ## values: all_inf[7,6],The following variables have undefined values:
    ## all_inf[8,6],The following variables have undefined values: all_inf[9,6],The
    ## following variables have undefined values: all_inf[57,6],The following
    ## variables have undefined values: all_inf[1,7],The following variables have
    ## undefined values: all_inf[2,7],The following variables have undefined values:
    ## all_inf[3,7],The following variables have undefined values: all_inf[4,7],The
    ## following variables have undefined values: all_inf[5,7],The following variables
    ## have undefined values: all_inf[6,7],The following variables have undefined
    ## values: all_inf[7,7],The following variables have undefined values:
    ## all_inf[8,7],The following variables have undefined values: all_inf[9,7],The
    ## following variables have undefined values: all_inf[57,7],The following
    ## variables have undefined values: all_inf[1,8],The following variables have
    ## undefined values: all_inf[2,8],The following variables have undefined values:
    ## all_inf[3,8],The following variables have undefined values: all_inf[4,8],The
    ## following variables have undefined values: all_inf[5,8],The following variables
    ## have undefined values: all_inf[6,8],The following variables have undefined
    ## values: all_inf[7,8],The following variables have undefined values:
    ## all_inf[8,8],The following variables have undefined values: all_inf[9,8],The
    ## following variables have undefined values: all_inf[57,8],The following
    ## variables have undefined values: all_inf[1,9],The following variables have
    ## undefined values: all_inf[2,9],The following variables have undefined values:
    ## all_inf[3,9],The following variables have undefined values: all_inf[4,9],The
    ## following variables have undefined values: all_inf[5,9],The following variables
    ## have undefined values: all_inf[6,9],The following variables have undefined
    ## values: all_inf[7,9],The following variables have undefined values:
    ## all_inf[8,9],The following variables have undefined values: all_inf[9,9],The
    ## following variables have undefined values: all_inf[57,9],The following
    ## variables have undefined values: inf_2m[1,1],The following variables have
    ## undefined values: inf_2m[2,1],The following variables have undefined values:
    ## inf_2m[1,2],The following variables have undefined values: inf_2m[2,2],The
    ## following variables have undefined values: inf_2m[1,3],The following variables
    ## have undefined values: inf_2m[2,3],The following variables have undefined
    ## values: inf_2m[1,4],The following variables have undefined values:
    ## inf_2m[2,4],The following variables have undefined values: inf_2m[1,5],The
    ## following variables have undefined values: inf_2m[2,5],The following variables
    ## have undefined values: inf_2m[1,6],The following variables have undefined
    ## values: inf_2m[2,6],The following variables have undefined values:
    ## inf_2m[1,7],The following variables have undefined values: inf_2m[2,7],The
    ## following variables have undefined values: inf_2m[1,8],The following variables
    ## have undefined values: inf_2m[2,8],The following variables have undefined
    ## values: inf_2m[1,9],The following variables have undefined values:
    ## inf_2m[2,9],The following variables have undefined values: inf_3m[1,1],The
    ## following variables have undefined values: inf_3m[2,1],The following variables
    ## have undefined values: inf_3m[3,1],The following variables have undefined
    ## values: inf_3m[1,2],The following variables have undefined values:
    ## inf_3m[2,2],The following variables have undefined values: inf_3m[3,2],The
    ## following variables have undefined values: inf_3m[1,3],The following variables
    ## have undefined values: inf_3m[2,3],The following variables have undefined
    ## values: inf_3m[3,3],The following variables have undefined values:
    ## inf_3m[1,4],The following variables have undefined values: inf_3m[2,4],The
    ## following variables have undefined values: inf_3m[3,4],The following variables
    ## have undefined values: inf_3m[1,5],The following variables have undefined
    ## values: inf_3m[2,5],The following variables have undefined values:
    ## inf_3m[3,5],The following variables have undefined values: inf_3m[1,6],The
    ## following variables have undefined values: inf_3m[2,6],The following variables
    ## have unde

``` r
ms <- rstan::extract(fit)

data2 <- list(T=57, K=9, Sus=df2, N=4, Dos=log(dose1), prop= c(0.44, 0.72, 0.32, 0.50, 0.44, 0.20, 0.51, 0.36, 0.42)) # pessimistic scenario; excluding Yamaguchi

fit2 <- sampling(
  stanmodel,
  data=data2,
  seed = 1234,
  chains=4, iter=2000, warmup=500, thin=1
)
```

    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 0.001441 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 14.41 seconds.
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
    ## Chain 1:  Elapsed Time: 2.736 seconds (Warm-up)
    ## Chain 1:                6.266 seconds (Sampling)
    ## Chain 1:                9.002 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 0.000228 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 2.28 seconds.
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
    ## Chain 2:  Elapsed Time: 2.736 seconds (Warm-up)
    ## Chain 2:                6.018 seconds (Sampling)
    ## Chain 2:                8.754 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 0.000268 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 2.68 seconds.
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
    ## Chain 3:  Elapsed Time: 2.755 seconds (Warm-up)
    ## Chain 3:                5.893 seconds (Sampling)
    ## Chain 3:                8.648 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 0.000293 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 2.93 seconds.
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
    ## Chain 4:  Elapsed Time: 2.764 seconds (Warm-up)
    ## Chain 4:                5.591 seconds (Sampling)
    ## Chain 4:                8.355 seconds (Total)
    ## Chain 4:

    ## Warning in validityMethod(object): The following variables have undefined
    ## values: inf_post[1,1],The following variables have undefined values:
    ## inf_post[1,2],The following variables have undefined values: inf_post[1,3],The
    ## following variables have undefined values: inf_post[1,4],The following
    ## variables have undefined values: inf_post[1,5],The following variables have
    ## undefined values: inf_post[1,6],The following variables have undefined values:
    ## inf_post[1,7],The following variables have undefined values: inf_post[1,8],The
    ## following variables have undefined values: inf_post[1,9],The following
    ## variables have undefined values: all_inf[1,1],The following variables have
    ## undefined values: all_inf[2,1],The following variables have undefined values:
    ## all_inf[3,1],The following variables have undefined values: all_inf[4,1],The
    ## following variables have undefined values: all_inf[5,1],The following variables
    ## have undefined values: all_inf[6,1],The following variables have undefined
    ## values: all_inf[7,1],The following variables have undefined values:
    ## all_inf[8,1],The following variables have undefined values: all_inf[9,1],The
    ## following variables have undefined values: all_inf[57,1],The following
    ## variables have undefined values: all_inf[1,2],The following variables have
    ## undefined values: all_inf[2,2],The following variables have undefined values:
    ## all_inf[3,2],The following variables have undefined values: all_inf[4,2],The
    ## following variables have undefined values: all_inf[5,2],The following variables
    ## have undefined values: all_inf[6,2],The following variables have undefined
    ## values: all_inf[7,2],The following variables have undefined values:
    ## all_inf[8,2],The following variables have undefined values: all_inf[9,2],The
    ## following variables have undefined values: all_inf[57,2],The following
    ## variables have undefined values: all_inf[1,3],The following variables have
    ## undefined values: all_inf[2,3],The following variables have undefined values:
    ## all_inf[3,3],The following variables have undefined values: all_inf[4,3],The
    ## following variables have undefined values: all_inf[5,3],The following variables
    ## have undefined values: all_inf[6,3],The following variables have undefined
    ## values: all_inf[7,3],The following variables have undefined values:
    ## all_inf[8,3],The following variables have undefined values: all_inf[9,3],The
    ## following variables have undefined values: all_inf[57,3],The following
    ## variables have undefined values: all_inf[1,4],The following variables have
    ## undefined values: all_inf[2,4],The following variables have undefined values:
    ## all_inf[3,4],The following variables have undefined values: all_inf[4,4],The
    ## following variables have undefined values: all_inf[5,4],The following variables
    ## have undefined values: all_inf[6,4],The following variables have undefined
    ## values: all_inf[7,4],The following variables have undefined values:
    ## all_inf[8,4],The following variables have undefined values: all_inf[9,4],The
    ## following variables have undefined values: all_inf[57,4],The following
    ## variables have undefined values: all_inf[1,5],The following variables have
    ## undefined values: all_inf[2,5],The following variables have undefined values:
    ## all_inf[3,5],The following variables have undefined values: all_inf[4,5],The
    ## following variables have undefined values: all_inf[5,5],The following variables
    ## have undefined values: all_inf[6,5],The following variables have undefined
    ## values: all_inf[7,5],The following variables have undefined values:
    ## all_inf[8,5],The following variables have undefined values: all_inf[9,5],The
    ## following variables have undefined values: all_inf[57,5],The following
    ## variables have undefined values: all_inf[1,6],The following variables have
    ## undefined values: all_inf[2,6],The following variables have undefined values:
    ## all_inf[3,6],The following variables have undefined values: all_inf[4,6],The
    ## following variables have undefined values: all_inf[5,6],The following variables
    ## have undefined values: all_inf[6,6],The following variables have undefined
    ## values: all_inf[7,6],The following variables have undefined values:
    ## all_inf[8,6],The following variables have undefined values: all_inf[9,6],The
    ## following variables have undefined values: all_inf[57,6],The following
    ## variables have undefined values: all_inf[1,7],The following variables have
    ## undefined values: all_inf[2,7],The following variables have undefined values:
    ## all_inf[3,7],The following variables have undefined values: all_inf[4,7],The
    ## following variables have undefined values: all_inf[5,7],The following variables
    ## have undefined values: all_inf[6,7],The following variables have undefined
    ## values: all_inf[7,7],The following variables have undefined values:
    ## all_inf[8,7],The following variables have undefined values: all_inf[9,7],The
    ## following variables have undefined values: all_inf[57,7],The following
    ## variables have undefined values: all_inf[1,8],The following variables have
    ## undefined values: all_inf[2,8],The following variables have undefined values:
    ## all_inf[3,8],The following variables have undefined values: all_inf[4,8],The
    ## following variables have undefined values: all_inf[5,8],The following variables
    ## have undefined values: all_inf[6,8],The following variables have undefined
    ## values: all_inf[7,8],The following variables have undefined values:
    ## all_inf[8,8],The following variables have undefined values: all_inf[9,8],The
    ## following variables have undefined values: all_inf[57,8],The following
    ## variables have undefined values: all_inf[1,9],The following variables have
    ## undefined values: all_inf[2,9],The following variables have undefined values:
    ## all_inf[3,9],The following variables have undefined values: all_inf[4,9],The
    ## following variables have undefined values: all_inf[5,9],The following variables
    ## have undefined values: all_inf[6,9],The following variables have undefined
    ## values: all_inf[7,9],The following variables have undefined values:
    ## all_inf[8,9],The following variables have undefined values: all_inf[9,9],The
    ## following variables have undefined values: all_inf[57,9],The following
    ## variables have undefined values: inf_2m[1,1],The following variables have
    ## undefined values: inf_2m[2,1],The following variables have undefined values:
    ## inf_2m[1,2],The following variables have undefined values: inf_2m[2,2],The
    ## following variables have undefined values: inf_2m[1,3],The following variables
    ## have undefined values: inf_2m[2,3],The following variables have undefined
    ## values: inf_2m[1,4],The following variables have undefined values:
    ## inf_2m[2,4],The following variables have undefined values: inf_2m[1,5],The
    ## following variables have undefined values: inf_2m[2,5],The following variables
    ## have undefined values: inf_2m[1,6],The following variables have undefined
    ## values: inf_2m[2,6],The following variables have undefined values:
    ## inf_2m[1,7],The following variables have undefined values: inf_2m[2,7],The
    ## following variables have undefined values: inf_2m[1,8],The following variables
    ## have undefined values: inf_2m[2,8],The following variables have undefined
    ## values: inf_2m[1,9],The following variables have undefined values:
    ## inf_2m[2,9],The following variables have undefined values: inf_3m[1,1],The
    ## following variables have undefined values: inf_3m[2,1],The following variables
    ## have undefined values: inf_3m[3,1],The following variables have undefined
    ## values: inf_3m[1,2],The following variables have undefined values:
    ## inf_3m[2,2],The following variables have undefined values: inf_3m[3,2],The
    ## following variables have undefined values: inf_3m[1,3],The following variables
    ## have undefined values: inf_3m[2,3],The following variables have undefined
    ## values: inf_3m[3,3],The following variables have undefined values:
    ## inf_3m[1,4],The following variables have undefined values: inf_3m[2,4],The
    ## following variables have undefined values: inf_3m[3,4],The following variables
    ## have undefined values: inf_3m[1,5],The following variables have undefined
    ## values: inf_3m[2,5],The following variables have undefined values:
    ## inf_3m[3,5],The following variables have undefined values: inf_3m[1,6],The
    ## following variables have undefined values: inf_3m[2,6],The following variables
    ## have unde

``` r
ms2 <- rstan::extract(fit2)

data3 <- list(T=57, K=9, Sus=df2, N=4, Dos=log(dose1), prop= c(0.51, 0.94, 0.68, 0.82, 0.66, 0.47, 0.81, 0.89, 0.96)) # optimistic scenario; excluding Yamaguchi

fit3 <- sampling(
  stanmodel,
  data=data3,
  seed = 1234,
  chains=4, iter=2000, warmup=500, thin=1
)
```

    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
    ## Chain 1: 
    ## Chain 1: Gradient evaluation took 0.00106 seconds
    ## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 10.6 seconds.
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
    ## Chain 1:  Elapsed Time: 2.879 seconds (Warm-up)
    ## Chain 1:                5.872 seconds (Sampling)
    ## Chain 1:                8.751 seconds (Total)
    ## Chain 1: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
    ## Chain 2: 
    ## Chain 2: Gradient evaluation took 0.000229 seconds
    ## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 2.29 seconds.
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
    ## Chain 2:  Elapsed Time: 2.802 seconds (Warm-up)
    ## Chain 2:                6.091 seconds (Sampling)
    ## Chain 2:                8.893 seconds (Total)
    ## Chain 2: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
    ## Chain 3: 
    ## Chain 3: Gradient evaluation took 0.000256 seconds
    ## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 2.56 seconds.
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
    ## Chain 3:  Elapsed Time: 2.923 seconds (Warm-up)
    ## Chain 3:                6.066 seconds (Sampling)
    ## Chain 3:                8.989 seconds (Total)
    ## Chain 3: 
    ## 
    ## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
    ## Chain 4: 
    ## Chain 4: Gradient evaluation took 0.000246 seconds
    ## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 2.46 seconds.
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
    ## Chain 4:  Elapsed Time: 2.583 seconds (Warm-up)
    ## Chain 4:                6.016 seconds (Sampling)
    ## Chain 4:                8.599 seconds (Total)
    ## Chain 4:

    ## Warning in validityMethod(object): The following variables have undefined
    ## values: inf_post[1,1],The following variables have undefined values:
    ## inf_post[1,2],The following variables have undefined values: inf_post[1,3],The
    ## following variables have undefined values: inf_post[1,4],The following
    ## variables have undefined values: inf_post[1,5],The following variables have
    ## undefined values: inf_post[1,6],The following variables have undefined values:
    ## inf_post[1,7],The following variables have undefined values: inf_post[1,8],The
    ## following variables have undefined values: inf_post[1,9],The following
    ## variables have undefined values: all_inf[1,1],The following variables have
    ## undefined values: all_inf[2,1],The following variables have undefined values:
    ## all_inf[3,1],The following variables have undefined values: all_inf[4,1],The
    ## following variables have undefined values: all_inf[5,1],The following variables
    ## have undefined values: all_inf[6,1],The following variables have undefined
    ## values: all_inf[7,1],The following variables have undefined values:
    ## all_inf[8,1],The following variables have undefined values: all_inf[9,1],The
    ## following variables have undefined values: all_inf[57,1],The following
    ## variables have undefined values: all_inf[1,2],The following variables have
    ## undefined values: all_inf[2,2],The following variables have undefined values:
    ## all_inf[3,2],The following variables have undefined values: all_inf[4,2],The
    ## following variables have undefined values: all_inf[5,2],The following variables
    ## have undefined values: all_inf[6,2],The following variables have undefined
    ## values: all_inf[7,2],The following variables have undefined values:
    ## all_inf[8,2],The following variables have undefined values: all_inf[9,2],The
    ## following variables have undefined values: all_inf[57,2],The following
    ## variables have undefined values: all_inf[1,3],The following variables have
    ## undefined values: all_inf[2,3],The following variables have undefined values:
    ## all_inf[3,3],The following variables have undefined values: all_inf[4,3],The
    ## following variables have undefined values: all_inf[5,3],The following variables
    ## have undefined values: all_inf[6,3],The following variables have undefined
    ## values: all_inf[7,3],The following variables have undefined values:
    ## all_inf[8,3],The following variables have undefined values: all_inf[9,3],The
    ## following variables have undefined values: all_inf[57,3],The following
    ## variables have undefined values: all_inf[1,4],The following variables have
    ## undefined values: all_inf[2,4],The following variables have undefined values:
    ## all_inf[3,4],The following variables have undefined values: all_inf[4,4],The
    ## following variables have undefined values: all_inf[5,4],The following variables
    ## have undefined values: all_inf[6,4],The following variables have undefined
    ## values: all_inf[7,4],The following variables have undefined values:
    ## all_inf[8,4],The following variables have undefined values: all_inf[9,4],The
    ## following variables have undefined values: all_inf[57,4],The following
    ## variables have undefined values: all_inf[1,5],The following variables have
    ## undefined values: all_inf[2,5],The following variables have undefined values:
    ## all_inf[3,5],The following variables have undefined values: all_inf[4,5],The
    ## following variables have undefined values: all_inf[5,5],The following variables
    ## have undefined values: all_inf[6,5],The following variables have undefined
    ## values: all_inf[7,5],The following variables have undefined values:
    ## all_inf[8,5],The following variables have undefined values: all_inf[9,5],The
    ## following variables have undefined values: all_inf[57,5],The following
    ## variables have undefined values: all_inf[1,6],The following variables have
    ## undefined values: all_inf[2,6],The following variables have undefined values:
    ## all_inf[3,6],The following variables have undefined values: all_inf[4,6],The
    ## following variables have undefined values: all_inf[5,6],The following variables
    ## have undefined values: all_inf[6,6],The following variables have undefined
    ## values: all_inf[7,6],The following variables have undefined values:
    ## all_inf[8,6],The following variables have undefined values: all_inf[9,6],The
    ## following variables have undefined values: all_inf[57,6],The following
    ## variables have undefined values: all_inf[1,7],The following variables have
    ## undefined values: all_inf[2,7],The following variables have undefined values:
    ## all_inf[3,7],The following variables have undefined values: all_inf[4,7],The
    ## following variables have undefined values: all_inf[5,7],The following variables
    ## have undefined values: all_inf[6,7],The following variables have undefined
    ## values: all_inf[7,7],The following variables have undefined values:
    ## all_inf[8,7],The following variables have undefined values: all_inf[9,7],The
    ## following variables have undefined values: all_inf[57,7],The following
    ## variables have undefined values: all_inf[1,8],The following variables have
    ## undefined values: all_inf[2,8],The following variables have undefined values:
    ## all_inf[3,8],The following variables have undefined values: all_inf[4,8],The
    ## following variables have undefined values: all_inf[5,8],The following variables
    ## have undefined values: all_inf[6,8],The following variables have undefined
    ## values: all_inf[7,8],The following variables have undefined values:
    ## all_inf[8,8],The following variables have undefined values: all_inf[9,8],The
    ## following variables have undefined values: all_inf[57,8],The following
    ## variables have undefined values: all_inf[1,9],The following variables have
    ## undefined values: all_inf[2,9],The following variables have undefined values:
    ## all_inf[3,9],The following variables have undefined values: all_inf[4,9],The
    ## following variables have undefined values: all_inf[5,9],The following variables
    ## have undefined values: all_inf[6,9],The following variables have undefined
    ## values: all_inf[7,9],The following variables have undefined values:
    ## all_inf[8,9],The following variables have undefined values: all_inf[9,9],The
    ## following variables have undefined values: all_inf[57,9],The following
    ## variables have undefined values: inf_2m[1,1],The following variables have
    ## undefined values: inf_2m[2,1],The following variables have undefined values:
    ## inf_2m[1,2],The following variables have undefined values: inf_2m[2,2],The
    ## following variables have undefined values: inf_2m[1,3],The following variables
    ## have undefined values: inf_2m[2,3],The following variables have undefined
    ## values: inf_2m[1,4],The following variables have undefined values:
    ## inf_2m[2,4],The following variables have undefined values: inf_2m[1,5],The
    ## following variables have undefined values: inf_2m[2,5],The following variables
    ## have undefined values: inf_2m[1,6],The following variables have undefined
    ## values: inf_2m[2,6],The following variables have undefined values:
    ## inf_2m[1,7],The following variables have undefined values: inf_2m[2,7],The
    ## following variables have undefined values: inf_2m[1,8],The following variables
    ## have undefined values: inf_2m[2,8],The following variables have undefined
    ## values: inf_2m[1,9],The following variables have undefined values:
    ## inf_2m[2,9],The following variables have undefined values: inf_3m[1,1],The
    ## following variables have undefined values: inf_3m[2,1],The following variables
    ## have undefined values: inf_3m[3,1],The following variables have undefined
    ## values: inf_3m[1,2],The following variables have undefined values:
    ## inf_3m[2,2],The following variables have undefined values: inf_3m[3,2],The
    ## following variables have undefined values: inf_3m[1,3],The following variables
    ## have undefined values: inf_3m[2,3],The following variables have undefined
    ## values: inf_3m[3,3],The following variables have undefined values:
    ## inf_3m[1,4],The following variables have undefined values: inf_3m[2,4],The
    ## following variables have undefined values: inf_3m[3,4],The following variables
    ## have undefined values: inf_3m[1,5],The following variables have undefined
    ## values: inf_3m[2,5],The following variables have undefined values:
    ## inf_3m[3,5],The following variables have undefined values: inf_3m[1,6],The
    ## following variables have undefined values: inf_3m[2,6],The following variables
    ## have unde

``` r
ms3 <- rstan::extract(fit3)
```

## Statistics for parameters

``` r
# Create a function to calculate the desired quantile
calculate_quantiles <- function(column) {
  quantile(column, probs = c(0.025, 0.5, 0.975))
}

# List of columns to calculate quantiles (base scenario)
columns <- list(ms$foi[,1], ms$foi[,2], ms$foi[,3], ms$foi[,4], ms$foi[,5], ms$foi[,6], ms$foi[,7], ms$foi[,8], ms$foi[,9])
# Apply the function to each column and store the results
quantiles <- lapply(columns, calculate_quantiles)
# Print the results
quantiles
```

    ## [[1]]
    ##         2.5%          50%        97.5% 
    ## 9.016616e-05 1.589772e-04 2.812417e-04 
    ## 
    ## [[2]]
    ##         2.5%          50%        97.5% 
    ## 9.895879e-05 1.770046e-04 3.134047e-04 
    ## 
    ## [[3]]
    ##         2.5%          50%        97.5% 
    ## 0.0001367754 0.0002402230 0.0004264372 
    ## 
    ## [[4]]
    ##         2.5%          50%        97.5% 
    ## 0.0000692653 0.0001233995 0.0002219979 
    ## 
    ## [[5]]
    ##         2.5%          50%        97.5% 
    ## 0.0001720526 0.0003054319 0.0005369985 
    ## 
    ## [[6]]
    ##         2.5%          50%        97.5% 
    ## 4.686652e-05 8.263700e-05 1.481041e-04 
    ## 
    ## [[7]]
    ##         2.5%          50%        97.5% 
    ## 5.630156e-05 1.005853e-04 1.849309e-04 
    ## 
    ## [[8]]
    ##         2.5%          50%        97.5% 
    ## 0.0001000079 0.0001756092 0.0003154619 
    ## 
    ## [[9]]
    ##         2.5%          50%        97.5% 
    ## 6.612495e-05 1.167011e-04 2.093481e-04

``` r
columns <- list(ms$shape[,1], ms$shape[,2], ms$shape[,3], ms$shape[,4], ms$shape[,5], ms$shape[,6], ms$shape[,7], ms$shape[,8], ms$shape[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##       2.5%        50%      97.5% 
    ## 0.02523108 0.18480546 0.58493158 
    ## 
    ## [[2]]
    ##       2.5%        50%      97.5% 
    ## 0.02704562 0.18612499 0.60496094 
    ## 
    ## [[3]]
    ##       2.5%        50%      97.5% 
    ## 0.02676928 0.19213114 0.62818191 
    ## 
    ## [[4]]
    ##       2.5%        50%      97.5% 
    ## 0.02764149 0.18104624 0.56680633 
    ## 
    ## [[5]]
    ##       2.5%        50%      97.5% 
    ## 0.02941774 0.19490687 0.63620766 
    ## 
    ## [[6]]
    ##       2.5%        50%      97.5% 
    ## 0.02810415 0.17349220 0.54914108 
    ## 
    ## [[7]]
    ##       2.5%        50%      97.5% 
    ## 0.02502281 0.17531817 0.55213710 
    ## 
    ## [[8]]
    ##       2.5%        50%      97.5% 
    ## 0.02301023 0.18393056 0.61723822 
    ## 
    ## [[9]]
    ##       2.5%        50%      97.5% 
    ## 0.02799538 0.18052440 0.57550491

``` r
columns <- list(ms$rate[,1], ms$rate[,2], ms$rate[,3], ms$rate[,4], ms$rate[,5], ms$rate[,6], ms$rate[,7], ms$rate[,8], ms$rate[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##       2.5%        50%      97.5% 
    ## 0.05152404 0.79507307 2.35149076 
    ## 
    ## [[2]]
    ##       2.5%        50%      97.5% 
    ## 0.05506121 0.80735560 2.39049841 
    ## 
    ## [[3]]
    ##      2.5%       50%     97.5% 
    ## 0.0610277 0.8032573 2.3483871 
    ## 
    ## [[4]]
    ##       2.5%        50%      97.5% 
    ## 0.07060946 0.80924386 2.33189046 
    ## 
    ## [[5]]
    ##       2.5%        50%      97.5% 
    ## 0.06498348 0.78804664 2.38482357 
    ## 
    ## [[6]]
    ##       2.5%        50%      97.5% 
    ## 0.06225799 0.77257585 2.32729268 
    ## 
    ## [[7]]
    ##       2.5%        50%      97.5% 
    ## 0.05945291 0.79480388 2.37805587 
    ## 
    ## [[8]]
    ##       2.5%        50%      97.5% 
    ## 0.06033962 0.79221658 2.43156486 
    ## 
    ## [[9]]
    ##       2.5%        50%      97.5% 
    ## 0.06068715 0.80079665 2.37958109

``` r
quantile(ms$sigma, probs = c(0.025, 0.5, 0.975))
```

    ##      2.5%       50%     97.5% 
    ## 0.3534504 0.4816901 0.7072427

``` r
# List of columns to calculate quantiles (pessimistic scenario)
columns <- list(ms2$foi[,1], ms2$foi[,2], ms2$foi[,3], ms2$foi[,4], ms2$foi[,5], ms2$foi[,6], ms2$foi[,7], ms2$foi[,8], ms2$foi[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##         2.5%          50%        97.5% 
    ## 9.783218e-05 1.704966e-04 2.985337e-04 
    ## 
    ## [[2]]
    ##         2.5%          50%        97.5% 
    ## 0.0001126556 0.0002004853 0.0003644133 
    ## 
    ## [[3]]
    ##         2.5%          50%        97.5% 
    ## 0.0002107458 0.0003759633 0.0006736825 
    ## 
    ## [[4]]
    ##         2.5%          50%        97.5% 
    ## 9.078563e-05 1.632329e-04 2.921353e-04 
    ## 
    ## [[5]]
    ##         2.5%          50%        97.5% 
    ## 0.0002141039 0.0003769317 0.0006652625 
    ## 
    ## [[6]]
    ##         2.5%          50%        97.5% 
    ## 7.351666e-05 1.296045e-04 2.317177e-04 
    ## 
    ## [[7]]
    ##         2.5%          50%        97.5% 
    ## 7.271034e-05 1.309085e-04 2.352554e-04 
    ## 
    ## [[8]]
    ##         2.5%          50%        97.5% 
    ## 0.0001742987 0.0003071746 0.0005424237 
    ## 
    ## [[9]]
    ##         2.5%          50%        97.5% 
    ## 0.0001088027 0.0001913165 0.0003356134

``` r
columns <- list(ms2$shape[,1], ms2$shape[,2], ms2$shape[,3], ms2$shape[,4], ms2$shape[,5], ms2$shape[,6], ms2$shape[,7], ms2$shape[,8], ms2$shape[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##       2.5%        50%      97.5% 
    ## 0.02517379 0.18525033 0.60703017 
    ## 
    ## [[2]]
    ##      2.5%       50%     97.5% 
    ## 0.0287752 0.1843476 0.6019582 
    ## 
    ## [[3]]
    ##       2.5%        50%      97.5% 
    ## 0.02808486 0.19942661 0.68465909 
    ## 
    ## [[4]]
    ##       2.5%        50%      97.5% 
    ## 0.02659294 0.18702226 0.58965260 
    ## 
    ## [[5]]
    ##       2.5%        50%      97.5% 
    ## 0.02989545 0.20368178 0.64210057 
    ## 
    ## [[6]]
    ##       2.5%        50%      97.5% 
    ## 0.02831151 0.17843078 0.57865802 
    ## 
    ## [[7]]
    ##       2.5%        50%      97.5% 
    ## 0.02581614 0.17928060 0.60220024 
    ## 
    ## [[8]]
    ##       2.5%        50%      97.5% 
    ## 0.03208225 0.20041256 0.61857698 
    ## 
    ## [[9]]
    ##       2.5%        50%      97.5% 
    ## 0.02696798 0.18358878 0.63103795

``` r
columns <- list(ms2$rate[,1], ms2$rate[,2], ms2$rate[,3], ms2$rate[,4], ms2$rate[,5], ms2$rate[,6], ms2$rate[,7], ms2$rate[,8], ms2$rate[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##       2.5%        50%      97.5% 
    ## 0.05840465 0.79900631 2.38056120 
    ## 
    ## [[2]]
    ##       2.5%        50%      97.5% 
    ## 0.05201326 0.80450442 2.33144519 
    ## 
    ## [[3]]
    ##       2.5%        50%      97.5% 
    ## 0.05720631 0.81788058 2.35310266 
    ## 
    ## [[4]]
    ##       2.5%        50%      97.5% 
    ## 0.05222829 0.77780457 2.38792143 
    ## 
    ## [[5]]
    ##       2.5%        50%      97.5% 
    ## 0.05847035 0.81123740 2.39172088 
    ## 
    ## [[6]]
    ##      2.5%       50%     97.5% 
    ## 0.0610204 0.7927628 2.3345666 
    ## 
    ## [[7]]
    ##       2.5%        50%      97.5% 
    ## 0.04921648 0.79299698 2.44505783 
    ## 
    ## [[8]]
    ##       2.5%        50%      97.5% 
    ## 0.06417437 0.82953324 2.39392584 
    ## 
    ## [[9]]
    ##      2.5%       50%     97.5% 
    ## 0.0531022 0.7911258 2.4058078

``` r
quantile(ms2$sigma, probs = c(0.025, 0.5, 0.975))
```

    ##      2.5%       50%     97.5% 
    ## 0.3572636 0.4828624 0.7173553

``` r
# List of columns to calculate quantiles (opportunistic scenario)
columns <- list(ms3$foi[,1], ms3$foi[,2], ms3$foi[,3], ms3$foi[,4], ms3$foi[,5], ms3$foi[,6], ms3$foi[,7], ms3$foi[,8], ms3$foi[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##         2.5%          50%        97.5% 
    ## 0.0000829258 0.0001474193 0.0002618593 
    ## 
    ## [[2]]
    ##         2.5%          50%        97.5% 
    ## 8.775484e-05 1.535529e-04 2.760381e-04 
    ## 
    ## [[3]]
    ##         2.5%          50%        97.5% 
    ## 0.0001003399 0.0001763220 0.0003200396 
    ## 
    ## [[4]]
    ##         2.5%          50%        97.5% 
    ## 5.715167e-05 9.924328e-05 1.778416e-04 
    ## 
    ## [[5]]
    ##         2.5%          50%        97.5% 
    ## 0.0001360267 0.0002502063 0.0004529776 
    ## 
    ## [[6]]
    ##         2.5%          50%        97.5% 
    ## 3.100814e-05 5.538859e-05 9.926577e-05 
    ## 
    ## [[7]]
    ##         2.5%          50%        97.5% 
    ## 4.676341e-05 8.244476e-05 1.446781e-04 
    ## 
    ## [[8]]
    ##         2.5%          50%        97.5% 
    ## 0.0000695512 0.0001229828 0.0002181975 
    ## 
    ## [[9]]
    ##         2.5%          50%        97.5% 
    ## 4.711920e-05 8.374096e-05 1.507100e-04

``` r
columns <- list(ms3$shape[,1], ms3$shape[,2], ms3$shape[,3], ms3$shape[,4], ms3$shape[,5], ms3$shape[,6], ms3$shape[,7], ms3$shape[,8], ms3$shape[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##       2.5%        50%      97.5% 
    ## 0.02566814 0.18086911 0.58099329 
    ## 
    ## [[2]]
    ##       2.5%        50%      97.5% 
    ## 0.02834936 0.18322036 0.57837729 
    ## 
    ## [[3]]
    ##       2.5%        50%      97.5% 
    ## 0.02496227 0.18305892 0.60321371 
    ## 
    ## [[4]]
    ##       2.5%        50%      97.5% 
    ## 0.02551654 0.17561954 0.56158175 
    ## 
    ## [[5]]
    ##       2.5%        50%      97.5% 
    ## 0.02779392 0.19465703 0.63332347 
    ## 
    ## [[6]]
    ##       2.5%        50%      97.5% 
    ## 0.02286323 0.16583524 0.53200615 
    ## 
    ## [[7]]
    ##       2.5%        50%      97.5% 
    ## 0.02652313 0.17253409 0.53430583 
    ## 
    ## [[8]]
    ##       2.5%        50%      97.5% 
    ## 0.02432844 0.17743157 0.58366545 
    ## 
    ## [[9]]
    ##      2.5%       50%     97.5% 
    ## 0.0270521 0.1707166 0.5547232

``` r
columns <- list(ms3$rate[,1], ms3$rate[,2], ms3$rate[,3], ms3$rate[,4], ms3$rate[,5], ms3$rate[,6], ms3$rate[,7], ms3$rate[,8], ms3$rate[,9])
quantiles <- lapply(columns, calculate_quantiles)
quantiles
```

    ## [[1]]
    ##       2.5%        50%      97.5% 
    ## 0.05691197 0.81302857 2.38987171 
    ## 
    ## [[2]]
    ##      2.5%       50%     97.5% 
    ## 0.0612851 0.8124725 2.3461462 
    ## 
    ## [[3]]
    ##       2.5%        50%      97.5% 
    ## 0.05566484 0.78680424 2.35072299 
    ## 
    ## [[4]]
    ##       2.5%        50%      97.5% 
    ## 0.05827626 0.79988283 2.38097320 
    ## 
    ## [[5]]
    ##       2.5%        50%      97.5% 
    ## 0.06554131 0.82809343 2.38703935 
    ## 
    ## [[6]]
    ##       2.5%        50%      97.5% 
    ## 0.05953136 0.79476764 2.33712029 
    ## 
    ## [[7]]
    ##       2.5%        50%      97.5% 
    ## 0.05457327 0.80088106 2.39118313 
    ## 
    ## [[8]]
    ##       2.5%        50%      97.5% 
    ## 0.06899937 0.81105478 2.32253213 
    ## 
    ## [[9]]
    ##      2.5%       50%     97.5% 
    ## 0.0453980 0.7847309 2.3729983

``` r
quantile(ms3$sigma, probs = c(0.025, 0.5, 0.975))
```

    ##      2.5%       50%     97.5% 
    ## 0.3554526 0.4834272 0.6975154

## Figure 1 (observed and estimated doses)

``` r
## df for doses
dose2 <- read.csv("spiramycin.csv")
dose2 <- subset(dose2, select = -c(Yamaguchi))
# create tidy table
d <- pivot_longer(dose2,
             cols = c(All, Hokkaido, Saitama, Chiba, Tokyo, Osaka, Hyogo, Nagasaki, Miyazaki),
             names_to = "prefecture",
             values_to = "doses"
             )
d <- d %>% filter(!(X=="2018"))
d$X <- recode(as.character(d$X), '2019' ="2019", '2020' ="2020", '2021'="2021")

N_mcmc <- length(ms$lp__)

# all
y_2019_all <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,1]), sd=ms$sigma))
y_2020_all <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,1]), sd=ms$sigma))
y_2021_all <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,1]), sd=ms$sigma))

d2019 <- quantile(x=y_2019_all, probs = c(0.025, 0.5, 0.975))
d2020 <- quantile(x=y_2020_all, probs = c(0.025, 0.5, 0.975))
d2021 <- quantile(x=y_2021_all, probs = c(0.025, 0.5, 0.975))

#Hokkaido
y_2019_Hkd <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,2]), sd=ms$sigma))
y_2020_Hkd <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,2]), sd=ms$sigma))
y_2021_Hkd <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,2]), sd=ms$sigma))

d2019hkd <- quantile(x=y_2019_Hkd, probs = c(0.025, 0.5, 0.975))
d2020hkd <- quantile(x=y_2020_Hkd, probs = c(0.025, 0.5, 0.975))
d2021hkd <- quantile(x=y_2021_Hkd, probs = c(0.025, 0.5, 0.975))

#Saitama
y_2019_Stm <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,3]), sd=ms$sigma))
y_2020_Stm <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,3]), sd=ms$sigma))
y_2021_Stm <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,3]), sd=ms$sigma))

d2019stm <- quantile(x=y_2019_Stm, probs = c(0.025, 0.5, 0.975))
d2020stm <- quantile(x=y_2020_Stm, probs = c(0.025, 0.5, 0.975))
d2021stm <- quantile(x=y_2021_Stm, probs = c(0.025, 0.5, 0.975))

#Chiba
y_2019_Cba <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,4]), sd=ms$sigma))
y_2020_Cba <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,4]), sd=ms$sigma))
y_2021_Cba <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,4]), sd=ms$sigma))

d2019cba <- quantile(x=y_2019_Cba, probs = c(0.025, 0.5, 0.975))
d2020cba <- quantile(x=y_2020_Cba, probs = c(0.025, 0.5, 0.975))
d2021cba <- quantile(x=y_2021_Cba, probs = c(0.025, 0.5, 0.975))

#Tokyo
y_2019_Tk <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,5]), sd=ms$sigma))
y_2020_Tk <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,5]), sd=ms$sigma))
y_2021_Tk <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,5]), sd=ms$sigma))

d2019tk <- quantile(x=y_2019_Tk, probs = c(0.025, 0.5, 0.975))
d2020tk <- quantile(x=y_2020_Tk, probs = c(0.025, 0.5, 0.975))
d2021tk <- quantile(x=y_2021_Tk, probs = c(0.025, 0.5, 0.975))

#Osaka
y_2019_Os <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,6]), sd=ms$sigma))
y_2020_Os <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,6]), sd=ms$sigma))
y_2021_Os <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,6]), sd=ms$sigma))

d2019os <- quantile(x=y_2019_Os, probs = c(0.025, 0.5, 0.975))
d2020os <- quantile(x=y_2020_Os, probs = c(0.025, 0.5, 0.975))
d2021os <- quantile(x=y_2021_Os, probs = c(0.025, 0.5, 0.975))


#Hyogo
y_2019_Hg <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,7]), sd=ms$sigma))
y_2020_Hg <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,7]), sd=ms$sigma))
y_2021_Hg <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,7]), sd=ms$sigma))

d2019hg <- quantile(x=y_2019_Hg, probs = c(0.025, 0.5, 0.975))
d2020hg <- quantile(x=y_2020_Hg, probs = c(0.025, 0.5, 0.975))
d2021hg <- quantile(x=y_2021_Hg, probs = c(0.025, 0.5, 0.975))

#Nagasaki
y_2019_Ngs <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,8]), sd=ms$sigma))
y_2020_Ngs <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,8]), sd=ms$sigma))
y_2021_Ngs <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,8]), sd=ms$sigma))

d2019ngs <- quantile(x=y_2019_Ngs, probs = c(0.025, 0.5, 0.975))
d2020ngs <- quantile(x=y_2020_Ngs, probs = c(0.025, 0.5, 0.975))
d2021ngs <- quantile(x=y_2021_Ngs, probs = c(0.025, 0.5, 0.975))

#Miyazaki
y_2019_Myz <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,2,9]), sd=ms$sigma))
y_2020_Myz <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,3,9]), sd=ms$sigma))
y_2021_Myz <- exp(rnorm(n=N_mcmc, mean = log(ms$dose_y[,4,9]), sd=ms$sigma))

d2019myz <- quantile(x=y_2019_Myz, probs = c(0.025, 0.5, 0.975))
d2020myz <- quantile(x=y_2020_Myz, probs = c(0.025, 0.5, 0.975))
d2021myz <- quantile(x=y_2021_Myz, probs = c(0.025, 0.5, 0.975))

df <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(d2019[2], d2020[2], d2021[2], d2019hkd[2], d2020hkd[2], d2021hkd[2],  d2019stm[2], d2020stm[2], d2021stm[2], d2019cba[2], d2020cba[2], d2021cba[2], d2019tk[2], d2020tk[2], d2021tk[2], d2019os[2], d2020os[2], d2021os[2], d2019hg[2], d2020hg[2], d2021hg[2], d2019ngs[2], d2020ngs[2], d2021ngs[2], d2019myz[2], d2020myz[2], d2021myz[2]),
  "2.5%" = c(d2019[1], d2020[1], d2021[1], d2019hkd[1], d2020hkd[1], d2021hkd[1], d2019stm[1], d2020stm[1], d2021stm[1], d2019cba[1], d2020cba[1], d2021cba[1], d2019tk[1], d2020tk[1], d2021tk[1],d2019os[1], d2020os[1], d2021os[1], d2019hg[1], d2020hg[1], d2021hg[1], d2019ngs[1], d2020ngs[1], d2021ngs[1], d2019myz[1], d2020myz[1], d2021myz[1]),
  "97.5%" = c(d2019[3], d2020[3], d2021[3], d2019hkd[3], d2020hkd[3], d2021hkd[3], d2019stm[3], d2020stm[3], d2021stm[3], d2019cba[3], d2020cba[3], d2021cba[3],  d2019tk[3], d2020tk[3], d2021tk[3], d2019os[3], d2020os[3], d2021os[3], d2019hg[3], d2020hg[3], d2021hg[3], d2019ngs[3], d2020ngs[3], d2021ngs[3], d2019myz[3], d2020myz[3], d2021myz[3])
)
d <- d %>% left_join(df, by=c("X", "prefecture"))

# Figure 1
d$prefecture <- fct_relevel(d$prefecture, "All", "Hokkaido", "Saitama", "Chiba", "Tokyo", "Osaka", "Hyogo", "Nagasaki", "Miyazaki")
p1<- ggplot()+
  geom_point(data = d, mapping = aes(x=prefecture, y=doses, shape=factor(X)), position=position_dodge(width = 0.9) )+
  scale_shape_manual(values = c("2019" = 1, "2020" = 5, "2021" =0))+
  geom_point(data = d, mapping = aes(x=prefecture, y=`50%`, colour =factor(X)), position=position_dodge(width = 0.9))+
  scale_colour_manual(values = c("2019" = "black", "2020" = "black", "2021" ="black"))+
  geom_linerange(data =  d, mapping=aes(x=prefecture, ymin = `2.5%`, ymax = `97.5%`, colour =factor(X)), position=position_dodge(width = 0.9)) +
  scale_fill_manual(values = c("2019" = "black", "2020" = "black", "2021" ="black"))+
  theme_classic()+
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1))+
  scale_y_continuous(trans = "log10")+
  labs(x= "Prefecture", y = "Doses")+
  guides(colour=FALSE)+
  guides(shape=FALSE)
```

    ## Warning: The `<scale>` argument of `guides()` cannot be `FALSE`. Use "none" instead as
    ## of ggplot2 3.3.4.
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
    ## generated.

``` r
p1
```

    ## Warning: No shared levels found between `names(values)` of the manual scale and the
    ## data's fill values.

![](toxoplasma_files/figure-gfm/plot%20for%20figure1-1.png)<!-- -->

## Figure 2 (cumulative incidence in pregnant women)

``` r
# all
i2019 <- quantile(x=ms$infected_2019[,1], probs = c(0.025, 0.5, 0.975))
i2020 <- quantile(x=ms$infected_2020[,1], probs = c(0.025, 0.5, 0.975))
i2021 <- quantile(x=ms$infected_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
i2019hkd <- quantile(x=ms$infected_2019[,2], probs = c(0.025, 0.5, 0.975))
i2020hkd <- quantile(x=ms$infected_2020[,2], probs = c(0.025, 0.5, 0.975))
i2021hkd <- quantile(x=ms$infected_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
i2019stm <- quantile(x=ms$infected_2019[,3], probs = c(0.025, 0.5, 0.975))
i2020stm <- quantile(x=ms$infected_2020[,3], probs = c(0.025, 0.5, 0.975))
i2021stm <- quantile(x=ms$infected_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
i2019cba <- quantile(x=ms$infected_2019[,4], probs = c(0.025, 0.5, 0.975))
i2020cba <- quantile(x=ms$infected_2020[,4], probs = c(0.025, 0.5, 0.975))
i2021cba <- quantile(x=ms$infected_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
i2019tk <- quantile(x=ms$infected_2019[,5], probs = c(0.025, 0.5, 0.975))
i2020tk <- quantile(x=ms$infected_2020[,5], probs = c(0.025, 0.5, 0.975))
i2021tk <- quantile(x=ms$infected_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
i2019os <- quantile(x=ms$infected_2019[,6], probs = c(0.025, 0.5, 0.975))
i2020os <- quantile(x=ms$infected_2020[,6], probs = c(0.025, 0.5, 0.975))
i2021os <- quantile(x=ms$infected_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
i2019hg <- quantile(x=ms$infected_2019[,7], probs = c(0.025, 0.5, 0.975))
i2020hg <- quantile(x=ms$infected_2020[,7], probs = c(0.025, 0.5, 0.975))
i2021hg <- quantile(x=ms$infected_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
i2019ngs <- quantile(x=ms$infected_2019[,8], probs = c(0.025, 0.5, 0.975))
i2020ngs <- quantile(x=ms$infected_2020[,8], probs = c(0.025, 0.5, 0.975))
i2021ngs <- quantile(x=ms$infected_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
i2019myz <- quantile(x=ms$infected_2019[,9], probs = c(0.025, 0.5, 0.975))
i2020myz <- quantile(x=ms$infected_2020[,9], probs = c(0.025, 0.5, 0.975))
i2021myz <- quantile(x=ms$infected_2021[,9], probs = c(0.025, 0.5, 0.975))

df_infected <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(i2019[2], i2020[2], i2021[2], i2019hkd[2], i2020hkd[2], i2021hkd[2],  i2019stm[2], i2020stm[2], i2021stm[2], i2019cba[2], i2020cba[2], i2021cba[2], i2019tk[2], i2020tk[2], i2021tk[2], i2019os[2], i2020os[2], i2021os[2], i2019hg[2], i2020hg[2], i2021hg[2], i2019ngs[2], i2020ngs[2], i2021ngs[2], i2019myz[2], i2020myz[2], i2021myz[2]),
  "2.5%" = c(i2019[1], i2020[1], i2021[1], i2019hkd[1], i2020hkd[1], i2021hkd[1], i2019stm[1], i2020stm[1], i2021stm[1], i2019cba[1], i2020cba[1], i2021cba[1], i2019tk[1], i2020tk[1], i2021tk[1],i2019os[1], i2020os[1], i2021os[1], i2019hg[1], i2020hg[1], i2021hg[1], i2019ngs[1], i2020ngs[1], i2021ngs[1], i2019myz[1], i2020myz[1], i2021myz[1]),
  "97.5%" = c(i2019[3], i2020[3], i2021[3], i2019hkd[3], i2020hkd[3], i2021hkd[3], i2019stm[3], i2020stm[3], i2021stm[3], i2019cba[3], i2020cba[3], i2021cba[3],  i2019tk[3], i2020tk[3], i2021tk[3], i2019os[3], i2020os[3], i2021os[3], i2019hg[3], i2020hg[3], i2021hg[3], i2019ngs[3], i2020ngs[3], i2021ngs[3], i2019myz[3], i2020myz[3], i2021myz[3])
)

#df for infection per 10000 pregnancies
df_infected_pregnancy <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = 10000*c(i2019[2]/sum(df1$All[19:30]), i2020[2]/sum(df1$All[31:42]), i2021[2]/sum(df1$All[43:54]), i2019hkd[2]/sum(df1$Hokkaido[19:30]), i2020hkd[2]/sum(df1$Hokkaido[31:42]), i2021hkd[2]/sum(df1$Hokkaido[43:54]),  i2019stm[2]/sum(df1$Saitama[19:30]), i2020stm[2]/sum(df1$Saitama[31:42]), i2021stm[2]/sum(df1$Saitama[43:54]), i2019cba[2]/sum(df1$Chiba[19:30]), i2020cba[2]/sum(df1$Chiba[31:42]), i2021cba[2]/sum(df1$Chiba[43:54]), i2019tk[2]/sum(df1$Tokyo[19:30]), i2020tk[2]/sum(df1$Tokyo[31:42]), i2021tk[2]/sum(df1$Tokyo[43:54]), i2019os[2]/sum(df1$Osaka[19:30]), i2020os[2]/sum(df1$Osaka[31:42]), i2021os[2]/sum(df1$Osaka[43:54]), i2019hg[2]/sum(df1$Hyogo[19:30]), i2020hg[2]/sum(df1$Hyogo[31:42]), i2021hg[2]/sum(df1$Hyogo[43:54]), i2019ngs[2]/sum(df1$Nagasaki[19:30]), i2020ngs[2]/sum(df1$Nagasaki[31:42]), i2021ngs[2]/sum(df1$Nagasaki[43:54]), i2019myz[2]/sum(df1$Miyazaki[19:30]), i2020myz[2]/sum(df1$Miyazaki[31:42]), i2021myz[2]/sum(df1$Miyazaki[43:54])),
  "2.5%" = 10000*c(i2019[1]/sum(df1$All[19:30]), i2020[1]/sum(df1$All[31:42]), i2021[1]/sum(df1$All[43:54]), i2019hkd[1]/sum(df1$Hokkaido[19:30]), i2020hkd[1]/sum(df1$Hokkaido[31:42]), i2021hkd[1]/sum(df1$Hokkaido[43:54]), i2019stm[1]/sum(df1$Saitama[19:30]), i2020stm[1]/sum(df1$Saitama[31:42]), i2021stm[1]/sum(df1$Saitama[43:54]), i2019cba[1]/sum(df1$Chiba[19:30]), i2020cba[1]/sum(df1$Chiba[31:42]), i2021cba[1]/sum(df1$Chiba[43:54]), i2019tk[1]/sum(df1$Tokyo[19:30]), i2020tk[1]/sum(df1$Tokyo[31:42]), i2021tk[1]/sum(df1$Tokyo[43:54]),i2019os[1]/sum(df1$Osaka[19:30]), i2020os[1]/sum(df1$Osaka[31:42]), i2021os[1]/sum(df1$Osaka[43:54]), i2019hg[1]/sum(df1$Hyogo[19:30]), i2020hg[1]/sum(df1$Hyogo[31:42]), i2021hg[1]/sum(df1$Hyogo[43:54]), i2019ngs[1]/sum(df1$Nagasaki[19:30]), i2020ngs[1]/sum(df1$Nagasaki[31:42]), i2021ngs[1]/sum(df1$Nagasaki[43:54]), i2019myz[1]/sum(df1$Miyazaki[19:30]), i2020myz[1]/sum(df1$Miyazaki[31:42]), i2021myz[1]/sum(df1$Miyazaki[43:54])),
  "97.5%" = 10000*c(i2019[3]/sum(df1$All[19:30]), i2020[3]/sum(df1$All[31:42]), i2021[3]/sum(df1$All[43:54]), i2019hkd[3]/sum(df1$Hokkaido[19:30]), i2020hkd[3]/sum(df1$Hokkaido[31:42]), i2021hkd[3]/sum(df1$Hokkaido[43:54]), i2019stm[3]/sum(df1$Saitama[19:30]), i2020stm[3]/sum(df1$Saitama[31:42]), i2021stm[3]/sum(df1$Saitama[43:54]), i2019cba[3]/sum(df1$Chiba[19:30]), i2020cba[3]/sum(df1$Chiba[31:42]), i2021cba[3]/sum(df1$Chiba[43:54]),  i2019tk[3]/sum(df1$Tokyo[19:30]), i2020tk[3]/sum(df1$Tokyo[31:42]), i2021tk[3]/sum(df1$Tokyo[43:54]), i2019os[3]/sum(df1$Osaka[19:30]), i2020os[3]/sum(df1$Osaka[31:42]), i2021os[3]/sum(df1$Osaka[43:54]), i2019hg[3]/sum(df1$Hyogo[19:30]), i2020hg[3]/sum(df1$Hyogo[31:42]), i2021hg[3]/sum(df1$Hyogo[43:54]), i2019ngs[3]/sum(df1$Nagasaki[19:30]), i2020ngs[3]/sum(df1$Nagasaki[31:42]), i2021ngs[3]/sum(df1$Nagasaki[43:54]), i2019myz[3]/sum(df1$Miyazaki[19:30]), i2020myz[3]/sum(df1$Miyazaki[31:42]), i2021myz[3]/sum(df1$Miyazaki[43:54]))
)

# Figure 2A
df_infected_pregnancy$prefecture <- fct_relevel(df_infected_pregnancy$prefecture, "All", "Hokkaido", "Saitama", "Chiba", "Tokyo", "Osaka", "Hyogo", "Nagasaki", "Miyazaki")
p2 <- ggplot(data =df_infected_pregnancy, mapping = aes(x=prefecture, y=`50%`, shape=factor(X))) +
  geom_point(position=position_dodge(width = 0.9))+
  geom_linerange(data =  df_infected_pregnancy, mapping=aes(x=prefecture, ymin = `2.5%`, ymax = `97.5%`), position=position_dodge(width = 0.9))+
  theme_classic()+
  labs(x= "Prefecture", y = "New infections per 10000 pregnancies")+
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1))+
  guides(shape=FALSE)
p2
```

![](toxoplasma_files/figure-gfm/plot%20for%20figure%202-1.png)<!-- -->

``` r
# Figure 2B (base plus sensitivity analysis)
# data frame for pessimistic case
# all
ip2019 <- quantile(x=ms2$infected_2019[,1], probs = c(0.025, 0.5, 0.975))
ip2020 <- quantile(x=ms2$infected_2020[,1], probs = c(0.025, 0.5, 0.975))
ip2021 <- quantile(x=ms2$infected_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
ip2019hkd <- quantile(x=ms2$infected_2019[,2], probs = c(0.025, 0.5, 0.975))
ip2020hkd <- quantile(x=ms2$infected_2020[,2], probs = c(0.025, 0.5, 0.975))
ip2021hkd <- quantile(x=ms2$infected_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
ip2019stm <- quantile(x=ms2$infected_2019[,3], probs = c(0.025, 0.5, 0.975))
ip2020stm <- quantile(x=ms2$infected_2020[,3], probs = c(0.025, 0.5, 0.975))
ip2021stm <- quantile(x=ms2$infected_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
ip2019cba <- quantile(x=ms2$infected_2019[,4], probs = c(0.025, 0.5, 0.975))
ip2020cba <- quantile(x=ms2$infected_2020[,4], probs = c(0.025, 0.5, 0.975))
ip2021cba <- quantile(x=ms2$infected_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
ip2019tk <- quantile(x=ms2$infected_2019[,5], probs = c(0.025, 0.5, 0.975))
ip2020tk <- quantile(x=ms2$infected_2020[,5], probs = c(0.025, 0.5, 0.975))
ip2021tk <- quantile(x=ms2$infected_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
ip2019os <- quantile(x=ms2$infected_2019[,6], probs = c(0.025, 0.5, 0.975))
ip2020os <- quantile(x=ms2$infected_2020[,6], probs = c(0.025, 0.5, 0.975))
ip2021os <- quantile(x=ms2$infected_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
ip2019hg <- quantile(x=ms2$infected_2019[,7], probs = c(0.025, 0.5, 0.975))
ip2020hg <- quantile(x=ms2$infected_2020[,7], probs = c(0.025, 0.5, 0.975))
ip2021hg <- quantile(x=ms2$infected_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
ip2019ngs <- quantile(x=ms2$infected_2019[,8], probs = c(0.025, 0.5, 0.975))
ip2020ngs <- quantile(x=ms2$infected_2020[,8], probs = c(0.025, 0.5, 0.975))
ip2021ngs <- quantile(x=ms2$infected_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
ip2019myz <- quantile(x=ms2$infected_2019[,9], probs = c(0.025, 0.5, 0.975))
ip2020myz <- quantile(x=ms2$infected_2020[,9], probs = c(0.025, 0.5, 0.975))
ip2021myz <- quantile(x=ms2$infected_2021[,9], probs = c(0.025, 0.5, 0.975))

df_infected_p <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(ip2019[2], ip2020[2], ip2021[2], ip2019hkd[2], ip2020hkd[2], ip2021hkd[2],  ip2019stm[2], ip2020stm[2], ip2021stm[2], ip2019cba[2], ip2020cba[2], ip2021cba[2], ip2019tk[2], ip2020tk[2], ip2021tk[2], ip2019os[2], ip2020os[2], ip2021os[2], ip2019hg[2], ip2020hg[2], ip2021hg[2], ip2019ngs[2], ip2020ngs[2], ip2021ngs[2], ip2019myz[2], ip2020myz[2], ip2021myz[2]),
  "2.5%" = c(ip2019[1], ip2020[1], ip2021[1], ip2019hkd[1], ip2020hkd[1], ip2021hkd[1], ip2019stm[1], ip2020stm[1], ip2021stm[1], ip2019cba[1], ip2020cba[1], ip2021cba[1], ip2019tk[1], ip2020tk[1], ip2021tk[1],ip2019os[1], ip2020os[1], ip2021os[1], ip2019hg[1], ip2020hg[1], ip2021hg[1], ip2019ngs[1], ip2020ngs[1], ip2021ngs[1], ip2019myz[1], ip2020myz[1], ip2021myz[1]),
  "97.5%" = c(ip2019[3], ip2020[3], ip2021[3], ip2019hkd[3], ip2020hkd[3], ip2021hkd[3], ip2019stm[3], ip2020stm[3], ip2021stm[3], ip2019cba[3], ip2020cba[3], ip2021cba[3],  ip2019tk[3], ip2020tk[3], ip2021tk[3], ip2019os[3], ip2020os[3], ip2021os[3], ip2019hg[3], ip2020hg[3], ip2021hg[3], ip2019ngs[3], ip2020ngs[3], ip2021ngs[3], ip2019myz[3], ip2020myz[3], ip2021myz[3])
)

#df for infection per 10000 pregnancies
df_infected_pregnancy_p <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = 10000*c(ip2019[2]/sum(df1$All[19:30]), ip2020[2]/sum(df1$All[31:42]), ip2021[2]/sum(df1$All[43:54]), ip2019hkd[2]/sum(df1$Hokkaido[19:30]), ip2020hkd[2]/sum(df1$Hokkaido[31:42]), ip2021hkd[2]/sum(df1$Hokkaido[43:54]),  ip2019stm[2]/sum(df1$Saitama[19:30]), ip2020stm[2]/sum(df1$Saitama[31:42]), ip2021stm[2]/sum(df1$Saitama[43:54]), ip2019cba[2]/sum(df1$Chiba[19:30]), ip2020cba[2]/sum(df1$Chiba[31:42]), ip2021cba[2]/sum(df1$Chiba[43:54]), ip2019tk[2]/sum(df1$Tokyo[19:30]), ip2020tk[2]/sum(df1$Tokyo[31:42]), ip2021tk[2]/sum(df1$Tokyo[43:54]), ip2019os[2]/sum(df1$Osaka[19:30]), ip2020os[2]/sum(df1$Osaka[31:42]), ip2021os[2]/sum(df1$Osaka[43:54]), ip2019hg[2]/sum(df1$Hyogo[19:30]), ip2020hg[2]/sum(df1$Hyogo[31:42]), ip2021hg[2]/sum(df1$Hyogo[43:54]), ip2019ngs[2]/sum(df1$Nagasaki[19:30]), ip2020ngs[2]/sum(df1$Nagasaki[31:42]), ip2021ngs[2]/sum(df1$Nagasaki[43:54]), ip2019myz[2]/sum(df1$Miyazaki[19:30]), ip2020myz[2]/sum(df1$Miyazaki[31:42]), ip2021myz[2]/sum(df1$Miyazaki[43:54])),
  "2.5%" = 10000*c(ip2019[1]/sum(df1$All[19:30]), ip2020[1]/sum(df1$All[31:42]), ip2021[1]/sum(df1$All[43:54]), ip2019hkd[1]/sum(df1$Hokkaido[19:30]), ip2020hkd[1]/sum(df1$Hokkaido[31:42]), ip2021hkd[1]/sum(df1$Hokkaido[43:54]), ip2019stm[1]/sum(df1$Saitama[19:30]), ip2020stm[1]/sum(df1$Saitama[31:42]), ip2021stm[1]/sum(df1$Saitama[43:54]), ip2019cba[1]/sum(df1$Chiba[19:30]), ip2020cba[1]/sum(df1$Chiba[31:42]), ip2021cba[1]/sum(df1$Chiba[43:54]), ip2019tk[1]/sum(df1$Tokyo[19:30]), ip2020tk[1]/sum(df1$Tokyo[31:42]), ip2021tk[1]/sum(df1$Tokyo[43:54]),ip2019os[1]/sum(df1$Osaka[19:30]), ip2020os[1]/sum(df1$Osaka[31:42]), ip2021os[1]/sum(df1$Osaka[43:54]), ip2019hg[1]/sum(df1$Hyogo[19:30]), ip2020hg[1]/sum(df1$Hyogo[31:42]), ip2021hg[1]/sum(df1$Hyogo[43:54]), ip2019ngs[1]/sum(df1$Nagasaki[19:30]), ip2020ngs[1]/sum(df1$Nagasaki[31:42]), ip2021ngs[1]/sum(df1$Nagasaki[43:54]), ip2019myz[1]/sum(df1$Miyazaki[19:30]), ip2020myz[1]/sum(df1$Miyazaki[31:42]), ip2021myz[1]/sum(df1$Miyazaki[43:54])),
  "97.5%" = 10000*c(ip2019[3]/sum(df1$All[19:30]), ip2020[3]/sum(df1$All[31:42]), ip2021[3]/sum(df1$All[43:54]), ip2019hkd[3]/sum(df1$Hokkaido[19:30]), ip2020hkd[3]/sum(df1$Hokkaido[31:42]), ip2021hkd[3]/sum(df1$Hokkaido[43:54]), ip2019stm[3]/sum(df1$Saitama[19:30]), ip2020stm[3]/sum(df1$Saitama[31:42]), ip2021stm[3]/sum(df1$Saitama[43:54]), ip2019cba[3]/sum(df1$Chiba[19:30]), ip2020cba[3]/sum(df1$Chiba[31:42]), ip2021cba[3]/sum(df1$Chiba[43:54]),  ip2019tk[3]/sum(df1$Tokyo[19:30]), ip2020tk[3]/sum(df1$Tokyo[31:42]), ip2021tk[3]/sum(df1$Tokyo[43:54]), ip2019os[3]/sum(df1$Osaka[19:30]), ip2020os[3]/sum(df1$Osaka[31:42]), ip2021os[3]/sum(df1$Osaka[43:54]), ip2019hg[3]/sum(df1$Hyogo[19:30]), ip2020hg[3]/sum(df1$Hyogo[31:42]), ip2021hg[3]/sum(df1$Hyogo[43:54]), ip2019ngs[3]/sum(df1$Nagasaki[19:30]), ip2020ngs[3]/sum(df1$Nagasaki[31:42]), ip2021ngs[3]/sum(df1$Nagasaki[43:54]), ip2019myz[3]/sum(df1$Miyazaki[19:30]), ip2020myz[3]/sum(df1$Miyazaki[31:42]), ip2021myz[3]/sum(df1$Miyazaki[43:54]))
)


# data frame for opportunistic case
# all
io2019 <- quantile(x=ms3$infected_2019[,1], probs = c(0.025, 0.5, 0.975))
io2020 <- quantile(x=ms3$infected_2020[,1], probs = c(0.025, 0.5, 0.975))
io2021 <- quantile(x=ms3$infected_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
io2019hkd <- quantile(x=ms3$infected_2019[,2], probs = c(0.025, 0.5, 0.975))
io2020hkd <- quantile(x=ms3$infected_2020[,2], probs = c(0.025, 0.5, 0.975))
io2021hkd <- quantile(x=ms3$infected_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
io2019stm <- quantile(x=ms3$infected_2019[,3], probs = c(0.025, 0.5, 0.975))
io2020stm <- quantile(x=ms3$infected_2020[,3], probs = c(0.025, 0.5, 0.975))
io2021stm <- quantile(x=ms3$infected_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
io2019cba <- quantile(x=ms3$infected_2019[,4], probs = c(0.025, 0.5, 0.975))
io2020cba <- quantile(x=ms3$infected_2020[,4], probs = c(0.025, 0.5, 0.975))
io2021cba <- quantile(x=ms3$infected_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
io2019tk <- quantile(x=ms3$infected_2019[,5], probs = c(0.025, 0.5, 0.975))
io2020tk <- quantile(x=ms3$infected_2020[,5], probs = c(0.025, 0.5, 0.975))
io2021tk <- quantile(x=ms3$infected_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
io2019os <- quantile(x=ms3$infected_2019[,6], probs = c(0.025, 0.5, 0.975))
io2020os <- quantile(x=ms3$infected_2020[,6], probs = c(0.025, 0.5, 0.975))
io2021os <- quantile(x=ms3$infected_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
io2019hg <- quantile(x=ms3$infected_2019[,7], probs = c(0.025, 0.5, 0.975))
io2020hg <- quantile(x=ms3$infected_2020[,7], probs = c(0.025, 0.5, 0.975))
io2021hg <- quantile(x=ms3$infected_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
io2019ngs <- quantile(x=ms3$infected_2019[,8], probs = c(0.025, 0.5, 0.975))
io2020ngs <- quantile(x=ms3$infected_2020[,8], probs = c(0.025, 0.5, 0.975))
io2021ngs <- quantile(x=ms3$infected_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
io2019myz <- quantile(x=ms3$infected_2019[,9], probs = c(0.025, 0.5, 0.975))
io2020myz <- quantile(x=ms3$infected_2020[,9], probs = c(0.025, 0.5, 0.975))
io2021myz <- quantile(x=ms3$infected_2021[,9], probs = c(0.025, 0.5, 0.975))

df_infected_o <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(io2019[2], io2020[2], io2021[2], io2019hkd[2], io2020hkd[2], io2021hkd[2],  io2019stm[2], io2020stm[2], io2021stm[2], io2019cba[2], io2020cba[2], io2021cba[2], io2019tk[2], io2020tk[2], io2021tk[2], io2019os[2], io2020os[2], io2021os[2], io2019hg[2], io2020hg[2], io2021hg[2], io2019ngs[2], io2020ngs[2], io2021ngs[2], io2019myz[2], io2020myz[2], io2021myz[2]),
  "2.5%" = c(io2019[1], io2020[1], io2021[1], io2019hkd[1], io2020hkd[1], io2021hkd[1], io2019stm[1], io2020stm[1], io2021stm[1], io2019cba[1], io2020cba[1], io2021cba[1], io2019tk[1], io2020tk[1], io2021tk[1],io2019os[1], io2020os[1], io2021os[1], io2019hg[1], io2020hg[1], io2021hg[1], io2019ngs[1], io2020ngs[1], io2021ngs[1], io2019myz[1], io2020myz[1], io2021myz[1]),
  "97.5%" = c(io2019[3], io2020[3], io2021[3], io2019hkd[3], io2020hkd[3], io2021hkd[3], io2019stm[3], io2020stm[3], io2021stm[3], io2019cba[3], io2020cba[3], io2021cba[3],  io2019tk[3], io2020tk[3], io2021tk[3], io2019os[3], io2020os[3], io2021os[3], io2019hg[3], io2020hg[3], io2021hg[3], io2019ngs[3], io2020ngs[3], io2021ngs[3], io2019myz[3], io2020myz[3], io2021myz[3])
)

#df for infection per 10000 pregnancies (optimistic)
df_infected_pregnancy_o <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = 10000*c(io2019[2]/sum(df1$All[19:30]), io2020[2]/sum(df1$All[31:42]), io2021[2]/sum(df1$All[43:54]), io2019hkd[2]/sum(df1$Hokkaido[19:30]), io2020hkd[2]/sum(df1$Hokkaido[31:42]), io2021hkd[2]/sum(df1$Hokkaido[43:54]),  io2019stm[2]/sum(df1$Saitama[19:30]), io2020stm[2]/sum(df1$Saitama[31:42]), io2021stm[2]/sum(df1$Saitama[43:54]), io2019cba[2]/sum(df1$Chiba[19:30]), io2020cba[2]/sum(df1$Chiba[31:42]), io2021cba[2]/sum(df1$Chiba[43:54]), io2019tk[2]/sum(df1$Tokyo[19:30]), io2020tk[2]/sum(df1$Tokyo[31:42]), io2021tk[2]/sum(df1$Tokyo[43:54]), io2019os[2]/sum(df1$Osaka[19:30]), io2020os[2]/sum(df1$Osaka[31:42]), io2021os[2]/sum(df1$Osaka[43:54]), io2019hg[2]/sum(df1$Hyogo[19:30]), io2020hg[2]/sum(df1$Hyogo[31:42]), io2021hg[2]/sum(df1$Hyogo[43:54]), io2019ngs[2]/sum(df1$Nagasaki[19:30]), io2020ngs[2]/sum(df1$Nagasaki[31:42]), io2021ngs[2]/sum(df1$Nagasaki[43:54]), io2019myz[2]/sum(df1$Miyazaki[19:30]), io2020myz[2]/sum(df1$Miyazaki[31:42]), io2021myz[2]/sum(df1$Miyazaki[43:54])),
  "2.5%" = 10000*c(io2019[1]/sum(df1$All[19:30]), io2020[1]/sum(df1$All[31:42]), io2021[1]/sum(df1$All[43:54]), io2019hkd[1]/sum(df1$Hokkaido[19:30]), io2020hkd[1]/sum(df1$Hokkaido[31:42]), io2021hkd[1]/sum(df1$Hokkaido[43:54]), io2019stm[1]/sum(df1$Saitama[19:30]), io2020stm[1]/sum(df1$Saitama[31:42]), io2021stm[1]/sum(df1$Saitama[43:54]), io2019cba[1]/sum(df1$Chiba[19:30]), io2020cba[1]/sum(df1$Chiba[31:42]), io2021cba[1]/sum(df1$Chiba[43:54]), io2019tk[1]/sum(df1$Tokyo[19:30]), io2020tk[1]/sum(df1$Tokyo[31:42]), io2021tk[1]/sum(df1$Tokyo[43:54]),io2019os[1]/sum(df1$Osaka[19:30]), io2020os[1]/sum(df1$Osaka[31:42]), io2021os[1]/sum(df1$Osaka[43:54]), io2019hg[1]/sum(df1$Hyogo[19:30]), io2020hg[1]/sum(df1$Hyogo[31:42]), io2021hg[1]/sum(df1$Hyogo[43:54]), io2019ngs[1]/sum(df1$Nagasaki[19:30]), io2020ngs[1]/sum(df1$Nagasaki[31:42]), io2021ngs[1]/sum(df1$Nagasaki[43:54]), io2019myz[1]/sum(df1$Miyazaki[19:30]), io2020myz[1]/sum(df1$Miyazaki[31:42]), io2021myz[1]/sum(df1$Miyazaki[43:54])),
  "97.5%" = 10000*c(io2019[3]/sum(df1$All[19:30]), io2020[3]/sum(df1$All[31:42]), io2021[3]/sum(df1$All[43:54]), io2019hkd[3]/sum(df1$Hokkaido[19:30]), io2020hkd[3]/sum(df1$Hokkaido[31:42]), io2021hkd[3]/sum(df1$Hokkaido[43:54]), io2019stm[3]/sum(df1$Saitama[19:30]), io2020stm[3]/sum(df1$Saitama[31:42]), io2021stm[3]/sum(df1$Saitama[43:54]), io2019cba[3]/sum(df1$Chiba[19:30]), io2020cba[3]/sum(df1$Chiba[31:42]), io2021cba[3]/sum(df1$Chiba[43:54]),  io2019tk[3]/sum(df1$Tokyo[19:30]), io2020tk[3]/sum(df1$Tokyo[31:42]), io2021tk[3]/sum(df1$Tokyo[43:54]), io2019os[3]/sum(df1$Osaka[19:30]), io2020os[3]/sum(df1$Osaka[31:42]), io2021os[3]/sum(df1$Osaka[43:54]), io2019hg[3]/sum(df1$Hyogo[19:30]), io2020hg[3]/sum(df1$Hyogo[31:42]), io2021hg[3]/sum(df1$Hyogo[43:54]), io2019ngs[3]/sum(df1$Nagasaki[19:30]), io2020ngs[3]/sum(df1$Nagasaki[31:42]), io2021ngs[3]/sum(df1$Nagasaki[43:54]), io2019myz[3]/sum(df1$Miyazaki[19:30]), io2020myz[3]/sum(df1$Miyazaki[31:42]), io2021myz[3]/sum(df1$Miyazaki[43:54]))
)

# DF for Figure 2B
df_infected_s <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "Base" = c(i2019[2], i2020[2], i2021[2], i2019hkd[2], i2020hkd[2], i2021hkd[2],  i2019stm[2], i2020stm[2], i2021stm[2], i2019cba[2], i2020cba[2], i2021cba[2], i2019tk[2], i2020tk[2], i2021tk[2], i2019os[2], i2020os[2], i2021os[2], i2019hg[2], i2020hg[2], i2021hg[2], i2019ngs[2], i2020ngs[2], i2021ngs[2], i2019myz[2], i2020myz[2], i2021myz[2]),
   "Pessimistic" = c(ip2019[2], ip2020[2], ip2021[2], ip2019hkd[2], ip2020hkd[2], ip2021hkd[2],  ip2019stm[2], ip2020stm[2], ip2021stm[2], ip2019cba[2], ip2020cba[2], ip2021cba[2], ip2019tk[2], ip2020tk[2], ip2021tk[2], ip2019os[2], ip2020os[2], ip2021os[2], ip2019hg[2], ip2020hg[2], ip2021hg[2], ip2019ngs[2], ip2020ngs[2], ip2021ngs[2], ip2019myz[2], ip2020myz[2], ip2021myz[2]),
  "Opportunistic" = c(io2019[2], io2020[2], io2021[2], io2019hkd[2], io2020hkd[2], io2021hkd[2],  io2019stm[2], io2020stm[2], io2021stm[2], io2019cba[2], io2020cba[2], io2021cba[2], io2019tk[2], io2020tk[2], io2021tk[2], io2019os[2], io2020os[2], io2021os[2], io2019hg[2], io2020hg[2], io2021hg[2], io2019ngs[2], io2020ngs[2], io2021ngs[2], io2019myz[2], io2020myz[2], io2021myz[2])
)

#df for infection per 10000 pregnancies
df_infected_pregnancy_s <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "Base" = 10000*c(i2019[2]/sum(df1$All[19:30]), i2020[2]/sum(df1$All[31:42]), i2021[2]/sum(df1$All[43:54]), i2019hkd[2]/sum(df1$Hokkaido[19:30]), i2020hkd[2]/sum(df1$Hokkaido[31:42]), i2021hkd[2]/sum(df1$Hokkaido[43:54]),  i2019stm[2]/sum(df1$Saitama[19:30]), i2020stm[2]/sum(df1$Saitama[31:42]), i2021stm[2]/sum(df1$Saitama[43:54]), i2019cba[2]/sum(df1$Chiba[19:30]), i2020cba[2]/sum(df1$Chiba[31:42]), i2021cba[2]/sum(df1$Chiba[43:54]), i2019tk[2]/sum(df1$Tokyo[19:30]), i2020tk[2]/sum(df1$Tokyo[31:42]), i2021tk[2]/sum(df1$Tokyo[43:54]), i2019os[2]/sum(df1$Osaka[19:30]), i2020os[2]/sum(df1$Osaka[31:42]), i2021os[2]/sum(df1$Osaka[43:54]), i2019hg[2]/sum(df1$Hyogo[19:30]), i2020hg[2]/sum(df1$Hyogo[31:42]), i2021hg[2]/sum(df1$Hyogo[43:54]), i2019ngs[2]/sum(df1$Nagasaki[19:30]), i2020ngs[2]/sum(df1$Nagasaki[31:42]), i2021ngs[2]/sum(df1$Nagasaki[43:54]), i2019myz[2]/sum(df1$Miyazaki[19:30]), i2020myz[2]/sum(df1$Miyazaki[31:42]), i2021myz[2]/sum(df1$Miyazaki[43:54])),
  "Pessimistic" = 10000*c(ip2019[2]/sum(df1$All[19:30]), ip2020[2]/sum(df1$All[31:42]), ip2021[2]/sum(df1$All[43:54]), ip2019hkd[2]/sum(df1$Hokkaido[19:30]), ip2020hkd[2]/sum(df1$Hokkaido[31:42]), ip2021hkd[2]/sum(df1$Hokkaido[43:54]), ip2019stm[2]/sum(df1$Saitama[19:30]), ip2020stm[2]/sum(df1$Saitama[31:42]), ip2021stm[2]/sum(df1$Saitama[43:54]), ip2019cba[2]/sum(df1$Chiba[19:30]), ip2020cba[2]/sum(df1$Chiba[31:42]), ip2021cba[2]/sum(df1$Chiba[43:54]), ip2019tk[2]/sum(df1$Tokyo[19:30]), ip2020tk[2]/sum(df1$Tokyo[31:42]), ip2021tk[2]/sum(df1$Tokyo[43:54]),ip2019os[2]/sum(df1$Osaka[19:30]), ip2020os[2]/sum(df1$Osaka[31:42]), ip2021os[2]/sum(df1$Osaka[43:54]), ip2019hg[2]/sum(df1$Hyogo[19:30]), ip2020hg[2]/sum(df1$Hyogo[31:42]), ip2021hg[2]/sum(df1$Hyogo[43:54]), ip2019ngs[2]/sum(df1$Nagasaki[19:30]), ip2020ngs[2]/sum(df1$Nagasaki[31:42]), ip2021ngs[2]/sum(df1$Nagasaki[43:54]), ip2019myz[2]/sum(df1$Miyazaki[19:30]), ip2020myz[2]/sum(df1$Miyazaki[31:42]), ip2021myz[2]/sum(df1$Miyazaki[43:54])),
  "Opportunistic" = 10000*c(io2019[2]/sum(df1$All[19:30]), io2020[2]/sum(df1$All[31:42]), io2021[2]/sum(df1$All[43:54]), io2019hkd[2]/sum(df1$Hokkaido[19:30]), io2020hkd[2]/sum(df1$Hokkaido[31:42]), io2021hkd[2]/sum(df1$Hokkaido[43:54]), io2019stm[2]/sum(df1$Saitama[19:30]), io2020stm[2]/sum(df1$Saitama[31:42]), io2021stm[2]/sum(df1$Saitama[43:54]), io2019cba[2]/sum(df1$Chiba[19:30]), io2020cba[2]/sum(df1$Chiba[31:42]), io2021cba[2]/sum(df1$Chiba[43:54]),  io2019tk[2]/sum(df1$Tokyo[19:30]), io2020tk[2]/sum(df1$Tokyo[31:42]), io2021tk[2]/sum(df1$Tokyo[43:54]), io2019os[2]/sum(df1$Osaka[19:30]), io2020os[2]/sum(df1$Osaka[31:42]), io2021os[2]/sum(df1$Osaka[43:54]), io2019hg[2]/sum(df1$Hyogo[19:30]), io2020hg[2]/sum(df1$Hyogo[31:42]), io2021hg[2]/sum(df1$Hyogo[43:54]), io2019ngs[2]/sum(df1$Nagasaki[19:30]), io2020ngs[2]/sum(df1$Nagasaki[31:42]), io2021ngs[2]/sum(df1$Nagasaki[43:54]), io2019myz[2]/sum(df1$Miyazaki[19:30]), io2020myz[2]/sum(df1$Miyazaki[31:42]), io2021myz[2]/sum(df1$Miyazaki[43:54]))
)

# Figure 2B
df_infected_pregnancy_s$prefecture <- fct_relevel(df_infected_pregnancy_s$prefecture, "All", "Hokkaido", "Saitama", "Chiba", "Tokyo", "Osaka", "Hyogo", "Nagasaki", "Miyazaki")
p3 <- ggplot(data =df_infected_pregnancy_s, mapping = aes(x=prefecture, y=`Base`, shape=factor(X))) +
  geom_point(position=position_dodge(width = 0.9))+
  geom_point(data =  df_infected_pregnancy_s, mapping=aes(x=prefecture, y = `Pessimistic`), position=position_dodge(width = 0.9))+
  geom_point(data =  df_infected_pregnancy_s, mapping=aes(x=prefecture, y = `Opportunistic`), position=position_dodge(width = 0.9))+
  theme_classic()+
  labs(x= "Prefecture", y = "New infections per 10000 pregnancies")+
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1))+
  guides(shape=FALSE)

p3
```

![](toxoplasma_files/figure-gfm/plot%20for%20figure%202-2.png)<!-- -->

``` r
library(patchwork)
p2+p3
```

![](toxoplasma_files/figure-gfm/plot%20for%20figure%202-3.png)<!-- -->

## Treated proportion

``` r
## df for treated proportion (Base)
# all
t2019 <- quantile(x=ms$treated_2019[,1], probs = c(0.025, 0.5, 0.975))
t2020 <- quantile(x=ms$treated_2020[,1], probs = c(0.025, 0.5, 0.975))
t2021 <- quantile(x=ms$treated_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
t2019hkd <- quantile(x=ms$treated_2019[,2], probs = c(0.025, 0.5, 0.975))
t2020hkd <- quantile(x=ms$treated_2020[,2], probs = c(0.025, 0.5, 0.975))
t2021hkd <- quantile(x=ms$treated_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
t2019stm <- quantile(x=ms$treated_2019[,3], probs = c(0.025, 0.5, 0.975))
t2020stm <- quantile(x=ms$treated_2020[,3], probs = c(0.025, 0.5, 0.975))
t2021stm <- quantile(x=ms$treated_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
t2019cba <- quantile(x=ms$treated_2019[,4], probs = c(0.025, 0.5, 0.975))
t2020cba <- quantile(x=ms$treated_2020[,4], probs = c(0.025, 0.5, 0.975))
t2021cba <- quantile(x=ms$treated_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
t2019tk <- quantile(x=ms$treated_2019[,5], probs = c(0.025, 0.5, 0.975))
t2020tk <- quantile(x=ms$treated_2020[,5], probs = c(0.025, 0.5, 0.975))
t2021tk <- quantile(x=ms$treated_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
t2019os <- quantile(x=ms$treated_2019[,6], probs = c(0.025, 0.5, 0.975))
t2020os <- quantile(x=ms$treated_2020[,6], probs = c(0.025, 0.5, 0.975))
t2021os <- quantile(x=ms$treated_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
t2019hg <- quantile(x=ms$treated_2019[,7], probs = c(0.025, 0.5, 0.975))
t2020hg <- quantile(x=ms$treated_2020[,7], probs = c(0.025, 0.5, 0.975))
t2021hg <- quantile(x=ms$treated_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
t2019ngs <- quantile(x=ms$treated_2019[,8], probs = c(0.025, 0.5, 0.975))
t2020ngs <- quantile(x=ms$treated_2020[,8], probs = c(0.025, 0.5, 0.975))
t2021ngs <- quantile(x=ms$treated_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
t2019myz <- quantile(x=ms$treated_2019[,9], probs = c(0.025, 0.5, 0.975))
t2020myz <- quantile(x=ms$treated_2020[,9], probs = c(0.025, 0.5, 0.975))
t2021myz <- quantile(x=ms$treated_2021[,9], probs = c(0.025, 0.5, 0.975))

df_treated <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3),rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(t2019[2], t2020[2], t2021[2], t2019hkd[2], t2020hkd[2], t2021hkd[2],  t2019stm[2], t2020stm[2], t2021stm[2], t2019cba[2], t2020cba[2], t2021cba[2], t2019tk[2], t2020tk[2], t2021tk[2], t2019os[2], t2020os[2], t2021os[2], t2019hg[2], t2020hg[2], t2021hg[2], t2019ngs[2], t2020ngs[2], t2021ngs[2], t2019myz[2], t2020myz[2], t2021myz[2]),
  "2.5%" = c(t2019[1], t2020[1], t2021[1], t2019hkd[1], t2020hkd[1], t2021hkd[1], t2019stm[1], t2020stm[1], t2021stm[1], t2019cba[1], t2020cba[1], t2021cba[1], t2019tk[1], t2020tk[1], t2021tk[1],t2019os[1], t2020os[1], t2021os[1], t2019hg[1], t2020hg[1], t2021hg[1], t2019ngs[1], t2020ngs[1], t2021ngs[1], t2019myz[1], t2020myz[1], t2021myz[1]),
  "97.5%" = c(t2019[3], t2020[3], t2021[3], t2019hkd[3], t2020hkd[3], t2021hkd[3], t2019stm[3], t2020stm[3], t2021stm[3], t2019cba[3], t2020cba[3], t2021cba[3],  t2019tk[3], t2020tk[3], t2021tk[3], t2019os[3], t2020os[3], t2021os[3], t2019hg[3], t2020hg[3], t2021hg[3], t2019ngs[3], t2020ngs[3], t2021ngs[3], t2019myz[3], t2020myz[3], t2021myz[3]),
)

## df for treated proportion (Pessimistic)
# all
tp2019 <- quantile(x=ms2$treated_2019[,1], probs = c(0.025, 0.5, 0.975))
tp2020 <- quantile(x=ms2$treated_2020[,1], probs = c(0.025, 0.5, 0.975))
tp2021 <- quantile(x=ms2$treated_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
tp2019hkd <- quantile(x=ms2$treated_2019[,2], probs = c(0.025, 0.5, 0.975))
tp2020hkd <- quantile(x=ms2$treated_2020[,2], probs = c(0.025, 0.5, 0.975))
tp2021hkd <- quantile(x=ms2$treated_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
tp2019stm <- quantile(x=ms2$treated_2019[,3], probs = c(0.025, 0.5, 0.975))
tp2020stm <- quantile(x=ms2$treated_2020[,3], probs = c(0.025, 0.5, 0.975))
tp2021stm <- quantile(x=ms2$treated_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
tp2019cba <- quantile(x=ms2$treated_2019[,4], probs = c(0.025, 0.5, 0.975))
tp2020cba <- quantile(x=ms2$treated_2020[,4], probs = c(0.025, 0.5, 0.975))
tp2021cba <- quantile(x=ms2$treated_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
tp2019tk <- quantile(x=ms2$treated_2019[,5], probs = c(0.025, 0.5, 0.975))
tp2020tk <- quantile(x=ms2$treated_2020[,5], probs = c(0.025, 0.5, 0.975))
tp2021tk <- quantile(x=ms2$treated_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
tp2019os <- quantile(x=ms2$treated_2019[,6], probs = c(0.025, 0.5, 0.975))
tp2020os <- quantile(x=ms2$treated_2020[,6], probs = c(0.025, 0.5, 0.975))
tp2021os <- quantile(x=ms2$treated_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
tp2019hg <- quantile(x=ms2$treated_2019[,7], probs = c(0.025, 0.5, 0.975))
tp2020hg <- quantile(x=ms2$treated_2020[,7], probs = c(0.025, 0.5, 0.975))
tp2021hg <- quantile(x=ms2$treated_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
tp2019ngs <- quantile(x=ms2$treated_2019[,8], probs = c(0.025, 0.5, 0.975))
tp2020ngs <- quantile(x=ms2$treated_2020[,8], probs = c(0.025, 0.5, 0.975))
tp2021ngs <- quantile(x=ms2$treated_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
tp2019myz <- quantile(x=ms2$treated_2019[,9], probs = c(0.025, 0.5, 0.975))
tp2020myz <- quantile(x=ms2$treated_2020[,9], probs = c(0.025, 0.5, 0.975))
tp2021myz <- quantile(x=ms2$treated_2021[,9], probs = c(0.025, 0.5, 0.975))

## df for treated proportion (Opportunistic)
# all
to2019 <- quantile(x=ms3$treated_2019[,1], probs = c(0.025, 0.5, 0.975))
to2020 <- quantile(x=ms3$treated_2020[,1], probs = c(0.025, 0.5, 0.975))
to2021 <- quantile(x=ms3$treated_2021[,1], probs = c(0.025, 0.5, 0.975))
```

## Figure 3 (cumulative CT)

``` r
# df for vertical
# all
v2019 <- quantile(x=ms$vertical_2019[,1], probs = c(0.025, 0.5, 0.975))
v2020 <- quantile(x=ms$vertical_2020[,1], probs = c(0.025, 0.5, 0.975))
v2021 <- quantile(x=ms$vertical_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
v2019hkd <- quantile(x=ms$vertical_2019[,2], probs = c(0.025, 0.5, 0.975))
v2020hkd <- quantile(x=ms$vertical_2020[,2], probs = c(0.025, 0.5, 0.975))
v2021hkd <- quantile(x=ms$vertical_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
v2019stm <- quantile(x=ms$vertical_2019[,3], probs = c(0.025, 0.5, 0.975))
v2020stm <- quantile(x=ms$vertical_2020[,3], probs = c(0.025, 0.5, 0.975))
v2021stm <- quantile(x=ms$vertical_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
v2019cba <- quantile(x=ms$vertical_2019[,4], probs = c(0.025, 0.5, 0.975))
v2020cba <- quantile(x=ms$vertical_2020[,4], probs = c(0.025, 0.5, 0.975))
v2021cba <- quantile(x=ms$vertical_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
v2019tk <- quantile(x=ms$vertical_2019[,5], probs = c(0.025, 0.5, 0.975))
v2020tk <- quantile(x=ms$vertical_2020[,5], probs = c(0.025, 0.5, 0.975))
v2021tk <- quantile(x=ms$vertical_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
v2019os <- quantile(x=ms$vertical_2019[,6], probs = c(0.025, 0.5, 0.975))
v2020os <- quantile(x=ms$vertical_2020[,6], probs = c(0.025, 0.5, 0.975))
v2021os <- quantile(x=ms$vertical_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
v2019hg <- quantile(x=ms$vertical_2019[,7], probs = c(0.025, 0.5, 0.975))
v2020hg <- quantile(x=ms$vertical_2020[,7], probs = c(0.025, 0.5, 0.975))
v2021hg <- quantile(x=ms$vertical_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
v2019ngs <- quantile(x=ms$vertical_2019[,8], probs = c(0.025, 0.5, 0.975))
v2020ngs <- quantile(x=ms$vertical_2020[,8], probs = c(0.025, 0.5, 0.975))
v2021ngs <- quantile(x=ms$vertical_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
v2019myz <- quantile(x=ms$vertical_2019[,9], probs = c(0.025, 0.5, 0.975))
v2020myz <- quantile(x=ms$vertical_2020[,9], probs = c(0.025, 0.5, 0.975))
v2021myz <- quantile(x=ms$vertical_2021[,9], probs = c(0.025, 0.5, 0.975))

df_vertical <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(v2019[2], v2020[2], v2021[2], v2019hkd[2], v2020hkd[2], v2021hkd[2],  v2019stm[2], v2020stm[2], v2021stm[2], v2019cba[2], v2020cba[2], v2021cba[2], v2019tk[2], v2020tk[2], v2021tk[2], v2019os[2], v2020os[2], v2021os[2], v2019hg[2], v2020hg[2], v2021hg[2], v2019ngs[2], v2020ngs[2], v2021ngs[2], v2019myz[2], v2020myz[2], v2021myz[2]),
  "2.5%" = c(v2019[1], v2020[1], v2021[1], v2019hkd[1], v2020hkd[1], v2021hkd[1], v2019stm[1], v2020stm[1], v2021stm[1], v2019cba[1], v2020cba[1], v2021cba[1], v2019tk[1], v2020tk[1], v2021tk[1],v2019os[1], v2020os[1], v2021os[1], v2019hg[1], v2020hg[1], v2021hg[1], v2019ngs[1], v2020ngs[1], v2021ngs[1], v2019myz[1], v2020myz[1], v2021myz[1]),
  "97.5%" = c(v2019[3], v2020[3], v2021[3], v2019hkd[3], v2020hkd[3], v2021hkd[3], v2019stm[3], v2020stm[3], v2021stm[3], v2019cba[3], v2020cba[3], v2021cba[3],  v2019tk[3], v2020tk[3], v2021tk[3], v2019os[3], v2020os[3], v2021os[3], v2019hg[3], v2020hg[3], v2021hg[3], v2019ngs[3], v2020ngs[3], v2021ngs[3], v2019myz[3], v2020myz[3], v2021myz[3])
)

# df for vertical transmission per 10000 pregnancies
df_vertical_pregnancy <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = 10000*c(v2019[2]/sum(df1$All[19:30]), v2020[2]/sum(df1$All[31:42]), v2021[2]/sum(df1$All[43:54]), v2019hkd[2]/sum(df1$Hokkaido[19:30]), v2020hkd[2]/sum(df1$Hokkaido[31:42]), v2021hkd[2]/sum(df1$Hokkaido[43:54]),  v2019stm[2]/sum(df1$Saitama[19:30]), v2020stm[2]/sum(df1$Saitama[31:42]), v2021stm[2]/sum(df1$Saitama[43:54]), v2019cba[2]/sum(df1$Chiba[19:30]), v2020cba[2]/sum(df1$Chiba[31:42]), v2021cba[2]/sum(df1$Chiba[43:54]), v2019tk[2]/sum(df1$Tokyo[19:30]), v2020tk[2]/sum(df1$Tokyo[31:42]), v2021tk[2]/sum(df1$Tokyo[43:54]), v2019os[2]/sum(df1$Osaka[19:30]), v2020os[2]/sum(df1$Osaka[31:42]), v2021os[2]/sum(df1$Osaka[43:54]), v2019hg[2]/sum(df1$Hyogo[19:30]), v2020hg[2]/sum(df1$Hyogo[31:42]), v2021hg[2]/sum(df1$Hyogo[43:54]), v2019ngs[2]/sum(df1$Nagasaki[19:30]), v2020ngs[2]/sum(df1$Nagasaki[31:42]), v2021ngs[2]/sum(df1$Nagasaki[43:54]), v2019myz[2]/sum(df1$Miyazaki[19:30]), v2020myz[2]/sum(df1$Miyazaki[31:42]), v2021myz[2]/sum(df1$Miyazaki[43:54])),
  "2.5%" = 10000*c(v2019[1]/sum(df1$All[19:30]), v2020[1]/sum(df1$All[31:42]), v2021[1]/sum(df1$All[43:54]), v2019hkd[1]/sum(df1$Hokkaido[19:30]), v2020hkd[1]/sum(df1$Hokkaido[31:42]), v2021hkd[1]/sum(df1$Hokkaido[43:54]), v2019stm[1]/sum(df1$Saitama[19:30]), v2020stm[1]/sum(df1$Saitama[31:42]), v2021stm[1]/sum(df1$Saitama[43:54]), v2019cba[1]/sum(df1$Chiba[19:30]), v2020cba[1]/sum(df1$Chiba[31:42]), v2021cba[1]/sum(df1$Chiba[43:54]), v2019tk[1]/sum(df1$Tokyo[19:30]), v2020tk[1]/sum(df1$Tokyo[31:42]), v2021tk[1]/sum(df1$Tokyo[43:54]),v2019os[1]/sum(df1$Osaka[19:30]), v2020os[1]/sum(df1$Osaka[31:42]), v2021os[1]/sum(df1$Osaka[43:54]), v2019hg[1]/sum(df1$Hyogo[19:30]), v2020hg[1]/sum(df1$Hyogo[31:42]), v2021hg[1]/sum(df1$Hyogo[43:54]), v2019ngs[1]/sum(df1$Nagasaki[19:30]), v2020ngs[1]/sum(df1$Nagasaki[31:42]), v2021ngs[1]/sum(df1$Nagasaki[43:54]), v2019myz[1]/sum(df1$Miyazaki[19:30]), v2020myz[1]/sum(df1$Miyazaki[31:42]), v2021myz[1]/sum(df1$Miyazaki[43:54])),
  "97.5%" = 10000*c(v2019[3]/sum(df1$All[19:30]), v2020[3]/sum(df1$All[31:42]), v2021[3]/sum(df1$All[43:54]), v2019hkd[3]/sum(df1$Hokkaido[19:30]), v2020hkd[3]/sum(df1$Hokkaido[31:42]), v2021hkd[3]/sum(df1$Hokkaido[43:54]), v2019stm[3]/sum(df1$Saitama[19:30]), v2020stm[3]/sum(df1$Saitama[31:42]), v2021stm[3]/sum(df1$Saitama[43:54]), v2019cba[3]/sum(df1$Chiba[19:30]), v2020cba[3]/sum(df1$Chiba[31:42]), v2021cba[3]/sum(df1$Chiba[43:54]),  v2019tk[3]/sum(df1$Tokyo[19:30]), v2020tk[3]/sum(df1$Tokyo[31:42]), v2021tk[3]/sum(df1$Tokyo[43:54]), v2019os[3]/sum(df1$Osaka[19:30]), v2020os[3]/sum(df1$Osaka[31:42]), v2021os[3]/sum(df1$Osaka[43:54]), v2019hg[3]/sum(df1$Hyogo[19:30]), v2020hg[3]/sum(df1$Hyogo[31:42]), v2021hg[3]/sum(df1$Hyogo[43:54]), v2019ngs[3]/sum(df1$Nagasaki[19:30]), v2020ngs[3]/sum(df1$Nagasaki[31:42]), v2021ngs[3]/sum(df1$Nagasaki[43:54]), v2019myz[3]/sum(df1$Miyazaki[19:30]), v2020myz[3]/sum(df1$Miyazaki[31:42]), v2021myz[3]/sum(df1$Miyazaki[43:54]))
)

# Figure 3A
df_vertical_pregnancy$prefecture <- fct_relevel(df_vertical_pregnancy$prefecture, "All", "Hokkaido", "Saitama", "Chiba", "Tokyo", "Osaka", "Hyogo", "Nagasaki", "Miyazaki")
p4 <- ggplot(data =df_vertical_pregnancy, mapping = aes(x=prefecture, y=`50%`, shape=factor(X))) +
  geom_point(position=position_dodge(width = 0.9))+
  geom_linerange(data =  df_vertical_pregnancy, mapping=aes(x=prefecture, ymin = `2.5%`, ymax = `97.5%`), position=position_dodge(width = 0.9))+
  theme_classic()+
  labs(x= "Prefecture", y = "New CT per 10000 pregnancies")+
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1))+
  guides(shape=FALSE)
p4
```

![](toxoplasma_files/figure-gfm/plot%20for%20figure%203-1.png)<!-- -->

``` r
# df for vertical (pessimistic case)
# all
vp2019 <- quantile(x=ms2$vertical_2019[,1], probs = c(0.025, 0.5, 0.975))
vp2020 <- quantile(x=ms2$vertical_2020[,1], probs = c(0.025, 0.5, 0.975))
vp2021 <- quantile(x=ms2$vertical_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
vp2019hkd <- quantile(x=ms2$vertical_2019[,2], probs = c(0.025, 0.5, 0.975))
vp2020hkd <- quantile(x=ms2$vertical_2020[,2], probs = c(0.025, 0.5, 0.975))
vp2021hkd <- quantile(x=ms2$vertical_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
vp2019stm <- quantile(x=ms2$vertical_2019[,3], probs = c(0.025, 0.5, 0.975))
vp2020stm <- quantile(x=ms2$vertical_2020[,3], probs = c(0.025, 0.5, 0.975))
vp2021stm <- quantile(x=ms2$vertical_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
vp2019cba <- quantile(x=ms2$vertical_2019[,4], probs = c(0.025, 0.5, 0.975))
vp2020cba <- quantile(x=ms2$vertical_2020[,4], probs = c(0.025, 0.5, 0.975))
vp2021cba <- quantile(x=ms2$vertical_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
vp2019tk <- quantile(x=ms2$vertical_2019[,5], probs = c(0.025, 0.5, 0.975))
vp2020tk <- quantile(x=ms2$vertical_2020[,5], probs = c(0.025, 0.5, 0.975))
vp2021tk <- quantile(x=ms2$vertical_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
vp2019os <- quantile(x=ms2$vertical_2019[,6], probs = c(0.025, 0.5, 0.975))
vp2020os <- quantile(x=ms2$vertical_2020[,6], probs = c(0.025, 0.5, 0.975))
vp2021os <- quantile(x=ms2$vertical_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
vp2019hg <- quantile(x=ms2$vertical_2019[,7], probs = c(0.025, 0.5, 0.975))
vp2020hg <- quantile(x=ms2$vertical_2020[,7], probs = c(0.025, 0.5, 0.975))
vp2021hg <- quantile(x=ms2$vertical_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
vp2019ngs <- quantile(x=ms2$vertical_2019[,8], probs = c(0.025, 0.5, 0.975))
vp2020ngs <- quantile(x=ms2$vertical_2020[,8], probs = c(0.025, 0.5, 0.975))
vp2021ngs <- quantile(x=ms2$vertical_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
vp2019myz <- quantile(x=ms2$vertical_2019[,9], probs = c(0.025, 0.5, 0.975))
vp2020myz <- quantile(x=ms2$vertical_2020[,9], probs = c(0.025, 0.5, 0.975))
vp2021myz <- quantile(x=ms2$vertical_2021[,9], probs = c(0.025, 0.5, 0.975))

df_vertical_p <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(vp2019[2], vp2020[2], vp2021[2], vp2019hkd[2], vp2020hkd[2], vp2021hkd[2],  vp2019stm[2], vp2020stm[2], vp2021stm[2], vp2019cba[2], vp2020cba[2], vp2021cba[2], vp2019tk[2], vp2020tk[2], vp2021tk[2], vp2019os[2], vp2020os[2], vp2021os[2], vp2019hg[2], vp2020hg[2], vp2021hg[2], vp2019ngs[2], vp2020ngs[2], vp2021ngs[2], vp2019myz[2], vp2020myz[2], vp2021myz[2]),
  "2.5%" = c(vp2019[1], vp2020[1], vp2021[1], vp2019hkd[1], vp2020hkd[1], vp2021hkd[1], vp2019stm[1], vp2020stm[1], vp2021stm[1], vp2019cba[1], vp2020cba[1], vp2021cba[1], vp2019tk[1], vp2020tk[1], vp2021tk[1],vp2019os[1], vp2020os[1], vp2021os[1], vp2019hg[1], vp2020hg[1], vp2021hg[1], vp2019ngs[1], vp2020ngs[1], vp2021ngs[1], vp2019myz[1], vp2020myz[1], vp2021myz[1]),
  "97.5%" = c(vp2019[3], vp2020[3], vp2021[3], vp2019hkd[3], vp2020hkd[3], vp2021hkd[3], vp2019stm[3], vp2020stm[3], vp2021stm[3], vp2019cba[3], vp2020cba[3], vp2021cba[3],  vp2019tk[3], vp2020tk[3], vp2021tk[3], vp2019os[3], vp2020os[3], vp2021os[3], vp2019hg[3], vp2020hg[3], vp2021hg[3], vp2019ngs[3], vp2020ngs[3], vp2021ngs[3], vp2019myz[3], vp2020myz[3], vp2021myz[3])
)

# df for vertical transmission per 10000 pregnancies
df_vertical_pregnancy_p <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = 10000*c(vp2019[2]/sum(df1$All[19:30]), vp2020[2]/sum(df1$All[31:42]), vp2021[2]/sum(df1$All[43:54]), vp2019hkd[2]/sum(df1$Hokkaido[19:30]), vp2020hkd[2]/sum(df1$Hokkaido[31:42]), vp2021hkd[2]/sum(df1$Hokkaido[43:54]),  vp2019stm[2]/sum(df1$Saitama[19:30]), vp2020stm[2]/sum(df1$Saitama[31:42]), vp2021stm[2]/sum(df1$Saitama[43:54]), vp2019cba[2]/sum(df1$Chiba[19:30]), vp2020cba[2]/sum(df1$Chiba[31:42]), vp2021cba[2]/sum(df1$Chiba[43:54]), vp2019tk[2]/sum(df1$Tokyo[19:30]), vp2020tk[2]/sum(df1$Tokyo[31:42]), vp2021tk[2]/sum(df1$Tokyo[43:54]), vp2019os[2]/sum(df1$Osaka[19:30]), vp2020os[2]/sum(df1$Osaka[31:42]), vp2021os[2]/sum(df1$Osaka[43:54]), vp2019hg[2]/sum(df1$Hyogo[19:30]), vp2020hg[2]/sum(df1$Hyogo[31:42]), vp2021hg[2]/sum(df1$Hyogo[43:54]), vp2019ngs[2]/sum(df1$Nagasaki[19:30]), vp2020ngs[2]/sum(df1$Nagasaki[31:42]), vp2021ngs[2]/sum(df1$Nagasaki[43:54]), vp2019myz[2]/sum(df1$Miyazaki[19:30]), vp2020myz[2]/sum(df1$Miyazaki[31:42]), vp2021myz[2]/sum(df1$Miyazaki[43:54])),
  "2.5%" = 10000*c(vp2019[1]/sum(df1$All[19:30]), vp2020[1]/sum(df1$All[31:42]), vp2021[1]/sum(df1$All[43:54]), vp2019hkd[1]/sum(df1$Hokkaido[19:30]), vp2020hkd[1]/sum(df1$Hokkaido[31:42]), vp2021hkd[1]/sum(df1$Hokkaido[43:54]), vp2019stm[1]/sum(df1$Saitama[19:30]), vp2020stm[1]/sum(df1$Saitama[31:42]), vp2021stm[1]/sum(df1$Saitama[43:54]), vp2019cba[1]/sum(df1$Chiba[19:30]), vp2020cba[1]/sum(df1$Chiba[31:42]), vp2021cba[1]/sum(df1$Chiba[43:54]), vp2019tk[1]/sum(df1$Tokyo[19:30]), vp2020tk[1]/sum(df1$Tokyo[31:42]), vp2021tk[1]/sum(df1$Tokyo[43:54]),vp2019os[1]/sum(df1$Osaka[19:30]), vp2020os[1]/sum(df1$Osaka[31:42]), vp2021os[1]/sum(df1$Osaka[43:54]), vp2019hg[1]/sum(df1$Hyogo[19:30]), vp2020hg[1]/sum(df1$Hyogo[31:42]), vp2021hg[1]/sum(df1$Hyogo[43:54]), vp2019ngs[1]/sum(df1$Nagasaki[19:30]), vp2020ngs[1]/sum(df1$Nagasaki[31:42]), vp2021ngs[1]/sum(df1$Nagasaki[43:54]), vp2019myz[1]/sum(df1$Miyazaki[19:30]), vp2020myz[1]/sum(df1$Miyazaki[31:42]), vp2021myz[1]/sum(df1$Miyazaki[43:54])),
  "97.5%" = 10000*c(vp2019[3]/sum(df1$All[19:30]), vp2020[3]/sum(df1$All[31:42]), vp2021[3]/sum(df1$All[43:54]), vp2019hkd[3]/sum(df1$Hokkaido[19:30]), vp2020hkd[3]/sum(df1$Hokkaido[31:42]), vp2021hkd[3]/sum(df1$Hokkaido[43:54]), vp2019stm[3]/sum(df1$Saitama[19:30]), vp2020stm[3]/sum(df1$Saitama[31:42]), vp2021stm[3]/sum(df1$Saitama[43:54]), vp2019cba[3]/sum(df1$Chiba[19:30]), vp2020cba[3]/sum(df1$Chiba[31:42]), vp2021cba[3]/sum(df1$Chiba[43:54]),  vp2019tk[3]/sum(df1$Tokyo[19:30]), vp2020tk[3]/sum(df1$Tokyo[31:42]), vp2021tk[3]/sum(df1$Tokyo[43:54]), vp2019os[3]/sum(df1$Osaka[19:30]), vp2020os[3]/sum(df1$Osaka[31:42]), vp2021os[3]/sum(df1$Osaka[43:54]), vp2019hg[3]/sum(df1$Hyogo[19:30]), vp2020hg[3]/sum(df1$Hyogo[31:42]), vp2021hg[3]/sum(df1$Hyogo[43:54]), vp2019ngs[3]/sum(df1$Nagasaki[19:30]), vp2020ngs[3]/sum(df1$Nagasaki[31:42]), vp2021ngs[3]/sum(df1$Nagasaki[43:54]), vp2019myz[3]/sum(df1$Miyazaki[19:30]), vp2020myz[3]/sum(df1$Miyazaki[31:42]), vp2021myz[3]/sum(df1$Miyazaki[43:54]))
)

# df for vertical (optimistic case)
# all
vo2019 <- quantile(x=ms3$vertical_2019[,1], probs = c(0.025, 0.5, 0.975))
vo2020 <- quantile(x=ms3$vertical_2020[,1], probs = c(0.025, 0.5, 0.975))
vo2021 <- quantile(x=ms3$vertical_2021[,1], probs = c(0.025, 0.5, 0.975))
# Hokkaido
vo2019hkd <- quantile(x=ms3$vertical_2019[,2], probs = c(0.025, 0.5, 0.975))
vo2020hkd <- quantile(x=ms3$vertical_2020[,2], probs = c(0.025, 0.5, 0.975))
vo2021hkd <- quantile(x=ms3$vertical_2021[,2], probs = c(0.025, 0.5, 0.975))
# Saitama
vo2019stm <- quantile(x=ms3$vertical_2019[,3], probs = c(0.025, 0.5, 0.975))
vo2020stm <- quantile(x=ms3$vertical_2020[,3], probs = c(0.025, 0.5, 0.975))
vo2021stm <- quantile(x=ms3$vertical_2021[,3], probs = c(0.025, 0.5, 0.975))
# Chiba
vo2019cba <- quantile(x=ms3$vertical_2019[,4], probs = c(0.025, 0.5, 0.975))
vo2020cba <- quantile(x=ms3$vertical_2020[,4], probs = c(0.025, 0.5, 0.975))
vo2021cba <- quantile(x=ms3$vertical_2021[,4], probs = c(0.025, 0.5, 0.975))
# Tokyo
vo2019tk <- quantile(x=ms3$vertical_2019[,5], probs = c(0.025, 0.5, 0.975))
vo2020tk <- quantile(x=ms3$vertical_2020[,5], probs = c(0.025, 0.5, 0.975))
vo2021tk <- quantile(x=ms3$vertical_2021[,5], probs = c(0.025, 0.5, 0.975))
# Osaka
vo2019os <- quantile(x=ms3$vertical_2019[,6], probs = c(0.025, 0.5, 0.975))
vo2020os <- quantile(x=ms3$vertical_2020[,6], probs = c(0.025, 0.5, 0.975))
vo2021os <- quantile(x=ms3$vertical_2021[,6], probs = c(0.025, 0.5, 0.975))
# Hyogo
vo2019hg <- quantile(x=ms3$vertical_2019[,7], probs = c(0.025, 0.5, 0.975))
vo2020hg <- quantile(x=ms3$vertical_2020[,7], probs = c(0.025, 0.5, 0.975))
vo2021hg <- quantile(x=ms3$vertical_2021[,7], probs = c(0.025, 0.5, 0.975))
# Nagasaki
vo2019ngs <- quantile(x=ms3$vertical_2019[,8], probs = c(0.025, 0.5, 0.975))
vo2020ngs <- quantile(x=ms3$vertical_2020[,8], probs = c(0.025, 0.5, 0.975))
vo2021ngs <- quantile(x=ms3$vertical_2021[,8], probs = c(0.025, 0.5, 0.975))
# Miyazaki
vo2019myz <- quantile(x=ms3$vertical_2019[,9], probs = c(0.025, 0.5, 0.975))
vo2020myz <- quantile(x=ms3$vertical_2020[,9], probs = c(0.025, 0.5, 0.975))
vo2021myz <- quantile(x=ms3$vertical_2021[,9], probs = c(0.025, 0.5, 0.975))

df_vertical_o <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = c(vo2019[2], vo2020[2], vo2021[2], vo2019hkd[2], vo2020hkd[2], vo2021hkd[2],  vo2019stm[2], vo2020stm[2], vo2021stm[2], vo2019cba[2], vo2020cba[2], vo2021cba[2], vo2019tk[2], vo2020tk[2], vo2021tk[2], vo2019os[2], vo2020os[2], vo2021os[2], vo2019hg[2], vo2020hg[2], vo2021hg[2], vo2019ngs[2], vo2020ngs[2], vo2021ngs[2], vo2019myz[2], vo2020myz[2], vo2021myz[2]),
  "2.5%" = c(vo2019[1], vo2020[1], vo2021[1], vo2019hkd[1], vo2020hkd[1], vo2021hkd[1], vo2019stm[1], vo2020stm[1], vo2021stm[1], vo2019cba[1], vo2020cba[1], vo2021cba[1], vo2019tk[1], vo2020tk[1], vo2021tk[1],vo2019os[1], vo2020os[1], vo2021os[1], vo2019hg[1], vo2020hg[1], vo2021hg[1], vo2019ngs[1], vo2020ngs[1], vo2021ngs[1], vo2019myz[1], vo2020myz[1], vo2021myz[1]),
  "97.5%" = c(vo2019[3], vo2020[3], vo2021[3], vo2019hkd[3], vo2020hkd[3], vo2021hkd[3], vo2019stm[3], vo2020stm[3], vo2021stm[3], vo2019cba[3], vo2020cba[3], vo2021cba[3],  vo2019tk[3], vo2020tk[3], vo2021tk[3], vo2019os[3], vo2020os[3], vo2021os[3], vo2019hg[3], vo2020hg[3], vo2021hg[3], vo2019ngs[3], vo2020ngs[3], vo2021ngs[3], vo2019myz[3], vo2020myz[3], vo2021myz[3])
)

# df for vertical transmission per 10000 pregnancies
df_vertical_pregnancy_o <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "50%" = 10000*c(vo2019[2]/sum(df1$All[19:30]), vo2020[2]/sum(df1$All[31:42]), vo2021[2]/sum(df1$All[43:54]), vo2019hkd[2]/sum(df1$Hokkaido[19:30]), vo2020hkd[2]/sum(df1$Hokkaido[31:42]), vo2021hkd[2]/sum(df1$Hokkaido[43:54]),  vo2019stm[2]/sum(df1$Saitama[19:30]), vo2020stm[2]/sum(df1$Saitama[31:42]), vo2021stm[2]/sum(df1$Saitama[43:54]), vo2019cba[2]/sum(df1$Chiba[19:30]), vo2020cba[2]/sum(df1$Chiba[31:42]), vo2021cba[2]/sum(df1$Chiba[43:54]), vo2019tk[2]/sum(df1$Tokyo[19:30]), vo2020tk[2]/sum(df1$Tokyo[31:42]), vo2021tk[2]/sum(df1$Tokyo[43:54]), vo2019os[2]/sum(df1$Osaka[19:30]), vo2020os[2]/sum(df1$Osaka[31:42]), vo2021os[2]/sum(df1$Osaka[43:54]), vo2019hg[2]/sum(df1$Hyogo[19:30]), vo2020hg[2]/sum(df1$Hyogo[31:42]), vo2021hg[2]/sum(df1$Hyogo[43:54]), vo2019ngs[2]/sum(df1$Nagasaki[19:30]), vo2020ngs[2]/sum(df1$Nagasaki[31:42]), vo2021ngs[2]/sum(df1$Nagasaki[43:54]), vo2019myz[2]/sum(df1$Miyazaki[19:30]), vo2020myz[2]/sum(df1$Miyazaki[31:42]), vo2021myz[2]/sum(df1$Miyazaki[43:54])),
  "2.5%" = 10000*c(vo2019[1]/sum(df1$All[19:30]), vo2020[1]/sum(df1$All[31:42]), vo2021[1]/sum(df1$All[43:54]), vo2019hkd[1]/sum(df1$Hokkaido[19:30]), vo2020hkd[1]/sum(df1$Hokkaido[31:42]), vo2021hkd[1]/sum(df1$Hokkaido[43:54]), vo2019stm[1]/sum(df1$Saitama[19:30]), vo2020stm[1]/sum(df1$Saitama[31:42]), vo2021stm[1]/sum(df1$Saitama[43:54]), vo2019cba[1]/sum(df1$Chiba[19:30]), vo2020cba[1]/sum(df1$Chiba[31:42]), vo2021cba[1]/sum(df1$Chiba[43:54]), vo2019tk[1]/sum(df1$Tokyo[19:30]), vo2020tk[1]/sum(df1$Tokyo[31:42]), vo2021tk[1]/sum(df1$Tokyo[43:54]),vo2019os[1]/sum(df1$Osaka[19:30]), vo2020os[1]/sum(df1$Osaka[31:42]), vo2021os[1]/sum(df1$Osaka[43:54]), vo2019hg[1]/sum(df1$Hyogo[19:30]), vo2020hg[1]/sum(df1$Hyogo[31:42]), vo2021hg[1]/sum(df1$Hyogo[43:54]), vo2019ngs[1]/sum(df1$Nagasaki[19:30]), vo2020ngs[1]/sum(df1$Nagasaki[31:42]), vo2021ngs[1]/sum(df1$Nagasaki[43:54]), vo2019myz[1]/sum(df1$Miyazaki[19:30]), vo2020myz[1]/sum(df1$Miyazaki[31:42]), vo2021myz[1]/sum(df1$Miyazaki[43:54])),
  "97.5%" = 10000*c(vo2019[3]/sum(df1$All[19:30]), vo2020[3]/sum(df1$All[31:42]), vo2021[3]/sum(df1$All[43:54]), vo2019hkd[3]/sum(df1$Hokkaido[19:30]), vo2020hkd[3]/sum(df1$Hokkaido[31:42]), vo2021hkd[3]/sum(df1$Hokkaido[43:54]), vo2019stm[3]/sum(df1$Saitama[19:30]), vo2020stm[3]/sum(df1$Saitama[31:42]), vo2021stm[3]/sum(df1$Saitama[43:54]), vo2019cba[3]/sum(df1$Chiba[19:30]), vo2020cba[3]/sum(df1$Chiba[31:42]), vo2021cba[3]/sum(df1$Chiba[43:54]),  vo2019tk[3]/sum(df1$Tokyo[19:30]), vo2020tk[3]/sum(df1$Tokyo[31:42]), vo2021tk[3]/sum(df1$Tokyo[43:54]), vo2019os[3]/sum(df1$Osaka[19:30]), vo2020os[3]/sum(df1$Osaka[31:42]), vo2021os[3]/sum(df1$Osaka[43:54]), vo2019hg[3]/sum(df1$Hyogo[19:30]), vo2020hg[3]/sum(df1$Hyogo[31:42]), vo2021hg[3]/sum(df1$Hyogo[43:54]), vo2019ngs[3]/sum(df1$Nagasaki[19:30]), vo2020ngs[3]/sum(df1$Nagasaki[31:42]), vo2021ngs[3]/sum(df1$Nagasaki[43:54]), vo2019myz[3]/sum(df1$Miyazaki[19:30]), vo2020myz[3]/sum(df1$Miyazaki[31:42]), vo2021myz[3]/sum(df1$Miyazaki[43:54]))
)


df_vertical_s <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "Base" = c(v2019[2], v2020[2], v2021[2], v2019hkd[2], v2020hkd[2], v2021hkd[2],  v2019stm[2], v2020stm[2], v2021stm[2], v2019cba[2], v2020cba[2], v2021cba[2], v2019tk[2], v2020tk[2], v2021tk[2], v2019os[2], v2020os[2], v2021os[2], v2019hg[2], v2020hg[2], v2021hg[2], v2019ngs[2], v2020ngs[2], v2021ngs[2], v2019myz[2], v2020myz[2], v2021myz[2]),
  "Pessimistic" = c(vp2019[2], vp2020[2], vp2021[2], vp2019hkd[2], vp2020hkd[2], vp2021hkd[2], vp2019stm[2], vp2020stm[2], vp2021stm[2], vp2019cba[2], vp2020cba[2], vp2021cba[2], vp2019tk[2], vp2020tk[2], vp2021tk[2],vp2019os[2], vp2020os[2], vp2021os[2], vp2019hg[2], vp2020hg[2], vp2021hg[2], vp2019ngs[2], vp2020ngs[2], vp2021ngs[2], vp2019myz[2], vp2020myz[2], vp2021myz[2]),
  "Opportunistic" = c(vo2019[2], vo2020[2], vo2021[2], vo2019hkd[2], vo2020hkd[2], vo2021hkd[2], vo2019stm[2], vo2020stm[2], vo2021stm[2], vo2019cba[2], vo2020cba[2], vo2021cba[2],  vo2019tk[2], vo2020tk[2], vo2021tk[2], vo2019os[2], vo2020os[2], vo2021os[2], vo2019hg[2], vo2020hg[2], vo2021hg[2], vo2019ngs[2], vo2020ngs[2], vo2021ngs[2], vo2019myz[2], vo2020myz[2], vo2021myz[2])
)

# df for vertical transmission per 10000 pregnancies (sensitivity analysis)
df_vertical_pregnancy_s <- tibble(
  X = rep(c("2019", "2020", "2021"),9),
  prefecture =c(rep("All", 3), rep("Hokkaido", 3), rep("Saitama", 3), rep("Chiba", 3), rep("Tokyo", 3), rep("Osaka", 3), rep("Hyogo", 3), rep("Nagasaki", 3), rep("Miyazaki", 3)),
  "Base" = 10000*c(v2019[2]/sum(df1$All[19:30]), v2020[2]/sum(df1$All[31:42]), v2021[2]/sum(df1$All[43:54]), v2019hkd[2]/sum(df1$Hokkaido[19:30]), v2020hkd[2]/sum(df1$Hokkaido[31:42]), v2021hkd[2]/sum(df1$Hokkaido[43:54]),  v2019stm[2]/sum(df1$Saitama[19:30]), v2020stm[2]/sum(df1$Saitama[31:42]), v2021stm[2]/sum(df1$Saitama[43:54]), v2019cba[2]/sum(df1$Chiba[19:30]), v2020cba[2]/sum(df1$Chiba[31:42]), v2021cba[2]/sum(df1$Chiba[43:54]), v2019tk[2]/sum(df1$Tokyo[19:30]), v2020tk[2]/sum(df1$Tokyo[31:42]), v2021tk[2]/sum(df1$Tokyo[43:54]), v2019os[2]/sum(df1$Osaka[19:30]), v2020os[2]/sum(df1$Osaka[31:42]), v2021os[2]/sum(df1$Osaka[43:54]), v2019hg[2]/sum(df1$Hyogo[19:30]), v2020hg[2]/sum(df1$Hyogo[31:42]), v2021hg[2]/sum(df1$Hyogo[43:54]), v2019ngs[2]/sum(df1$Nagasaki[19:30]), v2020ngs[2]/sum(df1$Nagasaki[31:42]), v2021ngs[2]/sum(df1$Nagasaki[43:54]), v2019myz[2]/sum(df1$Miyazaki[19:30]), v2020myz[2]/sum(df1$Miyazaki[31:42]), v2021myz[2]/sum(df1$Miyazaki[43:54])),
  "Pessimistic" = 10000*c(vp2019[2]/sum(df1$All[19:30]), vp2020[2]/sum(df1$All[31:42]), vp2021[2]/sum(df1$All[43:54]), vp2019hkd[2]/sum(df1$Hokkaido[19:30]), vp2020hkd[2]/sum(df1$Hokkaido[31:42]), vp2021hkd[2]/sum(df1$Hokkaido[43:54]),  vp2019stm[2]/sum(df1$Saitama[19:30]), vp2020stm[2]/sum(df1$Saitama[31:42]), vp2021stm[2]/sum(df1$Saitama[43:54]), vp2019cba[2]/sum(df1$Chiba[19:30]), vp2020cba[2]/sum(df1$Chiba[31:42]), vp2021cba[2]/sum(df1$Chiba[43:54]), vp2019tk[2]/sum(df1$Tokyo[19:30]), vp2020tk[2]/sum(df1$Tokyo[31:42]), vp2021tk[2]/sum(df1$Tokyo[43:54]), vp2019os[2]/sum(df1$Osaka[19:30]), vp2020os[2]/sum(df1$Osaka[31:42]), vp2021os[2]/sum(df1$Osaka[43:54]), vp2019hg[2]/sum(df1$Hyogo[19:30]), vp2020hg[2]/sum(df1$Hyogo[31:42]), vp2021hg[2]/sum(df1$Hyogo[43:54]), vp2019ngs[2]/sum(df1$Nagasaki[19:30]), vp2020ngs[2]/sum(df1$Nagasaki[31:42]), vp2021ngs[2]/sum(df1$Nagasaki[43:54]), vp2019myz[2]/sum(df1$Miyazaki[19:30]), vp2020myz[2]/sum(df1$Miyazaki[31:42]), vp2021myz[2]/sum(df1$Miyazaki[43:54])),
  "Opportunistic" = 10000*c(vo2019[2]/sum(df1$All[19:30]), vo2020[2]/sum(df1$All[31:42]), vo2021[2]/sum(df1$All[43:54]), vo2019hkd[2]/sum(df1$Hokkaido[19:30]), vo2020hkd[2]/sum(df1$Hokkaido[31:42]), vo2021hkd[2]/sum(df1$Hokkaido[43:54]),  vo2019stm[2]/sum(df1$Saitama[19:30]), vo2020stm[2]/sum(df1$Saitama[31:42]), vo2021stm[2]/sum(df1$Saitama[43:54]), vo2019cba[2]/sum(df1$Chiba[19:30]), vo2020cba[2]/sum(df1$Chiba[31:42]), vo2021cba[2]/sum(df1$Chiba[43:54]), vo2019tk[2]/sum(df1$Tokyo[19:30]), vo2020tk[2]/sum(df1$Tokyo[31:42]), vo2021tk[2]/sum(df1$Tokyo[43:54]), vo2019os[2]/sum(df1$Osaka[19:30]), vo2020os[2]/sum(df1$Osaka[31:42]), vo2021os[2]/sum(df1$Osaka[43:54]), vo2019hg[2]/sum(df1$Hyogo[19:30]), vo2020hg[2]/sum(df1$Hyogo[31:42]), vo2021hg[2]/sum(df1$Hyogo[43:54]), vo2019ngs[2]/sum(df1$Nagasaki[19:30]), vo2020ngs[2]/sum(df1$Nagasaki[31:42]), vo2021ngs[2]/sum(df1$Nagasaki[43:54]), vo2019myz[2]/sum(df1$Miyazaki[19:30]), vo2020myz[2]/sum(df1$Miyazaki[31:42]), vo2021myz[2]/sum(df1$Miyazaki[43:54]))
)

# Figure 3B
df_vertical_pregnancy_s$prefecture <- fct_relevel(df_vertical_pregnancy_s$prefecture, "All", "Hokkaido", "Saitama", "Chiba", "Tokyo", "Osaka", "Hyogo", "Nagasaki", "Miyazaki")
p5 <- ggplot(data =df_vertical_pregnancy_s, mapping = aes(x=prefecture, y=`Base`, shape=factor(X))) +
  geom_point(position=position_dodge(width = 0.9))+
  geom_point(data =  df_vertical_pregnancy_s, mapping=aes(x=prefecture, y = `Pessimistic`), position=position_dodge(width = 0.9))+
  geom_point(data =  df_vertical_pregnancy_s, mapping=aes(x=prefecture, y = `Opportunistic`), position=position_dodge(width = 0.9))+
  theme_classic()+
  labs(x= "Prefecture", y = "New CT per 10000 pregnancies")+
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1))+
  guides(shape=FALSE)
p5
```

![](toxoplasma_files/figure-gfm/plot%20for%20figure%203-2.png)<!-- -->

``` r
p4+p5
```

![](toxoplasma_files/figure-gfm/plot%20for%20figure%203-3.png)<!-- -->
