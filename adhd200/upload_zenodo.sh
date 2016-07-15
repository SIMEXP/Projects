# instructions used from http://siphonophore.org/blog/2016/01/
# https://zenodo.org/dev

# In a terminal - create data repository - will require to manually define a token variable $token
curl -i -H "Content-Type: application/json" -X POST --data '{"metadata":{"access_right": "open","creators": [{"affiliation": "NIAK ADHD200 preprocessed release", "name": "Bellec, Pierre"}],"description": "fMRI regional time series","keywords": ["fMRI", "Brain Parcellation"],"license": "cc-by-nc-4.0", "title": "ADHD200 preprocessed regional time series processed with NIAK and the ROI1000 brain parcellation", "upload_type": "dataset"}}' https://zenodo.org/api/deposit/depositions/?access_token=$token |tee zenodo.json

# In octave - upload all mat files in the current directory, which also needs to contain the zenodo.json file created above:

% Parse the repository identification number from the zenodo json file
instr_zid = 'cat zenodo.json|tr , ''\n''|awk ''/"id"/{printf"%i",$2}''';
[status,zid] = system(instr_zid)

% Push mat files
files = dir('*mat');
files = {files.name};
for ff = 1:length(files)
    to_transfer = files{ff};
    instr = sprintf('curl -i -F name=%s -F file=@%s/%s https://zenodo.org/api/deposit/depositions/%s/files?access_token=$token',to_transfer,pwd,to_transfer,zid);
    system(instr);
end

% Push the parcellation
instr = sprintf('curl -i -F name=brain_rois.nii.gz -F file=@%s/brain_rois.nii.gz https://zenodo.org/api/deposit/depositions/%s/files?access_token=$token',pwd,zid);
system(instr);

% Push the README.md
instr = sprintf('curl -i -F name=README.md -F file=@%s/README.md https://zenodo.org/api/deposit/depositions/%s/files?access_token=$token',pwd,zid);
system(instr);  

% Publish the dataset - will require to manually define a token variable
instr = sprintf('curl -i -X POST https://zenodo.org/api/deposit/depositions/%s/actions/publish?access_token=%s',zid,token)
system(instr)