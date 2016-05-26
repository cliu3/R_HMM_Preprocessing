process_staroddi = function(tag) {
# Read raw tag data and generate a Matlab file containing all information 
#
# tag = process_staroddi(tag)
#
# DESCRIPTION:
#    Read raw tag data and dump to matlab file for tag
#
# INPUT 
#   tag  = tag metadata in R list datatype  
#   
#
# OUTPUT:
#   matlab file containing tag data + metadata in standardized format 
#   where time series are standardized to GMT.
#
# EXAMPLE USAGE
#    tag = process_staroddi(tag) 
#
# Author(s):  
#    Chang Liu (University of Massachusetts Dartmouth)  
#    based on a Matlab code authored by Geoff Cowles
  
  # set parameters
  depth_cutoff <- 4.  #time series doesn't start until depth exceeds this value
  #time series ends last time depth is less than this value
  #this is used to trim data from the tag where the fish 
  #is not in the water
  
  print(paste("Processing tag #", tag[["fish_id"]], "..."))
  # make sure the tagfile exists
  if(file.exists(tag[["datafile"]])){
    
    nheader <- 14 # number of lines to skip
    mydata = read.table(tag[["datafile"]],skip=nheader,header=FALSE)
    
    datetime = as.POSIXct(paste(mydata[,2], mydata[,3]),format = "%d.%m.%y %H:%M:%S")
    # deal with decimal comma
    temp <- as.numeric(sub(",", ".", mydata[,4], fixed = TRUE)) 
    depth <- as.numeric(sub(",", ".", mydata[,5], fixed = TRUE)) 
    

    
    # spline interpolate missing values if necessary
    if(any(is.na(temp))){
      cz = temp
      temp = na.spline(cz)
    }
    if(any(is.na(depth))){
      cz = depth
      depth = na.spline(cz)
    }
    
    # convert time to Matlab/GMT
    ntimes <- length(datetime)
    
    tag[["process_date"]] <- strftime(Sys.time())

    if(tag[["tzone"]]=="UTC"){
      time_shift_hrs <- 0.0
    } else if(tag[["tzone"]]=="EDT"){
      time_shift_hrs <- 4.0
    } else if(tag[["tzone"]]=="EST"){
      time_shift_hrs <- 5.0
    } else {
      print(paste("tag time zone is",tag[["tzone"]]))
      print("not setup to shift from that time zone")
    }
    
    dnum = POSIXt2matlab(datetime) + time_shift_hrs/24.
    tag[["release_dnum"]] <- tag[["release_dnum"]] + time_shift_hrs/24.
    tag[["recapture_dnum"]] <- tag[["recapture_dnum"]] + time_shift_hrs/24.
    print(paste("Logged fish release time: ",matlab2POS(tag[["release_dnum"]])))
    print(paste("Logged fish recapture date: ",matlab2POS(tag[["recapture_dnum"]])))
    
    print(paste("tag turned on at",matlab2POS(dnum[1])))
    
    # trim the tag to have data from only when fish is in the water
    if (0.5*(min(depth)+max(depth))<0) {depth=-depth}
    
    tag[["dnum_raw"]] <- dnum
    tag[["temp_raw"]] <- temp
    tag[["depth_raw"]] <- depth
    
    # use rle to refine the range of "good" signal, by choosing the longest series where depth is greater than the cut_off 
    # code from Stackoverflow question: http://stackoverflow.com/questions/37447114/find-the-longest-continuous-chunk-of-true-in-a-boolean-vector 
    idx <- with(rle(depth > depth_cutoff), rep(lengths == max(lengths[values]) & values, lengths))
    
    tag[["dnum"]] <- dnum[idx]
    tag[["temp"]] <- temp[idx]
    tag[["depth"]] <- depth[idx]
    tag[["days_at_large"]] <- ceiling(tag[["dnum"]][length(tag[["dnum"]])]-tag[["dnum"]][1])
    
    print(paste("fish in water at",matlab2POS(tag[["dnum"]][1])))
    print(paste("fish recaptured at",matlab2POS(tail(tag[["dnum"]],n=1))))
    
    # check the time interval 
    tag[["min_intvl_seconds"]] = min(diff(tag[["dnum"]]))*3600*24
    tag[["max_intvl_seconds"]] = max(diff(tag[["dnum"]]))*3600*24
    
    dev.new()
    par(mfrow=c(2,1))
    plot(tag[["dnum"]],tag[["depth"]],type="l",ylim = rev(range(tag[["depth"]])), col="blue")
    title(paste(tag[["fish_id"]],"_",tag[["tag_id"]]))
    plot(tag[["dnum"]],tag[["temp"]],type="l", col="red")
  
  
  }
  return(tag)
}