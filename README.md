# Kubernetes + Helm + Argo CD | Práctica GitOps

Proyecto de aprendizaje para DevOps / DevSecOps: aplicación Nginx empaquetada con Helm, desplegada en Kubernetes (Kind) y reconciliada automáticamente por Argo CD desde GitHub.

## Requisitos

- Windows, Docker Desktop con **WSL Integration → Ubuntu** habilitada.
- Ubuntu WSL 2. Todas las órdenes de los scripts de este README se ejecutan **en la terminal Ubuntu**, no en PowerShell.
- Acceso a Internet y recursos libres en Docker Desktop (conviene detener temporalmente los stacks PGL y ELK, sin borrarlos).
- Un repositorio **público y vacío** en GitHub llamado `devops-helm-gitops` (sin inicializar README). No uses el GitHub de tu empresa para este ejercicio personal.

## Estructura

```text
helm/devops-web/
  Chart.yaml
  values.yaml           # replicaCount: 1 → 2
  templates/
    configmap.yaml
    deployment.yaml
    service.yaml
argocd/application.yaml # REEMPLAZAR TU_USUARIO antes de usar
kind/cluster.yaml
scripts/
ENTREGA.md
```

## A. Instalación local (Ubuntu WSL)

Abre esta carpeta en Antigravity, después ejecuta **PowerShell** `wsl -d Ubuntu`. Verifica que el indicador del terminal termina con `$`. Si el terminal sigue en la carpeta del proyecto, ejecuta:

```bash
bash scripts/01-instalar-herramientas-wsl.sh
bash scripts/02-crear-cluster.sh
kubectl get nodes
helm lint helm/devops-web
```

Si `docker info` no responde en WSL, abre Docker Desktop, ve a Settings → Resources → WSL Integration y habilita Ubuntu. Deja Docker Desktop abierto.

## B. Probar Helm de forma local (antes de GitOps)

```bash
helm install devops-web ./helm/devops-web -n devops --create-namespace --wait --timeout 5m
kubectl -n devops get deploy,pods,svc
```

Captura el resultado de la instalación. **Luego retira solo el release local** antes de activar Argo CD, para no tener dos sistemas gestionando los mismos recursos:

```bash
helm uninstall devops-web -n devops
```

El namespace permanece creado y Argo CD podrá utilizarlo.

## C. Crear repositorio en GitHub

En GitHub (tu cuenta personal), crea un repositorio **Public** llamado `devops-helm-gitops`, sin marcar la opción de README ni .gitignore. Edita antes `argocd/application.yaml`, cambiando `TU_USUARIO` por el nombre de usuario real. Desde la **terminal Ubuntu**, en la raíz del proyecto:

```bash
git init
git branch -M main
git add .
git commit -m "Agregar Helm Chart y configuracion GitOps"
git remote add origin https://github.com/TU_USUARIO/devops-helm-gitops.git
git push -u origin main
```

Sustituye también `TU_USUARIO` en el comando de `git remote`. Si Git pide identidad, configura primero `git config user.name "Tu nombre"` y `git config user.email "tu-correo-de-github"` (sin credenciales en archivos). Para el push, inicia sesión en GitHub con tu método habitual o usa un token de acceso: nunca coloques contraseñas o tokens en el repositorio.

## D. Instalar y abrir Argo CD

```bash
bash scripts/03-instalar-argocd.sh
```

En una **segunda terminal Ubuntu** (déjala abierta), ejecuta:

```bash
kubectl -n argocd port-forward svc/argocd-server 8085:443
```

Abre https://localhost:8085 (acepta la advertencia de certificado local para esta práctica). Usuario `admin`. Recupera su contraseña inicial en otra terminal Ubuntu:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

**No compartas la contraseña en capturas**. La instalación no expone Argo CD a Internet.

## E. Sincronización GitOps

Revisa que `argocd/application.yaml` tenga la URL REAL de tu GitHub y que el push se completó. Ejecuta:

```bash
kubectl apply -f argocd/application.yaml
kubectl -n argocd get applications
kubectl -n devops get deploy,pods,svc
```

Espera hasta que la app muestre `Healthy` + `Synced` en Argo CD UI. La sincronización inicial puede demorar minutos mientras se descargan las imágenes.

Para ver Nginx en otro terminal:

```bash
kubectl -n devops port-forward svc/devops-web 8081:80
```

Visita http://localhost:8081.

## F. Probar el cambio automático (capturas cruciales)

1. Abre `helm/devops-web/values.yaml`, cambia `replicaCount: 1` por `replicaCount: 2` y guarda.
2. Desde Ubuntu WSL y en la raíz del proyecto:

```bash
git add helm/devops-web/values.yaml
git commit -m "GitOps: escalar aplicacion de 1 a 2 replicas"
git push
```

3. Espera el intervalo de reconciliación de Argo CD y comprueba:

```bash
kubectl -n devops rollout status deployment/devops-web --timeout=180s
kubectl -n devops get deployment devops-web
kubectl -n devops get pods -o wide
kubectl -n argocd get applications
```

**Evidencia correcta:** `devops-web` con **READY 2/2**, dos pods `Running`, Argo CD en estado **Healthy / Synced** y el commit visible en GitHub. Una app puede tardar 2–3 minutos en detectar el push, dependiendo de la configuración y el sondeo del repositorio.

### Rollback (opcional, solicitado en la actividad)

Si el último commit es el que cambió las réplicas y no hay cambios locales sin guardar:

```bash
git revert --no-edit HEAD
git push
```

Observa Argo CD y luego comprueba `kubectl -n devops get deploy,pods`. El estado deseado regresa a 1 réplica. Es una reversión **desde Git**, no una modificación manual del clúster.

## G. Evidencias

```bash
bash scripts/04-guardar-evidencias.sh
```

Guarda capturas de Argo CD, `kubectl`, el commit de GitHub y la aplicación web. Completa `ENTREGA.md` con el enlace real. **No existen capturas reales pre-generadas**: debes tomarlas cuando los servicios estén operativos.

## Problemas comunes

- `kind: command not found` → `bash scripts/01-instalar-herramientas-wsl.sh`.
- `Cannot connect to Docker daemon` → habilita la integración Ubuntu en Docker Desktop.
- `kubectl get nodes` no responde → `kind export kubeconfig --name devops-gitops`.
- Argo CD indica `Unknown` o `ComparisonError` → revisa que `repoURL` no contenga `TU_USUARIO`, que el repo sea público y que exista `main` con el directorio `helm/devops-web`.
- UI en blanco → verifica port-forward y `kubectl -n argocd get pods`.
- Error de recursos insuficientes → detén **únicamente** stacks de prácticas anteriores (no ejecutes `docker system prune` ni borres volúmenes).
- `git push` rechaza autenticación → configura el método de login de tu cuenta personal en GitHub; una contraseña convencional no suele funcionar por HTTPS.

## Referencias oficiales

- Kind: https://kind.sigs.k8s.io/docs/user/quick-start/
- Helm: https://helm.sh/docs/
- Argo CD: https://argo-cd.readthedocs.io/en/stable/getting_started/
