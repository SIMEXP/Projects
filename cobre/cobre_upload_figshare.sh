# Before running this script, create a variable $token with a personal figshare identification token. This token can be generated at https://figshare.com/account/applications 
token="XXXX"
authors='[{"name":"Pierre Bellec"}]'
title="a test"

# Create a new article
data='{"authors": '$authors',"title": "'$title'","upload_type": "dataset"}'
json_article="$(curl -i -H "Content-Type: application/json" -X POST --data "$data" https://api.figshare.com/v2/account/articles?access_token=$token)"
id="$(echo "$json_article" | grep -oP '(/[0-9]+"})' | grep -oP '[0-9]*')"
echo 'An article was created with id '$id

# Initialize file list
list_file=("$search_dir"*)
for file in ${list_file[@]}
do
  md5_file="$(md5sum $file)"
  size_file=$(stat -c%s "$file")
  arg='{"md5": "'$md5_file'", "name": "'$file'", "size": '$size_file'}'
  curl -i -H "Content-Type: application/json" -X POST --data "$arg" https://api.figshare.com/v2/account/articles/$id/files?access_token=$token > /dev/null
done

# Retrieve upload tokens etc
file_json="$(curl -i -H "Content-Type: application/json" -X GET https://api.figshare.com/v2/account/articles/$id/files?access_token=$token|tee list_files.json)"
list_token=($(echo $file_json | tr '"' '\n' | grep -E '(^.{8}-)'))

file=fmri_0040048.nii.gz
upload_token=8a81ae47-df5f-4285-a183-2a81051713e3
upload_url=https://fup100010.figshare.com/upload/8a81ae47-df5f-4285-a183-2a81051713e3
id_file=6638550
curl -i -H "Content-Type: application/json" -X GET $upload_url?access_token=$token
curl -i -H "Content-Type: application/json" -X PUT --data-binary "@$file" $upload_url/1?access_token=$token
curl -i -H "Content-Type: application/json" -X POST https://api.figshare.com/v2/account/articles/$id/files/$id_file?access_token=$token 
