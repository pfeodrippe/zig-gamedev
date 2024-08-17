const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const enable = b.option(bool, "enable", "enable zpix") orelse false;
    const options = .{
        .enable = enable,
        .path = b.option([]const u8, "path", "installed pix path") orelse if (enable) @panic("PIX path is required when enabled") else "",
    };

    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }

    const options_module = options_step.createModule();

    const zwin32 = b.dependency("zwin32", .{
        .target = target,
    });
    const zwin32_module = zwin32.module("root");

    _ = b.addModule("root", .{
        .root_source_file = b.path("src/zpix.zig"),
        .imports = &.{
            .{ .name = "zpix_options", .module = options_module },
            .{ .name = "zwin32", .module = zwin32_module },
        },
    });
}
