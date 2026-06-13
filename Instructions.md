# x86/x64 Assembly Reference for Reverse Engineering

A study reference covering CPU registers and common instructions. Useful when reading disassembly in tools like IDA, Ghidra, x64dbg, or GDB.

---
## Common Instructions

### Data Movement

| Instruction | Meaning | Example |
|---|---|---|
| `mov` | Copy data from source to destination | `mov eax, ebx` |
| `movzx` | Move with zero-extension | `movzx eax, bl` |
| `movsx` | Move with sign-extension | `movsx eax, bl` |
| `lea` | Load Effective Address (compute address, don't deref) | `lea rax, [rbx+rcx*4]` |
| `xchg` | Exchange two operands | `xchg eax, ebx` |
| `push` | Push value onto the stack | `push rax` |
| `pop` | Pop value off the stack | `pop rax` |
| `cmov` | Conditional move (e.g. `cmove`, `cmovne`) | `cmovz eax, ebx` |

### Arithmetic

| Instruction | Meaning | Example |
|---|---|---|
| `add` | Addition | `add eax, 5` |
| `sub` | Subtraction | `sub eax, ebx` |
| `inc` | Increment by 1 | `inc ecx` |
| `dec` | Decrement by 1 | `dec ecx` |
| `mul` | Unsigned multiply | `mul ebx` |
| `imul` | Signed multiply | `imul eax, ebx` |
| `div` | Unsigned divide | `div ebx` |
| `idiv` | Signed divide | `idiv ebx` |
| `neg` | Two's-complement negation | `neg eax` |

### Logic & Bitwise

| Instruction | Meaning | Example |
|---|---|---|
| `and` | Bitwise AND | `and eax, 0xFF` |
| `or` | Bitwise OR | `or eax, ebx` |
| `xor` | Bitwise XOR (often used to zero a register) | `xor eax, eax` |
| `not` | Bitwise NOT | `not eax` |
| `shl` / `sal` | Shift left | `shl eax, 2` |
| `shr` | Logical shift right | `shr eax, 2` |
| `sar` | Arithmetic shift right (keeps sign) | `sar eax, 2` |
| `rol` / `ror` | Rotate left / right | `rol al, 4` |
| `bt` / `bts` / `btr` | Bit test / set / reset | `bt eax, 3` |

### Comparison & Test

| Instruction | Meaning | Example |
|---|---|---|
| `cmp` | Compare (does a subtraction, sets flags only) | `cmp eax, ebx` |
| `test` | Bitwise AND, sets flags only (e.g. check if zero) | `test eax, eax` |

### Control Flow — Unconditional

| Instruction | Meaning | Example |
|---|---|---|
| `jmp` | Unconditional jump | `jmp 0x401000` |
| `call` | Call a function (pushes return address) | `call func` |
| `ret` | Return from function (pops return address) | `ret` |
| `leave` | Restore stack frame (`mov rsp, rbp; pop rbp`) | `leave` |
| `nop` | No operation (padding / patching) | `nop` |

### Control Flow — Conditional Jumps

These read the flags set by the previous `cmp`/`test`. Many are aliases (e.g. `je` == `jz`).

| Instruction | Jumps if | Based on flag |
|---|---|---|
| `je` / `jz` | Equal / Zero | ZF = 1 |
| `jne` / `jnz` | Not Equal / Not Zero | ZF = 0 |
| `jg` / `jnle` | Greater (signed) | ZF=0 and SF=OF |
| `jge` / `jnl` | Greater or Equal (signed) | SF = OF |
| `jl` / `jnge` | Less (signed) | SF ≠ OF |
| `jle` / `jng` | Less or Equal (signed) | ZF=1 or SF≠OF |
| `ja` / `jnbe` | Above (unsigned) | CF=0 and ZF=0 |
| `jae` / `jnb` / `jnc` | Above or Equal (unsigned) | CF = 0 |
| `jb` / `jnae` / `jc` | Below (unsigned) | CF = 1 |
| `jbe` / `jna` | Below or Equal (unsigned) | CF=1 or ZF=1 |
| `js` | Sign (negative) | SF = 1 |
| `jns` | Not Sign (positive) | SF = 0 |
| `jo` / `jno` | Overflow / No Overflow | OF |
| `jc` / `jnc` | Carry / No Carry | CF |

> **Tip:** signed comparisons use g/l (greater/less), unsigned use a/b (above/below). Spotting which one the compiler chose tells you the variable's signedness.

### Stack Frame Setup (function prologue/epilogue)

| Pattern | Meaning |
|---|---|
| `push rbp` / `mov rbp, rsp` | Standard prologue — save & set up base pointer |
| `sub rsp, N` | Allocate N bytes of local stack space |
| `mov rsp, rbp` / `pop rbp` | Epilogue — tear down frame |
| `leave` | Shortcut for the epilogue above |

### String / Memory Instructions

| Instruction | Meaning |
|---|---|
| `movs` (movsb/w/d/q) | Move string data (RSI → RDI) |
| `stos` (stosb/w/d/q) | Store value (RAX) to [RDI] |
| `lods` (lodsb/w/d/q) | Load [RSI] into RAX |
| `scas` (scasb/w/d/q) | Scan string, compare with RAX |
| `cmps` (cmpsb/w/d/q) | Compare two strings |
| `rep` / `repe` / `repne` | Repeat prefix (uses RCX as counter) |

### System / Misc

| Instruction | Meaning |
|---|---|
| `syscall` | Invoke a kernel system call (x64 Linux) |
| `int` | Software interrupt (e.g. `int 0x80` on 32-bit Linux, `int3` = breakpoint) |
| `cpuid` | Query CPU information |
| `rdtsc` | Read timestamp counter (anti-debug / timing) |
| `cld` / `std` | Clear / set direction flag |