Got it — you want something that runs **inside OpenShift**, not just Docker locally, to test **Solace AMQP (1.0)**.

Here are the best container-native options that work cleanly in OpenShift:

---

## ✅ Option 1: Apache Qpid Proton Tools (Lightweight + CLI Based)

Use an AMQP 1.0 CLI tool inside a pod.

The most common is based on **Apache Qpid** (Proton).

You can deploy a simple test pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: amqp-test
spec:
  containers:
  - name: qpid
    image: quay.io/interconnectedcloud/qdrouterd:latest
    command: ["sleep","infinity"]
```

Then `oc rsh` into it and install proton tools (or build your own image with them pre-installed).

From inside the pod:

```bash
proton-send amqp://solace-broker:5672/testQueue -m "hello"
proton-receive amqp://solace-broker:5672/testQueue
```

This is the **cleanest CLI-based AMQP 1.0 testing approach**.

Best for:

* Connectivity validation
* Queue/topic validation
* Basic publish/consume testing

---

## ✅ Option 2: SDKPerf Container (More “Solace Native”)

Solace provides **SDKPerf**, which you can run inside a container.

You build a custom image with SDKPerf binaries and deploy it as a Job in OpenShift.

Example usage:

```bash
sdkperf_amqp.sh -cip=amqp://solace:5672 \
  -cu=user@vpn \
  -cp=password \
  -ptl=testQueue \
  -mn=100
```

Best for:

* Load testing
* Throughput testing
* Latency testing
* Durable queue validation

If you're doing performance validation inside OpenShift, this is the most production-aligned tool.

---

## ✅ Option 3: Ephemeral OpenShift Job (Best Practice)

Instead of a long-running pod, create a **Kubernetes Job** that runs AMQP tests and exits.

Example:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: amqp-producer-test
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: producer
        image: your-amqp-tester:latest
        args:
          - "amqp://solace:5672"
```

This is ideal for:

* CI/CD pipelines
* Smoke tests after deployment
* Automated environment validation

---

## ⚠️ Important for OpenShift

Make sure:

1. AMQP port is exposed in the Solace service (5672 or 5671 for TLS)
2. NetworkPolicy allows pod-to-pod communication
3. If using TLS:

   * Mount truststore as a secret
   * Verify OpenShift SCC allows needed permissions

---

## 🚀 What I’d Recommend

If your goal is:

* **Quick manual testing** → Qpid Proton CLI pod
* **Performance/load testing** → SDKPerf container
* **CI/CD smoke tests** → AMQP Job container

---

To narrow this down properly:

1. Is your Solace broker running inside the same OpenShift cluster?
2. Are you testing plain AMQP (5672) or AMQPS (5671 with TLS)?
3. Is this for manual debugging or automated pipeline validation?

Answer those and I’ll give you an exact YAML + container image that fits your setup.
