# Before running this script, create a variable $token with a personal figshare identification token. This token can be generated at https://figshare.com/account/applications 

# Create a new article
curl -i -H "Content-Type: application/json" -X POST --data '{"authors": [{"name":"Pierre Bellec"}],"description": "fMRI data","tags": ["neuroimaging", "resting-state","fMRI", "schizophrenia", "brain connectivity"], "title": "COBRE preprocessed with NIAK 0.17 - lightweight release", "upload_type": "dataset"}' https://api.figshare.com/v2/account/articles?access_token=$token

# Before running this next command, create a variable $id with the article id returned by the previous command. It can also be set to the id of an existing article, generated previously or generated with the gui

# Upload files
for file in "$search_dir"*
do
  md5_file="$(md5sum $file)"
  size_file=$(stat -c%s "$file")
  arg='{"md5": "'$md5_file'", "name": "'$file'", "size": '$size_file'}'
  curl -i -H "Content-Type: application/json" -X POST --data "$arg" https://api.figshare.com/v2/account/articles/$id/files?access_token=$token  
done
