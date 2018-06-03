import argparse
import math
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

def distance(x, y, object):
    return math.sqrt((x - object.point[0])**2 + (y - object.point[1])**2)

if __name__ == "__main__":
    # add arguments
    parser = argparse.ArgumentParser()
<<<<<<< HEAD
<<<<<<< e71f17b39959c6a1f1f84a3593d5df754ae2bdee
    parser.add_argument('-f', '--file', required=False, default='data.csv')
=======
    parser.add_argument('-f', '--input_file', required=False, default='../data.csv')
>>>>>>> Repo restructure
=======
    parser.add_argument('-f', '--input_file', required=False, default='../data.csv')
>>>>>>> 0c5dedb96a665f9e98f07edd11441b2c07d7de3e
    parser.add_argument('-long', '--longitude', required=True, default=None)
    parser.add_argument('-lat', '--latitude', required=True, default=None)
    parser.add_argument('-s', '--size', required=False, default=None)
    parser.add_argument('-t', '--type', required=False, default='box')
    parser.add_argument('-near', '--object', required=False, default=None)

    # parse arguments
    args = parser.parse_args()
    x = float(args.longitude)
    y = float(args.latitude)
    if args.size: size = float(args.size)
    near = False
    if args.object: near = True

    # add points
    points = parse(args.file)
    rtree = RTree()
    for point in points: rtree.insert(point)

    # search nearest (Additional task)
    if near:
        # search for near objects as square
        if args.type == "box":
            default_size = 1 # set default serch radius (square)
            res = rtree.find_rect(x, y, default_size, rtree.head) # find all near objects
            objects = [x for x in res if x.type == args.object] # get near objects
            while len(objects) == 0 and default_size < 15: # increase radius and continue searching
                default_size += 3
                objects = [x for x in res if x.type == args.object]

            # find nearest object
            distances = map(lambda obj: distance(x, y, obj), objects)
            min_index = distances.index(min(distances))
            nearest = objects[min_index]

            # print nearest
            print(str(nearest.point[0]), str(nearest.point[1]), str(nearest.type), str(nearest.subtype), str(nearest.name), str(nearest.address))

        # search as circle
        elif args.type == "circle":
            default_size = 1 # set default serch radius (square)
            res = rtree.find_circle(x, y, size, rtree.head) # find all near objects
            objects = [x for x in res if x.type == args.object] # get near objects
            while len(objects) == 0 and default_size < 15: # increase radius and continue searching
                default_size += 3
                objects = [x for x in res if x.type == args.object]

            # find nearest object
            distances = map(lambda obj: distance(x, y, obj), objects)
            min_index = distances.index(min(distances))
            nearest = objects[min_index]

            # print nearest
            print(str(nearest.point[0]), str(nearest.point[1]), str(nearest.type), str(nearest.subtype), str(nearest.name), str(nearest.address))

        # unknown type of search
        else: print("Invalid type!")
    else:
        # default task
        # search in range as box
        if args.type == "box":
            res = rtree.find_rect(x, y, size, rtree.head)

            # print found points
            for i in range(len(res)):
                print(str(i + 1) + ". " + str(res[i].point[0]), str(res[i].point[1]), str(res[i].type),
                        str(res[i].subtype), str(res[i].name), str(res[i].address))

        # search in range as circle
        elif args.type == "circle":
            res = rtree.find_circle(x, y, size, rtree.head)

            # print found points
            for i in range(len(res)):
                print(str(i + 1) + ". " + str(res[i].point[0]), str(res[i].point[1]), str(res[i].type),
                        str(res[i].subtype), str(res[i].name), str(res[i].address))
        else:
            # unknown type
            print("Invalid type!")
