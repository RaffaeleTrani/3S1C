---
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      networkservicemesh.io/app: "firewall"
      networkservicemesh.io/impl: "hybrid-example"
  replicas: 1
  template:
    metadata:
      labels:
        networkservicemesh.io/app: "firewall"
        networkservicemesh.io/impl: "hybrid-example"
    spec:
      serviceAccount: nse-acc
      affinity:
          nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                      - matchExpressions:
                        - key: kubernetes.io/hostname
                          operator: In
                          values:
                            - cube4
      containers:
        - name: vppagent-firewall-nse
          image: raffaeletrani/vpp-test-common:prova
          imagePullPolicy: IfNotPresent
          env:
            - name: TEST_APPLICATION
              value: "vppagent-firewall-nse"
            - name: ENDPOINT_NETWORK_SERVICE
              value: "hybrid-example"
            - name: ENDPOINT_LABELS
              value: "app=firewall"
            - name: CLIENT_NETWORK_SERVICE
              value: "hybrid-example"
            - name: CLIENT_LABELS
              value: "app=firewall"
          resources:
            limits:
              networkservicemesh.io/socket: 1
          volumeMounts:
            - mountPath: /etc/vppagent-firewall/config.yaml
              subPath: config.yaml
              name: vppagent-firewall-config-volume
      volumes:
        - name: vppagent-firewall-config-volume
          configMap:
            name: vppagent-firewall-config-file
metadata:
  name: vpp-firewall
  namespace: default
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vppagent-firewall-config-file
  namespace: default
data:
  config.yaml: |
    aclRules:
      "Allow ICMP": "action=reflect,icmptype=8"
      "Allow TCP": "action=reflect,tcplowport=5201,tcpupport=5201"
