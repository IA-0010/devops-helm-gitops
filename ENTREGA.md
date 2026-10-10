# ENTREGA — Kubernetes + Helm + Argo CD

**Asignatura:** DevOps y DevSecOps  
**Proyecto:** Despliegue de aplicación web con Helm y sincronización GitOps con Argo CD.

## 1. Enlace al repositorio Git

PEGAR AQUÍ EL ENLACE REAL DEL REPOSITORIO PÚBLICO, por ejemplo: https://github.com/<TU-USUARIO>/devops-helm-gitops

El repositorio incluye `helm/devops-web/Chart.yaml`, `values.yaml` y `templates/`, además de `argocd/application.yaml`.

## 2. Capturas requeridas (agregar capturas reales)

- Evidencia 1: Argo CD UI, aplicación `devops-web` en estado **Healthy / Synced**.
- Evidencia 2: Terminal `kubectl get deploy,pods,svc -n devops` con **1/1** réplica inicial.
- Evidencia 3: Commit y push de `values.yaml`, cambiando `replicaCount` de **1** a **2**.
- Evidencia 4: Argo CD UI, aplicación sincronizada tras el cambio.
- Evidencia 5: Terminal `kubectl get deploy,pods -n devops` mostrando **2/2** réplicas.
- Evidencia 6 (opcional): Reversión del commit desde Git y retorno a **1/1**.

**No se deben presentar capturas simuladas.** Cada imagen debe reflejar la ejecución en tu equipo.

## 3. Explicación breve del flujo GitOps

Se creó un clúster local de Kubernetes utilizando Kind y se definió un Helm Chart para una aplicación web Nginx. El chart se almacenó en un repositorio GitHub que Argo CD observa como fuente de verdad. Mediante una Application con sincronización automática, Argo CD compara el estado del repositorio con el clúster y aplica los cambios necesarios. Para validar GitOps, se modificó `replicaCount` de 1 a 2 en `values.yaml`, se hizo commit y push a GitHub, y Argo CD actualizó automáticamente el Deployment hasta alcanzar dos réplicas, sin ejecutar manualmente `kubectl apply` sobre el Deployment. La reversión puede hacerse desde Git, permitiendo restaurar el estado deseado anterior.

> Nota: ajusta la explicación final únicamente a las verificaciones efectivamente realizadas.
