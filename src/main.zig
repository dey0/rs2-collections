const LinkedList = @import("linked_list.zig").LinkedList;
const LRUCache = @import("lru_cache.zig").LRUCache;
const LRUNode = @import("lru_cache.zig").LRUNode;

const assert = @import("std").debug.assert;
const print = @import("std").debug.print;
pub fn main() void {
    var n1 = LinkedList.Node{};
    var n2 = LinkedList.Node{};
    var l: LinkedList = undefined;
    l.init();
    l.push_back(&n1);
    l.push_back(&n2);

    assert(l.pop_front()==&n1);
    assert(l.pop_front()==&n2);
    assert(l.pop_front()==null);

    var cache = LRUCache(8){};
    cache.init();
    print("{*}\n", .{&cache});

    var cn1 = LRUNode{};
    var cn2 = LRUNode{};
    cache.put(&cn1, 1337);
    cache.put(&cn2, 1338);
    assert(cache.get(1337)==&cn1);
    assert(cache.get(1338)==&cn2);
}
