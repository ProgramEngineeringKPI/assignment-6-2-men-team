module place;

import rtree : Point;
import std.format : format;

enum PlaceType { amenity, leisure, shop, sport, tourism, all }

struct PlaceData {
  float lat; // y
  float lon; // x
  PlaceType type;
  string subtype;
  wstring name;
  wstring address;
}

class Place : Point {
  immutable PlaceData data;

  this(PlaceData data) {
    super(data.lon, data.lat);
    this.data = data;
  }

  override string toString() const {
    return format!"(%s, %s); %s (%s); '%s'; %s"(
      this.data.lat,
      this.data.lon,
      this.data.type,
      this.data.subtype,
      this.data.name,
      this.data.address
    );
  }

  alias data this;
}
