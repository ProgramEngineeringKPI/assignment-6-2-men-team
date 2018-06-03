module place;

import rtree : Point;
import std.format : format;

struct PlaceData {
  float lat; // y
  float lon; // x
  string type;
  string subtype;
  wstring name;
  wstring address;
}

class Place : Point {
  private PlaceData _data;

  this(PlaceData data) {
    super(data.lon, data.lat);
    this._data = data;
  }

  override string toString() const {
    return format!"(%s, %s); %s (%s); '%s'; %s"(
      this._data.lat,
      this._data.lon,
      this._data.type,
      this._data.subtype,
      this._data.name,
      this._data.address
    );
  }

  alias _data this;
}
