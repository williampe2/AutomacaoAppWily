*** Settings ***
Resource         ../../../resources/shared/base.resource
Resource         ../../../resources/app/keywords/entrada_no_app.resource
Resource         ../../../resources/app/keywords/vistoria.resource

*** Test Cases ***
Vistoria Deve Ser Aceita E Concluída
    [Documentation]    Cenário feliz: Iniciar, aceitar a vistoria, iniciar o atendimento,
    ...                enviar fotos e vídeo e concluir.
    [Tags]    mobile    vistoria    smoke
    [Setup]    Preparar sessão de vistoria
    Given Iniciar
    Aceitar oferta
    Rolar até Iniciar vistoria
    Iniciar vistoria
    Enviar fotos
    Completar mídias e concluir

