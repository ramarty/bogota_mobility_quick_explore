# Bogota IE - Explore Data

# https://therinspark.com/starting.html

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

# Load Main Data ---------------------------------------------------------------
s_df <- spark_read_parquet(sc,
                           "test", 
                           file.path(cuebiq_dir, "RawData", "data",
                                     "country=CO"),
                           memory = F) %>%
  sparklyr::filter(lat >= 4.458683,
                   lat <= 4.837979,
                   lon >= -74.222495,
                   lon <= -73.991414,
                   date != "2020-01-05") %>% # issue with this parquet file
  dplyr::rename(date_local = "__date_local") %>%
  dplyr::rename(hr_local = "__hr_local") 
  
# Process Datasets =============================================================

# Example Data -----------------------------------------------------------------
ex_data <- s_df %>%
  sparklyr::filter(date=="2020-01-01") %>%
  sdf_sample(0.00001) %>%
  as.data.frame()

saveRDS(ex_data, file.path(cuebiq_dir, "FinalData", "example_data.Rds"))

# Observations by Day ----------------------------------------------------------
nrow_daily <- s_df %>%
  dplyr::group_by(date_local) %>%
  dplyr::summarise(N = n()) %>%
  collect

saveRDS(nrow_daily, file.path(cuebiq_dir, "FinalData", "n_obs_daily.Rds"))

# Observations by Day-Hour -----------------------------------------------------
nrow_daily_hourly <- s_df %>%
  dplyr::group_by(date_local, hr_local) %>%
  dplyr::summarise(N = n()) %>%
  collect

saveRDS(nrow_daily_hourly, file.path(cuebiq_dir, "FinalData", "n_obs_daily_hourly.Rds"))

# N Users by Day ---------------------------------------------------------------
nrow_user_daily <- s_df %>%
  sparklyr::distinct(device_id, date_local) %>%
  dplyr::group_by(date_local) %>%
  dplyr::summarise(N = n()) %>%
  collect

saveRDS(nrow_user_daily, file.path(cuebiq_dir, "FinalData", "n_user_daily.Rds"))

# Mobility Over Time -----------------------------------------------------------
mobility_daily_df <- s_df %>%
  sparklyr::filter(!is.na(lon),
                   !is.na(lon)) %>%
  dplyr::group_by(date_local, device_id) %>%
  dplyr::summarise(user_max_dist = sqrt((max(lat) - min(lat))^2 + (max(lon) - min(lon))^2)) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(date_local) %>%
  dplyr::summarise(user_max_dist_mean = mean(user_max_dist),
                   user_max_dist_mean_ifmoved = mean(user_max_dist[user_max_dist > 0]),
                   N_user = n()) %>%
  collect

saveRDS(mobility_daily_df, file.path(cuebiq_dir, "FinalData", "mobility_daily.Rds"))

