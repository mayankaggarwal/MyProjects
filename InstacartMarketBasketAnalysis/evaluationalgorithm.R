employ.data <- data.frame(
  employee=c('a','b','c'));
companies = list(4:5,7:13,1));
companies = list(c('Orange','Infy'),c('Google','Microsoft','IBM'),c('x')))
employ.data$companies <- list(c('Orange','Infy'),c('Google','Microsoft','IBM'),c('x'));
employ.data



df_real = data.frame(order_id= c(10, 11, 11, 12,12,12,12, 13,13,13,13, 14,14,14,14,14,14, 15,15,15,15,15,15,15,15, 16,16,16,16,16,16,16,16,16,16),
                     product_id = c("0","0","1","0","1","2","3","0","1","2","3","0","1","2","3","4","5","0","1","2","3","4","5","6","7","0","1","2","3","4","5","6","7","8","9"));

df_pred = data.frame(order_id= c(10, 11, 11, 12,12,12,12, 13,13,13,13,13,13, 14,14,14,14, 15,15,15,15,15,15,15,15,15,15,15, 16,16,16,16,16,16,16,16,16),
                     product_id = c("0","0","X","0","1","2","Y","0","1","2","3","4","5","0","1","2","3","0","1","2","3","4","5","6","7","8","9","X","0","1","2","3","4","5","6","7","8"));

df_real <- aggregate(product_id ~ order_id,data = df_real,paste,collapse=' ')
df_pred <- aggregate(product_id ~ order_id,data = df_pred,paste,collapse=' ')

dfcombined <- merge(df_real,df_pred,by = "order_id",suffixes = c("_real","_pred"));
dfcombined
dfcombined["realarray"] <- strsplit(dfcombined$product_id_real,' ');
apply(dfcombined,2,FUN = strsplit(dfcombined$product_id_real,' '));
sapply(strsplit(dfcombined$product_id_real,' '))

strsplit(dfcombined$product_id_real,' ')

splitfun <- function(x) strsplit(x,' ');

splitfun('0 1 2 3 4 5')