# #6 - CodeIt by Mike Hunhoff (@mehunhoff)

## Introduction

In this challenge, we're presented with a `codeit.exe` file along with the following message:

> Reverse engineer this little compiled script to figure out what you need to do to make it give you the flag (as a QR code).

If we launch the app, we are presented with a simple GUI that allows us to enter text to get a QR code.

![CodeIt](https://s.heyitsleo.io/ShareX/2020/10/codeit_ofu9GI8yrR.png)

The message says this program is a "compiled script." Our first order of business is to figure out what type of script it is.

## Part 1 - Recon

If we attempt to load the application into IDA, we receive a disturbing message:

![Imports error](https://s.heyitsleo.io/ShareX/2020/10/ida_VdQ6AvtEkh.png)

If we open the binary in a hex editor, it doesn't take long to spot the `UPX0` marker. This indicates the app was packed with UPX, just like [challenge #2](https://github.com/LeoCodes21/ctf-writeups/tree/main/Flare-On%202020/02-garbage).

![UPX0 in binary](https://s.heyitsleo.io/ShareX/2020/10/HxD_hHNGCy7Esn.png)

Unlike the binary in challenge #2, this one can be unpacked without any extra work.

```
$ upx -d codeit.exe
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2013
UPX 3.91w       Markus Oberhumer, Laszlo Molnar & John Reiser   Sep 30th 2013

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
    963584 <-    481280   49.95%    win32/pe     codeit.exe

Unpacked 1 file.
```

IDA can now load the binary without any issues, allowing us to continue our exploration.

![IDA loaded it](https://s.heyitsleo.io/ShareX/2020/10/ida_j3IAVtPQHt.png)

If we open the strings view (`SHIFT+F12`) we immediately see an "AutoIt" marker:
![AutoIt string](https://s.heyitsleo.io/ShareX/2020/10/ida_r8V52FIUgv.png)

This confirms what we were told: the binary is a compiled AutoIt3 script. Where could the script be, though? We can close IDA and start looking.

## Part 2 - Script hunting

The first place to search for the script is in the EXE's resource directory. After all, where else could it be?

Let's boot up [CFF Explorer](https://www.ntcore.com/?page_id=388) and load the EXE. Notice the presence of the **Resource Editor** - this allows us to view all of the embedded resources.

![Resource editor](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_GIqnSRtJdo.png)

In the resource editor, we can see several categories of resources - `Icons`, `Menus`, `Version Info`, and so on. The only one we care about is **`RCData`**. According to the [Win32 documentation](https://docs.microsoft.com/en-us/windows/win32/menurc/rcdata-resource),
> [RCData] resources permit the inclusion of binary data directly in the executable file.

If we expand the RCData category, there's a resource named `SCRIPT`! It can't be more obvious.

![SCRIPT resource](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_zQXNcWeSCh.png)

If we click on the `SCRIPT` resource, CFF Explorer will show a hex/plaintext view. It doesn't seem like we're looking at readable source code.

![SCRIPT data](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_GChR85QSt1.png)

We _can_ see an `AU3` (AutoIt3) marker, though - we're on the right track. Let's save the raw resource data and do some research.

![Save the data](https://s.heyitsleo.io/ShareX/2020/10/64SdcZlSQL.png)

The saved file should be 96 KB.

![SCRIPT resource](https://s.heyitsleo.io/ShareX/2020/10/explorer_0wO8NkSv8h.png)

## Part 3 - I can has source code?

We need to find an AutoIt3 decompiler that can handle this file. After doing some research, I found one that worked properly: [autoit-extractor by x0r19x91](https://gitlab.com/x0r19x91/autoit-extractor/-/blob/master/net40/AutoIt%20Extractor/bin/x86/Release/AutoIt%20Extractor.exe). It's worth noting that this tool works on _EXE files_, not the raw script resource. 

![autoit-extractor GUI](https://s.heyitsleo.io/ShareX/2020/10/AutoIt_Extractor_kbsOLQJJ4B.png)

We can now save the decompiled script to a file and start analyzing it.

![The decompiled script on disk](https://s.heyitsleo.io/ShareX/2020/10/explorer_0P50pJEUYP.png)

After scrolling past some AutoIt library functions, we see code that is obviously obfuscated.

```autoit
#OnAutoItStartRegister "AREIHNVAPWN"
Global $os
Global $flavekolca = Number(" 0 "), $flerqqjbmh = Number(" 1 "), $flowfrckmw = Number(" 0 "), $flmxugfnde = Number(" 0 "), $flvjxcqxyn = Number(" 2 "), $flddxnmrkh = Number(" 0 "), $flroseeflv = Number(" 1 "), $flpgrglpzm = Number(" 0 "), $flvzrkqwyg = Number(" 0 "), $flyvormnqr = Number(" 0 "), $flvthbrbxy = Number(" 1 "), $flxttxkikw = Number(" 0 "), $flgjmycrvw = Number(" 1 "), $flceujxgse = Number(" 0 "), $flhptoijin = Number(" 0 "), $flrzplgfoe = Number(" 0 "), $fliboupial = Number(" 0 "), $flidavtpzc = Number(" 1 "), $floeysmnkq = Number(" 1 "), $flaibuhicd = Number(" 0 "), $flekmapulu = Number(" 1 ")
...

Func AREOXAOHPTA($flmojocqtz, $fljzkjrgzs, $flsgxlqjno)
    Local $flfzxxyxzg[$flmtlcylqk]
    $flfzxxyxzg[$flegviikkn] = DllStructCreate(AREHDIDXRGK($os[$flmhuqjxlm]))
    DllStructSetData($flfzxxyxzg[$flmssjmyyw], AREHDIDXRGK($os[$flxnxnkthd]), ($flhzxpihkn * $flmojocqtz + Mod($flmojocqtz, $flwioqnuav) * Abs($fljzkjrgzs)))
    ...
```

We'll need to create some sort of tool to clean up this script - otherwise, it'll be impossible to analyze efficiently. The obfuscated version of this script can be found in [script_ORIGINAL.au3](./script_ORIGINAL.au3).

(I tested the decompiled script, and it ran properly. When I was working on this the first time, I initially used a different decompiler. It gave me a script that didn't work correctly.)

## Part 4 - Deobfuscation

There are a few steps we need to take to clean up this script:
1. **Constant deduplication**: We need to eliminate all the duplicated global variables for constants.
    
    e.g. `If $fluzytjacb[$flpevdrdlo] <> $flptdindai Then`
    to
    `If $fluzytjacb[$flpevdrdlo] <> $flpevdrdlo Then`

    ($flpevdrdlo and $flptdindai have the same value.)
2. **Constant inlining**: After eliminating the _duplicate_ variables for constants, we need to replace usages of the remaining ones with the appropriate constants.
    
    e.g. `If $fluzytjacb[$flpevdrdlo] <> $flpevdrdlo Then`
    to
    `If $fluzytjacb[0] <> 0 Then`
3. **String deobfuscation and inlining**: We need to get readable strings in this script. All strings are accessed by calling a decoder function on values in an array. We should automate the decoding process and put the strings inline, just like we want to do for the other constants.

I chose to call my tool the Janitor - the source can be found in [janitor.py](./janitor.py), and you can read more about how it works in [JANITOR.md](./JANITOR.md).

We can run the Janitor and get a fully functional script. The script can be executed from the AutoIt editor, and we can modify it as we wish.

\* Since we're running the script outside of the original EXE, two additional files are necessary: `qr_encoder.dll` and `sprite.bmp`. They can be extracted by the AutoIt decompiler.

![LeoCodes21-it](https://s.heyitsleo.io/ShareX/2020/10/AutoIt3_enl2zKnLUw.png)

## Part 5 - Actual reversing

Recall the challenge message:
> Reverse engineer this little compiled script to figure out what you need to do to make it give you the flag (**as a QR code**).

From now on, we'll be analyzing the [deobfuscated script](./script_deobfuscated.au3). Let's look into the QR code generator.

### Locating the target

The QR code generation begins in the `GUIFunc` function, which continuously receives (or "pumps") Windows GUI messages.

```autoit
        Switch GUIGetMsg()
            Case $code_gen_button
                Local $input_text = GUICtrlRead($input_text_box)
                If $input_text Then
                    Local $qr_encoder_path = drop_file_to_disk(26)
                    Local $qr_symbol_data = DllStructCreate("struct;dword;dword;byte[3918];endstruct")
                    Local $qr_encoder_result = DllCall($qr_encoder_path, "int:cdecl", "justGenerateQRSymbol", "struct*", $qr_symbol_data, "str", $input_text)
                    If $qr_encoder_result[0] <> 0 Then
                        attempt_flag_decrypt($qr_symbol_data)
                        Local $qr_bmp_structs = gen_bmp_structs((DllStructGetData($qr_symbol_data, 1) * DllStructGetData($qr_symbol_data, 2)), (DllStructGetData($qr_symbol_data, 1) * DllStructGetData($qr_symbol_data, 2)), 1024)
                        $qr_encoder_result = DllCall($qr_encoder_path, "int:cdecl", "justConvertQRSymbolToBitmapPixels", "struct*", $qr_symbol_data, "struct*", $qr_bmp_structs[1])
                        If $qr_encoder_result[0] <> 0 Then
                            $code_image_path = gen_random_string(25, 30) & ".bmp"
                            write_bmp($qr_bmp_structs, $code_image_path)
                        EndIf
                    EndIf
                    delete_file($qr_encoder_path)
                Else
                    $code_image_path = drop_file_to_disk(11)
                EndIf
                GUICtrlSetImage($code_image, $code_image_path)
                delete_file($code_image_path)
```

This bit of code is responsible for making the API calls to generate a QR code from the user's input. If you read it carefully, you'll notice this:

`attempt_flag_decrypt($qr_symbol_data)`

This `attempt_flag_decrypt` function, which can be found in the [deobfuscated script](./script_deobfuscated.au3), uses the computer's [NetBIOS name](https://en.wikipedia.org/wiki/NetBIOS#NetBIOS_name) to generate a decryption key.

```autoit
Func attempt_flag_decrypt(ByRef $qr_encoder_struct)
    Local $computer_name = get_computer_name()
    If $computer_name <> -1 Then
        $computer_name = Binary(StringLower(BinaryToString($computer_name)))
        Local $computer_name_struct = DllStructCreate("struct;byte[" & BinaryLen($computer_name) & "];endstruct")
        DllStructSetData($computer_name_struct, 1, $computer_name)
        generate_key_from_computername($computer_name_struct)
```

The modified computer name is then hashed with the SHA-256 algorithm.

```autoit
; 32780 = 0x800C = CALG_SHA_256
; https://docs.microsoft.com/en-us/windows/win32/seccrypto/alg-id
$crypto_api_result = DllCall("advapi32.dll", "int", "CryptCreateHash", "ptr", DllStructGetData($crypto_ctx_struct, 1), "dword", 32780, "dword", 0, "dword", 0, "ptr", DllStructGetPtr($crypto_ctx_struct, 2))
If $crypto_api_result[0] <> 0 Then
    $crypto_api_result = DllCall("advapi32.dll", "int", "CryptHashData", "ptr", DllStructGetData($crypto_ctx_struct, 2), "struct*", $computer_name_struct, "dword", DllStructGetSize($computer_name_struct), "dword", 0)
    If $crypto_api_result[0] <> 0 Then
        $crypto_api_result = DllCall("advapi32.dll", "int", "CryptGetHashParam", "ptr", DllStructGetData($hash_ctx_struct, 2), "dword", 2, "ptr", DllStructGetPtr($hash_ctx_struct, 4), "ptr", DllStructGetPtr($hash_ctx_struct, 3), "dword", 0)
```

The hash is used as the key to decrypt a blob of data that is embedded in the script. The data is encrypted with AES256.

```autoit
; Build crypto key structure
; BLOBHEADER:
;   bType = 08 = PLAINTEXTKEYBLOB 
;   bVersion = 02 
;   reserved = 0000
;   aiKeyAlg = 10660000 = 0x6610 = CALG_AES_256 
; keySize = 20000000 = 0x20
; DATA:
;  [32-byte SHA256 hash of modified computer name]
Local $crypto_key = Binary("0x080200001066000020000000") & DllStructGetData($hash_ctx_struct, 4)
Local $crypted_blob = Binary("0xCD4B32C650CF21BDA184D8913E6F920A37A4F3963736C042C459EA07B79EA443FFD1898BAE49B115F6CB1E2A7C1AB3C4C25612A519035F18FB3B17528B3AECAF3D480E98BF8A635DAF974E0013535D231E4B75B2C38B804C7AE4D266A37B36F2C555BF3A9EA6A58BC8F906CC665EAE2CE60F2CDE38FD30269CC4CE5BB090472FF9BD26F9119B8C484FE69EB934F43FEEDEDCEBA791460819FB21F10F832B2A5D4D772DB12C3BED947F6F706AE4411A52")
Local $crypto_ctx_struct = DllStructCreate("struct;ptr;ptr;dword;byte[8192];byte[" & BinaryLen($crypto_key) & "];dword;endstruct")
DllStructSetData($crypto_ctx_struct, 3, BinaryLen($crypted_blob))
DllStructSetData($crypto_ctx_struct, 4, $crypted_blob)
DllStructSetData($crypto_ctx_struct, 5, $crypto_key)
DllStructSetData($crypto_ctx_struct, 6, BinaryLen($crypto_key))

; Set up crypto context
; 24 = PROV_RSA_AES
; 4026531840 = 0xF0000000 = CRYPT_VERIFYCONTEXT
Local $crypto_api_result = DllCall("advapi32.dll", "int", "CryptAcquireContextA", "ptr", DllStructGetPtr($crypto_ctx_struct, 1), "ptr", 0, "ptr", 0, "dword", 24, "dword", 4026531840)
If $crypto_api_result[0] <> 0 Then
    $crypto_api_result = DllCall("advapi32.dll", "int", "CryptImportKey", "ptr", DllStructGetData($crypto_ctx_struct, 1), "ptr", DllStructGetPtr($crypto_ctx_struct, 5), "dword", DllStructGetData($crypto_ctx_struct, 6), "dword", 0, "dword", 0, "ptr", DllStructGetPtr($crypto_ctx_struct, 2))
    If $crypto_api_result[0] <> 0 Then
        ; BOOL CryptDecrypt(HCRYPTKEY hKey, HCRYPTHASH hHash, BOOL Final, DWORD dwFlags, BYTE *pbData, DWORD *pdwDataLen);
        $crypto_api_result = DllCall("advapi32.dll", "int", "CryptDecrypt", "ptr", DllStructGetData($crypto_ctx_struct, 2), "dword", 0, "dword", 1, "dword", 0, "ptr", DllStructGetPtr($crypto_ctx_struct, 4), "ptr", DllStructGetPtr($crypto_ctx_struct, 3))
```

### Finding the key

The `generate_key_from_computername` function is defined below:
```autoit
Func generate_key_from_computername(ByRef $computer_name)
    Local $bmp_file_path = drop_file_to_disk(14)
    Local $bmp_file_handle = open_file_for_read($bmp_file_path)
    If $bmp_file_handle <> -1 Then
        Local $bmp_data_len = get_file_size($bmp_file_handle)
        If $bmp_data_len <> -1 And DllStructGetSize($computer_name) < $bmp_data_len - 54 Then
            Local $bmp_data_full = DllStructCreate("struct;byte[" & $bmp_data_len & "];endstruct")
            Local $read_file_result = read_file($bmp_file_handle, $bmp_data_full)
            If $read_file_result <> -1 Then
                Local $bmp_struct = DllStructCreate("struct;byte[54];byte[" & $bmp_data_len - 54 & "];endstruct", DllStructGetPtr($bmp_data_full))
                Local $bmp_byte_index = 1
                Local $generated_key = ""
                For $computer_name_byte_idx = 1 To DllStructGetSize($computer_name)
                    Local $generated_key_byte = Number(DllStructGetData($computer_name, 1, $computer_name_byte_idx))
                    For $computer_name_bit_idx = 6 To 0 Step -1
                        $generated_key_byte += BitShift(BitAND(Number(DllStructGetData($bmp_struct, 2, $bmp_byte_index)), 1), -1 * $computer_name_bit_idx)
                        $bmp_byte_index += 1
                    Next
                    $generated_key &= Chr(BitShift($generated_key_byte, 1) + BitShift(BitAND($generated_key_byte, 1), -7))
                Next
                DllStructSetData($computer_name, 1, $generated_key)
            EndIf
        EndIf
        close_handle($bmp_file_handle)
    EndIf
    delete_file($bmp_file_path)
EndFunc
```

The part we care about, though, is this:
```autoit
Local $bmp_byte_index = 1
Local $generated_key = ""
For $computer_name_byte_idx = 1 To DllStructGetSize($computer_name)
    Local $generated_key_byte = Number(DllStructGetData($computer_name, 1, $computer_name_byte_idx))
    For $computer_name_bit_idx = 6 To 0 Step -1
        $generated_key_byte += BitShift(BitAND(Number(DllStructGetData($bmp_struct, 2, $bmp_byte_index)), 1), -1 * $computer_name_bit_idx)
        $bmp_byte_index += 1
    Next
    $generated_key &= Chr(BitShift($generated_key_byte, 1) + BitShift(BitAND($generated_key_byte, 1), -7))
Next
```

`$bmp_struct` is generated by reading the contents of the `sprite.bmp` file. It contains two sub-structures: the 54-byte BMP header, and the image bitmap data. `DllStructGetData($bmp_struct, 2, $bmp_byte_index)` retrieves a byte from the bitmap data.

According to the [AutoIt documentation](https://www.autoitscript.com/autoit3/docs/functions/BitShift.htm), passing a negative value for the second argument to `BitShift` results in a left-shift. We can create a simplified mental model of the shifting code:

```autoit
for $bit_idx = 6 to 0 step -1
    $computer_name_byte += ($bitmap_data[$bmp_byte_index] & 1) << $bit_idx
    $bmp_byte_index += 1
next

; append byte to key after manipulating it a little
$generated_key &= Chr(($computer_name_byte >> 1) | (($computer_name_byte & 1) << 7))
```

We can extract a chunk of `bitmap_data` by opening `sprite.bmp` in a hex editor, going to offset `0x36`, and copying **a multiple of 7 bytes**. Let's copy 28 (`0x1C`) bytes:
`FF FF FE FE FE FE FF FF FF FF FE FF FE FF FF FF FF FE FF FE FE FE FF FF FE FE FE FE`

The code is clearly interpreting each byte of the bitmap as a binary digit, and manipulating `$computer_name_byte` accordingly. An `FF` byte will be interpreted as a 1 (since the low bit is set), while an `FE` byte will be interpreted as a 0. Let's assume `$computer_name_byte` starts out as 0.

```
Block 1: FF FF FE FE FE FE FF = [0]1100001
Block 2: FF FF FF FE FF FE FF = [0]1110101
Block 3: FF FF FF FE FF FE FE = [0]1110100
Block 4: FE FF FF FE FE FE FE = [0]0110000
```

Since each block represents 7 bits, we might be looking at ASCII characters. Let's look at an [ASCII table](https://www.ascii-code.com/) and see what these binary values correspond to.

```
[0]1100001 = a
[0]1110101 = u
[0]1110100 = t
[0]0110000 = 0
```

You can probably see where this is going. This can be automated with yet another Python script ([bmp_stego_decoder.py](./bmp_stego_decoder.py))

```py
# Retrieve encoded string from sprite.bmp

f = open('sprite.bmp', 'rb')
f.seek(54)
sprite_data = f.read()
f.close()

block_str = ''

for i in range(13):
    block_bytes = sprite_data[i*7:i*7+7]
    block_bits = list(map(lambda x: x & 1, block_bytes))
    block_chr = chr(sum([bit << (6 - j) for (j, bit) in enumerate(block_bits)]))
    block_str += block_chr
print(block_str)
```

If we run the script, `aut01tfan1999` is printed. **This is the correct NetBIOS name.** There's no need to actually change anything on our computer - we can just modify the AutoIt script.

```autoit
Func get_computer_name()
    Return "aut01tfan1999"
EndFunc
```

If we apply this patch and run the script, we can enter any input we want in order to get the flag (as a QR code.)

![Flag QR](https://s.heyitsleo.io/ShareX/2020/10/AutoIt3_i4CulCoofo.png)

![Flag Decoded](https://s.heyitsleo.io/ShareX/2020/10/chrome_TsISduMrv9.png)

The flag is **`L00ks_L1k3_Y0u_D1dnt_Run_Aut0_Tim3_0n_Th1s_0ne!@flare-on.com`**.

## Conclusion

This was a thrilling challenge, albeit an extremely frustrating one. It took me _way too long_ to realize what was being done with the bitmap data. I wasn't expecting there to be steganography in a reversing challenge, but this one surprised me.