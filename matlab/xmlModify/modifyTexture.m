function [ xDoc ] = modifyTexture( xDoc )
%Change default texture

textItems = xDoc.getElementsByTagName('texture');
for a = 0:textItems.getLength-1
    if any(strcmp(textItems.item(a).getAttribute('id'), {'wallp_1_1.jpg','wallp_1_2.jpg'}))
        node = textItems.item(a).getElementsByTagName('string');
        node.item(0).setAttribute('value', '$default_texture_path');
    end

end


end

