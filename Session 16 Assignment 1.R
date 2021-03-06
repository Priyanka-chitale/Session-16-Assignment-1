library(caret)
library(glmnet)
library(mlbench)
library(psych)


getwd()
setwd("D:/acadgilds/rlecture/Dataset/Dataset/Training")
file.list.train = list.files(pattern='*.csv')
library(data.table)
train.new = do.call(rbind, lapply(file.list.train, fread))
colnames(train.new) <- c("Likes","Checkin","Interest_of_Individual","Category","D1","D2",
                  "D3","D4","D5","D6","D7","D8","D9","D10",
                  "D11","D12","D13","D14","D15","D16","D17",
                  "D18","D19","D20","D21","D22","D23","D24","D25",
                  "CC1","CC2","CC3","CC4","CC5","Base_Time","Post_Length",
                  "Post_Share_Count","Post_Promotion_Status","H_Local",
                  "Post_Published_Sunday","Post_Published_Monday","Post_Published_Tuesday",
                  "Post_Published_Wednesday","Post_Published_Thursday",
                  "Post_Published_Friday","Post_Published_Saturday",
                  "Base_Date_Time_Sunday","Base_Date_Time_Monday","Base_Date_Time_Tuesday",
                  "Base_date_time_Wednesday","Base_Date_Time_Thursday",
                  "Base_Date_Time_Friday","Base_Date_Time_Saturday","Target")

setwd("D:/acadgilds/rlecture/Dataset/Dataset/Testing")
file.list.test = list.files(pattern='*.csv')
test.new = do.call(rbind, lapply(file.list.test, fread))
colnames(test.new) <- c("Likes","Checkin","Interest_of_Individual","Category","D1","D2",
                     "D3","D4","D5","D6","D7","D8","D9","D10",
                     "D11","D12","D13","D14","D15","D16","D17",
                     "D18","D19","D20","D21","D22","D23","D24","D25",
                     "CC1","CC2","CC3","CC4","CC5","Base_Time","Post_Length",
                     "Post_Share_Count","Post_Promotion_Status","H_Local",
                     "Post_Published_Sunday","Post_Published_Monday","Post_Published_Tuesday",
                     "Post_Published_Wednesday","Post_Published_Thursday",
                     "Post_Published_Friday","Post_Published_Saturday",
                     "Base_Date_Time_Sunday","Base_Date_Time_Monday","Base_Date_Time_Tuesday",
                     "Base_date_time_Wednesday","Base_Date_Time_Thursday",
                     "Base_Date_Time_Friday","Base_Date_Time_Saturday","Target")

#custom control parameter
custom = trainControl(method = "repeatedcv",
                      number = 10,
                      repeats =5,
                      verboseIter = T)

# Linear Model / logical regression
set.seed(1234)
lm = train.new(Likes ~ .,
           data = train.new,
           methods = "lm",
           trControl = custom)
lm$results
lm
summary(lm)
plot(lm$finalModel)

# ridge Regression
set.seed(1234)
ridge = train(Likes ~ .,
              data = train.new,
              method = 'glmnet',
              tuneGrid = expand.grid(alpha = 0, lambda = seq(0.0001, 1, length = 5)),
              trControl = custom)
ridge
plot(ridge)
plot(ridge$finalModel, xvar = "lambda", label = T)
plot(ridge$finalModel, xvar = "dev", label = T)
plot(varImp(ridge, scale = T), cex = 0.5)
#names(getModelInfo())

#LASSO Regression
set.seed(1234)
lasso = train(Likes ~ .,
              data = train.new,
              method = 'glmnet',
              tuneGrid = expand.grid(alpha = 1, lambda = seq(0.0001, 2, length = 5)),
              trControl = custom)
plot(lasso)
plot(lasso$finalModel, xvar = "lambda", label = T)
plot(lasso$finalModel, xvar = "dev", label = T)
plot(varImp(lasso, scale = T), cex = 0.5)


#Elastic Net Regression
set.seed(1234)
en = train(Likes ~ .,
              data = train.new,
              method = 'glmnet',
              tuneGrid = expand.grid(alpha = seq(0,1, length = 10),
                                     lambda = seq(0.0001, 1, length = 5)),
              trControl = custom)
plot(en)
plot(en$finalModel, xvar = "lambda", label = T)
plot(en$finalModel, xvar = "dev", label = T)
plot(varImp(en), cex = 0.5)

#compare Models
model_list = list(LinearModel = lm, Rigde = ridge, LASSO = lasso, ElasticNet = en)
res = resamples(model_list)
summary(res)
bwplot(res)
xyplot(res, metric = 'RMSE')

#best model
en$bestTune
best = en$finalModel
coef(best, s = en$bestTune$lambda)

setwd("D:/acadgilds/rlecture")
saveRDS(en, "final_model.rds")
fm = readRDS("final_model.rds")
fm

#prediction
p1 = predict(fm, train.new)
sqrt(mean(train.new$Likes-p1)^2)

p2 = predict(fm, test.new)
sqrt(mean(test.new$Likes-p2)^2)
