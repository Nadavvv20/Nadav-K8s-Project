# Scalable WordPress Deployment on Kubernetes 🚀

## 1. Project Overview 📋
This project executes a robust migration of a WordPress application from a Docker-Compose environment to a production-ready Kubernetes cluster. The primary goal was to enhance scalability, reliability, and manageability by leveraging Kubernetes orchestration, Helm package management, and AWS ECR for container storage.

## 2. Containerization Lifecycle 📦
The migration began with preparing the container images for the cloud environment:
1.  **Build & Tag**:
    *   Pulled the official WordPress and MySQL images.
    *   Tagged them specifically for the Amazon Elastic Container Registry (ECR) target repositories (e.g., `nadav-project/wordpress`, `nadav-project/mariadb`).
2.  **Registry Push**:
    *   Authenticated the local Docker client with AWS ECR using `aws ecr get-login-password`.
    *   Pushed the tagged images to the private ECR repositories to ensure secure and reliable image availability for the cluster.

## 3. Helm Package Structure 📂
The application is packaged as a unified Helm chart for consistent deployment:

```text
wordpress-project/
├── Chart.yaml                  # Chart metadata and versioning
├── values.yaml                 # Configuration defaults (image refs, replicas, ports)
└── templates/
    ├── ingress.yaml            # Ingress rules for external access
    ├── mysql-statefulset.yaml  # StatefulSet for database consistency
    ├── secret.yaml             # Encoded secrets for DB credentials
    └── wordpress_deployment.yaml # Deployment logic for the WordPress app
```

## 4. Infrastructure & Automation 🏗️
*   **Minikube Addons**: Utilized the `registry-creds` addon (`minikube addons enable registry-creds`) to automate the retrieval and renewal of AWS ECR credentials, allowing the cluster to pull private images seamlessly without manual secret rotation.
*   **Helm Orchestration**: The entire stack—including the application, database, ingress rules, and secrets—is managed as a single atomic Helm release (`wordpress-release`).
*   **Port-Forwarding Strategy**: To bridge the gap between the EC2/Minikube isolated network and the user, custom scripts in the `bin/` directory manage port forwarding background processes, mapping local ports to Ingress/Service ports (8080 -> 80, 3000 -> Grafana).

## 5. Deployment Workflow 🚀

*   Kubernetes Cluster (Minikube on EC2)
*   Tools: `kubectl`, `helm`, `aws-cli`

### Step 1: Ingress Controller
Installed the NGINX Ingress Controller to manage external access. This was preferred over simple NodePorts to simulate a production-grade routing layer.
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
```

### Step 2: Application Deployment
Deployed the custom Helm chart. This single command instantiates all resources defined in the package structure, including 2 replicas of the wordpress pod.
```bash
helm install wordpress-release ./wordpress-project
```

### Step 3: Access
Executed the port-forwarding automation script to expose the application:
```bash
./bin/port-forwardings.sh
```

## 6. Observability Implementation 📊
*   **Monitoring Stack**: Deployed the **kube-prometheus-stack** to provide a complete monitoring solution (Prometheus, Grafana, Alertmanager).
*   **Uptime Monitoring**: Configured a custom **Uptime Panel** in Grafana to track the duration of pod operation.
    *   **Query**: `time()-kube_pod_start_time{namespace="default", pod=~"wordpress.*"}`
    *   **Purpose**: Visualizes the uptime duration of the WordPress pods since their last start.

## 7. Definition of Done Verification ✅
The project meets the following criteria:
*   [x] **Reachability**: Application is successfully reachable via the Ingress hostname/localhost mapped port.
*   [x] **Persistence**: Database data survives pod restarts, guaranteed by the implementation of **StatefulSets** and **Persistent Volume Claims (PVC)**.
*   [x] **Versioning**: The entire infrastructure configuration is versioned in Git and packaged via **Helm**.

## 8. Cleanup 🧹
To uninstall the release and free up resources:
```bash
helm uninstall wordpress-release
minikube delete
```