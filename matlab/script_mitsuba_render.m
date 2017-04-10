config;
serial_path = [output_path 'projects_serialize/'];
camera_path = [output_path 'projects_camera/'];
render_path = [output_path 'projects_render/'];

if ~exist(render_path, 'dir')
    mkdir(render_path);
end

valid = false(length(projects_list),1);
for a = 1:length(projects_list)
    main_tmp_color_path = [serial_path projects_list{a} '/main_template_color.xml'];
    dst_cam_path = [camera_path projects_list{a} '/room_camera.txt'];
    if exist(main_tmp_color_path, 'file') && exist(dst_cam_path, 'file')
        valid(a) = true;
        otp = [render_path projects_list{a}];
        if ~exist(otp, 'dir')
            mkdir(otp);
        end
    end
end

use_two_stage = false;
projects_list = projects_list(valid);
fprintf('%d load, %d valid\n', length(valid), sum(valid));

%%
image_height = 480;
image_width  = 640;
xfov_half    = 0.5534;

% mitsuba_path = 'mitsuba';
dependency = 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH';
number_job = 1;
command_path = [script_path '/cmd_mtsb_render/'];
mkdir(command_path);
allfp = cell(number_job,1);
for a = 1:number_job
    allfp{a} = fopen(sprintf('%scmd_%d.sh', command_path, a), 'w');

    fprintf(allfp{a}, '#!/bin/bash\n');
    fprintf(allfp{a}, '%s\n', dependency);
end

job_count = 0;
for a = 1:length(projects_list)
    main_tmp_color_path = [serial_path projects_list{a} '/main_template_color.xml'];
    dst_cam_path = [camera_path projects_list{a} '/room_camera.txt'];
    dst_camgood_path = [camera_path projects_list{a} '/room_camera_good.txt'];
    
    dst_result_path = [render_path projects_list{a} '/'];
    fileid = rem(a,number_job) + 1;
    fprintf(allfp{fileid}, 'cd %s\n', root_path);
    fprintf(allfp{fileid}, 'python %s -s %s -c %s -o %s -g %s\n', ...
        python_render_path, main_tmp_color_path, dst_cam_path, dst_result_path, dst_camgood_path);
    fprintf(allfp{fileid}, 'cd %s\n', [render_path projects_list{a}]);
    fprintf(allfp{fileid}, 'mtsutil tonemap -p 0.8,0.2 *.rgbe\n');
end

for a = 1:number_job
    fclose(allfp{a});
end
