module main;

import std.stdio : writeln;
import std.csv : csvReader, Malformed;
import std.getopt : getopt, defaultGetoptPrinter, config;
import std.file : readText;
import std.algorithm : map, filter, minElement;
import std.math : log, tan, PI;
import std.range : enumerate;

import rtree : RTree, Shape, Rect, Circle;
import place : PlaceData, Place, PlaceType;

enum ShapeType { rect, circle }
enum kmPerDegree = 111;
enum SearchType { all, nearest }

struct ParsedArgs {
  string db;
  float lat;
  float lon;
  float size;
  ShapeType shape = ShapeType.rect;
  bool help;
  PlaceType type = PlaceType.all;
  SearchType search = SearchType.all;
}

void main(string[] args) {
  try {
    ParsedArgs parsed = parseArgs(args);
    if (parsed.help) return;

    RTree!Place tree = new RTree!Place(5);
    foreach (elem; parsed.db.parseDB) tree ~= elem;

    auto data = tree.find(parsed.shapify).filter!(el => (
      el.type == parsed.type || parsed.type == PlaceType.all
    ));

    if (data.empty) "Looks like there's nothing to show :(".writeln;
    else if (parsed.search == SearchType.all) {
      "Here's what I've found:".writeln;
      foreach (i, elem; data.enumerate(1)) writeln(i, ": ", elem);
    } else {
      "The nearest place is:".writeln;
      data.minElement!(el => (el.x - parsed.lon) ^^ 2 + (el.y - parsed.lat) ^^ 2).writeln;
    }
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
    "shape|z", "Search zone shape (default to 'rect').", &result.shape,
    "type|t", "Type of object to find (default to 'all').", &result.type,
    "search|f", "Type of search result (default to 'all', can be 'nearest').", &result.search
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
  if (args.shape == ShapeType.rect)
    return new Rect(
      args.lon - args.size / kmPerDegree,
      args.lon + args.size / kmPerDegree,
      args.lat + args.size / kmPerDegree * mercator,
      args.lat - args.size / kmPerDegree * mercator
    );
  else // circle
    return new Circle(args.lon, args.lat, args.size / kmPerDegree * mercator);
}
