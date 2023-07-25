#!/usr/bin/env python3

from math import cos, sin, exp, pi, isnan, isinf
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

    N = 150000

    square_points = []
    circle_points = []
    result_points = []

    max_x = max_y = -np.inf
    min_x = min_y = np.inf

    circle = shape.Circle(0, 0,  radius=3, division_hack=True)
    square = shape.Polygon(0, 0, radius=3, num_sides=4, division_hack=True)

    # DIVISION TEST
    result = square / circle

    
    for n in range(N + 1):
        theta = n/N * 2 * pi

        square_pt = square.get_point(theta)
        square_points.append(square_pt)

        circle_pt = circle.get_point(theta)
        circle_points.append(circle_pt)

        result_pt = result.get_point(theta)
        result_points.append(result_pt)

        for p in [circle_pt, ]:
            max_x = max(p[0], max_x)
            max_y = max(p[1], max_y)
            min_x = min(p[0], min_x)
            min_y = min(p[1], min_y)

    max_x, max_y, min_x, min_y = shape.fix_extents(max_x, max_y, min_x, min_y)

    frames = []
    ctx.set_source_rgb(1, 1, 1)
    shape.draw_axes(ctx, STROKE, max_x, max_y, min_x, min_y, image_width, image_height)

    for i in range(len(circle_points)//1000):
        i = i * 1000
        print(f"Status 2: {i/N}")
        ctx.set_source_rgb(.5, 1, .5)
        shape.draw_curve(ctx, result_points[:i], STROKE, image_width, image_height,
                max_x, max_y, min_x, min_y, True)
        shape.draw_curve(ctx, result_points[:i], STROKE, image_width, image_height,
                max_x, max_y, min_x, min_y, False)

        frame = to_pil(surface)
        frame = ImageOps.flip(frame)
        frames.append(frame)
        # surface.write_to_png(f"tmp/{filename}_{i:07d}.png")

    # last frame; compete image
    ctx.set_source_rgb(.5, 1, .5)
    shape.draw_curve(ctx, result_points, STROKE, image_width, image_height,
            max_x, max_y, min_x, min_y, True)
    shape.draw_curve(ctx, result_points, STROKE, image_width, image_height,
            max_x, max_y, min_x, min_y, False)
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
