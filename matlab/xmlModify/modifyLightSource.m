function [ xDoc ] = modifyLightSource( mtl_file, light_geometry, xDoc )
%Set light bulb as shape emitter

light_model_list = {light_geometry.model};

bulb_material = [];
shade_material = [];
is_light_model = false;

shapeItems = xDoc.getElementsByTagName('shape');
for a = 0:shapeItems.getLength-1
    id = char(shapeItems.item(a).getAttribute('id'));
    
    if ~isempty(strfind(id,'Model'))
        p = strfind(id, '_mesh');
        id_sub = id(7:p-1);
        p1 = strfind(id_sub, '_');
        p2 = strfind(id_sub, '__');
        p3 = setdiff(p1, [p2 p2+1]);
        if isempty(p3)
            obj_index = id_sub;
        elseif length(p3)==1
            obj_index = id_sub(1:p3-1);
        else
            fprintf('Model name parse error!');
            return;
        end
        
        loc_mat_id = 0;
        lightid = find(ismember(light_model_list, obj_index));
        if ~isempty(lightid)
            is_light_model = true;
            bulb_id = light_geometry(lightid).bulb_id;
            shade_id = light_geometry(lightid).shade_id;
        else
            is_light_model = false;
        end
    end
    
    if strcmp(id(1:4),'main') && is_light_model
        loc_mat_id = loc_mat_id + 1;
    end
    
    if is_light_model
        if ismember(loc_mat_id, bulb_id)
            is_bulb = true;
        else
            is_bulb = false;
        end
        if ismember(loc_mat_id, shade_id)
            is_shade = true;
        else
            is_shade = false;
        end
    end
    
    if is_light_model && (is_bulb || is_shade)
        mtlNode = shapeItems.item(a).getElementsByTagName('ref');
        for b = 0:mtlNode.getLength-1
            if strcmp(mtlNode.item(b).getAttribute('name'), 'bsdf')
                material_name = char( mtlNode.item(b).getAttribute('id'));
                if is_bulb
                    bulb_material{end+1,1} = material_name;
                end
                if is_shade
                    shade_material{end+1,1} = material_name;
                end
            end
        end
    end
   
end


mtl=readmtl(mtl_file,false);
% get all mtl with d
title_id = 0;
opa_name  = cell(0,2);
for a = 1:length(mtl)
    if strcmp(mtl(a).type, 'newmtl')
        title_id = a;
    elseif strcmp(mtl(a).type, 'd') && mtl(a).data<1
        opa_name{end+1,1} = mtl(title_id).data;
        opa_name{end,2}  = mtl(a).data;       
    end
end
opa = opa_name;
for a = 1:size(opa_name,1)
    opa{a,1} = [opa{a,1} '_material'];
end

%%
shapeItem = xDoc.getElementsByTagName('shape');

for a = 0:shapeItem.getLength-1
    refNode = shapeItem.item(a).getElementsByTagName('ref');
    is_emissive = false;
    for b = 0:refNode.getLength-1
        shape_mtl_name = refNode.item(b).getAttribute('id');
        match = strcmp(shape_mtl_name, bulb_material);
        if any(match)
            is_emissive = true;
        end
    end
    if is_emissive
        emitterNode = xDoc.createElement('emitter');
        emitterNode.setAttribute('type', 'area');
        radNode = xDoc.createElement('spectrum');
        radNode.setAttribute('name', 'radiance');
        radNode.setAttribute('value', sprintf('%f', 400));
        emitterNode.appendChild(radNode);
        shapeItem.item(a).appendChild(emitterNode);
    end
end

%%
translucent_material = setdiff(shade_material, opa(:,1));

for a = 0:shapeItem.getLength-1
    refNode = shapeItem.item(a).getElementsByTagName('ref');
    is_emissive = false;
    for b = 0:refNode.getLength-1
        shape_mtl_name = refNode.item(b).getAttribute('id');
        match = strcmp(shape_mtl_name, translucent_material);
        if any(match)
            is_emissive = true;
        end
    end
    if is_emissive
        emitterNode = xDoc.createElement('emitter');
        emitterNode.setAttribute('type', 'area');
        radNode = xDoc.createElement('spectrum');
        radNode.setAttribute('name', 'radiance');
        radNode.setAttribute('value', '0.5');
        emitterNode.appendChild(radNode);
        shapeItem.item(a).appendChild(emitterNode);
    end
end

end

