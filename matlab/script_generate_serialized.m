config;
output_path = [output_path 'projects_serialize/'];

if ~exist(output_path, 'dir')
    mkdir(output_path);
end

valid = false(length(projects_list),1);
for a = 1:length(projects_list)
    if exist([output_path projects_list{a} '/main.xml'],'file') ...
        && exist([output_path projects_list{a} '/' projects_list{a} '.mtl'],'file') ...
        && exist([output_path projects_list{a} '/main.serialized'],'file')
        valid(a) = true;
    end
end

projects_list = projects_list(~valid);
fprintf('%d load, %d valid\n', length(valid), sum(~valid));

%%
dependency = 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH';
number_job = 5;
command_path = [script_path 'cmd_generate_serialized/'];
if ~exist(command_path, 'dir')
    mkdir(command_path);
end
allfp = cell(number_job,1);
for a = 1:number_job
    allfp{a} = fopen(sprintf('%scmd_%d.sh', command_path, a), 'w');

    fprintf(allfp{a}, '#!/bin/bash\n');
    fprintf(allfp{a}, '%s\n', dependency);
end

for a = 1:length(projects_list)
    fileid = rem(a,number_job) + 1;
    fprintf(allfp{fileid}, 'cd %s\n', output_path);
    fprintf(allfp{fileid}, 'rm -rf %s\n', projects_list{a});
    fprintf(allfp{fileid}, 'cp -r %shouse_obj/%s ./\n', suncg_path, projects_list{a});
    fprintf(allfp{fileid}, 'cd %s%s/\n', output_path, projects_list{a});
    fprintf(allfp{fileid}, 'xz -kd %s.obj.xz\n', projects_list{a});
    fprintf(allfp{fileid}, 'mv %s.obj main.obj\n', projects_list{a});
    fprintf(allfp{fileid}, '%s main.obj main.xml\n', mtsimport_path);
    fprintf(allfp{fileid}, 'rm -f main.obj\n');
    fprintf(allfp{fileid}, 'rm -f %s.obj.xz\n', projects_list{a});
end

for a = 1:number_job
    fclose(allfp{a});
end
