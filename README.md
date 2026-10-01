# platform-gitops

Repo ArgoCD đọc. Xem `Guide.md` (Phase 2).

```
bootstrap/        argocd-values.yaml (cài ArgoCD bằng Helm, một lần) + root-app.yaml (app-of-apps)
platform/         Application cho add-ons: ingress-nginx, cert-manager, external-secrets, platform-config
platform-config/  ClusterSecretStore trỏ Secrets Manager của Floci
charts/backend-service/   Helm chart dùng chung cho mọi app
apps/<app>/values-{dev,prod}.yaml
applicationsets/apps.yaml  app x env; dev auto-sync + self-heal, prod sync tay
optional/         cloudflared (cần token Cloudflare, không sync tự động)
```

## Bootstrap (một lần)
```bash
kubectl create ns external-secrets
kubectl -n external-secrets create secret generic floci-aws-creds \
  --from-literal=access-key=<id> --from-literal=secret-access-key=<secret>     # không commit
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd --version 10.9.6 -n argocd --create-namespace -f bootstrap/argocd-values.yaml
kubectl apply -n argocd -f bootstrap/root-app.yaml
```

## Lưu ý riêng của lab Floci
- Image của Phase 2 nạp tay vào k3s (CI ở Phase 3 sẽ thay bằng GHCR):
  `docker save order-service:local | docker exec -i floci-eks-platform-dev ctr --address /run/k3s/containerd/containerd.sock -n k8s.io images import -`
- ESO gọi Floci bằng IP container trong `platform/external-secrets.yaml` (pod không resolve được tên `floci`); sửa nếu IP đổi.
- ingress-nginx đã được cộng đồng K8s thông báo ngừng bảo trì (từ 3/2026); chart vẫn chạy được cho lab, production nên cân nhắc Gateway API / Traefik.
