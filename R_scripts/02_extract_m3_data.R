# Extract all tables
library(DBI)
library(odbc)
library(data.table)

sort(unique(odbcListDrivers()[[1]]))

con_v13 <- dbConnect(odbc(), 
                 Driver = odbc_driver, 
                 Server = "MAN-DWHPRDDB", 
                 Database = "M3_REPORTING",
                 UID = "BO_READER",
                 PWD = "93924bnqbz")
con_v10 <- dbConnect(odbc(), 
                     Driver = odbc_driver, 
                     Server = "MAN-DWHPRDDB", 
                     Database = "M3_REPORTING",
                     UID = "BO_READER",
                     PWD = "93924bnqbz")

extract_table=function(query,Rkey=NULL,save_csv=F,save_path=path_data_m3,save_file="m3_data_"){
  
  rs <- dbSendQuery(con, statement = query)
  dt1=data.table(dbFetch(rs, n = 2000000))
  dt2=data.table(dbFetch(rs, n = 2000000))
  dt3=data.table(dbFetch(rs, n = 2000000))
  dt4=data.table(dbFetch(rs, n = 2000000))
  dt=rbindlist(list(dt1,dt2,dt3,dt4))
  setkeyv(dt,Rkey)
  dbClearResult(rs)
  
  if(save_csv){
    fwrite(dt,file=paste0(save_path,save_file),row.names = F,sep="|")
  }
  
  return(dt)
  
}

F_Sales_Stat=extract_table("SELECT * FROM [M3_REPORTING].[DWH].[F_Sales_Stat]",
                           save_csv = T,save_file ="F_Sales_Stat.csv")

Dim_Facility=extract_table("select * from dwh.Dim_Facility",Rkey = "Dim_Facility_dKey",
                             save_csv=T,save_file="Dim_Facility.csv")

Dim_Warehouse=extract_table("select * from dwh.Dim_Warehouse",Rkey = "Dim_Warehouse_dKey",
                            save_csv=T,save_file="Dim_Warehouse.csv")

Dim_Customer_Delivery_Addresses=extract_table("select * from dwh.Dim_Customer_Delivery_Addresses",Rkey="Dim_Customer_Delivery_Addresses_dKey",
                                              save_csv=T,save_file="Dim_Customer_Delivery_Addresses.csv")

Dim_Customer=extract_table("select * from dwh.Dim_Customer",Rkey = "Dim_Customer_dKey",
                           save_csv=T,save_file="Dim_Customer.csv")

Dim_Item=extract_table("select * from dwh.Dim_Item",Rkey="Dim_Item_dKey",
                       save_csv=T,save_file = "Dim_Item.csv")

Dim_Item_Facility=extract_table("select * from dwh.Dim_Item_Facility",Rkey="Dim_Item_Facility_dKey",
                                save_csv=T,save_file="Dim_Item_Facility.csv")

Dim_Exchange_Rate=extract_table("select * from dwh.Dim_Exchange_Rate",Rkey="Dim_Exchange_Rate_dKey",
                                save_csv=T,save_file="Dim_Exchange_Rate.csv")

Dim_Item_Warehouse=extract_table("select * from dwh.Dim_Item_Warehouse",Rkey="Dim_Item_Warehouse_dKey",
                                 save_csv=T,save_file="Dim_Item_Warehouse.csv")

Dim_Serial_Item=extract_table("select * from dwh.dim_serial_item",
                                 save_csv=T,save_file="Dim_Serial_Item.csv")



save(F_Sales_Stat,Dim_Facility,Dim_Warehouse,Dim_Customer_Delivery_Addresses,
     Dim_Customer,Dim_Item,Dim_Item_Facility,Dim_Exchange_Rate,Dim_Item_Warehouse,
     file=paste0(path_data_m3,"raw_data_compress.Rdata"),compress = T)

