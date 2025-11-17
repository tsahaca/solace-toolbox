# How to create & run solace stm docker image 

1. Create a github repo with Dockerfile 

2. Create a ImageStream in your projcet ns

```bash
oc project solace-clients

oc apply -f - <<'EOF'
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: stm-cli
EOF
```
3. Create a BuildConfig 

```bash
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: stm-cli-build
spec:
  source:
    type: Git
    git:
      uri: https://github.com/your-org/your-stm-dockerfile-repo.git
  strategy:
    type: Docker
    dockerStrategy: {}
  output:
    to:
      kind: ImageStreamTag
      name: stm-cli:latest
```
4. Start the build in OpenShift using BuildConfig as

```bash
oc start-build stm-cli-build --follow
```

5. Start the pod as 
```bash
oc run stm-cli \
  --image=image-registry.openshift-image-registry.svc:5000/solace-clients/stm-cli:latest \
  --restart=Never \
  --command -it -- /bin/sh
```
