# Kubernetes Interview Preparation Guide

## Introduction

For a mid-level Full-stack engineer, Kubernetes interview questions typically bridge the gap between application development and basic cluster operations. To prepare, you can set up a minimal environment using lightweight tools like Minikube or kind, which run effectively on most modern laptops.

## Popular Mid-Level Full-Stack Interview Questions

Interviews for this role focus on how you interact with a cluster to deploy, scale, and troubleshoot your applications.

### Workload Management

- Explain the difference between a Pod and a Container.
- When would you use a StatefulSet instead of a Deployment (e.g., for databases vs. stateless web apps)?
- How do you perform a rolling update and a rollback of a service?

### Networking & Services

- Explain the roles of ClusterIP, NodePort, and LoadBalancer service types.
- What is an Ingress, and why would you use it over multiple LoadBalancer services?

### Configuration & Secrets

- How do you decouple application configuration from code using ConfigMaps and Secrets?
- Explain how to mount a Secret as an environment variable or a volume.

### Troubleshooting & Health

- What are Liveness, Readiness, and Startup probes, and how do they impact app availability?
- You have a Pod stuck in CrashLoopBackOff; walk through your debugging steps (e.g., `kubectl logs`, `kubectl describe`).

### Resource Management

- What is the difference between Resource Requests and Limits, and why are they critical for cluster stability?

## Minimum Local Practice Environment

You can run a practice cluster on a machine with as little as 2 CPUs, 2GB RAM, and 20GB disk space. The following tools are the standard "minimum" setups:

| Tool | Best For | Requirement Highlights |
|------|----------|------------------------|
| Minikube | General learning & experimenting | Runs a single-node cluster in a VM or Docker. |
| kind (K8s in Docker) | CI/CD testing & multi-node practice | Extremely lightweight; runs nodes as Docker containers. |
| K3s | Low-resource or edge devices | A lightweight binary (under 100MB) from Rancher. |

## Recommended Setup Strategy

- **Install kubectl**: The primary CLI for communicating with any cluster.
- **Enable Docker Desktop K8s**: If you use Docker Desktop, simply check "Enable Kubernetes" in settings for an instant local environment.
- **Use Lens**: A visual dashboard that helps you understand the relationships between objects (Deployments → ReplicaSets → Pods) without only relying on the CLI.

## Popular CLI Tools & Helpers

Research the popular CLI tools or programming language along with using kubectl. While kubectl is the standard tool for managing Kubernetes, a large ecosystem of CLI tools and programming libraries exists to streamline common tasks like switching clusters, debugging logs, and automating deployments. These tools often integrate directly with your terminal or provide a more user-friendly interface than raw kubectl commands.

| Tool | Category | Description |
|------|----------|-------------|
| kubectx + kubens | Cluster & Context Management | Widely used to switch between clusters (contexts) and namespaces quickly. |
| Krew | Cluster & Context Management | The official plugin manager for kubectl, used to discover and install over 200 community-maintained plugins. |
| kube-ps1 | Cluster & Context Management | Adds your current Kubernetes context and namespace to your shell prompt (Bash/Zsh) to prevent accidental commands on the wrong cluster. |
| K9s | Debugging & Observability | A terminal-based UI that provides a live, keyboard-driven dashboard for navigating and managing cluster resources. |
| Stern | Debugging & Observability | Allows you to tail multiple pods and containers simultaneously with color-coded output, which is more powerful than kubectl logs. |
| kubectl-neat | Debugging & Observability | Removes redundant information (like creationTimestamp or uid) from kubectl get output to make manifests easier to read. |
| access-matrix | Specialized Plugins | Formerly known as rakkess, it shows a matrix of your RBAC permissions across all resources. |
| kube-capacity | Specialized Plugins | Provides a snapshot of resource requests, limits, and utilization across nodes. | 

Programming Languages & Client Libraries
If you need to automate cluster management through code rather than scripts, use official or community-maintained Client Libraries. These allow your application to perform any operation kubectl can do. 
Language 
	Primary Library	Notes
Go	client-go	The "gold standard"; used by Kubernetes itself and most operators.
Python	kubernetes-python	Official client; popular for CI/CD automation and writing custom operators.
Java	fabric8	A highly popular community alternative to the official Java client, with extensive features.
JavaScript/TS	kubernetes-client/javascript	Official library for Node.js and TypeScript applications.
Rust	kube-rs	The most active community client for building performant and safe tools in Rust.
