############
# METADATA #
############
# project
tag[["notes"]] <- 'Yellowtail flounder' 
tag[["project"]] <- '-' 
tag[["investigator"]] <- 'Steven Cadrin, Geoffrey Cowles' 
tag[["tripID"]] <- '-' 

# tag specifications
tag[["type"]] <- 'Lotek'   
tag[["model_number"]] <- 'LTD 1100'  
tag[["parameters"]] <- '32K memory, 8 mm x 16 mm x 27 mm  Lotek, St.Johns Newfoundland'  
tag[["raw_time_lag_UTC_hrs"]] <- 5.    # shift in hours from tag time to UTC (4 for EDT,  <- 5 for EST, <- 0 for GMT)  


# fish
tag[["species_common_name"]] <- 'Yellowtail flounder' 
tag[["species_scientific_name"]] <- 'Limanda ferruginea' 
tag[["weight_kg"]] <-  '-' 
tag[["fish_notes"]] <- 'none' 

# release/capture data (use decimal degrees, use '-9999.' for lon/lat if recap location unknown)
tag[["released_by"]] <-  'S. Cadrin'
tag[["release_region"]] <- 'none'  
tag[["recapture_region"]] <- 'none'  
tag[["recaptured_by"]] <- 'none' 
tag[["recap_uncertainty_km"]] <- .001  #recapture uncertainty in km (must be > 0.) 
# time zone - all releases were in local time, EDT
tag[["tzone"]] <- 'EST' 