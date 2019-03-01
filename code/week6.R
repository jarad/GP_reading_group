library("tidyverse")
library("geoR")

d <- read.csv("yield.csv") %>%
  mutate(x = scale(x), y = scale(y))

ggplot(d, aes(x,y,color=yield)) + 
  geom_point() +
  theme_bw()


# 
dg <- as.geodata(d, coords.col = 18:19, data.col = 28)
plot(variog(dg))

fit <- likfit(dg, ini.cov.pars = 1:2, 
              cov.model = "exponential")

n <- 201
dp <- expand.grid(x = seq(min(d$x), max(d$x), length = n),
                  y = seq(min(d$y), max(d$y), length = n))


dk <- krige.conv(dg, locations = dp, 
           krige = krige.control(cov.pars = 1:2))

dp$mu <- dk$predict
dp$sd <- sqrt(dk$krige.var)

ggplot(dp, aes(x, y, fill = mu)) + 
  geom_raster() + 
  theme_bw()

ggplot(dp, aes(x, y, fill = sd)) + 
  geom_raster() + 
  theme_bw()
