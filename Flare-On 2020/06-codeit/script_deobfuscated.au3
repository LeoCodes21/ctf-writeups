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
EndFunc
#OnAutoItStartRegister "AREIHNVAPWN"
Global $os
Func gen_bmp_structs($width, $height, $_unused)
    Local $bmp_structs[2]
    $bmp_structs[0] = DllStructCreate("struct;uint bfSize;uint bfReserved;uint bfOffBits;uint biSize;int biWidth;int biHeight;ushort biPlanes;ushort biBitCount;uint biCompression;uint biSizeImage;int biXPelsPerMeter;int biYPelsPerMeter;uint biClrUsed;uint biClrImportant;endstruct;")
    DllStructSetData($bmp_structs[0], "bfSize", (3 * $width + Mod($width, 4) * Abs($height)))
    DllStructSetData($bmp_structs[0], "bfReserved", 0)
    DllStructSetData($bmp_structs[0], "bfOffBits", 54)
    DllStructSetData($bmp_structs[0], "biSize", 40)
    DllStructSetData($bmp_structs[0], "biWidth", $width)
    DllStructSetData($bmp_structs[0], "biHeight", $height)
    DllStructSetData($bmp_structs[0], "biPlanes", 1)
    DllStructSetData($bmp_structs[0], "biBitCount", 24)
    DllStructSetData($bmp_structs[0], "biCompression", 0)
    DllStructSetData($bmp_structs[0], "biSizeImage", 0)
    DllStructSetData($bmp_structs[0], "biXPelsPerMeter", 0)
    DllStructSetData($bmp_structs[0], "biYPelsPerMeter", 0)
    DllStructSetData($bmp_structs[0], "biClrUsed", 0)
    DllStructSetData($bmp_structs[0], "biClrImportant", 0)
    $bmp_structs[1] = DllStructCreate("struct;" & _StringRepeat("byte[" & DllStructGetData($bmp_structs[0], "biWidth") * 3 & "];", DllStructGetData($bmp_structs[0], "biHeight")) & "endstruct")
    Return $bmp_structs
EndFunc   
Func gen_random_string($min_length, $max_length)
    Local $random_string = ""
    For $i = 0 To Random($min_length, $max_length, 1)
        $random_string &= Chr(Random(97, 122, 1))
    Next
    Return $random_string
EndFunc   
Func drop_file_to_disk($file_type)
    Local $file_out_path = gen_random_string(15, 20)
    Switch $file_type
        Case 10 To 15
            $file_out_path &= ".bmp"
            FileInstall(".\sprite.bmp", @ScriptDir & "\" & $file_out_path)
        Case 25 To 30
            $file_out_path &= ".dll"
            FileInstall(".\qr_encoder.dll", @ScriptDir & "\" & $file_out_path)
    EndSwitch
    Return $file_out_path
EndFunc   
Func get_computer_name()
    Return "aut01tfan1999"
EndFunc   
GUICreate("CodeIt Plus!", 300, 375, -1, -1)
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
Func attempt_flag_decrypt(ByRef $qr_encoder_struct)
    Local $computer_name = get_computer_name()
    If $computer_name <> -1 Then
        $computer_name = Binary(StringLower(BinaryToString($computer_name)))
        Local $computer_name_struct = DllStructCreate("struct;byte[" & BinaryLen($computer_name) & "];endstruct")
        DllStructSetData($computer_name_struct, 1, $computer_name)
        generate_key_from_computername($computer_name_struct)
        Local $hash_ctx_struct = DllStructCreate("struct;ptr;ptr;dword;byte[32];endstruct")
        DllStructSetData($hash_ctx_struct, 3, 32)
        Local $crypto_api_result = DllCall("advapi32.dll", "int", "CryptAcquireContextA", "ptr", DllStructGetPtr($hash_ctx_struct, 1), "ptr", 0, "ptr", 0, "dword", 24, "dword", 4026531840)
        If $crypto_api_result[0] <> 0 Then
            $crypto_api_result = DllCall("advapi32.dll", "int", "CryptCreateHash", "ptr", DllStructGetData($hash_ctx_struct, 1), "dword", 32780, "dword", 0, "dword", 0, "ptr", DllStructGetPtr($hash_ctx_struct, 2))
            If $crypto_api_result[0] <> 0 Then
                $crypto_api_result = DllCall("advapi32.dll", "int", "CryptHashData", "ptr", DllStructGetData($hash_ctx_struct, 2), "struct*", $computer_name_struct, "dword", DllStructGetSize($computer_name_struct), "dword", 0)
                If $crypto_api_result[0] <> 0 Then
                    $crypto_api_result = DllCall("advapi32.dll", "int", "CryptGetHashParam", "ptr", DllStructGetData($hash_ctx_struct, 2), "dword", 2, "ptr", DllStructGetPtr($hash_ctx_struct, 4), "ptr", DllStructGetPtr($hash_ctx_struct, 3), "dword", 0)
                    If $crypto_api_result[0] <> 0 Then
                        Local $crypto_key = Binary("0x" & "08020" & "00010" & "66000" & "02000" & "0000") & DllStructGetData($hash_ctx_struct, 4)
                        Local $crypted_blob = Binary("0x" & "CD4B3" & "2C650" & "CF21B" & "DA184" & "D8913" & "E6F92" & "0A37A" & "4F396" & "3736C" & "042C4" & "59EA0" & "7B79E" & "A443F" & "FD189" & "8BAE4" & "9B115" & "F6CB1" & "E2A7C" & "1AB3C" & "4C256" & "12A51" & "9035F" & "18FB3" & "B1752" & "8B3AE" & "CAF3D" & "480E9" & "8BF8A" & "635DA" & "F974E" & "00135" & "35D23" & "1E4B7" & "5B2C3" & "8B804" & "C7AE4" & "D266A" & "37B36" & "F2C55" & "5BF3A" & "9EA6A" & "58BC8" & "F906C" & "C665E" & "AE2CE" & "60F2C" & "DE38F" & "D3026" & "9CC4C" & "E5BB0" & "90472" & "FF9BD" & "26F91" & "19B8C" & "484FE" & "69EB9" & "34F43" & "FEEDE" & "DCEBA" & "79146" & "0819F" & "B21F1" & "0F832" & "B2A5D" & "4D772" & "DB12C" & "3BED9" & "47F6F" & "706AE" & "4411A" & "52")
                        Local $crypto_ctx_struct = DllStructCreate("struct;ptr;ptr;dword;byte[8192];byte[" & BinaryLen($crypto_key) & "];dword;endstruct")
                        DllStructSetData($crypto_ctx_struct, 3, BinaryLen($crypted_blob))
                        DllStructSetData($crypto_ctx_struct, 4, $crypted_blob)
                        DllStructSetData($crypto_ctx_struct, 5, $crypto_key)
                        DllStructSetData($crypto_ctx_struct, 6, BinaryLen($crypto_key))
                        Local $crypto_api_result = DllCall("advapi32.dll", "int", "CryptAcquireContextA", "ptr", DllStructGetPtr($crypto_ctx_struct, 1), "ptr", 0, "ptr", 0, "dword", 24, "dword", 4026531840)
                        If $crypto_api_result[0] <> 0 Then
                            $crypto_api_result = DllCall("advapi32.dll", "int", "CryptImportKey", "ptr", DllStructGetData($crypto_ctx_struct, 1), "ptr", DllStructGetPtr($crypto_ctx_struct, 5), "dword", DllStructGetData($crypto_ctx_struct, 6), "dword", 0, "dword", 0, "ptr", DllStructGetPtr($crypto_ctx_struct, 2))
                            If $crypto_api_result[0] <> 0 Then
                                $crypto_api_result = DllCall("advapi32.dll", "int", "CryptDecrypt", "ptr", DllStructGetData($crypto_ctx_struct, 2), "dword", 0, "dword", 1, "dword", 0, "ptr", DllStructGetPtr($crypto_ctx_struct, 4), "ptr", DllStructGetPtr($crypto_ctx_struct, 3))
                                If $crypto_api_result[0] <> 0 Then
                                    Local $decrypted_data = BinaryMid(DllStructGetData($crypto_ctx_struct, 4), 1, DllStructGetData($crypto_ctx_struct, 3))
                                    $validation_marker_1 = Binary("FLARE")
                                    $validation_marker_2 = Binary("ERALF")
                                    $decrypted_marker_1 = BinaryMid($decrypted_data, 1, BinaryLen($validation_marker_1))
                                    $decrypted_marker_2 = BinaryMid($decrypted_data, BinaryLen($decrypted_data) - BinaryLen($validation_marker_2) + 1, BinaryLen($validation_marker_2))
                                    If $validation_marker_1 = $decrypted_marker_1 And $validation_marker_2 = $decrypted_marker_2 Then
                                        DllStructSetData($qr_encoder_struct, 1, BinaryMid($decrypted_data, 6, 4))
                                        DllStructSetData($qr_encoder_struct, 2, BinaryMid($decrypted_data, 10, 4))
                                        DllStructSetData($qr_encoder_struct, 3, BinaryMid($decrypted_data, 14, BinaryLen($decrypted_data) - 18))
                                    EndIf
                                EndIf
                                DllCall("advapi32.dll", "int", "CryptDestroyKey", "ptr", DllStructGetData($crypto_ctx_struct, 2))
                            EndIf
                            DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", DllStructGetData($crypto_ctx_struct, 1), "dword", 0)
                        EndIf
                    EndIf
                EndIf
                DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", DllStructGetData($hash_ctx_struct, 2))
            EndIf
            DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", DllStructGetData($hash_ctx_struct, 1), "dword", 0)
        EndIf
    EndIf
EndFunc   
Func GUIFunc()
    Local $input_text_box = GUICtrlCreateInput("Enter text to encode", -1, 5, 300)
    Local $code_gen_button = GUICtrlCreateButton("Can haz code?", -1, 30, 300)
    Local $code_image = GUICtrlCreatePic("", -1, 55, 300, 300)
    Local $help_menu = GUICtrlCreateMenu("Help")
    Local $about_menu_item = GUICtrlCreateMenuItem("About CodeIt Plus!", $help_menu)
    Local $code_image_path = drop_file_to_disk(13)
    GUICtrlSetImage($code_image, $code_image_path)
    delete_file($code_image_path)
    GUISetState(@SW_SHOW)
    While 1
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
            Case $about_menu_item
                Local $copyright_message = "This program generates QR codes using QR Code Generator (https://www.nayuki.io/page/qr-code-generator-library) developed by Nayuki. "
                $copyright_message &= "QR Code Generator is available on GitHub (https://github.com/nayuki/QR-Code-generator) and open-sourced under the following permissive MIT License (https://github.com/nayuki/QR-Code-generator#license):"
                $copyright_message &= @CRLF
                $copyright_message &= @CRLF
                $copyright_message &= "Copyright © 2020 Project Nayuki. (MIT License)"
                $copyright_message &= @CRLF
                $copyright_message &= "https://www.nayuki.io/page/qr-code-generator-library"
                $copyright_message &= @CRLF
                $copyright_message &= @CRLF
                $copyright_message &= "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"
                $copyright_message &= @CRLF
                $copyright_message &= @CRLF
                $copyright_message &= "1. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
                $copyright_message &= @CRLF
                $copyright_message &= "2. The Software is provided as is, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the Software or the use or other dealings in the Software."
                MsgBox(4096, "About CodeIt Plus!", $copyright_message)
            Case -3
                ExitLoop
        EndSwitch
    WEnd
EndFunc   
Func write_bmp_header($bmp_header, $bmp_path)
    Local $result = -1
    Local $bmp_header_magic = DllStructCreate("struct;ushort;endstruct")
    DllStructSetData($bmp_header_magic, 1, 19778)
    Local $bmp_file_handle = open_file_for_write($bmp_path, False)
    If $bmp_file_handle <> -1 Then
        Local $write_file_result = write_file($bmp_file_handle, DllStructGetPtr($bmp_header_magic), DllStructGetSize($bmp_header_magic))
        If $write_file_result <> -1 Then
            $write_file_result = write_file($bmp_file_handle, DllStructGetPtr($bmp_header[0]), DllStructGetSize($bmp_header[0]))
            If $write_file_result <> -1 Then
                $result = 0
            EndIf
        EndIf
        close_handle($bmp_file_handle)
    EndIf
    Return $result
EndFunc   
GUIFunc()
Func write_bmp($bmp_header, $bmp_path)
    Local $result = -1
    Local $write_bmp_header_result = write_bmp_header($bmp_header, $bmp_path)
    If $write_bmp_header_result <> -1 Then
        Local $bmp_file_handle = open_file_for_write($bmp_path, True)
        If $bmp_file_handle <> -1 Then
            Local $bmp_height = Abs(DllStructGetData($bmp_header[0], "biHeight"))
            Local $max_row = DllStructGetData($bmp_header[0], "biHeight") > 0 ? $bmp_height - 1 : 0
            Local $pixel = DllStructCreate("struct;byte;byte;byte;endstruct")
            For $row = 0 To $bmp_height - 1
                $write_bmp_header_result = write_file($bmp_file_handle, DllStructGetPtr($bmp_header[1], Abs($max_row - $row) + 1), DllStructGetData($bmp_header[0], "biWidth") * 3)
                If $write_bmp_header_result = -1 Then ExitLoop
                $write_bmp_header_result = write_file($bmp_file_handle, DllStructGetPtr($pixel), Mod(DllStructGetData($bmp_header[0], "biWidth"), 4))
                If $write_bmp_header_result = -1 Then ExitLoop
            Next
            If $write_bmp_header_result <> -1 Then
                $result = 0
            EndIf
            close_handle($bmp_file_handle)
        EndIf
    EndIf
    Return $result
EndFunc   
Func open_file_for_read($path)
    Local $create_file_result = DllCall("kernel32.dll", "ptr", "CreateFile", "str", @ScriptDir & "\" & $path, "uint", 2147483648, "uint", 0, "ptr", 0, "uint", 3, "uint", 128, "ptr", 0)
    Return $create_file_result[0]
EndFunc   
Func open_file_for_write($path, $open_existing = True)
    Local $create_file_result = DllCall("kernel32.dll", "ptr", "CreateFile", "str", @ScriptDir & "\" & $path, "uint", 1073741824, "uint", 0, "ptr", 0, "uint", $open_existing ? 0x3 : 2, "uint", 128, "ptr", 0)
    Return $create_file_result[0]
EndFunc   
GUIDelete()
Func write_file($file_handle, $data, $data_len)
    If $file_handle <> -1 Then
        Local $write_file_result = DllCall("kernel32.dll", "uint", "SetFilePointer", "ptr", $file_handle, "long", 0, "ptr", 0, "uint", 2)
        If $write_file_result[0] <> -1 Then
            Local $bytes_written = DllStructCreate("uint")
            $write_file_result = DllCall("kernel32.dll", "ptr", "WriteFile", "ptr", $file_handle, "ptr", $data, "uint", $data_len, "ptr", DllStructGetPtr($bytes_written), "ptr", 0)
            If $write_file_result[0] <> 0 And DllStructGetData($bytes_written, 1) = $data_len Then
                Return 0
            EndIf
        EndIf
    EndIf
    Return -1
EndFunc   
Func read_file($file_handle, ByRef $data)
    Local $out_len_struct = DllStructCreate("struct;dword;endstruct")
    Local $read_file_result = DllCall("kernel32.dll", "int", "ReadFile", "ptr", $file_handle, "struct*", $data, "dword", DllStructGetSize($data), "struct*", $out_len_struct, "ptr", 0)
    Return $read_file_result[0]
EndFunc   
Func close_handle($handle)
    Local $close_handle_result = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $handle)
    Return $close_handle_result[0]
EndFunc   
Func delete_file($file_path)
    Local $delete_file_result = DllCall("kernel32.dll", "int", "DeleteFileA", "str", $file_path)
    Return $delete_file_result[0]
EndFunc   
Func get_file_size($file_handle)
    Local $file_size_final = -1
    Local $file_size_high = DllStructCreate("struct;dword;endstruct")
    Local $file_size_low = DllCall("kernel32.dll", "dword", "GetFileSize", "ptr", $file_handle, "struct*", $file_size_high)
    If $file_size_low <> -1 Then
        $file_size_final = $file_size_low[0] + Number(DllStructGetData($file_size_high, 1))
    EndIf
    Return $file_size_final
EndFunc