pub const LinkedList = struct {
    pub const Node = struct {
        uid: i64 = 0,
        next: ?*Node = null,
        prev: ?*Node = null,

        pub fn removeFromList(self: *Node) void {
            if (self.prev == null) return;

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

    pub fn push_back(self: *LinkedList, n: *Node) void {
        if (n.next != null)
            n.removeFromList();

        n.prev = self.sentinel.prev;
        n.next = &self.sentinel;
        n.prev.?.next = n;
        n.next.?.prev = n;
    }

    pub fn pop_front(self: *LinkedList) ?*Node {
        var n = self.sentinel.next.?;
        if (n == &self.sentinel)
            return null;

        n.removeFromList();
        return n;
    }
};