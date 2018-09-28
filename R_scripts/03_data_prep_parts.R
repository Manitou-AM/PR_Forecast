################################
######### SPARE PARTS SALES
################################
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
F_Sales_stat[,Invoice_Date:=as.Date(Invoice_Date)]

# dt_dy=F_Sales_stat[(is_parts),.(Invoice_Quantity=sum(Invoice_Quantity)),by=.(Invoice_Date,Product_group_name)]
# 
# dcast_dy=dcast(dt_dy,Invoice_Date~Product_group_name,value.var="Invoice_Quantity")
# dt_dy[Product_group=="B053"]
# 
# dygraph(dt_dy[Product_group=="B053"][,.(Invoice_Date,Invoice_Quantity)])
# dygraph(dcast_dy[Invoice_Date>"2018-05-01"])
plotdy=function(dt,col_date,metrique,title=""){
  
  
  dt_dy=dt[,.(get(metrique)),by=.(get(col_date))]
  setnames(dt_dy,c(col_date,metrique))
  d=dygraph(dt)%>%
    dyOptions(drawPoints = TRUE, pointSize = 2)%>%
    dyRangeSelector()
  
  return(d)
}



