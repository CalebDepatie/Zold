// SPDX-FileCopyrightText: 2024 Caleb Depatie
//
// SPDX-License-Identifier: BSD-3-Clause

const std = @import("std");
const elf = @import("elf.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) {
            @panic("Leaked!");
        }
    }

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len != 2) {
        std.debug.print("Usage: zold <elf file>\n", .{});
        return;
    }

    const elf_file = try elf.parseELF64(args[1], &alloc);
    defer alloc.free(elf_file.program_headers);
    defer alloc.free(elf_file.section_headers);

    std.debug.print("hello world: {x}\n", .{elf_file.header.magic});
}
