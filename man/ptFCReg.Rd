% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ptFCReg.R
\name{ptFCReg}
\alias{ptFCReg}
\title{Functional concurrent regression using pointwise multiple linear regression.}
\usage{
ptFCReg(tGrid, dat)
}
\arguments{
\item{tGrid}{A vector of length \eqn{m} with the input time points.}

\item{dat}{A list of input functional/scalar covariates. 
Each field corresponds to a functional (a matrix) or scalar (a vector) variable. 
The last entry is assumed to be the functional response if no entry is names \code{'Y'}. 
If a field corresponds to a functional variable, it should be an \eqn{n}-by-\eqn{m} matrix,
where each row holds the observations for one subject on the common grid \code{tGrid}. 
If a field corresponds to a scalar covariate, it should be a vector of length \eqn{n}.}
}
\value{
A list containing the following fields: 
\describe{
\item{beta0}{A vector containing the time-varying intercept evaluated on \code{tGrid}.}
\item{beta}{A matrix for the concurrent regression effects, 
where rows correspond to different predictors and columns to different time points in \code{tGrid}.}
\item{tGrid}{The input \code{tGrid}.}
\item{R2}{A vector of the time-varying \eqn{R^2(t)}, evaluated at \eqn{t} in \code{tGrid}.}
\item{Ldf}{A list holding the input data, each element of which is a data frame holding 
the data observed at one element of \code{tGrid}.}
}
}
\description{
Functional concurrent regression using pointwise multiple linear regression.
}
\examples{
set.seed(1)
n <- 50
nGridIn <- 101
tGrid <- seq(0, 1, length.out=nGridIn) # Functional data support
muX1 <- tGrid * 2 # mean function for X_1
sigma <- 1
beta0 <- 0
beta <- rbind(cos(tGrid), 1.5 + sin(tGrid))
Z <- MASS::mvrnorm(n, rep(0, 2), diag(2))
X_1 <- Z[, 1, drop=FALSE] \%*\% matrix(1, 1, nGridIn) + matrix(muX1, n, nGridIn, byrow=TRUE)
epsilon <- rnorm(n, sd=sigma)
Y <- t(sapply(seq_len(n), function(i) {
  beta0 + beta[1,] * X_1[i, ] + beta[2,] * Z[i, 2] + epsilon[i]
}))
dat <- list(X1=X_1, Z1=Z[, 2], Y=Y)
res <- ptFCReg(tGrid = tGrid, dat = dat)
}
