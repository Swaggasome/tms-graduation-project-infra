#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для подтверждения опасных операций
confirm_dangerous_operation() {
    local message="$1"
    local confirm_word="$2"
    
    echo -e "${RED}⚠️  $message${NC}"
    read -p "Введите '${confirm_word}' для подтверждения: " input
    
    if [[ "$input" == "$confirm_word" ]]; then
        return 0
    else
        echo -e "${YELLOW}❌ Операция отменена${NC}"
        return 1
    fi
}

delete_main_project_with_progress() {
    echo "🗑️ Удаление основного проекта..."
    
    # Используем spinner для индикации процесса
    local pid
    local log_file=$(mktemp)
    
    # Запускаем destroy в фоне
    terraform destroy --auto-approve > "$log_file" 2>&1 &
    pid=$!
    
    # Spinner анимация
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r⏳ Удаление ресурсов... ${spin:$i:1}"
        sleep 0.5
    done
    printf "\r"
    
    # Проверяем результат
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\r${GREEN}✅ Основной проект успешно удален    ${NC}"
        rm -f "$log_file" terraform.tfstate terraform.tfstate.backup
    else
        echo -e "\r${RED}❌ Ошибка при удалении основного проекта${NC}"
        echo "Детали ошибки:"
        cat "$log_file" | grep -E "(Error|ERROR)"
        rm -f "$log_file"
        return 1
    fi
}

up_main_project_with_progress() {
    echo "▶️ Применение Terraform..."
    
    # Используем spinner для индикации процесса
    local pid
    local log_file=$(mktemp)
    
    cd setup_backend

    ACCESS_KEY=$(terraform output -raw access_key)
    SECRET_KEY=$(terraform output -raw secret_key)
    set -o history

    cd ../

    terraform init \
        -backend-config="access_key=$ACCESS_KEY" \
        -backend-config="secret_key=$SECRET_KEY" \
        -reconfigure > "$log_file" 2>&1
                
    # Очищаем переменные
    unset ACCESS_KEY SECRET_KEY

    # Запускаем apply в фоне
    terraform apply --auto-approve > "$log_file" 2>&1 &
    pid=$!
    
    # Spinner анимация
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r⏳ Поднятие ресурсов... ${spin:$i:1}"
        sleep 0.5
    done
    printf "\r"
    
    # Проверяем результат
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\r${GREEN}✅ Основной проект успешно поднят    ${NC}"
        rm -f "$log_file"
    else
        echo -e "\r${RED}❌ Ошибка при поднятии основного проекта${NC}"
        echo "Детали ошибки:"
        cat "$log_file" | grep -E "(Error|ERROR)"
        rm -f "$log_file"
        return 1
    fi
}

up_backend_with_progress() {
    echo "▶️ Применение Terraform..."
    
    # Используем spinner для индикации процесса
    local pid
    local log_file=$(mktemp)
    # Запускаем apply в фоне
    cd setup_backend
    terraform init -reconfigure > "$log_file" 2>&1
    terraform apply --auto-approve > "$log_file" 2>&1 &
    pid=$!
    
    # Spinner анимация
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r⏳ Поднятие ресурсов... ${spin:$i:1}"
        sleep 0.5
    done
    printf "\r"
    
    # Проверяем результат
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\r${GREEN}✅ Backend успешно поднят${NC}"
        rm -f "$log_file" 
    else
        echo -e "\r${RED}❌ Ошибка при поднятии backend${NC}"
        echo "Детали ошибки:"
        cat "$log_file" | grep -E "(Error|ERROR)"
        rm -f "$log_file"
        return 1
    fi
}

delete_backend_with_progress() {
    echo "🗑️ Удаление backend..."
    
    # Используем spinner для индикации процесса
    local pid
    local log_file=$(mktemp)
    
    # Запускаем destroy в фоне
    cd setup_backend
    terraform destroy --auto-approve > "$log_file" 2>&1 &
    pid=$!
    
    # Spinner анимация
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r⏳ Удаление ресурсов... ${spin:$i:1}"
        sleep 0.5
    done
    printf "\r"
    
    # Проверяем результат
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\r${GREEN}✅ Backend успешно удален${NC}"
        rm -f "$log_file"
    else
        echo -e "\r${RED}❌ Ошибка при удалении backend${NC}"
        echo "Детали ошибки:"
        cat "$log_file" | grep -E "(Error|ERROR)"
        rm -f "$log_file"
        return 1
    fi
}

show_menu() {
    echo "==================================="
    echo "    Управление инфраструктурой"
    echo "==================================="
    echo -e "${GREEN}1) Установить backend + основной проект${NC}"
    echo -e "${GREEN}2) Выполнить только backend${NC}"
    echo -e "${GREEN}3) Выполнить только основной проект${NC}"
    echo -e "${YELLOW}4) Удалить основной проект${NC}"
    echo -e "${YELLOW}5) Удалить backend (Только если основной проект удален)${NC}"
    echo -e "${RED}6) Удалить всё (backend + основной проект)${NC}"
    echo "7) Выйти"
    echo "==================================="
}

main() {
    while true; do
        show_menu
        read -p "Ваш выбор (1-6): " choice
        
        case $choice in
            1)
                local log_file=$(mktemp)
                echo "🔧 Полная установка с backend..."
                up_backend_with_progress
                if [ $? -eq 0 ]; then
                    ACCESS_KEY=$(terraform output -raw access_key)
                    SECRET_KEY=$(terraform output -raw secret_key)
                    
                    cd ../
                    
                    echo "▶️ Инициализируем основной проект с backend-конфигурацией..."
                    set -o history
                    terraform init \
                    -backend-config="access_key=$ACCESS_KEY" \
                    -backend-config="secret_key=$SECRET_KEY" \
                    -reconfigure > "$log_file" 2>&1
                    
                    # Очищаем переменные
                    unset ACCESS_KEY SECRET_KEY
                    
                    up_main_project_with_progress
                    K8S_ID=$(terraform output -raw k8s_id)
                    yc managed-kubernetes cluster get-credentials --id $K8S_ID --external --force
                    unset K8S_ID
                    echo "✅ Доступ настроен"
                    rm $log_file
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✅ Полная установка успешно завершена!${NC}"
                    else
                        echo -e "${RED}❌ Ошибка в основном проекте${NC}"
                        exit 1
                    fi
                else
                    echo -e "${RED}❌ Ошибка при установке backend${NC}"
                    cd ../
                    exit 1
                fi
                break
                ;;
            2)
                echo "🔧 Установка backend..."
                up_backend_with_progress
                if [ $? -eq 0 ]; then
                    ACCESS_KEY=$(terraform output -raw access_key)
                    SECRET_KEY=$(terraform output -raw secret_key)
                    
                    cd ../
                    
                    echo "▶️ Инициализируем основной проект с backend-конфигурацией..."
                    set -o history
                    terraform init \
                    -backend-config="access_key=$ACCESS_KEY" \
                    -backend-config="secret_key=$SECRET_KEY" \
                    -reconfigure > "$log_file" 2>&1
                    
                    # Очищаем переменные
                    unset ACCESS_KEY SECRET_KEY
                else
                    echo -e "${RED}❌ Ошибка при установке backend${NC}"
                    cd ../
                    exit 1
                fi
                break
                ;;
            3)
                echo "🚀 Выполнение только основного проекта..."
                up_main_project_with_progress
                
                echo "🔧 Настройка доступа "
                K8S_ID=$(terraform output -raw k8s_id)
                yc managed-kubernetes cluster get-credentials --id $K8S_ID --external --force
                unset K8S_ID
                echo "✅ Доступ настроен"

                break
                ;;
            4)
                echo "🗑️ Удаление основного проекта..."
                if confirm_dangerous_operation "Вы собираетесь удалить основной проект!" "DELETE-MAIN"; then
                    echo "▶️ Запуск terraform destroy для основного проекта..."
                    delete_main_project_with_progress
                fi
                break
                ;;
            5)
                echo "🗑️ Удаление backend..."
                if confirm_dangerous_operation "Вы собираетесь удалить backend!" "DELETE-BACKEND"; then
                    if [ -d "setup_backend" ]; then
                        delete_backend_with_progress
                    else
                        echo -e "${RED}❌ Папка setup_backend не найдена${NC}"
                    fi
                fi
                break
                ;;
            6)
                echo -e "${RED}💣 Удаление ВСЕХ ресурсов (backend + основной проект)...${NC}"
                if confirm_dangerous_operation "Это удалит ВСЕ ресурсы без возможности восстановления!" "DELETE-EVERYTHING"; then
                    
                    delete_main_project_with_progress

                    delete_backend_with_progress

                    echo -e "${GREEN}✅ Все ресурсы успешно удалены!${NC}"
                fi
                break
                ;;
            7)
                echo "👋 До свидания!"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Неверный выбор. Пожалуйста, выберите 1-6${NC}"
                echo ""
                ;;
        esac
    done
}
clear
main
