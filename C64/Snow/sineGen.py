import math

print("sine")

for i in range(256):
    value = int(8*8 - 8*8 * math.sin(i/255*(math.pi*2)))
    if i%8 == 0:
        print("\n\tdb\t",end='')

    out =  f'${value:02x}, '
    #{:x}.format(value)
    print(out,end='')

print()