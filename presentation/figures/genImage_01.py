#!/usr/bin/env python3

from math import cos, sin, exp, pi
import shape
import cairo
import numpy as np
import os

IMAGE_WIDTH_IN = 5
IMAGE_HEIGHT_IN = 5
DPI = 300
STROKE = 12


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

    square_points = []
    circle_points = []
    #result_points = []

    max_x = max_y = -np.inf
    min_x = min_y = np.inf

    circle = shape.Circle(0, 0,  radius=3)
    square = shape.Polygon(0, 0, radius=3, num_sides=4)

    # ADDING TEST
    #result = circle + square

    for n in range(N + 1):
        theta = n/N * 2 * pi

        square_pt = square.get_point(theta)
        square_points.append(square_pt)

        circle_pt = circle.get_point(theta)
        circle_points.append(circle_pt)

        #result_pt = result.get_point(theta)
        #result_points.append(result_pt)

        for p in [circle_pt, square_pt]: #, result_pt]:
            max_x = max(p[0], max_x)
            max_y = max(p[1], max_y)
            min_x = min(p[0], min_x)
            min_y = min(p[1], min_y)

    max_x, max_y, min_x, min_y = shape.fix_extents(max_x, max_y, min_x, min_y)

    ctx.set_source_rgb(1, 1, 1)
    shape.draw_axes(ctx, STROKE, max_x, max_y, min_x, min_y, image_width, image_height)

    ctx.set_source_rgb(.5, .5, 1)
    shape.draw_curve(ctx, circle_points, STROKE, image_width, image_height,
               max_x, max_y, min_x, min_y, True)

    ctx.set_source_rgb(1, .5, .5)
    shape.draw_curve(ctx, square_points, STROKE, image_width, image_height,
               max_x, max_y, min_x, min_y, True)

    # ctx.set_source_rgb(1, 0, 0)
    # shape.draw_curve(ctx, result_points, STROKE, image_width, image_height,
    #           max_x, max_y, min_x, min_y, True)


    surface.write_to_png(filename + ".png")
        
if __name__ == "__main__":
    width = IMAGE_WIDTH_IN * DPI
    height = IMAGE_HEIGHT_IN * DPI
    fn = os.path.basename(__file__)
    num = fn[9:11]
    filename = f"image_{num}"
    print(filename)
    makeImage(height, width, filename)
    os.system(f"convert -flip {filename}.png {filename}_final.png")
    print("Done")
