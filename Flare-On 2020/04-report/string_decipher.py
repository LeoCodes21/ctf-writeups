# Python implementation of "rigmarole" string decipher function

def str_decipher(input):
    res = ""
    for i in range(0, len(input), 4):
        a = int(input[i:i+2], 16)
        b = int(input[i+2:i+4], 16)
        c = a - b
        res += chr(c)
    return res

# Function canoodle(panjandrum As String, ardylo As Integer, s As Long, bibble As Variant) As Byte()
#     Dim quean As Long
#     Dim cattywampus As Long
#     Dim kerfuffle() As Byte
#     ReDim kerfuffle(s)
#     quean = 0
#     For cattywampus = 1 To Len(panjandrum) Step 4
#         kerfuffle(quean) = CByte("&H" & Mid(panjandrum, cattywampus + ardylo, 2)) Xor bibble(quean Mod (UBound(bibble) + 1))
#         quean = quean + 1
#         If quean = UBound(kerfuffle) Then
#             Exit For
#         End If
#     Next cattywampus
#     canoodle = kerfuffle
# End Function

def canoodle(panjandrum, ardylo, s, bibble):
    quean = 0
    kerfuffle = [0] * s

    for cattywampus in range(0, len(panjandrum), 4):
        kerfuffle[quean] = int(panjandrum[cattywampus+ardylo:cattywampus+ardylo+2], 16) ^ bibble[quean % len(bibble)]
        quean += 1
        if quean == s:
            break
    return bytearray(kerfuffle)