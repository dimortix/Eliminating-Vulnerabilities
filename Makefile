.PHONY: help build run docker-build docker-run lint vulncheck clean all

APP_NAME = test-task-dmrtx
DOCKER_IMAGE = $(APP_NAME):latest

help:
	@echo "Доступные команды:"
	@echo "  make build         Сборка бинарника"
	@echo "  make run           Запуск приложения"
	@echo "  make lint          Проверка кода линтером"
	@echo "  make vulncheck     Сканирование уязвимостей"
	@echo "  make docker-build  Сборка Docker образа"
	@echo "  make docker-run    Запуск в Docker контейнере"
	@echo "  make clean         Очистка артефактов"
	@echo "  make all           Полная проверка (lint + vulncheck + build + docker-build)"

build:
	@echo "Сборка бинарника..."
	go build -o $(APP_NAME) .
	@echo "Сборка завершена: $(APP_NAME)"

run: build
	@echo "Запуск приложения..."
	./$(APP_NAME)

lint:
	@echo "Проверка кода линтером..."
	golangci-lint run
	

vulncheck:
	@echo "Сканирование уязвимостей"
	@which govulncheck > /dev/null 2>&1 || (echo "Установка govulncheck..." && go install golang.org/x/vuln/cmd/govulncheck@latest)
	@$$HOME/go/bin/govulncheck ./... | tee govulncheck-final-report.txt
	@echo "Сканирование завершено"

docker-build:
	@echo "Сборка Docker образа..."
	docker build -t $(DOCKER_IMAGE) .
	@echo "Образ собран: $(DOCKER_IMAGE)"
	@docker images $(DOCKER_IMAGE)

docker-run: docker-build
	@echo "Запуск в Docker контейнере..."
	docker run --rm $(DOCKER_IMAGE)

clean:
	@echo "Очистка артефактов..."
	rm -f $(APP_NAME)
	rm -f *.txt
	@echo "Очистка завершена"

all: lint vulncheck build docker-build
	@echo "Все проверки пройдены успешно!"

