# Deploying a React App on Kubernetes

This guide provides step-by-step instructions for deploying a React application on a Kubernetes cluster. It covers Dockerization, creating a Kubernetes Deployment and Service, and checking the status of the deployment.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Dockerizing the React App](#dockerizing-the-react-app)
3. [Creating a Kubernetes Deployment](#creating-a-kubernetes-deployment)
4. [Creating a Kubernetes Service](#creating-a-kubernetes-service)
5. [Checking LoadBalancer Status](#checking-loadbalancer-status)
6. [Accessing the App](#accessing-the-app)
7. [Scaling the Application](#scaling-the-application)
8. [Conclusion](#conclusion)

## Prerequisites

- **Kubernetes Cluster**: Ensure you have access to a Kubernetes cluster. For local development, you can use [Minikube](https://minikube.sigs.k8s.io/docs/start/).
- **kubectl**: Install the Kubernetes command-line tool [kubectl](https://kubernetes.io/docs/tasks/tools/).
- **Docker**: Ensure Docker is installed to build your container image.
- **Note**: Make sure Your Docker Desktop is running Before your try the below steps.
  
## Dockerizing the React App
Open your react project folder 
1. **Create a Dockerfile in the root directory of your React app:**

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
   COPY --from=build /app/build /usr/share/nginx/html

   # Expose port 80
   EXPOSE 80

   # Start Nginx
   CMD ["nginx", "-g", "daemon off;"]
   ```

2. **Build the Docker image:**

   ```bash
   docker build -t your-dockerhub-username/react-app:v1 .
   ```

3. **Push the image to Docker Hub:**

   ```bash
   docker push your-dockerhub-username/react-app:v1
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
           image: your-dockerhub-username/react-app:v1
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

   - Wait for the `EXTERNAL-IP` to be assigned (if using a cloud provider) or run `minikube tunnel` if you're on Minikube.

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

You have successfully deployed your React application on Kubernetes! You can manage and scale your application as needed using Kubernetes’ powerful orchestration capabilities. For more advanced features, consider exploring Kubernetes concepts like **ConfigMaps**, **Secrets**, and **Ingress Controllers**.

---

Feel free to customize any part of this documentation to better fit your project or personal style! Let me know if you need further modifications or additional sections.
