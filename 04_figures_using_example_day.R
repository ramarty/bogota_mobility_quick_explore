# Bogota IE: Analysis

# Load Data --------------------------------------------------------------------
exday_cb <- readRDS(file.path(cuebiq_dir, "FinalData", "ex_day_sample_varsubset.Rds"))
exday_xm <- readRDS(file.path(xmode_dir, "FinalData", "ex_day_sample_varsubset.Rds"))

exday_xm$local_datetime <- exday_xm$local_location_at %>% str_replace_all("\\.[:digit:]{3}", "") %>% ymd_hms()
exday_xm$hr_local <- exday_xm$local_datetime %>% hour()

# Hourly -----------------------------------------------------------------------
hourly_cb <- exday_cb %>%
  group_by(hr_local) %>%
  dplyr::summarise(N = n()) %>%
  dplyr::mutate(prop = N / sum(N),
                source = "Cuebiq",
                hr_local = hr_local %>% as.numeric) 

hourly_xm <- exday_xm %>%
  group_by(hr_local) %>%
  dplyr::summarise(N = n()) %>%
  dplyr::mutate(prop = N / sum(N),
                source = "X-Mode") 

hourly_df <- bind_rows(
  hourly_cb,
  hourly_xm
)

hourly_df %>% 
  ggplot() + 
  geom_col(aes(x = hr_local,
               y = prop,
               fill = source)) +
  labs(x = "Hour",
       y = "Proportion") +
  scale_fill_manual(values = c("dodgerblue2",
                                "darkorange")) +
  theme(legend.position = "none") +
  facet_wrap(~source) 
ggsave(filename = file.path(figures_dir, "hourly_obs.png"), height = 5, width = 8)

# Speed ------------------------------------------------------------------------
exday_xm %>%
  ggplot() +
  geom_histogram(aes(x = speed)) +
  labs(x = "Speed (meters/second)",
       y = "N") +
  scale_y_continuous(label = comma)
ggsave(filename = file.path(figures_dir, "xmode_speed.png"), height = 5, width = 8)

exday_xm %>%
  dplyr::filter(speed > 0) %>%
  ggplot() +
  geom_histogram(aes(x = speed)) +
  labs(x = "Speed (meters/second)",
       y = "N") +
  scale_y_continuous(label = comma)
ggsave(filename = file.path(figures_dir, "xmode_speed_if_moving.png"), height = 5, width = 8)



