%% get paths of movie files
function [v1,v2] = getv1v2()

root = pwd;

[file,path] = utl.uiget(pwd,'MultiSelect',true);

if length(path) == 1
    %[file(2),path(2)] = utl.uiget(pwd,'MultiSelect',true);
    [file(2),path(2)] = utl.uiget(path,'MultiSelect',true);
elseif length(path) > 2
    error('Select only 2 video files/folders.')
end


if ~isempty(file{1})                    %video files selected
    v1{1} = fullfile(path(1),file(1));
    v2{1} = fullfile(path(2),file(2));

else                                    % video folders selected
    cd(path(1))
    vid = dir('*.MP4');
    for i=1:length(vid)
        v1{i} = fullfile(path(1),vid(i).name);
    end

    cd(path(2))
    vid = dir('*.MP4');
    for i=1:length(vid)
        v2{i} = fullfile(path(2),vid(i).name);
    end

end

% return to root folder
cd(root)

end

