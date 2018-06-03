module rtree.rtree;

import rtree.shape;
import std.algorithm : minElement;

template RTree(Value, MBR = Rect)
if (is(Value : Shape) && is(MBR : Cuboid)) {
  private abstract class NodeBase {
    MBR mbr;
    immutable bool isLeaf;
    Node parent;

    this(MBR mbr, Node parent, bool isLeaf) {
      this.mbr = mbr;
      this.isLeaf = isLeaf;
      this.parent = parent;
    }

    abstract MBR fixMBR();
  }

  private class Node : NodeBase {
    NodeBase[] childs;

    this(MBR mbr, Node parent) {
      super(mbr, parent, false);
    }

    Node opOpAssign(string op : "~")(NodeBase node) {
      this.childs ~= node;
      super.mbr.enlarge(node.mbr);
      node.parent = this;
      return this;
    }

    override MBR fixMBR() {
      MBR mbr = this.childs[0].mbr.dup;
      foreach (child; this.childs[1 .. $]) mbr.enlarge(child.mbr);
      super.mbr = mbr;
      return mbr;
    }
  }

  private class Leaf : NodeBase {
    Value[] childs;

    this(MBR mbr, Node parent) {
      super(mbr, parent, true);
    }

    Leaf opOpAssign(string op : "~")(Value val) {
      this.childs ~= val;
      super.mbr.enlarge(val);
      return this;
    }

    override MBR fixMBR() {
      MBR mbr = new MBR(this.childs[0]);
      foreach (child; this.childs[1 .. $]) mbr.enlarge(child);
      super.mbr = mbr;
      return mbr;
    }
  }

  class RTree {
    immutable uint M;
    private NodeBase _root;

    this(uint M) {
      if (M < 2)
        throw new Exception("Invalid construction arguments.");

      this.M = M;
    }

    private void _find(NodeBase node, Shape shape, ref Value[] res) {
      if (Node obj = cast(Node)node) {
        foreach (child; obj.childs) {
          if (child.mbr.intersects(shape))
            this._find(child, shape, res);
        }
      } else { // leaf
        Leaf obj = cast(Leaf)node;
        foreach (child; obj.childs) {
          if (child.intersects(shape))
            res ~= child;
        }
      }
    }

    Value[] find(Shape shape) {
      if (this._root is null) return null;
      Value[] result;
      this._find(this._root, shape, result);
      return result;
    }

    private Leaf _chooseLeaf(Value val) {
      NodeBase node = this._root;

      while (!node.isLeaf) {
        node = (cast(Node)node).childs.minElement!(el => (
          el.mbr.dup.enlarge(val).area - el.mbr.area
        ));
      }

      return cast(Leaf)node;
    }

    private void _adjust(NodeBase node, NodeBase splitted) {
      NodeBase part1 = node, part2 = splitted;

      while (part1 !is this._root) {
        Node p1 = part1.parent, p2 = null;
        part1.fixMBR();

        if (part2 !is null) {
          p1 ~= part2;
          if (p1.childs.length > this.M) p2 = this._split(p1);
        }

        part1 = p1;
        part2 = p2;
      }

      if (part2 !is null) {
        Node root = new Node(cast(MBR)part1.mbr.dup.enlarge(part2.mbr), null);
        root ~= part1;
        root ~= part2;
        this._root = root;
      }
    }

    private NodeType _split(NodeType)(NodeType obj)
    if (is(NodeType == Leaf) || is(NodeType == Node)) {
      auto childs = obj.childs.dup;
      auto middle = childs.length / 2;
      MBR mbr;
      static if (is(NodeType == Leaf)) mbr = new MBR(childs[middle]);
      else mbr = childs[middle].mbr.dup;
      NodeType splitted = new NodeType(mbr, null);

      obj.childs = childs[0 .. middle];
      obj.fixMBR();
      foreach (child; childs[middle .. $]) splitted ~= child;
      return splitted;
    }

    RTree opOpAssign(string op : "~")(Value val) { // insertion
      if (this._root is null) this._root = new Leaf(new MBR(val), null);
      Leaf node = this._chooseLeaf(val);

      Leaf splitted = null;
      node ~= val;
      if (node.childs.length > this.M) splitted = this._split(node);

      this._adjust(node, splitted);

      return this;
    }
  }
}
