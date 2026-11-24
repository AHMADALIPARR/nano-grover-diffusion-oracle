# Nano-Grover Diffusion & Oracle Iteration Circuit

Formal synthesis and verification of an analog **Nano-Grover Diffusion & Oracle Iteration Circuit** (`nano_grover_core.va`).

## Contents

### Part 1 — Circuit Architecture & Verilog-A Netlists

| File | Description |
|------|-------------|
| `src/nano_grover_core.va` | Continuous-time analog Nano-Grover diffusion & oracle core (parameterized N ≥ 8) |
| `src/nano_grover_triple_iteration.va` | 2-qubit (N=4) triple-iteration Grover with collapse |
| `src/spatial_grover_lattice.va` | Spatial quantum lattice 2-qubit coupling model (microwave / cross-resonance) |
| `src/trig_braid_processor.va` | Trigonometric braid processor (φ-scaled sin/cos) |
| `src/trig_processor.va` | Basic trigonometric processor with boundary checks |

### Part 2 — Formal Verification

- `lean/NanoGroverMarkov.lean` — Zero-dependency Lean 4 Markov-chain formalization with recursive tactical proofs (no Mathlib, no Lake, no reduction calculi, no `sorry`/`admit`).
- `docs/CIRCUIT_THEOREM.md` — Analytic energy-conservation and amplitude-amplification theorem.

## Constraints Observed

- Zero high-level abstractions.
- Zero external library imports.
- Zero `sorry` / `admit` / axioms.
- Every proof state transition driven by explicit atomic Lean 4 tactics.
- Markovian state-transition semantics only.

## License

- Primary: AGPLv3 (see `LICENSE`)
- Component covenant: `LicenseRef-Sovereign-Leviathan-SL-AGPL3-001` (see `LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt`)
- All `.va` sources carry the SL-AGPL3-001 header.
