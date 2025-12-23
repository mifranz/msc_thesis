from qgis.core import QgsProject, QgsLayoutExporter

project = QgsProject.instance()
root = project.layerTreeRoot()

GROUPS = {
    "01_paulsen_körner_steps": {
        "layout": "steps",
        "steps": [
            {"name": "01_arealstatistik_all", "visible": ["01_arealstatistik_all"]},
            {"name": "02_arealstat_testregion_forest", "visible": ["02_arealstat_testregion_forest"]},
            {"name": "03_DEM_25m", "visible": ["03_DEM_25m"]},
            {"name": "04_05_grid_and_forest", "visible": ["04_arealstat_forest_testregion_join", "05_grid_10km"]},
            {"name": "05_max_forest_elevation", "visible": ["05_max_forest_elevation"]},
            {"name": "08_treeline_difference", "visible": ["08_gis_treeline_difference"]},
            {"name": "09_treeline_mask", "visible": ["09_gis_treeline_mask"]},
            {"name": "10_treeline_vectorized", "visible": ["10_gis_treeline_vectorized"]},
        ]
    },
    "02_gehrig_fasel_steps": {
        "layout": "steps",
        "steps": [
            {"name": "01_arealstatistik_all", "visible": ["01_arealstatistik_all"]},
            {"name": "04_dem_forest_100m", "visible": ["04_dem_forest_100m"]},
            {"name": "06a_regional_max_forest", "visible": ["06a_regional_max_forest"]},
            {"name": "10b_regional_max_forest_masked_points", "visible": ["10b_regional_max_forest_masked_points"]},
            {"name": "11_max_forest_interpolation", "visible": ["11_max_forest_interpolation"]},
            {"name": "12b_treeline__diff_regional", "visible": ["12b_treeline__diff_regional"]},
            {"name": "13b_treeline_regional_binary", "visible": ["13b_treeline_regional_binary"]},
            {"name": "14b_final_treeline_regional", "visible": ["14b_final_treeline_regional"]},
        ]
    },
    "03_szerencsits_steps": {
        "layout": "steps",
        "steps": [
            {"name": "01_dem_final", "visible": ["01_dem_final"]},
            {"name": "01_Input_Forest", "visible": ["01_Input_Forest"]},
            {"name": "02_slope_smoothed", "visible": ["02_slope_smoothed"]},
            {"name": "05a_slope_catchment_intersection_merged_byArea", "visible": ["05a_slope_catchment_intersection_merged_byArea"]},
            {"name": "06_forest_altitude", "visible": ["06_forest_altitude"]},
            {"name": "07_slope_zone_max_alt_forest", "visible": ["07_slope_zone_max_alt_forest"]},
            {"name": "08_slope_zone_diff_forest", "visible": ["08_slope_zone_diff_forest"]},
            {"name": "09_slope_zone_diff_binary_forest", "visible": ["09_slope_zone_diff_binary_forest"]},
            {"name": "10_forest_altitude_focal_max_1000m", "visible": ["10_forest_altitude_focal_max_1000m"]},
            {"name": "11_mov_window_diff_forest", "visible": ["11_mov_window_diff_forest"]},
            {"name": "12_mov_window_diff_binary_forest", "visible": ["12_mov_window_diff_binary_forest"]},
            {"name": "13_combined_forest", "visible": ["13_combined_forest"]},
            {"name": "14_final_forestline", "visible": ["14_final_forestline"]},
        ]
    },
    "04_nguyen_steps": {
        "layout": "steps",
        "steps": [
            {"name": "00b_C_long", "visible": ["00b_C_long"]},
            {"name": "01b_forest_elev_cLong", "visible": ["01b_forest_elev_cLong"]},
            {"name": "02a_forestline_limit_rast", "visible": ["02a_forestline_limit_rast"]},
            {"name": "02b_timberline_limit_rast", "visible": ["02b_timberline_limit_rast"]},
            {"name": "03a_diff_rast_forest", "visible": ["03a_diff_rast_forest"]},
            {"name": "03b_diff_rast_timber", "visible": ["03b_diff_rast_timber"]},
            {"name": "5_lines_combined", "visible": ["5_lines_combined"]},
            {"name": "7_realized_treeline_nguyen", "visible": ["7_realized_treeline_nguyen"]},
        ]
    },
}

def get_subgroup(path):
    node = root
    for part in path.split('/'):
        node = node.findGroup(part)
        if not node:
            return None
    return node

def set_step_visibility(subgroup, step):
    for child in subgroup.children():
        child.setItemVisibilityChecked(child.name() in step["visible"])

def hide_all_layers(subgroup):
    for child in subgroup.children():
        child.setItemVisibilityChecked(False)

for group_name, config in GROUPS.items():
    group_path = f"test_region_3/{group_name}"
    subgroup = get_subgroup(group_path)
    
    if not subgroup:
        print(f"Group not found: {group_path}")
        continue
    
    layout = project.layoutManager().layoutByName(config["layout"])
    if not layout:
        print(f"Layout not found: {config['layout']}")
        continue
    
    output_dir = f"/Users/michafranz/Desktop/_Masterarbeit/Grafiken/thesis/{group_name}"
    
    for step in config["steps"]:
        set_step_visibility(subgroup, step)
        layout.refresh()
        
        exporter = QgsLayoutExporter(layout)
        settings = QgsLayoutExporter.ImageExportSettings()
        settings.dpi = 100
        
        exporter.exportToImage(f"{output_dir}/{step['name']}.png", settings)
        print(f"Exported {group_name}/{step['name']}")
        
    hide_all_layers(subgroup)