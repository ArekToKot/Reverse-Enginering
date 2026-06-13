# Comprehensive RE Tools — In-Depth Guide

A focused deep-dive on the **four heavyweight free tools** that form a complete reverse engineering setup. Two for **static** analysis (read the code), two for **dynamic** analysis (run and observe it), split across Windows and Linux.

| | Static (read code) | Dynamic (run & inspect) |
|---|---|---|
| **Windows** | Ghidra | x64dbg |
| **Linux** | Ghidra / Cutter | GDB + pwndbg |

> **Mental model:** Static tools show you the *whole map* of the program at rest. Dynamic tools let you *drive through it* and see real values. You constantly switch between them.

---

# Ghidra (Static + Decompiler)

The flagship free tool — works the same on Windows and Linux. Disassembles a binary and produces readable **pseudo-C**.

## Core Concepts
- **Project** — a container for one or more binaries. Created once, reused.
- **CodeBrowser** — the main analysis window (listing + decompiler + symbol tree).
- **Listing view** — the disassembly (assembly instructions, addresses, comments).
- **Decompiler view** — auto-generated C-like code (the killer feature).
- **Auto-analysis** — Ghidra's first pass that finds functions, strings, references.

## First-Time Workflow
1. **File → New Project** → Non-Shared Project → name it.
2. **File → Import File** → select your binary → OK.
3. Double-click the imported file to open **CodeBrowser**.
4. On the "analyze now?" prompt, click **Yes** and accept the default analyzers.
5. Wait for analysis to finish (bottom-right progress bar).

## Key Windows / Panels
| Panel | What it shows |
|---|---|
| **Symbol Tree** (left) | Functions, labels, imports, exports |
| **Listing** (center) | Disassembly with addresses |
| **Decompiler** (right) | Pseudo-C of the selected function |
| **Defined Strings** | All strings (Window → Defined Strings) |
| **Function Graph** | Visual control-flow graph of a function |

## Essential Shortcuts
| Key | Action |
|---|---|
| `G` | Go to an address or symbol |
| `L` | Rename a variable/function/label |
| `;` | Add a comment |
| `Ctrl+Shift+E` | Edit function signature |
| Double-click | Follow a reference / jump to function |
| `Ctrl+Shift+G` (or right-click → References) | Find references to current item |
| Space | Toggle listing ↔ graph view |

## Practical Example — Find a License Check
1. **Window → Defined Strings**, find `"Invalid license key"`.
2. Double-click it → you jump to it in the Listing.
3. Right-click the string's address → **References → Show References to Address**.
4. Double-click the reference → you land in the function that prints it.
5. Read the **Decompiler** panel:
   ```c
   if (check_key(input) == 0)
       puts("Invalid license key");
   else
       puts("Access granted");
   ```
6. Double-click `check_key` to read the validation logic. Press `L` to rename variables as you understand them (e.g. `iVar1` → `keyLength`).

## Pro Tips
- **Rename aggressively** (`L`). Turning `FUN_00401abc` into `validate_password` makes the whole binary readable.
- **Retype variables** — if Ghidra shows `undefined4` but it's really a pointer, right-click → Retype for cleaner output.
- **Bookmarks** (`Ctrl+D`) mark interesting spots to return to.
- The decompiler isn't perfect — when it looks wrong, drop into the **Listing** to read the real assembly.

---

# x64dbg (Dynamic — Windows)

A modern, free user-mode debugger for Windows (handles both 32-bit via `x32dbg` and 64-bit via `x64dbg`). Run the program, pause it, inspect/modify registers and memory, and patch it live.

## The Four Main Panels
| Panel | Purpose |
|---|---|
| **CPU / Disassembly** (top-left) | The instructions, with current EIP/RIP highlighted |
| **Registers** (right) | Live register values + flags (ZF, CF, etc.) |
| **Dump** (bottom-left) | Raw memory viewer |
| **Stack** (bottom-right) | The current call stack / stack memory |

## Essential Shortcuts
| Key | Action |
|---|---|
| `F2` | Toggle breakpoint at selected line |
| `F7` | Step into (enter a `call`) |
| `F8` | Step over (execute a `call` without entering) |
| `F9` | Run / continue |
| `Ctrl+F9` | Run until return (execute to `ret`) |
| `F4` | Run until selected line |
| `Space` | Assemble / edit instruction at cursor |

## Useful Right-Click Actions
- **Search for → All referenced strings** — jump to code by the text it prints (the fastest way to find the interesting part).
- **Search for → All intermodular calls** — list every Windows API call (e.g. find every `MessageBoxW`).
- **Follow in Dump / Disassembler** — pivot between memory and code.
- **Breakpoint → Hardware/Memory** — break when memory is read/written.

## Practical Example — Bypass a Check at Runtime
1. Open `target.exe` in x64dbg → it pauses at the system breakpoint; press `F9` to reach the entry point.
2. Right-click disassembly → **Search for → All referenced strings**.
3. Double-click `"Invalid license key"` → you land near the check.
4. Just above the string you'll see something like:
   ```asm
   test eax, eax
   je   0x40123A      ; jumps to "bad" branch when eax == 0
   ```
5. Set a breakpoint (`F2`) on the `je`. Press `F9`, enter any key.
6. When it breaks, look at **ZF** in the Registers panel. Two ways to bypass:
   - **Flip the flag:** double-click `ZF` to toggle it → forces the other branch.
   - **Patch the instruction:** select the `je`, press `Space`, change it to `jne` or `nop`.
7. Continue (`F9`) — the program now accepts any key.
8. To save: **right-click → Patches → Patch file** to write the modified `.exe`.

## Common Beginner Tasks
- **Set a breakpoint on an API:** in the command box type `bp MessageBoxW` then `F9` — break right before the message box appears.
- **Defeat simple anti-debug:** install the **ScyllaHide** plugin to hide the debugger from `IsDebuggerPresent` and friends.

---

# Cutter (Static — Linux/Cross-platform)

A free, open-source GUI built on the **rizin** framework, with an optional **Ghidra-based decompiler** bundled in. Lighter and faster to open than Ghidra; great for quick static looks. (Ghidra is also fully available on Linux and works exactly as described above — pick whichever you prefer.)

## Key Panels
| Panel | Purpose |
|---|---|
| **Functions** (left) | List of detected functions |
| **Disassembly** (center) | The assembly listing |
| **Decompiler** | Pseudo-C (enable the Ghidra decompiler plugin) |
| **Graph view** | Control-flow graph (press `Space`) |
| **Console** | Run raw rizin commands |

## Practical Example
1. Open `target` in Cutter → accept the default analysis level.
2. In the **Functions** panel, look for meaningful names (`main`, `check_password`) — present if the binary isn't stripped.
3. Double-click `check_password` → switch the central view to **Decompiler** to read pseudo-C.
4. Press `Space` for the **graph view** — visually trace the "success" branch vs the "fail" branch.
5. Rename symbols as you learn them (`N` key) to keep things readable.

> **Bonus:** Cutter exposes the rizin console, so you can run powerful one-liners (e.g. `afl` to list functions, `axt @ sym.main` to find cross-references) without leaving the GUI.

---

# GDB + pwndbg (Dynamic — Linux)

**GDB** is the standard Linux debugger (command-line). **pwndbg** is a plugin that adds colored, context-rich output — disassembly, registers, stack, and backtrace shown automatically at each stop. Together they're the Linux equivalent of x64dbg.

## Setup
Install pwndbg once (clone its repo and run its `setup.sh`); it loads automatically via your `~/.gdbinit`. After that, just run `gdb ./target`.

## Essential Commands
| Command | Action |
|---|---|
| `break main` / `b main` | Breakpoint at function `main` |
| `break *0x401234` | Breakpoint at an exact address |
| `run` / `r` | Start the program |
| `continue` / `c` | Resume until next breakpoint |
| `ni` | Next instruction (step over calls) |
| `si` | Step into (enter calls) |
| `info registers` | Show all registers |
| `x/s $rdi` | Examine memory as a string at RDI |
| `x/20xw $rsp` | Examine 20 hex words at the stack pointer |
| `bt` | Backtrace (call stack) |
| `finish` | Run until the current function returns |
| `set $rax = 1` | Modify a register value |

## Practical Example — Read a Hidden Password
On 64-bit Linux (System V ABI), the first function arguments are in **RDI, RSI, RDX, RCX, R8, R9**.

```bash
gdb ./target
```
Inside GDB:
```
pwndbg> break strcmp        # stop on every string comparison
pwndbg> run                 # start; enter a guess when prompted
```
When it breaks at `strcmp`, pwndbg auto-displays the registers. Inspect the two arguments:
```
pwndbg> x/s $rdi            # arg 1 = your input
pwndbg> x/s $rsi            # arg 2 = the real password 🎯
```
The second argument reveals the secret it's comparing against.

## Practical Example — Force a Branch
```
pwndbg> break *0x40120a     # the address of a conditional jump
pwndbg> run
pwndbg> info registers eflags   # check the zero flag
pwndbg> set $eflags ^= 0x40      # flip ZF (bit 6) to take the other branch
pwndbg> continue
```
Or skip a check entirely by setting the instruction pointer past it: `set $rip = 0x401230`.

## Why pwndbg over plain GDB
- Auto-shows **disassembly + registers + stack** at every stop (plain GDB shows almost nothing).
- Colored, dereferenced pointers so you can see what addresses point to.
- Built-in helpers: `vmmap` (memory layout), `telescope` (smart stack view), heap analysis for `malloc`-based challenges.

---

# Combined Workflow

A typical session ties all four together:

1. **Map it statically** in **Ghidra/Cutter** — find the interesting function (follow a string reference), read the decompiled logic, rename things until it makes sense.
2. **Note the key address** — e.g. the conditional jump that decides success/failure.
3. **Run it dynamically** in **x64dbg** (Windows) or **GDB+pwndbg** (Linux) — break at that address, inspect the *real* runtime values your static view couldn't compute.
4. **Modify & verify** — flip a flag, patch a jump, or change a register to confirm your understanding, then make the patch permanent if needed.

| Goal | Reach for... |
|---|---|
| Understand overall logic | Ghidra / Cutter (decompiler) |
| See a value computed at runtime | x64dbg / GDB+pwndbg |
| Find the interesting code fast | "Search referenced strings" (both static & dynamic tools have this) |
| Bypass a check | Patch the jump (static) or flip the flag (dynamic) |

> **Practice tip:** Compile your own program with `gcc -O0 -g test.c -o test`, open it in Ghidra to compare disassembly against your known source, then debug it in GDB+pwndbg. Doing this a few times builds the static↔dynamic intuition faster than anything else.