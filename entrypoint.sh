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


  PR=$(curl -s -H "Authorization: token ${{ env.GITHUB_TOKEN }}" \
    "https://api.github.com/repos/Nordelta/sgc-legacy/pulls/876")

  echo "$PR"

  LABEL=($(echo "$PR" | jq -r '.labels[].name'))

  echo "Labels on the merged PR: |$LABEL|"

  cd ../Documentos/GitHub/sgc-legacy
  
  prev_version=$(git describe --tags --abbrev=0)

  last_char="${prev_version: -1}"

  if [[ "$last_char" =~ [a-zA-Z] ]]; then
    prev_version="$prev_version.0"
  fi

  if [[ "$prev_version" == "" ]]; then
    echo "could not read previous version"; exit 1
  fi

  possible_release_types="major feature bug hotfix fix"

  release_type=$(echo "$(echo "$LABEL" | tr ',' '\n' | grep -E "($possible_release_types)")" | tr -d '[:space:]')

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

  if [[ ($release_type == "major" || $release_type == "feature" || $release_type == "bug") && $pre == "-hotfix" ]]; then
    pre="-stable"
  fi

  IFS=" " read -r -a possible_release_types <<< "$possible_release_types"

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
        if [[ "$pre" != "-${possible_release_types[4]}" ]];
          then
          preversion=1
          else ((++preversion))
        fi
    fi
    pre="-${possible_release_types[4]}.$preversion";;
  esac

  next_version="${major}.${minor}.${patch}${pre}"

  echo "create $release_type-release version: $prev_version -> $next_version"

  echo "next-version=$next_version" >> $GITHUB_OUTPUT
}

main
