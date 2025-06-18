# FBoot
Extraordinarily simple real mode bootloader written in NASM for x86 BIOS. 

FBoot sets up a basic and safe environment, loads the specified sector amount, and jumps to the raw loaded segment.

I do not suggest using FBoot for any serious production projects, this is primarily educational.

## Usage

- Building on a UNIX-like operating system like Linux is strongly recommended.
- Ensure you have [Git](https://git-scm.com/downloads), [GNU Make](https://www.gnu.org/software/make/#download), and [Nasm](https://www.nasm.us/pub/nasm/releasebuilds/) installed on your system.
- Clone the repository: `git clone https://github.com/FeltMacaroon389/FBoot.git`
- Move into the cloned directory: `cd FBoot`
- Run `make` to build the output image. By default, this will be located in `bin/fboot.bin`
- To use with your kernel, ensure it is assembled as a raw binary. Then, concatenate your FBoot binary with your kernel, placing FBoot first.
- For example, if your FBoot binary is named `fboot.bin` and your kernel source file is named `kernel.asm` and written with NASM syntax:
    - `nasm -f bin -o kernel.bin kernel.asm`
    - `cat fboot.bin kernel.bin > boot.img`
- This will produce a bootable image at `boot.img`
- If you wish for your kernel to return, it's important to use the `retf` instruction instead of normal `ret`

## Supported languages
Currently, only binaries assembled directly from assembly language is supported.
However, higher-level languages like C *may* work, provided it's compiled to a raw binary and that there are no additional files or headers included above the entrypoint.

## License
FBoot is licensed under the **GNU GPLv3** license.
For more information, see the `LICENSE` file in the root directory.

