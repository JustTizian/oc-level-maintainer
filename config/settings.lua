local settings = {}

settings["skip_failed_entry_reads"] = true
settings["show_debug_logs"] = true
settings["sleep_time_in_between_cycles"] = 5
-- "disabled", "bottom", "top", "north", "south", "west", "east"
settings["filter_chest_side"] = "north"
settings["clear_screen_interval_in_cycles"] = 4

return settings
