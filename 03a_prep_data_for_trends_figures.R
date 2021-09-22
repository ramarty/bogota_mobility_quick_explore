# Bogota IE: Analysis

# Load Data --------------------------------------------------------------------
#### N Daily
n_obs_daily_cb <- readRDS(file.path(cuebiq_dir, "FinalData", "n_obs_daily.Rds"))
n_obs_daily_xm <- readRDS(file.path(xmode_dir, "FinalData", "n_obs_daily.Rds"))

n_obs_daily <- bind_rows(
  n_obs_daily_cb %>% 
    mutate(source = "Cuebiq") %>%
    dplyr::rename(date = date_local) %>%
    dplyr::mutate(date = date %>% ymd()),
  n_obs_daily_xm %>% 
    mutate(source = "X-Mode") %>%
    dplyr::rename(date = location_dt)
) %>%
  dplyr::rename(N_obs = N)

#### N Users
n_users_daily_cb <- readRDS(file.path(cuebiq_dir, "FinalData", "n_user_daily.Rds"))
n_users_daily_xm <- readRDS(file.path(xmode_dir, "FinalData", "n_user_daily.Rds"))

n_users_daily <- bind_rows(
  n_users_daily_cb %>% 
    mutate(source = "Cuebiq") %>%
    dplyr::rename(date = date_local) %>%
    dplyr::mutate(date = date %>% ymd()),
  n_users_daily_xm %>% 
    mutate(source = "X-Mode") %>%
    dplyr::rename(date = location_dt)
) %>%
  dplyr::rename(N_user = N)

#### Mobility
mobility_daily_cb <- readRDS(file.path(cuebiq_dir, "FinalData", "mobility_daily.Rds"))
mobility_daily_xm <- readRDS(file.path(xmode_dir, "FinalData", "mobility_daily.Rds"))

mobility_daily <- bind_rows(
  mobility_daily_cb %>% 
    mutate(source = "Cuebiq") %>%
    dplyr::rename(date = date_local) %>%
    dplyr::mutate(date = date %>% ymd()),
  mobility_daily_xm %>% 
    mutate(source = "X-Mode") %>%
    dplyr::rename(date = location_dt)
) %>%
  dplyr::select(-N_user)

#### Merge
df <- n_obs_daily %>%
  left_join(n_users_daily, by = c("date", "source")) %>%
  left_join(mobility_daily, by = c("date", "source"))

#### Make variables
df <- df %>%
  dplyr::mutate(N_obs_user = N_obs / N_user) %>%
  dplyr::mutate(user_max_dist_mean = user_max_dist_mean * 111.12,
                user_max_dist_mean_ifmoved = user_max_dist_mean_ifmoved * 111.12)

# Export Data ------------------------------------------------------------------
df <- df %>%
  dplyr::select(date, source, N_obs, N_user, N_obs_user, user_max_dist_mean, user_max_dist_mean_ifmoved)

var_label(df$date) <- "Date"
var_label(df$source) <- "Source"
var_label(df$N_obs) <- "N observations"
var_label(df$N_user) <- "N users"
var_label(df$N_obs_user) <- "N observations per user (N_obs/N_user)"
var_label(df$user_max_dist_mean) <- "Movement range, average (km)"
var_label(df$user_max_dist_mean_ifmoved) <- "Movement range, average (km), among users with nonzero movement"

write_dta(df, file.path(proj_dir, "Data", "Mobility - All", "FinalData", "bogota_mobility.dta"))
saveRDS(df, file.path(proj_dir, "Data", "Mobility - All", "FinalData", "bogota_mobility.Rds"))

