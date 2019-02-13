# The dataset discussed in Diggle and Ribeiro is avaiable in their geoR R 
# package. So start by installing that package. This code also uses R packages
# within the "tidyverse" so install that package as well. 

# install.packages(c("geoR","tidyverse"))

library("tidyverse")
library("geoR")

# Matern correlation function
d <- expand.grid(distance = seq(0.01, 10, length = 101),
                 phi = c(1,10), kappa = c(1,10)) %>%
  group_by(phi,kappa) %>%
  mutate(correlation = geoR::matern(distance, phi, kappa))

ggplot(d, aes(distance, correlation, linetype = factor(phi), 
              color = factor(kappa))) +
  geom_line() + 
  theme_bw()


# Default exploratory plots
plot(elevation)


# Variogram
v <- variog(elevation)
plot(v)

vf <- variofit(v, 
               ini.cov.pars = 
               cov.model = cov.spatial(cov.model = "matern"))


