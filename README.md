# aws_rotate_keys
Some simple scripts to help you rotate your aws keys for multiple accounts

## Dependencies

You must have the aws cli (`pip install awscli`) and jq (`apt install jq`)

## Setup

These assume that you have a folder with a file per account that export your account keys:
`/some/secure/path/`

And the content of each file should look something export the AWS account credentials (so it can be sourced from bash or some other script):

    $ cat /some/secure/path/my_account
    export AWS_ACCESS_KEY_ID=TSRQPONMLKJIHGFEDCBA
    export AWS_SECRET_ACCESS_KEY=ABCDEFGHIJKLABCDEFGHIJKL
    export AWS_USERNAME=My.User.Name
    export AWS_REGION=eu-west-1
    
The script simply iterates through each of the files in this directory (or a specific file if you provide the name as a parameter), sources the keys, then uses the aws cli to rotate your IAM keys.

## Demo

    $ aws_rotate_keys.sh my_account
    Rotatating keys for my_account
    Generated new key ABCDEFGHIJKLMNOPQRST
    Deleting old key TSRQPONMLKJIHGFEDCBA

## Testing your keys

To double check that all your keys are ok, there's another script `aws_test_keys.sh` which just runs

    aws sts get-caller-identity
    
Which is an AWS command guaranteed to succeed if the keys are valid; it requires no permissions.
