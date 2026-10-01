*** Settings ***
Documentation    Arquivo responsável por iniciar e encerrar as sessões do Appium (Mobile) e do Browser (Web).
Library          AppiumLibrary
Library          DatabaseLibrary
Variables        ../../config/env_qa.yaml
variable         ../../config/secrets.yaml

*** Keywords ***

Abrir Aplicativo Wily no Emulador
    [Documentation]    Inicia a sessão do Appium e abre o aplicativo no Android
    Open Application    http://127.0.0.1:4723
    ...                 platformName=${app}[platform_name]
    ...                 automationName=${app}[automation_name]
    ...                 appPackage=${app}[app_package]
    ...                 appActivity=${app}[app_activity]
    ...                 deviceName=${app}[device_name]
    ...                 udid=${app}[udid]
    ...                 noReset=${app}[no_reset]
    ...                 autoGrantPermissions=${app}[auto_grant_permissions]
    
    # Aplica o timeout que você definiu no YAML para os comandos do Appium
    Set Appium Timeout    ${timeouts}[explicit_wait]

Connect To Database    
    psycopg2    ${db_name}    ${db_user}    ${db_pass}    ${db_host}    ${db_port}


Fechar Aplicativo Wily
    [Documentation]    Encerra a sessão do Appium
    Close Application

# Abrir navegador operador
#     Open Browser    ${WEB_BASE_URL}    ${BROWSER}
#     Maximize Browser Window

Fechar sessao do app
    Close Application

Desconectar do Banco de Dados
    Disconnect From Database

# Fechar sessao web
#     Close Browser
