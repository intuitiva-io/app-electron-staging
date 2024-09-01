#!/bin/bash
# Script de instalação da aplicação
APP_NAME="APP-INTUITIVA"
USER_OR_ORGANIZATION="intuitiva-io"
REPO_NAME="app-electron-staging"
ICON_URL="https://raw.githubusercontent.com/intuitiva-io/$REPO_NAME/main/assets/intuitiva-256.png"
PATH_APP="/opt/Intuitiva"

printf "Iniciando a instalação de $APP_NAME\n"

# Obter o último lançamento da API do GitHub
API_LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$USER_OR_ORGANIZATION/$REPO_NAME/releases/latest")

# Extrair o link do arquivo AppImage usando o 'jq'
DOWNLOAD_URL=$(echo "$API_LATEST_RELEASE" | grep -o 'https://.*.AppImage' | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    printf "Erro: Não foi possível encontrar o link do arquivo AppImage mais recente.\n"
    exit 1
fi

# Baixar o arquivo AppImage usando 'curl'
printf "Baixando $APP_NAME...\n"
curl -L -o "$APP_NAME.AppImage" "$DOWNLOAD_URL"

# Dar permissões de execução para o AppImage
#printf "Concedendo permissões de execução ao $APP_NAME...\n"

chmod a+wx "$APP_NAME.AppImage"

# Criar o diretório de aplicativos em /opt se ele não existir
if sudo mkdir -p "$PATH_APP"; then
    printf "Criando o diretório /opt/Intuitiva...\n"
else
    printf "O diretório /opt/$PATH_APP já existe.\n"
fi

# permições de escrita para o diretório de aplicativos em /opt

if sudo chmod a+w "$PATH_APP"; then
    printf "Concedendo permissões de escrita ao diretório $PATH_APP...\n"
else
    printf "Erro ao conceder permissões de escrita ao diretório /opt/Intuitiva. Por favor, verifique suas permissões.\n"
    exit 1
fi

# Mover o arquivo AppImage para /opt sem privilégios de administrador
#printf "Movendo $APP_NAME para /opt...\n"
if sudo mv "$APP_NAME.AppImage" "$PATH_APP/$APP_NAME"; then
    printf "Instalação do aplicativo $APP_NAME concluída!\n"
else
    printf "Erro ao mover $APP_NAME para /opt. Por favor, verifique suas permissões.\n"
    exit 1
fi

# Fazer o download do ícone e movê-lo para o diretório de ícones do sistema
#printf "Baixando o ícone do aplicativo...\n"
curl -L -o "$APP_NAME.png" "$ICON_URL"

# Mover o ícone para o local correto para que ele seja exibido no menu de aplicativos
ICON_DIR="/usr/share/icons/hicolor/256x256/apps"
sudo mv "$APP_NAME.png" "$ICON_DIR"

# Criar o arquivo de atalho (desktop file) para a bandeja de aplicativos
#printf "Criando o arquivo de atalho para a bandeja de aplicativos...\n"
echo "[Desktop Entry]
Name=$APP_NAME
Exec=$PATH_APP/$APP_NAME
Icon=/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png
Type=Application
Categories=Aplicativos;" | sudo tee "/usr/share/applications/$APP_NAME.desktop" >/dev/null

# Atualizar o cache de ícones e atalhos do sistema
#printf "Atualizando o cache de ícones e atalhos do sistema...\n"
sudo update-desktop-database
sudo gtk-update-icon-cache /usr/share/icons/*

printf "aplicaçao $APP_NAME instalada com sucesso!\n"
