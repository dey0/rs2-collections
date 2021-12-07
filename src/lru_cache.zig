const LinkedList = @import("linked_list.zig").LinkedList;
const HashTable = @import("hash_table.zig").HashTable;

pub const LRUNode = struct {
    ht_node: LinkedList.Node = .{},
    uid: i64 = 0,
    next: ?*LRUNode = null,
    prev: ?*LRUNode = null,

    pub fn removeFromQueue(self: *LRUNode) void {
        if (self.prev == null)
            return;

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

    pub fn push(self: *LRUQueue, n: *LRUNode) void {
        if (n.next != null)
            n.removeFromQueue();

        n.prev = self.sentinel.prev;
        n.next = &self.sentinel;
        n.prev.?.next = n;
        n.next.?.prev = n;
    }

    pub fn pop(self: *LRUQueue) ?*LRUNode {
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

        const Self = @This();

        pub fn init(self: *Self) void {
            self.table.init();
            self.queue.init();
        }

        pub fn get(self: *Self, uid: i64) ?*LRUNode {
            var n = self.table.get(uid) orelse return null;
            var lru = @ptrCast(*LRUNode, n);
            self.queue.push(lru);
            return lru;
        }

        pub fn put(self: *Self, n: *LRUNode, uid: i64) void {
            if (self.free == 0) {
                var lru = self.queue.pop().?;
                lru.ht_node.removeFromList();
            } else {
                self.free -= 1;
            }
            self.table.put(&n.ht_node, uid);
            self.queue.push(n);
        }

        pub fn clear(self: *Self) void {
            self.free = size;
            while (self.queue.pop()) |lru|
                lru.ht_node.removeFromList();
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
    try expect(q.pop() == null);
    q.push(&qn1);
    q.push(&qn2);

    try expect(q.pop() == &qn1);
    try expect(q.pop() == &qn2);
    try expect(q.pop() == null);
}

test "LRU cache" {
    const size = 8;
    var cache = LRUCache(size){};
    cache.init();

    var cn1 = LRUNode{};
    var cn2 = LRUNode{};
    print("Node 1: {*} Node 2: {*}\n", .{ &cn1.ht_node, &cn2.ht_node });
    cache.put(&cn1, 1337);
    cache.put(&cn2, 1338);
    try expect(cache.get(1337) == &cn1);
    try expect(cache.get(1338) == &cn2);

    print("Clearing cache...\n", .{});
    cache.clear();

    try expect(cache.get(1337) == null);
    try expect(cache.get(1338) == null);
    try expect(cache.free == size);
}
