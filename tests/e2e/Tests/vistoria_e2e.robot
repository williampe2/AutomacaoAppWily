*** Settings ***
Documentation     Fluxo End-to-End: conclui a vistoria no app (Appium) e aprova
...               a transação no sistema WEB (Selenium), no mesmo cenário.
Library           AppiumLibrary
Library           SeleniumLibrary
Resource          ../../../resources/shared/base.resource
Resource          ../../../resources/app/keywords/entrada_no_app.resource
Resource          ../../../resources/app/keywords/vistoria.resource
Resource          ../../../resources/web_operador/keywords/vistoria.resource
Resource          ../Keywords/aprovar_transacao.resource
Variables         ../../../config/env_qa.yaml
Variables         ../../../resources/data/perfis_usuarios.yaml

*** Test Cases ***
Vistoria Deve Ser Concluída E Aprovada No WEB
    [Documentation]    Conclui a vistoria no app e valida/aprova no sistema WEB.
    [Tags]    mobile    web    e2e    vistoria
    [Setup]       Preparar sessão de vistoria
    [Teardown]    Encerrar sessões E2E

    # ===== Etapas do App (Appium) =====
    Iniciar
    Aceitar oferta
    Rolar até Iniciar vistoria
    Iniciar vistoria
    Enviar fotos
    Completar mídias e concluir

    # ===== Etapas da Web (Selenium) =====
    # Roda o mesmo fluxo do aprovar_transacao.robot, depois de o app concluir.
    Aprovar transação no WEB
    Ficar offline