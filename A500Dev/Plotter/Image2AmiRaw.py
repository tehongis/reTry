import pygame
import random
import time
import math

SC_SIZE=(320,256)

pygame.init()
screen=pygame.display.set_mode(SC_SIZE)
DIV1=22
DIV2=32
DIV3=34
DIV4=42
DIV5=18
DIV6=24

for y in range(-128,128):
    for x in range(-160,160):
        r = 128+64*(math.sin(x/DIV1)+math.cos(y/DIV4))
        b = 128+64*(math.sin(x/DIV2)+math.cos(y/DIV5))
        g = 128+64*(math.sin(x/DIV3)+math.cos(y/DIV6))
        rgb = [r,g,b]
        loc = ((320/2) + x, (256/2) + y)
        pygame.draw.line( screen, rgb, loc,loc )
    pygame.display.update()

time.sleep(60)
pygame.quit()
