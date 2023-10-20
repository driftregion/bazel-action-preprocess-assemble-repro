```sh
bazel build --config=arm //:s 
```

fails with `src/main/tools/linux-sandbox-pid1.cc:518: "execvp(external/arm_none_eabi_linux_x86_64/bin/arm-none-eabi-gcc, 0x2326130)": No such file or directory`


```sh
bazel build --config=arm //:S
```

is OK 

