# Get summary information about the data available for selected sites, to help user better refine import to particular CharacteristicType and years of data
dat <- readWQPsummary(siteid = rv$selectedStations$MonitoringLocationIdentifier, summaryYears = "all")


# This one gives count per station-char and first/last year 
View(summary_dat <- dat %>%
  dplyr::group_by(OrganizationFormalName, MonitoringLocationIdentifier, ResolvedMonitoringLocationTypeName, CharacteristicType, CharacteristicName) %>%
  dplyr::summarize(first_yr = min(YearSummarized, na.rm = TRUE), last_yr = max(YearSummarized, na.rm = TRUE), total_activity_count = sum(ActivityCount, na.rm = TRUE), total_result_count = sum(ResultCount, na.rm = TRUE), .groups = "drop"))

# This one gives count per char
View(char_table <- dat %>% dplyr::group_by(CharacteristicType, CharacteristicName) %>% summarize(total_activity_count = sum(ActivityCount, na.rm = TRUE), total_result_count = sum(ResultCount, na.rm = TRUE), .groups = "drop"))
