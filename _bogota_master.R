# Bogota IE - Master

RUN_CODE <- F

# Notes ------------------------------------------------------------------------
# ASSUMES FOLLOWING FOLDER STRUCTURE:

# /Bogota IE

# --/Data
# ----/Cuebiq
# ------/RawData
# ------/FinalData
# ----/xmode
# ------/RawData
# ------/FinalData
# ----/Mobility - All
# ------/FinalData

# --/Outputs
# ----/figures
# ------/ex_user_cuebiq
# ------/ex_user_xmode

# File Paths -------------------------------------------------------------------
if(Sys.info()[["user"]] == "robmarty"){
  proj_dir <- file.path("/Volumes", "robmartyexternal", "Bogota IE")
  git_dir <- "~/Documents/Github/bogota_mobility_quick_explore"
} 
  
cuebiq_dir  <- file.path(proj_dir, "Data", "Cuebiq")
xmode_dir   <- file.path(proj_dir, "Data", "xmode")
figures_dir <- file.path(proj_dir, "Outputs", "figures")

# Packages ---------------------------------------------------------------------
library(sparklyr)
library(purrr)
library(ggplot2)
library(lubridate)
library(dplyr)
library(leaflet)
library(leaflet.extras)
library(mapview)
library(stringr)
library(scales)
library(haven)
library(labelled)

# Set JAVA to version 8 --------------------------------------------------------
# Needed for spark to work

# https://mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
# /usr/libexec/java_home -V
Sys.setenv(JAVA_HOME = "/Library/Java/JavaVirtualMachines/jdk1.8.0_161.jdk/Contents/Home")
system("java -version")
# spark_install()
# spark_web(sc)

# Code -------------------------------------------------------------------------
if(RUN_CODE){
  
  # Create aggregated datasets (eg, data aggegrated to daily level)
  # NOTE: xmode code takes a few hours to run
  source(file.path(git_dir, "01_cuebiq_make_datasets.R"))
  source(file.path(git_dir, "01_xmode_make_datasets.R"))
  
  # Create a dataset for an example day and make maps using the 
  # example day
  source(file.path(git_dir, "02_example_day_and_map_cuebiq.R"))
  source(file.path(git_dir, "02_example_day_and_map_xmode.R"))
  
  # Prep aggregated data for figures and make the figures 
  # (eg, for figure showing N observations over time)
  source(file.path(git_dir, "03a_prep_data_for_trends_figures.R"))
  source(file.path(git_dir, "03b_trends_figures.R"))
  
  # Make figures using example day data (eg, prop observations by hour)
  source(file.path(git_dir, "04_figures_using_example_day.R"))
}

