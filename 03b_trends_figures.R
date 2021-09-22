# Bogota IE: Analysis

# Load Data --------------------------------------------------------------------
df <- readRDS(file.path(proj_dir, "Data", "Mobility - All", "FinalData", "bogota_mobility.Rds"))

# Figures ----------------------------------------------------------------------
df %>%
  ggplot() +
  geom_line(aes(x = date,
                y = N_obs,
                color = source)) +
  scale_y_continuous(label=comma) +
  labs(color = "Source",
       title = "N Observations (Daily)",
       y = "N",
       x = NULL) +
  scale_color_manual(values = c("dodgerblue2",
                                "darkorange"))
ggsave(filename = file.path(figures_dir, "n_obs.png"), height = 5, width = 8)

df %>%
  ggplot() +
  geom_line(aes(x = date,
                y = N_user,
                color = source)) +
  scale_y_continuous(label=comma) +
  labs(color = "Source",
       title = "N Users (Daily)",
       y = "N",
       x = NULL) +
  scale_color_manual(values = c("dodgerblue2",
                                "darkorange"))
ggsave(filename = file.path(figures_dir, "n_user.png"), height = 5, width = 8)

df %>%
  ggplot() +
  geom_line(aes(x = date,
                y = N_obs_user,
                color = source)) +
  scale_y_continuous(label=comma) +
  labs(color = "Source",
       title = "N Observations per User, Average (Daily)",
       y = "Kilometers",
       x = NULL) +
  scale_color_manual(values = c("dodgerblue2",
                                "darkorange"))
ggsave(filename = file.path(figures_dir, "n_obs_per_user.png"), height = 5, width = 8)

# user_max_dist_mean_ifmoved
df %>%
  ggplot() +
  geom_line(aes(x = date,
                y = user_max_dist_mean,
                color = source,
                size = source)) +
  scale_y_continuous(label=comma) +
  labs(color = "Source",
       size = "Source",
       title = "Average Movement Range (Daily)",
       y = "Kilometers",
       x = NULL) +
  scale_color_manual(values = c("dodgerblue2",
                                "darkorange")) +
  scale_size_manual(values = c(0.6, 0.25)) 
ggsave(filename = file.path(figures_dir, "mobility.png"), height = 5, width = 8)


