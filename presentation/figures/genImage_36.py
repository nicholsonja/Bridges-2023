#!/usr/bin/env python3

from math import cos, sin, exp, pi
import shape
import cairo
import glob
import numpy as np
import os
import PIL.Image as Image
import PIL.ImageOps as ImageOps


IMAGE_WIDTH_IN = 2.5
IMAGE_HEIGHT_IN = 2.5
DPI = 300
STROKE = 2

# https://pycairo.readthedocs.io/en/stable/integration.html
def to_pil(surface: cairo.ImageSurface) -> Image:
    format = surface.get_format()
    size = (surface.get_width(), surface.get_height())
    stride = surface.get_stride()

    with surface.get_data() as memory:
        if format == cairo.Format.RGB24:
            return Image.frombuffer(
                "RGB", size, memory.tobytes(),
                'raw', "BGRX", stride)
        elif format == cairo.Format.ARGB32:
            return Image.frombuffer(
                "RGBA", size, memory.tobytes(),
                'raw', "BGRa", stride)
        else:
            raise NotImplementedError(repr(format))


def draw_frame(N, epi1, epi2):
    epi1_points = []
    epi2_points = []

    for n in range(N + 1):
        theta = n/N * 2 * pi

        epi1_pt = epi1.get_point(theta)
        epi1_points.append(epi1_pt)

        epi2_pt = epi2.get_point(theta)
        epi2_points.append(epi2_pt)

    return [
                (1, .5, 1, epi1_points),
                (.5, 1, 1, epi2_points),
           ]


def makeImage(height, width, filename):
    image_width = min(width, height)
    image_height = max(width, height)

    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, image_width, image_height)
    ctx = cairo.Context(surface)
    ctx.set_tolerance(.1)

    ctx.set_source_rgb(0, 0, 0)
    ctx.rectangle(0, 0, image_width, image_height)
    ctx.fill()
    ctx.stroke()

    radius = 3

    cx = 0
    cy = 0

    N = 15000

    epi1 = shape.Epitrochoid(0, 0, 100, 30, 40)
    epi2 = shape.Epitrochoid(0, 0, 200, 45, 40)

    offsets = 360

    all_frame_points = []
    for offset_num in range(offsets + 1):
        theta = 2 * pi/offsets * offset_num
        frame_points = draw_frame(N, 
                                  epi1.rotate(theta, 0, 0),
                                  epi2)
                                     
        all_frame_points.append(frame_points)

    max_x = max_y = -np.inf
    min_x = min_y = np.inf

    for frame_points in all_frame_points:
        for r, g, b, points in frame_points:
            for p in points:
                max_x = max(p[0], max_x)
                max_y = max(p[1], max_y)
                min_x = min(p[0], min_x)
                min_y = min(p[1], min_y)

    max_x, max_y, min_x, min_y = shape.fix_extents(max_x, max_y, min_x, min_y)

    frames = []

    for frame_points in all_frame_points:
        ctx.set_source_rgb(0, 0, 0)
        ctx.rectangle(0, 0, image_width, image_height)
        ctx.fill()
        ctx.stroke()

        ctx.set_source_rgb(1, 1, 1)
        shape.draw_axes(ctx, STROKE, max_x, max_y, min_x, min_y, 
                         image_width, image_height)
    
        for r, g, b, points in frame_points: 
            ctx.set_source_rgb(r, g, b)
            shape.draw_curve(ctx, points,
                             STROKE, image_width, image_height,
                             max_x, max_y, min_x, min_y, True)

        frame = to_pil(surface)
        frame = ImageOps.flip(frame)
        frames.append(frame)
   
    duration = (20 * 1000)/len(frames)
    frames[0].save(f'{filename}.gif',
               save_all=True, append_images=frames[1:], optimize=True, duration=duration, loop=0)
    
        
if __name__ == "__main__":
    width = int(IMAGE_WIDTH_IN * DPI)
    height = int(IMAGE_HEIGHT_IN * DPI)
    fn = os.path.basename(__file__)
    num = fn[9:11]

    filename = f"image_{num}"
    print(filename)
    makeImage(height, width, filename)

    print("Done")
