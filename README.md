# Scalable WordPress Deployment on Kubernetes 🚀

## 1. Project Overview 📋

### Purpose
The goal of this project is to migrate a WordPress application from a Docker-Compose setup to a production-ready Kubernetes environment. This transition enhances scalability, reliability, and manageability of the application.

### Core Components
*   **WordPress**: The core content management system.
*   **MySQL**: Relational database for storing WordPress data.
*   **NGINX Ingress**: Manages external access to the services in the cluster.
*   **Prometheus-Grafana Stack**: Provides comprehensive monitoring and visualization.

## 2. Architecture Design 🏗️

### Infrastructural Layout
Traffic enters the cluster through the **NGINX Ingress Controller**, which routes HTTP requests to the `wordpress` service. 

**Why NGINX Ingress?**
The Ingress Controller is a critical component that acts as the single entry point for all external traffic entering the cluster. Unlike simple NodePort services, it provides a production-grade routing layer that:
*   **Centralizes Access**: Eliminates the need to expose a separate LoadBalancer or NodePort for every service.
*   **Efficient Routing**: Intelligently routes HTTP/HTTPS traffic to the correct internal pods based on hostnames or paths.
*   **Scalability**: Decouples the routing configuration from the application logic, making it easier to scale and manage multiple services.

### Persistence Layer
To ensure data reliability and persistence, the database utilizes:
*   **StatefulSets**: Guarantees the deployment order and uniqueness of the MySQL pod.
*   **Persistent Volume Claims (PVC)**: `mysql-persistent-storage` creates a persistent volume to store database data, ensuring it survives pod restarts.

### Networking
*   **Dynamic Site URL**: The WordPress configuration (`wp-config.php`) is dynamically updated using environment variables (`WORDPRESS_CONFIG_EXTRA`) to set `WP_HOME` and `WP_SITEURL` based on the incoming `HTTP_HOST`. This allows the site to work correctly under port-forwarding (e.g., `localhost:8080`).
*   **Internal Communication**: Services communicate via internal DNS names (e.g., `wordpress-db` for the database).

## 3. Prerequisites 🛠️

### Environment
*   **EC2 Instance**: Managing a Minikube cluster.
*   **Minikube**: A local Kubernetes tool for learning and developing.

### Tools
Ensure you have the following installed:
*   `kubectl`
*   `helm`
*   `aws-cli`

### Access
*   **AWS ECR**: An IAM role with permissions to pull images from Amazon ECR must be attached to the EC2 instance.

### Minikube Addons
*   **registry-creds**: This addon must be enabled to handle ECR authentication automatically.
    ```bash
    minikube addons enable registry-creds
    ```

## 4. Installation & Deployment 🚀

### Repository Setup
Clone the repository to your local machine:
```bash
git clone <repository-url>
cd <repository-folder>
```

### Secrets Management
*   **DB Credentials**: Managed via the `templates/secret.yaml` file in the Helm chart, ensuring secure password injection into both WordPress and MySQL components.
*   **ECR Pull Secrets**: Handled automatically by the `registry-creds` addon.

### Ingress Controller Setup
Before deploying the application stack, you must install the NGINX Ingress Controller using Helm. This controller will manage the external access to your services.

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install my-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
```

### Helm Deployment
Deploy the entire stack using the custom Helm chart:
```bash
helm install wordpress-release ./wordpress-project
```

## 5. Accessing the Application 🌐

### Ingress Configuration
The application is exposed via the NGINX Ingress Controller. You can access it by mapping your local hostname or using the provided automation scripts.

### Automation Scripts
The `bin/` directory contains helper scripts to streamline access:

*   **Start Minikube**:
    ```bash
    ./bin/run_minikube.sh
    ```
    Starts Minikube with the Docker driver and optimized resources (12GB RAM, 3 CPUs).

*   **Port Forwarding**:
    ```bash
    ./bin/port-forwardings.sh
    ```
    Establishes port-forwarding for:
    *   **WordPress**: `http://<EC2_IP>:8080` (mapped to Ingress port 80)
    *   **Grafana**: `http://<EC2_IP>:3000`
    *   **Prometheus**: `http://<EC2_IP>:9090`

## 6. Monitoring & Observability 📊

### Stack Overview
The project integrates with the **kube-prometheus-stack** to collect metrics from the cluster and applications.

### Custom Metrics
A custom **Uptime Panel** has been configured in Grafana to monitor the health and uptime of the WordPress and MySQL containers.

### Usage
1.  Run the port-forwarding script.
2.  Open your browser to `http://<EC2_IP>:3000`.
3.  Log in with the default credentials (usually `admin` / `prom-operator` or check your specific setup).

## 7. Cleanup 🧹

### Teardown
To remove the release and delete resources:

```bash
helm uninstall wordpress-release
minikube delete
```