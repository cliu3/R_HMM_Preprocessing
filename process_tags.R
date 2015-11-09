#install.packages("gdata")
#install.packages("R.matlab")
library(gdata)
library(R.matlab)
source("matlab_time.R")
source("datenum.R")

# raw tag directory
tagdir <- "raw_tags"
outdir <- "processed_tags"

df <- read.xls("Inventory of yellowtail DST Recaptures.xlsx",stringsAsFactors=FALSE)
#df[] <- lapply(df, as.character)

ptags <- 1:2;

for(i in ptags)
  #i <- 1
{
  
  tag <- list()
  
  tag[["datafile"]]  <- file.path(tagdir,df[i,14])
  
  source("metadata.R")
  
  
  ####
  tag[["fish_id"]]   <- df[i,1]
  tag[["tag_id"]]    <- df[i,2]
  tag[["type"]]      <- df[i,3]
  tag[["length"]]    <- df[i,10]
  tag[["sex"]]       <- df[i,11]
  tag[["maturity"]]  <- df[i,12]
  tag[["release_dnum"]] <- datenum(paste(df[i,8],df[i,9]))
  tag[["release_lon"]] <- df[i,7]
  tag[["release_lat"]] <- df[i,6]
  tag[["recapture_lon"]] <- df[i,19]
  tag[["recapture_lat"]] <- df[i,18]
  tag[["recapture_dnum"]] <- datenum(df[i,15])
  tag[["recap_uncertainty_km"]] <- df[i,21] 
  
  
  #set time-dependent fields
  if(tag[["type"]]=="STAR-ODDI"){
    tag = process_staroddi(tag)
  } else if(tag[["type"]]=="LOTEK"){
    source("process_lotek.R")
    tag = process_lotek(tag)
  } else {
    print(paste("type is",tag[["type"]]))
    print("not setup to read the type")
  }
  
  matfilename <- file.path(outdir,paste(tag$fish_id,"_raw.mat",sep=""))
  writeMat(matfilename,tag=tag)
  
}