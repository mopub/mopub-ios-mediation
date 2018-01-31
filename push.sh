COMMAND='pod spec lint --allow-warnings --use-libraries --verbose'

find `pwd` -iname "*-PodSpecs"  | sort -u | while read i; do                                              
    cd "$i" && pwd && $COMMAND 
done


