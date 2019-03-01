# make sure to set the working directory to the GP_reading_group/code folder
# setwd("code")

library("tidyverse")
library("geoR")

d <- read.csv("yield.csv") %>%
  mutate(long = scale(x), lat = scale(y)) %>%
  select(long, lat, yield, elevation)

ggplot(d, aes(long, lat, color = yield)) + 
  geom_point() +
  theme_bw()


# Create a geodata object
dg <- as.geodata(d, coords.col = 1:2, data.col = 3)

# Take a look at the variogram
plot(variog(dg))

# Identify covariance parameters
segments(0,0, y1=1500, col='red'); text(0, 750, "nugget", col = 'red', pos = 4)
segments(0.1, 1500, y1 = 3500, col='blue'); text(0.1, 2500, "partial sill", col = 'blue', pos = 4)
segments(0, 0, x1 = 3, col='seagreen'); text(2, 0, "range", col='seagreen', pos=3)

nugget.init <- 1500
partial_sill.init   <- 3500-1500
range.init  <- 3


########################## Estimation ####################################
# Estimation of model parameters for exponential covariance function
varfit <- variofit(variog(dg), ini.cov.pars = c(partial_sill.init, range.init), 
         nugget = nugget.init,
         cov.model = "exponential")

fit <- likfit(dg, ini.cov.pars = c(partial_sill.init, range.init), 
              nugget = nugget.init,
              cov.model = "exponential")

# the results from the following command are odd
bayes.fit <- krige.bayes(dg, 
                         model = model.control(cov.m = "exponential"))



################### Prediction #############################

# Construct predictive grid
n <- 201
dp <- expand.grid(long = seq(min(d$long), max(d$long), length = n),
                  lat  = seq(min(d$lat ), max(d$lat ), length = n))

# Predict at those locations using ML estimation of covariance parameters
dk <- krige.conv(dg, locations = dp, 
           krige = krige.control(
             cov.model = fit$cov.model,
             cov.pars  = fit$cov.pars,
             nugget    = fit$nugget))

dp$mu <- dk$predict
dp$sd <- sqrt(dk$krige.var)

ggplot(dp, aes(long, lat, fill = mu)) + 
  geom_raster() + 
  guides(fill = guide_legend(title = "Expected\nyield")) +
  labs(title = "Posterior mean (given covariance parameter estimates)") + 
  theme_bw()

ggplot(dp, aes(long, lat, fill = sd)) + 
  geom_raster() + 
  labs(title = "Posterior sd (given covariance parameter estimates)") + 
  theme_bw()
