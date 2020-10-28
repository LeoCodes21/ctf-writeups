# Retrieve encoded string from sprite.bmp
# See repository LICENSE

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