# Formal Circuit Theorem — Nano-Grover Analog DAE

## Statement

Let $N = 2^n$ with $n \ge 3$. Let $\mathbf{V}(t) \in \mathbb{R}^N$ be the continuous-time node-voltage vector of the coupled nonlinear LC/memristive resonator network described by the Verilog-A module `nano_grover_iteration`.

Under Kirchhoff’s Current Law (KCL) and Kirchhoff’s Voltage Law (KVL) the system satisfies the differential-algebraic equations

$$
C\,\dot{\mathbf{V}} = \mathbf{I}_L + \mathbf{I}_{\mathrm{NDR}}(\mathbf{V}) + G_m(\bar{V}\mathbf{1} - \mathbf{V}) + O(\varepsilon^2)\,\mathbf{V},
$$
$$
L\,\dot{\mathbf{I}}_L = -\mathbf{V},
$$

where $\bar{V}(t) = N^{-1}\sum_k V_k(t)$ and $\mathbf{I}_{\mathrm{NDR}}$ implements the phase-inversion oracle $U_\omega$ via a voltage-controlled negative-differential-resistance characteristic on the target coordinate $\omega$ only.

### Energy conservation

$$
\|\mathbf{V}(t)\|_2^2 = V_0^2 + O(\varepsilon^2)
$$

for all $t$ in any finite cascade of $k$ quarter-cycle windows. The $O(\varepsilon^2)$ term arises solely from the explicit parasitic damping conductance $\varepsilon^2/R_{\mathrm{ndr}}$.

### Amplitude amplification

After $k = \lfloor\pi/4\,\sqrt{N}\rfloor$ cascaded stages (each stage consisting of one oracle NDR interval followed by one mean-reflection diffusion interval of duration $\Delta t = \pi/(2\omega_0)$) the target-node energy fraction obeys

$$
\frac{|V_\omega(k\Delta t)|^2}{V_0^2}\;\ge\; 1 - \frac{1}{N}.
$$

### Proof sketch (analytic)

1. **Norm preservation.** Differentiate $\|\mathbf{V}\|_2^2$ along trajectories. The LC part contributes a pure oscillatory term that integrates to zero over each closed quarter-cycle; the NDR on a single coordinate contributes an antisymmetric work term that cancels under the subsequent mean reflection; the only residual is the quadratic form of the parasitic conductance, which is $O(\varepsilon^2)$.
2. **Oracle action.** The cubic NDR characteristic is designed so that, inside one integration window, the target resonator acquires a relative phase $\pi$ while all other resonators retain their original phase (up to a global common-mode shift absorbed by the mean).
3. **Diffusion.** The star-coupled capacitive/gyrator bus forces every node voltage through the instantaneous affine map $V_k\mapsto 2\bar{V}-V_k$. On the Poincaré section taken at the end of each $\Delta t$ window this map is exactly the Householder reflection $2|s\rangle\langle s|-I$ written in the voltage basis.
4. **Discrete iteration.** The composition of the two maps on successive Poincaré sections yields the standard Grover iterate. The known closed-form recurrence for the target amplitude then gives the stated lower bound after $k$ steps.

The discrete Markov-chain formalization in `lean/NanoGroverMarkov.lean` encodes precisely this Poincaré map and proves the corresponding probabilistic statements under the zero-dependency, zero-automation constraints.
