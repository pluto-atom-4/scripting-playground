# Kubernetes Practice Guide: Cluster Operations & CLI Tools

**Goal:** Build hands-on familiarity with Kubernetes by deploying workloads to a local cluster and practicing with three popular CLI tools — **K9s**, **kubectx + kubens**, and **Stern** — that are widely used in production environments.

**Time estimate:** 3-4 hours hands-on

**Prerequisites:** A Linux workstation with Docker installed (rootless or standard), internet access, and basic familiarity with containers and the terminal. If you completed the Ansible lab, Docker is already set up.

---

## Table of Contents

1. [Environment Overview](#1-environment-overview)
2. [Install kubectl and kind](#2-install-kubectl-and-kind)
3. [Create a Local Cluster](#3-create-a-local-cluster)
4. [kubectl Fundamentals](#4-kubectl-fundamentals)
5. [Deploy Workloads](#5-deploy-workloads)
6. [Services and Networking](#6-services-and-networking)
7. [ConfigMaps and Secrets](#7-configmaps-and-secrets)
8. [Health Probes](#8-health-probes)
9. [Rolling Updates and Rollbacks](#9-rolling-updates-and-rollbacks)
10. [CLI Tool 1: kubectx + kubens](#10-cli-tool-1-kubectx--kubens)
11. [CLI Tool 2: K9s](#11-cli-tool-2-k9s)
12. [CLI Tool 3: Stern](#12-cli-tool-3-stern)
13. [Troubleshooting Exercises](#13-troubleshooting-exercises)
14. [Cleanup](#14-cleanup)
15. [Interview Talking Points](#15-interview-talking-points)

---

## 1. Environment Overview

The lab uses **kind** (Kubernetes in Docker) to run a multi-node cluster entirely inside Docker containers. This is lightweight, fast, and requires no VM or cloud account.

| Component | Description |
|-----------|-------------|
| **kind** | Creates Kubernetes clusters using Docker containers as nodes |
| **kubectl** | Primary CLI for all cluster operations |
| **K9s** | Terminal-based dashboard for navigating cluster resources |
| **kubectx + kubens** | Fast context and namespace switching |
| **Stern** | Multi-pod log tailing with color-coded output |

```
 ┌──────────────────────────────────────────────┐
 │   Local machine                              │
 │                                              │
 │   kubectl / K9s / Stern ─────┐               │
 │                               ▼              │
 │   ┌─────────────────────────────────────┐    │
 │   │  kind cluster (k8s-lab)             │    │
 │   │                                     │    │
 │   │  control-plane   worker-1  worker-2 │    │
 │   │  (Docker)        (Docker)  (Docker) │    │
 │   └─────────────────────────────────────┘    │
 └──────────────────────────────────────────────┘
```

---

## 2. Install kubectl and kind

### Step 2.1 — Run the install script

The lab includes a script that installs all required tools to `~/.local/bin`:

```bash
cd kubernetes-lab

chmod +x scripts/install-tools.sh
./scripts/install-tools.sh
```

The script installs: kubectl, kind, K9s, kubectx + kubens, and Stern. It skips tools that are already installed.

### Step 2.2 — Ensure ~/.local/bin is in your PATH

```bash
# Add to your shell profile if not already present
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Step 2.3 — Verify installations

```bash
kubectl version --client
kind version
k9s version
kubectx --help
stern --version
```

Each command should print version information without errors.

**Troubleshooting:**
- `command not found` — verify `~/.local/bin` is in your `$PATH` with `echo $PATH`.
- Permission denied — the script should set execute permissions, but you can run `chmod +x ~/.local/bin/{kubectl,kind,k9s,kubectx,kubens,stern}` manually.

---

## 3. Create a Local Cluster

### Step 3.1 — Create a multi-node cluster with kind

The lab includes a `kind-config.yml` that creates 1 control-plane + 2 worker nodes with port mappings for NodePort services:

```bash
cd kubernetes-lab

kind create cluster --config kind-config.yml --name k8s-lab
```

Expected output:

```
Creating cluster "k8s-lab" ...
 ✓ Ensuring node image (kindest/node:v1.x.x)
 ✓ Preparing nodes 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-k8s-lab"
```

### Step 3.2 — Verify the cluster is running

```bash
kubectl cluster-info
```

Expected output:

```
Kubernetes control plane is running at https://127.0.0.1:XXXXX
CoreDNS is running at https://127.0.0.1:XXXXX/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

```bash
kubectl get nodes
```

Expected output:

```
NAME                    STATUS   ROLES           AGE   VERSION
k8s-lab-control-plane   Ready    control-plane   30s   v1.x.x
k8s-lab-worker          Ready    <none>          20s   v1.x.x
k8s-lab-worker2         Ready    <none>          20s   v1.x.x
```

All three nodes should show `Ready` status.

### Step 3.3 — Inspect the Docker containers behind kind

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected output shows kind nodes running as Docker containers:

```
NAMES                    STATUS          PORTS
k8s-lab-control-plane    Up X minutes    0.0.0.0:8080->80/tcp, ...
k8s-lab-worker           Up X minutes
k8s-lab-worker2          Up X minutes
```

**Interview talking point:** kind is popular for CI/CD pipelines because it creates throwaway clusters fast, with no cloud cost. Each "node" is just a Docker container.

---

## 4. kubectl Fundamentals

Before deploying workloads, get comfortable with the core kubectl patterns.

### Step 4.1 — Explore the cluster

```bash
# List all namespaces
kubectl get namespaces

# List all resources in kube-system (the cluster's internal components)
kubectl get all -n kube-system

# View detailed node information
kubectl describe node k8s-lab-control-plane
```

### Step 4.2 — Understand the command pattern

kubectl follows a consistent pattern:

```
kubectl <verb> <resource> [name] [flags]
```

| Verb | Purpose | Example |
|------|---------|---------|
| `get` | List resources | `kubectl get pods` |
| `describe` | Show detailed info | `kubectl describe pod nginx-abc123` |
| `create` | Create from manifest | `kubectl create -f manifest.yml` |
| `apply` | Create or update | `kubectl apply -f manifest.yml` |
| `delete` | Remove resource | `kubectl delete pod nginx-abc123` |
| `logs` | View container logs | `kubectl logs pod/nginx-abc123` |
| `exec` | Run command in container | `kubectl exec -it pod/nginx -- /bin/sh` |
| `port-forward` | Forward local port | `kubectl port-forward svc/nginx 8080:80` |

### Step 4.3 — Useful flags to know

```bash
# Output as YAML (see the full object definition)
kubectl get pod <name>  -n kube-system -o yaml-o yaml

# Output as wide table (more columns)
kubectl get pods -o wide

# Watch for changes in real time
kubectl get pods -w

# Filter by label
kubectl get pods -l app=nginx-web

# All namespaces
kubectl get pods -A
```

---

## 5. Deploy Workloads

### Step 5.1 — Create namespaces

```bash
kubectl apply -f manifests/01-namespaces.yml
```

Expected output:

```
namespace/dev created
namespace/staging created
namespace/prod created
```

Verify:

```bash
kubectl get namespaces
```

You should see `dev`, `staging`, and `prod` alongside the default system namespaces.

### Step 5.2 — Deploy nginx

```bash
kubectl apply -f manifests/02-deployment-nginx.yml
```

Expected output:

```
deployment.apps/nginx-web created
```

### Step 5.3 — Watch Pods come up

```bash
kubectl get pods -n dev -w
```

Watch as the 3 replicas transition through states:

```
NAME                         READY   STATUS              RESTARTS   AGE
nginx-web-5d8f6b7c4-abc12   0/1     ContainerCreating   0          2s
nginx-web-5d8f6b7c4-def34   0/1     ContainerCreating   0          2s
nginx-web-5d8f6b7c4-ghi56   0/1     ContainerCreating   0          2s
nginx-web-5d8f6b7c4-abc12   1/1     Running             0          5s
nginx-web-5d8f6b7c4-def34   1/1     Running             0          6s
nginx-web-5d8f6b7c4-ghi56   1/1     Running             0          6s
```

Press `Ctrl+C` to stop watching.

### Step 5.4 — Inspect the Deployment

```bash
# View the Deployment
kubectl get deployment nginx-web -n dev

# See the ReplicaSet it created
kubectl get replicasets -n dev

# Describe the Deployment for full details
kubectl describe deployment nginx-web -n dev
```

**Key concept — the Deployment hierarchy:**

```
Deployment (nginx-web)
  └── ReplicaSet (nginx-web-5d8f6b7c4)
        ├── Pod (nginx-web-5d8f6b7c4-abc12)
        ├── Pod (nginx-web-5d8f6b7c4-def34)
        └── Pod (nginx-web-5d8f6b7c4-ghi56)
```

The Deployment manages ReplicaSets; the ReplicaSet manages Pods. You almost never interact with ReplicaSets directly.

### Step 5.5 — Exec into a Pod

```bash
# Get a Pod name
POD_NAME=$(kubectl get pods -n dev -l app=nginx-web -o jsonpath='{.items[0].metadata.name}')

# Open a shell inside the container
kubectl exec -it -n dev "$POD_NAME" -- /bin/sh

# Inside the container:
hostname
cat /etc/nginx/nginx.conf
wget -qO- http://localhost/
exit
```

---

## 6. Services and Networking

### Step 6.1 — Create Services

```bash
kubectl apply -f manifests/03-service-nginx.yml
```

Expected output:

```
service/nginx-clusterip created
service/nginx-nodeport created
```

### Step 6.2 — Understand Service types

```bash
kubectl get services -n dev
```

Expected output:

```
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx-clusterip   ClusterIP   10.96.x.x      <none>        80/TCP         5s
nginx-nodeport    NodePort    10.96.x.x      <none>        80:30080/TCP   5s
```

| Type | Who can access | Use case |
|------|---------------|----------|
| **ClusterIP** | Only within the cluster | Internal service-to-service |
| **NodePort** | External via `<NodeIP>:<NodePort>` | Dev/test external access |
| **LoadBalancer** | External via cloud LB | Production external access |


### Step 6.3 — Test the ClusterIP service (internal)

```bash
# ClusterIP is only reachable from inside the cluster.
# Use a temporary Pod to test it:
kubectl run curl-test -it --rm --restart=Never -n dev \
    --image=curlimages/curl -- curl -s http://nginx-clusterip
```

Expected: the nginx welcome page HTML.

### Step 6.4 — Test the NodePort service (external)

```bash
# NodePort is mapped to host port 30080 via the kind config
curl -s http://localhost:30080/
```

Expected: the nginx welcome page HTML. If this works, traffic is flowing from your host through the kind node to the Pod.

### Step 6.5 — Use port-forward for quick access

```bash
# Forward local port 9090 to the ClusterIP service
kubectl port-forward -n dev svc/nginx-clusterip 9090:80 &

curl -s http://localhost:9090/

# Stop the port-forward
kill %1
```

**Interview talking point:** In production, `port-forward` is a quick debugging tool, not a long-term access method. Use Ingress or LoadBalancer services instead.

---

## 7. ConfigMaps and Secrets

### Step 7.1 — Create a ConfigMap and Secret

```bash
kubectl apply -f manifests/04-configmap.yml
kubectl apply -f manifests/05-secret.yml
```

### Step 7.2 — Inspect the ConfigMap

```bash
kubectl get configmap app-config -n dev -o yaml
```

You'll see the key-value pairs and the embedded nginx config file.

### Step 7.3 — Inspect the Secret

```bash
# Secrets are base64-encoded, not encrypted
kubectl get secret db-credentials -n dev -o yaml
```

Decode a value:

```bash
kubectl get secret db-credentials -n dev -o jsonpath='{.data.DB_USER}' | base64 -d
# Output: wp_admin
```

**Interview talking point:** Kubernetes Secrets are base64-encoded by default, not encrypted. In production, enable encryption at rest for etcd and consider external secret managers (HashiCorp Vault, AWS Secrets Manager).

### Step 7.4 — Deploy using ConfigMap and Secret

```bash
kubectl apply -f manifests/06-deployment-with-config.yml
```

### Step 7.5 — Verify configuration was injected

```bash
# Get a Pod name from the configured deployment
POD_NAME=$(kubectl get pods -n dev -l app=nginx-configured -o jsonpath='{.items[0].metadata.name}')

# Check environment variables
kubectl exec -n dev "$POD_NAME" -- env | grep -E "APP_ENV|LOG_LEVEL|DATABASE"
```

Expected output:

```
APP_ENV=development
LOG_LEVEL=debug
MAX_CONNECTIONS=100
DATABASE_USER=wp_admin
DATABASE_PASSWORD=ChangeMe_2026!
```

```bash
# Check the mounted config file
kubectl exec -n dev "$POD_NAME" -- cat /etc/nginx/conf.d/default.conf
```

Expected: the custom nginx config from the ConfigMap with the `/health` endpoint.

```bash
# Test the health endpoint
kubectl exec -n dev "$POD_NAME" -- wget -qO- http://localhost/health
# Expected: healthy
```

---

## 8. Health Probes

### Step 8.1 — Deploy with probes

```bash
kubectl apply -f manifests/07-probes.yml
```

### Step 8.2 — Observe probe behavior

```bash
kubectl describe deployment nginx-probes -n dev
```

Look for the `Liveness`, `Readiness`, and `Startup` probe definitions in the output.

```bash
# Watch events related to probes
kubectl get events -n dev --sort-by='.lastTimestamp' | tail -20
```

### Step 8.3 — Simulate a probe failure

```bash
# Get a Pod name
POD_NAME=$(kubectl get pods -n dev -l app=nginx-probes -o jsonpath='{.items[0].metadata.name}')

# Kill the nginx process inside the container to trigger liveness failure
kubectl exec -n dev "$POD_NAME" -- /bin/sh -c "nginx -s stop"

# Watch the Pod — Kubernetes will detect the liveness failure and restart it
kubectl get pods -n dev -l app=nginx-probes -w
```

Expected: the `RESTARTS` counter increments as Kubernetes detects the liveness failure and restarts the container.

**Interview question:** "What happens if a readiness probe fails?"
**Answer:** The Pod is removed from Service endpoints, so no new traffic is routed to it. But the Pod is NOT restarted — only liveness probe failure triggers a restart. This is a key distinction.

---

## 9. Rolling Updates and Rollbacks

### Step 9.1 — Perform a rolling update

```bash
# Update the nginx image version
kubectl set image deployment/nginx-web nginx=nginx:1.26-alpine -n dev

# Watch the rollout
kubectl rollout status deployment/nginx-web -n dev
```

Expected output:

```
Waiting for deployment "nginx-web" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "nginx-web" rollout to finish: 2 out of 3 new replicas have been updated...
deployment "nginx-web" successfully rolled out
```

### Step 9.2 — View rollout history

```bash
kubectl rollout history deployment/nginx-web -n dev
```

Expected output:

```
deployment.apps/nginx-web
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

### Step 9.3 — Rollback to previous version

```bash
# Rollback to the previous revision
kubectl rollout undo deployment/nginx-web -n dev

# Verify
kubectl rollout status deployment/nginx-web -n dev
```

### Step 9.4 — Verify the image reverted

```bash
kubectl get deployment nginx-web -n dev -o jsonpath='{.spec.template.spec.containers[0].image}'
# Expected: nginx:1.27-alpine (the original version)
```

**Interview talking point:** Rolling updates replace Pods incrementally, so there is zero downtime. If something goes wrong, `kubectl rollout undo` instantly reverts to the previous ReplicaSet. Always mention this as a key Kubernetes operational benefit.

---

## 10. CLI Tool 1: kubectx + kubens

**What it does:** Switches between Kubernetes contexts (clusters) and namespaces without typing long `kubectl config` commands. Prevents the dangerous mistake of running commands against the wrong cluster.

### Step 10.1 — List and switch contexts

```bash
# List all contexts (clusters you're connected to)
kubectx
```

Expected output:

```
kind-k8s-lab
```

If you had multiple clusters, you would see them all listed, with the current one highlighted.

```bash
# Create a second cluster to practice switching
kind create cluster --name k8s-temp

# Now list contexts
kubectx
```

Expected output:

```
kind-k8s-lab
kind-k8s-temp
```

```bash
# Switch back to the lab cluster
kubectx kind-k8s-lab

# Verify
kubectl cluster-info
```

```bash
# Delete the temp cluster when done
kind delete cluster --name k8s-temp
```

### Step 10.2 — Switch namespaces with kubens

```bash
# List all namespaces
kubens
```

Expected output includes `default`, `dev`, `staging`, `prod`, `kube-system`, etc.

```bash
# Switch to the dev namespace
kubens dev
```

Expected output:

```
Context "kind-k8s-lab" modified.
Active namespace is "dev".
```

Now all kubectl commands default to the `dev` namespace — no `-n dev` flag needed:

```bash
# These are equivalent after switching:
kubectl get pods           # now targets 'dev' namespace
kubectl get pods -n dev    # explicitly targets 'dev'
```

```bash
# Switch to staging
kubens staging

# List pods (should be empty)
kubectl get pods
# Expected: No resources found in staging namespace.

# Switch back to dev
kubens dev
```

### Step 10.3 — Why this matters at scale

At UW-IT with multiple clusters (dev, staging, production) and many namespaces per cluster, accidentally running a command in the wrong context is a real operational risk. kubectx + kubens makes it fast to verify and switch, and pairs with **kube-ps1** (prompt indicator) to always show your current context and namespace.

**Scenario to practice:** Imagine you manage a production cluster with 29,000 WordPress sites in namespaces like `wp-tier1`, `wp-tier2`, `wp-batch`. You need to quickly check Pods in `wp-tier1` without accidentally affecting `wp-tier2`. kubens makes this safe.

---

## 11. CLI Tool 2: K9s

**What it does:** Provides a live, keyboard-driven terminal dashboard for cluster resources. Think of it as a real-time `htop` for Kubernetes — you can navigate resources, view logs, exec into containers, and delete Pods all from one interface.

### Step 11.1 — Launch K9s

```bash
# Make sure you're on the lab cluster and dev namespace
kubectx kind-k8s-lab
kubens dev

# Launch K9s
k9s
```

K9s opens a full-screen terminal UI showing Pods in the current namespace.

### Step 11.2 — Navigate resources

K9s uses Vim-style keyboard shortcuts:

| Key | Action |
|-----|--------|
| `:` | Open command mode (type a resource name) |
| `/` | Filter/search within current view |
| `Enter` | View details of selected resource |
| `d` | Describe the selected resource |
| `l` | View logs for selected Pod |
| `s` | Shell into selected Pod |
| `Ctrl+D` | Delete selected resource |
| `Esc` | Go back / close |
| `q` | Quit K9s |

**Exercise — Navigate the resource hierarchy:**

1. K9s starts showing Pods. Press `:` and type `deploy` then `Enter` to view Deployments.
2. Select `nginx-web` and press `Enter` to see its Pods.
3. Select a Pod and press `l` to view its logs.
4. Press `Esc` to go back. Press `d` on a Pod to see `describe` output.
5. Press `:` and type `svc` to view Services.
6. Press `:` and type `ns` to view Namespaces. Select `staging` and press `Enter`.
7. Press `q` to quit.

### Step 11.3 — Use K9s for quick operations

**View resource utilization:**
1. Launch `k9s`
2. Press `:` and type `node` — see node status and versions
3. Press `:` and type `pod` — see all Pods with their status, restarts, and age

**Delete a Pod and watch it respawn:**
1. Navigate to Pods (`:pod`)
2. Select an `nginx-web` Pod
3. Press `Ctrl+D` and confirm deletion
4. Watch the Deployment's ReplicaSet immediately create a replacement Pod

**View events:**
1. Press `:` and type `events` — see cluster events sorted by time
2. Use `/` to filter events (e.g., type `Warning` to see only warnings)

### Step 11.4 — K9s for troubleshooting

K9s is especially valuable for troubleshooting because you can:
- See Pod status at a glance (CrashLoopBackOff, ImagePullBackOff, etc.)
- Immediately drill into logs and events without typing long commands
- Shell into a container to inspect its filesystem
- View resource requests/limits alongside actual usage

**Interview talking point:** "When I get paged for a Kubernetes incident, my first step is to open K9s. Within seconds I can see which Pods are unhealthy, check their logs, and verify events — much faster than typing individual kubectl commands."

---

## 12. CLI Tool 3: Stern

**What it does:** Tails logs from multiple Pods simultaneously with color-coded output per Pod/container. Unlike `kubectl logs`, which only shows one Pod at a time, Stern can follow all Pods matching a label selector or name pattern.

### Step 12.1 — Deploy the multi-pod logging workloads

```bash
kubectl apply -f manifests/09-multi-pod-logging.yml
```

Wait for Pods to start:

```bash
kubectl get pods -n dev -l tier
```

Expected: 5 Pods running (2 api-server, 2 worker, 1 frontend).

### Step 12.2 — Tail all Pods in a namespace

```bash
# Tail ALL Pods in the dev namespace
stern -n dev ".*"
```

You'll see color-coded, interleaved output from all Pods:

```
api-server-abc12-xyz/api > [INFO] api-server request #1 processed — status=200
worker-def34-uvw/worker > [INFO] worker job #1 completed — queue_depth=3
frontend-ghi56-rst/frontend > [INFO] frontend page render #1 — path=/ latency=45ms
api-server-abc12-xyz/api > [INFO] api-server request #2 processed — status=200
...
```

Each Pod's output is a different color, making it easy to track which messages come from which Pod.

Press `Ctrl+C` to stop.

### Step 12.3 — Filter by Pod name pattern

```bash
# Tail only api-server Pods
stern -n dev "api-server"
```

```bash
# Tail only worker Pods
stern -n dev "worker"
```

### Step 12.4 — Filter by label selector

```bash
# Tail all backend Pods (both api-server and worker)
stern -n dev -l tier=backend
```

### Step 12.5 — Filter log content

```bash
# Show only ERROR lines across all Pods
stern -n dev ".*" --include "ERROR"
```

Expected: only `[ERROR]` lines from api-server and worker Pods.

```bash
# Show WARN and ERROR lines
stern -n dev ".*" --include "(WARN|ERROR)"
```

### Step 12.6 — Other useful Stern flags

```bash
# Show timestamps
stern -n dev "api-server" -t

# Show logs from the last 5 minutes
stern -n dev ".*" --since 5m

# Show only new logs (no history)
stern -n dev ".*" --tail 0

# Output as JSON (useful for piping to jq)
stern -n dev "api-server" -o json
```

### Step 12.7 — Stern vs kubectl logs

| Feature | `kubectl logs` | Stern |
|---------|---------------|-------|
| Multiple Pods | No (one at a time) | Yes (regex/label match) |
| Color-coded per Pod | No | Yes |
| Follow multiple containers | Manual (`-c` flag) | Automatic |
| Regex filtering | No (`grep` pipe) | Built-in (`--include`) |
| New Pod discovery | No | Yes (auto-follows new Pods) |

**Scenario to practice:** Imagine a 503 error is hitting the frontend. With Stern, you run `stern -n prod ".*" --include "ERROR" --since 10m` to see all errors across every Pod in the last 10 minutes. With kubectl, you'd need to check each Pod individually.

---

## 13. Troubleshooting Exercises

### Exercise 13.1 — Debug a CrashLoopBackOff

Create a Pod that intentionally crashes:

```bash
kubectl run crasher -n dev --image=busybox --restart=Always -- /bin/sh -c "echo 'starting...'; exit 1"
```

Now diagnose it:

```bash
# Step 1: Check Pod status
kubectl get pods -n dev crasher
# Expected: CrashLoopBackOff

# Step 2: View events
kubectl describe pod crasher -n dev | tail -20
# Look for "Back-off restarting failed container"

# Step 3: Check logs
kubectl logs crasher -n dev
# Expected: "starting..."

# Step 4: Check previous container logs (after restart)
kubectl logs crasher -n dev --previous
```

**Interview walkthrough:** "I'd start with `kubectl get pods` to see the status. CrashLoopBackOff means the container starts but exits immediately. I'd check `describe` for events, then `logs` and `logs --previous` to see what the container printed before crashing. The exit code tells me whether it's an application error (exit 1) or a signal (exit 137 = OOMKilled)."

Clean up:

```bash
kubectl delete pod crasher -n dev
```

### Exercise 13.2 — Debug an ImagePullBackOff

```bash
kubectl run badimage -n dev --image=nginx:nonexistent-tag --restart=Never
```

Diagnose:

```bash
kubectl get pods -n dev badimage
# Expected: ImagePullBackOff or ErrImagePull

kubectl describe pod badimage -n dev | grep -A5 "Events"
# Expected: "Failed to pull image" with details
```

Clean up:

```bash
kubectl delete pod badimage -n dev
```

### Exercise 13.3 — Debug resource exhaustion

```bash
# Deploy a Pod with impossibly high resource requests
kubectl run greedy -n dev --image=nginx:1.27-alpine \
    --overrides='{"spec":{"containers":[{"name":"greedy","image":"nginx:1.27-alpine","resources":{"requests":{"cpu":"100","memory":"256Gi"}}}]}}'
```

```bash
kubectl get pods -n dev greedy
# Expected: Pending (not enough resources)

kubectl describe pod greedy -n dev | grep -A3 "Events"
# Expected: "Insufficient cpu" or "Insufficient memory"
```

Clean up:

```bash
kubectl delete pod greedy -n dev
```

---

## 14. Cleanup

### Remove all lab resources

```bash
# Delete all resources in practice namespaces
kubectl delete namespace dev staging prod

# Delete the kind cluster
kind delete cluster --name k8s-lab
```

Verify cleanup:

```bash
# No clusters should remain (unless you have others)
kind get clusters

# Docker containers for the cluster should be gone
docker ps --filter "name=k8s-lab"
```

---

## 15. Interview Talking Points

### Kubernetes Operations Experience

> "I set up a multi-node Kubernetes cluster locally using kind and practiced the full deployment lifecycle — creating Deployments, Services, ConfigMaps, and Secrets. I used rolling updates with zero-downtime and practiced rollbacks. I'm familiar with the Deployment > ReplicaSet > Pod hierarchy and how Kubernetes self-heals when Pods fail."

### CLI Tooling and Efficiency

> "Beyond kubectl, I use K9s for real-time cluster monitoring, kubectx + kubens for safe context and namespace switching, and Stern for multi-pod log tailing. These tools are essential for incident response — K9s gives me an immediate overview of cluster health, and Stern lets me correlate logs across Pods without checking each one individually."

### Troubleshooting Methodology

When asked "A Pod is stuck in CrashLoopBackOff — walk through your debugging steps":

1. `kubectl get pods` — see the status and restart count
2. `kubectl describe pod <name>` — check events for error messages
3. `kubectl logs <name>` — see container output before crash
4. `kubectl logs <name> --previous` — see logs from the previous (crashed) container
5. Check exit code — exit 1 = app error, exit 137 = OOMKilled, exit 139 = segfault
6. `kubectl get events --sort-by='.lastTimestamp'` — broader cluster context

### ConfigMaps and Secrets

Key points to mention:
- **ConfigMaps** decouple configuration from images — same image across dev/staging/prod
- **Secrets** are base64-encoded by default, NOT encrypted — enable encryption at rest
- Both can be consumed as environment variables or volume-mounted files
- Volume-mounted ConfigMaps update automatically; env vars require Pod restart

### Service Networking

| Type | Scope | When to use |
|------|-------|-------------|
| ClusterIP | Internal only | Service-to-service communication |
| NodePort | External via node IP | Dev/test access |
| LoadBalancer | External via cloud LB | Production external access |
| Ingress | HTTP/HTTPS routing | Multiple services behind one entry point |

### Resource Management

> "Resource requests guarantee scheduling — the Pod won't start unless a node can fulfill the request. Limits cap usage — exceeding memory limits causes OOMKill. In a shared cluster with 29,000 sites, proper requests and limits are critical to prevent one tenant from starving others."

### Common kubectl Commands to Know

```bash
# Cluster state
kubectl get nodes
kubectl get pods -A
kubectl top pods -n <ns>          # requires metrics-server
kubectl get events --sort-by='.lastTimestamp'

# Deployments
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl scale deployment/<name> --replicas=5

# Debugging
kubectl describe pod <name>
kubectl logs <name> --previous
kubectl exec -it <name> -- /bin/sh
kubectl port-forward svc/<name> 8080:80

# Config
kubectl get configmap <name> -o yaml
kubectl get secret <name> -o jsonpath='{.data.KEY}' | base64 -d

# Context management (with kubectx/kubens)
kubectx                           # list contexts
kubectx <context>                 # switch context
kubens <namespace>                # switch namespace
```

---

## Quick Reference: File Summary

| File | Purpose |
|------|---------|
| `kind-config.yml` | Multi-node kind cluster configuration |
| `manifests/01-namespaces.yml` | Practice namespaces (dev, staging, prod) |
| `manifests/02-deployment-nginx.yml` | Basic nginx Deployment (3 replicas) |
| `manifests/03-service-nginx.yml` | ClusterIP and NodePort Services |
| `manifests/04-configmap.yml` | ConfigMap with key-values and file data |
| `manifests/05-secret.yml` | Secret with base64-encoded database credentials |
| `manifests/06-deployment-with-config.yml` | Deployment consuming ConfigMap + Secret |
| `manifests/07-probes.yml` | Deployment with liveness/readiness/startup probes |
| `manifests/08-statefulset.yml` | MySQL StatefulSet with PVC |
| `manifests/09-multi-pod-logging.yml` | Multi-Deployment setup for Stern practice |
| `scripts/install-tools.sh` | Installs all required CLI tools |

---

**Next steps after this exercise:**
- Deploy the StatefulSet manifest (`08-statefulset.yml`) and practice StatefulSet vs Deployment differences
- Install an Ingress controller and practice HTTP routing with manifests
- Explore Krew (kubectl plugin manager) to install additional plugins like `kubectl-neat` and `kube-capacity`
- Practice writing your own manifests from scratch instead of applying the provided ones
- Try deploying a WordPress stack on Kubernetes, connecting it to the MySQL StatefulSet
