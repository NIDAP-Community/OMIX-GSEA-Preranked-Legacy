# Canonical OMIX Module Source

## Canonical module

- **Module:** [OMIX GSEA Preranked Legacy](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSEA-Preranked-Legacy)
- **Canonical path:** `modules/OMIX-GSEA-Preranked-Legacy/`
- **Canonical module version:** `5.3.0`
- **Canonical interface version:** `1`
- **Canonical release tag:** Pending — baseline tag not yet established.
- **Canonical source reference:** [`1c71167c53f9fad5b2aaebf7871763ccfd114afd`](https://github.com/NIDAP-Community/OMIX/commit/1c71167c53f9fad5b2aaebf7871763ccfd114afd)
- **Interface schema:** [schemas/interface.yml](https://github.com/NIDAP-Community/OMIX/blob/main/modules/OMIX-GSEA-Preranked-Legacy/schemas/interface.yml)
- **Module contract:** [OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md)

## Exported scientific files

| Canonical file | Adapter copy | Purpose |
| --- | --- | --- |
| `R/GSEA_Preranked.R` | `code/functions/GSEA_Preranked.R` | Preranked GSEA implementation. |

The listed export was verified byte-for-byte against the canonical source
reference above.

## Adapter release record

| Field | Recorded value |
| --- | --- |
| Adapter version | Pending — baseline tag not yet established. |
| Adapter release tag | Pending. |
| Platform release | Pending validation record. |
| Runtime identity | Target: `codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v3`; public source identity: `ghcr.io/nidap-community/omix-r-pathway@sha256:20bfb0c77e8804b11730750f47ec8f355666a4be1ffa8d687052dc69a3b7e2e3`. Platform import and representative-run evidence are pending. |

See the [OMIX versioning and release policy](https://github.com/NIDAP-Community/OMIX/blob/main/docs/versioning-and-releases.md). The source commit, adapter tag, platform release, and runtime identity are separate records.

## Ownership and synchronization

The canonical module owns scientific functions, portable CLI behavior, schemas,
tests, and scientific documentation. This adapter owns deployment UI, input
discovery, result paths, runtime setup, and the platform entry point.

Make reusable changes in the canonical module, update its tests and interface,
record the next canonical version and immutable source reference here, and then re-export the listed
file without unreviewed behavioral changes. Validate the adapter with
representative deployment inputs before release.

The adapter delegates FindMarkers profile recognition to the canonical
`OmixPathwayInputs` package. It owns only Code Ocean input discovery and the
translation of the App Panel's standard `_tstat` default to FindMarkers'
signed `_logFC` scores.
