#!/bin/bash

read -r -s -p "Enter token for authenticate to github.com (if you don't have token check https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token): " userToken

while [ "$userToken" == '' ]; do
  tput setaf 1
  echo "Token cannot be empty."
  tput setaf 7
  read -r -s -p "Enter token for authenticate to github.com (if you don't have token check https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token): " userToken
done

echo

read -r -p "Enter a name of repository: " repoName

while [ "$repoName" == '' ]; do
  tput setaf 1
  echo "Repository name cannot be empty."
  tput setaf 7
  echo "Enter a name of repository: "
  read -r repoName
done

read -r -p "Enter username of your account on github.com: " userName
status=$(curl -i https://api.github.com/users/"$userName" -s -o response.txt -w "%{http_code}")
echo "$status"

while [ "$userName" == '' ] || [ "$status" != 200 ]; do
  if [ "$userName" == '' ]
  then
    tput setaf 1
    echo "Username cannot be empty."
    tput setaf 7
  fi
  if [ "$status" != 201 ]
  then
    echo "Username is incorrect."
    read -r -p "Enter username of your account on github.com: " userName
    status=$(curl -i https://api.github.com/users/"$userName" -s -o response.txt -w "%{http_code}")
  fi
done

# shellcheck disable=SC2206
validateName=( $repoName )
arrayLength=${#validateName[*]}
fullName=''
if [ "$arrayLength" -gt 1 ]; then
  fullName=${repoName// /_}
else
  fullName=${repoName}
fi

# shellcheck disable=SC2016
result=$(curl -H "Authorization: token $userToken" https://api.github.com/user/repos -d "{\"name\": \"$fullName\"}" -s -o response.txt -w "%{http_code}")
# -s -o response.txt -w "%{http_code}" for getting res.status
echo "$result"
if [ "$result" == 201 ]
then
  cd "$HOME" || exit
  mkdir -p "GitRepos"
  cd GitRepos || exit
  mkdir -p "$fullName"
  cd "$fullName" || exit

  echo "# TestRepo" >>README.md

  git init
  git add README.md
  git commit -m "first commit"
  git branch -M main
  git remote add origin git@github.com:"$userName"/"$fullName".git
  git push -u origin main

  $SHELL
  echo "Also created folder GitRepos"
  echo "Creating repository $fullName is successful. Check https://github.com/$userName?tab=repositories"
else
  echo "Your token is incorrect."
fi
