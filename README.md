# cat clone

The goal of this project was to recreate the GNU [cat](https://www.gnu.org/software/coreutils/cat) command in assembly language (x86_64) without access to [libc](https://en.wikipedia.org/wiki/C_standard_library) and using only stack allocations.

## Requirements

- Linux x86_64
- [nasm](https://www.nasm.us/)
- ld

## Build

```sh
./build.sh
./cat --help
```
