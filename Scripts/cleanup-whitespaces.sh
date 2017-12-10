#!/bin/sh
directories=(Sources Tests)

for directory in "${directories[@]}"
do
echo "Cleaning whitespaces in directory: $directory"

find $directory -iregex '.*\.swift' -exec sed -E -i '' -e 's/[[:blank:]]*$//' {} \;
done
echo "Done"