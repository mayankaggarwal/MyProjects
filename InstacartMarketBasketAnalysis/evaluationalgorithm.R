
df_real = data.frame(order_id= c(10, 11, 11, 12,12,12,12, 13,13,13,13, 14,14,14,14,14,14, 15,15,15,15,15,15,15,15, 16,16,16,16,16,16,16,16,16,16),
                     products = c("0","0","1","0","1","2","3","0","1","2","3","0","1","2","3","4","5","0","1","2","3","4","5","6","7","0","1","2","3","4","5","6","7","8","9"));

df_pred = data.frame(order_id= c(10, 11, 11, 12,12,12,12, 13,13,13,13,13,13, 14,14,14,14, 15,15,15,15,15,15,15,15,15,15,15, 16,16,16,16,16,16,16,16,16),
                     products = c("0","0","X","0","1","2","Y","0","1","2","3","4","5","0","1","2","3","0","1","2","3","4","5","6","7","8","9","X","0","1","2","3","4","5","6","7","8"));

df_real <- aggregate(products ~ order_id,data = df_real,paste,collapse=' ')
df_pred <- aggregate(products ~ order_id,data = df_pred,paste,collapse=' ')

ScoreInstacartPrediction(df_real,df_pred);

tempdf <- data.frame(m=c(1,1,1,1,1,1,2,2,2,2,3,3),
                     a=c(10,10,10,10,20,20,20,20,20,30,10,10),
                     b=c(0,15,21,29,28,19,2,4,7,1,40,50));

tempdf$explore <- ave(tempdf$b, tempdf$m+tempdf$a, FUN=cumsum);

tempdf %>% group_by(m,a) %>% summarise(averagelife = mean(b));



ordersmin <- subset(orders,user_id %in% c(1:100))
order_products_min <- subset(order_products,order_id %in% 
                               ordersmin$order_id)
order_products_prior_min <- subset(order_products_prior,order_id %in% 
                                     ordersmin$order_id)

head(ordersmin,20);
head(order_products_min);
head(order_products_prior);

  #### New approach
  ordersmin$days_since_prior_order[is.na(ordersmin$days_since_prior_order)] <- 0;
  ordersmin <- arrange(ordersmin,user_id,order_number);
  ordersmin$dspo_cum <- ave(ordersmin$days_since_prior_order,
                            ordersmin$user_id,FUN = cumsum);


### actual data
userorderproduct_train <- subset(ordersmin,eval_set == "train") %>% 
  inner_join(order_products_min,by="order_id")
userorderproduct_train <- userorderproduct_train[,c("order_id",
                                                    "product_id",
                                                    "user_id",
                                                    "order_dow",
                                                    "order_hour_of_day",
                                                    "days_since_prior_order")];
userorderproduct_train_sub <- aggregate(product_id~ user_id + order_id,
                                        data = userorderproduct_train,
                                        paste,collapse=' ')

userorderproduct_train_sub 
kable(head(userorderproduct_train,15));
nrow(userorderproduct_train)

  ###
  
### predicting values
userorderproduct <- subset(ordersmin,eval_set == "prior") %>% 
  left_join((order_products_prior_min),by="order_id")

  #### New approach
  userorderproduct <- userorderproduct[,c("product_id",
                                          "user_id",
                                          "order_dow",
                                          "order_hour_of_day",
                                          "days_since_prior_order",
                                          "order_number","dspo_cum")];
  userorderproduct <- arrange(userorderproduct,
                              user_id,
                              product_id,
                              order_number);
  userorderproduct$days_since_prior_order[is.na(userorderproduct$days_since_prior_order)] <- 0;
  
  
  #userorderproduct$dspo_product <- ave(userorderproduct$days_since_prior_order, userorderproduct$order_number+userorderproduct$user_id, FUN=cumsum);
  
  userorderproduct$dspo_product <- ave(userorderproduct$dspo_cum,
                                       userorderproduct$user_id + userorderproduct$product_id,
                                       FUN=function(x) c(0, diff(x)))
  
  
  userorderproduct[userorderproduct$product_id %in% c(13032,25133,196),]
  userorderproduct1 <- userorderproduct %>%
    group_by(user_id,product_id) %>%
    summarise(dspo_max = max(dspo_product),
              dspo_min = min(dspo_product[dspo_product>0]),
              max_order_no = max(order_number),
              dspo_mean = mean(dspo_product[dspo_product>0]),
              noOfdspoZeros = sum(dspo_product==0),
              noOfOrders = n());
  
  userorderproduct1$dspo_min[is.infinite(userorderproduct1$dspo_min)]<-0;
  userorderproduct1$dspo_mean[is.nan(userorderproduct1$dspo_mean)]<-0;
  
userorderproduct <- subset(userorderproduct,!is.na(days_since_prior_order))
userorderproduct <- userorderproduct[userorderproduct$reordered=="1",]

kable(head(userorderproduct,15));
kable(head(userorderproduct1,20));
nrow(userorderproduct)
userorderproduct

userorderproduct <- userorderproduct[,c("user_id","product_id")];
userorderproduct <- userorderproduct %>% 
  group_by(user_id,product_id) %>% 
  summarise(n_items = n());
userorderproduct <- userorderproduct[with(userorderproduct,order(user_id,-n_items)),];
userorderproduct <- subset(userorderproduct,n_items >= 0);
userorderproduct <- userorderproduct[,c("user_id","product_id")];
userorderproduct <- aggregate(product_id~user_id,data = userorderproduct,paste,collapse=' ')

  #new approach
  userorderproduct1 <- subset(userorderproduct1,noOfOrders > 1 | max_order_no > 8);
  userorderproduct <- userorderproduct1[,c("user_id","product_id")];
  userorderproduct <- aggregate(product_id~user_id,data = userorderproduct,paste,collapse=' ')
  
### calculating predicting values for 2 users
userorderproduct_train_submit <- distinct(userorderproduct_train[,c("order_id","user_id")]);
userorderproduct_train_submit <- userorderproduct_train_submit %>% left_join(userorderproduct,by="user_id")

userorderproduct_train_submit

userorderproduct_train_submit <- userorderproduct_train_submit[,c("order_id","product_id")];
colnames(userorderproduct_train_submit) <- c("order_id","products");
head(userorderproduct_train_submit)
nrow(userorderproduct_train_submit)

###identifying actual values
userorderproduct_train_actual <- userorderproduct_train[,c("order_id","product_id")];
userorderproduct_train_actual <- aggregate(product_id~order_id,data=userorderproduct_train_actual,paste,collapse=' ');
colnames(userorderproduct_train_actual) <- c("order_id","products");
userorderproduct_train_actual

realArray <- userorderproduct_train_actual;
  predictedArray <- userorderproduct_train_submit;
###Checking F1 Score
ScoreInstacartPrediction(userorderproduct_train_actual,userorderproduct_train_submit);

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
head(dfcombined)

ScoreInstacartPrediction <- function(realArray,predictedArray){
  dfcombined <- merge(realArray,predictedArray,by = "order_id",suffixes = c("_real","_pred"));
  
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
  dfcombined$F1_score[is.nan(dfcombined$F1_score)]<-0;
  return(mean(sapply(dfcombined["F1_score"],as.numeric)));
}











