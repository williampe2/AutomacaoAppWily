*** Settings ***
Documentation     Keywords de inspeção do Extrato e transferência.
Resource          ../screens/extrato_screen.resource
Resource          ../screens/home_tela.resource
Resource          entrada_no_app.resource
Resource          ../../shared/variables/common_variables.resource
Library           String

*** Keywords ***
Preparar extrato
    [Documentation]    Abre o app e realiza login com o perfil Wily DA.
    Abrir aplicativo
    ${email_yaml}    Set Variable    ${usuarios}[wily_DA][usuario_app]
    ${senha_yaml}    Set Variable    ${usuarios}[wily_DA][senha_app]
    Realizar login    ${email_yaml}    ${senha_yaml}

Abrir extrato
    [Documentation]    Abre o extrato pela opção correspondente na Home.
    Wait Until Element Is Visible    ${EXTRATO_ABRIR}    ${DEFAULT_TIMEOUT}s
    Click Element                    ${EXTRATO_ABRIR}
    Wait Until Element Is Visible    ${EXTRATO_TITULO}    ${DEFAULT_TIMEOUT}s

Abrir transferência
    [Documentation]    Abre Nova transferência sem enviar uma solicitação.
    Wait Until Element Is Visible    ${EXTRATO_TRANSFERIR_SALDO}    ${DEFAULT_TIMEOUT}s
    Click Element                    ${EXTRATO_TRANSFERIR_SALDO}
    Wait Until Element Is Visible    ${TRANSFERIR_SALDO_TITULO}     ${DEFAULT_TIMEOUT}s
    Wait Until Element Is Visible    ${TRANSFERIR_SALDO_VALOR}      ${DEFAULT_TIMEOUT}s

Validar texto preenchido
    [Documentation]    Confirma presença de texto sem expor saldo ou chave nos logs.
    [Arguments]    ${locator}
    ${nivel_log}=    Set Log Level    WARN
    ${texto}=    Get Element Attribute    ${locator}    text
    ${texto_preenchido}=    Evaluate    bool($texto and $texto.strip())
    Set Log Level    ${nivel_log}
    Should Be True    ${texto_preenchido}    Texto esperado ausente em ${locator}

Voltar para a home
    ${home_visivel}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${HOME_BTN_MENU}    2s
    IF    ${home_visivel}    RETURN
    ${transferencia_visivel}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${TRANSFERIR_SALDO_TITULO}    2s
    IF    ${transferencia_visivel}
        Click Element    ${EXTRATO_VOLTAR_BOTAO}
        Wait Until Element Is Visible    ${EXTRATO_TITULO}    ${DEFAULT_TIMEOUT}s
    END
    Click Element    ${EXTRATO_VOLTAR_BOTAO}
    Wait Until Element Is Visible    ${HOME_BTN_MENU}    ${DEFAULT_TIMEOUT}s