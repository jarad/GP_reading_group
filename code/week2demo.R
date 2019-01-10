## Reading group demo and functions

## packages to install
# install.packages(pkgs = "mvtnorm")
library(mvtnorm)

## squared exponential covariance function 
cov_fun_sqrd_exp <- function(x1, x2, cov_par)
{
  ## x1, x2 are possibly vectors (but need to be of the same length)
  ## cov_par is a list with elements "sigma" and "l"
  sigma <- cov_par$sigma
  l <- cov_par$l
  
  return(sigma^2 * exp(-1/(2*l^2) * sum((x1 - x2)^2)))
}

## squared exponential covariance function plot 
x1 <- 0
x2 <- seq(from = 0, to = 1, by = 0.05)

sigma <- 1
l <- c(0.1, 0.2, 0.5, 1)

cov_fun_vals <- matrix(nrow = length(x2), ncol = length(l))
for(i in 1:nrow(cov_fun_vals))
{
  for(j in 1:ncol(cov_fun_vals))
  {
    cov_fun_vals[i,j] <- cov_fun_sqrd_exp(x1 = x1, x2 = x2[i], 
                                          cov_par = list("sigma" = sigma, "l" = l[j]))
  }
}

plot(x = x2, y = cov_fun_vals[,1], type = "l", ylab = "Correlation") ## l = 0.1
points(x = x2, y = cov_fun_vals[,2], type = "l", col = "red") ## l = 0.2
points(x = x2, y = cov_fun_vals[,3], type = "l", col = "blue") ## l = 0.5
points(x = x2, y = cov_fun_vals[,4], type = "l", col = "green") ## l = 1

#############################################################################
## Function to make a covariance matrix from a covariance function
#############################################################################
make_cov_mat <- function(x, xpred, cov_fun, cov_par)
{
  ## x and xpred are matrices where each row is an observation
  xfull <- rbind(x,xpred)
  temp <- matrix(nrow = nrow(xfull), ncol = nrow(xfull))
  for(i in 1:nrow(xfull))
  {
    for(j in 1:nrow(xfull))
    {
      temp[i,j] <- cov_fun(xfull[i,], xfull[j,], cov_par)
    }
  }
  return(temp)
}

## Example of a covariance matrix created from the squared exponential covariance function
x <- matrix(seq(from = 0, to = 1, by = 0.5), ncol = 1) ## x coordinates at which we observe a y-value
sigma <- 1 
l <- 0.5

Sigma <- make_cov_mat(x = x, 
                      xpred = numeric(), 
                      cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = sigma, "l" = l))
Sigma


#################################################################################
## Simulate from a Gaussian process
#################################################################################

## Create the covariance matrix 
x <- matrix(seq(from = 0, to = 1, by = 0.01), ncol = 1)
sigma <- 1
l <- 0.1

Sigma <- make_cov_mat(x = x, 
                      xpred = numeric(), 
                      cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = sigma, "l" = l))

## simulate a GP
set.seed(1111)
gp <- mvtnorm::rmvnorm(n = 1, mean = rep(0, times = length(x)), sigma = Sigma)

plot(x = x, y = gp)
plot(x = x, y = gp, type = "l")

##################################################################################
## Predict from a GP
##################################################################################
xunobs <- matrix( x[x[,1] < 0.6 & x[,1] > 0.3,], ncol = 1) ## pretend like we didn't see the function between 0.3 and 0.6
xobs <- matrix( x[x[,1] >= 0.6 | x[,1] <= 0.3,], ncol = 1)
gpobs <- gp[x[,1] >= 0.6 | x[,1] <= 0.3]

plot(x = xobs, y = gpobs, ylim = c(-1.75, 3.5))

## Create the covariance matrix 
sigma <- 1
l <- 0.1

Sigma <- make_cov_mat(x = xobs, 
                      xpred = xunobs, 
                      cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = sigma, "l" = l))

Sigma <- Sigma + 1e-5 * diag(nrow(Sigma)) ## add a small number to the diagonal of the matrix to ensure invertability

## Functions to get the conditional mean and variance for a multivariate normal distribution

## conditional mean
normal_cond_mean <- function(y, x, xpred, mu, sigma)
{
  ## x is the matrix of observed x-values
  ## y is a numeric() vector of the observed y-values 
  ## mu has length rbind(x, xpred)
  ## sigma is the variance covariance matrix with the rows and columns 
  ##  ordered corresponding to (x,xpred)
  temp <- nrow(x) + nrow(xpred)
  
  sigma21 <- sigma[(nrow(x) + 1):temp,1:nrow(x)]
  sigma11 <- sigma[1:nrow(x), 1:nrow(x)]
  return(mu[(nrow(x) + 1):temp] + sigma21 %*% qr.solve(sigma11) %*% (y - mu[1:nrow(x)]))
}

## conditional variance 
normal_cond_var <- function(y,x, xpred, sigma)
{
  ## sigma is the variance covariance matrix with the rows and columns 
  ##  ordered corresponding to (x,xpred)
  temp <- nrow(x) + nrow(xpred)
  
  sigma21 <- sigma[(nrow(x) + 1):temp,1:nrow(x)]
  sigma11 <- sigma[1:nrow(x), 1:nrow(x)]
  sigma22 <- sigma[(nrow(x) + 1):temp,(nrow(x) + 1):temp]
  sigma12 <- sigma[1:nrow(x), (nrow(x) + 1):temp]
  return(sigma22 - sigma21 %*% solve(sigma11) %*% sigma12)
}

## get the conditional mean
gppred <- normal_cond_mean(y = gpobs, x = xobs, 
                           xpred = xunobs, 
                           mu = rep(0, times = nrow(x)), 
                           sigma = Sigma)

## get the conditional variances
gpvar <- normal_cond_var(y = gpobs, x = xobs, xpred = xunobs, sigma = Sigma)
gpsd <- sqrt(diag(gpvar))

## plot the predictive means and variances 
plot(x = xobs, y = gpobs, ylim = c(-1.75, 3.5))
points(x = xunobs, y = gppred, col = "red", pch = 2)
points(x = xunobs, y = gppred + 1.96 * gpsd, col = "blue", type = "l")
points(x = xunobs, y = gppred - 1.96 * gpsd, col = "blue", type = "l")
points(x = x, y = gp, type = "l")


###############################################################################
## Gaussian Process regression with known covariance parameters 
###############################################################################
sigma <- 1
l <- 0.1
tau <- 0.4

gp_noisy <- as.numeric(gp + rnorm(n = length(gp), mean = 0, sd = tau)) ## GP with noise

plot(x = x, y = gp_noisy)

#################################################################################
## Estimate the mean function
#################################################################################
Sigma <- make_cov_mat(x = x, xpred = x, 
                      cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = sigma, "l" = l))

## Make the covariance matrix for (Y, mu)
Sigma <- Sigma + diag(
  c(rep(tau^2, times = length(x)), rep(0, times = length(x)))
)

## Estimate the mean 
mu <- normal_cond_mean(y = gp_noisy, x = x, 
                       xpred = x, 
                       mu = rep(0, times = 2 * length(x)), 
                       sigma = Sigma)

## Estiamte the conditional standard deviations of the latent mean function
musd <- sqrt(diag(normal_cond_var(y = gp_noisy, 
                        x = x, 
                        xpred = x, 
                        sigma = Sigma)))

## plot the estimated mean and pointwise credible intervals
plot(x = x, y = gp_noisy)
points(x = x, y = mu, type = "l")
points(x = x, y = mu - 1.96 * musd, type = "l", lty = 2)
points(x = x, y = mu + 1.96 * musd, type = "l", lty = 2)

## plot prediction intervals
plot(x = x, y = gp_noisy)
points(x = x, y = mu, type = "l")
points(x = x, y = mu - 1.96 * sqrt(musd^2 + tau^2), type = "l", lty = 2)
points(x = x, y = mu + 1.96 * sqrt(musd^2 + tau^2), type = "l", lty = 2)


###############################################################################
## Estimate GP covariance parameters via maximum likelihood
###############################################################################

## log likelihood function compatible with optim
loglik <- function(cov_par, y, x, mu, cov_fun)
{
  ## cov_par is a list of covariannce parameters that now includes tau
  ## create the covariance matrix
  cov_par <- lapply(X = cov_par, FUN = exp)
  Sigma <- make_cov_mat(x = x, 
                        xpred = numeric(), 
                        cov_fun = cov_fun, 
                        cov_par = cov_par)
  
  Sigma <- Sigma + cov_par$tau^2 * diag(rep(1, times = nrow(Sigma))) ## add the noise variance 
  
  ll <- mvtnorm::dmvnorm(x = y, mean = mu, sigma = Sigma, log = TRUE)
  return(-ll)
  
}

start_vals <- list("sigma" = log(2), "l" = log(0.3), "tau" = log(0.1))
estimates <- optim(par = start_vals, 
                   fn = loglik, 
                   y = gp_noisy, 
                   x = x, 
                   mu = rep(0, times = length(gp_noisy)), 
                   cov_fun = cov_fun_sqrd_exp)

## parameter estimates 
exp(estimates$par)


#########################################################################
## Things to look out for...
#########################################################################
x <- matrix(c(0,0.5), ncol = 1) ## x coordinates at which we observe a y-value
sigma <- 1 
l <- 0.5

Sigma <- make_cov_mat(x = x, 
                      xpred = numeric(), 
                      cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = sigma, "l" = l))
Sigma
solve(Sigma)

## close observations
x <- matrix(c(0,0.01), ncol = 1) ## x coordinates at which we observe a y-value
sigma <- 1 
l <- 0.5

Sigma <- make_cov_mat(x = x, 
                      xpred = numeric(), 
                      cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = sigma, "l" = l))
Sigma
solve(Sigma)

## very close observations
x <- matrix(c(0,1e-5), ncol = 1) ## x coordinates at which we observe a y-value
sigma <- 1 
l <- 0.5

Sigma <- make_cov_mat(x = x, 
                      xpred = numeric(), 
                      cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = sigma, "l" = l))
Sigma
solve(Sigma)


###########################################################################
## What happens when you try to learn a discontinuous function
###########################################################################

## simple step function
x <- matrix(seq(from = 0, to = 2.8, by = 0.2), ncol = 1)
y <- as.numeric(floor(x))
plot(x = x, y = y)

## estimate covariance parameters
## log likelihood function compatible with optim (no noise variance)
loglik <- function(cov_par, y, x, mu, cov_fun)
{
  ## cov_par is a list of covariannce parameters that now includes tau
  ## create the covariance matrix
  cov_par <- lapply(X = cov_par, FUN = exp)
  Sigma <- make_cov_mat(x = x, 
                        xpred = numeric(), 
                        cov_fun = cov_fun, 
                        cov_par = cov_par)
  
  Sigma <- Sigma + 1e-5 * diag(rep(1, times = nrow(Sigma))) ## add the noise variance 
  
  
  ll <- mvtnorm::dmvnorm(x = y, mean = mu, sigma = Sigma, log = TRUE)
  return(-ll)
  
}

start_vals <- list("sigma" = log(2), "l" = log(0.3))
estimates <- optim(par = start_vals, 
                   fn = loglik, 
                   y = y, 
                   x = x, 
                   mu = rep(0, times = length(y)), 
                   cov_fun = cov_fun_sqrd_exp)

## parameter estimates 
exp(estimates$par)

## estimated function values
xpred <- matrix(seq(from = 0, to = 3, by = 0.03), ncol = 1)
Sigma <- make_cov_mat(x = x, xpred = xpred, cov_fun = cov_fun_sqrd_exp, 
                      cov_par = list("sigma" = exp(estimates$par)[1], "l" = exp(estimates$par)[2])) + 1e-5 * diag(nrow(rbind(x,xpred)))
mu <- normal_cond_mean(y = y, x = x, xpred = xpred, mu = rep(0, times = nrow(rbind(x,xpred))), sigma = Sigma)
musd <- sqrt(diag(normal_cond_var(y = y, x = x, xpred = xpred, sigma = Sigma)))

plot(x = x, y = y, ylim = c(-0.25, 2.25))
points(x = xpred, y = mu, col = "red", type = "l")
points(x = xpred, y = mu + 1.96 * musd, col = "red", type = "l", lty = 2)
points(x = xpred, y = mu - 1.96 * musd, col = "red", type = "l", lty = 2)


## Inversion time function?