
# find - type f = Finds all regular file types
# grep - searchs for files ending with the ending extension .ogg
# wc -l - counts the number of lines as outcome
printf "Total Tracks: $(find -type f | grep \.ogg | wc -l) \n\n"


# cut -f3 -d '/' - chooses the 3rd field delimited by '/'
printf "Total Artists: $(find -type f | cut -f 3 -d / | sort -u | wc -l) \n\n"

# Same as Total Artists, but keeps 2nd and 3rd field delimited by '/' for a (genre - musician) pair
# Unique (genre to musician) pairs
printf "Multi-Genre Artist: \n$(find -type f | cut -f 2,3 -d / | sort -u | cut -f 2 -d / | sort | uniq -d) \n\n"


# Finds all files with their directory paths delimited by fields 4,5, and 6
# Piped to only show file paths with disk directories
# Filtered to show only the album name
# Sorted by unique to delete any duplicates
printf "Multi-Disk Albums: \n$(find -type f | cut -f 4,5,6 -d / | grep disk[1-9]/ | cut -f 1 -d / | sort -u) \n\n"

printf "Detailed Report\n"

printf "Multi-Genre Artist: \n$(find -type f | cut -f 2,3 -d / | sort -u | cut -f 2 -d / | sort | uniq -d > genre.txt)"

while IFS= read -r line; do
    printf " $line \n"
    printf "$(find $pwd -type d -name "$line" | cut -f 2,3 -d / | sort -u | cut -f 1 -d / | sed 's/^/\t\t/') \n"
done < genre.txt

rm genre.txt


declare -A ARTIST

printf "Multi-Disk Albums: \n$(find -type f | grep disk[1-9]/ | cut -f 3,4 -d / | sort -u | sort -n -t '/' -k2 > multi-disk.txt)"

while IFS= read -r line; do
    tempOne="$(cut -d'/' -f1 <<<"$line")"
    tempTwo="$(cut -d'/' -f2 <<<"$line")"

    if [ ${ARTIST[$tempOne]+_} ]; then 
        #"Found"
        printf "\t$tempTwo\n"
    else 
        #"Not found"
        printf " $tempOne\n"
        printf "\t$tempTwo\n"
        ARTIST[$tempOne]=1
    fi
done < multi-disk.txt

rm multi-disk.txt

# Finds all albums
# Sorts by unique file paths, by the 3rd album
printf "Possible Duplicate Albums: \n$(find -type f | cut -f 2,3,4 -d / | sort -u | sort -t '/' -k3 | cut -f 3 -d / | uniq -d > dup.txt)"

while IFS= read -r line; do
    printf " $line \n"
    printf "$(find $pwd -type d -name "$line" | cut -f 2,3 -d / | sort -t '/' -k2 | sed 's/^/\t\t/' | sed 's/\//\t/g') \n"
done < dup.txt

rm dup.txt

