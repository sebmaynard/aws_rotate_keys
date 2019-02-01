#!/bin/bash -e

function clear_aws_keys() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_REGION
    unset AWS_DEFAULT_REGION
    unset AWS_USERNAME
}

key_root=/some/secure/path/
if [[ "$1" != "" ]] ; then
    keys=$key_root$1
else
    keys="$key_root/*"
fi

for keyset in $keys ; do
    if [[ "$keyset" == *".inactive" ]] ; then
        echo Inactive $keyset
        echo
        continue
    fi

    echo "Testing keys for" $(basename $keyset)
    clear_aws_keys
    source $keyset

    aws sts get-caller-identity | jq -r .Arn

    echo

done
