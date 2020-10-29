# Decrypt the stolen file packet
# See repository LICENSE

from Crypto.Cipher import ARC4

with open('stolen_file_packet.bin', 'rb') as stolen_file_packet:
    stolen_file_encrypted = stolen_file_packet.read()
    cipher = ARC4.new(b"intrepidmango")
    print(cipher.decrypt(stolen_file_encrypted).decode('ascii'))