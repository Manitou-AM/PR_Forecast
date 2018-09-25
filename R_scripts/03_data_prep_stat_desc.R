# Load data
F_Sales_stat=fread(paste0(path_data_m3,"F_Sales_Stat.csv"))
Dim_Item=fread(paste0(path_data_m3,"Dim_Item.csv"))
product_group_parts=fread(paste0(path_root,"01. Data/product_group_parts.csv"))


# Filter on Columns of interest
columns_of_interest=c("Dim_Customer_dKey",
                      "Dim_Item_dKey","Item_Number",
                      "Dim_Customer_Delivery_Addresses_dKey","Invoice_Date","Invoice_Quantity")
F_Sales_stat=F_Sales_stat[,..columns_of_interest]

#Join Item information
setkey(F_Sales_stat,Dim_Item_dKey)
setkey(Dim_Item,Dim_Item_dKey)
stats=map(names(Dim_Item),function(x) .Nby(Dim_Item,col = x))
F_Sales_stat[Dim_Item,Item_name:=i.Item_name]
F_Sales_stat[Dim_Item,Item_number_b:=i.Item_number]
F_Sales_stat[Dim_Item,Item_description:=i.Item_description]
F_Sales_stat[Dim_Item,Item_group:=i.Item_group]
F_Sales_stat[Dim_Item,Item_group_name:=i.Item_group_name]
F_Sales_stat[Dim_Item,Item_group_description:=i.Item_group_description]
F_Sales_stat[Dim_Item,Product_group:=i.Product_group]
F_Sales_stat[Dim_Item,Product_group_name:=i.Product_group_name]
F_Sales_stat[Dim_Item,Product_group_description:=i.Product_group_description]
F_Sales_stat[,is_parts:=Product_group%in%product_group_parts$Product_group_parts]
# map(F_Sales_stat
