pub const LinkedList = struct {
    pub const Node = struct {
        uid: i64 = 0,
        next: ?*Node = null,
        prev: ?*Node = null,

        pub fn removeFromList(self: *Node) void {
            if (self.prev == null)
                return;

            self.prev.?.next = self.next;
            self.next.?.prev = self.prev;
            self.next = null;
            self.prev = null;
        }
    };

    sentinel: Node = undefined,

    pub fn init(self: *LinkedList) void {
        self.sentinel.prev = &self.sentinel;
        self.sentinel.next = &self.sentinel;
    }

    pub fn pushBack(self: *LinkedList, n: *Node) void {
        if (n.next != null)
            n.removeFromList();

        n.prev = self.sentinel.prev;
        n.next = &self.sentinel;
        n.prev.?.next = n;
        n.next.?.prev = n;
    }

    pub fn popFront(self: *LinkedList) ?*Node {
        var n = self.sentinel.next.?;
        if (n == &self.sentinel)
            return null;

        n.removeFromList();
        return n;
    }
};

const expect = @import("std").testing.expect;
const print = @import("std").debug.print;
test "Linked list" {
    var n1 = LinkedList.Node{};
    var n2 = LinkedList.Node{};
    var l: LinkedList = undefined;
    l.init();

    try expect(l.popFront() == null);

    l.pushBack(&n1);
    l.pushBack(&n2);

    try expect(l.popFront() == &n1);
    try expect(l.popFront() == &n2);
    try expect(l.popFront() == null);
}
