This repo was created to reproduce an issue I currently have with qemu. 

When executing the command: `/opt/qemu/bin/qemu-system-riscv32 -plugin /opt/qemu/plugins/plugins/libinsn.so -L /opt/riscv/riscv64-unknown-elf -nographic -machine spike -bios /work/main`.

I get the following crash:

```
0.275 **
0.275 ERROR:../tests/tcg/plugins/insn.c:97:vcpu_init: assertion failed: (count > 0)
0.275 Bail out! ERROR:../tests/tcg/plugins/insn.c:97:vcpu_init: assertion failed: (count > 0)
0.433 Aborted (core dumped)
```
