module main;

import std.stdio : writeln;
import std.csv : csvReader, Malformed;
import std.getopt : getopt, defaultGetoptPrinter, config;
import std.file : readText;
import std.algorithm : map;
import std.math : log, tan, PI;

import rtree : RTree, Shape, Rect, Circle;
import place : PlaceData, Place;

enum ShapeType { Rect, Circle }

struct ParsedArgs {
  string db;
  float lat;
  float lon;
  float size;
  ShapeType type = ShapeType.Rect;
  bool help;
}

void main(string[] args) {
  try {
    ParsedArgs parsed = parseArgs(args);
    if (parsed.help) return;

    RTree!Place tree = new RTree!Place(5);
    foreach (elem; parsed.db.parseDB) tree ~= elem;

    foreach (i, elem; tree.find(parsed.shapify)) writeln(i + 1, ": ", elem);
  } catch (Exception e) writeln("Exception was thrown: ", e.msg);
}

ParsedArgs parseArgs(string[] raw) {
  ParsedArgs result;

  auto parsed = getopt(
    raw,
    config.required,
    "db", "Database file to parse.", &result.db,
    config.required,
    "lat", "Latitude of the search center.", &result.lat,
    config.required,
    "long", "Longitude of the search center.", &result.lon,
    config.required,
    "size|s", "Search zone radius.", &result.size,
    "type|t", "Search zone type.", &result.type
  );

  if (parsed.helpWanted) {
    defaultGetoptPrinter("Command line arguments:", parsed.options);
    result.help = true;
  }

  return result;
}

auto parseDB(string db) {
  return db.readText.csvReader!(PlaceData, Malformed.ignore)(';').map!(elem => (
    new Place(elem)
  ));
}

Shape shapify(ParsedArgs args) {
  real mercator = (args.lat / 2 * PI / 180 + PI / 4).tan.log;
  if (args.type == ShapeType.Rect)
    return new Rect(
      args.lon - args.size / 111,
      args.lon + args.size / 111,
      args.lat + args.size / 111 * mercator,
      args.lat - args.size / 111 * mercator
    );
  else // circle
    return new Circle(args.lon, args.lat, args.size / 111 * mercator);
}
