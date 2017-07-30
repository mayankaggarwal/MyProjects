employ.data <- data.frame(
  employee=c('a','b','c'));


companies = list(4:5,7:13,1));
companies = list(c('Orange','Infy'),c('Google','Microsoft','IBM'),c('x')))
employ.data$companies <- list(c('Orange','Infy'),c('Google','Microsoft','IBM'),c('x'));
employ.data



df_real = data.frame(order_id= c(10, 11, 11, 12,12,12,12, 13,13,13,13, 14,14,14,14,14,14, 15,15,15,15,15,15,15,15, 16,16,16,16,16,16,16,16,16,16),
                     products = c("0","0","1","0","1","2","3","0","1","2","3","0","1","2","3","4","5","0","1","2","3","4","5","6","7","0","1","2","3","4","5","6","7","8","9"));

df_pred = data.frame(order_id= c(10, 11, 11, 12,12,12,12, 13,13,13,13,13,13, 14,14,14,14, 15,15,15,15,15,15,15,15,15,15,15, 16,16,16,16,16,16,16,16,16),
                     products = c("0","0","X","0","1","2","Y","0","1","2","3","4","5","0","1","2","3","0","1","2","3","4","5","6","7","8","9","X","0","1","2","3","4","5","6","7","8"));

df_real <- aggregate(products ~ order_id,data = df_real,paste,collapse=' ')
df_pred <- aggregate(products ~ order_id,data = df_pred,paste,collapse=' ')

ScoreInstacartPrediction(df_real,df_pred);
df_real
df_pred



dfcombined <- merge(df_real,df_pred,by = "order_id",suffixes = c("_real","_pred"));
dfcombined


splitfun <- function(x) tstrsplit(x,' ');

splitfun1 <- function(x,y) sum(tstrsplit(x,' ') %in% tstrsplit(y,' '));

dfcombined$realarray <- sapply(dfcombined$product_id_real,FUN = splitfun)
dfcombined$realarrayLengths <- sapply(dfcombined$realarray,FUN = length)
dfcombined$predarray <- sapply(dfcombined$product_id_pred,FUN = splitfun)
dfcombined$predarrayLengths <- sapply(dfcombined$predarray,FUN = length)
dfcombined$noOfMatchedElements <- mapply(splitfun1,dfcombined$product_id_real,dfcombined$product_id_pred)
dfcombined$realarray <- NULL;
dfcombined$predarray <- NULL;

dfcombined["precision"] <- dfcombined["noOfMatchedElements"]/dfcombined["predarrayLengths"];
dfcombined["recall"] <- dfcombined["noOfMatchedElements"]/dfcombined["realarrayLengths"];
dfcombined["F1_score"] <- 2*(dfcombined["precision"]*dfcombined["recall"])/(dfcombined["precision"]+dfcombined["recall"]);

j <- 1;
for(i in dfcombined$product_id_pred){
  dfcombined$temppredarray[j] <- splitfun1(i)
  j <- j+1;
}

typeof(dfcombined$temppredarray[3])

length(strsplit(dfcombined[3,"product_id_real"]," "))
length(strsplit(dfcombined[3,"product_id_real"],' '))

sum(tstrsplit(dfcombined$product_id_real[2],' ') %in% tstrsplit(dfcombined$product_id_pred[2],' '));


dataFolder <- 'D:/Competitions/InstacartMarketBasketAnalysis';

library(data.table)
orders <- fread(file.path(dataFolder,'orders.csv'));
products <- fread(file.path(dataFolder,'products.csv'));
order_products <- fread(file.path(dataFolder,'order_products__train.csv'));
order_products_prior <- fread(file.path(dataFolder,'order_products__prior.csv'));
aisles <- fread(file.path(dataFolder,'aisles.csv'));
departments <- fread(file.path(dataFolder,'departments.csv'));
submission <- fread(file.path(dataFolder,'sample_submission.csv'));


head(orders)
ordersmin <- subset(orders,user_id %in% c(1,2))

order_products_min <- subset(order_products,order_id %in% ordersmin$order_id)
order_products_prior_min <- subset(order_products_prior,order_id %in% ordersmin$order_id)

### actual data
userorderproduct_train <- subset(ordersmin,eval_set == "train") %>% left_join(order_products_min,by="order_id")
userorderproduct_train <- userorderproduct_train[,c("order_id","product_id","user_id")]
userorderproduct_train

userorderproduct_train_sub <- aggregate(product_id~ user_id + order_id,data = userorderproduct_train,paste,collapse=' ')
userorderproduct_train_sub 
### predicting values
userorderproduct <- subset(ordersmin,eval_set == "prior") %>% left_join((order_products_prior_min),by="order_id")
userorderproduct <- subset(userorderproduct,!is.na(days_since_prior_order))
userorderproduct <- userorderproduct[userorderproduct$reordered=="1",]


nrow(userorderproduct)
head(userorderproduct)
userorderproduct
userorderproduct <- userorderproduct[,c("user_id","product_id")];
userorderproduct <- userorderproduct %>% 
  group_by(user_id,product_id) %>% 
  summarise(n_items = n());
userorderproduct <- userorderproduct[with(userorderproduct,order(user_id,-n_items)),];
userorderproduct <- subset(userorderproduct,n_items > 3);
userorderproduct <- userorderproduct[,c("user_id","product_id")];
userorderproduct_sub <- aggregate(product_id~user_id,data = userorderproduct,paste,collapse=' ')


kable(userorderproduct_sub)
kable(userorderproduct_train)



head(submission)


ScoreInstacartPrediction <- function(readArray,predictedArray){
  dfcombined <- merge(readArray,predictedArray,by = "order_id",suffixes = c("_real","_pred"));
  
  splitProdItems <- function(x) tstrsplit(x,' ');
  splitProdItemsMatch <- function(x,y) sum(tstrsplit(x,' ') %in% tstrsplit(y,' '));
  
  dfcombined$realarray <- sapply(dfcombined$products_real,FUN = splitProdItems)
  dfcombined$realarrayLengths <- sapply(dfcombined$realarray,FUN = length)
  dfcombined$predarray <- sapply(dfcombined$products_pred,FUN = splitProdItems)
  dfcombined$predarrayLengths <- sapply(dfcombined$predarray,FUN = length)
  dfcombined$noOfMatchedElements <- mapply(splitProdItemsMatch,dfcombined$products_real,dfcombined$products_pred)
  dfcombined$realarray <- NULL;
  dfcombined$predarray <- NULL;
  
  dfcombined["precision"] <- dfcombined["noOfMatchedElements"]/dfcombined["predarrayLengths"];
  dfcombined["recall"] <- dfcombined["noOfMatchedElements"]/dfcombined["realarrayLengths"];
  dfcombined["F1_score"] <- 2*(dfcombined["precision"]*dfcombined["recall"])/(dfcombined["precision"]+dfcombined["recall"]);
  
  splitProdItems <- NULL;
  splitProdItemsMatch <- NULL;
  
  return(mean(sapply(dfcombined["F1_score"],as.numeric)));
}











