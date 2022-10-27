#! /bin/bash

generate_http_conf () {
  UPSTREAMS=""
  LOCATIONS=""
  IFS='' read -ra INGRESSES <<<"$(kubectl get ingress -o name)"
  for i in "${INGRESSES[@]}"; do
    SERVICE_NAME=$(kubectl get "$i" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
    IFS='' read -ra ENDPOINTS <<<"$(kubectl get endpoints "$SERVICE_NAME" -o jsonpath='{.subsets[0].addresses[*].ip}')"
    PORT=$(kubectl get endpoints "$SERVICE_NAME" -o jsonpath='{.subsets[0].ports[0].port}')
    HTTP_PATH=$(kubectl get "$i" -o jsonpath='{.spec.rules[0].http.paths[0].path}')

    UPSTREAM=$(printf "upstream %s {" "$SERVICE_NAME")$'\n'
    for endpoint in "${ENDPOINTS[@]}"; do
      UPSTREAM+=$(printf "server %s:%s;" "$endpoint" "$PORT")$'\n'
    done
    UPSTREAM+="}"

    LOCATION=$(printf "location %s {\nproxy_pass http://%s;\n}" "$HTTP_PATH" "$SERVICE_NAME")

    UPSTREAMS+=$(printf "%s" "$UPSTREAM")$'\n'
    LOCATIONS+=$(printf "%s" "$LOCATION")$'\n'
  done

    cat > /etc/nginx/conf.d/default.conf <<-EOF
$UPSTREAMS

server {
  listen 80;
  $LOCATIONS
}
EOF
}

while true
do
  generate_http_conf
  nginx -s reload
  sleep 1
done
