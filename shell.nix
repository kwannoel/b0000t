{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    qemu
    nasm
  ];
  shellHook= ''
    QEMU_BIN_PATH=${pkgs.qemu}/bin
    qemu() { $QEMU_BIN_PATH/qemu-x86_64 $@; }

    # use this to boot seabios
    qemu-sys() { $QEMU_BIN_PATH/qemu-system-x86_64 $@; }
    compile() { nasm -f bin hello-world-bootloader.asm -o hello-world.bin; }
    boot() { qemu-sys -drive file=hello-world.bin,format=raw,index=0,media=disk; }
  '';
}
