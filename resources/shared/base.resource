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
    ...    Por padrão usa o no_reset do YAML e orientação retrato.
    ...    Para paisagem, passe orientacao=LANDSCAPE (no BrowserStack vira
    ...    deviceOrientation; nenhuma capability de rotação é enviada ao Appium).
    [Arguments]    ${no_reset}=${app}[no_reset]    ${orientacao}=PORTRAIT
    IF    '%{EXECUCAO=local}' == 'browserstack'
        ${url}    ${caps}=    Montar capabilities BrowserStack    ${no_reset}    ${orientacao}
    ELSE
        ${url}    ${caps}=    Montar capabilities local    ${no_reset}
    END
    Log To Console    \n>>> Destino: ${url}
    Open Application    ${url}    &{caps}
    Aceitar permissão de notificações na inicialização
    Conceder permissões de localização e câmera

Montar capabilities local
    [Arguments]    ${no_reset}
    &{caps}=    Create Dictionary
    ...    platformName=${app}[platform_name]
    ...    automationName=${app}[automation_name]
    ...    appPackage=${app}[app_package]
    ...    appActivity=${app}[app_activity]
    ...    deviceName=${app}[device_name]
    ...    udid=${app}[udid]
    ...    noReset=${no_reset}
    ...    appium:autoGrantPermissions=${app}[auto_grant_permissions]
    RETURN    http://127.0.0.1:4723    ${caps}

Montar capabilities BrowserStack
    [Arguments]    ${no_reset}    ${orientacao}=PORTRAIT
    ${orientacao_bs}=    Evaluate    $orientacao.lower()
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
    ...    deviceOrientation=${orientacao_bs}
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
    ...    appium:autoGrantPermissions=${True}
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

Aceitar permissão de notificações na inicialização
    [Documentation]    Aceita o diálogo Android de notificações antes de iniciar os passos do teste.
    ${permitir}=    Set Variable    id=com.android.permissioncontroller:id/permission_allow_button
    ${dialogo_visivel}=    Run Keyword And Return Status
    ...    AppiumLibrary.Wait Until Element Is Visible    ${permitir}    8s
    IF    not ${dialogo_visivel}
        ${permitir}=    Set Variable    xpath=//*[@text="Allow" or @text="Permitir"]
        ${dialogo_visivel}=    Run Keyword And Return Status
        ...    AppiumLibrary.Wait Until Element Is Visible    ${permitir}    2s
    END
    IF    ${dialogo_visivel}
        AppiumLibrary.Click Element    ${permitir}
        ${ainda_visivel}=    Run Keyword And Return Status
        ...    AppiumLibrary.Wait Until Element Is Visible    ${permitir}    2s
        IF    ${ainda_visivel}
            Fail    O diálogo de permissão de notificações continuou visível após tocar em Permitir.
        END
        Log To Console    Permissão de notificações aceita antes do início do teste.
    ELSE
        Log To Console    Diálogo de notificações não apareceu; nenhuma ação necessária.
    END

Conceder permissões de localização e câmera
    [Documentation]    Concede e valida localização precisa, em segundo plano e acesso à câmera.
    @{permissoes}=    Create List
    ...    android.permission.ACCESS_COARSE_LOCATION
    ...    android.permission.ACCESS_FINE_LOCATION
    ...    android.permission.ACCESS_BACKGROUND_LOCATION
    ...    android.permission.CAMERA
    &{opcoes}=    Create Dictionary
    ...    permissions=${permissoes}
    ...    appPackage=${app}[app_package]
    ...    action=grant
    ...    target=pm
    AppiumLibrary.Execute Script    mobile: changePermissions    &{opcoes}

    &{consulta}=    Create Dictionary
    ...    type=granted
    ...    appPackage=${app}[app_package]
    ${concedidas}=    AppiumLibrary.Execute Script    mobile: getPermissions    &{consulta}
    FOR    ${permissao}    IN    @{permissoes}
        Should Contain    ${concedidas}    ${permissao}
        ...    msg=Android não concedeu ${permissao} ao app ${app}[app_package].
    END
    Log To Console    Permissões de localização e câmera concedidas.
