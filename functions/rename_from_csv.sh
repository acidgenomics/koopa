while read line
do          
    old_name=${line%,*}
    new_name=${line#*,}
    mv "$old_name" "$new_name"
done < "$1"
