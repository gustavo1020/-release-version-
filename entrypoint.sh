#!/bin/bash -l

# active bash options:
#   - stops the execution of the shell script whenever there are any errors from a command or pipeline (-e)
#   - option to treat unset variables as an error and exit immediately (-u)
#   - print each command before executing it (-x)
#   - sets the exit code of a pipeline to that of the rightmost command
#     to exit with a non-zero status, or to zero if all commands of the
#     pipeline exit successfully (-o pipefail)
set -euo pipefail

main() {

  mkdir my_commits

  git clone https://$6:$3@github.com/$2.git my_commits
  
  cd my_commits

  git checkout $4

  git fetch origin $4

  git pull origin $4

  PR=$(curl -s -H "Authorization: token $3" \
    "https://api.github.com/repos/$2/pulls?base=$4&state=closed&sort=merged&direction=desc&per_page=1")
  
  LABELS=$(echo "$PR" | jq -r '.[0].labels[] | .name' | tr '\n' ' ')

  possible_release_types="$1"

  filtered_labels=""

  next_version="0"

  prev_version=$(git describe --tags --abbrev=0)

  if [ -z "$prev_version" ]; then
    prev_version="1.0.0-stable"
    echo "prev_version is null or the branch is new"
  fi

  if [[ "$prev_version" == "" ]]; then
     prev_version="1.0.0-stable"
     echo "prev_version is null or the branch is new"
  fi

  if [[ "${prev_version: -1}" =~ [a-zA-Z] ]]; then
    prev_version="$prev_version.0"
  fi

  IFS=' ' read -ra LABELS <<< "$LABELS"
  IFS=' ' read -ra possible_release_types <<< "$possible_release_types"

  for LABEL in "${LABELS[@]}"; do
      for possible_release_type in "${possible_release_types[@]}"; do
          if [[ $LABEL == $possible_release_type ]]; then
             filtered_labels="$LABEL"
          fi
      done
  done

  for LABEL in "${LABELS[@]}"; do
      if [[ $LABEL == "release" ]]; then

         if [ -n "$possible_release_types" ] || [ -z "$possible_release_types" ]; then
            echo "possible_release_types is null"; exit 1
         fi

         if [ -n "$filtered_labels" ] || [ -z "$filtered_labels" ]; then
            echo "Label in PR is null"; exit 1
         fi

         release_type=$filtered_labels

         if [[ ! ${possible_release_types[*]} =~ ${release_type} ]]; then
            echo "valid argument: [ ${possible_release_types[*]} ]"; exit 1
         fi

         major=0; minor=0; patch=0; pre=""; preversion=0

         regex="^v?([0-9]+).([0-9]+).([0-9]+)((-[a-z]+)?.([0-9]+))?$"

         if [[ $prev_version =~ $regex ]]; then
            major="${BASH_REMATCH[1]}"
            minor="${BASH_REMATCH[2]}"
            patch="${BASH_REMATCH[3]}"
            pre="${BASH_REMATCH[5]}"
            preversion="${BASH_REMATCH[6]}"
         else
            echo "previous version '$prev_version' is not a semantic version"
            exit 1
         fi

         if [[ ($release_type == "${possible_release_types[0]}" || $release_type == "${possible_release_types[1]}" || $release_type == "${possible_release_types[2]}") && $pre == "-hotfix" ]]; then
            pre="-stable"
         fi

         case "$release_type" in
         "${possible_release_types[0]}")
         ((++major)); minor=0; patch=0;;
         "${possible_release_types[1]}")
         ((++minor)); patch=0;;
         "${possible_release_types[2]}")
         ((++patch));;
         "${possible_release_types[3]}")
           if [[ -z "$preversion" ]];
             then
              preversion=0
             else
               if [[ "$pre" != "-${possible_release_types[3]}" ]];
                 then
                   preversion=1
                 else ((++preversion))
               fi
           fi
           pre="-${possible_release_types[3]}.$preversion";;
         "${possible_release_types[4]}")
           if [[ -z "$preversion" ]];
              then
                preversion=0
              else
                if [[ "$pre" != "-beta" ]];
                   then
                     preversion=1
                   else ((++preversion))
                fi
           fi
           pre="-beta.$preversion";;
         esac

         next_version="$5${major}.${minor}.${patch}${pre}"
         echo "create $release_type-release version: $prev_version -> $next_version"
      else
        echo "Release tag not found"
      fi
  done

  echo "next-version=$next_version" >> $GITHUB_OUTPUT

}

main "$1" "$2" "$3" "$4" "$5" "$6"