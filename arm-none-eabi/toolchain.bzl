load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "tool",
    "feature",
    "flag_group",
    "flag_set",
)

all_link_actions = [ 
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]


def _impl(ctx):
    include_flags = [
        "-isystem",
        "external/{}/arm-none-eabi/include".format(ctx.attr.gcc_repo),
        "-isystem",
        "external/{}/lib/gcc/arm-none-eabi/{}/include".format(ctx.attr.gcc_repo, ctx.attr.gcc_version),
        "-isystem",
        "external/{}/lib/gcc/arm-none-eabi/{}/include-fixed".format(ctx.attr.gcc_repo, ctx.attr.gcc_version),
        "-isystem",
        "external/{}/arm-none-eabi/include/c++/{}/".format(ctx.attr.gcc_repo, ctx.attr.gcc_version),
        "-isystem",
        "external/{}/arm-none-eabi/include/c++/{}/arm-none-eabi/".format(ctx.attr.gcc_repo, ctx.attr.gcc_version),
    ]

    features = [
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-specs=nano.specs",
                                "-Wl,--undefined=_write",
                                "-Wl,--gc-sections",
                                "-lc",
                                "-lm",
                                "-lnosys",
                                "-u",
                                "_printf_float",
                                "-Og",
                                "-g",
                                "-gdwarf-2",
                                "-mcpu=cortex-m4",
                                "-mthumb",
                                "-mfpu=fpv4-sp-d16",
                                "-mfloat-abi=hard",
                            ]
                        ),
                    ])
                )
            ]
        ),
        feature(
        name = "compiler_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(flags = [
                        "-Wall",
                        "-Werror=switch",
                        "-Werror=implicit-function-declaration",
                        "-fdata-sections",
                        "-ffunction-sections",
                        "-Os",
                        "-g",
                        "-gdwarf-2",
                        "-mcpu=cortex-m4",
                        "-mthumb",
                        "-mfpu=fpv4-sp-d16",
                        "-mfloat-abi=hard",
                    ]),
                    flag_group(flags=include_flags)
                ],
            ),
        ],
    )
    ]


    action_configs = [
        action_config(
            action_name = ACTION_NAMES.preprocess_assemble,
            tools = [
                struct(
                    type_name = "tool",
                    tool = ctx.file.gcc,
                )
            ]
        ),
        action_config(
            action_name = ACTION_NAMES.assemble,
            tools = [
                struct(
                    type_name = "tool",
                    tool = ctx.file.gcc,
                )
            ]
        ),
        action_config(
            action_name = ACTION_NAMES.c_compile,
            tools = [
                struct(
                    type_name = "tool",
                    tool = ctx.file.gcc,
                )
            ]
        ),
        action_config(
            action_name = ACTION_NAMES.cpp_compile,
            tools = [
                struct(
                    type_name = "tool",
                    tool = ctx.file.gcc,
                )
            ]
        ),
        action_config(
            action_name = ACTION_NAMES.cpp_link_executable,
            tools = [
                struct(
                    type_name = "tool",
                    tool = ctx.file.gcc,
                )
            ]
        ),
        action_config(
            action_name = ACTION_NAMES.cpp_link_static_library,
            tools = [
                struct(
                    type_name = "tool",
                    tool = ctx.file.ar,
                )
            ],
            flag_sets = [
                flag_set(
                    flag_groups = [
                        flag_group(flags = [
                            "rcs",
                            "%{output_execpath}",
                        ]),
                        flag_group(
                            iterate_over = "libraries_to_link",
                            flags = [
                                "%{libraries_to_link.name}",
                            ],
                        ),
                    ],
                ),
            ],
        ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        action_configs = action_configs,
        features = features,
        toolchain_identifier = "arm-none-eabi_linux_x86_64",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "armeabi-v7a",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
    )

cc_arm_none_eabi_config = rule(
    implementation = _impl,
    attrs = {
        "toolchain_identifier": attr.string(default = ""),
        "host_system_name": attr.string(default = ""),
        "wrapper_path": attr.string(default = ""),
        "wrapper_ext": attr.string(default = ""),
        "gcc_repo": attr.string(default = ""),
        "gcc_version": attr.string(default = ""),
        "gcc": attr.label(default="@arm_none_eabi_linux_x86_64//:bin/arm-none-eabi-gcc", allow_single_file=True),
        "ar": attr.label(default="@arm_none_eabi_linux_x86_64//:bin/arm-none-eabi-ar", allow_single_file=True),
    },
    provides = [CcToolchainConfigInfo],
)


def objcopy(input, output, format):
    native.genrule(
        name = input + "rule",
        srcs = [input],
        outs = [output],
        cmd = "$(location @arm_none_eabi_linux_x86_64//:bin/arm-none-eabi-objcopy) -O " + format + " -S $(SRCS) $(OUTS)",
        tools = ["@arm_none_eabi_linux_x86_64//:bin/arm-none-eabi-objcopy"],
    )

def arm_none_eabi_toolchain(name):
    config = name + "_config"
    cc_toolchain = "arm_none_eabi_toolchain_" + name
    compiler = "arm_none_eabi_linux_x86_64"

    cc_arm_none_eabi_config(
        name = config,
        gcc_repo = compiler,
        gcc_version = "10.2.1",
        host_system_name = "linux_x86_64",
        toolchain_identifier = "arm_none_eabi_linux_x86_64",
        wrapper_path = "arm-none-eabi",
    )

    native.cc_toolchain(
        name = cc_toolchain,
        all_files = ":empty", 
        ar_files = "@arm_none_eabi_linux_x86_64//:bin/arm-none-eabi-ar",
        compiler_files = "@arm_none_eabi_linux_x86_64//:compiler_files",
        dwp_files = ":empty",
        linker_files = "@arm_none_eabi_linux_x86_64//:linker_files",
        objcopy_files = ":empty", 
        strip_files = ":empty",
        supports_param_files = 0,
        toolchain_config = config,
        toolchain_identifier = "arm_none_eabi_" + name + "_on_linux_x86_64",
    )

    native.toolchain(
        name = name,
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:none",
            "@platforms//cpu:arm",
        ],
        toolchain = cc_toolchain,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
