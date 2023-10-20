package(default_visibility = ['//visibility:public'])

exports_files(glob(["bin/*"]))

filegroup(
    name = "compiler_pieces",
    srcs = glob([
        "arm-none-eabi/**",
        "lib/gcc/arm-none-eabi/**",
    ]),
)

filegroup(
    name = "compiler_files",
    srcs = [
        "bin/arm-none-eabi-gcc",
        ":compiler_pieces",
    ] 
)

filegroup(
    name = "linker_files",
    srcs = [
        "bin/arm-none-eabi-gcc",
        "bin/arm-none-eabi-ld",
        ":compiler_pieces",
    ]
)   