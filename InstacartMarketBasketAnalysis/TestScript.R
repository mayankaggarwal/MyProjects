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

order_user1 <- orders[orders$user_id==1,c('order_id')]
order_products_prior[order_products_prior$order_id %in% order_user1,]