*** Settings ***
Documentation     Mapeamento dos elementos da tela de extrato do app.

*** Variables ***
# Home -> botão que abre o extrato (palpite: falta o dump da Home)
${EXTRATO_ABRIR}                  xpath=//android.view.ViewGroup[@resource-id="balance"]

# Tela Extrato
${EXTRATO_TITULO}                 xpath=//android.widget.TextView[@text="Extrato"]
${EXTRATO_SALDO_DISPONIVEL}       xpath=//android.widget.TextView[@text="Saldo disponível"]
${EXTRATO_VALOR_SALDO}            xpath=//android.widget.TextView[@text="Saldo disponível"]/following-sibling::android.widget.TextView[starts-with(@text,"R$")][1]
${EXTRATO_TRANSFERIR_SALDO}       xpath=//android.view.ViewGroup[contains(@content-desc,"Transferir saldo")]
${EXTRATO_CHAVE_PIX}              xpath=//android.view.ViewGroup[contains(@content-desc,"Chave PIX")]
${EXTRATO_VOLTAR_BOTAO}           xpath=//android.widget.ImageButton[@content-desc="Navegar para cima"]

# Tela Transferir saldo (PALPITES, falta o dump desta tela)
${TRANSFERIR_SALDO_TITULO}        xpath=//android.widget.TextView[@text="Nova transferência"]
${TRANSFERIR_SALDO_VALOR}         xpath=//android.widget.EditText