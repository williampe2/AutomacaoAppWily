*** Settings ***
Documentation     Regras de alteração dos dados pessoais.
Variables         ${EXECDIR}/resources/data/perfis_usuarios.yaml
Resource          ../../../resources/shared/base.resource
Resource          ../../../resources/app/keywords/dados_pessoais.resource
Suite Setup       Preparar dados pessoais
Suite Teardown    Restaurar nome do perfil salvo
Test Setup        Garantir lista de dados pessoais
Test Teardown     Descartar alteração do nome

*** Test Cases ***


Nome De Uma Palavra Deve Ser Rejeitado
    [Documentation]    Confirma que um nome com uma única palavra não habilita a atualização.
    [Tags]    mobile    dados_pessoais
    Given Abrir edição do nome
    When Substituir nome digitado    Teste
    Then Validar atualização desabilitada

Nome Com Números Ou Caracteres Especiais Deve Ser Filtrado
    [Documentation]    Confirma que números e caracteres especiais são filtrados e a atualização continua desabilitada.
    [Tags]    mobile    dados_pessoais
    Given Abrir edição do nome
    When Validar filtro do nome    12345
    And Validar filtro do nome    !@#

Nome Vazio Não Deve Permitir Atualização
    [Documentation]    Confirma que um nome vazio não habilita a atualização.
    [Tags]    mobile    dados_pessoais
    Given Abrir edição do nome
    When Clear Text    ${DADOS_PESSOAIS_NOME_INPUT}
    Then Validar atualização desabilitada

Nome Repetido Não Deve Permitir Atualização
    [Documentation]    Confirma que repetir o nome já salvo não habilita a atualização.
    [Tags]    mobile    dados_pessoais
    Given Abrir edição do nome
    When Substituir nome digitado    ${NOME_DO_PERFIL}
    Then Validar atualização desabilitada

Nome Válido Deve Ser Atualizado
    [Documentation]    Salva um nome válido diferente do atual e depois restaura
    ...    o nome do perfil (perfis_usuarios.yaml).
    [Tags]    mobile    dados_pessoais    e2e
    [Teardown]    Restaurar nome do perfil salvo
    ${nome_novo}=    Set Variable If    $NOME_DO_PERFIL == "Maria Teste Alterada"
    ...    Pedro Teste Alterado    Maria Teste Alterada
    Given Abrir edição do nome
    When Substituir nome digitado    ${nome_novo}
    Then Validar atualização habilitada
    When Click Element    ${DADOS_PESSOAIS_NOME_BTN_ATUALIZAR}
    And Wait Until Element Is Visible    ${DADOS_PESSOAIS_ITEM_NOME}    ${DEFAULT_TIMEOUT}s
    And Abrir edição do nome
    ${nome_atualizado}=    Ler nome digitado
    Then Should Be Equal As Strings    ${nome_atualizado}    ${nome_novo}

Celular Inalterado Não Deve Permitir Atualização
    [Documentation]    Confirma que o celular sem alteração não habilita atualização.
    [Tags]    mobile    dados_pessoais
    [Teardown]    Voltar para dados pessoais
    Given Abrir edição do celular
    Then Validar celular inalterado

CPF Inalterado Não Deve Permitir Atualização
    [Documentation]    Confirma que o CPF sem alteração não habilita atualização.
    [Tags]    mobile    dados_pessoais
    [Teardown]    Voltar para dados pessoais
    Given Abrir edição do CPF
    Then Validar CPF inalterado

Lista De Dados Pessoais Deve Retornar Para A Home
    [Documentation]    Confirma o retorno à Home após finalizar a navegação.
    [Tags]    mobile    dados_pessoais
    [Teardown]    No Operation
    When Voltar para a home
    Then Wait Until Element Is Visible    ${MENU_BTN_ABRIR}    ${DEFAULT_TIMEOUT}s