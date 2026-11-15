#!/usr/bin/env bash
set -euo pipefail

#HACC input
INPUT_H5="data/EXASKY-HACC-data-medium-size"

#INPUT_H5="path/to/your/HM/data"

WORK_DIR="particle_pipeline_runs/$(basename -- "${INPUT_H5}")"

#HACC Run
python main.py roundtrip "${INPUT_H5}" \
  --config "config.yaml" \
  --work-dir "${WORK_DIR}" \
  --rel-eb "1e-3" \
  --force --clean-raw --metrics \
  --xnyzip-tie-sort

#HM Run
#python main.py roundtrip "${INPUT_H5}" \
#  --config "config.yaml" \
#  --work-dir "${WORK_DIR}" \
#  --rel-eb "1e-3" \
#  --force --clean-raw --metrics \
#  --lattice-layout