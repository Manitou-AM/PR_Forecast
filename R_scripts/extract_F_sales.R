# Extract all tables
library(DBI)
library(odbc)
library(data.table)

# sort(unique(odbcListDrivers()[[1]]))

con <- dbConnect(odbc(), 
                 Driver = "ODBC Driver 11 for SQL Server", 
                 Server = "MAN-DWHPRDDB", 
                 Database = "M3_REPORTING",
                 UID = "BO_READER",
                 PWD = "93924bnqbz")


extract_table=function(query,Rkey=NULL){
  
  rs <- dbSendQuery(con, statement = query)
  dt1=data.table(dbFetch(rs, n = 2000000))
  dt2=data.table(dbFetch(rs, n = 2000000))
  dt3=data.table(dbFetch(rs, n = 2000000))
  dt4=data.table(dbFetch(rs, n = 2000000))
  dt=rbindlist(list(dt1,dt2,dt3,dt4))
  setkeyv(dt,Rkey)
  dbClearResult(rs)
  return(dt)
  
}

F_Sales_Stat=extract_table("SELECT * FROM [M3_REPORTING].[DWH].[F_Sales_Stat]")
Dim_Facility=extract_table("select * from dwh.Dim_Facility",Rkey = "Dim_Facility_dKey")
Dim_Warehouse=extract_table("select * from dwh.Dim_Warehouse",Rkey = "Dim_Warehouse_dKey")
Dim_Customer_Delivery_Addresses=extract_table("select * from dwh.Dim_Customer_Delivery_Addresses",Rkey="Dim_Customer_Delivery_Addresses_dKey")
Dim_Customer=extract_table("select * from dwh.Dim_Customer",Rkey = "Dim_Customer_dKey")
Dim_Item=extract_table("select * from dwh.Dim_Item",Rkey="Dim_Item_dKey")
Dim_Item_Facility=extract_table("select * from dwh.Dim_Item_Facility",Rkey="Dim_Item_Facility_dKey")
Dim_Exchange_Rate=extract_table("select * from dwh.Dim_Exchange_Rate",Rkey="Dim_Exchange_Rate_dKey")
Dim_Item_Warehouse=extract_table("select * from dwh.Dim_Item_Warehouse",Rkey="Dim_Item_Warehouse_dKey")

save(F_Sales_Stat,Dim_Facility,Dim_Warehouse,Dim_Customer_Delivery_Addresses,
     Dim_Customer,Dim_Item,Dim_Item_Facility,Dim_Exchange_Rate,Dim_Item_Warehouse,
     file=paste0(path_root,path_data_m3,"raw_data.Rdata"),compress = F)

save(F_Sales_Stat,Dim_Facility,Dim_Warehouse,Dim_Customer_Delivery_Addresses,
     Dim_Customer,Dim_Item,Dim_Item_Facility,Dim_Exchange_Rate,Dim_Item_Warehouse,
     file=paste0(path_root,path_data_m3,"raw_data.Rdata"),compress = F)

