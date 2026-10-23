*** Settings ***
Documentation     Keywords de navegação e edição dos dados pessoais no app.
Library           AppiumLibrary
Resource          ../screens/menu_tela.resource
Resource          ./entrada_no_app.resource
Resource          ../../shared/base.resource
Resource          ../../shared/variables/common_variables.resource
Variables         ../../data/perfis_usuarios.yaml

*** Keywords ***
# ---------- Preparação da suíte ----------
Preparar dados pessoais
    [Documentation]    Abre o app, faz login se preciso, abre o menu e a lista de dados pessoais.
    ...    Garante que o nome salvo seja o do perfil (perfis_usuarios.yaml, usado na vistoria e na busca no sistema WEB).
    Set Suite Variable    ${NOME_DO_PERFIL}    ${usuarios}[wily_DA][nome]
    Abrir aplicativo    ${True}    ${True}    ${True}
    Garantir usuário logado
    Abrir dados pessoais
    Garantir nome salvo    ${NOME_DO_PERFIL}

Garantir usuário logado
    [Documentation]    Só faz login se o app não estiver já na Home. Trata também a
    ...    tela de boas-vindas ("Acessar conta"), que aparece com a sessão preservada.
    ${na_home}=    Elemento está visível    ${MENU_BTN_ABRIR}    5s
    IF    ${na_home}    RETURN
    ${boas_vindas}=    Elemento está visível    ${LOGIN_BTN_ACESSAR_CONTA}    5s
    IF    ${boas_vindas}
        Click Element    ${LOGIN_BTN_ACESSAR_CONTA}
        ${na_home}=    Elemento está visível    ${MENU_BTN_ABRIR}    10s
        IF    ${na_home}    RETURN
    END
    Realizar login

Garantir nome salvo
    [Documentation]    Estando na lista de dados pessoais, salva o nome informado caso o atual seja diferente.
    [Arguments]    ${nome_esperado}
    Abrir edição do nome
    ${nome_atual}=    Ler nome digitado
    IF    $nome_atual != $nome_esperado
        Salvar nome    ${nome_esperado}
    ELSE
        Voltar para dados pessoais
    END

Garantir nome do perfil
    [Documentation]    Assumindo o usuário logado na Home, garante o nome do perfil
    ...    (perfis_usuarios.yaml) e retorna à Home. Funciona mesmo sem o Suite Setup
    ...    "Preparar dados pessoais", pois lê o nome direto do YAML.
    Abrir dados pessoais
    Garantir nome salvo    ${usuarios}[wily_DA][nome]
    Voltar para a home

# ---------- Navegação ----------
Abrir menu
    [Documentation]    Abre o menu da Home, a menos que ele já esteja aberto.
    ${menu_aberto}=    Elemento está visível    ${MENU_ITEM_DADOS_PESSOAIS}
    IF    ${menu_aberto}    RETURN
    Wait Until Element Is Visible    ${MENU_BTN_ABRIR}    ${DEFAULT_TIMEOUT}s
    Click Element                    ${MENU_BTN_ABRIR}

Abrir dados pessoais
    [Documentation]    Abre a lista de dados pessoais pelo menu do app.
    Abrir menu
    Wait Until Element Is Visible    ${MENU_ITEM_DADOS_PESSOAIS}    ${DEFAULT_TIMEOUT}s
    Click Element                    ${MENU_ITEM_DADOS_PESSOAIS}

Tela de edição aberta
    [Documentation]    Retorna True se algum campo de edição (nome, celular ou CPF) está visível.
    ${nome}=       Elemento está visível    ${DADOS_PESSOAIS_NOME_INPUT}       1s
    ${celular}=    Elemento está visível    ${DADOS_PESSOAIS_CELULAR_INPUT}    1s
    ${cpf}=        Elemento está visível    ${DADOS_PESSOAIS_CPF_INPUT}        1s
    ${aberta}=     Evaluate    $nome or $celular or $cpf
    RETURN    ${aberta}

Garantir lista de dados pessoais
    [Documentation]    Leva até a lista de dados pessoais a partir de qualquer tela
    ...    (Home, menu, lista ou edição), sem desfazer alterações já salvas.
    ${na_lista}=    Elemento está visível    ${DADOS_PESSOAIS_ITEM_NOME}
    IF    ${na_lista}    RETURN
    ${em_edicao}=    Tela de edição aberta
    IF    ${em_edicao}
        Voltar para dados pessoais
    ELSE
        Abrir dados pessoais
    END

Abrir edição do nome
    [Documentation]    Abre a tela de edição do nome.
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_ITEM_NOME}    ${DEFAULT_TIMEOUT}s
    Click Element                    ${DADOS_PESSOAIS_ITEM_NOME}
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_NOME_INPUT}    ${DEFAULT_TIMEOUT}s

Abrir edição do celular
    [Documentation]    Abre a tela de edição do celular, garantindo a lista de dados pessoais.
    Garantir lista de dados pessoais
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_ITEM_CELULAR}    ${DEFAULT_TIMEOUT}s
    Click Element                    ${DADOS_PESSOAIS_ITEM_CELULAR}
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_CELULAR_INPUT}    ${DEFAULT_TIMEOUT}s

Abrir edição do CPF
    [Documentation]    Abre a tela de edição do CPF, garantindo a lista de dados pessoais.
    Garantir lista de dados pessoais
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_ITEM_CPF}    ${DEFAULT_TIMEOUT}s
    Click Element                    ${DADOS_PESSOAIS_ITEM_CPF}
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_CPF_INPUT}    ${DEFAULT_TIMEOUT}s

Voltar para dados pessoais
    [Documentation]    Retorna à lista sem salvar mudanças, a partir de uma tela de edição.
    ${na_lista}=    Elemento está visível    ${DADOS_PESSOAIS_ITEM_NOME}
    IF    ${na_lista}    RETURN
    Go Back
    ${na_lista}=    Elemento está visível    ${DADOS_PESSOAIS_ITEM_NOME}
    IF    not ${na_lista}
        Go Back
    END
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_ITEM_NOME}    ${DEFAULT_TIMEOUT}s

Voltar para a home
    [Documentation]    Retorna à Home usando o botão voltar do Android, a partir da edição,
    ...    da lista ou do menu. Para assim que a Home aparece (não sai do app).
    FOR    ${tentativa}    IN RANGE    5
        ${na_home}=    Elemento está visível    ${MENU_BTN_ABRIR}
        IF    ${na_home}    RETURN
        Go Back
    END
    Wait Until Element Is Visible    ${MENU_BTN_ABRIR}    ${DEFAULT_TIMEOUT}s

# ---------- Ações no campo de nome ----------
Substituir nome digitado
    [Documentation]    Limpa o campo de nome e digita o texto informado.
    [Arguments]    ${texto}
    Clear Text    ${DADOS_PESSOAIS_NOME_INPUT}
    Input Text    ${DADOS_PESSOAIS_NOME_INPUT}    ${texto}

Ler nome digitado
    [Documentation]    Retorna o texto atual do campo de nome.
    ${nome}=    Get Element Attribute    ${DADOS_PESSOAIS_NOME_INPUT}    text
    RETURN    ${nome}

Salvar nome
    [Documentation]    Digita o nome, confirma em "Atualizar nome" e aguarda o retorno à lista.
    [Arguments]    ${nome}
    Substituir nome digitado    ${nome}
    Validar atualização habilitada
    Click Element                    ${DADOS_PESSOAIS_NOME_BTN_ATUALIZAR}
    Wait Until Element Is Visible    ${DADOS_PESSOAIS_ITEM_NOME}    ${DEFAULT_TIMEOUT}s

Descartar alteração do nome
    [Documentation]    Se estiver na edição, devolve o nome do perfil ao campo sem submeter.
    ...    Em seguida garante a lista de dados pessoais. Tolerante: não falha se o teste
    ...    terminou antes de abrir a edição.
    ${em_edicao}=    Elemento está visível    ${DADOS_PESSOAIS_NOME_INPUT}
    IF    ${em_edicao}
        Substituir nome digitado    ${usuarios}[wily_DA][nome]
    END
    Garantir lista de dados pessoais

Restaurar nome do perfil salvo
    [Documentation]    Regrava o nome do perfil (perfis_usuarios.yaml), se necessário,
    ...    e retorna à Home para não afetar outros cenários.
    Garantir lista de dados pessoais
    Garantir nome salvo    ${usuarios}[wily_DA][nome]
    Voltar para a home

# ---------- Validações ----------
Validar atualização desabilitada
    [Documentation]    Verifica que o botão de atualizar o nome não pode ser usado.
    Element Attribute Should Match    ${DADOS_PESSOAIS_NOME_BTN_ATUALIZAR}    enabled    False

Validar atualização habilitada
    [Documentation]    Verifica que uma alteração válida do nome pode ser salva.
    Wait Until Keyword Succeeds    ${DEFAULT_TIMEOUT}s    500ms
    ...    Element Attribute Should Match    ${DADOS_PESSOAIS_NOME_BTN_ATUALIZAR}    enabled    True

Validar filtro do nome
    [Documentation]    Verifica que caracteres inválidos são removidos do campo
    ...    (o campo volta ao placeholder) e que a atualização segue desabilitada.
    [Arguments]    ${caracteres_invalidos}
    Substituir nome digitado    ${caracteres_invalidos}
    ${nome_digitado}=    Ler nome digitado
    Should Be Equal As Strings    ${nome_digitado}    ${DADOS_PESSOAIS_NOME_PLACEHOLDER}
    Validar atualização desabilitada

Validar celular inalterado
    [Documentation]    Verifica que o botão de celular não atualiza sem mudanças.
    Element Attribute Should Match    ${DADOS_PESSOAIS_CELULAR_BTN_ATUALIZAR}    enabled    False

Validar CPF inalterado
    [Documentation]    Verifica que o botão de CPF não atualiza sem mudanças.
    Element Attribute Should Match    ${DADOS_PESSOAIS_CPF_BTN_ATUALIZAR}    enabled    False

# ---------- Auxiliar ----------
Elemento está visível
    [Documentation]    Retorna True/False se o elemento aparece dentro do tempo informado.
    [Arguments]    ${locator}    ${tempo}=2s
    ${visivel}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${locator}    ${tempo}
    RETURN    ${visivel}