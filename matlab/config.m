root_path = '~/pbrs_release/render/';

mitsuba_path = [root_path '/mitsuba-af602c6fd98a/dist/'];
suncg_path = [root_path '/planner5d/'];
gaps_path = [root_path '/gaps/'];
output_path = [root_path '/rendering/'];

% load([root_path '/util_data/projects_list.mat']);
load([root_path '/util_data/projects_list_short.mat']);

mapping_file = [root_path '/util_data/ModelCategoryMappingNewActive.csv'];
badroom_file = [root_path '/util_data/bad_room.txt'];
lighting_file = [root_path '/util_data/light_geometry_compact.mat'];
script_path = [root_path '/matlab/'];

xfov_half = 0.5534;

%%%%%%%%%%%%%
scn2cam_path = [gaps_path '/bin/x86_64/scn2cam'];
scn2img_path = [gaps_path '/bin/x86_64/scn2img'];
mtsimport_path = [mitsuba_path 'mtsimport'];
python_render_path = [root_path 'mitsuba_render.py'];