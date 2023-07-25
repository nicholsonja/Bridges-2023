from math import cos, sin, pi, isnan, gcd
import numpy as np

def get_drawing_width(image_width):
    return image_width * .95


def fix_extents(max_x, max_y, min_x, min_y):
    x_range = abs(max_x - min_x)
    y_range = abs(max_y - min_y)
    if x_range > y_range:
        mid_y = (max_y + min_y)/2
        max_y  = mid_y + x_range/2
        min_y  = mid_y - x_range/2
    else:
        mid_x = (max_x + min_x)/2
        max_x  = mid_x + y_range/2
        min_x  = mid_x - y_range/2
    return max_x, max_y, min_x, min_y


def draw_axes(ctx, stroke, max_x, max_y, min_x, min_y, image_width, image_height):
    ctx.set_line_width(stroke)

    drawing_width = get_drawing_width(image_width)

    origin = (np.interp(0, [min_x, max_x], [-drawing_width/2, drawing_width/2]),
              np.interp(0, [min_y, max_y], [-drawing_width/2, drawing_width/2]))

    ctx.set_line_width(stroke/2)

    ctx.move_to(origin[0] + image_width/2, origin[1] + image_height + image_height/2)
    ctx.line_to(origin[0] + image_width/2, origin[1] - image_height + image_height/2)
    ctx.stroke()

    ctx.move_to(origin[0] + image_width + image_width/2, origin[1] + image_height/2)
    ctx.line_to(origin[0] - image_width + image_width/2, origin[1] + image_height/2)
    ctx.stroke()


# Big honkin' hack because
# pycairo doesn't seem to be able to tell the difference between
# INF and -INF
def fix_inf(pt, draw_pt):
    x, y = pt
    draw_pt = list(draw_pt)
    
    if np.isinf(x):
        if x > 0:
            draw_pt[0] = 1_000_000_000
        else:
            draw_pt[0] = -1_000_000_000

    if np.isinf(y):
        if y > 0:
            draw_pt[1] = 1_000_000_000
        else:
            draw_pt[1] = -1_000_000_000

    return draw_pt


def rotate_point(x, y, rotation_theta, rotation_cx, rotation_cy):
        x -= rotation_cx
        y -= rotation_cy
    
        s = sin(rotation_theta)
        c = cos(rotation_theta)
  
        x_new = x * c - y * s
        y_new = x * s + y * c

        x = x_new + rotation_cx
        y = y_new + rotation_cy

        return x, y


def draw_curve(ctx, points, stroke, image_width, image_height,
               max_x, max_y, min_x, min_y, 
               as_points=False, 
               show_start=False, start_color=(1,0,0), start_size=3):

    ctx.set_line_width(stroke)

    drawing_width = get_drawing_width(image_width)

    for i in range(len(points) - 1):
        tmp_a = points[i]
        a = (np.interp(tmp_a[0], [min_x, max_x], [-drawing_width/2, drawing_width/2]),
             np.interp(tmp_a[1], [min_y, max_y], [-drawing_width/2, drawing_width/2]))
        a = fix_inf(tmp_a, a)

        tmp_b = points[i+1]
        b = (np.interp(tmp_b[0], [min_x, max_x], [-drawing_width/2, drawing_width/2]),
             np.interp(tmp_b[1], [min_y, max_y], [-drawing_width/2, drawing_width/2]))
        b = fix_inf(tmp_b, b)

        if isnan(tmp_a[0]) or isnan(tmp_a[1]):
            continue

        if as_points: 
            ctx.arc(a[0] + image_width/2, a[1] + image_height/2, stroke/2, 0, 2*pi)
            ctx.fill()
        else:
            if isnan(tmp_b[0]) or isnan(tmp_b[1]):
                continue

            ctx.move_to(a[0] + image_width/2, a[1] + image_height/2)
            ctx.line_to(b[0] + image_width/2, b[1] + image_height/2)
            ctx.stroke()

    if show_start:
        ctx.set_source_rgb(start_color[0], start_color[1], start_color[2])
        pt = points[0]
        pt = (np.interp(pt[0], [min_x, max_x], [-drawing_width/2, drawing_width/2]),
              np.interp(pt[1], [min_y, max_y], [-drawing_width/2, drawing_width/2]))
        ctx.arc(pt[0] + image_width/2, pt[1] + image_height/2, start_size * stroke, 0, 2*pi)
        ctx.fill()



class Shape:
    def __init__(self, cx, cy):
        self._cx = cx
        self._cy = cy

    def get_point(self, theta):
        raise NotImplementException()

    def offset(self, theta):
        return OffsetShape(self, theta)

    def rotate(self, rotation_theta, rotation_cx=None, rotation_cy=None):
        """
        Create a RotateShape. 
        If rotation_cx is None, use the shape's center x.
        If rotation_cy is None, use the shape's center y.
        """
        if rotation_cx == None:
            rotation_cx = self._cx
        if rotation_cy == None:
            rotation_cy = self._cy
        return RotateShape(self, rotation_theta, rotation_cx, rotation_cy)

    def __add__(self, b):
        return AddShape(self, b)

    def __sub__(self, b):
        return SubtractShape(self, b)

    def __mul__(self, b):
        return MultiplyShape(self, b)

    def __truediv__(self, b):
        return DivideShape(self, b)

    def cos(self):
        return CosineShape(self)

    def translate(self, new_cx, new_cy):
        return TranslateShape(self, new_cx, new_cy)


class Circle(Shape):
    def __init__(self, cx, cy, radius, division_hack=False):
        super().__init__(cx, cy)
        self._radius = radius
        self._division_hack = division_hack 

    def get_point(self, theta):
        x = cos(theta) * self._radius + self._cx
        y = sin(theta) * self._radius + self._cy

        
        # truncate number because division and float aren't playing nice
        # when dividing by 0 for some examples
        # Python handles this different that Processing
        if self._division_hack:
            x = int(x * 1000) / 1000
            y = int(y * 1000) / 1000

        return (x, y)


class Line(Shape):
    def __init__(self, cx, cy, width):
        super().__init__(cx, cy)
        self._width = width;

    def get_point(self, theta):
        x = sin(theta) * self._width + self._cx
        y = self._cy
        return (x, y)
  


class Polygon(Shape):
    def __init__(self, cx, cy, radius, num_sides, division_hack=False):
        super().__init__(cx, cy)
        self._radius = radius
        self._num_sides = num_sides
        self._division_hack = division_hack 

    def get_point(self, theta):
        corner_angles = [2 * pi * i/self._num_sides for i in range(self._num_sides+1)]

        start_theta = corner_angles[0]
        end_theta = corner_angles[1]
        side = 1

        # print(theta, end=" ")
        theta = theta % (2 * pi)
        # print(theta)

        while theta > end_theta:
            start_theta = corner_angles[side-1]
            end_theta = corner_angles[side]
            side += 1

        start_point = [cos(start_theta) * self._radius + self._cx,
                       sin(start_theta) * self._radius + self._cy]
        end_point = [cos(end_theta) * self._radius + self._cx,
                     sin(end_theta) * self._radius + self._cy]

        # truncate number because division and float aren't playing nice
        # when dividing by 0 for some examples
        if self._division_hack:
            for pt in (start_point, end_point):
                pt[0] = int(pt[0] * 1000) / 1000
                pt[1] = int(pt[1] * 1000) / 1000

        amt = (theta - start_theta)/(end_theta - start_theta)

        return (
            np.interp(amt, [0.0, 1.0], [start_point[0], end_point[0]]),
            np.interp(amt, [0.0, 1.0], [start_point[1], end_point[1]]),
        )


class Epitrochoid(Shape):
    def __init__(self, cx, cy, R, r, d):
        super().__init__(cx, cy)
        self._R = R
        self._r = r
        self._d = d

    def get_point(self, theta):
        thetaMultiplier = self._r / gcd(self._R, self._r)
        theta = theta * thetaMultiplier

        x = (self._R+self._r) * cos(theta) - self._d * cos((self._R+self._r)/self._r * theta) + self._cx
        y = (self._R+self._r) * sin(theta) - self._d * sin((self._R+self._r)/self._r * theta) + self._cy
        return (x, y)


class Hypotrochoid(Shape):
    def __init__(self, cx, cy, R, r, d):
        super().__init__(cx, cy)
        self._R = R
        self._r = r
        self._d = d
    
        self._thetaMultiplier = r/ gcd(R, r)
  
    def get_point(self, theta):
        theta = theta * self._thetaMultiplier;
      
        x = (self._R-self._r) * cos(theta) + self._d * cos((self._R-self._r)/self._r * theta) + self._cx
        y = (self._R-self._r) * sin(theta) - self._d * sin((self._R-self._r)/self._r * theta) + self._cy
        return (x, y)

class Lemniscate(Shape):
    def __init__(self, cx, cy, alpha):
        super().__init__(cx, cy)
        self._alpha = alpha

    def get_point(self, theta):
        x = (self._alpha * cos(theta))/(1 + pow(sin(theta), 2)) + self._cx
        y = (self._alpha * sin(theta) * cos(theta))/(1 + pow(sin(theta), 2)) + self._cy
        return (x, y)


class RoseCurve(Shape):
    def __init__(self, cx, cy, alpha, n, d):
        super().__init__(cx, cy)
        self._alpha = alpha
        self._n = n
        self._d = d

    def get_point(self, theta):
        denom = gcd(self._n, self._d)
        n = self._n/denom
        d = self._d/denom
        k = n/d
       
        if n % 2 == 1 and d % 2 == 1:
            thetaMultiplier = d
        elif (n % 2 == 0 and d % 2 == 1) or (n % 2 == 1 and d % 2 == 0):
            thetaMultiplier = 2 * d
        else:
            thetaMultiplier = 1
        # print(f"rose_curve debug: n: {n}, d: {d}, thetaMul: {thetaMultiplier}")
    
        theta = theta * thetaMultiplier
        x = self._alpha * cos(k * theta) * cos(theta) + self._cx
        y = self._alpha * cos(k * theta) * sin(theta) + self._cy
        return (x, y)


class OffsetShape(Shape):
    """
    Used to offset the angle where the shape is drawn.
    """
    def __init__(self, shapeA, offset):
        super().__init__(shapeA._cx, shapeA._cy)
        self._shapeA = shapeA
        self._offset = offset

    def get_point(self, theta):
        a_pt = self._shapeA.get_point(theta + self._offset)
        return a_pt


class RotateShape(Shape):
    def __init__(self, shapeA, rotation_theta, rotation_cx, rotation_cy):
        cx, cy = rotate_point(shapeA._cx, shapeA._cy, 
                              rotation_theta, 
                              rotation_cx, rotation_cy)
        super().__init__(cx, cy)

        self._shapeA = shapeA
        self._rotation_theta = rotation_theta

        if rotation_cx is None:
            self._rotation_cx = shapeA._cx
        else:
            self._rotation_cx = rotation_cx

        if rotation_cy is None:
            self._rotation_cy = shapeA._cy
        else:
            self._rotation_cy = rotation_cy

    def get_point(self, theta):
        pt = self._shapeA.get_point(theta)

        x, y = rotate_point(pt[0], pt[1], self._rotation_theta, 
                            self._rotation_cx, self._rotation_cy)
    
        return (x, y)


class AddShape(Shape):
    def __init__(self, shapeA, shapeB):
        super().__init__(shapeA._cx + shapeB._cx, shapeA._cy + shapeB._cy)
        self._shapeA = shapeA
        self._shapeB = shapeB

    def get_point(self, theta):
        a_pt = self._shapeA.get_point(theta)
        b_pt = self._shapeB.get_point(theta)
        x = a_pt[0] + b_pt[0]
        y = a_pt[1] + b_pt[1]
        return (x, y)


class SubtractShape(Shape):
    def __init__(self, shapeA, shapeB):
        super().__init__(shapeA._cx - shapeB._cx, shapeA._cy - shapeB._cy)
        self._shapeA = shapeA
        self._shapeB = shapeB

    def get_point(self, theta):
        a_pt = self._shapeA.get_point(theta)
        b_pt = self._shapeB.get_point(theta)
        x = a_pt[0] - b_pt[0]
        y = a_pt[1] - b_pt[1]
        return (x, y)


class MultiplyShape(Shape):
    def __init__(self, shapeA, shapeB):
        super().__init__(shapeA._cx * shapeB._cx, shapeA._cy * shapeB._cy)
        self._shapeA = shapeA
        self._shapeB = shapeB

    def get_point(self, theta):
        a_pt = self._shapeA.get_point(theta)
        b_pt = self._shapeB.get_point(theta)
        x = a_pt[0] * b_pt[0]
        y = a_pt[1] * b_pt[1]
        return (x, y)


class DivideShape(Shape):
    def __init__(self, shapeA, shapeB):
        """
        In order to avoid division by 0, if the cx or xy of shapeB,
        then the cx or cy of the DivideShape to 0.
        """
        if shapeB._cx == 0:
            cx = 0
        else:
            b_cx = shapeA.cx / shapeB._cx

        if shapeB._cy == 0:
            cy = 0
        else:
            b_cy = shapeA.cy / shapeB._cy
        super().__init__(cx, cy)
        self._shapeA = shapeA
        self._shapeB = shapeB

    def get_point(self, theta):
        a_pt = self._shapeA.get_point(theta)
        b_pt = self._shapeB.get_point(theta)
        x = a_pt[0] / b_pt[0]
        y = a_pt[1] / b_pt[1]
        return (x, y)


class CosineShape(Shape):
    def __init__(self, shapeA):
        super().__init__(cos(shapeA._cx), cos(shapeA._cy))
        self._shapeA = shapeA

    def get_point(self, theta):
        a_pt = self._shapeA.get_point(theta)
        x = cos(a_pt[0])
        y = cos(a_pt[1])
        return (x, y)


class TranslateShape(Shape):
    def __init__(self, shapeA, new_cx, new_cy):
        super().__init__(new_cx, new_cy)
        self._shapeA = shapeA
        self._old_cx = shapeA._cx
        self._old_cy = shapeA._cy
        self._new_cx = new_cx
        self._new_cy = new_cy

    def get_point(self, theta):
        a_pt = self._shapeA.get_point(theta)
        return (
            a_pt[0] - self._old_cx + self._new_cx,
            a_pt[1] - self._old_cy + self._new_cy
        )

