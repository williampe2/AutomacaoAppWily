*** Settings ***
Documentation    Validar o fluxo de login no app 
Resource         ../../../resources/shared/base.resource
Resource         ../../../resources/app/actions/auth_actions.resource
Variables        ../../../config/secrets.yaml
Variables        ../../../resources/data/perfis_usuarios.yaml
Test Setup       Abrir Aplicativo Wily no Emulador
Test Teardown    Fechar Aplicativo Wily

*** Test Cases ***
Cenario: Login com sucesso
    [Documentation]    Validar o fluxo de login com sucesso no app.
    [Tags]    mobile    jornada_autenticacao
