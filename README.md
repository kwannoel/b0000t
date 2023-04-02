# Bootloader

A OS Bootloader for x86 machines.

See `shell.nix` for how to run.

## What is bootloader o.o

Software component just for starting up your computer, hand off the reins to your OS after.

## 2022-10-22 -- Bootloaders???

Interest in learning how everything works. Maybe one day I will explore hardware too.

There are two sorts of bootloaders.

### First stage bootloaders

Example here is the BIOS.
Bios will:
1. Receive a signal from **hardware**.
2. POST (does every device have right amount of power? Is memory corrupted?)
3. Initialize devices.

### Second stage bootloaders

BIOS boots into these.
Then these boot the OS.
May provide other utilities too around booting.

We will be writing one of these first, I think firmware bootloader (e.g. BIOS) too difficult, unable to find good references (so far...).
Maybe will write a embedded first stage bootloader next time.
Maybe x86 can try: https://www.seabios.org/Developer_Documentation too.

## 2022-10-22 -- Environment setup

- QEMU allows us to prototype our bootloader, before we actually try it out on bare metal.

### QEMU setup

We just want to boot into a x86 machine with seabios, and see if it works...
We use seabios in case we want to do stage one bootloader later,
seabios is open source.

## 2022-10-22 -- Why x86?

Well... this is just starting point, we can move on to other architectures.

## 2022-10-23 -- What's the process?

Some history is useful first. **We are booting via SeaBIOS, so following info may largely not apply to UEFI.**
1. BIOS originated in CP/M which was proprietary system.
2. Subsequent BIOS are adaptations of it, may not have a real spec.
3. Only one thing matters to us, which is when second-stage bootloader is called.
4. That happens after INTERRUPT signal (0x19) https://www.seabios.org/Execution_and_code_flow
5. Then it tries to find valid boot media.
6. This is done by looking through boot sectors of storage devices: https://en.wikipedia.org/wiki/Boot_sector
7. By convention (x86-CPUs use this for MBR), at the end of the boot sector, it is expected to see 0x55, 0xAA in first 512B block.
   Exact addresses of these bytes: 0x1FE, 0x1FF. https://en.wikipedia.org/wiki/Boot_sector
   From what I can infer, the development of BIOS went along with development of MBR.
   So these magic bytes originated in IBM PC DOS 2.0 (developed by msft).
   Seems like most docs out there rely on reverse engineering e.g. http://thestarman.narod.ru/asm/mbr/W7MBR.htm
   I don't think msft actually provided any official docs (please correct me if wrong).
8. Then, it is assumed that it contains Master Boot Record (MBR)
9. Copy the MBR execution code into memory at 0x7c00. See https://wiki.osdev.org/Boot_Sequence
10. Execute it.
   See https://en.wikipedia.org/wiki/Master_boot_record for layout.
   It executes in Real Mode:
   - https://wiki.osdev.org/BIOS
   - https://wiki.osdev.org/Real_Mode
   - https://github.com/coreboot/seabios/blob/master/docs/Memory_Model.md

## 2022-10-23 -- Implementation...

Just want a hello world bootloader first.
Some prerequisites:
- We need to specify execution mode (16-bit), so that assembly instructions we write can be serialized to 16-bit form.
  See: https://www.nasm.us/doc/nasmdoc7.html#section-7.1
- We need to offset all memory references by 0x7c00, since during execution that's where we start executing.
  We can use directive ORG for this.
- We need x86 assembly: https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
- We need interrupt calls: https://wiki.osdev.org/RBIL
- Easier reference: https://en.wikipedia.org/wiki/BIOS_interrupt_call
- Another good reference: https://wiki.osdev.org/BIOS
- Disclaimer: I'm writing this from scratch for learning,
  but I did skim through: https://www.viralpatel.net/taj/tutorial/hello_world_bootloader.php
  for a rough idea of what's needed.
  
### Implementation guides

Just a summary of resources above for easier reference.
  
- Assembler directives:
  - https://www.nasm.us/doc/nasmdoc7.html#section-7.1
  - (bin) https://www.nasm.us/doc/nasmdoc8.html#section-8.1.1
- x86 assembly (use the index):
  - https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
- We need interrupt calls:
  - https://wiki.osdev.org/BIOS
  - https://en.wikipedia.org/wiki/BIOS_interrupt_call
  - https://files.embeddedts.com//old/saved-downloads-manuals/EBIOS-UM.PDF
  - http://www.ctyme.com/intr/int.htm

Next few days (maybe?) start looking into how to move from bootloader to OS.

## 2022-10-29 -- Continuing

Continue, but instead of OS, maybe we shall try stage 1 bootloader first.

Goals:
- Find where we exec from for bios.
- Initialize hardware device for printing. (see seabios)
- Print to device.

What's going on with devices:
- https://www.qemu.org/2018/02/09/understanding-qemu-devices/
- https://wiki.osdev.org/System_Initialization_(x86)
   
### Other notes for UEFI

The discussion here is interesting, seems more high level for efi which looks for file systems instead:
https://unix.stackexchange.com/questions/677800/show-if-disk-or-partition-is-bios-bootable-or-uefi-bootable

## Misc resources

- intel x86: http://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf
- intel x86: https://www.viralpatel.net/taj/tutorial/booting.php
- embedded: https://interrupt.memfault.com/blog/how-to-write-a-bootloader-from-scratch

