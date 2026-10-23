*** Settings ***
Documentation     Keywords de autenticação no app.
Resource          ../screens/login_tela.resource
Resource          ../screens/home_tela.resource
Resource          ../../../resources/shared/variables/common_variables.resource
Library           OperatingSystem
Library           String
Library           AppiumLibrary

*** Keywords ***
Clicar em Acessar Conta
    [Documentation]    Clica no botão "Acessar Conta" na tela de login.
    Wait Until Element Is Visible    ${LOGIN_BTN_ACESSAR_CONTA}    10s
    Click Element                    ${LOGIN_BTN_ACESSAR_CONTA}

Preencher campos de Email
    [Documentation]    Preenche o usuário email
    [Arguments]                      ${EMAIL_WILY}
    Wait Until Element Is Visible    ${LOGIN_INPUT_USERNAME}    10s
    Input Text                       ${LOGIN_INPUT_USERNAME}    ${EMAIL_WILY}
    Hide Keyboard
    Click Element                    ${LOGIN_BTN_AVANCAR}

Preencher campos de senha
    [Documentation]    Preenche o campo de senha
    [Arguments]                      ${SENHA_WILY}
    Wait Until Element Is Visible    ${LOGIN_INPUT_PASSWORD}    10s
    Click Element                    ${LOGIN_INPUT_PASSWORD}
    @{caracteres}=                   Split String To Characters    ${SENHA_WILY}
    FOR    ${letra}    IN    @{caracteres}
        Run                          adb shell input text "${letra}"
        Sleep                        0.05s
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