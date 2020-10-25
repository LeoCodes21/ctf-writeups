# Decode data from giant_hex_blob.txt with NO-ERALF key

from string_decipher import canoodle

# write flag PNG
with open('./giant_hex_blob.txt', 'r') as giant_hex_blob_file:
    giant_hex_blob = giant_hex_blob_file.read()
    key = 'FLARE-ON'
    reversed_key = list(map(ord, key[::-1]))
    giant_hex_blob_decoded = canoodle(giant_hex_blob, 2, 0x45C21, reversed_key)

    with open('v.png', 'wb') as file_out:
        file_out.write(giant_hex_blob_decoded)

# write MP3
with open('./giant_hex_blob.txt', 'r') as giant_hex_blob_file:
    giant_hex_blob = giant_hex_blob_file.read()
    giant_hex_blob_decoded = canoodle(giant_hex_blob, 0, 168667, [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE])

    with open('stomp.mp3', 'wb') as file_out:
        file_out.write(giant_hex_blob_decoded)