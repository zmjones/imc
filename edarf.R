## for this section you need the development versions of
##
##  - zmjones/edarf
##  - zmjones/party (subdir pkg)
##
## devtools::install_github("zmjones/edarf")
## devtools::install_github("zmjones/party", subdir = "pkg")

library(edarf)
library(party)
library(doParallel)

cl <- makePSOCKcluster(6)
registerDoParallel(cl)

## classification example
data(iris)
fit <- cforest(Species ~ ., iris, controls = cforest_unbiased(mtry = 3))

features <- c("Petal.Width", "Petal.Length")
pd <- partial_dependence(fit, iris, features, parallel = TRUE)
plot_pd(pd)
pd <- partial_dependence(fit, iris, features, interaction = TRUE, parallel = TRUE)
plot_pd(pd)

imp <- variable_importance(fit, features, type = "aggregate", oob = TRUE, parallel = TRUE)
plot_imp(imp)
imp <- variable_importance(fit, features, type = "aggregate", interaction = TRUE, oob = TRUE, parallel = TRUE)
plot_imp(imp)
imp <- variable_importance(fit, features, type = "local", oob = TRUE, parallel = TRUE)
plot_imp(imp)
imp <- variable_importance(fit, features, type = "local", interaction = TRUE, oob = TRUE, parallel = TRUE)
plot_imp(imp)

## regression example
data(Boston, package = "MASS")
fit <- cforest(medv ~ ., Boston)

pd <- partial_dependence(fit, Boston, c("lstat", "rm"), ci = TRUE, parallel = TRUE) ## FIXME (works for non-parallel)
plot_pd(pd) ## FIXME
pd <- partial_dependence(fit, Boston, c("lstat", "rm"), interaction = TRUE, ci = TRUE, parallel = TRUE)
plot_pd(pd)

features <- c("lstat", "rm")
imp <- variable_importance(fit, features, type = "aggregate", oob = TRUE, parallel = TRUE)
plot_imp(imp)
imp <- variable_importance(fit, features, type = "aggregate", interaction = TRUE, oob = TRUE, parallel = TRUE)
plot_imp(imp)
imp <- variable_importance(fit, features, type = "local", oob = TRUE, parallel = TRUE)
plot_imp(imp)
imp <- variable_importance(fit, features, type = "local", interaction = TRUE, oob = TRUE, parallel = TRUE)
plot_imp(imp)

stopCluster(cl)
