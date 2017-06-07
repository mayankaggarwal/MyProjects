### D:\Competitions\InstacartMarketBasketAnalysis

dataFolder <- 'D:/Competitions/InstacartMarketBasketAnalysis';
files <- list.files(dataFolder);
if(length(files)>0){
  for(file in files){
    if(file.exists(file.path(dataFolder,file)))
      unzip(file.path(dataFolder,file),overwrite = TRUE,exdir = dataFolder);
  }
}
else{
  print('No files found')
}

aisle <- read.csv(file.path(dataFolder,'aisles.csv'),header=TRUE,sep=',',stringsAsFactors = FALSE);
departments <- read.csv(file.path(dataFolder,'departments.csv'),header=TRUE,sep=',',stringsAsFactors = FALSE);
order_products_prior <- read.csv(file.path(dataFolder,'order_products__prior.csv'),header=TRUE,sep=',',stringsAsFactors = FALSE);
order_products_train <- read.csv(file.path(dataFolder,'order_products__train.csv'),header=TRUE,sep=',',stringsAsFactors = FALSE);
orders <- read.csv(file.path(dataFolder,'orders.csv'),header=TRUE,sep=',',stringsAsFactors = FALSE);
products <- read.csv(file.path(dataFolder,'products.csv'),header=TRUE,sep=',',stringsAsFactors = FALSE);
sample_submission <- read.csv(file.path(dataFolder,'sample_submission.csv'),header=TRUE,sep=',',stringsAsFactors = FALSE);


orders_user3 <- subset(orders,user_id ==3)
order_products_user3 <- subset(order_products_prior,order_id %in% orders_user1$order_id)
39276 29259
### https://www.kaggle.com/frankherfert/local-validation-with-detailed-product-comparison
train_5 <- subset(order_products_train,order_id %in% c(199872, 427287, 569586, 894112, 1890016)) 

train_5 <- aggregate(product_id ~ order_id,data = train_5,paste,collapse = " ")

train_5

orders_user1
order_products_user3

colnames(order_products_prior)
colnames(order_products_train)
colnames(orders)
colnames(products)
colnames(sample_submission)

nrow(orders[orders$eval_set == 'test',])  #3214874 131209 75000
orders[orders$order_id %in% c('17','34','137','182'),]
head(sample_submission)
