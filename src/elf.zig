// SPDX-FileCopyrightText: 2024 Caleb Depatie
//
// SPDX-License-Identifier: BSD-3-Clause

const std = @import("std");

const elf_endian = enum (u8) {
    none,
    little,
    big
};

const elf_class = enum (u8) {
    none,
    elf32,
    elf64
};

const elf_header = packed struct {
    magic: u32,
    class: elf_class,
    endianness: elf_endian,
    ei_version: u8,
    os_abi: u8,
    abi_version: u8,
    padding: u56,
    elf_type: u16,
    machine: u16,
    e_version: u32,
    entry_point: u64,
    program_header_offset: u64,
    section_header_offset: u64,
    flags: u32,
    header_size: u16,
    program_header_entry_size: u16,
    program_header_entry_count: u16,
    section_header_entry_size: u16,
    section_header_entry_count: u16,
    section_header_name_table_index: u16,
};

fn parseHeader(elf_header_bytes: [0x40] u8) elf_header {
    var header: elf_header = @bitCast(elf_header_bytes);
    return header;
}

test "elf header" {
    try std.testing.expectEqual(@sizeOf(elf_header), 0x40);

    const example_header = [0x40] u8 {
        0x7f, 0x45, 0x4c, 0x46, 0x02, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x3e, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd8, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x0d, 0x00, 0x0c, 0x00,
    };
    
    const header = parseHeader(example_header);

    try std.testing.expectEqual(header.magic, 
        @as(u32, @bitCast([4]u8{0x7f, 'E', 'L', 'F'})),
    );

    try std.testing.expectEqual(header.class, .elf64);
    try std.testing.expectEqual(header.endianness, .little);
    try std.testing.expectEqual(header.ei_version, 1);
    try std.testing.expectEqual(header.os_abi, 0x0);
    try std.testing.expectEqual(header.padding, 0x0);
}

const elf_program_header = struct {
    segment_type: u32,
    segment_flags: u32,
    segment_offset: u64,
    segment_virtual_address: u64,
    segment_physical_address: u64,
    segment_file_size: u64,
    segment_memory_size: u64,
    segment_alignment: u64,
};

fn parseProgramHeader(elf_program_bytes: [0x38] u8) elf_program_header {
    var header: elf_program_header = @bitCast(elf_program_bytes);
    return header;
}

test "program header" {
    try std.testing.expectEqual(@sizeOf(elf_program_header), 0x38);
}

const elf_section_header = struct {
    section_name: u32,
    section_type: u32,
    section_flags: u64,
    section_virtual_address: u64,
    section_offset: u64,
    section_size: u64,
    section_link: u32,
    section_info: u32,
    section_address_alignment: u64,
    section_entry_size: u64,
};

test "section header" {
    try std.testing.expectEqual(@sizeOf(elf_section_header), 0x40);
}

fn parseSectionHeader(elf_section_bytes: [0x40] u8) elf_section_header {
    var header: elf_section_header = @bitCast(elf_section_bytes);
    return header;
}

const elf64 = struct {
    header: elf_header,
    program_headers: [] elf_program_header,
    section_headers: [] elf_section_header,
};

pub fn parseELF64(filename: []const u8, alloc: *std.mem.Allocator) !elf64 {
    
    var header: elf_header = undefined;

    var program_headers: [] elf_program_header = undefined;
    program_headers = try alloc.alloc(elf_program_header, 4);

    var section_headers: [] elf_section_header = undefined;
    section_headers = try alloc.alloc(elf_section_header, 4);

    const obj_file = try std.fs.cwd().openFile(filename, .{});
    defer obj_file.close();

    var buf_reader = std.io.bufferedReader(obj_file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(alloc.*);
    defer line.deinit();

    // Read the elf header first
    var header_bytes: [0x40] u8 = undefined;

    const num_read = try reader.read(&header_bytes);

    if (num_read != 0x40) {
        return error.elf_file_too_small;
    }

    return elf64 {
        .header = header,
        .program_headers = program_headers,
        .section_headers = section_headers,
    };

}