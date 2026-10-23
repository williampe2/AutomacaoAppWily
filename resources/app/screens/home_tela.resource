*** Settings ***
Documentation     Mapeamento dos elementos da tela inicial do app.

*** Variables ***
${HOME_BTN_MENU}             xpath=//android.view.ViewGroup[@resource-id="menu"]
${HOME_SALDO}                xpath=//android.view.ViewGroup[@resource-id="balance"]
${HOME_BTN_INICIAR}          xpath=//android.view.ViewGroup[@resource-id="start-button"]
${HOME_BTN_CHAT}             xpath=//android.view.ViewGroup[@resource-id="chat"]
${HOME_BTN_MINHA_LOCALIZACAO}    xpath=//android.view.ViewGroup[@resource-id="my-location"]
${HOME_MENU_VISTORIA}        xpath=//*[@text="Vistoria" or contains(@content-desc,"Vistoria")]
${HOME_MENU_EXTRATO}         xpath=//android.view.ViewGroup[@resource-id="balance"]
${HOME_MAPA}    xpath=//android.view.View[@content-desc="Mapa do Google"]