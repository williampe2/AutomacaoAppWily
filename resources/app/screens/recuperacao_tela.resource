*** Settings ***
Documentation     Mapeamento dos elementos da tela de recuperação de senha do app.

*** Variables ***

${RECUPERAR_SENHA_ESQUECI_SENHA}                 id=forget-password-button
${RECUPERAR_SENHA_INPUT_EMAIL}                   id=your-email-input
${RECUPERAR_SENHA_BTN_ENVIAR_CODIGO}             id=forget-password-next
${RECUPERAR_SENHA_INPUT_CODIGO}                  xpath=//android.widget.EditText[@resource-id="verification-code-input" and @text="1"]
${RECUPERAR_SENHA_INPUT_CODIGO_FINAL}            xpath=//android.widget.EditText[@resource-id="verification-code-input" and @text="7"]
${RECUPERAR_SENHA_BTN_REENVIAR_CODIGO}           id=active-account-resend-code-btn
${RECUPERAR_SENHA_BTN_CONTINUAR}                 id=create-password-button
${RECUPERAR_SENHA_INPUT_NOVA_SENHA}              id=create-password-input
${RECUPERAR_SENHA_INPUT_CONFIRMA_NOVA_SENHA}     id=confirm-password-input
${RECUPERAR_SENHA_TXT_SENHA_NAO_CONFERE}         xpath=//android.widget.TextView[@text="As senhas não conferem"]
${RECUPERAR_SENHA_BTN_CONFIRMAR}                 id=forgot-password-update-button
${RECUPERAR_SENHA_CODIGO_INVALIDO}               xpath=//android.widget.TextView[@text="Código não encontrado"]
${RECUPERAR_SENHA_BTN_ENVIAR_NOVO_CODIGO}        id=verification-code-continue-button





