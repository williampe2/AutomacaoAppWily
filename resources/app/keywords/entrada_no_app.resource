*** Settings ***
Documentation     Keywords de autenticação no app.
...               O destino da execução (local ou BrowserStack) é lido da variável de
...               ambiente EXECUCAO. No local o comportamento é o original (Hide Keyboard
...               e adb); no BrowserStack usa alternativas que passam pelo Appium.
Resource          ../screens/login_tela.resource
Resource          ../screens/home_tela.resource
Resource          ../../../resources/shared/variables/common_variables.resource
Library           OperatingSystem
Library           String
Library           AppiumLibrary

*** Keywords ***
# ---------- Auxiliares de destino ----------
Executando no BrowserStack
    [Documentation]    True quando EXECUCAO=browserstack. É o único lugar deste resource
    ...    que decide o destino da execução.
    ${bs}=    Evaluate    os.environ.get('EXECUCAO', 'local').lower() == 'browserstack'    modules=os
    RETURN    ${bs}

Esconder teclado
    [Documentation]    Local: Hide Keyboard como sempre. BrowserStack: o driver da nuvem não
    ...    aceita mobile: hideKeyboard nem mobile: pressKey. Tenta a ação "done" do
    ...    teclado e, se ele continuar aberto, usa o keycode Voltar direto pelo driver.
    ${bs}=    Executando no BrowserStack
    IF    ${bs}
        ${lib}=       Get Library Instance    AppiumLibrary
        ${driver}=    Call Method             ${lib}    _current_application
        ${aberto}=    Evaluate                $driver.is_keyboard_shown()
        IF    ${aberto}
            &{args}=    Create Dictionary    action=done
            Run Keyword And Ignore Error    Execute Script    mobile: performEditorAction    &{args}
            ${ainda}=    Evaluate    $driver.is_keyboard_shown()
            IF    ${ainda}
                Evaluate    $driver.press_keycode(4)
            END
        END
    ELSE
        Hide Keyboard
    END

# ---------- Login ----------
Clicar em Acessar Conta
    [Documentation]    Clica no botão "Acessar Conta" na tela de login.
    Wait Until Element Is Visible    ${LOGIN_BTN_ACESSAR_CONTA}    10s
    Click Element                    ${LOGIN_BTN_ACESSAR_CONTA}

Preencher campos de Email
    [Documentation]    Preenche o usuário email
    [Arguments]                      ${EMAIL_WILY}
    Wait Until Element Is Visible    ${LOGIN_INPUT_USERNAME}    10s
    Input Text                       ${LOGIN_INPUT_USERNAME}    ${EMAIL_WILY}
    Esconder teclado
    Click Element                    ${LOGIN_BTN_AVANCAR}

Preencher campos de senha
    [Documentation]    Local: digita caractere a caractere via adb (como era). BrowserStack:
    ...    envia as teclas por ações W3C (ActionChains), gerando eventos reais de teclado.
    ...    Isso dispara o onChangeText do React Native, que o Input Password não dispara.
    [Arguments]                      ${SENHA_WILY}
    Wait Until Element Is Visible    ${LOGIN_INPUT_PASSWORD}    10s
    Click Element                    ${LOGIN_INPUT_PASSWORD}
    ${bs}=    Executando no BrowserStack
    IF    ${bs}
        ${lib}=       Get Library Instance    AppiumLibrary
        ${driver}=    Call Method             ${lib}    _current_application
        Evaluate
        ...    selenium.webdriver.common.action_chains.ActionChains($driver).send_keys($SENHA_WILY).perform()
        ...    modules=selenium.webdriver.common.action_chains
    ELSE
        @{caracteres}=    Split String To Characters    ${SENHA_WILY}
        FOR    ${letra}    IN    @{caracteres}
            Run      adb shell input text "${letra}"
            Sleep    0.05s
        END
    END

Clicar em Entrar
    [Documentation]    Clica no botão "Entrar" na tela de login.
    Wait Until Element Is Visible    ${LOGIN_BTN_ENTRAR}    10s
    Click Element                    ${LOGIN_BTN_ENTRAR}

Verificar se o login foi realizado com sucesso
    [Documentation]    Verifica se o login foi realizado com sucesso
    Wait Until Element Is Visible    ${HOME_MAPA}    ${DEFAULT_TIMEOUT}s

Realizar login
    [Documentation]    Realiza o fluxo completo de login no aplicativo.
    [Arguments]    ${EMAIL_WILY}    ${SENHA_WILY}
    Clicar em Acessar Conta
    Preencher campos de Email    ${EMAIL_WILY}
    Preencher campos de senha    ${SENHA_WILY}
    Clicar em Entrar
    Verificar se o login foi realizado com sucesso