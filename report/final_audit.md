# Final audit against the marking criteria

Status legend: **DONE** = implemented and verified here; **PARTIAL** = implemented,
but only a smoke run was possible here; **BLOCKED** = cannot be executed in this
build environment (no Docker/k3d/kubectl/sudo, ~1.5 GiB free RAM); exact
commands are in `README.md` and `docs/RUNBOOK.md`.

## Task 1 (12 marks)

| Criterion | Status | Evidence / gap |
|---|---|---|
| Cluster from `cluster/k3d.yaml`, SeaweedFS in `data` | BLOCKED (code) | `cluster/k3d.yaml`, `k8s/seaweedfs.yaml`; no Docker/k3d here |
| Both buckets, `commands_pool.jsonl`, prompt in repo | DONE (code) | `scripts/init_storage.py`; provenance and hashes in `data/README.md` |
| Two workers with different `SHARD_INDEX` | PARTIAL | 4 shards run locally with `scripts/label_local.sh`; Kubernetes Indexed Job in `k8s/worker-job.yaml` not run |
| Every id exactly once, no gaps/repeats | PARTIAL | Coverage check in `worker/clean.py`; local smoke intentionally incomplete (`--allow-incomplete`) |
| `clean.py` reproduces `train.sha256` | PARTIAL | Checksum verification test passes; smoke checksum in `results/clean_counts.json` |
| Counts table and invariant | PARTIAL | Real smoke counts in `results/clean_counts.json`; full 3,000 run still needed |

## Task 2 (20 marks)

| Criterion | Status | Evidence / gap |
|---|---|---|
| `config.yaml` has six items | DONE | `training/config.yaml` |
| `make train SUBSET=50` completes | DONE | Run on the smoke dataset; see `results/train_subset.log` |
| `loss.csv` one value per epoch, seed fixed | DONE | `training/loss.csv`, `loss_v2.csv`; seed in `set_seeds` |
| `models/v1` and `v2` in object storage | PARTIAL | Local object store contains smoke models; SeaweedFS upload not run |
| Release checksum matches | BLOCKED | No GitHub Release/tag yet; script ready |
| Raw outputs/scores for teacher/base/student | DONE (smoke) | `results/pred_*.jsonl`, `results/score_*.json`, `results/teacher_validation.json` |
| Hidden validity >= 95%, full-frame >= half teacher | UNKNOWN | Local smoke scores are a pipeline check, not the hidden test |
| Explanation (4 points) | DONE | Report section 3.4 |

## Task 3 (14 marks)

| Criterion | Status | Evidence / gap |
|---|---|---|
| Three endpoints, headers, exact error body | DONE | `tests/test_service_api.py`; 49 tests pass |
| Model from object storage, no weights in image | DONE (code) | `service/model_runner.py`, `service/Dockerfile`; image build BLOCKED |
| Four env vars, credentials only from Secret | DONE (code) | `service/app.py`, `k8s/app.yaml`, `scripts/create_secrets.sh` |
| Image builds, pinned deps, <= 2 GB | BLOCKED | Dockerfile with CPU wheel and pins; no Docker daemon |
| 50 requests at 1 CPU / 1 GiB, peak memory | PARTIAL | Local process 50 requests measured in `results/service_local_inference.json`; cgroup limit not exercised |

## Task 4 (22 marks)

| Criterion | Status | Evidence / gap |
|---|---|---|
| Namespace/Deployment/Service/Ingress | BLOCKED (code) | `k8s/app.yaml`, `k8s/ingress.yaml`, `k8s/00-namespaces.yaml` |
| Requests/limits; no ready endpoints while loading | DONE (code/test) | `k8s/app.yaml`, `tests/test_service_api.py`; cluster not run |
| HPA as specified; 1->2->1 evidence | BLOCKED | `k8s/hpa.yaml`; commands in `docs/RUNBOOK.md` |
| Rolling update <=0.5% failures; rollback v1 | BLOCKED | `maxUnavailable: 0`; commands in runbook |
| Recovery, <=2% failures | BLOCKED | Runbook section 3 |
| Three cold starts + median + log evidence | BLOCKED | Runbook section 4 |
| Each replica >=30% of successes | BLOCKED | Runbook section 5 |

## Task 5 (10 marks)

| Criterion | Status | Evidence / gap |
|---|---|---|
| Subnet table (4 x 5 values) | DONE | `network/subnets.md`, `results/subnets.txt` |
| NACL decided correctly | DONE (sample) | Official simulator 6/6 (`results/nacl_check.txt`); hidden 20 packets unknown |
| Stateless/order explanation | DONE | `network/subnets.md`, report section 6 |

## Task 6 (10 marks)

| Criterion | Status | Evidence / gap |
|---|---|---|
| Lint and unit tests (>=3) | DONE | `ruff` clean; 49 tests pass (`results/lint.txt`, `results/pytest.txt`) |
| Evaluation stage from Release | DONE (code) | `.github/workflows/ci.yml`; Release asset missing |
| `make up` <=3 commands; `make down` | DONE (code) | `Makefile` bootstraps venv, `scripts/up.sh`, `scripts/down.sh`; not executed without Docker |
| Link to failing quality-gate run | BLOCKED | Workflow has `bad_model=true` dispatch; repo not pushed |
| `AI_USE.md`, secret scan clean | DONE | `AI_USE.md`; gitleaks: no leaks (`results/gitleaks.txt`) |

## Task 7 (12 marks)

| Criterion | Status | Evidence / gap |
|---|---|---|
| Five measurements + Locust files | PARTIAL | Local Locust files in `results/`; cluster `kubectl top`, cold start missing |
| Error rate <=1%, p95 <=5,000 ms | PARTIAL | Local values only; cluster values missing |
| Cost per 1,000 correct | DONE | `scripts/cost.py`, `results/cost.json` |
| SLO target/window and error budget | DONE | `results/cost.json` |
| Review table, measured numbers | PARTIAL | Local measured values; cluster rows marked limitations |

## Submission

| Item | Status |
|---|---|
| GitHub repo, code, tests, manifests, CI | Files present; **not committed/pushed** |
| Model Release asset | Missing; `scripts/fetch_model.sh` and `gh release create` ready |
| Evidence in `results/` | Local evidence present; cluster evidence missing |
| `README.md` | Done |
| Tag `final` | **Not created** by design: several tasks are unverified |
| `report/report.pdf` | Built from real measurements; unmeasured cells marked |
| Handwritten reflection `<roll>.pdf` | Must be handwritten and scanned by the student; notes in `docs/reflection_notes.md` |
