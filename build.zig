const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zig-testing", "src/lru_cache.zig");
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.install();

    var list_tests = b.addTest("src/linked_list.zig");
    list_tests.setTarget(target);
    list_tests.setBuildMode(mode);

    var ht_tests = b.addTest("src/hash_table.zig");
    ht_tests.setTarget(target);
    ht_tests.setBuildMode(mode);

    var cache_tests = b.addTest("src/lru_cache.zig");
    cache_tests.setTarget(target);
    cache_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&list_tests.step);
    test_step.dependOn(&ht_tests.step);
    test_step.dependOn(&cache_tests.step);
}
