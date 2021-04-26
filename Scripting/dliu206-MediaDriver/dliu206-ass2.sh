
cd Music

printf "<html>\n <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\n<body>\n<table border=\"1\">\n"
printf "  <tr>\n  <th>Artist</th>\n  <th>Album</th>\n  <th>Tracks</th>\n </tr>\n"

index=0
hit=0

artistName=""
albumName=""

while IFS=$'\n' read -r line; do
    # Hacked in prints empty first line :/
    if [ $index -eq 0 ]; then
        index=1
        continue
    fi

    disk='disk'
    disc='disc'
    # if it has disk
    if [[ "$line" == *"$disk"* ||  "$line" == *"$disc"* ]]; then
        newArtistName=$(echo $line | cut -f 2 -d /)
        newAlbumName=$(echo $line | cut -f 3 -d /)
        song=$(echo $line | cut -f 5 -d / | sed 's/.ogg//')
    else
        newArtistName=$(echo $line | cut -f 2 -d /)
        newAlbumName=$(echo $line | cut -f 3 -d /)
        song=$(echo $line | cut -f 4 -d / | sed 's/.ogg//')
    fi
    directory="Music/"
    newLine="$directory$line"
    # # New Artist name
    if [ "$artistName" != "$newArtistName" ]; then
        
        if [ $hit -eq 1 ]; then
            printf "      </table>\n    </td>\n  </tr>\n"
        fi
        hit=1
        spanCount=$(find -type f | cut -f 2,3,4 -d / | grep -F "/$newArtistName/" | sort -u | wc -l)
        printf "  <tr>\n  <td rowspan=\"%s\">%s</td>\n" "$spanCount" "$newArtistName"
        artistName=$newArtistName
        albumName=$newAlbumName
        printf "  <td>%s</td>\n  <td>\n   <table border=\"0\">\n" "$albumName"
        printf "    <tr><td><a href=\"%s\">%s</a></td></tr>\n" "$newLine" "$song"
    elif [ "$albumName" != "$newAlbumName" ]; then
        # New Album
        albumName=${newAlbumName}
        printf "   </table>\n </td>\n </tr>\n <tr>\n  <td>%s</td>\n  <td>\n    <table border=\"0\">\n" "$newAlbumName"
        printf "    <tr><td><a href=\"%s\">%s</a></td></tr>\n" "$newLine" "$song"
    else
        # Print song
        printf "    <tr><td><a href=\"%s\">%s</a></td></tr>\n" "$newLine" "$song"
    fi
done < <(find -type f | sort -u | cut -f 2,3,4,5,6 -d / | sort -t '/' -k2)


printf "      </table>\n    </td>\n  </tr>\n"
printf "</table>\n</body>\n"

