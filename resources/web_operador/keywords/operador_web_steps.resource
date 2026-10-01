*** Settings ***
Documentation     Keywords para ações do operador web.
Resource        ../pages/login_operador_page.resource
Resource        ../pages/validacao_vistoria_page.resource

*** Keywords ***
Login operador web
    [Arguments]    ${usuario}    ${senha}
    Input Text    ${LOGIN_WEB_USER}    ${usuario}
    Input Text    ${LOGIN_WEB_PASSWORD}    ${senha}
    Click Element    ${LOGIN_WEB_SUBMIT}

Abrir validacao de vistoria
    Wait Until Page Contains Element    ${VALIDACAO_TITULO}

Aprovar vistoria no operador web
    Click Element    ${BOTAO_APROVAR}
