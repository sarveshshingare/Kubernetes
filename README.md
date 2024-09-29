# Deploying a React App on Kubernetes

This guide provides step-by-step instructions for deploying a React application on a Kubernetes cluster. It covers Dockerization, creating a Kubernetes Deployment and Service, and checking the status of the deployment.

## Table of Contents
- [Deploying a React App on Kubernetes](#deploying-a-react-app-on-kubernetes)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Build React App](#build-react-app)
  - [Dockerizing the React App](#dockerizing-the-react-app)
  - [Creating a Kubernetes Deployment](#creating-a-kubernetes-deployment)
  - [Creating a Kubernetes Service](#creating-a-kubernetes-service)
  - [Checking LoadBalancer Status](#checking-loadbalancer-status)
  - [Accessing the App](#accessing-the-app)
  - [Scaling the Application](#scaling-the-application)
    - [1. Scaling Pods Manually](#1-scaling-pods-manually)
    - [2. Scaling Pods Dynamically](#2-scaling-pods-dynamically)
  - [Conclusion](#conclusion)

## Prerequisites

- **Kubernetes Cluster**: Ensure you have access to a Kubernetes cluster. For local development, you can use [Minikube](https://minikube.sigs.k8s.io/docs/start/).
- **kubectl**: Install the Kubernetes command-line tool [kubectl](https://kubernetes.io/docs/tasks/tools/).
- **Docker**: Ensure Docker is installed to build your container image.
- **Note**: Make sure your Docker Desktop is running before you try the below steps.

## Build React App
1. **First, build the production-ready React app:**
   ```bash
   npm run build
   ```
   This will generate a `build/` folder containing the static files to serve. 
   **Note:** You might have a different name (e.g., `dist/`) where build files are present. Make sure you specify the correct path in the below steps.

## Dockerizing the React App
Open your React project folder.
2. **Create a Dockerfile in the root directory of your React app:**

   ```dockerfile
   # Use the official Node.js image as the base image
   FROM node:16 as build

   # Set the working directory
   WORKDIR /app

   # Copy package.json and package-lock.json
   COPY package*.json ./

   # Install dependencies
   RUN npm install

   # Copy the rest of the application code
   COPY . .

   # Build the React application
   RUN npm run build

   # Use Nginx to serve the app
   FROM nginx:alpine
   # Make sure you describe the correct folder where your build files are present
   COPY --from=build /app/build /usr/share/nginx/html  

   # Expose port 80
   EXPOSE 80

   # Start Nginx
   CMD ["nginx", "-g", "daemon off;"]
   ```

3. **Log in to Docker Hub:**

   Before pushing your Docker image, log in to your Docker Hub account:

   ```bash
   docker login
   ```
   Enter your Docker Hub username and password when prompted.
   
4. **Build the Docker image:**

   ```bash
   docker build -t <your-dockerhub-username>/react-app:v1 .
   ```

5. **Push the image to Docker Hub:**

   ```bash
   docker push <your-dockerhub-username>/react-app:v1
   ```

## Creating a Kubernetes Deployment

1. **Create a Deployment YAML file (e.g., `deployment.yaml`):**

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: react-app-deployment
   spec:
     replicas: 1  # Adjust as necessary
     selector:
       matchLabels:
         app: react-app
     template:
       metadata:
         labels:
           app: react-app
       spec:
         containers:
         - name: react-app
           image: <your-dockerhub-username>/react-app:v1
           ports:
           - containerPort: 80
   ```

2. **Apply the Deployment:**

   ```bash
   kubectl apply -f deployment.yaml
   ```

## Creating a Kubernetes Service

1. **Create a Service YAML file (e.g., `service.yaml`):**

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: react-app-service
   spec:
     type: LoadBalancer
     selector:
       app: react-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
   ```

2. **Apply the Service:**

   ```bash
   kubectl apply -f service.yaml
   ```

## Checking LoadBalancer Status

1. **Check the status of the service:**

   ```bash
   kubectl get services
   ```

   **Note:** Wait for the `EXTERNAL-IP` to be assigned (if using a cloud provider) or run `minikube tunnel` if you're on Minikube.

## Accessing the App

1. **Once you have the `EXTERNAL-IP`, open it in your browser:**

   ```
   http://<EXTERNAL-IP>
   ```

   - Alternatively, if you are using Minikube, access it at:

   ```
   http://<minikube_ip>:<nodePort>
   ```

## Scaling the Application
### 1. Scaling Pods Manually
1. **Update the Number of Replicas in the Deployment YAML**
   In the Deployment YAML file, change the replicas field to the desired number of pods. For example, if you want to run 3 replicas, update the YAML like this:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: react-app-deployment
   spec:
     replicas: 3  # Increase this to 3 replicas
     selector:
       matchLabels:
         app: react-app
     template:
       metadata:
         labels:
           app: react-app
       spec:
         containers:
         - name: react-app
           image: <your-dockerhub-username>/react-app:v1
           ports:
           - containerPort: 80
   ```

2. **Apply the Updated Deployment**
   After updating the YAML, apply it using kubectl:
   ```bash
   kubectl apply -f react-app-deployment.yaml
   ```

   This will scale your React app to run 3 pods.

3. **Verify the number of pods:**

   ```bash
   kubectl get pods
   ```

### 2. Scaling Pods Dynamically
1. **To scale your application:**

   Update the `replicas` field in your `deployment.yaml` file or run:

   ```bash
   kubectl scale deployment react-app-deployment --replicas=3
   ```

2. **Verify the number of pods:**

   ```bash
   kubectl get pods
   ```

## Conclusion

Congratulations on successfully deploying your React application on Kubernetes! Enjoy exploring and scaling your application further! If you have any questions or need assistance, feel free to reach out.
