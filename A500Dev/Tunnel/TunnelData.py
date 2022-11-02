#!/usr/bin/python3

# The tunnel effect is accomplished by using 3 arrays, each the size of the screen.
# The first array contains the distance from that pixel to the center of the screen, scaled and modulated by the height of the texture.
# The second array contains the angle from that pixel to the center of the screen. 
# The third array contains a clamped distance from the center of the screen.
# These arrays are calculated only once. 
# Then they are used to calculate the coordinates of the texture. 
# The first array determines the x coordinate of the texture. The second array determines the y coordinate. 
# The third array determines how to darken the texture so that the center of the tunnel is blackened.
#
# Finally, to pan the center of the tunnel around, we actually make the arrays twice the screen size and simply pan around the arrays.
# 

"""
class Tunnel implements Effect {
  private width: number;
  private height: number;
  private src: ImageData;
  private distances: number[] = [];
  private angles: number[] = [];
  private shades: number[] = [];

  public async init(width: number, height: number): Promise<void> {
    this.width = width;
    this.height = height;
    this.src = await demoFX.loadImage("space.jpg");

    for (let y: number = 0; y < this.height * 2; y++) {
      const sqy: number = (y - this.height) * (y - this.height);
      for (let x: number = 0; x < this.width * 2; x++) {
        const sqx: number = (x - this.width) * (x - this.width);
        this.distances.push(Math.floor(32 * this.src.height /
                                       Math.sqrt(sqx + sqy)) % this.src.height);
        this.angles.push(Math.round(this.src.width *
                                    Math.atan2(y - this.height,
                                               x - this.width) / Math.PI));
        this.shades.push(Math.min(Math.sqrt(sqx + sqy), 255));
      }
    }
  }

  public render(ctx: CanvasRenderingContext2D, t: number): void {
    const dest: ImageData = ctx.getImageData(0, 0, this.width, this.height);
    const time: number = t / 1000;
    const shiftx: number = Math.floor(this.src.width * time);
    const shifty: number = Math.floor(this.src.height * 0.25 * time);
    const centerx: number = this.width / 2 + Math.floor(this.width / 4 *
                                                        Math.sin(time / 4));
    const centery: number = this.height / 2 + Math.floor(this.height / 4 *
                                                         Math.sin(time / 2));
    const stride: number = this.width * 2;
    let destOfs: number = 0;
    for (let y: number = 0; y < this.height; y++) {
      let srcOfs: number = y * stride + centerx + centery * stride;
      for (let x: number = 0; x < this.width; x++) {
        const u: number = (this.distances[srcOfs] + shiftx) & 0xff;
        let v: number = (this.angles[srcOfs] + shifty) % this.src.height;
        while (v < 0) {
          v += this.src.height;
        }
        const shade: number = this.shades[srcOfs] / 255;
        srcOfs++;
        let pixOfs: number = (u + (v << 8)) << 2;
        dest.data[destOfs++] = this.src.data[pixOfs++] * shade;  // r
        dest.data[destOfs++] = this.src.data[pixOfs++] * shade;  // g
        dest.data[destOfs++] = this.src.data[pixOfs++] * shade;  // b
        dest.data[destOfs++] = this.src.data[pixOfs++];  // a
      }
    }
    ctx.putImageData(dest, 0, 0);
  }
}
"""

import pygame
from pygame.locals import *
import numpy

SC_SIZE=(800,600)
try:
    pygame.init()
    screen=pygame.display.set_mode(SC_SIZE)
    texture = pygame.image.load("DALL·E 2022-10-27 13.25.43 - cloudy space  texture repeating.png")
    size = (size_x,size_y) = texture.get_size()
    #area = texture.get_bounding_rect()

    # The first array contains the distance from that pixel to the center of the screen, scaled and modulated by the height of the texture.
    array_x = numpy.zeros(size)
    # The second array contains the angle from that pixel to the center of the screen. 
    array_y = numpy.zeros(size)
    # The third array contains a clamped distance from the center of the screen.
    array_z = numpy.zeros(size)

    RUNNING=True
    while(RUNNING):
        for event in pygame.event.get():
            if event.type==pygame.QUIT:
                RUNNING=False        
    
        keys=pygame.key.get_pressed()
        if keys[pygame.K_ESCAPE]:
            print("ESC pressed.")
            RUNNING=False
        location = (0,0)
        area = (0,0,size_x,size_y)
        screen.blit(texture,location,area)
        pygame.display.update()

finally:
    pygame.quit()



