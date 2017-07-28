### D:\Competitions\InstacartMarketBasketAnalysis

dataFolder <- 'D:/Competitions/InstacartMarketBasketAnalysis';
files <- list.files(dataFolder);

if(length(files)>0){
  for(file in files){
    if(file.exists(file.path(dataFolder,file)))
      unzip(file.path(dataFolder,file),overwrite = TRUE,exdir = dataFolder);
  }
} else{
  print('No files found')
};

orders <- fread(file.path(dataFolder,'orders.csv'));
                
products <- fread(file.path(dataFolder,'products.csv'));
order_products <- fread(file.path(dataFolder,'order_products__train.csv'));
order_products_prior <- fread(file.path(dataFolder,'order_products__prior.csv'));
aisles <- fread(file.path(dataFolder,'aisles.csv'));
departments <- fread(file.path(dataFolder,'departments.csv'));

