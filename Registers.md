# x86/x64 Assembly Reference for Reverse Engineering

A study reference covering CPU registers and common instructions. Useful when reading disassembly in tools like IDA, Ghidra, x64dbg, or GDB.

---

## 1. General Purpose Registers

On x86 (32-bit) and x64 (64-bit), registers are nested: the smaller registers are sub-parts of the larger ones. Writing to a 32-bit register (e.g. `eax`) on x64 zero-extends into the full 64-bit register (`rax`).

### Register Size Map

| 64-bit | 32-bit | 16-bit | 8-bit (high) | 8-bit (low) | Typical Purpose |
|---|---|---|---|---|---|
| RAX | EAX | AX | AH | AL | Accumulator (return values, arithmetic) |
| RBX | EBX | BX | BH | BL | Base register (general use / preserved) |
| RCX | ECX | CX | CH | CL | Counter (loops, shifts) |
| RDX | EDX | DX | DH | DL | Data (I/O, multiply/divide high bits) |
| RSI | ESI | SI | — | SIL | Source Index (string/memory ops) |
| RDI | EDI | DI | — | DIL | Destination Index (string/memory ops) |
| RBP | EBP | BP | — | BPL | Base Pointer (stack frame base) |
| RSP | ESP | SP | — | SPL | Stack Pointer (top of stack) |

> Note: `AH/BH/CH/DH` (high byte) only exist for the original four registers and cannot be mixed with REX-prefixed instructions. `SIL/DIL/BPL/SPL` are only accessible in 64-bit mode.

### x64 Extended Registers (R8–R15)

x64 added eight new general-purpose registers. Each has 32-, 16-, and 8-bit sub-views.

| 64-bit | 32-bit | 16-bit | 8-bit | Purpose |
|---|---|---|---|---|
| R8  | R8D  | R8W  | R8B  | General purpose / argument passing |
| R9  | R9D  | R9W  | R9B  | General purpose / argument passing |
| R10 | R10D | R10W | R10B | General purpose / temporary |
| R11 | R11D | R11W | R11B | General purpose / temporary |
| R12 | R12D | R12W | R12B | General purpose (preserved) |
| R13 | R13D | R13W | R13B | General purpose (preserved) |
| R14 | R14D | R14W | R14B | General purpose (preserved) |
| R15 | R15D | R15W | R15B | General purpose (preserved) |

### Instruction Pointer

| 64-bit | 32-bit | 16-bit | Purpose |
|---|---|---|---|
| RIP | EIP | IP | Instruction Pointer — address of the next instruction to execute |

You cannot write to RIP/EIP directly; control flow instructions (`jmp`, `call`, `ret`) change it.

---

## 2. Segment Registers

Mostly legacy, but `FS`/`GS` are still used (e.g. thread-local storage, stack canaries).

| Register | Name | Purpose |
|---|---|---|
| CS | Code Segment | Points to the code segment |
| DS | Data Segment | Default data segment |
| SS | Stack Segment | Stack segment |
| ES | Extra Segment | Extra data segment (string ops) |
| FS | — | Often thread-local storage / TEB (Windows) |
| GS | — | Often thread-local storage / PEB (x64 Windows), per-CPU data (Linux kernel) |

---

## 3. The Flags Register (RFLAGS / EFLAGS)

A single register holding status bits set by arithmetic/logic instructions. Conditional jumps read these flags.

### Status Flags (most important for RE)

| Flag | Name | Set when... |
|---|---|---|
| CF | Carry Flag | Unsigned overflow / borrow occurred |
| PF | Parity Flag | Low byte of result has even number of set bits |
| AF | Auxiliary Carry | Carry/borrow between bit 3 and 4 (BCD math) |
| ZF | Zero Flag | Result was zero (very common in comparisons) |
| SF | Sign Flag | Result is negative (top bit set) |
| OF | Overflow Flag | Signed overflow occurred |

### Control Flags

| Flag | Name | Meaning |
|---|---|---|
| TF | Trap Flag | Single-step debugging |
| IF | Interrupt Flag | Interrupts enabled |
| DF | Direction Flag | String ops direction (0 = up, 1 = down) |

---

## 4. Calling Conventions (who passes args where)

Knowing where arguments live is essential when reversing function calls.

### x64 — System V (Linux, macOS)

| Argument | Register |
|---|---|
| 1st | RDI |
| 2nd | RSI |
| 3rd | RDX |
| 4th | RCX |
| 5th | R8 |
| 6th | R9 |
| Return value | RAX (and RDX for 128-bit) |

### x64 — Microsoft (Windows)

| Argument | Register |
|---|---|
| 1st | RCX |
| 2nd | RDX |
| 3rd | R8 |
| 4th | R9 |
| 5th+ | Stack |
| Return value | RAX |

### x86 (32-bit) — cdecl / stdcall

Arguments are pushed onto the **stack** (right to left). Return value in **EAX**. In `cdecl` the caller cleans the stack; in `stdcall` the callee does.