import argparse
from RTree import RTree
from RTree import Rectangle

# run : python3 -lat= -long= -t= -f=
# -t : --type
# -f : --input_file
# -s : --size

class Point:
    def __init__(self, coords, _type, subtype, name, address):
        self.point = coords
        self.type = _type
        self.subtype = subtype
        self.name = name
        self.address = address
        self.rectangle = Rectangle(coords[0], coords[0], coords[1], coords[1])

def parse(input_file):
    with open(input_file) as file:
        data = file.read().split("\n")
        data = [x.split(";") for x in data]
    return [Point([float(x[0]), float(x[1])], x[2], x[3], x[4], x[5]) for x in data[:-1]]

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--input_file', required=False, default='data.csv')
    parser.add_argument('-long', '--longitude', required=True, default=None)
    parser.add_argument('-lat', '--latitude', required=True, default=None)
    parser.add_argument('-s', '--size', required=True, default=None)
    parser.add_argument('-t', '--type', required=False, default='box')
    args = parser.parse_args()
    x = float(args.longitude)
    y = float(args.latitude)
    size = float(args.size)
    # add points
    points = parse(args.input_file)
    rtree = RTree()
    for point in points: rtree.insert(point)
    # search
    if args.type == "box":
        res = rtree.find_rect(x, y, size, rtree.head)
        for i in range(len(res)):
            print(str(i+1) + ". " + str(res[i].point[0]), str(res[i].point[1]), str(res[i].type), str(res[i].subtype), str(res[i].name), str(res[i].address))
    elif args.type == "circle":
        res = rtree.find_circle(x, y, size, rtree.head)
        for i in range(len(res)):
            print(str(i+1) + ". " + str(res[i].point[0]), str(res[i].point[1]), str(res[i].type), str(res[i].subtype), str(res[i].name), str(res[i].address))
    else:
        print("Invalid type!")
