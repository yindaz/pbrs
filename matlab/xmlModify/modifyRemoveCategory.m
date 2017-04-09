function [ xDoc ] = modifyRemoveCategory( xDoc, pure_trans_id )
%Remove unwanted object

is_remove = false;
shape_id = cell(0,1);
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
        
        is_remove = ismember(obj_index, pure_trans_id);
    elseif ~strcmp(id(1:4),'main') && is_remove
        is_remove = false;
    end
    
    if is_remove
        shape_id{end+1,1} = shapeItems.item(a);
    end

end

sceneItem = xDoc.getElementsByTagName('scene');
for a = 1:length(shape_id)
    sceneItem.item(0).removeChild(shape_id{a});
end

end

