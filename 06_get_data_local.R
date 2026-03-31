# Set working directly to script location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)

# List of coverage files in the specified directory
cov_files_unmod <- list.files(path = "05-methylationCalls", pattern = "*.cov", full.names = TRUE)

# ID empty files
empty_files <- cov_files_unmod[file.info(cov_files_unmod)$size < 21]

# Export list of empty files (failed samples)
writeLines(empty_files, "dataFiles/06_methyl_fails.txt")

# Remove empty files from the list
cov_files <- setdiff(cov_files_unmod, empty_files)

# Read in all .cov files to df
methyl_data <- map_dfr(cov_files, 
                       ~ read_tsv(.x, 
                                  show_col_types = FALSE,
                                  col_names = c("chr", "pos", "end_pos", "meth_pct", "meth_count", "unmeth_count")) %>%
                        mutate(sample = sub("_.*", "", basename(.x)),
                               site_id = paste0(chr, ":", pos, "-", end_pos)))

# Save object
saveRDS(methyl_data, file = "dataFiles/06_methyl_data.rds")

# End script
