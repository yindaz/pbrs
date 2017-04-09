function [ xDoc ] = modifyFaceNormals( xDoc )
%MODIFYFACENORMALS Summary of this function goes here
%   Detailed explanation goes here

shapeItem = xDoc.getElementsByTagName('shape');

for k = 0:shapeItem.getLength-1
   thisShapeItem = shapeItem.item(k);
   if strcmp(char(thisShapeItem.getAttribute('id')),'')
       continue;
   end
   
   fnNode = xDoc.createElement('boolean');
   fnNode.setAttribute('name', 'faceNormals');
   fnNode.setAttribute('value', 'true');
   
   thisShapeItem.appendChild(fnNode);
        
end

end

