## you must use the development versions of the following packages (github username/package)
##
##  - berndbischl/ParamHelpers
##  - berndbischl/BBmisc
##  - berndbischl/parallelMap (optional if you comment out the appropriate lines)
##  - mlr-org/mlr
##
## you can install these with devtools. e.g., devtools::install_github(c("berndbischl/ParamHelpers"))
## you need the following packages from CRAN
##
##  - numDeriv
##  - kernlab
##  - rpart
##  - party
##  - MASS

library(mlr)
library(parallelMap)
parallelStart("socket", cpus = 6)

## classification example
data(iris)
multiclass.task <- makeClassifTask(id = "iris", data = iris, target = "Species")
lrn <- makeLearner("classif.ksvm", predict.type = "prob")
fit <- train(lrn, multiclass.task)
rdesc <- makeResampleDesc("CV", iters = 10L)
pred <- resample(lrn, multiclass.task, rdesc, mmce)
ps <- makeParamSet(
  makeNumericParam("C", lower = -12, upper = 12, trafo = function(x) 2^x),
  makeNumericParam("sigma", lower = -12, upper = 12, trafo = function(x) 2^x)
)
ctrl <- makeTuneControlGrid(resolution = 3L)
res <- tuneParams(lrn, task = multiclass.task, resampling = rdesc, par.set = ps, control = ctrl)
lrn <- setHyperPars(lrn, par.vals = res$x)
fit <- train(lrn, multiclass.task)

fv <- generateFilterValuesData(multiclass.task, "cforest.importance", mtry = 3)
plotFilterValues(fv)
features <- tail(fv$data$name[order(fv$data$cforest.importance)], 2)
fv <- generateFilterValuesData(multiclass.task, "permutation.importance",
                               learner = "classif.rpart",
                               contrast = function(x, y) mean(x - y),
                               measure = mmce, nperm = 100L)

pd <- generatePartialPredictionData(fit, multiclass.task, features)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, multiclass.task, features, interaction = TRUE)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, multiclass.task, features, derivative = TRUE)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, multiclass.task, features, individual = TRUE)
plotPartialPrediction(pd)

minvals <- lapply(features, function(x) min(iris[[x]]))
names(minvals) <- features
pd <- generatePartialPredictionData(fit, multiclass.task, features, individual = TRUE,
                                    center = minvals)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, multiclass.task, features, individual = TRUE, derivative = TRUE)
plotPartialPrediction(pd)

## regression example
data(Boston, package = "MASS")
regr.task <- makeRegrTask("bh", data = Boston, target = "medv")
lrn <- makeLearner("regr.ksvm")
fit <- train(lrn, regr.task)
pred <- resample(lrn, regr.task, rdesc, rmse)
res <- tuneParams(lrn, task = regr.task, resampling = rdesc, par.set = ps, control = ctrl)
lrn <- setHyperPars(lrn, par.vals = res$x)
fit <- train(lrn, regr.task)

fv <- generateFilterValuesData(regr.task, "cforest.importance")
plotFilterValues(fv)
features <- tail(fv$data$name[order(fv$data$cforest.importance)], 2)

pd <- generatePartialPredictionData(fit, regr.task, features)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, regr.task, features, interaction = TRUE)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, regr.task, features, derivative = TRUE)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, regr.task, features, individual = TRUE)
plotPartialPrediction(pd)

minvals <- lapply(features, function(x) min(Boston[[x]]))
names(minvals) <- features
pd <- generatePartialPredictionData(fit, regr.task, features, individual = TRUE, center = minvals)
plotPartialPrediction(pd)
pd <- generatePartialPredictionData(fit, regr.task, features, individual = TRUE, derivative = TRUE)
plotPartialPrediction(pd)

parallelStop()
