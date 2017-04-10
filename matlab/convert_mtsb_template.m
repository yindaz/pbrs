function convert_mtsb_template( id )
config;
addpath('xmlModify');
serial_path = [output_path '/projects_serialize/'];

fp = fopen(mapping_file);
M = textscan(fp, '%s %s %s %s %s %s %s %s %s','Delimiter',',');
fclose(fp);
window_id_2 = ismember(M{3}, {'window','windows'}) | ismember(M{4}, {'window','windows'}) | ismember(M{6}, {'window','windows'});
door_id_2   = ismember(M{3}, {'door'}) | ismember(M{4}, {'door'}) | ismember(M{6}, {'door'});
plant_id = ismember(M{3}, {'plants'}) | ismember(M{4}, {'plants'}) | ismember(M{6}, {'plants'});
people_id = ismember(M{3}, {'person','people'}) | ismember(M{4}, {'person','people'}) | ismember(M{6}, {'person','people'});

% objects need to be set as transparent
pure_trans_id = M{2}(window_id_2 | door_id_2);
% objects need to be removed
remove_trans_id = M{2}(plant_id | people_id);
% get light bulb and shade material
load(lighting_file);
for a = 1:length(light_geometry_compact)
    bulb_mat_name = light_geometry_compact(a).bulb;
    shade_mat_name= light_geometry_compact(a).shade;
    bulb_id = zeros(length(bulb_mat_name),1);
    shade_id = zeros(length(shade_mat_name),1);
    for b = 1:length(bulb_mat_name)
        bulb_id(b) = str2num(bulb_mat_name{b}(end));
    end
    for b = 1:length(shade_mat_name)
        shade_id(b) = str2num(shade_mat_name{b}(end));
    end
    light_geometry_compact(a).bulb_id = bulb_id;
    light_geometry_compact(a).shade_id = shade_id;
end


for a = 1:length(projects_list)
    if rem(a,1)+1 == id
        fprintf('%d: %s\n', a, projects_list{a});
        
        main_mtl_path = [serial_path projects_list{a} '/' projects_list{a} '.mtl'];
        main_xml_path = [serial_path projects_list{a} '/main.xml'];
        main_tmp_color_path = [serial_path projects_list{a} '/main_template_color.xml'];
        
        if ~exist(main_mtl_path, 'file') || ~exist(main_xml_path, 'file')
            fprintf('File missing! Next...\n');
            continue;
        end

        xDoc = xmlread(main_xml_path);
        % convert material two be two-sided
        xDoc = modifyTwosidedMaterial(xDoc);
        % set transparent material
        xDoc = modifyTransparentMaterial(main_mtl_path, xDoc, pure_trans_id);
        % set emissive for light bulb and shade
        xDoc = modifyLightSource(main_mtl_path, light_geometry_compact, xDoc);
        % remove geometries 
        xDoc = modifyRemoveCategory(xDoc, remove_trans_id);
        % set up default texture
        xDoc = modifyTexture(xDoc);
        sceneItem = xDoc.getElementsByTagName('scene');

        % color
        integratorItem = xDoc.getElementsByTagName('integrator');
        assert(integratorItem.getLength == 1)
        for k = 0:integratorItem.getLength-1
           thisIntegratorItem = integratorItem.item(k);
           % Get the label element. In this file, each
           % listitem contains only one label.
           thisIntegratorItem.setAttribute('type','mlt');
           integratorHideEmittersNode = xDoc.createElement('boolean');
           integratorHideEmittersNode.setAttribute('name', 'hideEmitters');
           integratorHideEmittersNode.setAttribute('value', 'true');
           thisIntegratorItem.appendChild(integratorHideEmittersNode);

           integratorDepthNode = xDoc.createElement('boolean');
           integratorDepthNode.setAttribute('name', 'manifold');
           integratorDepthNode.setAttribute('value', 'true');
           thisIntegratorItem.appendChild(integratorDepthNode);
           
           integratorDirectSampleNode = xDoc.createElement('integer');
           integratorDirectSampleNode.setAttribute('name', 'directSamples');
           integratorDirectSampleNode.setAttribute('value', '512');
           thisIntegratorItem.appendChild(integratorDirectSampleNode);
           
           integratorStrictNormalNode = xDoc.createElement('boolean');
           integratorStrictNormalNode.setAttribute('name', 'strictNormals');
           integratorStrictNormalNode.setAttribute('value', 'true');
           thisIntegratorItem.appendChild(integratorStrictNormalNode);
           
        end

        % emitter
        emitterNode = xDoc.createElement('emitter');
        emitterNode.setAttribute('type', 'envmap');
        emitterScaleNode = xDoc.createElement('float');
        emitterScaleNode.setAttribute('name', 'scale');
        emitterScaleNode.setAttribute('value', '$emitter_scale');
        emitterFileNode = xDoc.createElement('string');
        emitterFileNode.setAttribute('name', 'filename');
        emitterFileNode.setAttribute('value', '$envmap_path');
        emitterNode.appendChild(emitterScaleNode);
        emitterNode.appendChild(emitterFileNode);

        sceneItem.item(0).appendChild(emitterNode);

        % camera
        sensorElement = xDoc.createElement('sensor');
        sensorElement.setAttribute('id', 'Camera_view');
        sensorElement.setAttribute('type', 'perspective');

        fovElement = xDoc.createElement('float');
        fovElement.setAttribute('name', 'fov');
        fovElement.setAttribute('value', '$fov');
        sensorElement.appendChild(fovElement);

        nearClipElement = xDoc.createElement('float');
        nearClipElement.setAttribute('name', 'nearClip');
        nearClipElement.setAttribute('value', '0.0000001');
        sensorElement.appendChild(nearClipElement);

        farClipElement = xDoc.createElement('float');
        farClipElement.setAttribute('name', 'farClip');
        farClipElement.setAttribute('value', '1000000');
        sensorElement.appendChild(farClipElement);

        fovAxisElement = xDoc.createElement('string');
        fovAxisElement.setAttribute('name', 'fovAxis');
        fovAxisElement.setAttribute('value', 'x');
        sensorElement.appendChild(fovAxisElement);

        transformElement = xDoc.createElement('transform');
        transformElement.setAttribute('name', 'toWorld');

        lookAtNode = xDoc.createElement('lookAt');
        lookAtNode.setAttribute('origin', '$origin');
        lookAtNode.setAttribute('target', '$target');   
        lookAtNode.setAttribute('up', '$up');
        transformElement.appendChild(lookAtNode);
        sensorElement.appendChild(transformElement);

        % sampler
        samplerNode = xDoc.createElement('sampler');
        samplerNode.setAttribute('type', 'independent');
        samplerCountNode = xDoc.createElement('integer');
        samplerCountNode.setAttribute('name', 'sampleCount');
        samplerCountNode.setAttribute('value', '$sampler');
        samplerNode.appendChild(samplerCountNode);
        sensorElement.appendChild(samplerNode);

        % hdr
        filmNode = xDoc.createElement('film');
        filmNode.setAttribute('id', 'Camera_film');
        filmNode.setAttribute('type', 'hdrfilm');

        widthNode = xDoc.createElement('integer');
        widthNode.setAttribute('name', 'width');
        widthNode.setAttribute('value', '$width');
        filmNode.appendChild(widthNode);

        heightNode = xDoc.createElement('integer');
        heightNode.setAttribute('name', 'height');
        heightNode.setAttribute('value', '$height');
        filmNode.appendChild(heightNode);

        pixelFormatNode = xDoc.createElement('string');
        pixelFormatNode.setAttribute('name', 'pixelFormat');
        pixelFormatNode.setAttribute('value', 'rgb');
        filmNode.appendChild(pixelFormatNode);

        bannerNode = xDoc.createElement('boolean');
        bannerNode.setAttribute('name', 'banner');
        bannerNode.setAttribute('value', 'false');
        filmNode.appendChild(bannerNode);

        bannerNode = xDoc.createElement('boolean');
        bannerNode.setAttribute('name', 'attachLog');
        bannerNode.setAttribute('value', 'false');
        filmNode.appendChild(bannerNode);

        fileFormatNode = xDoc.createElement('string');
        fileFormatNode.setAttribute('name', 'fileFormat');
        fileFormatNode.setAttribute('value', 'rgbe');
        filmNode.appendChild(fileFormatNode);

        sensorElement.appendChild(filmNode);

        sceneItem.item(0).appendChild(sensorElement);

        xmlwrite(main_tmp_color_path, xDoc);
        
    end
end


end

