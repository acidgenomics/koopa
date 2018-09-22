# Check for CSV file.
file="$1"

if [[ ! -f "$file" ]]; then
    echo "${file} does not exist"
fi

if [[ ! "$file" =~ "*.csv" ]]; then
    echo "${file} is not a CSV"
fi

while read line
do          
    from=${line%,*}
    to=${line#*,}
    mv "$from" "$to"
done < "$file"
