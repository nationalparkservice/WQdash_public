
# PICK UP from here
# rv_param_temp$subDat actually has ThreshCateg for each record
# rv_param_temp$threshList should add an element called cut_categ_full that is like ("Good (< 3 units)")--then I can use that in popup b/c edit popup so next to pie it says like "Good (< 3 units)"--see if test_map.Rmd can be simplified

popup_main_data <- rv_param_temp$subDat %>% 
  dplyr::select(MonitoringLocationIdentifier, CharSampleType, Yr, ActivityStartDate, ResultMeasureValue_replaced, ResultMeasure.MeasureUnitCode, ResultDetectionConditionText, ThreshCateg) %>%
  dplyr::filter(!is.na(ResultMeasureValue_replaced)) %>%
  dplyr::group_by(MonitoringLocationIdentifier, CharSampleType, ResultMeasure.MeasureUnitCode) %>%
  dplyr::arrange(MonitoringLocationIdentifier, CharSampleType, desc(ActivityStartDate)) %>%
  dplyr::summarise(
    Sample_Size = n(),
    Year_Range = if(min(Yr, na.rm = TRUE) == max(Yr, na.rm = TRUE)) {
      as.character(min(Yr, na.rm = TRUE))
    } else {
      paste0(min(Yr, na.rm = TRUE), "–", max(Yr, na.rm = TRUE))
    },
    Lowest_Value = {
      min_val <- min(ResultMeasureValue_replaced, na.rm = TRUE)
      min_conditions <- unique(ResultDetectionConditionText[ResultMeasureValue_replaced == min_val & !is.na(ResultDetectionConditionText)])
      min_conditions <- min_conditions[min_conditions != ""]
      if(length(min_conditions) > 0) {
        paste0(min_val, " (", paste(min_conditions, collapse = "/"), ")")
      } else {
        as.character(min_val)
      }
    },
    Highest_Value = {
      max_val <- max(ResultMeasureValue_replaced, na.rm = TRUE)
      max_conditions <- unique(ResultDetectionConditionText[ResultMeasureValue_replaced == max_val & !is.na(ResultDetectionConditionText)])
      max_conditions <- max_conditions[max_conditions != ""]
      if(length(max_conditions) > 0) {
        paste0(max_val, " (", paste(max_conditions, collapse = "/"), ")")
      } else {
        as.character(max_val)
      }
    },
    
    Most_Recent_Value = first(ResultMeasureValue_replaced),
    Most_Recent_Sample_Date = first(ActivityStartDate),
    
    Recent_Values = {
      recent_vals <- head(ResultMeasureValue_replaced, 5)
      paste(recent_vals[!is.na(recent_vals)], collapse = ",")
    },
    
    Recent_Dates = {
      recent_dates <- head(ActivityStartDate, 5)
      paste(format(recent_dates[!is.na(recent_dates)], "%Y-%m-%d"), collapse = ",")
    },
    
    Recent_Detection_Conditions = {
      recent_conditions <- head(ResultDetectionConditionText, 5)
      recent_conditions <- recent_conditions[!is.na(recent_conditions) & recent_conditions != ""]
      paste(recent_conditions, collapse = ",")
    },
    
    .groups = 'drop'
  ) %>%
  
  select(
    Site = MonitoringLocationIdentifier,
    Characteristic = CharSampleType,
    Unit = ResultMeasure.MeasureUnitCode,
    Sample_Size,
    Year_Range,
    Lowest_Value,
    Highest_Value,
    Most_Recent_Value,
    Most_Recent_Sample_Date,
    Recent_Values,
    Recent_Dates,
    Recent_Detection_Conditions
  )

# Calculate threshold counts with labels
threshold_data <- rv_param_temp$subDat %>%
  dplyr::filter(!is.na(ResultMeasureValue_replaced) & !is.na(ThreshCateg)) %>%
  dplyr::group_by(MonitoringLocationIdentifier, CharSampleType, ResultMeasure.MeasureUnitCode, ThreshCateg) %>%
  dplyr::summarise(n = n(), .groups = 'drop') %>%
  dplyr::mutate(threshold_key = paste0(CharSampleType, " (", ResultMeasure.MeasureUnitCode, ")")) %>%
  dplyr::left_join(
    # Create lookup table from threshList
    do.call(rbind, lapply(names(rv_param_temp$threshList), function(key) {
      if (!is.null(rv_param_temp$threshList[[key]]$cut_categ_label)) {
        data.frame(
          threshold_key = key,
          ThreshCateg = rv_param_temp$threshList[[key]]$cut_categ,
          ThreshCateg_Label = rv_param_temp$threshList[[key]]$cut_categ_label,
          stringsAsFactors = FALSE
        )
      }
    })),
    by = c("threshold_key", "ThreshCateg")
  ) %>%
  dplyr::mutate(ThreshCateg_Label = ifelse(is.na(ThreshCateg_Label), tools::toTitleCase(ThreshCateg), ThreshCateg_Label)) %>%
  dplyr::select(Site = MonitoringLocationIdentifier, Characteristic = CharSampleType, Unit = ResultMeasure.MeasureUnitCode, ThreshCateg, ThreshCateg_Label, n)
