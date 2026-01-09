# GIS-based Treeline Modelling Comparison

This repository contains the code for reproducing and comparing four GIS-based treeline modeling methods, developed as part of a master's thesis at the Departement of Geography, University of Zurich 2025:
Locating the Treeline: Terminology, Modelling and Vagueness.


## Abstract

The treeline is a widely used term that appears in various Swiss laws and regulations, often without further specification, implying a general understanding of the term. Scientific literature, however, paints a different picture: an analysis of over 30 publications revealed 72 distinct terms related to the treeline with varying definitions and inconsistencies across the different terms. Correspondence with Swiss authorities also indicated divergent understandings of the term in practice, varying by application context.

This thesis investigates how the treeline can be defined, modelled using GIS methods and spatially visualised, with a particular focus on aspects of vagueness. The objectives are to clarify terminology, evaluate GIS-based modelling approaches, quantify and visualise uncertainty and vagueness in spatial delineation.

A terminology review synthesised definitions from the literature into a framework distinguishing three hierarchical boundaries within the treeline ecotone: the forest line, treeline and shrubline. Four modelling approaches were reproduced and compared using qualitative and quantitative analysis, complemented by testing sensitivity to input data and forest definitions.

The results demonstrate that methods produce differing treeline delineations regardless of whether original or harmonised input data is used. These differences stem from both methodological choices and conceptual ambiguities. Intrinsic vagueness emerges as the primary source of terminological inconsistency and modelling divergence, manifesting as conceptual vagueness and sorites vagueness.

The thesis contributes a terminology framework for the treeline ecotone, a reproducible workflow enabling method comparison under harmonised conditions and a visualisation approach depicting zones of determinacy and indeterminacy across different treeline interpretations, representing vagueness.

## Methods Implemented

- Paulsen & Körner (2001)
- Gehrig-Fasel et al. (2007)
- Szerencsits (2012)
- Nguyen (2025)

## Requirements

### R Packages
```r
# Core spatial
terra
sf
raster
sp

# Data manipulation
dplyr
readr
glue
here

# Spatial operations
exactextractr
lwgeom
nngeo
smoothr
geometry
units

# GIS integration
RSAGA
rgrass
whitebox

# Statistics/modeling
mgcv
gstat
geostats
fields
dbscan

# Utilities
conflicted
digest
Rcpp
future.apply

# Visualization
mapview
RColorBrewer
extrafont

# Custom
myHelpers
```

### myHelpers Package

Custom helper functions (e.g., `download_and_merge_DEM()`). Install from this repo:
```r
devtools::install_local("R/myHelpers")
```
The package was written by me to facilitate some steps.

### External Software

- [SAGA GIS](https://saga-gis.sourceforge.io/) — required for thin plate spline interpolation (Gehrig-Fasel method)

## Data Sources

Source data must be downloaded manually.

### swisstopo

| Dataset | Description | Link |
|---------|-------------|------|
| swissALTI3D | 2m DEM | [swisstopo](https://www.swisstopo.admin.ch/en/height-model-swissalti3d) |
| swissALTIRegio | 10m DEM | [swisstopo](https://www.swisstopo.admin.ch/en/height-model-swissaltiregio) |
| swissTLM3D | Topographic landscape model (forest polygons, single trees) | [swisstopo](https://www.swisstopo.admin.ch/en/landscape-model-swisstlm3d) |
| swissBOUNDARIES3D | National boundaries | [swisstopo](https://www.swisstopo.admin.ch/en/swiss-administrative-boundaries) |
| Vector25 (SMV25) | 1:25k vector map | [swisstopo](https://www.swisstopo.admin.ch/en/maps-geodata-online/vector25.html) |

### Federal Statistical Office (BFS)

| Dataset | Description | Link |
|---------|-------------|------|
| Arealstatistik | Land use statistics (AS85, AS97, AS09, AS18, AS25) | [BFS](https://www.bfs.admin.ch/bfs/de/home/dienstleistungen/geostat/geodaten-bundesstatistik/boden-nutzung-bedeckung-eignung/arealstatistik-schweiz.html) |

### Federal Office for the Environment FOEN

| Dataset | Description | Link |
|---------|-------------|------|
| Einzugsgebiete 2km | catchment areas | [FOEN](https://data.geo.admin.ch/browser/index.html#/collections/ch.bafu.wasser-einzugsgebietsgliederung/items/wasser-einzugsgebietsgliederung) |

### Nguyen (2025)

Required if using original forest classification input:

--> Not publicly available, author may provide data upon request.

## Directory Structure
```
├── R/
│   └── myHelpers/
├── data/
│   ├── source_data/
│   │   ├── swissTLM3D_Einzelbaum.gpkg
│   │   ├── swissTLM3D_BB_Wald.gpkg
│   │   ├── arealstatistik.gpkg
│   │   ├── einzugsgebiete_2km.gpkg
│   │   ├── einzugsgebiete_40km.gpkg
│   │   ├── vector25/
│   │   └── nguyen/
│   ├── processed_data/
│   │   ├── arealstatistik_forest_trees_above_1000m.gpkg
│   │   ├── SMV25_merged_szerencsits.gpkg
│   │   └── einzugsgebiete_ch.gpkg
│   ├── test_region_X/
│   │   ├── DEM_Xm.tif
│   │   ├── paulsen_koerner/
│   │   ├── gehrig_fasel/
│   │   ├── szerencsits/
│   │   └── nguyen/
│   └── Results/
└── Template.qmd
```

## Usage

### 1. Preprocessing (run once, only to speed up processing, not strictly necessary)
```r
preprocess_arealstatistik()
process_vector25_szerencsits()
```

### 2. Define test region

Set `test_region_name` and run the setup chunk. This creates the test region folder and prepares all necessary data.

### 3. Run methods

Each method has its own code chunk with configurable parameters:
```r
config <- list(
  input_dataset = "swissTLM3D",       # "swissTLM3D" or "original"
  category = "closed_open_shrub"      # "closed", "closed_open", "closed_open_shrub"
)
```
Runs are saved in hashed folders based on config parameters for reproducibility tracking.

### 4. Compare results

- **Pixel comparison**: `compare_treeline_methods()`
- **Epsilon bands**: `polygons_to_rasterized_lines()`, `calculate_buffer_overlap()`
- **Elevation histograms**: `calculate_elevation_histograms()`


## License

