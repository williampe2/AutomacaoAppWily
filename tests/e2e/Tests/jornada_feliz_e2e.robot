*** Settings ***
Documentation     Jornada feliz E2E: login, dados pessoais, extrato e vistoria (app + WEB).
...               Todos os testes rodam em sequência e compartilham a mesma sessão do app.
Library           AppiumLibrary    run_on_failure=AppiumLibrary.Capture Page Screenshot
Library           SeleniumLibrary  run_on_failure=SeleniumLibrary.Capture Page Screenshot
Variables         ../../../config/env_qa.yaml
Variables         ../../../config/secrets.yaml
Variables         ../../../resources/data/perfis_usuarios.yaml
Resource          ../../../resources/shared/base.resource
Resource          ../../../resources/shared/variables/common_variables.resource
Resource          ../../../resources/app/keywords/entrada_no_app.resource
Resource          ../../../resources/app/keywords/quiz.resource
Resource          ../../../resources/app/keywords/dados_pessoais.resource
Resource          ../../../resources/app/keywords/extrato.resource
Resource          ../../../resources/app/keywords/vistoria.resource
Resource          ../../../resources/web_operador/keywords/vistoria.resource
Resource          ../Keywords/aprovar_transacao.resource
Suite Setup       Abrir Aplicativo Wily no Emulador
Suite Teardown    Encerrar sessões E2E

*** Test Cases ***
# ===================== LOGIN =====================
Cenario: Login com sucesso
    [Tags]    mobile    smoke    jornada_feliz
    ${email_yaml}     Set Variable    ${usuarios}[wily_DA][usuario_app]
    ${senha_yaml}     Set Variable    ${usuarios}[wily_DA][senha_app]
    Registrar rótulos de autenticação na tela atual
    Clicar em Acessar Conta
    Preencher campos de Email    ${email_yaml}
    Preencher campos de senha    ${senha_yaml}
    Clicar em Entrar
    Registrar estado da tela após enviar login
    ${existe_quiz}    Run Keyword And Return Status    AppiumLibrary.Wait Until Element Is Visible    ${QUIZ_BTN_DEIXAR_DEPOIS_QUIZ}    5s
    IF    ${existe_quiz}
        Clicar em Deixar para depois
    END
    Verificar se o login foi realizado com sucesso
    Sleep    5s

# ===================== DADOS PESSOAIS =====================
Nome De Uma Palavra Deve Ser Rejeitado
    [Documentation]    Confirma que um nome com uma única palavra não habilita a atualização.
    [Tags]    mobile    dados_pessoais    jornada_feliz
    [Setup]    Preparar e garantir dados pessoais
    [Teardown]    Descartar alteração do nome
    Given Abrir edição do nome
    When Substituir nome digitado    Teste
    Then Validar atualização desabilitada

Nome Com Números Ou Caracteres Especiais Deve Ser Filtrado
    [Documentation]    Confirma que números e caracteres especiais são filtrados e a atualização continua desabilitada.
    [Tags]    mobile    dados_pessoais    jornada_feliz
    [Setup]    Garantir lista de dados pessoais
    [Teardown]    Descartar alteração do nome
    Given Abrir edição do nome
    When Validar filtro do nome    12345
    And Validar filtro do nome    !@#

Nome Vazio Não Deve Permitir Atualização
    [Documentation]    Confirma que um nome vazio não habilita a atualização.
    [Tags]    mobile    dados_pessoais    jornada_feliz
    [Setup]    Garantir lista de dados pessoais
    [Teardown]    Descartar alteração do nome
    Given Abrir edição do nome
    When AppiumLibrary.Clear Text    ${DADOS_PESSOAIS_NOME_INPUT}
    Then Validar atualização desabilitada

Nome Repetido Não Deve Permitir Atualização
    [Documentation]    Confirma que repetir o nome já salvo não habilita a atualização.
    [Tags]    mobile    dados_pessoais    jornada_feliz
    [Setup]    Garantir lista de dados pessoais
    [Teardown]    Descartar alteração do nome
    Given Abrir edição do nome
    When Substituir nome digitado    ${NOME_DO_PERFIL}
    Then Validar atualização desabilitada

Nome Válido Deve Ser Atualizado
    [Documentation]    Salva um nome válido diferente do atual e depois restaura
    ...    o nome do perfil (perfis_usuarios.yaml).
    [Tags]    mobile    dados_pessoais    e2e    jornada_feliz
    [Setup]    Garantir lista de dados pessoais
    [Teardown]    Restaurar nome do perfil salvo
    ${nome_novo}=    Set Variable If    $NOME_DO_PERFIL == "Maria Teste Alterada"
    ...    Pedro Teste Alterado    Maria Teste Alterada
    Given Abrir edição do nome
    When Substituir nome digitado    ${nome_novo}
    Then Validar atualização habilitada
    When AppiumLibrary.Click Element    ${DADOS_PESSOAIS_NOME_BTN_ATUALIZAR}
    And AppiumLibrary.Wait Until Element Is Visible    ${DADOS_PESSOAIS_ITEM_NOME}    ${DEFAULT_TIMEOUT}s
    And Abrir edição do nome
    ${nome_atualizado}=    Ler nome digitado
    Then Should Be Equal As Strings    ${nome_atualizado}    ${nome_novo}

Celular Inalterado Não Deve Permitir Atualização
    [Documentation]    Confirma que o celular sem alteração não habilita atualização.
    [Tags]    mobile    dados_pessoais    jornada_feliz
    [Setup]    Garantir lista de dados pessoais
    [Teardown]    Voltar para dados pessoais
    Given Abrir edição do celular
    Then Validar celular inalterado

CPF Inalterado Não Deve Permitir Atualização
    [Documentation]    Confirma que o CPF sem alteração não habilita atualização.
    [Tags]    mobile    dados_pessoais    jornada_feliz
    [Setup]    Garantir lista de dados pessoais
    [Teardown]    Voltar para dados pessoais
    Given Abrir edição do CPF
    Then Validar CPF inalterado

Lista De Dados Pessoais Deve Retornar Para A Home
    [Documentation]    Confirma o retorno à Home após finalizar a navegação.
    [Tags]    mobile    dados_pessoais    jornada_feliz
    [Setup]    Garantir lista de dados pessoais
    [Teardown]    No Operation
    When dados_pessoais.Voltar para a home
    Then AppiumLibrary.Wait Until Element Is Visible    ${MENU_BTN_ABRIR}    ${DEFAULT_TIMEOUT}s

# ===================== EXTRATO =====================
Saldo Disponível Deve Ser Exibido
    [Documentation]    Confirma que o saldo é exibido no extrato.
    [Tags]    mobile    extrato    fluxo_principal    smoke    jornada_feliz
    [Setup]    Preparar extrato
    [Teardown]    extrato.Voltar para a home
    Given Abrir extrato
    Then AppiumLibrary.Wait Until Element Is Visible    ${EXTRATO_SALDO_DISPONIVEL}    ${DEFAULT_TIMEOUT}s

Saldo Disponível Deve Ter Valor Preenchido
    [Documentation]    Confirma que o saldo exibe um valor não vazio.
    [Tags]    mobile    extrato    fluxo_principal    jornada_feliz
    [Teardown]    extrato.Voltar para a home
    Given Abrir extrato
    Then Validar texto preenchido    ${EXTRATO_VALOR_SALDO}

# ===================== VISTORIA (APP + WEB) =====================
Vistoria Deve Ser Concluída E Aprovada No WEB
    [Documentation]    Conclui a vistoria no app e valida/aprova no sistema WEB.
    [Tags]    mobile    web    e2e    vistoria    jornada_feliz
    [Setup]    Preparar sessão de vistoria
    [Teardown]    Encerrar sessões E2E

    # Etapas do aplicativo (Appium)
    Iniciar
    Aceitar oferta
    Rolar até Iniciar vistoria
    Iniciar vistoria
    Enviar fotos
    Completar mídias e concluir

    # Etapas do sistema WEB (Selenium)
    Aprovar transação no WEB
    Ficar offline

*** Keywords ***
Preparar e garantir dados pessoais
    [Documentation]    Roda o preparo dos dados pessoais uma vez (salva o nome do perfil) e garante a lista aberta.
    Preparar dados pessoais
    Garantir lista de dados pessoais