*** Settings ***
Documentation     Keywords de autenticação no app.
Resource        ../screens/login_screen.resource

*** Keywords ***
Clicar em Acessar Conta
    [Documentation]    Clica no botão "Acessar Conta" na tela de login.
    wait until Element Is Visible    ${LOGIN_BTN_ACESSAR_CONTA}    10s    
    Click Element                    ${LOGIN_BTN_ACESSAR_CONTA}

Preencher campos de login
    [Documentation]    Preenche os campos de usuário e senha na tela de login.
    Arguments                        ${EMAIL_WILY}    ${SENHA_WILY}
    wait until Element Is Visible    ${LOGIN_USERNAME_INPUT}    10s
    Input Text                       ${LOGIN_USERNAME_INPUT}    ${EMAIL_WILY}
    wait until Element Is Visible    ${LOGIN_PASSWORD_INPUT}    10s
    Input Text                       ${LOGIN_PASSWORD_INPUT}    ${SENHA_WILY}

Clicar em Entrar
    [Documentation]    Clica no botão "Entrar" na tela de login.
    wait until Element Is Visible    ${LOGIN_BTN_ENTRAR}    10s
    Click Element                    ${LOGIN_BTN_ENTRAR}



