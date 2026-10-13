*** Settings ***
Library      SeleniumLibrary
Library      BuiltIn 
Variables    ../../../config/env_qa.yaml
Variables    ../../../resources/data/perfis_usuarios.yaml 
Variables    ../../data/perfis_usuarios.yaml 



*** Variables ***
# Variáveis de Mapeamento (Substitua pelos seletores reais do seu sistema)
${WEB_BTN_TERMOS}                   xpath=//*[@id="dpoeasy-banner"]//div/div[1]/div/section/div[3]/button[3]
${WEB_INPUT_EMAIL}                  name=email
${WEB_INPUT_SENHA}                  name=password
${WEB_BTN_LOGIN}                    name=login
${WEB_MENU_MAPA}                    xpath=//a[contains(normalize-space(), 'Mapa')]
${WEB_INDICADOR_LOGADO}             id=legendaMapaBtn
${WEB_BTN_ACESSA_FOTOS}             id=btn-accordion-photos
${WEB_SELECT_WILY_FILTRO}           id=willy-dispatchs-for-evaluation	        
${WEB_BTN_WILY_VISTOIRA}            xpath=//*[contains(text(), '${usuarios}[wily_DA][nome]')]
${WEB_BTN_DESBLOQUEAR}              id=btn-unlock-dispatch 
${WEB_SELECT_DIAGNOSTICO}           id=analize-image-performed
${WEB_BTN_ANALISE}                  xpath=//*[@id="div-select-analysis"]/span   
${WEB_OPCAO_ANALISE_TEXTO} 	        xpath=//li[contains(text(), 'Há vazamento de esgoto no local')] 
${WEB_RADIO_AVALIACAO_5}            xpath=//input[@name='radioRatingResolveOs' and @value='5']
${WEB_BTN_DIAGNOSTICO_ENVIAR}       id=btn-resove-os
${WEB_BTN_SCROOL}                   id=modal-analyze-images

*** Keywords ***
Acessar sistema WEB e verificar login
    [Documentation]    Acessa a URL legado, tenta fechar o LGPD e faz login.
    [Arguments]    ${EMAIL_WEB}    ${SENHA_WEB}

    SeleniumLibrary.Go To    ${web}[base_url_legado]

    Sleep    1s

    # TENTA CLICAR NO BANNER LGPD (SHADOW DOM)
    ${js_comando}=    Set Variable    document.querySelector("#dpoeasy-banner").shadowRoot.querySelector("button[data-action='accept']").click()
    Run Keyword And Ignore Error    SeleniumLibrary.Execute Javascript    ${js_comando}
    
    Sleep    1s

    # Verifica se já está logado procurando o menu do mapa
    ${esta_logado}=    Run Keyword And Return Status    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_MENU_MAPA}    1s
    
    IF    not ${esta_logado}
        SeleniumLibrary.Wait Until Element Is Visible    ${WEB_INPUT_EMAIL}    5s
        SeleniumLibrary.Input Text                       ${WEB_INPUT_EMAIL}    ${EMAIL_WEB}
        SeleniumLibrary.Input Password                   ${WEB_INPUT_SENHA}    ${SENHA_WEB}
        SeleniumLibrary.Click Element                    ${WEB_BTN_LOGIN}
        
        SeleniumLibrary.Wait Until Element Is Visible    ${WEB_MENU_MAPA}    5s
    ELSE
        Log    Usuário já está autenticado no sistema WEB.
    END
Acessar a tela do Mapa de Wilys
    [Documentation]    Clica no menu Mapa e valida o carregamento completo da página.
    
    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_MENU_MAPA}    10s
    SeleniumLibrary.Click Element                    ${WEB_MENU_MAPA}
    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_INDICADOR_LOGADO}    15s

Localizar o Wily e abrir o modal de fotos
    [Documentation]    Busca um Wily específico na tela usando um XPath dinâmico e clica nele.
    [Arguments]    ${NOME_WILY}
    
    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_BTN_ACESSA_FOTOS}    15s
    SeleniumLibrary.Click Element                    ${WEB_BTN_ACESSA_FOTOS}

    SeleniumLibrary.Wait Until Element Is Visible     ${WEB_SELECT_WILY_FILTRO}     10s 
    SeleniumLibrary.Select From List By Label     ${WEB_SELECT_WILY_FILTRO}     Todos 

    # Cria um localizador dinâmico com o nome do Wily (Ex: Procura o nome dentro de uma tabela/lista)
    ${elemento_wily}=    Set Variable    xpath=//*[contains(text(), '${usuarios}[wily_DA][nome]')]
    
    SeleniumLibrary.Wait Until Element Is Visible    ${elemento_wily}    15s
    SeleniumLibrary.Click Element                    ${elemento_wily}
    
    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_BTN_DESBLOQUEAR}   10s

Preencher o formulário de diagnóstico e enviar
    [Documentation]    Rola a tela até o formulário, preenche os campos e atualiza a OS.

    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_BTN_SCROOL}    10s
    SeleniumLibrary.Scroll Element Into View         ${WEB_BTN_SCROOL}

    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_SELECT_DIAGNOSTICO}    10s
    SeleniumLibrary.Select From List By Value        ${WEB_SELECT_DIAGNOSTICO}    5

    Sleep    1s
    
    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_BTN_ANALISE}    5s
    SeleniumLibrary.Click Element                    ${WEB_BTN_ANALISE}
    
    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_OPCAO_ANALISE_TEXTO}    5s
    SeleniumLibrary.Click Element                    ${WEB_OPCAO_ANALISE_TEXTO}
    
    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_RADIO_AVALIACAO_5}    5s
    SeleniumLibrary.Click Element                    ${WEB_RADIO_AVALIACAO_5}
    
    Sleep    1s

    SeleniumLibrary.Wait Until Element Is Visible    ${WEB_BTN_DIAGNOSTICO_ENVIAR}    5s
    SeleniumLibrary.Click Element                    ${WEB_BTN_DIAGNOSTICO_ENVIAR}

    sleep   1s

    