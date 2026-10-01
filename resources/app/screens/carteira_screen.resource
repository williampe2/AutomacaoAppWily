*** Settings ***
Documentation     Mapeamento dos elementos da tela de carteira do app.

*** Variables ***
${CARTEIRA_TITULO}           id=com.seuapp.qa:id/tv_carteira
${CARTEIRA_LISTA}            id=com.seuapp.qa:id/list_carteira
${CARTEIRA_ITEM}             xpath=//android.widget.TextView[contains(@text,'Carteira')]
