HERE=$(dirname $0)
eval $(sh $HERE/../scripts/get_registries.sh)

cat <<EOF
---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    service: ambassador-admin
  name: ambassador-admin
spec:
  type: NodePort
  ports:
  - name: ambassador-admin
    port: 8888
    targetPort: 8888
  selector:
    service: ambassador
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  creationTimestamp: null
  name: ambassador
spec:
  replicas: 1
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        service: ambassador
        # service: ambassador-admin
    spec:
      containers:
      - name: ambassador
        image: ${AMREG}ambassador:0.8.6
        # ports:
        # - containerPort: 80
        #   protocol: TCP
        resources:
          limits:
            cpu: 1
            memory: 400Mi
          requests:
            cpu: 200m
            memory: 100Mi
        volumeMounts:
        - mountPath: /etc/certs
          name: cert-data
        - mountPath: /etc/cacert
          name: cacert-data
      - name: statsd
        image: ${STREG}statsd:0.8.6
        resources: {}
      volumes:
      - name: cert-data
        secret:
          secretName: ambassador-certs
      - name: cacert-data
        secret:
          secretName: ambassador-cacert
      restartPolicy: Always
status: {}
EOF
