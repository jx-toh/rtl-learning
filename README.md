# rtl-learning
Inspired to enter RTL design / Design verification positions

# Vending Machine FSM — Verilog RTL Design

A finite state machine (FSM) implementation of a vending machine controller,
written in Verilog. Designed as a learning project to demonstrate core RTL
design and basic verification concepts.

---

## What it does

- Accepts coin inputs and tracks credit across clock cycles
- Dispenses an item after 2 coins are inserted
- Supports cancel input to return to idle at any time
- Outputs a 2-bit `credit` signal showing current coin count
- Resets cleanly to idle state via synchronous/asynchronous reset

---

## Design concepts demonstrated

| Concept | Where |
|---------|-------|
| Moore FSM | `vending_machine.v` — output depends only on state |
| Synchronous sequential logic | `always @(posedge clk)` state register |
| Combinational next-state logic | `always @(*)` with `if/else` priority |
| Parameterised output | `credit` output maps state to coin count |
| Priority logic | `cancel` takes priority over `coin` |
| Basic testbench | Stimulus, monitor, assertions in `tb_vending_machine.v` |

---

## File structure

```
vending-machine/
├── rtl/
│   └── vending_machine.v    — RTL design
└── tb/
    └── tb_vending_machine.v — Testbench
```

---

## State machine

```
          coin=1               coin=1
  ┌──────────────► ONE ──────────────► TWO ──► dispense=1
  │                 │                           │
IDLE ◄─────────────┘                           │
  ▲    coin=0 (stay)                           │
  └───────────────────────────────────────────┘
            (always returns to IDLE)

cancel=1 from any state → IDLE immediately
```

---

## Ports

### `vending_machine.v`

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | input | 1 | Clock — rising edge triggered |
| `rst` | input | 1 | Async reset — active high |
| `coin` | input | 1 | Coin inserted when high |
| `cancel` | input | 1 | Cancel transaction, return to idle |
| `dispense` | output | 1 | High for one cycle when dispensing |
| `credit` | output | 2 | Current coin count (0, 1, or 2) |

---

## How to simulate

### EDAPlayground (browser — no install needed)
1. Go to [edaplayground.com](https://edaplayground.com)
2. Paste `vending_machine.v` into the left editor
3. Paste `tb_vending_machine.v` into the right editor
4. Select **Icarus Verilog 0.9.7** as the simulator
5. Tick **Open EPWave after run**
6. Click **Run**

### Icarus Verilog (local)
```bash
iverilog -g2012 -o sim rtl/vending_machine.v tb/tb_vending_machine.v
vvp sim
```

---

## Expected output

```
--- Reset done. Expect state=00 (IDLE) ---
--- After 1 coin. Expect state=01 (ONE) ---
PASS: credit=1 after 1 coin
--- After 2nd coin. Expect credit back to 0 after dispense ---
PASS: credit=0 after dispensing
--- Test 3: Insert coin then cancel ---
PASS: credit=0 after cancel
--- Simulation complete ---
```

---

## Tools used

- Verilog (IEEE 1364-2001)
- Icarus Verilog 0.9.7 (simulation)
- EDAPlayground (browser-based IDE)
- GTKWave / EPWave (waveform viewer)

---

## Author

[Your Name] — Mechatronics Engineering student learning RTL design
and semiconductor verification.
