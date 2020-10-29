# Decrypt the second stage data
# See repository LICENSE

import struct
from Crypto.Cipher import ARC4

with open('second_stage_packet.bin', 'rb') as second_stage_packet_file:
    second_stage_encrypted = second_stage_packet_file.read()
    code_len = struct.unpack('<L', second_stage_encrypted[:4])[0] ^ 0x524F584B

    if code_len != len(second_stage_encrypted) - 4:
        raise RuntimeError("bad data")
    
    encrypted_code = second_stage_encrypted[4:]
    cipher = ARC4.new(b'killervulture123')
    decrypted_code = cipher.decrypt(encrypted_code)
    
    with open('second_stage_code.bin', 'wb') as second_stage_code_file:
        second_stage_code_file.write(decrypted_code)