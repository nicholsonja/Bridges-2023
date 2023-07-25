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
   
    epitrochoid_points = []
    lem1_points = []
    lem2_points = []
    lem3_points = []
    lem4_points = []

    # result_points = []

    max_x = max_y = -np.inf
    min_x = min_y = np.inf

    epitrochoid = shape.Epitrochoid(0, 0, 32, 4, 32);
    lem1 = shape.Lemniscate(0, 100, 40);
    lem2 = shape.Lemniscate(0, 100, 40).rotate(pi/2, 0, 0);
    lem3 = shape.Lemniscate(0, 100, 40).rotate(2 * pi/2, 0, 0);
    lem4 = shape.Lemniscate(0, 100, 40).rotate(3 * pi/2, 0, 0);

    for n in range(N + 1):
        theta = n/N * 2 * pi

        epitrochoid_pt = epitrochoid.get_point(theta)
        epitrochoid_points.append(epitrochoid_pt)

        lem1_pt = lem1.get_point(theta)
        lem1_points.append(lem1_pt)

        lem2_pt = lem2.get_point(theta)
        lem2_points.append(lem2_pt)

        lem3_pt = lem3.get_point(theta)
        lem3_points.append(lem3_pt)

        lem4_pt = lem4.get_point(theta)
        lem4_points.append(lem4_pt)

        for p in [epitrochoid_pt, lem1_pt, lem2_pt, lem3_pt, lem4_pt ]: #, result_pt]:
            max_x = max(p[0], max_x)
            max_y = max(p[1], max_y)
            min_x = min(p[0], min_x)
            min_y = min(p[1], min_y)

    max_x, max_y, min_x, min_y = shape.fix_extents(max_x, max_y, min_x, min_y)

    frames = []
    ctx.set_source_rgb(1, 1, 1)
    shape.draw_axes(ctx, STROKE, max_x, max_y, min_x, min_y, image_width, image_height)

    shape_data = [
            (.5, 1, .5, epitrochoid_points),
            (1, 1, 0, lem1_points),
            (0, 1, 1, lem2_points),
            (1, 0, 1, lem3_points),
            (1, .5, .5, lem4_points),
            ]

    for i in range(len(epitrochoid_points)//100):
        i = i * 100
        for r, g, b, points in shape_data:
            ctx.set_source_rgb(r, g, b)
            shape.draw_curve(ctx, points[:i], STROKE, image_width, image_height,
                    max_x, max_y, min_x, min_y, True)

        frame = to_pil(surface)
        frame = ImageOps.flip(frame)
        frames.append(frame)
        # surface.write_to_png(f"tmp/{filename}_{i:07d}.png")

    # last frame; compete image
    for r, g, b, points in shape_data:
        ctx.set_source_rgb(r, g, b)
        shape.draw_curve(ctx, points, STROKE, image_width, image_height,
                max_x, max_y, min_x, min_y, True)

    frame = to_pil(surface)
    frame = ImageOps.flip(frame)
    frames.append(frame)

    duration = (20 * 1000)/len(frames)
    frames[0].save(f'{filename}.gif',
               save_all=True, append_images=frames[1:], optimize=True, duration=duration)
    
        
if __name__ == "__main__":
    width = int(IMAGE_WIDTH_IN * DPI)
    height = int(IMAGE_HEIGHT_IN * DPI)
    fn = os.path.basename(__file__)
    num = fn[9:11]
    filename = f"image_{num}"
    print(filename)
    makeImage(height, width, filename)
    #os.system(f"convert -flip {filename}.png {filename}_final.png")
    print("Done")
