### This script updates the "saved" data that goes along with the water quality dashboard. These are:
# > park boundaries and the following things that intersect park boundaries...
# > HUC10 & HUC10 boundaries
# > WQP stations--only pulling recently active stations (last sample within past 5 yrs). In dashboard real time will need to filter for water body type. IF the user wants to specify a lower threshold for min activity, or to potentially pull stations that are no longer active, then should do a real-time import instead. In list of stations, NA means the query was unsuccessful and a blank database with 0 rows means it was successful but there were 0 recently active stations
# > USGS stream gage stations--only pulling recently active stations (last sample within past 1 year) with at least 5 years of data and that fall within HUC10 bbox and have daily mean discharge data. In dashboard real time can filter for start and end dates. IN DASHBOARD CODE I need to filter to the ones that occur within the HUC10 boundaries AFTER I convert to sf (remember that CRS may differ by station, so need to set that accordingly)
# > NOAA recently active weather stations--only pulling recently active stations (last sample within past 1 year) with at least 5 years of data and that fall within HUC10 boundary BOX with a small buffer. 
### These saved data should only need to be updated approximately annually

## NOTE!!
# The rnoaa package will soon be retired and archived because the underlying APIs have changed dramatically. The package currently works but does not pull the most recent data in all cases. A noaaWeather package is planned as a replacement but the functions will not be interchangeable.

library(tidyverse)
library(sf)
library(httr)
library(rnoaa)
library(magrittr)

options(timeout=360) # change default timeout of 1 min to 6 min

### Spatial intersect of park unit boundaries and HUC10 and HUC12 boundaries ----

  # ### >>> Below, just for testing
  # huc10_filenam = "HUC10_Sept23.gdb"
  # huc12_filenam = "HUC12_Sept23.gdb"
  # parks_filenam = "Administrative_Boundaries_of_National_Park_System_Units.gdb"
  # ## <<<
  
  # Read in the HUC10 data
  huc10_gdb <- sf::st_layers(dsn = here::here("watershed_boundaries", huc10_filenam))
  huc10_sf <- st_read(dsn = here::here("watershed_boundaries", huc10_filenam), layer = huc10_gdb$name) 
  huc10_sf <- sf::st_transform(huc10_sf, crs = "+proj=longlat +datum=WGS84") # Convert to WGS84
  if(!all(st_is_valid(huc10_sf))) {huc10_sf <- sf::st_make_valid(huc10_sf)} # make valid if not
  all(st_is_valid(huc10_sf)) # confirm valid
  saveRDS(huc10_sf, here::here("watershed_boundaries", ("huc10_sf.RDS")))
  rm(huc10_gdb)
  
  # Read in the HUC12 data
  huc12_gdb <- sf::st_layers(dsn = here::here("watershed_boundaries", huc12_filenam))
  huc12_sf <- st_read(dsn = here::here("watershed_boundaries", huc12_filenam), layer = huc12_gdb$name) 
  huc12_sf <- sf::st_transform(huc12_sf, crs = "+proj=longlat +datum=WGS84") # Convert to WGS84
  if(!all(st_is_valid(huc12_sf))) {huc12_sf <- sf::st_make_valid(huc12_sf)} # make valid if not
  all(st_is_valid(huc12_sf)) # confirm valid
  saveRDS(huc12_sf, here::here("watershed_boundaries", ("huc12_sf.RDS")))
  rm(huc12_gdb)
  
  # Read in the park unit boundaries
  parks_gdb <- sf::st_layers(dsn = here::here("park_boundaries", parks_filenam))
  parks_sf <- st_read(dsn = here::here("park_boundaries", parks_filenam), layer = "Administrative_Boundaries_of_National_Park_System_Units")
  parks_sf <- sf::st_transform(parks_sf, crs = "+proj=longlat +datum=WGS84") # Convert to WGS84
  if(!all(st_is_valid(parks_sf))) {parks_sf <- sf::st_make_valid(parks_sf)}
  all(st_is_valid(parks_sf))
  saveRDS(parks_sf, here::here("dashboard_files", "parks_sf.RDS"))
  rm(parks_gdb)
  
  # Read in the sf files for TESTING ONLY >>>>
  huc10_sf <- readRDS(here::here("watershed_boundaries", ("huc10_sf.RDS")))
  parks_sf <- readRDS(here::here("dashboard_files", "parks_sf.RDS"))
  huc12_sf <- readRDS(here::here("watershed_boundaries", ("huc12_sf.RDS")))
  # <<<< for testing only
  
  FuncLinkSF <- function(base_parks_sf, other_sf, other_names_col) {
    try(if(st_crs(base_parks_sf) != st_crs(other_sf)) stop("CRS does not match for the simple features"))
    
    cat("starting sf intersection")
    temp_overlaps <- sf::st_intersects(other_sf, base_parks_sf) # creates a list of vectors. Each list element is one row of other_sf. Each vector gives row number for intersecting parks_sf.
    cat("saving sf intersection as a temp file")
    saveRDS(temp_overlaps, "TEMP_overlaps.RDS") # save b/c it is such a long process
    names(temp_overlaps) <- other_sf[other_names_col] %>% sf::st_drop_geometry() %>% dplyr::pull() # add list element names
    
    # This is a data frame that gives the park unit and corresponding row number in the parks_sf
    temp_link_park_rownum <- base_parks_sf %>% 
      as.data.frame() %>% 
      rowid_to_column() %>% 
      dplyr::select(parks_sf_rownum = rowid, UNIT_CODE)
    
    # This is a data frame that shows the intersecting 'other' polygons for each park unit
    overlaps_df <- enframe(temp_overlaps, name = other_names_col, value = "parks_sf_rownum") %>% 
      unnest(parks_sf_rownum) %>% # converts to long data frame, where first column is the row number for other_sf and second column is the row number for intersecting park unit
      dplyr::left_join(temp_link_park_rownum, by = "parks_sf_rownum") %>% # link the park row number to the corresponding park unit code
      dplyr::select(-parks_sf_rownum) %>%
      dplyr::select(unit_code = UNIT_CODE, everything()) %>% #
      dplyr::arrange(unit_code)
    
    other_sf_subset <- other_sf[lengths(temp_overlaps)>0,] # This is the subset of other_sf that actually overlaps a park unit. Save this one with the dashboard.
    
    return_list <- tibble::lst(other_sf_subset, overlaps_df)
    
  }
  
  # Find park-HUC10 sf overlaps
  temp_overlaps_list <- FuncLinkSF(base_parks_sf = parks_sf, other_sf = huc10_sf, other_names_col = "huc10")
  temp_park_huc10_overlaps_df <- temp_overlaps_list$overlaps_df
  saveRDS(temp_overlaps_list$overlaps_df, "TEMP_park_huc10_overlaps_df.RDS")
  saveRDS(temp_overlaps_list$other_sf_subset, here::here("dashboard_files", "huc10_overlap_sf.RDS")) # This is the HUC10 sf that only includes HUC10 polygons that intersect at least one park unit
  
  # Find park-HUC12 sf overlaps
  temp_overlaps_list <- FuncLinkSF(base_parks_sf = parks_sf, other_sf = huc12_sf, other_names_col = "huc12")
  temp_park_huc12_overlaps_df <- temp_overlaps_list$overlaps_df
  saveRDS(temp_overlaps_list$overlaps_df, "TEMP_park_huc12_overlaps_df.RDS")
  saveRDS(temp_overlaps_list$other_sf_subset, here::here("dashboard_files", "huc12_overlap_sf.RDS")) # This is the HUC12 sf that only includes HUC12 polygons that intersect at least one park unit
  
  # Create and save list of park_HUC overlaps
  park_sf_overlaps_list <- list(HUC10 = temp_park_huc10_overlaps_df, HUC12 = temp_park_huc12_overlaps_df)
  saveRDS(park_sf_overlaps_list, here::here("dashboard_files", "park_sf_overlaps_list.RDS"))
  
  # ### Testing...
  # FuncSelHUC <- function(huc, huc_sf, park_code, overlaps_list) {
  #   # Function to generate HUC sf with only the HUCs that overlap the selected park unit
  #   huc_on_park <- overlaps_list[[huc]] %>%
  #     dplyr::filter(unit_code == park_code) %>%
  #     dplyr::pull(tolower(huc))
  #   
  #   huc_sf_subset <- huc_sf %>% 
  #     dplyr::rename(HUC = tolower(huc)) %>%
  #     dplyr::filter(HUC %in% huc_on_park)
  #   return(huc_sf_subset)
  # }
  # 
  # 
  # park_sf_overlaps_list <- readRDS(here::here("dashboard_files", "park_sf_overlaps_list.RDS"))
  # huc10_overlap_sf <- readRDS(here::here("dashboard_files", "huc10_overlap_sf.RDS"))
  # huc12_overlap_sf <- readRDS(here::here("dashboard_files", "huc12_overlap_sf.RDS"))
  # 
  # ggplot() +
  #   geom_sf(data =  FuncSelHUC(huc = "HUC12", huc_sf = huc12_overlap_sf, park_code = "LIRI), fill = "blue", alpha = 0.3) + 
  #   geom_sf(data =  parks_sf %>% dplyr::filter(UNIT_CODE == "LIRI"), fill = "yellow", alpha = 0.5)

### Recently active WQP stations that fall within the HUC10 boundaries (at least one sampling activity within past 5 years) ----
  ## NOTES:
  # > Only pulling recently active stations (last sample within past 5 yrs). In dashboard real time will need to filter for water body type. IF the user wants to specify a lower threshold for min activity, or to potentially pull stations that are no longer active, then should do a real-time import instead. In list of stations, NA means the query was unsuccessful and a blank database with 0 rows means it was successful but there were 0 recently active stations
  parks_sf <- readRDS(here::here("dashboard_files", "parks_sf.RDS"))
  park_sf_overlaps_list <- readRDS(here::here("dashboard_files", "park_sf_overlaps_list.RDS"))
  park_stations_overlaps_list <- list()

for(i in 1:nrow(parks_sf)) { # download station information park-by-park
    park_vec <- parks_sf[i,] # park record
    park_code <- park_vec$UNIT_CODE # grab the 4-letter park code
    cat(i, park_code, "\n")

  parkHucs <- park_sf_overlaps_list[["HUC10"]] %>% dplyr::filter(unit_code == park_code) %>% dplyr::pull(huc10) # grab the overlapping HUC10 ID's
  allHucs <- parkHucs %>% paste(., collapse = "%3B") # convert to HUC string for web service query
    
  # Recently active WQP stations that fall within the HUC10 boundaries (at least one sample within past 5 years)
  sitesURL <- paste0("https://www.waterqualitydata.us/data/Station/search?siteType=Estuary&siteType=Lake%2C%20Reservoir%2C%20Impoundment&siteType=Spring&siteType=Stream&siteType=Wetland&huc=", allHucs, "&minactivities=1&startDateLo=01-01-", lubridate::year(Sys.Date())-5, "&sampleMedia=Water&mimeType=csv&zip=no&providers=NWIS&providers=STEWARDS&providers=STORET")
  
  if(http_status(GET(sitesURL))$category=="Success") {
    download.file(sitesURL, "tempSites.csv", mode = "w")
    sites <- read_csv("tempSites.csv", trim_ws = TRUE)
    park_stations_overlaps_list[[park_code]] <- sites
    cat("successful download\n")
    
    rm(sitesURL);rm(sites)
    unlink("tempSites.cvs")
    
  } else {
    rm(sites_URL)
    park_stations_overlaps_list[[park_code]] <- NA # still have the list element for the park, but enter as NA
    cat("NOT SUCCESSFUL\n")
  }
  if(i%%3 == 0) {saveRDS(park_stations_overlaps_list, "TEMP_park_stations_overlaps_list.RDS")}
}
  saveRDS(park_stations_overlaps_list, here::here("dashboard_files", "park_stations_overlaps_list.RDS"))
  
  
  
  
### Recently active USGS stream gage stations that fall within the HUC10 boundary (no buffer) ----
  # NOTES: 
  # > Only pulling recently active stations (last sample within past 1 year) with at least 5 years of data and that fall within HUC10 bbox and have daily mean discharge data
  # > Not all sites have been associated with a hydrologic unit. As such those sites cannot be retrieved with this method. THEREFORE I'm pulling sites within the HUC10 boundary box, THEN in the dashboard I will be subsetting to the ones that fall within the HUC10 boundary
  parks_sf <- readRDS(here::here("dashboard_files", "parks_sf.RDS"))
  huc10_overlap_sf <- readRDS("C:/Users/echeng/Desktop/WQdash_public/dashboard_files/huc10_overlap_sf.RDS")
  park_huc10_overlaps <- readRDS(here::here("dashboard_files", "park_sf_overlaps_list.RDS"))[["HUC10"]]
  
  park_gage_overlaps_list <- list()
  
  # for(i in 1:nrow(parks_sf)) { # download station information park-by-park
  for(i in 1:2) {
    park_vec <- parks_sf[i,] # park record
    park_code <- park_vec$UNIT_CODE # grab the 4-letter park code
    cat(i, park_code, "\n")
    
    park_hucs <- park_huc10_overlaps %>% dplyr::filter(unit_code == park_code) %>% dplyr::pull(huc10)
    park_huc10_sf <- huc10_overlap_sf %>% dplyr::filter(huc10 %in% park_hucs) # HUC10 simple feature
    
    huc10_bbox <- sf::st_bbox(park_huc10_sf) # HUC10 bbox
    
    ## USGS Stream Gage Stations
    
    gageURL <- paste0("https://waterservices.usgs.gov/nwis/site/?format=rdb&bBox=", paste(huc10_bbox, collapse =","), "&seriesCatalogOutput=true&siteStatus=active&siteType=ES,LK,ST,SP,WE&agencyCd=USGS&parameterCd=00060&hasDataTypeCd=dv&outputDataTypeCd=dv")
    
    if(http_status(GET(gageURL))$category=="Success") {
      
      download.file(gageURL, "tempGages.txt", mode = "w")
      
      gageStations <- read.delim("tempGages.txt", comment.char = '#')
      cat("successful download\n")
      
      park_gage_overlaps_list[[park_code]] <- gageStations %>%
        dplyr::filter(agency_cd == "USGS" & data_type_cd == "dv" & parm_cd == "00060" & stat_cd == "00003" & !is.na(dec_lat_va) & !is.na(dec_long_va) & !is.na(dec_coord_datum_cd) & end_date >= paste0(lubridate::year(Sys.Date())-1, "-01-01")) %>% # statistics code is mean (stat_cd = 00003), parameter is discharge (cubic feet per second; parm_cd = 00060), data type is daily, and end date is within one year 
        dplyr::mutate(days_span = lubridate::as_date(end_date)-lubridate::as_date(begin_date)) %>% # number of days station in operation
        dplyr::filter(days_span >= 1825) %>% # only keep stations with at least five years of data
        dplyr::select(GageID = site_no, GageName = station_nm, SiteType = site_tp_cd, Latitude = dec_lat_va, Longitude = dec_long_va, GageDatum = dec_coord_datum_cd, GageHUC = huc_cd, StartDate = begin_date, EndDate = end_date, NumRecords = count_nu) %>%
        dplyr::mutate(
          Latitude = as.numeric(Latitude),
          Longitude = as.numeric(Longitude),
          StartDate = base::as.Date(StartDate),
          EndDate = base::as.Date(EndDate),
          NumRecords = as.integer(NumRecords),
          GAGELAB = paste0("USGS Gage Station: ", GageName, " [", GageID, "]"),
          GAGEPOP = paste0('Gage Name: <a href="https://waterdata.usgs.gov/nwis/inventory?agency_code=USGS&site_no=', GageID, '" target="_blank">', GageName, '</a>', "<br>Gage ID: ", GageID, "<br>Start Date: ", StartDate, "<br>End Date: ", EndDate, "<br>Number of Records: ", NumRecords))
      
      rm(gageURL); rm(gageStations)
      unlink("tempGages.txt")
    } else {
      rm(gageURL)
      park_gage_overlaps_list[[park_code]] <- NA
      cat("NOT SUCCESSFUL\n")
    }
    if(i%%5 == 0) {saveRDS(park_gage_overlaps_list, "TEMP_park_gage_overlaps_list.RDS")}
  }
  saveRDS(park_gage_overlaps_list, here::here("dashboard_files", "park_gage_overlaps_list.RDS"))
    
  
  
  
### Recently active NOAA weather stations that fall within the HUC10 boundary box (with a buffer) ----
    ## Get NOAA station data
    tempMeteoStationsBbox<-tryCatch(rnoaa::ncdc_stations(extent = c(buff_bbox[2], buff_bbox[1], buff_bbox[4], buff_bbox[3]), limit = 500, datacategoryid="PRCP", token = "GxPYgaqBEDAkerwNZiXWQyIpqkAQTYSv"), error=function(e) print("Error retrieving weather stations information")) # added a buffer. X represents longitude
    if(!is.null(tempMeteoStationsBbox)) {
      meteoStationsBbox <- tempMeteoStationsBbox$data %>% 
        dplyr::mutate(element = "PRCP",
                      first_year = lubridate::year(mindate),
                      last_year = lubridate::year(maxdate)) %>%
        dplyr::select(id, latitude, longitude, elevation, elevationUnit, name, element, first_year, last_year, datacoverage, elevation) %>%
        dplyr::filter(last_year - first_year > 15 & # station must have at least 15 years of data
                        datacoverage > 0.95 & # station must have at least 95% data coverage
                        last_year > lubridate::year(Sys.Date())-1) # at least 15-year data range, 95% data coverage, and most recent data within one year of current date
      
      meteoStationsBbox$MeteoShortID <- gsub("^.*:","", meteoStationsBbox$id)
      
      park_noaa_overlaps_list[[park_vec$UNIT_CODE]] <- meteoStationsBbox %>%
        dplyr::rename(MeteoID = id, MeteoName = name, Elev = elevation, ElevUnit = elevationUnit, StartYr = first_year, EndYr = last_year, DataCoverage = datacoverage) %>%
        dplyr::mutate(
          METEOLAB = paste0("Weather Station: ", MeteoName, " [", MeteoID, "]"),
          METEOPOP = paste0("Weather Station: ", MeteoName, "<br>Start Year: ", StartYr, "<br>End Year: ", EndYr, "<br>Data Coverage: ", round(DataCoverage*100, 1), "%"))
      rm(tempMeteoStationsBbox);rm(meteoStationsBbox)
      cat("Got the weather station data\n")
    }
    
    
    
    if(i%%5 == 0) {saveRDS(park_noaa_overlaps_list, "TEMP_park_noaa_overlaps_list.RDS")}
  }
  
  
  
  ## Testing
  noaa <- readRDS("C:/Users/echeng/Desktop/WQdash_public/TEMP_park_noaa_overlaps_list.RDS")
  gage <- readRDS("C:/Users/echeng/Desktop/WQdash_public/TEMP_park_gage_overlaps_list.RDS")
  
  sel_park <- "IATR" # <<<
  this_park_sf <- parks_sf %>% dplyr::filter(UNIT_CODE == sel_park)
  
  noaa_sf <- st_as_sf(noaa[[sel_park]], coords = c("longitude","latitude"), crs = st_crs(this_park_sf))
  gage_sf <- st_as_sf(gage[[sel_park]], coords = c("Longitude","Latitude"), crs = st_crs(this_park_sf))
  
  ggplot() +
    geom_sf(data = park_vec, fill = "yellow") +
    geom_sf(data = noaa_sf, color = "green") +
    geom_sf(data = gage_sf, color = "blue")
  