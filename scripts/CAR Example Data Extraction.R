# Taken from https://cran.r-project.org/web/packages/CARBayes/vignettes/CARBayes.pdf

rm(list = ls())

library(CARBayesdata)
library(sp)
library(rgdal)
library(spdep)
library(dplyr)


# Pollution health data --------------------
data(GGHB.IG)
data(pollutionhealthdata)
dat <- pollutionhealthdata
dat <- dat %>%
  filter(year == 2011)

dat.sp <- merge(x = GGHB.IG, y = dat, by = "IG", all.x = FALSE)
W.nb <- poly2nb(dat.sp, row.names = rownames(dat.sp@data))
W.list <- nb2listw(W.nb, style = "B")

# Adjacency matrix
W <- nb2mat(W.nb, style = "B")
write.csv(W, file = "adj.csv", row.names = TRUE)

# Data
dat <- dat.sp@data
dat$locations <- 0:(nrow(dat)-1)
dat$counts <- dat$observed
dat$expectedCounts <- dat$expected
dat$covariates <- dat$pm10
dat <- dat %>%
  select(locations, counts, expectedCounts, covariates)
write.csv(dat, file = "data.csv", row.names = FALSE)
