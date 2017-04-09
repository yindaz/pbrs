function simplifyMtl(input_name, output_name)

fpi = fopen(input_name);
fpo = fopen(output_name, 'w');

while ~feof(fpi)
    s = fgetl(fpi);
    if ~isempty(strfind(s,'.jpg')) || ~isempty(strfind(s,'.png'))
%         c = regexp(s, '/', 'split');
%         I = ismember(c, '.');
%         c(I) = [];
%         
%         k = cell(0,1);
%         count = 0;
%         
%         for a = 1:length(c)
%             if strcmp(c{a}, '.')
%                 continue;
%             end
%             
%         end
        c = regexp(s,' ', 'split');
        p = strfind(c{2}, '../../');
        
        fprintf(fpo, '%s %s\n', c{1}, c{2}(p:end));
    else
        fprintf(fpo, [s '\n']);
    end
end

fclose(fpi);
fclose(fpo);
end