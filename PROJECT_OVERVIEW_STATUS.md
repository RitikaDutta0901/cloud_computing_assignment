# Cloud Computing Project Overview and Submission Status

## Project title

**Knowledge Distillation and Deployment of a Lightweight Command-Parsing Language Model**

## Project purpose

This project builds and deploys a small language model that converts natural-language
cloud commands into structured JSON. A larger teacher model labels the training
commands, a smaller student model learns from those labels, and the student is
served through a FastAPI application running on Kubernetes.

The project is designed to demonstrate:

- Object storage and parallel data processing.
- Knowledge distillation and CPU-based model training.
- REST API design and model serving.
- Docker containerization.
- Kubernetes deployment, health probes, ingress, and autoscaling.
- Network subnet and NACL design.
- CI/CD, testing, performance measurement, and cost analysis.

## Architecture

```text
3,000 command records
        |
        v
Ollama phi3.5 teacher model
        |
        v
Four resumable labeling workers
        |
        v
SeaweedFS/object storage: teacher shards
        |
        v
worker/clean.py
        |
        v
Cleaned training dataset + checksum
        |
        v
Pythia-70M student training (v1 and v2)
        |
        v
Model archives in object storage
        |
        v
FastAPI command parser
        |
        v
Docker image and Kubernetes Deployment
        |
        v
Service + Ingress + HPA + Locust performance testing
```

## Repository structure

| Location | Purpose |
|---|---|
| `data/` | Assignment command pool, validation data, schemas, and rate card |
| `worker/` | Teacher labeling worker, shard handling, storage abstraction, and cleaning |
| `training/` | Student model training, prediction, configurations, and loss files |
| `service/` | FastAPI application, model loading, validation, and Dockerfile |
| `k8s/` | Namespace, SeaweedFS, worker Job, application, ingress, and HPA manifests |
| `cluster/` | k3d cluster configuration |
| `network/` | Subnet allocation and NACL rules |
| `scripts/` | Setup, storage, labeling, evaluation, benchmarking, and deployment scripts |
| `tests/` | Unit and service tests |
| `tools/` | Scoring, NACL simulation, and Locust load-test tools |
| `results/` | Reproducibility, test, checksum, benchmark, and validation evidence |
| `report/` | Final report source, PDF, and audit |
| `.github/workflows/ci.yml` | Lint, tests, secret scan, model evaluation, and quality gate |

## Work completed

### Application implementation

- Implemented four-way sharded teacher labeling.
- Added resumable workers that skip already completed command IDs.
- Added local and S3-compatible storage backends.
- Added data cleaning for malformed JSON, invalid intents, invalid slots,
  duplicates, and missing records.
- Added checksum and record-count verification.
- Added v1 and v2 CPU training configurations.
- Added FastAPI endpoints:
  - `/parse`
  - `/healthz`
  - `/readyz`
- Added request validation, model-version headers, readiness behavior, and
  invalid-model-output handling.
- Added Docker configuration with model weights loaded from object storage.
- Added Kubernetes Deployment, Service, Ingress, probes, resource bounds, and HPA.
- Added SeaweedFS manifests and storage initialization scripts.
- Added subnet and NACL configuration.
- Added CI workflow and an intentionally failing quality-gate demonstration.
- Added Locust load testing, local benchmarking, cost calculation, and runbook
  documentation.

### Locally verified

- Ruff lint: **passed**.
- Unit tests: **49 passed**.
- NACL simulator: **6/6 packets correct**.
- Python compilation: **passed**.
- Kubernetes YAML parsing: **8 files / 15 documents parsed**.
- Report PDF: **successfully built**.
- Local v1 and v2 smoke model archives: **created with checksums**.
- Local FastAPI inference benchmark: **completed**.
- Secret-scan configuration and local evidence: **present**.

## Current teacher-labeling status

The full assignment-compliant `phi3.5` labeling run is complete. All four
shards finished successfully:

| Shard | Completed | Target |
|---|---:|---:|
| Shard 0 | 750 | 750 |
| Shard 1 | 750 | 750 |
| Shard 2 | 750 | 750 |
| Shard 3 | 750 | 750 |
| **Total** | **3,000** | **3,000** |

Teacher labeling completion is **100%**. The full local cleaning run also
completed successfully:

- Input records: **3,000**
- Kept records: **2,782**
- Invalid JSON: **49**
- Wrong keys: **4**
- Invalid slots: **118**
- Duplicate commands: **47**
- Invalid intents: **0**
- Cleaned dataset SHA-256:
  `7e286136aaaaf4fd15e86ad4fe3c449b304182a69f7dd2664a0d729f13d33734`

## Completion estimate

These are engineering estimates based on implementation and verified evidence,
not official marks.

| Area | Estimated completion |
|---|---:|
| Project implementation and source structure | 90% |
| Teacher labeling and full dataset evidence | 100% |
| Student model training | 95% |
| Model evaluation | 90% |
| FastAPI service | 80% |
| Docker image validation | 35% |
| Kubernetes deployment validation | 25% |
| Networking and NACL | 100% |
| CI/CD | 60% |
| Performance and cost evidence | 50% |
| Final packaging and publication | 45% |
| **Overall submission readiness** | **Approximately 75%** |

Approximately **25% remains** before the project can honestly be described as
fully submission-ready. The source implementation is much further along than
the runtime evidence.

## Remaining work

### 1. Publish and verify the trained models

Full v1 and v2 training has completed on the required 1,500 records. Verify
the archives and publish the v1 archive as the `final` GitHub Release asset.

### 2. Validate Docker

An unprivileged Docker Engine socket was available and was tested. The image
build reached the base-image pull but failed because the daemon's DNS resolver
could not reach Docker Hub. Restarting the daemon with explicit DNS was not
possible because rootless mode requires the missing `newuidmap` helper and
passwordless sudo is unavailable. Required evidence still includes:

- Successful image build.
- Image size within the assignment limit.
- 50-request test with 1 CPU and 1 GiB memory.
- Peak memory measurement.
- Model loading from object storage rather than from the image.

### 3. Validate Kubernetes

The manifests exist, but cluster execution evidence is still missing:

- k3d cluster startup.
- SeaweedFS deployment and bucket initialization.
- Two ready application replicas.
- Ingress request.
- HPA scale-up and scale-down.
- Rolling update and rollback.
- Failure recovery.
- Three cold starts.
- Per-replica request distribution.

### 4. Complete performance evidence

Run Locust through the Kubernetes ingress and record:

- Request count.
- Error rate.
- p50 and p95 latency.
- Pod CPU and memory.
- Cold-start timings.
- Replica request shares.
- Cost per 1,000 successful/correct requests.

### 6. Complete GitHub submission

- Commit and push the final repository.
- Publish the required `final` model release asset.
- Run the normal CI workflow.
- Run the expected-failure quality-gate workflow.
- Record CI workflow URLs in the report.
- Add the required handwritten/scanned reflection PDF.

## Important status conclusion

The project is **substantially implemented but is not yet 100% submission-ready**.
The most important active dependency is the full teacher-labeling run. The next
major technical dependency is Docker/Kubernetes runtime validation. Until those
runtime measurements and the final GitHub release evidence exist, claiming
100% completion would be inaccurate.

For detailed audit information, see:

- [README.md](README.md)
- [PROJECT_STATUS.md](PROJECT_STATUS.md)
- [report/final_audit.md](report/final_audit.md)
- [docs/RUNBOOK.md](docs/RUNBOOK.md)
