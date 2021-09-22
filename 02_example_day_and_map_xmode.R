# Density Along Road in North

# Setup ------------------------------------------------------------------------
#### Set JAVA to version 8
# https://mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
# /usr/libexec/java_home -V
Sys.setenv(JAVA_HOME = "/Library/Java/JavaVirtualMachines/jdk1.8.0_161.jdk/Contents/Home")
system("java -version")
# spark_install()
# spark_web(sc)

#### Start Session
sc <- spark_connect(master = "local")

#### Example Data
if(F){
  s_tmp_df <- spark_read_parquet(sc,
                                 "test", 
                                 file.path(xmode_dir, "RawData", "data",
                                           "final_country=CO",
                                           "location_dt=2021-01-01"),
                                 memory = F) %>%
    head() %>%
    as.data.frame()
}

# Load Main Data ---------------------------------------------------------------
# Boundaries of Bogota
lat_min <- 4.458683
lat_max <- 4.837979
lon_min <- -74.222495
lon_max <- -73.991414

s_df <- spark_read_parquet(sc,
                           "test", 
                           file.path(xmode_dir, "RawData", "data",
                                     "final_country=CO"),
                           memory = F) %>%
  sparklyr::filter(latitude >= lat_min,
                   latitude <= lat_max,
                   longitude >= lon_min,
                   longitude <= lon_max)

# Example Day ==================================================================
ex_day <- s_df %>%
  sparklyr::filter(location_dt %in% c("2021-02-03")) %>%
  sdf_sample(fraction = 0.25, replacement = F) %>%
  sparklyr::select(latitude,longitude, speed, local_location_at, obfuscated_advertiser_id) %>%
  as.data.frame() 

saveRDS(ex_day, file.path(xmode_dir, "FinalData", "ex_day_sample_varsubset.Rds"))

# Map --------------------------------------------------------------------------
ex_day <- ex_day %>%
  dplyr::mutate(speed_kmhr = speed * 3.6)

ex_day$speed_kmhr[ex_day$speed_kmhr >= 80] <- 80

leaflet() %>%
  addTiles() %>%
  addHeatmap(data = ex_day,
             lat = ~latitude, 
             lng = ~longitude,
             max = 1000)

# Example Users ----------------------------------------------------------------
#### Follow user
ex_day <- ex_day %>%
  group_by(obfuscated_advertiser_id) %>%
  dplyr::mutate(N_ad = n()) %>%
  ungroup() %>%
  arrange(desc(N_ad))

# EXAMPLES: do they cross road using footbridge? Car/pedestrian by speed
user_id_unique <- unique(ex_day$obfuscated_advertiser_id)

for(i in 1:10){
  user_i <- user_id_unique[i]
  
  pal <- colorNumeric(
    palette = "RdYlGn",
    domain = ex_day$speed_kmhr)
  
  m <- leaflet() %>%
    addTiles() %>%
    addCircles(data = ex_day[ex_day$obfuscated_advertiser_id %in% user_i,],
               color = "black",
               radius = 35,
               opacity = 1,
               fillOpacity = 1) %>%
  addCircles(data = ex_day[ex_day$obfuscated_advertiser_id %in% user_i,],
             color = ~pal(speed_kmhr),
             opacity = 1,
             fillOpacity = 1) %>%
  leaflet::addLegend("topright", 
                     title = "Speed\n(km/hr)",
                     pal = pal, 
                     values = ex_day$speed_kmhr[!is.na(ex_day$speed_kmhr)])
  
  mapshot(m, file = file.path(figures_dir,
                              "ex_user_xmode",
                              paste0("ex_user_",i,".png")))
}

