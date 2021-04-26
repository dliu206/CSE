import os

file_paths = {}
span = {}

for root, directories, files in os.walk('Music'):
    for filename in files:
        # Join the two strings in order to form the full filepath.
        filepath = os.path.join(root, filename)
        artistPath = filepath.split("\\")
        if "disk" in artistPath[4] or "disc" in artistPath[4]:
            # on 3
            path = artistPath[2] + "/" + artistPath[3] + "/" + artistPath[5]
            if artistPath[2] not in span:
                span[artistPath[2]] = [artistPath[3]]
            else:
                if artistPath[3] not in span[artistPath[2]]:
                    span[artistPath[2]].append(artistPath[3])
        else:
            # on 2
            path = artistPath[2] + "/" + artistPath[3] + "/" + artistPath[4]
            if artistPath[2] not in span:
                span[artistPath[2]] = [artistPath[3]]
            else:
                if artistPath[3] not in span[artistPath[2]]:
                    span[artistPath[2]].append(artistPath[3])
        if filepath not in file_paths:
            file_paths[filepath] = path

out = open('output.html', 'w', encoding='utf8')

out.write("<html>\n  <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\n<body>\n<table border=\"1\">\n")
out.write("  <tr>\n    <th>Artist</th>\n    <th>Album</th>\n    <th>Tracks</th>\n  </tr>\n")

artistName = ""
albumName = ""
artistPass = False

sorted_d = sorted(file_paths.items(), key=lambda x: x[1])

for x, y in sorted_d:
    values = y.split('/')
    newArtistName = values[0]
    newAlbumName = values[1]
    song = values[2].replace(".ogg", "")
    if "disk" in song:
        continue

    x = x.replace("\\", "/")

    if artistName != newArtistName:
        if artistPass:
            out.write("      </table>\n    </td>\n  </tr>\n")
        artistPass = True
        # need the num of albums
        out.write("  <tr>\n    <td rowspan=\"%d\">%s</td>\n" % (len(span[newArtistName]), newArtistName))
        artistName = newArtistName
        albumName = newAlbumName
        out.write("    <td>%s</td>\n    <td>\n      <table border=\"0\">\n" % (albumName))
        out.write("        <tr><td><a href=\"%s\">%s</a></td></tr>\n" % (x, song))
    elif albumName != newAlbumName:
        albumName = newAlbumName
        out.write("      </table>\n    </td>\n  </tr>\n  <tr>\n    <td>%s</td>\n    <td>\n      <table border=\"0\">\n" % (albumName))
        out.write("        <tr><td><a href=\"%s\">%s</a></td></tr>\n" % (x, song))
    else:
        out.write("        <tr><td><a href=\"%s\">%s</a></td></tr>\n" % (x, song))


out.write("      </table>\n    </td>\n  </tr>\n")
out.write("</table>\n</body>\n")