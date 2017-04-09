function convert_camera_normal( id )
%Convert normal map in camera coordinate

config;
camera_path = [output_path '/projects_camera/'];
render_path = [output_path '/projects_render/'];

for i = id:100:length(projects_list)
    fprintf('id: %d, project: %s\b', i, projects_list{i});
    
    camera_file_path = [camera_path projects_list{i} '/room_cam.txt'];
    render_location  = [render_path projects_list{i} '/'];
    if ~exist(camera_file_path, 'file') || ~exist(render_location,'dir')
        continue;
    end
    
    render_camera = load(camera_file_path);
    for a = 1:size(render_camera,1)
        fprintf('%06d\n', a);
        normal_x_file = sprintf('%s%06d_xnormal.png', render_location, a-1);
        normal_y_file = sprintf('%s%06d_ynormal.png', render_location, a-1);
        normal_z_file = sprintf('%s%06d_znormal.png', render_location, a-1);
        if ~exist(normal_x_file,'file') || ~exist(normal_y_file,'file') || ~exist(normal_z_file,'file')
            continue;
        end
        
        valid_file_path = sprintf('%s%06d_valid.png', render_location, a-1);
        cam_norm_filename = sprintf('%s%06d_norm_camera.png', render_location, a-1);
        ali_norm_filename = sprintf('%s%06d_norm_align.png', render_location, a-1);
        
        normx = double(imread(normal_x_file));
        normy = double(imread(normal_y_file));
        normz = double(imread(normal_z_file));
        camera = render_camera(a,:);
        
        cam_eye = camera(1:3);
        cam_twd = camera(4:6);
        cam_ups = camera(7:9);
        t = cross(cam_twd, cam_ups, 2);
        R_c2w = [t' cam_twd' cam_ups'];
        R_w2c = R_c2w';
        
        norm_w = [reshape(normx/65535*2-1, 1, []); ...
                    reshape(normy/65535*2-1, 1, []); ...
                    reshape(normz/65535*2-1, 1, [])];
        invalid_mask = reshape(abs(sum(norm_w.^2,1)-1)>0.1, size(normx));
        v_map = uint8(~invalid_mask)*255;
        imwrite(v_map, valid_file_path);
        
        norm_c = R_w2c * norm_w;
        norm_c_map = reshape(norm_c', [size(normx) 3]);
        
        cam_z = [0 0 1];
        [~,k] = max(abs(cam_twd));
        cam_y = zeros(1,3); cam_y(k) = sign(cam_twd(k));
        cam_x = cross(cam_y, cam_z, 2);
        R_a2w = [cam_x' cam_y' cam_z'];
        R_w2a = R_a2w';
        
        norm_a = R_w2a * norm_w;
        norm_a_map = reshape(norm_a', [size(normx) 3]);
        
        c_map = uint16(min((norm_c_map+1)*65535/2, 65535));
        a_map = uint16(min((norm_a_map+1)*65535/2, 65535));
        imwrite(c_map, cam_norm_filename);
        imwrite(a_map, ali_norm_filename);

    end
end

fprintf('Done!\n');

end

