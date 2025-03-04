# -- Red outline on marker for federal stream gage priority
# -- Get EPA discharge and river miles import working
# >>> Map--when turn off legend item keep it off
# >>>> Change pie charts to follow the example in script!!! Can I do it in the matrix too??
# -- FOPU or CUIS--DIN has censored, Chl-A >> Mean, Median, Min, Max,
# >>>> Add measure units on plots
# >>>> Plot title is smushed and axis titles too large. When threshold limit added, need text indicating what the color means
# >> Median map size should give for THAT YEAR. Also should outline it in black and add a size legend and hover should give N and median value
# -- Get rid of all the 'Option to show...' checkboxes in user inputs
# >>>> The 'Selected Sites' table has SiteID and a much shorter Sites. Can I use Sites on all tables and summaries instead of the long SiteID? Check if all have a "Site" column filled in. Also remove latitude/longitude from that table and have that table expanded by default.
# >>>> Sample size matrix--put options for parameter on that tab.
# >> Map title doesn't show in box b/c it's assuming you have it fully open
# >> Legends of pie matrix should give the threshold values and sample size should be labeled on every pie
# >> Map pies--sample size (total across pie slices) should always be labeled
# >> THreshold page message should show if values for custom are not 999

# -- Have an info button next to each plot to include the bullet text
# -- Do somethinga bout loess...warning??
# >> Make sure user doesn't need to scroll OFF PAGE to see stuff just for a little bit of stuff. Try to keep header in place whenever scrolling.
# >>>> Find a good example site and a story--include censored data, categorical color, streamflow direction... but check how censored data are treated with thresholds
# -- More documentation to explain what to do and what is being shown!!!
# -- GET RID OF UNNECESSARY STEPS IN IMPORT.
# >> [BUG] Sometimes when I go to sample size page and then back to map, the map is screwy
# >>>> Add the data summaries page back in--should include number of DAYS of sampling as well as # of records b/c sometimes they take replicate samples in a day.


# Pull the test page into dashboard after making these fixes
# >>>> Link to EPA state-specific WQ standards: https://www.epa.gov/wqs-tech/state-specific-water-quality-standards-effective-under-clean-water-act-cwa#tb3
# >>>> For showing things on map, add a checkbox to show by-year (median, thresh, percentile) and always add N= sample size over the box for thresh and percentile
# >> Fix the alerts so the boxes only show when there is something important, and so it looks nice
# >>>> [BUG] Hover for points blocks things out. So change that to click, and then hover only gives date and value.
# >>>> [BUG] Move map title
# >>>> [!!!] Pie charts need to indicate sample sizes
# >>>> User can select a year to highlight in seasonal map
# -- Add labels for sites... argument to the addCircleMarkers: labelOptions = labelOptions(noHide = TRUE, fill = FALSE, offset = c(5,2), textsize = "18px", textOnly = TRUE))
# >> With flow category, set default order and color for levels and add a link for user to change that stuff
# > Add notes that quick import is limited to ...

####### >>>>>>>>>>>>>>>>>>>>>>> DEMO
# - Point is to bring all these data together--precip, stream flow, discharge sources, water quality from many agencies within and around a park... as a one-stop shop for information and to generate basic summary plots, tables, and maps for the user to understand trends and patterns in the data and to export them also for their own use
# - Emphasize defaults and quickstart instructions, then follow-up with additional options
# - Additional options
# ... custom seasons
# ... import by distance up/downstream
# ... changing categorical level colors
# ... custom import
# - Add thresholds and link to EPA thresholds info (can also upload a thresholds file)
# - Export plots and tables
# - Help pages
# - Upload saved RDS and then update the RDS with just pulling new data and also save your filter selections to the RDS as your default (starting) values
# - Click map links to see details on monitoring stations, discharge, etc. from other agency sites
# - Plot stream and precip
# - Put multiple plots on one page, change plot height
# - Open plot to full page
# - On maps, see which areas tend to have values in 'poor' category and which years

## UPSTREAM/DOWNSTREAM EXAMPLE WITH LIRI--30KM UPSTREAM, 50 DOWNSTREAM FROM













# GO THROUGH THE 'BEST DASHBOARD' EXAMPLES AND BORROW NICE ELEMENTS
# **Run the dashboard by Brian M., Eric Starkey, the Glacier folks, Brian Gregory, Dean Tucker, Brian Irwin & Spencer, Dusty, Tom Philippi
# Find out what parameters are typically displayed with log-transformed axes. Add alert when some axes are log-transformed.
# [DO FIRST] Fix the alerts so the boxes only show when there is something important, and so it looks nice
# Add a pop-up on load saying that the data are pulled WQP and other publicly available databases. OR PUT THIS ON THE HOME PAGE AND DON'T ALLOW ANYTHING UNLESS/UNTIL THE USER SELECTS "I agree". The dashboard displays the data and data summaries and it not responsible for any mistakes in the data, which should be directed to... By clicking "OK", you agree to....
# >> Move plot options to specific to plots, and put unimportant stuff (title, etc.) in additional plot options
# [DO FIRST] On minicharts, size circles or allow bar plots
# Add labels above sites on maps
# Do not add loess smooth if too many gaps in data
# >> Map should have scrollable y-axis so header not lost
# On map 'show', add color legend for organization
# >> Multiple sites in one plot--it goes wiggy for point plots, and I need to add the legend in
# >> Allow all plots on one panel (then legend needs to work) <<<<---
# Plots should be in order of selection
# >> Color points by characteristic --this option should show only if that is available. Also, then need to show legend. If flow category data, should have default colors set correctly for easy use.
# DONE--For seasonal, use week as the default and create pretty x-axis.
# >> Seasonal plots scrolling should not erase the survey freq options
# >> [DO FIRST] For seasonal point plots, add option to color a (OR 2) particular year of data in point plots--put in big plot, for scatterplots
# Move map title
# >> For thresholds, placeholder should be something else (LIKE BLANK OR NA)
# >> [DO FIRST] Additional plot options--log-transform Y-axis group checkbox selection. 
# >> Once plots are generated, hide weather and gage stations
# >> Hover for points blocks things out. So change that to click, and then hover only gives date and value.
# DONE--Add a page that shows 4-letter park codes, or better yet, allow user to just type part of park name to search
# [MAYBE??] Add Mann-Kendall, using OpenAir but follow wql rules to "flag" but not omit estimates. Run simulations to test validity of results when wql rules are violated. How does OpenAir deal with censored data?


### ON MAIN SCRIPT
# > Warning about different char types should pop up as soon as those are selected, and user should be able to see which sites have which 
# >> Add back in legacy data (where am i filtering it out?)
# >> Jacksonvill TIM 2003-2010 missing from dashboard
# > Allow user to filter by ProjectIdentifier
# > How should I summarize data when they collect replicate samples in a sample event. For example, ACAD collects 10 water temp values in a sample day at a single site.
# > RERUN THE PARKS PULL! I DIDN'T GET ONLY RECENT SITS.
# > Import information should show in a slide-in tab. Before actually getting the data, summarize what the user said they wanted to pull data for (preferably this should happen AS THEY CLICK). When they import an RDS, they should also have this slide-in tab.
# > Update plots instead of re-rendering, to stop the blink
# > Combine filter page with import and use default values
# > Pre-download EPA??
# > Convert sample size matrix into collapsible cards
# > [BUG] Sample size matrix has size limit
# > [BUG] If I load an RDS then I click on new data and begin search and then I go back to existing data, the former RDS is lost
# > number of years with survey data would be more useful, and that should be done by importing station summary information and then filtering stations before highlighting
# > [BUG] I don't have a way to clear selections of sites on map
# > For large data imports, break up the data into groups for import
# > In custom import, allow any site type and characteristic type
# > Check if NOAA stations are in NAD83
# > Check on this... when importing the stations, can we set the characteristic group [sel_CharType] as a filter? If yes, then do this filter up top before showing the available stations.
# > Add a button to see station summaries on Import--Should have a heatplot to show number of sample events (sampling days) for each year and parameter. Users should see this info BEFORE importing
# > Add option for select all/select none for HUCS and import orgs
# > For selecting sites to import by organization, user input should give number of stations next to the org
# > select all/none buttons for HUCs and orgs for impor
# > BUG--map doesn't render properly after "sites" unless I go to the filter page
# > BUG--sample size matrices still have oddities on first and last year
# > [WORKING ON IT] Pre-download recently active (sampled at least once w/in past 5 years) monitoring stations, NOAA precip, and USGS stream gages
# > Provide link to EPA site for relevant thresholds for your state
# > Report Result status for WQP data--specifies if it's provisional or whatever... and perhaps a summary stat of % accepted. Include the WQP disclaimer about using their data.
# > Home page--when click things, map legend should stay turned off if selected that way. Should not reset when switching HUC level
# > *** Import information should show in a slide-in tab. Before actually getting the data, summarize what the user said they wanted to pull data for (preferably this should happen AS THEY CLICK). When they import an RDS, they should also have this slide-in tab.

# > Check on the issue where I remove characteristics with (text)--should those be categorical?

### LONGER TERM PRIORITIES
# > All files saved with dashboard should be reduced to only cols needed
# > Change maps to use leafletProxy to react to input changes: https://stackoverflow.com/questions/46979328/how-to-make-shiny-leaflet-map-reac-to-change-in-input-value-r
# > Allow user to custom pull stream gage and noaa stations (not necessarily recent with 10 years of data)
# > USGS stream gage pulls by HUC8 for problematic ones
# > In custom import, allow any site type and characteristic type
# > Use the thresholds that EPA uses in their How's My Waterway? E.g., pH<6.5, pH>8.5, DO<2. But user needs to specifically choose to apply general EPA thresholds. Can I grab How's My Waterway "impairment" levels? and call it EPA impairment designation??
# > Checkbox for importing data from sites with no recent activity--in this case, goes to old import code
# > If user selects by HUC, have a suboption to select all HUC polygons
# > Need to always use the unit_name[code] b/c codes are replicated for DENA, GAAR, GLBA, GRSA, KATM, LACL, NOCA, WRST
# > Save the URL query so user can simply update the data next time--only need to save the name of the stations though b/c that 'get data' step is the only one that needs to update
# > Incorporate TADA functions into my dashboard!!! (Join their team?)
# > https://rconnect.usgs.gov/dataRetrieval/articles/wqp_large_pull_targets.html   to make an efficient pipeline
# > Add place where user can add/see notes to save to their RDS
# > More error checking and allow user to exclude site-characteristics via filter
# > Link to other waters information?
# - https://watersgeo.epa.gov/watershedreport/?reachcode=03070103001000&measure=67.07822999999999
# - How's my watershed?

### CAVEAT NOTES
# > For WQP stations for a single park, the datums may be NAD83 and WGS84 with possibly some NAD27, OTHER, AND UNKWN. The difference btwn NAD83 and WGS84 is only  about a meter shift, so I'm just going to say they are all NAD83 because that is the most common one.
