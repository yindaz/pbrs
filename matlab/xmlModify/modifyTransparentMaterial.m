function [ xDoc ] = modifyTransparentMaterial( mtl_file, xDoc, pure_trans_id )
%Set the opacity of transparent material to be 0

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

window_mtl_name = cell(0,1);
is_win_mtl = false;

shapeItems = xDoc.getElementsByTagName('shape');
for a = 0:shapeItems.getLength-1
    id = char(shapeItems.item(a).getAttribute('id'));
    
    if length(id)<4
        is_win_mtl = false;
    else     
        if ~isempty(strfind(id,'Window'))
            is_win_mtl = true;
        elseif ~isempty(strfind(id,'Model'))
            % example: Model#623_mesh or Model#209_185_mesh or Model#s__1195_192_mesh
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

            if ismember(obj_index, pure_trans_id)
                is_win_mtl = true;
            else
                is_win_mtl = false;
            end
        else
            if strcmp(id(1:4),'main') && is_win_mtl
                is_win_mtl = true;
            else
                is_win_mtl = false;
            end
        end
    end  
    
%     fprintf('%s %d\n', id, is_win_mtl);
    if is_win_mtl      
        mtlNode = shapeItems.item(a).getElementsByTagName('ref');
        for b = 0:mtlNode.getLength-1
            if strcmp(mtlNode.item(b).getAttribute('name'), 'bsdf')
                window_mtl_name{end+1,1} = char( mtlNode.item(b).getAttribute('id'));
            end
        end
    end
end

%%
sceneItem = xDoc.getElementsByTagName('scene');
bsdfItems = xDoc.getElementsByTagName('bsdf');

newNodeList = cell(0,1);
oldNodeList = cell(0,1);
speNodeList = cell(0,1);
for a = 0:bsdfItems.getLength-1
    match = strcmp(bsdfItems.item(a).getAttribute('id'), opa(:,1));
    if any(match)
        matchid = find(match);

        is_win = true;
        oldnode = bsdfItems.item(a);
        newNode = xDoc.createElement('bsdf');
        newNode.setAttribute('id',oldnode.getAttribute('id'));
        newNode.setAttribute('type','mask');
        
        specNode = xDoc.createElement('spectrum');
        specNode.setAttribute('name','opacity');
        if is_win
            specNode.setAttribute('value', '0');
        else
            specNode.setAttribute('value', sprintf('%2.1f',opa{matchid,2}));
        end
        oldnode.removeAttribute('id');
        
        if is_win
            refNode = oldnode.getElementsByTagName('rgb');
            for b = 0:refNode.getLength-1
                if strcmp(refNode.item(b).getAttribute('name'), 'reflectance')
                    refNode.item(b).setAttribute('value', '0 0 0');
                end
            end
        end
       
        newNodeList{end+1,1} = newNode;
        oldNodeList{end+1,1} = oldnode;
        speNodeList{end+1,1} = specNode;
    end
end

for a = 1:length(newNodeList)
    sceneItem.item(0).replaceChild(newNodeList{a}, oldNodeList{a});
    newNodeList{a}.appendChild(oldNodeList{a});
    newNodeList{a}.appendChild(speNodeList{a});
end

end

