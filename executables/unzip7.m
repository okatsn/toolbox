function status = unzip7(zipfilepath, outputDir)
% filepath = "D:\GeoMag (main)\ELC_2021-22\GeoElectric\2022\0101\PULI20220101.sec.7z"
zipfilepath =char(zipfilepath);
[~, zipname, ext] = fileparts(zipfilepath);

ps = path;
sps = split(ps,";");

ind0 = ~cellfun(@isempty,regexp(sps, ".+?executables.?(?=7ZipPortable)", "once"));
targets = sps(ind0);
[~, I] = min(cellfun(@(x) length(split(x, filesep)),targets));
dir7zip = targets(I);
path7zip = fullfile(dir7zip{1},"App","7-Zip", '7z.exe');

cmd1 = sprintf('"%s" x -y "%s" -o"%s"', path7zip, zipfilepath, outputDir);
[status,result] = system(cmd1);


if ~isequal(status, 0)
    error("%s", result);
end

end