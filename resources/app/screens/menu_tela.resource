*** Settings ***
Documentation     Mapeamento dos elementos do menu e das telas de dados pessoais do app.

*** Variables ***
# ---------- Home / Menu ----------
${MENU_BTN_ABRIR}                          xpath=//*[@resource-id="menu"]
${MENU_BTN_NAVEGAR_PARA_CIMA}              xpath=//android.widget.ImageButton[@content-desc="Navigate up"]
${MENU_ITEM_DADOS_PESSOAIS}                xpath=//android.view.ViewGroup[contains(@content-desc,"Dados pessoais")]

# ---------- Dados pessoais: lista ----------
${DADOS_PESSOAIS_BTN_VOLTAR}               xpath=//android.view.ViewGroup[@content-desc=""]
${DADOS_PESSOAIS_ITEM_NOME}                xpath=//android.view.ViewGroup[starts-with(@content-desc,"Nome,")]/android.view.ViewGroup
${DADOS_PESSOAIS_ITEM_CELULAR}             xpath=//android.view.ViewGroup[starts-with(@content-desc,"Celular,")]/android.view.ViewGroup
${DADOS_PESSOAIS_ITEM_CPF}                 xpath=//android.view.ViewGroup[starts-with(@content-desc,"CPF,")]/android.view.ViewGroup

# ---------- Dados pessoais: edição do nome ----------
${DADOS_PESSOAIS_NOME_INPUT}               xpath=//android.widget.EditText[@resource-id="your-name-input"]
${DADOS_PESSOAIS_NOME_BTN_ATUALIZAR}       accessibility_id=Atualizar nome
${DADOS_PESSOAIS_NOME_PLACEHOLDER}         Informe seu nome aqui

# ---------- Dados pessoais: edição do celular ----------
${DADOS_PESSOAIS_CELULAR_INPUT}            xpath=//android.widget.EditText[@resource-id="your-phone-input"]
${DADOS_PESSOAIS_CELULAR_BTN_LIMPAR}       xpath=//android.view.ViewGroup[@resource-id="clear-password"]
${DADOS_PESSOAIS_CELULAR_BTN_ATUALIZAR}    accessibility_id=Atualizar celular

# ---------- Dados pessoais: edição do CPF ----------
${DADOS_PESSOAIS_CPF_INPUT}                xpath=//android.widget.EditText[@resource-id="your-cpf-input"]
${DADOS_PESSOAIS_CPF_BTN_ATUALIZAR}        xpath=//android.view.ViewGroup[@content-desc="Atualizar CPF"]
