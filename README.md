# APZ: Error-Bounded Compression for Cosmological Particle Data

APZ reduces the storage and data transfer costs of cosmological simulation snapshots. It compresses particle positions and velocities within user-defined error bounds and preserves particle IDs exactly when present. APZ is designed for [HyperMillennium (Qianyan)](https://doi.org/10.1093/mnras/stag540) and HACC data. Molecular dynamics trajectories are a planned extension.

## Upstream compressors and credits

APZ combines existing codecs with data layouts and particle ordering tailored to snapshots with and without IDs. We thank the authors and contributors of the codecs used in APZ.

| Codec | Role in APZ | Reference |
| --- | --- | --- |
| [XnYZip](https://github.com/moonlightplague/XnYZip) | Compresses position triplets in the HACC workflow and can also compress velocity triplets. | Liu et al., [Error-bounded Point Cloud Compression Using Truncated Octahedron Quantization](https://doi.org/10.14778/3836663.3836676) |
| [Falcons](https://github.com/opensdc-org/Falcons) | APZ uses an earlier implementation of Falcons for HACC velocity fields and for positions and velocities in the lattice-based workflow. | Lu et al., [Falcons: Pushing the Speed-Ratio Limits of Lossy Compression for Parallel Scientific Applications](https://arxiv.org/abs/2610.41209), PPoPP ’27 |
| [LCP](https://github.com/moonlightplague/LCP) | Provides an alternative codec for position and velocity triplets. | Zhang et al., [LCP: Enhancing Scientific Data Management with Lossy Compression for Particles](https://doi.org/10.1145/3709700) |
| [SZ3](https://github.com/szcompressor/SZ3) | Provides an alternative error-bounded codec for individual floating-point fields via `pysz`. | Liang et al., [SZ3: A Modular Framework for Composing Prediction-Based Error-Bounded Lossy Compressors](https://ieeexplore.ieee.org/document/9866018) |
| [Pcodec](https://github.com/pcodec/pcodec) | Compresses IDs, ordering metadata, and optionally numeric fields losslessly. | Loncaric et al., [Pcodec: Better Compression for Numerical Sequences](https://arxiv.org/abs/2502.06112) |

APZ pins this earlier Falcons implementation as `tools/SZo` and selects it with `szo` on the command line.

## Compression results

The APZ study used the earlier SZo implementation of Falcons. At a range-relative error setting of `1e-3` under a common per-coordinate error criterion, it reported the following overall compression ratios, including IDs where present and reconstruction metadata.

| Dataset | Particles | APZ | Best evaluated baseline |
| --- | ---: | ---: | ---: |
| HyperMillennium HM1 | 531 million | **23.5×** | 7.7× (XnYZip) |
| HyperMillennium HM2 | 1.73 billion | **26.7×** | 8.0× (XnYZip) |
| HACC | 281 million | **11.3×** | 8.5× (SZo) |

At the tighter `1e-4` setting, the maximum relative deviation in the measured matter power spectra was 0.132% or less across the three datasets. See the [HACC experiment notes](experiments/hacc_linf_bound.md) for a separate repository run and its exact configuration.

## Installation

On Linux, install Git, CMake 3.18+, Make, a C++20 compiler with OpenMP support, the oneTBB development package, and Rust/Cargo. The example uses Python 3.13 in a Conda environment.

```bash
git clone --recurse-submodules https://github.com/opensdc-org/APZ.git
cd APZ
conda create -n apz python=3.13
conda activate apz
python -m pip install conan==2.30.0
# Run this once if Conan does not already have a default profile.
conan profile detect
bash install.sh
```

See [INSTALL.md](INSTALL.md) for build verification.

## Quick start

APZ reads HDF5 snapshots with position and velocity fields and optional IDs, native `dat_*` snapshots with their matching `cfg_*` files, and HACC directories containing `xx.f32`, `yy.f32`, `zz.f32`, `vx.f32`, `vy.f32`, and `vz.f32`.

Download the [SDRBench HACC medium snapshot](https://huggingface.co/datasets/sdrbench/hacc/tree/main/medium) and place its six fields in `data/EXASKY-HACC-data-medium-size/`. Run a one-million-particle roundtrip:

```bash
python main.py roundtrip data/EXASKY-HACC-data-medium-size \
  --work-dir particle_pipeline_runs/hacc \
  --pos-compressor xnyzip --vel-compressor szo --rel-eb 1e-3 \
  --xnyzip-tie-sort --xnyzip-linf-bound --limit 1000000 --metrics --clean-raw
```

The example explicitly enables velocity tie sorting and per-coordinate error bounds for XnYZip positions. Remove `--limit 1000000` and use a fresh work directory to process the full snapshot. The work directory contains `compressed/`, `manifest.json`, `reconstructed.h5`, and `metrics.json`.

Use `python main.py roundtrip --help` for available options. See [run.sh](run.sh) and [config.yaml](config.yaml) for HACC and HyperMillennium settings.

<a name="higher-compression-for-snapshot_7"></a>
For advanced layouts and larger runs, see the [snapshot examples](https://github.com/opensdc-org/APZ/blob/fba36141ac35455ae45c2c488a471a0e111781f9/README.md#higher-compression-for-snapshot_7).
