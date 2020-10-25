# #4 - report by Moritz Raabe (@m_r_tz)

## Introduction

In this challenge we are presented with a single [Excel](https://www.microsoft.com/en-us/microsoft-365/excel) spreadsheet. It's in the `.xls` format, which was used up until the release of Office 2007. The player is told that the spreadsheet is a "macro thrill-ride", which is common (if not ubiquitous) for malicious documents. Let's see if this one lives up to our expectations.

## Part 1 - Recon

Since we're dealing with a document that has macros, we need to find a way to extract the underlying code. Specifically, we need to be able to access the document's [OLE](https://en.wikipedia.org/wiki/Object_Linking_and_Embedding) streams. OLE streams are essentially just embedded data, sort of like a `.zip` file. Enter [oledump](https://blog.didierstevens.com/programs/oledump-py/), a neat tool that allows us to extract these streams for analysis.

Let's run it on the `report.xls` file and see what we get:
```
$ python oledump.py /d/Development/Flare-On\ 2020/4-report_for_writeup/report.xls
  1:       108 '\x01CompObj'
  2:       244 '\x05DocumentSummaryInformation'
  3:    352240 'Workbook'
  4:        97 '_VBA_PROJECT_CUR/F/\x01CompObj'
  5:       284 '_VBA_PROJECT_CUR/F/\x03VBFrame'
  6:       163 '_VBA_PROJECT_CUR/F/f'
  7:   1143744 '_VBA_PROJECT_CUR/F/o'
  8:       534 '_VBA_PROJECT_CUR/PROJECT'
  9:        68 '_VBA_PROJECT_CUR/PROJECTwm'
 10: m    1388 '_VBA_PROJECT_CUR/VBA/F'
 11:     10518 '_VBA_PROJECT_CUR/VBA/Sheet1'
 12: M    1785 '_VBA_PROJECT_CUR/VBA/ThisWorkbook'
 13:      4327 '_VBA_PROJECT_CUR/VBA/_VBA_PROJECT'
 14:      3345 '_VBA_PROJECT_CUR/VBA/__SRP_0'
 15:       486 '_VBA_PROJECT_CUR/VBA/__SRP_1'
 16:       592 '_VBA_PROJECT_CUR/VBA/__SRP_2'
 17:       140 '_VBA_PROJECT_CUR/VBA/__SRP_3'
 18:      3158 '_VBA_PROJECT_CUR/VBA/__SRP_4'
 19:       473 '_VBA_PROJECT_CUR/VBA/__SRP_5'
 20:       448 '_VBA_PROJECT_CUR/VBA/__SRP_6'
 21:        66 '_VBA_PROJECT_CUR/VBA/__SRP_7'
 22:       827 '_VBA_PROJECT_CUR/VBA/dir'
```

Notice the `M` indicator for item #12. According to the oledump documentation, `M` means the stream contains macros! Let's see what's inside.

```
$ python oledump.py -s 12 -v /d/Development/Flare-On\ 2020/4-report_for_writeup/report.xls

Attribute VB_Name = "ThisWorkbook"
Attribute VB_Base = "0{00020819-0000-0000-C000-000000000046}"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Attribute VB_TemplateDerived = False
Attribute VB_Customizable = True
Sub Workbook_Open()
Sheet1.folderol
End Sub

Sub Auto_Open()
Sheet1.folderol
End Sub
```

Well, that's not very helpful. Luckily, we have another tool in our toolbox: `olevba` from [oletools](https://github.com/decalage2/oletools). Let's run it on `report.xls` and see what we get.

```
$ olevba /d/Development/Flare-On\ 2020/4-report_for_writeup/report.xls

...
+----------+--------------------+---------------------------------------------+
|Type      |Keyword             |Description                                  |
+----------+--------------------+---------------------------------------------+
|AutoExec  |Auto_Open           |Runs when the Excel Workbook is opened       |
|AutoExec  |Workbook_Open       |Runs when the Excel Workbook is opened       |
|Suspicious|GetObject           |May get an OLE object with a running instance|
|Suspicious|CreateObject        |May create an OLE object                     |
|Suspicious|Environ             |May read system environment variables        |
|Suspicious|Open                |May open a file                              |
|Suspicious|Write               |May write to a file (if combined with Open)  |
|Suspicious|Put                 |May write to a file (if combined with Open)  |
|Suspicious|Lib                 |May run code from a DLL                      |
|Suspicious|Chr                 |May attempt to obfuscate specific strings    |
|          |                    |(use option --deobf to deobfuscate)          |
|Suspicious|Xor                 |May attempt to obfuscate specific strings    |
|          |                    |(use option --deobf to deobfuscate)          |
|Suspicious|Binary              |May read or write a binary file (if combined |
|          |                    |with Open)                                   |
|Suspicious|Hex Strings         |Hex-encoded strings were detected, may be    |
|          |                    |used to obfuscate strings (option --decode to|
|          |                    |see all)                                     |
|IOC       |wininet.dll         |Executable file name                         |
|IOC       |winmm.dll           |Executable file name                         |
|Suspicious|VBA Stomping        |VBA Stomping was detected: the VBA source    |
|          |                    |code and P-code are different, this may have |
|          |                    |been used to hide malicious code             |
+----------+--------------------+---------------------------------------------+
```

 (The full output can be found [here](./report_olevba_analysis.txt).)

## Part 2 - Initial analysis

 As `olevba` indicated, the macro code is quite unusual. This is to be expected from malware. The code below implements a string deobfuscation function.

 ```vb
 Function rigmarole(es As String) As String
    Dim furphy As String
    Dim c As Integer
    Dim s As String
    Dim cc As Integer
    furphy = ""
    For i = 1 To Len(es) Step 4
        c = CDec("&H" & Mid(es, i, 2))
        s = CDec("&H" & Mid(es, i + 2, 2))
        cc = c - s
        furphy = furphy + Chr(cc)
    Next i
    rigmarole = furphy
End Function
```

Looking for usages of this function, we immediately find something of interest:

```vb
    onzo = Split(F.L, ".")
    ...
    Set fudgel = GetObject(rigmarole(onzo(7)))
```

To figure out what `F.L` is, we can search the `olevba` output with a regular expression:

```re
([A-F0-9]{2})\.
```

This will find all 2-digit hexadecimal literals that are followed by a `.` character. The value of `F.L` is

```
9655B040B64667238524D15D6201.B95D4E01C55CC562C7557405A532D768C55FA12DD074DC697A06E172992CAF3F8A5C7306B7476B38.C555AC40A7469C234424.853FA85C470699477D3851249A4B9C4E.A855AF40B84695239D24895D2101D05CCA62BE5578055232D568C05F902DDC74D2697406D7724C2CA83FCF5C2606B547A73898246B4BC14E941F9121D464D263B947EB77D36E7F1B8254.853FA85C470699477D3851249A4B9C4E.9A55B240B84692239624.CC55A940B44690238B24CA5D7501CF5C9C62B15561056032C468D15F9C2DE374DD696206B572752C8C3FB25C3806.A8558540924668236724B15D2101AA5CC362C2556A055232AE68B15F7C2DC17489695D06DB729A2C723F8E5C65069747AA389324AE4BB34E921F9421.CB55A240B5469B23.AC559340A94695238D24CD5D75018A5CB062BA557905A932D768D15F982D.D074B6696F06D5729E2CAE3FCF5C7506AD47AC388024C14B7C4E8F1F8F21CB64
```

## Part 3 - Scripting

Let's re-implement the `rigmarole` function in Python.

```py
def str_decipher(input):
    res = ""
    for i in range(0, len(input), 4):
        a = int(input[i:i+2], 16)
        b = int(input[i+2:i+4], 16)
        c = a - b
        res += chr(c)
    return res
```

We can use this as part of a script to decode the entirety of `F.L`. (See [split_string_decoder.py](./split_string_decoder.py) for source.)

Running our script gives us readable results:
```
parts[0] = AppData
parts[1] = \Microsoft\stomp.mp3
parts[2] = play
parts[3] = FLARE-ON
parts[4] = Sorry, this machine is not supported.
parts[5] = FLARE-ON
parts[6] = Error
parts[7] = winmgmts:\\.\root\CIMV2
parts[8] = SELECT Name FROM Win32_Process
parts[9] = vbox
parts[10] = WScript.Network
parts[11] = \Microsoft\v.png
```

Now that we've got _that_ out of the way, let's move on to the next interesting part of the macro.

## Part 4 - Going down the wabbit hole

This code is a perfect example of why you should _always_ double check the assembly (in this case, VBA P-code) before trusting decompilation. Can you spot the problem?

```vb
    xertz = Array(&H11, &H22, &H33, &H44, &H55, &H66, &H77, &H88, &H99, &HAA, &HBB, &HCC, &HDD, &HEE)

    wabbit = canoodle(F.T.Text, 0, 168667, xertz)
    mf = Environ(rigmarole(onzo(0))) & rigmarole(onzo(1))
    Open mf For Binary Lock Read Write As #fn
      Put #fn, , wabbit
    Close #fn
```

The `xertz` array _appears_ to be initialized with references to columns in the spreadsheet. However, studying the P-code reveals something different.

```
' Line #51:
' 	LitHI2 0x0011 
' 	LitHI2 0x0022 
' 	LitHI2 0x0033 
' 	LitHI2 0x0044 
' 	LitHI2 0x0055 
' 	LitHI2 0x0066 
' 	LitHI2 0x0077 
' 	LitHI2 0x0088 
' 	LitHI2 0x0099 
' 	LitHI2 0x00AA 
' 	LitHI2 0x00BB 
' 	LitHI2 0x00CC 
' 	LitHI2 0x00DD 
' 	LitHI2 0x00EE 
' 	ArgsArray Array 0x000E 
' 	St xertz 
```

`xertz` is _actually_ an array of bytes (although items are stored as shorts.) This means the code should look more like:

```vb
    xertz = Array(0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE)

    wabbit = canoodle(F.T.Text, 0, 168667, xertz)
    mf = Environ(rigmarole(onzo(0))) & rigmarole(onzo(1))
    Open mf For Binary Lock Read Write As #fn
      Put #fn, , wabbit
    Close #fn
```

Also note that we can replace `mf` with `%AppData%\Microsoft\stomp.mp3`. At least... that's what the script _wants_ you to think.

### P-code stomping

Remember that warning?
> VBA Stomping was detected

Turns out `olevba` was correct. If we read the decompiled code, it looks like a file is being written to `%AppData%\Microsoft\stomp.mp3`, because `onzo(0) = "AppData"` and `onzo(1) = "\Microsoft\stomp.mp3"`. If we look at the _P-code_, though, we see something different:

```
' Line #66:
...
' 	LitDI2 0x000B 
' 	ArgsLd onzo 0x0001 
```

`0x000B` is equal to 11. The macro is _actually_ calling `onzo(11)`, which returns `"\Microsoft\v.png"`.

We could go on with analyzing the P-code to spot all the tricks, but there's a much easier alternative. We can use the [pcode2code](https://pypi.org/project/pcode2code/) tool, which will decompile the _P-code_ rather than the stomped VBA source.

```bash
$ pip install pcode2code
$ pcode2code /d/Development/Flare-On\ 2020/4-report_for_writeup/report.xls > stomped_decompilation.vb
```

The `stomped_decompilation.vb` file can be accessed [here](./stomped_decompilation.vb).

Now that we have a proper decompilation, let's take another look.

## Part 5 - Endgame

Here's our new target code:

```vb
        Set groke = CreateObject(rigmarole(onzo(10)))
        firkin = groke.UserDomain
        If firkin <> rigmarole(onzo(3)) Then
          MsgBox rigmarole(onzo(4)), vbCritical, rigmarole(onzo(6))
          End
        End If
        n = Len(firkin)
        For i = 1 To n
          buff(n - i) = Asc(Mid$(firkin, i, 1))
        Next
        wabbit = canoodle(F.T.Text, 2, 285729, buff)
```

Recall that `rigmarole(onzo(3)) = "FLARE-ON"`. The macro is checking to see if the computer's NetBIOS name (also known as `UserDomain`) is equal to `FLARE-ON`. Now we know that `firkin` must be equal to `FLARE-ON` as well, and `buff` is just `firkin` reversed.

We've already determined the real output file path, so we can use [another Python script](./giant_blob_decoder.py) to do the hard work for us.

And just like that, we have the flag!

![Flag image](./v.png)

**`thi5_cou1d_h4v3_b33n_b4d@flare-on.com`**

## Conclusion

This challenge is a great lesson in _checking your assumptions._ P-code stomping is a common trick, and it's super easy to get tripped up if you've never seen it before. This was my first exposure to malicious Office documents, and I fell into the trap. Thankfully, I was able to escape.

## Bonus

Decrypting `F.T.Text` with the stomped key and length arguments yields a [valid MP3](./stomp.mp3) with 8 seconds of stomping. 

![MP3](https://s.heyitsleo.io/ShareX/2020/10/ApplicationFrameHost_dL5lrrVQo3.png)

_It's by P. Code. How appropriate!_