# David Liu
# CSS 390 - Scripting - Assignment #3
# Autumn, 2020 - 11/11/2020


index = 0
total_cookies_in_baseline = 0
empty_cookies_in_baseline = 0
non_empty_cookies_in_baseline = 0
# # Segments -> Cookies
baseline_dataOne = {}

baselineCookies = set()

# Record Data
f = open("small-baseline", "r")
for x in f:
    try:
        isEmpty = False
        delimited = x.split("==>")
        cookie = delimited[0].split(" ")[6]
        segments = delimited[1].replace("[", "")
        segments = segments.replace("]", "")
        segments = segments.replace(" ", "")
        segments = segments.replace("\n", "")
        segmented = segments.split(",")
        total_cookies_in_baseline += 1
        if len(segmented) == 0:
            empty_cookies_in_baseline += 1
            isEmpty = True
        else:
            for element in segmented:
                if len(element) > 0:
                    if element in baseline_dataOne:
                        s = baseline_dataOne[element]
                        s.add(cookie)
                        baseline_dataOne[element] = s
                    else:
                        s = set()
                        baseline_dataOne[element] = s
                elif len(element) == 0 and len(segmented) == 1:
                    empty_cookies_in_baseline += 1
                    isEmpty = True
        if not isEmpty:
            baselineCookies.add(cookie)
            non_empty_cookies_in_baseline += 1
    except IndexError:
        print("Index: %d" % index)
    index += 1
f.close()

total_cookies_in_test = 0
empty_cookies_in_test = 0
non_empty_cookies_in_test = 0

testCookies = set()
test_dataOne = {}

f2 = open("small-evaluate", "r")
index = 0
for x in f2:
    if index > 10:
        try:
            isEmpty = False
            delimited = x.split("==>")
            cookie = delimited[0].split(" ")[6]
            segments = delimited[1].replace("[", "")
            segments = segments.replace("]", "")
            segments = segments.replace(" ", "")
            segments = segments.replace("\n", "")
            segmented = segments.split(",")
            total_cookies_in_test += 1
            if len(segmented) == 0:
                empty_cookies_in_test += 1
                isEmpty = True
            else:
                for element in segmented:
                    if len(element) > 0:
                        if element in test_dataOne:
                            s = test_dataOne[element]
                            s.add(cookie)
                            test_dataOne[element] = s
                        else:
                            s = set()
                            test_dataOne[element] = s
                    elif len(element) == 0 and len(segmented) == 1:
                        empty_cookies_in_test += 1
                        isEmpty = True
            if not isEmpty:
                testCookies.add(cookie)
                non_empty_cookies_in_test += 1
        except IndexError:
            print(x)
            print("Index: %d" % index)
    index += 1
f2.close()


# Cookie                               Segment
# 010011e17ac73b92d9d9dc78cbc4418b ==> [F09828_0, F09828_14186, L15029_10004]


out = open('output2.txt', 'w', encoding='utf8')

non_empty_cookies_in_baseline_only = len(baselineCookies.difference(testCookies))
non_empty_cookies_in_test_only = len(testCookies.difference(baselineCookies))

non_empty_cookies_in_both = len(baselineCookies.intersection(testCookies))
non_empty_cookies_in_either = len(baselineCookies | testCookies)


segmentsGainedWriter = []
segmentsLostWriter = []
# # Segments that gained extra cookies
segmentsGainedCookies = 0
segmentsLostCookies = 0

# Cookies in extra segments
extraCookies = {}
# Cookies omitted from segments
omittedCookies = {}
# # O(n)
for x in sorted(baseline_dataOne):
    # O(1)
    if x in test_dataOne:
        # Segment Lost Cookie - Cookies ommited from this segment
        # O(len(baseline_dataOne[x]))
        resultOne = baseline_dataOne[x].difference(test_dataOne[x])
        # Segment Gained - Cookies in this extra segment
        resultTwo = test_dataOne[x].difference(baseline_dataOne[x])
        if len(resultTwo) > 0:
            segmentsGainedWriter.append(
                str(segmentsGainedCookies).ljust(4) + x.ljust(16) + str(len(resultTwo)).ljust(4) + sorted(resultTwo).__str__() + "\n")
            segmentsGainedCookies += 1
            # x is the segment and the set in resultTwo are the extra cookies
            for element in resultTwo:
                if element not in extraCookies:
                    s = set()
                    s.add(x)
                    extraCookies[element] = s
                else:
                    s = extraCookies[element]
                    s.add(x)
                    extraCookies[element] = s
        if len(resultOne) > 0:
            segmentsLostWriter.append(
                str(segmentsLostCookies).ljust(8) + x.ljust(16) + str(len(resultOne)).ljust(4) + sorted(resultOne).__str__() + "\n")
            segmentsLostCookies += 1
            for element in resultOne:
                if element not in omittedCookies:
                    s = set()
                    s.add(x)
                    omittedCookies[element] = s
                else:
                    s = omittedCookies[element]
                    s.add(x)
                    omittedCookies[element] = s

out.write("Summary:\n")
out.write("total cookies in baseline = %d\n" % total_cookies_in_baseline)
out.write("empty cookies in baseline = %d\n" % empty_cookies_in_baseline)
out.write("non-empty cookies in baseline = %d\n" % non_empty_cookies_in_baseline)
out.write("total cookies in test = %d\n" % total_cookies_in_test)
out.write("empty cookies in test = %d\n" % empty_cookies_in_test)
out.write("non-empty cookies in test = %d\n" % non_empty_cookies_in_test)
out.write("non-empty cookies in baseline only = %d\n" % non_empty_cookies_in_baseline_only)
out.write("non-empty cookies in test only = %d\n" % non_empty_cookies_in_test_only)
out.write("non-empty cookies in both = %d\n" % non_empty_cookies_in_both)
out.write("non-empty cookies in either = %d\n" % non_empty_cookies_in_either)

out.write("\n")
out.write("Segments with added cookies: %d / %d\n" % (segmentsGainedCookies, len(baseline_dataOne)))
out.writelines(segmentsGainedWriter)
out.write("\n")
out.write("Segments with missing cookies: %d / %d\n" % (segmentsLostCookies, len(baseline_dataOne)))
out.writelines(segmentsLostWriter)
out.write("\n")

out.write("Cookies in extra segments %d / %d\n" % (len(extraCookies), 999999))
index = 0
# Cookies in extra segments
for element in sorted(extraCookies):
    out.write(str(index).ljust(4) + element.ljust(36) + str(len(extraCookies[element])).ljust(4) + sorted(extraCookies[element]).__str__() + "\n")
    index += 1

out.write("\n")

index = 0
out.write("Cookies omitted from segments %d / %d\n" % (len(omittedCookies), 999999))
for element in sorted(omittedCookies):
    padding = 4
    if index >= 1000:
        padding = 8
    out.write(str(index).ljust(padding) + element.ljust(36) + str(len(omittedCookies[element])).ljust(4) + sorted(omittedCookies[element]).__str__() + "\n")
    index += 1

out.close()

