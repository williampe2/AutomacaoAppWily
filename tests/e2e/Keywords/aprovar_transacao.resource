*** Settings ***
Documentation     Keywords do fluxo de aprovação de transação no sistema WEB (operador).
...               Usado tanto pelo teste E2E quanto pelo aprovar_transacao.robot.
Library           SeleniumLibrary
Resource          ../../../resources/web_operador/keywords/vistoria.resource
Variables         ../../../config/env_qa.yaml
Variables         ../../../config/secrets.yaml
Variables         ../../../resources/data/perfis_usuarios.yaml

*** Keywords ***
Aprovar transação no WEB
    [Documentation]    Abre o navegador, acessa o sistema WEB, localiza o Wily,
    ...                preenche o formulário de diagnóstico e envia a aprovação.
    ...                Deve ser chamada DEPOIS de o app concluir a vistoria, para que
    ...                as fotos e o vídeo já estejam disponíveis no sistema WEB.
    ${email_web}=    Set Variable    ${web_login}[username]
    ${senha_web}=    Set Variable    ${web_login}[password]
    ${nome_wily}=    Set Variable    ${usuarios}[wily_DA][nome]

    SeleniumLibrary.Open Browser    about:blank    ${web}[browser]
    SeleniumLibrary.Maximize Browser Window

    Acessar sistema WEB e verificar login    ${email_web}    ${senha_web}
    Acessar a tela do Mapa de Wilys
    Localizar o Wily e abrir o modal de fotos    ${nome_wily}
    Preencher o formulário de diagnóstico e enviar