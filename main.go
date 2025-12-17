// тут код, который загружает Helm chart
package main

import (
	"fmt"
	"log"
	"os"

	"helm.sh/helm/v3/pkg/action"
	"helm.sh/helm/v3/pkg/chart/loader"
	"helm.sh/helm/v3/pkg/cli"
)

func main() {
	settings := cli.New()

	actionConfig := new(action.Configuration)
	if err := actionConfig.Init(settings.RESTClientGetter(), "default", os.Getenv("HELM_DRIVER"), log.Printf); err != nil {
		log.Fatalf("Ошибка инициализации Helm: %v", err)
	}

	chartPath := "./my-chart"

	_, err := loader.Load(chartPath)
	if err != nil {
		log.Fatalf("Ошибка загрузки чарта: %v", err)
	}

	values := map[string]interface{}{
		"replicaCount": 2,
		"image": map[string]interface{}{
			"repository": "nginx",
			"tag":        "1.21",
		},
	}

	client := action.NewInstall(actionConfig)
	client.ReleaseName = "my-release"
	client.Namespace = "default"

	fmt.Println("Helm chart успешно обработан")
	fmt.Printf("Релиз: %s\n", client.ReleaseName)
	fmt.Printf("Namespace: %s\n", client.Namespace)
	fmt.Printf("Replica Count: %d\n", values["replicaCount"])
	imageMap := values["image"].(map[string]interface{})
	fmt.Printf("Image: %s:%s\n", imageMap["repository"], imageMap["tag"])
}
