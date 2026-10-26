*** Settings ***
Documentation    Smoke test para validar a abertura do Wily na BrowserStack.
Resource         ../../../resources/shared/base.resource
Suite Teardown   Fechar Aplicativo Wily

*** Test Cases ***
Aplicativo Wily Deve Abrir No Dispositivo Remoto
    [Tags]    mobile    browserstack    smoke
    Abrir aplicativo    no_reset=${False}
    ${source}=    AppiumLibrary.Get Source
    Should Not Be Empty    ${source}
