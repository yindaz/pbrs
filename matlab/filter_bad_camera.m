function filter_bad_camera( id )
config;
camera_path = [output_path 'projects_camera/'];

overwrite = false;

fp = fopen(badroom_file);
M = textscan(fp, '%s');
fclose(fp);
bad_room = M{1}(2:end);

for a = 1:length(projects_list)
    if rem(a,100)+1 == id
        fprintf('%d: %s\n', a, projects_list{a});
        
        camera_name_file = [camera_path projects_list{a} '/room_camera_name.txt'];
        camera_good_file = [camera_path projects_list{a} '/room_camera_good.txt'];
        
        if ~overwrite
            if exist(camera_good_file, 'file')
                fprintf('Exist.\n');
                continue;
            end
        end
        
        if ~exist(camera_name_file, 'file')
            fprintf('No camera file.\n');
            continue;
        end
        
        fp = fopen(camera_name_file);
        M = textscan(fp, '%s');
        fclose(fp);
        
        camera_name = M{1};
        for b = 1:length(camera_name)
            p = strfind(camera_name{b}, '_');
            camera_name{b} = strrep(camera_name{b}(1:p(end)-1), 'Room#', [projects_list{a} '_']);
        end
        
        is_loc_bad_room = ismember(camera_name, bad_room);
        fp = fopen(camera_good_file, 'w');
        fprintf(fp, '%d\n', ~is_loc_bad_room);
        fclose(fp);
        
        fprintf('Done.\n');
    end
end

end

