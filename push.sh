COMMAND='pod spec lint --allow-warnings --use-libraries --verbose'
COMMAND2='pod trunk push --allow-warnings --use-libraries --verbose'
find `pwd` -iname "*-PodSpecs"  | sort -u | while read i; do
cd "$i" && pwd && $COMMAND && $COMMAND2
done

#remove # sign when required to push
