# toxoplasma_japan

This repository contains the data and code used to produce the results
presented in “Toxoplasma gondii infection risk among pregnant people and congenital toxoplasmosis incidence in Japan”.

The raw data is located in the folder “data”:

-   `Data_seroprevalence.csv` (data from reports on seropositivity)
-   `data_under5.txt` (pre-F data of individuals &lt; 5 years)
-   `data_over5.txt` (pre-F data of groups &gt; 5 years)
-   `cleanedData.R` (scripts used to clean the data)
-   `cleanedData.RDS` (cleaned data)

The main scripts are located in the folder “main”:

- :  `FoIEstimation.R` (estimation of FoIs and decay rate assuming SIS
    catalytic model)
-   `MixtureModel.R` (estimation of the means and variances for the

The scripts for the sensitivity analysis are located in the folder "sensitivity":
