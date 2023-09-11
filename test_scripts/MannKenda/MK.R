### NADA2 --------------------------------
# No CI and the output is not easy to save in a format I can use
# Need to first calculate median per season-yr, with appropriate consideration of censoring. Otherwise, seasons with more data will be weighted more.
library(tidyverse)
library(here)
library(NADA2)
library(openair)
library(magrittr)

# how to address MK autocorrelation?
# use NADA2 to calculate median per season, with censored data--then feed that to ceasenken
# apply USGS criteria for conducting seasonal Kendall

trendDat <- readRDS(here::here("test_scripts", "MannKenda", "trendDat.RDS"))

subdat <- subset(trendDat, MonitoringLocationIdentifier == "11NPSWRD_WQX-BITH_BSVC") # "11NPSWRD_WQX-BITH_BSVC" "11NPSWRD_WQX-BITH_MCMC"

  subdat$DaySinceStart <- as.integer(subdat$ActivityStartDate - min(subdat$ActivityStartDate, na.rm = TRUE))
  mk_NADA2 <- with(subdat, censeaken(time = DaySinceStart, y = ResultMeasureValue_replaced, y.cen = Censored, group = Season, seaplots = TRUE, printstat = FALSE))
  mk_NADA2


### smwrQW and restrend--------------------------------------
# This package is no longer maintained. I can't download restrend b/c AppLocker.

### openAir ------------------------
# Don't use its deseasonalization, no good with missing data

# using stl-deseasonalized
subdat <- subset(trendDat, MonitoringLocationIdentifier == "11NPSWRD_WQX-BITH_BSVC") # "11NPSWRD_WQX-BITH_BSVC" "11NPSWRD_WQX-BITH_MCMC"
subdat$date <- subdat$ActivityStartDate
smooth1 <- openair::smoothTrend(subdat, pollutant = "ResultMeasureValue_replaced", deseason = FALSE, simulate = TRUE, n = 1000, avg.time = "season", statistic = "median", type = "season", autocor = TRUE, ci = TRUE, ylab = unique(subdat$CharacteristicName), xlab = "Year", main = paste0("(smoothTrend)", unique(subdat$MonitoringLocationIdentifier), ": ", unique(subdat$CharacteristicName)))

thsen1 <- TheilSen(subdat, pollutant = "ResultMeasureValue_replaced", avg.time = "season", statistic = "median", type = "Season", main = paste0("(TheilSen)", unique(subdat$MonitoringLocationIdentifier), ": ", unique(subdat$CharacteristicName)), ylab = unique(subdat$CharacteristicName), xlab = "Year", deseason = FALSE, autocor = TRUE, date.format = "%Y") # does block bootstrap. The 1:1 line is solid and the 1:0.5 and 1:2 lines are dashed. Uses the user-defined season (type = "Season") # <<<< THIS DOES NOT MEAN IT'S SEASONAL MK
View(thsen1$data$res2)

thsen_full <- TheilSen(subdat, pollutant = "ResultMeasureValue_replaced", avg.time = "season", statistic = "median", main = paste0("(TheilSen)", unique(subdat$MonitoringLocationIdentifier), ": ", unique(subdat$CharacteristicName)), ylab = unique(subdat$CharacteristicName), xlab = "Year", deseason = FALSE, autocor = TRUE, date.format = "%Y") 
View(thsen_full$data$res2)

### modifiedMK -------------------------------

### wql --------------------------------
subdat <- subset(trendDat, MonitoringLocationIdentifier == "11NPSWRD_WQX-BITH_BSVC") # "11NPSWRD_WQX-BITH_BSVC" "11NPSWRD_WQX-BITH_MCMC"
trend_type <- "MKS" # "MK" for MannKendall, "MKS" for seasonal


subdat %<>%
      dplyr::mutate(Year = as.integer(Yr))
subdat$Yr <- as.factor("Annual")
    
    subdat %<>% 
      dplyr::rename("Interval" = switch("MKS", "MK" = "Yr", "MKS" = "Season", "MKM" = "Mnth")) %>%
      dplyr::select(MonitoringLocationIdentifier, CharacteristicName, ResultMeasureValue_replaced, ResultDetectionConditionText, Year, Interval) %>%
      dplyr::filter(!is.na(ResultMeasureValue_replaced)) %>%
      group_by(MonitoringLocationIdentifier, CharacteristicName, Year, Interval) %>%
      summarise(MedianValue = median(ResultMeasureValue_replaced, na.rm = TRUE), # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ADD CAVEAT
                N = n(),
                PropDetect = round((sum(ResultDetectionConditionText=="Detected and Quantified")/N)*100)) %>%
      ungroup() %>%
      dplyr::mutate(LocChar = paste0(MonitoringLocationIdentifier, "_", CharacteristicName)) %>%
      arrange(MonitoringLocationIdentifier, CharacteristicName, Year, Interval)

    subdat <- switch((nrow(subdat) > 0)+1, NULL, subdat)
 
    if(!is.null(subdat)) {

        MKsubdat <- subdat %>%
          mutate_if(is.factor, as.character) %>%
          right_join(expand.grid(Year = modelr::seq_range(subdat$Year, by = 1), Interval = levels(subdat$Interval)), by = c("Year", "Interval")) %>%
          mutate(Interval = factor(Interval, levels = levels(subdat$Interval))) %>%
          arrange(Year, Interval)
        
        if(trend_type == "MK") {
          MKtemp <- as.data.frame(mannKen(MKsubdat$MedianValue)) %>%
            mutate(season = "Annual")
        }
        
        if(trend_type == "MKS") {
          ts_dat <- ts(MKsubdat$MedianValue, start = 1, end = length(unique(MKsubdat$Year)), frequency = length(levels(MKsubdat$Interval)))
          MKtemp <- seasonTrend(ts_dat)
          MKtemp$season <- dplyr::recode(as.numeric(MKtemp$season), .default = levels(MKsubdat$Interval))
        }
        
        mk_wql <- MKtemp %>%
          dplyr::mutate(
            MonitoringLocationIdentifier = unique(subdat$MonitoringLocationIdentifier),
            CharacteristicName = unique(subdat$CharacteristicName)) %>%
          dplyr::mutate_if(is.numeric, round, digits=3) %>%
          dplyr::mutate(miss = round(100*miss)) %>%
          dplyr::select(MonitoringLocationIdentifier, CharacteristicName, Interval = season, SenSlope = sen.slope, RelativeSenSlope = sen.slope.rel, Pvalue = p.value, `%MissingEnds` = miss)
        mk_wql$SenSlope[mk_wql$`%MissingEnds` > 50] <- NA
        mk_wql$RelativeSenSlope[mk_wql$`%MissingEnds` > 50] <- NA
        mk_wql$Pvalue[mk_wql$`%MissingEnds` > 50] <- NA
        
        if(trend_type == "MKS") {
          mk_wql$Interval <- factor(mk_wql$Interval, levels = levels(subdat$Interval))
          }
        mk_wql
    }





  
        