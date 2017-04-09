function convert_instance_boundary( id )
%Convert instance segmentation to instance boundary map

config;
render_path = [output_path '/projects_render/'];

for i = id:100:length(projects_list)
    fprintf('id: %d, project: %s\b', i, projects_list{i});
    
    render_location  = [render_path projects_list{i} '/'];
    if ~exist(render_location,'dir')
        continue;
    end
    
    node_list = dir([render_location '*_node.png']);
    for a = 1:length(node_list)
        fprintf('%06d\n', a);
        
        node_image = imread([render_location node_list(a).name]);
        inst_bound = seg2bdry(node_image, 'imageSize');
        
        save_path = [render_location node_list(a).name(1:6) '_instance_boundary.png'];
        imwrite(inst_bound, save_path);
    end
end

fprintf('Done!\n');

end

