### D:\Competitions\InstacartMarketBasketAnalysis

### reading files
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

library(data.table)
orders <- fread(file.path(dataFolder,'orders.csv'));
products <- fread(file.path(dataFolder,'products.csv'));
order_products <- fread(file.path(dataFolder,'order_products__train.csv'));
order_products_prior <- fread(file.path(dataFolder,'order_products__prior.csv'));
aisles <- fread(file.path(dataFolder,'aisles.csv'));
departments <- fread(file.path(dataFolder,'departments.csv'));

### basic data descriptions
library(knitr)
kable(head(orders))
kable(head(products))
kable(head(order_products))
kable(head(order_products_prior))
kable(head(aisles))
kable(head(departments))
glimpse(orders)
glimpse(products)
glimpse(order_products)
glimpse(order_products_prior)
glimpse(aisles)
glimpse(departments)

###
library(dplyr)
orders <- orders %>% mutate(eval_set = as.factor(eval_set)
                            ,order_hour_of_day = as.numeric(order_hour_of_day));
products <- products %>% mutate(product_name = as.factor(product_name));
aisles <- aisles %>% mutate(aisle = as.factor(aisle));
departments <- departments %>% mutate(department = as.factor(department));

### basic patterns
library(ggplot2)
orders %>% ggplot(aes(x=order_hour_of_day)) + geom_histogram(stat="count",fill="red");
orders %>% ggplot(aes(x=order_dow)) + geom_histogram(stat="count",fill="red");
orders %>% ggplot(aes(x=days_since_prior_order)) + geom_histogram(stat="count",fill="red");
orders %>% filter(eval_set=="prior") %>% count(order_number) %>% ggplot(aes(order_number,n)) + geom_line(color="red",size=1) + geom_point(color="blue",size=2)
order_products %>% group_by(order_id) %>% summarise(n_items = n()) %>% ggplot(aes(x=n_items)) + geom_histogram(stat="count",fill="red") + geom_rug() + coord_cartesian(xlim = c(0,80))

### Bestsellers
tmp <- order_products %>% 
  group_by(product_id) %>% summarise(count = n()) %>% top_n(10,wt=count) %>%
  left_join(select(products,product_id,product_name),by="product_id") %>%
  arrange(desc(count));

kable(tmp);

tmp %>% 
  ggplot(aes(x=reorder(product_name,-count), y=count)) + 
  geom_bar(stat="identity") + 
  theme(axis.text.x = element_text(angle=90,hjust=1),axis.title.x = element_blank())


### my sample submission
head();
nrow(orders) 
nrow(order_products)
nrow(order_products_prior)

order_products_comb <- rbind(order_products[,c("order_id","product_id","reordered")],order_products_prior[,c("order_id","product_id","reordered")]) %>%
   left_join(orders[,c("order_id","user_id","days_since_prior_order")],by="order_id");
head(order_products_comb)
nrow(order_products_comb)

order_products_comb <- subset(order_products_comb,!is.na(days_since_prior_order) & reordered=="1")

order_products_comb <- order_products_comb[,c("user_id","product_id")];
order_products_comb <- order_products_comb %>% 
  group_by(user_id,product_id) %>% 
  summarise(n_items = n());
order_products_comb <- order_products_comb[with(order_products_comb,order(user_id,-n_items)),];
order_products_comb <- subset(order_products_comb,n_items > 3);
order_products_comb <- order_products_comb[,c("user_id","product_id")];
order_products_comb <- aggregate(product_id~user_id,data = order_products_comb,paste,collapse=' ')

order_products_submit <- subset(orders,eval_set=="test");
order_products_submit <- order_products_submit[,c("order_id","user_id")];

order_products_submit <- order_products_submit %>% left_join(order_products_comb,by="user_id")

nrow(order_products_submit)
order_products_submit <- order_products_submit[,c("order_id","product_id")];
colnames(order_products_submit) <- c("order_id","products"); 
fwrite(order_products_submit,file.path(dataFolder,"mySubmission1.csv"));










