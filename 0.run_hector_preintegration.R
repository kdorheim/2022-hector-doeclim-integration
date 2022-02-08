# Run Hector v3 pre the doeclim inntegration
#
# IMPORTANT! This scipt needs to be run from a specific version of Hector.
# commit 6048e45716af7b11254cc2e4bf21f8ea02749e66 (HEAD -> land_tracking, origin/land_tracking)
# devtools::load_all()
library(dplyr)

# Select the scenarios to run.
files <- list.files(here::here("inst", "input"), pattern = "ini", full.names = TRUE)

# Run hector and extract the outputs!
lapply(files, function(f){
    n <- gsub(pattern = "hector_|.ini", replacement = "", basename(f))
    core <- newcore(f, name = n)
    run(core)
    vars <- c(GLOBAL_TEMP(), LAND_AIR_TEMP(), OCEAN_AIR_TEMP(), OCEAN_SURFACE_TEMP(), TEMP_HL(), TEMP_LL(),
              PH_HL(), PH_LL(), CO3_HL(), CO3_LL(), PCO2_HL(), PCO2_LL(), OCEAN_CFLUX(), OCEAN_C_HL(), OCEAN_C_LL(),
              OCEAN_C_IO(), OCEAN_C_DO(), ATM_OCEAN_FLUX_HL(), ATM_OCEAN_FLUX_LL(), DIC_HL(), DIC_LL(), NPP())
    out <- fetchvars(core, dates = 1850:2100, vars = vars)
    out$version <- "land-tracking"

    return(out)
}) %>%
    do.call(what = "rbind") ->
    out

# Save the Hector results to doeclim_integration, the working directory for this repository.
write.csv(out, "hector_land-tracking.csv", row.names = FALSE)
