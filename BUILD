package(default_visibility = ["//visibility:public"])
load("//arm-none-eabi:toolchain.bzl", "arm_none_eabi_toolchain")

platform(
    name = "arm",
    constraint_values = [
        "@platforms//cpu:arm",
        "@platforms//os:none",
    ],
)

arm_none_eabi_toolchain(
    name = "arm_none_eabi",
)

cc_library(
    name = "s",
    srcs = [":startup_stm32f429_439xx.s"],
)

cc_library(
    name = "S",
    srcs = [":startup_stm32f429_439xx.S"],
)