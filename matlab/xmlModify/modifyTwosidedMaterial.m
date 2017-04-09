function [ xDoc ] = modifyTwosidedMaterial( xDoc )
%Change material to two-sided

sceneItem = xDoc.getElementsByTagName('scene');
% two-sided material
bsdfItem = xDoc.getElementsByTagName('bsdf');
oldBsdfNodes = [];
newBsdfNodes = [];
for k = 0:bsdfItem.getLength-1
   thisBSDFItem = bsdfItem.item(k);
   if strcmp(char(thisBSDFItem.getAttribute('id')),'')
       continue;
   end

   bsdfNode = xDoc.createElement('bsdf');
   bsdfNode.setAttribute('type', 'twosided');
   bsdfNode.setAttribute('id', thisBSDFItem.getAttribute('id'));
   thisBSDFItem.removeAttribute('id');
   oldBsdfNodes = [oldBsdfNodes; thisBSDFItem];
   newBsdfNodes = [newBsdfNodes; bsdfNode];      
end
for k=1:length(newBsdfNodes)
    sceneItem.item(0).replaceChild(newBsdfNodes(k), oldBsdfNodes(k));
    newBsdfNodes(k).appendChild(oldBsdfNodes(k));
end 

end

