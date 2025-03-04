# https://dreamrs.github.io/shinyWidgets/
  
### >>>> CHI, INSTALL PACKAGE
library(devtools)
install_github("nationalparkservice/EnvironmentalSetting_Toolkit/ES_Toolkit_R")


### >>>>>>>>>>>>>>>> FIX THESE FIRST!!!

### Fix the import--rnoaa, precip & gage. Phase out rgdal code completely. 
# > https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt
# > https://waterservices.usgs.gov/nwis/dv/?format=rdb,1.0&sites=06036905,06191000&startDT=2010-08-02&endDT=2021-08-06&siteStatus=all
# > Look into Daymet gridded data?
# > See the Temp_EnvironmentalSettings script for ACIS

# Importing precip or gage requires going through filter page
### When i import new data I don't see anything in selected sites, and rv$imported...for Orgs gives NULL

### Need to be able to break up downloads into smaller chunks so can work
### >>> Nice reactable table with stats from thresholds table etc (make sure it's filterable). Also, expand all/collapse all button.





# The button to add to import page----
renderUI({
  shiny::req(!is.null(rv$sitesPointsSub))
  checkboxGroupInput("sel_Organization",
                     label = h6("Import WQP data only from these organizations: "),
                     choices = sort(unique(rv$sitesPointsSub$OrganizationFormalName)),
                     selected = rv_param_temp$currentInputs$sel_Organization
  )
}),

renderUI({
  shiny::req(!is.null(rv$sitesPointsSub))
  
  FuncAllNoneButtons(cond = "input.sel_Organization", name_all = "button_allImportOrgs", name_none = "button_noImportOrgs")
}),

# Action to select all organizations to import----
observeEvent(eventExpr = input$button_allImportOrgs, {
  shiny::req(!is.null(rv$sitesPointsSub))
  
  rv_param_temp$currentInputs$sel_Organization <- unique(rv$sitesPointsSub$OrganizationFormalName)
}, ignoreInit = TRUE) # end of observeEvent

# Action to select no organizations to import----
observeEvent(eventExpr = input$button_noImportOrgs, {
  shiny::req(!is.null(rv$sitesPointsSub))
  
  rv_param_temp$currentInputs$sel_Organization <- character(0)
}, ignoreInit = TRUE) # end of observeEvent

# Set this right after setting loadmap to TRUE----
# Set initial import values
rv_param_temp$currentInputs$sel_Organization <- unique(rv$sitesPointsSub$OrganizationFormalName)




### >>> thresh file doesn't show as defulat; with file selected, should not see the custom dropdown options
### >>> should add text when y-axis is log-transformed
### >>> Threshold--need legend explanation
# plot title problem
### >>> Color categ has legend and it actually doubles up but not quite enough
### When showing one plot (combined sites), title should not cut up. When showing many, it should not run into plots. Pull it out of the plot page and put it above instead.
# On map, it goes blank in years with no data
### Does an annyoing double blink on plots



### >>> Add explanations/warnings on loess (just for general pattern, does not treat non-detects correctly, funny things with data gaps)--also anything like estimated median and percentile treats non-detects and other censored data a certain way (so should also include % BDL, etc.). Warnings on percentile lines also and need to clearly state WHAT THE PERCENTILE VALUES ARE AND ACROSS HOW MANY SITES AND YEARS. Default for percentile should be OFF.




### >>> MUST add sample sizes to pie matrices/maps and ideally sample size scaled to area

### fILTER user select of param list, should have "Show None" working <<<<<<<<<<<< FIX IT FOR ALL!

# >>>>>> MIssing threshold legends?

https://www.rcc-acis.org/docs_webservices.html



# WQP CHANGES
# > sTATUS PAGE https://doi-usgs.github.io/dataRetrieval/articles/Status.html
# > https://www.waterqualitydata.us/
  # > Get ideas from here: https://waterdata.usgs.gov/monitoring-location/040851385/#parameterCode=00065&period=P7D&showMedian=false
# > New download samples API: https://api.waterdata.usgs.gov/samples-data/docs
# > https://waterservices.usgs.gov/docs/

# OTHER THINGS TO DO
# pie matrix legend runs into plot when few rows of data
# If I select a park to import and press button then it should reset map to blank even if it's the same park i had loaded last (the sites should all become unselected again)
# FuncOrderCheck should no longer show filter rquirement. also, need to Sys.sleep some messages
# ResultMeasureValue --convert all to uppercase b/c categorical; check if case of measureunit is causing problems
# CONG doesn't work!!
# On plot hover, add thresh categ
# Next to plots, add stats for thresholds
# Popup table dismiss button needs to be easily visible: https://stackoverflow.com/questions/63882483/how-to-adjust-shiny-modaldialog-width-to-a-dt-object-to-fully-show-the-table-i
# For min and max in summary tables, need to indicate if that is the detection level or the real number!
# Flagging issues--but
###   # > On map summaries by year median, Invalid list type of argument--I think this is in years with no data? E.g., BISO Ammonium. Also should add caveat about how median treats non-detects.

# > Save RDS should be more default and obvious
# Add text stating which year is highlighted
  # > I think?? I can get rid of a lot of extraneous code b/c when action buttons are pushed and then use input selects, I can jsust use them directly as is. CHanging user selection won't cause reactions if those reactions are enclosed in action button observeEvents.
  # > (Page to create thresholds and save file that can later be imported)
  # > (BITH vertice error)
### Plot legend needs to wrap.
  # Option to select all sites in park boundary, or to select individual sites (import). Also, select/deselect all HUCs
  # > Change home page so it starts with request to load data or select a park. The info page should be moved to the back.
  # > Check that I'm calling web services appropriately: https://info201.github.io/apis.html#what-is-a-web-api
  # >>>>> In time series sometimes I get an error if the first plot doesn't have something
  # >>>>> Need to explain better how to use the dashboard
  # >>>>> Hydro-linked data pull no longer working. Check again in mid-March after USGS updates WQP API's
  # > (Test that package for web service pull)
  # > Add characteristic sets and water types >>> I really broadened the filter on line 2500 so user options need to be expanded too
  # > Yellowstone's requested hydrograph
  # > Documentation, links to data sources, 503 compliance, troubleshooting/FAQs page
  # > (Maps, tables and some others are not yet exportable)
  # > (Put maps in function to minimize duplication)
  # > (Add extensive error check page allowing user to omit site-parameters with issues)
  # >>>>> Sometimes initial map has problems after sample size
  # > If user selects Custom Season, filtered data uses water year to assign year...but shouldn't be that way...
  # >>>>>> Option to filter data based on recency to sampling activity
  # > When I change to download data from web services, map automatically disappears even though I didn't press green Search button
  # > Refresh filter seems to not work or give a warning if the filter selection results in 0 records--should give a warning
  # > When I combine sites in a plot, should automatically increase plot height to +7. Can't always see the full hover, gets cut off at top for season b/c it shows many at once.


  
  ### ADD TO R TEMPLATE:
  # > bslib cards
  # > Additional plot options dropdown
  # > SelectNone issue
# > glue



TEMP - PLOT SUMMARY
======================================
  
  ### Plot Data Summary
  ```{r plot_summary}
output$plotDT <- DT::renderDT({
  FuncOrderCheck(import = TRUE, filter_internal = FALSE, filter_external = TRUE, plot = TRUE)
  shiny::req(!is.null(input$sel_SummaryTab), !is.null(rv_param_temp$plotSummarizeBy), !is.null(rv_param_temp$plotDat), !is.null(rv_param_temp$plotSummary))
  
  
  temp_plotsummary <- DT::datatable(
    rv_param_temp$plotSummary,
    escape = FALSE,
    filter = "top",
    rownames = FALSE,
    selection = "none",
    class="compact stripe",
    options = list(
      # pageLength = -1,
      colReorder = TRUE,
      # lengthMenu = c(5, 10, 15, 20),
      columnDefs = list(
        list(className = 'dt-center', targets = "_all"))
    )
  )
})
plot_proxyDT <- DT::dataTableProxy("plotDT", session = session)
dataTableOutput("plotDT")
tags$style("#plotDT{height:100vh;overflow-x:scroll;overflow-y:scroll}")
```


  
