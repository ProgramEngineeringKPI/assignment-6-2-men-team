import math

class Rectangle:
    def __init__(self, xlower, xupper, ylower, yupper):
        self.xlower = xlower
        self.xupper = xupper
        self.ylower = ylower
        self.yupper = yupper
        self.area = (xupper - xlower) * (yupper - ylower)

    def intersection(self, rect):
        return (self.xupper >= rect.xlower and rect.xupper >= self.xlower and self.yupper >= rect.ylower and rect.yupper >= self.ylower)

    def add_rect(self, rect):
        return Rectangle(min(self.xlower, rect.xlower), max(self.xupper, rect.xupper), min(self.ylower, rect.ylower), max(self.yupper, rect.yupper))

class Circle:
    def __init__(self, x, y, radius):
        self.x = x
        self.y = y
        mercator = math.log(math.tan(y/2*math.pi/180 + math.pi/4))
        self.radius = radius/111*mercator

    def intersection(self, rect):
        if self.x >= rect.xupper:
            if self.y >= rect.yupper:
                return ((self.x - rect.xupper)**2 + (self.y - rect.yupper)**2 <= self.radius**2)
            elif self.y >= rect.ylower and self.y < rect.yupper:
                return (self.x - rect.xupper <= self.radius)
            else: return ((self.x - rect.xupper)**2 + (self.y - rect.ylower)**2 <= self.radius**2)
        elif self.x <= rect.xupper and self.x > rect.xlower:
            if self.y >= rect.yupper:
                return (self.y - rect.yupper <= self.radius)
            elif self.y <= rect.yupper and self.y >= rect.ylower:
                return True
            else: return (rect.yupper - self.y <= self.radius)
        elif self.x <= rect.xlower:
            if self.y >= rect.yupper:
                return ((self.x - rect.xlower)**2 + (self.y - rect.yupper)**2 <= self.radius**2)
            elif self.y >= rect.ylower and self.y <= rect.yupper:
                return (rect.xlower - self.x <= self.radius)
            else: return ((self.x - rect.xlower)**2 + (self.y - rect.ylower)**2 <= self.radius**2)

class RTree:
    def __init__(self, N=5):
        self.N = N
        self.head = None

    def insert(self, entry):
        if not self.head:
            self.head = LeafNode([entry])
        else:
            leaf = self.choose_leaf(entry)
            if len(leaf.elem) < self.N:
                self.add_child(leaf, entry)
                self.adjust_bound(leaf)
            elif not leaf.father:
                [leaf, leaf_2] = self.split_head(leaf, entry)
                new_head = Node([leaf, leaf_2])
                self.head = new_head
            else:
                [leaf, leaf_2] = self.split_node(leaf, entry)
                P = self.adjust_tree(leaf, leaf_2)
                self.adjust_bound(P)

    def choose_leaf(self, entry):
        current = self.head
        while True:
            if isinstance(current, LeafNode):
                return current
            else:
                current = self.min_increase(current, entry)

    def min_increase(self, node, entry):
        rect = entry.rectangle
        child = node.children[0]
        min_inc = child.rectangle.add_rect(rect).area - child.rectangle.area
        for item in node.children[1:]:
            increase = item.rectangle.add_rect(rect).area - item.rectangle.area
            if increase < min_inc:
                child, min_inc = item, increase
        return child

    def add_rect(self, node, new_rect):
        if not node.rectangle:
            node.rectangle = new_rect.copy()
        else:
            node.rectangle = node.rectangle.add_rect(new_rect)

    def add_child(self, node, child):
        node.add_child(child)

    def adjust_tree(self, leaf, leaf_2):
        father = leaf.father
        while len(father.children) > self.N:
            children = father.children
            mid = int(len(children)/2)
            left_children, right_children = children[0:mid], children[mid:]
            leaf, leaf_2 = Node(left_children), Node(right_children)
            if father.father:
                father.father.add_child(leaf)
                father.father.add_child(leaf_2)
                father.father.delete_child(father)
            else:
                self.head = Node([leaf, leaf_2])
                break
            father = leaf.father
        return father

    def adjust_bound(self,leaf):
        rect, father = leaf.rectangle, leaf.father
        while father:
            self.add_rect(father, rect)
            rect = father.rectangle
            father = father.father

    def split_node(self, leaf, entry):
        new_entry = leaf.elem + [entry]
        mid = int(len(new_entry)/2)
        left_child, right_child = new_entry[:mid], new_entry[mid:]
        left_leaf, right_leaf = LeafNode(left_child), LeafNode(right_child)
        leaf.father.add_child(left_leaf)
        leaf.father.add_child(right_leaf)
        leaf.father.delete_child(leaf)
        return [left_leaf, right_leaf]

    def split_head(self, leaf, entry):
        new_entry = leaf.elem + [entry]
        mid = int(len(new_entry)/ 2)
        left_child, right_child = new_entry[:mid], new_entry[mid:]
        left_leaf, right_leaf = LeafNode(left_child), LeafNode(right_child)
        return [left_leaf, right_leaf]

    def find_leaf(self, node, entry):
        rect = entry.rectangle
        if isinstance(node, LeafNode):
            for i in node.elem:
                if i.point == entry.point:
                    return i
            return None
        elif isinstance(node, Node):
            for child in node.children:
                if child.rectangle.intersection(rect):
                    found = self.find_leaf(child, entry)
                    if found: return found
            return None

    def find_rect(self, x, y, N, node):
        mercator = math.log(math.tan(y/2*math.pi/180 + math.pi/4))
        xlower, xupper, ylower, yupper = x - N/222, x + N/222, y - N/222*mercator, y + N/222*mercator
        rect = Rectangle(xlower, xupper, ylower, yupper)
        result = []
        if isinstance(node, LeafNode):
            for i in node.elem:
                if rect.intersection(i.rectangle):
                    result.append(i)
        elif isinstance(node, Node):
            for child in node.children:
                if child.rectangle.intersection(rect):
                    result += self.find_rect(x, y, N, child)
        return result

    def find_circle(self, x ,y, N, node):
        circle = Circle(x, y, N)
        result = []
        if isinstance(node, LeafNode):
            for i in node.elem:
                if circle.intersection(i.rectangle):
                    result.append(i)
        elif isinstance(node, Node):
            for child in node.children:
                if circle.intersection(child.rectangle):
                    result += self.find_circle(x, y, N, child)
        return result

class LeafNode:
    def __init__(self, elems=[]):
        self.elem = elems
        self.father = None
        self.rectangle = self.get_rectangle()
        for elem in elems: elem.father = self

    def get_rectangle(self):
        if not self.elem:
            return None
        else:
            rect = self.elem[0].rectangle
            for item in self.elem:
                new_rect = item.rectangle
                rect = rect.add_rect(new_rect)
            return rect

    def add_child(self, entry):
        self.elem.append(entry)
        entry.father = self
        self.rectangle = self.get_rectangle()

    def delete_child(self, entry):
        self.elem.remove(entry)
        entry.father = None
        self.rectangle = self.get_rectangle()

class Node:
    def __init__(self, elems=[]):
        self.children = elems
        self.father = None
        self.rectangle = self.get_rectangle()
        for elem in elems: elem.father = self

    def add_child(self, entry):
        self.children.append(entry)
        entry.father = self
        self.rectangle = self.get_rectangle()

    def delete_child(self, entry):
        self.children.remove(entry)
        entry.father = None
        self.rectangle = self.get_rectangle()

    def get_rectangle(self):
        if not self.children:
            return None
        else:
            rect = self.children[0].rectangle
            for item in self.children:
                new_rect = item.rectangle
                rect = rect.add_rect(new_rect)
            return rect
