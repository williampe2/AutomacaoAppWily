*** Settings ***
Documentation    Arquivo responsável por iniciar e encerrar as sessões do Appium (Mobile) e do Browser (Web).
...              O destino do app é escolhido pela variável de ambiente EXECUCAO:
...              local (padrão, dispositivo físico) ou browserstack.
Library          AppiumLibrary      run_on_failure=AppiumLibrary.Capture Page Screenshot
Library          DatabaseLibrary
Library          OperatingSystem
Library          Collections
Variables        ../../config/env_qa.yaml
Variables        ../data/perfis_usuarios.yaml
Resource         ../app/screens/cadastro_tela.resource
Resource         ../app/keywords/entrada_no_app.resource


*** Keywords ***

# ---------- App ----------
Abrir Aplicativo Wily no Emulador
    [Documentation]    Abre o app no destino definido por EXECUCAO e garante que está na tela inicial.
    Abrir aplicativo
    ${botao_visivel}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${CADASTRO_BTN_CRIAR_CONTA}    3s
    IF    not ${botao_visivel}
        Clicar em Acessar Conta
    END

Abrir aplicativo
    [Documentation]    Abre o app no destino definido por EXECUCAO (local | browserstack).
    ...    Por padrão usa o no_reset do YAML; com no_reset=${True} preserva a sessão.
    [Arguments]    ${no_reset}=${app}[no_reset]
    IF    '%{EXECUCAO=local}' == 'browserstack'
        ${url}    ${caps}=    Montar capabilities BrowserStack    ${no_reset}
    ELSE
        ${url}    ${caps}=    Montar capabilities local    ${no_reset}
    END
    Log To Console    \n>>> Destino: ${url}
    Open Application    ${url}    &{caps}

Montar capabilities local
    [Documentation]    Capabilities do dispositivo físico, via Appium local.
    [Arguments]    ${no_reset}
    &{caps}=    Create Dictionary
    ...    platformName=${app}[platform_name]
    ...    automationName=${app}[automation_name]
    ...    appPackage=${app}[app_package]
    ...    appActivity=${app}[app_activity]
    ...    deviceName=${app}[device_name]
    ...    udid=${app}[udid]
    ...    noReset=${no_reset}
    ...    autoGrantPermissions=${app}[auto_grant_permissions]
    RETURN    http://127.0.0.1:4723    ${caps}

Montar capabilities BrowserStack
    [Documentation]    Capabilities da nuvem. Variáveis de ambiente usadas:
    ...    BROWSERSTACK_USERNAME, BROWSERSTACK_ACCESS_KEY, BS_APP_URL (obrigatórias);
    ...    BS_DEVICE, BS_OS_VERSION, BS_BUILD_NAME, BS_SESSION_NAME, BS_LOCAL, BS_GPS_LOCATION,
    ...    BS_GEO_LOCATION, BROWSERSTACK_LOCAL_IDENTIFIER (opcionais).
    ...    BS_GPS_LOCATION no formato "latitude,longitude" (padrão: Rua Getúlio Vargas, Picos-PI).
    ...    BS_GEO_LOCATION é o código do país do IP de saída (padrão: BR).
    ...    BROWSERSTACK_LOCAL_IDENTIFIER é o nome do túnel (vazio = túnel sem nome).
    ...    networkLogs permanece desativado para evitar interceptação TLS em APIs com certificate pinning.
    [Arguments]    ${no_reset}
    ${local}=    Evaluate    '%{BS_LOCAL=true}'.lower() == 'true'
    &{opts}=    Create Dictionary
    ...    userName=%{BROWSERSTACK_USERNAME}
    ...    accessKey=%{BROWSERSTACK_ACCESS_KEY}
    ...    projectName=Automacao Wily
    ...    buildName=%{BS_BUILD_NAME=local}
    ...    sessionName=%{BS_SESSION_NAME=login}
    ...    local=${local}
    ...    gpsLocation=%{BS_GPS_LOCATION=-7.0769,-41.4672}
    ...    networkLogs=${False}
    ${local_id}=    Get Environment Variable    BROWSERSTACK_LOCAL_IDENTIFIER    default=${EMPTY}
    IF    '${local_id}' != ''
        Set To Dictionary    ${opts}    localIdentifier=${local_id}
    END
    &{caps}=    Create Dictionary
    ...    platformName=Android
    ...    automationName=UiAutomator2
    ...    deviceName=%{BS_DEVICE=Samsung Galaxy S23}
    ...    platformVersion=%{BS_OS_VERSION=13.0}
    ...    app=%{BS_APP_URL}
    ...    noReset=${no_reset}
    ...    autoGrantPermissions=${True}
    ...    bstack:options=${opts}
    RETURN    https://hub.browserstack.com/wd/hub    ${caps}

Fechar Aplicativo Wily
    [Documentation]    Encerra a sessão do Appium
    Close Application

Fechar sessao do app
    Close Application

# ---------- Web ----------
Abrir navegador operador
    Open Browser    ${WEB_BASE_URL}    ${BROWSER}
    Maximize Browser Window

Fechar sessao web
    Close Browser

# ---------- Banco de dados ----------
Conectar ao Banco de Dados
    [Documentation]    Conecta ao PostgreSQL (DatabaseLibrary 2.x).
    DatabaseLibrary.Connect To Database
    ...    db_module=psycopg2
    ...    db_name=${db_name}
    ...    db_user=${db_user}
    ...    db_password=${db_pass}
    ...    db_host=${db_host}
    ...    db_port=${db_port}

Desconectar do Banco de Dados
    Disconnect From Database