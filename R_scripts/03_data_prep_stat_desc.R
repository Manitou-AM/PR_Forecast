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


################################
######### MACHINES SALES
################################

Dim_Serial_Item=fread(paste0(path_data_m3,"Dim_Serial_Item.csv"))
Dim_Customer=fread(paste0(path_data_m3,"Dim_Customer.csv"))
Dim_Customer[]
machine_count=Dim_Serial_Item[,.N,by=Equipment_description][order(Equipment_description)]

Dim_Serial_Item[,.N,by=is.na(Customer)]
Dim_Serial_Item[,Customer:=as.character(Customer)]
setkey(Dim_Serial_Item,Customer)
setkey(Dim_Customer,Customer)
Dim_Serial_Item[Dim_Customer,Country:=i.Country]
Dim_Serial_Item[Dim_Customer,Country_Description:=i.Country_Description]
Dim_Serial_Item[,Invoice_Date_b:=as.Date(Invoice_Date,"%Y-%m-%d")]
evol_by_Country=Dim_Serial_Item[,.N,by=.(Country_Description,year=format(Invoice_Date_b,"%Y"))][order(Country_Description,year)]
cb(evol_by_Country)

evol_by_Country[,pct_country:=N/sum(N),by=year]
dyg_dt_evol_country=dcast(evol_by_Country,year~Country_Description,value.var="pct_country")
dyg_dt_evol_country=dcast(evol_by_Country,year~Country_Description,value.var="N")
dyg_dt_evol_country[,year:=as.Date(year,"%Y")]
dyg_dt_evol_country[year>"1980-01-01"]

names(dyg_dt_evol_country)%in%evol_by_Country[,.(N=sum(N)),by=Country_Description][order(-N)]$Country_Description
evol_by_Country[,.(N=sum(N)),by=Country_Description][order(-N)]$Country_Description%in%names(dyg_dt_evol_country)

setorderv(dyg_dt_evol_country,c("year",evol_by_Country[,.(N=sum(N)),by=Country_Description][order(-N)]$Country_Description))

dygraph(dyg_dt_evol_country[year>"1980-01-01"])%>%
  dyRangeSelector()%>%
  dyLegend(show = "onmouseover",showZeroValues = F)


# ASsist ticket : 
tickets_raw=fread(paste0(path_data_assist,"ASSIST_MDL_ISSUES.csv"),encoding = "UTF-8")
tickets_raw[,type_ticket:=substr(ASSIST_TICKET,1,1)]
tickets_raw[,ASSIST_SUBMIT_DATE:=as.Date(ASSIST_SUBMIT_DATE,format="%d/%m/%Y")]
tickets_raw=tickets_raw[type_ticket%in%c("I","S")]
tickets_raw=tickets_raw[,last_submit_date:=max(ASSIST_SUBMIT_DATE),by=.(ASSIST_SERIAL_NUMBER)]
tickets_raw=tickets_raw[ASSIST_SUBMIT_DATE==last_submit_date]
tickets_raw=tickets_raw[,.(ASSIST_TICKET,ASSIST_SUBMIT_DATE,ASSIST_MODEL,ASSIST_PART_REFERENCE,type_ticket,
                           ASSIST_STARTUP_DATE,ASSIST_LOCATION_EN,ASSIST_DEPARTMENT_EN,ASSIST_SERIAL_NUMBER,ASSIST_SERIAL_NUMBER2)]
tickets_raw[,ASSIST_SERIAL_NUMBER2:=as.character(ASSIST_SERIAL_NUMBER2)]


split_column=function(dt,col,nb_col_split){
  for(i in (1:nb_col_split)){
    dt[,paste0(col,"_",i):=tstrsplit(get(col),"/",keep = i)]  
  }
}
split_column(tickets_raw,"ASSIST_DEPARTMENT_EN",4)
split_column(tickets_raw,"ASSIST_LOCATION_EN",4)
library(networkD3)
sankey_prepare_dt_3=function(dt,columns=c("PR_LOCATION_1","PR_LOCATION_2","PR_LOCATION_3"),
                             prefixes=c("c1_","c2_","c3_"),removeNAs=F,minN=0){
  
  levels=length(columns)-1
  links=rbindlist(map(1:levels,function(x){
    res=dt[,.N,by=.(source=get(columns[x]),target=get(columns[x+1]))][order(source,target)]
    if(removeNAs){
      res=res[!is.na(source) & !is.na(target)]
    }
    res[,source:=paste0(prefixes[x],source)]
    res[,target:=paste0(prefixes[x+1],target)]
  }))
  
  links=links[N>minN]
  nodes=rbind(links[,.(names=source)],links[,.(names=target)])
  nodes=nodes[order(names),.(names=unique(names))]
  nodes[,pos:=1:.N-1]
  nodes=nodes[order(pos)]
  
  setkey(links,source)
  setkey(nodes,names)
  links[nodes,int_source:=i.pos]
  setkey(links,target)
  links[nodes,int_target:=i.pos][]
  
  # forceNetwork(Links = links, Nodes = nodes, Source = 'int_source', Target = 'int_target',
  #              Value = 'N', NodeID = 'names', Group = 'pos', zoom = TRUE)
  
  sk=sankeyNetwork(Links=links,Nodes=nodes,
                   Source = "int_source",Target = "int_target",Value="N",
                   NodeID = "names",sinksRight = F,
                   units = " tickets",fontSize = 12, nodeWidth = 30)
  print(sk)
  return(links)
}
sankey_prepare_dt_3(tickets_raw,c("type_ticket","ASSIST_DEPARTMENT_EN_1","ASSIST_DEPARTMENT_EN_2"))

setkey(tickets_raw,ASSIST_SERIAL_NUMBER)
setkey(Dim_Serial_Item,Serial_number)
Dim_Serial_Item[tickets_raw,location_1:=ASSIST_DEPARTMENT_EN_2]
Dim_Serial_Item[tickets_raw,ASSIST_SUBMIT_DATE:=ASSIST_SUBMIT_DATE]
# setkey(Dim_Serial_Item,Manufacturer_Serial_Number)
# Dim_Serial_Item[tickets_raw,location_2:=ASSIST_DEPARTMENT_EN_2]
# setkey(tickets_raw,ASSIST_SERIAL_NUMBER2)
# setkey(Dim_Serial_Item,Serial_number)
# Dim_Serial_Item[tickets_raw,location_3:=ASSIST_DEPARTMENT_EN_2]
# setkey(Dim_Serial_Item,Manufacturer_Serial_Number)
# Dim_Serial_Item[tickets_raw,location_4:=ASSIST_DEPARTMENT_EN_2]
sankey_prepare_dt_3(Dim_Serial_Item,c("Country","location_1","location_3","location_4"),removeNAs = F,minN = 50)
sankey_prepare_dt_3(Dim_Serial_Item,c("Country","location_1"),removeNAs = T,minN = 25)
sankey_prepare_dt_3(Dim_Serial_Item[grep("mrt",tolower(Equipment_description))],c("Country","location_1"),removeNAs = F,minN = 2)
Dim_Serial_Item[,diff_date_assist:=as.integer(ASSIST_SUBMIT_DATE-Invoice_Date_b)]
Dim_Serial_Item[,diff_date_assist_rounded:=as.integer(diff_date_assist/(365*2))]
sankey_prepare_dt_3(Dim_Serial_Item[diff_date_assist_rounded>4],c("Country","location_1"),removeNAs = T,minN=10)



