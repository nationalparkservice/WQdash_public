stat<- test(unitCode = "AGFO", customBBox = "-104.19609745831781, 42.112886184389545, -103.2970796760243, 42.7314612519983", climateParameters = list("pcpn"))

  unitCode = "AGFO"
  customBBox = "-104.19609745831781, 42.112886184389545, -103.2970796760243, 42.7314612519983"
  climateParameters = list("pcpn","snow")
  distance = NULL
  filePathAndName = NULL


test <- function (unitCode, distance = NULL, climateParameters = NULL, 
          filePathAndName = NULL, customBBox = NULL) {
  if (is.null(distance)) {
    bboxExpand = 0
  } else if (distance == 0) {
    bboxExpand = 0
  } else {
    bboxExpand = distance * 0.011
  }
  baseURL <- "http://data.rcc-acis.org/"
  webServiceSource <- "StnMeta"
  lookups <- fromJSON(system.file("ACISLookups.json", package = "EnvironmentalSettingToolkit"), 
                      flatten = TRUE)
  stationMetadata = c("uid", "name", "state", "climdiv", "county", 
                      "ll", "elev", "valid_daterange", "sids")
  encode <- c("json")
  config <- add_headers(Accept = "'Accept':'application/json'")
  stationURL <- gsub(" ", "", paste(baseURL, webServiceSource))
  if (is.null(customBBox)) {
    bbox <- getBBox(unitCode, bboxExpand)
  } else {
    bbox <- getBBox(unitCode, bboxExpand, customBBox)
  }
  body <- list(bbox = bbox)
  if (is.null(climateParameters)) {
    climateParameters0 <- lookups$element$code
    climateParameters <- climateParameters0[1:7]
  }
  stationList = NULL
  # for (p in 1:length(climateParameters)) {
  p= 1
    stationRequest <- gsub(" ", "%20", paste(paste(paste(stationURL, paste(climateParameters[p], collapse = ","), sep = "?elems="), body, sep = "&bbox="), paste(stationMetadata, collapse = ","), sep = "&meta="))
    stationListInit <- fromJSON(stationRequest)
    if (length(stationListInit$meta) > 0) {
      uid <- setNames(as.data.frame(as.numeric(stationListInit$meta$uid)), 
                      "uid")
      longitude <- setNames(as.data.frame(as.numeric(as.matrix(lapply(stationListInit$meta$ll, 
                                                                      function(x) unlist(as.numeric(x[1])))))), "longitude")
      latitude <- setNames(as.data.frame(as.numeric(as.matrix(lapply(stationListInit$meta$ll, 
                                                                     function(x) unlist(as.numeric(x[2])))))), "latitude")
      sid1 = c()
      sid2 = c()
      sid3 = c()
      sid1_type = c(as.character(NA))
      sid2_type = c(as.character(NA))
      sid3_type = c(as.character(NA))
      minDate = c(as.Date(NA))
      maxDate = c(as.Date(NA))
      hcn = c()
      climDiv = c()
      county = c()
      for (i in 1:length(stationListInit$meta$sids)) {
        if (length(unlist(stationListInit$meta$sids[i])) >= 
            3) {
          sid1[i] <- as.character(as.vector(lapply(stationListInit$meta$sids[i], 
                                                   function(x) unlist(x[1]))))
          sid1_type[i] <- suppressWarnings(getStationSubtype(unlist(strsplit(sid1[i], 
                                                                             " "))[2], substr(sid1[i], 1, 3)))
          sid2[i] <- as.character(as.vector(lapply(stationListInit$meta$sids[i], 
                                                   function(x) unlist(x[2]))))
          sid2_type[i] <- suppressWarnings(getStationSubtype(unlist(strsplit(sid2[i], 
                                                                             " "))[2], substr(sid2[i], 1, 3)))
          sid3[i] <- as.character(as.vector(lapply(stationListInit$meta$sids[i], 
                                                   function(x) unlist(x[3]))))
          sid3_type[i] <- suppressWarnings(getStationSubtype(unlist(strsplit(sid3[i], 
                                                                             " "))[2], substr(sid3[i], 1, 3)))
        }
        else if (identical(length(unlist(stationListInit$meta$sids[i])), 
                           as.integer(c(2)))) {
          sid1[i] <- as.character(as.vector(lapply(stationListInit$meta$sids[i], 
                                                   function(x) unlist(x[1]))))
          sid1_type[i] <- suppressWarnings(getStationSubtype(unlist(strsplit(sid1[i], 
                                                                             " "))[2], substr(sid1[i], 1, 3)))
          sid2[i] <- as.character(as.vector(lapply(stationListInit$meta$sids[i], 
                                                   function(x) unlist(x[2]))))
          sid2_type[i] <- suppressWarnings(getStationSubtype(unlist(strsplit(sid2[i], 
                                                                             " "))[2], substr(sid2[i], 1, 3)))
          sid3[i] <- as.character(NA)
          sid3_type[i] <- as.character(NA)
        }
        else {
          sid1[i] <- as.character(as.vector(lapply(stationListInit$meta$sids[i], 
                                                   function(x) unlist(x[1]))))
          sid1_type[i] <- suppressWarnings(getStationSubtype(unlist(strsplit(sid1[i], 
                                                                             " "))[2], substr(sid1[i], 1, 3)))
          sid2[i] <- as.character(NA)
          sid2_type[i] <- as.character(NA)
          sid3[i] <- as.character(NA)
          sid3_type[i] <- as.character(NA)
        }
      }
      sid1 <- setNames(as.data.frame(sid1), "sid1")
      sid2 <- setNames(as.data.frame(sid2), "sid2")
      sid3 <- setNames(as.data.frame(sid3), "sid3")
      sid1_type <- setNames(as.data.frame(sid1_type), "sid1_type")
      sid2_type <- setNames(as.data.frame(sid2_type), "sid2_type")
      sid3_type <- setNames(as.data.frame(sid3_type), "sid3_type")
      i <- NULL
      for (i in 1:length(stationListInit$meta$sids)) {
        if (!is.null(unlist(stationListInit$meta$valid_daterange[i])) & 
            length(as.data.frame(stationListInit$meta$valid_daterange[i])) > 
            0) {
          minDate[i] <- as.Date(range(unlist(stationListInit$meta$valid_daterange[i]))[1], 
                                "%Y-%m-%d")
          maxDate[i] <- as.Date(range(unlist(stationListInit$meta$valid_daterange[i]))[2], 
                                "%Y-%m-%d")
        }
        else {
          minDate[i] <- NA
          maxDate[i] <- NA
        }
      }
      minDate <- setNames(as.data.frame(minDate), "minDate")
      maxDate <- setNames(as.data.frame(maxDate), "maxDate")
      hcn0 <- getUSHCN(sid1)
      hcn <- setNames(as.data.frame(hcn0), "isHCNStation")
      options(digits = 1)
      if (!is.null(stationListInit$meta$elev)) {
        elev <- as.numeric(stationListInit$meta$elev)
      }
      else {
        elev <- as.numeric(NA)
      }
      climDiv <- stationListInit$meta$climdiv
      county <- stationListInit$meta$county
      options(digits = 7)
      if (is.null(stationList)) {
        stationList <- cbind(uid, name = stationListInit$meta$name, 
                             longitude, latitude, sid1, sid1_type, sid2, 
                             sid2_type, sid3, sid3_type, state = stationListInit$meta$state, 
                             elev = elev, climDiv = climDiv, county = county, 
                             isHCNStation = hcn, minDate, maxDate)
        stationList$climateParameter <- unlist(climateParameters[p])
        stationList$unitCode <- unitCode[1]
      }
      else {
        stationListTemp <- cbind(uid, name = stationListInit$meta$name, 
                                 longitude, latitude, sid1, sid1_type, sid2, 
                                 sid2_type, sid3, sid3_type, state = stationListInit$meta$state, 
                                 elev = elev, climDiv = climDiv, county = county, 
                                 isHCNStation = hcn, minDate, maxDate)
        stationListTemp$climateParameter <- unlist(climateParameters[p])
        stationListTemp$unitCode <- unitCode[1]
        stationList <- rbind(stationList, stationListTemp)
      }
      fc <- sapply(stationList, is.factor)
      lc <- sapply(stationList, is.logical)
      stationList[, fc] <- sapply(stationList[, fc], as.character)
      stationList[, lc] <- sapply(stationList[, lc], as.character)
    }
    else {
      stationList <- NA
    }
  }
  if (!is.null(filePathAndName)) {
    if (file.exists(filePathAndName)) {
      write.table(stationList, file = filePathAndName, 
                  append = TRUE, sep = ",", row.names = FALSE, 
                  col.names = FALSE, qmethod = "double")
    }
    else {
      write.table(stationList, file = filePathAndName, 
                  sep = ",", row.names = FALSE, qmethod = "double")
    }
  }
  else {
    return(stationList)
  }
  return(stationList)
}
  