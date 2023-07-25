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
STROKE = 1

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


def draw_frame(N, c1, c2, c3, c4):
    c1_points = []
    c2_points = []
    c3_points = []
    c4_points = []
    #result_points = []
    #result = epitrochoid + hypotrochoid

    for n in range(N + 1):
        theta = n/N * 2 * pi

        c1_pt = c1.get_point(theta)
        c1_points.append(c1_pt)

        c2_pt = c2.get_point(theta)
        c2_points.append(c2_pt)

        c3_pt = c3.get_point(theta)
        c3_points.append(c3_pt)

        c4_pt = c4.get_point(theta)
        c4_points.append(c4_pt)

        # result_pt = result.get_point(theta)
        # result_points.append(result_pt)

    return [
                (1, .5, .5, c1_points),
                (.5, 1, .5, c2_points),
                (.5, .5, 1, c3_points),
                (.5, 1, 1, c4_points),
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

    N = 15000

    maxN = 4
    radius = 250
    paths = []
    shapes = []

    for n in range(maxN):
      theta = 2 * pi * n / maxN;
      
      lineCenter = (radius + 25, 0);
      paths.append(shape.Line(lineCenter[0], lineCenter[1], radius)
                        .rotate(theta, 0, 0))
      if n % 2 == 0:
          shapes.append(shape.RoseCurve(0, 0, 100, 2, 1)) # //.rotate(origin, theta));
      else:
          shapes.append(shape.RoseCurve(0, 0, 100, (n + 1) * 20, 1)) #  //.rotate(origin, theta));

    offsets = 360

    all_frame_points = []
    for offset_num in range(offsets + 1):
        theta = 2 * pi/offsets * offset_num

        tmp = []
        for n in range(maxN):
            p = paths[n];
            p_point = p.get_point((n % 2 * 2 -1) * theta)

            s = shapes[n].rotate((n % 2 * 2 -1) * theta, 0, 0) \
                         .translate(p_point[0], p_point[1])
            tmp.append(s);
      
        frame_points = draw_frame(N, tmp[0], tmp[1], tmp[2], tmp[3])

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
