# Nano-Grover Diffusion & Oracle Iteration Circuit

Formal synthesis and verification of an analog **Nano-Grover Diffusion & Oracle Iteration Circuit** (`nano_grover_core.va`).

## Contents

- **Part 1** — Circuit architecture, formal energy-conservation / amplitude-amplification theorem, and complete continuous-time Verilog-A behavioral netlist (`src/nano_grover_core.va`).
- **Part 2** — Zero-dependency Lean 4 Markov-chain formalization (`lean/NanoGroverMarkov.lean`) with recursive tactical proofs under the stated constraints (no Mathlib, no Lake, no reduction calculi, no `sorry`/`admit`).

## Constraints Observed

- Zero high-level abstractions.
- Zero external library imports.
- Zero `sorry` / `admit` / axioms.
- Every proof state transition driven by explicit atomic Lean 4 tactics.
- Markovian state-transition semantics only.

## License

AGPLv3 (see LICENSE).
