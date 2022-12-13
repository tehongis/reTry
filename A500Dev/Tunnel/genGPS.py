#!/usr/bin/python3
# -*- coding: utf-8 -*-

import random
import sys
import math
from pprint import pprint

def decdeg2dms(dd_lat,dd_lon):

    is_positive = dd_lat >= 0
    dd_lat = abs(dd_lat)
    minutes,seconds = divmod(dd_lat*3600,60)
    degrees,minutes = divmod(minutes,60)
    if degrees >= 0:
        we = 'W'
    else:
        we = 'E'
    coord_lat = f"{degrees:2.0f}\N{DEGREE SIGN}{minutes:02.0f},{seconds:02.0f}´{we}"

    is_positive = dd_lon >= 0
    dd_lon = abs(dd_lon)
    minutes,seconds = divmod(dd_lon*3600,60)
    degrees,minutes = divmod(minutes,60)
    degrees = degrees if is_positive else -degrees
    if degrees >= 0:
        ns = 'N'
    else:
        ns = 'S'
    coord_lon = f"{degrees:03.0f}\N{DEGREE SIGN}{minutes:02.0f},{seconds:02.0f}´{ns}"

    return (coord_lat, coord_lon)

def gen_pos(min,max):
    dd = random.uniform(min, max)
    return (dd)

def get_next():
    lat,lon = decdeg2dms( gen_pos(63.80000000,64.03055556) , gen_pos(25.43333333,26.15000000) )
    angle = random.uniform(0, 360)
    angle = f"{angle:03.0f}\N{DEGREE SIGN}"
    mpk = random.uniform(0, 10)
    mpk = f"{mpk:1.1f} mpk"
    knots = random.uniform(1, 10)
    knots = f"{knots:1.0f} knots"
    textline = f"{lat}, {lon}, {angle}, {mpk}, {knots}"
    return textline

for count in range(0,10):
    pprint( get_next() )
