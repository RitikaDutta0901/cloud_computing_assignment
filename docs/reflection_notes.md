# Notes for the handwritten reflection (3 pages)

Use these notes to write the scanned `<roll_number>.pdf` by hand. Do not submit
this file as the reflection; the assignment requires a handwritten scan.
Include your name, roll number (230101067) and the GitHub repository link on
the first page.

## What I learnt

- Sequence-level distillation is much simpler than logit-based distillation:
  the teacher's text is the label, so the project only needs an HTTP endpoint,
  not access to the teacher's internal logits or vocabulary.
- Object storage changes the deployment shape. Because weights live in
  SeaweedFS and not in the image, a model version is a key (`models/v1` vs
  `models/v2`), a rolling update is an environment change, and cold start is
  dominated by download plus load.
- Readiness is not the same as liveness. `/healthz` keeps the process from
  being restarted while `/readyz` keeps traffic away until the model is
  actually usable. This matters because a 70M model still takes time to
  download and load.
- A stateless NACL has to describe both directions explicitly. The return
  traffic rule and the rule number of the deny are not decoration; without
  them the sample packets are misclassified.
- Reproducibility is mostly bookkeeping: seeds, pinned versions, checksummed
  tarballs, one loss row per epoch, and evidence files that can be re-read.
- Measured evidence is harder than code. The build machine had no Docker, so
  many Kubernetes checks could not be run. I chose to mark them not measured
  rather than invent numbers.

## Challenges and how I handled them

- The prompt contains literal JSON braces, so `str.format` broke with a
  `KeyError`. I replaced it with a literal `{command}` substitution and added a
  regression test.
- The teacher takes several seconds per command on CPU. A full 3,000-command
  run is hours, so the worker flushes after every reply and skips ids already
  present in its own shard. I validated this with a smaller four-shard run.
- The local machine had about 1.5 GiB free while `phi3.5` needs about 2.6 GiB.
  I used `num_ctx=1024` and `num_predict=64` for the smoke run and unloaded the
  teacher before training, rather than risking an OOM kill.
- Training the whole prompt would waste the 70M model's capacity on copying
  the command. I masked the prompt tokens so the loss is only on the teacher
  reply.
- A rerun could put an old `model.sha256` inside the new tarball; I excluded
  the checksum file from the archive.
- The cost formula bills limits even when idle. I had to separate "cost per
  1,000 requests" from "cost per hour" and show the intermediate arithmetic.

## What I would do better

- Start the full teacher run on the first day, not after the code is finished.
- Use a machine with Docker and at least 8 GiB free RAM so the k3d, HPA,
  rolling-update and cold-start evidence can be captured in one session.
- Collect `kubectl top pods`, the three cold-start times, and per-replica
  request counts before writing the report, not after.
- Add a network policy and a queue-depth autoscaler; CPU is a poor proxy for
  inference load.
- Train on more data and evaluate with a proper held-out split; the smoke
  scores are a pipeline check, not a quality claim.
- Pin transitive dependencies in a lock file for a truly byte-identical image.

## Observations and findings

- The teacher was accurate on the sampled commands (for example, weather and
  calendar intents with grounded slots); the student is much weaker because it
  is tiny and saw few examples.
- Two concurrent teacher requests did not double throughput on this CPU; they
  contended and were slower per request. Sharding helps throughput only when
  there are enough cores and memory for parallel model work.
- The official NACL simulator is a good specification test: it checks the
  actual packet decisions, not just the JSON shape.
- The 6/6 NACL result and the 49 passing tests are reproducible locally; the
  cluster numbers are not, and the report says so.
