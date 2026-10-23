*** Settings ***
Documentation     Aprovação da transação no sistema WEB.
Resource          ../Keywords/aprovar_transacao.resource
Resource          ../../../resources/shared/base.resource
Library           SeleniumLibrary

*** Test Cases ***
Cenario: Aceitar vistoria no App e validar recebimento de fotos no sistema WEB
    [Documentation]    Aprovação da transação no sistema WEB.
    [Teardown]    SeleniumLibrary.Close Browser
    Aprovar transação no WEB
