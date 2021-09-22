# Density Along Road in North

# Setup ------------------------------------------------------------------------

#### Start Session
sc <- spark_connect(master = "local")

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

# Process Datasets =============================================================

# Example Data -----------------------------------------------------------------
ex_data <- s_df %>%
  sparklyr::filter(location_dt == "2021-01-10") %>%
  sdf_sample(fraction = 0.0001) %>%
  as.data.frame()

saveRDS(ex_data, file.path(xmode_dir, "FinalData", "example_data.Rds"))

# Observations by Day ----------------------------------------------------------
nrow_daily <- s_df %>%
  dplyr::group_by(location_dt) %>%
  dplyr::summarise(N = n()) %>%
  collect
saveRDS(nrow_daily, file.path(xmode_dir, "FinalData", "n_obs_daily.Rds"))

# N Users by Day ---------------------------------------------------------------
nrow_user_daily <- s_df %>%
  sparklyr::distinct(obfuscated_advertiser_id, location_dt) %>%
  dplyr::group_by(location_dt) %>%
  dplyr::summarise(N = n()) %>%
  collect

saveRDS(nrow_user_daily, file.path(xmode_dir, "FinalData", "n_user_daily.Rds"))

# Mobility Over Time -----------------------------------------------------------
mobility_daily_df <- s_df %>%
  dplyr::group_by(obfuscated_advertiser_id, location_dt) %>%
  dplyr::summarise(user_max_dist = sqrt((max(latitude) - min(latitude))^2 + (max(longitude) - min(longitude))^2)) %>%
  dplyr::group_by(location_dt) %>%
  dplyr::summarise(user_max_dist_mean = mean(user_max_dist),
                   user_max_dist_mean_ifmoved = mean(user_max_dist[user_max_dist > 0]),
                   N_user = n()) %>%
  collect

saveRDS(mobility_daily_df, file.path(xmode_dir, "FinalData", "mobility_daily.Rds"))

