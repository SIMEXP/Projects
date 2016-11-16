# Before running this script, create a variable $token with a personal figshare identification token. This token can be generated at https://figshare.com/account/applications 
token="XXXX"
authors='[{"name":"Pierre Bellec"}]'
title="COBRE preprocessed with NIAK 0.17 - lightweight release"

# Create a new article
data='{"authors": '$authors',"title": "'$title'","upload_type": "dataset"}'
json_article="$(curl -i -H "Content-Type: application/json" -X POST --data "$data" https://api.figshare.com/v2/account/articles?access_token=$token)"
id="$(echo "$json_article" | grep -oP '(/[0-9]+"})' | grep -oP '[0-9]*')"
echo 'An article was created with id '$id

# Initialize file list
list_file=("$search_dir"*)
for file in ${list_file[@]}
do
  md5_file=$(md5sum $file | grep -oP '^.* ')
  md5_file=${md5_file%\  };
  size_file=$(wc -c < "$file")
  arg='{"md5": "'$md5_file'", "name": "'$file'", "size": '$size_file'}'
  curl -H "Content-Type: application/json" -X POST --data "$arg" https://api.figshare.com/v2/account/articles/$id/files?access_token=$token
done

# Retrieve upload tokens etc
file_json="$(curl -i -H "Content-Type: application/json" -X GET https://api.figshare.com/v2/account/articles/$id/files?access_token=$token)"
list_file=($(echo $file_json | grep -oP '"name": "(.*?)\"'  | grep -oP ' ".*?"$'))
list_url=($(echo $file_json | grep -oP '"upload_url": "(.*?)\"'  | grep -oP ' ".*?"$'))
list_id=($(echo $file_json | grep -oP '"id": (.*?),'  | grep -oP ' .*?,$'))
nfiles=${#list_id[@]}
for ((ind=0;ind<$nfiles;ind++))
do 
  file=${list_file[ind]%\"};
  file=${file#\"};
  upload_url=${list_url[ind]%\"};
  upload_url=${upload_url#\"};
  id_file=${list_id[ind]%\,};
  
  echo 'Uploading file: '$file
  echo '  token: '$token
  echo '  url: '$url
  echo '  id: '$id
  #  curl -i -H "Content-Type: application/json" -X GET $upload_url?access_token=$token 
  #  curl -i -H "Content-Type: application/json" -X PUT --data-binary "@$file" $upload_url/1?access_token=$token
   curl -i --request PUT --data-binary "@$file" $upload_url/1?access_token=$token
  curl -i -H "Content-Type: application/json" -X POST https://api.figshare.com/v2/account/articles/$id/files/$id_file?access_token=$token 
done
