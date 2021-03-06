const LinkedList = @import("linked_list.zig").LinkedList;

pub fn HashTable(comptime size: usize) type {
    return struct {
        buckets: [size]LinkedList = [size].{},

        const Self = @This();

        pub fn init(self: *Self) void {
            for (self.buckets) |*bucket|
                bucket.init();
        }

        pub fn get(self: *Self, uid: i64) ?*LinkedList.Node {
            var list = &self.buckets[@intCast(usize, uid) & size - 1];

            var it = list.sentinel.next.?;
            while (it != &list.sentinel) {
                if (it.uid == uid)
                    return it;

                it = it.next.?;
            }

            return null;
        }

        pub fn put(self: *Self, n: *LinkedList.Node, uid: i64) void {
            var list = &self.buckets[@intCast(usize, uid) & size - 1];
            list.pushBack(n);

            n.uid = uid;
        }
    };
}

const expect = @import("std").testing.expect;
const print = @import("std").debug.print;
test "Hash table" {
    const size = 8;
    var n1 = LinkedList.Node{};
    var n2 = LinkedList.Node{};
    var ht: HashTable(size) = undefined;
    ht.init();
    try expect(ht.get(37) == null);
    ht.put(&n1, 37);
    ht.put(&n2, 76);
    try expect(ht.get(37) == &n1);
    try expect(ht.get(76) == &n2);

    n1.removeFromList();
    n2.removeFromList();

    try expect(ht.get(37) == null);
}
