#' tests for a spatial relationship and adds true/false to the new col and displays a progress bar
#' @export
check_spatial_relationship <- function(input_sf, reference_sf, sf_function, column_name) {
  n <- nrow(input_sf)
  pb <- txtProgressBar(min = 0, max = n, style = 3)  # Progress bar

  input_sf <- input_sf %>%
    mutate(!!column_name := sapply(1:n, function(i) {
      setTxtProgressBar(pb, i)
      sf_function(input_sf[i, ], reference_sf, sparse = FALSE)
    }))

  close(pb)  # Close progress bar
  return(input_sf)
}

#' This function compares the crs of two sf objects
#' @export
compare_crs <- function(dataset1, dataset2)
{print(paste0(sf::st_crs(dataset1)$Name,"  |  " , sf::st_crs(dataset2)$Name))}

#' This function joins data from two sf objects
#' @export
join_geodata <- function(base_data, join_data, base_key, join_key, attributes = NULL) {

  # select attributes to join
  if (is.null(attributes)) {
    join_data_selected <- join_data
  } else {
    join_data_selected <- join_data %>% select(tidyselect::all_of(c(join_key, attributes)))
  }

  join_data_df <- st_drop_geometry(join_data_selected)

  joined_data <- base_data %>%
    left_join(join_data_df, by = setNames(join_key, base_key))

  return(joined_data)
}

#' This function generates download links from the swissalti3d product of swisstopo for an input region
#' @export
generate_swissalti3d_urls <- function(region, directory, resolution) {
  bbox <- st_bbox(region)

  # get tile ranges (rounded down to km to get swisstopo grid ID)
  east_range <- floor(bbox$xmin / 1000):floor(bbox$xmax / 1000)
  north_range <- floor(bbox$ymin / 1000):floor(bbox$ymax / 1000)

  # create all tile combinations
  tiles <- expand.grid(e = east_range, n = north_range)

  urls <- glue(
    "https://data.geo.admin.ch/ch.swisstopo.swissalti3d/",
    "swissalti3d_2024_{tiles$e}-{tiles$n}/",
    "swissalti3d_2024_{tiles$e}-{tiles$n}_", resolution, "_2056_5728.tif"
  )

  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  # save csv without header
  writeLines(urls, paste0(directory, "/swisstopo_download_links.csv"))
  print("Download links generated")
}

#' This function reads a csv containing download links for swissalti3d and downloads the .tif files
#' @export

directory = "/Users/michafranz/Desktop/_Masterarbeit/msc_thesis/data/test_region_xx/DEM_2m"
download_files_from_csv <- function(directory) {
  csv_file <- list.files(directory, pattern = "\\.csv$", full.names = TRUE)
  download_links <- readr::read_csv(csv_file, col_names = FALSE)
  names(download_links) <- "download_link"
  tif_files <- list.files(path = directory, pattern = "\\.tif$", full.names = TRUE)

  # Skip if files already downloaded
  if (length(tif_files) > 1) {
    return()
  }

  # All possible years, latest first
  all_years <- c("2024", "2023", "2022", "2021", "2020", "2019",
                 "2018", "2017", "2016", "2015", "2012")
  # link <- download_links$download_link[1]
  for (link in download_links$download_link) {
    file_name <- basename(link)
    destination <- file.path(directory, file_name)
    downloaded <- FALSE
    # year = "2024"
    # Try each year starting with the original link's year
    for (year in all_years) {
      test_link <- gsub("2024", year, link)
      test_file_name <- basename(test_link)
      tryCatch({
        response <- httr::GET(test_link)
        if (httr::status_code(response) == 200) {
          httr::GET(test_link, httr::write_disk(destination, overwrite = TRUE))
          message("Downloaded (", year, "): ", test_file_name)
          downloaded <- TRUE
          break
        }
      }, error = function(e) {
        # Continue to next year
      })
    }

    if (!downloaded) {
      message("Skipped (no available years): ", file_name)
    }
  }
}

#' This function merges all .tif files in a directory
#' @export
merge_raster_files <- function(directory, name, resolution){

  tif_files <- list.files(path = directory, pattern = "\\.tif$", full.names = TRUE)
  raster_list <- vector("list", length(tif_files))

  for (i in seq_along(tif_files)) {
    # store raster in list
    raster_list[[i]] <- rast(tif_files[i])
  }

  # Combine rasters into SpatRasterCollection and merge
  m <- terra::merge(sprc(raster_list))
  writeRaster(m, paste0(directory, "/merged_DEM_", resolution, "m_",name,".tif"), overwrite = TRUE)
  message("Rasters successfully merged")
}

#' This function combines the three functions used to generate download links for swissalti3d, downloading the files and mergin the .tifs
#' @export
download_and_merge_DEM <- function(region, directory, resolution, name){
  generate_swissalti3d_urls(region, directory, resolution)
  download_files_from_csv(directory)
  merge_raster_files(directory, name, resolution)
}

#' This function displays differences of two columns from different datasets
#' @export
compare_column_values <- function(df1, df2, attribute) {
  vals1 <- unique(df1[[attribute]])
  vals2 <- unique(df2[[attribute]])

  only_in_df1 <- setdiff(vals1, vals2)
  only_in_df2 <- setdiff(vals2, vals1)

  if (length(only_in_df1) > 0) {
    cat("Only in DF1:\n")
    print(only_in_df1)
  } else {
    cat("No values unique to DF1.\n")
  }

  if (length(only_in_df2) > 0) {
    cat("Only in DF2:\n")
    print(only_in_df2)
  }
}
