*** Settings ***
# Lembre-se de importar o seu arquivo resource e o arquivo YAML de configuração
Resource         ../../resources/web_operador/keywords/vistoria.resource
Variables        ../../config/env_qa.yaml
Variables        ../../resources/data/perfis_usuarios.yaml 
Resource         ../../resources/shared/base.resource
Library          SeleniumLibrary

*** Test Cases ***
Cenario: Aceitar vistoria no App e validar recebimento de fotos no sistema WEB
    [Documentation]    Fluxo ponta a ponta (End-to-End) envolvendo Appium e Selenium.
    
    # Busca as credenciais no arquivo YAML
    ${name_wily_yaml}        Set Variable    ${usuarios}[wily_DA][nome]
    ${email_web_yaml}        Set Variable    ${web}[username]
    ${senha_web_yaml}        Set Variable    ${web}[password]

    # ==========================================================
    # 1. Etapas do Aplicativo (Appium)
    # (Suas keywords do Appium entram aqui no futuro)
    # ==========================================================
    
    # ==========================================================
    # 2. Etapas da Web (Selenium)
    # ==========================================================
    Open Browser    about:blank    chrome
    Maximize Browser Window

    Acessar sistema WEB e verificar login          ${email_web_yaml}    ${senha_web_yaml}
    
    Acessar a tela do Mapa de Wilys
    
    Localizar o Wily e abrir o modal de fotos      ${name_wily_yaml}
    
    Preencher o formulário de diagnóstico e enviar
    
    [Teardown]    Close Browser