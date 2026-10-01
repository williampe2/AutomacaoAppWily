*** Settings ***
Documentation     Mapeamento dos elementos da tela de login do app.

*** Variables ***
${LOGIN_BTN_ACESSAR_CONTA}               id=welcome-screen-login
${LOGIN_USERNAME_INPUT}                  id=login-input-username
${LOGIN_PASSWORD_INPUT}                  id=login-password-input
${LOGIN_BTN_ENTRAR}                      id=login-button
${LOGIN_TXT_USUARIO_INVALIDO}            xpath=//android.widget.TextView[@text="Usuário inválida"] 
${LOGIN_BTN_ESQUECI_SENHA}               id=forget-password-button
${LOGIN_TXT_USUARIO_NAO_AUTORIZADO}      xpath=//android.widget.TextView[@text="Não autorizado"]




