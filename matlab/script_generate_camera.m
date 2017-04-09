config;

output_path = [output_path 'projects_camera/'];
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

done_job = cell(0,1);
for a = 1:length(projects_list)
    if exist([output_path projects_list{a} '/room_camera_name.txt'],'file')
        done_job{end+1,1} = projects_list{a};
    end
end

I = ismember(projects_list, done_job);
projects_list = projects_list(~I);
fprintf('%d exist, %d valid\n', length(I), length(projects_list));

%%
dependency = 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH';
number_job = 20;
command_path = [script_path 'cmd_generate_cam/'];
if ~exist(command_path, 'dir')
    mkdir(command_path);
end
allfp = cell(number_job,1);
for a = 1:number_job
    allfp{a} = fopen(sprintf('%scmd_%d.sh', command_path, a), 'w');
    fprintf(allfp{a}, '#!/bin/bash\n');
    fprintf(allfp{a}, '%s\n', dependency);
end

for a = 1:length(projects_list)
    target_path = [output_path projects_list{a} '/'];
    fileid = rem(a,number_job) + 1;
    
    fprintf(allfp{fileid}, 'echo ''Start project: %s''\n', projects_list{a});
    fprintf(allfp{fileid}, 'cd %s\n', ...
        [suncg_path 'house/' projects_list{a}]);
    fprintf(allfp{fileid}, 'mkdir %s\n', target_path);
    fprintf(allfp{fileid}, '%s %s %s  -create_room_cameras -output_nodes %s -output_camera_names %s -categories %s -xfov %f -mesa\n', ...
        scn2cam_path, ...
        'house.json', ...
        [target_path '/room_camera.txt'], ...
        [target_path '/room_camera_node.txt'], ...
        [target_path '/room_camera_name.txt'], ...
        mapping_file, ...
        xfov_half);
    
    fprintf(allfp{fileid}, 'echo ''Done''\n'); 
end

for a = 1:number_job
    fclose(allfp{a});
end

