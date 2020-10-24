# Decryptor for challenge #2 embedded data

import struct

# Convert array of integers to array of bytes
def ints2bytes(int_array):
    result = bytearray(len(int_array) * 4)
    for i in range(len(int_array)):
        struct.pack_into('<I', result, i*4, int_array[i])
    return result

# Decrypt ciphertext with key
def decrypt_data(ciphertext, key):
    ciphertext_len = len(ciphertext)
    key_len = len(key)
    output = [0 for i in range(ciphertext_len)]

    for i in range(ciphertext_len):
        output[i] = ciphertext[i] ^ key[i % key_len]
    return ''.join(map(chr, output)).rstrip('\x00')

filename_key = b'KglPFOsQDxBPXmclOpmsdLDEPMRWbMDzwhDGOyqAkVMRvnBeIkpZIhFznwVylfjrkqprBPAdPuaiVoVugQAlyOQQtxBNsTdPZgDH \x00'
filename_encrypted = ints2bytes([
    0x3B020E38, 0x341B3B19, 0x3E230C1B, 0x42110833,
    0x731E1239
])

filedata_key = b'nPTnaGLkIqdcQwvieFQKGcTGOTbfMjDNmvibfBDdFBhoPaBbtfQuuGWYomtqTFqvBSKdUMmciqKSGZaosWCSoZlcIlyQpOwkcAgw \x00'
filedata_encrypted = ints2bytes([
    0x2C332323, 0x49643F0E, 0x40A1E0A, 0x1A021623, 
    0x24086644, 0x2C741132, 0xF422D2A, 0xD64503E,
    0x171B045D, 0x5033616, 0x8092034, 0xE242163,
    0x58341415, 0x3A79291A, 0x58560000
])

print("Filename: %s" % decrypt_data(filename_encrypted, filename_key))
print("File contents: %s" % decrypt_data(filedata_encrypted, filedata_key))