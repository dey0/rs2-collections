const LinkedList = @import("linked_list.zig").LinkedList;

pub fn HashTable(comptime size: usize) type {
    return struct {
        buckets: [size]LinkedList = [size].{},

        pub fn init(self: *HashTable(size)) void {
            for (self.buckets) |*el|
                el.init();
        }

        pub fn get(self: *HashTable(size), uid: i64) ?*LinkedList.Node {
            var list = self.buckets[@intCast(usize, uid) & size - 1];

            var n = list.sentinel.next.?;
            while (n != &list.sentinel) {
                if (n.uid == uid)
                    return n;

                n = n.next.?;
            }
            return null;
        }

        pub fn put(self: *HashTable(size), n: *LinkedList.Node, uid: i64) void {
            var list = self.buckets[@intCast(usize, uid) & size - 1];
            list.pushBack(n);

            n.uid = uid;
        }
    };
}
