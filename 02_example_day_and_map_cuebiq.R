# Bogota IE - Explore Data

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

#### Load Data: Initial
if(F){
  s_df_tmp <- spark_read_parquet(sc,
                                 "test", 
                                 file.path(cuebiq_dir, "RawData", "data",
                                           "country=CO", "date=2020-04-01"),
                                 memory = F)
  
  #### Columns and Types
  df <- s_df_tmp %>% head() %>% as.data.frame()
  spec_with_r <- sapply(df, class)
}

# Load Main Data ---------------------------------------------------------------
s_df <- spark_read_parquet(sc,
                           "test", 
                           file.path(cuebiq_dir, "RawData", "data",
                                     "country=CO"),
                           memory = F) %>%
  sparklyr::filter(lat >= 4.458683,
                   lat <= 4.837979,
                   lon >= -74.222495,
                   lon <= -73.991414)

# Example Day ==================================================================
ex_day <- s_df %>%
  sparklyr::filter(date=="2021-02-03") %>%
  sparklyr::select(lat,lon,timestamp, "__hr_local", device_id) %>%
  as.data.frame() %>%
  dplyr::rename(hr_local = "__hr_local")

saveRDS(ex_day, file.path(cuebiq_dir, "FinalData", "ex_day_sample_varsubset.Rds"))

# Map --------------------------------------------------------------------------
leaflet() %>%
  addTiles() %>%
  addHeatmap(data = ex_day,
             lat = ~lat, 
             lng = ~lon,
             max = 500)

# Example Users ----------------------------------------------------------------
#### Follow user
ex_day <- ex_day %>%
  group_by(device_id) %>%
  dplyr::mutate(N_ad = n()) %>%
  ungroup() %>%
  arrange(desc(N_ad))


user_id_unique <- unique(ex_day$device_id)

for(i in 1:10){
  user_i <- user_id_unique[i]
  
  m <- leaflet() %>%
    addTiles() %>%
    addCircles(data = ex_day[ex_day$device_id %in% user_i,],
               color = "red",
               radius = 10,
               opacity = 1,
               fillOpacity = 1) 

  mapshot(m, file = file.path(figures_dir,
                              "ex_user_cuebiq",
                              paste0("ex_user_",i,".png")))
}


