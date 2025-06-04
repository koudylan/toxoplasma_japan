# toxoplasma_japan

This repository contains the data and code used to produce the results
presented in “Toxoplasma gondii infection risk among pregnant people and congenital toxoplasmosis incidence in Japan”.

The raw data is located in the folder “data”:

-   `offsprings.csv` (monthly offspring report from Jun 2022 to Dec 2022)
-   `offsprings2.csv` (monthly offspring report from Apr 2018 to Jul 2018)
-   `pregnancy_report.csv` (monthly pregnancy report from Jan 2018 to Oct 2021)
-   `spiramycin.csv` (prescribed number of spiramycin doses per fiscal year from 2018 to 2021)

The main scripts are located in the folder “main”:

- :  `FoIEstimation.R` (estimation of FoIs and decay rate assuming SIS
    catalytic model)
-   `MixtureModel.R` (estimation of the means and variances for the

The scripts for the sensitivity analysis are located in the folder "sensitivity":
