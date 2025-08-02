FROM ubuntu
RUN apt update
RUN apt install -y autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev  \
    libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev  \
    ninja-build git cmake libglib2.0-dev libslirp-dev git
WORKDIR /work
RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain
RUN mkdir riscv-gnu-toolchain/build
WORKDIR /work/riscv-gnu-toolchain/build

RUN ../configure --prefix=/opt/riscv  \
    --with-cmodel=medany  \
    --with-multilib-generator="\
    rv32im-ilp32--;"
RUN make -j8
ARG QEMU_VERSION="9.2.2"
ENV QEMU_RELEASE="https://github.com/qemu/qemu/archive/refs/tags/v$QEMU_VERSION.tar.gz"
WORKDIR /qemu
RUN curl -L $QEMU_RELEASE | tar -xvz --strip-components=1
WORKDIR /qemu/build
RUN ../configure --prefix=/opt/qemu --target-list=riscv32-softmmu
RUN make -j $(nproc)
RUN make install
RUN mkdir /opt/qemu/plugins && cp -r /qemu/build/tests/tcg/plugins /opt/qemu/plugins
COPY init.S /work/init.S
COPY link.ld /work/link.ld
COPY main.c /work/main.c
RUN /opt/riscv/bin/riscv64-unknown-elf-gcc -S -c -march=rv32im -mabi=ilp32 /work/main.c -o /work/main.s
RUN /opt/riscv/bin/riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -static -nostartfiles -T/work/link.ld  /work/main.s /work/init.S -o /work/main 
RUN /opt/qemu/bin/qemu-system-riscv32 -plugin /opt/qemu/plugins/plugins/libinsn.so -L /opt/riscv/riscv64-unknown-elf -nographic -machine spike -bios /work/main
