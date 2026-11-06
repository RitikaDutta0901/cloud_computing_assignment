# Project Status

Audit date: 2026-11-06

The assignment specification was read from the supplied 15-page PDF
(`CLOUD_ASSIGNMENT_DESCRIPTION.pdf`, located in `/home/ritika/Downloads` in
this workspace). The workspace is not a Git checkout (`git status` reports
“not a git repository”), so commit/tag/release verification cannot be
performed here. Docker, k3d, and kubectl are also not available in this
environment.

| Task | Required Implementation | Current Status | Missing Work |
|---|---|---|---|
| Task 1 | Object Storage and Teacher Labelling | **Partial** | k3d/SeaweedFS manifests, prompt, sharded worker, cleaner, checksum logic, and local tests exist. Only a 70-record partial run is evidenced; the required 3,000-command teacher run, two live workers, buckets, and complete shard evidence have not been run here. |
| Task 2 | Student Model Training | **Partial** | CPU sequence-level training, YAML configs, v1/v2 support, checksums, scoring, and tests exist. No model weights/tokenizers or `models/v1`/`models/v2` object-storage artifacts are present; the recorded training input is only 36 cleaned records from the partial run, not the required first 1,500 records. |
| Task 3 | FastAPI and Docker | **Partial** | `/parse`, `/healthz`, `/readyz`, schema validation, fault injection, object-storage loading, pinned CPU dependencies, and Dockerfile exist and pass unit tests. Docker build, image-size check, 50-request 1 CPU/1 GiB run, and peak-memory evidence are unavailable because Docker is not installed. |
| Task 4 | Kubernetes Deployment | **Partial** | Namespace, Deployment, Service, Ingress, probes, resource bounds, HPA, rolling-update settings, and runbook exist. No cluster deployment, ingress request, HPA transition, rollback, recovery, three cold starts, or per-replica load-balancing evidence was executed. |
| Task 5 | Networking and NACL | **Complete (local)** | Subnet allocation, NACL, simulator, sample packets, validation output, and tests exist. This is locally verified; no cloud networking is required by the assignment. |
| Task 6 | CI/CD and Testing | **Partial** | Makefile, CI workflow, unit tests, evaluation/quality-gate jobs, gitleaks configuration/result, and `AI_USE.md` exist. CI cannot be executed or linked from this non-Git workspace; the evaluation job depends on a GitHub Release model asset that is absent locally. |
| Task 7 | Performance and Cost Analysis | **Partial** | Locust workload, local benchmark, cost calculator, rate card, SLO calculation, report, and runbook exist. Cluster Locust output, pod CPU/memory, cold-start timings, and replica request shares are missing; report placeholders must remain marked unmeasured. |

## Verified during audit

- `./.venv/bin/pytest -q`: **49 passed**, one dependency deprecation warning.
- `data/commands_pool.jsonl`: 3,000 records.
- `data/validation.jsonl`: 100 records.
- A complete four-shard local Ollama run was started on 2026-11-06 with four
  concurrent workers. It is still in progress; the prior evidence remains a
  70-record first-pass/partial training run until all four shards finish.
- No `TODO`, `FIXME`, `XXX`, or `NotImplemented` markers were found in the project source.
- Existing reports correctly identify unavailable cluster/container measurements
  rather than claiming success.

## Exact continuation order

1. Run `make up`, storage initialization, and two or more teacher workers on a
   host with Docker, k3d, kubectl, and Ollama available; retain raw shard logs.
2. Clean all shards and verify the checksum/count invariant for all 3,000
   commands.
3. Run `make train` and `make train-v2`, upload both model/tokenizer versions,
   and run teacher/untrained/trained evaluation.
4. Build and size the image, run the 50-request constrained-container test,
   then deploy and collect Task 4 evidence.
5. Run Locust through the Ingress, collect `kubectl top pods`, cold starts, and
   per-replica counts; update `results/`, `report/report.md`, and this file
   only with measured values.
6. Execute CI from a real GitHub checkout, publish the model release asset,
   run the deliberately bad-model quality-gate workflow, and record its URL.

## Changes made during this continuation

- Added this audit/status handoff.
- Fixed `make train-v2 SUBSET=50` so the v2 smoke-test target has the same
  reproducibility behavior as v1.
- Fixed the CI Release download to pass the repository and explicit `final`
  tag to `gh release download`; the previous workflow depended on an unset
  shell variable and could not reliably download the required asset.
- Re-ran lint (**clean**), unit tests (**49 passed**), and the NACL simulator
  (**6/6 correct**).
- Generated `report/report.pdf` from the report source with LibreOffice; it
  preserves the report's explicit distinction between measured local evidence
  and unmeasured cluster-dependent results.

## Live labeling diagnosis (2026-11-06)

- The labeling shell remains active as shell session 66. Four
  `python -m worker.worker` processes are alive.
- At the audit, shard line counts were 224, 226, 125, and 126; each file had
  a current modification time and the logs advanced during inspection.
- Ollama has `phi3.5:latest` installed and its `llama-server` was using CPU
  while the workers ran. A separate `/api/generate` probe timed out after 30
  seconds because the server is configured with one inference slot (`-np 1`)
  and was occupied by active labeling requests.
- This is slow serialized CPU inference, not an indefinite wait or failed
  worker. No worker or data was restarted or deleted.
- At 21:07, after about 42 minutes, the active shards had 289, 290, 189,
  and 189 records respectively and all four logs were still advancing. At
  this observed rate, completion is expected to take roughly another
  50–70 minutes on this laptop.
- Resumability is implemented in `worker/worker.py`: each worker reads its
  existing `teacher/shard-N.jsonl`, skips completed IDs, flushes after every
  record, and writes the shard atomically. Re-running
  `SHARD_COUNT=4 PARALLEL=4 bash scripts/label_local.sh` continues from the
  last completed records.

The next dependency-gated step is to wait for the four shards to complete,
run `python worker/clean.py` against the full 3,000-command output, and only
then start the 1,500-record student training run. Docker, k3d, kubectl, and a
Git checkout remain external prerequisites for the unmeasured deployment and
CI evidence.
