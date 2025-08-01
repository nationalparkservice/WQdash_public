## PICK UP FROM HERE:
# > I don't think my user option of only data with samples collected within X years, actually works. I can't get startdateLo to work, and it seems summaryYears = 8 fails.
# > Incorporate this into dashboard. I moved the characteristic selection up so it's done, then user can select to "Summarize Selected Data" (instead of "Highlight..."). Then it should show information on the tabs. Then user can select the stream and weather data. Then download everything. For efficiency, just create this searchURL then for summary vs download result I can just append the appropriate URL prefix. May work also for getting the station info.

## I PUT THIS INTO DASHBOARD...CONTINUE WORKING FROM THERE.
searchURL <- paste0("search?organization=", orgChoiceString, "&siteid=", stationChoiceString, "&characteristicType=", charTypeChoiceString, "&sampleMedia=Water&mimeType=csv&zip=no") # REMOVED SITETYPE & MINACTIVITIES & START & END DATES AS AN OPTION AT THIS STAGE)

summaryURL <- paste0("https://www.waterqualitydata.us/data/summary/monitoringLocation/", searchURL, "&summaryYears=all&count=no&dataProfile=periodOfRecord")



# Get summary information about the data available for selected sites, to help user better refine import to particular CharacteristicType and years of data
dat <- readWQPsummary(
  siteid = rv$selectedStations$MonitoringLocationIdentifier[1:3],
  characteristicType = input$sel_CharType[4:5],
  summaryYears = "all"
  )
# GET: https://www.waterqualitydata.us/data/summary/monitoringLocation/search?siteid=11NPSWRD_WQX-CONG_CCBR01%3B21SC60WQ_WQX-B-080%3B21SC60WQ_WQX-C-007&characteristicType=Nutrient&characteristicType=Physical&summaryYears=all&mimeType=csv&count=no&dataProfile=periodOfRecord

# This one gives count per station-char and first/last year 
View(summary_dat <- dat %>%
  dplyr::group_by(OrganizationFormalName, MonitoringLocationIdentifier, MonitoringLocationTypeName, CharacteristicType, CharacteristicName) %>%
  dplyr::summarize(first_yr = min(YearSummarized, na.rm = TRUE), last_yr = max(YearSummarized, na.rm = TRUE), total_activity_count = sum(ActivityCount, na.rm = TRUE), total_result_count = sum(ResultCount, na.rm = TRUE), .groups = "drop"))

# This one gives count per char
View(char_table <- dat %>% dplyr::group_by(CharacteristicType, CharacteristicName) %>% summarize(total_activity_count = sum(ActivityCount, na.rm = TRUE), total_result_count = sum(ResultCount, na.rm = TRUE), .groups = "drop"))
