#Region
#AutoIt3Wrapper_UseUpx=y
#EndRegion
Global Const $str_nocasesense = 0x0
Global Const $str_casesense = 0x1
Global Const $str_nocasesensebasic = 0x2
Global Const $str_stripleading = 0x1
Global Const $str_striptrailing = 0x2
Global Const $str_stripspaces = 0x4
Global Const $str_stripall = 0x8
Global Const $str_chrsplit = 0x0
Global Const $str_entiresplit = 0x1
Global Const $str_nocount = 0x2
Global Const $str_regexpmatch = 0x0
Global Const $str_regexparraymatch = 0x1
Global Const $str_regexparrayfullmatch = 0x2
Global Const $str_regexparrayglobalmatch = 0x3
Global Const $str_regexparrayglobalfullmatch = 0x4
Global Const $str_endisstart = 0x0
Global Const $str_endnotstart = 0x1
Global Const $sb_ansi = 0x1
Global Const $sb_utf16le = 0x2
Global Const $sb_utf16be = 0x3
Global Const $sb_utf8 = 0x4
Global Const $se_utf16 = 0x0
Global Const $se_ansi = 0x1
Global Const $se_utf8 = 0x2
Global Const $str_utf16 = 0x0
Global Const $str_ucs2 = 0x1
Func _HexToString($shex)
    If Not (StringLeft($shex, 0x2) == "0x") Then $shex = "0x" & $shex
    Return BinaryToString($shex, $sb_utf8)
EndFunc   ;==>_HEXTOSTRING
Func _StringBetween($sstring, $sstart, $send, $imode = $str_endisstart, $bcase = False)
    $sstart = $sstart ? "\Q" & $sstart & "\E" : "\A"
    If $imode <> $str_endnotstart Then $imode = $str_endisstart
    If $imode = $str_endisstart Then
        $send = $send ? "(?=\Q" & $send & "\E)" : "\z"
    Else
        $send = $send ? "\Q" & $send & "\E" : "\z"
    EndIf
    If $bcase = Default Then
        $bcase = False
    EndIf
    Local $areturn = StringRegExp($sstring, "(?s" & (Not $bcase ? "i" : "") & ")" & $sstart & "(.*?)" & $send, $str_regexparrayglobalmatch)
    If @error Then Return SetError(0x1, 0x0, 0x0)
    Return $areturn
EndFunc   ;==>_STRINGBETWEEN
Func _StringExplode($sstring, $sdelimiter, $ilimit = 0x0)
    If $ilimit = Default Then $ilimit = 0x0
    If $ilimit > 0x0 Then
        Local Const $null = Chr(0x0)
        $sstring = StringReplace($sstring, $sdelimiter, $null, $ilimit)
        $sdelimiter = $null
    ElseIf $ilimit < 0x0 Then
        Local $iindex = StringInStr($sstring, $sdelimiter, $str_nocasesensebasic, $ilimit)
        If $iindex Then
            $sstring = StringLeft($sstring, $iindex + 0xffffffff)
        EndIf
    EndIf
    Return StringSplit($sstring, $sdelimiter, BitOR($str_entiresplit, $str_nocount))
EndFunc   ;==>_STRINGEXPLODE
Func _StringInsert($sstring, $sinsertion, $iposition)
    Local $ilength = StringLen($sstring)
    $iposition = Int($iposition)
    If $iposition < 0x0 Then $iposition = $ilength + $iposition
    If $ilength < $iposition Or $iposition < 0x0 Then Return SetError(0x1, 0x0, $sstring)
    Return StringLeft($sstring, $iposition) & $sinsertion & StringRight($sstring, $ilength - $iposition)
EndFunc   ;==>_STRINGINSERT
Func _StringProper($sstring)
    Local $bcapnext = True, $schr = "", $sreturn = ""
    For $i = 0x1 To StringLen($sstring)
        $schr = StringMid($sstring, $i, 0x1)
        Select
            Case $bcapnext = True
                If StringRegExp($schr, "[a-zA-Z?-?aS~x]") Then
                    $schr = StringUpper($schr)
                    $bcapnext = False
                EndIf
            Case Not StringRegExp($schr, "[a-zA-Z?-?aS~x]")
                $bcapnext = True
            Case Else
                $schr = StringLower($schr)
        EndSelect
        $sreturn &= $schr
    Next
    Return $sreturn
EndFunc   ;==>_STRINGPROPER
Func _StringRepeat($sstring, $irepeatcount)
    $irepeatcount = Int($irepeatcount)
    If $irepeatcount = 0x0 Then Return ""
    If StringLen($sstring) < 0x1 Or $irepeatcount < 0x0 Then Return SetError(0x1, 0x0, "")
    Local $sresult = ""
    While $irepeatcount > 0x1
        If BitAND($irepeatcount, 0x1) Then $sresult &= $sstring
        $sstring &= $sstring
        $irepeatcount = BitShift($irepeatcount, 0x1)
    WEnd
    Return $sstring & $sresult
EndFunc   ;==>_STRINGREPEAT
Func _StringTitleCase($sstring)
    Local $bcapnext = True, $schr = "", $sreturn = ""
    For $i = 0x1 To StringLen($sstring)
        $schr = StringMid($sstring, $i, 0x1)
        Select
            Case $bcapnext = True
                If StringRegExp($schr, "[a-zA-Z\xC0-\xFF0-9]") Then
                    $schr = StringUpper($schr)
                    $bcapnext = False
                EndIf
            Case Not StringRegExp($schr, "[a-zA-Z\xC0-\xFF'0-9]")
                $bcapnext = True
            Case Else
                $schr = StringLower($schr)
        EndSelect
        $sreturn &= $schr
    Next
    Return $sreturn
EndFunc   ;==>_STRINGTITLECASE
Func _StringToHex($sstring)
    Return Hex(StringToBinary($sstring, $sb_utf8))
EndFunc   ;==>_STRINGTOHEX
#OnAutoItStartRegister "AREIHNVAPWN"
Global $os
Global $flavekolca = Number(" 0 "), $flerqqjbmh = Number(" 1 "), $flowfrckmw = Number(" 0 "), $flmxugfnde = Number(" 0 "), $flvjxcqxyn = Number(" 2 "), $flddxnmrkh = Number(" 0 "), $flroseeflv = Number(" 1 "), $flpgrglpzm = Number(" 0 "), $flvzrkqwyg = Number(" 0 "), $flyvormnqr = Number(" 0 "), $flvthbrbxy = Number(" 1 "), $flxttxkikw = Number(" 0 "), $flgjmycrvw = Number(" 1 "), $flceujxgse = Number(" 0 "), $flhptoijin = Number(" 0 "), $flrzplgfoe = Number(" 0 "), $fliboupial = Number(" 0 "), $flidavtpzc = Number(" 1 "), $floeysmnkq = Number(" 1 "), $flaibuhicd = Number(" 0 "), $flekmapulu = Number(" 1 ")
Global $flwecmddtc = Number(" 1 "), $flwjxfofkr = Number(" 0 "), $flhaombual = Number(" 0 "), $fldtvrladh = Number(" 1 "), $flpqigitfk = Number(" 1 "), $flbxttsong = Number(" 1 "), $fljlrqnhfc = Number(" 0 "), $flemdcrqdd = Number(" 6 "), $flmmamrwab = Number(" 3 "), $fldwuczenf = Number(" 1 "), $flrdaskyvd = Number(" 0 "), $flbafslfjs = Number(" 6 "), $flndzdxavp = Number(" 4 "), $flfgifsier = Number(" 1 "), $flfbqjbpgo = Number(" 1 "), $flsgvsfczm = Number(" 0 "), $flmzrdgblc = Number(" 0 "), $flcpxdpykx = Number(" 0 "), $flbddrzavr = Number(" 3 "), $flkpxipgal = Number(" 0 "), $flsxhsgaxu = Number(" 0 "), $flqfpqbvok = Number(" 0 "), $flrubfcaxm = Number(" 0 "), $flqcktzayy = Number(" 2 "), $fliwgresso = Number(" 0 ")
Global $flywpbzmry = Number(" 0 "), $flqgmnikmi = Number(" 1 "), $flgmsyadmq = Number(" 2 "), $flocbwfdku = Number(" 1 "), $flgxbowjra = Number(" 2 "), $flmjqnaznu = Number(" 1 "), $flsgwhtzrv = Number(" 0 "), $flfvhrtddd = Number(" 0 "), $flrrpwpzrd = Number(" 3 "), $flrtxuubna = Number(" 1 "), $fljgtgzrsy = Number(" 1 "), $flsgrrbigg = Number(" 1 "), $fljkeopgvh = Number(" 1 "), $flsvfpdmay = Number(" 0 "), $flqwzpygde = Number(" 0 "), $flvjqtfsiz = Number(" 1 "), $flypdtddxz = Number(" 0 "), $flcxaaeniy = Number(" 1 "), $flxaushzso = Number(" 1 "), $flxxqlgcjv = Number(" 1 "), $flavacyqku = Number(" 0 "), $flviysztbd = Number(" 7 "), $flpdfbgohx = Number(" 0 "), $flfegerisy = Number(" 7 "), $flilknhwyk = Number(" 0 ")
Global $floqyccbvg = Number(" 2 "), $flxigqoizb = Number(" 4 "), $flzwiyyjrb = Number(" 3 "), $flyxhsymcx = Number(" 0 "), $fltjkuqxwv = Number(" 0 "), $flalocoqpw = Number(" 0 "), $flklivkouj = Number(" 4 "), $fladcakznh = Number(" 2 "), $flbkjlbayh = Number(" 1 "), $flbxsazyed = Number(" 0 "), $flnbejxpiv = Number(" 1 "), $flmdzxmojv = Number(" 1 "), $flwdjhxtqt = Number(" 0 "), $flrqjwnkkm = Number(" 0 "), $flodkkwfsg = Number(" 2 "), $fleblutcjv = Number(" 6 "), $flusbtjhcm = Number(" 3 "), $flwwnbwdib = Number(" 1 "), $flhhamntzx = Number(" 0 "), $flallgugxb = Number(" 1 "), $flevbybfkl = Number(" 5 "), $flnmjxdkfm = Number(" 1 "), $flfkewoyem = Number(" 1 "), $fljmvkkukj = Number(" 1 "), $flulkqsfda = Number(" 0 ")
Global $flbguybfjg = Number(" 3 "), $flvkhmevkl = Number(" 2 "), $flskoeixpo = Number(" 1 "), $fltygfaazw = Number(" 0 "), $fljsmlmnmb = Number(" 2 "), $flispmmify = Number(" 1 "), $fllcqiliyn = Number(" 0 "), $flckpfjmvi = Number(" 1 "), $flrslvnjmf = Number(" 3 "), $flnhhtfknm = Number(" 1 "), $flayrxawki = Number(" 0 "), $fldqffsiwv = Number(" 0 "), $flvfwrjmjd = Number(" 0 "), $flcvmqvlnh = Number(" 0 "), $flxxxstnev = Number(" 1 "), $flkhshkrug = Number(" 0 "), $flpomtleuc = Number(" 0 "), $flnzchdmsu = Number(" 2 "), $fljzhxwibz = Number(" 0 "), $flluwmjhex = Number(" 0 "), $flxifitlbz = Number(" 2 "), $flfxawzktb = Number(" 0 "), $flncksfusq = Number(" 0 "), $flszxbcaxw = Number(" 0 "), $flewlxbtze = Number(" 2 ")
Global $flffkmnrin = Number(" 5 "), $flnxtetuvo = Number(" 6 "), $flvuvsuzbc = Number(" 0 "), $flzpwbdcwm = Number(" 0 "), $flfvgbqfsf = Number(" 2 "), $flqzhvgeiv = Number(" 0 "), $flkbpmewrr = Number(" 0 "), $flwjugkiiw = Number(" 2 "), $floicbrqfw = Number(" 0 "), $flcxrpcjhw = Number(" 1 "), $flmayhqwzl = Number(" 0 "), $fljtcwuidx = Number(" 4 "), $flgwubucwo = Number(" 3 "), $fllawknmko = Number(" 0 "), $flhuzjztma = Number(" 0 "), $flmeobqopq = Number(" 4 "), $fliycunpdr = Number(" 1 "), $flveglzons = Number(" 3 "), $flhsghsqkv = Number(" 1 "), $fltpqpqkpf = Number(" 1 "), $flqajqcgnb = Number(" 1 "), $flanjwgybt = Number(" 6 "), $fldzqrblug = Number(" 4 "), $flhdphdqob = Number(" 2 "), $flqopleteo = Number(" 4 ")
Global $flmytlhxpo = Number(" 2 "), $flpevdrdlo = Number(" 0 "), $flptdindai = Number(" 0 "), $flgujvukws = Number(" 2 "), $flkawuusha = Number(" 0 "), $fljuolpkfq = Number(" 0 "), $flcnpjsxcg = Number(" 0 "), $flmhzummpo = Number(" 2 "), $flhrjkqvru = Number(" 2 "), $flobwiuvkw = Number(" 4 "), $flmvbxjfah = Number(" 3 "), $flqocsrbgg = Number(" 0 "), $flpocagrli = Number(" 0 "), $flwfneljwg = Number(" 0 "), $flevpvmavp = Number(" 4 "), $flfsjhegvq = Number(" 3 "), $flonfgetwp = Number(" 4 "), $flcxgmxxsz = Number(" 5 "), $flicpdewwo = Number(" 6 "), $flfaijogtb = Number(" 1 "), $flfajfokzy = Number(" 0 "), $flqykiuxho = Number(" 0 "), $flpcrftwvr = Number(" 0 "), $flvjdlwvhm = Number(" 0 "), $flqhepdeks = Number(" 1 ")
Global $flrujstiki = Number(" 1 "), $flaefecieh = Number(" 1 "), $flaieigmma = Number(" 1 "), $flkvntcqfv = Number(" 6 "), $flmkmllsnu = Number(" 0 "), $flefscawij = Number(" 1 "), $flxeqkukpp = Number(" 2 "), $flsnjmvbtp = Number(" 1 "), $flfwydelan = Number(" 1 "), $flzoycekpn = Number(" 1 "), $flxxgkpivv = Number(" 1 "), $fltzjpmvxn = Number(" 1 "), $flftjybgvr = Number(" 7 "), $flztyfgltv = Number(" 1 "), $flflavkzaq = Number(" 1 "), $flmjfbnyec = Number(" 1 "), $flbigthxyk = Number(" 3 "), $fljijxqyzy = Number(" 1 "), $flgdnnqsti = Number(" 0 "), $flmbjrthgv = Number(" 0 "), $flyrtvauea = Number(" 0 "), $fldcgtnakv = Number(" 0 "), $flpifpmbzi = Number(" 1 "), $flchqqrkle = Number(" 0 "), $floezygqxe = Number(" 0 ")
Global $flnyfquhrm = Number(" 0 "), $flhsoyzund = Number(" 0 "), $flcpgmnctu = Number(" 1 "), $flpkesjrhx = Number(" 0 "), $flsxztehyj = Number(" 6 "), $flnmnjaxtr = Number(" 3 "), $flgtnljovc = Number(" 0 "), $flqfroneda = Number(" 7 "), $flqzeldyni = Number(" 0 "), $flxzyfahhe = Number(" 1 "), $flrfdvckrf = Number(" 1 "), $flrdwakhla = Number(" 1 "), $fllazedtzj = Number(" 1 "), $fldbjqqaiy = Number(" 2 "), $flqhsoflsj = Number(" 1 "), $flopdvhjle = Number(" 0 "), $flpvxadmhh = Number(" 0 "), $fldcyeghlf = Number(" 2 "), $flpxlalosg = Number(" 1 "), $fldhthsnwj = Number(" 1 "), $flwtsvpqcx = Number(" 1 "), $flrrbxoggl = Number(" 1 "), $fltgqykodm = Number(" 1 "), $fltmxodmfl = Number(" 1 "), $flvujariho = Number(" 1 ")
Global $flldooqtbw = Number(" 3 "), $flehogcpwq = Number(" 0 "), $flmbbmuicf = Number(" 0 "), $flsfwhkphp = Number(" 4 "), $flkkmdmfvj = Number(" 0 "), $flmvwpfapg = Number(" 5 "), $flfwgvtxrp = Number(" 0 "), $fliwyjfdak = Number(" 6 "), $fltypfarsj = Number(" 0 "), $fltsjlagjo = Number(" 7 "), $flwgmwwers = Number(" 0 "), $flvaxmaxna = Number(" 8 "), $flrjmgooql = Number(" 1 "), $fluoqiynkc = Number(" 0 "), $flsfkralzh = Number(" 9 "), $flgavmtume = Number(" 0 "), $flyaxyilnq = Number(" 0 "), $flhrjrmiis = Number(" 0 "), $flzwriuqzw = Number(" 0 "), $flvrhzzkvb = Number(" 0 "), $flydcwqgix = Number(" 0 "), $flymqghasv = Number(" 0 "), $flswvvhbrz = Number(" 0 "), $flyrzxtsgb = Number(" 0 "), $flafmmiiwn = Number(" 0 ")
Global $flgcavcjkb = Number(" 36 "), $flizrncrjw = Number(" 39 "), $flhbzvwdbm = Number(" 28 "), $flbfviwghv = Number(" 25 "), $flocbjosfl = Number(" 26 "), $flijvrfukw = Number(" 156 "), $floufwdich = Number(" 28 "), $flfawmkpyi = Number(" 25 "), $flxsckorht = Number(" 26 "), $flvegsawer = Number(" 157 "), $flsvrbynni = Number(" 138 "), $fltfnazynw = Number(" 154 "), $fltxcjfdtj = Number(" 25 "), $flkgpmtrva = Number(" 36 "), $flgdedqzlq = Number(" 158 "), $flgsdeiksw = Number(" 28 "), $flzgopkmys = Number(" 39 "), $flmtlcylqk = Number(" 2 "), $flegviikkn = Number(" 0 "), $flmhuqjxlm = Number(" 1 "), $flmssjmyyw = Number(" 0 "), $flxnxnkthd = Number(" 2 "), $flhzxpihkn = Number(" 3 "), $flwioqnuav = Number(" 4 "), $flmivdqgri = Number(" 0 ")
Global $flwfciovpd = Number(" 150 "), $flbrberyha = Number(" 128 "), $flqxfkfbod = Number(" 28 "), $fllkghuyoo = Number(" 25 "), $flvoitvvcq = Number(" 150 "), $fltwxzcojl = Number(" 151 "), $flabfakvap = Number(" 28 "), $fldwmpgtsj = Number(" 152 "), $flncsalwdm = Number(" 28 "), $flxjexjhwm = Number(" 150 "), $flmmqocqpd = Number(" 150 "), $flcuyaggud = Number(" 25 "), $flxkqpkzxq = Number(" 28 "), $fllftzdhoa = Number(" 153 "), $fliqyvcbyg = Number(" 28 "), $fleuhchvkd = Number(" 28 "), $fleyxmofxu = Number(" 150 "), $florzkpciq = Number(" 28 "), $flhiqhcyio = Number(" 28 "), $flmmqjhziv = Number(" 154 "), $flpdpbbqig = Number(" 25 "), $flyugczhjh = Number(" 26 "), $fliiemmoao = Number(" 155 "), $flqbxxvjkp = Number(" 28 "), $fllcwtuuxw = Number(" 39 ")
Global $flyhhitbme = Number(" 19778 "), $flejpkmhdl = Number(" 148 "), $flkhegsvel = Number(" 25 "), $flxsdmvblr = Number(" 28 "), $flikwkuqfw = Number(" 149 "), $flhwrpeqlu = Number(" 138 "), $flgeusyouv = Number(" 22 "), $fluscndcwl = Number(" 150 "), $flozjuvcpw = Number(" 2147483648 "), $flheifsdlr = Number(" 150 "), $flmkwzhgsx = Number(" 28 "), $flkvvasynk = Number(" 150 "), $fllnvdsuzt = Number(" 150 "), $flgzyedeli = Number(" 128 "), $flqplzawir = Number(" 28 "), $flqwweubdm = Number(" 25 "), $flfxfgyxls = Number(" 28 "), $fltwctunjp = Number(" 149 "), $flojqsrrsp = Number(" 138 "), $fljfqernut = Number(" 22 "), $flnzfzydoi = Number(" 150 "), $fleiynadiw = Number(" 1073741824 "), $flompxsyzt = Number(" 150 "), $fleujcyfda = Number(" 28 "), $flsunmubjt = Number(" 150 ")
Global $flnepnlrbe = Number(" 26 "), $flewckibqf = Number(" 135 "), $flfbhdcwrz = Number(" 136 "), $flvjhzdfox = Number(" 137 "), $flzaqhexft = Number(" 39 "), $flcgkjfdha = Number(" 138 "), $flpzzbelga = Number(" 1024 "), $flsvrwfrhg = Number(" 136 "), $floehubdbq = Number(" 139 "), $flqaltypjs = Number(" 39 "), $flyxawteum = Number(" 39 "), $flzhydqkfa = Number(" 25 "), $flxjnumurx = Number(" 30 "), $flkkjswqsg = Number(" 21 "), $flbwrjdmci = Number(" 11 "), $flkaiidxzu = Number(" 140 "), $flghbwhiij = Number(" 141 "), $flawuytxzy = Number(" 142 "), $flkuoykdct = Number(" 143 "), $flqjzijekx = Number(" 144 "), $fldbkumrch = Number(" 145 "), $flvmxyzxjh = Number(" 146 "), $flwwjkdacg = Number(" 4096 "), $flscevepor = Number(" 134 "), $flocqaiwzd = Number(" 147 ")
Global $flpuwwmbao = Number(" 26 "), $flouvibzyw = Number(" 126 "), $flmrudhnhp = Number(" 28 "), $flhhpbrjke = Number(" 34 "), $flrkparhzh = Number(" 26 "), $flnycpueln = Number(" 125 "), $flnegilmwq = Number(" 28 "), $flyqwvfhlw = Number(" 36 "), $flqjtxmafd = Number(" 128 "), $flzlvskjaw = Number(" 25 "), $flrxmffbjl = Number(" 26 "), $flvlzpmufo = Number(" 129 "), $fldcvsitmj = Number(" 39 "), $flktwrjohv = Number(" 130 "), $flkfrjyxwm = Number(" 300 "), $flpxfiylod = Number(" 131 "), $fldusywyur = Number(" 30 "), $flbahbntyi = Number(" 300 "), $flchkrzxfi = Number(" 132 "), $flpyqymbhq = Number(" 55 "), $flnpwtojrc = Number(" 300 "), $flctswluwo = Number(" 300 "), $fljrlgnyxn = Number(" 133 "), $flgoleifxh = Number(" 134 "), $flqpcttrlm = Number(" 13 ")
Global $fldcdylywl = Number(" 34 "), $fllvmmtgod = Number(" 26 "), $flhvcbzfrn = Number(" 37 "), $fltrngarjy = Number(" 28 "), $flkxleyzxr = Number(" 36 "), $flzufqksvp = Number(" 32771 "), $flbjfbsnip = Number(" 36 "), $flswnjceva = Number(" 36 "), $fljhoxspca = Number(" 28 "), $fldensetkm = Number(" 34 "), $flixvxwcri = Number(" 26 "), $flmjfdjlzq = Number(" 38 "), $flsmzhobco = Number(" 28 "), $flgckwhruk = Number(" 39 "), $flvqlgyufz = Number(" 36 "), $flshmkxxuh = Number(" 36 "), $flcuwkmzyt = Number(" 34 "), $flycibmgpd = Number(" 26 "), $flitcabdow = Number(" 40 "), $fliclftine = Number(" 28 "), $flinelzznd = Number(" 36 "), $fleqczuvlg = Number(" 28 "), $flokxreddk = Number(" 28 "), $flywdvownk = Number(" 36 "), $flyabzrrmv = Number(" 34 ")
Global $flhmejjpgg = Number(" 26 "), $flvtvyiyzu = Number(" 125 "), $flvvrrdevf = Number(" 28 "), $flsvnuqocx = Number(" 36 "), $flnpzlyjmk = Number(" 34 "), $flvcsigzxl = Number(" 26 "), $flpuowucoh = Number(" 126 "), $fliccbnvun = Number(" 28 "), $floaipmnkp = Number(" 34 "), $flmlupdwyw = Number(" 26 "), $flrynetwbg = Number(" 125 "), $flpytxgnae = Number(" 28 "), $flyxgoankm = Number(" 36 "), $flgiybxvqu = Number(" 127 "), $flriujdhwu = Number(" 16 "), $flidkfvoer = Number(" 34 "), $fljhxpdlgl = Number(" 26 "), $flfqexpzzc = Number(" 35 "), $flkfnstomi = Number(" 28 "), $flioplujrx = Number(" 28 "), $flqonphkjt = Number(" 28 "), $flwcdnzybe = Number(" 36 "), $flxowoscqi = Number(" 24 "), $flofosbflo = Number(" 36 "), $flkvwonhmy = Number(" 4026531840 ")
Global $flbkxrnxpv = Number(" 28 "), $flmgldspdj = Number(" 28 "), $fltgdgujkn = Number(" 36 "), $fltzqiggdk = Number(" 36 "), $flnyytfkei = Number(" 36 "), $flznxmaqlq = Number(" 28 "), $flrmmepznf = Number(" 34 "), $flkctwjxsv = Number(" 26 "), $flxznyhvmb = Number(" 121 "), $flzkhknuxv = Number(" 28 "), $flfhwpdvdv = Number(" 36 "), $flhaajvxmt = Number(" 36 "), $flhukovwky = Number(" 36 "), $flguylaqhb = Number(" 28 "), $fltzvugnmn = Number(" 28 "), $flfnyyixlr = Number(" 122 "), $flgsadhexo = Number(" 123 "), $flbqtuhkmy = Number(" 10 "), $flcvbsklvz = Number(" 14 "), $fljicudgov = Number(" 18 "), $fljmhypfzy = Number(" 34 "), $flcscartxg = Number(" 26 "), $flatlaxfun = Number(" 124 "), $flkyehpfcl = Number(" 28 "), $flsbvdgrpi = Number(" 34 ")
Global $flxzavwmtk = Number(" 108 "), $flmiginejb = Number(" 109 "), $fltcctsiso = Number(" 110 "), $flvolubnxk = Number(" 111 "), $flxvccpzhb = Number(" 112 "), $flbyzxyfqo = Number(" 113 "), $flophsmbek = Number(" 114 "), $fldpastqqh = Number(" 115 "), $flvmfptzcs = Number(" 116 "), $flxireqgpl = Number(" 117 "), $flhfdxuudy = Number(" 118 "), $flfmfyahhr = Number(" 119 "), $fllsbiddpb = Number(" 34 "), $fluopltsma = Number(" 26 "), $flbnlstaug = Number(" 35 "), $flywhxdmqv = Number(" 28 "), $flgfnzsvnj = Number(" 28 "), $flbucrjuwo = Number(" 28 "), $flyafxnzcb = Number(" 36 "), $fldjwjttjz = Number(" 24 "), $flxpzbcwes = Number(" 36 "), $flkjeqhlaq = Number(" 4026531840 "), $flveiodzpl = Number(" 34 "), $flroncrwtg = Number(" 26 "), $flmymaytor = Number(" 120 ")
Global $flwvicvsms = Number(" 83 "), $flcpbndhbq = Number(" 84 "), $fliecjfrpe = Number(" 85 "), $flghxsbhmp = Number(" 86 "), $floaidmlpx = Number(" 87 "), $fllvmncnny = Number(" 88 "), $flsfutymly = Number(" 89 "), $fluhbelzbi = Number(" 90 "), $flmnjwehod = Number(" 91 "), $flimuxorrr = Number(" 92 "), $flwlkknrpp = Number(" 93 "), $flhblipjbm = Number(" 94 "), $flubwwkeml = Number(" 95 "), $fljufrnthn = Number(" 96 "), $flktybyfdh = Number(" 97 "), $flcrizoigp = Number(" 98 "), $fldrutgtai = Number(" 99 "), $fljwnwaben = Number(" 100 "), $flxdasfsup = Number(" 101 "), $flvtsklnds = Number(" 102 "), $flgmzabuwz = Number(" 103 "), $flwrppuxsb = Number(" 104 "), $flmnmtpcbt = Number(" 105 "), $fltgxuvxht = Number(" 106 "), $fltkwhzfio = Number(" 107 ")
Global $flyatafxxs = Number(" 58 "), $flswkvicqg = Number(" 59 "), $flevoknzhs = Number(" 60 "), $flezsvlbbu = Number(" 61 "), $flvtqedrnc = Number(" 62 "), $flusnuqyrh = Number(" 63 "), $flryydwmeb = Number(" 64 "), $flpxkdtiub = Number(" 65 "), $flmfelfgbm = Number(" 66 "), $flaqvpxefd = Number(" 67 "), $flctnooltz = Number(" 68 "), $flgdvxhtzc = Number(" 69 "), $flwehnunfj = Number(" 70 "), $fllonnyibc = Number(" 71 "), $fllzjoogng = Number(" 72 "), $floduobscm = Number(" 73 "), $flgtvyiwta = Number(" 74 "), $flevlqhfzo = Number(" 75 "), $floodysbvz = Number(" 76 "), $flzluahbyv = Number(" 77 "), $flvnfpqxze = Number(" 78 "), $flaiqgjntx = Number(" 79 "), $flcwlffkhm = Number(" 80 "), $flqcqufhqv = Number(" 81 "), $flrbuzyvzf = Number(" 82 ")
Global $flhqanofav = Number(" 26 "), $flzjxicupp = Number(" 40 "), $flxdfspfko = Number(" 28 "), $flsermhiop = Number(" 36 "), $flcnxxwsyv = Number(" 28 "), $fldbgphumx = Number(" 28 "), $flxubnstgs = Number(" 36 "), $fletewazkh = Number(" 41 "), $flabbihpaw = Number(" 42 "), $flbymtwvbx = Number(" 43 "), $flgcijtdlm = Number(" 44 "), $fljjiooifn = Number(" 45 "), $flxfeftbwv = Number(" 46 "), $flticitoyz = Number(" 41 "), $flmstpwbrq = Number(" 47 "), $flecuynwdb = Number(" 48 "), $fljicvvbxq = Number(" 49 "), $fltonztzlf = Number(" 50 "), $flsbpkavsy = Number(" 51 "), $flxpwifgkd = Number(" 52 "), $flwxylvbjs = Number(" 53 "), $flgckmzayx = Number(" 54 "), $fltwuwurss = Number(" 55 "), $fljlijhegu = Number(" 56 "), $flwswtvquf = Number(" 57 ")
Global $flxquvzrly = Number(" 35 "), $flshmemjjj = Number(" 28 "), $flhqjglfws = Number(" 28 "), $flwvzhffsc = Number(" 28 "), $flfrtkctqe = Number(" 36 "), $flfaxzhhen = Number(" 24 "), $fljhsdaeav = Number(" 36 "), $flvwfavfwc = Number(" 4026531840 "), $flvoretncd = Number(" 34 "), $flyxdicudb = Number(" 26 "), $flcrgsivod = Number(" 37 "), $flanaocmrr = Number(" 28 "), $flvzomlpcy = Number(" 36 "), $fleqwgegsh = Number(" 32780 "), $flnponcvdb = Number(" 36 "), $flkgskcvuw = Number(" 36 "), $flfmpbdwej = Number(" 28 "), $flfwmyxvvj = Number(" 34 "), $fljcjbfhkv = Number(" 26 "), $flggfvewxl = Number(" 38 "), $flnxzdbehd = Number(" 28 "), $fluktgcieq = Number(" 39 "), $fllueubehx = Number(" 36 "), $fllrdexkdn = Number(" 36 "), $flgrkcxavd = Number(" 34 ")
Global $flhanaxdhn = Number(" 22 "), $flaexdqsrh = Number(" 24 "), $flgnduvhbh = Number(" 1024 "), $flsnpewutk = Number(" 25 "), $flamfdduxi = Number(" 26 "), $flcwfyxdtf = Number(" 27 "), $flafbzxahu = Number(" 28 "), $flskiskqti = Number(" 28 "), $flfbevuldl = Number(" 29 "), $flwnrvojhl = Number(" 300 "), $flllvvitvl = Number(" 375 "), $flmyerylny = Number(" 14 "), $flaevyfmea = Number(" 54 "), $floyeoxjvb = Number(" 30 "), $fluodjmwgw = Number(" 31 "), $fltibtjhtt = Number(" 32 "), $fljokrijny = Number(" 54 "), $fljevdjxae = Number(" 31 "), $flauqlvkxg = Number(" 20 "), $flxzrpavsw = Number(" 30 "), $flmdifziop = Number(" 31 "), $fldfpzzafd = Number(" 33 "), $flavwisyrl = Number(" 32 "), $fljdtvsdso = Number(" 34 "), $flexjevbco = Number(" 26 ")
Global $flwybtlyiv = Number(" 54 "), $flhmbuoowk = Number(" 40 "), $flfbipqyue = Number(" 24 "), $flsoprhueg = Number(" 10 "), $flbzbcwqxo = Number(" 11 "), $flmmexivfs = Number(" 12 "), $flzzzdhszn = Number(" 13 "), $flfsohvcfj = Number(" 14 "), $flfstfcrlf = Number(" 15 "), $flhxyjqrtq = Number(" 16 "), $fluyicwqbf = Number(" 17 "), $flhdlfyqrt = Number(" 18 "), $flbrxfhgjg = Number(" 19 "), $flxupdtbky = Number(" 20 "), $fltnemqxvo = Number(" 97 "), $flygcayiiq = Number(" 122 "), $flbrznfbke = Number(" 15 "), $flcgkrahml = Number(" 20 "), $flbmaiufhi = Number(" 10 "), $fltmgsdyfv = Number(" 15 "), $flramjdyfu = Number(" 21 "), $flukndiwex = Number(" 22 "), $flkpnpaftg = Number(" 25 "), $flxezgjwbw = Number(" 30 "), $flsgbzulnf = Number(" 23 ")
Func AREOXAOHPTA($flmojocqtz, $fljzkjrgzs, $flsgxlqjno)
    Local $flfzxxyxzg[$flmtlcylqk]
    $flfzxxyxzg[$flegviikkn] = DllStructCreate(AREHDIDXRGK($os[$flmhuqjxlm]))
    DllStructSetData($flfzxxyxzg[$flmssjmyyw], AREHDIDXRGK($os[$flxnxnkthd]), ($flhzxpihkn * $flmojocqtz + Mod($flmojocqtz, $flwioqnuav) * Abs($fljzkjrgzs)))
    DllStructSetData($flfzxxyxzg[$flmivdqgri], AREHDIDXRGK($os[$flldooqtbw]), $flehogcpwq)
    DllStructSetData($flfzxxyxzg[$flmbbmuicf], AREHDIDXRGK($os[$flsfwhkphp]), $flwybtlyiv)
    DllStructSetData($flfzxxyxzg[$flkkmdmfvj], AREHDIDXRGK($os[$flmvwpfapg]), $flhmbuoowk)
    DllStructSetData($flfzxxyxzg[$flfwgvtxrp], AREHDIDXRGK($os[$fliwyjfdak]), $flmojocqtz)
    DllStructSetData($flfzxxyxzg[$fltypfarsj], AREHDIDXRGK($os[$fltsjlagjo]), $fljzkjrgzs)
    DllStructSetData($flfzxxyxzg[$flwgmwwers], AREHDIDXRGK($os[$flvaxmaxna]), $flrjmgooql)
    DllStructSetData($flfzxxyxzg[$fluoqiynkc], AREHDIDXRGK($os[$flsfkralzh]), $flfbipqyue)
    DllStructSetData($flfzxxyxzg[$flgavmtume], AREHDIDXRGK($os[$flsoprhueg]), $flyaxyilnq)
    DllStructSetData($flfzxxyxzg[$flhrjrmiis], AREHDIDXRGK($os[$flbzbcwqxo]), $flzwriuqzw)
    DllStructSetData($flfzxxyxzg[$flvrhzzkvb], AREHDIDXRGK($os[$flmmexivfs]), $flydcwqgix)
    DllStructSetData($flfzxxyxzg[$flymqghasv], AREHDIDXRGK($os[$flzzzdhszn]), $flswvvhbrz)
    DllStructSetData($flfzxxyxzg[$flyrzxtsgb], AREHDIDXRGK($os[$flfsohvcfj]), $flafmmiiwn)
    DllStructSetData($flfzxxyxzg[$flnyfquhrm], AREHDIDXRGK($os[$flfstfcrlf]), $flhsoyzund)
    $flfzxxyxzg[$flcpgmnctu] = DllStructCreate(AREHDIDXRGK($os[$flhxyjqrtq]) & _StringRepeat(AREHDIDXRGK($os[$fluyicwqbf]) & DllStructGetData($flfzxxyxzg[$flpkesjrhx], AREHDIDXRGK($os[$flsxztehyj])) * $flnmnjaxtr & AREHDIDXRGK($os[$flhdlfyqrt]), DllStructGetData($flfzxxyxzg[$flgtnljovc], AREHDIDXRGK($os[$flqfroneda]))) & AREHDIDXRGK($os[$flbrxfhgjg]))
    Return $flfzxxyxzg
EndFunc   ;==>AREOXAOHPTA
Func AREWUOKNZVH($flyoojibbo, $fltyapmigo)
    Local $fldknagjpd = AREHDIDXRGK($os[$flxupdtbky])
    For $flezmzowno = $flqzeldyni To Random($flyoojibbo, $fltyapmigo, $flxzyfahhe)
        $fldknagjpd &= Chr(Random($fltnemqxvo, $flygcayiiq, $flrfdvckrf))
    Next
    Return $fldknagjpd
EndFunc   ;==>AREWUOKNZVH
Func AREGFMWBSQD($flslbknofv)
    Local $flxgrwiiel = AREWUOKNZVH($flbrznfbke, $flcgkrahml)
    Switch $flslbknofv
        Case $flbmaiufhi To $fltmgsdyfv
            $flxgrwiiel &= AREHDIDXRGK($os[$flramjdyfu])
            FileInstall(".\sprite.bmp", @ScriptDir & AREHDIDXRGK($os[$flukndiwex]) & $flxgrwiiel)
        Case $flkpnpaftg To $flxezgjwbw
            $flxgrwiiel &= AREHDIDXRGK($os[$flsgbzulnf])
            FileInstall(".\qr_encoder.dll", @ScriptDir & AREHDIDXRGK($os[$flhanaxdhn]) & $flxgrwiiel)
    EndSwitch
    Return $flxgrwiiel
EndFunc   ;==>AREGFMWBSQD
Func AREUZNAQFMN()
    Local $flfnvbvvfi = -$flrdwakhla
    Local $flfnvbvvfiraw = DllStructCreate(AREHDIDXRGK($os[$flaexdqsrh]))
    DllStructSetData($flfnvbvvfiraw, $fllazedtzj, $flgnduvhbh)
    Local $flmyeulrox = DllCall(AREHDIDXRGK($os[$flsnpewutk]), AREHDIDXRGK($os[$flamfdduxi]), AREHDIDXRGK($os[$flcwfyxdtf]), AREHDIDXRGK($os[$flafbzxahu]), DllStructGetPtr($flfnvbvvfiraw, $fldbjqqaiy), AREHDIDXRGK($os[$flskiskqti]), DllStructGetPtr($flfnvbvvfiraw, $flqhsoflsj))
    If $flmyeulrox[$flopdvhjle] <> $flpvxadmhh Then
        $flfnvbvvfi = BinaryMid(DllStructGetData($flfnvbvvfiraw, $fldcyeghlf), $flpxlalosg, DllStructGetData($flfnvbvvfiraw, $fldhthsnwj))
    EndIf
    Return $flfnvbvvfi
EndFunc   ;==>AREUZNAQFMN
GUICreate(AREHDIDXRGK($os[$flfbevuldl]), $flwnrvojhl, $flllvvitvl, -$flwtsvpqcx, -$flrrbxoggl)
Func AREGTFDCYNI(ByRef $flkqaovzec)
    Local $flqvizhezm = AREGFMWBSQD($flmyerylny)
    Local $flfwezdbyc = ARERUJPVSFP($flqvizhezm)
    If $flfwezdbyc <> -$fltgqykodm Then
        Local $flvburiuyd = ARENWRBSKLL($flfwezdbyc)
        If $flvburiuyd <> -$fltmxodmfl And DllStructGetSize($flkqaovzec) < $flvburiuyd - $flaevyfmea Then
            Local $flnfufvect = DllStructCreate(AREHDIDXRGK($os[$floyeoxjvb]) & $flvburiuyd & AREHDIDXRGK($os[$fluodjmwgw]))
            Local $flskuanqbg = AREMLFOZYNU($flfwezdbyc, $flnfufvect)
            If $flskuanqbg <> -$flvujariho Then
                Local $flxmdchrqd = DllStructCreate(AREHDIDXRGK($os[$fltibtjhtt]) & $flvburiuyd - $fljokrijny & AREHDIDXRGK($os[$fljevdjxae]), DllStructGetPtr($flnfufvect))
                Local $flqgwnzjzc = $flrujstiki
                Local $floctxpgqh = AREHDIDXRGK($os[$flauqlvkxg])
                For $fltergxskh = $flaefecieh To DllStructGetSize($flkqaovzec)
                    Local $flydtvgpnc = Number(DllStructGetData($flkqaovzec, $flaieigmma, $fltergxskh))
                    For $fltajbykxx = $flkvntcqfv To $flmkmllsnu Step -$flefscawij
                        $flydtvgpnc += BitShift(BitAND(Number(DllStructGetData($flxmdchrqd, $flxeqkukpp, $flqgwnzjzc)), $flsnjmvbtp), -$flfwydelan * $fltajbykxx)
                        $flqgwnzjzc += $flzoycekpn
                    Next
                    $floctxpgqh &= Chr(BitShift($flydtvgpnc, $flxxgkpivv) + BitShift(BitAND($flydtvgpnc, $fltzjpmvxn), -$flftjybgvr))
                Next
                DllStructSetData($flkqaovzec, $flztyfgltv, $floctxpgqh)
            EndIf
        EndIf
        AREVTGKXJHU($flfwezdbyc)
    EndIf
    AREBBYTWCOJ($flqvizhezm)
EndFunc   ;==>AREGTFDCYNI
Func AREYZOTAFNF(ByRef $flodiutpuy)
    Local $flisilayln = AREUZNAQFMN()
    If $flisilayln <> -$flflavkzaq Then
        $flisilayln = Binary(StringLower(BinaryToString($flisilayln)))
        Local $flisilaylnraw = DllStructCreate(AREHDIDXRGK($os[$flxzrpavsw]) & BinaryLen($flisilayln) & AREHDIDXRGK($os[$flmdifziop]))
        DllStructSetData($flisilaylnraw, $flmjfbnyec, $flisilayln)
        AREGTFDCYNI($flisilaylnraw)
        Local $flnttmjfea = DllStructCreate(AREHDIDXRGK($os[$fldfpzzafd]))
        DllStructSetData($flnttmjfea, $flbigthxyk, $flavwisyrl)
        Local $fluzytjacb = DllCall(AREHDIDXRGK($os[$fljdtvsdso]), AREHDIDXRGK($os[$flexjevbco]), AREHDIDXRGK($os[$flxquvzrly]), AREHDIDXRGK($os[$flshmemjjj]), DllStructGetPtr($flnttmjfea, $fljijxqyzy), AREHDIDXRGK($os[$flhqjglfws]), $flgdnnqsti, AREHDIDXRGK($os[$flwvzhffsc]), $flmbjrthgv, AREHDIDXRGK($os[$flfrtkctqe]), $flfaxzhhen, AREHDIDXRGK($os[$fljhsdaeav]), $flvwfavfwc)
        If $fluzytjacb[$flyrtvauea] <> $fldcgtnakv Then
            $fluzytjacb = DllCall(AREHDIDXRGK($os[$flvoretncd]), AREHDIDXRGK($os[$flyxdicudb]), AREHDIDXRGK($os[$flcrgsivod]), AREHDIDXRGK($os[$flanaocmrr]), DllStructGetData($flnttmjfea, $flpifpmbzi), AREHDIDXRGK($os[$flvzomlpcy]), $fleqwgegsh, AREHDIDXRGK($os[$flnponcvdb]), $flchqqrkle, AREHDIDXRGK($os[$flkgskcvuw]), $floezygqxe, AREHDIDXRGK($os[$flfmpbdwej]), DllStructGetPtr($flnttmjfea, $flmytlhxpo))
            If $fluzytjacb[$flpevdrdlo] <> $flptdindai Then
                $fluzytjacb = DllCall(AREHDIDXRGK($os[$flfwmyxvvj]), AREHDIDXRGK($os[$fljcjbfhkv]), AREHDIDXRGK($os[$flggfvewxl]), AREHDIDXRGK($os[$flnxzdbehd]), DllStructGetData($flnttmjfea, $flgujvukws), AREHDIDXRGK($os[$fluktgcieq]), $flisilaylnraw, AREHDIDXRGK($os[$fllueubehx]), DllStructGetSize($flisilaylnraw), AREHDIDXRGK($os[$fllrdexkdn]), $flkawuusha)
                If $fluzytjacb[$fljuolpkfq] <> $flcnpjsxcg Then
                    $fluzytjacb = DllCall(AREHDIDXRGK($os[$flgrkcxavd]), AREHDIDXRGK($os[$flhqanofav]), AREHDIDXRGK($os[$flzjxicupp]), AREHDIDXRGK($os[$flxdfspfko]), DllStructGetData($flnttmjfea, $flmhzummpo), AREHDIDXRGK($os[$flsermhiop]), $flhrjkqvru, AREHDIDXRGK($os[$flcnxxwsyv]), DllStructGetPtr($flnttmjfea, $flobwiuvkw), AREHDIDXRGK($os[$fldbgphumx]), DllStructGetPtr($flnttmjfea, $flmvbxjfah), AREHDIDXRGK($os[$flxubnstgs]), $flqocsrbgg)
                    If $fluzytjacb[$flpocagrli] <> $flwfneljwg Then
                        Local $flmtvyzrsy = Binary(AREHDIDXRGK($os[$fletewazkh]) & AREHDIDXRGK($os[$flabbihpaw]) & AREHDIDXRGK($os[$flbymtwvbx]) & AREHDIDXRGK($os[$flgcijtdlm]) & AREHDIDXRGK($os[$fljjiooifn]) & AREHDIDXRGK($os[$flxfeftbwv])) & DllStructGetData($flnttmjfea, $flevpvmavp)
                        Local $flkpzlqkch = Binary(AREHDIDXRGK($os[$flticitoyz]) & AREHDIDXRGK($os[$flmstpwbrq]) & AREHDIDXRGK($os[$flecuynwdb]) & AREHDIDXRGK($os[$fljicvvbxq]) & AREHDIDXRGK($os[$fltonztzlf]) & AREHDIDXRGK($os[$flsbpkavsy]) & AREHDIDXRGK($os[$flxpwifgkd]) & AREHDIDXRGK($os[$flwxylvbjs]) & AREHDIDXRGK($os[$flgckmzayx]) & AREHDIDXRGK($os[$fltwuwurss]) & AREHDIDXRGK($os[$fljlijhegu]) & AREHDIDXRGK($os[$flwswtvquf]) & AREHDIDXRGK($os[$flyatafxxs]) & AREHDIDXRGK($os[$flswkvicqg]) & AREHDIDXRGK($os[$flevoknzhs]) & AREHDIDXRGK($os[$flezsvlbbu]) & AREHDIDXRGK($os[$flvtqedrnc]) & AREHDIDXRGK($os[$flusnuqyrh]) & AREHDIDXRGK($os[$flryydwmeb]) & AREHDIDXRGK($os[$flpxkdtiub]) & AREHDIDXRGK($os[$flmfelfgbm]) & AREHDIDXRGK($os[$flaqvpxefd]) & AREHDIDXRGK($os[$flctnooltz]) & AREHDIDXRGK($os[$flgdvxhtzc]) & AREHDIDXRGK($os[$flwehnunfj]) & AREHDIDXRGK($os[$fllonnyibc]) & AREHDIDXRGK($os[$fllzjoogng]) & AREHDIDXRGK($os[$floduobscm]) & AREHDIDXRGK($os[$flgtvyiwta]) & AREHDIDXRGK($os[$flevlqhfzo]) & AREHDIDXRGK($os[$floodysbvz]) & AREHDIDXRGK($os[$flzluahbyv]) & AREHDIDXRGK($os[$flvnfpqxze]) & AREHDIDXRGK($os[$flaiqgjntx]) & AREHDIDXRGK($os[$flcwlffkhm]) & AREHDIDXRGK($os[$flqcqufhqv]) & AREHDIDXRGK($os[$flrbuzyvzf]) & AREHDIDXRGK($os[$flwvicvsms]) & AREHDIDXRGK($os[$flcpbndhbq]) & AREHDIDXRGK($os[$fliecjfrpe]) & AREHDIDXRGK($os[$flghxsbhmp]) & AREHDIDXRGK($os[$floaidmlpx]) & AREHDIDXRGK($os[$fllvmncnny]) & AREHDIDXRGK($os[$flsfutymly]) & AREHDIDXRGK($os[$fluhbelzbi]) & AREHDIDXRGK($os[$flmnjwehod]) & AREHDIDXRGK($os[$flimuxorrr]) & AREHDIDXRGK($os[$flwlkknrpp]) & AREHDIDXRGK($os[$flhblipjbm]) & AREHDIDXRGK($os[$flubwwkeml]) & AREHDIDXRGK($os[$fljufrnthn]) & AREHDIDXRGK($os[$flktybyfdh]) & AREHDIDXRGK($os[$flcrizoigp]) & AREHDIDXRGK($os[$fldrutgtai]) & AREHDIDXRGK($os[$fljwnwaben]) & AREHDIDXRGK($os[$flxdasfsup]) & AREHDIDXRGK($os[$flvtsklnds]) & AREHDIDXRGK($os[$flgmzabuwz]) & AREHDIDXRGK($os[$flwrppuxsb]) & AREHDIDXRGK($os[$flmnmtpcbt]) & AREHDIDXRGK($os[$fltgxuvxht]) & AREHDIDXRGK($os[$fltkwhzfio]) & AREHDIDXRGK($os[$flxzavwmtk]) & AREHDIDXRGK($os[$flmiginejb]) & AREHDIDXRGK($os[$fltcctsiso]) & AREHDIDXRGK($os[$flvolubnxk]) & AREHDIDXRGK($os[$flxvccpzhb]) & AREHDIDXRGK($os[$flbyzxyfqo]) & AREHDIDXRGK($os[$flophsmbek]) & AREHDIDXRGK($os[$fldpastqqh]) & AREHDIDXRGK($os[$flvmfptzcs]) & AREHDIDXRGK($os[$flxireqgpl]))
                        Local $fluelrpeax = DllStructCreate(AREHDIDXRGK($os[$flhfdxuudy]) & BinaryLen($flmtvyzrsy) & AREHDIDXRGK($os[$flfmfyahhr]))
                        DllStructSetData($fluelrpeax, $flfsjhegvq, BinaryLen($flkpzlqkch))
                        DllStructSetData($fluelrpeax, $flonfgetwp, $flkpzlqkch)
                        DllStructSetData($fluelrpeax, $flcxgmxxsz, $flmtvyzrsy)
                        DllStructSetData($fluelrpeax, $flicpdewwo, BinaryLen($flmtvyzrsy))
                        Local $fluzytjacb = DllCall(AREHDIDXRGK($os[$fllsbiddpb]), AREHDIDXRGK($os[$fluopltsma]), AREHDIDXRGK($os[$flbnlstaug]), AREHDIDXRGK($os[$flywhxdmqv]), DllStructGetPtr($fluelrpeax, $flfaijogtb), AREHDIDXRGK($os[$flgfnzsvnj]), $flfajfokzy, AREHDIDXRGK($os[$flbucrjuwo]), $flqykiuxho, AREHDIDXRGK($os[$flyafxnzcb]), $fldjwjttjz, AREHDIDXRGK($os[$flxpzbcwes]), $flkjeqhlaq)
                        If $fluzytjacb[$flpcrftwvr] <> $flvjdlwvhm Then
                            $fluzytjacb = DllCall(AREHDIDXRGK($os[$flveiodzpl]), AREHDIDXRGK($os[$flroncrwtg]), AREHDIDXRGK($os[$flmymaytor]), AREHDIDXRGK($os[$flbkxrnxpv]), DllStructGetData($fluelrpeax, $flqhepdeks), AREHDIDXRGK($os[$flmgldspdj]), DllStructGetPtr($fluelrpeax, $flffkmnrin), AREHDIDXRGK($os[$fltgdgujkn]), DllStructGetData($fluelrpeax, $flnxtetuvo), AREHDIDXRGK($os[$fltzqiggdk]), $flvuvsuzbc, AREHDIDXRGK($os[$flnyytfkei]), $flzpwbdcwm, AREHDIDXRGK($os[$flznxmaqlq]), DllStructGetPtr($fluelrpeax, $flfvgbqfsf))
                            If $fluzytjacb[$flqzhvgeiv] <> $flkbpmewrr Then
                                $fluzytjacb = DllCall(AREHDIDXRGK($os[$flrmmepznf]), AREHDIDXRGK($os[$flkctwjxsv]), AREHDIDXRGK($os[$flxznyhvmb]), AREHDIDXRGK($os[$flzkhknuxv]), DllStructGetData($fluelrpeax, $flwjugkiiw), AREHDIDXRGK($os[$flfhwpdvdv]), $floicbrqfw, AREHDIDXRGK($os[$flhaajvxmt]), $flcxrpcjhw, AREHDIDXRGK($os[$flhukovwky]), $flmayhqwzl, AREHDIDXRGK($os[$flguylaqhb]), DllStructGetPtr($fluelrpeax, $fljtcwuidx), AREHDIDXRGK($os[$fltzvugnmn]), DllStructGetPtr($fluelrpeax, $flgwubucwo))
                                If $fluzytjacb[$fllawknmko] <> $flhuzjztma Then
                                    Local $flsekbkmru = BinaryMid(DllStructGetData($fluelrpeax, $flmeobqopq), $fliycunpdr, DllStructGetData($fluelrpeax, $flveglzons))
                                    $flfzfsuaoz = Binary(AREHDIDXRGK($os[$flfnyyixlr]))
                                    $fltvwqdotg = Binary(AREHDIDXRGK($os[$flgsadhexo]))
                                    $flgggftges = BinaryMid($flsekbkmru, $flhsghsqkv, BinaryLen($flfzfsuaoz))
                                    $flnmiatrft = BinaryMid($flsekbkmru, BinaryLen($flsekbkmru) - BinaryLen($fltvwqdotg) + $fltpqpqkpf, BinaryLen($fltvwqdotg))
                                    If $flfzfsuaoz = $flgggftges And $fltvwqdotg = $flnmiatrft Then
                                        DllStructSetData($flodiutpuy, $flqajqcgnb, BinaryMid($flsekbkmru, $flanjwgybt, $fldzqrblug))
                                        DllStructSetData($flodiutpuy, $flhdphdqob, BinaryMid($flsekbkmru, $flbqtuhkmy, $flqopleteo))
                                        DllStructSetData($flodiutpuy, $flbguybfjg, BinaryMid($flsekbkmru, $flcvbsklvz, BinaryLen($flsekbkmru) - $fljicudgov))
                                    EndIf
                                EndIf
                                DllCall(AREHDIDXRGK($os[$fljmhypfzy]), AREHDIDXRGK($os[$flcscartxg]), AREHDIDXRGK($os[$flatlaxfun]), AREHDIDXRGK($os[$flkyehpfcl]), DllStructGetData($fluelrpeax, $flvkhmevkl))
                            EndIf
                            DllCall(AREHDIDXRGK($os[$flsbvdgrpi]), AREHDIDXRGK($os[$flhmejjpgg]), AREHDIDXRGK($os[$flvtvyiyzu]), AREHDIDXRGK($os[$flvvrrdevf]), DllStructGetData($fluelrpeax, $flskoeixpo), AREHDIDXRGK($os[$flsvnuqocx]), $fltygfaazw)
                        EndIf
                    EndIf
                EndIf
                DllCall(AREHDIDXRGK($os[$flnpzlyjmk]), AREHDIDXRGK($os[$flvcsigzxl]), AREHDIDXRGK($os[$flpuowucoh]), AREHDIDXRGK($os[$fliccbnvun]), DllStructGetData($flnttmjfea, $fljsmlmnmb))
            EndIf
            DllCall(AREHDIDXRGK($os[$floaipmnkp]), AREHDIDXRGK($os[$flmlupdwyw]), AREHDIDXRGK($os[$flrynetwbg]), AREHDIDXRGK($os[$flpytxgnae]), DllStructGetData($flnttmjfea, $flispmmify), AREHDIDXRGK($os[$flyxgoankm]), $fllcqiliyn)
        EndIf
    EndIf
EndFunc   ;==>AREYZOTAFNF
Func AREAQWBMTIZ(ByRef $flkhfbuyon)
    Local $fluupfrkdz = -$flckpfjmvi
    Local $flqbsfzezk = DllStructCreate(AREHDIDXRGK($os[$flgiybxvqu]))
    DllStructSetData($flqbsfzezk, $flrslvnjmf, $flriujdhwu)
    Local $fltrtsuryd = DllCall(AREHDIDXRGK($os[$flidkfvoer]), AREHDIDXRGK($os[$fljhxpdlgl]), AREHDIDXRGK($os[$flfqexpzzc]), AREHDIDXRGK($os[$flkfnstomi]), DllStructGetPtr($flqbsfzezk, $flnhhtfknm), AREHDIDXRGK($os[$flioplujrx]), $flayrxawki, AREHDIDXRGK($os[$flqonphkjt]), $fldqffsiwv, AREHDIDXRGK($os[$flwcdnzybe]), $flxowoscqi, AREHDIDXRGK($os[$flofosbflo]), $flkvwonhmy)
    If $fltrtsuryd[$flvfwrjmjd] <> $flcvmqvlnh Then
        $fltrtsuryd = DllCall(AREHDIDXRGK($os[$fldcdylywl]), AREHDIDXRGK($os[$fllvmmtgod]), AREHDIDXRGK($os[$flhvcbzfrn]), AREHDIDXRGK($os[$fltrngarjy]), DllStructGetData($flqbsfzezk, $flxxxstnev), AREHDIDXRGK($os[$flkxleyzxr]), $flzufqksvp, AREHDIDXRGK($os[$flbjfbsnip]), $flkhshkrug, AREHDIDXRGK($os[$flswnjceva]), $flpomtleuc, AREHDIDXRGK($os[$fljhoxspca]), DllStructGetPtr($flqbsfzezk, $flnzchdmsu))
        If $fltrtsuryd[$fljzhxwibz] <> $flluwmjhex Then
            $fltrtsuryd = DllCall(AREHDIDXRGK($os[$fldensetkm]), AREHDIDXRGK($os[$flixvxwcri]), AREHDIDXRGK($os[$flmjfdjlzq]), AREHDIDXRGK($os[$flsmzhobco]), DllStructGetData($flqbsfzezk, $flxifitlbz), AREHDIDXRGK($os[$flgckwhruk]), $flkhfbuyon, AREHDIDXRGK($os[$flvqlgyufz]), DllStructGetSize($flkhfbuyon), AREHDIDXRGK($os[$flshmkxxuh]), $flfxawzktb)
            If $fltrtsuryd[$flncksfusq] <> $flszxbcaxw Then
                $fltrtsuryd = DllCall(AREHDIDXRGK($os[$flcuwkmzyt]), AREHDIDXRGK($os[$flycibmgpd]), AREHDIDXRGK($os[$flitcabdow]), AREHDIDXRGK($os[$fliclftine]), DllStructGetData($flqbsfzezk, $flewlxbtze), AREHDIDXRGK($os[$flinelzznd]), $floqyccbvg, AREHDIDXRGK($os[$fleqczuvlg]), DllStructGetPtr($flqbsfzezk, $flxigqoizb), AREHDIDXRGK($os[$flokxreddk]), DllStructGetPtr($flqbsfzezk, $flzwiyyjrb), AREHDIDXRGK($os[$flywdvownk]), $flyxhsymcx)
                If $fltrtsuryd[$fltjkuqxwv] <> $flalocoqpw Then
                    $fluupfrkdz = DllStructGetData($flqbsfzezk, $flklivkouj)
                EndIf
            EndIf
            DllCall(AREHDIDXRGK($os[$flyabzrrmv]), AREHDIDXRGK($os[$flpuwwmbao]), AREHDIDXRGK($os[$flouvibzyw]), AREHDIDXRGK($os[$flmrudhnhp]), DllStructGetData($flqbsfzezk, $fladcakznh))
        EndIf
        DllCall(AREHDIDXRGK($os[$flhhpbrjke]), AREHDIDXRGK($os[$flrkparhzh]), AREHDIDXRGK($os[$flnycpueln]), AREHDIDXRGK($os[$flnegilmwq]), DllStructGetData($flqbsfzezk, $flbkjlbayh), AREHDIDXRGK($os[$flyqwvfhlw]), $flbxsazyed)
    EndIf
    Return $fluupfrkdz
EndFunc   ;==>AREAQWBMTIZ
Func AREPFNKWYPW()
    Local $flgqbtjbmi = -$flnbejxpiv
    Local $fltpvjccvq = DllStructCreate(AREHDIDXRGK($os[$flqjtxmafd]))
    DllStructSetData($fltpvjccvq, $flmdzxmojv, DllStructGetSize($fltpvjccvq))
    Local $flaghdvgyv = DllCall(AREHDIDXRGK($os[$flzlvskjaw]), AREHDIDXRGK($os[$flrxmffbjl]), AREHDIDXRGK($os[$flvlzpmufo]), AREHDIDXRGK($os[$fldcvsitmj]), $fltpvjccvq)
    If $flaghdvgyv[$flwdjhxtqt] <> $flrqjwnkkm Then
        If DllStructGetData($fltpvjccvq, $flodkkwfsg) = $fleblutcjv Then
            If DllStructGetData($fltpvjccvq, $flusbtjhcm) = $flwwnbwdib Then
                $flgqbtjbmi = $flhhamntzx
            EndIf
        EndIf
    EndIf
    Return $flgqbtjbmi
EndFunc   ;==>AREPFNKWYPW
Func AREIALBHUYT()
    Local $flokwzamxw = GUICtrlCreateInput(AREHDIDXRGK($os[$flktwrjohv]), -$flallgugxb, $flevbybfkl, $flkfrjyxwm)
    Local $flkhwwzgne = GUICtrlCreateButton(AREHDIDXRGK($os[$flpxfiylod]), -$flnmjxdkfm, $fldusywyur, $flbahbntyi)
    Local $fluhtsijxf = GUICtrlCreatePic(AREHDIDXRGK($os[$flchkrzxfi]), -$flfkewoyem, $flpyqymbhq, $flnpwtojrc, $flctswluwo)
    Local $flxeuaihlc = GUICtrlCreateMenu(AREHDIDXRGK($os[$fljrlgnyxn]))
    Local $flxeuaihlcitem = GUICtrlCreateMenuItem(AREHDIDXRGK($os[$flgoleifxh]), $flxeuaihlc)
    Local $flpnltlqhh = AREGFMWBSQD($flqpcttrlm)
    GUICtrlSetImage($fluhtsijxf, $flpnltlqhh)
    AREBBYTWCOJ($flpnltlqhh)
    GUISetState(@SW_SHOW)
    While $fljmvkkukj
        Switch GUIGetMsg()
            Case $flkhwwzgne
                Local $flnwbvjljj = GUICtrlRead($flokwzamxw)
                If $flnwbvjljj Then
                    Local $flwxdpsimz = AREGFMWBSQD($flnepnlrbe)
                    Local $flnpapeken = DllStructCreate(AREHDIDXRGK($os[$flewckibqf]))
                    Local $fljfojrihf = DllCall($flwxdpsimz, AREHDIDXRGK($os[$flfbhdcwrz]), AREHDIDXRGK($os[$flvjhzdfox]), AREHDIDXRGK($os[$flzaqhexft]), $flnpapeken, AREHDIDXRGK($os[$flcgkjfdha]), $flnwbvjljj)
                    If $fljfojrihf[$flulkqsfda] <> $flywpbzmry Then
                        AREYZOTAFNF($flnpapeken)
                        Local $flbvokdxkg = AREOXAOHPTA((DllStructGetData($flnpapeken, $flqgmnikmi) * DllStructGetData($flnpapeken, $flgmsyadmq)), (DllStructGetData($flnpapeken, $flocbwfdku) * DllStructGetData($flnpapeken, $flgxbowjra)), $flpzzbelga)
                        $fljfojrihf = DllCall($flwxdpsimz, AREHDIDXRGK($os[$flsvrwfrhg]), AREHDIDXRGK($os[$floehubdbq]), AREHDIDXRGK($os[$flqaltypjs]), $flnpapeken, AREHDIDXRGK($os[$flyxawteum]), $flbvokdxkg[$flmjqnaznu])
                        If $fljfojrihf[$flsgwhtzrv] <> $flfvhrtddd Then
                            $flpnltlqhh = AREWUOKNZVH($flzhydqkfa, $flxjnumurx) & AREHDIDXRGK($os[$flkkjswqsg])
                            ARELASSEHHA($flbvokdxkg, $flpnltlqhh)
                        EndIf
                    EndIf
                    AREBBYTWCOJ($flwxdpsimz)
                Else
                    $flpnltlqhh = AREGFMWBSQD($flbwrjdmci)
                EndIf
                GUICtrlSetImage($fluhtsijxf, $flpnltlqhh)
                AREBBYTWCOJ($flpnltlqhh)
            Case $flxeuaihlcitem
                Local $flomtrkawp = AREHDIDXRGK($os[$flkaiidxzu])
                $flomtrkawp &= AREHDIDXRGK($os[$flghbwhiij])
                $flomtrkawp &= @CRLF
                $flomtrkawp &= @CRLF
                $flomtrkawp &= AREHDIDXRGK($os[$flawuytxzy])
                $flomtrkawp &= @CRLF
                $flomtrkawp &= AREHDIDXRGK($os[$flkuoykdct])
                $flomtrkawp &= @CRLF
                $flomtrkawp &= @CRLF
                $flomtrkawp &= AREHDIDXRGK($os[$flqjzijekx])
                $flomtrkawp &= @CRLF
                $flomtrkawp &= @CRLF
                $flomtrkawp &= AREHDIDXRGK($os[$fldbkumrch])
                $flomtrkawp &= @CRLF
                $flomtrkawp &= AREHDIDXRGK($os[$flvmxyzxjh])
                MsgBox($flwwjkdacg, AREHDIDXRGK($os[$flscevepor]), $flomtrkawp)
            Case -$flrrpwpzrd
                ExitLoop
        EndSwitch
    WEnd
EndFunc   ;==>AREIALBHUYT
Func AREPQQKAETO($flmwacufre, $fljxaivjld)
    Local $fljiyeluhx = -$flrtxuubna
    Local $flmwacufreheadermagic = DllStructCreate(AREHDIDXRGK($os[$flocqaiwzd]))
    DllStructSetData($flmwacufreheadermagic, $fljgtgzrsy, $flyhhitbme)
    Local $flivpiogmf = AREMYFDTFQP($fljxaivjld, False)
    If $flivpiogmf <> -$flsgrrbigg Then
        Local $flchlkbend = AREMFKXLAYV($flivpiogmf, DllStructGetPtr($flmwacufreheadermagic), DllStructGetSize($flmwacufreheadermagic))
        If $flchlkbend <> -$fljkeopgvh Then
            $flchlkbend = AREMFKXLAYV($flivpiogmf, DllStructGetPtr($flmwacufre[$flsvfpdmay]), DllStructGetSize($flmwacufre[$flqwzpygde]))
            If $flchlkbend <> -$flvjqtfsiz Then
                $fljiyeluhx = $flypdtddxz
            EndIf
        EndIf
        AREVTGKXJHU($flivpiogmf)
    EndIf
    Return $fljiyeluhx
EndFunc   ;==>AREPQQKAETO
AREIALBHUYT()
Func ARELASSEHHA($flbaqvujsl, $flkelsuuiy)
    Local $flefoubdxt = -$flcxaaeniy
    Local $flamtlcncx = AREPQQKAETO($flbaqvujsl, $flkelsuuiy)
    If $flamtlcncx <> -$flxaushzso Then
        Local $flvikmhxwu = AREMYFDTFQP($flkelsuuiy, True)
        If $flvikmhxwu <> -$flxxqlgcjv Then
            Local $flwldjlwrq = Abs(DllStructGetData($flbaqvujsl[$flavacyqku], AREHDIDXRGK($os[$flviysztbd])))
            Local $flumnoetuu = DllStructGetData($flbaqvujsl[$flpdfbgohx], AREHDIDXRGK($os[$flfegerisy])) > $flilknhwyk ? $flwldjlwrq - $flwecmddtc : $flwjxfofkr
            Local $flqphcjgtp = DllStructCreate(AREHDIDXRGK($os[$flejpkmhdl]))
            For $fllrcvawmx = $flhaombual To $flwldjlwrq - $fldtvrladh
                $flamtlcncx = AREMFKXLAYV($flvikmhxwu, DllStructGetPtr($flbaqvujsl[$flpqigitfk], Abs($flumnoetuu - $fllrcvawmx) + $flbxttsong), DllStructGetData($flbaqvujsl[$fljlrqnhfc], AREHDIDXRGK($os[$flemdcrqdd])) * $flmmamrwab)
                If $flamtlcncx = -$fldwuczenf Then ExitLoop
                $flamtlcncx = AREMFKXLAYV($flvikmhxwu, DllStructGetPtr($flqphcjgtp), Mod(DllStructGetData($flbaqvujsl[$flrdaskyvd], AREHDIDXRGK($os[$flbafslfjs])), $flndzdxavp))
                If $flamtlcncx = -$flfgifsier Then ExitLoop
            Next
            If $flamtlcncx <> -$flfbqjbpgo Then
                $flefoubdxt = $flsgvsfczm
            EndIf
            AREVTGKXJHU($flvikmhxwu)
        EndIf
    EndIf
    Return $flefoubdxt
EndFunc   ;==>ARELASSEHHA
Func ARERUJPVSFP($flrriteuxd)
    Local $flrichemye = DllCall(AREHDIDXRGK($os[$flkhegsvel]), AREHDIDXRGK($os[$flxsdmvblr]), AREHDIDXRGK($os[$flikwkuqfw]), AREHDIDXRGK($os[$flhwrpeqlu]), @ScriptDir & AREHDIDXRGK($os[$flgeusyouv]) & $flrriteuxd, AREHDIDXRGK($os[$fluscndcwl]), $flozjuvcpw, AREHDIDXRGK($os[$flheifsdlr]), $flmzrdgblc, AREHDIDXRGK($os[$flmkwzhgsx]), $flcpxdpykx, AREHDIDXRGK($os[$flkvvasynk]), $flbddrzavr, AREHDIDXRGK($os[$fllnvdsuzt]), $flgzyedeli, AREHDIDXRGK($os[$flqplzawir]), $flkpxipgal)
    Return $flrichemye[$flsxhsgaxu]
EndFunc   ;==>ARERUJPVSFP
Func AREMYFDTFQP($flzxepiook, $flzcodzoep = True)
    Local $flogmfcakq = DllCall(AREHDIDXRGK($os[$flqwweubdm]), AREHDIDXRGK($os[$flfxfgyxls]), AREHDIDXRGK($os[$fltwctunjp]), AREHDIDXRGK($os[$flojqsrrsp]), @ScriptDir & AREHDIDXRGK($os[$fljfqernut]) & $flzxepiook, AREHDIDXRGK($os[$flnzfzydoi]), $fleiynadiw, AREHDIDXRGK($os[$flompxsyzt]), $flqfpqbvok, AREHDIDXRGK($os[$fleujcyfda]), $flrubfcaxm, AREHDIDXRGK($os[$flsunmubjt]), $flzcodzoep ? 0x3 : $flqcktzayy, AREHDIDXRGK($os[$flwfciovpd]), $flbrberyha, AREHDIDXRGK($os[$flqxfkfbod]), $fliwgresso)
    Return $flogmfcakq[$flavekolca]
EndFunc   ;==>AREMYFDTFQP
GUIDelete()
Func AREMFKXLAYV($fllsczdyhr, $flbfzgxbcy, $flutgabjfj)
    If $fllsczdyhr <> -$flerqqjbmh Then
        Local $flvfnkosuf = DllCall(AREHDIDXRGK($os[$fllkghuyoo]), AREHDIDXRGK($os[$flvoitvvcq]), AREHDIDXRGK($os[$fltwxzcojl]), AREHDIDXRGK($os[$flabfakvap]), $fllsczdyhr, AREHDIDXRGK($os[$fldwmpgtsj]), $flowfrckmw, AREHDIDXRGK($os[$flncsalwdm]), $flmxugfnde, AREHDIDXRGK($os[$flxjexjhwm]), $flvjxcqxyn)
        If $flvfnkosuf[$flddxnmrkh] <> -$flroseeflv Then
            Local $flwzfbbkto = DllStructCreate(AREHDIDXRGK($os[$flmmqocqpd]))
            $flvfnkosuf = DllCall(AREHDIDXRGK($os[$flcuyaggud]), AREHDIDXRGK($os[$flxkqpkzxq]), AREHDIDXRGK($os[$fllftzdhoa]), AREHDIDXRGK($os[$fliqyvcbyg]), $fllsczdyhr, AREHDIDXRGK($os[$fleuhchvkd]), $flbfzgxbcy, AREHDIDXRGK($os[$fleyxmofxu]), $flutgabjfj, AREHDIDXRGK($os[$florzkpciq]), DllStructGetPtr($flwzfbbkto), AREHDIDXRGK($os[$flhiqhcyio]), $flpgrglpzm)
            If $flvfnkosuf[$flvzrkqwyg] <> $flyvormnqr And DllStructGetData($flwzfbbkto, $flvthbrbxy) = $flutgabjfj Then
                Return $flxttxkikw
            EndIf
        EndIf
    EndIf
    Return -$flgjmycrvw
EndFunc   ;==>AREMFKXLAYV
Func AREMLFOZYNU($flfdnkxwze, ByRef $flgfdykdor)
    Local $flqcvtzthz = DllStructCreate(AREHDIDXRGK($os[$flmmqjhziv]))
    Local $flqnsbzfsf = DllCall(AREHDIDXRGK($os[$flpdpbbqig]), AREHDIDXRGK($os[$flyugczhjh]), AREHDIDXRGK($os[$fliiemmoao]), AREHDIDXRGK($os[$flqbxxvjkp]), $flfdnkxwze, AREHDIDXRGK($os[$fllcwtuuxw]), $flgfdykdor, AREHDIDXRGK($os[$flgcavcjkb]), DllStructGetSize($flgfdykdor), AREHDIDXRGK($os[$flizrncrjw]), $flqcvtzthz, AREHDIDXRGK($os[$flhbzvwdbm]), $flceujxgse)
    Return $flqnsbzfsf[$flhptoijin]
EndFunc   ;==>AREMLFOZYNU
Func AREVTGKXJHU($fldiapcptm)
    Local $flhvhgvtxm = DllCall(AREHDIDXRGK($os[$flbfviwghv]), AREHDIDXRGK($os[$flocbjosfl]), AREHDIDXRGK($os[$flijvrfukw]), AREHDIDXRGK($os[$floufwdich]), $fldiapcptm)
    Return $flhvhgvtxm[$flrzplgfoe]
EndFunc   ;==>AREVTGKXJHU
Func AREBBYTWCOJ($flxljyoycl)
    Local $flaubrmoip = DllCall(AREHDIDXRGK($os[$flfawmkpyi]), AREHDIDXRGK($os[$flxsckorht]), AREHDIDXRGK($os[$flvegsawer]), AREHDIDXRGK($os[$flsvrbynni]), $flxljyoycl)
    Return $flaubrmoip[$fliboupial]
EndFunc   ;==>AREBBYTWCOJ
Func ARENWRBSKLL($flpxhqhcav)
    Local $flzmcdhzwh = -$flidavtpzc
    Local $flztpegdeg = DllStructCreate(AREHDIDXRGK($os[$fltfnazynw]))
    Local $flekmcmpdl = DllCall(AREHDIDXRGK($os[$fltxcjfdtj]), AREHDIDXRGK($os[$flkgpmtrva]), AREHDIDXRGK($os[$flgdedqzlq]), AREHDIDXRGK($os[$flgsdeiksw]), $flpxhqhcav, AREHDIDXRGK($os[$flzgopkmys]), $flztpegdeg)
    If $flekmcmpdl <> -$floeysmnkq Then
        $flzmcdhzwh = $flekmcmpdl[$flaibuhicd] + Number(DllStructGetData($flztpegdeg, $flekmapulu))
    EndIf
    Return $flzmcdhzwh
EndFunc   ;==>ARENWRBSKLL
Func AREIHNVAPWN()
    Local $dlit = "7374727563743b75696e7420626653697a653b75696e7420626652657365727665643b75696e742062664f6666426974733b"
    $dlit &= "75696e7420626953697a653b696e7420626957696474683b696e742062694865696768743b7573686f7274206269506c616e"
    $dlit &= "65733b7573686f7274206269426974436f756e743b75696e74206269436f6d7072657373696f6e3b75696e7420626953697a"
    $dlit &= "65496d6167653b696e742062695850656c735065724d657465723b696e742062695950656c735065724d657465723b75696e"
    $dlit &= "74206269436c72557365643b75696e74206269436c72496d706f7274616e743b656e647374727563743b4FD5$626653697a6"
    $dlit &= "54FD5$626652657365727665644FD5$62664f6666426974734FD5$626953697a654FD5$626957696474684FD5$6269486569"
    $dlit &= "6768744FD5$6269506c616e65734FD5$6269426974436f756e744FD5$6269436f6d7072657373696f6e4FD5$626953697a65"
    $dlit &= "496d6167654FD5$62695850656c735065724d657465724FD5$62695950656c735065724d657465724FD5$6269436c7255736"
    $dlit &= "5644FD5$6269436c72496d706f7274616e744FD5$7374727563743b4FD5$627974655b4FD5$5d3b4FD5$656e647374727563"
    $dlit &= "744FD5$4FD5$2e626d704FD5$5c4FD5$2e646c6c4FD5$7374727563743b64776f72643b636861725b313032345d3b656e647"
    $dlit &= "374727563744FD5$6b65726e656c33322e646c6c4FD5$696e744FD5$476574436f6d70757465724e616d65414FD5$7074724"
    $dlit &= "FD5$436f6465497420506c7573214FD5$7374727563743b627974655b4FD5$5d3b656e647374727563744FD5$73747275637"
    $dlit &= "43b627974655b35345d3b627974655b4FD5$7374727563743b7074723b7074723b64776f72643b627974655b33325d3b656e"
    $dlit &= "647374727563744FD5$61647661706933322e646c6c4FD5$437279707441637175697265436f6e74657874414FD5$64776f7"
    $dlit &= "2644FD5$4372797074437265617465486173684FD5$437279707448617368446174614FD5$7374727563742a4FD5$4372797"
    $dlit &= "07447657448617368506172616d4FD5$30784FD5$30383032304FD5$30303031304FD5$36363030304FD5$30323030304FD5"
    $dlit &= "$303030304FD5$43443442334FD5$32433635304FD5$43463231424FD5$44413138344FD5$44383931334FD5$45364639324"
    $dlit &= "FD5$30413337414FD5$34463339364FD5$33373336434FD5$30343243344FD5$35394541304FD5$37423739454FD5$413434"
    $dlit &= "33464FD5$46443138394FD5$38424145344FD5$39423131354FD5$46364342314FD5$45324137434FD5$31414233434FD5$3"
    $dlit &= "4433235364FD5$31324135314FD5$39303335464FD5$31384642334FD5$42313735324FD5$38423341454FD5$43414633444"
    $dlit &= "FD5$34383045394FD5$38424638414FD5$36333544414FD5$46393734454FD5$30303133354FD5$33354432334FD5$314534"
    $dlit &= "42374FD5$35423243334FD5$38423830344FD5$43374145344FD5$44323636414FD5$33374233364FD5$46324335354FD5$3"
    $dlit &= "5424633414FD5$39454136414FD5$35384243384FD5$46393036434FD5$43363635454FD5$41453243454FD5$36304632434"
    $dlit &= "FD5$44453338464FD5$44333032364FD5$39434334434FD5$45354242304FD5$39303437324FD5$46463942444FD5$323646"
    $dlit &= "39314FD5$31394238434FD5$34383446454FD5$36394542394FD5$33344634334FD5$46454544454FD5$44434542414FD5$3"
    $dlit &= "7393134364FD5$30383139464FD5$42323146314FD5$30463833324FD5$42324135444FD5$34443737324FD5$44423132434"
    $dlit &= "FD5$33424544394FD5$34374636464FD5$37303641454FD5$34343131414FD5$35324FD5$7374727563743b7074723b70747"
    $dlit &= "23b64776f72643b627974655b383139325d3b627974655b4FD5$5d3b64776f72643b656e647374727563744FD5$437279707"
    $dlit &= "4496d706f72744b65794FD5$4372797074446563727970744FD5$464c4152454FD5$4552414c464FD5$43727970744465737"
    $dlit &= "4726f794b65794FD5$437279707452656c65617365436f6e746578744FD5$437279707444657374726f79486173684FD5$73"
    $dlit &= "74727563743b7074723b7074723b64776f72643b627974655b31365d3b656e647374727563744FD5$7374727563743b64776"
    $dlit &= "f72643b64776f72643b64776f72643b64776f72643b64776f72643b627974655b3132385d3b656e647374727563744FD5$47"
    $dlit &= "657456657273696f6e4578414FD5$456e746572207465787420746f20656e636f64654FD5$43616e2068617a20636f64653f"
    $dlit &= "4FD5$4FD5$48656c704FD5$41626f757420436f6465497420506c7573214FD5$7374727563743b64776f72643b64776f7264"
    $dlit &= "3b627974655b333931385d3b656e647374727563744FD5$696e743a636465636c4FD5$6a75737447656e6572617465515253"
    $dlit &= "796d626f6c4FD5$7374724FD5$6a757374436f6e76657274515253796d626f6c546f4269746d6170506978656c734FD5$546"
    $dlit &= "869732070726f6772616d2067656e65726174657320515220636f646573207573696e6720515220436f64652047656e65726"
    $dlit &= "1746f72202868747470733a2f2f7777772e6e6179756b692e696f2f706167652f71722d636f64652d67656e657261746f722"
    $dlit &= "d6c6962726172792920646576656c6f706564206279204e6179756b692e204FD5$515220436f64652047656e657261746f72"
    $dlit &= "20697320617661696c61626c65206f6e20476974487562202868747470733a2f2f6769746875622e636f6d2f6e6179756b69"
    $dlit &= "2f51522d436f64652d67656e657261746f722920616e64206f70656e2d736f757263656420756e6465722074686520666f6c"
    $dlit &= "6c6f77696e67207065726d697373697665204d4954204c6963656e7365202868747470733a2f2f6769746875622e636f6d2f"
    $dlit &= "6e6179756b692f51522d436f64652d67656e657261746f72236c6963656e7365293a4FD5$436f7079726967687420c2a9203"
    $dlit &= "23032302050726f6a656374204e6179756b692e20284d4954204c6963656e7365294FD5$68747470733a2f2f7777772e6e61"
    $dlit &= "79756b692e696f2f706167652f71722d636f64652d67656e657261746f722d6c6962726172794FD5$5065726d697373696f6"
    $dlit &= "e20697320686572656279206772616e7465642c2066726565206f66206368617267652c20746f20616e7920706572736f6e2"
    $dlit &= "06f627461696e696e67206120636f7079206f66207468697320736f66747761726520616e64206173736f636961746564206"
    $dlit &= "46f63756d656e746174696f6e2066696c6573202874686520536f667477617265292c20746f206465616c20696e207468652"
    $dlit &= "0536f66747761726520776974686f7574207265737472696374696f6e2c20696e636c7564696e6720776974686f7574206c6"
    $dlit &= "96d69746174696f6e207468652072696768747320746f207573652c20636f70792c206d6f646966792c206d657267652c207"
    $dlit &= "075626c6973682c20646973747269627574652c207375626c6963656e73652c20616e642f6f722073656c6c20636f7069657"
    $dlit &= "3206f662074686520536f6674776172652c20616e6420746f207065726d697420706572736f6e7320746f2077686f6d20746"
    $dlit &= "86520536f667477617265206973206675726e697368656420746f20646f20736f2c207375626a65637420746f20746865206"
    $dlit &= "66f6c6c6f77696e6720636f6e646974696f6e733a4FD5$312e205468652061626f766520636f70797269676874206e6f7469"
    $dlit &= "636520616e642074686973207065726d697373696f6e206e6f74696365207368616c6c20626520696e636c7564656420696e"
    $dlit &= "20616c6c20636f70696573206f72207375627374616e7469616c20706f7274696f6e73206f662074686520536f6674776172"
    $dlit &= "652e4FD5$322e2054686520536f6674776172652069732070726f76696465642061732069732c20776974686f75742077617"
    $dlit &= "272616e7479206f6620616e79206b696e642c2065787072657373206f7220696d706c6965642c20696e636c7564696e67206"
    $dlit &= "27574206e6f74206c696d6974656420746f207468652077617272616e74696573206f66206d65726368616e746162696c697"
    $dlit &= "4792c206669746e65737320666f72206120706172746963756c617220707572706f736520616e64206e6f6e696e6672696e6"
    $dlit &= "7656d656e742e20496e206e6f206576656e74207368616c6c2074686520617574686f7273206f7220636f707972696768742"
    $dlit &= "0686f6c64657273206265206c6961626c6520666f7220616e7920636c61696d2c2064616d61676573206f72206f746865722"
    $dlit &= "06c696162696c6974792c207768657468657220696e20616e20616374696f6e206f6620636f6e74726163742c20746f72742"
    $dlit &= "06f72206f74686572776973652c2061726973696e672066726f6d2c206f7574206f66206f7220696e20636f6e6e656374696"
    $dlit &= "f6e20776974682074686520536f667477617265206f722074686520757365206f72206f74686572206465616c696e6773206"
    $dlit &= "96e2074686520536f6674776172652e4FD5$7374727563743b7573686f72743b656e647374727563744FD5$7374727563743"
    $dlit &= "b627974653b627974653b627974653b656e647374727563744FD5$43726561746546696c654FD5$75696e744FD5$53657446"
    $dlit &= "696c65506f696e7465724FD5$6c6f6e674FD5$577269746546696c654FD5$7374727563743b64776f72643b656e647374727"
    $dlit &= "563744FD5$5265616446696c654FD5$436c6f736548616e646c654FD5$44656c65746546696c65414FD5$47657446696c655"
    $dlit &= "3697a65"
    Global $os = StringSplit($dlit, "4FD5$", 0x1)
EndFunc   ;==>AREIHNVAPWN
Func AREHDIDXRGK($flqlnxgxbp)
    Local $flqlnxgxbp_
    For $flrctqryub = 0x1 To StringLen($flqlnxgxbp) Step 0x2
        $flqlnxgxbp_ &= Chr(Dec(StringMid($flqlnxgxbp, $flrctqryub, 0x2)))
    Next
    Return $flqlnxgxbp_
EndFunc   ;==>AREHDIDXRGK