*** Settings ***
Documentation    Arquivo responsável por iniciar e encerrar as sessões do Appium (Mobile) e do Browser (Web).
Library          AppiumLibrary      run_on_failure=AppiumLibrary.Capture Page Screenshot
Library          DatabaseLibrary
Library          OperatingSystem
Variables        ../../config/env_qa.yaml
Variables        ../data/perfis_usuarios.yaml
Resource         ../app/screens/cadastro_tela.resource
Resource         ../app/keywords/entrada_no_app.resource


*** Keywords ***

Abrir Aplicativo Wily no Emulador
    [Documentation]    Inicia a sessão do Appium e abre o aplicativo no Android.
    Abrir sessão Appium    ${app}[no_reset]
    ${botao_visivel}    Run Keyword And Return Status    Wait Until Element Is Visible    ${CADASTRO_BTN_CRIAR_CONTA}    3s
    IF    not ${botao_visivel}
        Clicar em Acessar Conta
    END

Abrir aplicativo
    [Documentation]    Abre o app. Por padrão usa o no_reset do YAML.
    [Arguments]    ${no_reset}=${app}[no_reset]    ${arg2}=${None}    ${arg3}=${None}
    Abrir sessão Appium    ${no_reset}

Abrir sessão Appium
    [Documentation]    Abre uma sessão remota na BrowserStack quando as variáveis de ambiente existem; caso contrário, mantém a conexão local.
    [Arguments]    ${no_reset}
    ${bs_username}=    Get Environment Variable    BROWSERSTACK_USERNAME    ${EMPTY}
    IF    $bs_username != ''
        ${bs_access_key}=    Get Environment Variable    BROWSERSTACK_ACCESS_KEY    ${EMPTY}
        ${bs_app_id}=    Get Environment Variable    BROWSERSTACK_APP_ID    ${EMPTY}
        Should Not Be Empty    ${bs_access_key}    A variável BROWSERSTACK_ACCESS_KEY não foi configurada.
        Should Not Be Empty    ${bs_app_id}    A variável BROWSERSTACK_APP_ID não foi configurada.
        Open Application    https://hub-cloud.browserstack.com/wd/hub
        ...    platformName=Android
        ...    automationName=UiAutomator2
        ...    app=${bs_app_id}
        ...    device=Samsung Galaxy S22 Ultra
        ...    os_version=12.0
        ...    browserstack.user=${bs_username}
        ...    browserstack.key=${bs_access_key}
        ...    project=AutomacaoAppWily
        ...    build=GitHub Actions - Integration
        ...    name=${TEST NAME}
        ...    noReset=${no_reset}
        ...    autoGrantPermissions=${app}[auto_grant_permissions]
    ELSE
        Open Application    http://127.0.0.1:4723
        ...    platformName=${app}[platform_name]
        ...    automationName=${app}[automation_name]
        ...    appPackage=${app}[app_package]
        ...    appActivity=${app}[app_activity]
        ...    deviceName=${app}[device_name]
        ...    udid=${app}[udid]
        ...    noReset=${no_reset}
        ...    autoGrantPermissions=${app}[auto_grant_permissions]
    END

Connect To Database
    psycopg2    ${db_name}    ${db_user}    ${db_pass}    ${db_host}    ${db_port}


Fechar Aplicativo Wily
    [Documentation]    Encerra a sessão do Appium.
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
