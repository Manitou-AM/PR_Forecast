# Core library
library(data.table)
library(DBI)
library(odbc)


# Paths
if(Sys.info()['sysname']=="Windows"){
  if(Sys.info()['nodename']=="MAN-DATALAB02"){
    path_root="D:/02. Spare Parts Forecast/"
  }
  if(Sys.info()['nodename']=="20172067M"){
    path_root="D:/local_project/07. Spare parts forecast/"
  }
}


path_data_m3=paste0(path_root,"01. data/extract_m3/")


## Other const
if(Sys.info()['nodename']=="MAN-DATALAB02"){
  odbc_driver="ODBC Driver 11 for SQL Server"
}
if(Sys.info()['nodename']=="20172067M"){
  odbc_driver="ODBC Driver 17 for SQL Server"
}