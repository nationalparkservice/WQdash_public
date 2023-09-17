### TODAY
# Return plot legend
# Move real-time map/plot inputs to top
# Fix plot size issue
# Move to full dashboard
# For each map marker selection, add explanatory text at top





### INSTALL REQUESTS
install.packages(c("sortable"), repos = "https://cloud.r-project.org", dep=TRUE)


### NOTES
# Keep is as a private dashboard until we complete compliance, data documentation, final approval.
# https://rigorousthemes.com/blog/best-power-bi-dashboard-examples/


### HIGH PRIORITY ISSUES
# > BUG > When switch to many stations, the second click of a site will caues the last selected site from One Station to select itself
# > Move plots & map user inputs for real-time update to above those. Add button for Advanced Plot Options--so user can add title & subtitle or caption, sort sites or characters, apply a different y-axis transform per plot, put multiple sites in a single plot (does this work?).
# > WHen user selects to show site marker, add legend for organization color
# NOTE: There is something funny zoom going on when I click site. Oh it's to show label. Can we have label overlap?
# BUG > The plots are all pushed down. This is because of legend. I should try using flexbox.
# > CHange plots font sizes so I can see them better
# Slider to adjust view window as ratio of map to summary plots. 
# >>> On season map, when you click on a point it should highlight all the other points from that year of data. Connect that to some selection box that allows to select one to highlight??
# >>> At top of data filter page overall reactable, identify the parameters and sites with ANY threshold violations.
# >>> mOVE all green buttons to top
# >>> On some page, give the option of uploading a threshold file or using default values (for common char-units, default is the most commonly used thresholds. SHow the table of default values on dashboard, as sliders, and allow users to set those levels there. So for all downloaded parameters. Then allow them to export a thresholds .csv for later use. That page should also show color options, like what color to use for below, between, and above.
# >>> Have default categorical colors and thresholds set.
# >>> Put the categorical color thing as a navmenu of a page called CUSTOMIZATIONS. Have link to jump to it.
# >>> Have all raw data tables on a page
# >>> Generate error text when numeric parameters detect non-numeric entries. Add option to exclude the monitoring sites with the problem entries
# >>> Raw data and other tables should have 'show all' option and if it's not reactable, add the buttons for export
# >>> MK w/graphs and maps
# >>> On maps page, add marker option of total threshold pie. Try to put map on same page as time series/seasonal plots so can look at them together and highlight as well.
# >>> Sample size matrix--add color for first and last cols. Move year to top. Have user select param. from drop-down so it only shows one at a time. tHERE is something funny with BITH for USGS--no matter the years selected, USGS starts on next year
# >>> Data warnings page and option to remove site-chars with problems. Catch: non-numeric, censored data assigned to wrong level (above or below), pH values outside of range, negative values for some things...
# >>> PIE CHARTS NEED TO SOMEHOW REFLECT SAMPLE SIZE
# On the data import page, identify the criteria (filters) used to import the data and date of import. Also provide the URL so anyone can replicate the import.
# >> Initially, should have these alerts with icons and with instructions for changing: 1. Using default filters for the subset of data to show, 2. (if relevant) Using default colors and alpha order for categorical parameters, 3. Using default water quality thresholds for key parameters. Then if/when they change it, remove the alert (or if they imported an RDS with specified values). Also at top of dashboard have an option to save a dashboard data file with the currently set filters, thresholds, and categorical specs.
# >> Set default colors for categorical flow and save
# >> Instead of pie charts, consider dot plots. Or pie charts that reflect sample size.


### FORMAT EASY FIXES
# DON'T SHOW ANY MEANS! Show min, max, median and IQR; leave in things like % censored by season.
# INCREASE FONT SIZES!!!
# Add CI for loess, but take care of the issue with it cutting off?
# On each page, include in bold text the data filters being applied, the park, etc.
# For each parameter, allow separate y-transform option
# Key summary stats on top left of each page.
# Reactable tables expanded by default for sites
# Hard to read site names on facet plots--increase the info on source agency and put the site full name
# Include measurement unit on y-axis. Throw warning for multiple units. Throw warning for unspecified units.
# Threshold and percentage lines should be labeled on plots.
# The extensive text for time series plots, etc., should be moved to a pop-up user accesses by clicking on a page info icon
# Trends in %--change order to below, good, above to match thresholds. On hover, level should say below WHAT VALUE, e.g.


### BUGS
# BITH crashes when something with threshold on pH... not sure if it has to do with fact there are two units?
# TIMU Sample size matrix with week--Failed to create Cairo backend! This occurs when too large
# >>> Fix summary tables issue
# Running elephant disappears prematurely
# Map doesn't zoom to correct place if done after another


### DEMO
# Demo the select-by-location on stream, and with threshold map showing patterns along the stream. Preferably with discharge stations downloaded and selection is of a site by discharge station
# Show censored data plots and also warning if using different char sets
# Demo BITH
# > Error-catching page
# > pH across multiple agencies (set thresh) w/color code and prcip. BUT THE PLOT SIZES ARE FUNNY
# > Select one NPS site and show all (inc seasonal)
# > Check on e.coli question about censored data
# > Check on sample size matrix


### LOW PRIORITY ENHANCEMENTS (POST-DEMO IS OK)
# >>Default filter on import should include all sites with data collected within the past four years and include all NPS-collected parameters with data within the past four years. If no NPS sites, thrn use the default parameters. Move filter button to top of dashboard, always present. 
# >> Allow user to just import NPS data discharge/precip and be done
# >> Make sure don't need to do pages in "order"
# >> Add back in the function to show seasonal patterns highlighted by year. But instead, allow comparison of two years. Initial year is one highlight color and second year is another highlight color. Default is to show the first and last years highlighted. Put some kind of delay on reacting to the slider. ALSO allow them to click on a point to highlight year across all plots including streamflow/precip.
# >> On data filter page-by-parameter, show thumbnail trend plots and allow overall threshold stats across all years (perhaps as horizontal bar but also have the numbers and % in cols so can be sorted or filtered)
# >> (Matrix of threshold violations by site (row) and parameter? But only if there is a certain amount of data. Perhaps size of pie chart should be scaled to sample size. OR think about a better way to present this.
# >> On the maps page, show the threshold info as matrix by site and year. And then under that, show the map. Do that instead of showing a separate page just of threshold info. Same if they choose percentile.
# >> Make sure all tables and graphs can be exported
# Maybe on import page for gage station, weather stations and discharge facilities--instead of providing the station information actually show the graphs and have titles show the station name and date range. Can show graphs as actual data on regular or log scale, or something. Alternatively, remove these.
# Save RDS with the thresholds and color code files included
# >> Raw data fields for showing raw data--this should be a expandable button at top of that table tab
# >> For sample size matrix, have option at top to select parameter instead of showing all
# >> Provide a test dataset, which corresponds with instructions for dashboard use
# >> Percentile input should only accept values 0 - 1. Warning otherwise.


### MAPVIEW LOW PRIORITY FIXES
# > It renders the full plot each time. Can isolate those parts of full plot, but then updates from user input don't work.
# > The first click on a site doesn't seem to work.


<div align="center">
  rchunk
</div>