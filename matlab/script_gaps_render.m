
config;
camera_path = [output_path '/projects_camera/'];
output_path = [output_path '/projects_render/'];

valid = false(length(projects_list),1);
camexist = false(length(projects_list),1);
for a = 1:length(projects_list)
    dst_cam_path = [camera_path projects_list{a} '/room_camera.txt'];
    
    if exist(dst_cam_path, 'file')
        camexist(a) = true;
        camera = load(dst_cam_path);
        for kkk = 1:size(camera,1)
            last_file = [output_path projects_list{a} sprintf('/%06d_color.jpg', kkk-1)];
            if ~exist(last_file, 'file')
                valid(a) = true;
                break;
            end
        end   
    end
    
end
projects_list = projects_list(valid);
fprintf('%d projects load, %d valid\n', length(valid), sum(valid));

%%
dependency = 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH';
number_job = 200;
command_path = [script_path '/cmd_gaps_render/'];
mkdir(command_path);
allfp = cell(number_job,1);
for a = 1:number_job
    allfp{a} = fopen(sprintf('%scmd_%d.sh', command_path, a), 'w');
    
    fprintf(allfp{a}, '#!/bin/bash\n');
    fprintf(allfp{a}, '%s\n', dependency);
end

for a = 1:length(projects_list)
    fileid = rem(a,number_job) + 1;   
    target_path = [output_path projects_list{a} '/'];
    
    fprintf(allfp{fileid}, 'cd %s\n', [suncg_path 'house/' projects_list{a}]);

    fprintf(allfp{fileid}, sprintf('%s %s %s %s -categories %s -capture_color_images -capture_depth_images -capture_normal_images -capture_node_images -width 640 -height 480 -headlight -mesa\n', ...
            scn2img_path, ...
            'house.json', ...
            [camera_path projects_list{a} '/room_camera.txt'], ...
            [output_path projects_list{a} '/'], ...
            mapping_file));
end

for a = 1:number_job
    fclose(allfp{a});
end
