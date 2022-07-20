const std = @import("std");
const fs = std.fs;

fn cat(w: anytype, r: anytype) !void {
    var buf: [std.mem.page_size]u8 = undefined;
    while (true) {
        var nread = try r.read(buf[0..]);
        if (nread <= 0) break;
        try w.writeAll(buf[0..nread]);
    }
}

pub fn main() anyerror!void {
    var a = std.heap.page_allocator;

    var args = try std.process.argsAlloc(a);
    defer a.free(args);

    const writer = std.io.getStdOut().writer();
    if (args.len > 1) {
        for (args[1..args.len]) |arg| {
            var f = try fs.cwd().openFile(arg, fs.File.OpenFlags{ .mode = .read_only });
            defer f.close();
            cat(writer, f) catch |err| {
                std.log.warn("error reading file '{s}': {}\n", .{ arg, err });
            };
        }
    } else {
        cat(writer, std.io.getStdIn().reader()) catch |err| {
            std.log.warn("error reading stdin: {}\n", .{err});
        };
    }
}
