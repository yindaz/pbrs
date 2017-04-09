function  objects=readmtl(filename_mtl,verbose)
if(verbose),disp(['Reading Material file : ' filename_mtl]); end
file_words=file2cellarray(filename_mtl);
% Remove empty cells, merge lines split by "\" and convert strings with values to double
[ftype fdata]= fixlines(file_words);

% Surface data
objects.type(length(ftype))=0; 
objects.data(length(ftype))=0; 
no=0;
% Loop through the Wavefront object file
for iline=1:length(ftype)
  type=ftype{iline}; data=fdata{iline};
    
    % Switch on data type line
    switch(type)
        case{'#','$'}
            % Comment
            tline='  %'; 
            if(iscell(data))
                for i=1:length(data), tline=[tline ' ' data{i}]; end
            else
                tline=[tline data];
            end
            if(verbose), disp(tline); end
        case{''}
        otherwise
            no=no+1;
            if(mod(no,10000)==1), objects(no+10001).data=0; end
            objects(no).type=type;
            objects(no).data=data;
    end
end
objects=objects(1:no);
if(verbose),disp('Finished Reading Material file'); end

function file_words=file2cellarray(filename)
% Open a DI3D OBJ textfile
fid=fopen(filename,'r');
file_text=fread(fid, inf, 'uint8=>char')';
fclose(fid);
file_lines = regexp(file_text, '\n+', 'split');
file_words = regexp(file_lines, '\s+', 'split');

function [ftype fdata]=fixlines(file_words)
ftype=cell(size(file_words));
fdata=cell(size(file_words));

iline=0; jline=0;
while(iline<length(file_words))
    iline=iline+1;
    twords=removeemptycells(file_words{iline});
    if(~isempty(twords))
        % Add next line to current line when line end with '\'
        while(strcmp(twords{end},'\')&&iline<length(file_words))
            iline=iline+1;
            twords(end)=[];
            twords=[twords removeemptycells(file_words{iline})];
        end
        % Values to double
        
        type=twords{1};
        stringdold=true;
        j=0;
        switch(type)
            case{'#','$'}
                for i=2:length(twords)
                    j=j+1; twords{j}=twords{i};                    
                end    
            otherwise    
                for i=2:length(twords)
                    str=twords{i};
                    val=str2double(str);
                    stringd=~isfinite(val);
                    if(stringd)
                        j=j+1; twords{j}=str;
                    else
                        if(stringdold)
                            j=j+1; twords{j}=val;
                        else
                            twords{j}=[twords{j} val];    
                        end
                    end
                    stringdold=stringd;
                end
        end
        twords(j+1:end)=[];
        jline=jline+1;
        ftype{jline}=type;
        if(length(twords)==1), twords=twords{1}; end
        fdata{jline}=twords;
    end
end
ftype(jline+1:end)=[];
fdata(jline+1:end)=[];

function b=removeemptycells(a)
j=0; b={};
for i=1:length(a);
    if(~isempty(a{i})),j=j+1; b{j}=a{i}; end;
end

