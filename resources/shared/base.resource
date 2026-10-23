*** Settings ***
Documentation    Arquivo responsável por iniciar e encerrar as sessões do Appium (Mobile) e do Browser (Web).
Library          AppiumLibrary    run_on_failure=Nothing
Library          DatabaseLibrary
Variables        ../../config/env_qa.yaml
Variables        ../data/perfis_usuarios.yaml
Resource         ../app/screens/cadastro_tela.resource
Resource         ../app/keywords/entrada_no_app.resource


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
    ${botao_visivel}    Run Keyword And Return Status    Wait Until Element Is Visible    ${CADASTRO_BTN_CRIAR_CONTA}    3s
    IF    not ${botao_visivel}
            Clicar em Acessar Conta
    END

Abrir aplicativo
    [Documentation]    Abre o app. Por padrão usa o no_reset do YAML; com no_reset=${True}
    ...    preserva a sessão (não limpa dados do app).
    [Arguments]    ${no_reset}=${app}[no_reset]    ${arg2}=${None}    ${arg3}=${None}
    Open Application    http://127.0.0.1:4723
    ...    platformName=${app}[platform_name]
    ...    automationName=${app}[automation_name]
    ...    appPackage=${app}[app_package]
    ...    appActivity=${app}[app_activity]
    ...    deviceName=${app}[device_name]
    ...    udid=${app}[udid]
    ...    noReset=${no_reset}
    ...    autoGrantPermissions=${app}[auto_grant_permissions]

Connect To Database    
    psycopg2    ${db_name}    ${db_user}    ${db_pass}    ${db_host}    ${db_port}


Fechar Aplicativo Wily
    [Documentation]    Encerra a sessão do Appium
    Close Application

Abrir navegador operador
    Open Browser    ${WEB_BASE_URL}    ${BROWSER}
    Maximize Browser Window

Fechar sessao do app
    Close Application

Desconectar do Banco de Dados
    Disconnect From Database

Fechar sessao web
    Close Browser
