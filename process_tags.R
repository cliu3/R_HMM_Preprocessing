#install.packages("gdata")
#install.packages("R.matlab")
#install.packages("zoo")
library(gdata)
library(R.matlab)
library(zoo)
source("matlab_time.R")
source("datenum.R")

# raw tag directory
tagdir <- "raw_tag_data"
outdir <- "processed_tags"

df <- read.xls("Inventory of non-SCCZ cod DSTs_2-18-16.xlsx",stringsAsFactors=FALSE)
#df[] <- lapply(df, as.character)

ptags <- 101:105;

for(i in ptags)
  #i <- 1
{
  i = which(df[,"FISH.ID.."]==i)
  tag <- list()
  
  tag[["datafile"]]  <- file.path(tagdir, df[i, "TAG.FILE"])
  
  source("metadata.R")
  
  
  ####
  tag[["fish_id"]]   <- df[i,"FISH.ID.."]
  tag[["tag_id"]]    <- df[i,"DST.."]
  tag[["type"]]      <- df[i,"DST.TYPE"]
  tag[["length"]]    <- df[i,"TAG_LONG"]
  tag[["sex"]]       <- df[i,"SEX"]
  tag[["maturity"]]  <- df[i,"MATURITY"]
  tag[["release_dnum"]] <- datenum(paste(df[i,"DATE.TAGGED"],df[i,"RELEASE.TIME."]))
  tag[["release_lon"]] <- df[i,"TAG_LONG"]
  tag[["release_lat"]] <- df[i,"TAG_LAT"]
  tag[["recapture_lon"]] <- df[i,"RECAP_LONG"]
  tag[["recapture_lat"]] <- df[i,"RECAP_LAT"]
  tag[["recapture_dnum"]] <- datenum(df[i,"DATE.RECAPTURED"])
  tag[["recap_uncertainty_km"]] <- df[i,"RECAP.UNCERTAINTY_DISTANCE..Km."] 
  
  
  #set time-dependent fields
  if(tag[["type"]]=="STAR-ODDI"){
    source("process_staroddi.R")
    tag = process_staroddi(tag)
  } else if(tag[["type"]]=="LOTEK"){
    source("process_lotek.R")
    tag = process_lotek(tag)
  } else {
    print(paste("type is", tag[["type"]]))
    print("not setup to read the type")
  }
  
  matfilename <- file.path(outdir, paste(tag$fish_id,"_raw.mat",sep=""))
  writeMat(matfilename, tag=tag)
  
}