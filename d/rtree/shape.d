module rtree.shape;

import std.math : PI;
import std.algorithm : min, max;

// x - longitude
// y - latitude

interface Shape {
  bool intersects(const Shape) const;
  float area() const;
}

interface Cuboid : Shape {
  Cuboid enlarge(const Shape);
}

class Rect : Cuboid {
  private float _left;
  private float _right;
  private float _top;
  private float _bottom;

  this(float left, float right, float top, float bottom) {
    this._left = left;
    this._right = right;
    this._top = top;
    this._bottom = bottom;
  }

  this(Point p) {
    this._left = this._right = p.x;
    this._top = this._bottom = p.y;
  }

  override @property float area() const
  { return (this._right - this._left) * (this._top - this._bottom); }

  @property float left() const { return this._left; }
  @property float left(float val) { return this._left = val; }

  @property float right() const { return this._right; }
  @property float right(float val) { return this._right = val; }

  @property float top() const { return this._top; }
  @property float top(float val) { return this._top = val; }

  @property float bottom() const { return this._bottom; }
  @property float bottom(float val) { return this._bottom = val; }

  override bool intersects(const Shape s) const {
    if (Rect other = cast(Rect)s) {
      return (
        other._left <= this._right &&
        other._right >= this._left &&
        other._top >= this._bottom &&
        other._bottom <= this._top
      );
    } else if (Circle other = cast(Circle)s) {
      float x = max(this._left, min(other.x, this._right)); // the nearest to the circle
      float y = max(this._bottom, min(other.y, this._top));
      return (x - other.x) ^^ 2 + (y - other.y) ^^ 2 <= other.radius ^^ 2;
    } else if (Point other = cast(Point)s) {
      return (
        other.x <= this._right && other.x >= this._left &&
        other.y <= this._top && other.y >= this._bottom
      );
    } else return s.intersects(this);
  }

  override Cuboid enlarge(const Shape s) {
    if (Point p = cast(Point)s) {
      if (p.x > this._right) this._right = p.x;
      else if (p.x < this._left) this._left = p.x;
      if (p.y > this._top) this._top = p.y;
      else if (p.y < this._bottom) this._bottom = p.y;
    } else if (Rect p = cast(Rect)s) {
      this._left = min(this._left, p._left);
      this._right = max(this._right, p._right);
      this._top = max(this._top, p._top);
      this._bottom = min(this._bottom, p._bottom);
    } else throw new Exception("Not implemented type: " ~ typeid(s).name);
    return this;
  }

  @property Rect dup() const
  { return new Rect(this._left, this._right, this._top, this._bottom); }
}

class Point : Shape {
  private float _x;
  private float _y;

  this(float x, float y) {
    this._x = x;
    this._y = y;
  }

  override @property float area() const { return 0; }

  @property float x() const { return this._x; }
  @property float x(float val) { return this._x = val; }

  @property float y() const { return this._y; }
  @property float y(float val) { return this._y = val; }

  override bool intersects(const Shape s) const {
    if (Rect other = cast(Rect)s) {
      return (
        this._x <= other.right && this._x >= other.left &&
        this._y <= other.top && this._y >= other.bottom
      );
    } else if (Circle other = cast(Circle)s) {
      return (this._x - other.x) ^^ 2 + (this._y - other.y) ^^ 2 <= other.radius ^^ 2;
    } else if (Point other = cast(Point)s) {
      return other._x == this._x && other._y == this._y;
    } else return s.intersects(this);
  }
}

class Circle : Shape {
  private float _x;
  private float _y;
  private float _r;

  this(float x, float y, float r) {
    this._x = x;
    this._y = y;
    this._r = r;
  }

  override @property float area() const
  { return PI * this._r ^^ 2; }

  @property float x() const { return this._x; }
  @property float x(float val) { return this._x = val; }

  @property float y() const { return this._y; }
  @property float y(float val) { return this._y = val; }

  @property float radius() const { return this._r; }
  @property float radius(float val) { return this._r = val; }

  override bool intersects(const Shape s) const {
    if (Rect other = cast(Rect)s) {
      float x = max(other.left, min(this._x, other.right)); // the nearest to the circle
      float y = max(other.bottom, min(this._y, other.top));
      return (x - this._x) ^^ 2 + (y - this._y) ^^ 2 <= this._r ^^ 2;
    } else if (Circle other = cast(Circle)s) {
      return (this._x - other._x) ^^ 2 + (this._y - other._y) ^^ 2 <= (this._r + other._r) ^^ 2;
    } else if (Point other = cast(Point)s) {
      return (other.x - this._x) ^^ 2 + (other.y - this._y) ^^ 2 <= this._r ^^ 2;
    } else return s.intersects(this);
  }
}
