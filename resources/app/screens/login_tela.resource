*** Settings ***
Documentation     Mapeamento dos elementos da tela de login do app.

*** Variables ***
${LOGIN_BTN_ACESSAR_CONTA}                       accessibility_id=Acessar conta
${LOGIN_INPUT_USERNAME}                          xpath=//android.widget.EditText[@resource-id="login-input-username"]
${LOGIN_BTN_AVANCAR}                             xpath=//android.view.ViewGroup[@content-desc=""]
${LOGIN_TXT_PASSWORD}                            xpath=//android.widget.EditText[@resource-id="login-password-input"]
${LOGIN_INPUT_PASSWORD}                          xpath=//android.widget.EditText[@resource-id="login-password-input"]
${LOGIN_BTN_ENTRAR}                              accessibility_id=Entrar
${LOGIN_TXT_USUARIO_INVALIDO}                    xpath=//android.widget.TextView[@text="Usuário inválida"] 
${LOGIN_TXT_USUARIO_NAO_AUTORIZADO}              xpath=//android.widget.TextView[@text="Não autorizado"]






