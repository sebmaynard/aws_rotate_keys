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

    echo "Rotatating keys for" $(basename $keyset)
    clear_aws_keys

    source $keyset
    ACTIVE_KEY=$AWS_ACCESS_KEY_ID
    new_key=$(aws iam create-access-key)
    KEY_ID=$(echo $new_key | jq -r .AccessKey.AccessKeyId)
    KEY_SECRET=$(echo $new_key | jq -r .AccessKey.SecretAccessKey)
    KEY_USER=$(echo $new_key | jq -r .AccessKey.UserName)
    CREATED=$(echo $new_key | jq -r .AccessKey.CreateDate)
    
    # if we got here, we can probably assume it all worked, so delete the old one
    echo Generated new key $KEY_ID

    # reset the keyset file
    echo -n > $keyset
    echo export AWS_ACCESS_KEY_ID=$KEY_ID > $keyset
    echo export AWS_SECRET_ACCESS_KEY=$KEY_SECRET >> $keyset
    echo export AWS_USERNAME=$KEY_USER >> $keyset
    echo export AWS_REGION=$AWS_REGION >> $keyset
    echo export AWS_DEFAULT_REGION=$AWS_REGION >> $keyset
    echo export CREATED=$CREATED >> $keyset
    
    # if we got here, we can probably assume it all worked, so delete the old one
    echo Deleting old key $ACTIVE_KEY
    aws iam delete-access-key --access-key-id=$ACTIVE_KEY

    echo

done
