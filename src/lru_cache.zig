const LinkedList = @import("linked_list.zig").LinkedList;
const HashTable = @import("hash_table.zig").HashTable;

pub const LRUNode = struct {
    ht_node: LinkedList.Node = .{},
    uid: i64 = 0,
    next: ?*LRUNode = null,
    prev: ?*LRUNode = null,

    pub fn removeFromQueue(self: *LRUNode) void {
        if (self.prev == null) return;

        self.prev.?.next = self.next;
        self.next.?.prev = self.prev;
        self.next = null;
        self.prev = null;
    }
};

const LRUQueue = struct {
    sentinel: LRUNode = undefined,

    pub fn init(self: *LRUQueue) void {
        self.sentinel.prev = &self.sentinel;
        self.sentinel.next = &self.sentinel;
    }

    pub fn enqueue(self: *LRUQueue, n: *LRUNode) void {
        if (n.next != null)
            n.removeFromQueue();

        n.prev = self.sentinel.prev;
        n.next = &self.sentinel;
        n.prev.?.next = n;
        n.next.?.prev = n;
    }

    pub fn dequeue(self: *LRUQueue) ?*LRUNode {
        var n = self.sentinel.next.?;
        if (n == &self.sentinel)
            return null;

        n.removeFromQueue();
        return n;
    }
};

pub fn LRUCache(comptime size: usize) type {
    comptime var ht_size = 1;
    comptime {
        while (ht_size + ht_size < size)
            ht_size += ht_size;
            
    }

    return struct {
        free: usize = size,
        table: HashTable(ht_size) = undefined,
        queue: LRUQueue = .{},

        pub fn init(self: *LRUCache(size)) void {
            self.table.init();
            self.queue.init();
        }

        pub fn get(self: *LRUCache(size), uid: i64) ?*LRUNode {
            var n = self.table.get(uid);
            if (n == null)
                return null;

            var lru = @ptrCast(*LRUNode, n.?);
            self.queue.enqueue(lru);
            return lru;
        }

        pub fn put(self: *LRUCache(size), n: *LRUNode, uid: i64) void {
            if (self.free == 0) {
                var lru = self.queue.dequeue().?;
                lru.ht_node.removeFromList();
            } else {
                self.free -= 1;
            }
            self.table.put(&n.ht_node, uid);
            self.queue.enqueue(n);
        }
    };
}

const expect = @import("std").testing.expect;
const print = @import("std").debug.print;
test "LRU queue" {
    var qn1 = LRUNode{};
    var qn2 = LRUNode{};
    var q = LRUQueue{};
    q.init();
    try expect(q.dequeue() == null);
    q.enqueue(&qn1);
    q.enqueue(&qn2);

    try expect(q.dequeue() == &qn1);
    try expect(q.dequeue() == &qn2);
    try expect(q.dequeue() == null);
}

test "LRU cache" {
    var cache = LRUCache(8){};
    cache.init();
    print("{*}\n", .{&cache});

    var cn1 = LRUNode{};
    var cn2 = LRUNode{};
    cache.put(&cn1, 1337);
    cache.put(&cn2, 1338);
    try expect(cache.get(1337) == &cn1);
    try expect(cache.get(1338) == &cn2);
}
