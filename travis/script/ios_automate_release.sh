#!/usr/bin/env bash
#!/bin/bash -l

# ==================================================== #

### Set up gitsubmodules to run gradle build ###

# Networks this script checks for
NETWORKS=( 
    AdColony
    AdMob
    AppLovin 
    Chartboost
    FacebookAudienceNetwork
    Flurry 
    IronSource
    Tapjoy
    UnityAds
    Vungle
)

### Function to get display name for Firebase update ###
function get_display_name {
    key=$1
    out=$2
    name=$key
    case "$key" in
        AdMob ) name="Google (AdMob)";;
        FacebookAudienceNetwork ) name="Facebook Audience Network";;
        Flurry ) name="Yahoo! Flurry";;
        IronSource ) name="ironSource";;
        OnebyAOL ) name="One by AOL";;
        UnityAds ) name="Unity Ads";;
    esac
    eval "$out='$name'"
}

### Function to read Adapter version from AdapterConfiguration ###
function read_networkAdapter_version
{
 versionnumber=`grep -r "s.version          = " ./$1/ | awk '{print $3}' | sed s/\'//g`
 echo $versionnumber
 lowercaseselection=$(echo "$1" | tr '[:upper:]' '[:lower:]')
 echo $lowercaseselection

### git tag release ###
commitId= git rev-parse HEAD
echo $commitId
tagname="$lowercaseselection-$versionnumber"
echo $tagname

### Publish release in Github [TO_DO]
#curl -H "Authorization: token ${GITHUB_TOKEN}" --data '{"tag_name": "'"$tagname"'","target_commitish": "'"$commitId"'","name": "'"$versionnumber"'","body": "Refer https://github.com/mopub/mopub-ios-mediation/blob/master/'"$1"'/CHANGELOG.md.","draft": false,"prerelease": false}' https://api.github.com/repos/mopub/ios-mediation/releases

### pod spec lint run ###
pod spec lint ./ios-mediation/MoPub-$1-Adapters.podspec --allow-warnings --use-libraries
if [ $? -eq 0 ]; then
 ### Uncomment pod push to cocoapods for final release ###
 #pod trunk push ./ios-mediation/MoPub-$1-Adapters.podspec --allow-warnings --use-libraries --verbose
 if [ $? -eq 0 ]; then
    ### UPDATE FIREBASE ###
    echo "Updating staging JSON..."
    firebase_project="mopub-mediation-staging"
    get_display_name $i name
    json_path="/releaseInfo/$name/iOS/version"

    echo $i
    echo $versionnumber
    if [ -z "${FIREBASE_TOKEN}" ]; then
        print_red_line "\${FIREBASE_TOKEN} environment variable not set!"
    else
        firebase database:set --confirm "/releaseInfo/$name/iOS/version/adapter/" --data "\"$versionnumber\"" --project $firebase_project --token ${FIREBASE_TOKEN}
        firebase database:set --confirm "/releaseInfo/$name/iOS/version/sdk/" --data "\"$sdkverion\"" --project $firebase_project --token ${FIREBASE_TOKEN}
        if [[ $? -ne 0 ]]; then
            echo "ERROR: Failed to run firebase commands; please follow instructions at: https://firebase.google.com/docs/cli/"
        else
            echo "Done updating firebase JSON"
        fi
      fi
else
    echo Failed to push pods. Please fix  before updating Firebase.
fi
fi 
}

for i in "${NETWORKS[@]}"
do
    changed=$(git log --name-status -1 --oneline ./ | grep $i)
    if [[ ! -z "$changed" ]]; then
        echo "$changed"
        read_networkAdapter_version  $i
    fi  
done

