#!/bin/bash

if ! [ $1 -eq $1 2>/dev/null ]
        then
            echo "Invalid input, please give integer as first parameter"
fi

echo "-----------------------------"
echo "Creating $1 POD files"
echo "-----------------------------"

for (( c=1; c<=$1; c++ ))
do  
   echo "Creating file Session-pod$c.md for pod$c"
   sed -i -e 's/podxx/pod'"$c"'/g' Session-podxx.md
   mv Session-podxx.md Session-pod$c.md
   mv Session-podxx.md-e Session-podxx.md
done

