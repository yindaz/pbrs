% This demo shows the rendering process from whole scene obj model to the
% physically based rendering. You need to install Mitsuba first.

% If 'system' does not work in your matlab, run the script in terminal.
addpath(genpath('matlab'));
config;

serialize_ready = true;

%% From scene OBJ -> serialize template
if ~serialize_ready
    % generate serialized file, this step generates main.xml and main.serialize
    script_generate_serialized;
    % require 'texture' folder from SUNCG in ./rendering/
    system(sprintf('sh %s', [script_path 'cmd_generate_serialized/cmd_1.sh']));

    % create template, this step generate main_color_template.xml
    convert_mtsb_template(1);
end

%% From template -> rendering
% render color image, this step generate *.rgbe and *.png
script_mitsuba_render;
system(sprintf('sh %s', [script_path 'cmd_mtsb_render/cmd_1.sh']));

fprintf('Now you can find rendering in ./rendering/projects_render/');