*** Settings ***
Resource         ../../../resources/shared/base.resource
Resource         ../../../resources/app/keywords/extrato.resource
Resource         ../../../resources/app/keywords/entrada_no_app.resource
Variables        ../../../config/secrets.yaml
Variables        ../../../resources/data/perfis_usuarios.yaml
Resource    ../../../resources/shared/variables/common_variables.resource

Suite Setup      Preparar extrato

*** Test Cases ***
Saldo Disponível Deve Ser Exibido
    [Documentation]    Confirma que o saldo é exibido no extrato.
    [Tags]    mobile    extrato    fluxo_principal    smoke
    [Teardown]    Voltar para a home
    Given Abrir extrato
    Then Wait Until Element Is Visible    ${EXTRATO_SALDO_DISPONIVEL}    ${DEFAULT_TIMEOUT}s

Saldo Disponível Deve Ter Valor Preenchido
    [Documentation]    Confirma que o saldo exibe um valor não vazio.
    [Tags]    mobile    extrato    fluxo_principal
    [Teardown]    Voltar para a home
    Given Abrir extrato
    Then Validar texto preenchido    ${EXTRATO_VALOR_SALDO}