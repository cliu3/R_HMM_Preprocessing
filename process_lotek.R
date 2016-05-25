process_lotek = function(tag) {
  
  # set parameters
  depth_cutoff <- 5.  #time series doesn't start until depth exceeds this value
  #time series ends last time depth is less than this value
  #this is used to trim data from the tag where the fish 
  #is not in the water
  
  print(paste("Processing tag #", tag[["fish_id"]], "..."))

  # make sure the tagfile exists
  if(file.exists(tag[["datafile"]])){
    
    nheader <- 5 # number of lines to skip
    mydata = read.table(tag[["datafile"]],skip=nheader,header=FALSE)
    ttime <- mydata[,1]
    temp <- mydata[,2]
    depth <- mydata[,3]
    
    # convert from psi to depth
    depth <- 1/(1.4504) * depth
    
    # convert time to Matlab/GMT
    ntimes <- length(ttime)
    
    
    tag[["process_date"]] <- strftime(Sys.time())
    
    # convert time to Matlab/GMT
    #ntimes <- numel(ttime);
    
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
    #smast-preprocessed tags, note time is shifted from excel time (days since 1900,1,0,0,0,0)
    #into the datenum time (days since 0000,1,0,0,0,0).  
    #note, we also subtract 1 day because Excel (Windows version, not Mac version) 
    #incorrectly believes that 1900 was a leap year
    #which it was not.  Datenum correctly calculates all the leap years.
    dnum <- (ttime -1.0 + datenum("1899/12/31 00:00:00"))  + time_shift_hrs/24.
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